import 'package:flutter/material.dart';
import 'package:frontend/app_scaffold.dart';
import 'package:frontend/components/todo_card.dart';
import 'package:frontend/dialogs/create_todo_dialog.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/models/todo_model.dart';
import 'package:frontend/services/todo_service.dart';
import 'package:go_router/go_router.dart';

class TodoScreen extends StatefulWidget {
  final List<TodoModel>? todos;

  const TodoScreen({super.key, this.todos});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  late List<TodoModel> todos;
  List<TodoModel> selectedTodos = [];
  bool _selectionMode = false;
  bool _showFloatingActionButton = true;
  bool _isLoadingData = false;

  @override
  void initState() {
    super.initState();
    if (widget.todos != null) {
      todos = widget.todos!;
      _showFloatingActionButton = false;
    } else {
      _fetchData();
    }
  }

  void _fetchData() async {
    setState(() {
      _isLoadingData = true;
    });
    todos = await locator<TodoService>().getTodos();
    setState(() {
      _isLoadingData = false;
    });
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () async {
            await locator<TodoService>().deleteTodos(selectedTodos.map((todo) => todo.id!).toList());
            todos.removeWhere((todo) => selectedTodos.contains(todo));
            setState(() {
              selectedTodos.clear();
              _selectionMode = false;
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              selectedTodos.clear();
              _selectionMode = false;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTodoList() {
    return ListView(
      children: todos.map((todo) {
        return TodoCard(
          todo: todo,
          selectionMode: _selectionMode,
          isSelected: selectedTodos.contains(todo),
          onLongPress: () {
            setState(() {
              _selectionMode = true;
              selectedTodos.add(todo);
            });
          },
          onTap: () async {
            if (_selectionMode) {
              setState(() {
                if (selectedTodos.contains(todo)) {
                  selectedTodos.remove(todo);
                  if (selectedTodos.isEmpty) {
                    _selectionMode = false;
                  }
                } else {
                  selectedTodos.add(todo);
                }
              });
            } else {
              final potentiallyDeletedTodo = await context.push('/todo_detail', extra: todo);
              if (potentiallyDeletedTodo != null && potentiallyDeletedTodo is TodoModel) {
                setState(() {
                  todos.remove(potentiallyDeletedTodo);
                });
              }
            }
          },
          onCompletedChanged: () async {
            setState(() {
              todo.isCompleted = !todo.isCompleted;
            });
            try {
              await locator<TodoService>().updateTodo(todo);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to update todo: $e')),
              );
            }
          },
        );
      }).toList(),
    );
  }

  Future<void> _showCreateTodoDialog() async {
    final newTodo = await showDialog<TodoModel>(
      context: context,
      builder: (BuildContext context) {
        return const CreateTodoDialog();
      },
    );

    if (newTodo != null) {
      await locator<TodoService>().addTodo(newTodo);
      setState(() {});
    }
  }

  Widget _buildCreateTodoButton() {
    return GestureDetector(
      onTap: _showCreateTodoDialog,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(50)),
          boxShadow: const [
            BoxShadow(color: Colors.black, blurRadius: 10, offset: Offset(0, 5)),
          ],
        ),
        child: const Icon(Icons.add_task_outlined, size: 35),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return const Center(
        // todo replace with loading screen
        child: CircularProgressIndicator(),
      );
    }

    return AppScaffold(
      floatingActionButton: _showFloatingActionButton ? _buildCreateTodoButton() : null,
      actions: [
        if (_selectionMode) _buildActionButtons(),
      ],
      body: _buildTodoList(),
    );
  }
}
