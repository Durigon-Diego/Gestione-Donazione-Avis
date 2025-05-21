import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:avis_donation_management/components/avis_theme.dart';
import 'package:avis_donation_management/components/protected_pages.dart';
import 'package:avis_donation_management/components/collapsible_group.dart';
import 'package:avis_donation_management/helpers/logger_helper.dart';

class OperatorsPage extends ProtectedAvisScaffoldedPage
    with LoggedCheck, AdminCheck {
  const OperatorsPage({
    super.key,
    required super.appInfo,
    required super.connectionStatus,
    required super.operatorSession,
  }) : super(
          title: 'Gestione Operatori',
          body: const _OperatorsPageBody(),
        );
}

class _OperatorsPageBody extends StatefulWidget {
  const _OperatorsPageBody();

  @override
  State<_OperatorsPageBody> createState() => _OperatorsPageBodyState();
}

class _OperatorsPageBodyState extends State<_OperatorsPageBody> {
  late RealtimeChannel _channel;
  List<Map<String, dynamic>> _operators = [];

  @override
  void initState() {
    super.initState();
    _loadOperators();
    _subscribeToChanges();
  }

  @override
  void dispose() {
    _channel.unsubscribe();
    super.dispose();
  }

  Future<void> _loadOperators() async {
    final List<Map<String, dynamic>> data = await Supabase.instance.client
        .from('operators')
        .select(
            'id, auth_user_id, is_admin, active, first_name, last_name, nickname');
    setState(() {
      _operators = _sortOperators(data);
    });
  }

  void _subscribeToChanges() {
    _channel = Supabase.instance.client
        .channel('public:operators')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'operators',
          callback: (payload) {
            if (!mounted) return;
            final newOp = payload.newRecord;
            final oldOp = payload.oldRecord;

            setState(() {
              switch (payload.eventType) {
                case PostgresChangeEvent.insert:
                  _operators.add(newOp);
                  break;
                case PostgresChangeEvent.update:
                  final index =
                      _operators.indexWhere((o) => o['id'] == oldOp['id']);
                  if (index != -1) _operators[index] = newOp;
                  break;
                case PostgresChangeEvent.delete:
                  _operators.removeWhere((o) => o['id'] == oldOp['id']);
                  break;
                default:
                  break;
              }
              _operators = _sortOperators(_operators);
            });
          },
        )
        .subscribe();
  }

  List<Map<String, dynamic>> _sortOperators(List<Map<String, dynamic>> ops) {
    int priority(Map<String, dynamic> o) {
      if (o['auth_user_id'] == null) {
        return 3;
      }
      if (o['is_admin'] == true) {
        return 0;
      }
      if (o['active'] == true) {
        return 1;
      }
      return 2;
    }

    ops.sort((a, b) {
      final priorityComparison = priority(a).compareTo(priority(b));
      if (priorityComparison != 0) {
        return priorityComparison;
      }

      final nameA = (a['first_name'] ?? '') as String;
      final nameB = (b['first_name'] ?? '') as String;
      final firstNameComparison = nameA.compareTo(nameB);
      if (firstNameComparison != 0) {
        return firstNameComparison;
      }

      final lastA = (a['last_name'] ?? '') as String;
      final lastB = (b['last_name'] ?? '') as String;
      final lastNameComparison = lastA.compareTo(lastB);
      if (lastNameComparison != 0) {
        return lastNameComparison;
      }

      final nickA = (a['nickname'] ?? '') as String;
      final nickB = (b['nickname'] ?? '') as String;

      return nickA.compareTo(nickB);
    });
    return ops;
  }

  void _openOperator(Map<String, dynamic>? operatorData) {
    logInfo('Open operator: ${operatorData?['id'] ?? 'new'}');
    final args = operatorData != null ? {'operator': operatorData} : null;
    Navigator.of(context).pushNamed('/account', arguments: args);
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> admins = [];
    List<Map<String, dynamic>> active = [];
    List<Map<String, dynamic>> inactive = [];
    List<Map<String, dynamic>> deleted = [];

    for (final op in _operators) {
      if (op['auth_user_id'] == null) {
        deleted.add(op);
      } else if (op['active'] == false) {
        inactive.add(op);
      } else if (op['is_admin'] == false) {
        active.add(op);
      } else {
        admins.add(op);
      }
    }

    return Stack(
      children: [
        ListView(
          children: [
            CollapsibleGroup(
              title: 'Amministratori',
              operators: admins,
              onTap: _openOperator,
              visible: admins.isNotEmpty,
            ),
            CollapsibleGroup(
              title: 'Operatori attivi',
              operators: active,
              onTap: _openOperator,
              visible: active.isNotEmpty,
            ),
            CollapsibleGroup(
              title: 'Operatori disattivati',
              operators: inactive,
              onTap: _openOperator,
              initialExpanded: false,
              visible: inactive.isNotEmpty,
            ),
            CollapsibleGroup(
              title: 'Operatori eliminati',
              operators: deleted,
              onTap: _openOperator,
              initialExpanded: false,
              visible: deleted.isNotEmpty,
            ),
          ],
        ),
        const SizedBox(height: 60),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () => _openOperator(null),
            tooltip: 'Aggiungi operatore',
            backgroundColor: AvisColors.blue,
            foregroundColor: AvisColors.white,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
