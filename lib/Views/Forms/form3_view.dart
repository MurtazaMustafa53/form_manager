import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:form_manager/Controller/provider_controller.dart';
import 'package:form_manager/Model/form_data_model.dart';
import 'package:form_manager/Model/person_model.dart';

class Form3View extends StatefulWidget {
  final PersonModel person;

  const Form3View({Key? key, required this.person}) : super(key: key);

  @override
  State<Form3View> createState() => _Form3ViewState();
}

class _Form3ViewState extends State<Form3View> {
  final _formKey = GlobalKey<FormState>();

  // 1. Roof & Physical Survey Controllers & States
  String? _roofType;
  final _roofSizeController = TextEditingController();
  final _houseNoOfSolarPanelsController = TextEditingController();
  final _floorMountNoOfSolarController = TextEditingController();
  final _elevatedNoOfSolarController = TextEditingController();

  // 2. Electrical Details Controllers & States
  String? _mainBoardType;
  final _dcWireLengthController = TextEditingController();
  final _acWireLengthController = TextEditingController();
  bool? _upsWiring;
  final _upsWiringLengthController = TextEditingController();
  final _inverterInstallationAreaController = TextEditingController();
  bool? _separateRoomWiseBreakers;
  bool? _waterConnectionOnRoof;
  final _earthingLengthController = TextEditingController();

  // 3. Bill of Materials / Material Inventory Controllers
  final Map<String, TextEditingController> _matControllers = {
    'dbBox': TextEditingController(),
    'acBreaker': TextEditingController(),
    'dcBreaker': TextEditingController(),
    'changeOver': TextEditingController(),
    'indicationLights': TextEditingController(),
    'mc4Connector': TextEditingController(),
    'flexiblePipe34': TextEditingController(),
    'duct1x1': TextEditingController(),
    'batteryWire': TextEditingController(),
    'thimble': TextEditingController(),
    'nutBolts': TextEditingController(),
    'clip1': TextEditingController(),
    'insulationTape': TextEditingController(),
    'pipeLength34': TextEditingController(),
    'wire7029': TextEditingController(),
    'pipeLength1': TextEditingController(),
    'wire4mm': TextEditingController(),
    'screw': TextEditingController(),
    'wire4076': TextEditingController(),
    'rawalPlug': TextEditingController(),
    'duct25x25': TextEditingController(),
    'flexiblePipe1': TextEditingController(),
    'band': TextEditingController(),
    'clip34': TextEditingController(),
    'socket': TextEditingController(),
  };

  // Remarks & Staff Name
  final _remarksController = TextEditingController();
  final _filledByStaffController = TextEditingController();

  bool _isSavingDraft = false;
  bool _isSubmitting = false;

  final List<String> _roofTypeOptions = [
    'Concrete Roof',
    'TR Girder Roof',
    'GI Sheets Roof',
  ];

  final List<String> _mainBoardOptions = ['Circuit Breaker', 'Old Main Switch'];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final provider = Provider.of<AppProvider>(context, listen: false);

    FormDataModel? draft = provider.loadDraft(widget.person.id, 3);
    draft ??= await provider.getSubmittedForm(widget.person.id, 3);

