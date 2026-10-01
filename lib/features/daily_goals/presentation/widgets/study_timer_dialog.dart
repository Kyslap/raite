import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/daily_goals_provider.dart';

class StudyTimerDialog extends ConsumerStatefulWidget {
  const StudyTimerDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const StudyTimerDialog(),
    );
  }

  @override
  ConsumerState<StudyTimerDialog> createState() => _StudyTimerDialogState();
}

class _StudyTimerDialogState extends ConsumerState<StudyTimerDialog> {
  int _selectedDurationMinutes = 15;
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;
  bool _isCompleted = false;

  final TextEditingController _offlineNoteController = TextEditingController();
  int _offlineMinutes = 15;
  int _selectedTab = 0; // 0 = Live Timer, 1 = Quick Log

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _selectedDurationMinutes * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _offlineNoteController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
        setState(() {
          _isRunning = false;
          _isCompleted = true;
        });
        ref
            .read(dailyGoalsProvider.notifier)
            .recordFocusSessionCompleted(_selectedDurationMinutes);
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isCompleted = false;
      _remainingSeconds = _selectedDurationMinutes * 60;
    });
  }

  void _finishEarly() {
    _timer?.cancel();
    final elapsedMinutes =
        ((_selectedDurationMinutes * 60 - _remainingSeconds) / 60).ceil();
    if (elapsedMinutes > 0) {
      ref
          .read(dailyGoalsProvider.notifier)
          .recordFocusSessionCompleted(elapsedMinutes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Added $elapsedMinutes mins to your Daily Goal!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    final totalSeconds = _selectedDurationMinutes * 60;
    final progress = totalSeconds > 0
        ? (1.0 - (_remainingSeconds / totalSeconds)).clamp(0.0, 1.0)
        : 0.0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: colorScheme.surface,
      elevation: 8,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.timer_outlined, color: colorScheme.primary, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Study Desk Focus',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    if (_isRunning) {
                      _showExitConfirmDialog();
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tab switcher: Timer vs Quick Log
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _isRunning ? null : () => setState(() => _selectedTab = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedTab == 0
                              ? colorScheme.surface
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _selectedTab == 0
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'Live Focus Timer',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _selectedTab == 0
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: _isRunning ? null : () => setState(() => _selectedTab = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedTab == 1
                              ? colorScheme.surface
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _selectedTab == 1
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'Quick Log Minutes',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _selectedTab == 1
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (_selectedTab == 0) ...[
              // Duration selector pills (only visible when paused or not started)
              if (!_isRunning && !_isCompleted) ...[
                Wrap(
                  spacing: 8,
                  children: [10, 15, 25, 45].map((mins) {
                    final isSel = _selectedDurationMinutes == mins;
                    return ChoiceChip(
                      label: Text('$mins min'),
                      selected: isSel,
                      selectedColor: colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSel ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                      ),
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _selectedDurationMinutes = mins;
                            _remainingSeconds = mins * 60;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],

              // Circular Countdown Visual
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 170,
                    height: 170,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 10,
                      backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _isCompleted ? const Color(0xFF22C55E) : colorScheme.primary,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isCompleted) ...[
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 48),
                        const SizedBox(height: 6),
                        const Text(
                          'Goal Achieved!',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ] else ...[
                        Text(
                          '$minutes:$seconds',
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          _isRunning ? 'Deep Focus...' : 'Ready to study',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.outline,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Control buttons
              if (_isCompleted) ...[
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    minimumSize: const Size(double.infinity, 46),
                  ),
                  icon: const Icon(Icons.done_all, size: 20),
                  label: const Text('Back to Study Desk', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isRunning || _remainingSeconds < totalSeconds)
                      IconButton.filledTonal(
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Reset',
                        onPressed: _resetTimer,
                      ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _isRunning ? _pauseTimer : _startTimer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isRunning
                            ? colorScheme.secondaryContainer
                            : colorScheme.primary,
                        foregroundColor: _isRunning
                            ? colorScheme.onSecondaryContainer
                            : colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      icon: Icon(_isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 24),
                      label: Text(
                        _isRunning ? 'Pause' : 'Start Focus',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    if (_isRunning || _remainingSeconds < totalSeconds) ...[
                      const SizedBox(width: 16),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.stop_rounded),
                        tooltip: 'Complete Early',
                        onPressed: _finishEarly,
                      ),
                    ],
                  ],
                ),
              ],
            ] else ...[
              // Quick Log Tab
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Log Offline Study Minutes',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Studied using textbooks, paper notes, or attended a lecture? Add your time here:',
                    style: TextStyle(fontSize: 12, color: colorScheme.outline),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: [10, 15, 30, 45, 60].map((m) {
                      final isSel = _offlineMinutes == m;
                      return ChoiceChip(
                        label: Text('+$m mins'),
                        selected: isSel,
                        selectedColor: colorScheme.primaryContainer,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSel ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                        ),
                        onSelected: (val) {
                          if (val) setState(() => _offlineMinutes = m);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _offlineNoteController,
                    decoration: InputDecoration(
                      hintText: 'What did you study? (e.g. Chapter 4 Quiz Review)',
                      hintStyle: const TextStyle(fontSize: 12),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerLow,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.outlineVariant),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(dailyGoalsProvider.notifier).logOfflineStudy(
                            _offlineMinutes,
                            _offlineNoteController.text.trim(),
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('🎉 Added +$_offlineMinutes mins to your Daily Goal!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      minimumSize: const Size(double.infinity, 44),
                    ),
                    child: Text('Add +$_offlineMinutes Minutes', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showExitConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave Focus Session?'),
        content: const Text(
          'Your active focus timer is still running. Would you like to log the time completed so far or discard it?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _finishEarly();
            },
            child: const Text('Save & Exit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Discard', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
