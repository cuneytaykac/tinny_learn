import 'package:hive/hive.dart';

part 'animals.g.dart';

@HiveType(typeId: 0, adapterName: 'AnimalAdapter')
class Animal {
  @HiveField(0)
  String? name;
  @HiveField(1)
  String? imagePath;
  @HiveField(2)
  String? audioPath;

  Animal({this.name, this.imagePath, this.audioPath});

  Animal.fromJson(Map<String, dynamic> json) {
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