    if (draft != null && mounted) {
      final ans = draft.answers;
      setState(() {
        _roofType = ans['roofType'];
        _roofSizeController.text = ans['roofSize'] ?? '';
        _houseNoOfSolarPanelsController.text =
            ans['houseNoOfSolarPanels'] ?? '';
        _floorMountNoOfSolarController.text = ans['floorMountNoOfSolar'] ?? '';
        _elevatedNoOfSolarController.text = ans['elevatedNoOfSolar'] ?? '';

        _mainBoardType = ans['mainBoardType'];
        _dcWireLengthController.text = ans['dcWireLength'] ?? '';
        _acWireLengthController.text = ans['acWireLength'] ?? '';
        _upsWiring = ans['upsWiring'];
        _upsWiringLengthController.text = ans['upsWiringLength'] ?? '';
        _inverterInstallationAreaController.text =
            ans['inverterInstallationArea'] ?? '';
        _separateRoomWiseBreakers = ans['separateRoomWiseBreakers'];
        _waterConnectionOnRoof = ans['waterConnectionOnRoof'];
        _earthingLengthController.text = ans['earthingLength'] ?? '';

        _remarksController.text = ans['remarks'] ?? '';
        _filledByStaffController.text = ans['filledByStaff'] ?? '';

        if (ans['materials'] != null) {
          final Map<String, dynamic> mats = ans['materials'];
          mats.forEach((key, val) {
            if (_matControllers.containsKey(key)) {
              _matControllers[key]!.text = val.toString();
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _roofSizeController.dispose();
    _houseNoOfSolarPanelsController.dispose();
    _floorMountNoOfSolarController.dispose();
    _elevatedNoOfSolarController.dispose();
    _dcWireLengthController.dispose();
    _acWireLengthController.dispose();
    _upsWiringLengthController.dispose();
    _inverterInstallationAreaController.dispose();
    _earthingLengthController.dispose();
    _remarksController.dispose();
    _filledByStaffController.dispose();

    _matControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  double _calculateCompletionRatio() {
    int filledCount = 0;
    const int trackedFields = 12;

    if (_roofType != null) filledCount++;
    if (_roofSizeController.text.trim().isNotEmpty) filledCount++;
    if (_houseNoOfSolarPanelsController.text.trim().isNotEmpty) filledCount++;
    if (_mainBoardType != null) filledCount++;
    if (_dcWireLengthController.text.trim().isNotEmpty) filledCount++;
    if (_acWireLengthController.text.trim().isNotEmpty) filledCount++;
    if (_upsWiring != null) filledCount++;
    if (_inverterInstallationAreaController.text.trim().isNotEmpty)
      filledCount++;
    if (_separateRoomWiseBreakers != null) filledCount++;
    if (_waterConnectionOnRoof != null) filledCount++;
    if (_earthingLengthController.text.trim().isNotEmpty) filledCount++;
    if (_filledByStaffController.text.trim().isNotEmpty) filledCount++;

    return filledCount / trackedFields;
  }

  Map<String, dynamic> _collectAnswers() {
    final Map<String, String> materialsData = {};
    _matControllers.forEach((key, controller) {
      materialsData[key] = controller.text.trim();
    });

    return {
      'roofType': _roofType ?? '',
      'roofSize': _roofSizeController.text.trim(),
      'houseNoOfSolarPanels': _houseNoOfSolarPanelsController.text.trim(),
      'floorMountNoOfSolar': _floorMountNoOfSolarController.text.trim(),
      'elevatedNoOfSolar': _elevatedNoOfSolarController.text.trim(),
      'mainBoardType': _mainBoardType ?? '',
      'dcWireLength': _dcWireLengthController.text.trim(),
      'acWireLength': _acWireLengthController.text.trim(),
      'upsWiring': _upsWiring,
      'upsWiringLength': _upsWiringLengthController.text.trim(),
      'inverterInstallationArea': _inverterInstallationAreaController.text
          .trim(),
      'separateRoomWiseBreakers': _separateRoomWiseBreakers,
      'waterConnectionOnRoof': _waterConnectionOnRoof,
      'earthingLength': _earthingLengthController.text.trim(),
      'materials': materialsData,
      'remarks': _remarksController.text.trim(),
      'filledByStaff': _filledByStaffController.text.trim(),
      'completionRatio': _calculateCompletionRatio(),
    };
  }

  Future<void> _handleSaveDraft() async {
    setState(() => _isSavingDraft = true);
    final provider = Provider.of<AppProvider>(context, listen: false);

    final draftData = FormDataModel(
      id: '${widget.person.id}_form_3',
      personId: widget.person.id,
      formNumber: 3,
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
        const SnackBar(content: Text('Form 3 local draft saved successfully.')),
      );
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final provider = Provider.of<AppProvider>(context, listen: false);
    final formData = FormDataModel(
      id: '${widget.person.id}_form_3',
      personId: widget.person.id,
      formNumber: 3,
      filledByStaffId: provider.currentUser?.uid ?? '',
      isDraft: false,
      updatedAt: DateTime.now(),
      answers: _collectAnswers(),
    );

    try {
      await provider.submitFormToFirebase(formData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form 3 submitted successfully.')),
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
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
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
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        items: items
            .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildBooleanDropdown(
    bool? value,
    String label,
    ValueChanged<bool?> onChanged,
  ) {
    return SizedBox(
      width: 260,
      child: DropdownButtonFormField<bool>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        items: const [
          DropdownMenuItem(value: true, child: Text('Yes')),
          DropdownMenuItem(value: false, child: Text('No')),
        ],
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildMaterialField(String keyName, String label) {
    return SizedBox(
      width: 260,
      child: TextFormField(
        controller: _matControllers[keyName],
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
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
    final double completionRatio = _calculateCompletionRatio();
    final int completionPercentage = (completionRatio * 100).toInt();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        title: Text('${widget.person.name} - Form 3 (Physical Survey)'),
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
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Form 3: Physical & Electrical Survey',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'IBM Solar Physical Survey 2026 / 1448H',
                          style: TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w500,
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

              // Section 1: Roof & Structural Details
              _buildSectionCard('1. Roof & Structural Details', [
                _buildDropdownField(
                  _roofType,
                  'Roof Type',
                  _roofTypeOptions,
                  (val) => setState(() => _roofType = val),
                ),
                _buildTextField(_roofSizeController, 'Roof Size (sq ft)'),
                _buildTextField(
                  _houseNoOfSolarPanelsController,
                  'Max Solar Panels Count',
                  isNumeric: true,
                ),
                _buildTextField(
                  _floorMountNoOfSolarController,
                  'Floor Mount Panels Count',
                  isNumeric: true,
                ),
                _buildTextField(
                  _elevatedNoOfSolarController,
                  'Elevated Mount Panels Count',
                  isNumeric: true,
                ),
              ]),
              const SizedBox(height: 16),

              // Section 2: Electrical Details
              _buildSectionCard('2. Electrical Infrastructure Details', [
                _buildDropdownField(
                  _mainBoardType,
                  'Main DB Board Type',
                  _mainBoardOptions,
                  (val) => setState(() => _mainBoardType = val),
                ),
                _buildTextField(_dcWireLengthController, 'DC Wire Length (m)'),
                _buildTextField(_acWireLengthController, 'AC Wire Length (m)'),
                _buildBooleanDropdown(
                  _upsWiring,
                  'UPS Wiring Present?',
                  (val) => setState(() => _upsWiring = val),
                ),
                _buildTextField(
                  _upsWiringLengthController,
                  'UPS Wiring Length (m)',
                ),
                _buildTextField(
                  _inverterInstallationAreaController,
                  'Inverter Location Area',
                ),
                _buildBooleanDropdown(
                  _separateRoomWiseBreakers,
                  'Separate Room Breakers?',
                  (val) => setState(() => _separateRoomWiseBreakers = val),
                ),
                _buildBooleanDropdown(
                  _waterConnectionOnRoof,
                  'Water Tap on Roof?',
                  (val) => setState(() => _waterConnectionOnRoof = val),
                ),
                _buildTextField(
                  _earthingLengthController,
                  'Earthing Cable Length (m)',
                ),
              ]),
              const SizedBox(height: 16),

              // Section 3: Bill of Materials
              _buildSectionCard('3. Bill of Materials Inventory', [
                _buildMaterialField('dbBox', 'DB Box'),
                _buildMaterialField('nutBolts', 'Nuts & Bolts'),
                _buildMaterialField('clip1', 'Clips 1"'),
                _buildMaterialField('insulationTape', 'Insulation Tape'),
                _buildMaterialField('acBreaker', 'AC Breaker'),
                _buildMaterialField('pipeLength34', 'PVC Pipe 3/4"'),
                _buildMaterialField('wire7029', 'Wire 7/0.29'),
                _buildMaterialField('dcBreaker', 'DC Breaker'),
                _buildMaterialField('pipeLength1', 'PVC Pipe 1"'),
                _buildMaterialField('wire4mm', 'Wire 4mm'),
                _buildMaterialField('changeOver', 'Changeover Switch'),
                _buildMaterialField('screw', 'Screws'),
                _buildMaterialField('wire4076', 'Wire 40/0.76'),
                _buildMaterialField('indicationLights', 'Indication Lights'),
                _buildMaterialField('rawalPlug', 'Rawal Plugs'),
                _buildMaterialField('duct25x25', 'Duct 25x25'),
                _buildMaterialField('mc4Connector', 'MC4 Connectors'),
                _buildMaterialField('flexiblePipe34', 'Flexible Pipe 3/4"'),
                _buildMaterialField('duct1x1', 'Duct 1x1'),
                _buildMaterialField('batteryWire', 'Battery Cable'),
                _buildMaterialField('flexiblePipe1', 'Flexible Pipe 1"'),
                _buildMaterialField('band', 'Pipe Bends'),
                _buildMaterialField('thimble', 'Thimble Lugs'),
                _buildMaterialField('clip34', 'Clips 3/4"'),
                _buildMaterialField('socket', 'Sockets'),
              ]),
              const SizedBox(height: 16),

              // Staff & Remarks
              _buildSectionCard('Staff & Remarks', [
                _buildTextField(
                  _filledByStaffController,
                  'Filled By Staff Name',
                ),
              ]),
              const SizedBox(height: 16),

              TextFormField(
                controller: _remarksController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Survey Remarks & Observations',
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: Colors.white,
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
