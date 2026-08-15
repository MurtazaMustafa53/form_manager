import 'package:flutter/material.dart';
import 'package:form_manager/Controller/provider_controller.dart';
import 'package:form_manager/Model/person_model.dart';
import 'package:form_manager/Views/login_view.dart';
import 'package:form_manager/Views/profile_detail_view.dart';
import 'package:form_manager/Views/summary_dashboard_view.dart';
import 'package:provider/provider.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatusFilter = 'All';

  // Active Chart Stage Filter: null = All, 1..5 = minimum form number submitted.
  int? _activeFormFilter;

  int _sortColumnIndex = 1;
  bool _isAscending = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddProfileDialog(BuildContext context) {
    final nameController = TextEditingController();
    final itsController = TextEditingController();
    final sfController = TextEditingController();
    final contactController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Brand New Profile'),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: itsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'ITS Number'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: sfController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'SF Number'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: contactController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Contact Number',
                    ),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final provider = Provider.of<AppProvider>(
                    context,
                    listen: false,
                  );

                  final newPerson = PersonModel(
                    id: 'person_${DateTime.now().millisecondsSinceEpoch}',
                    name: nameController.text.trim(),
                    its: int.parse(itsController.text.trim()),
                    sfNo: int.parse(sfController.text.trim()),
                    contact: contactController.text.trim(),
                  );

                  try {
                    await provider.addNewPerson(newPerson);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('New profile created successfully!'),
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                }
              },
              child: const Text('Save Profile'),
            ),
          ],
        );
      },
    );
  }

  List<PersonModel> _getFilteredAndSortedPeople(List<PersonModel> people) {
    final query = _searchController.text.trim().toLowerCase();

    final filtered = people.where((person) {
      // 1. Chart Stage Filter Logic
      if (_activeFormFilter != null) {
        if (person.completedFormCount < _activeFormFilter!) {
          return false;
        }
      }

      // 2. Search Field Filter
      final matchesName = person.name.toLowerCase().contains(query);
      final matchesIts = person.its.toString().contains(query);
      final matchesSf = person.sfNo.toString().contains(query);
      final matchesSearch =
          query.isEmpty || matchesName || matchesIts || matchesSf;

      // 3. Status Dropdown Filter
      bool matchesStatus = true;
      if (_selectedStatusFilter == 'Pending') {
        matchesStatus = !person.isComplete;
      } else if (_selectedStatusFilter == 'Submitted') {
        matchesStatus = person.isComplete;
      }

      return matchesSearch && matchesStatus;
    }).toList();

    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortColumnIndex) {
        case 0:
          comparison = (a.isComplete ? 1 : 0).compareTo(b.isComplete ? 1 : 0);
          break;
        case 1:
          comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          break;
        case 2:
          comparison = a.its.compareTo(b.its);
          break;
        case 3:
          comparison = a.sfNo!.compareTo(b.sfNo!);
          break;
        case 4:
          comparison = a.progressPercentage.compareTo(b.progressPercentage);
          break;
        default:
          comparison = 0;
      }
      return _isAscending ? comparison : -comparison;
    });

    return filtered;
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _isAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDev = provider.isDev;
    final isAdmin = provider.isAdmin;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('IBM Solar Survey Dashboard'),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        actions: [
          if (isDev || isAdmin)
            if (isDev)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4.0,
                  vertical: 8.0,
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.playlist_add, size: 18),
                  label: const Text('Import Profiles'),
                  onPressed: () async {
                    try {
                      await provider.importProfilesFromExcel();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profiles imported successfully!'),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                ),
              ),
          if (isDev)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4.0,
                vertical: 8.0,
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('Add Profile'),
                onPressed: () => _showAddProfileDialog(context),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await provider.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginView()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final people = provider.people;
          final totalProfiles = people.length;

          final int totalRequiredForms = totalProfiles * PersonModel.totalForms;
          final int totalFormsSubmitted = people.fold<int>(
            0,
            (sum, p) =>
                sum + p.completedFormCount.clamp(0, PersonModel.totalForms),
          );
          final double overallProgress = totalRequiredForms > 0
              ? (totalFormsSubmitted / totalRequiredForms)
              : 0.0;
          final pendingCount = people.where((p) => !p.isComplete).length;
          final completedProfilesCount = people
              .where((p) => p.isComplete)
              .length;
          final displayedPeople = _getFilteredAndSortedPeople(people);

          final formSubmissionCounts = List.generate(
            PersonModel.totalForms,
            (index) =>
                people.where((p) => p.completedFormCount >= index + 1).length,
          );

          final form1SubmittedCount = formSubmissionCounts[0];
          final form2SubmittedCount = formSubmissionCounts[1];
          final form3SubmittedCount = formSubmissionCounts[2];
          final form4SubmittedCount = formSubmissionCounts[3];
          final form5SubmittedCount = formSubmissionCounts[4];

          final form1Denominator = totalProfiles;
          final form2Denominator = form1SubmittedCount;
          final form3Denominator = form2SubmittedCount;
          final form4Denominator = form3SubmittedCount;
          final form5Denominator = form4SubmittedCount;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 4 Metric Cards Row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Profiles',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Icon(
                                  Icons.people,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              totalProfiles.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${(overallProgress * 100).toInt()}% Completed',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setState(() {
                              if (_activeFormFilter == 4) {
                                _activeFormFilter = null;
                              } else {
                                _activeFormFilter = 4;
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _activeFormFilter == 4
                                    ? const Color(0xFF10B981)
                                    : Colors.grey.shade200,
                                width: _activeFormFilter == 4 ? 2.0 : 1.0,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Forms Submitted',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Icon(
                                      Icons.assignment_turned_in_outlined,
                                      color: Colors.grey.shade400,
                                      size: 20,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '$completedProfilesCount/$totalProfiles',
                                  style: const TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Fully Completed Profiles',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF97316),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Pending Profiles',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Icon(
                                  Icons.schedule,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              pendingCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Needs Attention',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SummaryDashboardView(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF10B981,
                                  ).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Survey Analytics',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Icon(
                                      Icons.analytics_outlined,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Summary',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      'View Breakdown',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                      size: 10,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Progress cards show how many profiles have submitted each form.
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
                            'Form Progress',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          if (_activeFormFilter != null)
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF2563EB),
                                side: const BorderSide(
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                              icon: const Icon(Icons.clear, size: 16),
                              label: const Text('Show All Profiles'),
                              onPressed: () {
                                setState(() {
                                  _activeFormFilter = null;
                                });
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInteractiveCascadingCard(
                              stageNumber: 1,
                              title: 'Form 1 Submitted',
                              completed: form1SubmittedCount,
                              total: form1Denominator,
                              subtitle: 'Out of $form1Denominator profiles',
                              color: const Color(0xFF2563EB),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInteractiveCascadingCard(
                              stageNumber: 2,
                              title: 'Form 2 Submitted',
                              completed: form2SubmittedCount,
                              total: form2Denominator,
                              subtitle: 'Out of $form2Denominator profiles',
                              color: const Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInteractiveCascadingCard(
                              stageNumber: 3,
                              title: 'Form 3 Submitted',
                              completed: form3SubmittedCount,
                              total: form3Denominator,
                              subtitle: 'Out of $form3Denominator profiles',
                              color: const Color(0xFF8B5CF6),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInteractiveCascadingCard(
                              stageNumber: 4,
                              title: 'Form 4 Submitted',
                              completed: form4SubmittedCount,
                              total: form4Denominator,
                              subtitle: 'Out of $form4Denominator profiles',
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInteractiveCascadingCard(
                              stageNumber: 5,
                              title: 'Form 5 Submitted',
                              completed: form5SubmittedCount,
                              total: form5Denominator,
                              subtitle: 'Out of $form5Denominator profiles',
                              color: const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Client Survey List Section
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
                          Row(
                            children: [
                              Text(
                                _activeFormFilter == null
                                    ? 'Client Survey List'
                                    : (_activeFormFilter == 1
                                          ? 'Filtered List: Form 1 Filled (33%)'
                                          : _activeFormFilter == 2
                                          ? 'Filtered List: Forms 1 & 2 Filled (66%)'
                                          : _activeFormFilter == 3
                                          ? 'Filtered List: All Forms Completed (100%)'
                                          : 'Filtered List: Fully Completed Profiles'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${displayedPeople.length} Profiles',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF2563EB),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 260,
                                height: 40,
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (val) => setState(() {}),
                                  decoration: InputDecoration(
                                    hintText: 'Search Name, ITS, SF...',
                                    hintStyle: const TextStyle(fontSize: 13),
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      size: 18,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 0,
                                      horizontal: 10,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                height: 40,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedStatusFilter == 'All'
                                        ? 'All Status'
                                        : _selectedStatusFilter,
                                    items:
                                        ['All Status', 'Submitted', 'Pending']
                                            .map(
                                              (status) => DropdownMenuItem(
                                                value: status,
                                                child: Text(
                                                  status,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() {
                                          _selectedStatusFilter =
                                              val == 'All Status' ? 'All' : val;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (displayedPeople.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32.0),
                          child: Center(
                            child: Text(
                              'No profiles match the current filter criteria.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              sortColumnIndex: _sortColumnIndex,
                              sortAscending: _isAscending,
                              horizontalMargin: 0,
                              columnSpacing: 32,
                              columns: [
                                DataColumn(
                                  label: const Text('Status'),
                                  onSort: _onSort,
                                ),
                                DataColumn(
                                  label: const Text('Name'),
                                  onSort: _onSort,
                                ),
                                DataColumn(
                                  label: const Text('ITS'),
                                  numeric: true,
                                  onSort: _onSort,
                                ),
                                DataColumn(
                                  label: const Text('SF No'),
                                  numeric: true,
                                  onSort: _onSort,
                                ),
                                DataColumn(
                                  label: const Text('Form Progress'),
                                  onSort: _onSort,
                                ),
                                const DataColumn(label: Text('Action')),
                                if (isDev)
                                  const DataColumn(label: Text('Delete')),
                              ],
                              rows: displayedPeople
                                  .map(
                                    (person) =>
                                        _buildTableRow(context, person, isDev),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Interactive Cascading Card Widget
  Widget _buildInteractiveCascadingCard({
    required int stageNumber,
    required String title,
    required int completed,
    required int total,
    required String subtitle,
    required Color color,
  }) {
    final double ratio = total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;
    final int percentage = (ratio * 100).toInt();
    final bool isSelected = _activeFormFilter == stageNumber;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          setState(() {
            if (_activeFormFilter == stageNumber) {
              _activeFormFilter = null; // Toggle off on second click
            } else {
              _activeFormFilter = stageNumber; // Set active stage filter
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.08)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade200,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 54,
                    height: 54,
                    child: CircularProgressIndicator(
                      value: ratio,
                      backgroundColor: const Color(0xFFE2E8F0),
                      color: color,
                      strokeWidth: 6,
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isSelected ? color : const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completed / $total',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DataRow _buildTableRow(BuildContext context, PersonModel person, bool isDev) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final bool isViewer = provider.isViewer;
    final bool isComplete = person.isComplete;
    final int percentage = (person.progressPercentage * 100).toInt();

    final String buttonText = isViewer
        ? 'View Details'
        : (isComplete ? 'View Details' : 'View Details');

    List<DataCell> cells = [
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
        Text(person.name, style: const TextStyle(fontWeight: FontWeight.w600)),
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
              LinearProgressIndicator(
                value: person.progressPercentage,
                minHeight: 4,
                backgroundColor: const Color(0xFFE2E8F0),
                color: isComplete
                    ? const Color(0xFF10B981)
                    : const Color(0xFFF59E0B),
              ),
            ],
          ),
        ),
      ),
      DataCell(
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileDetailView(person: person),
              ),
            );
          },
          child: Text(buttonText),
        ),
      ),
    ];

    if (isDev) {
      cells.add(
        DataCell(
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Delete Profile (Dev Only)',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Deletion'),
                  content: Text(
                    'Are you sure you want to delete ${person.name}?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await provider.deletePerson(person.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile deleted successfully.'),
                    ),
                  );
                }
              }
            },
          ),
        ),
      );
    }

    return DataRow(cells: cells);
  }
}
