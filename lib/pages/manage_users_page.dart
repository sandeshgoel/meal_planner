import 'package:flutter/material.dart';
import 'package:meal_planner/services/database.dart';
import 'package:meal_planner/services/settings.dart';
import 'package:provider/provider.dart';

class ManageUsers extends StatefulWidget {
  const ManageUsers({super.key});

  @override
  State<ManageUsers> createState() => _ManageUsersState();
}

class _ManageUsersState extends State<ManageUsers> {
  Future<List<YogaSettings>> _getUsers() async {
    YogaSettings settings = Provider.of<YogaSettings>(context);
    return await DBService(email: settings.getUser().email).getUsers();
  }

  @override
  Widget build(BuildContext context) {
    YogaSettings settings = Provider.of<YogaSettings>(context);

    return FutureBuilder<List<YogaSettings>>(
      future: _getUsers(), // a previously-obtained Future<String> or null
      builder:
          (BuildContext context, AsyncSnapshot<List<YogaSettings>> snapshot) {
        Widget ret;

        if (snapshot.hasData) {
          List<YogaSettings> users = snapshot.data!;

          ret = Scaffold(
            appBar: AppBar(
              title: Text('Manage Users'),
            ),
            body: _listUsers(settings, users),
          );
        } else {
          ret = Container();
        }
        return ret;
      },
    );
  }

  Widget _listUsers(YogaSettings settings, List<YogaSettings> users) {
    return SingleChildScrollView(
      child: Column(
        children: [
              Container(
                color: Colors.lightBlue,
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                padding: const EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Name',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Superuser',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ] +
            users
                .map(
                  (e) => Container(
                    //color: Colors.lightBlue[100],
                    margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e.getUser().email),
                            Text(e.getSuperUser().toString()),
                          ],
                        ),
                        Divider(),
                      ],
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }
}
