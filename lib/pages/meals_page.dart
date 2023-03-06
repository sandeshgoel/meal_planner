import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meal_planner/pages/edit_meal_page.dart';
import 'package:meal_planner/services/meal_plan.dart';
import 'package:meal_planner/services/settings.dart';
import 'package:meal_planner/shared/constants.dart';
import 'package:provider/provider.dart';

class MealsPage extends StatefulWidget {
  const MealsPage({super.key});

  @override
  State<MealsPage> createState() => _MealsPageState();
}

class _MealsPageState extends State<MealsPage> {
  late DateTime day;
  late DateTime today;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    day = DateTime(now.year, now.month, now.day);
    today = day;
  }

  Future<bool> _cacheMPD() async {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);
    if (settings.mpCachingNeeded) {
      await settings.getCurMealPlanData();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _cacheMPD(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        Widget ret = Container();

        if (snapshot.hasData) {
          ret = Consumer<YogaSettings>(
            builder: (context, settings, _) {
              String formatted = DateFormat('MMM dd, y').format(day);
              List<Widget> dayList = _dayList(day, settings.mealPlanData);
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      color: Colors.lightBlue[100],
                      margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              if (today.difference(day).inDays < 7 * numWeeks)
                                day = day.subtract(Duration(days: 7));
                              else
                                showToast(context,
                                    'Cannot go beyond $numWeeks weeks');
                              setState(() {});
                            },
                            icon: const Icon(Icons.arrow_back),
                          ),
                          Text(
                            'Week of $formatted',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          IconButton(
                            onPressed: () {
                              if (day.difference(today).inDays < 7 * numWeeks)
                                day = day.add(Duration(days: 7));
                              else
                                showToast(context,
                                    'Cannot go beyond $numWeeks weeks');
                              setState(() {});
                            },
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
            },
          );
        } else {
          ret = Scaffold(
            appBar: AppBar(title: Text('Loading ...')),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 60),
                Container(
                  child: CircularProgressIndicator(),
                  width: 60,
                  height: 60,
                  alignment: Alignment.center,
                ),
                Container(
                  padding: EdgeInsets.only(top: 16),
                  child: Text('Loading meal data ...'),
                  alignment: Alignment.center,
                )
              ],
            ),
          );
        }
        return ret;
      },
    );
  }

  List<Widget> _dayList(DateTime day, Map<DateTime, DayMeal> mealMap) {
    List<Widget> ret = [];

    for (var i = 0; i < 7; i++) {
      DateTime nday = day.add(Duration(days: i));
      ret.add(_dayTile(nday, mealMap[nday] ?? DayMeal('', '', '')));
    }
    return ret;
  }

  Widget _dayTile(DateTime date, DayMeal dayMeal) {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);
    DateFormat formatter = DateFormat('MMM dd, y (E)');
    String formatted = formatter.format(date);

    return Card(
      margin: const EdgeInsets.fromLTRB(10, 20, 10, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Container(
        margin: const EdgeInsets.all(5),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              //padding: const EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatted,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  (date == today)
                      ? Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(5)),
                          child: Text(
                            '  TODAY  ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      : Container(),
                  IconButton(
                      onPressed: () {
                        _editMeal(date, dayMeal);
                      },
                      icon: Icon(Icons.edit)),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              padding: const EdgeInsets.all(5),
              color: Colors.lightGreen,
              child: Row(
                children: [
                  Text(
                    'Breakfast: ${settings.meals[dayMeal.breakfast]}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              padding: const EdgeInsets.all(5),
              color: Colors.yellow,
              child: Row(
                children: [
                  Text(
                    'Lunch: ${settings.meals[dayMeal.lunch]}',
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
                    'Dinner: ${settings.meals[dayMeal.dinner]}',
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

  void _editMeal(DateTime date, DayMeal dayMeal) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) {
        return EditMeal(
          date: date,
          dayMeal: dayMeal,
        );
      }),
    ).then((value) {
      setState(() {});
    });
  }
}
