import 'package:divoom_api/divoom_api.dart';
import 'package:divoom_api/src/model/divoom_device.dart';

void main() async {
  await for (DivoomDevice device in DivoomDetector.detectDevicesOnNetwork(
    '192.168.10.0',
  )) {
    await device.adjustBrightness(100);
  }
}
