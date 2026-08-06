import 'package:form_manager/Model/Form%20Mappers/base_form_mapper.dart';
import 'package:form_manager/Model/form_data_model.dart';

class Form3Mapper implements BaseFormMapper {
  @override
  int get formNumber => 3;

  @override
  Map<String, dynamic> toPersonUpdates(FormDataModel formData) {
    final ans = formData.answers;

    return {
      'completedFormCount': 3,
      'fieldCompletionRatio': ans['completionRatio'] ?? 1.0,

      // Roof & Structural Details
      'roofType': (ans['roofType'] ?? '').toString().trim(),
      'roofSize': (ans['roofSize'] ?? '').toString().trim(),
      'houseNoOfSolarPanels':
          int.tryParse((ans['houseNoOfSolarPanels'] ?? '0').toString()) ?? 0,
      'floorMountNoOfSolar':
          int.tryParse((ans['floorMountNoOfSolar'] ?? '0').toString()) ?? 0,
      'elevatedNoOfSolar':
          int.tryParse((ans['elevatedNoOfSolar'] ?? '0').toString()) ?? 0,

      // Electrical Infrastructure Details
      'mainBoardType': (ans['mainBoardType'] ?? '').toString().trim(),
      'dcWireLength': (ans['dcWireLength'] ?? '').toString().trim(),
      'acWireLength': (ans['acWireLength'] ?? '').toString().trim(),
      'upsWiring': ans['upsWiring'] == true,
      'upsWiringLength': (ans['upsWiringLength'] ?? '').toString().trim(),
      'inverterInstallationArea': (ans['inverterInstallationArea'] ?? '')
          .toString()
          .trim(),
      'separateRoomWiseBreakers': ans['separateRoomWiseBreakers'] == true,
      'waterConnectionOnRoof': ans['waterConnectionOnRoof'] == true,
      'earthingLength': (ans['earthingLength'] ?? '').toString().trim(),

      // Bill of Materials / Inventory Map
      'materials': ans['materials'] is Map ? ans['materials'] : {},

      // Staff & Remarks
      'form3Remarks': (ans['remarks'] ?? '').toString().trim(),
      'surveyFilledByStaff': (ans['filledByStaff'] ?? '').toString().trim(),
    };
  }
}
