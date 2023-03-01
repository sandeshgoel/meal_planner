import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meal_planner/services/database.dart';
import 'package:meal_planner/services/meal_plan.dart';
import 'package:meal_planner/services/settings.dart';
import 'package:provider/provider.dart';

class DayMeal {
  late String breakfast;
  late String lunch;
  late String dinner;

  DayMeal(this.breakfast, this.lunch, this.dinner);
}

class MealsPage extends StatefulWidget {
  const MealsPage({super.key});

  @override
  State<MealsPage> createState() => _MealsPageState();
}

class _MealsPageState extends State<MealsPage> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<List<MealPlanData>> _getMpData() async {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);
    String mpid = settings.getMprs()[settings.getCurMpIndex()].mpid;
    DateTime now = DateTime.now();
    var startDate = DateTime(now.year, now.month, now.day);

    QuerySnapshot queryRef = await DBService(email: settings.getUser().email)
        .getMealPlanDataWeek(mpid, startDate);

    return queryRef.docs
        .map((doc) => MealPlanData.fromJson(doc.data()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime day = DateTime(now.year, now.month, now.day);
    DateFormat formatter = DateFormat('MMM dd, y');
    String formatted = formatter.format(day);

    return Consumer<YogaSettings>(builder: (context, settings, _) {
      return FutureBuilder<List<MealPlanData>>(
        future: _getMpData(),
        builder:
            (BuildContext context, AsyncSnapshot<List<MealPlanData>> snapshot) {
          Widget ret;

          if (snapshot.hasData) {
            List<MealPlanData> mpdList = snapshot.data!;
            Map<DateTime, DayMeal> mealMap = {};
            for (MealPlanData mpd in mpdList) {
              print(
                  '${mpd.date}, ${mpd.breakfast}, ${mpd.lunch}, ${mpd.dinner}');
              mealMap[mpd.date] = DayMeal(mpd.breakfast, mpd.lunch, mpd.dinner);
            }
            print(mealMap);
            List<Widget> dayList = _dayList(day, mealMap);
            ret = SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    color: Colors.lightBlue,
                    margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.arrow_back),
                        ),
                        Text(
                          'Week of $formatted',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.arrow_forward),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: dayList,
                  ),
                  const SizedBox(
                    height: 20,
                  )
                ],
              ),
            );
          } else if (snapshot.hasError) {
            ret = Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('Error: ${snapshot.error}'),
                  )
                ]);
          } else {
            ret = Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    child: CircularProgressIndicator(),
                    width: 60,
                    height: 60,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text('Awaiting result...'),
                  )
                ]);
          }
          return ret;
        },
      );
    });
  }

  List<Widget> _dayList(DateTime day, Map<DateTime, DayMeal> mealMap) {
    List<Widget> ret = [];

    for (var i = 0; i < 7; i++) {
      DateTime nday = day.add(Duration(days: i));
      print('$nday: ${mealMap[nday]}');
      ret.add(_dayTile(nday, mealMap[nday] ?? DayMeal('', '', '')));
    }
    return ret;
  }

  Widget _dayTile(DateTime date, DayMeal dayMeal) {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);
    String mpid = settings.getMprs()[settings.getCurMpIndex()].mpid;
    DateFormat formatter = DateFormat('MMM dd, y (E)');
    String formatted = formatter.format(date);

    return Card(
      margin: const EdgeInsets.fromLTRB(10, 20, 10, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Container(
        margin: const EdgeInsets.all(5),
        child: Column(
          children: [
            Center(
              child: Text(
                formatted,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            InkWell(
              onTap: () async {
                String name = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      'Meal name',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    content: TextField(
                      controller: controller,
                      autofocus: true,
                      decoration: InputDecoration(
                          hintText: 'Enter the name of meal ...'),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () =>
                              Navigator.of(context).pop(controller.text),
                          child: Text('Submit'))
                    ],
                  ),
                );
                dayMeal.breakfast = name;
                DBService(email: settings.getUser().email).addMealPlanData(
                    MealPlanData(
                            date: date,
                            mpid: mpid,
                            breakfast: dayMeal.breakfast,
                            lunch: dayMeal.lunch,
                            dinner: dayMeal.dinner)
                        .toJson());
                setState(() {});
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                padding: const EdgeInsets.all(5),
                color: Colors.lightGreen,
                child: Row(
                  children: [
                    Text(
                      'Breakfast: ${dayMeal.breakfast}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              padding: const EdgeInsets.all(5),
              color: Colors.yellow,
              child: Row(
                children: [
                  Text(
                    'Lunch: ${dayMeal.lunch}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              padding: const EdgeInsets.all(5),
              color: Colors.orange,
              child: Row(
                children: [
                  Text(
                    'Dinner: ${dayMeal.dinner}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
