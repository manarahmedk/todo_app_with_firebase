import 'package:cloud_firestore/cloud_firestore.dart';

class TodoFire {
  DocumentReference? id;
  String? title;
  String? description;
  String? startDate;
  String? endDate;
  String? status;
  String? userId;
  String? image;

  TodoFire({
    this.id,
    this.title,
    this.description,
    this.startDate,
    this.endDate,
    this.status,
    this.userId,
    this.image,
  });

  TodoFire.fromJson(Map<String, dynamic> json ,{required this.id}) {
    title = json['title'];
    description = json['description'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    status = json['status'];
    userId=json['user_id'];
    image=json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['description'] = description;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['status'] = status;
    data['user_id']=userId;
    data['image']=image;
    return data;
  }
}
