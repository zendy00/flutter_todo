import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_todo/models/todo.dart';
import 'package:flutter_todo/providers/todo_default.dart';
import 'package:flutter_todo/providers/todo_sqlite.dart';

class ListScreen extends StatefulWidget {
  ListScreen({Key? key}) : super(key: key);

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  late List<Todo> todos;
  bool isLoading = true;
  TodoSqlite todoDefault = TodoSqlite();

  Future initDb() async {
    await todoDefault.initDb().then((value) async {
      todos = await todoDefault.getTodos();
    });
  }

  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: 2), () {
      initDb().then((_) {
        log('initDb complete!');
        setState(() {
          isLoading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('할 일 목록 앱'),
        actions: [
          InkWell(
            onTap: () {},
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
                        await todoDefault.addTodo(
                          Todo(title: title, description: description),
                        );
                        List<Todo> newTodos = await todoDefault.getTodos();

                        setState(() {
                          log("[UI] ADD");
                          todos = newTodos;
                        });
                        Navigator.of(context).pop();
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
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.separated(
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
                                  String description = todos[index].description;

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
                                          );

                                          await todoDefault.updateTodo(newTodo);
                                          List<Todo> newTodos =
                                              await todoDefault.getTodos();

                                          setState(() {
                                            todos = newTodos;
                                          });

                                          Navigator.of(context).pop();
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
                                              .deleteTodo(todos[index].id ?? 0);

                                          List<Todo> newTodos =
                                              await todoDefault.getTodos();

                                          setState(() {
                                            todos = newTodos;
                                          });
                                          Navigator.of(context).pop();
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
}
