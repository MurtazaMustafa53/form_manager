import 'package:flutter/material.dart';
import 'package:form_manager/Controller/provider_controller.dart';
import 'package:form_manager/Model/form_data_model.dart';
import 'package:form_manager/Model/person_model.dart';
import 'package:provider/provider.dart';

class SolarSurveyFormView extends StatefulWidget {
  final PersonModel person;

  const SolarSurveyFormView({super.key, required this.person});

  @override
  State<SolarSurveyFormView> createState() => _SolarSurveyFormViewState();
}

class _SolarSurveyFormViewState extends State<SolarSurveyFormView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _sfController;
  late TextEditingController _nameController;
  late TextEditingController _itsController;
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _dateController = TextEditingController();
  final _houseTypeController = TextEditingController();
  final _landlordController = TextEditingController();
  final _noOfPersonsController = TextEditingController();
  String? _selectedRoomType;

  final _kwInstalledController = TextEditingController();
  final _panelsWattageController = TextEditingController();
  final _inverterCapacityController = TextEditingController();
  final _batteryTypeController = TextEditingController();
  final _normalUpsController = TextEditingController();
  final _existingInverterController = TextEditingController();
  final _existingBatteryController = TextEditingController();
  final _remarksController = TextEditingController();
  final _filledByController = TextEditingController();

  final List<String> _roomOptions = [
    '2Bed Lounge',
    '2Bed D/D',
    '3Bed Lounges',
    '3Bed D/D',
  ];

  final Map<String, int> _applianceWatts = {
    'Fan': 100,
    'Ac/Dc Fan': 45,
    'Tube Light': 45,
    'LED Tube Light': 50,
    'LED Bulb': 15,
    'Energy Saver': 28,
    'LED TV': 80,
    'Wifi Router': 12,
    'AC 1-Ton-Inverter': 975,
    'AC 1-1/2-Ton Inverter': 1950,
    'AC 1-Ton-Standard': 1400,
    'AC 1-1/2-Ton - Standard': 2050,
    'Fridge': 250,
    'Deep Freezer': 400,
    'Dispanser': 200,
    'Iron': 800,
    'Microwave': 2250,
    'Water Motor 1/2 HP': 450,
    'Water Motor 1 HP': 900,
    'Boring Pump 1 HP': 900,
    'Boring Pump 2 HP': 2100,
    'Washing Machine - Manual': 700,
    'Washing Machine - Automatic': 700,
  };

  final Map<String, TextEditingController> _qtyControllers = {};

  @override
  void initState() {
    super.initState();
    _sfController = TextEditingController(text: widget.person.sfNo.toString());
    _nameController = TextEditingController(text: widget.person.name);
    _itsController = TextEditingController(text: widget.person.its.toString());
    _dateController.text = DateTime.now().toString().split(' ')[0];

    for (var key in _applianceWatts.keys) {
      _qtyControllers[key] = TextEditingController(text: '0');
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFormData();
    });
  }

  Future<void> _loadFormData() async {
    final provider = Provider.of<AppProvider>(context, listen: false);

    // 1. Try fetching already submitted form from Firebase
    final submittedForm = await provider.getSubmittedForm(widget.person.id, 1);

    if (submittedForm != null) {
      _populateFieldsFromMap(submittedForm.answers);
      return;
    }

    // 2. If not submitted, fall back to loading local draft
    final draft = provider.loadDraft(widget.person.id, 1);
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
      _houseTypeController.text = ans['houseType'] ?? '';
      _landlordController.text = ans['landlordContact'] ?? '';
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

      _applianceWatts.keys.forEach((item) {
        if (ans.containsKey('qty_$item')) {
          _qtyControllers[item]?.text = ans['qty_$item'].toString();
        }
      });
    });
  }

  void _onFieldChanged() {
    setState(() {});
    _saveDraftLocally();
  }

  void _saveDraftLocally() {
    final Map<String, dynamic> answers = _buildAnswersMap();
    final formData = FormDataModel(
      id: '${widget.person.id}_form_1',
      personId: widget.person.id,
      formNumber: 1,
      filledByStaffId: _filledByController.text,
      answers: answers,
      isDraft: true,
      updatedAt: DateTime.now(),
    );

    Provider.of<AppProvider>(context, listen: false).saveDraft(formData);
  }

  double _calculateProfileCompletionPercentage() {
    int totalFields = 11;
    int filledCount = 0;

    if (_sfController.text.trim().isNotEmpty) filledCount++;
    if (_nameController.text.trim().isNotEmpty) filledCount++;
    if (_itsController.text.trim().isNotEmpty) filledCount++;
    if (_addressController.text.trim().isNotEmpty) filledCount++;
    if (_contactController.text.trim().isNotEmpty) filledCount++;
    if (_houseTypeController.text.trim().isNotEmpty) filledCount++;
    if (_landlordController.text.trim().isNotEmpty) filledCount++;
    if (_noOfPersonsController.text.trim().isNotEmpty) filledCount++;
    if (_selectedRoomType != null && _selectedRoomType!.isNotEmpty)
      filledCount++;
    if (_remarksController.text.trim().isNotEmpty) filledCount++;
    if (_filledByController.text.trim().isNotEmpty) filledCount++;

    return (filledCount / totalFields).clamp(0.0, 1.0);
  }

  int _calculateTotalWatts() {
    int total = 0;
    _applianceWatts.forEach((item, watts) {
      int qty = int.tryParse(_qtyControllers[item]?.text ?? '0') ?? 0;
      total += qty * watts;
    });
    return total;
  }

  Map<String, dynamic> _buildAnswersMap() {
    final Map<String, dynamic> answers = {
      'sfNo': _sfController.text,
      'name': _nameController.text,
      'its': _itsController.text,
      'address': _addressController.text,
      'contact': _contactController.text,
      'date': _dateController.text,
      'houseType': _houseTypeController.text,
      'landlordContact': _landlordController.text,
      'noOfPersons': _noOfPersonsController.text,
      'rooms': _selectedRoomType ?? '',
      'totalWatts': _calculateTotalWatts(),
      'kwInstalled': _kwInstalledController.text,
      'panelsWattage': _panelsWattageController.text,
      'inverterCapacity': _inverterCapacityController.text,
      'batteryType': _batteryTypeController.text,
      'normalUpsInstalled': _normalUpsController.text,
      'existingInverter': _existingInverterController.text,
      'existingBattery': _existingBatteryController.text,
      'remarks': _remarksController.text,
      'filledBy': _filledByController.text,
      'completionRatio': _calculateProfileCompletionPercentage(),
    };

    _qtyControllers.forEach((item, controller) {
      answers['qty_$item'] = int.tryParse(controller.text) ?? 0;
    });

    return answers;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final formData = FormDataModel(
        id: '${widget.person.id}_form_1',
        personId: widget.person.id,
        formNumber: 1,
        filledByStaffId: _filledByController.text,
        answers: _buildAnswersMap(),
        isDraft: false,
        updatedAt: DateTime.now(),
      );

      Provider.of<AppProvider>(
        context,
        listen: false,
      ).submitFormToFirebase(formData);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final completionRatio = _calculateProfileCompletionPercentage();
    final percentageInt = (completionRatio * 100).toInt();

    return Scaffold(
      appBar: AppBar(
        title: Text('IBM Solar Survey - ${widget.person.name}'),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: const Color(0xFFEFF6FF),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color(0xFFBFDBFE)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Profile Form Completion',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E40AF),
                            ),
                          ),
                          Text(
                            '$percentageInt%',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E40AF),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: completionRatio,
                          minHeight: 8,
                          backgroundColor: const Color(0xFFDBEAFE),
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'IBM Solar Data Collection 2026/1448H',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(height: 16),

              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildInput('SF No', _sfController, width: 160),
                  _buildInput('Name', _nameController, width: 250),
                  _buildInput('ITS', _itsController, width: 160),
                  _buildInput('Contact', _contactController, width: 200),
                  _buildInput('Date', _dateController, width: 160),
                  _buildInput('Address', _addressController, width: 430),
                  _buildInput('House Type', _houseTypeController, width: 200),
                  _buildInput(
                    'Landlord Name & Contact#',
                    _landlordController,
                    width: 250,
                  ),
                  _buildInput(
                    'No. of Persons',
                    _noOfPersonsController,
                    width: 160,
                    isNumber: true,
                  ),
                  SizedBox(
                    width: 200,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedRoomType,
                      decoration: const InputDecoration(
                        labelText: 'Rooms',
                        border: OutlineInputBorder(),
                      ),
                      items: _roomOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (val) {
                        _selectedRoomType = val;
                        _onFieldChanged();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Appliance Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Total Watts: ${_calculateTotalWatts()} W',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Card(
                elevation: 0,
                // side: BorderSide(color: Colors.grey.shade300),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: _applianceWatts.keys.map((item) {
                      final watts = _applianceWatts[item]!;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text('Avg. $watts W'),
                            const SizedBox(width: 24),
                            SizedBox(
                              width: 80,
                              child: TextFormField(
                                controller: _qtyControllers[item],
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Qty',
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (_) => _onFieldChanged(),
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

              const Text(
                'Already Installed Solar System / UPS',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildInput(
                    'How many kW installed',
                    _kwInstalledController,
                    width: 220,
                  ),
                  _buildInput(
                    'No. of panels/Wattage',
                    _panelsWattageController,
                    width: 220,
                  ),
                  _buildInput(
                    'Inverter capacity',
                    _inverterCapacityController,
                    width: 220,
                  ),
                  _buildInput(
                    'Battery type / Ampere',
                    _batteryTypeController,
                    width: 220,
                  ),
                  _buildInput(
                    'Normal UPS installed',
                    _normalUpsController,
                    width: 220,
                  ),
                  _buildInput(
                    'Inverter',
                    _existingInverterController,
                    width: 220,
                  ),
                  _buildInput(
                    'Battery/Type/Ampere',
                    _existingBatteryController,
                    width: 220,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInput(
                'Remarks',
                _remarksController,
                width: double.infinity,
              ),
              const SizedBox(height: 16),
              _buildInput('Form filled by', _filledByController, width: 300),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                  ),
                  child: const Text(
                    'Submit Solar Survey Form',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    String label,
    TextEditingController controller, {
    required double width,
    bool isNumber = false,
  }) {
    return SizedBox(
      width: width,
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        onChanged: (_) => _onFieldChanged(),
      ),
    );
  }
}
