import 'package:flutter/material.dart';
import 'package:my_notepad/add_notes.dart';
import 'package:my_notepad/constant.dart';
import 'package:my_notepad/edit_screen.dart';

import 'db_helper.dart';
import 'model.dart';

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

  void getData() {
    setState(() {
      notesList = dbHelper?.getNotesModelList() ?? Future.value([]); // If dbHelper is null, return an empty list
    });
  }

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[200],

      appBar: isSearch == false

     ? AppBar(
        centerTitle: true,

        backgroundColor: backgroundColor,

        foregroundColor: Colors.white,
        title: Text('My Notepad'),
        actions: [
          IconButton(

              onPressed: (){
                setState(() {
                  isSearch = true;
                });
              },
              icon: Icon(Icons.search)
          ),
        ],
      )

      : AppBar(
        centerTitle: true,

        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
       
        leading: BackButton(
          onPressed: (){
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
            border: InputBorder.none
          ),

          onChanged: (String value){

            search = value.toString();
            setState(() {});
          },

        ),
        
        
        
      ),
      
      body: FutureBuilder<List<NotesModel>>(
        future: notesList,
        builder: (context, AsyncSnapshot<List<NotesModel>> snapshot){

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

                itemCount: snapshot.data!.length,
                itemBuilder: (context, int index){
                  String noteId = snapshot.data![index].id.toString();
                  String noteTitle = snapshot.data![index].title.toLowerCase();
                  String searchQuery = searchController.text.toLowerCase();

                  if(searchController.text.isEmpty || noteTitle.contains(searchQuery) || noteId.contains(searchQuery)){

                    return Card(

                      child: ListTile(
                        contentPadding: EdgeInsets.all(10),

                        leading: CircleAvatar(
                          backgroundColor: backgroundColor,
                          radius: 20,
                          child: Text(snapshot.data![index].id.toString()),
                        ),
                        title: Text(snapshot.data![index].title.toString(), style: TextStyle(fontWeight: FontWeight.bold),),
                        subtitle: Text(snapshot.data![index].description.toString()),
                        trailing: PopupMenuButton(
                            itemBuilder: (context)=>
                            [
                              PopupMenuItem(
                                child: ListTile(
                                  leading: Icon(Icons.edit, color: Colors.green,),
                                  title: Text('Edit'),
                                  onTap: (){

                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>EditScreen(
                                        id: snapshot.data![index].id,
                                        title: snapshot.data![index].title.toString(),
                                        description: snapshot.data![index].description.toString()
                                    )
                                    ));

                                  },

                                ),
                              ),

                              PopupMenuItem(
                                child: ListTile(
                                  leading: Icon(Icons.delete, color: Colors.red),
                                  title: Text('Delete'),
                                  onTap: (){

                                    setState(() {
                                      dbHelper!.delete(snapshot.data![index].id!);
                                      notesList = dbHelper!.getNotesModelList();
                                      snapshot.data!.remove(snapshot.data![index]);
                                      Navigator.pop(context);
                                    });

                                  },

                                ),
                              ),


                            ]
                        ),


                      ),

                    );

                  } else if(snapshot.data![index].title.toLowerCase().contains(searchController.text.toLowerCase()))
                  {
                    return Card(

                      child: ListTile(
                        contentPadding: EdgeInsets.all(10),

                        leading: CircleAvatar(
                          backgroundColor: backgroundColor,
                          radius: 20,
                          child: Text(snapshot.data![index].id.toString()),
                        ),
                        title: Text(snapshot.data![index].title.toString(), style: TextStyle(fontWeight: FontWeight.bold),),
                        subtitle: Text(snapshot.data![index].description.toString()),
                        trailing: PopupMenuButton(
                            itemBuilder: (context)=>
                            [
                              PopupMenuItem(
                                child: ListTile(
                                  leading: Icon(Icons.edit, color: Colors.green,),
                                  title: Text('Edit'),
                                  onTap: (){

                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>EditScreen(
                                        id: snapshot.data![index].id,
                                        title: snapshot.data![index].title.toString(),
                                        description: snapshot.data![index].description.toString()
                                    )
                                    ));

                                  },

                                ),
                              ),

                              PopupMenuItem(
                                child: ListTile(
                                  leading: Icon(Icons.delete, color: Colors.red),
                                  title: Text('Delete'),
                                  onTap: (){

                                    setState(() {
                                      dbHelper!.delete(snapshot.data![index].id!);
                                      notesList = dbHelper!.getNotesModelList();
                                      snapshot.data!.remove(snapshot.data![index]);
                                      Navigator.pop(context);
                                    });

                                  },

                                ),
                              ),


                            ]
                        ),


                      ),

                    );
                  }

                  else{

                  }
                  return SizedBox();

                }
            ),
          );
        },
      ),


      floatingActionButton: FloatingActionButton(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>AddNotes()));
        },
        child: Icon(Icons.add),
      ),

    );
  }
}
