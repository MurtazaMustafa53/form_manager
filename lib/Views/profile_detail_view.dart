import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:form_manager/Controller/provider_controller.dart';
import 'package:form_manager/Model/person_model.dart';
import 'package:form_manager/Views/Forms/form1_view.dart';
import 'package:form_manager/Views/Forms/form2_view.dart';
import 'package:form_manager/Views/Forms/form3_view.dart';
import 'package:form_manager/Views/Forms/form4_veiw.dart';
import 'package:form_manager/Views/Forms/form_finance_view.dart';
import 'package:form_manager/Views/Forms/form6_solar_extension_view.dart';
import 'package:form_manager/Views/Forms/temporary_form_view.dart';

class ProfileDetailView extends StatelessWidget {
  final PersonModel person;

  const ProfileDetailView({super.key, required this.person});

  void _navigateToForm(
    BuildContext context,
    int formNumber, {
    bool readOnly = false,
  }) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    if (formNumber == AppProvider.temporaryFormNumber &&
        !provider.canAccessTemporaryForm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This form is available to Dev and Finance only.'),
        ),
      );
      return;
    }
    if (formNumber == 4 && !(provider.isDev || provider.isFinance)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Form 4 is available to Dev and Finance only.'),
        ),
      );
      return;
    }

    Widget targetForm;

    switch (formNumber) {
      case 1:
        targetForm = Form1View(person: person, readOnly: readOnly);
        break;
      case 2:
        targetForm = Form2View(person: person, readOnly: readOnly);
        break;
      case 4:
        targetForm = Form4View(person: person, readOnly: readOnly);
        break;
      case 5:
        targetForm = FormFinanceView(person: person);
        break;
      case 6:
        targetForm = SolarExtensionFormView(person: person, readOnly: readOnly);
        break;
      case AppProvider.temporaryFormNumber:
        targetForm = TemporaryFormView(person: person, readOnly: readOnly);
        break;
      case 3:
      default:
        targetForm = Form3View(person: person, readOnly: readOnly);
        break;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => targetForm));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final currentPerson = provider.people.firstWhere(
      (p) => p.id == person.id,
      orElse: () => person,
    );
    final int completedCount = currentPerson.completedFormCount.clamp(
      0,
      currentPerson.requiredFormCount,
    );
    final double progressRatio = currentPerson.progressPercentage;
    final int percentage = (progressRatio * 100).toInt();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: Text('${currentPerson.name} Profile'),
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
                      backgroundColor: const Color(
                        0xFF2563EB,
                      ).withValues(alpha: 0.1),
                      child: Text(
                        currentPerson.name.isNotEmpty
                            ? currentPerson.name[0].toUpperCase()
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
                                currentPerson.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '(#SF-${currentPerson.sfNo} • ITS: ${currentPerson.its})',
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
                              color: currentPerson.isComplete
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              currentPerson.isComplete
                                  ? 'COMPLETED'
                                  : 'IN PROGRESS',
                              style: TextStyle(
                                color: currentPerson.isComplete
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
                                value: progressRatio,
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
                              '$completedCount of ${currentPerson.requiredFormCount}',
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
                        value: progressRatio,
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
                      isCompleted: currentPerson.isFormCompleted(1),
                    ),
                    const Divider(height: 24),
                    _buildFormChecklistItem(
                      context,
                      formNumber: 2,
                      formTitle:
                          'Form 2: Electrical Appliances & Financial Expectations',
                      isCompleted: currentPerson.isFormCompleted(2),
                    ),
                    const Divider(height: 24),
                    _buildFormChecklistItem(
                      context,
                      formNumber: 3,
                      formTitle: 'Form 3: Physical & Electrical Survey',
                      isCompleted: currentPerson.isFormCompleted(3),
                      isLocked: currentPerson.hasExistingSolarSystem,
                    ),
                    const Divider(height: 24),
                    _buildFormChecklistItem(
                      context,
                      formNumber: 4,
                      formTitle: 'Form 4: Financial Survey',
                      isCompleted: currentPerson.isFormCompleted(4),
                      isLocked: currentPerson.hasExistingSolarSystem,
                    ),
                    const Divider(height: 24),
                    _buildFormChecklistItem(
                      context,
                      formNumber: 5,
                      formTitle: 'Finance: Financial Summary',
                      isCompleted: currentPerson.isFormCompleted(5),
                    ),
                    if (currentPerson.hasExistingSolarSystem) ...[
                      const Divider(height: 24),
                      _buildFormChecklistItem(
                        context,
                        formNumber: 6,
                        formTitle: 'Solar Extension Request Form',
                        isCompleted: currentPerson.isFormCompleted(6),
                      ),
                    ],
                    if (provider.canAccessTemporaryForm) ...[
                      const Divider(height: 24),
                      _buildFormChecklistItem(
                        context,
                        formNumber: AppProvider.temporaryFormNumber,
                        formTitle: 'Temporary Form: Building Name',
                        isCompleted: currentPerson.isFormCompleted(
                          AppProvider.temporaryFormNumber,
                        ),
                        roleRestricted: true,
                      ),
                    ],
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
    bool isLocked = false,
    bool roleRestricted = false,
  }) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final canEdit =
        !provider.isViewer &&
        !isLocked &&
        (formNumber != 4 || provider.isDev || provider.isFinance) &&
        (!roleRestricted || provider.canAccessTemporaryForm);
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
                isLocked
                    ? 'Not Required'
                    : isCompleted
                    ? 'Completed'
                    : 'Not Started',
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
              label: const Text('View'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
                foregroundColor: const Color(0xFF2563EB),
                elevation: 0,
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              icon: const Icon(Icons.remove_red_eye, size: 16),
              onPressed: isLocked
                  ? null
                  : () => _navigateToForm(context, formNumber, readOnly: true),
            ),
            const SizedBox(width: 12),
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
              onPressed: canEdit
                  ? () => _navigateToForm(context, formNumber)
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}
