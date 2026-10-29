import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../providers/caregiver_agenda_provider.dart';
import '../../providers/caregiver_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/client_dashboard_provider.dart';
import '../../providers/resource_provider.dart';
import '../../providers/shop_provider.dart';
import '../../providers/visit_provider.dart';
import '../../providers/workshop_provider.dart';

void resetClientProviders(BuildContext context) {
  context.read<CaregiverAgendaProvider>().reset();
  context.read<ChatProvider>().reset();
  context.read<ClientDashboardProvider>().reset();
  context.read<CaregiverProvider>().reset();
  context.read<WorkshopProvider>().reset();
  context.read<ResourceProvider>().reset();
  context.read<ShopProvider>().reset();
  context.read<VisitProvider>().reset();
}
