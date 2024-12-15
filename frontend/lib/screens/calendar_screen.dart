import 'package:flutter/material.dart';
import 'package:frontend/app_router.dart';
import 'package:frontend/app_scaffold.dart';
import 'package:frontend/components/todo_card.dart';
import 'package:frontend/dialogs/create_time_dialog.dart';
import 'package:frontend/models/schedule_model.dart';
import 'package:frontend/models/todo_model.dart';
import 'package:frontend/services/calendar_service.dart';
import 'package:frontend/services/todo_service.dart';
import 'package:frontend/theme/all_themes.dart';
import 'package:frontend/theme/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  Map<String, int> weekDays = {'Po': 1, 'Ut': 2, 'St': 3, 'Št': 4, 'Pi': 5};
  DateTime now = DateTime.now();
  int currentWeekDay = DateTime.now().weekday;
  int selectedWeekDay = DateTime.now().weekday;
  DateTime selectedDate = DateTime.now();
  List<ScheduleModel> schedules = CalendarService.getSchedules();
  List<TodoModel> selectedTodos = [];
  bool _selectionMode = false;

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

  Widget _buildAddScheduleButton() {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => CreateTimeDialog(selectedWeekDay: selectedWeekDay),
        ).then((_) {
          setState(() {});
        });
      },
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

  Widget _buildDayButton(String dayLabel, String dateLabel) {
    return Column(
      children: [
        Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: AppTheme.getThemeFromColors(AllAppColors.lightBlueColorScheme).primaryColor,
            ),
            child: Text(dayLabel, style: const TextStyle(color: Colors.white))),
        const SizedBox(height: 4.0),
        SizedBox(width: 58, child: Center(child: Text(dateLabel))),
      ],
    );
  }

  Widget _buildCurrentDayButton(String dayLabel, String dateLabel) {
    return Container(
      padding: const EdgeInsets.only(top: 6.0, bottom: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: AppTheme.getThemeFromColors(AllAppColors.lightBlueColorScheme).primaryColor.withOpacity(0.2),
      ),
      child: _buildDayButton(dayLabel, dateLabel),
    );
  }

  Widget _buildWeekButtons() {
    DateTime monday = now.subtract(Duration(days: currentWeekDay - 1));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(5, (index) {
        DateTime date = monday.add(Duration(days: index));
        String dayLabel = weekDays.keys.elementAt(index);
        String dateLabel = '${date.day}.${date.month}.';

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedWeekDay = date.weekday;
              selectedDate = DateTime(date.year, date.month, date.day);
            });
          },
          child: selectedWeekDay == date.weekday
              ? _buildCurrentDayButton(dayLabel, dateLabel)
              : _buildDayButton(dayLabel, dateLabel),
        );
      }),
    );
  }

  Widget _buildScheduleTime(ScheduleModel schedule) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.15,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(schedule.startTime.format(context)),
            Text(schedule.endTime.format(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoTitles(List<TodoModel> todos, Color backgroundColor) {
    return Align(
        alignment: Alignment.centerRight,
        child: todos.length <= 2
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: todos
                    .map((todo) => GestureDetector(
                          onTap: () async {
                            final potentiallyDeletedTodo = await router.push('/todo_detail', extra: todo);
                            if (potentiallyDeletedTodo != null && potentiallyDeletedTodo is TodoModel) {
                              setState(() {
                                todos.remove(potentiallyDeletedTodo);
                              });
                            }
                            // todo doesnt update when is selected to or un completed in the calendar_screen
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2.0),
                            decoration: BoxDecoration(
                              color: backgroundColor.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4.0, right: 4.0, top: 2.0, bottom: 2.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_outline_outlined, color: Colors.black),
                                  const SizedBox(width: 2.0),
                                  Text(todo.title),
                                ],
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              )
            : IntrinsicWidth(
                child: GestureDetector(
                  onTap: () {
                    router.push('/todo', extra: todos);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2.0),
                    decoration: BoxDecoration(
                      color: backgroundColor.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4.0, right: 4.0, top: 2.0, bottom: 2.0),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline_outlined, color: Colors.black),
                          const SizedBox(width: 2.0),
                          Text(todos.length.toString()),
                        ],
                      ),
                    ),
                  ),
                ),
              ));
  }

  Widget _buildScheduleCalendar(ScheduleModel schedule, {List<TodoModel>? todos}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(left: 24.0, right: 32.0),
        decoration: BoxDecoration(
          color: schedule.color.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Dismissible(
            key: Key(schedule.id),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              setState(() {
                schedules.remove(schedule);
                CalendarService.deleteSchedule(schedule);
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${schedule.title} bol vymazaný')),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(schedule.title, style: const TextStyle().copyWith(fontWeight: FontWeight.bold)),
                  if (todos != null && todos.isNotEmpty) _buildTodoTitles(todos, schedule.color),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (schedule.description != null)
                        Text(schedule.description!,
                            style: const TextStyle().copyWith(color: Colors.black.withOpacity(0.4))),
                      if (schedule.room != null) Text(schedule.room!),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(bool isLast) {
    if (isLast) {
      return const SizedBox.shrink();
    } else {
      return const Column(
        children: [
          SizedBox(height: 4.0),
          Divider(indent: 8.0, endIndent: 8.0),
          SizedBox(height: 4.0),
        ],
      );
    }
  }

  Widget _buildTodo(List<TodoModel> todosWithoutScheduleCollision, TodoModel todo) {
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
              todosWithoutScheduleCollision.remove(potentiallyDeletedTodo);
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
  }

  Widget _buildTimeTable() {
    List<TodoModel> selectedDayTodosWithTime = TodoService.getTodosForDateWithTime(selectedDate);
    List<TodoModel> todosWithoutScheduleCollision = List.from(selectedDayTodosWithTime);
    List<ScheduleModel> sortedSchedules = schedules.where((schedule) => schedule.weekDay == selectedWeekDay).toList();
    sortedSchedules.sort(
      (a, b) => (a.startTime.hour * 60 + a.startTime.minute).compareTo(b.startTime.hour * 60 + b.startTime.minute),
    );

    // Sort todos without collision by time
    todosWithoutScheduleCollision.sort((a, b) {
      if (a.time == null && b.time == null) return 0;
      if (a.time == null) return 1;
      if (b.time == null) return -1;
      return (a.time!.hour * 60 + a.time!.minute).compareTo(b.time!.hour * 60 + b.time!.minute);
    });

    List<Widget> timetableWidgets = [];

    int scheduleIndex = 0;
    int todoIndex = 0;

    int totalSchedules = sortedSchedules.length;
    int totalTodos = todosWithoutScheduleCollision.length;

    while (scheduleIndex < totalSchedules || todoIndex < totalTodos) {
      ScheduleModel? currentSchedule = scheduleIndex < totalSchedules ? sortedSchedules[scheduleIndex] : null;
      TodoModel? currentTodo = todoIndex < totalTodos ? todosWithoutScheduleCollision[todoIndex] : null;

      // Calculate remaining items
      int remainingSchedules = totalSchedules - scheduleIndex;
      int remainingTodos = totalTodos - todoIndex;

      // Determine if the current item is the last one
      bool isLastItem = (remainingSchedules + remainingTodos) == 1;

      if (currentSchedule != null && currentTodo != null) {
        DateTime scheduleStart = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          currentSchedule.startTime.hour,
          currentSchedule.startTime.minute,
        );

        DateTime todoTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          currentTodo.time!.hour,
          currentTodo.time!.minute,
        );

        if (scheduleStart.isBefore(todoTime)) {
          List<TodoModel> todosForSchedule = selectedDayTodosWithTime.where((todo) {
            int scheduleStartMinutes = currentSchedule.startTime.hour * 60 + currentSchedule.startTime.minute;
            int scheduleEndMinutes = currentSchedule.endTime.hour * 60 + currentSchedule.endTime.minute;
            int todoMinutes = todo.time!.hour * 60 + todo.time!.minute;
            return scheduleStartMinutes <= todoMinutes && scheduleEndMinutes >= todoMinutes;
          }).toList();

          timetableWidgets.add(
            Column(
              children: [
                SizedBox(
                  height: 100,
                  child: Row(
                    children: [
                      _buildScheduleTime(currentSchedule),
                      _buildScheduleCalendar(currentSchedule, todos: todosForSchedule),
                    ],
                  ),
                ),
                _buildDivider(isLastItem),
              ],
            ),
          );

          scheduleIndex++;
          todosWithoutScheduleCollision.removeWhere((todo) => todosForSchedule.contains(todo));
          totalTodos = todosWithoutScheduleCollision.length;
        } else {
          timetableWidgets.add(
            Column(
              children: [
                _buildTodo(todosWithoutScheduleCollision, currentTodo),
                _buildDivider(isLastItem),
              ],
            ),
          );

          todoIndex++;
        }
      } else if (currentSchedule != null) {
        List<TodoModel> todosForSchedule = selectedDayTodosWithTime.where((todo) {
          int scheduleStartMinutes = currentSchedule.startTime.hour * 60 + currentSchedule.startTime.minute;
          int scheduleEndMinutes = currentSchedule.endTime.hour * 60 + currentSchedule.endTime.minute;
          int todoMinutes = todo.time!.hour * 60 + todo.time!.minute;
          return scheduleStartMinutes <= todoMinutes && scheduleEndMinutes >= todoMinutes;
        }).toList();

        timetableWidgets.add(
          Column(
            children: [
              SizedBox(
                height: 100,
                child: Row(
                  children: [
                    _buildScheduleTime(currentSchedule),
                    _buildScheduleCalendar(currentSchedule, todos: todosForSchedule),
                  ],
                ),
              ),
              _buildDivider(isLastItem),
            ],
          ),
        );

        scheduleIndex++;
        todosWithoutScheduleCollision.removeWhere((todo) => todosForSchedule.contains(todo));
        totalTodos = todosWithoutScheduleCollision.length;
      } else if (currentTodo != null) {
        timetableWidgets.add(
          Column(
            children: [
              _buildTodo(todosWithoutScheduleCollision, currentTodo),
              _buildDivider(isLastItem),
            ],
          ),
        );

        todoIndex++;
      }
    }

    return Column(
      children: timetableWidgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      floatingActionButton: _buildAddScheduleButton(),
      actions: [
        if (_selectionMode) _buildActionButtons(),
      ],
      body: Column(
        children: [
          _buildWeekButtons(),
          const SizedBox(height: 16.0),
          Expanded(child: SingleChildScrollView(child: _buildTimeTable())),
        ],
      ),
    );
  }
}
