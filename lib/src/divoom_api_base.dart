import 'dart:async';
import 'dart:io';

import 'package:divoom_api/src/model/divoom_device.dart';
import 'package:divoom_api/src/utils/network_utils.dart';

class DivoomDetector {
  const DivoomDetector._();

  static Stream<DivoomDevice> detectDevicesOnNetwork(String baseIp) {
    final StreamController<DivoomDevice> out = StreamController<DivoomDevice>();

    NetworkUtils.discoverOnlineDevices(baseIp, 80).listen(
      (DiscoverableNetworkAddress device) async {
        print('${DateTime.now()} New device ${device}');
        if (await _hasDivoomAPI(device.ip) == true) {
          print('${DateTime.now()} New device OK ${device}');
          out.add(DivoomDevice(device));
        }
      },
    );

    return out.stream;
  }

  static Stream<DivoomDevice> detectDevicesOnAnyNetwork() {
    final StreamController<DivoomDevice> out = StreamController<DivoomDevice>();

    print('Start');

    // List all network interfaces
    NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLinkLocal: true,
    ).then((List<NetworkInterface> interfaces) {
      print('End');

      List<Future> futures = [];
      Set<DiscoverableNetworkAddress> addresses = {};

      for (NetworkInterface interface in interfaces) {
        String myIp = interface.addresses.first.address;
        List<String> baseIpParts = myIp.split('.');
        String ip = '${baseIpParts[0]}.${baseIpParts[1]}.${baseIpParts[2]}';

        futures.add(NetworkUtils.discoverOnlineDevices(ip, 80)
            .forEach((DiscoverableNetworkAddress element) {
          addresses.add(element);
        }));
      }

      Future.wait(futures).then((_) {
        print(addresses);
        Set<Future<NetworkAddress>> futures = {};

        // List all devices with the Divoom API
        for (DiscoverableNetworkAddress element in addresses) {
          futures.add(_hasDivoomAPI(element.ip).then(
            (value) => NetworkAddress(element.ip, value),
          ));
        }

        /*Future.wait<NetworkAddress>(futures)
            .then<void>((List<NetworkAddress> sockets) {
          for (NetworkAddress device in sockets) {
            if (device.exists) {
              out.sink.add(DivoomDevice(device));
            }
          }

          out.close();
        }).catchError((_) => out.close());*/
      });
    });

    return out.stream;
  }

  static Future<bool> _hasDivoomAPI(
    String ip, {
    Duration timeout = const Duration(seconds: 5),
  }) {
    return NetworkUtils.sendDivoomDeviceAPIRequest(
      ip,
      timeout: timeout,
    );
  }
}

class NetworkAddress {
  final String ip;
  final bool exists;

  NetworkAddress(this.ip, this.exists);

  @override
  String toString() {
    return 'NetworkAddress{exists: $exists, ip: $ip}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkAddress &&
          runtimeType == other.runtimeType &&
          ip == other.ip &&
          exists == other.exists;

  @override
  int get hashCode => ip.hashCode ^ exists.hashCode;
}
