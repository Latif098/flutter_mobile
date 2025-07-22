import 'package:tugasakhir_mobile/models/kategori_model.dart';

class ProdukModel {
  final int id;
  final String namaProduk;
  final int harga;
  final int stok;
  final String? gambarProduk;
  final int kategoriProdukId;
  final String? createdAt;
  final String? updatedAt;
  final KategoriModel? kategori;

  ProdukModel({
    required this.id,
    required this.namaProduk,
    required this.harga,
    required this.stok,
    this.gambarProduk,
    required this.kategoriProdukId,
    this.createdAt,
    this.updatedAt,
    this.kategori,
  });

  factory ProdukModel.fromJson(Map<String, dynamic> json) {
    return ProdukModel(
      id: json['id'],
      namaProduk: json['nama_produk'],
      harga: json['harga'],
      stok: json['stok'],
      gambarProduk: json['gambar_produk'],
      kategoriProdukId: json['kategori_produk_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      kategori:
          json['kategori'] != null
              ? KategoriModel.fromJson(json['kategori'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_produk': namaProduk,
      'harga': harga,
      'stok': stok,
      'gambar_produk': gambarProduk,
      'kategori_produk_id': kategoriProdukId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Untuk keperluan edit, convert ke Map tanpa id dan tanpa fields null
  Map<String, dynamic> toJsonForEdit() {
    return {
      'nama_produk': namaProduk,
      'harga': harga,
      'stok': stok,
      'kategori_produk_id': kategoriProdukId,
    };
  }
}
