import 'dart:async';

import 'package:crud_example/webservice/WebServiceResponse.dart';
import 'package:crud_example/webservice/webservice.dart';
import 'package:rxdart/rxdart.dart';

class MainBloc {

  WebService webService;

  Stream<WebServiceResponse> get listUsers => _listUsersSubject.stream;
  final _listUsersSubject = BehaviorSubject<WebServiceResponse>();

  MainBloc(this.webService);

  void dispose() {
    _listUsersSubject.close();
  }

  Future<WebServiceResponse> listUser() {
    _listUsersSubject.add(new WebServiceResponse([], null, true));
    return webService.getListUsers().then((result) {
      _listUsersSubject.add(result);
      return result;
    });
  }

  Future<WebServiceResponse> deleteUser(int idUser) async {
    return await webService.deleteUser(idUser).then((result) {
      return result;
    });
  }

}