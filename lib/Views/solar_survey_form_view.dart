import 'package:flutter/material.dart';
import 'package:form_manager/Controller/provider_controller.dart';
import 'package:form_manager/Model/form_data_model.dart';
import 'package:form_manager/Model/person_model.dart';
import 'package:provider/provider.dart';

class SolarSurveyFormView extends StatefulWidget {
  final PersonModel person;
  final int formNumber;

  const SolarSurveyFormView({
    super.key,
    required this.person,
    this.formNumber = 1,
  });

  @override
  State<SolarSurveyFormView> createState() => _SolarSurveyFormViewState();
}

class _SolarSurveyFormViewState extends State<SolarSurveyFormView> {
  final _formKey = GlobalKey<FormState>();

  // General & Personal Controllers (For Form 1)
  late TextEditingController _sfController;
  late TextEditingController _nameController;
  late TextEditingController _itsController;
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _dateController = TextEditingController();

  // House Type & Landlord Details
  String? _selectedHouseType;
  final List<String> _houseTypeOptions = ['Ownership', 'Rent', 'Goodwill'];
  final _landlordNameController = TextEditingController();
  final _landlordContactController = TextEditingController();
  final _noOfPersonsController = TextEditingController();

  // Room Type & Survey Dropdowns
  String? _selectedRoomType;
  final List<String> _roomTypeOptions = [
    '2-Bed Lounge',
    '3-Bed Lounge',
    '2-Bed D/D',
    '3-Bed D/D',
  ];

  String? _selectedSolarWillingness;
  final List<String> _solarWillingnessOptions = [
    'Yes',
    'No',
    'Already Installed',
  ];

  String? _selectedLandlordApproval;
  final List<String> _landlordApprovalOptions = ['Maybe', 'Yes', 'No'];

  // System & Survey Details (For Form 2)
  final _kwInstalledController = TextEditingController();
  final _panelsWattageController = TextEditingController();
  final _inverterCapacityController = TextEditingController();
  final _batteryTypeController = TextEditingController();
  final _normalUpsController = TextEditingController();
  final _existingInverterController = TextEditingController();
  final _existingBatteryController = TextEditingController();

  // Finance Details
  final _financeByMuminController = TextEditingController();
  String? _selectedFinanceExpectation;
  final List<String> _financeExpectationOptions = ['Yes', 'No'];

  final _remarksController = TextEditingController();
  final _filledByController = TextEditingController();

  final Map<String, int> _applianceWatts = {
    'Fan': 80,
    'LED Bulb': 12,
    'AC 1-Ton-Inverter': 1200,
    'AC 1.5-Ton-Inverter': 1800,
    'AC 2-Ton-Inverter': 2400,
    'Fridge Normal': 300,
    'Fridge Inverter': 150,
    'Deep Freezer Normal': 350,
    'Deep Freezer Inverter': 200,
    'Water Pump (1/2 HP)': 400,
    'Water Pump (1 HP)': 750,
    'Washing Machine': 500,
    'Iron': 1000,
    'Microwave': 1200,
    'TV': 100,
  };

  final Map<String, TextEditingController> _qtyControllers = {};
  final Map<String, TextEditingController> _wattControllers = {};

  bool _isLoading = false;
  double _completionRatio = 0.0;
  int _totalWatts = 0;

