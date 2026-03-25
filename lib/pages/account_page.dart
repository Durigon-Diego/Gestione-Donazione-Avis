import 'package:avis_donation_management/components/protected_pages.dart';
import 'package:avis_donation_management/components/operator_details_component.dart';

class AccountPage extends ProtectedAvisScaffoldedPage with LoggedCheck {
  AccountPage({
    super.key,
    required super.appInfo,
    required super.connectionStatus,
    required super.operatorSession,
  }) : super(
          title: 'Gestione Account Operatore',
          body: OperatorDetailsComponent(
            operatorSession: operatorSession,
            operatorData: operatorSession.data,
          ),
        );
}
