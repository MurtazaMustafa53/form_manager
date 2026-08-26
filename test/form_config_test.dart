import 'package:flutter_test/flutter_test.dart';
import 'package:form_manager/Controller/Excel_controller.dart';
import 'package:form_manager/Model/Form%20Mappers/form5_mapper.dart';
import 'package:form_manager/Model/Form%20Mappers/form_mapper_registry.dart';
import 'package:form_manager/Model/form_data_model.dart';
import 'package:form_manager/Views/Forms/form2_view.dart';
import 'package:form_manager/Views/Forms/form3_view.dart';
import 'package:form_manager/Views/Forms/form_finance_view.dart';
import 'package:form_manager/Views/report_view.dart';

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

    test('finance uses the configured default prices and fallback price', () {
      expect(financeDefaultPrice('dbBox'), 1200);
      expect(financeDefaultPrice('nutBolts'), 25);
      expect(financeDefaultPrice('flexiblePipe34'), 25);
      expect(financeDefaultPrice('band'), 35);
      expect(financeDefaultPrice('duct1x1'), 1);
      expect(financeDefaultPrice('solarPanel'), 1);
    });

    test('report money formatting uses PKR with thousands separators', () {
      expect(formatPkrAmount(1234567), 'PKR 1,234,567');
      expect(formatPkrAmount(1234567.89), 'PKR 1,234,567.89');
      expect(formatPkrAmount(0), 'PKR 0');
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

    test(
      'temporary form updates building name without completion progress',
      () {
        final summary = FormMapperRegistry.buildSummaryFromSubmittedForms([
          FormDataModel(
            id: 'person_1_form_7',
            personId: 'person_1',
            formNumber: 7,
            filledByStaffId: 'staff_1',
            updatedAt: DateTime.now(),
            answers: {'buildingName': 'North Building'},
            isDraft: false,
          ),
        ]);

        expect(summary['buildingName'], 'North Building');
        expect(summary['completedFormCount'], 0);
        expect(summary['submittedFormNumbers'], [7]);
      },
    );

    test('excel export expands nested answer fields into columns', () {
      final forms = [
        FormDataModel(
          id: 'person_1_form_2',
          personId: 'person_1',
          formNumber: 2,
          filledByStaffId: 'staff_1',
          updatedAt: DateTime.now(),
          answers: {
            'totalWatts': 320,
            'appliances': [
              {'name': 'AC/DC Fan', 'watts': 30},
              {'name': 'Tube Light', 'watts': 40},
            ],
            'materials': {'wire': '2', 'pipe': '5'},
          },
        ),
      ];

      final columns = ExcelService.buildExportColumns(forms);

      expect(columns, contains('Person ID'));
      expect(columns, contains('Name'));
      expect(columns, contains('totalWatts'));
      expect(columns, contains('appliances[0].name'));
      expect(columns, contains('appliances[0].watts'));
      expect(columns, contains('appliances[1].name'));
      expect(columns, contains('materials.wire'));
      expect(columns, contains('materials.pipe'));
    });
  });
}
