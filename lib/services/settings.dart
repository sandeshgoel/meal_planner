// ------------------------------------------------------

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:meal_planner/services/database.dart';
import 'package:meal_planner/services/meal_plan.dart';
import 'package:meal_planner/shared/constants.dart';
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

const BREAKFAST = 'breakfast';
const LUNCH = 'lunch';
const DINNER = 'dinner';

const BSNACK = 'bsnack';
const BSIDE = 'bside';
const LSNACK = 'lsnack';
const LSIDE = 'lside';
const DSNACK = 'dsnack';
const DSIDE = 'dside';

// ------------------------------------------------------

class YogaSettings with ChangeNotifier {
  late UserInfo _user;

  late List<MealPlanRole> _mprs;
  late int _curMpIndex;
  late bool _superUser;
  late int _mpIndex;
  late bool _notify;
  late bool _bsnack, _bside;
  late bool _lsnack, _lside;
  late bool _dsnack, _dside;

  // cached only, not written to DB
  late Map<String, String> meals; // label to name mapping
  late Map<String, MealCategory> mealsCategory; // label to category
  late List<MealPlan> mealPlans;
  late Map<DateTime, DayMeal> mealPlanData;
  late bool mpCachingNeeded;
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
    _superUser = false;
    _mpIndex = 0;
    _notify = defNotify;
    _bside = _bsnack = _lside = _lsnack = _dside = _dsnack = false;

    meals = {};
    mealsCategory = {};
    mealPlans = [];
    mealPlanData = {};
    mpCachingNeeded = true;
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

  YogaSettings.fromJson(Map<String, dynamic> jval) {
    _user = UserInfo.fromJson(jval['user'] ?? (_user).toJson());
    _mprs = (jval['mprs'] ?? (this._mprs.map((e) => e.toJson()).toList()))
        .map<MealPlanRole>((x) => MealPlanRole.fromJson(x))
        .toList();
    _curMpIndex = jval['curMpIndex'] ?? _curMpIndex;
    _superUser = jval['superUser'] ?? _superUser;
    _mpIndex = jval['mpIndex'] ?? _mpIndex;
    _notify = jval['notify'] ?? _notify;
    _bsnack = jval[BSNACK] ?? _bsnack;
    _bside = jval[BSIDE] ?? _bside;
    _lsnack = jval[LSNACK] ?? _lsnack;
    _lside = jval[LSIDE] ?? _lside;
    _dsnack = jval[DSNACK] ?? _dsnack;
    _dside = jval[DSIDE] ?? _dside;

    //notifyListeners();
  }

  void settingsFromJson(Map<String, dynamic> jval) {
    _user = UserInfo.fromJson(jval['user'] ?? (_user).toJson());
    _mprs = (jval['mprs'] ?? (this._mprs.map((e) => e.toJson()).toList()))
        .map<MealPlanRole>((x) => MealPlanRole.fromJson(x))
        .toList();
    _curMpIndex = jval['curMpIndex'] ?? _curMpIndex;
    _superUser = jval['superUser'] ?? _superUser;
    _mpIndex = jval['mpIndex'] ?? _mpIndex;
    _notify = jval['notify'] ?? _notify;
    _bsnack = jval[BSNACK] ?? _bsnack;
    _bside = jval[BSIDE] ?? _bside;
    _lsnack = jval[LSNACK] ?? _lsnack;
    _lside = jval[LSIDE] ?? _lside;
    _dsnack = jval[DSNACK] ?? _dsnack;
    _dside = jval[DSIDE] ?? _dside;

    notifyListeners();
  }

  Map<String, dynamic> settingsToJson() {
    return {
      'user': (_user).toJson(),
      'mprs': this._mprs.map((e) => e.toJson()).toList(),
      'curMpIndex': _curMpIndex,
      'superUser': _superUser,
      'mpIndex': _mpIndex,
      'notify': _notify,
      BSNACK: _bsnack,
      BSIDE: _bside,
      LSNACK: _lsnack,
      LSIDE: _lside,
      DSNACK: _dsnack,
      DSIDE: _dside,
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

  Future loadSettingsFromDB() async {
    var doc = await DBService(email: _user.email).getUserData();
    var cfg = doc.data();
    if (cfg != null)
      settingsFromJson(cfg);
    else
      print('loadSettingsFromDB: DB returned null record for ${_user.uid}!!');
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
        (_superUser == cfg._superUser) &
        (_notify == cfg._notify) &
        (_bsnack == cfg._bsnack) &
        (_bside == cfg._bside) &
        (_lsnack == cfg._lsnack) &
        (_lside == cfg._lside) &
        (_dsnack == cfg._dsnack) &
        (_dside == cfg._dside)) {
      return true;
    } else {
      return false;
    }
  }
  // ----------------------------------------------------

  List<MealPlanRole> getMprs() {
    return this._mprs;
  }

  void addMpRole(MealPlanRole mprole, MealPlan mp) {
    this._mprs.add(mprole);
    this.mealPlans.add(mp);
    saveSettings();
  }

  void updateMpRoleOther(String mpid, MpRole role) {
    // Delete any existing roles for this mpid
    _mprs.removeWhere((element) => element.mpid == mpid);
    // Add mpid with new role
    _mprs.add(MealPlanRole(mpid, role));
  }

  void delMpRoleOther(String mpid) {
    _mprs.removeWhere((element) => element.mpid == mpid);
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
    String mpId = email + '_' + _mpIndex.toString();
    await DBService(email: email).addMealPlan(mpId, mp.toJson());
    _mpIndex += 1; // save settings will be called in addMpRole

    MealPlanRole mprole = MealPlanRole(mpId, MpRole.admin);
    addMpRole(mprole, mp);
  }

  Future getAllMealPlans() async {
    String firstname = _user.name.split(' ')[0].trim();
    if (firstname == '') firstname = 'My';
    if (_mprs.length == 0) addMealPlan(firstname + ' Meal Plan');

    mealPlans = [];
    for (int i = 0; i < _mprs.length; i++)
      mealPlans.add(await getMealPlan(_mprs[i].mpid));

    print(
        'getAllMealPlans: MPR len=${_mprs.length}, MP len=${mealPlans.length}');
  }

  // ----------------------------------------------------

  Future getCurMealPlanData() async {
    DateTime now = DateTime.now();
    DateTime startDate = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: 7 * numWeeks));

