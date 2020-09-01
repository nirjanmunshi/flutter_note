import 'package:flutter/material.dart';
import 'package:flutter_app/database/note_database.dart';
import 'package:flutter_app/models/note.dart';
import 'package:flutter_app/screens/note_details.dart';
import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {
  NoteDb db = NoteDb();
  List<Note> noteList;
  int _itemCount = 3;

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = List<Note>();
      updateListView();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Note"),
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        tooltip: "fab tooltip",
        child: Icon(Icons.add),
        onPressed: () {
          debugPrint("fab clicked");
          navigateToNoteDetails(Note('','','',0),'Add Note');
        },
      ),
    );
  }

  getNoteListView() {
    TextStyle titleStyle = Theme
        .of(context)
        .textTheme
        .subtitle1;

    return ListView.builder(
        itemCount: _itemCount,
        itemBuilder: (BuildContext context, int position) {
          return Card(
            color: Colors.white,
            elevation: 2.0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                getPriorityColor(this.noteList[position].priority),
                child: getPriorityIcon(this.noteList[position].priority),
              ),
              title: Text(
                this.noteList[position].title,
                style: titleStyle,
              ),
              subtitle: Text(
                this.noteList[position].description,
              ),
              trailing: GestureDetector(
                child: Icon(Icons.delete_sweep),
                onTap: () {
                  _delete(context, noteList[position]);
                },
              ),
              onTap: () {
                debugPrint("On tap list tile");
                navigateToNoteDetails(this.noteList[position],'Edit Note');
              },
            ),
          );
        });
  }

  void navigateToNoteDetails(Note note, String title) async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) => NoteDetails(note, title)));
    if(result == true){
      updateListView();
    }
  }

  void _delete(BuildContext context, Note note) async {
    int result = await db.deleteNote(note.id);
    if (result != 0) {
      _showSnackBar(context, 'Note successfully deleted');
      // update the list view
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String msg) {
    final snackBar = SnackBar(
      content: Text(msg),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  // Returns the priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;

      default:
        return Colors.yellow;
    }
  }

  // Returns the priority icon
  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.play_arrow);
        break;
      case 2:
        return Icon(Icons.keyboard_arrow_right);
        break;

      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = db.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = db.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this._itemCount = noteList.length;
        });
      });
    });
  }

  void listViewUpdate() async {
    Database dbFuture = await db.initializeDatabase();
    List<Note> noteList = await db.getNoteList();
    setState(() {
      this.noteList = noteList;
      this._itemCount = noteList.length;
    });
  }
}


