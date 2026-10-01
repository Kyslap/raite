import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/class_provider.dart';
import '../../domain/class_model.dart';
import '../../domain/topic_model.dart';
import '../../domain/student_submission_model.dart';
import '../providers/student_class_hub_provider.dart';
import '../../../teacher/domain/announcement_model.dart';
import '../../../teacher/domain/assignment_model.dart';
import '../../../teacher/domain/lesson_model.dart';
import '../../../teacher/presentation/providers/teacher_class_hub_provider.dart';
import '../../../teacher/presentation/providers/teacher_lesson_provider.dart';

class ClassScreen extends ConsumerStatefulWidget {
  final String? classId;
  const ClassScreen({super.key, this.classId});

  @override
  ConsumerState<ClassScreen> createState() => _ClassScreenState();
}

class _ClassScreenState extends ConsumerState<ClassScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedClassId;
  String _assignmentFilter = 'All'; // 'All', 'Assigned', 'Turned In'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _selectedClassId = widget.classId;
  }

  @override
  void didUpdateWidget(ClassScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.classId != oldWidget.classId && widget.classId != null) {
      _selectedClassId = widget.classId;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Fetch dynamic enrolled classes
    final enrolledList = ref.watch(enrolledClassesProvider).value ?? [];

    // Determine current class
    ClassModel? currentClass;
    if (_selectedClassId != null) {
      currentClass = enrolledList.firstWhere(
        (c) => c.id == _selectedClassId,
        orElse: () => enrolledList.isNotEmpty ? enrolledList.first : ClassModel(
          id: _selectedClassId!,
          courseCode: 'CLS',
          name: 'Course Class',
          professor: 'Academic Instructor',
          progress: 0.0,
          topics: [],
        ),
      );
    } else if (enrolledList.isNotEmpty) {
      currentClass = enrolledList.first;
      _selectedClassId = currentClass.id;
    }

    if (currentClass == null) {
      return _buildNoClassScreen(context, colorScheme, theme);
    }

    // Class specific data from teacher providers
    final allAnnouncements = ref.watch(classAnnouncementsProvider);
    final classAnnouncements = allAnnouncements.where((a) => a.classId == currentClass!.id).toList();

    final allAssignments = ref.watch(classAssignmentsProvider);
    final classAssignments = allAssignments.where((a) => a.classId == currentClass!.id).toList();

    final allLessons = ref.watch(teacherLessonsProvider);
    final classLessons = allLessons.where((l) => l.classId == currentClass!.id).toList();

    final submissionsMap = ref.watch(studentSubmissionsProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: context.canPop()
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface, size: 20),
                onPressed: () => context.pop(),
              )
            : null,
        title: enrolledList.length > 1
            ? DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: enrolledList.any((c) => c.id == currentClass!.id)
                      ? currentClass.id
                      : enrolledList.first.id,
                  icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
                  borderRadius: BorderRadius.circular(16),
                  dropdownColor: colorScheme.surfaceContainerHigh,
                  items: enrolledList.map((c) {
                    return DropdownMenuItem<String>(
                      value: c.id,
                      child: Text(
                        c.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (newId) {
                    if (newId != null) {
                      setState(() {
                        _selectedClassId = newId;
                      });
                    }
                  },
                ),
              )
            : Text(
                currentClass.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: colorScheme.primary),
            tooltip: 'Join Another Class with Code',
            onPressed: () => _showJoinClassDialog(context),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 4.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: colorScheme.primary,
              child: Icon(Icons.person, size: 18, color: colorScheme.onPrimary),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Student Class Hub Header Banner (Retro / Microsoft Teams Style)
            _buildClassHeaderBanner(context, currentClass, colorScheme, theme),

            // Microsoft Teams Style Channels TabBar
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
                    text: 'Materials (${classLessons.isNotEmpty ? classLessons.length : currentClass.topics.length})',
                  ),
                  Tab(
                    icon: const Icon(Icons.people_alt_outlined, size: 18),
                    text: 'Members',
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Channel Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 1. Announcements Channel (Feed with Reactions & Replies)
                  _buildAnnouncementsChannel(currentClass, classAnnouncements, colorScheme, theme),

                  // 2. Assignments Channel (Tasks with Turn In action)
                  _buildAssignmentsChannel(currentClass, classAssignments, submissionsMap, colorScheme, theme),

                  // 3. Materials & Files Channel (PPTX, PDF, AI Tutor)
                  _buildMaterialsChannel(currentClass, classLessons, colorScheme, theme),

                  // 4. Members Channel (Instructor & Classmates)
                  _buildMembersChannel(currentClass, colorScheme, theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Header Banner with course code, professor, and progress
  Widget _buildClassHeaderBanner(
    BuildContext context,
    ClassModel classModel,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.school, color: colorScheme.onPrimaryContainer, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            classModel.courseCode,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSecondaryContainer,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          classModel.professor,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      classModel.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Student Progress Bar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your Course Progress',
                          style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                        ),
                        Text(
                          '${((classModel.progress > 0 ? classModel.progress : 0.65) * 100).toInt()}% Completed',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: classModel.progress > 0 ? classModel.progress : 0.65,
                        backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 1. Announcements Channel
  Widget _buildAnnouncementsChannel(
    ClassModel classModel,
    List<AnnouncementModel> announcements,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    if (announcements.isEmpty) {
      // Show default welcoming teacher announcements for great UX
      final defaultAnnouncements = [
        AnnouncementModel(
          id: 'default-ann-1',
          classId: classModel.id,
          title: 'Welcome to ${classModel.name}!',
          content: 'Hello class! Welcome to the new semester. Please review our syllabus and check the Materials tab for this week\'s lecture slides and notes.',
          authorName: classModel.professor,
          isPinned: true,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        AnnouncementModel(
          id: 'default-ann-2',
          classId: classModel.id,
          title: 'Office Hours & Study Group Reminders',
          content: 'Regular office hours will be held on Tuesdays and Thursdays from 2:00 PM to 4:00 PM. Feel free to reply below or ask your questions anytime.',
          authorName: classModel.professor,
          isPinned: false,
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
      ];
      return _buildAnnouncementsList(defaultAnnouncements, colorScheme, theme);
    }

    // Sort pinned to top
    final sorted = List<AnnouncementModel>.from(announcements)
      ..sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });

    return _buildAnnouncementsList(sorted, colorScheme, theme);
  }

  Widget _buildAnnouncementsList(
    List<AnnouncementModel> list,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    final likesSet = ref.watch(announcementLikesProvider);
    final allReplies = ref.watch(announcementRepliesProvider);

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final ann = list[index];
        final isLiked = likesSet.contains(ann.id);
        final replies = allReplies.where((r) => r.announcementId == ann.id).toList();

        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: ann.isPinned
                  ? Colors.amber.withValues(alpha: 0.6)
                  : colorScheme.outlineVariant.withValues(alpha: 0.4),
              width: ann.isPinned ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.onSurface.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pinned badge
              if (ann.isPinned)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.push_pin, size: 14, color: Colors.amber.shade900),
                      const SizedBox(width: 6),
                      Text(
                        'PINNED BY INSTRUCTOR',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Author & Time
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: colorScheme.primaryContainer,
                          child: Icon(Icons.person, size: 20, color: colorScheme.onPrimaryContainer),
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
                                      color: colorScheme.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Instructor',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                _formatTimeAgo(ann.createdAt),
                                style: TextStyle(fontSize: 11, color: colorScheme.outline),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 8),

                    // Actions: Like & Reply
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            ref.read(announcementLikesProvider.notifier).toggleLike(ann.id);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Row(
                              children: [
                                Icon(
                                  isLiked ? Icons.favorite : Icons.favorite_border,
                                  size: 16,
                                  color: isLiked ? Colors.red : colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isLiked ? 'Liked' : 'Like',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isLiked ? Colors.red : colorScheme.onSurfaceVariant,
                                    fontWeight: isLiked ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        InkWell(
                          onTap: () => _showAddReplySheet(context, ann.id, ann.title),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Row(
                              children: [
                                Icon(Icons.mode_comment_outlined, size: 16, color: colorScheme.onSurfaceVariant),
                                const SizedBox(width: 4),
                                Text(
                                  replies.isNotEmpty ? 'Reply (${replies.length})' : 'Reply',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Threaded replies if any
                    if (replies.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Discussion (${replies.length})',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...replies.map((reply) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 12,
                                        backgroundColor: reply.authorRole == 'Instructor'
                                            ? colorScheme.primaryContainer
                                            : colorScheme.secondaryContainer,
                                        child: Text(
                                          reply.authorName[0],
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: reply.authorRole == 'Instructor'
                                                ? colorScheme.onPrimaryContainer
                                                : colorScheme.onSecondaryContainer,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  reply.authorName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  _formatTimeAgo(reply.createdAt),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: colorScheme.outline,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              reply.content,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: colorScheme.onSurface,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                            InkWell(
                              onTap: () => _showAddReplySheet(context, ann.id, ann.title),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  '+ Write a reply...',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 2. Assignments Channel
  Widget _buildAssignmentsChannel(
    ClassModel classModel,
    List<AssignmentModel> assignments,
    Map<String, StudentSubmissionModel> submissionsMap,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    // If empty, provide standard course activities
    final list = assignments.isNotEmpty
        ? assignments
        : [
            AssignmentModel(
              id: 'sample-asg-1',
              classId: classModel.id,
              title: 'Problem Set #4: Advanced Applications',
              instructions: 'Complete proofs for continuous vector fields and manifold geometry. Submit your typed or scanned handwritten solution.',
              points: 100,
              dueDate: 'Tomorrow at 11:59 PM',
              category: 'Homework',
              createdAt: DateTime.now().subtract(const Duration(days: 2)),
            ),
            AssignmentModel(
              id: 'sample-asg-2',
              classId: classModel.id,
              title: 'Midterm Practical Quiz',
              instructions: 'Interactive quiz on lecture 1 through 10 concepts. AI Tutor review recommended before attempting.',
              points: 150,
              dueDate: 'Friday, 5:00 PM',
              category: 'Quiz',
              createdAt: DateTime.now().subtract(const Duration(days: 4)),
            ),
          ];

    // Filter assignments
    final filtered = list.where((a) {
      final isSub = submissionsMap.containsKey(a.id);
      if (_assignmentFilter == 'Turned In') return isSub;
      if (_assignmentFilter == 'Assigned') return !isSub;
      return true;
    }).toList();

    return Column(
      children: [
        // Filter chips bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: colorScheme.surfaceContainerLow,
          child: Row(
            children: [
              _buildFilterChip('All', list.length, colorScheme),
              const SizedBox(width: 8),
              _buildFilterChip(
                'Assigned',
                list.where((a) => !submissionsMap.containsKey(a.id)).length,
                colorScheme,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                'Turned In',
                list.where((a) => submissionsMap.containsKey(a.id)).length,
                colorScheme,
              ),
            ],
          ),
        ),

        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 48, color: colorScheme.outline),
                      const SizedBox(height: 12),
                      Text(
                        _assignmentFilter == 'Turned In'
                            ? 'No assignments turned in yet.'
                            : 'No pending assignments!',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final asg = filtered[index];
                    final submission = submissionsMap[asg.id];
                    final isSubmitted = submission != null;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSubmitted
                              ? const Color(0xFF10B981).withValues(alpha: 0.5)
                              : colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.onSurface.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
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
                                  color: colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  asg.category.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    isSubmitted ? Icons.check_circle : Icons.schedule,
                                    size: 14,
                                    color: isSubmitted ? const Color(0xFF10B981) : Colors.amber.shade900,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isSubmitted
                                        ? 'Turned In'
                                        : 'Due: ${asg.dueDate}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isSubmitted ? const Color(0xFF10B981) : Colors.amber.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  asg.title,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${asg.points} pts',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (asg.instructions.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              asg.instructions,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.3,
                              ),
                            ),
                          ],

                          if (isSubmitted && submission.attachedFileName != null) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.attach_file, size: 14, color: Color(0xFF10B981)),
                                  const SizedBox(width: 6),
                                  Text(
                                    submission.attachedFileName!,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 14),
                          const Divider(height: 1),
                          const SizedBox(height: 10),

                          // Student Action Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (isSubmitted)
                                TextButton(
                                  onPressed: () {
                                    ref
                                        .read(studentSubmissionsProvider.notifier)
                                        .unsubmitAssignment(asg.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Assignment submission undone.'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Undo Turn In',
                                    style: TextStyle(fontSize: 12, color: Colors.red),
                                  ),
                                )
                              else
                                const SizedBox.shrink(),
                              ElevatedButton.icon(
                                onPressed: isSubmitted
                                    ? null
                                    : () => _showSubmitAssignmentSheet(context, asg, classModel),
                                icon: Icon(
                                  isSubmitted ? Icons.check : Icons.upload_file,
                                  size: 16,
                                ),
                                label: Text(isSubmitted ? 'Completed' : 'Turn In Work'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isSubmitted
                                      ? colorScheme.surfaceContainerHighest
                                      : colorScheme.primary,
                                  foregroundColor: isSubmitted
                                      ? colorScheme.outline
                                      : colorScheme.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                              ),
                            ],
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

  Widget _buildFilterChip(String label, int count, ColorScheme colorScheme) {
    final isSelected = _assignmentFilter == label;
    return InkWell(
      onTap: () => setState(() => _assignmentFilter = label),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  // 3. Materials & Files Channel
  Widget _buildMaterialsChannel(
    ClassModel classModel,
    List<LessonModel> lessons,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    // If no lessons uploaded yet, display topics from classModel
    if (lessons.isEmpty) {
      if (classModel.topics.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_open, size: 56, color: colorScheme.outline),
              const SizedBox(height: 12),
              Text(
                'No learning materials posted yet.',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Text(
                'When your teacher uploads slides or notes, they will appear here.',
                style: TextStyle(fontSize: 12, color: colorScheme.outline),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: classModel.topics.length,
        separatorBuilder: (context, index) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final topic = classModel.topics[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.menu_book, color: colorScheme.onPrimaryContainer, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (topic.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          topic.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    context.push('/ai-tutor', extra: {
                      'topic': topic,
                      'showTopicContent': true,
                    });
                  },
                  icon: const Icon(Icons.smart_toy, size: 14),
                  label: const Text('AI Tutor', style: TextStyle(fontSize: 11)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: lessons.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: colorScheme.onSurface.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.slideshow_rounded, color: colorScheme.onPrimaryContainer, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Estimated study time: ${lesson.estimatedMinutes}',
                          style: TextStyle(fontSize: 11, color: colorScheme.outline),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.push(
                        '/ai-tutor',
                        extra: {
                          'topic': TopicModel(
                            id: lesson.id,
                            title: lesson.title,
                            description: lesson.content,
                          ),
                          'showTopicContent': true,
                        },
                      );
                    },
                    icon: const Icon(Icons.smart_toy, size: 14),
                    label: const Text('AI Tutor', style: TextStyle(fontSize: 11)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
              if (lesson.content.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  lesson.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
              if (lesson.attachments.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Attached Files & Slides (${lesson.attachments.length})',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: lesson.attachments.map((att) {
                    final isPpt = att.fileType.toLowerCase().contains('ppt');
                    final isPdf = att.fileType.toLowerCase().contains('pdf');
                    return InkWell(
                      onTap: () {
                        context.push('/ai-tutor', extra: {
                          'topic': TopicModel(
                            id: lesson.id,
                            title: lesson.title,
                            description: lesson.content,
                          ),
                          'pdfUrl': isPdf ? att.url : null,
                          'pdfTitle': att.name,
                          'showTopicContent': !isPdf,
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
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
                                  fontWeight: FontWeight.w600,
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

  // 4. Members Channel
  Widget _buildMembersChannel(
    ClassModel classModel,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Instructor Profile Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Faculty Instructor',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(Icons.school, color: colorScheme.onPrimaryContainer, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          classModel.professor,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Office: Room 304 • Hours: Mon/Wed 2:00 - 4:00 PM',
                          style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Contact info for ${classModel.professor} copied to clipboard.'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.mail_outline, size: 16),
                label: const Text('Message Instructor'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Classmates Roster
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Enrolled Classmates',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '42 Students',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ...<Map<String, dynamic>>[
          {'name': 'Alex Rivera (You)', 'status': 'Online • Reviewing Lecture 14', 'isSelf': true},
          {'name': 'Julian Davies', 'status': 'Active 10m ago • Study Group', 'isSelf': false},
          {'name': 'Maya Patel', 'status': 'Online • Working on Problem Set #4', 'isSelf': false},
          {'name': 'Carlos Santana', 'status': 'Offline • Last seen yesterday', 'isSelf': false},
          {'name': 'Sophia Chen', 'status': 'Online • Asking AI Tutor', 'isSelf': false},
        ].map((student) {
          final isSelf = student['isSelf'] == true;
          final name = student['name'].toString();
          final status = student['status'].toString();
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelf
                  ? colorScheme.primaryContainer.withValues(alpha: 0.2)
                  : colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelf
                    ? colorScheme.primary.withValues(alpha: 0.3)
                    : colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: isSelf
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  child: Text(
                    name.isNotEmpty ? name[0] : 'S',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelf ? colorScheme.onPrimary : colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontWeight: isSelf ? FontWeight.bold : FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        status,
                        style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // Turn In Work Submission Bottom Sheet
  void _showSubmitAssignmentSheet(
    BuildContext context,
    AssignmentModel assignment,
    ClassModel classModel,
  ) {
    final noteController = TextEditingController();
    String? selectedDemoFile;
    final colorScheme = Theme.of(context).colorScheme;

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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                          Icon(Icons.upload_file, color: colorScheme.primary, size: 24),
                          const SizedBox(width: 10),
                          Text(
                            'Turn In Work',
                            style: TextStyle(
                              fontSize: 18,
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
                  const SizedBox(height: 12),
                  Text(
                    assignment.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Due: ${assignment.dueDate} • ${assignment.points} Points Available',
                    style: TextStyle(fontSize: 12, color: colorScheme.outline),
                  ),
                  const SizedBox(height: 16),

                  // Submission Note
                  TextField(
                    controller: noteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Add an optional note to your instructor...',
                      filled: true,
                      fillColor: colorScheme.surfaceContainerLow,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Attach file section
                  Text(
                    'Attach Solution File:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      'Solution_Document.pdf',
                      'Homework_Answers.docx',
                      'Calculus_Proofs.pdf',
                    ].map((fileName) {
                      final isSelected = selectedDemoFile == fileName;
                      return ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.picture_as_pdf,
                              size: 14,
                              color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(fileName),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (val) {
                          setSheetState(() {
                            selectedDemoFile = val ? fileName : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      ref.read(studentSubmissionsProvider.notifier).submitAssignment(
                            assignmentId: assignment.id,
                            classId: classModel.id,
                            note: noteController.text.trim(),
                            attachedFileName: selectedDemoFile ?? 'Solution_Submission.pdf',
                          );

                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: const [
                              Icon(Icons.check_circle, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text('🎉 Assignment turned in successfully!'),
                              ),
                            ],
                          ),
                          backgroundColor: const Color(0xFF10B981),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'Turn In Assignment',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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

  // Reply Composer Bottom Sheet
  void _showAddReplySheet(BuildContext context, String announcementId, String announcementTitle) {
    final replyController = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reply to Announcement',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              announcementTitle,
              style: TextStyle(fontSize: 12, color: colorScheme.outline),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: replyController,
              autofocus: true,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Write a question or response to your professor and class...',
                filled: true,
                fillColor: colorScheme.surfaceContainerLow,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final content = replyController.text.trim();
                if (content.isEmpty) return;

                ref.read(announcementRepliesProvider.notifier).addReply(
                      announcementId: announcementId,
                      content: content,
                      authorName: 'Alex Rivera (You)',
                    );

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('💬 Reply posted to class announcement!'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Post Reply', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // Empty state when student is enrolled in 0 classes
  Widget _buildNoClassScreen(BuildContext context, ColorScheme colorScheme, ThemeData theme) {
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: context.canPop()
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
                onPressed: () => context.pop(),
              )
            : null,
        title: Text(
          'CLASS HUB',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.key, color: colorScheme.primary),
            tooltip: 'Join Class with Code',
            onPressed: () => _showJoinClassDialog(context),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.school_outlined, size: 56, color: colorScheme.primary),
              ),
              const SizedBox(height: 24),
              Text(
                'No Class Selected or Enrolled',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You have not joined any classes yet. Enter an invite code from your teacher to view announcements, assignments, and slide decks.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _showJoinClassDialog(context),
                icon: const Icon(Icons.key, size: 18),
                label: const Text('Join Class with Code'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Join class with code bottom sheet dialog
  void _showJoinClassDialog(BuildContext context) {
    final codeController = TextEditingController();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        bool isLoading = false;
        String? errorMessage;

        return StatefulBuilder(
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                              child: Icon(Icons.key, color: colorScheme.primary, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Join Class with Code',
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
                    const SizedBox(height: 12),
                    Text(
                      'Ask your instructor for the class code (e.g. MATH-402, AI-101, or 6-digit code) and enter it below:',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: codeController,
                      textCapitalization: TextCapitalization.characters,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. CS-101',
                        hintStyle: TextStyle(
                          fontSize: 16,
                          letterSpacing: 1.0,
                          color: colorScheme.outline,
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        errorText: errorMessage,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              final code = codeController.text.trim();
                              if (code.isEmpty) {
                                setSheetState(() {
                                  errorMessage = 'Please enter a code';
                                });
                                return;
                              }

                              setSheetState(() {
                                isLoading = true;
                                errorMessage = null;
                              });

                              final result = await ref
                                  .read(enrolledClassesProvider.notifier)
                                  .joinClassByCode(code);

                              if (!context.mounted) return;

                              setSheetState(() {
                                isLoading = false;
                              });

                              if (result.success) {
                                Navigator.pop(ctx);
                                if (result.classModel != null) {
                                  setState(() {
                                    _selectedClassId = result.classModel!.id;
                                  });
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('🎉 ${result.message}'),
                                    backgroundColor: colorScheme.primary,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              } else {
                                setSheetState(() {
                                  errorMessage = result.message;
                                });
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Join Class',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }
}
