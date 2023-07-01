import 'dart:core';

import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;

import 'package:vdo_ninja/theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
import 'src/call_sample/call_sample.dart';
import 'src/route_item.dart';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:wakelock/wakelock.dart';
import 'package:flutter_background/flutter_background.dart';

void main() {
  if (WebRTC.platformIsDesktop) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  } else if (WebRTC.platformIsAndroid) {
    WidgetsFlutterBinding.ensureInitialized();
    startForegroundService();
  }
  runApp(MyApp());
}

Future<bool> startForegroundService() async {
  final androidConfig = FlutterBackgroundAndroidConfig(
    notificationTitle: 'VDO.Ninja background service',
    notificationText: 'VDO.Ninja background service',
    notificationImportance: AndroidNotificationImportance.Default,
    notificationIcon: AndroidResource(
        name: 'background_icon',
        defType: 'drawable'), // Default is ic_launcher from folder mipmap
  );
  await FlutterBackground.initialize(androidConfig: androidConfig);
  return FlutterBackground.enableBackgroundExecution();
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

String streamID = "";
String roomID = "";
String password = "";
bool quality = false;
bool advanced = false;
String WSSADDRESS = 'wss://wss.vdo.ninja:443';

enum DialogDemoAction {
  cancel,
  connect,
}

class _MyAppState extends State<MyApp> {
  List<RouteItem> items = [];
  late SharedPreferences _prefs;

  var _deviceID = "screen";
  List<Color> colors = [
    Color(0xFFA53E97),
    Color(0xFF645098),
    Color(0xFF33517E),
    Colors.amber,
    Colors.red,
	Color(0xF133511E),
	Color(0xF233512E),
	Color(0xF333513E),
	Color(0xF433514E),
	Color(0xF533515E),
	Color(0xF633516E),
	Color(0xF733517E),
	Color(0xF833518E),
	Color(0xF933519E),
	Color(0xFF33510E),
	Color(0xFF33517E),
	Color(0xFF33517E),
	Color(0xFF33517E),
	Color(0xFF33517E),
	Color(0xFF33517E)
  ];

  @override
  initState() {
    super.initState();
    _initData();
    _initItems();
  }

  _buildRow(context, item, index) {
    return Card(
      margin: EdgeInsets.only(top: 20, left: 20, right: 20),
      color: colors[index],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          title: Text(
            item.title,
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          // subtitle: Text(item.subtitle),
          onTap: () => item.push(context),
          trailing: Icon(Icons.arrow_right),
          leading: Icon(
            item.icon,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('VDO.Ninja'),
        ),
        body: Container(
            child: Stack(
          children: [
            SingleChildScrollView(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 25, 0, 0),
                  child: Container(
                    width: double.infinity,
                    child: Text(
                      "Share",
                      textAlign: TextAlign.left,
                      style: theme.textTheme.displayLarge!.apply(
                          color: Colors.white,
                          fontWeightDelta: 10,
                          fontSizeFactor: 1.5),
                    ),
                  ),
                ),
                ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(8.0),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      return _buildRow(context, items[i], i);
                    }),
                Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: TextButton.icon(
                      icon: Icon(Icons.help_center),
                      style: Theme.of(context).elevatedButtonTheme.style,
                      onPressed: () => {_openDiscord()},
                      label: Text("Need help? Join our Discord.")),
                ),
              ],
            )),
          ],
        )),
      ),
    );
  }

  _initData() async {
    _prefs = await SharedPreferences.getInstance();

    streamID = _prefs.getString('streamID') ?? "";
    roomID = _prefs.getString('roomID') ?? "";
    password = _prefs.getString('password') ?? "";
	WSSADDRESS = _prefs.getString('WSSADDRESS') ?? WSSADDRESS;

    try {
      quality = _prefs.getBool('resolution') ?? false;
    } catch (e) {}

    if (streamID == "") {
      var chars = 'AaBbCcDdEeFfGgHhJjKkLMmNnoPpQqRrSsTtUuVvWwXxYyZz23456789';
      Random _rnd = Random();
      String getRandomString(int length) =>
          String.fromCharCodes(Iterable.generate(
              length, (_) => chars.codeUnitAt(_rnd.nextInt(chars.length))));
      streamID = getRandomString(8);
      _prefs.setString('streamID', streamID);
    }

    setState(() {
      Wakelock.enable();
      // You could also use Wakelock.toggle(on: true);
    });

    final androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: "VDO.Ninja",
      notificationText: "VDO.Ninja is running in the background",
      notificationImportance: AndroidNotificationImportance.Default,
      notificationIcon: AndroidResource(
          name: 'background_icon',
          defType: 'drawable'), // Default is ic_launcher from folder mipmap
    );
    await FlutterBackground.initialize(androidConfig: androidConfig);
  }

  void showDemoDialog<T>({required BuildContext context, required Widget child}) {
    showDialog<T>(
      context: context,
      builder: (BuildContext context) => child,
    ).then<void>((T? value) {
      // The value passed to Navigator.pop() or null.
        if (value == DialogDemoAction.connect) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CallSample(
						key: new GlobalKey<ScaffoldState>(),
                        streamID: streamID,
                        deviceID: _deviceID,
                        roomID: roomID,
                        quality: quality,
						WSSADDRESS: WSSADDRESS,
						muted: false,
						preview: true,
						mirrored:true
                      )));
        }
      
    });
  }

  _showAddressDialog(context) {
    showDemoDialog<DialogDemoAction>(
        context: context,
        child: AlertDialog(
            title: const Text('Publishing settings'),
            content: Stack(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: TextField(
                  onChanged: (String text) {
                    setState(() {
                      streamID = text;
                      _prefs.setString('streamID', streamID);
                    });
                  },
                  decoration: InputDecoration(
                    hintText: streamID,
                    labelText: 'Stream ID',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                child: TextField(
                  controller: TextEditingController()..text = roomID ?? "",
                  onChanged: (String text) {
                    setState(() {
                      roomID = text;
                      _prefs.setString('roomID', roomID);
                    });
                  },
                  decoration: InputDecoration(
                    hintText: roomID ?? "Room name",
                    labelText: 'Optional room name',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
                child: SwitchListTile(
                    title: const Text('Prefer 1080p'),
                    value: quality,
                    onChanged: (bool value) {
                      _prefs.setBool('resolution', value);
                      setState(() {
                        quality = value;
                        Navigator.pop(context);
                        _showAddressDialog(context);
                      });
                    }),
              ),
			  
			  Padding(
                padding: const EdgeInsets.fromLTRB(0, 145, 0, 0),
                child: Text(
                  '(Passwords not yet supported)',
                  style: TextStyle(
                      color: Color.fromARGB(255, 188, 188, 188), fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
			  
			  if (!advanced)
			   Padding(
                padding: const EdgeInsets.fromLTRB(0, 160, 0, 0),
                child: SwitchListTile(
                    title: const Text('Advanced'),
                    value: advanced,
                    onChanged: (bool value) {
                      _prefs.setBool('advanced', value);
                      setState(() {
                        advanced = value;
                        Navigator.pop(context);
                        _showAddressDialog(context);
                      });
                    }),
              ),
			  
			  if (advanced)
				Padding(
					padding: const EdgeInsets.fromLTRB(0, 170, 0, 0),
					child: TextField(
					  onChanged: (String text) {
						setState(() {
						  WSSADDRESS = text;
						  _prefs.setString('WSSADDRESS', WSSADDRESS);
						});
					  },
					  decoration: InputDecoration(
						hintText: WSSADDRESS,
						labelText: 'Handshake server',
					  ),
					  textAlign: TextAlign.center,
					),
				),
              //     Padding(
              //        padding: const EdgeInsets.fromLTRB(0, 130, 0, 0),
              //        child: TextField(
              //         onChanged: (String text) {
              //            setState(() {
              //              password = text;
              //              _prefs.setString('Password:', password);
              //            });
              //          },
              //          decoration: InputDecoration(
              //            hintText: "Password",
              //            labelText: 'Optional password',
              //          ),
              //          textAlign: TextAlign.center,
              //        ),
              //       ),

              
            ]),
            actions: <Widget>[
              TextButton(
                  child: const Text('CANCEL'),
                  onPressed: () {
                    Navigator.pop(context, DialogDemoAction.cancel);
                  }),
              TextButton(
                  child: const Text('CONNECT'),
                  onPressed: () {
                    Navigator.pop(context, DialogDemoAction.connect);
                  })
            ]));
  }

  _initItems() async {
    items = <RouteItem>[];

    items.add(RouteItem(
        title: 'SCREEN',
        subtitle: 'Share your device\'s screen',
        icon: Icons.screen_share,
        push: (BuildContext context) {
          _deviceID = "screen";
          _showAddressDialog(context);
        }));

    var devices = await navigator.mediaDevices.enumerateDevices();
    for (var item in devices) {
      if (item.kind != "videoinput") {
        continue;
      }

      var cameraType = "Camera";

      if (item.label.toLowerCase().contains('back')) {
        cameraType = 'Back Camera';
      } else if (item.label.toLowerCase().contains('rear')) {
        cameraType = 'Back Camera';
      } else if (item.label.toLowerCase().contains('user')) {
        cameraType = 'Front Camera';
      } else if (item.label.toLowerCase().contains('front')) {
        cameraType = 'Front Camera';
      } else if (item.label.toLowerCase().contains('environment')) {
        cameraType = 'Rear Camera';
      } else      cameraType = item.label;


      items.add(RouteItem(
          title: cameraType.toUpperCase(),
          subtitle: item.label.toString(),
          icon: item.label.toLowerCase().contains('front') ||
                  item.label.toLowerCase().contains('user')
              ? Icons.video_camera_front
              : Icons.video_camera_back,
          push: (BuildContext context) {
            _deviceID = item.deviceId;
            _showAddressDialog(context);
          }));

      //if (item.label.contains('front')) {
      //  cameraType = 'Camera + Screen';
      //   items.add(RouteItem(
      //      title: cameraType.toUpperCase(),
      //      subtitle: item.label.toString(),
      //    icon: Icons.auto_awesome_mosaic,
      //  push: (BuildContext context) {
      //      _deviceID = "screen_" + item.deviceId;
      //     _showAddressDialog(context);
      //   }));
      // }
      //}
    }
	
	
	 items.add(RouteItem(
        title: 'MICROPHONE',
        subtitle: 'Share microphone audio only',
        icon: Icons.mic,
        push: (BuildContext context) {
          _deviceID = "microphone";
          _showAddressDialog(context);
        }));
	
    setState(() {});
  }

  _openDiscord() async {
    const url = 'https://discord.vdo.ninja';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
