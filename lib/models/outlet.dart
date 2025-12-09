class Outlet {
  final int id; // Changed to int to match database BIGINT
  final String? outletCode; // PZ-DNY01, etc.
  final String nama;
  final String alamat;
  final double latitude;
  final double longitude;
  final String telepon;
  final String jamOperasional;
  final double jarak; // dalam km, dihitung saat runtime

  Outlet({
    required this.id,
    this.outletCode,
    required this.nama,
    required this.alamat,
    required this.latitude,
    required this.longitude,
    required this.telepon,
    required this.jamOperasional,
    this.jarak = 0,
  });

  // Factory constructor untuk parsing dari JSON backend
  factory Outlet.fromJson(Map<String, dynamic> json) {
    return Outlet(
      id: json['idOutlet'] ?? json['id'],
      outletCode: json['outletCode'],
      nama: json['nama'] ?? '',
      alamat: json['address'] ?? json['alamat'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      telepon: json['phone'] ?? json['telepon'] ?? '',
      jamOperasional:
          json['operatingHours'] ?? json['jamOperasional'] ?? '10:00 - 22:00',
    );
  }

  Outlet copyWith({double? jarak}) {
    return Outlet(
      id: id,
      outletCode: outletCode,
      nama: nama,
      alamat: alamat,
      latitude: latitude,
      longitude: longitude,
      telepon: telepon,
      jamOperasional: jamOperasional,
      jarak: jarak ?? this.jarak,
    );
  }
}
