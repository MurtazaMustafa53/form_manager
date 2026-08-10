import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:form_manager/Controller/provider_controller.dart';
import 'package:form_manager/Model/form_data_model.dart';
import 'package:form_manager/Model/person_model.dart';

List<Map<String, dynamic>> buildDefaultAppliances() {
  return [
    {'name': 'Fan', 'watts': 80},
    {'name': 'AC/DC Fan', 'watts': 30},
    {'name': 'Tube Light', 'watts': 40},
    {'name': 'LED Bulb', 'watts': 12},
    {'name': 'Wifi Router', 'watts': 10},
    {'name': 'AC 1-Ton-Inverter', 'watts': 1200},
    {'name': 'AC 1.5-Ton-Inverter', 'watts': 1800},
    {'name': 'AC 2-Ton-Inverter', 'watts': 2400},
    {'name': 'Fridge Normal', 'watts': 300},
    {'name': 'Fridge Inverter', 'watts': 150},
    {'name': 'Deep Freezer Normal', 'watts': 350},
    {'name': 'Deep Freezer Inverter', 'watts': 200},
    {'name': 'Dispenser', 'watts': 150},
    {'name': 'Water Pump (1/2 HP)', 'watts': 400},
    {'name': 'Water Pump (1 HP)', 'watts': 750},
    {'name': 'Boring Pump', 'watts': 1000},
    {'name': 'Washing Machine', 'watts': 500},
    {'name': 'Iron', 'watts': 1000},
    {'name': 'Microwave', 'watts': 1200},
    {'name': 'TV', 'watts': 100},
  ];
}

class Form2View extends StatefulWidget {
  final PersonModel person;
  final bool readOnly;

  const Form2View({Key? key, required this.person, this.readOnly = false})
    : super(key: key);

  @override
  State<Form2View> createState() => _Form2ViewState();
}

class _Form2ViewState extends State<Form2View> {
  final _formKey = GlobalKey<FormState>();

  // Section 3 Controllers
  final _kwInstalledController = TextEditingController();
  final _panelsWattageController = TextEditingController();
  final _inverterCapacityController = TextEditingController();
  final _batteryTypeController = TextEditingController();
  final _normalUpsInstalledController = TextEditingController();
  final _existingInverterController = TextEditingController();
  final _existingBatteryController = TextEditingController();
  final _financeByMuminController = TextEditingController();
  final _filledByStaffController = TextEditingController();
  final _landlordNameController = TextEditingController();
  final _landlordContactController = TextEditingController();
  final _remarksController = TextEditingController();

  String? _selectedFinanceExpectation;
  String? _selectedAlternativeBackup;
  bool _showSolarSpecificFields = false;

  bool _isSavingDraft = false;
  bool _isSubmitting = false;
  bool _isReadOnly = false;

  // Updated options to only Yes and No
  final List<String> _financeExpectationOptions = ['Yes', 'No'];
  final List<String> _alternativeBackupOptions = [
    'None',
    'UPS',
    'SOLAR SYSTEM',
  ];

  // Appliances initialized with Watts, Controllers for Watts & Qty
  late List<Map<String, dynamic>> _appliances;

  @override
  void initState() {
    super.initState();
    _initAppliances();
    _isReadOnly =
        widget.readOnly ||
        Provider.of<AppProvider>(context, listen: false).isViewer;
    _loadInitialData();
  }

  void _initAppliances() {
    final defaultData = buildDefaultAppliances();

    _appliances = defaultData.map((item) {
      return {
        'name': item['name'],
        'wattsController': TextEditingController(
          text: item['watts'].toString(),
        ),
        'qtyController': TextEditingController(text: '0'),
      };
    }).toList();
  }

