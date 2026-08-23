import 'dart:ui' show PointerDeviceKind;

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

class _BuildingReadinessRow {
  final String buildingName;
  final int profileCount;
  final int completedChecks;
  final int totalChecks;

  const _BuildingReadinessRow({
    required this.buildingName,
    required this.profileCount,
    required this.completedChecks,
    required this.totalChecks,
  });

  int get percentage =>
      totalChecks == 0 ? 0 : ((completedChecks / totalChecks) * 100).round();
}

class _ReportTwoRow {
  final String buildingName;
  final String name;
  final String its;
  final String sfNo;
  final String willingToSolar;
  final String landlordApproval;
  final String form2Expectation;
  final String form4Expectation;
  final String roofReady;

  const _ReportTwoRow({
    required this.buildingName,
    required this.name,
    required this.its,
    required this.sfNo,
    required this.willingToSolar,
    required this.landlordApproval,
    required this.form2Expectation,
    required this.form4Expectation,
    required this.roofReady,
  });

  String get finalExpectation =>
      _isYes(form2Expectation) || _isYes(form4Expectation) ? 'Yes' : 'No';

  int get readinessCount => [
    willingToSolar,
    landlordApproval,
    finalExpectation,
    roofReady,
  ].where((value) => value.trim().isNotEmpty).length;

  int get readinessPercentage => ((readinessCount / 4) * 100).round();

  static bool _isYes(String value) => value.trim().toLowerCase() == 'yes';
}

