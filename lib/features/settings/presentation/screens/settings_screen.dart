import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/spacing.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _checkNotificationStatus();
  }

  Future<void> _checkNotificationStatus() async {
    final enabled = await NotificationService.instance
        .areNotificationsEnabled();
    if (mounted) {
      setState(() {
        _notificationsEnabled = enabled;
      });
    }
  }

  Future<void> _requestNotificationPermission() async {
    final granted = await NotificationService.instance.requestPermissions();
    if (mounted) {
      setState(() {
        _notificationsEnabled = granted;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            granted
                ? 'Notification permissions enabled!'
                : 'Notification permissions were not granted.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<TaskFlowColors>();
    final currentThemeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Preferences & Storage',
              style: theme.textTheme.bodySmall?.copyWith(
                color: customColors?.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenMargin),
        children: [
          // Section 1: Appearance
          Text(
            'APPEARANCE',
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.p8),
          Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: customColors?.cardBackground ?? theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              border: Border.all(
                color:
                    customColors?.hairlineBorder ??
                    theme.colorScheme.outlineVariant,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.palette,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.p12),
                    Text(
                      'Theme Mode',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.p16),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text('System'),
                      icon: Icon(LucideIcons.laptop, size: 16),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text('Light'),
                      icon: Icon(LucideIcons.sun, size: 16),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text('Dark'),
                      icon: Icon(LucideIcons.moon, size: 16),
                    ),
                  ],
                  selected: {currentThemeMode},
                  onSelectionChanged: (Set<ThemeMode> newSelection) {
                    ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(newSelection.first);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.p24),

          // Section 2: Notifications
          Text(
            'NOTIFICATIONS & REMINDERS',
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.p8),
          Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: customColors?.cardBackground ?? theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              border: Border.all(
                color:
                    customColors?.hairlineBorder ??
                    theme.colorScheme.outlineVariant,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _notificationsEnabled
                            ? theme.colorScheme.primaryContainer.withValues(
                                alpha: 0.2,
                              )
                            : theme.colorScheme.errorContainer.withValues(
                                alpha: 0.3,
                              ),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMedium,
                        ),
                      ),
                      child: Icon(
                        _notificationsEnabled
                            ? LucideIcons.bellRing
                            : LucideIcons.bellOff,
                        size: 18,
                        color: _notificationsEnabled
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.p12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notification Status',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _notificationsEnabled
                                ? 'Active'
                                : 'Disabled or permission pending',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: customColors?.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!_notificationsEnabled)
                      FilledButton(
                        onPressed: _requestNotificationPermission,
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.p12,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text('Enable'),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.p24),

          // Section 3: Developer Info (Resume)
          Text(
            'DEVELOPER & CREDENTIALS',
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.p8),
          _buildDeveloperCard(context),
          const SizedBox(height: AppSpacing.p24),

          // Section 4: Privacy & Local-first info
          Text(
            'PRIVACY & ARCHITECTURE',
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.p8),
          Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: customColors?.cardBackground ?? theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              border: Border.all(
                color:
                    customColors?.hairlineBorder ??
                    theme.colorScheme.outlineVariant,
              ),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  context,
                  icon: LucideIcons.shieldCheck,
                  title: '100% Local-First',
                  subtitle: 'No cloud database, no tracking, works completely in airplane mode.',
                ),
                const Divider(height: AppSpacing.p24),
                _buildInfoRow(
                  context,
                  icon: LucideIcons.database,
                  title: 'On-Device SQLite Storage',
                  subtitle:
                      'Type-safe relational data powered by Drift engine.',
                ),
                const Divider(height: AppSpacing.p24),
                _buildInfoRow(
                  context,
                  icon: LucideIcons.info,
                  title: 'App Version',
                  subtitle: '${AppConstants.appName} v1.0.0 (Production Build)',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperCard(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<TaskFlowColors>();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: customColors?.cardBackground ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(
          color:
              customColors?.hairlineBorder ?? theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  'KV',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.p12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KALEESWARAN V',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Full Stack Engineer • Mobile App Developer',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'AI Assisted Full Stack Engineer',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: customColors?.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.p12),
          Text(
            'Full Stack & Mobile Developer with 2+ years experience building enterprise healthcare platforms, Flutter apps (Pharmacy4U), and AI/LLM integrations across MEAN, MERN, and Python stacks.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: customColors?.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.p12),
          Wrap(
            spacing: AppSpacing.p8,
            runSpacing: AppSpacing.p4,
            children: [
              _buildSkillBadge(context, 'Flutter & Dart'),
              _buildSkillBadge(context, 'AI / LLM APIs'),
              _buildSkillBadge(context, 'Angular / React / Next.js'),
              _buildSkillBadge(context, 'NestJS & Node.js'),
              _buildSkillBadge(context, 'FastAPI'),
              _buildSkillBadge(context, 'MySQL & MongoDB'),
            ],
          ),
          const Divider(height: AppSpacing.p24),
          _buildContactLine(
            context,
            icon: LucideIcons.mail,
            text: 'vkalees64@gmail.com',
          ),
          const SizedBox(height: AppSpacing.p8),
          _buildContactLine(
            context,
            icon: LucideIcons.phone,
            text: '+91 8248589198',
          ),
          const SizedBox(height: AppSpacing.p8),
          _buildContactLine(
            context,
            icon: LucideIcons.graduationCap,
            text: 'B.E. CSE • PSN Institute of Tech & Science (CGPA: 8.17)',
          ),
          const SizedBox(height: AppSpacing.p16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showResumeModal(context),
              icon: const Icon(LucideIcons.briefcase, size: 16),
              label: const Text('View Full Experience & Projects'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                side: BorderSide(
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillBadge(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.p8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildContactLine(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 15, color: theme.colorScheme.primary),
        const SizedBox(width: AppSpacing.p8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _showResumeModal(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<TaskFlowColors>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusSheet),
                ),
                border: Border.all(
                  color:
                      customColors?.hairlineBorder ??
                      theme.colorScheme.outlineVariant,
                ),
              ),
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(AppSpacing.screenMargin),
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusPill,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.p16),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kaleeswaran V',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Full Stack & Mobile Engineer',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(LucideIcons.x, size: 20),
                      ),
                    ],
                  ),
                  const Divider(height: AppSpacing.p24),

                  // Experience Section
                  _buildResumeSectionHeader(context, 'WORK EXPERIENCE'),
                  const SizedBox(height: AppSpacing.p8),
                  _buildExperienceItem(
                    context,
                    company: 'Assay Clinical Research Pvt Ltd',
                    role: 'Full Stack Developer',
                    duration: 'Dec 2024 – Present',
                    points: const [
                      'Built cross-platform Flutter mobile app for Pharmacy4U (medicine ordering, prescription uploads, order tracking) for Android & iOS.',
                      'Contributed to healthcare platforms Cureo App, EMR, CTMS, and Cureo Static Web Application.',
                      'Designed RESTful APIs & real-time backend with NestJS and optimized MySQL/MongoDB schemas.',
                      'Integrated OpenAI & Claude AI APIs for clinical workflow automation and intelligent assistance.',
                    ],
                  ),
                  const SizedBox(height: AppSpacing.p16),
                  _buildExperienceItem(
                    context,
                    company: 'Spinsoft Learning Solutions Pvt Ltd',
                    role: 'Full Stack Developer',
                    duration: 'Sep 2024 – Dec 2024',
                    points: const [
                      'Developed full-stack web applications with React.js, Angular, and Next.js.',
                      'Managed MySQL and MongoDB integrations ensuring reliable data storage and retrieval.',
                    ],
                  ),
                  const Divider(height: AppSpacing.p24),

                  // Key Projects Section
                  _buildResumeSectionHeader(context, 'KEY PROJECTS'),
                  const SizedBox(height: AppSpacing.p8),
                  _buildProjectItem(
                    context,
                    name: 'Pharmacy4U Mobile & Web Platform',
                    tech: 'Flutter, NestJS, MySQL',
                    desc: 'Cross-platform mobile application enabling medicine prescription upload, fulfillment tracking, and seamless healthcare delivery.',
                  ),
                  const SizedBox(height: AppSpacing.p12),
                  _buildProjectItem(
                    context,
                    name: 'EMR (Electronic Medical Records System)',
                    tech: 'Angular, NestJS, MySQL, MongoDB, AI/LLM',
                    desc: 'Comprehensive patient management system with automated clinical assistance powered by OpenAI & Claude AI APIs.',
                  ),
                  const SizedBox(height: AppSpacing.p12),
                  _buildProjectItem(
                    context,
                    name: 'Freelance – My Family Circle',
                    tech: 'Angular, NestJS, PostgreSQL, Render, Vercel',
                    desc: 'Full-stack family finance and wallet management platform with automated funds tracking and bulk Excel data import.',
                  ),
                  const Divider(height: AppSpacing.p24),

                  // Honors & Certifications
                  _buildResumeSectionHeader(
                    context,
                    'ACHIEVEMENTS & CERTIFICATIONS',
                  ),
                  const SizedBox(height: AppSpacing.p8),
                  _buildBulletPoint(
                    context,
                    'Completed NCC "C" Certificate (Grade C) — discipline, leadership, teamwork.',
                  ),
                  _buildBulletPoint(
                    context,
                    'IBM Academic Best Project Award — Indoor Plant Management System.',
                  ),
                  _buildBulletPoint(
                    context,
                    'Infosys Springboard — Full Stack (MEAN).',
                  ),
                  _buildBulletPoint(
                    context,
                    'Udemy — Prompt Engineering & LLM Integration.',
                  ),
                  _buildBulletPoint(
                    context,
                    'GUVI & Shiash Info Solutions — Python Full Stack Internship.',
                  ),
                  const SizedBox(height: AppSpacing.p32),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildResumeSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.labelSmall?.copyWith(
        letterSpacing: 1.1,
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildExperienceItem(
    BuildContext context, {
    required String company,
    required String role,
    required String duration,
    required List<String> points,
  }) {
    final theme = Theme.of(context);
    final customColors = theme.extension<TaskFlowColors>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                role,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              duration,
              style: theme.textTheme.bodySmall?.copyWith(
                color: customColors?.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        Text(
          company,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.p8),
        ...points.map((p) => _buildBulletPoint(context, p)),
      ],
    );
  }

  Widget _buildProjectItem(
    BuildContext context, {
    required String name,
    required String tech,
    required String desc,
  }) {
    final theme = Theme.of(context);
    final customColors = theme.extension<TaskFlowColors>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          tech,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          desc,
          style: theme.textTheme.bodySmall?.copyWith(
            color: customColors?.textSecondary,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(BuildContext context, String text) {
    final theme = Theme.of(context);
    final customColors = theme.extension<TaskFlowColors>();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.p4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: customColors?.textSecondary,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final customColors = theme.extension<TaskFlowColors>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: AppSpacing.p12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: customColors?.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
