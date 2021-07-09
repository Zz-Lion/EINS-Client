import 'package:eins_client/models/filter_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:localstorage/localstorage.dart';
import 'package:uuid/uuid.dart';

class LocalStorageProvider with ChangeNotifier {
  final LocalStorage _filterStorage = LocalStorage('eins_filter');
  final LocalStorage _uidStorage = LocalStorage('eins_uid');
  final LocalStorage _notificationStorage = LocalStorage('eins_notification');
  late final String uid;
  late bool _isNotificated;

  bool get isNotificated => _isNotificated;

  Future<void> initLocalStorage() async {
    bool isReady = (await _filterStorage.ready) &&
        (await _uidStorage.ready) &&
        (await _notificationStorage.ready);

    if (!isReady) {
      throw "로컬 저장소를 시작할 수 없습니다.";
    }

    var uidData = _uidStorage.getItem('eins_uid');

    if (uidData == null) {
      uid = Uuid().v4();

      await _uidStorage.setItem('eins_uid', uid);
    } else {
      uid = uidData as String;
    }

    var notificationData = _notificationStorage.getItem('eins_notification');

    _isNotificated = notificationData ?? false;
    await _uidStorage.setItem('eis_notification', _isNotificated);
  }

  List<FilterModel> fetchData() {
    try {
      var filterDatas = _filterStorage.getItem('eins_filter');

      if (filterDatas != null) {
        return List<FilterModel>.from(
            (filterDatas as List).map((e) => FilterModel(
                  id: e["id"],
                  productName: e["product_name"],
                  startDate: DateTime.parse(e["start_date"]),
                  replaceDate: DateTime.parse(e["replace_date"]),
                  desc: e["desc"],
                )));
      }

      return <FilterModel>[];
    } catch (e) {
      throw "로컬 저장소에서 불러올 수 없습니다.";
    }
  }

  Future<void> saveData(List<FilterModel> filters) async {
    try {
      await _filterStorage.setItem(
          'eins_filter', (filters.map((e) => e.toJson())).toList());
    } catch (e) {
      throw "로컬 저장소에 저장할 수 없습니다.";
    }
  }

  Future<void> toggleNotification() async {
    _isNotificated = !_isNotificated;
    await _uidStorage.setItem('eis_notification', _isNotificated);

    print(_isNotificated);

    notifyListeners();
  }

  void disposeLocalStorage() {
    _filterStorage.dispose();
    _uidStorage.dispose();
    _notificationStorage.dispose();
  }
}
