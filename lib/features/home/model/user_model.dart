class UserModel {
  final String userId;
  final String userName;
  final String role;
  final String designation;
  final String mobileNo;
  final String managerName;
  final String hierarchy;
  final String todayOffice;

  UserModel({
    required this.userId,
    required this.userName,
    required this.role,
    required this.designation,
    required this.mobileNo,
    required this.managerName,
    required this.hierarchy,
    required this.todayOffice,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json["userId"] ?? "",
      userName: json["userName"] ?? "",
      role: json["role"] ?? "",
      designation: json["designation"] ?? "",
      mobileNo: json["mobileNo"] ?? "",
      managerName: json["managerName"] ?? "",
      hierarchy: json["hierarchy"] ?? "",
      todayOffice: json["todayOffice"] ?? "",
    );
  }
}