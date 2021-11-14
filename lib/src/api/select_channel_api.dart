import 'package:divoom_api/src/model/divoom_device.dart';
import 'package:divoom_api/src/utils/network_utils.dart';

extension SelectChannelAPI on DivoomDevice {
  Future<bool> selectChannel(DivoomChannel channel) {
    return NetworkUtils.sendDivoomDeviceAPIRequest(
      address,
      commandName: 'Channel/SetIndex',
      extras: {
        'SelectIndex': _channelToValue(channel),
      },
    );
  }

  int _channelToValue(DivoomChannel channel) {
    switch (channel) {
      case DivoomChannel.faces:
        return 0;
      case DivoomChannel.cloud:
        return 1;
      case DivoomChannel.visualizer:
        return 2;
      case DivoomChannel.custom:
        return 3;
    }
  }
}

enum DivoomChannel {
  faces,
  cloud,
  visualizer,
  custom,
}
