import 'package:flutter/material.dart';
import 'package:frontend/app_router.dart';
import 'package:frontend/models/todo_model.dart';

class TodoCard extends StatefulWidget {
  final TodoModel todo;

  const TodoCard({
    super.key,
    required this.todo,
  });

  @override
  State<TodoCard> createState() => _TodoCardState();
}

class _TodoCardState extends State<TodoCard> {
  bool _isChecked = false;

  Widget _buildText() {
    return Text(widget.todo.title, style: Theme.of(context).textTheme.titleMedium);
  }

  Widget _buildTextWithDescription() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.todo.title, style: Theme.of(context).textTheme.titleMedium),
        Text(widget.todo.description!, style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        router.push('/todo_detail', extra: widget.todo);
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, right: 16.0, bottom: 8.0, left: 16.0),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        _isChecked = !_isChecked;
                      });
                    },
                    icon: _isChecked
                        ? const Icon(Icons.check_circle_outline, size: 35)
                        : const Icon(Icons.circle_outlined, size: 35)),
                const SizedBox(width: 8.0),
                Expanded(
                  child: widget.todo.description == null ? _buildText() : _buildTextWithDescription(),
                ),
                const Icon(Icons.arrow_forward)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
