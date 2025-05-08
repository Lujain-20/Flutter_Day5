import 'package:flutter/material.dart';
import 'package:task_day5/controllers/hive_controller.dart';
import 'package:task_day5/controllers/sqlite_controller.dart';
import 'package:task_day5/models/note.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

enum StorageType { hive, sqlite }

class _NotesScreenState extends State<NotesScreen> {
  final SqliteController sqliteController = SqliteController();
  final HiveController hiveController = HiveController();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<Note> _notes = [];
  StorageType selectedStorage = StorageType.hive;

  void _initHive() async {
    hiveController.init();
  }

  void _loadNotes() async {
    if (selectedStorage == StorageType.sqlite) {
      final notes = await sqliteController.getNotes();
      setState(() => _notes = notes);
    } else {
      final notes = await hiveController.getNotes();
      setState(() => _notes = notes);
    }
  }

  void _addNote() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      return;
    }

    final note = Note(
      title: _titleController.text,
      description: _descriptionController.text,
    );

    if (selectedStorage == StorageType.sqlite) {
      await sqliteController.insert(note);
    } else {
      hiveController.add(note);
    }

    _titleController.clear();
    _descriptionController.clear();
    _loadNotes();
  }

  void deleteNote(int? id, int index) async {
    if (selectedStorage == StorageType.sqlite) {
      await sqliteController.delete(id);
    } else {
      hiveController.delete(index);
    }
    setState(() => _loadNotes());
  }

  @override
  void initState() {
    super.initState();
    _initHive();
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text(
          'My Notes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF16213E),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F3460),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 10)],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(),
                      prefixIcon: const Icon(
                        Icons.title,
                        color: Colors.white70,
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descriptionController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(),
                      prefixIcon: const Icon(
                        Icons.description,
                        color: Colors.white70,
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _addNote,
                        icon: const Icon(Icons.add, color: Colors.black),
                        label: const Text(
                          "Add Note",
                          style: TextStyle(color: Colors.black),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                      DropdownButton<StorageType>(
                        dropdownColor: const Color(0xFF0F3460),
                        value: selectedStorage,
                        style: const TextStyle(color: Colors.white),
                        iconEnabledColor: Colors.amber,
                        items: const [
                          DropdownMenuItem(
                            value: StorageType.sqlite,
                            child: Text('SQLite'),
                          ),
                          DropdownMenuItem(
                            value: StorageType.hive,
                            child: Text('Hive'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => selectedStorage = value!);
                          _loadNotes();
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_forever,
                          color: Colors.redAccent,
                        ),
                        tooltip: "Clear Hive",
                        onPressed: () {
                          hiveController.clear();
                          _loadNotes();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Your Notes:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return Card(
                  color: const Color(0xFF1A1A2E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    title: Text(
                      note.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      note.description,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      onPressed: () async {
                        deleteNote(note.id, index);
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
