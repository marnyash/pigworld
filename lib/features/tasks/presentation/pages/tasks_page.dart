import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/components/bottom_navigation.dart';

class TaskRecord {
  TaskRecord({
    required this.id,
    required this.title,
    required this.assignee,
    required this.dueDate,
    required this.priority,
    required this.category,
    required this.isDone,
  });

  final String id;
  final String title;
  final String assignee;
  final String dueDate;
  final String priority;
  final String category;
  bool isDone;
}

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final List<TaskRecord> _tasks = [
    TaskRecord(
      id: '1',
      title: 'Check feed stock for the evening batch',
      assignee: 'M. Kibet',
      dueDate: 'Today · 16:00',
      priority: 'High',
      category: 'Feeding',
      isDone: false,
    ),
    TaskRecord(
      id: '2',
      title: 'Vaccination follow-up for nursery pigs',
      assignee: 'J. Achieng',
      dueDate: 'Today · 18:00',
      priority: 'Medium',
      category: 'Health',
      isDone: false,
    ),
    TaskRecord(
      id: '3',
      title: 'Review piglet growth and weight log',
      assignee: 'Farm manager',
      dueDate: 'Tomorrow',
      priority: 'Low',
      category: 'Growth',
      isDone: true,
    ),
  ];

  String _selectedFilter = 'All';

  List<TaskRecord> get _filteredTasks {
    switch (_selectedFilter) {
      case 'Due today':
        return _tasks.where(_isDueToday).toList();
      case 'High priority':
        return _tasks.where((task) => task.priority == 'High').toList();
      case 'Completed':
        return _tasks.where((task) => task.isDone).toList();
      case 'All':
      default:
        return _tasks;
    }
  }

  bool _isDueToday(TaskRecord task) =>
      task.dueDate.startsWith('Today') || task.dueDate.startsWith('Leo');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dueTodayCount = _tasks.where((task) => _isDueToday(task) && !task.isDone).length;
    final highPriorityCount = _tasks.where((task) => task.priority == 'High' && !task.isDone).length;
    final completedCount = _tasks.where((task) => task.isDone).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.farmTasks),
        leading: IconButton(
          tooltip: l10n.openMenu,
          icon: const Icon(Icons.menu),
          onPressed: () => navigationScaffoldKey.currentState?.openDrawer(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateTaskDialog,
        icon: const Icon(Icons.add_task_rounded),
        label: Text(l10n.addTask),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.pagePadding),
        children: [
          _SummaryCard(
            title: l10n.dailyFarmPlan,
            subtitle: l10n.dailyFarmPlanDescription,
            items: [
              _MetricItem(label: l10n.dueToday, value: '$dueTodayCount'),
              _MetricItem(label: l10n.highPriority, value: '$highPriorityCount'),
              _MetricItem(label: l10n.completed, value: '$completedCount'),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Due today', 'High priority', 'Completed']
                  .map(
                    (filter) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(switch (filter) {
                          'All' => l10n.allTasksFilter,
                          'Due today' => l10n.dueToday,
                          'High priority' => l10n.highPriority,
                          _ => l10n.completed,
                        }),
                        selected: _selectedFilter == filter,
                        onSelected: (_) => setState(() => _selectedFilter = filter),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          if (_filteredTasks.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingLarge),
                child: Column(
                  children: [
                    Icon(Icons.task_alt_outlined, size: 42, color: AppColors.primaryGreen),
                    const SizedBox(height: 12),
                    Text(l10n.noTasksInView, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(l10n.createTaskInstruction),
                  ],
                ),
              ),
            )
          else
            ..._filteredTasks.map(
              (task) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.spacingMedium),
                child: _TaskCard(
                  task: task,
                  onToggle: () => setState(() => task.isDone = !task.isDone),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showCreateTaskDialog() async {
    final l10n = AppLocalizations.of(context);
    final titleController = TextEditingController();
    final assigneeController = TextEditingController();
    final dueController = TextEditingController(text: l10n.today);
    String priority = 'Medium';
    String category = 'Feeding';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.addFarmTask),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: l10n.taskTitle),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: assigneeController,
                  decoration: InputDecoration(labelText: l10n.assignedTo),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dueController,
                  decoration: InputDecoration(labelText: l10n.due),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: priority,
                  decoration: InputDecoration(labelText: l10n.priority),
                  items: [
                    DropdownMenuItem(value: 'High', child: Text(l10n.high)),
                    DropdownMenuItem(value: 'Medium', child: Text(l10n.medium)),
                    DropdownMenuItem(value: 'Low', child: Text(l10n.low)),
                  ],
                  onChanged: (value) => setState(() => priority = value ?? priority),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: InputDecoration(labelText: l10n.category),
                  items: [
                    DropdownMenuItem(value: 'Feeding', child: Text(l10n.feeding)),
                    DropdownMenuItem(value: 'Health', child: Text(l10n.health)),
                    DropdownMenuItem(value: 'Growth', child: Text(l10n.growth)),
                    DropdownMenuItem(value: 'Sales', child: Text(l10n.salesCategory)),
                  ],
                  onChanged: (value) => setState(() => category = value ?? category),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(l10n.cancel)),
            FilledButton(
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.taskTitleRequired)),
                  );
                  return;
                }

                setState(() {
                  _tasks.insert(
                    0,
                    TaskRecord(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: title,
                      assignee: assigneeController.text.trim().isEmpty
                          ? l10n.unassigned
                          : assigneeController.text.trim(),
                      dueDate: dueController.text.trim().isEmpty ? 'Today' : dueController.text.trim(),
                      priority: priority,
                      category: category,
                      isDone: false,
                    ),
                  );
                });
                Navigator.of(dialogContext).pop();
              },
              child: Text(l10n.saveTask),
            ),
          ],
        ),
      ),
    );
  }
}


