class Reservation {
  final int id;
  final int? seatNumber;
  final String? roomName;
  final String? buildingName;
  final String? floorName;
  final String? reservationDate;
  final String? startTime;
  final String? endTime;
  final String? status;

  Reservation({
    required this.id,
    this.seatNumber,
    this.roomName,
    this.buildingName,
    this.floorName,
    this.reservationDate,
    this.startTime,
    this.endTime,
    this.status,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      seatNumber: json['seatNumber'],
      roomName: json['roomName'],
      buildingName: json['buildingName'],
      floorName: json['floorName'],
      reservationDate: json['reservationDate'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seatNumber': seatNumber,
      'roomName': roomName,
      'buildingName': buildingName,
      'floorName': floorName,
      'reservationDate': reservationDate,
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
    };
  }
}
