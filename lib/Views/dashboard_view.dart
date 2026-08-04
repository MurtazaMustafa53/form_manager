import 'package:flutter/material.dart';
import 'package:form_manager/Controller/provider_controller.dart';
import 'package:form_manager/Model/person_model.dart';
import 'package:form_manager/Views/solar_survey_form_view.dart';
import 'package:provider/provider.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('IBM Solar Survey Dashboard'),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final people = provider.people;
          final totalProfiles = people.length;
          final completedForms = people.where((p) => p.isComplete).length;
          final overallProgress = totalProfiles > 0
              ? (completedForms / totalProfiles)
              : 0.0;
          final pendingCount = people.where((p) => !p.isComplete).length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildStatCard(
                      title: 'Total Profiles',
                      value: '$totalProfiles',
                      subtitle:
                          '${(overallProgress * 100).toStringAsFixed(0)}% Completed',
                      backgroundColor: const Color(0xFF2563EB),
                      icon: Icons.people_outline,
                      isWhite: false,
                    ),
                    _buildStatCard(
                      title: 'Forms Submitted',
                      value: '$completedForms/$totalProfiles',
                      subtitle:
                          '${(overallProgress * 100).toStringAsFixed(0)}% Overall Progress',
                      backgroundColor: Colors.white,
                      icon: Icons.assignment_turned_in_outlined,
                      isWhite: true,
                    ),
                    _buildStatCard(
                      title: 'Pending Forms',
                      value: '$pendingCount',
                      subtitle: 'Needs Attention',
                      backgroundColor: const Color(0xFFF97316),
                      icon: Icons.access_time_rounded,
                      isWhite: false,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Survey Completion Progress',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              '${(overallProgress * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: overallProgress,
                            minHeight: 10,
                            backgroundColor: const Color(0xFFE2E8F0),
                            color: const Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '0%',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '$completedForms of $totalProfiles forms submitted',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const Text(
                              '100%',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Client Survey List',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (people.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32.0),
                            child: Center(
                              child: Text(
                                'No profiles loaded from Firebase yet.',
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            width: double.infinity,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                horizontalMargin: 12,
                                columnSpacing: 28,
                                columns: const [
                                  DataColumn(label: Text('Status')),
                                  DataColumn(label: Text('Name')),
                                  DataColumn(label: Text('ITS')),
                                  DataColumn(label: Text('SF No')),
                                  DataColumn(label: Text('Form Progress')),
                                  DataColumn(label: Text('Action')),
                                ],
                                rows: people
                                    .map(
                                      (person) =>
                                          _buildTableRow(context, person),
                                    )
                                    .toList(),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color backgroundColor,
    required IconData icon,
    required bool isWhite,
  }) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: isWhite ? Border.all(color: Colors.grey.shade200) : null,
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
                  color: isWhite ? Colors.grey.shade700 : Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                icon,
                color: isWhite ? const Color(0xFF2563EB) : Colors.white70,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: isWhite ? const Color(0xFF1E293B) : Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: isWhite ? Colors.grey.shade600 : Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildTableRow(BuildContext context, PersonModel person) {
    final bool isComplete = person.isComplete;
    final int percentage = (person.progressPercentage * 100).toInt();

    return DataRow(
      cells: [
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isComplete
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isComplete ? 'Submitted' : 'Pending',
              style: TextStyle(
                color: isComplete
                    ? const Color(0xFF166534)
                    : const Color(0xFF92400E),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        DataCell(
          Text(
            person.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
        DataCell(Text('${person.its}')),
        DataCell(Text('${person.sfNo}')),
        DataCell(
          SizedBox(
            width: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: person.progressPercentage,
                    minHeight: 4,
                    backgroundColor: const Color(0xFFE2E8F0),
                    color: isComplete
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
          ),
        ),
        DataCell(
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isComplete
                  ? Colors.grey.shade300
                  : const Color(0xFF2563EB),
              foregroundColor: isComplete ? Colors.black87 : Colors.white,
              elevation: 0,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SolarSurveyFormView(person: person),
                ),
              );
            },
            child: Text(isComplete ? 'View Form' : 'Fill Form'),
          ),
        ),
      ],
    );
  }
}
