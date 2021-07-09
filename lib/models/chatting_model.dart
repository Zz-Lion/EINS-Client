import 'package:cloud_firestore/cloud_firestore.dart';

class ChattingModel {
  ChattingModel(
      {required this.isClient, required this.text, required this.uploadTime});

  final bool isClient;
  final String text;
  final Timestamp uploadTime;

  factory ChattingModel.fromDoc(
      DocumentSnapshot<Map<String, dynamic>> chattingDoc) {
    final Map<String, dynamic> chattingData =
        Map<String, dynamic>.from(chattingDoc.data()!);

    return ChattingModel(
      isClient: chattingData["is_client"],
      text: chattingData["text"],
      uploadTime: chattingData["upload_time"],
    );
  }

  Map<String, dynamic> toDoc() {
    Map<String, dynamic> m = <String, dynamic>{};

    m["is_client"] = isClient;
    m["text"] = text;
    m["upload_time"] = uploadTime;

    return m;
  }
}
