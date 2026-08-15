import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:form_manager/Controller/provider_controller.dart';
import 'package:form_manager/Model/form_data_model.dart';
import 'package:form_manager/Model/person_model.dart';
import 'package:form_manager/Views/Forms/form3_view.dart' as form3;

class FormFinanceView extends StatefulWidget {
  final PersonModel person;

  const FormFinanceView({super.key, required this.person});

  @override
  State<FormFinanceView> createState() => _FormFinanceViewState();
}

class _FormFinanceViewState extends State<FormFinanceView> {
  bool _isLoading = true;
  bool _isSavingDraft = false;
  bool _isSubmitting = false;

  final _numberOfSolarPanelsController = TextEditingController(text: '2');
  final _numberOfInverterController = TextEditingController(text: '1');
  final _lithiumBatteryController = TextEditingController(text: '1');
  final _structureQuantityController = TextEditingController(text: '1');

  // Form1 fields
  String _landlordApproval = '';
  String _solarWillingness = '';

  // Form2 fields
  String _financeByMumin = '';
  String _financeExpectation = '';

  String? _selectedStructure = 'elevated';

  // Form3 materials
  Map<String, dynamic> _materials = {};
  final Map<String, TextEditingController> _multControllers = {};

  @override
  void initState() {
    super.initState();
    _loadAllForms();
  }

