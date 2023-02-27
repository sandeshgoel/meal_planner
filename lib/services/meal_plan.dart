class MealPlan {
  late String name;
  late String creator;
  late DateTime createTime;
  late List<String> admins;
  late List<String> members;
  late List<String> viewers;

  DateTime defDate = DateTime(2023);

  MealPlan(
      {String name = 'default',
      String creator = '',
      DateTime? createTime,
      List<String> admins = const [],
      List<String> members = const [],
      List<String> viewers = const []}) {
    this.name = name;
    this.creator = creator;
    this.createTime = createTime ?? DateTime.now();
    this.admins = admins;
    this.members = members;
    this.viewers = viewers;
  }

  MealPlan.fromJson(Map<String, dynamic> jval) {
    this.name = jval['name'] ?? '';
    this.creator = jval['creator'] ?? '';
    this.createTime = jval['createTime'].toDate();
    this.admins = (jval['admins'] as List).map((x) => x as String).toList();
    this.members = (jval['members'] as List).map((x) => x as String).toList();
    this.viewers = (jval['viewers'] as List).map((x) => x as String).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'name': this.name,
      'creator': this.creator,
      'createTime': this.createTime,
      'admins': this.admins,
      'members': this.members,
      'viewers': this.viewers,
    };
  }
}

class MealPlanData {}
