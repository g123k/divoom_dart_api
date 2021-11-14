import 'package:divoom_api/src/model/divoom_device.dart';
import 'package:divoom_api/src/utils/network_utils.dart';

extension AdjustBrightnessExtension on DivoomDevice {
  Future<bool> adjustBrightness(int brightness) {
    assert(brightness >= 0 && brightness <= 100,
        'Brightness must be between 0-100');
    return NetworkUtils.sendDivoomDeviceAPIRequest(
      address,
      commandName: 'Channel/SetBrightness',
      extras: {
        'Brightness': brightness,
      },
    );
  }
}
