import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:safe_note/utils.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _storage = const FlutterSecureStorage();
  final _passwordControllerFirst = TextEditingController();
  final _passwordControllerSecond = TextEditingController();
  final _passwordControllerThird = TextEditingController();

  final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20),
      padding: const EdgeInsets.all(16));

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safe Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  obscureText: true,
                  controller: _passwordControllerThird,
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Enter your old password',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  obscureText: true,
                  controller: _passwordControllerSecond,
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Enter your new password',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  obscureText: true,
                  controller: _passwordControllerFirst,
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Reenter new password',
                  ),
                ),
              ),
              ElevatedButton(
                style: style,
                onPressed: () async {
                  var salt = await _storage.read(key: "salt");
                  var passwordFromStorage = await _storage.read(key: "hashed");
                  var pass = _passwordControllerThird.text.trim();
                  var hmacSha256 = Hmac(sha256, utf8.encode(salt!));
                  var hashed = hmacSha256.convert(utf8.encode(pass));
                  if (hashed.toString() == passwordFromStorage) {
                    if (_passwordControllerSecond.text.trim() ==
                        _passwordControllerFirst.text.trim()) {
                      var salt = generateRandomString(32);
                      var pass = _passwordControllerFirst.text.trim();
                      var hmacSha256 = Hmac(sha256, utf8.encode(salt));
                      var hashed = hmacSha256.convert(utf8.encode(pass));
                      await _storage.write(key: 'salt', value: salt);
                      await _storage.write(
                          key: 'hashed', value: hashed.toString());
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    } else {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return const AlertDialog(
                              content: Text("Passwords do not match!"),
                            );
                          });
                    }
                  } else {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return const AlertDialog(
                            content: Text("Wrong old password!"),
                          );
                        });
                  }
                },
                child: const Text('Save'),
              ),
            ]),
      ),
    );
  }
}
