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

class Meal {
  late String label;
  late String display_name;

  Meal({label = '', display_name = ''}) {
    this.label = label;
    this.display_name = display_name;
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
