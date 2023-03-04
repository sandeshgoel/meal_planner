import 'package:flutter/foundation.dart';

class MealPlan {
  late String name;
  late String creator;
  late DateTime createTime;
  late List<String> admins;
  late List<String> members;
  late List<String> viewers;

  DateTime defDate = DateTime(2023);

  MealPlan(
      {required String name,
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

class MealPlanData {
  late String mpid;
  late DateTime date;

  late String breakfast;
  late String lunch;
  late String dinner;

  MealPlanData(
      {required String mpid,
      required DateTime date,
      String breakfast = '',
      String lunch = '',
      String dinner = ''}) {
    this.mpid = mpid;
    this.date = date;
    this.breakfast = breakfast;
    this.lunch = lunch;
    this.dinner = dinner;
  }

  MealPlanData.fromJson(jval) {
    this.mpid = jval['mpid'];
    this.date = jval['date'].toDate();
    this.breakfast = jval['breakfast'];
    this.lunch = jval['lunch'];
    this.dinner = jval['dinner'];
  }

  Map<String, dynamic> toJson() {
    return {
      'mpid': this.mpid,
      'date': this.date,
      'breakfast': this.breakfast,
      'lunch': this.lunch,
      'dinner': this.dinner,
    };
  }
}

enum MealCategory { dal, veg, snack }

String displayCategory(MealCategory category) {
  switch (category) {
    case MealCategory.dal:
      return 'Dal';
    case MealCategory.veg:
      return 'Veg/Curry';
    case MealCategory.snack:
      return 'Snack';
    default:
      return 'Not found';
  }
}

// reverse of describe enum
MealCategory strToCategory(String c) {
  MealCategory res = MealCategory.values.firstWhere((e) => describeEnum(e) == c,
      orElse: () => MealCategory.snack);
  return res;
}

class Meal {
  late String label;
  late String display_name;
  late MealCategory category;

  Meal({required label, required display_name, required category}) {
    this.label = label;
    this.display_name = display_name;
    this.category = category;
  }

  Meal.fromJson(jval) {
    this.label = jval['label'];
    this.display_name = jval['name'];
    this.category =
        strToCategory(jval['category'] ?? describeEnum(MealCategory.snack));
  }

  Map<String, dynamic> toJson() {
    return {
      'label': this.label,
      'name': this.display_name,
      'category': describeEnum(this.category),
    };
  }
}

class DayMeal {
  late String breakfast;
  late String lunch;
  late String dinner;

  DayMeal(this.breakfast, this.lunch, this.dinner);

  bool equalTo(DayMeal other) {
    if ((breakfast == other.breakfast) &
        (lunch == other.lunch) &
        (dinner == other.dinner))
      return true;
    else
      return false;
  }

  String toString() {
    return '$breakfast,$lunch,$dinner';
  }

  DayMeal copy() {
    return DayMeal(breakfast, lunch, dinner);
  }
}
