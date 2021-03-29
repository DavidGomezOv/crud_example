class Users_Data {

  int id;
  String name;
  int age;
  String last_name;
  String birthday;
  String address;

  Users_Data({this.id, this.name, this.age, this.last_name, this.birthday, this.address});

  Users_Data.fromJson(Map<String, dynamic> json_map) {
    id =  int.parse(json_map['id']);
    name = json_map['name'];
    age = json_map['age'];
    last_name = json_map['lastname'];
    birthday = json_map['birthday'].toString();
    address = json_map['address'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'name' : name,
      'age' : age,
      'lastname' : last_name,
      'birthday' : birthday,
      'address' : address,
    };
  }

}