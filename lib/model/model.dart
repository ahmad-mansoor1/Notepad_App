
class NotesModel{

  final int? id;
  final String title;
  final String description;
  String createdTime; // Store timestamp as a string

  NotesModel({this.id ,required this.title, required this.description, required this.createdTime});



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