import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/components/bottom_navigation.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../health/presentation/providers/health_providers.dart';
import '../../../reports/presentation/widgets/herd_reports_browser.dart';
import '../../domain/entities/animal.dart';
import '../providers/herd_provider.dart';

class HerdPage extends ConsumerWidget {
  const HerdPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final herd = ref.watch(herdProvider);
    final registeredFarm = ref.watch(authProvider).valueOrNull?.selectedFarm;
    final healthOverview = ref.watch(healthOverviewProvider);
    final registeredHerdCount = registeredFarm?.registeredHerdCount ?? 0;
    final vaccinatedCount = healthOverview.valueOrNull?['vaccinated'] ?? 0;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.herdPageTitle),
        leading: IconButton(
          tooltip: l10n.openMenu,
          icon: const Icon(Icons.menu),
          onPressed: () => navigationScaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            tooltip: l10n.refreshHerd,
            onPressed: () => ref.invalidate(herdProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAnimalDialog(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.addPig),
      ),
      body: herd.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: FilledButton.icon(
            onPressed: () => ref.invalidate(herdProvider),
            icon: const Icon(Icons.refresh),
            label: Text('Could not load herd: $error'),
          ),
        ),
        data: (animals) {
          final pregnantCount = animals
              .where((animal) => animal.isPregnant)
              .length;
          var searchQuery = '';
          var statusFilter = 'all';
          return StatefulBuilder(
            builder: (context, setLocalState) {
              final filteredAnimals = animals.where((animal) {
                final matchesSearch =
                    '${animal.tag} ${animal.type} ${animal.sex} ${animal.notes ?? ''}'
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase());
                return matchesSearch &&
                    (statusFilter == 'all' || animal.status == statusFilter);
              }).toList();
              final displayedHerdCount = animals.length > registeredHerdCount
                  ? animals.length
                  : registeredHerdCount;
              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(herdProvider),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.pagePadding,
                    AppDimensions.pagePadding,
                    AppDimensions.pagePadding,
                    96,
                  ),
                  children: [
                    TextField(
                      onChanged: (value) =>
                          setLocalState(() => searchQuery = value),
                      decoration: InputDecoration(
                        hintText: l10n.searchAnimals,
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingMedium),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['all', 'active', 'sold', 'deceased']
                            .map(
                              (status) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(switch (status) {
                                    'all' => l10n.allPigs,
                                    'active' => l10n.active,
                                    'sold' => l10n.sold,
                                    _ => l10n.deceased,
                                  }),
                                  selected: statusFilter == status,
                                  onSelected: (_) => setLocalState(
                                    () => statusFilter = status,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingMedium),
                    Row(
                      children: [
                        Expanded(
                          child: _HerdSummary(
                            label: l10n.registeredHerd,
                            value: '$displayedHerdCount',
                            icon: Icons.pets_outlined,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacingMedium),
                        Expanded(
                          child: _HerdSummary(
                            label: l10n.active,
                            value:
                                '${animals.where((animal) => animal.status == 'active').length}',
                            icon: Icons.favorite_border,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingMedium),
                    _HerdStatusSummary(
                      pregnant: pregnantCount,
                      vaccinated: vaccinatedCount,
                      active: animals
                          .where((animal) => animal.status == 'active')
                          .length,
                    ),
                    if (registeredHerdCount > 0) ...[
                      const SizedBox(height: AppDimensions.spacingMedium),
                      _RegistrationSummary(
                        motherPigs: registeredFarm?.motherPigCount ?? 0,
                        piglets: registeredFarm?.registeredPigletCount ?? 0,
                        pregnantPigs: registeredFarm?.pregnantPigCount ?? 0,
                      ),
                    ],
                    const SizedBox(height: AppDimensions.spacingLarge),
                    const HerdReportsBrowser(),
                    const SizedBox(height: AppDimensions.spacingLarge),
                    const SizedBox(height: AppDimensions.spacingLarge),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.yourAnimals,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          '${filteredAnimals.length} ${l10n.shown}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingMedium),
                    if (filteredAnimals.isEmpty)
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Icon(
                                Icons.pets_outlined,
                                size: 40,
                                color: AppColors.primaryGreen,
                              ),
                              SizedBox(height: 12),
                              Text(
                                searchQuery.isEmpty
                                    ? l10n.noPigsFound
                                    : l10n.noMatchingPigs,
                              ),
                              SizedBox(height: 4),
                              Text(
                                l10n.adjustSearchOrFilters,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = constraints.maxWidth >= 700
                              ? 3
                              : constraints.maxWidth >= 380
                              ? 2
                              : 1;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredAnimals.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: AppDimensions.spacingMedium,
                                  mainAxisSpacing: AppDimensions.spacingMedium,
                                  childAspectRatio: columns == 1 ? 1.6 : 0.65,
                                ),
                            itemBuilder: (context, index) {
                              final animal = filteredAnimals[index];
                              return _AnimalCard(
                                animal: animal,
                                onEdit: () =>
                                    _showEditAnimalDialog(context, ref, animal),
                                onArchive: () =>
                                    _archiveAnimal(context, ref, animal),
                              );
                            },
                          );
                        },
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showAddAnimalDialog(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _AddAnimalDialog(
        onSave:
            (
              tag,
              type,
              sex,
              birthDate,
              weightKg,
              notes,
              image,
              imageName,
            ) async {
              try {
                await ref
                    .read(herdProvider.notifier)
                    .createAnimal(
                      tag: tag,
                      type: type,
                      sex: sex,
                      birthDate: birthDate,
                      weightKg: weightKg,
                      notes: notes,
                      imageBytes: image,
                      imageName: imageName,
                    );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              } catch (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not add pig: $error')),
                  );
                }
              }
            },
      ),
    );
  }

  Future<void> _archiveAnimal(
    BuildContext context,
    WidgetRef ref,
    Animal animal,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Archive animal?'),
        content: Text(
          'Mark ${animal.tag} as deceased and remove it from active herd tracking?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(herdProvider.notifier).archiveAnimal(animal.id);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not archive animal: $error')),
        );
      }
    }
  }

  Future<void> _showEditAnimalDialog(
    BuildContext context,
    WidgetRef ref,
    Animal animal,
  ) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _EditAnimalPage(animal: animal),
      ),
    );
  }
}

