import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:form_manager/Controller/provider_controller.dart';
import 'package:form_manager/Model/form_data_model.dart';
import 'package:form_manager/Model/person_model.dart';

List<Map<String, String>> buildMaterialFieldDefinitions() {
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
    {'key': 'rawalPlug', 'label': 'Rawal Plugs'}, //order changed
    {'key': 'wire4076', 'label': 'Wire 40/0.76'}, //order changed
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

class Form3View extends StatefulWidget {
  final PersonModel person;
  final bool readOnly;

  const Form3View({super.key, required this.person, this.readOnly = false});

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
    'acWire4mm': TextEditingController(),
    'dcWire4mm': TextEditingController(),
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
  bool _isDeleting = false;
  bool _isReadOnly = false;

  final List<String> _roofTypeOptions = [
    'Concrete Roof',
    'TR Girder Roof',
    'GI Sheets Roof',
  ];

  final List<String> _mainBoardOptions = ['Circuit Breaker', 'Old Main Switch'];

  @override
  void initState() {
    super.initState();
    _isReadOnly =
        widget.readOnly ||
        Provider.of<AppProvider>(context, listen: false).isViewer;
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
        _upsWiring = _coerceBool(ans['upsWiring']);
        _upsWiringLengthController.text = ans['upsWiringLength'] ?? '';
        _inverterInstallationAreaController.text =
            ans['inverterInstallationArea'] ?? '';
        _separateRoomWiseBreakers = _coerceBool(
          ans['separateRoomWiseBreakers'],
        );
        _waterConnectionOnRoof = _coerceBool(ans['waterConnectionOnRoof']);
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

          // If older drafts used the single 'wire4mm' key, migrate that value
          // into the new 'acWire4mm' and 'dcWire4mm' fields so viewers keep data.
          if (mats.containsKey('wire4mm')) {
            final migrated = (mats['wire4mm'] ?? '').toString();
            if (_matControllers.containsKey('acWire4mm')) {
              _matControllers['acWire4mm']!.text = migrated;
            }
            if (_matControllers.containsKey('dcWire4mm')) {
              _matControllers['dcWire4mm']!.text = migrated;
            }
          }
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

  bool? _coerceBool(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    if (v is String) {
      final s = v.toLowerCase().trim();
      if (s == 'true' || s == 'yes' || s == '1') return true;
      if (s == 'false' || s == 'no' || s == '0') return false;
    }
    if (v is num) return v != 0;
    return null;
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
    if (_inverterInstallationAreaController.text.trim().isNotEmpty) {
      filledCount++;
    }
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
      await provider.deleteSubmittedForm(widget.person.id, 3);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form 3 deleted successfully.')),
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

  Widget _buildBooleanDropdown(
    bool? value,
    String label,
    ValueChanged<bool?> onChanged,
  ) {
    return SizedBox(
      width: 260,
      child: DropdownButtonFormField<bool>(
        initialValue: [true, false].contains(value) ? value : null,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: !_isReadOnly ? Colors.white : Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        items: const [
          DropdownMenuItem(value: true, child: Text('Yes')),
          DropdownMenuItem(value: false, child: Text('No')),
        ],
        onChanged: _isReadOnly ? null : onChanged,
      ),
    );
  }

  Widget _buildMaterialField(String keyName, String label) {
    return SizedBox(
      width: 260,
      child: TextFormField(
        controller: _matControllers[keyName],
        enabled: !_isReadOnly,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: !_isReadOnly ? Colors.white : Colors.grey.shade100,
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
                ...buildMaterialFieldDefinitions().map(
                  (item) => _buildMaterialField(item['key']!, item['label']!),
                ),
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
                enabled: !_isReadOnly,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Survey Remarks & Observations',
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
