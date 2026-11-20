import 'package:flutter/material.dart';

import '../../theme/web_colors.dart';

class WebMyBatchesScreen extends StatefulWidget {
  const WebMyBatchesScreen({super.key});

  @override
  State<WebMyBatchesScreen> createState() => _WebMyBatchesScreenState();
}

class _WebMyBatchesScreenState extends State<WebMyBatchesScreen> {
  static const _filters = ['All', 'Active', 'Needs Review', 'Completed'];

  final _query = TextEditingController();
  String _filter = 'All';

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Find and review your saved grading results.',
            style: TextStyle(color: WebColors.muted, fontSize: 13),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _query,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(color: Colors.white),
            cursorColor: WebColors.accent,
            decoration: InputDecoration(
              hintText: 'Search batches',
              prefixIcon: const Icon(Icons.search, color: WebColors.accent),
              suffixIcon: _query.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        setState(_query.clear);
                      },
                      icon: const Icon(Icons.close, color: WebColors.muted),
                    ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: .10),
              border: _border(),
              enabledBorder: _border(),
              focusedBorder: _border(WebColors.accent, 1.5),
            ),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((filter) {
                final selected = _filter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: selected,
                    showCheckmark: false,
                    onSelected: (_) {
                      setState(() => _filter = filter);
                    },
                    selectedColor: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: .10),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: .16),
                    ),
                    shape: const StadiumBorder(),
                    labelStyle: TextStyle(
                      color: selected ? WebColors.background : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            '0 batches',
            style: TextStyle(color: WebColors.muted, fontSize: 13),
          ),
          const SizedBox(height: 10),
          _emptyState(),
        ],
      ),
    );
  }

  OutlineInputBorder _border([Color? color, double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: color ?? Colors.white.withValues(alpha: .16),
          width: width,
        ),
      );

  Widget _emptyState() => Container(
    constraints: const BoxConstraints(minHeight: 220),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withValues(alpha: .14)),
    ),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _filter == 'All' && _query.text.isEmpty
                ? Icons.layers_outlined
                : Icons.search_off,
            color: WebColors.accent,
            size: 36,
          ),
          const SizedBox(height: 12),
          Text(
            _filter == 'All' && _query.text.isEmpty
                ? 'No batches yet'
                : 'No matching batches',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _filter == 'All' && _query.text.isEmpty
                ? 'Your saved grading batches will appear here.'
                : 'Try a different name or clear the filter.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: WebColors.muted, fontSize: 13),
          ),
          if (_filter != 'All' || _query.text.isNotEmpty) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => setState(() {
                _query.clear();
                _filter = 'All';
              }),
              child: const Text('Clear filters'),
            ),
          ],
        ],
      ),
    ),
  );
}
