class Room {
  final int id;
  final String name;
  final int floorId;
  final String floorName;
  final String? buildingName;

  Room({
    required this.id,
    required this.name,
    required this.floorId,
    required this.floorName,
    this.buildingName,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      name: json['name'],
      floorId: json['floorId'],
      floorName: json['floorName'],
      buildingName: json['buildingName'],
    );
  }
}
