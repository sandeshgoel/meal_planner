// ------------------------------------------------------

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
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
  late int _curMpIndex;
  late bool _notify;

  // cached only, not written to DB
  late Map<String, String> meals;
  late List<MealPlan> mealPlans;
  late Map<DateTime, DayMeal> mealPlanData;
  late bool loadComplete;

  YogaSettings() {
    initSettings();
  }

  // defaults
  bool defNotify = true;

  void initSettings() {
    _user = UserInfo();
    _user.initUser();

    _mprs = [];
    _curMpIndex = 0;
    _notify = defNotify;

    meals = {};
    mealPlans = [];
    mealPlanData = {};
    loadComplete = false;
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
    _mprs = (jval['mprs'] ?? (this._mprs.map((e) => e.toJson()).toList()))
        .map<MealPlanRole>((x) => MealPlanRole.fromJson(x))
        .toList();
    _curMpIndex = jval['curMpIndex'] ?? _curMpIndex;
    _notify = jval['notify'] ?? _notify;

    notifyListeners();
  }

  Map<String, dynamic> settingsToJson() {
    return {
      'user': (_user).toJson(),
      'mprs': this._mprs.map((e) => e.toJson()).toList(),
      'curMpIndex': _curMpIndex,
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
        (_curMpIndex == cfg._curMpIndex) &
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

  // ----------------------------------------------------

  Future<MealPlan> getMealPlan(String mpid) async {
    var doc = await DBService(email: _user.email).getMealPlan(mpid);
    var cfg = doc.data();
    if (cfg != null)
      return MealPlan.fromJson(cfg);
    else {
      print('Meal plan not found in DB, id $mpid');
      return MealPlan(name: 'Default');
    }
  }

  Future addMealPlan(String name) async {
    String email = _user.email;
    MealPlan mp = MealPlan(name: name, creator: email, admins: [email]);
    String mpId = await DBService(email: email).addMealPlan(mp.toJson());
    MealPlanRole mprole = MealPlanRole(mpId, MpRole.admin);
    addMpRole(mprole, mp);
  }

  Future getAllMealPlans() async {
    if (_mprs.length == 0) addMealPlan('My Meal Plan');

    mealPlans = [];
    for (int i = 0; i < _mprs.length; i++)
      mealPlans.add(await getMealPlan(_mprs[i].mpid));

    print(
        'getAllMealPlans: MPR len=${_mprs.length}, MP len=${mealPlans.length}');
  }

  // ----------------------------------------------------

  Future getCurMealPlanData() async {
    DateTime now = DateTime.now();
    DateTime startDate =
        DateTime(now.year, now.month, now.day).subtract(Duration(days: 28));

    QuerySnapshot queryRef = await DBService(email: _user.email)
        .getMealPlanDataDuration(_mprs[_curMpIndex].mpid, startDate, 7 * 9);

    List<MealPlanData> mpdList =
        queryRef.docs.map((doc) => MealPlanData.fromJson(doc.data())).toList();

    for (MealPlanData mpd in mpdList) {
      mealPlanData[mpd.date] = DayMeal(mpd.breakfast, mpd.lunch, mpd.dinner);
      print('${mpd.date}:${mealPlanData[mpd.date]}');
    }
    print('mealPlanData cached, length=${mealPlanData.length}');
  }

  Future saveMealPlanData(DateTime date, DayMeal dayMeal) async {
    Map<String, dynamic> mpd = MealPlanData(
            mpid: _mprs[_curMpIndex].mpid,
            date: date,
            breakfast: dayMeal.breakfast,
            lunch: dayMeal.lunch,
            dinner: dayMeal.dinner)
        .toJson();
    print('Saving meal plan data: ${mpd.toString()}');

    await DBService(email: _user.email).addMealPlanData(mpd);
    mealPlanData[date] = dayMeal;
  }

  // ----------------------------------------------------

  void setCurMpIndex(int val) {
    _curMpIndex = val;
  }

  int getCurMpIndex() {
    return _curMpIndex;
  }

  // ----------------------------------------------------

  void setNotify(bool notify) {
    _notify = notify;
  }

  bool getNotify() {
    return _notify;
  }

  // ----------------------------------------------------
}
