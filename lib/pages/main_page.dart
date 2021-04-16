import 'package:crud_example/blocs/main_bloc.dart';
import 'package:crud_example/model/users_model.dart';
import 'package:crud_example/webservice/web_service_response.dart';
import 'package:crud_example/webservice/web_service.dart';
import 'package:flutter/material.dart';

import 'add_edit_user_page.dart';

const String ADD_USER_SCREEN = 'Agregar Usuario';
const String EDIT_USER_SCREEN = 'Editar Usuario';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<UserData> _listUsers = [];
  MainBloc _mainBloc;

  @override
  void initState() {
    super.initState();
    _mainBloc = MainBloc(new WebService());
    _mainBloc.listUser();
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
          child: _validateListSizeMB(),
          onRefresh: () async {
            setState(() {
              _listUsers.clear();
            });
            await _mainBloc.listUser();
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
            _mainBloc.listUser();
          });
        },
      ),
    );
  }

  Widget _validateListSizeMB() {
    return StreamBuilder<WebServiceResponse>(
        stream: _mainBloc.listUsers,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.errorMessage != null) {
              return _ShowErrorScreen(
                errorMsg: snapshot.data.errorMessage,
                onRefresh: () {
                  _mainBloc.listUser();
                  return Future.value(true);
                },
              );
            }
            if (snapshot.data.data.isEmpty) {
              if (snapshot.data.isLoading) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return _ShowErrorScreen(
                  errorMsg: 'No existen usuarios',
                  onRefresh: () {
                    _mainBloc.listUser();
                    return Future.value(true);
                  },
                );
              }
            } else {
              _listUsers = snapshot.data.data;
              return ListView.builder(
                itemCount: _listUsers.length,
                itemBuilder: (context, index) {
                  return _CreateItem(index: index, listUsers: _listUsers, mainBloc: _mainBloc,);
                },
              );
            }
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}

class _CreateItem extends StatelessWidget {
  final int index;
  final List<UserData> listUsers;
  final MainBloc mainBloc;
  const _CreateItem({@required this.index, @required this.listUsers, @required this.mainBloc});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: Colors.lightBlueAccent),
        margin: EdgeInsets.symmetric(vertical: 5.0),
        child: ListTile(
          title: Text(listUsers[index].name, style: TextStyle(fontSize: 16.0),),
          subtitle: Text(listUsers[index].lastName),
          trailing: Text("Edad: ${listUsers[index].age.toString()}"),
        ),
      ),
      confirmDismiss: (direction) => _showDialog(index, context, direction),
      background: _ShowContainerDismissible(
        color: Colors.red,
        icon: Icon(Icons.delete, color: Colors.white,),
        title: 'Eliminar',
        alignment: AlignmentDirectional.centerStart,
      ),
      secondaryBackground: _ShowContainerDismissible(
        color: Colors.orange,
        icon: Icon(Icons.edit, color: Colors.white,),
        title: 'Actualizar',
        alignment: AlignmentDirectional.centerEnd,
      ),
    );
  }

  Future<bool> _showDialog(
      int index, BuildContext context, DismissDirection direction) async {
    String _action;
    int actualId = listUsers[index].id;
    if (direction == DismissDirection.startToEnd) {
      _action = "eliminar";
    } else {
      _action = "actualizar";
    }
    return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Advertencia!"),
          content: Text("Desea $_action el usuario ${listUsers[index].name}?"),
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
                    builder: (context) =>
                        AddEditUser(
                          typeScreen: EDIT_USER_SCREEN,
                          userData: listUsers[index],
                        ),)).then((value) => mainBloc.listUser());
                } else {
                  mainBloc.deleteUser(actualId).then((event) {
                    if (event.data) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(
                            "Usuario eliminado exitosamente"),),
                      );
                      mainBloc.listUser();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(
                            "Error: ${event.errorMessage}"),),
                      );
                    }
                    Navigator.pop(context, event.data);
                  });
                }
              },
            )
          ],
        );
      },
    );
  }

}


class _ShowErrorScreen extends StatelessWidget {
  final String errorMsg;
  final Future<void> Function() onRefresh;
  const _ShowErrorScreen({@required this.errorMsg, @required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: RefreshIndicator(
            child: Stack(
              children: <Widget>[
                Center(child: Text(errorMsg),),
                ListView()
              ],
            ),
            onRefresh: onRefresh,
        )
    );
  }
}

class _ShowContainerDismissible extends StatelessWidget {
  final Color color;
  final Icon icon;
  final String title;
  final AlignmentDirectional alignment;
  const _ShowContainerDismissible({@required this.color, @required this.icon,
    @required this.title, @required this.alignment});

  @override
  Widget build(BuildContext context) {
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
        )
    );
  }
}


