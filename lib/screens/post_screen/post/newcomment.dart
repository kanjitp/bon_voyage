import 'package:flutter/material.dart';

class NewComment extends StatefulWidget {
  final Function addComment;

  NewComment(this.addComment);

  @override
  _NewCommentState createState() => _NewCommentState();
}

class _NewCommentState extends State<NewComment> {
  final _commentController = TextEditingController();

  void _submitComment() {
    if (_commentController.text.isEmpty) {
      return;
    }

    widget.addComment(_commentController.text);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return SingleChildScrollView(
      child: Card(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 20, bottom: 10),
                padding: EdgeInsets.symmetric(
                    horizontal: mediaQuery.size.width * 0.02),
                decoration: BoxDecoration(
                  color: Theme.of(context).splashColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                      hintText: 'Say something about this memory ...',
                      border: InputBorder.none),
                  controller: _commentController,
                  onSubmitted: (_) => _submitComment(),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 40, right: 20),
                child: RaisedButton(
                  child: Text('Post'),
                  onPressed: _submitComment,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
