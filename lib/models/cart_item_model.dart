import 'dart:convert';
import 'package:tugasakhir_mobile/models/produk_model.dart';

class CartItemModel {
  final int id;
  final String namaProduk;
  final int harga;
  final String? gambarProduk;
  final String selectedColor;
  final int quantity;

  CartItemModel({
    required this.id,
    required this.namaProduk,
    required this.harga,
    this.gambarProduk,
    required this.selectedColor,
    this.quantity = 1,
  });

  factory CartItemModel.fromProduk(
    ProdukModel produk, {
    required String selectedColor,
    int quantity = 1,
  }) {
    return CartItemModel(
      id: produk.id,
      namaProduk: produk.namaProduk,
      harga: produk.getHargaAsInt(),
      gambarProduk: produk.gambarProduk,
      selectedColor: selectedColor,
      quantity: quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'namaProduk': namaProduk,
      'harga': harga,
      'gambarProduk': gambarProduk,
      'selectedColor': selectedColor,
      'quantity': quantity,
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'],
      namaProduk: json['namaProduk'],
      harga: json['harga'],
      gambarProduk: json['gambarProduk'],
      selectedColor: json['selectedColor'],
      quantity: json['quantity'] ?? 1,
    );
  }

  String getImageUrl() {
    if (gambarProduk == null || gambarProduk!.isEmpty) {
      return '';
    }
    return 'http://192.168.137.185:8000/storage/$gambarProduk';
  }

  CartItemModel copyWith({
    int? id,
    String? namaProduk,
    int? harga,
    String? gambarProduk,
    String? selectedColor,
    int? quantity,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      namaProduk: namaProduk ?? this.namaProduk,
      harga: harga ?? this.harga,
      gambarProduk: gambarProduk ?? this.gambarProduk,
      selectedColor: selectedColor ?? this.selectedColor,
      quantity: quantity ?? this.quantity,
    );
  }
}
