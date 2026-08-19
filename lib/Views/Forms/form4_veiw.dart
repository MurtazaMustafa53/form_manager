import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:form_manager/Controller/provider_controller.dart';
import 'package:form_manager/Model/form_data_model.dart';
import 'package:form_manager/Model/person_model.dart';

List<Map<String, String>> buildMaterialFieldDefinitionsForm4() {
  return [
    {'key': 'dbBox', 'label': 'DB Box'},
    {'key': 'nutBolts', 'label': 'Nuts & Bolts'},
    {'key': 'clip1', 'label': 'Clips 1"'},
    {'key': 'insulationTape', 'label': 'Insulation Tape'},
    {'key': 'acBreaker', 'label': 'AC Breaker'},
    {'key': 'pipeLength34', 'label': 'PVC Pipe 3/4"'},
    {'key': 'wire7029', 'label': 'Wire 7/0.29'},
    {'key': 'socket', 'label': 'Sockets'},
    {'key': 'dcBreaker', 'label': 'DC Breaker'},
    {'key': 'pipeLength1', 'label': 'PVC Pipe 1"'},
    {'key': 'acWire4mm', 'label': 'Wire 4mm (AC)'},
    {'key': 'changeOver', 'label': 'Change Over Switch'},
    {'key': 'screw', 'label': 'Screws'},
    {'key': 'dcWire4mm', 'label': 'Wire 4mm (DC)'},
    {'key': 'indicationLights', 'label': 'Indication Lights'},
    {'key': 'rawalPlug', 'label': 'Rawal Plugs'},
    {'key': 'wire4076', 'label': 'Wire 40/0.76'},
    {'key': 'mc4Connector', 'label': 'MC4 Connectors'},
    {'key': 'flexiblePipe34', 'label': 'Flexible Pipe 3/4"'},
    {'key': 'duct25x25', 'label': 'Duct 25x25'},
    {'key': 'batteryWire', 'label': 'Battery Cable'},
    {'key': 'flexiblePipe1', 'label': 'Flexible Pipe 1"'},
    {'key': 'duct1x1', 'label': 'Duct 1x1'},
    {'key': 'thimble', 'label': 'Thimble Lugs'},
    {'key': 'clip34', 'label': 'Clips 3/4"'},
    {'key': 'band', 'label': 'Pipe Bands'},
  ];
}

class Form4View extends StatefulWidget {
  final PersonModel person;
  final bool readOnly;

  const Form4View({super.key, required this.person, this.readOnly = false});

  @override
  State<Form4View> createState() => _Form4ViewState();
}

class _Form4ViewState extends State<Form4View> {
  final _formKey = GlobalKey<FormState>();

  bool _isSavingDraft = false;
  bool _isSubmitting = false;
  bool _isDeleting = false;
  bool _isReadOnly = false;

  // Header fields (minimal)
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();

  // Family counts
  final _mardoController = TextEditingController();
  final _bairoController = TextEditingController();
  final _gairBalighController = TextEditingController();

  final _earningMembersController = TextEditingController();
  final _dependentMembersController = TextEditingController();

  String _financialStatus = 'Good';
  String _incomeSource = 'Salary/Job';
  final List<String> _financialStatusOptions = [
    'Good',
    'Average',
    'Below Average',
  ];
  final List<String> _incomeSourceOptions = ['Salary/Job', 'Business', 'Other'];
  final List<String> _financeExpectationOptions = ['Yes', 'No'];

  final _ownAmountController = TextEditingController();
  final _totalAmount = TextEditingController();

  final _qarzanAmountController = TextEditingController();
  String _hassanaTerm = 'Short-Term';
  final _hassanaMonthsController = TextEditingController();

  final _jammatContributionController = TextEditingController();

  String _financeExpectation = 'Yes';

  final _remarksController = TextEditingController();
  final _formFillByController = TextEditingController();
  final _amilSignController = TextEditingController();
  final _applicantSignController = TextEditingController();

  double _parseMoneyInput(String? value) {
    if (value == null || value.trim().isEmpty) return 0;
    return double.tryParse(value.replaceAll(',', '').trim()) ?? 0;
  }

