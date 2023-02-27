import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:meal_planner/services/settings.dart';
import 'package:meal_planner/shared/constants.dart';

class EditSettingsPage extends StatefulWidget {
  const EditSettingsPage({Key? key}) : super(key: key);

  @override
  _EditSettingsPageState createState() => _EditSettingsPageState();
}

class _EditSettingsPageState extends State<EditSettingsPage> {
  final _settingsFormKey = new GlobalKey<FormBuilderState>();
  late YogaSettings _settings;
  late String dropdownValue;

  @override
  void didChangeDependencies() {
    _settings = Provider.of<YogaSettings>(context, listen: false);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _settings.saveSettings();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.lime, Colors.white],
                end: Alignment.topLeft,
                begin: Alignment.bottomRight,
              ), /*
              image: DecorationImage(
                image: AssetImage("assets/images/bg-blue.jpeg"),
                fit: BoxFit.cover,
              ),*/
            ),
          ),
          _editSettingsPage(),
        ],
      ),
    );
  }

  Widget _editSettingsPage() {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);

    return SingleChildScrollView(
      child: Column(children: <Widget>[
        FormBuilder(
          key: _settingsFormKey,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                // Email and user name

                Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    settings.getUser().email +
                        ', Verified: ' +
                        settings.getUser().verified.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: TextFormField(
                    initialValue: settings.getUser().name,
                    validator: (val) => val!.isNotEmpty ? null : 'Enter a name',
                    onChanged: (val) {
                      if (val != '')
                        settings.setUserName(val);
                      else
                        settings.setUserName(
                            settings.getUser().email.split('@')[0]);
                    },
                    decoration: textInputDeco.copyWith(hintText: 'Name'),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),

                // Notify

                kIsWeb
                    ? Container()
                    : Row(
                        children: [
                          Text(
                            settings.getNotify() == settings.defNotify
                                ? ''
                                : '* ',
                            style: starStyle,
                          ),
                          Text('Daily Notifications', style: settingsTextStyle),
                          _infoIcon(topicNotify),
                          Expanded(
                            child: Container(),
                          ),
                          Switch(
                            value: settings.getNotify(),
                            onChanged: (val) {
                              setState(() {
                                settings.setNotify(val);
                              });
                            },
                          ),
                        ],
                      ),

                // Reset to defaults

                SizedBox(height: 10),
                ElevatedButton(
                    onPressed: settings.allDefaults()
                        ? null
                        : () {
                            settings.setNotify(settings.defNotify);
                            Navigator.pop(context);
                          },
                    child: Text('Defaults')),
                SizedBox(height: 20),
              ],
            ),
          ),
        )
      ]),
    );
  }

  static const String topicNotify = 'notify';

  Widget _infoIcon(String topic) {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);

    String msg = '';
    switch (topic) {
      case topicNotify:
        msg = 'Enable or disable daily notifications';
        break;
      default:
    }
    return IconButton(
      icon: Icon(Icons.help_outline, size: 15),
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: Text(msg),
            title: Text('Information'),
          ),
        );
      },
    );
  }
}
