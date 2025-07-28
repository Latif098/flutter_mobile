import 'package:tugasakhir_mobile/models/produk_model.dart';

class WishlistModel {
  final int id;
  final String namaProduk;
  final int harga;
  final String? gambarProduk;

  WishlistModel({
    required this.id,
    required this.namaProduk,
    required this.harga,
    this.gambarProduk,
  });

  factory WishlistModel.fromProduk(ProdukModel produk) {
    return WishlistModel(
      id: produk.id,
      namaProduk: produk.namaProduk,
      harga: produk.getHargaAsInt(),
      gambarProduk: produk.gambarProduk,
    );
  }

  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    return WishlistModel(
      id: json['id'],
      namaProduk: json['namaProduk'],
      harga: json['harga'],
      gambarProduk: json['gambarProduk'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'namaProduk': namaProduk,
      'harga': harga,
      'gambarProduk': gambarProduk,
    };
  }

  // Get the full image URL
  String? getImageUrl() {
    if (gambarProduk == null || gambarProduk!.isEmpty) {
      return null;
    }
    return 'http://10.148.46.9:8000/storage/$gambarProduk';
  }
}