  Future<void> _loadAllForms() async {
    final provider = Provider.of<AppProvider>(context, listen: false);

    final f1 = await provider.getSubmittedForm(widget.person.id, 1);
    final f2 = await provider.getSubmittedForm(widget.person.id, 2);
    final f3 = await provider.getSubmittedForm(widget.person.id, 3);
    final financeDraft = provider.loadDraft(widget.person.id, 5);
    final financeSaved =
        financeDraft ?? await provider.getSubmittedForm(widget.person.id, 5);

    setState(() {
      _landlordApproval = (f1?.answers['landlordApproval'] ?? '').toString();
      _solarWillingness = (f1?.answers['solarWillingness'] ?? '').toString();

      _financeByMumin = (f2?.answers['financeByMumin'] ?? '').toString();
      _financeExpectation = (f2?.answers['financeExpectation'] ?? '')
          .toString();

      final financeAnswers = financeSaved?.answers ?? {};
      _numberOfSolarPanelsController.text =
          (financeAnswers['numberOfSolarPanels'] ?? 2).toString();
      _numberOfInverterController.text =
          (financeAnswers['numberOfInverter'] ?? 1).toString();
      _lithiumBatteryController.text = (financeAnswers['lithiumBattery'] ?? 1)
          .toString();
      _selectedStructure = (financeAnswers['structure'] ?? 'elevated')
          .toString();
      _structureQuantityController.text =
          (financeAnswers['structureQuantity'] ?? 1).toString();

      final mats = (f3?.answers['materials'] ?? {}) as Map<String, dynamic>;
      _materials = Map<String, dynamic>.from(mats);

      // initialize multiplier controllers
      for (var def in form3.buildMaterialFieldDefinitions()) {
        final key = def['key']!;
        _multControllers[key] = TextEditingController(text: '1');
      }

      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _numberOfSolarPanelsController.dispose();
    _numberOfInverterController.dispose();
    _lithiumBatteryController.dispose();
    _structureQuantityController.dispose();
    for (var c in _multControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  int _computedFor(String key) {
    final orig = int.tryParse((_materials[key] ?? '0').toString()) ?? 0;
    final mult = int.tryParse(_multControllers[key]?.text.trim() ?? '0') ?? 0;
    return orig * mult;
  }

  int _totalComputed() {
    int total = 0;
    for (var def in form3.buildMaterialFieldDefinitions()) {
      total += _computedFor(def['key']!);
    }
    return total;
  }

  double _calculateCompletionRatio() {
    final defs = form3.buildMaterialFieldDefinitions();
    final totalFields = 9 + defs.length;
    int filled = 0;
    if (_landlordApproval.isNotEmpty) filled++;
    if (_solarWillingness.isNotEmpty) filled++;
    if (_financeByMumin.isNotEmpty) filled++;
    if (_financeExpectation.isNotEmpty) filled++;
    if (_numberOfSolarPanelsController.text.trim().isNotEmpty) filled++;
    if (_numberOfInverterController.text.trim().isNotEmpty) filled++;
    if (_lithiumBatteryController.text.trim().isNotEmpty) filled++;
    if (_selectedStructure != null && _selectedStructure!.isNotEmpty) filled++;
    if (_structureQuantityController.text.trim().isNotEmpty) filled++;
    for (var def in defs) {
      final key = def['key']!;
      final mult = _multControllers[key]?.text.trim() ?? '';
      if (mult.isNotEmpty) filled++;
    }
    if (totalFields == 0) return 0.0;
    return (filled / totalFields).clamp(0.0, 1.0);
  }

  Future<void> _handleSaveDraft() async {
    setState(() => _isSavingDraft = true);
    final provider = Provider.of<AppProvider>(context, listen: false);

    final materialsWithMultipliers = <Map<String, dynamic>>[];
    for (var def in form3.buildMaterialFieldDefinitions()) {
      final key = def['key']!;
      materialsWithMultipliers.add({
        'key': key,
        'label': def['label'],
        'original': _materials[key] ?? '0',
        'multiplier': _multControllers[key]?.text ?? '1',
        'computed': _computedFor(key),
      });
    }

    final answers = {
      'landlordApproval': _landlordApproval,
      'solarWillingness': _solarWillingness,
      'financeByMumin': _financeByMumin,
      'financeExpectation': _financeExpectation,
      'numberOfSolarPanels':
          int.tryParse(_numberOfSolarPanelsController.text.trim()) ?? 2,
      'numberOfInverter':
          int.tryParse(_numberOfInverterController.text.trim()) ?? 1,
      'lithiumBattery':
          int.tryParse(_lithiumBatteryController.text.trim()) ?? 1,
      'structure': _selectedStructure ?? 'elevated',
      'structureQuantity':
          int.tryParse(_structureQuantityController.text.trim()) ?? 1,
      'materials': materialsWithMultipliers,
      'summaryTotal': _totalComputed(),
    };

    final draft = FormDataModel(
      id: 'finance_${widget.person.id}',
      personId: widget.person.id,
      formNumber: 5,
      filledByStaffId: provider.currentUser?.uid ?? '',
      isDraft: true,
      updatedAt: DateTime.now(),
      answers: answers,
    );

    await provider.saveDraft(draft);
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() => _isSavingDraft = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Finance draft saved')));
    }
  }

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);
    final provider = Provider.of<AppProvider>(context, listen: false);

    final materialsWithMultipliers = <Map<String, dynamic>>[];
    for (var def in form3.buildMaterialFieldDefinitions()) {
      final key = def['key']!;
      materialsWithMultipliers.add({
        'key': key,
        'label': def['label'],
        'original': _materials[key] ?? '0',
        'multiplier': _multControllers[key]?.text ?? '1',
        'computed': _computedFor(key),
      });
    }

    final answers = {
      'landlordApproval': _landlordApproval,
      'solarWillingness': _solarWillingness,
      'financeByMumin': _financeByMumin,
      'financeExpectation': _financeExpectation,
      'numberOfSolarPanels':
          int.tryParse(_numberOfSolarPanelsController.text.trim()) ?? 2,
      'numberOfInverter':
          int.tryParse(_numberOfInverterController.text.trim()) ?? 1,
      'lithiumBattery':
          int.tryParse(_lithiumBatteryController.text.trim()) ?? 1,
      'structure': _selectedStructure ?? 'elevated',
      'structureQuantity':
          int.tryParse(_structureQuantityController.text.trim()) ?? 1,
      'materials': materialsWithMultipliers,
      'summaryTotal': _totalComputed(),
    };

    final submission = FormDataModel(
      id: 'finance_${widget.person.id}',
      personId: widget.person.id,
      formNumber: 5,
      filledByStaffId: provider.currentUser?.uid ?? '',
      isDraft: false,
      updatedAt: DateTime.now(),
      answers: answers,
    );

    try {
      await provider.submitFormToFirebase(submission);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Finance submission saved')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Submit failed: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isFinance = provider.currentUser?.isFinance ?? false;

    if (!isFinance) {
      return Scaffold(
        appBar: AppBar(title: const Text('Finance Form')),
        body: const Center(
          child: Text('Access denied. Finance account required.'),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Finance Form')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        title: Text('${widget.person.name} - Finance'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Finance Form',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.person.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Landlord Approval: $_landlordApproval'),
                            Text('Willing to Solar: $_solarWillingness'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Finance Details',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Text('Finance By Mumin: $_financeByMumin'),
                            Text('Finance Expectation: $_financeExpectation'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
                  const Text(
                    'Solar Installation Details',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: 180,
                        child: TextFormField(
                          controller: _numberOfSolarPanelsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Number of solar panels',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 180,
                        child: TextFormField(
                          controller: _numberOfInverterController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Number of inverter',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 180,
                        child: TextFormField(
                          controller: _lithiumBatteryController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Lithium Battery',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedStructure,
                          decoration: const InputDecoration(
                            labelText: 'Structure',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'elevated',
                              child: Text('Elevated'),
                            ),
                            DropdownMenuItem(
                              value: 'floormount',
                              child: Text('Floormount'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedStructure = value ?? 'elevated';
                              if (_structureQuantityController.text
                                  .trim()
                                  .isEmpty) {
                                _structureQuantityController.text = '1';
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (_selectedStructure != null)
                        Expanded(
                          child: TextFormField(
                            controller: _structureQuantityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Structure quantity',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

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
                  const Text(
                    'Bill of Materials',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  // Table header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 6,
                    ),
                    color: Colors.grey.shade50,
                    child: Row(
                      children: const [
                        Expanded(
                          flex: 4,
                          child: Text(
                            'Item',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Quantity',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Amount',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Text(
                              'Total',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...form3.buildMaterialFieldDefinitions().map((def) {
                    final key = def['key']!;
                    final orig = _materials[key] ?? '0';
                    final controller = _multControllers[key]!;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 6,
                      ),
                      decoration: const BoxDecoration(),
                      child: Row(
                        children: [
                          Expanded(flex: 4, child: Text(def['label'] ?? key)),
                          Expanded(flex: 2, child: Text(orig.toString())),
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 40,
                              child: TextFormField(
                                controller: controller,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: Text(
                                "Rs. ${_computedFor(key).toString()}",
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

            const SizedBox(height: 16),
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
                  const Text(
                    'Finance Summary',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text(
                        'Total Computed Amount:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Rs. ${_totalComputed().toString()}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            const SizedBox(height: 16),
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
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Save Draft',
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
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Submit',
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
    );
  }
}
