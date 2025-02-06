import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_notepad/constant.dart';
import 'package:my_notepad/db_helper/db_helper.dart';
import 'package:my_notepad/model/model.dart';
import 'package:my_notepad/notes_screen.dart';

class AddNotes extends StatefulWidget {
  const AddNotes({super.key});

  @override
  State<AddNotes> createState() => _AddNotesState();
}

class _AddNotesState extends State<AddNotes> {

  final _formKey = GlobalKey<FormState>();

  DBHelper? dbHelper;
  late Future<List<NotesModel>> notesList;

  @override
  void initState() {
    dbHelper = DBHelper();
    super.initState();
  }



  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        title: Text('Add Note'),
      ),


      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [

                      TextFormField(
                        controller: titleController,
                      validator: (value){
                          if(value == null || value.isEmpty){
                            return 'Please Enter Title';
                          }
                          return null;

                      },

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
                      SizedBox(height: 10),
                      Container(
                        constraints: BoxConstraints(minHeight: 250),
                        child: TextFormField(

                          controller: descriptionController,

                          validator: (value){
                            if(value == null || value.isEmpty){
                              return 'Please Enter Some Description';
                            }
                            return null;

                          },
                          maxLines: 22,
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
                      ),

                    ],
                  ),
                ),
              ),

              SizedBox(height: 30),
              SizedBox(

                width: 200,
                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(
                    backgroundColor: backgroundColor,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.blueGrey
                  ),
                    onPressed: (){

                    if(_formKey.currentState!.validate()) {
                      String formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());
                      dbHelper!.insert(NotesModel(
                        title: titleController.text.toString(),
                        description: descriptionController.text.toString(),
                        createdTime: formattedDate,
                    )).then((value){

                      setState(() {

                        notesList = dbHelper!.getNotesModelList();
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>NotesScreen()));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Notes Added'), backgroundColor: Colors.green,));
                      });

                    }).onError((error, stackTrace) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error'), backgroundColor: Colors.red,));

                    });
                    }

                    },
                    child: Text('Save')
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
