import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eins_client/constants/db_constant.dart';
import 'package:eins_client/models/chatting_model.dart';
import 'package:eins_client/models/filter_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

class ChattingProgressState extends Equatable {
  ChattingProgressState({required this.loading});

  final bool loading;

  ChattingProgressState copyWith({bool? loading}) {
    return ChattingProgressState(loading: loading ?? this.loading);
  }

  @override
  List<Object?> get props => [loading];
}

class ChattingProvider with ChangeNotifier {
  ChattingProvider(this.uid);

  final String uid;

  ChattingProgressState state = ChattingProgressState(loading: false);

  List<ChattingModel> _chattingList = <ChattingModel>[];

  List<ChattingModel> get chattingList => _chattingList;

  Future<void> loadChatting() async {
    final DateTime now = DateTime.now();

    List<ChattingModel> tempChattingList = <ChattingModel>[];

    state = state.copyWith(loading: true);
    notifyListeners();

    try {
      final QuerySnapshot<Map<String, dynamic>> chattingData = await customerRef
          .doc(uid)
          .collection("chatting")
          .where("upload_time", isLessThan: Timestamp.fromDate(now))
          .orderBy("upload_time", descending: true)
          .get();

      tempChattingList =
          chattingData.docs.map((e) => ChattingModel.fromDoc(e)).toList();
    } catch (e) {
      state = state.copyWith(loading: false);
      notifyListeners();

      throw "고객센터 정보를 불러올 수 없습니다.";
    }

    _chattingList = tempChattingList;

    _chattingList.add(ChattingModel(
      isClient: false,
      text: "안녕하세요. EINS 고객센터 입니다.",
      uploadTime: Timestamp.now(),
    ));

    state = state.copyWith(loading: false);

    notifyListeners();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getSnapshot() {
    return customerRef
        .doc(uid)
        .collection("chatting")
        .limit(1)
        .orderBy("upload_time", descending: true)
        .snapshots();
  }

  void addChatting(ChattingModel chatting) {
    _chattingList.insert(0, chatting);

    notifyListeners();
  }

  Future<void> sendChatting(String text) async {
    final DateTime now = DateTime.now();

    state = state.copyWith(loading: true);
    notifyListeners();

    try {
      await customerRef
          .doc(uid)
          .collection("chatting")
          .doc(now.toString())
          .set(ChattingModel(
            isClient: true,
            text: text,
            uploadTime: Timestamp.fromDate(now),
          ).toDoc());

      state = state.copyWith(loading: false);
      notifyListeners();
    } catch (e) {
      state = state.copyWith(loading: false);
      notifyListeners();

      throw "전송에 실패하였습니다. 다시 시도해주세요.";
    }
  }

  Future<void> updateCustomerInfo(List<FilterModel> filters) async {
    List<String> temp = <String>[];

    filters.forEach((element) {
      temp.add(element.productName);
    });

    await customerRef.doc(uid).set({"products": temp});
  }
}
