import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio_logger/dio_logger.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:mess_app_staff/utils/constants.dart';

class API {
  final Dio dio = Dio();

  static const baseUrl = STRINGS.serverUrl;
  late CookieJar cookieJar;

  API(Directory dir) {
    cookieJar = PersistCookieJar(storage: FileStorage(dir.path));
    dio.interceptors.add(CookieManager(cookieJar));
    dio.interceptors.add(RetryInterceptor(
      dio: dio,
      logPrint: print, // specify log function (optional)
      retries: 3, // retry count (optional)
      retryDelays: const [
        Duration(seconds: 1), // wait 1 sec before first retry
        Duration(seconds: 2), // wait 2 sec before second retry
        Duration(seconds: 3), // wait 3 sec before third retry
      ],
    ));
    dio.interceptors.add(dioLoggerInterceptor);
  }

  Future<bool> isAuthenticated() async {
    final cookies = await PersistCookieJar().loadForRequest(Uri.parse(baseUrl));
    return cookies.isNotEmpty;
  }

  Future<dynamic> login(String kerberos, String password) async {
    final response = await dio.post('$baseUrl/auth/login', data: {
      'kerberos': kerberos,
      'password': password,
    });
    if (response.statusCode == 201) {
      return response.data;
      /*
      {
        "id": String,
        "kerberos": String,
        "isManager": bool,
        "name": String,
        "role": String,
        "messNames": String[],
      }
      */
    } else {
      await logout();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final response = await dio.post('$baseUrl/auth/logout');
    } catch (e) {
      print(e);
    }
    await cookieJar.delete(Uri.parse(baseUrl));
  }

  Future<dynamic> myProfile() async {
    final response = await dio.get('$baseUrl/auth/myProfile');
    if (response.statusCode == 200) {
      return response.data;
      /*
      {
        "_id": String,
        "kerberos": String,
        "password_hash": String,
        "name": String,
        "role": String,
        "isManager": bool
      }
      */
    } else {
      await logout();
      return false;
    }
  }

  Future<dynamic> verifyToken(String kerberos, String token) async {
    final response = await dio
        .get("$baseUrl/staff/verifyToken?kerberos=$kerberos&token=$token");
    if (response.statusCode == 200) {
      return response.data;
      /*
      {
        "token": {
            "_id": String,
            "user_id": {
                "_id": String,
                "kerberos": String,
                "name": String,
                "hostel": String,
                "isActive": bool,
                "__v": 0
            },
            "token": String,
            "created_time": Date,
            "isActive": String,
            "scope": String,
            "__v": 0
        },
        "active_meals": [
          {
            "_id": String,
            "user_id": String,
            "meal_id": String,
            "status": "BOOKED" | "USED",
            "enter_time": DATE?
            "__v": 0
          }
        ]
      }
      */
    } else {
      return false;
    }
  }

  Future<dynamic> verifyWithoutToken(String kerberos) async {
    final response =
        await dio.get("$baseUrl/staff/verifyWithoutToken?kerberos=$kerberos");
    if (response.statusCode == 200) {
      return response.data;
    } else {
      return false;
    }
  }

  Future<dynamic> getMealTokens(String kerberos) async {
    final response =
        await dio.get("$baseUrl/staff/getMealTokens?kerberos=$kerberos");
    if (response.statusCode == 200) {
      return response.data;
      /*
        [
          {
              "_id": String,
              "user_id": String,
              "meal_id": {
                  "_id": String,
                  "mess": "UDAIGIRI",
                  "name": String,
                  "start_time": Date,
                  "end_time": Date,
                  "capacity": number,
                  "price": number,
                  "__v": 0
              },
              "status": "BOOKED" | "USED",
              "enter_time": DATE?
              "__v": 0
          }
        ]
      */
    } else {
      return false;
    }
  }

  Future<dynamic> useMealToken(String tokenId) async {
    final response = await dio.post('$baseUrl/staff/useMealToken', data: {
      'token_id': tokenId,
    });
    if (response.statusCode == 201) {
      return response.data;
      /*
        {
          "_id": String,
          "user_id": String,
          "meal_id": String,
          "status": "USED",
          "__v": 0,
          "enter_time": Date
        }
      */
    } else {
      return false;
    }
  }
}