  @override
  void initState() {
    super.initState();
    _sfController = TextEditingController(text: widget.person.sfNo.toString());
    _nameController = TextEditingController(text: widget.person.name);
    _itsController = TextEditingController(text: widget.person.its.toString());
    _dateController.text = DateTime.now().toString().split(' ')[0];

    for (var key in _applianceWatts.keys) {
      _qtyControllers[key] = TextEditingController(text: '0');
      _qtyControllers[key]!.addListener(_calculateTotalWatts);

      _wattControllers[key] = TextEditingController(
        text: _applianceWatts[key].toString(),
      );
      _wattControllers[key]!.addListener(_calculateTotalWatts);
    }

    _sfController.addListener(_calculateCompletionRatio);
    _nameController.addListener(_calculateCompletionRatio);
    _itsController.addListener(_calculateCompletionRatio);
    _addressController.addListener(_calculateCompletionRatio);
    _contactController.addListener(_calculateCompletionRatio);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFormData();
    });
  }

  @override
  void dispose() {
    _sfController.dispose();
    _nameController.dispose();
    _itsController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _dateController.dispose();
    _landlordNameController.dispose();
    _landlordContactController.dispose();
    _noOfPersonsController.dispose();
    _kwInstalledController.dispose();
    _panelsWattageController.dispose();
    _inverterCapacityController.dispose();
    _batteryTypeController.dispose();
    _normalUpsController.dispose();
    _existingInverterController.dispose();
    _existingBatteryController.dispose();
    _financeByMuminController.dispose();
    _remarksController.dispose();
    _filledByController.dispose();
    for (var controller in _qtyControllers.values) {
      controller.dispose();
    }
    for (var controller in _wattControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadFormData() async {
    final provider = Provider.of<AppProvider>(context, listen: false);

    if (widget.formNumber == 2) {
      final formOneData = await provider.getSubmittedForm(widget.person.id, 1);
      if (formOneData != null) {
        _populateFieldsFromMap(formOneData.answers);
      }
    }

    final submittedForm = await provider.getSubmittedForm(
      widget.person.id,
      widget.formNumber,
    );

    if (submittedForm != null) {
      _populateFieldsFromMap(submittedForm.answers);
      return;
    }

    final draft = provider.loadDraft(widget.person.id, widget.formNumber);
    if (draft != null) {
      _populateFieldsFromMap(draft.answers);
    }
  }

  void _populateFieldsFromMap(Map<String, dynamic> ans) {
    setState(() {
      _sfController.text = ans['sfNo']?.toString() ?? _sfController.text;
      _nameController.text = ans['name']?.toString() ?? _nameController.text;
      _itsController.text = ans['its']?.toString() ?? _itsController.text;
      _addressController.text = ans['address'] ?? _addressController.text;
      _contactController.text = ans['contact'] ?? _contactController.text;
      _dateController.text = ans['date'] ?? _dateController.text;

      final loadedHouseType = ans['houseType']?.toString();
      if (_houseTypeOptions.contains(loadedHouseType)) {
        _selectedHouseType = loadedHouseType;
      }

      _landlordNameController.text = ans['landlordName'] ?? '';
      _landlordContactController.text = ans['landlordContact'] ?? '';
      _noOfPersonsController.text = ans['noOfPersons']?.toString() ?? '';

      final loadedRoom = ans['rooms']?.toString();
      if (_roomTypeOptions.contains(loadedRoom)) {
        _selectedRoomType = loadedRoom;
      }

      final loadedSolarWillingness = ans['solarWillingness']?.toString();
      if (_solarWillingnessOptions.contains(loadedSolarWillingness)) {
        _selectedSolarWillingness = loadedSolarWillingness;
      }

      final loadedLandlordApproval = ans['landlordApproval']?.toString();
      if (_landlordApprovalOptions.contains(loadedLandlordApproval)) {
        _selectedLandlordApproval = loadedLandlordApproval;
      }

      _kwInstalledController.text = ans['kwInstalled'] ?? '';
      _panelsWattageController.text = ans['panelsWattage'] ?? '';
      _inverterCapacityController.text = ans['inverterCapacity'] ?? '';
      _batteryTypeController.text = ans['batteryType'] ?? '';
      _normalUpsController.text = ans['normalUpsInstalled'] ?? '';
      _existingInverterController.text = ans['existingInverter'] ?? '';
      _existingBatteryController.text = ans['existingBattery'] ?? '';

      _financeByMuminController.text = ans['financeByMumin'] ?? '';
      final loadedFinanceExp = ans['financeExpectation']?.toString();
      if (_financeExpectationOptions.contains(loadedFinanceExp)) {
        _selectedFinanceExpectation = loadedFinanceExp;
      }

      _remarksController.text = ans['remarks'] ?? '';
      _filledByController.text = ans['filledBy'] ?? '';

      for (var item in _applianceWatts.keys) {
        if (ans.containsKey('qty_$item')) {
          _qtyControllers[item]?.text = ans['qty_$item'].toString();
        }
        if (ans.containsKey('watt_$item')) {
          _wattControllers[item]?.text = ans['watt_$item'].toString();
        }
      }
    });
    _calculateTotalWatts();
    _calculateCompletionRatio();
  }

  void _calculateTotalWatts() {
    int watts = 0;
    _applianceWatts.keys.forEach((key) {
      final qty = int.tryParse(_qtyControllers[key]?.text ?? '0') ?? 0;
      final unitWatt = int.tryParse(_wattControllers[key]?.text ?? '0') ?? 0;
      watts += qty * unitWatt;
    });
    setState(() => _totalWatts = watts);
  }

  void _calculateCompletionRatio() {
    int totalFields = 5;
    int filledFields = 0;

    if (_nameController.text.trim().isNotEmpty) filledFields++;
    if (_itsController.text.trim().isNotEmpty) filledFields++;
    if (_sfController.text.trim().isNotEmpty) filledFields++;
    if (_contactController.text.trim().isNotEmpty) filledFields++;
    if (_addressController.text.trim().isNotEmpty) filledFields++;

    setState(() {
      _completionRatio = (filledFields / totalFields).clamp(0.0, 1.0);
    });
  }

  Map<String, dynamic> _buildAnswersMap() {
    final Map<String, dynamic> map = {
      'sfNo': _sfController.text,
      'name': _nameController.text,
      'its': _itsController.text,
      'address': _addressController.text,
      'contact': _contactController.text,
      'date': _dateController.text,
      'houseType': _selectedHouseType ?? '',
      'landlordName': _landlordNameController.text,
      'landlordContact': _landlordContactController.text,
      'noOfPersons': _noOfPersonsController.text,
      'rooms': _selectedRoomType ?? '',
      'solarWillingness': _selectedSolarWillingness ?? '',
      'landlordApproval': _selectedLandlordApproval ?? '',
      'kwInstalled': _kwInstalledController.text,
      'panelsWattage': _panelsWattageController.text,
      'inverterCapacity': _inverterCapacityController.text,
      'batteryType': _batteryTypeController.text,
      'normalUpsInstalled': _normalUpsController.text,
      'existingInverter': _existingInverterController.text,
      'existingBattery': _existingBatteryController.text,
      'financeByMumin': _financeByMuminController.text,
      'financeExpectation': _selectedFinanceExpectation ?? '',
      'remarks': _remarksController.text,
      'filledBy': _filledByController.text,
      'totalWatts': _totalWatts,
      'completionRatio': _completionRatio,
    };

    _applianceWatts.keys.forEach((key) {
      map['qty_$key'] = int.tryParse(_qtyControllers[key]?.text ?? '0') ?? 0;
      map['watt_$key'] = int.tryParse(_wattControllers[key]?.text ?? '0') ?? 0;
    });

    return map;
  }

  void _saveDraft() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final formData = FormDataModel(
      id: '${widget.person.id}_form_${widget.formNumber}',
      personId: widget.person.id,
      formNumber: widget.formNumber,
      filledByStaffId: _filledByController.text,
      isDraft: true,
      updatedAt: DateTime.now(),
      answers: _buildAnswersMap(),
    );

    provider.saveDraft(formData);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Form ${widget.formNumber} draft saved!')),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final provider = Provider.of<AppProvider>(context, listen: false);

    final formData = FormDataModel(
      id: '${widget.person.id}_form_${widget.formNumber}',
      personId: widget.person.id,
      formNumber: widget.formNumber,
      filledByStaffId: _filledByController.text,
      isDraft: false,
      updatedAt: DateTime.now(),
      answers: _buildAnswersMap(),
    );

    await provider.submitFormToFirebase(formData);
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Form ${widget.formNumber} submitted successfully to Firebase!',
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final bool isGlobalViewer = provider.isViewer;

    final bool isFormOne = widget.formNumber == 1;
    final bool isEditable = !isGlobalViewer;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          '${widget.person.name} - Form ${widget.formNumber} ${isFormOne ? "(Personal Profile)" : "(Appliances & Solar)"}',
        ),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isFormOne
                                      ? 'Form 1: Personal Profile Details'
                                      : 'Form 2: Electrical Load & Existing Solar',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Calculated Total Watts: $_totalWatts W',
                                  style: const TextStyle(
                                    color: Color(0xFF2563EB),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${(_completionRatio * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (isFormOne) ...[
                      _buildSectionHeader('1. Personal Profile Details'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _buildTextField(
                            _nameController,
                            'Full Name',
                            enabled: isEditable,
                          ),
                          _buildTextField(
                            _itsController,
                            'ITS Number',
                            isNumeric: true,
                            enabled: isEditable,
                          ),
                          _buildTextField(
                            _sfController,
                            'SF Number',
                            isNumeric: true,
                            enabled: isEditable,
                          ),
                          _buildTextField(
                            _contactController,
                            'Contact Number',
                            enabled: isEditable,
                          ),
                          _buildTextField(
                            _addressController,
                            'Complete Address (Flat, Floor, Building, Area)',
                            enabled: isEditable,
                          ),

                          SizedBox(
                            width: 260,
                            child: DropdownButtonFormField<String>(
                              value: _selectedHouseType,
                              decoration: InputDecoration(
                                labelText: 'House Type',
                                filled: true,
                                fillColor: isEditable
                                    ? Colors.white
                                    : Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              items: _houseTypeOptions.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                              onChanged: isEditable
                                  ? (value) => setState(
                                      () => _selectedHouseType = value,
                                    )
                                  : null,
                            ),
                          ),

                          SizedBox(
                            width: 260,
                            child: DropdownButtonFormField<String>(
                              value: _selectedRoomType,
                              decoration: InputDecoration(
                                labelText: 'Total Number of Rooms',
                                filled: true,
                                fillColor: isEditable
                                    ? Colors.white
                                    : Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              items: _roomTypeOptions.map((room) {
                                return DropdownMenuItem(
                                  value: room,
                                  child: Text(room),
                                );
                              }).toList(),
                              onChanged: isEditable
                                  ? (value) => setState(
                                      () => _selectedRoomType = value,
                                    )
                                  : null,
                            ),
                          ),

                          _buildTextField(
                            _noOfPersonsController,
                            'Number of Family Members',
                            isNumeric: true,
                            enabled: isEditable,
                          ),
                          _buildTextField(
                            _landlordNameController,
                            'Landlord Name',
                            enabled: isEditable,
                          ),
                          _buildTextField(
                            _landlordContactController,
                            'Landlord Contact',
                            enabled: isEditable,
                          ),

                          SizedBox(
                            width: 300,
                            child: DropdownButtonFormField<String>(
                              value: _selectedSolarWillingness,
                              decoration: InputDecoration(
                                labelText: 'Are you willing to install solar?',
                                filled: true,
                                fillColor: isEditable
                                    ? Colors.white
                                    : Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              items: _solarWillingnessOptions.map((opt) {
                                return DropdownMenuItem(
                                  value: opt,
                                  child: Text(opt),
                                );
                              }).toList(),
                              onChanged: isEditable
                                  ? (value) => setState(
                                      () => _selectedSolarWillingness = value,
                                    )
                                  : null,
                            ),
                          ),

                          SizedBox(
                            width: 380,
                            child: DropdownButtonFormField<String>(
                              value: _selectedLandlordApproval,
                              decoration: InputDecoration(
                                labelText:
                                    "Is your landlord's approval required for rooftop solar?",
                                filled: true,
                                fillColor: isEditable
                                    ? Colors.white
                                    : Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              items: _landlordApprovalOptions.map((opt) {
                                return DropdownMenuItem(
                                  value: opt,
                                  child: Text(opt),
                                );
                              }).toList(),
                              onChanged: isEditable
                                  ? (value) => setState(
                                      () => _selectedLandlordApproval = value,
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],

                    if (!isFormOne) ...[
                      _buildSectionHeader('2. Electrical Appliances Load'),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'Appliance',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Watts',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Qty',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Total (W)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              ..._applianceWatts.keys.map((item) {
                                final qty =
                                    int.tryParse(
                                      _qtyControllers[item]?.text ?? '0',
                                    ) ??
                                    0;
                                final unitWatt =
                                    int.tryParse(
                                      _wattControllers[item]?.text ?? '0',
                                    ) ??
                                    0;
                                final itemTotal = qty * unitWatt;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          item,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 8.0,
                                          ),
                                          child: TextField(
                                            controller: _wattControllers[item],
                                            keyboardType: TextInputType.number,
                                            enabled: isEditable,
                                            decoration: const InputDecoration(
                                              isDense: true,
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 8.0,
                                          ),
                                          child: TextField(
                                            controller: _qtyControllers[item],
                                            keyboardType: TextInputType.number,
                                            enabled: isEditable,
                                            decoration: const InputDecoration(
                                              isDense: true,
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          '$itemTotal W',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2563EB),
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
                      ),
                      const SizedBox(height: 24),

                      _buildSectionHeader(
                        '3. Existing Solar / Backup System & Finance',
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _buildTextField(
                            _kwInstalledController,
                            'KW Installed',
                            enabled: isEditable,
                          ),
                          _buildTextField(
                            _panelsWattageController,
                            'Panels Wattage',
                            enabled: isEditable,
                          ),
                          _buildTextField(
                            _inverterCapacityController,
                            'Inverter Capacity',
                            enabled: isEditable,
                          ),
                          _buildTextField(
                            _batteryTypeController,
                            'Battery Type',
                            enabled: isEditable,
                          ),
                          _buildTextField(
                            _normalUpsController,
                            'Normal UPS Installed',
                            enabled: isEditable,
                          ),
                          _buildTextField(
                            _existingInverterController,
                            'Existing Inverter',
                            enabled: isEditable,
                          ),
                          _buildTextField(
                            _existingBatteryController,
                            'Existing Battery',
                            enabled: isEditable,
                          ),
                          _buildTextField(
                            _financeByMuminController,
                            'Finance by Mumin',
                            enabled: isEditable,
                          ),

                          SizedBox(
                            width: 260,
                            child: DropdownButtonFormField<String>(
                              value: _selectedFinanceExpectation,
                              decoration: InputDecoration(
                                labelText: 'Finance as per expectation',
                                filled: true,
                                fillColor: isEditable
                                    ? Colors.white
                                    : Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              items: _financeExpectationOptions.map((opt) {
                                return DropdownMenuItem(
                                  value: opt,
                                  child: Text(opt),
                                );
                              }).toList(),
                              onChanged: isEditable
                                  ? (value) => setState(
                                      () => _selectedFinanceExpectation = value,
                                    )
                                  : null,
                            ),
                          ),

                          _buildTextField(
                            _filledByController,
                            'Filled By Staff Name',
                            enabled: isEditable,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: TextFormField(
                          controller: _remarksController,
                          maxLines: 3,
                          enabled: isEditable,
                          decoration: InputDecoration(
                            labelText: 'Remarks',
                            filled: true,
                            fillColor: isEditable
                                ? Colors.white
                                : Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    if (isEditable)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              onPressed: _saveDraft,
                              child: const Text('Save Local Draft'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              onPressed: _submitForm,
                              child: const Text('Submit Form'),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
    );
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
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
