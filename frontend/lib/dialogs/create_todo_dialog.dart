import 'package:flutter/material.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/models/todo_model.dart';
import 'package:frontend/services/todo_service.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CreateTodoDialog extends StatefulWidget {
  const CreateTodoDialog({super.key});

  @override
  State<CreateTodoDialog> createState() => _CreateTodoDialogState();
}

class _CreateTodoDialogState extends State<CreateTodoDialog> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Widget _buildTitleField() {
    return TextFormField(
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
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Popis',
      ),
      onSaved: (value) {
        _description = value!.trim();
      },
    );
  }

  Widget _buildDatePickerField() {
    return TextFormField(
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Dátum',
      ),
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          setState(() {
            _selectedDate = pickedDate;
          });
        }
      },
      controller: TextEditingController(
        text: _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : '',
      ),
    );
  }

  Widget _buildTimePickerField() {
    return TextFormField(
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Čas',
      ),
      onTap: () async {
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (pickedTime != null) {
          setState(() {
            _selectedTime = pickedTime;
          });
        }
      },
      controller: TextEditingController(
        text: _selectedTime != null ? _selectedTime!.format(context) : '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Vytvoriť nový Todo'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTitleField(),
            const SizedBox(height: 10),
            _buildDescriptionField(),
            const SizedBox(height: 10),
            _buildDatePickerField(),
            if (_selectedDate != null)
              Column(
                children: [
                  const SizedBox(height: 10),
                  _buildTimePickerField(),
                ],
              )
            else
              const SizedBox.shrink()
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.cancel, color: Colors.red, size: 30),
          onPressed: () {
            context.pop();
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
                date: _selectedDate,
                time: _selectedTime,
              );
              locator<TodoService>().addTodo(newTodo);
              context.pop(newTodo);
            }
          },
        ),
      ],
    );
  }
}
