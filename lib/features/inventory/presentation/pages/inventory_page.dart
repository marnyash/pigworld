import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/components/bottom_navigation.dart';
import '../../../../shared/components/bottom_navigation.dart';
import '../../../../shared/widgets/pig_world_icon.dart';
import 'package:proj/features/inventory/presentation/pages/sections/inventory_overview_section.dart';
import 'package:proj/features/inventory/presentation/pages/sections/search_categories_section.dart';
import 'package:proj/features/inventory/presentation/pages/sections/stock_items_section.dart';
import 'package:proj/features/inventory/presentation/pages/sections/suppliers_section.dart';
import 'package:proj/features/inventory/presentation/pages/sections/stock_movements_section.dart';
import 'package:proj/features/inventory/presentation/pages/sections/alerts_section.dart';
import 'package:proj/features/inventory/presentation/pages/sections/feed_stock_section.dart';
import 'package:proj/features/inventory/presentation/providers/inventory_providers.dart';

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage> {
  _InventorySection? _selectedSection;

  Widget _sectionContent() => switch (_selectedSection!) {
    _InventorySection.overview => const InventoryOverviewSection(),
    _InventorySection.search => const SearchCategoriesSection(),
    _InventorySection.stockItems => const StockItemsSection(),
    _InventorySection.suppliers => const SuppliersSection(),
    _InventorySection.movements => const StockMovementsSection(),
    _InventorySection.alerts => const AlertsSection(),
    _InventorySection.feedStock => const FeedStockSection(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PigWorldIcon('inventory', size: 24),
            SizedBox(width: 8),
            Text('Inventory'),
          ],
        ),
        elevation: 0,
        leading: IconButton(
          tooltip: 'Open menu',
          icon: const PigWorldIcon('inventory', size: 24),
          onPressed: () => navigationScaffoldKey.currentState?.openDrawer(),
        ),
        leading: _selectedSection == null
            ? IconButton(
                tooltip: 'Open menu',
                icon: const Icon(Icons.menu_rounded),
                onPressed: () =>
                    navigationScaffoldKey.currentState?.openDrawer(),
              )
            : IconButton(
                tooltip: 'Inventory sections',
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _selectedSection = null),
              ),
      ),
      body: _selectedSection == null
          ? _InventorySectionCards(
              onSelected: (section) =>
                  setState(() => _selectedSection = section),
            )
          : _sectionContent(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }

  Future<void> _showAddItemDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final skuController = TextEditingController();
    final quantityController = TextEditingController(text: '0');
    final minimumController = TextEditingController(text: '0');
    final costController = TextEditingController(text: '0');
    final supplierController = TextEditingController();
    final locationController = TextEditingController();
    final barcodeController = TextEditingController();
    final notesController = TextEditingController();
    String category = 'Feed';
    String unit = 'kg';
    DateTime? expiryDate;

    try {
      final created = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Add inventory item'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Enter an item name.'
                          : null,
                    ),
                    TextFormField(
                      controller: skuController,
                      decoration: const InputDecoration(labelText: 'SKU'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Enter an SKU.'
                          : null,
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items:
                          const [
                                'Feed',
                                'Medicine',
                                'Vaccines',
                                'Equipment',
                                'Cleaning',
                                'Other',
                              ]
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                      onChanged: (value) =>
                          setState(() => category = value ?? category),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: quantityController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Quantity',
                            ),
                            validator: _validateNumber,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: unit,
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                            ),
                            items:
                                const [
                                      'kg',
                                      'liters',
                                      'bottles',
                                      'pieces',
                                      'bags',
                                    ]
                                    .map(
                                      (value) => DropdownMenuItem(
                                        value: value,
                                        child: Text(value),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) =>
                                setState(() => unit = value ?? unit),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: minimumController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Minimum level',
                            ),
                            validator: _validateNumber,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: costController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Cost price',
                            ),
                            validator: _validateNumber,
                          ),
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: supplierController,
                      decoration: const InputDecoration(
                        labelText: 'Supplier (optional)',
                      ),
                    ),
                    TextFormField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Storage location (optional)',
                      ),
                    ),
                    TextFormField(
                      controller: barcodeController,
                      decoration: const InputDecoration(
                        labelText: 'Barcode (optional)',
                      ),
                    ),
                    TextFormField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                      ),
                      maxLines: 2,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 3650),
                            ),
                            initialDate: expiryDate ?? DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() => expiryDate = picked);
                          }
                        },
                        icon: const Icon(Icons.calendar_today_outlined),
                        label: Text(
                          expiryDate == null
                              ? 'Add expiry date'
                              : 'Expires ${expiryDate!.day}/${expiryDate!.month}/${expiryDate!.year}',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  if (!(formKey.currentState?.validate() ?? false)) return;
                  try {
                    await ref
                        .read(createInventoryItemProvider.notifier)
                        .createItem(
                          name: nameController.text.trim(),
                          category: category,
                          sku: skuController.text.trim(),
                          quantity: double.parse(quantityController.text),
                          unit: unit,
                          minimumLevel: double.parse(minimumController.text),
                          costPrice: double.parse(costController.text),
                          supplier: _optionalValue(supplierController.text),
                          expiryDate: expiryDate,
                          storageLocation: _optionalValue(
                            locationController.text,
                          ),
                          barcode: _optionalValue(barcodeController.text),
                          notes: _optionalValue(notesController.text),
                        );
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext, true);
                    }
                  } catch (error) {
                    if (dialogContext.mounted) {
                      ScaffoldMessenger.of(
                        dialogContext,
                      ).showSnackBar(SnackBar(content: Text('$error')));
                    }
                  }
                },
                child: const Text('Add item'),
              ),
            ],
          ),
        ),
      );
      if (created == true && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Inventory item added')));
      }
    } finally {
      for (final controller in [
        nameController,
        skuController,
        quantityController,
        minimumController,
        costController,
        supplierController,
        locationController,
        barcodeController,
        notesController,
      ]) {
        controller.dispose();
      }
    }
  }

  String? _validateNumber(String? value) {
    final number = double.tryParse(value ?? '');
    return number == null || number < 0 ? 'Enter a valid amount.' : null;
  }

  String? _optionalValue(String value) =>
      value.trim().isEmpty ? null : value.trim();
}

enum _InventorySection {
  overview(
    'Overview',
    'Inventory summary and alerts',
    Icons.dashboard_outlined,
  ),
  search('Search', 'Find items by name, SKU, or barcode', Icons.search),
  stockItems(
    'Stock Items',
    'Manage inventory quantities',
    Icons.inventory_2_outlined,
  ),
  suppliers(
    'Suppliers',
    'Supplier contacts and orders',
    Icons.local_shipping_outlined,
  ),
  movements('Movements', 'Review stock changes', Icons.swap_horiz),
  alerts(
    'Alerts',
    'Review stock and expiry alerts',
    Icons.notifications_outlined,
  ),
  feedStock('Feed Stock', 'Manage feed inventory', Icons.grass_outlined);

  const _InventorySection(this.title, this.description, this.icon);

  final String title;
  final String description;
  final IconData icon;
}

class _InventorySectionCards extends StatelessWidget {
  const _InventorySectionCards({required this.onSelected});

  final ValueChanged<_InventorySection> onSelected;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _InventorySection.values.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: constraints.maxWidth >= 700
            ? 3
            : constraints.maxWidth >= 420
            ? 2
            : 1,
        mainAxisExtent: 116,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final section = _InventorySection.values[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => onSelected(section),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    section.icon,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          section.description,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
