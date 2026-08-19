import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:form_manager/Controller/provider_controller.dart';
import 'package:form_manager/Model/form_data_model.dart';
import 'package:provider/provider.dart';

class ReportView extends StatefulWidget {
  const ReportView({super.key});

  @override
  State<ReportView> createState() => _ReportViewState();
}

class _ReportOneRow {
  final String name;
  final String its;
  final String sfNo;
  final String contact;
  final String form2Expectation;
  final String form4Expectation;

  const _ReportOneRow({
    required this.name,
    required this.its,
    required this.sfNo,
    required this.contact,
    required this.form2Expectation,
    required this.form4Expectation,
  });

  String get finalExpectation =>
      _isYes(form2Expectation) || _isYes(form4Expectation) ? 'Yes' : 'No';

  static bool _isYes(String value) => value.trim().toLowerCase() == 'yes';

  List<dynamic> get exportValues => [
    name,
    its,
    sfNo,
    contact,
    form2Expectation,
    form4Expectation,
    finalExpectation,
  ];
}

class _ReportViewState extends State<ReportView> {
  final _searchController = TextEditingController();
  List<_ReportOneRow> _rows = [];
  bool _isLoading = true;
  String? _error;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_refreshTable);
    _loadReport();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_refreshTable)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadReport() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    if (!provider.isDev && !provider.isFinance) {
      setState(() {
        _isLoading = false;
        _error = 'Access denied. Reports are available to Finance accounts.';
      });
      return;
    }

    try {
      final rows = await Future.wait(
        provider.people.map((person) async {
          final forms = await Future.wait<FormDataModel?>([
            provider.getSubmittedForm(person.id, 2),
            provider.getSubmittedForm(person.id, 4),
          ]);
          if (forms[0] == null) return null;
          return _ReportOneRow(
            name: person.name,
            its: person.its.toString(),
            sfNo: person.sfNo?.toString() ?? '',
            contact: person.contact,
            form2Expectation: (forms[0]?.answers['financeExpectation'] ?? 'No')
                .toString(),
            form4Expectation: (forms[1]?.answers['financeExpectation'] ?? 'No')
                .toString(),
          );
        }),
      );

      if (!mounted) return;
      setState(() {
        _rows = rows.whereType<_ReportOneRow>().toList();
        _isLoading = false;
      });
      _sortRows();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Unable to load Report One: $error';
      });
    }
  }

  List<_ReportOneRow> get _visibleRows {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return List<_ReportOneRow>.from(_rows);
    return _rows.where((row) {
      return row.name.toLowerCase().contains(query) ||
          row.its.toLowerCase().contains(query) ||
          row.sfNo.toLowerCase().contains(query) ||
          row.contact.toLowerCase().contains(query) ||
          row.form2Expectation.toLowerCase().contains(query) ||
          row.form4Expectation.toLowerCase().contains(query) ||
          row.finalExpectation.toLowerCase().contains(query);
    }).toList();
  }

  String _valueFor(_ReportOneRow row, int columnIndex) {
    return [
      row.name,
      row.its,
      row.sfNo,
      row.contact,
      row.form2Expectation,
      row.form4Expectation,
      row.finalExpectation,
    ][columnIndex].toLowerCase();
  }

  void _sortRows() {
    _rows.sort((a, b) {
      final comparison = _valueFor(
        a,
        _sortColumnIndex,
      ).compareTo(_valueFor(b, _sortColumnIndex));
      return _sortAscending ? comparison : -comparison;
    });
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _sortRows();
    });
  }

  void _refreshTable() => setState(() {});

  Future<void> _exportVisibleRows() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    try {
      await provider.exportReportOneToExcel(
        _visibleRows.map((row) => row.exportValues).toList(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report One exported successfully.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final hasAccess = provider.isDev || provider.isFinance;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('Reports Dashboard'),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
      ),
      body: !hasAccess
          ? const Center(
              child: Text(
                'Access denied. Reports are available to Finance accounts.',
              ),
            )
          : _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [_buildReportCard()],
                  ),
                  const SizedBox(height: 24),
                  _buildExpectationChart(),
                  const SizedBox(height: 24),
                  _buildReportOneTable(),
                ],
              ),
            ),
    );
  }

  Widget _buildReportCard() {
    return Container(
      width: 360,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F766E),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reports',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Icon(Icons.table_chart_outlined, color: Colors.white70),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Report One',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Expectation comparison',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildReportOneTable() {
    final rows = _visibleRows;
    const headers = [
      'Name',
      'ITS Number',
      'SF Number',
      'Contact',
      'Expectation (Form 2)',
      'Expectation (Form 4)',
      'Final Expectation',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Report One',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _exportVisibleRows,
                icon: const Icon(Icons.download_outlined),
                label: const Text('Export to Excel'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Filter report rows',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          if (rows.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('No matching report rows.'),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                columns: [
                  for (var index = 0; index < headers.length; index++)
                    DataColumn(label: Text(headers[index]), onSort: _onSort),
                ],
                rows: [
                  for (final row in rows)
                    DataRow(
                      cells: [
                        DataCell(Text(row.name)),
                        DataCell(Text(row.its)),
                        DataCell(Text(row.sfNo)),
                        DataCell(Text(row.contact)),
                        DataCell(Text(row.form2Expectation)),
                        DataCell(Text(row.form4Expectation)),
                        DataCell(Text(row.finalExpectation)),
                      ],
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpectationChart() {
    final form2Yes = _rows
        .where((row) => _ReportOneRow._isYes(row.form2Expectation))
        .length;
    final form4Yes = _rows
        .where((row) => _ReportOneRow._isYes(row.form4Expectation))
        .length;
    final finalYes = _rows
        .where((row) => _ReportOneRow._isYes(row.finalExpectation))
        .length;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildExpectationPie(
          title: 'Form 2 Expectation',
          yesCount: form2Yes,
          color: const Color(0xFF2563EB),
        ),
        _buildExpectationPie(
          title: 'Form 4 Expectation',
          yesCount: form4Yes,
          color: const Color(0xFF0F766E),
        ),
        _buildExpectationPie(
          title: 'Final Expectation',
          yesCount: finalYes,
          color: const Color(0xFFF59E0B),
        ),
      ],
    );
  }

  Widget _buildExpectationPie({
    required String title,
    required int yesCount,
    required Color color,
  }) {
    final noCount = _rows.length - yesCount;
    final hasData = _rows.isNotEmpty;
    final sections = hasData
        ? [
            PieChartSectionData(
              color: color,
              value: yesCount.toDouble(),
              title: yesCount == 0 ? '' : '$yesCount',
              radius: 42,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            PieChartSectionData(
              color: Colors.grey.shade300,
              value: noCount.toDouble(),
              title: noCount == 0 ? '' : '$noCount',
              radius: 42,
              titleStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ]
        : [
            PieChartSectionData(
              color: Colors.grey.shade300,
              value: 1,
              title: '0',
              radius: 42,
            ),
          ];

    return Container(
      width: 360,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                height: 130,
                width: 130,
                child: PieChart(
                  PieChartData(
                    centerSpaceRadius: 32,
                    sectionsSpace: 2,
                    sections: sections,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChartLegend('Yes', yesCount, color),
                  const SizedBox(height: 10),
                  _buildChartLegend('No', noCount, Colors.grey.shade400),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend(String label, int count, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, color: color),
        const SizedBox(width: 8),
        Text(label),
        const SizedBox(width: 12),
        Text('$count', style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