class _EditAnimalPage extends ConsumerStatefulWidget {
  const _EditAnimalPage({required this.animal});

  final Animal animal;

  @override
  ConsumerState<_EditAnimalPage> createState() => _EditAnimalPageState();
}

class _EditAnimalPageState extends ConsumerState<_EditAnimalPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _weightController;
  late final TextEditingController _notesController;
  late String _sex;
  late String _status;
  late bool _isPregnant;
  late DateTime? _birthDate;
  late DateTime? _lastDewormedAt;
  late DateTime? _lastVaccinatedAt;
  Uint8List? _imageBytes;
  String? _imageName;
  bool _saving = false;

  Animal get animal => widget.animal;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: animal.name ?? '');
    _weightController = TextEditingController(
      text: animal.weightKg?.toString() ?? '',
    );
    _notesController = TextEditingController(text: animal.notes ?? '');
    _sex = animal.sex;
    _status = animal.status;
    _isPregnant = animal.isPregnant;
    _birthDate = animal.birthDate;
    _lastDewormedAt = animal.lastDewormedAt;
    _lastVaccinatedAt = animal.lastVaccinatedAt;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 80,
      );
      if (picked == null || !mounted) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        _imageBytes = bytes;
        _imageName = picked.name;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load pig photo: $error')),
        );
      }
    }
  }

  Future<void> _pickDate({
    required DateTime? current,
    required ValueChanged<DateTime?> onSelected,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1990),
      lastDate: now,
      initialDate: current ?? now,
    );
    if (picked != null && mounted) onSelected(picked);
  }

  Future<void> _save() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(herdProvider.notifier)
          .updateAnimal(
            animalId: animal.id,
            name: _nameController.text.trim(),
            sex: _sex,
            status: _status,
            birthDate: _birthDate,
            weightKg: double.tryParse(_weightController.text.trim()),
            isPregnant: _sex == 'female' && _isPregnant,
            lastDewormedAt: _lastDewormedAt,
            lastVaccinatedAt: _lastVaccinatedAt,
            notes: _notesController.text,
            imageBytes: _imageBytes,
            imageName: _imageName,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update ${animal.tag}: $error')),
        );
      }
    }
  }

  String _dateLabel(DateTime? value) {
    if (value == null) return 'Not recorded';
    return '${value.day}/${value.month}/${value.year}';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Edit ${animal.tag}'),
      leading: IconButton(
        tooltip: 'Back',
        onPressed: _saving ? null : () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back),
      ),
    ),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppDimensions.pagePadding),
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 220,
                height: 180,
                child: _imageBytes != null
                    ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                    : animal.imageUrl == null
                    ? const ColoredBox(
                        color: AppColors.pigPink,
                        child: Icon(Icons.pets_outlined, size: 64),
                      )
                    : Image.network(
                        animal.imageUrl!,
                        key: ValueKey(animal.imageUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const ColoredBox(
                          color: AppColors.pigPink,
                          child: Icon(Icons.broken_image_outlined, size: 48),
                        ),
                      ),
              ),
            ),
          ),
          Center(
            child: TextButton.icon(
              onPressed: _saving ? null : _pickImage,
              icon: const Icon(Icons.add_a_photo_outlined),
              label: Text(
                _imageBytes == null ? 'Change photo' : 'Photo selected',
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          InputDecorator(
            decoration: const InputDecoration(labelText: 'App-assigned tag'),
            child: Text(animal.tag),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Pig name (optional)'),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          TextFormField(
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Weight (kg)'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return null;
              final weight = double.tryParse(value.trim());
              if (weight == null || weight <= 0) {
                return 'Enter a weight greater than zero.';
              }
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          DropdownButtonFormField<String>(
            initialValue: _sex,
            decoration: const InputDecoration(labelText: 'Gender'),
            items: const [
              DropdownMenuItem(value: 'female', child: Text('Female')),
              DropdownMenuItem(value: 'male', child: Text('Male')),
              DropdownMenuItem(value: 'unknown', child: Text('Not set')),
            ],
            onChanged: _saving
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() {
                      _sex = value;
                      if (_sex != 'female') _isPregnant = false;
                    });
                  },
          ),
          if (_sex == 'female')
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Pregnant'),
              value: _isPregnant,
              onChanged: _saving
                  ? null
                  : (value) => setState(() => _isPregnant = value),
            ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Age / date of birth'),
            subtitle: Text(_dateLabel(_birthDate)),
            trailing: IconButton(
              tooltip: 'Set birth date',
              onPressed: _saving
                  ? null
                  : () => _pickDate(
                      current: _birthDate,
                      onSelected: (value) => setState(() => _birthDate = value),
                    ),
              icon: const Icon(Icons.calendar_month_outlined),
            ),
          ),
          const Divider(),
          Text('Health status', style: Theme.of(context).textTheme.titleMedium),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Last dewormed'),
            subtitle: Text(_dateLabel(_lastDewormedAt)),
            trailing: IconButton(
              tooltip: 'Set last dewormed date',
              onPressed: _saving
                  ? null
                  : () => _pickDate(
                      current: _lastDewormedAt,
                      onSelected: (value) =>
                          setState(() => _lastDewormedAt = value),
                    ),
              icon: const Icon(Icons.calendar_month_outlined),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Last vaccinated'),
            subtitle: Text(_dateLabel(_lastVaccinatedAt)),
            trailing: IconButton(
              tooltip: 'Set last vaccinated date',
              onPressed: _saving
                  ? null
                  : () => _pickDate(
                      current: _lastVaccinatedAt,
                      onSelected: (value) =>
                          setState(() => _lastVaccinatedAt = value),
                    ),
              icon: const Icon(Icons.calendar_month_outlined),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          DropdownButtonFormField<String>(
            initialValue: _status,
            decoration: const InputDecoration(labelText: 'Animal status'),
            items: const [
              DropdownMenuItem(value: 'active', child: Text('Active')),
              DropdownMenuItem(value: 'sold', child: Text('Sold')),
              DropdownMenuItem(value: 'deceased', child: Text('Deceased')),
            ],
            onChanged: _saving
                ? null
                : (value) {
                    if (value != null) setState(() => _status = value);
                  },
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          TextFormField(
            controller: _notesController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Notes (optional)'),
          ),
        ],
      ),
    ),
    bottomNavigationBar: SafeArea(
      minimum: const EdgeInsets.all(AppDimensions.pagePadding),
      child: FilledButton(
        onPressed: _saving ? null : _save,
        child: _saving
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Save pig details'),
      ),
    ),
  );
}

