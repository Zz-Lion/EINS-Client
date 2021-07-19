import 'package:eins_client/models/chatting_model.dart';
import 'package:flutter/material.dart';

class ChattingItem extends StatelessWidget {
  const ChattingItem({Key? key, required this.chattingModel}) : super(key: key);

  final ChattingModel chattingModel;

  @override
  Widget build(BuildContext context) {
    final Size mediaSize = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.fromLTRB(chattingModel.isClient ? 80 : 0, 6,
          chattingModel.isClient ? 0 : 80, 6),
      child: Row(
        mainAxisAlignment: chattingModel.isClient
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Visibility(
            visible: !chattingModel.isClient,
            child: Container(
              width: 44,
              height: 44,
              margin: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  color: Colors.white),
              child: Image.asset(
                'assets/images/EINS_title.png',
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: chattingModel.isClient
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: <Widget>[
              Visibility(
                visible: !chattingModel.isClient,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 13),
                  child: Text(
                    "EINS 고객센터",
                    style: TextStyle(fontSize: 17, color: Colors.grey[600]),
                  ),
                ),
              ),
              Container(
                constraints: BoxConstraints(
                    maxWidth:
                        mediaSize.width - (chattingModel.isClient ? 90 : 140)),
                margin: EdgeInsets.symmetric(horizontal: 5),
                padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                decoration: BoxDecoration(
                    color: chattingModel.isClient
                        ? Colors.deepPurple[400]
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft:
                            Radius.circular(chattingModel.isClient ? 30 : 0),
                        topRight:
                            Radius.circular(chattingModel.isClient ? 0 : 30),
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30))),
                child: Text(
                  chattingModel.text,
                  softWrap: true,
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
