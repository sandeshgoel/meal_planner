import 'package:flutter/material.dart';
import 'package:meal_planner/pages/meals_page.dart';
import 'package:meal_planner/pages/stats_page.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:provider/provider.dart';

import 'package:meal_planner/services/settings.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //final AuthService _auth = AuthService();
  final _skey0 = GlobalKey();
  final _skey1 = GlobalKey();
  final _skey2 = GlobalKey();
  final _skey3 = GlobalKey();
  final _skey4 = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Consumer<YogaSettings>(builder: (context, settings, _) {
      return ShowCaseWidget(
        builder: Builder(builder: (context) {
          return Scaffold(
            appBar: AppBar(
              actions: [
                Showcase(
                  key: _skey1,
                  description: 'Click here for the monthly view',
                  overlayPadding: const EdgeInsets.fromLTRB(-5, 0, 5, 0),
                  contentPadding: const EdgeInsets.all(20),
                  shapeBorder: const CircleBorder(),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.calendar_month),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (BuildContext context) {
                        return StatsPage();
                      }),
                    ).then((value) {
                      setState(() {});
                    });
                  },
                  icon:
                      const Icon(IconData(0xf5a9, fontFamily: 'MaterialIcons')),
                ),
                IconButton(
                  icon: const Icon(Icons.help_rounded),
                  onPressed: () {
                    setState(() {
                      ShowCaseWidget.of(context).startShowCase(
                          [_skey0, _skey1, _skey2, _skey3, _skey4]);
                    });
                  },
                ),
              ],
              title: Text('Welcome: ${settings.getUser().name}',
                  style: const TextStyle(fontSize: 18)),
            ),
            drawer: _drawer(context),
            body: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/background.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                MealsPage(),
              ],
            ),
          );
        }),
      );
    });
  }
}

Widget _drawer(context) {
  return Drawer(
    child: ListView(
      children: [
        _drawerHeader(context),
        _drawerItem(context, 'Settings', Icon(Icons.settings)),
        _drawerItem(context, 'About', Icon(Icons.info)),
      ],
    ),
  );
}

Widget _drawerItem(context, String text, Icon icon) {
  return Material(
    child: InkWell(
      child: Container(
        margin: EdgeInsets.fromLTRB(15, 15, 15, 0),
        child: Row(children: [
          Expanded(child: icon),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            flex: 4,
          ),
        ]),
      ),
      onTap: () {
        Navigator.pop(context);
      },
    ),
  );
}

Widget _drawerHeader(context) {
  return Container(
    padding: EdgeInsets.all(20),
    color: Colors.lightBlue,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage("assets/icon/yoga_icon_circular.png"),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          'Sandesh Goel',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          'email@domain.com',
          style: TextStyle(
            color: Colors.grey[200],
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        )
      ],
    ),
  );
}
/*
  Widget _popupMenu(settings) {
    GoogleSignInProvider _google =
        Provider.of<GoogleSignInProvider>(context, listen: false);
    var _photo = settings.getUser().photo;

    return PopupMenuButton(
      icon: Container(
        margin: EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 1, color: Colors.yellow),
          image: DecorationImage(
            fit: BoxFit.contain,
            image: (_photo == '')
                ? AssetImage("assets/icon/yoga_icon_circular.png")
                    as ImageProvider
                : NetworkImage(_photo),
          ),
        ),
      ),
      color: Colors.white,
      offset: Offset(0, 50),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      itemBuilder: (context) => [
        PopupMenuItem<int>(
          value: 0,
          child: Row(
            children: [
              Icon(
                Icons.settings,
                color: Colors.black,
              ),
              Text(
                "  Settings",
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
        PopupMenuItem<int>(
          value: 1,
          child: Row(
            children: [
              Icon(
                Icons.logout,
                color: Colors.black,
              ),
              Text(
                "  Log out",
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
        PopupMenuItem<int>(
          value: 2,
          child: Row(
            children: [
              Icon(
                Icons.info,
                color: Colors.black,
              ),
              Text(
                "  About",
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
      ],
      onSelected: (item) async {
        switch (item) {
          case 0:
            _editSettings();
            break;
          case 1:
            await _auth.signOut();
            await _google.googleSignOut();
            break;
          case 2:
            await _about();
            break;
          default:
            print('invalid item $item');
        }
      },
    );
  }

  Future _about() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    showAboutDialog(
      context: context,
      applicationVersion: 'Ver $version +$buildNumber',
      applicationIcon: Image.asset(
        "assets/icon/yoga_icon_circular.png",
        height: 40,
        width: 40,
      ),
      children: [
        RichText(
          text: TextSpan(
            text: 'https://sites.google.com/view/yogabuddy',
            style: TextStyle(color: Colors.blue),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                final url = 'https://sites.google.com/view/yogabuddy';
                if (await canLaunchUrlString(url)) {
                  await launchUrlString(
                    url,
                    mode: LaunchMode.externalApplication,
                  );
                }
              },
          ),
        ),
      ],
    );
  }

  void _editSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) {
        return EditSettingsPage();
      }),
    ).then((value) {
      setState(() {});
    });
  }
  */


