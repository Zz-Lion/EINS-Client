import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eins_client/constants/color_constant.dart';
import 'package:eins_client/constants/db_constant.dart';
import 'package:eins_client/models/filter_model.dart';
import 'package:eins_client/providers/local_storage_provider.dart';
import 'package:eins_client/providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MyFilterProvider with ChangeNotifier {
  MyFilterProvider({required this.productProv, required this.localStorageProv});

  final ProductProvider productProv;
  final LocalStorageProvider localStorageProv;

  List<FilterModel> _filters = <FilterModel>[];
  int _length = 0;

  List<FilterModel> get filters => _filters;
  int get length => _length;

  void initFilter() {
    _filters = localStorageProv.fetchData();
    _length = _filters.length;

    notifyListeners();
  }

  Future<void> addFilter(BuildContext context, String id, int index) async {
    DocumentSnapshot<Map<String, dynamic>> filterData =
        await filtersRef.doc(id).get();

    if (filterData.exists == false) {
      throw "등록되지 않은 필터입니다.";
    }

    if (filterData.data()!["start_date"] == null) {
      final int num;

      try {
        num = await showModalBottomSheet(
          enableDrag: false,
          context: context,
          builder: (context) => SafeArea(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    "필터를 사용하시는 환경을 설정해주세요.",
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _bottomSheetButton(context,
                        text: "3인 이하 가정집", icon: Icons.home_filled, num: 0),
                    _bottomSheetButton(context,
                        text: "4인 이상 가정집", icon: Icons.home_filled, num: 1),
                    _bottomSheetButton(context,
                        text: "사무실", icon: Icons.home_filled, num: 2),
                  ],
                ),
              ],
            ),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
        );
      } catch (e) {
        throw "필터를 사용하시는 환경을 설정해주세요.";
      }

      Map<String, dynamic> tempDoc = <String, dynamic>{};
      DateTime startDate = DateTime.now();
      DateTime replaceDate = startDate.add(Duration(
          days: (30 *
                  productProv.productDefaultDurationByName(
                      filterData.data()!["product_name"] as String)![num])
              .toInt()));

      tempDoc.addAll(filterData.data()!);
      tempDoc.addAll({
        "id": id,
        "start_date": Timestamp.fromDate(startDate),
        "replace_date": Timestamp.fromDate(replaceDate),
        "desc": "나의 " + (filterData.data()!["product_name"] as String),
      });

      await filtersRef.doc(id).set(tempDoc);

      final DocumentSnapshot<Map<String, dynamic>> newFilterData;

      newFilterData = await filtersRef.doc(id).get();

      filterData = newFilterData;
    }

    _filters.insert(index, FilterModel.fromDoc(filterData));
    _length++;
    await localStorageProv.saveData(_filters);

    notifyListeners();
  }

  Future<void> editFilter(int index, String desc) async {
    final FilterModel tempFilter = _filters[index];

    try {
      _filters[index] = tempFilter.copyWith(desc: desc);

      await filtersRef.doc(_filters[index].id).set(tempFilter.toDoc());

      await localStorageProv.saveData(_filters);

      notifyListeners();
    } catch (e) {
      _filters[index] = tempFilter;
      rethrow;
    }
  }

  Future<void> deleteFilter(int index) async {
    _filters.removeAt(index);

    _length--;

    await localStorageProv.saveData(_filters);

    dailyAtTimeNotification();

    notifyListeners();
  }

  int? findIndex(String id) {
    for (int i = 0; i < _filters.length; i++)
      if (_filters[i].id == id) return i;

    return null;
  }

  Future<void> dailyAtTimeNotification() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    final bool? result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    if (result == true || Platform.isAndroid) {
      await deleteNotification();

      final String notiTitle = "필터 교체 알림";
      late String notiDesc;
      for (int i = 0; i < _length; i++) {
        notiDesc = "${_filters[i].desc} 교체일입니다. 필터를 교체해주세요!";

        AndroidNotificationDetails android = AndroidNotificationDetails(
            "eins", notiTitle, notiDesc,
            importance: Importance.max, priority: Priority.max);
        IOSNotificationDetails ios = IOSNotificationDetails();
        NotificationDetails detail =
            NotificationDetails(android: android, iOS: ios);

        await flutterLocalNotificationsPlugin.zonedSchedule(
          0,
          notiTitle,
          notiDesc,
          _setNotiTime(i, 0),
          detail,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );

        if (_filters[i].replaceDate.difference(DateTime.now()).inDays >= 7) {
          notiDesc = "${_filters[i].desc} 교체일이 7일 남았습니다.";

          android = AndroidNotificationDetails("eins", notiTitle, notiDesc,
              importance: Importance.max, priority: Priority.max);
          ios = IOSNotificationDetails();
          detail = NotificationDetails(android: android, iOS: ios);

          await flutterLocalNotificationsPlugin.zonedSchedule(
            0,
            notiTitle,
            notiDesc,
            _setNotiTime(i, 7),
            detail,
            androidAllowWhileIdle: true,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        }
        if (_filters[i].replaceDate.difference(DateTime.now()).inDays >= 30) {
          notiDesc = "${_filters[i].desc}  교체일이 30일 남았습니다.";

          android = AndroidNotificationDetails("eins", notiTitle, notiDesc,
              importance: Importance.max, priority: Priority.max);
          ios = IOSNotificationDetails();
          detail = NotificationDetails(android: android, iOS: ios);

          await flutterLocalNotificationsPlugin.zonedSchedule(
            0,
            notiTitle,
            notiDesc,
            _setNotiTime(i, 30),
            detail,
            androidAllowWhileIdle: true,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        }
      }
    } else {
      throw "알림 설정 권한이 없습니다.";
    }
  }

  Future<void> deleteNotification() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.deleteNotificationChannelGroup("eins");
  }

  tz.TZDateTime _setNotiTime(int index, int day) {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    DateTime temp = _filters[index].replaceDate.subtract(Duration(days: day));

    tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, temp.year, temp.month, temp.day, temp.hour, temp.minute);

    return scheduledDate;
  }
}

Widget _bottomSheetButton(BuildContext context,
    {required String text, required IconData icon, required int num}) {
  return Padding(
    padding: const EdgeInsets.all(10),
    child: InkWell(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.25,
        height: MediaQuery.of(context).size.width * 0.25,
        decoration: BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              color: kBackgroundColor,
            ),
            Text(
              text,
              style: TextStyle(fontSize: 12, color: kBackgroundColor),
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context).pop(num);
      },
    ),
  );
}
