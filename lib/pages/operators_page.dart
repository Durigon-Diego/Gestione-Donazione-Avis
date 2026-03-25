import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:avis_donation_management/helpers/logger_helper.dart';
import 'package:avis_donation_management/helpers/operator_session_controller.dart';
import 'package:avis_donation_management/helpers/operator_data.dart';
import 'package:avis_donation_management/components/avis_theme.dart';
import 'package:avis_donation_management/components/protected_pages.dart';
import 'package:avis_donation_management/components/collapsible_group.dart';
import 'package:avis_donation_management/components/operator_details_component.dart';

class OperatorsPage extends ProtectedAvisScaffoldedPage
    with LoggedCheck, AdminCheck {
  OperatorsPage({
    super.key,
    required super.appInfo,
    required super.connectionStatus,
    required super.operatorSession,
  }) : super(
          title: 'Gestione Operatori',
          body: _OperatorsPageBody(
            operatorSession: operatorSession,
          ),
        );
}

class _OperatorsPageBody extends StatefulWidget {
  final OperatorSessionController operatorSession;
  const _OperatorsPageBody({
    required this.operatorSession,
  });

  @override
  State<_OperatorsPageBody> createState() => _OperatorsPageBodyState();
}

class _OperatorsPageBodyState extends State<_OperatorsPageBody> {
  late RealtimeChannel _channel;
  Map<String, OperatorData> _operatorMap = {};

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
    final List<Map<String, dynamic>> data =
        await Supabase.instance.client.rpc('get_operators_profiles');

    setState(() {
      _operatorMap = {for (var op in data.map(OperatorData.fromMap)) op.id: op};
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
                case PostgresChangeEvent.update:
                  OperatorData op = _createOperatorFromMap(newOp, oldOp);
                  _operatorMap[op.id] = op;
                  break;
                case PostgresChangeEvent.delete:
                  _operatorMap.remove(oldOp['id']);
                  break;
                default:
                  break;
              }
            });
          },
        )
        .subscribe();
  }

  OperatorData _createOperatorFromMap(
    Map<String, dynamic> newOp,
    Map<String, dynamic> oldOp,
  ) {
    _updateReferences('created_by', newOp, oldOp);
    _updateReferences('updated_by', newOp, oldOp);
    _updateReferences('deleted_by', newOp, oldOp);

    return OperatorData.fromMap(newOp);
  }

  void _updateReferences(
    String name,
    Map<String, dynamic> newOp,
    Map<String, dynamic> oldOp,
  ) {
    final String? field = newOp[name];
    if (field != null &&
        field != oldOp[name] &&
        _operatorMap.containsKey(field)) {
      newOp['${name}_first_name'] = _operatorMap[field]!.firstName;
      newOp['${name}_last_name'] = _operatorMap[field]!.lastName;
      newOp['${name}_nickname'] = _operatorMap[field]!.nickname;
    }
  }

  List<OperatorData> _sortOperators(Iterable<OperatorData> ops) {
    List<OperatorData> sorted = ops.toList();
    int priority(OperatorData o) {
      if (o.isDeleted) return 3;
      if (o.isAdmin) return 0;
      if (o.isActive) return 1;
      return 2;
    }

    sorted.sort((a, b) {
      final priorityComparison = priority(a).compareTo(priority(b));
      if (priorityComparison != 0) return priorityComparison;

      final nameA = a.firstName;
      final nameB = b.firstName;
      final firstNameComparison = nameA.compareTo(nameB);
      if (firstNameComparison != 0) return firstNameComparison;

      final lastA = a.lastName;
      final lastB = b.lastName;
      final lastNameComparison = lastA.compareTo(lastB);
      if (lastNameComparison != 0) return lastNameComparison;

      final nickA = a.nickname ?? '';
      final nickB = b.nickname ?? '';
      return nickA.compareTo(nickB);
    });

    return sorted;
  }

  void _showOperatorDetailsOverlay(OperatorData? operatorData) {
    logInfo('Open operator: ${operatorData?.id ?? 'new'}');
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black.withOpacity(0.5),
        child: Column(
          children: [
            AppBar(
              title: Text(operatorData == null
                  ? 'Nuovo Operatore'
                  : 'Modifica Operatore ${operatorData.name}'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => entry.remove(),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: OperatorDetailsComponent(
                  operatorSession: widget.operatorSession,
                  operatorData: operatorData,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    final allOperators = _operatorMap.values;
    final admins =
        _sortOperators(allOperators.where((op) => !op.isDeleted && op.isAdmin));
    final active = _sortOperators(allOperators
        .where((op) => !op.isDeleted && !op.isAdmin && op.isActive));
    final inactive = _sortOperators(allOperators
        .where((op) => !op.isDeleted && !op.isAdmin && !op.isActive));
    final deleted = _sortOperators(allOperators.where((op) => op.isDeleted));

    return Stack(
      children: [
        ListView(
          children: [
            CollapsibleGroup(
              title: 'Amministratori',
              data: admins,
              elementBuilder: _listElement,
              visible: admins.isNotEmpty,
            ),
            CollapsibleGroup(
              title: 'Operatori Attivi',
              data: active,
              elementBuilder: _listElement,
              visible: active.isNotEmpty,
            ),
            CollapsibleGroup(
              title: 'Operatori Disattivati',
              data: inactive,
              elementBuilder: _listElement,
              initialExpanded: false,
              visible: inactive.isNotEmpty,
            ),
            CollapsibleGroup(
              title: 'Operatori Eliminati',
              data: deleted,
              elementBuilder: _listElement,
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
            onPressed: () => _showOperatorDetailsOverlay(null),
            tooltip: 'Aggiungi operatore',
            backgroundColor: AvisColors.blue,
            foregroundColor: AvisColors.white,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _listElement(OperatorData operatorData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: ListTile(
        title: Text(
          operatorData.name,
          style: operatorData.isDeleted
              ? const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: AvisColors.darkGrey,
                )
              : null,
        ),
        leading: Icon(
          operatorData.isDeleted
              ? operatorData.isAdmin
                  ? Icons.shield_outlined
                  : Icons.person_outlined
              : operatorData.isAdmin
                  ? Icons.shield
                  : Icons.person,
          color: operatorData.isActive ? AvisColors.blue : AvisColors.red,
        ),
        tileColor: AvisColors.lightGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        onTap: () => _showOperatorDetailsOverlay(operatorData),
      ),
    );
  }
}
