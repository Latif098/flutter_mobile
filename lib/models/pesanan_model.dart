import 'dart:convert';

class PesananModel {
  final int id;
  final int userId;
  final String tanggalPesan;
  final String status;
  final String? createdAt;
  final String? updatedAt;
  final List<PesananDetailModel> detail;

  PesananModel({
    required this.id,
    required this.userId,
    required this.tanggalPesan,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.detail = const [],
  });

  factory PesananModel.fromJson(Map<String, dynamic> json) {
    List<PesananDetailModel> detailList = [];
    if (json['detail'] != null) {
      detailList = List<PesananDetailModel>.from(
        json['detail'].map((detail) => PesananDetailModel.fromJson(detail)),
      );
    }

    return PesananModel(
      id: json['id'],
      userId: json['user_id'],
      tanggalPesan: json['tanggal_pesan'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      detail: detailList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'tanggal_pesan': tanggalPesan,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'detail': detail.map((item) => item.toJson()).toList(),
    };
  }

  int calculateTotal() {
    int total = 0;
    for (var item in detail) {
      total += item.subtotal;
    }
    return total;
  }
}

class PesananDetailModel {
  final int id;
  final int pesananId;
  final int produkId;
  final int jumlah;
  final int subtotal;
  final String? createdAt;
  final String? updatedAt;
  final Map<String, dynamic>? produk;

  PesananDetailModel({
    required this.id,
    required this.pesananId,
    required this.produkId,
    required this.jumlah,
    required this.subtotal,
    this.createdAt,
    this.updatedAt,
    this.produk,
  });

  factory PesananDetailModel.fromJson(Map<String, dynamic> json) {
    return PesananDetailModel(
      id: json['id'],
      pesananId: json['pesanan_id'],
      produkId: json['produk_id'],
      jumlah: json['jumlah'],
      subtotal: json['subtotal'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      produk: json['produk'] != null
          ? Map<String, dynamic>.from(json['produk'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pesanan_id': pesananId,
      'produk_id': produkId,
      'jumlah': jumlah,
      'subtotal': subtotal,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'produk': produk,
    };
  }

  String get namaProduk {
    return produk != null ? produk!['nama_produk'] ?? 'Produk' : 'Produk';
  }

  String? get gambarProduk {
    return produk != null ? produk!['gambar_produk'] : null;
  }

  // Get the full image URL
  String? getImageUrl() {
    if (gambarProduk == null || gambarProduk!.isEmpty) {
      return null;
    }
    return 'http://192.168.96.9:8000/storage/$gambarProduk';
  }
}
