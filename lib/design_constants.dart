import 'package:flutter/material.dart';

// ============================================================================
// BRANDING
// ============================================================================
const String fontAll = 'Montserrat';
const String imageAll = 'assets/images/chicken_joo_logo.png';
const Color colorAll = Colors.red;

// ============================================================================
// COLORS - Primary
// ============================================================================
const Color primaryRed = Color(0xFFEF4848);
const Color primaryRedDark = Color(0xFFD32F2F);
const Color loginButtonRed = Color(0xFFD62828);
const Color actionButtonRed = Color(0xFFE30417);
const Color approveGreen = Color(0xFF0A8F1A);
const Color backgroundGrey = Color(0xFFEEEEEE);

// ============================================================================
// COLORS - Status
// ============================================================================
const Color statusConnected = Colors.green;
const Color statusReconnecting = Colors.orange;
const Color statusPolling = Colors.blue;
const Color statusDisconnected = Colors.red;
const Color statusSuccess = Colors.green;
const Color statusError = Colors.red;
const Color statusWarning = Colors.orange;

// ============================================================================
// COLORS - UI Elements
// ============================================================================
const Color textPrimary = Colors.black;
const Color textSecondary = Colors.black54;
const Color textMuted = Colors.grey;
const Color cardBackground = Colors.white;
const Color searchHighlight = Colors.yellow;
const Color shadowColor = Colors.black;

// ============================================================================
// COLORS - Chart Palette (for reports)
// ============================================================================
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
const double fontSizeTitle = 26.0;
const double fontSizeHeader = 24.0;
const double fontSizeDialogTitle = 20.0;
const double fontSizeButton = 18.0;
const double fontSizeInput = 18.0;
const double fontSizeBody = 16.0;
const double fontSizeSubtitle = 14.0;
const double fontSizeCaption = 12.0;
const double fontSizeSmall = 11.0;
const double fontSizeTiny = 10.0;

// ============================================================================
// SPACING - Standard sizes for SizedBox (height/width)
// ============================================================================
const double spacingXxs = 4.0;
const double spacingXs = 5.0;
const double spacingSm = 6.0;
const double spacingMd = 8.0;
const double spacingLg = 10.0;
const double spacingXl = 12.0;
const double spacingXxl = 16.0;
const double spacing20 = 20.0;
const double spacing24 = 24.0;
const double spacing30 = 30.0;
const double spacing40 = 40.0;

// ============================================================================
// BORDER RADIUS
// ============================================================================
const double radiusXs = 4.0;
const double radiusSm = 6.0;
const double radiusMd = 8.0;
const double radiusLg = 10.0;
const double radiusXl = 12.0;
const double radiusXxl = 16.0;
const double radiusSearchBar = 25.0;
const double radiusPill = 30.0;

// ============================================================================
// PADDING - Common EdgeInsets
// ============================================================================
const EdgeInsets paddingAllXs = EdgeInsets.all(4);
const EdgeInsets paddingAllSm = EdgeInsets.all(10);
const EdgeInsets paddingAllMd = EdgeInsets.all(12);
const EdgeInsets paddingAllLg = EdgeInsets.all(16);
const EdgeInsets paddingAllXl = EdgeInsets.all(20);

const EdgeInsets paddingHorizontalSm = EdgeInsets.symmetric(horizontal: 8);
const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(horizontal: 12);
const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(horizontal: 16);
const EdgeInsets paddingHorizontalXl = EdgeInsets.symmetric(horizontal: 20);
const EdgeInsets paddingHorizontalInput = EdgeInsets.symmetric(horizontal: 25);

const EdgeInsets paddingVerticalSm = EdgeInsets.symmetric(vertical: 4);
const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(vertical: 8);
const EdgeInsets paddingVerticalLg = EdgeInsets.symmetric(vertical: 14);
const EdgeInsets paddingVerticalXl = EdgeInsets.symmetric(vertical: 16);

const EdgeInsets paddingStatusBadge = EdgeInsets.symmetric(horizontal: 8, vertical: 4);
const EdgeInsets paddingButton = EdgeInsets.symmetric(horizontal: 25, vertical: 12);
const EdgeInsets paddingInput = EdgeInsets.symmetric(horizontal: 25, vertical: 18);

// ============================================================================
// ICON SIZES
// ============================================================================
const double iconSizeXs = 14.0;
const double iconSizeSm = 16.0;
const double iconSizeMd = 20.0;
const double iconSizeLg = 24.0;
const double iconSizeXl = 28.0;
const double iconSizeXxl = 40.0;
const double iconSizeEmpty = 64.0;

// ============================================================================
// ELEVATION & SHADOWS
// ============================================================================
const double elevationLow = 4.0;
const double elevationMedium = 8.0;
const double elevationHigh = 10.0;
const double elevationDialog = 16.0;
const double shadowBlurLow = 4.0;
const double shadowBlurMedium = 10.0;
const double shadowOpacity = 0.1;
const double shadowOpacityLight = 0.05;

// ============================================================================
// DIALOG CONSTRAINTS
// ============================================================================
const BoxConstraints dialogConstraintsLarge = BoxConstraints(maxWidth: 900, maxHeight: 700);
const BoxConstraints dialogConstraintsMedium = BoxConstraints(maxWidth: 700, maxHeight: 600);

// ============================================================================
// PROGRESS INDICATOR
// ============================================================================
const double progressIndicatorSize = 20.0;
const double progressIndicatorStrokeWidth = 2.0;

// ============================================================================
// APP LAYOUT HELPER CLASS
// ============================================================================
class AppLayout {
  const AppLayout._();

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > 1000;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static double fieldPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 400;
    if (width >= 800) return 200;
    return 24;
  }

  static double loginButtonWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 320;
    if (width >= 800) return 280;
    return double.infinity;
  }

  /// Breakpoint constants
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

  static const TextStyle title = TextStyle(
    fontFamily: fontAll,
    fontSize: fontSizeTitle,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle header = TextStyle(
    fontFamily: fontAll,
    fontSize: fontSizeHeader,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle dialogTitle = TextStyle(
    fontFamily: fontAll,
    fontSize: fontSizeDialogTitle,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontAll,
    fontSize: fontSizeButton,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle input = TextStyle(
    fontFamily: fontAll,
    fontSize: fontSizeInput,
    color: textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontAll,
    fontSize: fontSizeBody,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: fontAll,
    fontSize: fontSizeSubtitle,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontAll,
    fontSize: fontSizeCaption,
    color: textMuted,
  );

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

  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: loginButtonRed,
    foregroundColor: Colors.white,
    padding: paddingVerticalXl,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusLg),
    ),
    elevation: elevationHigh,
  );

  static ButtonStyle actionButton = ElevatedButton.styleFrom(
    backgroundColor: actionButtonRed,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
    ),
  );

  static ButtonStyle successButton = ElevatedButton.styleFrom(
    backgroundColor: approveGreen,
    foregroundColor: Colors.white,
    padding: paddingVerticalLg,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusPill),
    ),
  );

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

  static const BoxDecoration primaryBackground = BoxDecoration(
    color: primaryRed,
  );

  static BoxDecoration primaryGradient = const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [primaryRed, primaryRedDark],
    ),
  );

  static BoxDecoration card = BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(radiusXl),
  );

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

  static BoxDecoration dialog = BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(radiusXxl),
  );
}