  Future<void> _loadInitialData() async {
    final provider = Provider.of<AppProvider>(context, listen: false);

    FormDataModel? form1Data = provider.loadDraft(widget.person.id, 1);
    form1Data ??= await provider.getSubmittedForm(widget.person.id, 1);

    final solarSelection = (form1Data?.answers['solarWillingness'] ?? '')
        .toString()
        .trim()
        .toLowerCase();

    final bool showSolarSpecificFields = solarSelection == 'already installed';

    FormDataModel? draft = provider.loadDraft(widget.person.id, 2);
    draft ??= await provider.getSubmittedForm(widget.person.id, 2);

    if (mounted) {
      setState(() {
        _showSolarSpecificFields = showSolarSpecificFields;

        if (draft != null) {
          final ans = draft.answers;
          _kwInstalledController.text = ans['kwInstalled'] ?? '';
          _panelsWattageController.text = ans['panelsWattage'] ?? '';
          _inverterCapacityController.text = ans['inverterCapacity'] ?? '';
          _batteryTypeController.text = ans['batteryType'] ?? '';
          _normalUpsInstalledController.text = ans['normalUpsInstalled'] ?? '';
          _existingInverterController.text = ans['existingInverter'] ?? '';
          _existingBatteryController.text = ans['existingBattery'] ?? '';
          _financeByMuminController.text = ans['financeByMumin'] ?? '';
          _selectedFinanceExpectation = ans['financeExpectation'];
          _selectedAlternativeBackup = ans['alternativeBackup'];
          _filledByStaffController.text = ans['filledByStaff'] ?? '';
          _landlordNameController.text = ans['landlordName'] ?? '';
          _landlordContactController.text = ans['landlordContact'] ?? '';
          _remarksController.text = ans['remarks'] ?? '';

          if (ans['appliances'] != null) {
            final List savedList = ans['appliances'];
            for (var item in savedList) {
              final index = _appliances.indexWhere(
                (a) => a['name'] == item['name'],
              );
              if (index != -1) {
                _appliances[index]['wattsController'].text =
                    (item['watts'] ?? 0).toString();
                _appliances[index]['qtyController'].text = (item['qty'] ?? 0)
                    .toString();
              }
            }
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _kwInstalledController.dispose();
    _panelsWattageController.dispose();
    _inverterCapacityController.dispose();
    _batteryTypeController.dispose();
    _normalUpsInstalledController.dispose();
    _existingInverterController.dispose();
    _existingBatteryController.dispose();
    _financeByMuminController.dispose();
    _filledByStaffController.dispose();
    _landlordNameController.dispose();
    _landlordContactController.dispose();
    _remarksController.dispose();

    for (var app in _appliances) {
      (app['wattsController'] as TextEditingController).dispose();
      (app['qtyController'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  int _calculateTotalWatts() {
    int total = 0;
    for (var app in _appliances) {
      final watts =
          int.tryParse(
            (app['wattsController'] as TextEditingController).text.trim(),
          ) ??
          0;
      final qty =
          int.tryParse(
            (app['qtyController'] as TextEditingController).text.trim(),
          ) ??
          0;
      total += (watts * qty);
    }
    return total;
  }

  double _calculateCompletionRatio() {
    int filledCount = 0;
    int trackedFields = 6;

    if (_showSolarSpecificFields) {
      trackedFields += 7;
      if (_kwInstalledController.text.trim().isNotEmpty) filledCount++;
      if (_panelsWattageController.text.trim().isNotEmpty) filledCount++;
      if (_inverterCapacityController.text.trim().isNotEmpty) filledCount++;
      if (_batteryTypeController.text.trim().isNotEmpty) filledCount++;
      if (_normalUpsInstalledController.text.trim().isNotEmpty) filledCount++;
      if (_existingInverterController.text.trim().isNotEmpty) filledCount++;
      if (_existingBatteryController.text.trim().isNotEmpty) filledCount++;
    }

    if (_financeByMuminController.text.trim().isNotEmpty) filledCount++;
    if (_selectedFinanceExpectation != null) filledCount++;
    if (_selectedAlternativeBackup != null) filledCount++;
    if (_filledByStaffController.text.trim().isNotEmpty) filledCount++;
    if (_landlordNameController.text.trim().isNotEmpty) filledCount++;
    if (_landlordContactController.text.trim().isNotEmpty) filledCount++;

    return trackedFields == 0 ? 0 : filledCount / trackedFields;
  }

  Map<String, dynamic> _collectAnswers() {
    final applianceData = _appliances.map((app) {
      return {
        'name': app['name'],
        'watts':
            int.tryParse(
              (app['wattsController'] as TextEditingController).text.trim(),
            ) ??
            0,
        'qty':
            int.tryParse(
              (app['qtyController'] as TextEditingController).text.trim(),
            ) ??
            0,
      };
    }).toList();

    return {
      'appliances': applianceData,
      'totalWatts': _calculateTotalWatts(),
      'kwInstalled': _kwInstalledController.text.trim(),
      'panelsWattage': _panelsWattageController.text.trim(),
      'inverterCapacity': _inverterCapacityController.text.trim(),
      'batteryType': _batteryTypeController.text.trim(),
      'normalUpsInstalled': _normalUpsInstalledController.text.trim(),
      'existingInverter': _existingInverterController.text.trim(),
      'existingBattery': _existingBatteryController.text.trim(),
      'financeByMumin': _financeByMuminController.text.trim(),
      'financeExpectation': _selectedFinanceExpectation ?? '',
      'alternativeBackup': _selectedAlternativeBackup ?? '',
      'filledByStaff': _filledByStaffController.text.trim(),
      'landlordName': _landlordNameController.text.trim(),
      'landlordContact': _landlordContactController.text.trim(),
      'remarks': _remarksController.text.trim(),
      'completionRatio': _calculateCompletionRatio(),
    };
  }

  Future<void> _handleSaveDraft() async {
    setState(() => _isSavingDraft = true);
    final provider = Provider.of<AppProvider>(context, listen: false);

    final draftData = FormDataModel(
      id: '${widget.person.id}_form_2',
      personId: widget.person.id,
      formNumber: 2,
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
        const SnackBar(content: Text('Form 2 local draft saved successfully.')),
      );
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final provider = Provider.of<AppProvider>(context, listen: false);
    final formData = FormDataModel(
      id: '${widget.person.id}_form_2',
      personId: widget.person.id,
      formNumber: 2,
      filledByStaffId: provider.currentUser?.uid ?? '',
      isDraft: false,
      updatedAt: DateTime.now(),
      answers: _collectAnswers(),
    );

    try {
      await provider.submitFormToFirebase(formData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form 2 submitted successfully.')),
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumeric = false,
  }) {
    return SizedBox(
      width: 260,
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        enabled: !_isReadOnly,
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
        value: value,
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
    final totalWatts = _calculateTotalWatts();
    final double completionRatio = _calculateCompletionRatio();
    final int completionPercentage = (completionRatio * 100).toInt();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        title: Text('${widget.person.name} - Form 2 (Appliances & Solar)'),
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
                          'Form 2: Electrical Load & Existing Solar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Calculated Total Watts: $totalWatts W',
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

              // Section 2 Header
              _buildSectionHeader('2. Electrical Appliances Load'),
              const SizedBox(height: 12),

              // Electrical Appliances Table Container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Table Header Row
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Appliance',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Watts',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Qty',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Total (W)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    // Appliances Rows
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _appliances.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final app = _appliances[index];
                        final wattsCtrl =
                            app['wattsController'] as TextEditingController;
                        final qtyCtrl =
                            app['qtyController'] as TextEditingController;

                        final wattsVal = int.tryParse(wattsCtrl.text) ?? 0;
                        final qtyVal = int.tryParse(qtyCtrl.text) ?? 0;
                        final itemTotal = wattsVal * qtyVal;

                        return Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                app['name'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: SizedBox(
                                  height: 40,
                                  child: TextFormField(
                                    controller: wattsCtrl,
                                    keyboardType: TextInputType.number,
                                    enabled: !_isReadOnly,
                                    onChanged: (_) => setState(() {}),
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                      filled: true,
                                      fillColor: !_isReadOnly
                                          ? Colors.white
                                          : Colors.grey.shade100,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: SizedBox(
                                  height: 40,
                                  child: TextFormField(
                                    controller: qtyCtrl,
                                    keyboardType: TextInputType.number,
                                    enabled: !_isReadOnly,
                                    onChanged: (_) => setState(() {}),
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                      filled: true,
                                      fillColor: !_isReadOnly
                                          ? Colors.white
                                          : Colors.grey.shade100,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                '$itemTotal W',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2563EB),
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
              const SizedBox(height: 24),

              // Section 3 Header
              _buildSectionHeader(
                '3. Existing Solar / Backup System & Finance',
              ),
              const SizedBox(height: 16),

              // Inputs Grid
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  if (_showSolarSpecificFields) ...[
                    _buildTextField(_kwInstalledController, 'KW Installed'),
                    _buildTextField(_panelsWattageController, 'Panels Wattage'),
                    _buildTextField(
                      _inverterCapacityController,
                      'Inverter Capacity',
                    ),
                    _buildTextField(_batteryTypeController, 'Battery Type'),
                    _buildTextField(
                      _normalUpsInstalledController,
                      'Normal UPS Installed',
                    ),
                    _buildTextField(
                      _existingInverterController,
                      'Existing Inverter',
                    ),
                    _buildTextField(
                      _existingBatteryController,
                      'Existing Battery',
                    ),
                  ],
                  _buildDropdownField(
                    _selectedAlternativeBackup,
                    'Alternative Backup',
                    _alternativeBackupOptions,
                    (val) => setState(() => _selectedAlternativeBackup = val),
                  ),
                  _buildTextField(
                    _financeByMuminController,
                    'Finance by Mumin',
                  ),
                  _buildDropdownField(
                    _selectedFinanceExpectation,
                    'Finance as per expectation',
                    _financeExpectationOptions,
                    (val) => setState(() => _selectedFinanceExpectation = val),
                  ),
                  _buildTextField(
                    _filledByStaffController,
                    'Filled By Staff Name',
                  ),
                  _buildTextField(_landlordNameController, 'Landlord Name'),
                  _buildTextField(
                    _landlordContactController,
                    'Landlord Contact',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Remarks Full Width Box
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
              const SizedBox(height: 32),

              // Action Buttons
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
