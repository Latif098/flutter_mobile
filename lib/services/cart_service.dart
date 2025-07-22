import 'dart:convert';
import 'package:tugasakhir_mobile/models/cart_item_model.dart';
import 'package:tugasakhir_mobile/models/produk_model.dart';
import 'package:tugasakhir_mobile/utils/storage_helper.dart';

class CartService {
  static const String _cartKey = 'cart_items';

  // Mendapatkan semua item dalam cart
  Future<List<CartItemModel>> getCartItems() async {
    try {
      final cartJson = await StorageHelper.getValue(_cartKey);
      if (cartJson == null || cartJson.isEmpty) {
        return [];
      }

      final List<dynamic> cartData = jsonDecode(cartJson);
      return cartData.map((item) => CartItemModel.fromJson(item)).toList();
    } catch (e) {
      print('Error getting cart items: $e');
      return [];
    }
  }

  // Menambahkan item ke cart
  Future<bool> addToCart(ProdukModel produk, String selectedColor) async {
    try {
      // Dapatkan cart saat ini
      final currentCart = await getCartItems();

      // Cek apakah produk sudah ada di cart dengan warna yang sama
      final existingItemIndex = currentCart.indexWhere((item) =>
          item.id == produk.id && item.selectedColor == selectedColor);

      if (existingItemIndex >= 0) {
        // Update quantity jika produk sudah ada
        final existingItem = currentCart[existingItemIndex];
        currentCart[existingItemIndex] =
            existingItem.copyWith(quantity: existingItem.quantity + 1);
      } else {
        // Tambahkan produk baru ke cart
        currentCart.add(CartItemModel.fromProduk(
          produk,
          selectedColor: selectedColor,
        ));
      }

      // Simpan cart yang sudah diupdate
      final cartJson =
          jsonEncode(currentCart.map((item) => item.toJson()).toList());
      await StorageHelper.saveValue(_cartKey, cartJson);

      return true;
    } catch (e) {
      print('Error adding to cart: $e');
      return false;
    }
  }

  // Menghapus item dari cart
  Future<bool> removeFromCart(int productId, String selectedColor) async {
    try {
      final currentCart = await getCartItems();

      final updatedCart = currentCart
          .where((item) =>
              !(item.id == productId && item.selectedColor == selectedColor))
          .toList();

      final cartJson =
          jsonEncode(updatedCart.map((item) => item.toJson()).toList());
      await StorageHelper.saveValue(_cartKey, cartJson);

      return true;
    } catch (e) {
      print('Error removing from cart: $e');
      return false;
    }
  }

  // Mengubah quantity item dalam cart
  Future<bool> updateCartItemQuantity(
      int productId, String selectedColor, int quantity) async {
    try {
      if (quantity <= 0) {
        return removeFromCart(productId, selectedColor);
      }

      final currentCart = await getCartItems();

      final itemIndex = currentCart.indexWhere((item) =>
          item.id == productId && item.selectedColor == selectedColor);

      if (itemIndex >= 0) {
        currentCart[itemIndex] =
            currentCart[itemIndex].copyWith(quantity: quantity);

        final cartJson =
            jsonEncode(currentCart.map((item) => item.toJson()).toList());
        await StorageHelper.saveValue(_cartKey, cartJson);

        return true;
      }

      return false;
    } catch (e) {
      print('Error updating cart item quantity: $e');
      return false;
    }
  }

  // Mendapatkan jumlah total item di cart
  Future<int> getCartItemCount() async {
    try {
      final cartItems = await getCartItems();
      int total = 0;
      for (var item in cartItems) {
        total += item.quantity;
      }
      return total;
    } catch (e) {
      print('Error getting cart item count: $e');
      return 0;
    }
  }

  // Mendapatkan total harga di cart
  Future<int> getCartTotal() async {
    try {
      final cartItems = await getCartItems();
      int total = 0;
      for (var item in cartItems) {
        total += item.harga * item.quantity;
      }
      return total;
    } catch (e) {
      print('Error getting cart total: $e');
      return 0;
    }
  }

  // Menghapus semua item dari cart
  Future<bool> clearCart() async {
    try {
      await StorageHelper.saveValue(_cartKey, '[]');
      return true;
    } catch (e) {
      print('Error clearing cart: $e');
      return false;
    }
  }
}
