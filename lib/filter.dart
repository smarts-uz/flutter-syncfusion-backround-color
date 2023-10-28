import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class CustomDataGrid extends StatefulWidget {
  const CustomDataGrid({
    Key? key,
    this.width,
    this.height,
    required this.tableName,
    required this.headerColor,
    required this.rowColor,
    required this.columnName,
    required this.rowValue,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String tableName;
  final Color headerColor;
  final Color rowColor;
  final String columnName;
  final dynamic rowValue;

  @override
  _CustomDataGridState createState() => _CustomDataGridState();
}

class _CustomDataGridState extends State<CustomDataGrid> {
  late JSONDataSource dataGridSource;

  @override
  void initState() {
    super.initState();
    dataGridSource = JSONDataSource(
      tableName: widget.tableName,
      rowColor: widget.rowColor,
      columnName: widget.columnName,
      rowValue: widget.rowValue,
    );
    dataGridSource.getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(widget.tableName),
      ),
      body: Container(
        width: widget.width,
        height: widget.height,
        child: SfDataGridTheme(
          data: SfDataGridThemeData(
            headerColor: widget.headerColor,
            sortIcon: Builder(
              builder: (context) {
                Widget? icon;
                String columnName = '';
                context.visitAncestorElements((element) {
                  if (element is GridHeaderCellElement) {
                    columnName = element.column.columnName;
                  }
                  return true;
                });
                var column = dataGridSource.sortedColumns
                    .where((element) => element.name == columnName)
                    .firstOrNull;
                if (column != null) {
                  if (column.sortDirection == DataGridSortDirection.ascending) {
                    icon = const Icon(Icons.arrow_upward_rounded, size: 16);
                  } else if (column.sortDirection ==
                      DataGridSortDirection.descending) {
                    icon = const Icon(Icons.arrow_downward_rounded, size: 16);
                  }
                }
                return icon ?? const SizedBox();
              },
            ),
            filterIcon: Builder(
              builder: (context) {
                Widget? icon;
                String columnName = '';
                context.visitAncestorElements((element) {
                  if (element is GridHeaderCellElement) {
                    columnName = element.column.columnName;
                  }
                  return true;
                });
                var column = dataGridSource.filterConditions.keys
                    .where((element) => element == columnName)
                    .firstOrNull;
                if (column != null) {
                  icon = const Icon(
                    Icons.filter_alt_outlined,
                    size: 20,
                  );
                }
                return icon ??
                    const Icon(
                      Icons.filter_alt_off_outlined,
                      size: 20,
                    );
              },
            ),
          ),
          child: SfDataGrid(
            allowSorting: true,
            allowFiltering: true,
            footerFrozenColumnsCount: 1,
            columnWidthMode: ColumnWidthMode.auto,
            source: dataGridSource,
            columns: dataGridSource.gridColumnsList,
          ),
        ),
      ),
    );
  }
}

class JSONDataSource extends DataGridSource {
  List<GridColumn> gridColumnsList = [];
  List<DataGridRow> dataRows = [];

  final supabase = Supabase.instance.client;
  var data;
  final String tableName;
  final Color rowColor;
  final String columnName;
  final dynamic rowValue;

  JSONDataSource({
    required this.tableName,
    required this.rowColor,
    required this.columnName,
    required this.rowValue,
  });

  void updateData({required var data}) {
    generateColumns(data[0].keys.toList());
    dataRows.clear();

    for (var row in data) {
      List<DataGridCell> _cells = [];
      for (var key in row.keys.toList()) {
        _cells.add(DataGridCell(columnName: key.toString(), value: row[key]));
      }
      _cells.add(const DataGridCell(columnName: 'actions', value: 'Actions'));
      dataRows.add(DataGridRow(cells: _cells));
    }
    notifyListeners();
  }

  void generateColumns(var headers) {
    gridColumnsList.clear();
    for (var h in headers) {
      gridColumnsList.add(
        GridColumn(
          columnName: h.toString(),
          autoFitPadding: const EdgeInsets.all(12.0),
          label: Container(
            padding: const EdgeInsets.all(12.0),
            alignment: Alignment.center,
            child: Text(
              h.toString(),
            ),
          ),
        ),
      );
    }
    gridColumnsList.add(
      GridColumn(
        columnName: 'actions',
        allowSorting: false,
        allowFiltering: false,
        width: 180,
        autoFitPadding: const EdgeInsets.all(12.0),
        label: Container(
          padding: const EdgeInsets.all(12.0),
          alignment: Alignment.center,
          child: const Text('Actions'),
        ),
      ),
    );
  }

  void getData() async {
    final data =
        await supabase.from(tableName).select().eq(columnName, rowValue);
    updateData(data: data);
  }

  @override
  List<DataGridRow> get rows => dataRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      if (e.columnName == 'actions') {
        return Container(
          color: rowColor,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.remove_red_eye),
              ),
            ],
          ),
        );
      }
      return Container(
        color: rowColor,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(12.0),
        child: Text(
          e.value.toString(),
        ),
      );
    }).toList());
  }
}
