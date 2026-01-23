import 'package:hive/hive.dart';

part 'response_color.g.dart';

@HiveType(typeId: 2, adapterName: 'ResponseColorAdapter')
class ResponseColor {
  @HiveField(0)
  String? imagePath;

  ResponseColor({this.imagePath});

  ResponseColor.fromJson(Map<String, dynamic> json) {
    imagePath = json['imagePath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['imagePath'] = imagePath;
    return data;
  }
}
