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
                // TAB CARDS ROW (Stays fixed, no flickering)
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

                // ONLY CONTENT BELOW RELOADS SMOOTHLY
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
  // FORM 1 SUMMARY WITH CHARTS
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
        // CHARTS ROW
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

        // DATA TABLE
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
  // FORM 2 SUMMARY WITH FINANCE CHART
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
        // FINANCE CHART CARD
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
                              '${entry.value} (${percentage}%)',
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

        // DATA TABLE
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
  // HELPER: DONUT/PIE CHART CARD FOR FORM 1 METRICS
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

  // FORM 3 SUMMARY TABLE
  Widget _buildForm3Summary(List<PersonModel> people) {
    final form3People = people.where((p) => p.completedFormCount >= 3).toList();

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
          const Text(
            'Form 3 Submissions',
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
                  DataColumn(label: Text('Status')),
                ],
                rows: form3People.map((person) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          person.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataCell(Text(person.its.toString())),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Completed',
                            style: TextStyle(
                              color: Color(0xFF166534),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
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
    );
  }
}
