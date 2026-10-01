import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/widgets/retro_top_bar.dart';
import '../../domain/study_models.dart';
import '../providers/study_deck_provider.dart';

class FlashcardStudyScreen extends ConsumerStatefulWidget {
  final String deckId;

  const FlashcardStudyScreen({super.key, required this.deckId});

  @override
  ConsumerState<FlashcardStudyScreen> createState() => _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends ConsumerState<FlashcardStudyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isFront = true;
  int _currentIndex = 0;
  final List<String> _masteredCardIds = [];
  bool _isSessionFinished = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFront) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    setState(() => _isFront = !_isFront);
  }

  void _nextCard(MasteryStatus status, FlashcardDeck deck) {
    final currentCard = deck.cards[_currentIndex];
    ref
        .read(studyDeckProvider.notifier)
        .updateMastery(deck.id, currentCard.id, status);

    if (status == MasteryStatus.mastered && !_masteredCardIds.contains(currentCard.id)) {
      _masteredCardIds.add(currentCard.id);
    }

    if (_currentIndex < deck.cards.length - 1) {
      if (!_isFront) {
        _flipController.reverse();
        _isFront = true;
      }
      setState(() => _currentIndex++);
    } else {
      setState(() => _isSessionFinished = true);
    }
  }

  void _restartSession() {
    if (!_isFront) {
      _flipController.reverse();
      _isFront = true;
    }
    setState(() {
      _currentIndex = 0;
      _isSessionFinished = false;
      _masteredCardIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(studyDeckProvider);

    final deck = state.decks.firstWhere(
      (d) => d.id == widget.deckId,
      orElse: () => state.decks.first,
    );

    if (deck.cards.isEmpty) {
      return Scaffold(
        appBar: RetroTopAppBar(
          title: 'Flashcards',
          subtitle: deck.courseCode,
          showStreak: true,
        ),
        body: const Center(child: Text('No flashcards found in this deck.')),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: RetroTopAppBar(
        title: deck.courseCode,
        subtitle: deck.title,
        showStreak: true,
      ),
      body: _isSessionFinished
          ? _buildCompletionView(context, deck, theme, colorScheme)
          : _buildStudyView(context, deck, theme, colorScheme),
    );
  }

  Widget _buildStudyView(
    BuildContext context,
    FlashcardDeck deck,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final card = deck.cards[_currentIndex];
    final progress = (_currentIndex + 1) / deck.cards.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        children: [
          // 1. Progress Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Card ${_currentIndex + 1} of ${deck.cards.length}',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  card.topic,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
          const SizedBox(height: 24),

          // 2. Interactive Flip Flashcard
          Expanded(
            child: GestureDetector(
              onTap: _flipCard,
              child: AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) {
                  final angle = _flipAnimation.value * pi;
                  final isUnder = angle > (pi / 2);

                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle),
                    child: isUnder
                        ? Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(pi),
                            child: _buildCardBack(card, theme, colorScheme),
                          )
                        : _buildCardFront(card, theme, colorScheme),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Flip Hint
          Text(
            '💡 Tap card to flip between Question and Answer',
            style: TextStyle(fontSize: 12, color: colorScheme.outline),
          ),
          const SizedBox(height: 20),

          // 3. Self-Rating Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _nextCard(MasteryStatus.learning, deck),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.12),
                    foregroundColor: const Color(0xFFDC2626),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                    ),
                  ),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Still Learning', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _nextCard(MasteryStatus.reviewing, deck),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    foregroundColor: const Color(0xFFD97706),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(color: Color(0xFFFCD34D)),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Good', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _nextCard(MasteryStatus.mastered, deck),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Mastered', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildCardFront(Flashcard card, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.quiz_outlined, size: 36, color: colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'QUESTION / CONCEPT',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.outline,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            card.front,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(Flashcard card, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle_outline, size: 32, color: colorScheme.onPrimaryContainer),
          ),
          const SizedBox(height: 14),
          Text(
            'EXPLANATION & SOLUTION',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            child: Text(
              card.back,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onPrimaryContainer,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionView(
    BuildContext context,
    FlashcardDeck deck,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final masteredCount = _masteredCardIds.length;
    final total = deck.cards.length;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emoji_events_rounded, size: 64, color: Color(0xFF22C55E)),
            ),
            const SizedBox(height: 20),
            Text(
              'Deck Review Complete! 🎉',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You reviewed all $total cards in ${deck.courseCode}. Mastered $masteredCount cards during this study session!',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.outline, height: 1.4),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _restartSession,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Review Again', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    icon: const Icon(Icons.done),
                    label: const Text('Finished', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
