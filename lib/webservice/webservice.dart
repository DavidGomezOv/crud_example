import 'dart:convert';
import 'dart:io';
import 'package:crud_example/database/sqflite_helper.dart';
import 'package:crud_example/model/users_model.dart';
import 'package:crud_example/webservice/WebServiceResponse.dart';
import 'package:http/http.dart' as http;

class WebService {
  List<UserData> _listUsers = [];
  String _baseUrl = "https://605c95166d85de00170da8da.mockapi.io/api/users";

  Future<WebServiceResponse> getListUsers() async {

    bool isConnected = await checkInternetConnection();

    if (isConnected) {
      try {

        var response = await http.get(Uri.parse(_baseUrl)).timeout(Duration(seconds: 30));
        var json = jsonDecode(response.body);

        if (response.statusCode != 200) {
          return WebServiceResponse([], "Error");
        }

        await SqfliteHelper().deleteTableData();
        for (var data in json) {
          SqfliteHelper().insertUser(UserData.fromJson(data));
        }

        _listUsers.clear();
        await SqfliteHelper().listUsers().then((value) {
          value.forEach((element) {
            _listUsers.add(element);
          });
        });

        return WebServiceResponse(_listUsers, null);

      } on Exception {
        return WebServiceResponse([], "Error inesperado");
      }
    } else {

      _listUsers.clear();
      await SqfliteHelper().listUsers().then((value) {
        value.forEach((element) {
          _listUsers.add(element);
        });
      });

      return WebServiceResponse(_listUsers, null);

    }
  }

  Future<WebServiceResponse> deleteUser(int id) async {
    bool isConnected = await checkInternetConnection();

    if(isConnected) {
      try {

        var response = await http
            .delete(Uri.parse(_baseUrl + "/$id"))
            .timeout(Duration(seconds: 30));

        if (response.statusCode == 200) {
          return WebServiceResponse(true, null);
        } else {
          return WebServiceResponse(false, "Error");
        }

      } on Exception {
        return WebServiceResponse(false, "Error inesperado");
      }

    } else {
      return WebServiceResponse(false, "No hay conexión a internet");
    }


  }

  Future<WebServiceResponse> addOrUpdateUser(UserData userData, bool isAdd) async {

    bool isConnected = await checkInternetConnection();

    if(isConnected) {

      Map<String, dynamic> datos = {
        'name': userData.name,
        'lastname': userData.last_name,
        'age': userData.age,
        'birthday': userData.birthday,
        'address': userData.address
      };

      var response;
      if (isAdd) {
        response = await http
            .post(Uri.parse(_baseUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(datos))
            .timeout(Duration(seconds: 30));
      } else {
        response = await http
            .put(Uri.parse(_baseUrl + "/${userData.id}"),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(datos))
            .timeout(Duration(seconds: 30));
      }

      if ((response.statusCode == 201 && isAdd) || (response.statusCode == 200 && !isAdd)) {
        return WebServiceResponse(true, null);
      } else {
        return WebServiceResponse(false, "Error");
      }

    } else {
      return WebServiceResponse(false, "No hay conexión a internet");
    }
  }

  Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        return true;
      }
    } on SocketException catch (_) {
      print('not connected');
      return false;
    }
  }

}