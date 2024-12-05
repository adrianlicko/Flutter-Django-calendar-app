import 'package:flutter/material.dart';
import 'package:frontend/app_router.dart';
import 'package:frontend/models/todo_model.dart';
import 'package:frontend/services/todo_service.dart';

class CreateTodoDialog extends StatefulWidget {
  const CreateTodoDialog({super.key});

  @override
  State<CreateTodoDialog> createState() => _CreateTodoDialogState();
}

class _CreateTodoDialogState extends State<CreateTodoDialog> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Vytvoriť nový Todo'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Názov *',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Názov nemôže byť prázdny';
                }
                return null;
              },
              onSaved: (value) {
                _title = value!.trim();
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Popis',
              ),
              onSaved: (value) {
                _description = value!.trim();
              },
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.cancel, color: Colors.red, size: 30),
          onPressed: () {
            router.pop();
          },
        ),
        IconButton(
          icon: const Icon(Icons.check, color: Colors.green, size: 30),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final newTodo = TodoModel(
                id: UniqueKey().toString(),
                title: _title,
                description: _description.isEmpty ? null : _description,
                isCompleted: false,
              );
              TodoService.addTodo(newTodo);
              router.pop(newTodo);
            }
          },
        ),
      ],
    );
  }
}
