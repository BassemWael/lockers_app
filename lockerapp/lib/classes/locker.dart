class Locker {
  int? lockerId;
  String? location;
  int? numOfCells;
  int? reservationMode;
  String? id;

  Locker({
    required this.lockerId,
    required this.location,
    required this.numOfCells,
    required this.reservationMode,
    required this.id,
  });

  factory Locker.fromJson(Map<String, dynamic> json) {
    return Locker(
      lockerId: json['locker_id'] ?? 0,
      location: json['location'] ?? 'Unknown',
      numOfCells: json['num_of_cells'] ?? 0,
      reservationMode: json['reservation_mode'] ?? 0,
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locker_id': lockerId,
      'location': location,
      'num_of_cells': numOfCells,
      'reservation_mode': reservationMode,
      'id': id,
    };
  }
}
