import 'package:flutter/material.dart';
import 'package:form_manager/Controller/provider_controller.dart';
import 'package:form_manager/Model/form_data_model.dart';
import 'package:form_manager/Model/person_model.dart';
import 'package:provider/provider.dart';

class SolarExtensionFormView extends StatefulWidget {
  final PersonModel person;
  final bool readOnly;

  const SolarExtensionFormView({
    super.key,
    required this.person,
    this.readOnly = false,
  });

  @override
  State<SolarExtensionFormView> createState() => _SolarExtensionFormViewState();
}

class _SolarExtensionFormViewState extends State<SolarExtensionFormView> {
  final _formKey = GlobalKey<FormState>();
  final _currentCapacityController = TextEditingController();
  final _requiredCapacityController = TextEditingController();
  final _solarPanelsController = TextEditingController();
  final _mountingStructureController = TextEditingController();
  final _batteryController = TextEditingController();
  final _inverterController = TextEditingController();
  final _wiringController = TextEditingController();
  final _otherController = TextEditingController();
  final _reasonController = TextEditingController();
  final _financingMethodController = TextEditingController();
  final _remarksController = TextEditingController();
  final _filledByController = TextEditingController();

  final Map<String, bool> _items = {
    'solarPanels': false,
    'mountingStructure': false,
    'battery': false,
    'inverter': false,
    'wiring': false,
    'other': false,
  };

  bool _isLoading = true;
  bool _isReadOnly = false;
  bool _isSavingDraft = false;
  bool _isSubmitting = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AppProvider>(context, listen: false);
    _isReadOnly = widget.readOnly || provider.isViewer;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    FormDataModel? form = provider.loadDraft(widget.person.id, 6);
    form ??= await provider.getSubmittedForm(widget.person.id, 6);

    if (!mounted) return;
    if (form != null) {
      final answers = form.answers;
      setState(() {
        _currentCapacityController.text = (answers['currentCapacity'] ?? '')
            .toString();
        _requiredCapacityController.text =
            (answers['requiredExtensionCapacity'] ?? '').toString();
        _solarPanelsController.text = (answers['solarPanels'] ?? '').toString();
        _mountingStructureController.text = (answers['mountingStructure'] ?? '')
            .toString();
        _batteryController.text = (answers['battery'] ?? '').toString();
        _inverterController.text = (answers['inverter'] ?? '').toString();
        _wiringController.text = (answers['wiring'] ?? '').toString();
        _otherController.text = (answers['other'] ?? '').toString();
        _reasonController.text = (answers['reason'] ?? '').toString();
        _financingMethodController.text = (answers['financingMethod'] ?? '')
            .toString();
        _remarksController.text = (answers['remarks'] ?? '').toString();
        _filledByController.text = (answers['formFilledBy'] ?? '').toString();
        final savedItems = answers['items'];
        if (savedItems is Map) {
          for (final entry in _items.keys) {
            _items[entry] = savedItems[entry] == true;
          }
        }
      });
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _currentCapacityController.dispose();
    _requiredCapacityController.dispose();
    _solarPanelsController.dispose();
    _mountingStructureController.dispose();
    _batteryController.dispose();
    _inverterController.dispose();
    _wiringController.dispose();
    _otherController.dispose();
    _reasonController.dispose();
    _financingMethodController.dispose();
    _remarksController.dispose();
    _filledByController.dispose();
    super.dispose();
  }

  double _completionRatio() {
    final values = [
      _currentCapacityController.text,
      _requiredCapacityController.text,
      _solarPanelsController.text,
      _mountingStructureController.text,
      _batteryController.text,
      _inverterController.text,
      _wiringController.text,
      _otherController.text,
      _reasonController.text,
      _financingMethodController.text,
      _remarksController.text,
      _filledByController.text,
    ];
    final filled = values.where((value) => value.trim().isNotEmpty).length;
    final selectedItems = _items.values.where((value) => value).length;
    return ((filled + selectedItems) / (values.length + 1)).clamp(0.0, 1.0);
  }

  Map<String, dynamic> _collectAnswers() {
    return {
      'name': widget.person.name,
      'address': widget.person.address ?? '',
      'currentCapacity': _currentCapacityController.text.trim(),
      'requiredExtensionCapacity': _requiredCapacityController.text.trim(),
      'items': Map<String, bool>.from(_items),
      'solarPanels': _solarPanelsController.text.trim(),
      'mountingStructure': _mountingStructureController.text.trim(),
      'battery': _batteryController.text.trim(),
      'inverter': _inverterController.text.trim(),
      'wiring': _wiringController.text.trim(),
      'other': _otherController.text.trim(),
      'reason': _reasonController.text.trim(),
      'financingMethod': _financingMethodController.text.trim(),
      'remarks': _remarksController.text.trim(),
      'formFilledBy': _filledByController.text.trim(),
      'completionRatio': _completionRatio(),
    };
  }

