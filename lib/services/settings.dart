// ------------------------------------------------------

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:meal_planner/services/database.dart';
import 'package:meal_planner/services/meal_plan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserInfo {
  late String uid;
  late String email;
  late String name;
  late String photo;
  late bool verified;

  UserInfo() {
    initUser();
  }

  void initUser() {
    name = '';
    email = '';
    uid = '';
    photo = '';
    verified = false;
  }

  @override
  String toString() {
    return '{$name, $email, $verified, $uid, $photo}';
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'uid': uid,
      'photo': photo,
      'verified': verified,
    };
  }

  UserInfo.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    uid = json['uid'];
    photo = json['photo'];
    verified = json['verified'];
  }

  bool equals(UserInfo user) {
    if ((name == user.name) &
        (email == user.email) &
        (uid == user.uid) &
        (photo == user.photo) &
        (verified == user.verified)) {
      return true;
    } else {
      return false;
    }
  }
}

// ------------------------------------------------------
enum MpRole { admin, member, viewer }

class MealPlanRole {
  late String mpid;
  late MpRole mpRole;

  MealPlanRole(this.mpid, this.mpRole);

  Map<String, dynamic> toJson() {
    return {
      'mpid': this.mpid,
      'mpRole': describeEnum(this.mpRole),
    };
  }

  MealPlanRole.fromJson(Map<String, dynamic> jval) {
    this.mpid = jval['mpid'];
    this.mpRole = strToRole(jval['mpRole']);
  }

  static MpRole strToRole(String r) {
    MpRole res = MpRole.values.firstWhere(
        (element) => describeEnum(element) == r,
        orElse: () => MpRole.viewer);

    return res;
  }

  bool equals(MealPlanRole mp) {
    if ((this.mpid == mp.mpid) & (this.mpRole == mp.mpRole))
      return true;
    else
      return false;
  }
}

// ------------------------------------------------------

class YogaSettings with ChangeNotifier {
  late UserInfo _user;

  late List<MealPlanRole> _mprs;
  late bool _notify;

  // cached only, not written to DB
  late List<MealPlan> mealPlans;

  YogaSettings() {
    initSettings();
  }

  // defaults
  bool defNotify = true;

  void initSettings() {
    _user = UserInfo();
    _user.initUser();

    _mprs = [];
    mealPlans = [];
    _notify = defNotify;
  }

  bool allDefaults() {
    if ((_notify == defNotify)) {
      return true;
    } else {
      return false;
    }
  }

  // ----------------------------------------------------

  void setUser(
      String name, String email, String uid, String photo, bool verified) {
    _user.name = name;
    _user.email = email;
    _user.uid = uid;
    _user.photo = photo;
    _user.verified = verified;
    notifyListeners();
  }

  UserInfo getUser() {
    return _user;
  }

  void setUserName(String name) {
    _user.name = name;
    notifyListeners();
  }

  void setUserVerified(bool v) {
    _user.verified = v;
    notifyListeners();
  }

  // ----------------------------------------------------

  void settingsFromJson(Map<String, dynamic> jval) {
    _user = UserInfo.fromJson(jval['user'] ?? (_user).toJson());
    _mprs = (jval['mps'] ?? (this._mprs.map((e) => e.toJson()).toList()))
        .map<MealPlanRole>((x) => MealPlanRole.fromJson(x))
        .toList();
    _notify = jval['notify'] ?? _notify;

    notifyListeners();
  }

  Map<String, dynamic> settingsToJson() {
    return {
      'user': (_user).toJson(),
      'mprs': this._mprs.map((e) => e.toJson()).toList(),
      'notify': _notify,
    };
  }

  Future saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> jval = settingsToJson();
    String value = jsonEncode(jval);
    print('**** Saving settings');
    prefs.setString('meal-settings', value);

    await DBService(email: _user.email).updateUserData(this);
  }

  void loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    String value = prefs.getString('meal-settings') ?? '';
    print('**** Loading settings');
    if (value != '') {
      Map<String, dynamic> jval = jsonDecode(value);
      if (jval['email'] == _user.email) settingsFromJson(jval);
    }
  }

  bool mpsEquals(List<MealPlanRole> mps) {
    if (this._mprs.length != mps.length) return false;
    for (int i = 0; i < mps.length; i++) {
      if (!this._mprs[i].equals(mps[i])) return false;
    }
    return true;
  }

  bool equals(YogaSettings cfg) {
    if (_user.equals(cfg._user) &
        (mpsEquals(cfg._mprs)) &
        (_notify == cfg._notify)) {
      return true;
    } else {
      return false;
    }
  }
  // ----------------------------------------------------

  void addMpRole(MealPlanRole mprole, MealPlan mp) {
    this._mprs.add(mprole);
    this.mealPlans.add(mp);
    saveSettings();
  }

  List<MealPlanRole> getMprs() {
    return this._mprs;
  }

  Future<MealPlan> getMealPlan(String mpid) async {
    var doc = await DBService(email: _user.email).getMealPlan(mpid);
    var cfg = doc.data();
    if (cfg != null)
      return MealPlan.fromJson(cfg);
    else {
      print('Meal plan not found in DB, id $mpid');
      return MealPlan();
    }
  }

  Future getAllMealPlans() async {
    mealPlans = [];
    for (int i = 0; i < _mprs.length; i++)
      mealPlans.add(await getMealPlan(_mprs[i].mpid));
  }

  // ----------------------------------------------------

  void setNotify(bool notify) {
    _notify = notify;
  }

  bool getNotify() {
    return _notify;
  }
}
