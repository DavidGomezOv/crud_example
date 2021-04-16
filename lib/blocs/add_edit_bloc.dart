import 'dart:async';

import 'package:crud_example/model/users_model.dart';
import 'package:crud_example/webservice/web_service_response.dart';
import 'package:crud_example/webservice/web_service.dart';
import 'package:rxdart/rxdart.dart';

class AddEditBloc {

  Stream<WebServiceResponse> get finishEvent => _finishEventSubject.stream;
  final _finishEventSubject = BehaviorSubject<WebServiceResponse>();

  WebService webService;

  AddEditBloc(this.webService);


  Future<WebServiceResponse> addOrEditUser(UserData userData, bool isAdd) async {
    return await webService.addOrUpdateUser(userData, isAdd).then((value) {
      _finishEventSubject.add(value);
      return value;
    });
  }

  void dispose() {
    _finishEventSubject.close();
  }

}
