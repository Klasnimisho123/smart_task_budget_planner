import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:smart_task_budget_planner/src/models/task.dart';
import 'package:smart_task_budget_planner/src/ui/add_task_dialog.dart';
import 'package:smart_task_budget_planner/src/viewmodels/task_view_model.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _headerController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _progressAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeInOut,
    );
    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  void _runHeaderAnimation() {
    _headerController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<TaskViewModel>();
    final tasks = model.tasks;
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    final percentComplete = tasks.isEmpty ? 0.0 : completedTasks / tasks.length;

    _progressAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeInOut,
    );
    _runHeaderAnimation();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 720;
            return Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tasks Overview',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'The task list loads remote tasks from an API and adds local entries with Provider state management.',
                                  ),
                                ],
                              ),
                            ),
                            if (!isWide)
                              SizedBox(
                                width: 120,
                                height: 120,
                                child: Lottie.network(
                                  'https://assets9.lottiefiles.com/packages/lf20_j1adxtyb.json',
                                  fit: BoxFit.contain,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Completed tasks', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 10),
                              AnimatedBuilder(
                                animation: _progressAnimation,
                                builder: (context, child) {
                                  return LinearProgressIndicator(
                                    value: percentComplete * _progressAnimation.value,
                                    minHeight: 10,
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              Text('$completedTasks of ${tasks.length} tasks done'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (isWide)
                          SizedBox(
                            height: 180,
                            child: Lottie.network(
                              'https://assets9.lottiefiles.com/packages/lf20_j1adxtyb.json',
                              fit: BoxFit.contain,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: model.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : model.error != null
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(model.error!, style: const TextStyle(color: Colors.red)),
                                  const SizedBox(height: 12),
                                  FilledButton.icon(
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Retry'),
                                    onPressed: model.loadRemoteTasks,
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: model.loadRemoteTasks,
                              child: ListView.separated(
                                itemCount: tasks.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final task = tasks[index];
                                  return Dismissible(
                                    key: ValueKey(task.id),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Icon(Icons.delete, color: Colors.white),
                                    ),
                                    onDismissed: (_) => model.deleteTask(task.id),
                                    child: AnimatedOpacity(
                                      duration: const Duration(milliseconds: 300),
                                      opacity: task.isCompleted ? 0.7 : 1.0,
                                      child: Card(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        child: ListTile(
                                          leading: Checkbox(
                                            value: task.isCompleted,
                                            onChanged: (_) => model.toggleCompletion(task.id),
                                          ),
                                          title: Text(
                                            task.title,
                                            style: TextStyle(
                                              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                            ),
                                          ),
                                          subtitle: Text('${task.description}\nDue: ${task.dueDate.toLocal().toString().split(' ')[0]}'),
                                          isThreeLine: true,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final viewModel = context.read<TaskViewModel>();
          final result = await showDialog<Task>(
            context: context,
            builder: (_) => const AddTaskDialog(),
          );
          if (result == null) return;
          viewModel.addTask(result);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }
}
