import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:raite/features/auth/presentation/providers/auth_provider.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../ai_tutor/data/knowledge_base_repository.dart';
import '../../../ai_tutor/presentation/providers/ai_tutor_provider.dart';
import '../providers/teacher_lesson_provider.dart';
import '../providers/teacher_insights_provider.dart';
import 'teacher_class_detail_screen.dart';
import 'package:raite/features/hive_mind/presentation/widgets/hive_mind_report_card.dart';

class TeacherClassesScreen extends ConsumerStatefulWidget {
  final Function(int)? onNavigateTab;

  const TeacherClassesScreen({super.key, this.onNavigateTab});

  @override
  ConsumerState<TeacherClassesScreen> createState() => _TeacherClassesScreenState();
}

class _TeacherClassesScreenState extends ConsumerState<TeacherClassesScreen> {
  TeacherClass? _selectedClass;

  void _showDeleteClassDialog(TeacherClass cls) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: colorScheme.error, size: 28),
            const SizedBox(width: 10),
            const Text('Delete Class?'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${cls.title}"?\n\n'
          'This will permanently delete the class, its lessons, materials, and student enrollments. This cannot be undone.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (_selectedClass?.id == cls.id) {
                setState(() => _selectedClass = null);
              }
              await ref.read(teacherClassesProvider.notifier).deleteClass(cls.id);
              ref.read(teacherLessonsProvider.notifier).removeLessonsForClass(cls.id);

              if (!mounted) return;
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🗑️ Class "${cls.title}" deleted.'),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete Class', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadMaterial(BuildContext context, WidgetRef ref, String classId) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt', 'md', 'csv'],
      );

      if (result.isNotEmpty && result.first.path != null) {
        File file = File(result.first.path!);

        if (!context.mounted) return;
        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: colorScheme.surface,
            content: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    'Uploading and processing into AI Brain...',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                ),
              ],
            ),
          ),
        );

        final repo = KnowledgeBaseRepository();
        await repo.uploadClassMaterial(classId, file);
        ref.invalidate(classDocumentsProvider(classId));

        // Close loading dialog
        if (context.mounted) Navigator.pop(context);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✅ Material added to AI Brain successfully!'),
              backgroundColor: colorScheme.primary,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context); // Close dialog if open
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload: $e'),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    }
  }

  void _showCreateClassSheet() {
    final titleController = TextEditingController();
    final deptController = TextEditingController();
    final codeController = TextEditingController();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    bool isCreating = false;
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.school,
                              color: colorScheme.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Create New Class',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Class Title',
                      hintText: 'e.g. Intro to Astrophysics',
                      filled: true,
                      fillColor: colorScheme.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: deptController,
                    decoration: InputDecoration(
                      labelText: 'Department / Track',
                      hintText: 'e.g. Physics & Astronomy',
                      filled: true,
                      fillColor: colorScheme.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: codeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: 'Custom Join Code (Optional)',
                      hintText:
                          'e.g. ASTRO-101 (or leave blank to auto-generate)',
                      filled: true,
                      fillColor: colorScheme.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.key, size: 18),
                    ),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer.withValues(
                          alpha: 0.4,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: colorScheme.error.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        errorMessage!,
                        style: TextStyle(
                          color: colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isCreating
                        ? null
                        : () async {
                            final title = titleController.text.trim();
                            final dept = deptController.text.trim();
                            final customCode = codeController.text.trim();

                            if (title.isEmpty) {
                              setSheetState(
                                () =>
                                    errorMessage = 'Please enter a class title',
                              );
                              return;
                            }

                            setSheetState(() {
                              isCreating = true;
                              errorMessage = null;
                            });

                            try {
                              final newCls = await ref
                                  .read(teacherClassesProvider.notifier)
                                  .addClass(
                                    title: title,
                                    department: dept.isNotEmpty
                                        ? dept
                                        : 'General Studies',
                                    customCode: customCode.isNotEmpty
                                        ? customCode
                                        : null,
                                  );

                              if (!ctx.mounted) return;
                              Navigator.pop(ctx);

                              Clipboard.setData(ClipboardData(text: newCls.code));
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.white, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text('🎉 Class created! Join code ${newCls.code} copied to clipboard.'),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: colorScheme.primary,
                                  duration: const Duration(seconds: 3),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            } catch (e) {
                              setSheetState(() {
                                isCreating = false;
                                errorMessage =
                                    'Error saving to Supabase:\n$e\n\nEnsure you have run the database setup in Supabase SQL editor.';
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isCreating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Create Class & Generate Code',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final classes = ref.watch(teacherClassesProvider);
    final lessons = ref.watch(teacherLessonsProvider);

    // Keep bottom navigation bar visible by rendering detail screen in-place
    if (_selectedClass != null) {
      final matching = classes.where((c) => c.id == _selectedClass!.id);
      if (matching.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _selectedClass = null);
        });
      } else {
        return TeacherClassDetailScreen(
          teacherClass: matching.first,
          onBack: () {
            setState(() {
              _selectedClass = null;
            });
          },
        );
      }
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My Managed Classes',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle, color: colorScheme.primary, size: 28),
            tooltip: 'Create New Class',
            onPressed: _showCreateClassSheet,
          ),
          IconButton(
            icon: Icon(Icons.logout, color: colorScheme.onSurfaceVariant),
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) context.go('/');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: classes.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withValues(
                          alpha: 0.3,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.school_outlined,
                        size: 56,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No Classes Created Yet',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the button below to create your first class and generate an invite code for your students.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _showCreateClassSheet,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Create Your First Class'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              itemCount: classes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final cls = classes[index];
                final classLessons = lessons
                    .where((l) => l.classId == cls.id)
                    .toList();

                return Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.onSurface.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedClass = cls;
                        });
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Class Header
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    Icons.menu_book,
                                    color: colorScheme.onPrimaryContainer,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cls.title,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.onSurface,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${cls.department} • ${cls.studentCount} Students Enrolled',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      // Mobile-Optimized Join Code Badge with 1-Tap Copy
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Clipboard.setData(
                                                ClipboardData(text: cls.code),
                                              );
                                              ScaffoldMessenger.of(
                                                context,
                                              ).hideCurrentSnackBar();
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    '📋 Code ${cls.code} copied to clipboard!',
                                                  ),
                                                  duration: const Duration(
                                                    milliseconds: 1500,
                                                  ),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(10),
                                                  ),
                                                ),
                                              );
                                            },
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: colorScheme.primary
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: colorScheme.primary
                                                      .withValues(alpha: 0.3),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.key,
                                                    size: 14,
                                                    color: colorScheme.primary,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    'CODE: ${cls.code}',
                                                    style: TextStyle(
                                                      color: colorScheme.primary,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Icon(
                                                    Icons.copy,
                                                    size: 13,
                                                    color: colorScheme.primary,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.share_outlined,
                                              size: 18,
                                            ),
                                            tooltip: 'Share Invite',
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () {
                                              final shareMsg =
                                                  'Join my class "${cls.title}" on Raite using code: ${cls.code}';
                                              Clipboard.setData(
                                                ClipboardData(text: shareMsg),
                                              );
                                              ScaffoldMessenger.of(
                                                context,
                                              ).hideCurrentSnackBar();
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Invite message copied: "$shareMsg"',
                                                  ),
                                                  duration: const Duration(
                                                    milliseconds: 1500,
                                                  ),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(10),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: Icon(
                                    Icons.more_vert,
                                    color: colorScheme.outline,
                                    size: 20,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  onSelected: (val) {
                                    if (val == 'open') {
                                      setState(() {
                                        _selectedClass = cls;
                                      });
                                    } else if (val == 'copy_code') {
                                      Clipboard.setData(
                                        ClipboardData(text: cls.code),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).hideCurrentSnackBar();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '📋 Code ${cls.code} copied!',
                                          ),
                                          duration: const Duration(
                                            milliseconds: 1500,
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    } else if (val == 'delete') {
                                      _showDeleteClassDialog(cls);
                                    }
                                  },
                                  itemBuilder: (ctx) => [
                                    const PopupMenuItem(
                                      value: 'open',
                                      child: Row(
                                        children: [
                                          Icon(Icons.hub_outlined, size: 18),
                                          SizedBox(width: 10),
                                          Text('Open Class Hub (Teams)'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'copy_code',
                                      child: Row(
                                        children: [
                                          Icon(Icons.key, size: 18),
                                          SizedBox(width: 10),
                                          Text('Copy Join Code'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuDivider(),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete_outline,
                                            color: colorScheme.error,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Delete Class',
                                            style: TextStyle(
                                              color: colorScheme.error,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),

                          // Lessons in this class
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Published Lessons (${classLessons.length})',
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        if (widget.onNavigateTab != null) {
                                          widget.onNavigateTab!(2);
                                        }
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.add,
                                            size: 14,
                                            color: colorScheme.primary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Add Lesson',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                if (classLessons.isEmpty)
                                  Text(
                                    'No lessons published yet. Post your first lesson to engage students!',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.outline,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  )
                                else
                                  ...classLessons.map((l) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.check_circle,
                                                color: Color(0xFF10B981),
                                                size: 16,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  l.title,
                                                  style: theme
                                                      .textTheme.bodyMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                              ),
                                              Text(
                                                l.estimatedMinutes,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: colorScheme.outline,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (l.attachments.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 24.0),
                                              child: Wrap(
                                                spacing: 6,
                                                runSpacing: 4,
                                                children: l.attachments.map((att) {
                                                  final isPdf = att.fileType
                                                      .toLowerCase()
                                                      .contains('pdf');
                                                  final isPpt = att.fileType
                                                      .toLowerCase()
                                                      .contains('ppt');
                                                  return Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 3),
                                                    decoration: BoxDecoration(
                                                      color: isPpt
                                                          ? Colors.orange
                                                              .withValues(alpha: 0.12)
                                                          : isPdf
                                                              ? Colors.red
                                                                  .withValues(alpha: 0.12)
                                                              : colorScheme.primary
                                                                  .withValues(alpha: 0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(6),
                                                      border: Border.all(
                                                        color: isPpt
                                                            ? Colors.orange
                                                                .withValues(alpha: 0.3)
                                                            : isPdf
                                                                ? Colors.red
                                                                    .withValues(alpha: 0.3)
                                                                : colorScheme.primary
                                                                    .withValues(alpha: 0.2),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          isPpt
                                                              ? Icons.slideshow_rounded
                                                              : isPdf
                                                                  ? Icons.picture_as_pdf_rounded
                                                                  : Icons.attach_file_rounded,
                                                          size: 13,
                                                          color: isPpt
                                                              ? Colors.orange.shade800
                                                              : isPdf
                                                                  ? Colors.red.shade800
                                                                  : colorScheme.primary,
                                                        ),
                                                        const SizedBox(width: 4),
                                                        ConstrainedBox(
                                                          constraints:
                                                              const BoxConstraints(
                                                                  maxWidth: 180),
                                                          child: Text(
                                                            att.name,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight.w600,
                                                              color: isPpt
                                                                  ? Colors.orange.shade900
                                                                  : isPdf
                                                                      ? Colors.red.shade900
                                                                      : colorScheme.primary,
                                                            ),
                                                          ),
                                                        ),
                                                        if (att.formattedSize.isNotEmpty) ...[
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            '(${att.formattedSize})',
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              color:
                                                                  colorScheme.outline,
                                                            ),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    );
                                  }),
                              ],
                            ),
                          ),
                          const Divider(height: 1),

                          // AI Brain / Knowledge Base
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'AI Brain Knowledge Base',
                                      style:
                                          theme.textTheme.labelMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Upload text materials to teach your class\'s AI Tutor new context.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.outline,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () =>
                                        _uploadMaterial(context, ref, cls.id),
                                    icon: Icon(
                                      Icons.upload_file,
                                      size: 16,
                                      color: colorScheme.primary,
                                    ),
                                    label: Text(
                                      'Upload Material (.pdf, .txt, .md, .csv)',
                                      style:
                                          TextStyle(color: colorScheme.primary),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: colorScheme.primary.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _ClassMaterialsList(classId: cls.id),
                              ],
                            ),
                          ),
                          const Divider(height: 1),

                          // Bottom Action Banner
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer
                                  .withValues(alpha: 0.15),
                              borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(18)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.dashboard_customize_outlined,
                                        size: 16, color: colorScheme.primary),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Open Class Hub (Announcements & Tasks)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(Icons.arrow_forward_ios,
                                    size: 12, color: colorScheme.primary),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          _ClassInsightsCard(classId: cls.id),
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: HiveMindReportCard(
                              classId: cls.id,
                              className: cls.title,
                              courseCode: cls.code,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _ClassMaterialsList extends ConsumerWidget {
  final String classId;
  const _ClassMaterialsList({required this.classId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialsAsync = ref.watch(classDocumentsProvider(classId));
    final colorScheme = Theme.of(context).colorScheme;

    return materialsAsync.when(
      data: (materials) {
        if (materials.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: materials.map((m) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.insert_drive_file, size: 16, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      m['title'] ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.open_in_new, size: 16, color: colorScheme.primary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'View Document',
                    onPressed: () async {
                      try {
                        final supabase = Supabase.instance.client;
                        final url = await supabase.storage
                            .from('class_materials')
                            .createSignedUrl(m['file_url']!, 60 * 60);
                        final uri = Uri.parse(url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Could not open file.')));
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')));
                        }
                      }
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _ClassInsightsCard extends ConsumerWidget {
  final String classId;
  const _ClassInsightsCard({required this.classId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(classInsightsProvider(classId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return insightsAsync.when(
      data: (insights) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0E1C2).withValues(alpha: 0.3), // Light warm tone
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFD8C4B6),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.insights, color: colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'AI Class Insights',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              MarkdownBody(
                data: insights,
                styleSheet: MarkdownStyleSheet(
                  p: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.5,
                  ),
                  strong: const TextStyle(fontWeight: FontWeight.bold),
                  listBullet: TextStyle(color: colorScheme.primary),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    // Force a refresh of the insights
                    ref.invalidate(classInsightsProvider(classId));
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Refresh Insights', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Analyzing student questions...',
                style: TextStyle(color: colorScheme.outline, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
      error: (err, _) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.error_outline, color: colorScheme.error.withValues(alpha: 0.7)),
              const SizedBox(height: 8),
              Text('Insights unavailable', style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Could not generate insights right now.', style: TextStyle(color: colorScheme.outline, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
