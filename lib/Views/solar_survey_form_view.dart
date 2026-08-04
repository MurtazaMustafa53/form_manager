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

  // General & Personal Controllers
  late TextEditingController _sfController;
  late TextEditingController _nameController;
  late TextEditingController _itsController;
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _dateController = TextEditingController();

  // House Type & Separated Landlord Details
  String? _selectedHouseType;
  final List<String> _houseTypeOptions = ['Ownership', 'Rented', 'Goodwill'];
  final _landlordNameController = TextEditingController();
  final _landlordContactController = TextEditingController();
  final _noOfPersonsController = TextEditingController();
  String? _selectedRoomType;

  // System & Survey Details
  final _kwInstalledController = TextEditingController();
  final _panelsWattageController = TextEditingController();
  final _inverterCapacityController = TextEditingController();
  final _batteryTypeController = TextEditingController();
  final _normalUpsController = TextEditingController();
  final _existingInverterController = TextEditingController();
  final _existingBatteryController = TextEditingController();
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
    _remarksController.dispose();
    _filledByController.dispose();
    for (var controller in _qtyControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadFormData() async {
    final provider = Provider.of<AppProvider>(context, listen: false);

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
      _addressController.text = ans['address'] ?? '';
      _contactController.text = ans['contact'] ?? '';
      _dateController.text = ans['date'] ?? _dateController.text;

      final loadedHouseType = ans['houseType']?.toString();
      _selectedHouseType = (_houseTypeOptions.contains(loadedHouseType))
          ? loadedHouseType
          : null;

      _landlordNameController.text =
          ans['landlordName'] ?? ans['landlordNameAndContact'] ?? '';
      _landlordContactController.text = ans['landlordContact'] ?? '';
      _noOfPersonsController.text = ans['noOfPersons']?.toString() ?? '';
      _selectedRoomType =
          (ans['rooms'] != null && ans['rooms'].toString().isNotEmpty)
          ? ans['rooms']
          : null;
      _kwInstalledController.text = ans['kwInstalled'] ?? '';
      _panelsWattageController.text = ans['panelsWattage'] ?? '';
      _inverterCapacityController.text = ans['inverterCapacity'] ?? '';
      _batteryTypeController.text = ans['batteryType'] ?? '';
      _normalUpsController.text = ans['normalUpsInstalled'] ?? '';
      _existingInverterController.text = ans['existingInverter'] ?? '';
      _existingBatteryController.text = ans['existingBattery'] ?? '';
      _remarksController.text = ans['remarks'] ?? '';
      _filledByController.text = ans['filledBy'] ?? '';

      for (var item in _applianceWatts.keys) {
        if (ans.containsKey('qty_$item')) {
          _qtyControllers[item]?.text = ans['qty_$item'].toString();
        }
      }
    });
    _calculateTotalWatts();
    _calculateCompletionRatio();
  }

  void _calculateTotalWatts() {
    int watts = 0;
    _qtyControllers.forEach((key, controller) {
      final qty = int.tryParse(controller.text) ?? 0;
      watts += qty * (_applianceWatts[key] ?? 0);
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
      _completionRatio = filledFields / totalFields;
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
      'kwInstalled': _kwInstalledController.text,
      'panelsWattage': _panelsWattageController.text,
      'inverterCapacity': _inverterCapacityController.text,
      'batteryType': _batteryTypeController.text,
      'normalUpsInstalled': _normalUpsController.text,
      'existingInverter': _existingInverterController.text,
      'existingBattery': _existingBatteryController.text,
      'remarks': _remarksController.text,
      'filledBy': _filledByController.text,
      'totalWatts': _totalWatts,
      'completionRatio': _completionRatio,
    };

    _qtyControllers.forEach((key, controller) {
      map['qty_$key'] = int.tryParse(controller.text) ?? 0;
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
    final bool isReadOnly = provider.isViewer;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('${widget.person.name} - Form ${widget.formNumber}'),
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
                                  isReadOnly
                                      ? 'Form Status: Read Only'
                                      : 'Form ${widget.formNumber} Status',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Calculated Watts: $_totalWatts W',
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

                    _buildSectionHeader('1. Personal Profile Details'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildTextField(
                          _nameController,
                          'Full Name',
                          enabled: !isReadOnly,
                        ),
                        _buildTextField(
                          _itsController,
                          'ITS Number',
                          isNumeric: true,
                          enabled: !isReadOnly,
                        ),
                        _buildTextField(
                          _sfController,
                          'SF Number',
                          isNumeric: true,
                          enabled: !isReadOnly,
                        ),
                        _buildTextField(
                          _contactController,
                          'Contact Number',
                          enabled: !isReadOnly,
                        ),
                        _buildTextField(
                          _addressController,
                          'Address',
                          enabled: !isReadOnly,
                        ),

                        // House Type Dropdown
                        SizedBox(
                          width: 260,
                          child: DropdownButtonFormField<String>(
                            value: _selectedHouseType,
                            decoration: InputDecoration(
                              labelText: 'House Type',
                              filled: true,
                              fillColor: !isReadOnly
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
                            onChanged: !isReadOnly
                                ? (value) =>
                                      setState(() => _selectedHouseType = value)
                                : null,
                          ),
                        ),

                        // Separated Landlord Fields
                        _buildTextField(
                          _landlordNameController,
                          'Landlord Name',
                          enabled: !isReadOnly,
                        ),
                        _buildTextField(
                          _landlordContactController,
                          'Landlord Contact',
                          enabled: !isReadOnly,
                        ),
                        _buildTextField(
                          _noOfPersonsController,
                          'No. of Persons',
                          isNumeric: true,
                          enabled: !isReadOnly,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

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
                          children: _applianceWatts.keys.map((item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('$item (${_applianceWatts[item]}W)'),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: _qtyControllers[item],
                                      keyboardType: TextInputType.number,
                                      enabled: !isReadOnly,
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildSectionHeader('3. Existing Solar / Backup System'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildTextField(
                          _kwInstalledController,
                          'KW Installed',
                          enabled: !isReadOnly,
                        ),
                        _buildTextField(
                          _panelsWattageController,
                          'Panels Wattage',
                          enabled: !isReadOnly,
                        ),
                        _buildTextField(
                          _inverterCapacityController,
                          'Inverter Capacity',
                          enabled: !isReadOnly,
                        ),
                        _buildTextField(
                          _batteryTypeController,
                          'Battery Type',
                          enabled: !isReadOnly,
                        ),
                        _buildTextField(
                          _normalUpsController,
                          'Normal UPS Installed',
                          enabled: !isReadOnly,
                        ),
                        _buildTextField(
                          _existingInverterController,
                          'Existing Inverter',
                          enabled: !isReadOnly,
                        ),
                        _buildTextField(
                          _existingBatteryController,
                          'Existing Battery',
                          enabled: !isReadOnly,
                        ),
                        _buildTextField(
                          _filledByController,
                          'Filled By Staff Name',
                          enabled: !isReadOnly,
                        ),
                        _buildTextField(
                          _remarksController,
                          'Remarks',
                          enabled: !isReadOnly,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    if (!isReadOnly)
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
