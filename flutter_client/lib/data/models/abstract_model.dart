abstract class AbstractModel {
  int? id;
  DateTime? createdAt;

  AbstractModel({this.id, this.createdAt});

  Map<String, dynamic> toJson();
}
