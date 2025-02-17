import 'package:flutter/material.dart';
import 'package:frontend/models/todo_model.dart';

class TodoCard extends StatefulWidget {
  final TodoModel todo;
  final bool selectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onCompletedChanged;
  final bool withVerticalPadding;

  const TodoCard({
    super.key,
    required this.todo,
    required this.selectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onCompletedChanged,
    this.withVerticalPadding = true,
  });

  @override
  State<TodoCard> createState() => _TodoCardState();
}

class _TodoCardState extends State<TodoCard> {
  double rotationTurns = 0.0;

  void _handleCompletedChanged() {
    setState(() {
      widget.onCompletedChanged();
      rotationTurns += 1.0;
    });
  }

  Widget _buildText(BuildContext context) {
    return Text(widget.todo.title, style: Theme.of(context).textTheme.titleMedium);
  }

  Widget _buildTextWithDescription(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.todo.title, style: Theme.of(context).textTheme.titleMedium),
        Text(widget.todo.description ?? '', style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }

  Widget _buildDateTimeWidget() {
    if (widget.todo.date != null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: IntrinsicHeight(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorLight,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.todo.date!.toIso8601String().substring(0, 10),
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black)),
                  if (widget.todo.time != null)
                    Text(widget.todo.time.toString().substring(10, 15),
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black)),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 16.0, top: 1.0, bottom: 1.0),
      child: Row(
        children: [
          if (widget.selectionMode)
            Row(
              children: [
                Transform.scale(
                  scale: 1.3,
                  child: Checkbox(
                    value: widget.isSelected,
                    onChanged: (bool? value) {
                      widget.onTap();
                    },
                  ),
                ),
                const SizedBox(width: 4.0),
              ],
            ),
          AnimatedRotation(
            turns: rotationTurns,
            duration: const Duration(milliseconds: 250),
            child: IconButton(
              onPressed: _handleCompletedChanged,
              icon: widget.todo.isCompleted
                  ? const Icon(Icons.check_circle_outline_outlined, size: 35)
                  : const Icon(Icons.circle_outlined, size: 35),
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: widget.todo.description == null ? _buildText(context) : _buildTextWithDescription(context),
          ),
          _buildDateTimeWidget(),
          const Icon(Icons.arrow_forward),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: widget.withVerticalPadding ? 8.0 : 0.0, horizontal: 16.0),
        child: Opacity(
          opacity: widget.todo.isCompleted ? 0.5 : 1.0,
          child: IntrinsicHeight(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: _buildContent(context),
            ),
          ),
        ),
      ),
    );
  }
}
