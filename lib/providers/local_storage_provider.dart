import 'package:eins_client/models/filter_model.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

class LocalStorageProvider with ChangeNotifier {
  final LocalStorage _storage = LocalStorage('eins_filter');

  Future<void> initLocalStorage() async {
    bool isReady = await _storage.ready;

    if (!isReady) {
      throw Exception("로컬 저장소를 시작할 수 없습니다.");
    }
  }

  List<FilterModel> fetchData() {
    try {
      var filterDatas = _storage.getItem("eins_filter");

      if (filterDatas != null) {
        return List<FilterModel>.from(
            (filterDatas as List).map((e) => FilterModel(
                  id: e["id"],
                  productName: e["product_name"],
                  defaultDuration: e["default_duration"],
                  startDate: DateTime.parse(e["start_date"]),
                  replaceDate: DateTime.parse(e["replace_date"]),
                  desc: e["desc"],
                )));
      }

      return <FilterModel>[];
    } catch (e) {
      throw Exception("로컬 저장소에서 불러올 수 없습니다.");
    }
  }

  Future<void> saveData(List<FilterModel> filters) async {
    try {
      await _storage.setItem(
          'eins_filter', (filters.map((e) => e.toJson())).toList());
    } catch (e) {
      throw Exception("로컬 저장소에 저장할 수 없습니다.");
    }
  }

  void disposeLocalStorage() {
    _storage.dispose();
  }
}
