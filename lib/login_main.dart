import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_widgets/entity/user_entity.dart';
import 'package:flutter_widgets/list/project_list_page.dart';
import 'package:flutter_widgets/loading_dialog.dart';
import 'package:flutter_widgets/net/net.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  //去掉状态栏透明层
  if (Platform.isAndroid) {
    var style = SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(style);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: LoginPage(),
      // 解决输入框长按菜单仅英语问题
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[
        Locale('en', 'US'),
        Locale('zh', 'CH'),
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextStyle _blackStyle = const TextStyle(
    fontSize: 14,
    textBaseline: TextBaseline.alphabetic,
    color: Color(0xFF333333),
  );

  final TextStyle _whiteStyle = const TextStyle(
    fontSize: 14,
    color: Colors.white,
  );

  final TextStyle _blueStyle = const TextStyle(
    fontSize: 14,
    color: Colors.lightBlue,
  );

  final FocusNode _pwdFocus = FocusNode();
  final TextEditingController _accountController =
      TextEditingController(text: '13512341235');
  final TextEditingController _pwdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('登陆'),
        brightness: Brightness.light,
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
//      // 侧边栏
//      drawer: Drawer(
//        child: Column(
//          crossAxisAlignment: CrossAxisAlignment.start,
//          children: <Widget>[
//            SizedBox(
//              height: 200,
//              child: Container(
//                color: Colors.lightBlue,
//              ),
//            ),
//            Text('这是一个侧边栏演示'),
//          ],
//        ),
//      ),
      // SingleChildScrollView 包裹解决溢出问题，当然这是根据实际需求来，也可以通过设置 resizeToAvoidBottomInset 解决
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/img_head.jpg',
                  height: 100,
                  width: 100,
                ),
              ),
            ),
            TextField(
              style: _blackStyle,
              controller: _accountController,
              maxLength: 11,
              autofocus: false,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              onEditingComplete: () {
                FocusScope.of(context).requestFocus(_pwdFocus);
              },
              inputFormatters: [
                WhitelistingTextInputFormatter(RegExp("[0-9]"))
              ],
              decoration: const InputDecoration(
                icon: ImageIcon(
                  AssetImage('assets/images/ic_phone.png'),
                  size: 22,
                  color: Colors.grey,
                ),
                counterText: '',
                hintText: '请输入手机账号',
              ),
            ),
            SizedBox(height: 15),
            TextField(
              style: _blackStyle,
              controller: _pwdController,
              obscureText: true,
              maxLength: 20,
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.done,
              focusNode: _pwdFocus,
              inputFormatters: [
                BlacklistingTextInputFormatter(RegExp("[\u4e00-\u9fa5]"))
              ],
              decoration: const InputDecoration(
                icon: ImageIcon(
                  AssetImage('assets/images/ic_password.png'),
                  size: 22,
                  color: Colors.grey,
                ),
                counterText: '',
                hintText: '请输入密码',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                children: <Widget>[
                  Text.rich(TextSpan(
                      text: '登陆即同意',
                      children: [
                        TextSpan(
                          text: '《用户隐私协议》',
                          style: _blueStyle,
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => _showInfoDialog('这是用户隐私协议'),
                        ),
                      ],
                      style: _blackStyle)),
                  Spacer(),
                  Text(
                    '忘记密码？',
                    style: _blueStyle,
                  )
                ],
              ),
            ),
            SizedBox(height: 30),
            RaisedButton(
              color: Colors.lightBlue,
              onPressed: () {
                _doLogin();
              },
              child: Text(
                '登陆',
                style: _whiteStyle,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              alignment: Alignment.center,
              child: Text(
                '------------------  第三方登录  ------------------',
                style: _blackStyle,
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.asset(
                    'assets/images/ic_wx.png',
                    width: 50,
                    height: 50,
                  ),
                  SizedBox(width: 60),
                  Image.asset(
                    'assets/images/ic_qq.png',
                    width: 50,
                    height: 50,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _accountController.dispose();
    _pwdController.dispose();
    _pwdFocus.dispose();
    super.dispose();
  }

  void _showInfoDialog(String content) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          children: <Widget>[
            SimpleDialogOption(
              child: Text(content),
            )
          ],
        );
      },
    );
  }

  _doLogin() {
    LoadingDialog.show(context);
    Net.instance
        .post('user/login',
            data: FormData.fromMap({
              "username": _accountController.text.trim(),
              "password": _pwdController.text.trim(),
            }))
        .then((data) async {
      UserEntity user = UserEntity.fromJson(data);
      if (user.errorCode == 0) {
        //登录成功后 保存信息
        LoadingDialog.hide(context);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('user', jsonEncode(user.data));
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProjectListPage(),
          ),
        );
      } else {
        LoadingDialog.hide(context);
        _showInfoDialog('登录失败：${user.errorMsg}');
      }
    }).catchError((e) {
      print(e.toString());
    });
  }
}
