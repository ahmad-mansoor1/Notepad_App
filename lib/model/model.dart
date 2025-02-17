
class NotesModel{

  final String id;
  final String title;
  final String description;
  int createdTime; // Store timestamp as a string

  NotesModel({required this.id ,required this.title, required this.description, required this.createdTime});



  NotesModel.fromMap(Map<String, dynamic> res):

  id = res['id'],
  title = res['title'],
  description = res['description'],
  createdTime = res['createdTime'];




  Map<String, Object?> toMap(){

    return {

      'id' : id,
      'title' : title,
      'description': description,
      'createdTime' : createdTime,

    };


  }


}