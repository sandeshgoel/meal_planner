import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:meal_planner/services/settings.dart';

class DBService {
  final String email;
  static Map<String, dynamic> _lastCfg = {};

  DBService({required this.email});

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

  Future<List<YogaSettings>> getUsers() async {
    print('Getting all users ...');
    QuerySnapshot queryRef = await cfgCollection.get();

    return queryRef.docs
        .map<YogaSettings>(
            (doc) => YogaSettings.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<DocumentSnapshot> getOtherUser(String otherEmail) async {
    DocumentSnapshot doc = await cfgCollection.doc(otherEmail).get();
    return doc;
  }

  Future updateOtherUserData(String otherEmail, YogaSettings cfg) async {
    Map<String, dynamic> jval = cfg.settingsToJson();
    _lastCfg = jsonDecode(jsonEncode(jval)); // make a copy
    await cfgCollection.doc(otherEmail).set(jval);
    print('Updated profile for $otherEmail');
  }

// -------------------------------------------------

  final CollectionReference mpCollection =
      FirebaseFirestore.instance.collection('mealplans');

  Future addMealPlan(String mpid, Map<String, dynamic> mp) async {
    await mpCollection.doc(mpid).set(mp);
    print('Written to DB mealplan $mpid...');
  }

  Future updateMealPlan(Map<String, dynamic> mp, String mpid) async {
    await mpCollection.doc(mpid).set(mp);
    print("Updated meal plan with ID: $mpid");
  }

  Future getMealPlan(String docId) async {
    print('Getting from meal plan, doc id $docId ...');
    return await mpCollection.doc(docId).get();
  }

// -------------------------------------------------

  final CollectionReference mpDataCollection =
      FirebaseFirestore.instance.collection('mealplanData');

  Future addMealPlanData(Map<String, dynamic> mpd) async {
    String docid = mpd['mpid'] + '_' + DateFormat('yyMMdd').format(mpd['date']);
    await mpDataCollection.doc(docid).set(mpd);
  }

  Future delMealPlanData(String mpid, DateTime date) async {
    String docid = mpid + '_' + DateFormat('yyMMdd').format(date);
    print('Deleting from mealplanData, $docid ...');
    await mpDataCollection.doc(docid).delete();
  }

  Future<QuerySnapshot> getMealPlanData(String mpid, DateTime date) async {
    print('Getting from mealplanData, mpid $mpid $date ...');
    return await mpDataCollection
        .where('mpid', isEqualTo: mpid)
        .where('date', isEqualTo: date)
        .get();
  }

  Future<QuerySnapshot> getMealPlanDataDuration(
      String mpid, DateTime startDate, int numDays) async {
    DateTime endDate = startDate.add(Duration(days: numDays));
    print('Getting from mealplanData, mpid $mpid $startDate $endDate...');

    return await mpDataCollection
        .where('mpid', isEqualTo: mpid)
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThan: endDate)
        .get();
  }

// -------------------------------------------------

  final CollectionReference mealsCollection =
      FirebaseFirestore.instance.collection('meallib');

  Future addMeal(Map<String, dynamic> m, String label) async {
    print('Writing to DB meallib $m ...');
    await mealsCollection.doc(label).set(m, SetOptions(merge: true));
  }

  Future<QuerySnapshot> getMeals() async {
    print('Getting from meals library ...');
    return await mealsCollection.get();
  }

// -------------------------------------------------
}
