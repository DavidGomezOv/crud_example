import 'package:age/age.dart';
import 'package:crud_example/model/users_model.dart';
import 'package:crud_example/screens/main_screen.dart';
import 'package:crud_example/webservices/webservice.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class AddEditUser extends StatefulWidget {

  String typeScreen;
  UserData userData;
  AddEditUser({this.typeScreen, this.userData});

  @override
  _AddEditUserState createState() => _AddEditUserState(typeScreen: typeScreen, userData: userData);
}

class _AddEditUserState extends State<AddEditUser> {

  String typeScreen;
  UserData userData;
  TextEditingController _editingControllerAge = new TextEditingController();
  TextEditingController _editingControllerDate = new TextEditingController();
  TextEditingController _editingControllerName = new TextEditingController();
  TextEditingController _editingControllerAddress = new TextEditingController();
  GlobalKey<FormState> _formKey =  new GlobalKey<FormState>();
  final FocusNode _focusNodeAddress = FocusNode();

  WebService webService = new WebService();

  _AddEditUserState({this.typeScreen, this.userData});

  @override
  void initState() {
    super.initState();
    if (userData != null) {
      _setUserData(userData);
    } else {
      userData = new UserData();
    }
  }

  @override
  void dispose() {
    _focusNodeAddress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(typeScreen),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            padding: EdgeInsets.all(25.0),
            child: Column(
              children: [
                _createInput(context, "Nombre", "Ingrese nombre y apellido", 30, Icons.person, true, _editingControllerName),
                _createInput(context, "Fecha de nacimiento", "Seleccione la fecha de nacimiento", 10, Icons.calendar_today, false, _editingControllerDate),
                _createInput(context, "Edad", "", null, Icons.person_pin_sharp, false, _editingControllerAge),
                _createInput(context, "Dirección", "Ingrese dirección de residencia", 50, Icons.house, true, _editingControllerAddress),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text(typeScreen.substring(0, typeScreen.indexOf(" "))),
        onPressed: () {
          if (_formKey.currentState.validate()) {
            if (_getInputData()) {
              _addEditUserAPI();
            }
          } else {
            _showSnackbar("Debe llenar todos los campos", context);
            FocusScope.of(context).requestFocus(new FocusNode());
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _addEditUserAPI() {
    if (typeScreen == ADD_USER_SCREEN) {
      webService.addOrUpdateUser(userData, true).then((value) {
        if (value) {
          _showSnackbar("Usuario creado exitosamente", context);
          Navigator.of(context).pop();
        } else {
          _showSnackbar("Error al crear usuario", context);
        }
        FocusScope.of(context).requestFocus(new FocusNode());
      });
    } else if (typeScreen == EDIT_USER_SCREEN) {
      webService.addOrUpdateUser(userData, false).then((value) {
        if (value) {
          _showSnackbar("Datos actualizados exitosamente", context);
          Navigator.of(context).pop();
        } else {
          _showSnackbar("Error al crear usuario", context);
        }
        FocusScope.of(context).requestFocus(new FocusNode());
      });
    }

  }

  Widget _createInput(BuildContext context, String title, String textInfo, int maxLength, IconData icon, bool isEnable, TextEditingController textEditingController) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: textEditingController,
        enabled: title != "Edad",
        focusNode: title == "Dirección" ? _focusNodeAddress : null,
        validator: (value) => value.isEmpty ? "Debe ingresar datos" : null,
        decoration: InputDecoration(
          hintText: title,
          labelText: title,
          helperText: textInfo,
          prefixIcon: Icon(icon),
          suffixIcon: isEnable ? Icon(Icons.edit) : null,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0)
          ),
        ),
        maxLength: maxLength,
        onEditingComplete: () => FocusScope.of(context).nextFocus(),
        onFieldSubmitted: (value) {
          if (title == "Nombre") {
            FocusScope.of(context).requestFocus(_focusNodeAddress);
          } else if (title == "Dirección") {
            FocusScope.of(context).requestFocus(new FocusNode());
          }
        },
        onTap: () {
          if (!isEnable) {
            FocusScope.of(context).requestFocus(new FocusNode());
            if (title.contains("Fecha")) _showSelectDate();
          }
        },
      ),
    );
  }

  void _showSelectDate() async {

    DateTime datePicked = await showDatePicker(
        context: context,
        initialDate: new DateTime(2001, 12, 31),
        firstDate: new DateTime(1900),
        lastDate: new DateTime(2001, 12, 31),
        locale: Locale("es", "ES")
    );

    if (datePicked != null) {

      AgeDuration age;
      age = Age.dateDifference(
          fromDate: new DateTime(datePicked.year, datePicked.month, datePicked.day),
          toDate: DateTime.now(),
          includeToDate: false
      );

      setState(() {
        userData.birthday = ("${datePicked.day}-${datePicked.month}-${datePicked.year}");
        userData.age = int.parse(age.years.toString());
        _editingControllerDate.text = userData.birthday;
        _editingControllerAge.text = userData.age.toString() + " años";
      });
    }

  }

  bool _getInputData() {

    String _name = _editingControllerName.text;

    if (_name.contains(" ") && _name.length > _name.indexOf(" ") + 1) {
      userData.name = _name.substring(0, _name.indexOf(" "));
      userData.last_name = _name.substring(_name.indexOf(" ") + 1);
      userData.address = _editingControllerAddress.text;
      return true;
    } else {
      _showSnackbar("Debe ingresar nombre y apellido", this.context);
      return false;
    }

  }

  void _showSnackbar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _setUserData(UserData userData) {
    _editingControllerName.text = userData.name + " " + userData.last_name;
    _editingControllerDate.text = userData.birthday;
    _editingControllerAge.text = userData.age.toString();
    _editingControllerAddress.text = userData.address;
  }

}
