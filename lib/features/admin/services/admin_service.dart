import 'dart:async';

import '../models/admin_activity.dart';
import '../models/admin_overview.dart';
import '../models/admin_role_summary.dart';

class AdminService {
  const AdminService();

  Future<AdminOverview> getOverview() async {
    await Future.delayed(const Duration(milliseconds: 350));
    return AdminOverview.fake();
  }

  Future<List<AdminRoleSummary>> getRoleSummaries() async {
    await Future.delayed(const Duration(milliseconds: 320));
    final roles = ['Admin', 'Seller', 'Delivery', 'Buyer'];
    return roles.map((r) => AdminRoleSummary.fake(r)).toList();
  }

  Future<List<AdminActivity>> getRecentActivities() async {
    await Future.delayed(const Duration(milliseconds: 380));
    return [
      AdminActivity.fakeOrder(),
      AdminActivity.fakeDelivery(),
      AdminActivity.fakeSystem(),
    ];
  }
}
