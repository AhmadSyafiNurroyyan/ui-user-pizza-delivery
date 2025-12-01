class Outlet {
  final String id;
  final String nama;
  final String alamat;
  final double latitude;
  final double longitude;
  final String telepon;
  final String jamOperasional;
  final double jarak; // dalam km, dihitung saat runtime

  Outlet({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.latitude,
    required this.longitude,
    required this.telepon,
    required this.jamOperasional,
    this.jarak = 0,
  });

  Outlet copyWith({double? jarak}) {
    return Outlet(
      id: id,
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
