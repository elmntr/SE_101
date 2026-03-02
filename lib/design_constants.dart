import 'package:flutter/material.dart';

// ============================================================================
// BRANDING
// ============================================================================

/// Used in: tables.dart, login_header.dart, login_form.dart, home_mobile.dart,
/// home_desktop.dart, home.dart, employee_items.dart, employee_account.dart,
/// employee_review_changes_page.dart, franchisee screens (reports, items, inventory, employee, products)
const String fontAll = 'Montserrat';

/// Used in: login_header.dart, home_mobile.dart, home_desktop.dart
const String imageAll = 'assets/images/chicken_joo_logo.png';

/// Used in: tables.dart (header text, add icon), sync_conflicts_screen.dart
const Color colorAll = Colors.red;

// ============================================================================
// COLORS - Primary
// ============================================================================

/// Used in: AppDecorations.primaryBackground (login scaffolds), AppDecorations.primaryGradient
const Color primaryRed = Color(0xFFEF4848);

/// Used in: AppDecorations.primaryGradient (auth_gate_screen.dart)
const Color primaryRedDark = Color(0xFFD32F2F);

/// Used in: login_form.dart (login button), AppButtonStyles.primaryButton
const Color loginButtonRed = Color(0xFFD62828);

/// Used in: employee_items.dart (dialogs), employee_items_mobile/desktop.dart (FAB),
/// employee_change_item_stock.dart, replenish_stock_tab.dart, AppButtonStyles.actionButton
const Color actionButtonRed = Color(0xFFE30417);

/// Used in: employee_review_changes_page.dart (approve button), AppButtonStyles.successButton
const Color approveGreen = Color(0xFF0A8F1A);

/// Used in: employee_change_item_stock.dart (main container background)
const Color backgroundGrey = Color(0xFFEEEEEE);

// ============================================================================
// COLORS - Status
// ============================================================================

/// Used in: realtime_status_indicator.dart (connected status)
const Color statusConnected = Colors.green;

/// Used in: realtime_status_indicator.dart (reconnecting status)
const Color statusReconnecting = Colors.orange;

/// Used in: realtime_status_indicator.dart (polling status)
const Color statusPolling = Colors.blue;

/// Used in: realtime_status_indicator.dart (disconnected status)
const Color statusDisconnected = Colors.red;

/// Available for success states
const Color statusSuccess = Colors.green;

/// Used in: tables.dart (elevated button), employee_review_changes_page.dart (delete dialog),
/// AppButtonStyles.dangerButton
const Color statusError = Colors.red;

/// Available for warning states
const Color statusWarning = Colors.orange;

// ============================================================================
// COLORS - UI Elements
// ============================================================================

/// Used in: AppTextStyles.header, AppTextStyles.input
const Color textPrimary = Colors.black;

/// Used in: tables.dart (empty message text)
const Color textSecondary = Colors.black54;

/// Used in: search_service.dart (hint text, icons), login_form.dart (visibility toggle),
/// AppTextStyles.caption, employee_change_item_stock.dart
const Color textMuted = Colors.grey;

/// Used in: login_form.dart, AppDecorations (card, inputField, searchBar, dialog),
/// employee_change_item_stock.dart
const Color cardBackground = Colors.white;

/// Used in: search_service.dart (highlighted search text)
const Color searchHighlight = Colors.yellow;

/// Used in: AppDecorations.inputField, AppDecorations.searchBar (box shadows)
const Color shadowColor = Colors.black;

// ============================================================================
// COLORS - Chart Palette (for reports)
// ============================================================================

/// Used in: franchisee_reports_controller.dart (itemColors for stacked/grouped bar charts)
const List<Color> chartColorPalette = [
  Color(0xFFE53935), // Red
  Color(0xFF1E88E5), // Blue
  Color(0xFF43A047), // Green
  Color(0xFFFB8C00), // Orange
  Color(0xFF8E24AA), // Purple
  Color(0xFF00ACC1), // Cyan
  Color(0xFFFFB300), // Amber
  Color(0xFF5E35B1), // Deep Purple
  Color(0xFF00897B), // Teal
  Color(0xFFD81B60), // Pink
  Color(0xFF3949AB), // Indigo
  Color(0xFF7CB342), // Light Green
];

// ============================================================================
// FONT SIZES
// ============================================================================

/// Used in: AppTextStyles.title (page titles - 26px)
const double fontSizeTitle = 26.0;

/// Used in: AppTextStyles.header (login_header.dart - 24px)
const double fontSizeHeader = 24.0;

