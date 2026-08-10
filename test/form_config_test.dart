import 'package:flutter_test/flutter_test.dart';
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

      expect(keys.indexOf('socket'), lessThan(keys.indexOf('dcBreaker')));
      expect(keys.indexOf('changeOver'), lessThan(keys.indexOf('dcWire4mm')));
      expect(keys.indexOf('screw'), lessThan(keys.indexOf('dcWire4mm')));
      expect(
        keys.indexOf('indicationLights'),
        lessThan(keys.indexOf('wire4076')),
      );
      expect(keys.indexOf('rawalPlug'), lessThan(keys.indexOf('wire4076')));
      expect(keys.indexOf('mc4Connector'), lessThan(keys.indexOf('rawalPlug')));
      expect(
        keys.indexOf('flexiblePipe34'),
        lessThan(keys.indexOf('rawalPlug')),
      );
      expect(keys.indexOf('batteryWire'), lessThan(keys.indexOf('duct1x1')));
      expect(keys.indexOf('flexiblePipe1'), lessThan(keys.indexOf('duct1x1')));
      expect(keys.indexOf('thimble'), lessThan(keys.indexOf('band')));
      expect(keys.indexOf('clip34'), lessThan(keys.indexOf('band')));
    });
  });
}