    QuerySnapshot queryRef = await DBService(email: _user.email)
        .getMealPlanDataDuration(
            _mprs[_curMpIndex].mpid, startDate, 7 * (2 * numWeeks + 1));
    print('getCurMealPlanData: retrieved ${queryRef.docs.length} records');

    List<MealPlanData> mpdList = [];

    for (var doc in queryRef.docs) {
      print(doc.data());
      MealPlanData m =
          MealPlanData.fromJson(doc.data() as Map<String, dynamic>);
      print(m.toString());
      mpdList.add(m);
    }

    mealPlanData = {};
    for (MealPlanData mpd in mpdList) {
      mealPlanData[mpd.date] =
          DayMeal(mpd.breakfast, mpd.lunch, mpd.dinner, mpd.other);
      print('${mpd.date}:${mealPlanData[mpd.date]}');
    }

    mpCachingNeeded = false;
    print('mealPlanData cached, length=${mealPlanData.length}');
  }

  Future saveMealPlanData(DateTime date, DayMeal dayMeal) async {
    Map<String, dynamic> mpd = MealPlanData(
            mpid: _mprs[_curMpIndex].mpid,
            date: date,
            breakfast: dayMeal.breakfast,
            lunch: dayMeal.lunch,
            dinner: dayMeal.dinner,
            other: dayMeal.other)
        .toJson();
    print('Saving meal plan data: ${mpd.toString()}');

    await DBService(email: _user.email).addMealPlanData(mpd);
    mealPlanData[date] = dayMeal;
  }

  // ----------------------------------------------------

  Future getAllMeals() async {
    QuerySnapshot queryRef = await DBService(email: _user.email).getMeals();

    List<Meal> listMeals =
        queryRef.docs.map((doc) => Meal.fromJson(doc.data())).toList();

    for (Meal meal in listMeals) {
      meals[meal.label] = meal.display_name;
      mealsCategory[meal.label] = meal.category;
    }
    meals[''] = '-';
  }

  List<String> listMeals(MealCategory category) {
    List<String> res = [];

    for (String label in meals.keys) {
      if (mealsCategory[label] == category) res.add(label);
    }
    return res;
  }

  Future refreshCache() async {
    await loadSettingsFromDB();
    await getAllMeals();
    await getAllMealPlans();
    await getCurMealPlanData();
  }
  // ----------------------------------------------------

  void setCurMpIndex(int val) {
    if (val != _curMpIndex) {
      mpCachingNeeded = true;
      _curMpIndex = val;
      saveSettings();
    }
  }

  int getCurMpIndex() {
    return _curMpIndex;
  }

  // ----------------------------------------------------

  void setSuperUser(bool val) {
    _superUser = val;
  }

  bool getSuperUser() {
    return _superUser;
  }

  // ----------------------------------------------------

  void setNotify(bool notify) {
    _notify = notify;
  }

  bool getNotify() {
    return _notify;
  }

  // ----------------------------------------------------

  void setBsnack(bool val) {
    _bsnack = val;
  }

  bool getBsnack() {
    return _bsnack;
  }

  // ----------------------------------------------------

  void setBside(bool val) {
    _bside = val;
  }

  bool getBside() {
    return _bside;
  }

  // ----------------------------------------------------

  void setLsnack(bool val) {
    _lsnack = val;
  }

  bool getLsnack() {
    return _lsnack;
  }

  // ----------------------------------------------------

  void setLside(bool val) {
    _lside = val;
  }

  bool getLside() {
    return _lside;
  }

  // ----------------------------------------------------

  void setDsnack(bool val) {
    _dsnack = val;
  }

  bool getDsnack() {
    return _dsnack;
  }

  // ----------------------------------------------------

  void setDside(bool val) {
    _dside = val;
  }

  bool getDside() {
    return _dside;
  }

  // ----------------------------------------------------
}
