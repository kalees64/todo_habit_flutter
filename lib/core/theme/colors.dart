import 'package:flutter/material.dart';

/// Calm Kinetic Color Palette for TaskFlow
class AppColors {
  AppColors._();

  // Light Theme Palette
  static const Color lightBackground = Color(0xFFFAFAF9);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainerLow = Color(0xFFF6F3F2);
  static const Color lightSurfaceContainer = Color(0xFFF0EDED);
  static const Color lightSurfaceContainerHigh = Color(0xFFEAE7E7);
  static const Color lightPrimary = Color(0xFF2F6F4E);
  static const Color lightPrimaryContainer = Color(0xFF2F6F4E);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryFixed = Color(0xFFAEF1C8);
  static const Color lightOnPrimaryFixed = Color(0xFF002111);
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF6B6B6B);
  static const Color lightOverdue = Color(0xFFC0392B);
  static const Color lightOverdueContainer = Color(0xFFFFDAD6);
  static const Color lightOnOverdueContainer = Color(0xFF93000A);
  static const Color lightSecondary = Color(0xFFE67E22);
  static const Color lightSecondaryContainer = Color(0xFFFC8F34);
  static const Color lightSecondaryFixed = Color(0xFFFFDCC5);
  static const Color lightOnSecondaryFixed = Color(0xFF301400);
  static const Color lightBorder = Color(0xFFE7E5E4);

  // Dark Theme Palette
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceContainerLow = Color(0xFF181818);
  static const Color darkSurfaceContainer = Color(0xFF242424);
  static const Color darkSurfaceContainerHigh = Color(0xFF2A2A2A);
  static const Color darkPrimary = Color(0xFF5FBE8E);
  static const Color darkPrimaryContainer = Color(0xFF24573D);
  static const Color darkOnPrimary = Color(0xFF00381E);
  static const Color darkPrimaryFixed = Color(0xFF2F6F4E);
  static const Color darkOnPrimaryFixed = Color(0xFFAEF1C8);
  static const Color darkTextPrimary = Color(0xFFEDEDED);
  static const Color darkTextSecondary = Color(0xFFA0A0A0);
  static const Color darkOverdue = Color(0xFFE57373);
  static const Color darkOverdueContainer = Color(0xFF5C1B1B);
  static const Color darkOnOverdueContainer = Color(0xFFFFDAD6);
  static const Color darkSecondary = Color(0xFFFC8F34);
  static const Color darkSecondaryContainer = Color(0xFF944A00);
  static const Color darkSecondaryFixed = Color(0xFF532500);
  static const Color darkOnSecondaryFixed = Color(0xFFFFDCC5);
  static const Color darkBorder = Color(0xFF2C2C2C);
}

/// Theme Extension for custom semantics like Streak Flame and Overdue colors
@immutable
class TaskFlowColors extends ThemeExtension<TaskFlowColors> {
  const TaskFlowColors({
    required this.streak,
    required this.streakContainer,
    required this.onStreakContainer,
    required this.overdue,
    required this.overdueContainer,
    required this.onOverdueContainer,
    required this.hairlineBorder,
    required this.cardBackground,
    required this.textSecondary,
    required this.pillActiveBackground,
  });

  final Color streak;
  final Color streakContainer;
  final Color onStreakContainer;
  final Color overdue;
  final Color overdueContainer;
  final Color onOverdueContainer;
  final Color hairlineBorder;
  final Color cardBackground;
  final Color textSecondary;
  final Color pillActiveBackground;

  static const TaskFlowColors light = TaskFlowColors(
    streak: AppColors.lightSecondary,
    streakContainer: AppColors.lightSecondaryFixed,
    onStreakContainer: AppColors.lightOnSecondaryFixed,
    overdue: AppColors.lightOverdue,
    overdueContainer: AppColors.lightOverdueContainer,
    onOverdueContainer: AppColors.lightOnOverdueContainer,
    hairlineBorder: AppColors.lightBorder,
    cardBackground: AppColors.lightSurface,
    textSecondary: AppColors.lightTextSecondary,
    pillActiveBackground: AppColors.lightPrimaryFixed,
  );

  static const TaskFlowColors dark = TaskFlowColors(
    streak: AppColors.darkSecondary,
    streakContainer: AppColors.darkSecondaryFixed,
    onStreakContainer: AppColors.darkOnSecondaryFixed,
    overdue: AppColors.darkOverdue,
    overdueContainer: AppColors.darkOverdueContainer,
    onOverdueContainer: AppColors.darkOnOverdueContainer,
    hairlineBorder: AppColors.darkBorder,
    cardBackground: AppColors.darkSurface,
    textSecondary: AppColors.darkTextSecondary,
    pillActiveBackground: AppColors.darkPrimaryFixed,
  );

  @override
  TaskFlowColors copyWith({
    Color? streak,
    Color? streakContainer,
    Color? onStreakContainer,
    Color? overdue,
    Color? overdueContainer,
    Color? onOverdueContainer,
    Color? hairlineBorder,
    Color? cardBackground,
    Color? textSecondary,
    Color? pillActiveBackground,
  }) {
    return TaskFlowColors(
      streak: streak ?? this.streak,
      streakContainer: streakContainer ?? this.streakContainer,
      onStreakContainer: onStreakContainer ?? this.onStreakContainer,
      overdue: overdue ?? this.overdue,
      overdueContainer: overdueContainer ?? this.overdueContainer,
      onOverdueContainer: onOverdueContainer ?? this.onOverdueContainer,
      hairlineBorder: hairlineBorder ?? this.hairlineBorder,
      cardBackground: cardBackground ?? this.cardBackground,
      textSecondary: textSecondary ?? this.textSecondary,
      pillActiveBackground: pillActiveBackground ?? this.pillActiveBackground,
    );
  }

  @override
  TaskFlowColors lerp(ThemeExtension<TaskFlowColors>? other, double t) {
    if (other is! TaskFlowColors) return this;
    return TaskFlowColors(
      streak: Color.lerp(streak, other.streak, t)!,
      streakContainer: Color.lerp(streakContainer, other.streakContainer, t)!,
      onStreakContainer: Color.lerp(onStreakContainer, other.onStreakContainer, t)!,
      overdue: Color.lerp(overdue, other.overdue, t)!,
      overdueContainer: Color.lerp(overdueContainer, other.overdueContainer, t)!,
      onOverdueContainer: Color.lerp(onOverdueContainer, other.onOverdueContainer, t)!,
      hairlineBorder: Color.lerp(hairlineBorder, other.hairlineBorder, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      pillActiveBackground: Color.lerp(pillActiveBackground, other.pillActiveBackground, t)!,
    );
  }
}
