import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo/models/todo.dart';
import 'package:flutter_todo/providers/todo_default.dart';
import 'package:flutter_todo/providers/todo_firebase.dart';
import 'package:flutter_todo/providers/todo_sqlite.dart';
import 'package:flutter_todo/screens/news_screen.dart';

class ListScreen extends StatefulWidget {
  ListScreen({Key? key}) : super(key: key);

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<Todo> todos = [];
  TodoFirebase todoDefault = TodoFirebase();

  @override
  void initState() {
    super.initState();

    log('initDb complete!');
    setState(() {
      todoDefault.initDb();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: todoDefault.todoStream,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            todos = todoDefault.getTodos(snapshot);

            return Scaffold(
              appBar: AppBar(
                title: Text('할 일 목록 앱'),
                actions: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => NewsScreen(),
                      ));
                    },
                    child: Container(
                        padding: EdgeInsets.all(5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.book),
                            Text('뉴스'),
                          ],
                        )),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                child: Icon(
                  Icons.add,
                  size: 30,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      String title = '';
                      String description = '';

                      return AlertDialog(
                          title: Text('할 일 추가하기'),
                          content: Container(
                            height: 200,
                            child: Column(
                              children: [
                                TextField(
                                  onChanged: (value) {
                                    title = value;
                                  },
                                  decoration: InputDecoration(labelText: '제목'),
                                ),
                                TextField(
                                  onChanged: (value) {
                                    description = value;
                                  },
                                  decoration: InputDecoration(labelText: '설명'),
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                Todo newTodo = Todo(
                                    title: title, description: description);

                                todoDefault.todoReference
                                    .add(newTodo.toMap())
                                    .then((value) {
                                  Navigator.of(context).pop();
                                });
                              },
                              child: Text('추가'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('취소'),
                            )
                          ]);
                    },
                  );
                },
              ),
              body: ListView.separated(
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(todos[index].title),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return SimpleDialog(
                            title: Text('할 일 보기'),
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                child: Text('제목 : ${todos[index].title}'),
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                child: Text("설명 : ${todos[index].description}"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    trailing: Container(
                      width: 80,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.all(5),
                            child: InkWell(
                              child: Icon(Icons.edit),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    String title = todos[index].title;
                                    String description =
                                        todos[index].description;

                                    return AlertDialog(
                                      title: Text('할 일 수정하기'),
                                      content: Container(
                                        height: 200,
                                        child: Column(
                                          children: [
                                            TextField(
                                              onChanged: (value) {
                                                title = value;
                                              },
                                              decoration: InputDecoration(
                                                hintText: todos[index].title,
                                              ),
                                            ),
                                            TextField(
                                              onChanged: (value) {
                                                description = value;
                                              },
                                              decoration: InputDecoration(
                                                hintText:
                                                    todos[index].description,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          child: Text('수정'),
                                          onPressed: () async {
                                            Todo newTodo = Todo(
                                              id: todos[index].id,
                                              title: title,
                                              description: description,
                                              reference: todos[index].reference,
                                            );

                                            await todoDefault
                                                .updateTodo(newTodo)
                                                .then((_) {
                                              Navigator.of(context).pop();
                                            });
                                          },
                                        ),
                                        TextButton(
                                          child: Text('취소'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        )
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(5),
                            child: InkWell(
                              child: Icon(Icons.delete),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('할 일 삭제하기'),
                                      content: Container(
                                        child: Text('삭제하시겠습니까?'),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () async {
                                            await todoDefault
                                                .deleteTodo(todos[index])
                                                .then((_) {
                                              Navigator.of(context).pop();
                                            });
                                          },
                                          child: Text('삭제'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('취소'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider();
                },
              ),
            );
          }
        });
  }
}
