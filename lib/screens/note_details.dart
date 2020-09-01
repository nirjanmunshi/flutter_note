import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/database/note_database.dart';
import 'package:flutter_app/models/note.dart';
import 'package:intl/intl.dart';

class NoteDetails extends StatefulWidget {
  String _appBarTitle;
  Note _note;

  NoteDetails(this._note, this._appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this._note, this._appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetails> {
  String title;
  Note note;

  NoteDetailState(this.note, this.title);

  NoteDb db = NoteDb();

  static var _priorities = ['High', 'Low'];
  EdgeInsets _itemPadding = EdgeInsets.only(top: 15.0, bottom: 15.0);

  TextEditingController titleEditingController = TextEditingController();
  TextEditingController descriptionEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.title),
      ),
      body: noteDetailsBody(),
    );
  }

  noteDetailsBody() {
    TextStyle textStyle = Theme.of(context).textTheme.subtitle1;
    titleEditingController.text = note.title;
    descriptionEditingController.text = note.description;
    return Padding(
      padding: EdgeInsets.only(top: 15.0, bottom: 0.0, right: 10.0, left: 10.0),
      child: ListView(
        children: [
          // first element
          ListTile(
            title: DropdownButton(
              items: _priorities.map((spinnerItem) {
                return DropdownMenuItem<String>(
                  value: spinnerItem,
                  child: Text(spinnerItem),
                );
              }).toList(),
              style: textStyle,
              value: updatePriorityAsString(note.priority),
              onChanged: (value) {
                setState(() {
                  debugPrint('user selected $value');
                  updatePriorityAsInt(value);
                });
              },
            ),
          ),

          // second element
          Padding(
            padding: _itemPadding,
            child: TextField(
              controller: titleEditingController,
              style: textStyle,
              onChanged: (value) {
                debugPrint("titleBox: $value");
                updateTitle();
              },
              decoration: InputDecoration(
                  labelStyle: textStyle,
                  labelText: "Title",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  )),
            ),
          ),

          // third element
          Padding(
            padding: _itemPadding,
            child: TextField(
              controller: descriptionEditingController,
              style: textStyle,
              onChanged: (value) {
                debugPrint("descriptionBox: $value");
                updateDescription();
              },
              decoration: InputDecoration(
                  labelStyle: textStyle,
                  labelText: "Description",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  )),
            ),
          ),

          // fourth element
          Padding(
            padding: _itemPadding,
            child: Row(
              children: [
                Expanded(
                  child: RaisedButton(
                    onPressed: () {
                      setState(() {
                        debugPrint("save button clicked");
                        _save();
                      });
                    },
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryColorLight,
                    child: Text(
                      "Save",
                      textScaleFactor: 1.5,
                    ),
                  ),
                ),
                Container(
                  width: 5.0,
                ),
                Expanded(
                  child: RaisedButton(
                    onPressed: () {
                      setState(() {
                        debugPrint("Delete button clicked");
                        _delete();
                      });
                    },
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryColorLight,
                    child: Text(
                      "Delete",
                      textScaleFactor: 1.5,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  String updatePriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0];
        break;
      case 2:
        priority = _priorities[1];
        break;
    }
    return priority;
  }

  void updateTitle() {
    note.title = titleEditingController.text;
  }

  void updateDescription() {
    note.description = descriptionEditingController.text;
  }

  void _save() async {
    moveToLastScreen();
    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id != null) {
      // id exists so update
      result = await db.updateNote(note);
    } else {
      // id not exists so insert
      result = await db.insertNote(note);
    }

    if (result != 0) {
      _showAlertDialog('Success', "Note saved successfully");
    } else {
      _showAlertDialog('Failure', 'Something went wrong');
    }
  }

  void _delete() async {
    moveToLastScreen();

    // Case 1: If user is trying to delete the NEW NOTE i.e. he has come to
    // the detail page by pressing the FAB of NoteList page.
    if (note.id == null) {
      _showAlertDialog('Status', 'No Note was deleted');
      return;
    }

    // Case 2: User is trying to delete the old note that already has a valid ID.
    int result = await db.deleteNote(note.id);
    if (result != 0) {
      _showAlertDialog('Status', 'Note Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error occured while Deleting Note');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );

    showDialog(context: context, builder: (_) => alertDialog);
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }
}
