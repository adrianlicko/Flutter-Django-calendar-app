import 'package:flutter/material.dart';
import 'package:frontend/models/todo_model.dart';
import 'package:frontend/theme/all_themes.dart';
import 'package:frontend/theme/app_theme.dart';

class TodoCard extends StatefulWidget {
  final TodoModel todo;
  final bool selectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onCompletedChanged;

  const TodoCard({
    super.key,
    required this.todo,
    required this.selectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onCompletedChanged,
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

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          if (widget.selectionMode)
            Transform.scale(
              scale: 1.3,
              child: Checkbox(
                fillColor: WidgetStateProperty.all(Colors.white),
                checkColor: Colors.black,
                value: widget.isSelected,
                onChanged: (bool? value) {
                  widget.onTap();
                },
              ),
            ),
          const SizedBox(width: 8.0),
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
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Opacity(
          opacity: widget.todo.isCompleted ? 0.5 : 1.0,
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: AppTheme.getThemeFromColors(AllAppColors.lightBlueColorScheme).primaryColor,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: _buildContent(context),
          ),
        ),
      ),
    );
  }
}
