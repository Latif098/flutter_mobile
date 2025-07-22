import 'dart:convert';
import 'package:tugasakhir_mobile/models/wishlist_model.dart';
import 'package:tugasakhir_mobile/models/produk_model.dart';
import 'package:tugasakhir_mobile/utils/storage_helper.dart';

class WishlistService {
  static const String _wishlistKey = 'wishlist_items';

  // Get all wishlist items
  Future<List<WishlistModel>> getWishlistItems() async {
    try {
      final wishlistJson = await StorageHelper.getValue(_wishlistKey);

      if (wishlistJson == null) {
        return [];
      }

      final List<dynamic> decodedList = jsonDecode(wishlistJson);
      return decodedList.map((item) => WishlistModel.fromJson(item)).toList();
    } catch (e) {
      print('Error getting wishlist items: ${e.toString()}');
      return [];
    }
  }

  // Add item to wishlist
  Future<bool> addToWishlist(ProdukModel produk) async {
    try {
      final wishlistItems = await getWishlistItems();

      // Check if item is already in wishlist
      if (wishlistItems.any((item) => item.id == produk.id)) {
        return false; // Item already exists
      }

      // Create wishlist item from product
      final wishlistItem = WishlistModel.fromProduk(produk);

      // Add item to list
      wishlistItems.add(wishlistItem);

      // Save updated list
      final updatedJson =
          jsonEncode(wishlistItems.map((item) => item.toJson()).toList());
      await StorageHelper.saveValue(_wishlistKey, updatedJson);

      return true;
    } catch (e) {
      print('Error adding to wishlist: ${e.toString()}');
      return false;
    }
  }

  // Remove item from wishlist
  Future<bool> removeFromWishlist(int produkId) async {
    try {
      final wishlistItems = await getWishlistItems();

      // Check if item exists in wishlist
      final newList =
          wishlistItems.where((item) => item.id != produkId).toList();

      if (newList.length == wishlistItems.length) {
        return false; // Item wasn't in wishlist
      }

      // Save updated list
      final updatedJson =
          jsonEncode(newList.map((item) => item.toJson()).toList());
      await StorageHelper.saveValue(_wishlistKey, updatedJson);

      return true;
    } catch (e) {
      print('Error removing from wishlist: ${e.toString()}');
      return false;
    }
  }

  // Check if product is in wishlist
  Future<bool> isInWishlist(int produkId) async {
    try {
      final wishlistItems = await getWishlistItems();
      return wishlistItems.any((item) => item.id == produkId);
    } catch (e) {
      print('Error checking wishlist: ${e.toString()}');
      return false;
    }
  }

  // Get wishlist item count
  Future<int> getWishlistItemCount() async {
    try {
      final wishlistItems = await getWishlistItems();
      return wishlistItems.length;
    } catch (e) {
      print('Error getting wishlist count: ${e.toString()}');
      return 0;
    }
  }

  // Clear wishlist
  Future<bool> clearWishlist() async {
    try {
      await StorageHelper.saveValue(_wishlistKey, jsonEncode([]));
      return true;
    } catch (e) {
      print('Error clearing wishlist: ${e.toString()}');
      return false;
    }
  }
}
