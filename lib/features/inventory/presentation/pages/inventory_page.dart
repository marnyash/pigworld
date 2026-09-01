import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proj/features/inventory/presentation/pages/sections/inventory_overview_section.dart';
import 'package:proj/features/inventory/presentation/pages/sections/search_categories_section.dart';
import 'package:proj/features/inventory/presentation/pages/sections/stock_items_section.dart';
import 'package:proj/features/inventory/presentation/pages/sections/suppliers_section.dart';
import 'package:proj/features/inventory/presentation/pages/sections/stock_movements_section.dart';
import 'package:proj/features/inventory/presentation/pages/sections/alerts_section.dart';

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard_outlined)),
            Tab(text: 'Search', icon: Icon(Icons.search)),
            Tab(text: 'Stock Items', icon: Icon(Icons.inventory_2_outlined)),
            Tab(text: 'Suppliers', icon: Icon(Icons.local_shipping_outlined)),
            Tab(text: 'Movements', icon: Icon(Icons.swap_horiz)),
            Tab(text: 'Alerts', icon: Icon(Icons.notifications_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const InventoryOverviewSection(),
          const SearchCategoriesSection(),
          const StockItemsSection(),
          const SuppliersSection(),
          const StockMovementsSection(),
          const AlertsSection(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Show add inventory item dialog
          _showAddItemDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    // TODO: Implement add inventory item dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Item dialog coming soon')),
    );
  }
}
