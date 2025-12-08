import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';

Widget emptyTables({
  required String message,
  VoidCallback? onAddPressed,
}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(message, style: const TextStyle(color: Colors.black54)),
        if (onAddPressed != null) ...[
          const SizedBox(height: 15),
          IconButton(
            icon: const Icon(Icons.add_circle, color: colorAll, size: 55),
            onPressed: onAddPressed,
          ),
        ],
      ],
    ),
  );
}


//Universal Table builder
Widget buildUniversalTable({
  required List<String> headers,
  required List<List<dynamic>> rows, // ✅ Widgets now
  double smallHeaderWidth = 60,
  double largeHeaderWidth = 120,
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

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              columnSpacing: isSmall ? 10 : 60,
              horizontalMargin: isSmall ? 12 : 24,
              dataRowMinHeight: kMinInteractiveDimension,
              dataRowMaxHeight: double.infinity,

              columns: headers.map((h) => DataColumn(label: header(h))).toList(),

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
    },
  );
}

/// ✅ Helper to build text cell

