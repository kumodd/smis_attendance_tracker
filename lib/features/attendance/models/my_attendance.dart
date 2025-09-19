class Attendance {
  final String captureDate;
  final String userId;
  final String officeName;

  Attendance({
    required this.captureDate,
    required this.userId,
    required this.officeName,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      captureDate: json['captureDate'] ?? '',
      userId: json['userId'] ?? '',
      officeName: json['officeName'] ?? '',
    );
  }
}
