import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/farmer_page_layout.dart';

class MyBatchesScreen extends StatefulWidget {
  const MyBatchesScreen({super.key});

  @override
  State<MyBatchesScreen> createState() => _MyBatchesScreenState();
}

class _MyBatchesScreenState extends State<MyBatchesScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchController = TextEditingController();

  String _filter = 'All';
  String _sort = 'Newest first';

  static const _filters = ['All', 'Active', 'Needs Review', 'Completed'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _backToDashboard() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      endDrawer: _navigationDrawer(),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/hero_background.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background.withValues(alpha: 0.80),
                    AppColors.background.withValues(alpha: 0.97),
                    AppColors.background,
                  ],
                  stops: const [0, 0.4, 1],
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 600;

                return FarmerPageLayout(
                  header: _header(),
                  child: _panel(
                    padding: EdgeInsets.all(compact ? 18 : 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'My Batches',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Find and review your saved grading results.',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: compact ? 16 : 24),
                        _toolbar(),
                        const SizedBox(height: 12),
                        _filterButtons(),
                        const SizedBox(height: 12),
                        const Text(
                          'Active includes batches that need review.',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: Colors.white12),
                        _emptyState(compact: compact),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return _panel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final expanded =
              constraints.maxWidth >= 1000 &&
              MediaQuery.textScalerOf(context).scale(16) <= 20;
          return Row(
            children: [
              Image.asset(
                'assets/images/app_icon.png',
                width: expanded ? 100 : 72,
                height: 58,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'My Batches',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: expanded ? 21 : 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (expanded)
                ..._navigationItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: TextButton.icon(
                      onPressed: () => _navigate(item.title),
                      icon: Hero(
                        tag: 'farmer-nav-${item.title}',
                        child: Icon(item.icon, size: 20),
                      ),
                      label: Text(item.title),
                      style: TextButton.styleFrom(
                        foregroundColor: item.title == 'My Batches'
                            ? AppColors.background
                            : Colors.white,
                        backgroundColor: item.title == 'My Batches'
                            ? AppColors.mint
                            : Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 18,
                        ),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                )
              else
                IconButton(
                  tooltip: 'Open navigation',
                  onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                  icon: const Icon(Icons.menu_rounded, color: Colors.white),
                ),
            ],
          );
        },
      ),
    );
  }

  static const _navigationItems = [
    (title: 'Dashboard', icon: Icons.dashboard_outlined),
    (title: 'My Batches', icon: Icons.layers_outlined),
    (title: 'History', icon: Icons.history),
    (title: 'Profile', icon: Icons.person_outline),
  ];

  void _navigate(String title) {
    if (title == 'Dashboard') {
      _backToDashboard();
    } else if (title != 'My Batches') {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('$title will be added next.'),
          ),
        );
    }
  }

  Widget _navigationDrawer() {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Image.asset('assets/images/app_icon.png', height: 90),
            const SizedBox(height: 24),
            for (final item in _navigationItems)
              ListTile(
                selected: item.title == 'My Batches',
                selectedTileColor: AppColors.mint.withValues(alpha: 0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                leading: Icon(item.icon, color: AppColors.mint),
                title: Text(
                  item.title,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  _scaffoldKey.currentState?.closeEndDrawer();
                  _navigate(item.title);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _toolbar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 650) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _searchField(),
              const SizedBox(height: 12),
              _sortField(),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: _searchField()),
            const SizedBox(width: 16),
            SizedBox(width: 220, child: _sortField()),
          ],
        );
      },
    );
  }

  Widget _searchField() {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Search batches',
        hintStyle: const TextStyle(color: AppColors.muted),
        prefixIcon: const Icon(Icons.search, color: AppColors.mint),
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.close, color: AppColors.muted),
              ),
        filled: true,
        fillColor: AppColors.card.withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: _inputBorder(Colors.white24),
        focusedBorder: _inputBorder(AppColors.mint),
      ),
    );
  }

  Widget _sortField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _sort,
          isExpanded: true,
          dropdownColor: AppColors.surface,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.mint),
          style: const TextStyle(color: Colors.white, fontSize: 15),
          items: const [
            DropdownMenuItem(
              value: 'Newest first',
              child: Text('Newest first'),
            ),
            DropdownMenuItem(
              value: 'Oldest first',
              child: Text('Oldest first'),
            ),
            DropdownMenuItem(value: 'Name A–Z', child: Text('Name A–Z')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _sort = value);
            }
          },
        ),
      ),
    );
  }

  Widget _filterButtons() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final filter in _filters)
          ChoiceChip(
            label: Text(filter),
            selected: _filter == filter,
            onSelected: (_) {
              setState(() => _filter = filter);
            },
            showCheckmark: false,
            selectedColor: AppColors.mint,
            backgroundColor: Colors.transparent,
            side: BorderSide(
              color: _filter == filter ? AppColors.mint : Colors.white30,
            ),
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            labelStyle: TextStyle(
              color: _filter == filter ? AppColors.background : Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _emptyState({required bool compact}) {
    final hasSearch = _searchController.text.trim().isNotEmpty;
    final filtered = hasSearch || _filter != 'All';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 20 : 40),
      child: Column(
        children: [
          Icon(
            filtered ? Icons.search_off : Icons.layers_outlined,
            size: 58,
            color: AppColors.mint.withValues(alpha: 0.75),
          ),
          const SizedBox(height: 18),
          Text(
            filtered ? 'No matching batches' : 'No batches yet',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            filtered
                ? 'Try another search or clear your filters.'
                : 'Your saved grading batches will appear here.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          if (filtered)
            OutlinedButton.icon(
              onPressed: () {
                _searchController.clear();
                setState(() => _filter = 'All');
              },
              icon: const Icon(Icons.filter_alt_off_outlined),
              label: const Text('Clear filters'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.mint,
                side: const BorderSide(color: AppColors.mint),
                minimumSize: const Size(0, 48),
                shape: const StadiumBorder(),
              ),
            )
          else
            FilledButton.icon(
              onPressed: _backToDashboard,
              icon: const Icon(Icons.dashboard_outlined),
              label: const Text('Go to dashboard'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.mint,
                foregroundColor: AppColors.background,
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(horizontal: 22),
                shape: const StadiumBorder(),
              ),
            ),
        ],
      ),
    );
  }

  OutlineInputBorder _inputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color),
    );
  }

  Widget _panel({required Widget child, required EdgeInsetsGeometry padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
          ),
          child: child,
        ),
      ),
    );
  }
}
