import 'package:eins_client/providers/question_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuestionScreen extends StatefulWidget {
  static const String routeName = '/question';

  const QuestionScreen({Key? key}) : super(key: key);

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  late List<bool> _isOpen;

  @override
  void initState() {
    _isOpen = List<bool>.generate(
        context.read<QuestionProvider>().length, (index) => false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final QuestionProvider questionProv = context.read<QuestionProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(Icons.arrow_back_ios_rounded, color: Colors.black)),
        title: Text("자주 묻는 질문", style: TextStyle(color: Colors.black)),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView.builder(
            itemCount: questionProv.length,
            itemBuilder: (context, index) {
              return Column(
                children: <Widget>[
                  ListTile(
                    onTap: () {
                      setState(() {
                        _isOpen[index] = !_isOpen[index];
                      });
                    },
                    title: Text(
                      "Q. " + questionProv.questionList[index],
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                    trailing: Icon(_isOpen[index]
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down),
                  ),
                  _isOpen[index]
                      ? Container(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "A. ",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                              Flexible(
                                child: Text(
                                  questionProv.answerList[index]
                                      .replaceAll("\\n", "\n"),
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                  Divider(),
                ],
              );
            }),
      ),
    );
  }
}
