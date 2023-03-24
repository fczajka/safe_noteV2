import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:safe_note/views/note.dart';
import 'package:safe_note/utils.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _storage = const FlutterSecureStorage();
  bool _isSet = false;
  var pass = "";

  @override
  void initState() {
    super.initState();
    getNote();
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  Future getNote() async {
    String? note = await _storage.read(key: 'note');
    if (note == null) {
      _isSet = false;
    } else {
      _isSet = true;
    }
    setState(() {});
  }

  final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20),
      padding: const EdgeInsets.all(16));

  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isSet) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: TextField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Enter p@\$\$w0rd',
                ),
                controller: myController,
              ),
            ),
            ElevatedButton(
                style: style,
                child: const Text('Log in with p@\$\$w0rd'),
                onPressed: () async {
                  var salt = await _storage.read(key: "salt");
                  var passwordFromStorage = await _storage.read(key: "hashed");
                  var pass = myController.text.trim();
                  var hmacSha256 = Hmac(sha256, utf8.encode(salt!));
                  var hashed = hmacSha256.convert(utf8.encode(pass));

                  if (hashed.toString() == passwordFromStorage) {
                    var note = await _storage.read(key: "note");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Note(note: note!)),
                    );
                  } else {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return const AlertDialog(
                            content: Text("Wrong password!"),
                          );
                        });
                  }
                  setState(() {
                    myController.text = "";
                    _isSet = true;
                  });
                }),
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: ElevatedButton(
                    style: style,
                    child: const Text('Log in with finger'),
                    onPressed: () async {
                      final LocalAuthentication auth = LocalAuthentication();
                      final bool canAuthenticateWithBiometrics =
                          await auth.canCheckBiometrics;
                      final bool canAuthenticate =
                          canAuthenticateWithBiometrics ||
                              await auth.isDeviceSupported();

                      if (!canAuthenticate) {
                        return;
                      }
                      final bool didAuthenticate;
                      try {
                        didAuthenticate = await auth.authenticate(
                            localizedReason: 'Sign in',
                            options: const AuthenticationOptions(
                                biometricOnly: true));
                      } on PlatformException catch (e) {
                        if (e.code == auth_error.lockedOut) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return const AlertDialog(
                                  content: Text("Wrong password!"),
                                );
                              });
                        }
                        return;
                      }

                      if (didAuthenticate) {
                        var note = await _storage.read(key: "note");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Note(note: note!)),
                        );
                      } else {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return const AlertDialog(
                                content: Text("Wrong finger!!!"),
                              );
                            });
                      }

                      setState(() {
                        myController.text = "";
                        _isSet = true;
                      });
                    }))
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: TextField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Set p@\$\$w0rd',
                ),
                controller: myController,
              ),
            ),
            ElevatedButton(
                style: style,
                child: const Text('Set password'),
                onPressed: () async {
                  var salt = generateRandomString(32);
                  var pass = myController.text.trim();
                  var hmacSha256 = Hmac(sha256, utf8.encode(salt));
                  var hashed = hmacSha256.convert(utf8.encode(pass));

                  await _storage.write(key: 'salt', value: salt);
                  await _storage.write(key: 'hashed', value: hashed.toString());
                  await _storage.write(
                      key: "note", value: "Enter your note here");

                  setState(() {
                    myController.text = "";
                    _isSet = true;
                  });
                }),
          ],
        ],
      ),
    );
  }
}
