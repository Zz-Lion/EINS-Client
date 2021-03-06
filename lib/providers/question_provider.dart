import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eins_client/constants/db_constant.dart';

class QuestionProvider {
  late final List<String> questionList;
  late final List<String> answerList;
  int? _length;

  int get length => _length ?? 0;

  Future<void> getQuestionInfo() async {
    List<String> tempQuestionList = <String>[];
    List<String> tempAnswerList = <String>[];

    try {
      final QuerySnapshot<Map<String, dynamic>> questionData =
          await questionRef.get();

      questionData.docs.forEach((element) {
        tempQuestionList.add(element.data()["question"]);
        tempAnswerList.add(element.data()["answer"]);
      });
    } catch (e) {
      throw "Q&A를 불러오지 못 하였습니다.";
    }

    questionList = tempQuestionList;
    answerList = tempAnswerList;
    _length = questionList.length;
  }
}