  String _formatMoneyValue(double value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  void _syncTotalMuminContribution() {
    final ownAmount = _parseMoneyInput(_ownAmountController.text);
    final qarzanAmount = _parseMoneyInput(_qarzanAmountController.text);
    final nextTotal = _formatMoneyValue(ownAmount + qarzanAmount);
    if (_totalAmount.text != nextTotal) {
      _totalAmount.text = nextTotal;
    }
  }

  @override
  void initState() {
    super.initState();
    _isReadOnly =
        widget.readOnly ||
        Provider.of<AppProvider>(context, listen: false).isViewer;
    _ownAmountController.addListener(_syncTotalMuminContribution);
    _qarzanAmountController.addListener(_syncTotalMuminContribution);
    _loadInitialData();
  }

  double _calculateCompletionRatio() {
    final keys = [
      _addressController.text.trim(),
      _contactController.text.trim(),
      _mardoController.text.trim(),
      _bairoController.text.trim(),
      _gairBalighController.text.trim(),
      _earningMembersController.text.trim(),
      _dependentMembersController.text.trim(),
      _ownAmountController.text.trim(),
      _totalAmount.text.trim(),
      _qarzanAmountController.text.trim(),
      _hassanaMonthsController.text.trim(),
      _jammatContributionController.text.trim(),
      _remarksController.text.trim(),
      _financialStatus,
      _incomeSource,
      _financeExpectation,
    ];
    final total = keys.length;
    final filled = keys.where((k) => k.isNotEmpty).length;
    if (total == 0) return 0.0;
    return (filled / total).clamp(0.0, 1.0);
  }

  Future<void> _loadInitialData() async {
    final provider = Provider.of<AppProvider>(context, listen: false);

    FormDataModel? draft = provider.loadDraft(widget.person.id, 4);
    draft ??= await provider.getSubmittedForm(widget.person.id, 4);

    if (draft != null && mounted) {
      final ans = draft.answers;
      setState(() {
        _addressController.text = ans['address'] ?? widget.person.address ?? '';
        _contactController.text = ans['contact'] ?? widget.person.contact;

        _mardoController.text = ans['mardo'] ?? '';
        _bairoController.text = ans['bairo'] ?? '';
        _gairBalighController.text = ans['gairBaligh'] ?? '';

        _earningMembersController.text = ans['earningMembers'] ?? '';
        _dependentMembersController.text = ans['dependentMembers'] ?? '';

        _financialStatus = ans['financialStatus'] ?? _financialStatus;
        _incomeSource = ans['incomeSource'] ?? _incomeSource;

        _ownAmountController.text = ans['ownAmount'] ?? '';
        _syncTotalMuminContribution();

        _qarzanAmountController.text = ans['qarzanAmount'] ?? '';
        _hassanaTerm = ans['hassanaTerm'] ?? _hassanaTerm;
        _hassanaMonthsController.text = ans['hassanaMonths'] ?? '';

        _jammatContributionController.text = ans['jammatContribution'] ?? '';

        _financeExpectation = ans['financeExpectation'] ?? _financeExpectation;

        _remarksController.text = ans['remarks'] ?? '';
        _formFillByController.text = ans['formFilledBy'] ?? '';
        _amilSignController.text = ans['amilSignature'] ?? '';
        _applicantSignController.text = ans['applicantSignature'] ?? '';
      });
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _mardoController.dispose();
    _bairoController.dispose();
    _gairBalighController.dispose();
    _earningMembersController.dispose();
    _dependentMembersController.dispose();
    _ownAmountController.dispose();
    _totalAmount.dispose();
    _qarzanAmountController.dispose();
    _hassanaMonthsController.dispose();
    _jammatContributionController.dispose();
    _remarksController.dispose();
    _formFillByController.dispose();
    _amilSignController.dispose();
    _applicantSignController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _collectAnswers() {
    return {
      'date': '',
      'name': widget.person.name,
      'address': _addressController.text.trim(),

      'mardo': _mardoController.text.trim(),
      'bairo': _bairoController.text.trim(),
      'gairBaligh': _gairBalighController.text.trim(),

      'earningMembers': _earningMembersController.text.trim(),
      'dependentMembers': _dependentMembersController.text.trim(),

      'financialStatus': _financialStatus,
      'incomeSource': _incomeSource,

      'ownAmount': _ownAmountController.text.trim(),
      'totalMuminContribution': _formatMoneyValue(
        _parseMoneyInput(_ownAmountController.text) +
            _parseMoneyInput(_qarzanAmountController.text),
      ),

      'qarzanAmount': _qarzanAmountController.text.trim(),
      'hassanaTerm': _hassanaTerm,
      'hassanaMonths': _hassanaMonthsController.text.trim(),

      'jammatContribution': _jammatContributionController.text.trim(),
      'financeExpectation': _financeExpectation,

      'remarks': _remarksController.text.trim(),
      'formFilledBy': _formFillByController.text.trim(),
      'amilSignature': _amilSignController.text.trim(),
      'applicantSignature': _applicantSignController.text.trim(),
    };
  }

  Future<void> _handleSaveDraft() async {
    setState(() => _isSavingDraft = true);
    final provider = Provider.of<AppProvider>(context, listen: false);

    final draftData = FormDataModel(
      id: '${widget.person.id}_form_4',
      personId: widget.person.id,
      formNumber: 4,
      filledByStaffId: provider.currentUser?.uid ?? '',
      isDraft: true,
      updatedAt: DateTime.now(),
      answers: _collectAnswers(),
    );

    provider.saveDraft(draftData);
    await Future.delayed(const Duration(milliseconds: 400));

    if (mounted) {
      setState(() => _isSavingDraft = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form 4 local draft saved successfully.')),
      );
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final provider = Provider.of<AppProvider>(context, listen: false);
    final formData = FormDataModel(
      id: '${widget.person.id}_form_4',
      personId: widget.person.id,
      formNumber: 4,
      filledByStaffId: provider.currentUser?.uid ?? '',
      isDraft: false,
      updatedAt: DateTime.now(),
      answers: _collectAnswers(),
    );

    try {
      await provider.submitFormToFirebase(formData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form 4 submitted successfully.')),
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
      if (mounted) setState(() => _isSubmitting = false);
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
      await provider.deleteSubmittedForm(widget.person.id, 4);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form 4 deleted successfully.')),
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

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumeric = false,
    bool readOnly = false,
  }) {
    return SizedBox(
      width: 260,
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        enabled: !_isReadOnly,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: !_isReadOnly ? Colors.white : Colors.grey.shade100,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        title: Text('${widget.person.name} - Form 4'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary banner similar to Form 2
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
                          'Form 4: Financial Survey',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                    Builder(
                      builder: (context) {
                        final pct = (_calculateCompletionRatio() * 100).toInt();
                        return Text(
                          '$pct%',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    const Text(
                      'Survey Details',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildTextField(
                          _mardoController,
                          'Mardo Count',
                          isNumeric: true,
                        ),
                        _buildTextField(
                          _bairoController,
                          'Bairo Count',
                          isNumeric: true,
                        ),
                        _buildTextField(
                          _gairBalighController,
                          'Gair Baligh Count',
                          isNumeric: true,
                        ),
                        _buildTextField(
                          _earningMembersController,
                          'How many family members earn income?',
                          isNumeric: true,
                        ),
                        _buildTextField(
                          _dependentMembersController,
                          'How many dependent family members?',
                          isNumeric: true,
                        ),
                        _buildDropdownField(
                          _financialStatus,
                          'Financial Status',
                          _financialStatusOptions,
                          (v) => setState(
                            () => _financialStatus = v ?? _financialStatus,
                          ),
                        ),
                        SizedBox(width: 190),

                        _buildDropdownField(
                          _incomeSource,
                          'Source of Income',
                          _incomeSourceOptions,
                          (v) => setState(
                            () => _incomeSource = v ?? _incomeSource,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      'Financial Contribution',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildTextField(
                          _ownAmountController,
                          'Own: Amount',
                          isNumeric: true,
                        ),

                        _buildTextField(
                          _qarzanAmountController,
                          'Qarzan Amount',
                        ),
                        _buildTextField(
                          _totalAmount,
                          'Total Mumin Contribution',
                          isNumeric: true,
                          readOnly: true,
                        ),
                        DropdownButton<String>(
                          value: _hassanaTerm,
                          items: const [
                            DropdownMenuItem(
                              value: 'Short-Term',
                              child: Text('Short-Term'),
                            ),
                            DropdownMenuItem(
                              value: 'Long-Term',
                              child: Text('Long-Term'),
                            ),
                          ],
                          onChanged: (v) => setState(() => _hassanaTerm = v!),
                        ),
                        _buildTextField(
                          _hassanaMonthsController,
                          'No of Months',
                          isNumeric: true,
                        ),
                        _buildTextField(
                          _jammatContributionController,
                          'Jammat Contribution',
                        ),
                        _buildDropdownField(
                          _financeExpectation,
                          'Finance as per expectation',
                          _financeExpectationOptions,
                          (v) => setState(
                            () =>
                                _financeExpectation = v ?? _financeExpectation,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _buildTextField(_formFillByController, 'Filled By Staff'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _remarksController,
                enabled: !_isReadOnly,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Remarks',
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: !_isReadOnly ? Colors.white : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),

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
                              ? const CircularProgressIndicator(strokeWidth: 2)
                              : const Text(
                                  'Save Local Draft',
                                  style: TextStyle(fontWeight: FontWeight.w600),
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
                                  style: TextStyle(fontWeight: FontWeight.w600),
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
                              ? const CircularProgressIndicator(strokeWidth: 2)
                              : const Text(
                                  'Delete Form',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
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
