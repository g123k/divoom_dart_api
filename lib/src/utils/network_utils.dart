import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;

import 'text_utils.dart';

class NetworkUtils {
  static final Map<String, dynamic> _validAPIResponse = {
    'error_code': 0,
  };

  const NetworkUtils._();

  static Future<Socket> ping(
    String host,
    int port, [
    Duration timeout = const Duration(seconds: 5),
  ]) {
    return Socket.connect(host, port, timeout: timeout);
  }

  static Stream<DiscoverableNetworkAddress> discoverOnlineDevices(
    String subnet,
    int port, {
    Duration timeout = const Duration(seconds: 5),
  }) {
    if (port < 1 || port > 65535) {
      throw 'Incorrect port';
    } else if (subnet.count('.') != 3) {
      throw 'Wrong subnet';
    }

    final StreamController<DiscoverableNetworkAddress> out =
        StreamController<DiscoverableNetworkAddress>();
    final List<Future<Socket>> futures = <Future<Socket>>[];
    List<String> parts = subnet.split('.');

    for (int i = 1; i < 256; ++i) {
      final String host = '${parts[0]}.${parts[1]}.${parts[2]}.$i';
      final Future<Socket> f = ping(host, port, timeout);
      futures.add(f);
      f.then((Socket socket) {
        print(socket.address);
        socket.destroy();
        out.sink.add(DiscoverableNetworkAddress._(host));
      }).catchError((_) {});
    }

    Future.wait<Socket>(futures)
        .then<void>((List<Socket> sockets) => out.close())
        .catchError((dynamic e) => out.close());

    return out.stream;
  }

  static Future<String> _sendAPIRequest(
    String url,
    Object body, {
    Duration timeout = const Duration(seconds: 5),
  }) {
    return http
        .post(
          Uri.parse(url),
          body: jsonEncode(body),
          headers: {
            "Content-type": "application/json",
          },
        )
        .timeout(timeout, onTimeout: () => http.Response('', 408))
        .then((http.Response value) {
          if (value.statusCode >= 200 && value.statusCode <= 299) {
            return value.body;
          } else {
            throw Exception(value.body);
          }
        });
  }

  static Future<bool> sendDivoomDeviceAPIRequest(
    String ip, {
    String? commandName,
    Map<String, dynamic>? extras,
    Duration timeout = const Duration(seconds: 5),
  }) {
    Map<String, dynamic> body = <String, dynamic>{};

    if (commandName?.isNotEmpty == true) {
      body['Command'] = commandName;
    }

    if (extras != null) {
      body.addAll(extras);
    }

    return NetworkUtils._sendAPIRequest(
      'http://$ip:80/post',
      body,
      timeout: timeout,
    )
        .then<bool>(
          (String value) => DeepCollectionEquality()
              .equals(jsonDecode(value), _validAPIResponse),
        )
        .catchError((_) => Future.value(false));
  }

  static Future<Object> sendDivoomPublicAPIRequest(
    String url,
    Object body, {
    Duration timeout = const Duration(seconds: 5),
  }) {
    return NetworkUtils._sendAPIRequest(
      'https://app.divoom-gz.com/$url',
      body,
      timeout: timeout,
    ).then((String value) => jsonDecode(value));
  }
}

class DiscoverableNetworkAddress {
  final String ip;

  DiscoverableNetworkAddress._(this.ip);

  @override
  String toString() {
    return 'DiscoverableNetworkAddress{ip: $ip}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscoverableNetworkAddress &&
          runtimeType == other.runtimeType &&
          ip == other.ip;

  @override
  int get hashCode => ip.hashCode;
}
