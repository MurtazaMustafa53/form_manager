import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:form_manager/Model/person_model.dart';

class SummaryDashboardView extends StatefulWidget {
  const SummaryDashboardView({super.key});

  @override
  State<SummaryDashboardView> createState() => _SummaryDashboardViewState();
}

class _SummaryDashboardViewState extends State<SummaryDashboardView> {
  final ValueNotifier<int> _selectedFormTabNotifier = ValueNotifier<int>(1);

  @override
  void dispose() {
    _selectedFormTabNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('Summary Analytics Dashboard'),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('people').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No data found in Firestore.'));
          }

          final people = snapshot.data!.docs
              .map((doc) => PersonModel.fromFirestore(doc))
              .toList();

          final form1People = people
              .where((p) => p.completedFormCount >= 1)
              .toList();
          final form2People = people
              .where((p) => p.completedFormCount >= 2)
              .toList();
          final form3People = people
              .where((p) => p.completedFormCount >= 3)
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TAB CARDS ROW
                ValueListenableBuilder<int>(
                  valueListenable: _selectedFormTabNotifier,
                  builder: (context, currentTab, _) {
                    return Row(
                      children: [
                        Expanded(
                          child: _buildFormTabCard(
                            formNumber: 1,
                            title: 'Form 1 Summary',
                            subtitle: 'Personal Data',
                            count: form1People.length,
                            total: people.length,
                            color: const Color(0xFF2563EB),
                            isSelected: currentTab == 1,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFormTabCard(
                            formNumber: 2,
                            title: 'Form 2 Summary',
                            subtitle: 'Appliance Inventory',
                            count: form2People.length,
                            total: form1People.length,
                            color: const Color(0xFF10B981),
                            isSelected: currentTab == 2,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFormTabCard(
                            formNumber: 3,
                            title: 'Form 3 Summary',
                            subtitle: 'Audit Data',
                            count: form3People.length,
                            total: form2People.length,
                            color: const Color(0xFF8B5CF6),
                            isSelected: currentTab == 3,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // CONTENT SWITCHER
                ValueListenableBuilder<int>(
                  valueListenable: _selectedFormTabNotifier,
                  builder: (context, currentTab, _) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      reverseDuration: const Duration(milliseconds: 200),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            final offsetAnimation = Tween<Offset>(
                              begin: const Offset(0.0, 0.04),
                              end: Offset.zero,
                            ).animate(animation);

                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: offsetAnimation,
                                child: child,
                              ),
                            );
                          },
                      child: KeyedSubtree(
                        key: ValueKey<int>(currentTab),
                        child: _buildSelectedSummaryContent(currentTab, people),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormTabCard({
    required int formNumber,
    required String title,
    required String subtitle,
    required int count,
    required int total,
    required Color color,
    required bool isSelected,
  }) {
    final double percentage = total > 0 ? (count / total * 100) : 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _selectedFormTabNotifier.value = formNumber,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade200,
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
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
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF1E293B),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    child: Text(title),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.insert_chart_outlined,
                      key: ValueKey<bool>(isSelected),
                      color: isSelected ? Colors.white : Colors.grey.shade400,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: isSelected ? Colors.white70 : Colors.grey.shade600,
                  fontSize: 12,
                ),
                child: Text(subtitle),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      color: isSelected ? Colors.white : color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    child: Text('$count Submissions'),
                  ),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.grey.shade600,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    child: Text('${percentage.toInt()}%'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedSummaryContent(int tabIndex, List<PersonModel> people) {
    switch (tabIndex) {
      case 1:
        return _buildForm1Summary(people);
      case 2:
        return _buildForm2Summary(people);
      case 3:
        return _buildForm3Summary(people);
      default:
        return Container();
    }
  }

  // ---------------------------------------------------------------------------
  // FORM 1 SUMMARY
  // ---------------------------------------------------------------------------
  Widget _buildForm1Summary(List<PersonModel> people) {
    final form1People = people.where((p) => p.completedFormCount >= 1).toList();
    final int total = form1People.length;

    final int willingCount = form1People
        .where((p) => p.willingToSolar == true)
        .length;
    final int landlordApprovedCount = form1People
        .where((p) => p.landlordApproval == true)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildPieChartCard(
                title: 'Willing to Solar',
                positiveCount: willingCount,
                totalCount: total,
                positiveColor: const Color(0xFF2563EB),
                positiveLabel: 'Willing',
                negativeLabel: 'Not Willing',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildPieChartCard(
                title: 'Landlord Approval',
                positiveCount: landlordApprovedCount,
                totalCount: total,
                positiveColor: const Color(0xFF0EA5E9),
                positiveLabel: 'Approved',
                negativeLabel: 'Pending/No',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
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
                'Form 1 Details Table',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('ITS')),
                      DataColumn(label: Text('SF No')),
                      DataColumn(label: Text('Contact')),
                      DataColumn(label: Text('Address')),
                      DataColumn(label: Text('Willing to Solar')),
                      DataColumn(label: Text('Landlord Approval')),
                    ],
                    rows: form1People.map((person) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              person.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(Text(person.its.toString())),
                          DataCell(Text(person.sfNo?.toString() ?? 'N/A')),
                          DataCell(Text(person.contact)),
                          DataCell(Text(person.address ?? 'N/A')),
                          DataCell(
                            Text(person.willingToSolar == true ? 'Yes' : 'No'),
                          ),
                          DataCell(
                            Text(
                              person.landlordApproval == true ? 'Yes' : 'No',
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // FORM 2 SUMMARY
  // ---------------------------------------------------------------------------
  Widget _buildForm2Summary(List<PersonModel> people) {
    final form2People = people.where((p) => p.completedFormCount >= 2).toList();

    double grandTotalWattage = 0;
    final Map<String, int> financeCounts = {};

    for (var p in form2People) {
      grandTotalWattage += p.totalWattage ?? 0;
      final val =
          (p.financeAsPerExpectation != null &&
              p.financeAsPerExpectation!.isNotEmpty)
          ? p.financeAsPerExpectation!
          : 'Unspecified';
      financeCounts[val] = (financeCounts[val] ?? 0) + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
                'Finance as per Expectation Breakdown',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              if (financeCounts.isEmpty)
                const Text('No financial expectation data available.')
              else
                ...financeCounts.entries.map((entry) {
                  final double ratio = form2People.isNotEmpty
                      ? entry.value / form2People.length
                      : 0.0;
                  final int percentage = (ratio * 100).toInt();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${entry.value} ($percentage%)',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 10,
                            backgroundColor: const Color(0xFFE2E8F0),
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
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
                'Form 2 Financial & Wattage Table',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Profile Name')),
                      DataColumn(label: Text('ITS')),
                      DataColumn(label: Text('Total Wattage'), numeric: true),
                      DataColumn(label: Text('Finance by Momin')),
                      DataColumn(label: Text('Finance as per Expectation')),
                    ],
                    rows: [
                      ...form2People.map((person) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                person.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            DataCell(Text(person.its.toString())),
                            DataCell(Text('${person.totalWattage ?? 0} W')),
                            DataCell(Text(person.financeByMomin ?? 'N/A')),
                            DataCell(
                              Text(person.financeAsPerExpectation ?? 'N/A'),
                            ),
                          ],
                        );
                      }),
                      DataRow(
                        color: WidgetStateProperty.all(const Color(0xFFECFDF5)),
                        cells: [
                          const DataCell(
                            Text(
                              'TOTAL',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF065F46),
                              ),
                            ),
                          ),
                          const DataCell(Text('-')),
                          DataCell(
                            Text(
                              '${grandTotalWattage.toStringAsFixed(1)} W',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ),
                          const DataCell(Text('-')),
                          const DataCell(Text('-')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // FORM 3 SUMMARY (DIRECT FIREBASE MAPPING)
  // ---------------------------------------------------------------------------
  // ---------------------------------------------------------------------------
  // FORM 3 SUMMARY (DIRECT FIREBASE MAPPING ON PERSON MODEL)
  // ---------------------------------------------------------------------------
  // ---------------------------------------------------------------------------
  // FORM 3 SUMMARY (FETCHING DIRECTLY FROM FIRESTORE 'forms' COLLECTION)
  // ---------------------------------------------------------------------------
  Widget _buildForm3Summary(List<PersonModel> people) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('forms')
          .where('formNumber', isEqualTo: 3)
          .where('isDraft', isEqualTo: false)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading Form 3 data: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('No Form 3 submissions found in Firebase.'),
            ),
          );
        }

        final form3Docs = snapshot.data!.docs;
        final int totalForm3 = form3Docs.length;

        // Analytics Aggregators
        final Map<String, int> roofTypeCounts = {};
        int totalHousePanels = 0;
        int totalFloorMountPanels = 0;
        int totalElevatedPanels = 0;

        final Map<String, int> mainBoardCounts = {};
        int waterTapCount = 0;
        int separateBreakersCount = 0;
        int upsWiringCount = 0;

        double totalDcWireMeters = 0;
        double totalAcWireMeters = 0;
        double totalEarthingMeters = 0;

        final Map<String, int> aggregateBom = {};

        for (var doc in form3Docs) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          final answers = Map<String, dynamic>.from(data['answers'] ?? {});

          // 1. Roof Details
          final rawRoofType = answers['roofType']?.toString().trim();
          final roofType = (rawRoofType != null && rawRoofType.isNotEmpty)
              ? rawRoofType
              : 'Unspecified';
          roofTypeCounts[roofType] = (roofTypeCounts[roofType] ?? 0) + 1;

          totalHousePanels +=
              int.tryParse(
                answers['houseNoOfSolarPanels']?.toString() ?? '0',
              ) ??
              0;
          totalFloorMountPanels +=
              int.tryParse(answers['floorMountNoOfSolar']?.toString() ?? '0') ??
              0;
          totalElevatedPanels +=
              int.tryParse(answers['elevatedNoOfSolar']?.toString() ?? '0') ??
              0;

          // 2. Electrical Infrastructure Details
          final rawMainBoard = answers['mainBoardType']?.toString().trim();
          final mainBoard = (rawMainBoard != null && rawMainBoard.isNotEmpty)
              ? rawMainBoard
              : 'Unspecified';
          mainBoardCounts[mainBoard] = (mainBoardCounts[mainBoard] ?? 0) + 1;

          if (answers['waterConnectionOnRoof'] == true) waterTapCount++;
          if (answers['separateRoomWiseBreakers'] == true)
            separateBreakersCount++;
          if (answers['upsWiring'] == true) upsWiringCount++;

          totalDcWireMeters +=
              double.tryParse(answers['dcWireLength']?.toString() ?? '0') ?? 0;
          totalAcWireMeters +=
              double.tryParse(answers['acWireLength']?.toString() ?? '0') ?? 0;
          totalEarthingMeters +=
              double.tryParse(answers['earthingLength']?.toString() ?? '0') ??
              0;

          // 3. Bill of Materials (BOM) Map
          final rawMaterials = answers['materials'];
          if (rawMaterials is Map) {
            rawMaterials.forEach((key, val) {
              final int qty = int.tryParse(val?.toString() ?? '0') ?? 0;
              if (qty > 0) {
                aggregateBom[key.toString()] =
                    (aggregateBom[key.toString()] ?? 0) + qty;
              }
            });
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // METRIC CARDS ROW
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'Total Solar Panels',
                    value:
                        '${totalHousePanels + totalFloorMountPanels + totalElevatedPanels}',
                    subtitle:
                        'House: $totalHousePanels | Floor: $totalFloorMountPanels | Elevated: $totalElevatedPanels',
                    icon: Icons.solar_power,
                    color: const Color(0xFF8B5CF6),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Roof Water Tap Access',
                    value: '$waterTapCount / $totalForm3',
                    subtitle:
                        '${totalForm3 > 0 ? ((waterTapCount / totalForm3) * 100).toInt() : 0}% sites with water tap',
                    icon: Icons.water_drop_outlined,
                    color: const Color(0xFF0EA5E9),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Wiring Metrics',
                    value:
                        '${(totalDcWireMeters + totalAcWireMeters).toInt()}m Total',
                    subtitle:
                        'DC: ${totalDcWireMeters.toInt()}m | AC: ${totalAcWireMeters.toInt()}m | Earth: ${totalEarthingMeters.toInt()}m',
                    icon: Icons.cable,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // CHARTS ROW
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Roof Types Breakdown
                Expanded(
                  child: Container(
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
                          'Roof Types Breakdown',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (roofTypeCounts.isEmpty)
                          const Text('No roof data recorded.')
                        else
                          ...roofTypeCounts.entries.map((entry) {
                            final double ratio = totalForm3 > 0
                                ? entry.value / totalForm3
                                : 0.0;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        entry.key,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '${entry.value} (${(ratio * 100).toInt()}%)',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF8B5CF6),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: ratio,
                                      minHeight: 8,
                                      backgroundColor: const Color(0xFFE2E8F0),
                                      color: const Color(0xFF8B5CF6),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Electrical Boards & Readiness
                Expanded(
                  child: Container(
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
                          'Main Board Readiness',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (mainBoardCounts.isEmpty)
                          const Text('No main board data recorded.')
                        else
                          ...mainBoardCounts.entries.map((entry) {
                            final double ratio = totalForm3 > 0
                                ? entry.value / totalForm3
                                : 0.0;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        entry.key,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '${entry.value} (${(ratio * 100).toInt()}%)',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF10B981),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: ratio,
                                      minHeight: 8,
                                      backgroundColor: const Color(0xFFE2E8F0),
                                      color: const Color(0xFF10B981),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Room-Wise Breakers',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '$separateBreakersCount / $totalForm3',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Existing UPS Wiring',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '$upsWiringCount / $totalForm3',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // BILL OF MATERIALS (BOM) TABLE
            Container(
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bill of Materials (BOM) Aggregated Requirements',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${aggregateBom.length} Material Types Required',
                          style: const TextStyle(
                            color: Color(0xFF6B21A8),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (aggregateBom.isEmpty)
                    const Text(
                      'No material inventory entries found in Firebase forms.',
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Material Description')),
                            DataColumn(
                              label: Text('Total Required Quantity'),
                              numeric: true,
                            ),
                          ],
                          rows: aggregateBom.entries.map((entry) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    _formatMaterialKey(entry.key),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '${entry.value}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
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

  // ---------------------------------------------------------------------------
  // HELPER WIDGETS
  // ---------------------------------------------------------------------------
  Widget _buildPieChartCard({
    required String title,
    required int positiveCount,
    required int totalCount,
    required Color positiveColor,
    required String positiveLabel,
    required String negativeLabel,
  }) {
    final int negativeCount = totalCount - positiveCount;
    final double positivePct = totalCount > 0
        ? (positiveCount / totalCount) * 100
        : 0;

    return Container(
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
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                height: 100,
                width: 100,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 28,
                    sections: [
                      PieChartSectionData(
                        color: positiveColor,
                        value: positiveCount.toDouble(),
                        title: '',
                        radius: 18,
                      ),
                      PieChartSectionData(
                        color: Colors.grey.shade300,
                        value: negativeCount.toDouble(),
                        title: '',
                        radius: 18,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${positivePct.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: positiveColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(width: 8, height: 8, color: positiveColor),
                      const SizedBox(width: 6),
                      Text(
                        '$positiveLabel ($positiveCount)',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$negativeLabel ($negativeCount)',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
          ),
        ],
      ),
    );
  }

  String _formatMaterialKey(String key) {
    final RegExp camelCasePattern = RegExp(r'(?<=[a-z])(?=[A-Z])');
    final String formatted = key.replaceAllMapped(
      camelCasePattern,
      (match) => ' ',
    );
    return formatted.substring(0, 1).toUpperCase() + formatted.substring(1);
  }
}
