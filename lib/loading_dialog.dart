import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  final String message;

  const LoadingDialog({
    Key key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _padding = EdgeInsets.all(24);
    var _children = <Widget>[CircularProgressIndicator()];

    if (message != null && message.isNotEmpty) {
      _padding = EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 16);
      _children.add(new Padding(
        padding: EdgeInsets.only(
          top: 20.0,
        ),
        child: new Text(
          message,
          style: new TextStyle(fontSize: 12.0),
        ),
      ));
    }

    return new Material(
      color: _getColor(context),
      type: MaterialType.transparency, //透明类型
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            decoration: ShapeDecoration(
              color: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
            ),
            padding: _padding,
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _children,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(BuildContext context) {
    return Theme.of(context).dialogBackgroundColor;
  }

  static show(BuildContext context, {String message}) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return LoadingDialog(message: message);
        });
  }

  static hide(BuildContext context) {
    Navigator.pop(context);
  }
}
