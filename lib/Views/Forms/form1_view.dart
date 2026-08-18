// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:form_manager/Controller/provider_controller.dart';
import 'package:form_manager/Model/form_data_model.dart';
import 'package:form_manager/Model/person_model.dart';

class Form1View extends StatefulWidget {
  final PersonModel person;
  final bool readOnly;

  const Form1View({super.key, required this.person, this.readOnly = false});

  @override
  State<Form1View> createState() => _Form1ViewState();
}

class _Form1ViewState extends State<Form1View> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _itsController;
  late TextEditingController _sfNoController;
  late TextEditingController _contactController;
  late TextEditingController _addressController;
  late TextEditingController _familyMembersController;
  late TextEditingController _landlordNameController;
  late TextEditingController _landlordContactController;

  String? _selectedHouseType;
  String? _selectedTotalRooms;
  String? _willingToSolar;
  String? _landlordApproval;

  bool _isSavingDraft = false;
  bool _isSubmitting = false;
  bool _isDeleting = false;
  bool _isReadOnly = false;

  final List<String> _houseTypeOptions = ['Ownership', 'Rent', 'Goodwill'];
  final List<String> _roomOptions = [
    '2-Bed Lounge',
    '3-Bed Lounge',
    '2-Bed D/D',
    '3-Bed D/D',
  ];
  final List<String> _solarWillingnessOptions = [
    'Yes',
    'No',
    'Already Installed',
  ];
  final List<String> _landlordApprovalOptions = ['Yes', 'No', 'Maybe'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.person.name);
    _itsController = TextEditingController(text: widget.person.its.toString());
    _sfNoController = TextEditingController(
      text: widget.person.sfNo?.toString() ?? '',
    );
    _contactController = TextEditingController(text: widget.person.contact);
    _addressController = TextEditingController(
      text: widget.person.address ?? '',
    );
    _familyMembersController = TextEditingController();
    _landlordNameController = TextEditingController();
    _landlordContactController = TextEditingController();

    _willingToSolar = widget.person.willingToSolar ? 'Yes' : 'No';
    _landlordApproval = widget.person.landlordApproval ? 'Yes' : 'No';

    _isReadOnly =
        widget.readOnly ||
        Provider.of<AppProvider>(context, listen: false).isViewer;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final provider = Provider.of<AppProvider>(context, listen: false);

    FormDataModel? draft = provider.loadDraft(widget.person.id, 1);
    draft ??= await provider.getSubmittedForm(widget.person.id, 1);

    if (draft != null && mounted) {
      final ans = draft.answers;
      setState(() {
        _nameController.text = (ans['name'] ?? '').toString();
        _itsController.text = (ans['its'] ?? '').toString();
        _sfNoController.text = (ans['sfNo'] ?? '').toString();
        _contactController.text = (ans['contact'] ?? '').toString();
        _addressController.text = (ans['address'] ?? '').toString();
        _familyMembersController.text = (ans['noOfPersons'] ?? '').toString();
        _landlordNameController.text = (ans['landlordName'] ?? '').toString();
        _landlordContactController.text = (ans['landlordContact'] ?? '')
            .toString();

        final houseType = (ans['houseType'] ?? '').toString();
        _selectedHouseType = houseType.isNotEmpty ? houseType : null;

        final rooms = (ans['rooms'] ?? '').toString();
        _selectedTotalRooms = rooms.isNotEmpty ? rooms : null;

        final solarWillingness = (ans['solarWillingness'] ?? '').toString();
        _willingToSolar = solarWillingness.isNotEmpty ? solarWillingness : null;

        final landlordApproval = (ans['landlordApproval'] ?? '').toString();
        _landlordApproval = landlordApproval.isNotEmpty
            ? landlordApproval
            : null;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _itsController.dispose();
    _sfNoController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _familyMembersController.dispose();
    _landlordNameController.dispose();
    _landlordContactController.dispose();
    super.dispose();
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumeric = false,
    bool enabled = true,
  }) {
    return SizedBox(
      width: 260,
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        enabled: enabled && !_isReadOnly,
        onChanged: (_) => setState(() {}),
        validator: (v) {
          if (label.contains('*') && (v == null || v.trim().isEmpty)) {
            return 'Required';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String? value,
    String label,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return SizedBox(
      width: 260,
      child: DropdownButtonFormField<String>(
        initialValue: items.contains(value) ? value : null,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: !_isReadOnly ? Colors.white : Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        items: items
            .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
            .toList(),
        onChanged: _isReadOnly ? null : onChanged,
        validator: (v) {
          if (label.contains('*') && v == null) {
            return 'Required';
          }
          return null;
        },
      ),
    );
  }

  double _calculateCompletionRatio() {
    int filledFields = 0;
    const int totalTrackedFields = 9;

    if (_sfNoController.text.trim().isNotEmpty) filledFields++;
    if (_itsController.text.trim().isNotEmpty) filledFields++;
    if (_nameController.text.trim().isNotEmpty) filledFields++;
    if (_contactController.text.trim().isNotEmpty) filledFields++;
    if (_addressController.text.trim().isNotEmpty) filledFields++;
    if (_familyMembersController.text.trim().isNotEmpty) filledFields++;
    if (_selectedHouseType != null) filledFields++;
    if (_selectedTotalRooms != null) filledFields++;
    if (_willingToSolar != null) filledFields++;

    return filledFields / totalTrackedFields;
  }

  Map<String, dynamic> _collectFormAnswers() {
    final ratio = _calculateCompletionRatio();
    return {
      'name': _nameController.text.trim(),
      'its': _itsController.text.trim(),
      'sfNo': _sfNoController.text.trim(),
      'contact': _contactController.text.trim(),
      'address': _addressController.text.trim(),
      'houseType': _selectedHouseType ?? '',
      'rooms': _selectedTotalRooms ?? '',
      'noOfPersons': _familyMembersController.text.trim(),
      'landlordName': _landlordNameController.text.trim(),
      'landlordContact': _landlordContactController.text.trim(),
      'solarWillingness': _willingToSolar ?? '',
      'landlordApproval': _landlordApproval ?? '',
      'completionRatio': ratio,
    };
  }

  Future<void> _handleSaveDraft() async {
    setState(() => _isSavingDraft = true);
    final provider = Provider.of<AppProvider>(context, listen: false);
    final answers = _collectFormAnswers();

    final draft = FormDataModel(
      id: 'draft_form1_${widget.person.id}',
      personId: widget.person.id,
      formNumber: 1,
      filledByStaffId: provider.currentUser?.uid ?? '',
      answers: answers,
      isDraft: true,
      updatedAt: DateTime.now(),
    );

    await provider.saveDraft(draft);
    await Future.delayed(const Duration(milliseconds: 400));

    if (mounted) {
      setState(() => _isSavingDraft = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form 1 local draft saved successfully.')),
      );
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final provider = Provider.of<AppProvider>(context, listen: false);
    final answers = _collectFormAnswers();

    final submission = FormDataModel(
      id: 'form1_${widget.person.id}',
      personId: widget.person.id,
      formNumber: 1,
      filledByStaffId: provider.currentUser?.uid ?? '',
      answers: answers,
      isDraft: false,
      updatedAt: DateTime.now(),
    );

    try {
      await provider.submitFormToFirebase(submission);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form 1 submitted successfully.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Submission failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Form'),
        content: const Text(
          'Are you sure you want to delete this form? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);
    final provider = Provider.of<AppProvider>(context, listen: false);

    try {
      await provider.deleteSubmittedForm(widget.person.id, 1);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form 1 deleted successfully.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double completionRatio = _calculateCompletionRatio();
    final int completionPercentage = (completionRatio * 100).toInt();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        title: Text('${widget.person.name} - Form 1 (Personal Profile)'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Banner
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Form 1: Personal Profile Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Calculated Total Watts: ${widget.person.totalWattage.toInt()} W',
                          style: const TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '$completionPercentage%',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionHeader('1. Personal Profile Details'),
              const SizedBox(height: 16),

              // Reordered Input Grid as per image sequence
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  // Row 1
                  _buildTextField(_nameController, 'Full Name *'),
                  _buildTextField(
                    _itsController,
                    'ITS Number *',
                    isNumeric: true,
                  ),
                  _buildTextField(
                    _sfNoController,
                    'SF Number *',
                    isNumeric: true,
                  ),
                  _buildTextField(_contactController, 'Contact Number *'),
                  _buildTextField(
                    _addressController,
                    'Complete Address (Flat, Floor, Building, Area) *',
                  ),
                  _buildDropdownField(
                    _selectedHouseType,
                    'House Type *',
                    _houseTypeOptions,
                    (val) => setState(() => _selectedHouseType = val),
                  ),

                  // Row 2
                  _buildDropdownField(
                    _selectedTotalRooms,
                    'Total Number of Rooms *',
                    _roomOptions,
                    (val) => setState(() => _selectedTotalRooms = val),
                  ),
                  _buildTextField(
                    _familyMembersController,
                    'Number of Family Members *',
                    isNumeric: true,
                  ),
                  _buildDropdownField(
                    _willingToSolar,
                    'Are you willing to install solar? *',
                    _solarWillingnessOptions,
                    (val) => setState(() => _willingToSolar = val),
                  ),
                  _buildDropdownField(
                    _landlordApproval,
                    'Is your landlord\'s approval required for rooftop solar? *',
                    _landlordApprovalOptions,
                    (val) => setState(() => _landlordApproval = val),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const SizedBox(height: 32),

              // Bottom Actions
              LayoutBuilder(
                builder: (context, constraints) {
                  final bool isWide = constraints.maxWidth > 600;
                  final double buttonWidth = isWide
                      ? (constraints.maxWidth - 16) / 2
                      : constraints.maxWidth;

                  return Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      if (!_isReadOnly) ...[
                        SizedBox(
                          width: buttonWidth,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: _isSavingDraft ? null : _handleSaveDraft,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF2563EB),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: _isSavingDraft
                                ? const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  )
                                : const Text(
                                    'Save Local Draft',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(
                          width: buttonWidth,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: _isSubmitting
                                ? const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Submit Form',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(
                          width: buttonWidth,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: _isDeleting ? null : _handleDelete,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: _isDeleting
                                ? const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  )
                                : const Text(
                                    'Delete Form',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ] else ...[
                        const Text(
                          'Viewer account: read-only access. Edit and submission are disabled.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
