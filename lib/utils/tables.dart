import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';

enum EmptyButtonType { none, icon, elevated }

Widget emptyTables({
  required String message,
  VoidCallback? onAddPressed,
  EmptyButtonType buttonType = EmptyButtonType.none,
  String? buttonText,
}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(message, style: const TextStyle(color: Colors.black54)),
        if (buttonType != EmptyButtonType.none && onAddPressed != null) ...[
          const SizedBox(height: 5),

          /// ICON BUTTON (Add / Plus)
          if (buttonType == EmptyButtonType.icon)
            IconButton(
              icon: const Icon(Icons.add_circle, color: colorAll, size: 40),
              onPressed: onAddPressed,
            ),

          /// ELEVATED BUTTON (Request Stock)
          if (buttonType == EmptyButtonType.elevated)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 12,
                ),
              ),
              onPressed: onAddPressed,
              child: Text(
                buttonText ?? "Confirm",
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ],
    ),
  );
}

//Universal Table builder
Widget buildUniversalTable({
  required List<String> headers,
  required List<List<dynamic>> rows,
  required double smallHeaderWidth,
  required double largeHeaderWidth,
  bool showHorizontalScrollbar = false,
  ScrollController? horizontalController,
}) {
  // When showing scrollbar, we need a shared controller between
  // Scrollbar and SingleChildScrollView. Use _UniversalTableWrapper
  // to manage the controller lifecycle if none was provided.
  if (showHorizontalScrollbar && horizontalController == null) {
    return _UniversalTableWrapper(
      headers: headers,
      rows: rows,
      smallHeaderWidth: smallHeaderWidth,
      largeHeaderWidth: largeHeaderWidth,
    );
  }

  return _buildTableContent(
    headers: headers,
    rows: rows,
    smallHeaderWidth: smallHeaderWidth,
    largeHeaderWidth: largeHeaderWidth,
    showHorizontalScrollbar: showHorizontalScrollbar,
    horizontalController: horizontalController,
  );
}

/// Stateful wrapper that owns a ScrollController for the horizontal scrollbar
class _UniversalTableWrapper extends StatefulWidget {
  final List<String> headers;
  final List<List<dynamic>> rows;
  final double smallHeaderWidth;
  final double largeHeaderWidth;

  const _UniversalTableWrapper({
    required this.headers,
    required this.rows,
    required this.smallHeaderWidth,
    required this.largeHeaderWidth,
  });

  @override
  State<_UniversalTableWrapper> createState() => _UniversalTableWrapperState();
}

class _UniversalTableWrapperState extends State<_UniversalTableWrapper> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildTableContent(
      headers: widget.headers,
      rows: widget.rows,
      smallHeaderWidth: widget.smallHeaderWidth,
      largeHeaderWidth: widget.largeHeaderWidth,
      showHorizontalScrollbar: true,
      horizontalController: _controller,
    );
  }
}

Widget _buildTableContent({
  required List<String> headers,
  required List<List<dynamic>> rows,
  required double smallHeaderWidth,
  required double largeHeaderWidth,
  bool showHorizontalScrollbar = false,
  ScrollController? horizontalController,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final isSmall = constraints.maxWidth < 800;

      Widget header(String value) {
        return SizedBox(
          width: isSmall ? smallHeaderWidth : largeHeaderWidth,
          child: Text(
            value,
            maxLines: null,
            softWrap: true,
            overflow: TextOverflow.fade,
            style: const TextStyle(color: Colors.red),
          ),
        );
      }

      Widget textCell(String value, {double? width, bool isSmall = false}) {
        return SizedBox(
          width: isSmall ? 80 : width ?? double.infinity,
          child: Text(
            value,
            maxLines: null,
            softWrap: true,
            overflow: TextOverflow.fade,
            style: const TextStyle(fontFamily: fontAll),
          ),
        );
      }

      /// Convert a dynamic cell into a Widget
      Widget buildCellFrom(dynamic cellValue) {
        if (cellValue == null) return textCell("");
        if (cellValue is Widget) return cellValue;
        // Numbers, bool, other -> toString
        return textCell(cellValue.toString());
      }

      final table = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: horizontalController,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              columnSpacing: isSmall ? 10 : 60,
              horizontalMargin: isSmall ? 12 : 24,
              dataRowMinHeight: kMinInteractiveDimension,
              dataRowMaxHeight: double.infinity,

              columns: headers
                  .map((h) => DataColumn(label: header(h)))
                  .toList(),

              rows: rows.map((rowCells) {
                return DataRow(
                  cells: rowCells
                      .map((value) => DataCell(buildCellFrom(value)))
                      .toList(),
                );
              }).toList(),
            ),
          ),
        ),
      );

      if (!showHorizontalScrollbar) {
        return table;
      }

      return Scrollbar(
        controller: horizontalController,
        scrollbarOrientation: ScrollbarOrientation.bottom,
        thumbVisibility: true,
        child: table,
      );
    },
  );
}
