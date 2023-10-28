import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'filter.dart';

class MyDataHomePage extends StatefulWidget {
  const MyDataHomePage({
    Key? key,
    required this.tableName,
  }) : super(key: key);

  final String tableName;

  @override
  _CustomDataGridState createState() => _CustomDataGridState();
}

class _CustomDataGridState extends State<MyDataHomePage> {
  late JSONDataSource dataGridSource;

  @override
  void initState() {
    super.initState();
    dataGridSource = JSONDataSource(
      tableName: widget.tableName,
      context: context,
      // rowColor: Colors.yellow,
    );
    dataGridSource.getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rental'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: SfDataGridTheme(
          data: SfDataGridThemeData(
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
            // onCellDoubleTap: (detail) {
              // String columnName = detail.column.columnName;
              // print(columnName);
              // int selectedRowIndex = detail.rowColumnIndex.rowIndex - 1;
              // var row =
              //     dataGridSource.effectiveRows.elementAt(selectedRowIndex);
              // dynamic rowValue =
              //     row.getCells()[detail.rowColumnIndex.columnIndex].value;

              // if () return;
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => CustomDataGrid(
              //       headerColor: Colors.yellow,
              //       rowColor: Colors.yellow,
              //       tableName: 'rental',
              //       height: double.infinity,
              //       width: double.infinity,
              //       columnName: columnName,
              //       rowValue: rowValue,
              //     ),
              //   ),
              // );
            // },
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
  final BuildContext context;

  // final Color rowColor;

  JSONDataSource({required this.tableName, required this.context});

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
    final data = await supabase.from(tableName).select();
    updateData(data: data);
  }

  @override
  List<DataGridRow> get rows => dataRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      final int id = row.getCells()[0].value;
      if (e.columnName == 'actions') {
        return Container(
          // color: rowColor,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomDataGrid(
                        headerColor: Colors.yellow,
                        rowColor: Colors.yellow,
                        tableName: 'rental_payment',
                        height: double.infinity,
                        width: double.infinity,
                        columnName: 'rental_id',
                        rowValue: id,
                      ),
                    ),
                  );
                },
                child: const Text('RPa'),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomDataGrid(
                        headerColor: Colors.yellow,
                        rowColor: Colors.yellow,
                        tableName: 'rental_product',
                        height: double.infinity,
                        width: double.infinity,
                        columnName: 'rental_id',
                        rowValue: id,
                      ),
                    ),
                  );
                },
                child: const Text('RPr'),
              ),
            ],
          ),
        );
      }
      return Container(
        // color: rowColor,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(12.0),
        child: Text(
          e.value.toString(),
        ),
      );
    }).toList());
  }
}