/// Used in: AppTextStyles.dialogTitle (employee_items.dart dialogs - 20px)
const double fontSizeDialogTitle = 20.0;

/// Used in: AppTextStyles.button, replenish_stock_tab.dart (18px)
const double fontSizeButton = 18.0;

/// Used in: AppTextStyles.input (login_form.dart text fields - 18px)
const double fontSizeInput = 18.0;

/// Used in: AppTextStyles.body, auth_gate_screen.dart, replenish_stock_tab.dart (16px)
const double fontSizeBody = 16.0;

/// Used in: AppTextStyles.subtitle, replenish_stock_tab.dart (14px)
const double fontSizeSubtitle = 14.0;

/// Used in: AppTextStyles.caption (12px)
const double fontSizeCaption = 12.0;

/// Used in: AppTextStyles.small, realtime_status_indicator.dart (11px)
const double fontSizeSmall = 11.0;

/// Available for tiny text (10px)
const double fontSizeTiny = 10.0;

// ============================================================================
// SPACING - Standard sizes for SizedBox (height/width)
// ============================================================================

/// 4px - Available for extra extra small spacing
const double spacingXxs = 4.0;

/// 5px - Used in: tables.dart (between message and button)
const double spacingXs = 5.0;

/// 6px - Used in: realtime_status_indicator.dart (between icon and text)
const double spacingSm = 6.0;

/// 8px - Available for medium spacing
const double spacingMd = 8.0;

/// 10px - Available for large spacing
const double spacingLg = 10.0;

/// 12px - Used in: employee_items.dart (dialog header), replenish_stock_tab.dart,
/// employee_review_changes_page.dart
const double spacingXl = 12.0;

/// 16px - Used in: employee_change_item_stock.dart (before save button)
const double spacingXxl = 16.0;

/// 20px - Used in: login_form.dart, login_header.dart, replenish_stock_tab.dart
const double spacing20 = 20.0;

/// 24px - Used in: auth_gate_screen.dart (below loading spinner)
const double spacing24 = 24.0;

/// 30px - Used in: login_form.dart (before login button)
const double spacing30 = 30.0;

/// 40px - Used in: login_header.dart (after title)
const double spacing40 = 40.0;

// ============================================================================
// BORDER RADIUS
// ============================================================================

/// 4px - Used in: realtime_status_indicator.dart (compact mode container)
const double radiusXs = 4.0;

/// 6px - Available for small radius
const double radiusSm = 6.0;

/// 8px - Used in: replenish_stock_tab.dart (submit button), AppButtonStyles.actionButton
const double radiusMd = 8.0;

/// 10px - Used in: login_form.dart (login button), AppButtonStyles.primaryButton
const double radiusLg = 10.0;

/// 12px - Used in: realtime_status_indicator.dart, employee_change_item_stock.dart,
/// AppDecorations.card
const double radiusXl = 12.0;

/// 16px - Used in: employee_items.dart (dialogs), AppDecorations.dialog
const double radiusXxl = 16.0;

/// 25px - Used in: AppDecorations.searchBar
const double radiusSearchBar = 25.0;

/// 30px - Used in: login_form.dart (input fields), employee_items_mobile/desktop.dart (FAB),
/// employee_change_item_stock.dart, employee_review_changes_page.dart, AppDecorations.inputField,
/// AppButtonStyles.successButton, AppButtonStyles.dangerButton
const double radiusPill = 30.0;

// ============================================================================
// PADDING - Common EdgeInsets
// ============================================================================

/// 4px all - Used in: realtime_status_indicator.dart (compact mode)
const EdgeInsets paddingAllXs = EdgeInsets.all(4);

/// 10px all - Available
const EdgeInsets paddingAllSm = EdgeInsets.all(10);

/// 12px all - Available
const EdgeInsets paddingAllMd = EdgeInsets.all(12);

/// 16px all - Used in: employee_change_item_stock.dart (info card margin/padding)
const EdgeInsets paddingAllLg = EdgeInsets.all(16);

/// 20px all - Available
const EdgeInsets paddingAllXl = EdgeInsets.all(20);

/// 8px horizontal - Available
const EdgeInsets paddingHorizontalSm = EdgeInsets.symmetric(horizontal: 8);

/// 12px horizontal - Available
const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(horizontal: 12);

/// 16px horizontal - Available
const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(horizontal: 16);

/// 20px horizontal - Available
const EdgeInsets paddingHorizontalXl = EdgeInsets.symmetric(horizontal: 20);

