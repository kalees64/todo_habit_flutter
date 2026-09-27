---
name: Calm Kinetic
colors:
  surface: '#fcf9f8'
  surface-dim: '#dcd9d9'
  surface-bright: '#fcf9f8'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f6f3f2'
  surface-container: '#f0eded'
  surface-container-high: '#eae7e7'
  surface-container-highest: '#e5e2e1'
  on-surface: '#1c1b1b'
  on-surface-variant: '#404942'
  inverse-surface: '#313030'
  inverse-on-surface: '#f3f0ef'
  outline: '#707972'
  outline-variant: '#bfc9c0'
  surface-tint: '#296a49'
  primary: '#115637'
  on-primary: '#ffffff'
  primary-container: '#2f6f4e'
  on-primary-container: '#acefc6'
  inverse-primary: '#93d5ad'
  secondary: '#944a00'
  on-secondary: '#ffffff'
  secondary-container: '#fc8f34'
  on-secondary-container: '#663100'
  tertiary: '#951910'
  on-tertiary: '#ffffff'
  tertiary-container: '#b73326'
  on-tertiary-container: '#ffd8d2'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#aef1c8'
  primary-fixed-dim: '#93d5ad'
  on-primary-fixed: '#002111'
  on-primary-fixed-variant: '#095133'
  secondary-fixed: '#ffdcc5'
  secondary-fixed-dim: '#ffb783'
  on-secondary-fixed: '#301400'
  on-secondary-fixed-variant: '#713700'
  tertiary-fixed: '#ffdad5'
  tertiary-fixed-dim: '#ffb4a9'
  on-tertiary-fixed: '#410000'
  on-tertiary-fixed-variant: '#8e130c'
  background: '#fcf9f8'
  on-background: '#1c1b1b'
  surface-variant: '#e5e2e1'
typography:
  display-lg:
    fontFamily: Manrope
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Manrope
    fontSize: 26px
    fontWeight: '600'
    lineHeight: 34px
    letterSpacing: -0.015em
  title-lg:
    fontFamily: Manrope
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  title-md:
    fontFamily: Manrope
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: -0.005em
  section-title:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 22px
    letterSpacing: 0em
  body-lg:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: 0em
  body-md:
    fontFamily: Manrope
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0em
  body-sm:
    fontFamily: Manrope
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
    letterSpacing: 0.005em
  caption:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.02em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

This design system is tailored for personal productivity, habit reinforcement, and local-first task execution. The philosophy balances modern Material 3 conventions with an editorial, human-centered stillness: the interface steps out of the way to foster calm focus, clarity, and daily momentum.

### Target Audience & Emotional Tone
Designed for professionals, knowledge workers, and mindful achievers who prioritize intentionality over chaotic urgency. The visual and spatial language evokes:
- **Quiet Confidence:** Purposeful space without distracting flourishes or gamified noise.
- **Organic Progression:** A sense of continuous, steady growth through natural botanical accents and focused completion states.
- **Tactile Trust:** Immediate, predictable, local-first responsiveness reinforced through crisp layout structure and hairline precision.

### Design Movement
Modern Material 3 paired with functional minimalism. The system relies on restrained warm-neutral surfaces, soft ambient shadows, structured geometric typography, and intentional color accents that signal completion, consistency, and time-sensitivity without cognitive fatigue.

## Colors

The color system centers around organic growth, focused clarity, and contextual utility. Surfaces avoid harsh blue-light whites in favor of an archival, warm paper feel.

### Core Role Assignments
- **Primary (`#2F6F4E`):** Calm Forest Green. Applied to core actions, active bottom navigation states, completed task indicators, habit progression tracks, and primary floating actions.
- **Secondary (`#E67E22`):** Streak Amber. Reserved for habit streak flame indicators, active continuous milestones, and gentle energetic highlights.
- **Tertiary (`#C0392B`):** Muted Crimson. Strict functional usage for overdue tasks, missed daily thresholds, critical alerts, and destructive actions.
- **Neutral Primary (`#1A1A1A`):** Deep charcoal used for primary text, structural icons, and high-emphasis dark surface elements.
- **Neutral Secondary (`#6B6B6B`):** Neutral gray for timestamps, metadata, completion counters, and passive placeholder labels.
- **Hairline Border (`#E7E5E4`):** Soft stone gray used for crisp 1dp structural borders, card separation, and list dividers.
- **Background Canvas (`#FAFAF9`):** Warm off-white substrate providing soft, low-fatigue contrast.
- **Surface Elevation (`#FFFFFF`):** Pure white container surface for floating cards, bottom sheets, and modal views.

### Application Rules
- Maintain high contrast ratios for accessibility (minimum 4.5:1 for body and data readouts).
- Never use `#E67E22` or `#C0392B` for decorative large surface fills; reserve them for contextual signals (badges, chips, icons, streak meters).
- Progress states shift deliberately from neutral stroke (`#E7E5E4`) to solid forest green (`#2F6F4E`) upon completion.

## Typography

The typographic hierarchy balances Manrope's open, contemporary geometric form with Inter's precision in data and functional interface metadata.

### Typographic Roles
- **Display & Titles (Manrope):** Clean geometric letterforms with subtle optical weight adjustments. `title-lg` (22px semi-bold) sets the primary screen titles and sheet headers. `section-title` (16px semi-bold) groups tasks, time horizons, and habit frequency clusters.
- **Body Elements (Manrope):** `body-md` (14px regular) serves as the primary task description and habit name size, delivering balanced legibility without vertical bloat.
- **Labels & Microcopy (Inter):** `label-md`, `label-sm`, and `caption` (12px regular) provide crisp, neutral metric indicators (streak day counts, sub-task ratios, due-date pills).

