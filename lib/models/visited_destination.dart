class VisitedDestination {
  final String note;
  final String location;
  final DateTime tanggal;

  VisitedDestination({
    required this.note,
    required this.location,
    required this.tanggal,
  });

  Map<String, dynamic> toJson() => {
        'note': note,
        'location': location,
        'tanggal': tanggal.toIso8601String().split('T').first,
        'visited_at': tanggal.toIso8601String(),
      };

  factory VisitedDestination.fromJson(Map<String, dynamic> json) {
    return VisitedDestination(
      note: json['note'] ?? '',
      location: json['location'] ?? '',
      tanggal: DateTime.parse(json['visited_at'] ?? json['tanggal']),
    );
  }
}
