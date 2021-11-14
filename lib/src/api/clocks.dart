import 'dart:collection';

import 'package:divoom_api/src/model/divoom_device.dart';
import 'package:divoom_api/src/utils/network_utils.dart';

class DivoomClocks {
  const DivoomClocks._();

  static Future<ClockCategories> listClockCategories() {
    return NetworkUtils.sendDivoomPublicAPIRequest('Channel/GetDialType', {})
        .then((Object value) {
      if (value is Map && value.containsKey('DialTypeList')) {
        List<ClockCategory> categories = <ClockCategory>[];

        for (String category in value['DialTypeList']) {
          categories.add(
            ClockCategory._(category),
          );
        }
        return ClockCategories._(categories);
      } else {
        throw Exception('An occured has occured!');
      }
    });
  }

  static Future<ClockFaces> listClocks(
    ClockCategory category, {
    int? page = 1,
  }) {
    assert((page ?? 1) > 0);

    return NetworkUtils.sendDivoomPublicAPIRequest('Channel/GetDialList', {
      'DialType': category.name,
      'Page': page,
    }).then((Object value) {
      if (value is Map && value.containsKey('DialList')) {
        List<ClockFace> faces = <ClockFace>[];

        for (Map clock in value['DialList']) {
          faces.add(
            ClockFace._(clock['ClockId'] as int, clock['Name'] as String),
          );
        }
        return ClockFaces._(category, faces);
      } else {
        throw Exception('An occured has occured!');
      }
    });
  }
}

extension ClocksAPIExtension on DivoomDevice {
  Future<bool> changeClockId(ClockFace clock) {
    return NetworkUtils.sendDivoomDeviceAPIRequest(
      address,
      commandName: 'Channel/SetClockSelectId',
      extras: {
        'ClockId': clock._id,
      },
    );
  }

  Future<ClockCategories> listClockCategories() {
    return DivoomClocks.listClockCategories();
  }

  Future<ClockFaces> listClocks(
    ClockCategory category, {
    int? page = 1,
  }) {
    return DivoomClocks.listClocks(
      category,
      page: page,
    );
  }
}

class ClockCategory {
  final String name;

  ClockCategory._(this.name);

  @override
  String toString() {
    return name;
  }
}

class ClockCategories with ListMixin<ClockCategory> {
  final List<ClockCategory> _categories = <ClockCategory>[];

  ClockCategories._(Iterable<ClockCategory> faces) {
    _categories.addAll(faces);
  }

  @override
  int get length => _categories.length;

  @override
  ClockCategory operator [](int index) => _categories[index];

  @override
  void operator []=(int index, ClockCategory value) =>
      throw UnimplementedError();

  @override
  set length(int newLength) => throw UnimplementedError();
}

class ClockFaces with ListMixin<ClockFace> {
  final ClockCategory category;
  final List<ClockFace> faces = <ClockFace>[];

  ClockFaces._(this.category, Iterable<ClockFace> faces) {
    this.faces.addAll(faces);
  }

  @override
  int get length => faces.length;

  @override
  ClockFace operator [](int index) => faces[index];

  @override
  void operator []=(int index, ClockFace value) => throw UnimplementedError();

  @override
  set length(int newLength) => throw UnimplementedError();
}

class ClockFace {
  final int _id;
  final String name;

  ClockFace._(this._id, this.name);
}
