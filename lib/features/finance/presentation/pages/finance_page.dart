import 'package:flutter/material.dart';
import '../../../../shared/widgets/module_page.dart';

class FinancePage extends StatelessWidget { const FinancePage({super.key}); @override Widget build(BuildContext context) => const ModulePage(title: 'Finance', description: 'See income, expenses, profit, and outstanding balances.', icon: Icons.account_balance_wallet_outlined); }
