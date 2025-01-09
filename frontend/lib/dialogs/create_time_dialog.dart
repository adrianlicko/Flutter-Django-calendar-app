import 'package:flutter/material.dart';
import 'package:frontend/models/schedule_model.dart';
import 'package:go_router/go_router.dart';

class CreateTimeDialog extends StatefulWidget {
  final int selectedWeekDay;

  const CreateTimeDialog({super.key, required this.selectedWeekDay});

  @override
  State<CreateTimeDialog> createState() => _CreateTimeDialogState();
}

class _CreateTimeDialogState extends State<CreateTimeDialog> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String? _description;
  String? _room;
  int? _weekDay;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  Color _selectedColor = Colors.blue;
  late String _selectedWeekDay;

  final Map<String, int> _daysOfWeek = {
    'Pondelok': 1,
    'Utorok': 2,
    'Streda': 3,
    'Štvrtok': 4,
    'Piatok': 5,
  };
  final List<Color> _availableColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];

  final List<TimeOfDay> _timeOptions = List.generate(
    ((20 - 7) * 4) + 1,
    (index) {
      final hour = 7 + (index * 15) ~/ 60;
      final minute = (index * 15) % 60;
      return TimeOfDay(hour: hour, minute: minute);
    },
  );

  @override
  void initState() {
    super.initState();
    _selectedWeekDay = _daysOfWeek.keys
        .firstWhere((key) => _daysOfWeek[key] == widget.selectedWeekDay, orElse: () => _daysOfWeek.entries.first.key);
    _weekDay = widget.selectedWeekDay;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Vytvoriť nový predmet'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Názov predmetu
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Názov predmetu *',
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
              // Popis
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Popis',
                ),
                onSaved: (value) {
                  _description = value?.trim();
                },
              ),
              const SizedBox(height: 10),
              // Miestnosť
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Miestnosť',
                ),
                onSaved: (value) {
                  _room = value?.trim();
                },
              ),
              const SizedBox(height: 10),
              // Deň v týždni
              DropdownButtonFormField<String>(
                value: _selectedWeekDay,
                decoration: const InputDecoration(
                  labelText: 'Deň *',
                ),
                style: const TextStyle(color: Colors.black),
                items: _daysOfWeek.entries.map((entry) {
                  return DropdownMenuItem(value: entry.key, child: Text(entry.key));
                }).toList(),
                validator: (value) => value == null ? 'Vyberte deň' : null,
                onChanged: (value) {
                  setState(() {
                    _weekDay = value != null ? _daysOfWeek[value] : null;
                  });
                },
              ),
              const SizedBox(height: 10),
              // Čas od
              DropdownButtonFormField<TimeOfDay>(
                decoration: const InputDecoration(
                  labelText: 'Čas od *',
                ),
                style: const TextStyle(color: Colors.black),
                items: _timeOptions.map((time) {
                  return DropdownMenuItem(value: time, child: Text(time.format(context)));
                }).toList(),
                validator: (value) => value == null ? 'Vyberte čas' : null,
                onChanged: (value) {
                  setState(() {
                    _startTime = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              // Čas do
              DropdownButtonFormField<TimeOfDay>(
                decoration: const InputDecoration(
                  labelText: 'Čas do *',
                ),
                style: const TextStyle(color: Colors.black),
                items: _timeOptions.map((time) {
                  return DropdownMenuItem(value: time, child: Text(time.format(context)));
                }).toList(),
                validator: (value) {
                  if (value == null) return 'Vyberte čas';
                  if (_startTime != null &&
                      (value.hour * 60 + value.minute) <= (_startTime!.hour * 60 + _startTime!.minute)) {
                    return 'Čas do musí byť po čase od';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _endTime = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              // Farba
              DropdownButtonFormField<Color>(
                decoration: const InputDecoration(
                  labelText: 'Farba',
                ),
                style: const TextStyle(color: Colors.black),
                value: _selectedColor,
                items: _availableColors.map((color) {
                  return DropdownMenuItem(
                    value: color,
                    child: Container(
                      width: 24,
                      height: 24,
                      color: color,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedColor = value!;
                  });
                },
              ),
            ],
          ),
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
              final newSchedule = ScheduleModel(
                title: _title,
                description: _description,
                room: _room,
                weekDay: _weekDay!,
                startTime: _startTime!,
                endTime: _endTime!,
                color: _selectedColor,
              );
              context.pop(newSchedule);
            }
          },
        ),
      ],
    );
  }
}
