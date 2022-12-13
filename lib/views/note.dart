import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:safe_note/views/changePassword.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class Note extends StatefulWidget {
  final String note;
  const Note({super.key, required this.note});

  @override
  State<Note> createState() => _NoteState();
}

class _NoteState extends State<Note> {
  final _storage = const FlutterSecureStorage();
  final _noteController = TextEditingController();
  final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20),
      padding: const EdgeInsets.all(16));

  bool _isSet = false;

  @override
  void initState() {
    super.initState();
    getNote();
  }

  Future getNote() async {
    _noteController.text = widget.note;
    _isSet = true;
    setState(() {});
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
            TextField(
              controller: _noteController,
              maxLines: 7,
              decoration: const InputDecoration.collapsed(
                hintText: 'Enter your note here',
              ),
            ),
            ElevatedButton(
              style: style,
              onPressed: () async {
                await _storage.write(
                    key: 'note', value: _noteController.text.trim());
                setState(() {
                  _isSet = true;
                });
              },
              child: const Text('Save!'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChangePassword()),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.settings),
      ),
    );
  }
}