/// 25px horizontal - Available
const EdgeInsets paddingHorizontalInput = EdgeInsets.symmetric(horizontal: 25);

/// 4px vertical - Available
const EdgeInsets paddingVerticalSm = EdgeInsets.symmetric(vertical: 4);

/// 8px vertical - Available
const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(vertical: 8);

/// 14px vertical - Used in: employee_review_changes_page.dart (approve button),
/// AppButtonStyles.successButton, AppButtonStyles.dangerButton
const EdgeInsets paddingVerticalLg = EdgeInsets.symmetric(vertical: 14);

/// 16px vertical - Used in: login_form.dart (login button), AppButtonStyles.primaryButton
const EdgeInsets paddingVerticalXl = EdgeInsets.symmetric(vertical: 16);

/// 8px horizontal, 4px vertical - Used in: realtime_status_indicator.dart (badge)
const EdgeInsets paddingStatusBadge = EdgeInsets.symmetric(horizontal: 8, vertical: 4);

/// 25px horizontal, 12px vertical - Used in: tables.dart (elevated button)
const EdgeInsets paddingButton = EdgeInsets.symmetric(horizontal: 25, vertical: 12);

/// 25px horizontal, 18px vertical - Used in: login_form.dart (text fields)
const EdgeInsets paddingInput = EdgeInsets.symmetric(horizontal: 25, vertical: 18);

// ============================================================================
// ICON SIZES
// ============================================================================

/// 14px - Available
const double iconSizeXs = 14.0;

/// 16px - Available
const double iconSizeSm = 16.0;

/// 20px - Used in: search_service.dart (clear icon)
const double iconSizeMd = 20.0;

/// 24px - Used in: employee_items.dart (dialog header icons)
const double iconSizeLg = 24.0;

/// 28px - Available
const double iconSizeXl = 28.0;

/// 40px - Used in: tables.dart (add circle icon)
const double iconSizeXxl = 40.0;

/// 64px - Available for empty state icons
const double iconSizeEmpty = 64.0;

// ============================================================================
// ELEVATION & SHADOWS
// ============================================================================

/// 4px - Available
const double elevationLow = 4.0;

/// 8px - Used in: employee_items_mobile/desktop.dart (FAB)
const double elevationMedium = 8.0;

/// 10px - Used in: AppButtonStyles.primaryButton (login button)
const double elevationHigh = 10.0;

/// 16px - Used in: employee_items.dart (dialogs)
const double elevationDialog = 16.0;

/// 4px - Used in: AppDecorations.searchBar
const double shadowBlurLow = 4.0;

/// 10px - Used in: AppDecorations.inputField
const double shadowBlurMedium = 10.0;

/// 0.1 (10%) - Used in: AppDecorations.inputField, employee_items.dart (dialog shadows)
const double shadowOpacity = 0.1;

/// 0.05 (5%) - Used in: AppDecorations.searchBar
const double shadowOpacityLight = 0.05;

// ============================================================================
// DIALOG CONSTRAINTS
// ============================================================================

/// 900x700 - Used in: employee_items.dart (Change Stock dialog)
const BoxConstraints dialogConstraintsLarge = BoxConstraints(maxWidth: 900, maxHeight: 700);

/// 700x600 - Used in: employee_items.dart (Review Changes dialog)
const BoxConstraints dialogConstraintsMedium = BoxConstraints(maxWidth: 700, maxHeight: 600);

// ============================================================================
// PROGRESS INDICATOR
// ============================================================================

/// 20px - Used in: login_form.dart, replenish_stock_tab.dart (loading spinner size)
const double progressIndicatorSize = 20.0;

/// 2px - Used in: login_form.dart, replenish_stock_tab.dart (spinner stroke)
const double progressIndicatorStrokeWidth = 2.0;

// ============================================================================
// APP LAYOUT HELPER CLASS
// Used in: login_form.dart (fieldPadding, loginButtonWidth)
// ============================================================================
class AppLayout {
  const AppLayout._();

  /// Used in: responsive layout decisions
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > 1000;

  /// Used in: responsive layout decisions
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  /// Used in: login_form.dart (text field horizontal padding)
  static double fieldPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 400;
    if (width >= 800) return 200;
    return 24;
  }

  /// Used in: login_form.dart (login button width constraint)
  static double loginButtonWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 320;
    if (width >= 800) return 280;
    return double.infinity;
  }

  /// Breakpoint constants for responsive design
  static const double breakpointMobile = 600;
  static const double breakpointTablet = 800;
  static const double breakpointDesktop = 1000;
  static const double breakpointLarge = 1200;
}

