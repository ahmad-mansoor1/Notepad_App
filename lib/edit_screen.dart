import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_notepad/constant.dart';
import 'package:my_notepad/db_helper/db_helper.dart';

import 'model/model.dart';
import 'notes_screen.dart';

class EditScreen extends StatefulWidget {
  final String title, description;
  final String id;

  const EditScreen({super.key, required this.title, required this.description, required this.id});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late Future<List<NotesModel>> notesList;

  late TextEditingController titleController = TextEditingController(text: widget.title);
  late TextEditingController descriptionController = TextEditingController(text: widget.description);

  DBHelper? dbHelper;

  late FocusNode titleFocusNode;

  @override
  void initState() {
    dbHelper = DBHelper();
    titleFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    titleFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, object) async {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NotesScreen()));
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          title: GestureDetector(
            onTap: () {
              titleFocusNode.requestFocus();
            },
            child: Text('Edit'),
          ),
          leading: IconButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NotesScreen()));
              },
              icon: Icon(Icons.arrow_back)),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextFormField(
                        focusNode: titleFocusNode,
                        controller: titleController,
                        maxLines: 1,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                        decoration: InputDecoration(
                          hintText: 'Enter a Title',
                          hintStyle: TextStyle(color: Colors.grey),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.blueGrey)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: backgroundColor, width: 0.5),
                          ),
                          fillColor: Colors.grey[300],
                          filled: true,
                        ),
                      ),
                      SizedBox(height: 5),
                      Container(
                        constraints: BoxConstraints(minHeight: 250),
                        child: TextFormField(
                          controller: descriptionController,
                          maxLines: 22,
                          decoration: InputDecoration(
                            focusedBorder:
                                OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.blueGrey)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: backgroundColor, width: 0.5),
                            ),
                            hintText: 'Description',
                            hintStyle: TextStyle(color: Colors.grey),
                            fillColor: Colors.grey[300],
                            filled: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: backgroundColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        int formattedDate = DateTime.now().millisecondsSinceEpoch;

                        // Updated Note Data
                        NotesModel updatedNote = NotesModel(
                          id: widget.id,
                          title: titleController.text.trim(),
                          description: descriptionController.text.trim(),
                          createdTime: formattedDate,
                        );

                        try {
                          // Save to Local Database
                          await dbHelper!.edit(updatedNote);

                          // Save to Firebase FireStore
                          await FirebaseFirestore.instance.collection('notes').doc(widget.id) // Ensure ID is a String
                              .set({ // Use set() to create/update
                            'title': updatedNote.title,
                            'description': updatedNote.description,
                            'createdTime': updatedNote.createdTime,
                          }, SetOptions(merge: true)); // Merge to prevent overwriting

                          // await dbHelper!.edit(updatedNote);
                          // DocumentReference docRef = FirebaseFirestore.instance.collection('notes').doc(widget.id);
                          //
                          // // Check if document exists
                          // // DocumentSnapshot docSnap = await docRef.get();
                          // bool docExists = (await docRef.get()).exists;
                          //
                          // if (docExists) {
                          //   await docRef.update({
                          //     'title': updatedNote.title,
                          //     'description': updatedNote.description,
                          //     'createdTime': updatedNote.createdTime,
                          //   });
                          // } else {
                          //
                          //     if (kDebugMode) {
                          //       print('Error: Note with ID ${widget.id} does not exist in FireStore!');
                          //     }
                          //
                          //     return;

                            // If document doesn't exist, create a new one with the same ID
                            // await docRef.set({
                            //   'title': updatedNote.title,
                            //   'description': updatedNote.description,
                            //   'createdTime': updatedNote.createdTime,
                            // }, SetOptions(merge: true));


                          // Success Message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Update Successful!'), backgroundColor: Colors.green),
                          );

                          // Navigate to Notes Screen
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NotesScreen()));
                        } catch (error) {
                          if (kDebugMode) {
                            print('Error updating note: $error');
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Update Failed!'), backgroundColor: Colors.red),
                          );
                        }
                      },

                      // },
                      child: Text('Update')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
