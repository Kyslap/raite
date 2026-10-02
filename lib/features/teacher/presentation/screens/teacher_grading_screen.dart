import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/assignment_model.dart';
import '../providers/teacher_lesson_provider.dart';
import '../providers/teacher_class_hub_provider.dart';
import '../../../class/domain/student_submission_model.dart';

class TeacherGradingScreen extends ConsumerStatefulWidget {
  final AssignmentModel assignment;
  final TeacherClass teacherClass;

  const TeacherGradingScreen({
    super.key,
    required this.assignment,
    required this.teacherClass,
  });

  @override
  ConsumerState<TeacherGradingScreen> createState() =>
      _TeacherGradingScreenState();
}

class _TeacherGradingScreenState extends ConsumerState<TeacherGradingScreen> {
  String _selectedFilter = 'All'; // 'All', 'Needs Grading', 'Graded', 'Missing'

  // Map of controllers for each submission: submissionId -> TextEditingController
  final Map<String, TextEditingController> _gradeControllers = {};
  final Map<String, TextEditingController> _feedbackControllers = {};

  @override
  void dispose() {
    for (final c in _gradeControllers.values) {
      c.dispose();
    }
    for (final c in _feedbackControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _showPdfPreview(String fileName) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Icon(Icons.picture_as_pdf_rounded, color: colorScheme.primary, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fileName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Student Attachment Preview',
                          style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.description, size: 48, color: colorScheme.primary),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        fileName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Student submitted work verified • Ready for grading',
                        style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Return to Grading'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveGrade(StudentSubmissionModel sub) {
    final gradeText = _gradeControllers[sub.id]?.text.trim() ?? '';
    final feedbackText = _feedbackControllers[sub.id]?.text.trim() ?? '';

    if (gradeText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a grade score (e.g. 95)'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    ref.read(teacherSubmissionsProvider.notifier).gradeSubmission(
          submissionId: sub.id,
          grade: gradeText,
          feedback: feedbackText.isNotEmpty ? feedbackText : null,
        );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Grade and feedback saved for ${sub.studentName}!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final allSubmissions = ref.watch(teacherSubmissionsProvider);

    // Filter submissions matching this assignment
    final directMatches = allSubmissions
        .where((s) => s.assignmentId == widget.assignment.id)
        .toList();

    final assignmentSubmissions = directMatches.isNotEmpty
        ? directMatches
        : allSubmissions.where((s) => s.assignmentId == 'asg-demo-1').toList();

    // Derived statistics
    final totalStudents = widget.teacherClass.studentCount > 0
        ? widget.teacherClass.studentCount
        : assignmentSubmissions.length;

    final turnedInCount =
        assignmentSubmissions.where((s) => s.status != 'missing').length;

    final gradedCount =
        assignmentSubmissions.where((s) => s.grade != null).length;

    final needsGradingCount =
        assignmentSubmissions.where((s) => s.status == 'submitted' && s.grade == null).length;

    final missingCount =
        assignmentSubmissions.where((s) => s.status == 'missing').length;

    // Filtered list
    final displayedSubmissions = assignmentSubmissions.where((s) {
      if (_selectedFilter == 'Turned In') return s.status != 'missing';
      if (_selectedFilter == 'Needs Grading') return s.status == 'submitted' && s.grade == null;
      if (_selectedFilter == 'Graded') return s.grade != null;
      if (_selectedFilter == 'Missing') return s.status == 'missing';
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Grade & Review Turn-ins',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              '${widget.assignment.title} • Max ${widget.assignment.points} pts',
              style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.playlist_add_check_rounded, color: colorScheme.primary),
            tooltip: 'Grade all turned-in at 100%',
            onPressed: () {
              for (final sub in assignmentSubmissions) {
                if (sub.status != 'missing' && sub.grade == null) {
                  ref.read(teacherSubmissionsProvider.notifier).gradeSubmission(
                        submissionId: sub.id,
                        grade: '${widget.assignment.points}',
                        feedback: 'Full credit awarded for complete on-time turn in.',
                      );
                }
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('🎉 Full credit recorded for all un-graded turn-ins!'),
                  backgroundColor: colorScheme.primary,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // 1. Assignment Context Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.assignment.category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 14, color: colorScheme.outline),
                        const SizedBox(width: 4),
                        Text(
                          'Due: ${widget.assignment.dueDate}',
                          style: TextStyle(fontSize: 11, color: colorScheme.outline, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                if (widget.assignment.instructions.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    widget.assignment.instructions,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 14),

                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _MiniTurnInStat(
                      label: 'Class Size',
                      value: '$totalStudents',
                      colorScheme: colorScheme,
                    ),
                    _MiniTurnInStat(
                      label: 'Turned In',
                      value: '$turnedInCount',
                      colorScheme: colorScheme,
                      textColor: const Color(0xFF10B981),
                    ),
                    _MiniTurnInStat(
                      label: 'Graded',
                      value: '$gradedCount',
                      colorScheme: colorScheme,
                      textColor: colorScheme.primary,
                    ),
                    _MiniTurnInStat(
                      label: 'Missing',
                      value: '$missingCount',
                      colorScheme: colorScheme,
                      textColor: colorScheme.error,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. Filter Pills Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'All (${assignmentSubmissions.length})',
                  isSelected: _selectedFilter == 'All',
                  onTap: () => setState(() => _selectedFilter = 'All'),
                  colorScheme: colorScheme,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Needs Grading ($needsGradingCount)',
                  isSelected: _selectedFilter == 'Needs Grading',
                  onTap: () => setState(() => _selectedFilter = 'Needs Grading'),
                  colorScheme: colorScheme,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Graded ($gradedCount)',
                  isSelected: _selectedFilter == 'Graded',
                  onTap: () => setState(() => _selectedFilter = 'Graded'),
                  colorScheme: colorScheme,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Missing ($missingCount)',
                  isSelected: _selectedFilter == 'Missing',
                  onTap: () => setState(() => _selectedFilter = 'Missing'),
                  colorScheme: colorScheme,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Submissions List
          if (displayedSubmissions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined, size: 48, color: colorScheme.outline),
                    const SizedBox(height: 12),
                    Text(
                      'No submissions in this filter category.',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            )
          else
            ...displayedSubmissions.map((sub) {
              // Ensure controllers exist
              _gradeControllers.putIfAbsent(
                sub.id,
                () => TextEditingController(text: sub.grade ?? ''),
              );
              _feedbackControllers.putIfAbsent(
                sub.id,
                () => TextEditingController(text: sub.feedback ?? ''),
              );

              final isGraded = sub.grade != null;
              final isMissing = sub.status == 'missing';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isGraded
                        ? colorScheme.primary.withValues(alpha: 0.3)
                        : colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Student Header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: isMissing
                              ? colorScheme.outlineVariant
                              : colorScheme.primaryContainer,
                          child: Text(
                            sub.studentName.isNotEmpty ? sub.studentName[0].toUpperCase() : 'S',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isMissing
                                  ? colorScheme.onSurfaceVariant
                                  : colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sub.studentName,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                sub.studentEmail,
                                style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        // Status Badge
                        if (isGraded)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle, size: 14, color: colorScheme.primary),
                                const SizedBox(width: 4),
                                Text(
                                  '${sub.grade}/${widget.assignment.points}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (isMissing)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.errorContainer.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Missing',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onErrorContainer,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                            ),
                            child: const Text(
                              'Turned In',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ),
                      ],
                    ),

                    if (!isMissing) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 13, color: colorScheme.outline),
                          const SizedBox(width: 4),
                          Text(
                            'Turned in ${DateFormat('MMM d, h:mm a').format(sub.submittedAt)}',
                            style: TextStyle(fontSize: 11, color: colorScheme.outline),
                          ),
                        ],
                      ),
                    ],

                    // Attached File
                    if (sub.attachedFileName != null) ...[
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () => _showPdfPreview(sub.attachedFileName!),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.picture_as_pdf_rounded, size: 16, color: colorScheme.primary),
                              const SizedBox(width: 8),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 200),
                                child: Text(
                                  sub.attachedFileName!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.visibility_outlined, size: 14, color: colorScheme.outline),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // Student note if present
                    if (sub.note.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '"${sub.note}"',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],

                    // Grading Form (for non-missing submissions)
                    if (!isMissing) ...[
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: _gradeControllers[sub.id],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Score',
                                hintText: '${widget.assignment.points}',
                                suffixText: '/ ${widget.assignment.points}',
                                isDense: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 7,
                            child: TextField(
                              controller: _feedbackControllers[sub.id],
                              decoration: InputDecoration(
                                labelText: 'Teacher Feedback',
                                hintText: 'e.g. Well done on proofs!',
                                isDense: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () => _saveGrade(sub),
                          icon: const Icon(Icons.check, size: 14),
                          label: Text(
                            isGraded ? 'Update Grade' : 'Record Grade',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _MiniTurnInStat extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme colorScheme;
  final Color? textColor;

  const _MiniTurnInStat({
    required this.label,
    required this.value,
    required this.colorScheme,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor ?? colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
