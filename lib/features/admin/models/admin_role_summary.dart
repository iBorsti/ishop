// AdminRoleSummary model
class AdminRoleSummary {
  final String roleName;
  final int activeUsers;
  final int todayActivity;
  final String status; // ok, warning, critical

  const AdminRoleSummary({
    required this.roleName,
    required this.activeUsers,
    required this.todayActivity,
    required this.status,
  });

  factory AdminRoleSummary.fake(String roleName) => AdminRoleSummary(
    roleName: roleName,
    activeUsers: roleName == 'Admin' ? 5 : (roleName == 'Delivery' ? 120 : 890),
    todayActivity: roleName == 'Admin'
        ? 8
        : (roleName == 'Delivery' ? 48 : 210),
    status: roleName == 'Delivery' ? 'ok' : 'ok',
  );
}
