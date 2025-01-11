import 'package:flutter/material.dart';
import 'package:frontend/app_scaffold.dart';
import 'package:frontend/components/todo_card.dart';
import 'package:frontend/dialogs/create_time_dialog.dart';
import 'package:frontend/dialogs/create_todo_dialog.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/models/schedule_model.dart';
import 'package:frontend/models/todo_model.dart';
import 'package:frontend/models/user_data_model.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:frontend/screens/loading_screen.dart';
import 'package:frontend/services/schedule_service.dart';
import 'package:frontend/services/todo_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late Map<String, int> weekDays;
  DateTime now = DateTime.now();
  int currentWeekDay = DateTime.now().weekday;
  int selectedWeekDay = DateTime.now().weekday;
  DateTime selectedDate = DateTime.now();
  List<ScheduleModel> schedules = [];
  List<TodoModel> selectedTodos = [];
  bool _selectionMode = false;
  bool _isLoadingData = false;
  List<TodoModel> selectedDayTodosWithoutTime = [];
  List<TodoModel> selectedDayTodosWithTime = [];
  late final UserDataModel _userData;

  @override
  void initState() {
    super.initState();
    _userData = Provider.of<AuthProvider>(context, listen: false).user!;
    _fetchSchedules();
    _fetchTodos(selectedDate);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    weekDays = {
      AppLocalizations.of(context)!.mondayShortcut: 1,
      AppLocalizations.of(context)!.tuesdayShortcut: 2,
      AppLocalizations.of(context)!.wednesdayShortcut: 3,
      AppLocalizations.of(context)!.thursdayShortcut: 4,
      AppLocalizations.of(context)!.fridayShortcut: 5,
    };
  }

  Future<void> _fetchSchedules() async {
    setState(() {
      _isLoadingData = true;
    });
    schedules = await locator<ScheduleService>().getSchedules(context);
    setState(() {
      _isLoadingData = false;
    });
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            setState(() {
              selectedTodos.forEach((todo) async {
                locator<TodoService>().deleteTodo(context, todo.id!);
              });
              selectedDayTodosWithTime.removeWhere((todo) => selectedTodos.contains(todo));
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

  Future<void> _showCreateScheduleDialog() async {
    final newSchedule = await showDialog<ScheduleModel>(
      context: context,
      builder: (context) => CreateTimeDialog(selectedWeekDay: selectedWeekDay),
    );

    if (newSchedule != null) {
      await locator<ScheduleService>().addSchedule(context, newSchedule);
      await _fetchSchedules();
      setState(() {});
    }
  }

  Widget _buildAddScheduleButton() {
    return GestureDetector(
      onTap: _showCreateScheduleDialog,
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
        child: const Icon(Icons.playlist_add, size: 35),
      ),
    );
  }

  Future<void> _showCreateTodoDialog() async {
    final newTodo = await showDialog<TodoModel>(
      context: context,
      builder: (BuildContext context) {
        return CreateTodoDialog(date: selectedDate);
      },
    );

    if (newTodo != null) {
      await locator<TodoService>().addTodo(context, newTodo);
      _fetchTodos(selectedDate);
      setState(() {});
    }
  }

  Widget _buildCreateTodoButton() {
    return GestureDetector(
      onTap: _showCreateTodoDialog,
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(50)),
          boxShadow: const [
            BoxShadow(color: Colors.black, blurRadius: 10, offset: Offset(0, 5)),
          ],
        ),
        child: const Icon(Icons.add_task_outlined, size: 28),
      ),
    );
  }

  Widget _buildDayButton(String dayLabel, String dateLabel, {Color? dateColor}) {
    Color? color = dateColor;
    color ??= Provider.of<ThemeProvider>(context).currentTheme.textColor;

    return Column(
      children: [
        Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: Theme.of(context).primaryColor,
            ),
            child: Text(dayLabel, style: Theme.of(context).textTheme.titleMedium)),
        const SizedBox(height: 4.0),
        SizedBox(
            width: 58,
            child: Center(
                child: Text(dateLabel,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(color: color, fontWeight: FontWeight.normal)))),
      ],
    );
  }

  Widget _buildCurrentDayButton(String dayLabel, String dateLabel) {
    return Container(
      padding: const EdgeInsets.only(top: 6.0, bottom: 4.0, right: 4.0, left: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Theme.of(context).primaryColorLight,
      ),
      child: _buildDayButton(dayLabel, dateLabel, dateColor: Colors.black),
    );
  }

  Widget _buildWeekButtons() {
    DateTime monday = now.subtract(Duration(days: currentWeekDay - 1));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(weekDays.length, (index) {
        DateTime date = monday.add(Duration(days: index));
        String dayLabel = weekDays.keys.elementAt(index);
        String dateLabel = '${date.day}.${date.month}.';

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedWeekDay = date.weekday;
              selectedDate = DateTime(date.year, date.month, date.day);
            });
            _fetchTodos(selectedDate);
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
                            final potentiallyDeletedTodo = await context.push('/todo_detail', extra: todo);
                            if (potentiallyDeletedTodo != null && potentiallyDeletedTodo is TodoModel) {
                              setState(() {
                                selectedDayTodosWithTime.remove(potentiallyDeletedTodo);
                              });
                            }
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
                                  Text(todo.title,
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.black)),
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
                    // todo handle removed or completed todos
                    context.push('/todo', extra: todos);
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
                          Text(todos.length.toString(),
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.black)),
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
            key: Key(schedule.id.toString()),
            direction: DismissDirection.startToEnd,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              setState(() {
                schedules.remove(schedule);
                locator<ScheduleService>().deleteSchedule(context, schedule.id!);
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(schedule.title, style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.black)),
                  if (todos != null && todos.isNotEmpty) _buildTodoTitles(todos, schedule.color),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (schedule.description != null)
                        Text(schedule.description!,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(color: Colors.black.withOpacity(0.7), fontWeight: FontWeight.normal)),
                      if (schedule.room != null)
                        Text(schedule.room!,
                            style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Colors.black)),
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
          Divider(indent: 8.0, endIndent: 8.0),
        ],
      );
    }
  }

  Widget _buildTodo(List<TodoModel> todosWithoutScheduleCollision, TodoModel todo) {
    return TodoCard(
      todo: todo,
      withVerticalPadding: false,
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
              todosWithoutScheduleCollision.remove(potentiallyDeletedTodo);
              selectedDayTodosWithTime.remove(potentiallyDeletedTodo);
            });
          }
        }
      },
      onCompletedChanged: () async {
        setState(() {
          todo.isCompleted = !todo.isCompleted;
        });
        await locator<TodoService>().updateTodo(context, todo);
      },
    );
  }

  Future<void> _fetchTodos(DateTime date) async {
    setState(() {
      _isLoadingData = true;
    });
    if (_userData.preferences.showTodosInCalendar) {
      selectedDayTodosWithTime = await locator<TodoService>()
          .getTodosForDateWithTime(context, date, onlyNotCompleted: _userData.preferences.removeTodoFromCalendarWhenCompleted);
    }
    selectedDayTodosWithoutTime = await locator<TodoService>()
        .getTodosForDateWithoutTime(context, date, onlyNotCompleted: _userData.preferences.removeTodoFromCalendarWhenCompleted);
    setState(() {
      _isLoadingData = false;
    });
  }

  Widget _buildTimeTable() {
    if (_isLoadingData) {
      // will show loading screen instead
      return Container();
    }
    List<TodoModel> todosWithoutScheduleCollision = List.from(selectedDayTodosWithTime);
    List<ScheduleModel> sortedSchedules = schedules.where((schedule) => schedule.weekDay == selectedWeekDay).toList();
    sortedSchedules.sort(
      (a, b) => (a.startTime.hour * 60 + a.startTime.minute).compareTo(b.startTime.hour * 60 + b.startTime.minute),
    );

    // Sort todos without collision by time
    todosWithoutScheduleCollision.sort((a, b) {
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

    // TODO doesnt work
    selectedDayTodosWithoutTime.map((todo) {
      timetableWidgets.add(
        Column(
          children: [
            _buildTodo(todosWithoutScheduleCollision, todo),
            (selectedDayTodosWithoutTime.indexOf(todo) == (selectedDayTodosWithoutTime.length - 1))
                ? _buildDivider(true)
                : _buildDivider(false),
          ],
        ),
      );
      todoIndex++;
    });

    return Column(
      children: timetableWidgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return const LoadingScreen();
    }

    return AppScaffold(
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildCreateTodoButton(),
          const SizedBox(width: 10),
          _buildAddScheduleButton(),
        ],
      ),
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
