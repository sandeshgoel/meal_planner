import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meal_planner/services/settings.dart';

class DBService {
  final String uid;
  final String email;
  static Map<String, dynamic> _lastCfg = {};

  DBService({required this.uid, required this.email});

// -------------------------------------------------

  final CollectionReference cfgCollection =
      FirebaseFirestore.instance.collection('configs');

  Future updateUserData(YogaSettings cfg) async {
    YogaSettings lastCfg = YogaSettings();
    lastCfg.settingsFromJson(_lastCfg);

    if (cfg.equals(lastCfg)) {
      print('updateUserData: config unchanged, skipping write to DB');
    } else {
      print('updateUserData: config changed, writing to DB ...');
      Map<String, dynamic> jval = cfg.settingsToJson();
      _lastCfg = jsonDecode(jsonEncode(jval)); // make a copy
      await cfgCollection.doc(email).set(jval);
    }
  }

  Future getUserData() async {
    return await cfgCollection.doc(email).get();
  }
/*
  Future getOtherUserData(String otherEmail) async {
    return await cfgCollection.doc(otherEmail).get();
  }

  Future getOtherUserDataByEmail(String otherEmail) async {
    QuerySnapshot ref =
        await cfgCollection.where('user.email', isEqualTo: otherEmail).get();

    for (var doc in ref.docs) return doc;
    return null;
  }
  */
}
