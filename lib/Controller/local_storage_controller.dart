import 'dart:convert';

import 'package:form_manager/Model/form_data_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageController {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String _getDraftKey(String personId, int formNumber) {
    return 'draft_${personId}_form_$formNumber';
  }

  static Future<bool> saveFormDraft(FormDataModel formData) async {
    if (_prefs == null) await init();
    final key = _getDraftKey(formData.personId, formData.formNumber);
    final jsonString = jsonEncode(formData.toLocalMap());
    return await _prefs!.setString(key, jsonString);
  }

  static FormDataModel? getFormDraft(String personId, int formNumber) {
    if (_prefs == null) return null;
    final key = _getDraftKey(personId, formNumber);
    final jsonString = _prefs!.getString(key);

    if (jsonString == null || jsonString.isEmpty) return null;

    try {
      final Map<String, dynamic> map = jsonDecode(jsonString);
      return FormDataModel.fromLocalMap(map);
    } catch (e) {
      return null;
    }
  }
}
