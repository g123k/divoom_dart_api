import 'package:divoom_api/src/model/divoom_device.dart';
import 'package:divoom_api/src/utils/network_utils.dart';

extension ControlCustomChannelAPI on DivoomDevice {
  Future<bool> controlCustomChannel(DivoomCustomChannel channel) {
    return NetworkUtils.sendDivoomDeviceAPIRequest(
      address,
      commandName: 'Channel/SetCustomPageIndex',
      extras: {
        'CustomPageIndex': _channelToValue(channel),
      },
    );
  }

  int _channelToValue(DivoomCustomChannel channel) {
    switch (channel) {
      case DivoomCustomChannel.page0:
        return 0;
      case DivoomCustomChannel.page1:
        return 1;
      case DivoomCustomChannel.page2:
        return 2;
    }
  }
}

enum DivoomCustomChannel {
  page0,
  page1,
  page2,
}
