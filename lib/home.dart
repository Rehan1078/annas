import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dbhelper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController titlecontroller = TextEditingController();
  TextEditingController desccontroller = TextEditingController();
  List<Map<String, dynamic>> allNotes = [];

  DBHelper? dbRef;

  @override
  void initState() {
    super.initState();
    dbRef = DBHelper.getInstance;
    getNotes(); // Fetch notes when the app starts
  }

  void getNotes() async {
    allNotes = await dbRef!.getallNotes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes App"),
      ),
      body: allNotes.isNotEmpty
          ? ListView.builder(
        itemCount: allNotes.length,
        itemBuilder: (_, index) {
          return ListTile(
            leading: Text("${allNotes[index][DBHelper.COLUMN_NOTE_SNO]}"),
            title: Text(allNotes[index][DBHelper.COLUMN_NOTE_TITLE]),
            subtitle: Text(allNotes[index][DBHelper.COLUMN_NOTE_DISC]),
            trailing: SizedBox(
              width: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      titlecontroller.text = allNotes[index][DBHelper.COLUMN_NOTE_TITLE];
                      desccontroller.text = allNotes[index][DBHelper.COLUMN_NOTE_DISC];
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return getBottomSheetWidget(
                            isUpdate: true,
                            sno: allNotes[index][DBHelper.COLUMN_NOTE_SNO],
                          );
                        },
                      );
                    },
                    child: Icon(Icons.edit),
                  ),
                  InkWell(
                    onTap: () async {
                      bool deleted = await dbRef!.deleteNote(sno: allNotes[index][DBHelper.COLUMN_NOTE_SNO]);
                      if (deleted) {
                        Fluttertoast.showToast(msg: "Note deleted successfully");
                        getNotes();
                      } else {
                        Fluttertoast.showToast(msg: "Failed to delete note");
                      }
                    },
                    child: Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            ),
          );
        },
      )
          : Center(child: Text("No Notes yet")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          titlecontroller.clear();
          desccontroller.clear();
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return getBottomSheetWidget();
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  ButtonStyle customButtonStyle() {
    return OutlinedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      side: BorderSide(
        width: 4,
      ),
    );
  }

  Widget getBottomSheetWidget({bool isUpdate = false, int sno = 0}) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(11),
        width: double.infinity,
        child: Column(
          children: [
            Text(
              isUpdate ? "Update Note" : "Add Note",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
            ),
            SizedBox(height: 23),
            TextField(
              controller: titlecontroller,
              decoration: InputDecoration(
                hintText: "Enter title here*",
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            SizedBox(height: 23),
            TextField(
              controller: desccontroller,
              maxLength: 400,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Enter your description here*",
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: customButtonStyle(),
                    onPressed: () async {
                      var title = titlecontroller.text;
                      var desc = desccontroller.text;
                      if (title.isNotEmpty && desc.isNotEmpty) {
                        bool check = isUpdate
                            ? await dbRef!.updateNote(title: title, desc: desc, sno: sno)
                            : await dbRef!.addNote(title, desc);
                        if (check) {
                          Fluttertoast.showToast(msg: isUpdate ? "Note updated successfully" : "Note added successfully");
                          getNotes();
                          Navigator.pop(context);
                        } else {
                          Fluttertoast.showToast(msg: "Failed to ${isUpdate ? 'update' : 'add'} note");
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please fill all fields")),
                        );
                      }
                    },
                    child: Text(isUpdate ? "Update Note" : "Add Note"),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: OutlinedButton(
                    style: customButtonStyle(),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancel"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
