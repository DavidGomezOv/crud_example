import 'dart:async';

import 'package:crud_example/model/users_model.dart';
import 'package:crud_example/webservice/webservice.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class MainBase {}

class ListUsers extends MainBase {}

class DeleteUser extends MainBase {
  int idUser;
  BuildContext context;
  DeleteUser(this.idUser, this.context);
}

class MainBloc {

  StreamController<MainBase> _inputController = new StreamController();
  StreamSink<MainBase> get sendEvent => _inputController.sink;

  Stream<List<UserData>> get list => _listUsersSubject.stream;
  final _listUsersSubject = BehaviorSubject<List<UserData>>();

  StreamController<bool> _deletedUser = new StreamController();
  StreamSink<bool> get _inDeleted => _deletedUser.sink;
  Stream<bool> get isDeletedUser => _deletedUser.stream;

  MainBloc() {
    _inputController.stream.listen(_event);
  }

  void dispose() {
    _listUsersSubject.close();
    _inputController.close();
    _deletedUser.close();
  }


  void _event(MainBase event) async {

    List<UserData> _listUsers = [];
    WebService webService = new WebService();

    if (event is ListUsers) {

      await webService.getData().then((result) {
        _listUsers.clear();
        _listUsers.addAll(result);
        _listUsersSubject.add(_listUsers);
      });

    } else if (event is DeleteUser) {

      await webService.deleteUser(event.idUser).then((result) {
        Future.delayed(Duration(seconds: 2));
        _inDeleted.add(result);
        if (result) {
          ScaffoldMessenger.of(event.context).showSnackBar(
            SnackBar(content: Text("Usuario eliminado exitosamente"),),
          );
          return true;
        } else {
          ScaffoldMessenger.of(event.context).showSnackBar(
            SnackBar(content: Text("Error eliminando usuario (API)"),),
          );
          return false;
        }
      });

    }

  }
}