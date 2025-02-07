import 'package:flutter/material.dart';

import '../db_helper/db_helper.dart';
import '../model/model.dart';

class showDeleteAllDialog extends StatefulWidget {
  const showDeleteAllDialog({super.key});

  @override
  State<showDeleteAllDialog> createState() => _showDeleteAllDialogState();
}

class _showDeleteAllDialogState extends State<showDeleteAllDialog> {

  DBHelper? dbHelper;
  late Future<List<NotesModel>> notesList = Future.value([]);
  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper(); // Initialize the DBHelper
    notesList = dbHelper!.getNotesModelList(); // Initialize the notes list
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
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        bool shouldDelete = await _showDeleteAllDialog();
        if (shouldDelete) {
          await dbHelper!.deleteAllNotes(); // Call the deleteAll method
          setState(() {
            notesList = dbHelper!.getNotesModelList(); // Refresh the notes list
          });
        }
      },
      icon: Icon(Icons.delete_sweep), // Icon for deleting all notes
    );
  }
}
