import 'package:flutter_test/flutter_test.dart';
import 'package:form_manager/Model/Form%20Mappers/form5_mapper.dart';
import 'package:form_manager/Model/Form%20Mappers/form_mapper_registry.dart';
import 'package:form_manager/Model/form_data_model.dart';
import 'package:form_manager/Views/Forms/form2_view.dart';
import 'package:form_manager/Views/Forms/form3_view.dart';

void main() {
  group('Form configuration helpers', () {
    test('form2 includes the requested appliances and wattages', () {
      final appliances = buildDefaultAppliances();
      final names = appliances.map((app) => app['name']).toList();

      expect(names, contains('AC/DC Fan'));
      expect(names, contains('Tube Light'));
      expect(names, contains('Wifi Router'));
      expect(names, contains('Dispenser'));
      expect(names, contains('Boring Pump'));

      final acFan = appliances.firstWhere((app) => app['name'] == 'AC/DC Fan');
      final tubeLight = appliances.firstWhere(
        (app) => app['name'] == 'Tube Light',
      );
      final wifiRouter = appliances.firstWhere(
        (app) => app['name'] == 'Wifi Router',
      );
      final dispenser = appliances.firstWhere(
        (app) => app['name'] == 'Dispenser',
      );
      final boringPump = appliances.firstWhere(
        (app) => app['name'] == 'Boring Pump',
      );

      expect(acFan['watts'], 30);
      expect(tubeLight['watts'], 40);
      expect(wifiRouter['watts'], 10);
      expect(dispenser['watts'], 150);
      expect(boringPump['watts'], 1000);
    });

    test('form3 keeps the requested BOM ordering', () {
      final materials = buildMaterialFieldDefinitions();
      final keys = materials.map((item) => item['key']).toList();

      expect(
        keys.indexOf('indicationLights'),
        lessThan(keys.indexOf('rawalPlug')),
      );
      expect(keys.indexOf('rawalPlug'), lessThan(keys.indexOf('wire4076')));
      expect(keys.indexOf('wire4076'), lessThan(keys.indexOf('mc4Connector')));
      expect(keys.indexOf('batteryWire'), lessThan(keys.indexOf('duct1x1')));
      expect(keys.indexOf('flexiblePipe1'), lessThan(keys.indexOf('duct1x1')));
      expect(keys.indexOf('thimble'), lessThan(keys.indexOf('band')));
      expect(keys.indexOf('clip34'), lessThan(keys.indexOf('band')));
    });

    test(
      'finance mapper includes the solar installation and contribution fields',
      () {
        final update = Form5Mapper().toPersonUpdates(
          FormDataModel(
            id: 'person_1_form_5',
            personId: 'person_1',
            formNumber: 5,
            filledByStaffId: 'staff_1',
            updatedAt: DateTime.now(),
            answers: {
              'summaryTotal': 25000,
              'materials': [],
              'financeByMumin': 'Yes',
              'financeExpectation': 'Yes',
              'numberOfSolarPanels': 2,
              'numberOfInverter': 1,
              'lithiumBattery': 1,
              'structure': 'elevated',
              'structureQuantity': 1,
              'solarPanelAmount': 2500,
              'inverterAmount': 1200,
              'lithiumBatteryAmount': 1800,
              'structureAmount': 500,
              'ownContribution': 15000,
              'qarzanHasana': 10000,
              'totalContribution': 25000,
            },
          ),
        );

        expect(update['numberOfSolarPanels'], 2);
        expect(update['numberOfInverter'], 1);
        expect(update['lithiumBattery'], 1);
        expect(update['structure'], 'elevated');
        expect(update['structureQuantity'], 1);
        expect(update['solarPanelAmount'], 2500);
        expect(update['inverterAmount'], 1200);
        expect(update['lithiumBatteryAmount'], 1800);
        expect(update['structureAmount'], 500);
        expect(update['ownContribution'], 15000);
        expect(update['qarzanHasana'], 10000);
        expect(update['totalContribution'], 25000);
      },
    );

    test(
      'summary rebuild keeps the highest remaining form number after delete',
      () {
        final forms = [
          FormDataModel(
            id: 'person_1_form_1',
            personId: 'person_1',
            formNumber: 1,
            filledByStaffId: 'staff_1',
            updatedAt: DateTime.now(),
            answers: {'address': 'Street 1', 'solarWillingness': 'Yes'},
          ),
          FormDataModel(
            id: 'person_1_form_3',
            personId: 'person_1',
            formNumber: 3,
            filledByStaffId: 'staff_1',
            updatedAt: DateTime.now(),
            answers: {'roofType': 'Concrete', 'houseNoOfSolarPanels': 5},
          ),
        ];

        final summary = FormMapperRegistry.buildSummaryFromSubmittedForms(
          forms,
        );

        expect(summary['completedFormCount'], 3);
        expect(summary['roofType'], 'Concrete');
        expect(summary['address'], 'Street 1');
      },
    );
  });
}
