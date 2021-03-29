import 'package:flutter/material.dart';


class AddEditUser extends StatefulWidget {

  String typeScreen;
  AddEditUser({this.typeScreen});

  @override
  _AddEditUserState createState() => _AddEditUserState(typeScreen: typeScreen);
}

class _AddEditUserState extends State<AddEditUser> {

  String typeScreen;
  _AddEditUserState({this.typeScreen});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(typeScreen),
      ),
      body: ListView(
        padding: EdgeInsets.all(25.0),
        children: [
          _createInputs(context)
        ],
      ),
    );
  }

  Widget _createInputs(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: "Nombre",
        labelText: "Nombre",
        helperText: "Ingrese nombre y apellido",
        prefixIcon: Icon(Icons.person),
        suffixIcon: Icon(Icons.edit),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0)
        ),
      ),
      maxLength: 30,
      onEditingComplete: () => FocusScope.of(context).nextFocus(),
      textInputAction: TextInputAction.next,
      onChanged: (value) {
        setState(() {

        });
      },
    );
  }

}
