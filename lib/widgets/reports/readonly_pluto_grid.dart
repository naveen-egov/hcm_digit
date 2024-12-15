import 'package:collection/collection.dart';
import 'package:digit_components/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class ReadonlyDigitGrid extends StatelessWidget {
  final DigitGridData data;

  const ReadonlyDigitGrid({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlutoGrid(
      mode: PlutoGridMode.readOnly,
      noRowsWidget: const Center(child: Text('No data found')),
      configuration: PlutoGridConfiguration(
        scrollbar: const PlutoGridScrollbarConfig(
          isAlwaysShown: true,
        ),
        columnSize: const PlutoGridColumnSizeConfig(
          resizeMode: PlutoResizeMode.none,
          restoreAutoSizeAfterFrozenColumn: true,
        ),
        style: PlutoGridStyleConfig(
          gridBorderColor: const DigitColors().seaShellGray,
          oddRowColor: const DigitColors().seaShellGray,
          borderColor: const DigitColors().seaShellGray,
          iconColor: Colors.transparent,
          evenRowColor: Colors.transparent,
          activatedColor: const DigitColors().burningOrange.withOpacity(
                0.2,
              ),
          activatedBorderColor: const DigitColors().burningOrange.withOpacity(
                0.8,
              ),
          enableRowColorAnimation: true,
        ),
      ),
      columns: [
        ...data.columns.mapIndexed(
          (index, element) {
            final first = index == 0;

            return PlutoColumn(
              title: element.label,
              field: element.key,
              type: PlutoColumnType.text(),
              enableContextMenu: false,
              enableColumnDrag: false,
              width: element.width,
              cellPadding: first ? EdgeInsets.zero : null,
              frozen: first ? PlutoColumnFrozen.start : PlutoColumnFrozen.none,
              renderer: first
                  ? (rendererContext) => Container(
                        color: Colors.white,
                        child: Center(
                          child: Text(rendererContext.cell.value.toString()),
                        ),
                      )
                  : null,
            );
          },
        ),
      ],
      rows: [
        ...data.rows.map(
          (e) => PlutoRow(
            cells: Map.fromEntries(
              e.cells.map(
                (e) => MapEntry(
                  e.key,
                  PlutoCell(value: e.value),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DigitGridData {
  final List<DigitGridColumn> columns;
  final List<DigitGridRow> rows;

  DigitGridData({
    required this.columns,
    this.rows = const [],
  }) : assert(rows.every((e) => e.cells.length == columns.length));
}

class DigitGridColumn {
  final String label;
  final String key;
  final double width;

  const DigitGridColumn({
    required this.label,
    required this.key,
    this.width = 100,
  });
}

class DigitGridRow {
  final List<DigitGridCell> cells;

  DigitGridRow(this.cells);
}

class DigitGridCell {
  final String key;
  final String value;

  const DigitGridCell({
    required this.key,
    required this.value,
  });
}
