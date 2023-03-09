import 'package:flutter/material.dart';
import 'package:meal_planner/services/database.dart';
import 'package:meal_planner/services/meal_plan.dart';
import 'package:meal_planner/services/settings.dart';
import 'package:meal_planner/shared/constants.dart';
import 'package:provider/provider.dart';

class AddMealLib extends StatefulWidget {
  const AddMealLib({super.key});

  @override
  State<AddMealLib> createState() => _AddMealLibState();
}

class _AddMealLibState extends State<AddMealLib> {
  late TextEditingController controller1;
  late TextEditingController controller2;
  late MealCategory category;

  @override
  void initState() {
    super.initState();
    controller1 = TextEditingController();
    controller2 = TextEditingController();
    category = MealCategory.snack;
  }

  @override
  void dispose() {
    controller1.dispose();
    controller2.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Add meal to library'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: 20),

            // display name

            Text(
              'Meal Name',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
            Container(
              child: TextField(controller: controller1),
            ),
            SizedBox(height: 50),

            // label
            Text(
              'Meal Label (optional)',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
            Container(
              child: TextField(controller: controller2),
            ),

            SizedBox(height: 50),

            // category

            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Category'),
                  DropdownButton<MealCategory>(
                    value: category,
                    items: MealCategory.values
                        .map((k) => DropdownMenuItem<MealCategory>(
                            value: k,
                            child: Text(
                              displayCategory(k),
                              style: TextStyle(fontSize: 12),
                            )))
                        .toList(),
                    onChanged: (MealCategory? newValue) {
                      setState(() {
                        category = newValue!;
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),

            // buttons

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              // cancel button

              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),

                // save button

                ElevatedButton(
                  onPressed: () async {
                    String label = controller2.text.trim().toLowerCase();
                    String display = controller1.text.trim().toTitleCase();

                    controller1.clear();
                    controller2.clear();

                    if (label.isEmpty)
                      label = display.replaceAll(' ', '').toLowerCase();

                    if (display.isEmpty) {
                      showMsg(context, 'Name can\'t be empty, try again!!');
                    } else if (label.contains(' ')) {
                      showMsg(
                          context, 'Label can\'t contain space, try again!!');
                    } else if (settings.meals.keys.any((x) => x == label)) {
                      showMsg(
                          context, 'Meal label \'$label\' already exists!!');
                    } else if (settings.meals.values.any((x) => x == display)) {
                      showMsg(
                          context, 'Meal name \'$display\' already exists!!');
                    } else {
                      Meal m = Meal(
                          label: label,
                          display_name: display,
                          category: category);
                      settings.meals[label] = display;
                      settings.mealsCategory[label] = category;
                      await DBService(email: settings.getUser().email)
                          .addMeal(m.toJson(), label);
                      showToast(context, 'Added Meal $label,$display');

                      setState(() {});
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
