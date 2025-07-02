import 'package:flutter/material.dart';
import 'models/todo.dart';
import 'services/todo_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Todo> todos = [];
  final TextEditingController controller = TextEditingController();
  bool isLoading = false;

  final List<Tab> myTabs = [
    const Tab(text: 'Pending'),
    const Tab(text: 'Completed'),
    const Tab(text: 'Deleted'),
  ];

  @override
  void initState() {
    super.initState();
    fetchTodos();
  }

  Future<void> fetchTodos() async {
    setState(() => isLoading = true);
    try {
      todos = await TodoService.fetchTodos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading todos: $e')),
      );
    }
    setState(() => isLoading = false);
  }

  Future<void> addTodo() async {
    final title = controller.text.trim();
    if (title.isEmpty) return;
    try {
      final newTodo = await TodoService.addTodo(title);
      setState(() {
        todos.add(newTodo);
        controller.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding todo: $e')),
      );
    }
  }

  Future<void> toggleComplete(Todo todo) async {
    try {
      final updated = await TodoService.toggleComplete(todo.id);
      setState(() {
        final idx = todos.indexWhere((t) => t.id == todo.id);
        if (idx != -1) todos[idx] = updated;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating todo: $e')),
      );
    }
  }

  Future<void> moveToDeleted(Todo todo) async {
    try {
      final updated = await TodoService.moveToDeleted(todo.id);
      setState(() {
        final idx = todos.indexWhere((t) => t.id == todo.id);
        if (idx != -1) todos[idx] = updated;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting todo: $e')),
      );
    }
  }

  Future<void> restoreTask(Todo todo) async {
    try {
      final updated = await TodoService.restoreTask(todo.id);
      setState(() {
        final idx = todos.indexWhere((t) => t.id == todo.id);
        if (idx != -1) todos[idx] = updated;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error restoring todo: $e')),
      );
    }
  }

  Future<void> deleteTodoPermanently(Todo todo) async {
    try {
      await TodoService.deleteTodo(todo.id);
      setState(() {
        todos.removeWhere((t) => t.id == todo.id);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting todo: $e')),
      );
    }
  }

  List<Todo> getTasks({required bool completed, bool deleted = false}) {
    return todos
        .where((task) =>
            task.isCompleted == completed && task.isDeleted == deleted)
        .toList();
  }

  List<Todo> getDeletedTasks() {
    return todos.where((task) => task.isDeleted).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: myTabs.length,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              pinned: true,
              floating: true,
              snap: true,
              expandedHeight: 120,
              backgroundColor: Colors.blueAccent.shade700,
              flexibleSpace: const FlexibleSpaceBar(
                titlePadding: EdgeInsets.only(left: 16, bottom: 50),
                title: Text('📝 My Tasks', style: TextStyle(color: Colors.white)),
              ),
              bottom: TabBar(
                tabs: myTabs,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                indicatorWeight: 3,
              ),
            )
          ],
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        margin: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller,
                                decoration: const InputDecoration(
                                  hintText: 'Enter your task...',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: addTodo,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: const Text("Add", style: TextStyle(color: Colors.white)),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            buildTaskList(getTasks(completed: false), isPending: true),
                            buildTaskList(getTasks(completed: true), isPending: false),
                            buildDeletedTaskList(getDeletedTasks()),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget buildTaskList(List<Todo> tasks, {required bool isPending}) {
    if (tasks.isEmpty) {
      return const Center(
        child: Text(
          "No tasks here 😴 ",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: tasks.length,
      itemBuilder: (context, idx) {
        final task = tasks[idx];
        return Dismissible(
          key: Key(task.id.toString()),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) async {
            return await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.redAccent),
                      const SizedBox(height: 16),
                      const Text(
                        'Delete Task',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Are you sure you want to delete this task?',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.of(context).pop(true),
                            icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                            label: const Text('Delete', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
          onDismissed: (_) => moveToDeleted(task),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: ListTile(
              leading: Checkbox(
                value: task.isCompleted,
                onChanged: (_) => toggleComplete(task),
                activeColor: Colors.green,
              ),
              title: Text(
                task.title,
                style: TextStyle(
                  fontSize: 16,
                  decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                  color: task.isCompleted ? Colors.grey : Colors.black,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildDeletedTaskList(List<Todo> tasks) {
    if (tasks.isEmpty) {
      return const Center(
        child: Text(
          "No deleted tasks 🗑️",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: tasks.length,
      itemBuilder: (context, idx) {
        final task = tasks[idx];
        return ListTile(
          title: Text(
            task.title,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.restore, color: Colors.green),
                onPressed: () => restoreTask(task),
                tooltip: 'Restore',
              ),
              IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                onPressed: () => deleteTodoPermanently(task),
                tooltip: 'Delete Permanently',
              ),
            ],
          ),
        );
      },
    );
  }
}