class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.subtitle,
    required this.items,
  });

  final String title;
  final String subtitle;
  final List<_MetricItem> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.deepGreen,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.inverseText),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.inverseMutedText),
            ),
            const SizedBox(height: 16),
            Row(
              children: items
                  .map(
                    (item) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.inverseText.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.value,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.inverseText),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.inverseMutedText),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricItem {
  const _MetricItem({required this.label, required this.value});

  final String label;
  final String value;
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, required this.onToggle});

  final TaskRecord task;
  final VoidCallback onToggle;

  Color _priorityColor() {
    switch (task.priority) {
      case 'High':
        return AppColors.danger;
      case 'Medium':
        return AppColors.warmGold;
      default:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final displayTitle = switch (task.id) {
      '1' => l10n.taskExampleFeedCheck,
      '2' => l10n.taskExampleVaccination,
      '3' => l10n.taskExampleGrowthReview,
      _ => task.title,
    };
    final categoryLabel = switch (task.category) {
      'Feeding' => l10n.feeding,
      'Health' => l10n.health,
      'Growth' => l10n.growth,
      'Sales' => l10n.salesCategory,
      _ => task.category,
    };
    final priorityLabel = switch (task.priority) {
      'High' => l10n.high,
      'Medium' => l10n.medium,
      _ => l10n.low,
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingMedium),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: task.isDone,
              onChanged: (_) => onToggle(),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      decoration: task.isDone ? TextDecoration.lineThrough : null,
                      color: task.isDone ? AppColors.mutedText : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Pill(label: categoryLabel, color: AppColors.primaryContainer),
                      _Pill(label: priorityLabel, color: _priorityColor().withValues(alpha: 0.12)),
                      _Pill(label: _displayDueDate(task.dueDate, l10n), color: AppColors.infoContainer),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${l10n.assignedTo}: ${task.assignee}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _displayDueDate(String dueDate, AppLocalizations l10n) {
  if (dueDate == 'Tomorrow') return l10n.tomorrow;
  if (dueDate.startsWith('Today')) return dueDate.replaceFirst('Today', l10n.today);
  return dueDate;
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}

