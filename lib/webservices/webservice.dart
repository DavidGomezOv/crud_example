import 'dart:convert';
import 'package:crud_example/database/sqflite_helper.dart';
import 'package:crud_example/model/users_model.dart';
import 'package:http/http.dart' as http;

class WebService {

  List<UserData> _listUsers = [];
  String _baseUrl = "https://605c95166d85de00170da8da.mockapi.io/api/users";

  Future<List<UserData>> getData() async {
    var response = await http.get(Uri.parse(_baseUrl)).timeout(Duration(seconds: 30));
    var json = jsonDecode(response.body);

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

    return _listUsers;
  }

  Future<bool> createUser(UserData userData) async {
    Map<String, dynamic> datos = {
      'name' : userData.name,
      'lastname' : userData.last_name,
      'age' : userData.age,
      'birthday' : userData.birthday,
      'address' : userData.address
    };

    var response = await http.post(Uri.parse(_baseUrl), headers: {'Content-Type': 'application/json'}, body: jsonEncode(datos)).timeout(Duration(seconds: 30));
    var json = jsonDecode(response.body);

    UserData usersDataRecive = UserData.fromJson(json);

    if (usersDataRecive.name == userData.name) {
      return true;
    } else {
      return false;
    }

  }

  Future<bool> deleteUser(int id) async {
    var response = await http.delete(Uri.parse(_baseUrl + "/$id")).timeout(Duration(seconds: 30));
    var json = jsonDecode(response.body);

    UserData usersData = UserData.fromJson(json);

    if (usersData.id == id) {
      return true;
    } else {
      return false;
    }

  }

}