// ------------------------------------------------------

import 'dart:convert';

import 'package:flutter/material.dart';
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
    name = 'Goels';
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

class YogaSettings with ChangeNotifier {
  late UserInfo _user;

  late bool _notify;

  YogaSettings() {
    initSettings();
  }

  // defaults
  bool defNotify = true;

  void initSettings() {
    _user = UserInfo();
    _user.initUser();

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
    _notify = jval['notify'] ?? _notify;

    notifyListeners();
  }

  Map<String, dynamic> settingsToJson() {
    return {
      'user': (_user).toJson(),
      'notify': _notify,
    };
  }

  void saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> jval = settingsToJson();
    String value = jsonEncode(jval);
    print('**** Saving settings');
    prefs.setString('meal-settings', value);
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

  bool equals(YogaSettings cfg) {
    if (_user.equals(cfg._user) & (_notify == cfg._notify)) {
      return true;
    } else {
      return false;
    }
  }

  // ----------------------------------------------------

  void setNotify(bool notify) {
    _notify = notify;
  }

  bool getNotify() {
    return _notify;
  }
}
