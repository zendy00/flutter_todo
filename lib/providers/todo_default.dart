import 'package:flutter_todo/models/todo.dart';

class TodoDefault {
  List<Todo> dummyTodos = [
    Todo(id: 1, title: '플러터 공부 시작하기', description: '뽕 뽑는 플러터를 읽어봅시다'),
    Todo(id: 2, title: '해진이 공부 시키기', description: '말 잘 안듣는 해진이'),
  ];

  List<Todo> getTodos() {
    return dummyTodos;
  }

  Todo getTodo(int id) {
    return dummyTodos[id];
  }

  Todo addTodo(Todo todo) {
    Todo newTodo = Todo(
      id: dummyTodos.length + 1,
      title: todo.title,
      description: todo.description,
    );
    dummyTodos.add(newTodo);
    return newTodo;
  }

  void deleteTodo(int id) {
    for (int i = 0; i < dummyTodos.length; i++) {
      if (dummyTodos[i].id == id) {
        dummyTodos.removeAt(i);
        return;
      }
    }
  }

  void updateTodo(Todo todo) {
    for (int i = 0; i < dummyTodos.length; i++) {
      if (dummyTodos[i].id == todo.id) {
        dummyTodos[i] = todo;
        return;
      }
    }
  }
}
