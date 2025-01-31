import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_notepad/constant.dart';
import 'package:my_notepad/db_helper.dart';

import 'model.dart';
import 'notes_screen.dart';


class EditScreen extends StatefulWidget {

  final String title, description;
  final int? id;

  const EditScreen({super.key, required this.title, required this.description, this.id});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {

  late Future<List<NotesModel>> notesList;

  late TextEditingController titleController = TextEditingController(text: widget.title);
 late TextEditingController descriptionController = TextEditingController(text: widget.description);

 DBHelper? dbHelper;

 @override
  void initState() {
    dbHelper = DBHelper();
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        title: Text('Edit'),
      ),


      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [

                  TextFormField(
                    controller: titleController,

                    maxLines: 1,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    decoration: InputDecoration(
                      hintText: 'Enter a Title',
                      hintStyle: TextStyle(color: Colors.grey),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.blueGrey)
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: backgroundColor, width: 0.5),
                      ),
                      fillColor: Colors.grey[300],
                      filled: true,


                    ),
                  ),
                  SizedBox(height: 5),
                  TextFormField(

                    controller: descriptionController,

                    maxLines: 3,
                    // style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.blueGrey)
                      ),
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

                ],
              ),
            ),

            SizedBox(
              width: 200,
              child: ElevatedButton(

                  style: ElevatedButton.styleFrom(
                    backgroundColor: backgroundColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: (){

                    dbHelper!.edit(NotesModel(
                      id: widget.id,
                        title: titleController.text.toString(),
                        description: descriptionController.text.toString()
                    )).then((value){

                      notesList = dbHelper!.getNotesModelList();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update Successfully'), backgroundColor: Colors.green,));
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> NotesScreen()));

                    }).onError((error, stackTrace) {
                      if (kDebugMode) {
                        print('Error');

                      }
                    });

                  },
                  child: Text('Save')
              ),
            ),
          ],
        ),
      ),
    );
  }
}
