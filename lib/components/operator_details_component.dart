import 'package:flutter/material.dart';
import 'package:avis_donation_management/helpers/operator_session_controller.dart';
import 'package:avis_donation_management/helpers/operator_data.dart';
import 'package:avis_donation_management/components/avis_theme.dart';
import 'package:intl/intl.dart';

class OperatorDetailsComponent extends StatelessWidget {
  final OperatorSessionController operatorSession;
  final OperatorData? operatorData;
  final void Function()? onClose;
  final void Function()? onSave;
  final void Function()? onDelete;
  final void Function()? onResendEmail;
  final bool editable;
  final bool isCreation;

  const OperatorDetailsComponent({
    super.key,
    required this.operatorSession,
    required this.operatorData,
    this.onClose,
    this.onSave,
    this.onDelete,
    this.onResendEmail,
    this.editable = false,
    this.isCreation = false,
  });

  bool get isAdmin => operatorSession.isAdmin;
  bool get isOwnAccount => operatorData?.id == operatorSession.data?.id;

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    if (!isAdmin && !isOwnAccount && !isCreation) {
      return const Center(child: Text('Accesso negato'));
    }

    final nameController =
        TextEditingController(text: operatorData?.firstName ?? '');
    final surnameController =
        TextEditingController(text: operatorData?.lastName ?? '');
    final nicknameController =
        TextEditingController(text: operatorData?.nickname ?? '');
    final emailController = TextEditingController(
        text: operatorData?.authUserId != null
            ? 'email@email.it'
            : ''); // Placeholder

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isCreation
                    ? 'Crea nuovo operatore'
                    : (isOwnAccount
                        ? 'Il mio profilo'
                        : 'Modifica Operatore ${operatorData?.name ?? ''}'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClose ?? () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nome'),
            readOnly: !editable,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: surnameController,
            decoration: const InputDecoration(labelText: 'Cognome'),
            readOnly: !editable,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: nicknameController,
            decoration: const InputDecoration(labelText: 'Nickname'),
            readOnly: !editable,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              suffixIcon: editable && operatorData?.authUserId == null
                  ? IconButton(
                      onPressed: onResendEmail,
                      icon: const Icon(Icons.send),
                      tooltip: 'Invia link di registrazione',
                    )
                  : null,
            ),
            readOnly: !editable,
          ),
          const SizedBox(height: 24),
          if (!isCreation && operatorData != null) ...[
            if (operatorData!.createdByName != null)
              Text(
                'Creato da: ${operatorData!.createdByName!}' +
                    (operatorData!.createdAt != null
                        ? ' il ${_formatDate(operatorData!.createdAt)}'
                        : ''),
              ),
            if (operatorData!.updatedByName != null)
              Text(
                'Ultima modifica: ${operatorData!.updatedByName!}' +
                    (operatorData!.updatedAt != null
                        ? ' il ${_formatDate(operatorData!.updatedAt)}'
                        : ''),
              ),
            if (operatorData!.deletedByName != null)
              Text(
                'Eliminato da: ${operatorData!.deletedByName!}' +
                    (operatorData!.deletedAt != null
                        ? ' il ${_formatDate(operatorData!.deletedAt)}'
                        : ''),
              ),
          ],
          const SizedBox(height: 30),
          if ((isAdmin || isOwnAccount || isCreation) && editable)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Salva'),
                  onPressed: onSave,
                ),
                if (!isOwnAccount && !isCreation && onDelete != null)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Elimina'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AvisColors.red,
                    ),
                    onPressed: onDelete,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
