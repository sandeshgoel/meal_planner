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
      return DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: ShowCaseWidget(
          builder: Builder(builder: (context) {
            return Scaffold(
              appBar: AppBar(
                actions: [
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
                leading: Showcase(
                    key: _skey4,
                    description:
                        'Click here to access the settings menu, or logout from the application',
                    overlayPadding: const EdgeInsets.fromLTRB(-5, 0, 5, 0),
                    contentPadding: const EdgeInsets.all(20),
                    shapeBorder: const CircleBorder(),
                    child:
                        const Icon(Icons.face_outlined) //_popupMenu(settings),
                    ),
                bottom: TabBar(
                  tabs: [
                    Showcase(
                      key: _skey0,
                      description: 'First tab lists all the meals',
                      overlayPadding:
                          const EdgeInsets.symmetric(horizontal: 15),
                      contentPadding: const EdgeInsets.all(20),
                      child: const Tab(
                        child: Text(
                          'Meals',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    Showcase(
                      key: _skey1,
                      description: 'Second tab provides statistical analysis',
                      overlayPadding:
                          const EdgeInsets.symmetric(horizontal: 15),
                      contentPadding: const EdgeInsets.all(50),
                      child: const Tab(
                        child: Text(
                          'Statistics',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ), /*
                  Showcase(
                    key: _skey2,
                    description:
                        'Third tab shows your activity and your progress relative to the target you have set',
                    overlayPadding: EdgeInsets.symmetric(horizontal: 15),
                    contentPadding: EdgeInsets.all(20),
                    child: Tab(
                      child: Text(
                        'Activity',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  Showcase(
                    key: _skey3,
                    description:
                        'The last tab shows shared routines by other users',
                    overlayPadding: EdgeInsets.symmetric(horizontal: 15),
                    contentPadding: EdgeInsets.all(20),
                    child: Tab(
                      child: Text(
                        'Social',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),*/
                  ],
                ),
              ),
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
                  const TabBarView(
                    children: [
                      MealsPage(),
                      StatsPage(),
                      //SocialPage(),
                    ],
                  ),
                ],
              ),
            );
          }),
        ),
      );
    });
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
}
