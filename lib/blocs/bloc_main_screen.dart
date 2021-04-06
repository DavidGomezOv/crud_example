
import 'dart:async';

import 'package:crud_example/model/users_model.dart';
import 'package:crud_example/webservice/webservice.dart';

class MainScreenBase {}

class ListUsers extends MainScreenBase {}

class MainScreenBloc {

  StreamController<MainScreenBase> _inputController = new StreamController();
  StreamController<List<UserData>> _outputController = new StreamController();

  Stream<List<UserData>> get listUsers => _outputController.stream;
  StreamSink<MainScreenBase> get sendEvent => _inputController.sink;

  MainScreenBloc() {
    _inputController.stream.listen(event);
  }

  void dispose() {
    _inputController.close();
    _outputController.close();
  }

  void event(MainScreenBase event) async {

    List<UserData> _listUsers = [];
    WebService webService = new WebService();

    if (event is ListUsers) {

      await webService.getData().then((value) {
          _listUsers.clear();
          _listUsers.addAll(value);
          _outputController.add(_listUsers);
      });

    }

  }

}