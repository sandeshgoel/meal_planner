import 'package:flutter/material.dart';
import 'package:meal_planner/services/settings.dart';
import 'package:provider/provider.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  @override
  Widget build(BuildContext context) {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics'),
      ),
      body: Container(
        child: Column(
          children: [
            Text('${settings.mealPlanData.length} days have any meals'),
          ],
        ),
      ),
    );
  }
}
