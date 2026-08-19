import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:form_manager/Controller/provider_controller.dart';
import 'package:form_manager/Model/form_data_model.dart';
import 'package:form_manager/Model/person_model.dart';
import 'package:form_manager/Views/Forms/form3_view.dart' as form3;

const Map<String, int> financeDefaultPrices = {
  'dbBox': 1200,
  'nutBolts': 25,
  'clip1': 16,
  'insulationTape': 60,
  'acBreaker': 2100,
  'pipeLength34': 30,
  'wire7029': 180,
  'socket': 20,
  'dcBreaker': 2800,
  'pipeLength1': 45,
  'acWire4mm': 235,
  'changeOver': 3600,
  'screw': 350,
  'dcWire4mm': 235,
  'indicationLights': 100,
  'rawalPlug': 100,
  'wire4076': 100,
  'mc4Connector': 220,
  'flexiblePipe34': 25,
  'duct25x25': 350,
  'batteryWire': 1200,
  'flexiblePipe1': 35,
  'thimble': 60,
  'clip34': 12,
  'band': 35,
};

int financeDefaultPrice(String key) => financeDefaultPrices[key] ?? 1;

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
  bool _isDeleting = false;

  final _numberOfSolarPanelsController = TextEditingController(text: '2');
  final _numberOfInverterController = TextEditingController(text: '1');
  final _lithiumBatteryController = TextEditingController(text: '1');
  final _structureQuantityController = TextEditingController(text: '1');
  final _solarPanelAmountController = TextEditingController(text: '1');
  final _inverterAmountController = TextEditingController(text: '1');
  final _lithiumBatteryAmountController = TextEditingController(text: '1');
  final _structureAmountController = TextEditingController(text: '1');
  final _labourPriceController = TextEditingController(text: '1');
  final _ownContributionController = TextEditingController(text: '0');
  final _qarzanHasanaController = TextEditingController(text: '0');
  final _totalContributionController = TextEditingController(text: '0');

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

  double _parseMoneyInput(String? value) {
    if (value == null || value.trim().isEmpty) return 0;
    return double.tryParse(value.replaceAll(',', '').trim()) ?? 0;
  }

  String _formatMoneyValue(double value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  void _syncContributionTotal() {
    final own = _parseMoneyInput(_ownContributionController.text);
    final qarzan = _parseMoneyInput(_qarzanHasanaController.text);
    final total = own + qarzan;
    final nextTotal = _formatMoneyValue(total);
    if (_totalContributionController.text != nextTotal) {
      _totalContributionController.text = nextTotal;
    }
  }

  @override
  void initState() {
    super.initState();
    _ownContributionController.addListener(_syncContributionTotal);
    _qarzanHasanaController.addListener(_syncContributionTotal);
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
      _solarPanelAmountController.text =
          (financeAnswers['solarPanelAmount'] ?? 1).toString();
      _inverterAmountController.text = (financeAnswers['inverterAmount'] ?? 1)
          .toString();
      _lithiumBatteryAmountController.text =
          (financeAnswers['lithiumBatteryAmount'] ?? 1).toString();
      _structureAmountController.text = (financeAnswers['structureAmount'] ?? 1)
          .toString();
      _labourPriceController.text = (financeAnswers['labourPrice'] ?? 1)
          .toString();
      _ownContributionController.text = (financeAnswers['ownContribution'] ?? 0)
          .toString();
      _qarzanHasanaController.text = (financeAnswers['qarzanHasana'] ?? 0)
          .toString();
      _totalContributionController.text =
          (financeAnswers['totalContribution'] ?? 0).toString();

      final mats = (f3?.answers['materials'] ?? {}) as Map<String, dynamic>;
      _materials = Map<String, dynamic>.from(mats);

      final savedMaterialPrices = <String, dynamic>{};
      final savedMaterials = financeAnswers['materials'];
      if (savedMaterials is List) {
        for (final material in savedMaterials) {
          if (material is Map && material['key'] != null) {
            savedMaterialPrices[material['key'].toString()] =
                material['multiplier'];
          }
        }
      }

      for (var def in form3.buildMaterialFieldDefinitions()) {
        final key = def['key']!;
        _multControllers[key] = TextEditingController(
          text: (savedMaterialPrices[key] ?? financeDefaultPrice(key))
              .toString(),
        );
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
    _solarPanelAmountController.dispose();
    _inverterAmountController.dispose();
    _lithiumBatteryAmountController.dispose();
    _structureAmountController.dispose();
    _labourPriceController.dispose();
    _ownContributionController.dispose();
    _qarzanHasanaController.dispose();
    _totalContributionController.dispose();
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

  double _rowTotalFromQtyAndAmount(String qty, String amount) {
    final quantity = int.tryParse(qty.trim()) ?? 0;
    final unitAmount = _parseMoneyInput(amount);
    return quantity * unitAmount;
  }

  double _installationTotals() {
    return _rowTotalFromQtyAndAmount(
          _numberOfSolarPanelsController.text,
          _solarPanelAmountController.text,
        ) +
        _rowTotalFromQtyAndAmount(
          _numberOfInverterController.text,
          _inverterAmountController.text,
        ) +
        _rowTotalFromQtyAndAmount(
          _lithiumBatteryController.text,
          _lithiumBatteryAmountController.text,
        ) +
        _rowTotalFromQtyAndAmount(
          _structureQuantityController.text,
          _structureAmountController.text,
        ) +
        _parseMoneyInput(_labourPriceController.text);
  }

  double _getMaterialsTotal() {
    double total = 0;
    for (var def in form3.buildMaterialFieldDefinitions()) {
      total += _computedFor(def['key']!);
    }
    return total.toDouble();
  }

  int _totalComputed() {
    int total = 0;
    for (var def in form3.buildMaterialFieldDefinitions()) {
      total += _computedFor(def['key']!);
    }
    return total + _installationTotals().round();
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
      'solarPanelAmount': _parseMoneyInput(_solarPanelAmountController.text),
      'inverterAmount': _parseMoneyInput(_inverterAmountController.text),
      'lithiumBatteryAmount': _parseMoneyInput(
        _lithiumBatteryAmountController.text,
      ),
      'structureAmount': _parseMoneyInput(_structureAmountController.text),
      'labourPrice': _parseMoneyInput(_labourPriceController.text),
      'ownContribution': _parseMoneyInput(_ownContributionController.text),
      'qarzanHasana': _parseMoneyInput(_qarzanHasanaController.text),
      'totalContribution': _parseMoneyInput(_totalContributionController.text),
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
      'solarPanelAmount': _parseMoneyInput(_solarPanelAmountController.text),
      'inverterAmount': _parseMoneyInput(_inverterAmountController.text),
      'lithiumBatteryAmount': _parseMoneyInput(
        _lithiumBatteryAmountController.text,
      ),
      'structureAmount': _parseMoneyInput(_structureAmountController.text),
      'labourPrice': _parseMoneyInput(_labourPriceController.text),
      'ownContribution': _parseMoneyInput(_ownContributionController.text),
      'qarzanHasana': _parseMoneyInput(_qarzanHasanaController.text),
      'totalContribution': _parseMoneyInput(_totalContributionController.text),
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
      await provider.deleteSubmittedForm(widget.person.id, 5);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Finance form deleted successfully.')),
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
    final provider = Provider.of<AppProvider>(context);
    final isAllowed =
        (provider.currentUser?.isDev ?? false) ||
        (provider.currentUser?.isAdmin ?? false) ||
        (provider.currentUser?.isFinance ?? false);

    if (!isAllowed) {
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
                          controller: _ownContributionController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Own Contribution',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 180,
                        child: TextFormField(
                          controller: _qarzanHasanaController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Qarzan Hasana',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 180,
                        child: TextFormField(
                          controller: _totalContributionController,
                          keyboardType: TextInputType.number,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Total Contribution',
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
                  SizedBox(
                    width: 300,
                    child: DropdownButtonFormField<String>(
                      value: _selectedStructure,
                      decoration: const InputDecoration(
                        labelText: 'Structure Type',
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
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
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
                  // Material rows from form3
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
                  // Divider line
                  const SizedBox(height: 12),
                  Divider(height: 1, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  // Installation items as table rows
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 6,
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 4, child: const Text('Solar Panels')),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 40,
                            child: TextFormField(
                              controller: _numberOfSolarPanelsController,
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
                          child: SizedBox(
                            height: 40,
                            child: TextFormField(
                              controller: _solarPanelAmountController,
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
                              "Rs. ${_rowTotalFromQtyAndAmount(_numberOfSolarPanelsController.text, _solarPanelAmountController.text).toInt().toString()}",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 6,
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 4, child: const Text('Inverter')),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 40,
                            child: TextFormField(
                              controller: _numberOfInverterController,
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
                          child: SizedBox(
                            height: 40,
                            child: TextFormField(
                              controller: _inverterAmountController,
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
                              "Rs. ${_rowTotalFromQtyAndAmount(_numberOfInverterController.text, _inverterAmountController.text).toInt().toString()}",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 6,
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 4, child: const Text('Lithium Battery')),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 40,
                            child: TextFormField(
                              controller: _lithiumBatteryController,
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
                          child: SizedBox(
                            height: 40,
                            child: TextFormField(
                              controller: _lithiumBatteryAmountController,
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
                              "Rs. ${_rowTotalFromQtyAndAmount(_lithiumBatteryController.text, _lithiumBatteryAmountController.text).toInt().toString()}",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 6,
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 4, child: const Text('Structure')),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 40,
                            child: TextFormField(
                              controller: _structureQuantityController,
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
                          child: SizedBox(
                            height: 40,
                            child: TextFormField(
                              controller: _structureAmountController,
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
                              "Rs. ${_rowTotalFromQtyAndAmount(_structureQuantityController.text, _structureAmountController.text).toInt().toString()}",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 6,
                    ),
                    child: Row(
                      children: [
                        const Expanded(flex: 4, child: Text('Labour')),
                        const Expanded(flex: 2, child: Text('-')),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 40,
                            child: TextFormField(
                              controller: _labourPriceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Price',
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
                              'Rs. ${_parseMoneyInput(_labourPriceController.text).toInt()}',
                            ),
                          ),
                        ),
                      ],
                    ),
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
                    'Finance Summary',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  // Materials subtotal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Materials Total:'),
                      Text(
                        'Rs. ${_getMaterialsTotal().toInt().toString()}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Installation items subtotal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Installation Items Total:'),
                      Text(
                        'Rs. ${_installationTotals().toInt().toString()}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(height: 1, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  // Grand total
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
    );
  }
}
