import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  @override
  Widget build(BuildContext context) {
    DateTime day = DateTime.now();
    DateFormat formatter = DateFormat('MMM dd, y');
    String formatted = formatter.format(day);

    List<Widget> dayList = _dayList(day);
    return SingleChildScrollView(
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
  }

  List<Widget> _dayList(DateTime day) {
    List<Widget> ret = [];

    for (var i = 0; i < 7; i++) {
      ret.add(_dayTile(day.add(Duration(days: i))));
    }
    return ret;
  }

  Widget _dayTile(DateTime date) {
    DateFormat formatter = DateFormat('MMM dd, y (E)');
    String formatted = formatter.format(date);

    DayMeal dayMeal = DayMeal('Oats', 'Raajmaa', 'Paneer');

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
            Container(
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
