import 'package:flutter/material.dart';
import 'package:avis_donation_management/components/avis_theme.dart';

class CollapsibleGroup<T> extends StatefulWidget {
  final String title;
  final List<T> data;
  final Widget Function(T) elementBuilder;
  final bool visible;
  final bool initialExpanded;

  const CollapsibleGroup({
    super.key,
    required this.title,
    required this.data,
    required this.elementBuilder,
    this.visible = true,
    this.initialExpanded = true,
  });

  @override
  State<CollapsibleGroup<T>> createState() => _CollapsibleGroupState<T>();
}

class _CollapsibleGroupState<T> extends State<CollapsibleGroup<T>> {
  bool _expanded = true;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initialExpanded;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          ListTile(
            tileColor: AvisColors.white,
            title: Text(
              widget.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AvisColors.blue,
              ),
            ),
            leading: Icon(
              _expanded ? Icons.expand_less : Icons.expand_more,
              color: AvisColors.blue,
            ),
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          if (_expanded) ...widget.data.map(widget.elementBuilder),
        ],
      ),
    );
  }
}
