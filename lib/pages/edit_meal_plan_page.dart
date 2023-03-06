import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meal_planner/services/database.dart';
import 'package:meal_planner/services/meal_plan.dart';
import 'package:meal_planner/services/settings.dart';
import 'package:meal_planner/shared/constants.dart';
import 'package:provider/provider.dart';

class EditMealPlan extends StatefulWidget {
  final int index;
  const EditMealPlan({required this.index, super.key});

  @override
  State<EditMealPlan> createState() => _EditMealPlanState();
}

class _EditMealPlanState extends State<EditMealPlan> {
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
    MealPlan mp = settings.mealPlans[widget.index];
    MealPlanRole mpr = settings.getMprs()[widget.index];

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit \'${mp.name}\''),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(10),
          child: Column(
            children: [
                  // currently selected or not

                  Row(
                    children: [
                      Text('Currently selected', style: settingsTextStyle),
                      Expanded(
                        child: Container(),
                      ),
                      Switch(
                        value: widget.index == settings.getCurMpIndex(),
                        onChanged: (val) {
                          setState(() {
                            if (val)
                              settings.setCurMpIndex(widget.index);
                            else
                              showMsg(context,
                                  'In order to unselect this, just select a different meal plan');
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // creator

                  Row(children: [
                    Text('Creator: ', style: settingsTextStyle),
                    Expanded(
                      child: Container(),
                    ),
                    Text(mp.creator, style: settingsTextStyle),
                  ]),
                  SizedBox(height: 20),

                  // my role

                  Row(children: [
                    Text('My Role: ', style: settingsTextStyle),
                    Expanded(
                      child: Container(),
                    ),
                    Text(describeEnum(mpr.mpRole), style: settingsTextStyle),
                  ]),
                  SizedBox(height: 20),

                  // time

                  Row(children: [
                    Text('Create time: ', style: settingsTextStyle),
                    Expanded(
                      child: Container(),
                    ),
                    Text(DateFormat('MMM dd, y HH:mm').format(mp.createTime),
                        style: settingsTextStyle),
                  ]),
                  SizedBox(height: 20),

                  // admins

                  Divider(),
                  Center(
                    child: Text(
                      'Admins',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),
                ] +
                mp.admins
                    .map(
                      (e) => Text(
                        e,
                        style: settingsTextStyle,
                      ),
                    )
                    .toList() +
                [
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                        onPressed: (mpr.mpRole != MpRole.admin)
                            ? null
                            : () => _addAdmin(),
                        child: Text('Add Admin')),
                  ),
                  SizedBox(height: 20),

                  // members
                  Divider(),

                  Center(
                    child: Text(
                      'Members',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),
                ] +
                mp.members
                    .map(
                      (e) => Text(
                        e,
                        style: settingsTextStyle,
                      ),
                    )
                    .toList() +
                [
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                        onPressed: (mpr.mpRole == MpRole.viewer)
                            ? null
                            : () => _addMember(),
                        child: Text('Add Member')),
                  ),
                  SizedBox(height: 20),

                  // viewers

                  Divider(),
                  Center(
                    child: Text(
                      'Viewers',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),
                ] +
                mp.viewers
                    .map(
                      (e) => Text(
                        e,
                        style: settingsTextStyle,
                      ),
                    )
                    .toList() +
                [
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                        onPressed: () => _addViewer(),
                        child: Text('Add Viewer')),
                  ),
                  SizedBox(height: 20),

                  // delete this
                  Divider(),
                  SizedBox(height: 20),
                ],
          ),
        ),
      ),
    );
  }

  Future<DocumentSnapshot> getOtherUserDoc() async {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);
    String emailToAdd = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add User',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: 'Enter email'),
        ),
        actions: [
          TextButton(
              onPressed: () {
                String email = controller.text;
                controller.clear();
                Navigator.of(context).pop(email);
              },
              child: Text('Submit'))
        ],
      ),
    );

    emailToAdd = emailToAdd.trim();

    DocumentSnapshot doc = await DBService(email: settings.getUser().email)
        .getOtherUser(emailToAdd);
    return doc;
  }

  Future _addAdmin() async {
    DocumentSnapshot doc = await getOtherUserDoc();

    if (!doc.exists) {
      showMsg(context, 'User does not exist!!');
    } else {
      YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);
      MealPlanRole mpr = settings.getMprs()[widget.index];
      YogaSettings otherCfg =
          YogaSettings.fromJson(doc.data() as Map<String, dynamic>);
      String emailToAdd = otherCfg.getUser().email;

      if (settings.mealPlans[widget.index].admins.contains(emailToAdd)) {
        showMsg(context, 'User is already an admin!!');
      } else {
        settings.mealPlans[widget.index].admins.add(emailToAdd);
        settings.mealPlans[widget.index].members.remove(emailToAdd);
        settings.mealPlans[widget.index].viewers.remove(emailToAdd);
        DBService(email: settings.getUser().email).updateMealPlan(
            settings.mealPlans[widget.index].toJson(), mpr.mpid);

        showToast(context, 'Added user \'$emailToAdd\' as admin');

        // Add this meal plan to the new admin too
        otherCfg.updateMpRoleOther(mpr.mpid, MpRole.admin);
        DBService(email: emailToAdd).updateOtherUserData(emailToAdd, otherCfg);
      }
    }
    setState(() {});
  }

  Future _addMember() async {}

  Future _addViewer() async {}
}
