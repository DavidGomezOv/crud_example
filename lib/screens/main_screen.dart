import 'package:crud_example/blocs/main_bloc.dart';
import 'package:crud_example/database/sqflite_helper.dart';
import 'package:crud_example/model/users_model.dart';
import 'package:crud_example/screens/add_edit_user.dart';
import 'package:crud_example/webservice/webservice.dart';
import 'package:flutter/material.dart';

const String ADD_USER_SCREEN = 'Agregar Usuario';
const String EDIT_USER_SCREEN = 'Editar Usuario';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  List<UserData> _listUsers = [];
  WebService webService = new WebService();
  SqfliteHelper sqfliteHelper = new SqfliteHelper();

  MainBloc _mainBloc = MainBloc();

  @override
  void initState() {
    super.initState();
    _mainBloc.sendEvent.add(ListUsers());
  }

  @override
  void dispose() {
    _mainBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de usuarios"),
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: RefreshIndicator(
          child: _validateListSizeMB(_listUsers.length),
          onRefresh: () {
            setState(() {
              _listUsers.clear();
            });
            _mainBloc.sendEvent.add(ListUsers());
            return Future.value(true);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.person_add),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddEditUser(
                  typeScreen: ADD_USER_SCREEN,
                  userData: null,
                ),
              )).then((value) {
            _mainBloc.sendEvent.add(ListUsers());
          });
        },
      ),
    );
  }

  Widget _createItem(int index, BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: Colors.lightBlueAccent),
        margin: EdgeInsets.symmetric(vertical: 5.0),
        child: ListTile(
          title: Text(_listUsers[index].name),
          subtitle: Text(_listUsers[index].last_name),
        ),
      ),
      confirmDismiss: (direction) => _showDialog(index, context, direction),
      background: _showContainerDismissible(
          Colors.red,
          Icon(
            Icons.delete,
            color: Colors.white,
          ),
          "Eliminar",
          AlignmentDirectional.centerStart),
      secondaryBackground: _showContainerDismissible(
          Colors.orange,
          Icon(
            Icons.edit,
            color: Colors.white,
          ),
          "Actualizar",
          AlignmentDirectional.centerEnd),
    );
  }

  Future<bool> _showDialog(
      int index, BuildContext context, DismissDirection direction) async {
    String _action;
    int actualId = _listUsers[index].id;
    if (direction == DismissDirection.startToEnd) {
      _action = "eliminar";
    } else {
      _action = "actualizar";
    }
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Advertencia!"),
          content: Text("Desea $_action el usuario ${_listUsers[index].name}?"),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: Text("Aceptar"),
              onPressed: () {
                if (direction == DismissDirection.endToStart) {
                  Navigator.pop(context, false);
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => AddEditUser(
                      typeScreen: EDIT_USER_SCREEN,
                      userData: _listUsers[index],
                    ),)).then((value) => _mainBloc.sendEvent.add(ListUsers()));
                } else {
                  _mainBloc.sendEvent.add(DeleteUser(actualId, context));
                  _mainBloc.isDeletedUser.listen((event) {
                    if (event) {
                      setState(() {
                        _listUsers.removeAt(index);
                      });
                    }
                    _mainBloc.sendEvent.add(ListUsers());
                    Navigator.pop(context, event);
                  });
                }
              },
            )
          ],
        );
      },
    );
  }

  Widget _showContainerDismissible(
      Color color, Icon icon, String title, AlignmentDirectional alignment) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 5.0),
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        alignment: alignment,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0), color: color),
        child: Wrap(
          children: [
            icon,
            SizedBox(
              width: 10.0,
            ),
            Text(
              title,
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            )
          ],
        ));
  }

  Widget _validateListSizeMB(int size) {
    return StreamBuilder(
        stream: _mainBloc.list,
        builder: (context, snapshot) {
          _listUsers = snapshot.data == null ? [] : snapshot.data;
          if (_listUsers.isEmpty) {
            return Center(
              child: Text("No existen usuarios"),
            );
          } else {
            return ListView.builder(
              itemCount: _listUsers.length,
              itemBuilder: (context, index) {
                return _createItem(index, context);
              },
            );
          }
        });
  }

}