class _HerdStatusSummary extends StatelessWidget {
  const _HerdStatusSummary({
    required this.pregnant,
    required this.vaccinated,
    required this.active,
  });

  final int pregnant;
  final int vaccinated;
  final int active;

  @override
  Widget build(BuildContext context) {
    final items = [
      _HerdStatusMetric(
        label: AppLocalizations.of(context).pregnant,
        value: '$pregnant',
        color: AppColors.pigPink,
      ),
      _HerdStatusMetric(
        label: AppLocalizations.of(context).vaccinated,
        value: '$vaccinated',
        color: AppColors.info,
      ),
      _HerdStatusMetric(
        label: AppLocalizations.of(context).active,
        value: '$active',
        color: AppColors.success,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).herdStatus,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          Row(
            children: items
                .map(
                  (item) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.label,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.value,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _HerdStatusMetric {
  const _HerdStatusMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;
}

class _RegistrationSummary extends StatelessWidget {
  const _RegistrationSummary({
    required this.motherPigs,
    required this.piglets,
    required this.pregnantPigs,
  });

  final int motherPigs;
  final int piglets;
  final int pregnantPigs;

  @override
  Widget build(BuildContext context) {
    final summary = <String>[
      if (motherPigs > 0) '$motherPigs mothers',
      if (piglets > 0) '$piglets piglets',
      if (pregnantPigs > 0) '$pregnantPigs pregnant',
    ].join(' • ');
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMedium),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryContainer, AppColors.infoContainer],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radius),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primaryGreen,
            child: Icon(Icons.auto_awesome, color: AppColors.inverseText),
          ),
          const SizedBox(width: AppDimensions.spacingMedium),
          Expanded(
            child: Text(
              'Setup saved: $summary',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _HerdSummary extends StatelessWidget {
  const _HerdSummary({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 12),
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    ),
  );
}

class _AddAnimalDialog extends StatefulWidget {
  const _AddAnimalDialog({required this.onSave});

  final Future<void> Function(
    String tag,
    String type,
    String sex,
    DateTime? birthDate,
    double weightKg,
    String notes,
    Uint8List? image,
    String? imageName,
  )
  onSave;

  @override
  State<_AddAnimalDialog> createState() => _AddAnimalDialogState();
}

class _AddAnimalDialogState extends State<_AddAnimalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _tagController = TextEditingController();
  final _notesController = TextEditingController();
  final _weightController = TextEditingController();
  DateTime? _birthDate;
  XFile? _image;
  String _type = 'sow';
  String _sex = 'female';
  bool _saving = false;

  @override
  void dispose() {
    _tagController.dispose();
    _notesController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      await widget.onSave(
        _tagController.text.trim(),
        _type,
        _sex,
        _birthDate,
        double.parse(_weightController.text),
        _notesController.text,
        _image == null ? null : await _image!.readAsBytes(),
        _image?.name,
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not prepare pig details: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Add pig'),
    content: Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _tagController,
              decoration: const InputDecoration(labelText: 'Tag'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter an animal tag.'
                  : null,
            ),
            TextFormField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Weight (kg)'),
              validator: (value) {
                final weight = double.tryParse(value?.trim() ?? '');
                if (weight == null || weight <= 0) {
                  return 'Enter a weight greater than zero.';
                }
                return null;
              },
            ),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: const [
                DropdownMenuItem(value: 'boar', child: Text('Male pig')),
                DropdownMenuItem(value: 'sow', child: Text('Female pig')),
                DropdownMenuItem(value: 'piglet', child: Text('Piglet')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _type = value;
                  _sex = switch (value) {
                    'boar' => 'male',
                    'sow' => 'female',
                    _ => 'unknown',
                  };
                });
              },
            ),
            if (_type == 'piglet')
              DropdownButtonFormField<String>(
                initialValue: _sex,
                decoration: const InputDecoration(labelText: 'Sex'),
                items: const [
                  DropdownMenuItem(value: 'unknown', child: Text('Not set')),
                  DropdownMenuItem(value: 'male', child: Text('Male')),
                  DropdownMenuItem(value: 'female', child: Text('Female')),
                ],
                onChanged: (value) => setState(() => _sex = value ?? _sex),
              ),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _saving ? null : _pickBirthDate,
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(
                  _birthDate == null
                      ? 'Add birth date'
                      : 'Born ${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
                ),
              ),
            ),
            if (_image != null)
              FutureBuilder(
                future: _image!.readAsBytes(),
                builder: (context, snapshot) => snapshot.hasData
                    ? Image.memory(
                        snapshot.data!,
                        height: 120,
                        fit: BoxFit.cover,
                      )
                    : const SizedBox(
                        height: 120,
                        child: Center(child: CircularProgressIndicator()),
                      ),
              ),
            TextButton.icon(
              onPressed: _saving ? null : _pickImage,
              icon: const Icon(Icons.add_a_photo_outlined),
              label: Text(_image == null ? 'Add a photo' : 'Change photo'),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _saving ? null : _save,
        child: _saving
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Add pig'),
      ),
    ],
  );

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1990),
      lastDate: now,
      initialDate: _birthDate ?? now,
    );
    if (picked != null && mounted) setState(() => _birthDate = picked);
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 80,
    );
    if (picked != null && mounted) setState(() => _image = picked);
  }
}

