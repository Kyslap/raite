import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/widgets/retro_top_bar.dart';
import '../../domain/study_models.dart';
import '../providers/study_deck_provider.dart';

class QuizPlayScreen extends ConsumerStatefulWidget {
  final String quizId;

  const QuizPlayScreen({super.key, required this.quizId});

  @override
  ConsumerState<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends ConsumerState<QuizPlayScreen> {
  int _currentIndex = 0;
  int? _selectedOptionIndex;
  bool _hasAnswered = false;
  int _correctAnswersCount = 0;
  bool _isQuizFinished = false;

  void _selectOption(int index, QuizQuestion question) {
    if (_hasAnswered) return;
    setState(() {
      _selectedOptionIndex = index;
      _hasAnswered = true;
      if (index == question.correctIndex) {
        _correctAnswersCount++;
      }
    });
  }

  void _nextQuestion(QuizDeck quiz) {
    if (_currentIndex < quiz.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOptionIndex = null;
        _hasAnswered = false;
      });
    } else {
      final finalScore =
          ((_correctAnswersCount / quiz.questions.length) * 100).round();
      ref
          .read(studyDeckProvider.notifier)
          .submitQuizResult(quiz.id, finalScore, quiz.questions.length);

      setState(() => _isQuizFinished = true);
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentIndex = 0;
      _selectedOptionIndex = null;
      _hasAnswered = false;
      _correctAnswersCount = 0;
      _isQuizFinished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(studyDeckProvider);

    final quiz = state.quizzes.firstWhere(
      (q) => q.id == widget.quizId,
      orElse: () => state.quizzes.first,
    );

    if (quiz.questions.isEmpty) {
      return Scaffold(
        appBar: RetroTopAppBar(title: 'Practice Quiz', subtitle: quiz.courseCode),
        body: const Center(child: Text('No questions available in this quiz.')),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: RetroTopAppBar(
        title: quiz.courseCode,
        subtitle: quiz.title,
        showStreak: true,
      ),
      body: _isQuizFinished
          ? _buildResultsView(context, quiz, theme, colorScheme)
          : _buildQuestionView(context, quiz, theme, colorScheme),
    );
  }

  Widget _buildQuestionView(
    BuildContext context,
    QuizDeck quiz,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final question = quiz.questions[_currentIndex];
    final progress = (_currentIndex + 1) / quiz.questions.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentIndex + 1} of ${quiz.questions.length}',
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
                  question.topic,
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
          const SizedBox(height: 20),

          // Question Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              question.question,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Options List
          Expanded(
            child: ListView.separated(
              itemCount: question.options.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final optionText = question.options[index];
                final isSelected = _selectedOptionIndex == index;
                final isCorrect = index == question.correctIndex;

                Color borderColor = colorScheme.outlineVariant.withValues(alpha: 0.6);
                Color bgColor = colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
                Widget? trailingIcon;

                if (_hasAnswered) {
                  if (isCorrect) {
                    borderColor = const Color(0xFF22C55E);
                    bgColor = const Color(0xFF22C55E).withValues(alpha: 0.12);
                    trailingIcon = const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 20);
                  } else if (isSelected) {
                    borderColor = const Color(0xFFEF4444);
                    bgColor = const Color(0xFFEF4444).withValues(alpha: 0.12);
                    trailingIcon = const Icon(Icons.cancel, color: Color(0xFFEF4444), size: 20);
                  }
                } else if (isSelected) {
                  borderColor = colorScheme.primary;
                  bgColor = colorScheme.primaryContainer.withValues(alpha: 0.2);
                }

                return InkWell(
                  onTap: _hasAnswered ? null : () => _selectOption(index, question),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: isSelected || (_hasAnswered && isCorrect) ? 1.8 : 1.0),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: borderColor),
                            color: isSelected
                                ? (_hasAnswered && isCorrect
                                    ? const Color(0xFF22C55E)
                                    : colorScheme.primary)
                                : Colors.transparent,
                          ),
                          child: Center(
                            child: Text(
                              String.fromCharCode(65 + index), // A, B, C, D
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            optionText,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        ?trailingIcon,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Explanation Banner (when answered)
          if (_hasAnswered) ...[
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: _selectedOptionIndex == question.correctIndex
                    ? const Color(0xFF22C55E).withValues(alpha: 0.1)
                    : const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _selectedOptionIndex == question.correctIndex
                      ? const Color(0xFF22C55E).withValues(alpha: 0.4)
                      : const Color(0xFFEF4444).withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _selectedOptionIndex == question.correctIndex
                        ? Icons.check_circle_outline
                        : Icons.info_outline,
                    size: 18,
                    color: _selectedOptionIndex == question.correctIndex
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFEF4444),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      question.explanation,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Bottom Action
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _hasAnswered ? () => _nextQuestion(quiz) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                _currentIndex == quiz.questions.length - 1 ? 'Finish Quiz' : 'Next Question',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildResultsView(
    BuildContext context,
    QuizDeck quiz,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final total = quiz.questions.length;
    final percentage = ((_correctAnswersCount / total) * 100).round();

    String grade = 'A';
    Color gradeColor = const Color(0xFF22C55E);
    String feedback = 'Outstanding! You have mastered these concepts.';

    if (percentage < 60) {
      grade = 'C';
      gradeColor = const Color(0xFFEF4444);
      feedback = 'Keep practicing! Review flashcards to reinforce key formulas.';
    } else if (percentage < 80) {
      grade = 'B';
      gradeColor = const Color(0xFFF59E0B);
      feedback = 'Solid performance! A quick review will get you to perfection.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: gradeColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Text(
                grade,
                style: TextStyle(
                  fontSize: 54,
                  fontWeight: FontWeight.w900,
                  color: gradeColor,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Quiz Completed!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You scored $_correctAnswersCount out of $total ($percentage%) in ${quiz.courseCode}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              feedback,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: colorScheme.outline, height: 1.4),
            ),
            const SizedBox(height: 20),

            // Streak Credit Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department_rounded, color: Color(0xFFF97316), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '+15 Mins Added to Daily Goal! 🔥',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _restartQuiz,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retake Quiz', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.check),
                    label: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
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