### Hierarchy & Legibility Directives
- **Numeric Rhythm:** For habit streak counts and day matrices, use tabular figures (`tnum`) where available to prevent jitter during increment transitions.
- **Strikethrough States:** Completed tasks retain `body-md` sizing but drop to `#6B6B6B` with a `#E7E5E4` midline strike, maintaining visual scan integrity.

## Layout & Spacing

The layout philosophy follows a responsive mobile-first single-column structure that shifts cleanly into structured dual-pane containers on larger viewports.

### Grid & Density
- **Mobile Handheld (360dp - 599dp):** Single primary stack, 16dp outer screen margin (`margin`), 16dp item separation gap (`space-md`), and edge-to-edge bottom sheet surfaces.
- **Tablet / Foldable Expanded (600dp+):** Dual-pane layout (navigation rail + split task/habit detail view) using 24dp margins and 16dp column gutters (`gutter`).
- **Vertical Rhythm:** A strict 4dp / 8dp spatial baseline rules all component interiors. Task list rows measure 56dp minimum height to satisfy Android touch target guidelines while sustaining visual breathing room.

## Elevation & Depth

Visual hierarchy uses clean tonal surfaces bordered by hairline edges rather than heavy drop shadows, preserving an editorial, paper-crafted clarity.

### Elevation Hierarchy
- **Level 0 (Canvas Base):** `#FAFAF9`. Completely flat; hosts grouped background areas and static list backdrops.
- **Level 1 (Card & Row Surface):** `#FFFFFF` paired with a 1dp solid border in `#E7E5E4`. Shadow: `0px 1px 2px rgba(26, 26, 26, 0.04)`. Used for task items, habit cards, and summary stats.
- **Level 2 (Active Drag & Context Menus):** `#FFFFFF` surface with a 1dp `#E7E5E4` border. Shadow: `0px 4px 12px rgba(26, 26, 26, 0.08)`. Applied when reordering habits or opening context popovers.
- **Level 3 (Floating Action Button & Bottom Sheets):** `#FFFFFF` or `#2F6F4E`. Shadow: `0px 6px 16px rgba(26, 26, 26, 0.12)`. Bottom navigation is pinned flat against `#FFFFFF` with a 1dp hairline border on top (`#E7E5E4`).

## Shapes

The shape vocabulary uses gentle, organic geometry that balances modern friendliness with professional restraint.

### Geometric Scale
- **Cards, Content Panels & Bottom Sheets:** 16dp corner radius (`rounded-lg`). Creates distinct, friendly grouping boundaries that nest comfortably within phone display corners.
- **Interactive Buttons & Badges:** 24dp corner radius (`rounded-xl` / pill form) for Floating Action Buttons (FAB), filter chips, and streak badges.
- **Checkboxes & Habit Nodes:** 6dp corner radius (`rounded-sm` / soft square) for habit completion tiles and task checkboxes, differentiating interactive actionable nodes from outer content card contours.
- **Dividers & Separators:** 1dp hairline geometry without soft edge caps, extending edge-to-edge or inset by 16dp to match text alignment.

## Components

### Buttons & Actions
- **Primary FAB:** 56x56dp circular or extended pill (24dp radius), filled in `#2F6F4E` with an icon/label in `#FFFFFF`. Pressed state shifts to `#24583E`. Subtle 2dp elevation.
- **Secondary / Ghost Buttons:** Inset 12dp horizontal padding, 40dp height, transparent background with `#1A1A1A` text and `#E7E5E4` 1dp border.

### Checkboxes & Habit Toggles
- **Task Checkbox:** 22x22dp bounding box with a 6dp rounded corner. Default: 1.5dp border in `#E7E5E4`, clear center. Checked state: solid `#2F6F4E` fill with a sharp white checkmark glyph.
- **Habit Streak Tracker Matrix:** 7-day horizontal mini-strip. Each day node is an 8dp rounded square (32x32dp touch frame). Unfilled days use `#FAFAF9` with a 1dp `#E7E5E4` stroke. Completed days fill with `#2F6F4E`. An active current-day streak displays a gentle `#E67E22` flame indicator badge with glowing accent styling.

### Cards & Habit Rows
- **Task Row:** `#FFFFFF` background, 16dp corner radius, 1dp border `#E7E5E4`. Interior layout hosts the checkbox at the leading edge, task title in `body-md`, and trailing metadata (tag pill, due date) in `caption` with `#6B6B6B`.
- **Overdue Task Row:** Retains the white card surface but highlights the date badge text in `#C0392B` with a soft 10% `#C0392B` background tint.

### Chips & Badges
- **Streak Pill:** 24dp height, 12dp pill radius, background tint of `#FEF3E8`, text and flame icon in `#E67E22`, typography in `label-sm`.
- **Filter Chips:** 32dp height, 16dp pill radius. Inactive: `#FFFFFF` fill with 1dp `#E7E5E4` border and `#6B6B6B` text. Active: `#1A1A1A` fill with `#FFFFFF` text.

### Inputs & Quick-Add
- **Inline Quick Add:** Borderless input field set against `#FAFAF9` canvas, featuring `#6B6B6B` placeholder text in `body-md`. Triggers a raised bottom sheet (`#FFFFFF`, 16dp top radius) with dedicated date, priority, and reminder pill toggles.

### Navigation Elements
- **Android Status Bar:** Integrated cleanly with background (`#FAFAF9`), dark icons (`#1A1A1A`).
- **Bottom Navigation Bar:** 64dp height, `#FFFFFF` background with 1dp `#E7E5E4` top border. Active destinations use a pill-shaped indicator containing `#2F6F4E` icon and text; inactive destinations render in `#6B6B6B`.