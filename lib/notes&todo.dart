import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:to_do_app/sql_helper.dart';

class NotesTodo extends StatefulWidget {
  const NotesTodo({super.key});

  @override
  State<NotesTodo> createState() => _NotesTodoState();
}

class _NotesTodoState extends State<NotesTodo> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  get contentInit => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.brown,
        actions: [
          IconButton(
              onPressed: () {
                sqlHelper().deleteAllNotes();
                sqlHelper().deleteAllTodos().whenComplete(() => setState);
              },
              icon: Icon(Icons.delete))
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
                child: FutureBuilder(
              future: sqlHelper().loadNotes(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return Dismissible(
                            key: UniqueKey(),
                            onDismissed: (direction) {
                              sqlHelper()
                                  .deleteNotes(snapshot.data![index]['id']);
                            },
                            child: Card(
                              color: Colors.purpleAccent,
                              child: Column(
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        showEditNoteDialog(
                                            context,
                                            snapshot.data![index]['title'],
                                            snapshot.data![index]['content'],
                                            snapshot.data![index]['id']);
                                      },
                                      icon: Icon(Icons.edit)),
                                  Text(
                                    'id: ' + (snapshot.data![index]['id']),
                                  ),
                                  Text(
                                    'title: ' +
                                        (snapshot.data![index]['title'])
                                            .toString(),
                                  ),
                                  Text(
                                    'content: ' +
                                        (snapshot.data![index]['content'])
                                            .toString(),
                                  ),
                                ],
                              ),
                            ));
                      });
                }
                return Center(child: CircularProgressIndicator());
              },
            )),
            Expanded(
                child: FutureBuilder(
              future: sqlHelper().loadTodos(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        bool isDone =
                            snapshot.data![index]['value'] == 0 ? false : true;
                        return Card(
                          color: isDone ? Colors.green : Colors.red,
                          child: Row(
                            children: [
                              Checkbox(
                                  value: isDone,
                                  onChanged: (bool? value) {
                                    sqlHelper()
                                        .updateTodoChecked(
                                          snapshot.data![index]['id'],
                                          snapshot.data![index]['value'],
                                        )
                                        .whenComplete(() => setState(() {}));
                                  }),
                              Text(
                                ' ${snapshot.data![index]['title']}',
                                style: TextStyle(
                                    color: isDone ? Colors.white : Colors.teal),
                              ),
                            ],
                          ),
                        );
                      });
                }
                return Center(child: CircularProgressIndicator());
              },
            ))
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            tooltip: 'Increment',
            onPressed: () {
              showInsertNoteDialog(context);
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.purpleAccent,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: FloatingActionButton(
              tooltip: 'Increment',
              onPressed: () {
                showInsertTodoDialog(context);
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  void showInsertNoteDialog(context) {
    showCupertinoDialog(
        context: context,
        builder: (_) {
          return Material(
            color: Colors.brown.withOpacity(0.3),
            child: CupertinoAlertDialog(
              title: Text("Add new Note"),
              content: Column(
                children: [
                  TextField(
                    controller: titleController,
                  ),
                  TextField(
                    controller: titleController,
                  ),
                ],
              ),
              actions: <CupertinoDialogAction>[
                CupertinoDialogAction(
                  child: Text('No'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                CupertinoDialogAction(
                  child: Text('yes'),
                  onPressed: () {
                    sqlHelper()
                        .insertNote(Note(
                            title: titleController.text,
                            content: contentController.text,
                            id: null))
                        .whenComplete(() => setState(() {}));
                    Navigator.pop(context);
                  },
                )
              ],
            ),
          );
        });
  }

  void showInsertTodoDialog(context) {
    showCupertinoDialog(
        context: context,
        builder: (_) {
          return Material(
            color: Colors.blue.withOpacity(0.3),
            child: CupertinoAlertDialog(
              title: Text("Add new Todo"),
              content: Column(
                children: [
                  TextField(
                    controller: titleController,
                  ),
                ],
              ),
              actions: <CupertinoDialogAction>[
                CupertinoDialogAction(
                  child: Text('No'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                CupertinoDialogAction(
                  child: Text('yes'),
                  onPressed: () {
                    sqlHelper()
                        .insertToDo(
                          Todo(
                            title: titleController.text,
                            id: null,
                          ),
                        )
                        .whenComplete(() => setState(() {}));
                    titleController.clear();
                    Navigator.pop(context);
                  },
                )
              ],
            ),
          );
        });
  }

  void showEditNoteDialog(
      context, String titleInit, String contenInit, int id) {
    showCupertinoDialog(
        context: context,
        builder: (_) {
          return Material(
            color: Colors.amber.withOpacity(0.3),
            child: CupertinoAlertDialog(
              title: Text("Edit  Note"),
              content: Column(
                children: [
                  TextFormField(
                    initialValue: titleInit,
                    onChanged: (value) {
                      titleInit = value;
                    },
                  ),
                  TextFormField(
                    initialValue: contentInit,
                    onChanged: (value) {
                      dynamic contentInit = value;
                    },
                  ),
                ],
              ),
              actions: <CupertinoDialogAction>[
                CupertinoDialogAction(
                  child: Text('No'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                CupertinoDialogAction(
                  child: Text('yes'),
                  onPressed: () {
                    sqlHelper()
                        .updateNote(
                            Note(id: id, title: titleInit, content: contenInit))
                        .whenComplete(() => setState(() {}));
                    titleController.clear();
                    contentController.clear();
                    Navigator.pop(context);
                  },
                )
              ],
            ),
          );
        });
  }
}
