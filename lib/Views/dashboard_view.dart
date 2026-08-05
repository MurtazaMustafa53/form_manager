import 'package:flutter/material.dart';
import 'package:form_manager/Controller/provider_controller.dart';
import 'package:form_manager/Model/person_model.dart';
import 'package:form_manager/Views/login_view.dart';
import 'package:form_manager/Views/profile_detail_view.dart';
import 'package:provider/provider.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatusFilter = 'All';

  // Sorting State
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
                  );

                  await provider.addNewPerson(newPerson);

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('New profile created successfully!'),
                      ),
                    );
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
      final matchesName = person.name.toLowerCase().contains(query);
      final matchesIts = person.its.toString().contains(query);
      final matchesSf = person.sfNo.toString().contains(query);
      final matchesSearch =
          query.isEmpty || matchesName || matchesIts || matchesSf;

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
          comparison = a.sfNo.compareTo(b.sfNo);
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
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('IBM Solar Survey Dashboard'),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
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
              final provider = Provider.of<AppProvider>(context, listen: false);
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
          final completedForms = people.where((p) => p.isComplete).length;
          final overallProgress = totalProfiles > 0
              ? (completedForms / totalProfiles)
              : 0.0;
          final pendingCount = people.where((p) => !p.isComplete).length;

          final displayedPeople = _getFilteredAndSortedPeople(people);

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
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          spacing: 16,
                          runSpacing: 12,
                          children: [
                            const Text(
                              'Client Survey List',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 240,
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      hintText: 'Search Name, ITS, SF...',
                                      prefixIcon: const Icon(
                                        Icons.search,
                                        size: 20,
                                      ),
                                      suffixIcon:
                                          _searchController.text.isNotEmpty
                                          ? IconButton(
                                              icon: const Icon(
                                                Icons.clear,
                                                size: 18,
                                              ),
                                              onPressed: () {
                                                _searchController.clear();
                                                setState(() {});
                                              },
                                            )
                                          : null,
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade400,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedStatusFilter,
                                      isDense: true,
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'All',
                                          child: Text('All Status'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'Pending',
                                          child: Text('Pending'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'Submitted',
                                          child: Text('Submitted'),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(() {
                                            _selectedStatusFilter = value;
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
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32.0),
                            child: Center(
                              child: Text(
                                people.isEmpty
                                    ? 'No profiles loaded from Firebase yet.'
                                    : 'No profiles match your search criteria.',
                                style: const TextStyle(color: Colors.grey),
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
                                horizontalMargin: 12,
                                columnSpacing: 28,
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
                                ],
                                rows: displayedPeople
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
    final provider = Provider.of<AppProvider>(context, listen: false);
    final bool isViewer = provider.isViewer;
    final bool isComplete = person.isComplete;
    final int percentage = (person.progressPercentage * 100).toInt();

    final String buttonText = isViewer
        ? 'View Details'
        : (isComplete ? 'View Details' : 'Open Profile');

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
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 0,
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
      ],
    );
  }
}
