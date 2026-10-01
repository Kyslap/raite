import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raite/main.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../features/teacher/presentation/providers/teacher_class_hub_provider.dart';

/// Unified Retro Top Bar for the student experience across all screens.
/// Features academic title branding, live flame streak counter, notifications badge,
/// and student avatar that routes to the Profile tab.
class RetroTopAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? customActions;
  final bool showStreak;
  final bool showNotifications;
  final bool showProfileAvatar;

  const RetroTopAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.leading,
    this.customActions,
    this.showStreak = true,
    this.showNotifications = true,
    this.showProfileAvatar = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  static void showNotificationsSheet(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final announcements = ref.watch(classAnnouncementsProvider);
    final assignments = ref.watch(classAssignmentsProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.notifications_active, color: colorScheme.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Class Alerts & Notifications',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
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
              child: announcements.isEmpty && assignments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_none, size: 48, color: colorScheme.outline),
                          const SizedBox(height: 12),
                          Text(
                            'No new notifications right now.',
                            style: TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (announcements.isNotEmpty) ...[
                          Text(
                            'RECENT ANNOUNCEMENTS',
                            style: theme.textTheme.labelSmall?.copyWith(
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...announcements.take(5).map((ann) => Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      ann.isPinned ? Icons.push_pin : Icons.campaign_outlined,
                                      color: colorScheme.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ann.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            ann.content,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                        if (assignments.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(
                            'UPCOMING DEADLINES',
                            style: theme.textTheme.labelSmall?.copyWith(
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...assignments.take(4).map((asg) => Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.assignment_outlined, color: colorScheme.secondary, size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            asg.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            'Due: ${asg.dueDate} • ${asg.category}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  static void showStreakSheet(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF97316).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_fire_department_rounded,
                color: Color(0xFFF97316),
                size: 44,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '3-Day Learning Streak! 🔥',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You have consistently engaged with your coursework for 3 consecutive days. Complete 15 minutes of study today to extend your streak!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Keep Learning', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authUser = ref.watch(authStateProvider).value;
    final displayName = authUser?.name ?? 'Student';

    final announcements = ref.watch(classAnnouncementsProvider);
    final assignments = ref.watch(classAssignmentsProvider);
    final hasUnreadAlerts = announcements.isNotEmpty || assignments.isNotEmpty;

    return AppBar(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: leading ??
          (context.canPop()
              ? IconButton(
                  icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface, size: 18),
                  tooltip: 'Back',
                  onPressed: () => context.pop(),
                )
              : null),
      titleSpacing: leading != null || context.canPop() ? 0 : 20,
      title: titleWidget ??
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (subtitle != null) ...[
                Text(
                  subtitle!.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
              ],
              Text(
                title ?? 'Study Desk',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
      actions: [
        // 1. Streak Flame Badge
        if (showStreak)
          Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: InkWell(
              onTap: () => showStreakSheet(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFF97316).withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      color: Color(0xFFF97316),
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '3 Days',
                      style: TextStyle(
                        color: Color(0xFFC2410C),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Custom extra actions if supplied
        if (customActions != null) ...customActions!,

        // 2. Notification Bell with Unread Indicator
        if (showNotifications)
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none_outlined, color: colorScheme.onSurface),
                tooltip: 'Notifications',
                onPressed: () => showNotificationsSheet(context, ref),
              ),
              if (hasUnreadAlerts)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.surface, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),

        // 3. Profile Avatar
        if (showProfileAvatar)
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 4.0),
            child: InkWell(
              onTap: () {
                ref.read(studentBottomNavIndexProvider.notifier).setIndex(4);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: colorScheme.primary,
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'S',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
