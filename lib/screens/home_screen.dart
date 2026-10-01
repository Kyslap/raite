import 'package:flutter/material.dart';
import 'package:raite/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 8.0),
            child: CircleAvatar(
              backgroundColor: AppColors.primary,
              radius: 16,
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 20),
            _buildGoalCard(),
            const SizedBox(height: 20),
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildSectionHeader('Enrolled Classes', 'View All'),
            const SizedBox(height: 12),
            _buildClassCard(
              title: 'Advanced Mathematics',
              subtitle: 'Dr. Aris Thorne • Chapter 4: Calculus',
              progress: 0.82,
              progressText: '82%',
              icon: Icons.functions,
            ),
            const SizedBox(height: 12),
            _buildClassCard(
              title: 'Computer Science 101',
              subtitle: 'Prof. Sarah Jenkins • Module 3: Data Structures',
              progress: 0.64,
              progressText: '64%',
              icon: Icons.computer,
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Upcoming Activities', 'Today'),
            const SizedBox(height: 12),
            _buildActivityCard(
              title: 'Math Problem Set #4',
              subtitle: 'Due in 3 hours • Advanced Math',
              icon: Icons.assignment_outlined,
              iconColor: AppColors.warning,
              buttonText: 'Start',
              isPrimaryAction: true,
            ),
            const SizedBox(height: 12),
            _buildActivityCard(
              title: 'Coding Lab Review',
              subtitle: '4:00 PM • CS 101',
              icon: Icons.people_outline,
              iconColor: AppColors.success,
              buttonText: 'Join',
              isPrimaryAction: false,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text(
                  'Alex Rivera',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('👋', style: TextStyle(fontSize: 24)),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED), // Light orange bg
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                '14 Days',
                style: TextStyle(
                  color: Colors.orange[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryLight, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'DAILY GOAL PROGRESS',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(Icons.emoji_events, color: Colors.white.withValues(alpha: 0.9), size: 20),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '45 / 60 mins',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 45 / 60,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '15 mins left to maintain streak',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              InkWell(
                onTap: () {},
                child: const Text(
                  'Resume Session',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            title: 'AI Tutor',
            subtitle: 'Ask anything',
            icon: Icons.smart_toy,
            iconColor: AppColors.primary,
            bgColor: AppColors.iconBg,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            title: 'Metrics',
            subtitle: 'View analyti...',
            icon: Icons.bar_chart,
            iconColor: AppColors.success,
            bgColor: AppColors.successLight,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          action,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildClassCard({
    required String title,
    required String subtitle,
    required double progress,
    required String progressText,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.textSecondary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      progressText,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.background,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String buttonText,
    required bool isPrimaryAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: isPrimaryAction ? AppColors.primary : Colors.white,
              foregroundColor: isPrimaryAction ? Colors.white : AppColors.textPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: isPrimaryAction
                    ? BorderSide.none
                    : const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
