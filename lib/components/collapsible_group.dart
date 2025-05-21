import 'package:flutter/material.dart';
import 'package:avis_donation_management/components/avis_theme.dart';

class CollapsibleGroup extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> operators;
  final void Function(Map<String, dynamic>) onTap;
  final bool visible;
  final bool initialExpanded;

  const CollapsibleGroup({
    super.key,
    required this.title,
    required this.operators,
    required this.onTap,
    this.visible = true,
    this.initialExpanded = true,
  });

  @override
  State<CollapsibleGroup> createState() => _CollapsibleGroupState();
}

class _CollapsibleGroupState extends State<CollapsibleGroup> {
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
          if (_expanded)
            ...widget.operators.map(
              (op) {
                final name = '${op['first_name']} ${op['last_name']}'
                    '${op['nickname']?.toString().isNotEmpty == true ? ' (${op['nickname']})' : ''}';
                final isAdmin = op['is_admin'] == true;
                final isActive = op['active'] == true;
                final isDeleted = op['auth_user_id'] == null;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 6.0),
                  child: ListTile(
                    title: Text(
                      name,
                      style: isDeleted
                          ? const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: AvisColors.darkGrey,
                            )
                          : null,
                    ),
                    leading: Icon(
                      isDeleted
                          ? isAdmin
                              ? Icons.shield_outlined
                              : Icons.person_outlined
                          : isAdmin
                              ? Icons.shield
                              : Icons.person,
                      color: isActive ? AvisColors.blue : AvisColors.red,
                    ),
                    tileColor: AvisColors.lightGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    onTap: () => widget.onTap(op),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
