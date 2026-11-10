import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      if (!RegExp(r'^[a-z0-9-]+$').hasMatch(name)) return false;
      final directory = Directory('build/integration_screenshots');
      await directory.create(recursive: true);
      await File('${directory.path}/$name.png').writeAsBytes(bytes);
      return bytes.isNotEmpty;
    },
    responseDataCallback: (_) async {
      // Avoid serializing screenshot bytes or any runtime credentials into logs.
      stdout.writeln(
        'Android Atlas integration test completed; screenshots saved.',
      );
    },
  );
}
