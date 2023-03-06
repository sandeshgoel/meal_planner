import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meal_planner/services/meal_plan.dart';
import 'package:meal_planner/services/popup_submenu.dart';
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

            Card(
              margin: EdgeInsets.all(10),
              child: Column(
                children: [
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
                        Text(widget.dayMeal.breakfast),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Select:'),
                        PopupMenuButton<String>(
                          icon: Icon(Icons.arrow_drop_down),
                          tooltip: 'Categories',
                          onSelected: (value) {
                            //Do something with selected parent value
                            print('$value parent selected');
                          },
                          itemBuilder: (BuildContext context) {
                            return <PopupMenuEntry<String>>[
                              PopupSubMenuItem<String>(
                                title: displayCategory(MealCategory.dal),
                                items: settings.listMeals(MealCategory.dal),
                                display_function: (val) => settings.meals[val]!,
                                onSelected: (value) {
                                  //Do something with selected child value
                                  print('$value selected');
                                  setState(() {
                                    widget.dayMeal.breakfast = value;
                                  });
                                },
                              ),
                              PopupSubMenuItem<String>(
                                title: displayCategory(MealCategory.snack),
                                items: settings.listMeals(MealCategory.snack),
                                display_function: (val) => settings.meals[val]!,
                                onSelected: (value) {
                                  //Do something with selected child value
                                  print('$value selected');
                                  setState(() {
                                    widget.dayMeal.breakfast = value;
                                  });
                                },
                              ),
                              PopupSubMenuItem<String>(
                                title: displayCategory(MealCategory.veg),
                                items: settings.listMeals(MealCategory.veg),
                                display_function: (val) => settings.meals[val]!,
                                onSelected: (value) {
                                  //Do something with selected child value
                                  print('$value selected');
                                  setState(() {
                                    widget.dayMeal.breakfast = value;
                                  });
                                },
                              ),
                            ];
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),

            // lunch

            Card(
              margin: EdgeInsets.all(10),
              child: Column(
                children: [
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
                        Text(widget.dayMeal.lunch),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Select:'),
                        PopupMenuButton<String>(
                          icon: Icon(Icons.arrow_drop_down),
                          tooltip: 'Categories',
                          onSelected: (value) {
                            //Do something with selected parent value
                            print('$value parent selected');
                          },
                          itemBuilder: (BuildContext context) {
                            return <PopupMenuEntry<String>>[
                              PopupSubMenuItem<String>(
                                title: displayCategory(MealCategory.dal),
                                items: settings.listMeals(MealCategory.dal),
                                display_function: (val) => settings.meals[val]!,
                                onSelected: (value) {
                                  //Do something with selected child value
                                  print('$value selected');
                                  setState(() {
                                    widget.dayMeal.lunch = value;
                                  });
                                },
                              ),
                              PopupSubMenuItem<String>(
                                title: displayCategory(MealCategory.snack),
                                items: settings.listMeals(MealCategory.snack),
                                display_function: (val) => settings.meals[val]!,
                                onSelected: (value) {
                                  //Do something with selected child value
                                  print('$value selected');
                                  setState(() {
                                    widget.dayMeal.lunch = value;
                                  });
                                },
                              ),
                              PopupSubMenuItem<String>(
                                title: displayCategory(MealCategory.veg),
                                items: settings.listMeals(MealCategory.veg),
                                display_function: (val) => settings.meals[val]!,
                                onSelected: (value) {
                                  //Do something with selected child value
                                  print('$value selected');
                                  setState(() {
                                    widget.dayMeal.lunch = value;
                                  });
                                },
                              ),
                            ];
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),

            // dinner

            Card(
              margin: EdgeInsets.all(10),
              child: Column(
                children: [
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
                        Text(widget.dayMeal.dinner),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Select:'),
                        PopupMenuButton<String>(
                          icon: Icon(Icons.arrow_drop_down),
                          tooltip: 'Categories',
                          onSelected: (value) {
                            //Do something with selected parent value
                            print('$value parent selected');
                          },
                          itemBuilder: (BuildContext context) {
                            return <PopupMenuEntry<String>>[
                              PopupSubMenuItem<String>(
                                title: displayCategory(MealCategory.dal),
                                items: settings.listMeals(MealCategory.dal),
                                display_function: (val) => settings.meals[val]!,
                                onSelected: (value) {
                                  //Do something with selected child value
                                  print('$value selected');
                                  setState(() {
                                    widget.dayMeal.dinner = value;
                                  });
                                },
                              ),
                              PopupSubMenuItem<String>(
                                title: displayCategory(MealCategory.snack),
                                items: settings.listMeals(MealCategory.snack),
                                display_function: (val) => settings.meals[val]!,
                                onSelected: (value) {
                                  //Do something with selected child value
                                  print('$value selected');
                                  setState(() {
                                    widget.dayMeal.dinner = value;
                                  });
                                },
                              ),
                              PopupSubMenuItem<String>(
                                title: displayCategory(MealCategory.veg),
                                items: settings.listMeals(MealCategory.veg),
                                display_function: (val) => settings.meals[val]!,
                                onSelected: (value) {
                                  //Do something with selected child value
                                  print('$value selected');
                                  setState(() {
                                    widget.dayMeal.dinner = value;
                                  });
                                },
                              ),
                            ];
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),

            // Save

            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel')),
                  ElevatedButton(
                      onPressed: (_lastSaved.equalTo(widget.dayMeal))
                          ? null
                          : () async {
                              await settings.saveMealPlanData(
                                  widget.date, widget.dayMeal);
                              _lastSaved = widget.dayMeal.copy();
                              setState(() {});
                              Navigator.pop(context);
                            },
                      child: Text('Save')),
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
