import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/todo.dart';

class TodoService {
  static const String baseUrl = 'http://192.168.100.13:3000/todos';

  static Future<List<Todo>> fetchTodos() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Todo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load todos');
    }
  }

  static Future<Todo> addTodo(String title) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'title': title}),
    );
    if (response.statusCode == 201) {
      return Todo.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add todo');
    }
  }

  static Future<Todo> toggleComplete(int id) async {
    final response = await http.patch(Uri.parse('$baseUrl/$id/complete'));
    if (response.statusCode == 200) {
      return Todo.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to toggle complete');
    }
  }

  static Future<Todo> moveToDeleted(int id) async {
    final response = await http.patch(Uri.parse('$baseUrl/$id/delete'));
    if (response.statusCode == 200) {
      return Todo.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to move to deleted');
    }
  }

  static Future<Todo> restoreTask(int id) async {
    final response = await http.patch(Uri.parse('$baseUrl/$id/restore'));
    if (response.statusCode == 200) {
      return Todo.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to restore task');
    }
  }

  static Future<void> deleteTodo(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete todo');
    }
  }
}
