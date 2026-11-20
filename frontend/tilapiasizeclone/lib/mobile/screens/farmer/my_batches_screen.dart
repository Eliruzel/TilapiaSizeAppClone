import 'package:flutter/material.dart';

import '../../../theme/mobile_colors.dart';

class MobileMyBatchesScreen extends StatefulWidget {
  const MobileMyBatchesScreen({super.key});

  @override
  State<MobileMyBatchesScreen> createState() => _MobileMyBatchesScreenState();
}

class _MobileMyBatchesScreenState extends State<MobileMyBatchesScreen> {
  final _search = TextEditingController();
  String _filter = 'All';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _searchField(),
      const SizedBox(height: 14),
      _filters(),
      const SizedBox(height: 12),
      const Text(
        '0 batches',
        style: TextStyle(color: MobileColors.muted, fontSize: 13),
      ),
      const SizedBox(height: 10),
      Expanded(
        child: ListView(
          key: const PageStorageKey('mobile-batches-scroll'),
          padding: EdgeInsets.zero,
          children: [
            _emptyState(
              _filter == 'All' && _search.text.isEmpty
                  ? 'No batches yet'
                  : 'No matching batches',
              _filter == 'All' && _search.text.isEmpty
                  ? 'Your saved grading batches will appear here.'
                  : 'Try another search or choose a different status filter.',
              _filter == 'All' && _search.text.isEmpty
                  ? Icons.layers_outlined
                  : Icons.search_off_outlined,
            ),
            if (_filter != 'All' || _search.text.isNotEmpty)
              TextButton(
                onPressed: () => setState(() {
                  _filter = 'All';
                  _search.clear();
                }),
                child: const Text('Clear filters'),
              ),
          ],
        ),
      ),
    ],
  );

  Widget _searchField() => TextField(
    controller: _search,
    onChanged: (_) => setState(() {}),
    cursorColor: MobileColors.accent,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      hintText: 'Search batches',
      hintStyle: const TextStyle(color: MobileColors.muted),
      prefixIcon: const Icon(Icons.search, color: MobileColors.muted),
      suffixIcon: _search.text.isEmpty
          ? null
          : IconButton(
              tooltip: 'Clear search',
              onPressed: () => setState(_search.clear),
              icon: const Icon(Icons.close, color: MobileColors.muted),
            ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: .10),
      border: _border(),
      enabledBorder: _border(),
      focusedBorder: _border(color: MobileColors.accent, width: 1.5),
    ),
  );

  OutlineInputBorder _border({Color? color, double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: color ?? Colors.white.withValues(alpha: .16),
          width: width,
        ),
      );

  Widget _filters() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: ['All', 'Active', 'Needs Review', 'Completed'].map((value) {
        final selected = _filter == value;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            selected: selected,
            showCheckmark: false,
            label: Text(value),
            onSelected: (_) => setState(() => _filter = value),
            selectedColor: Colors.white,
            backgroundColor: Colors.white.withValues(alpha: .10),
            side: BorderSide(
              color: Colors.white.withValues(alpha: selected ? .9 : .16),
            ),
            shape: const StadiumBorder(),
            labelStyle: TextStyle(
              color: selected ? MobileColors.background : Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 7),
          ),
        );
      }).toList(),
    ),
  );

  Widget _emptyState(String title, String message, IconData icon) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withValues(alpha: .14)),
    ),
    child: Column(
      children: [
        Icon(icon, color: MobileColors.accent, size: 38),
        const SizedBox(height: 14),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: MobileColors.muted,
            fontSize: 13,
            height: 1.35,
          ),
        ),
      ],
    ),
  );
}
