class KategoriModel {
  final int id;
  final String namaKategori;
  final String? createdAt;
  final String? updatedAt;

  KategoriModel({
    required this.id,
    required this.namaKategori,
    this.createdAt,
    this.updatedAt,
  });

  factory KategoriModel.fromJson(Map<String, dynamic> json) {
    return KategoriModel(
      id: json['id'],
      namaKategori: json['nama_kategori'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_kategori': namaKategori,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
