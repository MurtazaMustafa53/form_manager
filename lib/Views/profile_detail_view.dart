import 'package:flutter/material.dart';
import 'package:form_manager/Model/person_model.dart';
import 'package:form_manager/Views/solar_survey_form_view.dart';

class ProfileDetailView extends StatelessWidget {
  final PersonModel person;

  const ProfileDetailView({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    final int percentage = (person.progressPercentage * 100).toInt();
    final int completedCount = person.isComplete
        ? 2
        : (person.progressPercentage > 0 ? 1 : 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: Text('${person.name} Profile'),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Card
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
                      child: Text(
                        person.name.isNotEmpty
                            ? person.name[0].toUpperCase()
                            : 'P',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                person.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '(#SF-${person.sfNo} • ITS: ${person.its})',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: person.isComplete
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              person.isComplete ? 'COMPLETED' : 'IN PROGRESS',
                              style: TextStyle(
                                color: person.isComplete
                                    ? const Color(0xFF166534)
                                    : const Color(0xFF92400E),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(
                                value: person.progressPercentage,
                                backgroundColor: const Color(0xFFE2E8F0),
                                color: const Color(0xFF10B981),
                                strokeWidth: 6,
                              ),
                            ),
                            Text(
                              '$percentage%',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$completedCount of 2',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const Text(
                              'Forms Completed',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Progress Overview Bar Card
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Profile Completion Overview',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          '$percentage%',
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
                        value: person.progressPercentage,
                        minHeight: 10,
                        backgroundColor: const Color(0xFFE2E8F0),
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '0% - 100%',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        Text(
                          'Survey Progress Metric',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Profile Form Checklist Card
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
                      'Profile Form Checklist',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFormChecklistItem(
                      context,
                      formNumber: 1,
                      formTitle: 'Form 1: Personal Profile Details',
                      isCompleted:
                          person.isComplete || person.progressPercentage >= 0.5,
                    ),
                    const Divider(height: 24),
                    _buildFormChecklistItem(
                      context,
                      formNumber: 2,
                      formTitle:
                          'Form 2: Electrical Appliances & Existing Solar',
                      isCompleted: person.isComplete,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormChecklistItem(
    BuildContext context, {
    required int formNumber,
    required String formTitle,
    required bool isCompleted,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isCompleted ? const Color(0xFF10B981) : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              formTitle,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isCompleted ? 'Completed' : 'Not Started',
                style: TextStyle(
                  color: isCompleted
                      ? const Color(0xFF166534)
                      : const Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              label: Text(isCompleted ? 'Edit' : 'Fill Form'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isCompleted
                    ? Colors.white
                    : const Color(0xFF2563EB),
                foregroundColor: isCompleted
                    ? const Color(0xFF2563EB)
                    : Colors.white,
                elevation: 0,
                side: isCompleted
                    ? const BorderSide(color: Color(0xFF2563EB))
                    : null,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              icon: Icon(
                isCompleted ? Icons.edit : Icons.arrow_forward,
                size: 16,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SolarSurveyFormView(
                      person: person,
                      formNumber: formNumber,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
