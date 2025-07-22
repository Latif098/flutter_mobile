import 'dart:convert';
import 'dart:math';
import 'package:tugasakhir_mobile/models/address_model.dart';
import 'package:tugasakhir_mobile/utils/storage_helper.dart';

class AddressService {
  static const String _addressKey = 'saved_addresses';

  // Mendapatkan semua alamat tersimpan
  Future<List<AddressModel>> getSavedAddresses() async {
    try {
      final addressesJson = await StorageHelper.getValue(_addressKey);
      if (addressesJson == null || addressesJson.isEmpty) {
        // Buat data dummy jika belum ada alamat tersimpan
        return _createDummyAddresses();
      }

      final List<dynamic> addressesData = jsonDecode(addressesJson);
      return addressesData.map((item) => AddressModel.fromJson(item)).toList();
    } catch (e) {
      print('Error getting saved addresses: $e');
      return _createDummyAddresses();
    }
  }

  // Menyimpan alamat baru
  Future<bool> saveAddress(AddressModel address) async {
    try {
      final addresses = await getSavedAddresses();

      // Cek apakah ini adalah alamat default baru
      if (address.isDefault) {
        // Reset default status untuk alamat lainnya
        for (int i = 0; i < addresses.length; i++) {
          if (addresses[i].isDefault) {
            addresses[i] = addresses[i].copyWith(isDefault: false);
          }
        }
      }

      // Cek apakah ini update atau alamat baru
      final existingIndex = addresses.indexWhere((a) => a.id == address.id);
      if (existingIndex >= 0) {
        addresses[existingIndex] = address;
      } else {
        addresses.add(address);
      }

      final addressesJson =
          jsonEncode(addresses.map((a) => a.toJson()).toList());
      await StorageHelper.saveValue(_addressKey, addressesJson);

      return true;
    } catch (e) {
      print('Error saving address: $e');
      return false;
    }
  }

  // Menghapus alamat
  Future<bool> deleteAddress(String addressId) async {
    try {
      final addresses = await getSavedAddresses();

      final updatedAddresses =
          addresses.where((a) => a.id != addressId).toList();

      // Jika alamat yang dihapus adalah default, set alamat pertama sebagai default
      if (addresses.any((a) => a.id == addressId && a.isDefault) &&
          updatedAddresses.isNotEmpty) {
        updatedAddresses[0] = updatedAddresses[0].copyWith(isDefault: true);
      }

      final addressesJson =
          jsonEncode(updatedAddresses.map((a) => a.toJson()).toList());
      await StorageHelper.saveValue(_addressKey, addressesJson);

      return true;
    } catch (e) {
      print('Error deleting address: $e');
      return false;
    }
  }

  // Mendapatkan alamat default
  Future<AddressModel?> getDefaultAddress() async {
    try {
      final addresses = await getSavedAddresses();

      return addresses.firstWhere((a) => a.isDefault,
          orElse: () => addresses.isNotEmpty
              ? addresses.first
              : createNewAddress(isDefault: true));
    } catch (e) {
      print('Error getting default address: $e');
      return null;
    }
  }

  // Set alamat sebagai default
  Future<bool> setDefaultAddress(String addressId) async {
    try {
      final addresses = await getSavedAddresses();

      for (int i = 0; i < addresses.length; i++) {
        addresses[i] =
            addresses[i].copyWith(isDefault: addresses[i].id == addressId);
      }

      final addressesJson =
          jsonEncode(addresses.map((a) => a.toJson()).toList());
      await StorageHelper.saveValue(_addressKey, addressesJson);

      return true;
    } catch (e) {
      print('Error setting default address: $e');
      return false;
    }
  }

  // Membuat dummy address untuk contoh
  List<AddressModel> _createDummyAddresses() {
    return [
      AddressModel(
        id: 'addr1',
        name: 'Home',
        address: 'Dr Hamka No 363 Padang',
        isDefault: true,
      ),
      AddressModel(
        id: 'addr2',
        name: 'Office',
        address: 'Jl Air Tawar Barat UNP Padang',
        isDefault: false,
      ),
      AddressModel(
        id: 'addr3',
        name: 'Apartment',
        address: 'Jl Thamrin Jakarta Selatan',
        isDefault: false,
      ),
      AddressModel(
        id: 'addr4',
        name: 'Parent\'s House',
        address: 'Salingka Bungo Permai 2',
        isDefault: false,
      ),
    ];
  }

  // Membuat alamat baru
  AddressModel createNewAddress({bool isDefault = false}) {
    final random = Random();
    final id =
        'addr_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(1000)}';

    return AddressModel(
      id: id,
      name: '',
      address: '',
      isDefault: isDefault,
    );
  }
}