class _ReadinessLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _ReadinessLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, color: color),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _ReportViewState extends State<ReportView> {
  final _searchController = TextEditingController();
  final _buildingSearchController = TextEditingController();
  final _reportOneScrollController = ScrollController();
  final _buildingTableScrollController = ScrollController();
  final _applicantTableScrollController = ScrollController();
  final _chartScrollController = ScrollController();
  List<_ReportOneRow> _rows = [];
  List<_ReportTwoRow> _reportTwoRows = [];
  List<_BuildingReadinessRow> _readinessRows = [];
  bool _isLoading = true;
  String? _error;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  AppProvider? _provider;
  bool _reloadScheduled = false;
  bool _loadInProgress = false;
  int _selectedReport = 1;
  String? _selectedBuilding;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_refreshTable);
    _buildingSearchController.addListener(_refreshTable);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<AppProvider>(context);
    if (_provider != provider) {
      _provider?.removeListener(_onProviderChanged);
      _provider = provider;
      provider.addListener(_onProviderChanged);
      _scheduleReportLoad();
    }
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_refreshTable)
      ..dispose();
    _buildingSearchController
      ..removeListener(_refreshTable)
      ..dispose();
    _reportOneScrollController.dispose();
    _buildingTableScrollController.dispose();
    _applicantTableScrollController.dispose();
    _chartScrollController.dispose();
    _provider?.removeListener(_onProviderChanged);
    super.dispose();
  }

  void _onProviderChanged() {
    if (_provider?.isLoading == false && _provider?.isAuthLoading == false) {
      _scheduleReportLoad();
    }
  }

  void _scheduleReportLoad() {
    if (_reloadScheduled || !mounted) return;
    _reloadScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reloadScheduled = false;
      if (mounted) _loadReport();
    });
  }

  Future<void> _loadReport() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    if (provider.isLoading || provider.isAuthLoading || _loadInProgress) return;
    _loadInProgress = true;
    if (!provider.isDev && !provider.isFinance) {
      _loadInProgress = false;
      setState(() {
        _isLoading = false;
        _error = 'Access denied. Reports are available to Finance accounts.';
      });
      return;
    }

    try {
      final submittedForms = await provider.getSubmittedForms();
      final formsByPerson = <String, Map<int, FormDataModel>>{};
      for (final form in submittedForms) {
        formsByPerson.putIfAbsent(form.personId, () => {})[form.formNumber] =
            form;
      }

      final rows = provider.people.map((person) {
        final forms = formsByPerson[person.id] ?? {};
        final form2 = forms[2];
        if (form2 == null) return null;
        return _ReportOneRow(
          name: person.name,
          its: person.its.toString(),
          sfNo: person.sfNo?.toString() ?? '',
          contact: person.contact,
          form2Expectation: (form2.answers['financeExpectation'] ?? 'No')
              .toString(),
          form4Expectation: (forms[4]?.answers['financeExpectation'] ?? 'No')
              .toString(),
        );
      }).toList();

      final reportTwoRows = provider.people.map((person) {
        final forms = formsByPerson[person.id] ?? {};
        final form1 = forms[1];
        final form2 = forms[2];
        final form4 = forms[4];
        final temporaryForm = forms[AppProvider.temporaryFormNumber];
        final buildingName = person.buildingName.trim().isNotEmpty
            ? person.buildingName.trim()
            : (form1?.answers['buildingName'] ?? '').toString().trim();
        return _ReportTwoRow(
          buildingName: buildingName.isEmpty
              ? 'Unnamed building'
              : buildingName,
          name: person.name,
          its: person.its.toString(),
          sfNo: person.sfNo?.toString() ?? '',
          willingToSolar: (form1?.answers['solarWillingness'] ?? '').toString(),
          landlordApproval: (form1?.answers['landlordApproval'] ?? '')
              .toString(),
          form2Expectation: (form2?.answers['financeExpectation'] ?? '')
              .toString(),
          form4Expectation: (form4?.answers['financeExpectation'] ?? '')
              .toString(),
          roofReady: (temporaryForm?.answers['roofReady'] ?? '').toString(),
        );
      }).toList();

      final grouped = <String, List<int>>{};
      for (final row in reportTwoRows) {
        final key = row.buildingName;
        final totals = grouped.putIfAbsent(key, () => [0, 0, 0]);
        totals[0]++;
        totals[1] += row.readinessCount;
        totals[2] += 4;
      }
      final readinessRows =
          grouped.entries
              .map(
                (entry) => _BuildingReadinessRow(
                  buildingName: entry.key,
                  profileCount: entry.value[0],
                  completedChecks: entry.value[1],
                  totalChecks: entry.value[2],
                ),
              )
              .toList()
            ..sort((a, b) => a.buildingName.compareTo(b.buildingName));

      if (!mounted) return;
      setState(() {
        _rows = rows.whereType<_ReportOneRow>().toList();
        _reportTwoRows = reportTwoRows;
        _readinessRows = readinessRows;
        _isLoading = false;
      });
      _sortRows();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Unable to load Report One: $error';
      });
    } finally {
      _loadInProgress = false;
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
              padding: EdgeInsets.all(
                MediaQuery.sizeOf(context).width < 600 ? 12 : 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReportCards(),
                  const SizedBox(height: 24),
                  if (_selectedReport == 1) ...[
                    _buildExpectationChart(),
                    const SizedBox(height: 24),
                    _buildReportOneTable(),
                  ] else ...[
                    _buildReadinessReport(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildReportCards() {
    final completedBuildings = _readinessRows
        .where((row) => row.percentage >= 100)
        .length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth < 360
            ? constraints.maxWidth
            : 360.0;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildReportCard(
              reportNumber: 1,
              title: 'Report One',
              subtitle: 'Expectation comparison',
              count: _rows.length,
              total: _provider?.people.length ?? 0,
              color: const Color(0xFF2563EB),
              width: cardWidth,
            ),
            _buildReportCard(
              reportNumber: 2,
              title: 'Report Two',
              subtitle: 'Building readiness',
              count: completedBuildings,
              total: _readinessRows.length,
              color: const Color(0xFF0F766E),
              width: cardWidth,
            ),
          ],
        );
      },
    );
  }

  Widget _buildReportCard({
    required int reportNumber,
    required String title,
    required String subtitle,
    required int count,
    required int total,
    required Color color,
    required double width,
  }) {
    final isSelected = _selectedReport == reportNumber;
    final percentage = total > 0 ? (count / total * 100).round() : 0;
    final pending = total - count;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _selectedReport = reportNumber),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: width,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF1E293B),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    isSelected
                        ? Icons.check_circle
                        : Icons.insert_chart_outlined,
                    color: isSelected ? Colors.white : Colors.grey.shade400,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(
                  color: isSelected ? Colors.white70 : Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$count',
                        style: TextStyle(
                          color: isSelected ? Colors.white : color,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Completed out of $total',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF1E293B),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$pending pending',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white70
                              : Colors.grey.shade600,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.grey.shade600,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              const Text(
                'Report One',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            RawScrollbar(
              controller: _reportOneScrollController,
              thumbVisibility: true,
              trackVisibility: true,
              interactive: true,
              scrollbarOrientation: ScrollbarOrientation.bottom,
              thickness: 12,
              minThumbLength: 48,
              child: ScrollConfiguration(
                behavior: _horizontalScrollBehavior(context),
                child: SingleChildScrollView(
                  controller: _reportOneScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  child: DataTable(
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    columns: [
                      for (var index = 0; index < headers.length; index++)
                        DataColumn(
                          label: Text(headers[index]),
                          onSort: _onSort,
                        ),
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
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusCell(String value) {
    final normalized = value.trim().toLowerCase();
    final isYes = normalized == 'yes';
    final isNo = normalized == 'no';
    final percentage = normalized.endsWith('%')
        ? int.tryParse(normalized.substring(0, normalized.length - 1))
        : null;
    final color = percentage != null
        ? _readinessColor(percentage)
        : isYes
        ? const Color(0xFF166534)
        : isNo
        ? const Color(0xFFB91C1C)
        : const Color(0xFF64748B);
    final background = percentage != null
        ? color.withValues(alpha: 0.14)
        : isYes
        ? const Color(0xFFDCFCE7)
        : isNo
        ? const Color(0xFFFEE2E2)
        : const Color(0xFFF1F5F9);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        value.trim().isEmpty ? 'Pending' : value,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildReadinessReport() {
    final buildings = _readinessRows;
    final selectedRows = _selectedBuilding == null
        ? <_ReportTwoRow>[]
        : _reportTwoRows
              .where((row) => row.buildingName == _selectedBuilding)
              .toList();
    final selectedReadiness = selectedRows.isEmpty
        ? 0
        : (selectedRows
                      .map((row) => row.readinessCount)
                      .reduce((a, b) => a + b) /
                  (selectedRows.length * 4) *
                  100)
              .round();
    final chartRows = selectedRows.isEmpty ? _reportTwoRows : selectedRows;
    final chartReadiness = chartRows.isEmpty
        ? 0
        : (chartRows.map((row) => row.readinessCount).reduce((a, b) => a + b) /
                  (chartRows.length * 4) *
                  100)
              .round();

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
          const Text(
            'Report Two: Building Readiness',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text('Select a building to inspect all assigned profiles.'),
          const SizedBox(height: 16),
          _buildAnimatedReveal(
            _buildReadinessCharts(chartReadiness),
            const Duration(milliseconds: 450),
          ),
          const SizedBox(height: 24),
          _buildReadinessLegend(),
          const SizedBox(height: 24),
          _buildAnimatedReveal(
            _buildBuildingGrid(buildings),
            const Duration(milliseconds: 550),
          ),
          const SizedBox(height: 24),
          if (buildings.isEmpty)
            const Text('No building data available.')
          else
            RawScrollbar(
              controller: _buildingTableScrollController,
              thumbVisibility: true,
              trackVisibility: true,
              interactive: true,
              scrollbarOrientation: ScrollbarOrientation.bottom,
              thickness: 12,
              minThumbLength: 48,
              child: ScrollConfiguration(
                behavior: _horizontalScrollBehavior(context),
                child: SingleChildScrollView(
                  controller: _buildingTableScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Building Name')),
                      DataColumn(label: Text('Profiles')),
                      DataColumn(label: Text('Readiness')),
                    ],
                    rows: buildings
                        .map(
                          (row) => DataRow(
                            selected: row.buildingName == _selectedBuilding,
                            onSelectChanged: (_) => setState(
                              () => _selectedBuilding = row.buildingName,
                            ),
                            cells: [
                              DataCell(Text(row.buildingName)),
                              DataCell(Text(row.profileCount.toString())),
                              DataCell(Text('${row.percentage}%')),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
          if (_selectedBuilding != null) ...[
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Text(
                  'Applicants in $_selectedBuilding',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Readiness: $selectedReadiness%',
                  style: const TextStyle(
                    color: Color(0xFF0F766E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (selectedRows.isEmpty)
              const Text('No applicants found for this building.')
            else
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: RawScrollbar(
                  controller: _applicantTableScrollController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  interactive: true,
                  scrollbarOrientation: ScrollbarOrientation.bottom,
                  thickness: 12,
                  minThumbLength: 48,
                  child: ScrollConfiguration(
                    behavior: _horizontalScrollBehavior(context),
                    child: SingleChildScrollView(
                      key: ValueKey(_selectedBuilding),
                      controller: _applicantTableScrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('ITS')),
                          DataColumn(label: Text('SF No.')),
                          DataColumn(label: Text('Willing to Solar')),
                          DataColumn(label: Text('Landlord Approval')),
                          DataColumn(label: Text('Final Expectation')),
                          DataColumn(label: Text('Roof Ready')),
                          DataColumn(label: Text('Readiness')),
                        ],
                        rows: selectedRows
                            .map(
                              (row) => DataRow(
                                cells: [
                                  DataCell(Text(row.name)),
                                  DataCell(Text(row.its)),
                                  DataCell(Text(row.sfNo)),
                                  DataCell(
                                    _buildStatusCell(row.willingToSolar),
                                  ),
                                  DataCell(
                                    _buildStatusCell(row.landlordApproval),
                                  ),
                                  DataCell(
                                    _buildStatusCell(row.finalExpectation),
                                  ),
                                  DataCell(_buildStatusCell(row.roofReady)),
                                  DataCell(
                                    _buildStatusCell(
                                      '${row.readinessPercentage}%',
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  ScrollBehavior _horizontalScrollBehavior(BuildContext context) {
    return ScrollConfiguration.of(context).copyWith(
      dragDevices: {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      },
    );
  }

  Widget _buildAnimatedReveal(Widget child, Duration delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: delay,
      curve: Curves.easeOutCubic,
      builder: (context, value, animatedChild) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - value)),
            child: animatedChild,
          ),
        );
      },
      child: child,
    );
  }

  Color _readinessColor(int percentage) {
    if (percentage >= 75) return const Color(0xFF15803D);
    if (percentage >= 50) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }

  String _readinessDescription(int percentage) {
    if (percentage >= 75) return 'Ready';
    if (percentage >= 50) return 'Needs attention';
    return 'Not ready';
  }

  Widget _buildReadinessLegend() {
    const levels = [
      (color: Color(0xFF15803D), range: '75-100%', label: 'Ready'),
      (color: Color(0xFFD97706), range: '50-74%', label: 'Needs attention'),
      (color: Color(0xFFDC2626), range: '0-49%', label: 'Not ready'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Wrap(
        spacing: 20,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline, color: Color(0xFF92400E), size: 18),
              SizedBox(width: 8),
              Text(
                'Readiness color guide',
                style: TextStyle(
                  color: Color(0xFF92400E),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          for (final level in levels)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: level.color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 6),
                Text('${level.range}: ${level.label}'),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBuildingGrid(List<_BuildingReadinessRow> buildings) {
    if (buildings.isEmpty) return const SizedBox.shrink();
    final buildingQuery = _buildingSearchController.text.trim().toLowerCase();
    final visibleBuildings = buildings
        .where(
          (building) =>
              building.buildingName.toLowerCase().contains(buildingQuery),
        )
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Buildings',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _buildingSearchController,
            decoration: InputDecoration(
              hintText: 'Search buildings',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: buildingQuery.isEmpty
                  ? null
                  : IconButton(
                      onPressed: _buildingSearchController.clear,
                      icon: const Icon(Icons.clear),
                    ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (visibleBuildings.isEmpty)
            const Text('No buildings match your search.')
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 190,
                mainAxisExtent: 112,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: visibleBuildings.length,
              itemBuilder: (context, index) {
                final building = visibleBuildings[index];
                final isSelected = building.buildingName == _selectedBuilding;
                final color = _readinessColor(building.percentage);
                return InkWell(
                  onTap: () =>
                      setState(() => _selectedBuilding = building.buildingName),
                  borderRadius: BorderRadius.circular(8),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.92, end: 1),
                    duration: Duration(
                      milliseconds: 220 + (index.clamp(0, 12) * 35),
                    ),
                    curve: Curves.easeOutBack,
                    builder: (context, scale, child) => Transform.scale(
                      scale: scale,
                      alignment: Alignment.center,
                      child: child,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 150,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? color : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? color
                              : color.withValues(alpha: 0.45),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            building.buildingName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF1E293B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${building.profileCount} applicants',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white70
                                  : const Color(0xFF64748B),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${building.percentage}% ready',
                            style: TextStyle(
                              color: isSelected ? Colors.white : color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _readinessDescription(building.percentage),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white70
                                  : color.withValues(alpha: 0.85),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildReadinessCharts(int selectedReadiness) {
    final remaining = 100 - selectedReadiness;
    final hasData = _reportTwoRows.isNotEmpty;
    final chartWidth = (_readinessRows.length * 42).clamp(520, 2800).toDouble();

    return LayoutBuilder(
      builder: (context, constraints) {
        final pieWidth = constraints.maxWidth < 360
            ? constraints.maxWidth
            : 360.0;
        final chartCardWidth = constraints.maxWidth < 520
            ? constraints.maxWidth
            : 520.0;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            Container(
              width: pieWidth,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDFA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF99F6E4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedBuilding == null
                        ? 'Overall Readiness'
                        : '$_selectedBuilding Readiness',
                    style: const TextStyle(
                      color: Color(0xFF115E59),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      SizedBox(
                        width: 132,
                        height: 132,
                        child: PieChart(
                          PieChartData(
                            centerSpaceRadius: 42,
                            sectionsSpace: 2,
                            sections: [
                              PieChartSectionData(
                                value: hasData
                                    ? selectedReadiness.toDouble()
                                    : 0,
                                color: _readinessColor(selectedReadiness),
                                title: hasData ? '$selectedReadiness%' : '0%',
                                radius: 24,
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              PieChartSectionData(
                                value: hasData ? remaining.toDouble() : 100,
                                color: const Color(0xFFCCFBF1),
                                title: '',
                                radius: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ReadinessLegend(
                            color: Color(0xFF0F766E),
                            label: 'Ready checks',
                          ),
                          SizedBox(height: 10),
                          _ReadinessLegend(
                            color: Color(0xFFCCFBF1),
                            label: 'Remaining',
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: chartCardWidth,
              height: 220,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Readiness by Building',
                    style: TextStyle(
                      color: Color(0xFF92400E),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: RawScrollbar(
                      controller: _chartScrollController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      interactive: true,
                      scrollbarOrientation: ScrollbarOrientation.bottom,
                      thickness: 12,
                      minThumbLength: 48,
                      child: ScrollConfiguration(
                        behavior: _horizontalScrollBehavior(context),
                        child: SingleChildScrollView(
                          controller: _chartScrollController,
                          scrollDirection: Axis.horizontal,
                          physics: const ClampingScrollPhysics(),
                          child: SizedBox(
                            width: chartWidth,
                            child: BarChart(
                              BarChartData(
                                minY: 0,
                                maxY: 100,
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: 25,
                                ),
                                borderData: FlBorderData(show: false),
                                barTouchData: BarTouchData(enabled: false),
                                titlesData: FlTitlesData(
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  leftTitles: const AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 32,
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 32,
                                      getTitlesWidget: (value, meta) {
                                        final index = value.toInt();
                                        if (index < 0 ||
                                            index >= _readinessRows.length) {
                                          return const SizedBox.shrink();
                                        }
                                        final name =
                                            _readinessRows[index].buildingName;
                                        return SideTitleWidget(
                                          meta: meta,
                                          child: Text(
                                            name.length > 8
                                                ? '${name.substring(0, 8)}...'
                                                : name,
                                            style: const TextStyle(fontSize: 9),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                barGroups: [
                                  for (
                                    var index = 0;
                                    index < _readinessRows.length;
                                    index++
                                  )
                                    BarChartGroupData(
                                      x: index,
                                      barRods: [
                                        BarChartRodData(
                                          toY: _readinessRows[index].percentage
                                              .toDouble(),
                                          width: 16,
                                          color: _readinessColor(
                                            _readinessRows[index].percentage,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth < 360
            ? constraints.maxWidth
            : 360.0;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildExpectationPie(
              title: 'Form 2 Expectation',
              yesCount: form2Yes,
              color: const Color(0xFF2563EB),
              width: cardWidth,
            ),
            _buildExpectationPie(
              title: 'Form 4 Expectation',
              yesCount: form4Yes,
              color: const Color(0xFF0F766E),
              width: cardWidth,
            ),
            _buildExpectationPie(
              title: 'Final Expectation',
              yesCount: finalYes,
              color: const Color(0xFFF59E0B),
              width: cardWidth,
            ),
          ],
        );
      },
    );
  }

  Widget _buildExpectationPie({
    required String title,
    required int yesCount,
    required Color color,
    required double width,
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
      width: width,
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
