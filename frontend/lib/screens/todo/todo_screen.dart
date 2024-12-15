import 'package:flutter/material.dart';
import 'package:frontend/app_router.dart';
import 'package:frontend/app_scaffold.dart';
import 'package:frontend/components/todo_card.dart';
import 'package:frontend/dialogs/create_todo_dialog.dart';
import 'package:frontend/models/todo_model.dart';
import 'package:frontend/services/todo_service.dart';
import 'package:frontend/theme/all_themes.dart';
import 'package:frontend/theme/app_theme.dart';

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

  @override
  void initState() {
    super.initState();
    if (widget.todos != null) {
      todos = widget.todos!;
      _showFloatingActionButton = false;
    } else {
      todos = TodoService.getTodos();
    }
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            setState(() {
              TodoService.deleteTodos(selectedTodos);
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
              final potentiallyDeletedTodo = await router.push('/todo_detail', extra: todo);
              if (potentiallyDeletedTodo != null && potentiallyDeletedTodo is TodoModel) {
                setState(() {
                  todos.remove(potentiallyDeletedTodo);
                });
              }
            }
          },
          onCompletedChanged: () {
            setState(() {
              todo.isCompleted = !todo.isCompleted;
            });
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
          color: AppTheme.getThemeFromColors(AllAppColors.lightBlueColorScheme).primaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(50)),
        ),
        child: const Icon(Icons.playlist_add, size: 30),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      floatingActionButton: _showFloatingActionButton ? _buildCreateTodoButton() : null,
      actions: [
        if (_selectionMode) _buildActionButtons(),
      ],
      body: _buildTodoList(),
    );
  }
}