class _AnimalCard extends StatelessWidget {
  const _AnimalCard({
    required this.animal,
    required this.onEdit,
    required this.onArchive,
  });
  final Animal animal;
  final VoidCallback onEdit;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    final active = animal.status == 'active';
    return Card(
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontal = constraints.maxWidth > 280;
          final photo = animal.imageUrl == null
              ? const ColoredBox(
                  color: AppColors.pigPink,
                  child: Center(
                    child: Icon(
                      Icons.pets_outlined,
                      size: 42,
                      color: AppColors.deepGreen,
                    ),
                  ),
                )
              : Image.network(
                  animal.imageUrl!,
                  key: ValueKey(animal.imageUrl),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const ColoredBox(
                    color: AppColors.pigPink,
                    child: Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: AppColors.deepGreen,
                      ),
                    ),
                  ),
                );
          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                animal.name?.isNotEmpty == true ? animal.name! : animal.tag,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              if (animal.name?.isNotEmpty == true)
                Text(animal.tag, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 3),
              Text(
                '${animal.type} · ${animal.sex} · ${_ageLabel(animal.birthDate)}${animal.weightKg == null ? '' : ' · ${animal.weightKg} kg'}',
              ),
              const SizedBox(height: 7),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _DetailChip(label: active ? 'Healthy' : animal.status),
                  const _DetailChip(label: 'RFID not set'),
                  const _DetailChip(label: 'Pen not set'),
                ],
              ),
            ],
          );
          if (horizontal) {
            return Row(
              children: [
                SizedBox(width: 112, height: double.infinity, child: photo),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: details,
                  ),
                ),
                _AnimalActions(onEdit: onEdit, onArchive: onArchive),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: photo),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: details),
                    _AnimalActions(onEdit: onEdit, onArchive: onArchive),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AnimalActions extends StatelessWidget {
  const _AnimalActions({required this.onEdit, required this.onArchive});

  final VoidCallback onEdit;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
    onSelected: (value) {
      if (value == 'edit') onEdit();
      if (value == 'archive') onArchive();
    },
    itemBuilder: (context) => const [
      PopupMenuItem(value: 'edit', child: Text('Edit')),
      PopupMenuItem(value: 'archive', child: Text('Delete / archive')),
    ],
  );
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: AppColors.primaryContainer,
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(label, style: Theme.of(context).textTheme.labelSmall),
  );
}

String _ageLabel(DateTime? birthDate) {
  if (birthDate == null) return 'Age not set';
  final days = DateTime.now().difference(birthDate).inDays;
  return days < 365
      ? '${(days / 30).floor()} mo'
      : '${(days / 365).floor()} yr';
}
