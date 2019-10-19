import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_widgets/entity/user_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Net {
  Dio _dio;

  factory Net() => instance;

  static final Net instance = Net._();

  // 私有构造器
  Net._() {
    _dio = Dio();

    // 基本配置
    _dio.options.baseUrl = 'https://www.wanandroid.com/';
    _dio.options.connectTimeout = 5000;
    _dio.options.receiveTimeout = 5000;

    // 拦截器
    _dio.interceptors
      ..add(
        InterceptorsWrapper(
          onRequest: (RequestOptions options) async {
            var prefs = await SharedPreferences.getInstance();
            var userJson = prefs.getString('user');
            if (userJson != null && userJson.isNotEmpty) {
              UserData user = UserData.fromJson(jsonDecode(userJson));
              options.headers
                ..addAll({
                  'userId': user.id ?? '',
                  'token': user.token ?? '',
                });
            }
            // 添加cookie
            var cookie = prefs.getString("login_cookies");
            if (cookie != null) {
              options.headers.addAll({"Cookie": cookie.toString()});
            }
            return options;
          },
          onResponse: (Response res) async {
            // 保存cookie
            var cookies = res.headers['Set-Cookie'];
            var prefs = await SharedPreferences.getInstance();
            if (cookies != null && cookies.isNotEmpty) {
              prefs.setString("login_cookies", cookies.toString());
            }
          },
        ),
      )
      ..add(LogInterceptor(requestBody: true, responseBody: true));

//    // 设置代理
//    var clientAdapter = (dio.httpClientAdapter as DefaultHttpClientAdapter);
//
//    clientAdapter.onHttpClientCreate = (HttpClient client) {
//      client.findProxy = (uri) {
//        //proxy all request to localhost:8888
//        return 'PROXY 192.168.10.82:8888';
//      };
//      client.badCertificateCallback =
//          (X509Certificate cert, String host, int port) => true;
//    };
  }

  Future post(String path, {data}) async {
    // 检测网络连接
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('网络错误～');
    }
    // 发起请求
    Response response = await dio.post(path, data: data);
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('服务器错误～');
    }
  }

  Future get(String path, {Map<String, dynamic> queryParameters}) async {
    // 检测网络连接
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('网络错误～');
    }
    // 发起请求
    Response response = await dio.get(path, queryParameters: queryParameters);
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('服务器错误～');
    }
  }

  Dio get dio {
    return _dio;
  }
}