// ============================================================================
// TEXT STYLES - Common reusable text styles
// ============================================================================
class AppTextStyles {
  const AppTextStyles._();

  /// Available for page titles
  static const TextStyle title = TextStyle(
    fontFamily: fontAll,
    fontSize: fontSizeTitle,
    fontWeight: FontWeight.w600,
  );

  /// Used in: login_header.dart (welcome/sign in text)
  static const TextStyle header = TextStyle(
    fontFamily: fontAll,
    fontSize: fontSizeHeader,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  /// Used in: employee_items.dart (dialog headers - Change Stock, Review Changes)
  static const TextStyle dialogTitle = TextStyle(
    fontFamily: fontAll,
    fontSize: fontSizeDialogTitle,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  /// Used in: login_form.dart (login button text style)
  static const TextStyle button = TextStyle(
    fontFamily: fontAll,
    fontSize: fontSizeButton,
    fontWeight: FontWeight.bold,
  );

  /// Used in: login_form.dart (text field style)
  static const TextStyle input = TextStyle(
    fontFamily: fontAll,
    fontSize: fontSizeInput,
    color: textPrimary,
  );

  /// Available for body text
  static const TextStyle body = TextStyle(
    fontFamily: fontAll,
    fontSize: fontSizeBody,
  );

  /// Available for subtitles
  static const TextStyle subtitle = TextStyle(
    fontFamily: fontAll,
    fontSize: fontSizeSubtitle,
  );

  /// Available for captions
  static const TextStyle caption = TextStyle(
    fontFamily: fontAll,
    fontSize: fontSizeCaption,
    color: textMuted,
  );

  /// Used in: realtime_status_indicator.dart (status text)
  static const TextStyle small = TextStyle(
    fontFamily: fontAll,
    fontSize: fontSizeSmall,
    fontWeight: FontWeight.w600,
  );
}

// ============================================================================
// BUTTON STYLES - Common button styles
// ============================================================================
class AppButtonStyles {
  const AppButtonStyles._();

  /// Used in: login_form.dart (login button)
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: loginButtonRed,
    foregroundColor: Colors.white,
    padding: paddingVerticalXl,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusLg),
    ),
    elevation: elevationHigh,
  );

  /// Available for action buttons (red)
  static ButtonStyle actionButton = ElevatedButton.styleFrom(
    backgroundColor: actionButtonRed,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
    ),
  );

  /// Available for success/approve actions (green)
  static ButtonStyle successButton = ElevatedButton.styleFrom(
    backgroundColor: approveGreen,
    foregroundColor: Colors.white,
    padding: paddingVerticalLg,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusPill),
    ),
  );

  /// Available for danger/cancel actions
  static ButtonStyle dangerButton = ElevatedButton.styleFrom(
    backgroundColor: statusError,
    foregroundColor: Colors.white,
    padding: paddingVerticalLg,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusPill),
    ),
  );
}

// ============================================================================
// DECORATIONS - Common BoxDecoration styles
// ============================================================================
class AppDecorations {
  const AppDecorations._();

  /// Used in: login_scaffold_mobile.dart, login_scaffold_desktop.dart (background)
  static const BoxDecoration primaryBackground = BoxDecoration(
    color: primaryRed,
  );

  /// Used in: auth_gate_screen.dart (loading screen gradient background)
  static BoxDecoration primaryGradient = const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [primaryRed, primaryRedDark],
    ),
  );

  /// Available for card containers
  static BoxDecoration card = BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(radiusXl),
  );

  /// Used in: login_form.dart (text field decoration)
  static BoxDecoration inputField = BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(radiusPill),
    boxShadow: [
      BoxShadow(
        color: shadowColor.withValues(alpha: shadowOpacity),
        blurRadius: shadowBlurMedium,
        offset: const Offset(0, 5),
      ),
    ],
  );

  /// Used in: search_service.dart (search bar container)
  static BoxDecoration searchBar = BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(radiusSearchBar),
    boxShadow: [
      BoxShadow(
        color: shadowColor.withValues(alpha: shadowOpacityLight),
        blurRadius: shadowBlurLow,
        offset: const Offset(0, 2),
      ),
    ],
  );

  /// Used in: employee_items.dart (dialog container decoration)
  static BoxDecoration dialog = BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(radiusXxl),
  );
}
