import 'package:flutter/material.dart';
import 'package:form_manager/Controller/provider_controller.dart';
import 'package:form_manager/Model/person_model.dart';
import 'package:provider/provider.dart';

class SummaryDashboardView extends StatelessWidget {
  const SummaryDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final people = provider.people;
    final totalProfiles = people.length;

    // Form Completion Statistics
    final form1Completed = people
        .where((p) => p.completedFormCount >= 1)
        .length;
    final form2Completed = people
        .where((p) => p.completedFormCount >= 2)
        .length;
    final form3Completed = people
        .where((p) => p.completedFormCount >= 3)
        .length; // Scalable for Form 3

    // Dropdown Metrics Aggregation
    final houseTypeCounts = _aggregateField(people, (p) => p.houseType);
    final roomTypeCounts = _aggregateField(people, (p) => p.rooms);
    final solarWillingnessCounts = _aggregateField(
      people,
      (p) => p.solarWillingness,
    );
    final landlordApprovalCounts = _aggregateField(
      people,
      (p) => p.landlordApproval,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('Executive Analytics & Summary'),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Form Progress & Completion Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Form Completion Donut Cards Grid
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildCompletionDonutCard(
                        'Form 1 (Personal Profile)',
                        form1Completed,
                        totalProfiles,
                        const Color(0xFF2563EB),
                      ),
                      _buildCompletionDonutCard(
                        'Form 2 (Electrical & Solar)',
                        form2Completed,
                        totalProfiles,
                        const Color(0xFF10B981),
                      ),
                      _buildCompletionDonutCard(
                        'Form 3 (Surveys / Expansion)',
                        form3Completed,
                        totalProfiles,
                        const Color(0xFF8B5CF6),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  const Text(
                    'Survey Response Distribution (Dropdown Fields)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dropdown Graph Section
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildDistributionChartCard(
                        'Solar Installation Willingness',
                        solarWillingnessCounts,
                        totalProfiles,
                        {
                          'Yes': const Color(0xFF10B981),
                          'No': const Color(0xFFEF4444),
                          'Already Installed': const Color(0xFFF59E0B),
                        },
                      ),
                      _buildDistributionChartCard(
                        'House Ownership Type',
                        houseTypeCounts,
                        totalProfiles,
                        {
                          'Ownership': const Color(0xFF3B82F6),
                          'Rent': const Color(0xFFF97316),
                          'Goodwill': const Color(0xFF6B7280),
                        },
                      ),
                      _buildDistributionChartCard(
                        'Landlord Approval Requirement',
                        landlordApprovalCounts,
                        totalProfiles,
                        {
                          'Yes': const Color(0xFFEF4444),
                          'No': const Color(0xFF10B981),
                          'Maybe': const Color(0xFFF59E0B),
                        },
                      ),
                      _buildDistributionChartCard(
                        'Room Layout Distribution',
                        roomTypeCounts,
                        totalProfiles,
                        {
                          '2-Bed Lounge': const Color(0xFF06B6D4),
                          '3-Bed Lounge': const Color(0xFF3B82F6),
                          '2-Bed D/D': const Color(0xFF8B5CF6),
                          '3-Bed D/D': const Color(0xFFEC4899),
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  // Helper method to group and count dropdown occurrences
  static Map<String, int> _aggregateField(
    List<PersonModel> people,
    String Function(PersonModel) getField,
  ) {
    final Map<String, int> counts = {};
    for (var p in people) {
      final val = getField(p);
      final key = val.trim().isEmpty ? 'Unspecified' : val;
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return counts;
  }

  // Card widget for individual Form Progress Donut Rings
  Widget _buildCompletionDonutCard(
    String title,
    int completed,
    int total,
    Color themeColor,
  ) {
    final ratio = total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;
    final percentage = (ratio * 100).toInt();

    return Container(
      width: 280,
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
              fontSize: 14,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: ratio,
                      backgroundColor: const Color(0xFFE2E8F0),
                      color: themeColor,
                      strokeWidth: 7,
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$completed / $total',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: themeColor,
                    ),
                  ),
                  const Text(
                    'Completed',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Card widget for visual horizontal distribution bar graphs per dropdown field
  Widget _buildDistributionChartCard(
    String title,
    Map<String, int> counts,
    int totalProfiles,
    Map<String, Color> colorMap,
  ) {
    return Container(
      width: 420,
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
              fontSize: 15,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          if (counts.isEmpty || totalProfiles == 0)
            const Text(
              'No data recorded yet',
              style: TextStyle(color: Colors.grey),
            )
          else
            ...counts.entries.map((entry) {
              final label = entry.key;
              final count = entry.value;
              final ratio = totalProfiles > 0
                  ? (count / totalProfiles).clamp(0.0, 1.0)
                  : 0.0;
              final percentage = (ratio * 100).toStringAsFixed(1);
              final barColor = colorMap[label] ?? Colors.indigo;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '$count ($percentage%)',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFE2E8F0),
                        color: barColor,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}