  Future<void> _saveDraft() async {
    setState(() => _isSavingDraft = true);
    final provider = Provider.of<AppProvider>(context, listen: false);
    await provider.saveDraft(
      FormDataModel(
        id: '${widget.person.id}_form_6',
        personId: widget.person.id,
        formNumber: 6,
        filledByStaffId: provider.currentUser?.uid ?? '',
        isDraft: true,
        updatedAt: DateTime.now(),
        answers: _collectAnswers(),
      ),
    );
    if (!mounted) return;
    setState(() => _isSavingDraft = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Solar extension draft saved.')),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final provider = Provider.of<AppProvider>(context, listen: false);
    try {
      await provider.submitFormToFirebase(
        FormDataModel(
          id: '${widget.person.id}_form_6',
          personId: widget.person.id,
          formNumber: 6,
          filledByStaffId: provider.currentUser?.uid ?? '',
          isDraft: false,
          updatedAt: DateTime.now(),
          answers: _collectAnswers(),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solar extension form submitted.')),
      );
      Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Submission failed: $error')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _delete() async {
    setState(() => _isDeleting = true);
    final provider = Provider.of<AppProvider>(context, listen: false);
    try {
      await provider.deleteSubmittedForm(widget.person.id, 6);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Delete failed: $error')));
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Widget _field(TextEditingController controller, String label) {
    return SizedBox(
      width: 280,
      child: TextFormField(
        controller: controller,
        enabled: !_isReadOnly,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: _isReadOnly ? Colors.grey.shade100 : Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _profileField(String value, String label) {
    return SizedBox(
      width: 280,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(value.isEmpty ? '-' : value),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(spacing: 16, runSpacing: 16, children: children),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (_completionRatio() * 100).round();
    if (!widget.person.hasExistingSolarSystem) {
      return Scaffold(
        appBar: AppBar(title: const Text('Solar Extension Form')),
        body: const Center(
          child: Text(
            'This form is only available for already-installed systems.',
          ),
        ),
      );
    }
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        title: Text('${widget.person.name} - Solar Extension Request'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'IBM Solar Survey 2026 / 1448H',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Solar Extension Request Form',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: _completionRatio(),
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE2E8F0),
                      color: const Color(0xFF10B981),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('$percentage% complete'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _section('Profile Information', [
                _profileField(widget.person.name, 'Name'),
                _profileField(widget.person.address ?? '', 'Address'),
                _profileField(widget.person.sfNo?.toString() ?? '', 'SF'),
                _profileField(widget.person.its.toString(), 'ITS'),
                _profileField(widget.person.contact, 'Contact'),
              ]),
              const SizedBox(height: 16),
              _section('Solar Capacity', [
                _field(
                  _currentCapacityController,
                  'Current Solar Capacity (kW)',
                ),
                _field(
                  _requiredCapacityController,
                  'Required Extension Capacity (kW)',
                ),
              ]),
              const SizedBox(height: 16),
              _section('Items Required for Extension', [
                for (final item in _items.keys)
                  SizedBox(
                    width: 280,
                    child: CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_itemLabel(item)),
                      value: _items[item],
                      onChanged: _isReadOnly
                          ? null
                          : (value) =>
                                setState(() => _items[item] = value ?? false),
                    ),
                  ),
                _field(_solarPanelsController, 'Solar Panels'),
                _field(_mountingStructureController, 'Mounting Structure'),
                _field(_batteryController, 'Battery'),
                _field(_inverterController, 'Inverter'),
                _field(_wiringController, 'Wiring'),
                _field(_otherController, 'Other'),
              ]),
              const SizedBox(height: 16),
              _section('Request Details', [
                _field(_reasonController, 'Reason for Extension'),
                _field(_financingMethodController, 'Financing Method'),
                _field(_filledByController, 'Form fill by'),
                SizedBox(
                  width: double.infinity,
                  child: TextFormField(
                    controller: _remarksController,
                    enabled: !_isReadOnly,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Remarks',
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: _isReadOnly
                          ? Colors.grey.shade100
                          : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 20),
              if (!_isReadOnly)
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OutlinedButton(
                      onPressed: _isSavingDraft ? null : _saveDraft,
                      child: Text(_isSavingDraft ? 'Saving...' : 'Save Draft'),
                    ),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: Text(_isSubmitting ? 'Submitting...' : 'Submit'),
                    ),
                    OutlinedButton(
                      onPressed: _isDeleting ? null : _delete,
                      child: Text(_isDeleting ? 'Deleting...' : 'Delete Form'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _itemLabel(String key) {
    switch (key) {
      case 'solarPanels':
        return 'Solar Panels';
      case 'mountingStructure':
        return 'Mounting Structure';
      case 'battery':
        return 'Battery';
      case 'inverter':
        return 'Inverter';
      case 'wiring':
        return 'Wiring';
      case 'other':
        return 'Other';
      default:
        return key;
    }
  }
}
