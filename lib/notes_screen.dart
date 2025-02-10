import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_notepad/add_notes.dart';
import 'package:my_notepad/constant.dart';
import 'package:my_notepad/edit_screen.dart';

import 'db_helper/db_helper.dart';
import 'model/model.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String search = "";
  bool isSearch = false;
  TextEditingController searchController = TextEditingController();

  DBHelper? dbHelper;

  // late Future<List<NotesModel>> notesList;
  late Future<List<NotesModel>> notesList = Future.value([]);

  void getData() async {
    List<NotesModel> localNotes = await dbHelper!.getNotesModelList();

    if (localNotes.isEmpty) {
      print("Local DB is empty. Fetching from Firebase...");
      await syncFirestoreToLocalDB();
    }

    setState(() {
      notesList = dbHelper!.getNotesModelList(); // Refresh UI
    });
  }

  Future<void> syncFirestoreToLocalDB() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('notes').get();

    for (var doc in snapshot.docs) {
      NotesModel note = NotesModel(
        title: doc['title'],
        description: doc['description'],
        createdTime: doc['createdTime'],
      );

      await dbHelper!.insert(note);  // Store into SQLite
    }

    print("FireStore data synced to local DB.");
  }


  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    getData();

  }

  Future<bool> _onWillPop() async {
    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Exit"),
            content: Text("Are you sure you want to close?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // Stay in app
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true), // Exit app
                child: Text("Exit"),
              ),
            ],
          );
        });
  }

  Future<bool> _showDeleteAllDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Delete All Notes"),
              content: Text("Are you sure you want to delete all notes? This action cannot be undone."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false), // Cancel
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true), // Confirm deletion
                  child: Text("Delete All"),
                ),
              ],
            );
          },
        ) ??
        false;
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.blueGrey[200],
        appBar: isSearch == false
            ? AppBar(
                centerTitle: true,
                backgroundColor: backgroundColor,
                foregroundColor: Colors.white,
                title: Text('My Notepad'),
                actions: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          isSearch = true;
                        });
                      },
                      icon: Icon(Icons.search)),

                  // showDeleteAllDialog()

                  IconButton(
                    onPressed: () async {
                      bool shouldDelete = await _showDeleteAllDialog();
                      if (shouldDelete) {

                        // Delete all notes from Firebase FireStore
                        await FirebaseFirestore.instance.collection('notes').get().then((querySnapshot) {
                          for (var doc in querySnapshot.docs) {
                            doc.reference.delete();
                          }
                        });

                        await dbHelper!.deleteAllNotes(); // Call the deleteAll method
                        setState(() {
                          notesList = dbHelper!.getNotesModelList(); // Refresh the notes list
                        });
                      }
                    },
                    icon: Icon(Icons.delete_sweep), // Icon for deleting all notes
                  ),
                ],
              )
            : AppBar(
                centerTitle: true,
                backgroundColor: backgroundColor,
                foregroundColor: Colors.white,
                leading: BackButton(
                  onPressed: () {
                    setState(() {
                      isSearch = false;
                    });
                  },
                ),
                title: TextFormField(
                  controller: searchController,
                  maxLines: 1,
                  decoration: InputDecoration(
                      hintText: 'search',
                      hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white54),
                      border: InputBorder.none),
                  onChanged: (String value) {
                    search = value.toString();
                    setState(() {});
                  },
                ),
              ),

        body: FutureBuilder<List<NotesModel>>(
          future: notesList,
          builder: (context, AsyncSnapshot<List<NotesModel>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator()); // Show loading indicator
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}')); // Handle errors gracefully
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No notes found')); // Handle empty data
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                  reverse: false,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, int index) {
                    String noteId = snapshot.data![index].id.toString();
                    String noteTitle = snapshot.data![index].title.toLowerCase();
                    String searchQuery = searchController.text.toLowerCase();

                    if (searchController.text.isEmpty || noteTitle.contains(searchQuery) || noteId.contains(searchQuery)) {
                      return Dismissible(
                          direction: DismissDirection.endToStart,
                          key: ValueKey(snapshot.data![index].id),
                          background: Container(
                            color: Colors.red,
                            child: Icon(Icons.delete_forever),
                          ),
                          onDismissed: (DismissDirection direction) async {

                            await dbHelper!.delete(snapshot.data![index].id!);


                            await FirebaseFirestore.instance.collection('notes').where('createdTime', isEqualTo: snapshot.data![index].createdTime).get()
                                .then((querySnapshot) {
                              for (var doc in querySnapshot.docs) {
                                doc.reference.delete();
                              }
                            });

                            setState(() {
                              notesList = dbHelper!.getNotesModelList();

                            });
                          },
                          child: InkWell(
                            onTap: () {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EditScreen(
                                          id: snapshot.data![index].id,
                                          title: snapshot.data![index].title.toString(),
                                          description: snapshot.data![index].description.toString())));
                            },
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  SizedBox(
                                    width: 50, // Fixed width for the leading widget
                                    child: CircleAvatar(
                                      backgroundColor: backgroundColor,
                                      radius: 20,
                                      // child: Text(snapshot.data![index].id.toString()),
                                      child: Text((index + 1).toString()),
                                    ),
                                  ),
                                  SizedBox(width: 10), // Add spacing between avatar and text
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          snapshot.data![index].title.toString(),
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 5), // Space between title and description
                                        Text(
                                          snapshot.data![index].description.toString(),
                                          maxLines: 1, // Limit max lines for better UI
                                          overflow: TextOverflow.ellipsis, // Prevent overflow issues
                                        ),
                                      ],
                                    ),
                                  ),

                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(snapshot.data![index].createdTime)),
                                        // Display time
                                        style: TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ]),
                              ),
                            ),
                          ));
                    }

                    return SizedBox();
                  }),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          shape: CircleBorder(),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AddNotes()));
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}