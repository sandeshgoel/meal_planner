import 'package:flutter/material.dart';
import 'package:meal_planner/services/database.dart';
import 'package:meal_planner/services/meal_plan.dart';
import 'package:meal_planner/services/settings.dart';
import 'package:provider/provider.dart';

class EditMealLib extends StatefulWidget {
  final String label;
  const EditMealLib({required this.label, super.key});

  @override
  State<EditMealLib> createState() => _EditMealLibState();
}

class _EditMealLibState extends State<EditMealLib> {
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

  @override
  Widget build(BuildContext context) {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);
    controller.text = settings.meals[widget.label]!;

    print(
        '${settings.meals[widget.label]}, ${settings.mealsCategory[widget.label]}');
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit meal \'${widget.label}\''),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),

            // label

            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Label: '),
                  Text(widget.label),
                ],
              ),
            ),
            SizedBox(height: 20),

            // display name

            Container(
              child: TextField(controller: controller),
            ),
            SizedBox(height: 20),

            // category

            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Category'),
                  DropdownButton<MealCategory>(
                    value: settings.mealsCategory[widget.label],
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
                        settings.mealsCategory[widget.label] = newValue!;
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // submit button

            ElevatedButton(
              onPressed: () async {
                settings.meals[widget.label] = controller.text;
                Meal m = Meal(
                    label: widget.label,
                    display_name: settings.meals[widget.label],
                    category: settings.mealsCategory[widget.label]);
                await DBService(email: settings.getUser().email)
                    .addMeal(m.toJson(), widget.label);
                print('Meal saved');
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
