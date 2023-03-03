import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meal_planner/services/database.dart';
import 'package:meal_planner/services/meal_plan.dart';
import 'package:meal_planner/services/settings.dart';
import 'package:provider/provider.dart';

class EditMeal extends StatefulWidget {
  final DateTime date;
  final DayMeal dayMeal;
  const EditMeal({required this.date, required this.dayMeal, super.key});

  @override
  State<EditMeal> createState() => _EditMealState();
}

class _EditMealState extends State<EditMeal> {
  late DayMeal _lastSaved;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _lastSaved = widget.dayMeal.copy();
    print('_init called');
  }

  @override
  Widget build(BuildContext context) {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);
    DateFormat formatter = DateFormat('MMM dd, y (E)');
    String formatted = formatter.format(widget.date);
    print('cur: ${widget.dayMeal.toString()}');
    print('last: ${_lastSaved.toString()}');

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Meals'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // heading

            Container(
              width: double.infinity,
              color: Colors.lightBlue,
              padding: EdgeInsets.all(10),
              margin: const EdgeInsets.fromLTRB(10, 10, 10, 20),
              child: Center(
                child: Text(
                  'Edit meals for $formatted',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),

            // breakfast

            Container(
              margin: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Breakfast:',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  DropdownButton<String>(
                    value: widget.dayMeal.breakfast,
                    items: settings.meals.keys
                        .map((k) => DropdownMenuItem<String>(
                            value: k,
                            child: Text(
                              settings.meals[k]!,
                              style: TextStyle(fontSize: 12),
                            )))
                        .toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        if (newValue! != widget.dayMeal.breakfast) {
                          widget.dayMeal.breakfast = newValue;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // lunch

            Container(
              margin: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lunch:',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  DropdownButton<String>(
                    value: widget.dayMeal.lunch,
                    items: settings.meals.keys
                        .map((k) => DropdownMenuItem<String>(
                            value: k,
                            child: Text(
                              settings.meals[k]!,
                              style: TextStyle(fontSize: 12),
                            )))
                        .toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        if (newValue! != widget.dayMeal.lunch) {
                          widget.dayMeal.lunch = newValue;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // dinner

            Container(
              margin: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dinner:',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  DropdownButton<String>(
                    value: widget.dayMeal.dinner,
                    items: settings.meals.keys
                        .map((k) => DropdownMenuItem<String>(
                            value: k,
                            child: Text(
                              settings.meals[k]!,
                              style: TextStyle(fontSize: 12),
                            )))
                        .toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        if (newValue! != widget.dayMeal.dinner) {
                          widget.dayMeal.dinner = newValue;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Save

            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: (_lastSaved.equalTo(widget.dayMeal))
                          ? null
                          : () {
                              settings.saveMealPlanData(
                                  widget.date, widget.dayMeal);
                              _lastSaved = widget.dayMeal.copy();
                              setState(() {});
                              Navigator.pop(context);
                            },
                      child: Text('Save')),
                  ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

/*
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
              */
}
