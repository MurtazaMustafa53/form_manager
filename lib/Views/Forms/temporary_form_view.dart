import 'package:flutter/material.dart';
import 'package:form_manager/Controller/provider_controller.dart';
import 'package:form_manager/Model/form_data_model.dart';
import 'package:form_manager/Model/person_model.dart';
import 'package:provider/provider.dart';

class TemporaryFormView extends StatefulWidget {
  final PersonModel person;
  final bool readOnly;

  const TemporaryFormView({
    super.key,
    required this.person,
    this.readOnly = false,
  });

  @override
  State<TemporaryFormView> createState() => _TemporaryFormViewState();
}

class _TemporaryFormViewState extends State<TemporaryFormView> {
  final _formKey = GlobalKey<FormState>();
  final _buildingNameController = TextEditingController();
  bool _isReadOnly = false;
  bool _isSavingDraft = false;
  bool _isSubmitting = false;
  bool _isDeleting = false;
  bool _hasSavedForm = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AppProvider>(context, listen: false);
    _isReadOnly = widget.readOnly || !provider.canAccessTemporaryForm;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    FormDataModel? draft = provider.loadDraft(
      widget.person.id,
      AppProvider.temporaryFormNumber,
    );
    final submitted = await provider.getSubmittedForm(
      widget.person.id,
      AppProvider.temporaryFormNumber,
    );
    draft ??= submitted;

    final loadedData = draft;
    if (loadedData != null && mounted) {
      setState(() {
        _buildingNameController.text =
            (loadedData.answers['buildingName'] ?? '').toString();
        _hasSavedForm = true;
      });
    }
  }

  @override
  void dispose() {
    _buildingNameController.dispose();
    super.dispose();
  }

  FormDataModel _buildFormData({required bool isDraft}) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    return FormDataModel(
      id: '${widget.person.id}_form_${AppProvider.temporaryFormNumber}',
      personId: widget.person.id,
      formNumber: AppProvider.temporaryFormNumber,
      filledByStaffId: provider.currentUser?.uid ?? '',
      answers: {'buildingName': _buildingNameController.text.trim()},
      isDraft: isDraft,
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _handleSaveDraft() async {
    setState(() => _isSavingDraft = true);
    try {
      await Provider.of<AppProvider>(
        context,
        listen: false,
      ).saveDraft(_buildFormData(isDraft: true));
      if (mounted) {
        setState(() => _hasSavedForm = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Temporary form draft saved.')),
        );
      }
    } catch (e) {
      _showError('Save failed: $e');
    } finally {
      if (mounted) setState(() => _isSavingDraft = false);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await Provider.of<AppProvider>(
        context,
        listen: false,
      ).submitFormToFirebase(_buildFormData(isDraft: false));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Temporary form submitted.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showError('Submission failed: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Form'),
        content: const Text('Delete the saved temporary form?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isDeleting = true);
    try {
      await Provider.of<AppProvider>(
        context,
        listen: false,
      ).deleteSubmittedForm(widget.person.id, AppProvider.temporaryFormNumber);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showError('Delete failed: $e');
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Widget _buildTextField() {
    return SizedBox(
      width: 260,
      child: TextFormField(
        controller: _buildingNameController,
        enabled: !_isReadOnly,
        decoration: InputDecoration(
          labelText: 'Building Name *',
          filled: true,
          fillColor: _isReadOnly ? Colors.grey.shade100 : Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) =>
            value == null || value.trim().isEmpty ? 'Required' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    if (!provider.canAccessTemporaryForm) {
      return Scaffold(
        appBar: AppBar(title: const Text('Temporary Form')),
        body: const Center(
          child: Text(
            'This form is available to Dev and Finance accounts only.',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        title: Text('${widget.person.name} - Temporary Form'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Temporary Form: Building Name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'Internal Form',
                      style: TextStyle(
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '1. Building Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(spacing: 16, runSpacing: 16, children: [_buildTextField()]),
              const SizedBox(height: 32),
              if (!_isReadOnly)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 600;
                    final buttonWidth = isWide
                        ? (constraints.maxWidth - 16) / 2
                        : constraints.maxWidth;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      children: [
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
                      ],
                    );
                  },
                )
              else
                const Text(
                  'Read-only access. Editing and submission are disabled.',
                  style: TextStyle(color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
