class UserData {

  int id;
  String name;
  int age;
  String lastName;
  String birthday;
  String address;

  UserData({this.id, this.name, this.age, this.lastName, this.birthday, this.address});

  UserData.fromJson(Map<String, dynamic> json_map) {
    id =  int.parse(json_map['id']);
    name = json_map['name'];
    age = json_map['age'];
    lastName = json_map['lastname'];
    birthday = json_map['birthday'].toString();
    address = json_map['address'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'name' : name,
      'age' : age,
      'lastname' : lastName,
      'birthday' : birthday,
      'address' : address,
    };
  }

}