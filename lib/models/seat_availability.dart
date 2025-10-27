class SeatAvailability {
  final int id;
  final String seatNumber;
  final String roomName;
  final String floorName;
  final String buildingName;
  final bool isAvailable;
  final String? reservedBy;
  final String? reservedTime;

  SeatAvailability({
    required this.id,
    required this.seatNumber,
    required this.roomName,
    required this.floorName,
    required this.buildingName,
    required this.isAvailable,
    this.reservedBy,
    this.reservedTime,
  });

  factory SeatAvailability.fromJson(Map<String, dynamic> json) {
    return SeatAvailability(
      id: json['id'],
      seatNumber: json['seatNumber'],
      roomName: json['roomName'],
      floorName: json['floorName'],
      buildingName: json['buildingName'],
      isAvailable: json['isAvailable'],
      reservedBy: json['reservedBy'],
      reservedTime: json['reservedTime'],
    );
  }
}
