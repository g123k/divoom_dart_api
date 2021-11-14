import 'package:divoom_api/src/utils/network_utils.dart';

export '../api/api.dart';

class DivoomDevice {
  final String address;

  DivoomDevice(DiscoverableNetworkAddress address) : address = address.ip;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DivoomDevice &&
          runtimeType == other.runtimeType &&
          address == other.address;

  @override
  int get hashCode => address.hashCode;
}
