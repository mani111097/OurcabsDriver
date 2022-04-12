import 'package:firebase_database/firebase_database.dart';

class Drivers {
  String name;
  String phone;
  String car_name;
  String id;
  String ppic;
  String carType;
  String car_color;
  String car_model;
  String car_number;

  Drivers({
    this.name,
    this.phone,
    this.id,
    this.ppic,
    this.carType,
    this.car_color,
    this.car_name,
    this.car_model,
    this.car_number,
  });

  Drivers.fromSnapshot(DataSnapshot dataSnapshot) {
    id = dataSnapshot.key;
    phone = dataSnapshot.value["Phone"];
    ppic = dataSnapshot.value["ppic"];
    name = dataSnapshot.value["Name"];
    carType = dataSnapshot.value["type"];
    car_color = dataSnapshot.value["CColor"];
    car_name = dataSnapshot.value["CName"];
    //car_model = dataSnapshot.value["CModel"];
    car_number = dataSnapshot.value["Rno"];
  }
}
