import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk/providers/core_providers.dart';
import 'package:solodesk/screens/about_screen.dart';
import 'package:solodesk/screens/clients/client_form_screen.dart';
import 'package:solodesk/screens/clients/clients_screen.dart';
import 'package:solodesk/screens/dashboard_screen.dart';
import 'package:solodesk/screens/demo_screen.dart';
import 'package:solodesk/screens/expenses/expenses_screen.dart';
import 'package:solodesk/screens/invoices/invoice_form_screen.dart';
import 'package:solodesk/screens/invoices/invoices_screen.dart';
import 'package:solodesk/screens/pricing_screen.dart';
import 'package:solodesk/screens/projects/project_form_screen.dart';
import 'package:solodesk/screens/projects/projects_screen.dart';
import 'package:solodesk/screens/reports/reports_screen.dart';
import 'package:solodesk/screens/settings/settings_screen.dart';
import 'package:solodesk/screens/time/time_screen.dart';
import 'package:solodesk/utils/ext.dart';
import 'package:solodesk/utils/nav.dart';

/// Bottom navigation (Dashboard, Clients, Projects, Invoices, More) + FAB.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key, this.onExitDemo});

  /// Non-null only inside the demo.
  final VoidCallback? onExitDemo;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  void _add() {
    final Widget page = switch (_index) {
      1 => const ClientFormScreen(),
      2 => const ProjectFormScreen(),
      _ => const InvoiceFormScreen(),
    };
    pushPage<void>(context, page);
  }

  Widget _more(BuildContext context) {
    final l = context.l10n;
    final demo = ref.watch(isDemoProvider);
    final items = <(IconData, String, Widget)>[
      (Icons.timer_outlined, l.timeTracker, const TimeScreen()),
      (Icons.payments_outlined, l.expenses, const ExpensesScreen()),
      (Icons.bar_chart, l.reports, const ReportsScreen()),
      (Icons.settings_outlined, l.settings, const SettingsScreen()),
      (Icons.workspace_premium_outlined, l.pricing, const PricingScreen()),
      if (!demo) (Icons.play_circle_outline, l.tryDemo, const DemoScreen()),
      (Icons.info_outline, l.about, const AboutScreen()),
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final i in items)
          Card(
            child: ListTile(
              leading: Icon(i.$1),
              title: Text(i.$2),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => pushPage<void>(context, i.$3),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final titles = [l.navDashboard, l.navClients, l.navProjects, l.navInvoices, l.navMore];
    final pages = <Widget>[
      const DashboardScreen(),
      const ClientsScreen(),
      const ProjectsScreen(),
      const InvoicesScreen(),
      _more(context),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        actions: [
          if (widget.onExitDemo != null)
            TextButton(onPressed: widget.onExitDemo, child: Text(l.exitDemo)),
        ],
        bottom: widget.onExitDemo == null
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(28),
                child: Container(
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  child: Text(l.demoBanner,
                      style: TextStyle(color: Theme.of(context).colorScheme.onTertiaryContainer)),
                ),
              ),
      ),
      body: pages[_index],
      floatingActionButton: _index == 4
          ? null
          : FloatingActionButton(
              tooltip: l.add,
              onPressed: _add,
              child: const Icon(Icons.add),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.dashboard_outlined), label: l.navDashboard),
          NavigationDestination(icon: const Icon(Icons.people_outline), label: l.navClients),
          NavigationDestination(icon: const Icon(Icons.folder_open), label: l.navProjects),
          NavigationDestination(icon: const Icon(Icons.receipt_long_outlined), label: l.navInvoices),
          NavigationDestination(icon: const Icon(Icons.more_horiz), label: l.navMore),
        ],
      ),
    );
  }
}
