import 'package:hive/hive.dart';

part 'vehicle.g.dart';

@HiveType(typeId: 1, adapterName: 'VehicleAdapter')
class Vehicle {
  @HiveField(0)
  String? name;
  @HiveField(1)
  String? imagePath;
  @HiveField(2)
  String? audioPath;

  Vehicle({this.name, this.imagePath, this.audioPath});

  Vehicle.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    imagePath = json['imagePath'];
    audioPath = json['audioPath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['name'] = name;
    data['imagePath'] = imagePath;
    data['audioPath'] = audioPath;
    return data;
  }
}
