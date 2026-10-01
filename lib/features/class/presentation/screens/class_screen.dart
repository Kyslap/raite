import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/class_provider.dart';

class ClassScreen extends ConsumerStatefulWidget {
  final String? classId;
  const ClassScreen({super.key, this.classId});

  @override
  ConsumerState<ClassScreen> createState() => _ClassScreenState();
}

class _ClassScreenState extends ConsumerState<ClassScreen> {
  int _selectedTabIndex = 0; // 0 for Activities, 1 for Posts

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Fetch dynamic class data
    final classModel = widget.classId != null 
        ? ref.watch(classDetailProvider(widget.classId!))
        : null;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
        title: Text(
          'CLASS',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: colorScheme.primary,
              child: Icon(Icons.person, size: 18, color: colorScheme.onPrimary),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Course Header Banner
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.onSurface.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      bottom: -30,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: colorScheme.secondaryContainer,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      classModel?.courseCode ?? 'MATH 402',
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        color: colorScheme.onSecondaryContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    classModel?.name ?? 'Advanced Mathematics',
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${classModel?.professor ?? 'Professor Aris Thorne'} • Room 304',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(Icons.calculate, color: colorScheme.onPrimaryContainer, size: 28),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        // Quick Stats Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _QuickStat(label: 'Next Class', value: 'Today, 2:00 PM', theme: theme, colorScheme: colorScheme),
                            _QuickStat(label: 'Assignments', value: '3 Due Soon', theme: theme, colorScheme: colorScheme),
                            _QuickStat(label: 'Class Rank', value: 'Top 5%', theme: theme, colorScheme: colorScheme),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Topics Section
              if (classModel != null && classModel.topics.isNotEmpty) ...[
                Text(
                  'Current Topics',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: classModel.topics.map((topic) {
                    return ActionChip(
                      label: Text(topic.title),
                      backgroundColor: colorScheme.surfaceContainerHigh,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      onPressed: () {
                        context.push('/ai-tutor', extra: topic);
                      },
                      avatar: Icon(Icons.smart_toy, color: colorScheme.primary, size: 16),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],

              // Live Lecture Banner
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: colorScheme.error,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'LIVE SESSION ACTIVE',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: colorScheme.primaryContainer,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Lecture 14: Non-Euclidean Geometry Proofs',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '42 classmates are currently attending.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primaryContainer, // closest to primary-fixed-dim in context
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.surface,
                        foregroundColor: colorScheme.onSurface,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      icon: Icon(Icons.podcasts, color: colorScheme.primary, size: 20),
                      label: const Text('Join Live', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Interactive Tabs
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _TabButton(
                        label: 'Activities & Assignments',
                        isSelected: _selectedTabIndex == 0,
                        onTap: () => setState(() => _selectedTabIndex = 0),
                      ),
                    ),
                    Expanded(
                      child: _TabButton(
                        label: 'Class Posts',
                        isSelected: _selectedTabIndex == 1,
                        onTap: () => setState(() => _selectedTabIndex = 1),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tab Content
              if (_selectedTabIndex == 0) ...[
                // Urgent Assignment Card
                _AssignmentCard(
                  icon: Icons.assignment_late_outlined,
                  iconColor: colorScheme.onErrorContainer,
                  iconBgColor: colorScheme.errorContainer,
                  badgeText: 'Due in 4 Hours',
                  badgeColor: colorScheme.onErrorContainer,
                  badgeBgColor: colorScheme.errorContainer,
                  title: 'Topology Problem Set #4',
                  points: '100 pts',
                  description: 'Complete proofs for compact metric spaces and connected components. Show all steps clearly.',
                  dueTime: '11:59 PM Tonight',
                  actionText: 'Submit Work',
                  isPrimaryAction: true,
                ),
                const SizedBox(height: 16),
                // Secondary Assignment Card
                _AssignmentCard(
                  icon: Icons.quiz_outlined,
                  iconColor: colorScheme.onSecondaryContainer,
                  iconBgColor: colorScheme.secondaryContainer,
                  badgeText: 'Due Friday',
                  badgeColor: colorScheme.onSecondaryContainer,
                  badgeBgColor: colorScheme.secondaryContainer,
                  title: 'Midterm Take-Home Quiz',
                  points: '250 pts',
                  description: 'Comprehensive analysis covering vector spaces, linear transformations, and eigenvalues.',
                  dueTime: 'Oct 20, 5:00 PM',
                  actionText: 'View Details',
                  isPrimaryAction: false,
                ),
                const SizedBox(height: 16),
                // Completed Assignment Card
                Opacity(
                  opacity: 0.8,
                  child: _AssignmentCard(
                    icon: Icons.task_alt,
                    iconColor: colorScheme.onPrimaryContainer,
                    iconBgColor: colorScheme.primaryContainer,
                    badgeText: 'Graded • 98/100',
                    badgeColor: colorScheme.onPrimaryContainer,
                    badgeBgColor: colorScheme.primaryContainer,
                    title: 'Tensor Calculus Lab #3',
                    points: 'A+',
                    pointsColor: colorScheme.primary,
                    description: 'Exceptional work on the Christoffel symbols derivation. Great intuition shown.',
                    hasAction: false,
                  ),
                ),
              ] else ...[
                _PostCard(
                  initials: 'AT',
                  avatarBgColor: colorScheme.secondary,
                  avatarTextColor: colorScheme.onSecondary,
                  name: 'Prof. Aris Thorne',
                  time: 'Yesterday at 4:15 PM',
                  content: 'Office hours for this Thursday are rescheduled to 3:00 PM in Room 304 due to the departmental faculty meeting. Please bring your draft proofs.',
                  likes: 14,
                  replies: 3,
                ),
                const SizedBox(height: 16),
                _PostCard(
                  initials: 'JD',
                  avatarBgColor: colorScheme.tertiaryContainer,
                  avatarTextColor: colorScheme.onTertiaryContainer,
                  name: 'Julian Davies',
                  time: '2 days ago',
                  content: 'Does anyone want to form a study group for Problem Set #4 tonight at the library around 7 PM? Working on question 3 specifically.',
                  likes: 8,
                  replies: 5,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _QuickStat({
    required this.label,
    required this.value,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.onSurface.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            color: isSelected ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String badgeText;
  final Color badgeColor;
  final Color badgeBgColor;
  final String title;
  final String points;
  final Color? pointsColor;
  final String description;
  final String? dueTime;
  final String? actionText;
  final bool isPrimaryAction;
  final bool hasAction;

  const _AssignmentCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.badgeText,
    required this.badgeColor,
    required this.badgeBgColor,
    required this.title,
    required this.points,
    this.pointsColor,
    required this.description,
    this.dueTime,
    this.actionText,
    this.isPrimaryAction = false,
    this.hasAction = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
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
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badgeText,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: badgeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                points,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: pointsColor ?? colorScheme.tertiary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (hasAction) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(
                      dueTime ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPrimaryAction ? colorScheme.primary : colorScheme.surface,
                    foregroundColor: isPrimaryAction ? colorScheme.onPrimary : colorScheme.onSurface,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isPrimaryAction ? BorderSide.none : BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    minimumSize: const Size(0, 36),
                  ),
                  child: Text(
                    actionText ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final String initials;
  final Color avatarBgColor;
  final Color avatarTextColor;
  final String name;
  final String time;
  final String content;
  final int likes;
  final int replies;

  const _PostCard({
    required this.initials,
    required this.avatarBgColor,
    required this.avatarTextColor,
    required this.name,
    required this.time,
    required this.content,
    required this.likes,
    required this.replies,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: avatarBgColor,
                child: Text(
                  initials,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: avatarTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    time,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _PostAction(icon: Icons.thumb_up_outlined, label: '$likes likes'),
              const SizedBox(width: 24),
              _PostAction(icon: Icons.chat_bubble_outline, label: '$replies replies'),
            ],
          ),
        ],
      ),
    );
  }
}

class _PostAction extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PostAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
