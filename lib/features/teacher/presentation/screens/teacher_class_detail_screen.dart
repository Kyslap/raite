import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/announcement_model.dart';
import '../../domain/assignment_model.dart';
import '../../domain/lesson_model.dart';
import '../providers/teacher_lesson_provider.dart';
import '../providers/teacher_class_hub_provider.dart';
import 'teacher_grading_screen.dart';

class TeacherClassDetailScreen extends ConsumerStatefulWidget {
  final TeacherClass teacherClass;
  final VoidCallback? onBack;

  const TeacherClassDetailScreen({
    super.key,
    required this.teacherClass,
    this.onBack,
  });

  @override
  ConsumerState<TeacherClassDetailScreen> createState() =>
      _TeacherClassDetailScreenState();
}

class _TeacherClassDetailScreenState
    extends ConsumerState<TeacherClassDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showDeleteClassDialog() {
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
          'Are you sure you want to delete "${widget.teacherClass.title}"?\n\n'
          'This will permanently remove the class, its lessons, learning materials, and student enrollments. This action cannot be undone.',
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
              Navigator.pop(ctx); // Close dialog

              final classId = widget.teacherClass.id;
              await ref.read(teacherClassesProvider.notifier).deleteClass(classId);
              ref.read(teacherLessonsProvider.notifier).removeLessonsForClass(classId);

              if (!mounted) return;

              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🗑️ Class "${widget.teacherClass.title}" has been deleted.'),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );

              // Return to Teacher Classes list
              if (widget.onBack != null) {
                widget.onBack!();
              } else if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
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

  void _showCreateAnnouncementSheet() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    bool isPinned = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final theme = Theme.of(ctx);
          final colorScheme = theme.colorScheme;

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.campaign_rounded, color: colorScheme.primary, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Post Announcement',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
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
                      labelText: 'Announcement Title',
                      hintText: 'e.g. Exam Schedule Update / Office Hours',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: contentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Message Body',
                      hintText: 'Write instructions or important notices for students...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: isPinned,
                        activeColor: colorScheme.primary,
                        onChanged: (val) {
                          setSheetState(() => isPinned = val ?? false);
                        },
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Pin to top of feed 📌',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: () async {
                      final title = titleController.text.trim();
                      final content = contentController.text.trim();
                      if (title.isEmpty || content.isEmpty) {
                        return;
                      }

                      await ref.read(classAnnouncementsProvider.notifier).addAnnouncement(
                            classId: widget.teacherClass.id,
                            title: title,
                            content: content,
                            isPinned: isPinned,
                          );

                      if (ctx.mounted) Navigator.pop(ctx);
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('📢 Announcement posted to class feed!'),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text('Post Announcement', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCreateAssignmentSheet() {
    final titleController = TextEditingController();
    final instructionsController = TextEditingController();
    final pointsController = TextEditingController(text: '100');
    String selectedCategory = 'Homework';
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final theme = Theme.of(ctx);
          final colorScheme = theme.colorScheme;
          final categories = ['Homework', 'Project', 'Quiz', 'Lab'];

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                            Icon(Icons.assignment_add, color: colorScheme.primary, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'Create Assignment',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
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
                        labelText: 'Assignment Title',
                        hintText: 'e.g. Problem Set 2: Graph Traversal',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: instructionsController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Instructions / Prompt',
                        hintText: 'Describe expectations, submission format, and rubric...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: pointsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Max Points',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: ctx,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                setSheetState(() => selectedDate = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Due Date',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                suffixIcon: const Icon(Icons.calendar_month, size: 18),
                              ),
                              child: Text(
                                DateFormat('MMM d, yyyy').format(selectedDate),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'CATEGORY',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: categories.map((cat) {
                        final isSel = cat == selectedCategory;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: isSel,
                            onSelected: (val) {
                              if (val) setSheetState(() => selectedCategory = cat);
                            },
                            selectedColor: colorScheme.primaryContainer,
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              color: isSel ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final title = titleController.text.trim();
                        final inst = instructionsController.text.trim();
                        final pts = int.tryParse(pointsController.text.trim()) ?? 100;
                        if (title.isEmpty) return;

                        final formattedDue = DateFormat('EEE, MMM d • 11:59 PM').format(selectedDate);

                        await ref.read(classAssignmentsProvider.notifier).addAssignment(
                              classId: widget.teacherClass.id,
                              title: title,
                              instructions: inst,
                              points: pts,
                              dueDate: formattedDue,
                              category: selectedCategory,
                            );

                        if (ctx.mounted) Navigator.pop(ctx);
                        if (!mounted) return;

                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('📝 Assignment "$title" published to class!'),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: const Text('Publish Assignment', style: TextStyle(fontWeight: FontWeight.bold)),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cls = widget.teacherClass;

    final allAnnouncements = ref.watch(classAnnouncementsProvider);
    final classAnnouncements = allAnnouncements.where((a) => a.classId == cls.id).toList();

    final allAssignments = ref.watch(classAssignmentsProvider);
    final classAssignments = allAssignments.where((a) => a.classId == cls.id).toList();

    final allLessons = ref.watch(teacherLessonsProvider);
    final classLessons = allLessons.where((l) => l.classId == cls.id).toList();

    return PopScope(
      canPop: widget.onBack == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && widget.onBack != null) {
          widget.onBack!();
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            onPressed: () {
              if (widget.onBack != null) {
                widget.onBack!();
              } else if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
        title: Text(
          cls.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (val) {
              if (val == 'copy_code') {
                Clipboard.setData(ClipboardData(text: cls.code));
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('📋 Code ${cls.code} copied to clipboard!'),
                    duration: const Duration(milliseconds: 1500),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else if (val == 'share') {
                final shareMsg = 'Join my class "${cls.title}" on Raite using code: ${cls.code}';
                Clipboard.setData(ClipboardData(text: shareMsg));
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Invite message copied: "$shareMsg"'),
                    duration: const Duration(milliseconds: 1500),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else if (val == 'delete') {
                _showDeleteClassDialog();
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'copy_code',
                child: Row(
                  children: const [
                    Icon(Icons.key, size: 18),
                    SizedBox(width: 10),
                    Text('Copy Join Code'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: const [
                    Icon(Icons.share, size: 18),
                    SizedBox(width: 10),
                    Text('Share Invite'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: colorScheme.error, size: 18),
                    const SizedBox(width: 10),
                    Text('Delete Class', style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Teams-Style Class Header Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.25),
              border: Border(
                bottom: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      cls.title.isNotEmpty ? cls.title.substring(0, cls.title.length >= 2 ? 2 : 1).toUpperCase() : 'CL',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cls.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              cls.department,
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('•', style: TextStyle(color: colorScheme.outline)),
                          const SizedBox(width: 8),
                          Flexible(
                            child: InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: cls.code));
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('📋 Code ${cls.code} copied!'),
                                    duration: const Duration(milliseconds: 1500),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.key, size: 11, color: colorScheme.primary),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        cls.code,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.primary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.copy, size: 10, color: colorScheme.primary),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Microsoft Teams Style Channels / Tab Bar
          Container(
            color: colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              indicatorColor: colorScheme.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: [
                Tab(
                  icon: const Icon(Icons.forum_outlined, size: 18),
                  text: 'Announcements (${classAnnouncements.length})',
                ),
                Tab(
                  icon: const Icon(Icons.assignment_outlined, size: 18),
                  text: 'Assignments (${classAssignments.length})',
                ),
                Tab(
                  icon: const Icon(Icons.folder_open_outlined, size: 18),
                  text: 'Materials (${classLessons.length})',
                ),
                Tab(
                  icon: const Icon(Icons.people_alt_outlined, size: 18),
                  text: 'Members (${cls.studentCount})',
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Channels View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. Announcements Channel (Teams Posts)
                _buildAnnouncementsTab(classAnnouncements),

                // 2. Assignments Channel
                _buildAssignmentsTab(classAssignments),

                // 3. Lessons & Materials Channel (Files)
                _buildMaterialsTab(classLessons),

                // 4. Members / Roster Channel
                _buildMembersTab(),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  // 1. Teams Posts / Announcements Feed
  Widget _buildAnnouncementsTab(List<AnnouncementModel> announcements) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Quick Post Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: colorScheme.surfaceContainerLow,
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _showCreateAnnouncementSheet,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.edit_note_rounded, color: colorScheme.primary, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'Post an announcement or update...',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.send_rounded, color: colorScheme.primary),
                tooltip: 'Post Announcement',
                onPressed: _showCreateAnnouncementSheet,
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Feed
        Expanded(
          child: announcements.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.forum_outlined, size: 48, color: colorScheme.primary),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Announcements Yet',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Post your first class update to notify enrolled students about exams, syllabus updates, or discussions.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _showCreateAnnouncementSheet,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Post First Announcement'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: announcements.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final ann = announcements[index];

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: ann.isPinned
                              ? colorScheme.primary.withValues(alpha: 0.5)
                              : colorScheme.outlineVariant.withValues(alpha: 0.6),
                          width: ann.isPinned ? 1.5 : 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: colorScheme.primary,
                                child: Text(
                                  ann.authorName.isNotEmpty ? ann.authorName[0].toUpperCase() : 'P',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          ann.authorName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: colorScheme.primaryContainer,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'Instructor',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.onPrimaryContainer,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      DateFormat('MMM d, yyyy • h:mm a').format(ann.createdAt),
                                      style: TextStyle(fontSize: 11, color: colorScheme.outline),
                                    ),
                                  ],
                                ),
                              ),
                              if (ann.isPinned)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.push_pin, size: 12, color: colorScheme.primary),
                                      const SizedBox(width: 4),
                                      Text(
                                        'PINNED',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18),
                                color: colorScheme.outline,
                                onPressed: () {
                                  ref.read(classAnnouncementsProvider.notifier).deleteAnnouncement(ann.id);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            ann.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            ann.content,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // 2. Teams Assignments Channel
  Widget _buildAssignmentsTab(List<AssignmentModel> assignments) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateAssignmentSheet,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('New Assignment', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: assignments.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.assignment_outlined, size: 48, color: colorScheme.primary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Assignments Created',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Assign homework, projects, or quizzes to students in this class.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _showCreateAssignmentSheet,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Create Assignment'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: assignments.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final asg = assignments[index];

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TeacherGradingScreen(
                          assignment: asg,
                          teacherClass: widget.teacherClass,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                asg.category.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '${asg.points} pts',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18),
                                  color: colorScheme.outline,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    ref.read(classAssignmentsProvider.notifier).deleteAssignment(asg.id);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          asg.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        if (asg.instructions.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            asg.instructions,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.schedule, size: 14, color: colorScheme.outline),
                            const SizedBox(width: 6),
                            Text(
                              'Due: ${asg.dueDate}',
                              style: TextStyle(fontSize: 11, color: colorScheme.outline, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.assignment_turned_in_outlined, size: 15, color: colorScheme.primary),
                                const SizedBox(width: 6),
                                Text(
                                  '${asg.submissionsCount}/${widget.teacherClass.studentCount} Turn-ins',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Grade & Review',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(Icons.chevron_right, size: 16, color: colorScheme.primary),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // 3. Teams Materials & Lessons Channel (Files)
  Widget _buildMaterialsTab(List<LessonModel> lessons) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return lessons.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.folder_open_outlined, size: 48, color: colorScheme.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Lessons or Slides Uploaded',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Publish lecture notes, upload PowerPoint decks, and attach PDFs from the Lesson Uploader.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          )
        : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: lessons.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final lesson = lessons[index];

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.menu_book, color: Color(0xFF10B981), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            lesson.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        Text(
                          lesson.estimatedMinutes,
                          style: TextStyle(fontSize: 12, color: colorScheme.outline),
                        ),
                      ],
                    ),
                    if (lesson.content.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        lesson.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                    if (lesson.attachments.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Attached Files & Slides (${lesson.attachments.length}):',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: lesson.attachments.map((att) {
                          final isPdf = att.fileType.toLowerCase().contains('pdf');
                          final isPpt = att.fileType.toLowerCase().contains('ppt');

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isPpt
                                  ? Colors.orange.withValues(alpha: 0.12)
                                  : isPdf
                                      ? Colors.red.withValues(alpha: 0.12)
                                      : colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isPpt
                                    ? Colors.orange.withValues(alpha: 0.3)
                                    : isPdf
                                        ? Colors.red.withValues(alpha: 0.3)
                                        : colorScheme.primary.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isPpt
                                      ? Icons.slideshow_rounded
                                      : isPdf
                                          ? Icons.picture_as_pdf_rounded
                                          : Icons.attach_file_rounded,
                                  size: 14,
                                  color: isPpt
                                      ? Colors.orange.shade800
                                      : isPdf
                                          ? Colors.red.shade800
                                          : colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 160),
                                  child: Text(
                                    att.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
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
                                    style: TextStyle(fontSize: 10, color: colorScheme.outline),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
  }

  // 4. Teams Members / Roster Channel
  Widget _buildMembersTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cls = widget.teacherClass;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Join Code Recruitment Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.primary.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Class Join Code',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Share this code with students to let them self-enroll instantly.',
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        cls.code,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: cls.code));
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('📋 Code ${cls.code} copied!'),
                        duration: const Duration(milliseconds: 1500),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'ENROLLED MEMBERS (${cls.studentCount})',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),

          if (cls.studentCount == 0)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: colorScheme.outline, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No students enrolled yet. Distribute join code "${cls.code}" to your class roster.',
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            )
          else
            ...List.generate(cls.studentCount, (i) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                  child: Text(
                    'S${i + 1}',
                    style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text('Student #${i + 1}', style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Active learner • Enrolled via code'),
                trailing: const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
              );
            }),
        ],
      ),
    );
  }
}
