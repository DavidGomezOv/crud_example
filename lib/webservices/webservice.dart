import 'dart:convert';
import 'package:crud_example/database/sqflite_helper.dart';
import 'package:crud_example/model/users_model.dart';
import 'package:http/http.dart' as http;

class WebService {

  List<Users_Data> _listUsers = [];
  String _baseUrl = "https://605c95166d85de00170da8da.mockapi.io/api/users";

  Future<List<Users_Data>> getData() async {
    var response = await http.get(Uri.parse(_baseUrl)).timeout(Duration(seconds: 30));
    var json = jsonDecode(response.body);

    for (var data in json) {
      SqfliteHelper().insertUser(Users_Data.fromJson(data));
    }

    _listUsers.clear();
    await SqfliteHelper().listUsers().then((value) {
      value.forEach((element) {
        _listUsers.add(element);
      });
    });

    return _listUsers;
  }

  Future<bool> deleteUser(int id) async {
    var response = await http.delete(Uri.parse(_baseUrl + "/$id")).timeout(Duration(seconds: 30));
    var json = jsonDecode(response.body);

    Users_Data usersData = Users_Data.fromJson(json);

    if (usersData.id == id) {
      return true;
    } else {
      return false;
    }

  }

}