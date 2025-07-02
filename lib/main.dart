// ignore_for_file: deprecated_member_use, no_leading_underscores_for_local_identifiers, prefer_const_constructors, unused_import, depend_on_referenced_packages, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart'; // Import for firstWhereOrNull
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

part 'main.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();

  Hive.registerAdapter(SepatuAdapter());
  Hive.registerAdapter(PembelianAdapter());
  Hive.registerAdapter(CartItemAdapter());
  Hive.registerAdapter(FavoriteItemAdapter()); // Register new adapter
  Hive.registerAdapter(ReviewAdapter()); // Register new adapter

  runApp(
    ChangeNotifierProvider(
      create: (context) => SepatuProvider(),
      child: const MyApp(),
    ),
  );
}

@HiveType(typeId: 0)
class Sepatu {
  @HiveField(0)
  final String barcode;
  @HiveField(1)
  final String nama;
  @HiveField(2)
  final String brand;
  @HiveField(3)
  final String ukuran;
  @HiveField(4)
  String jumlah;
  @HiveField(5)
  final String detail;
  @HiveField(6)
  final String waktuInput;
  @HiveField(7)
  final String harga;
  @HiveField(8)
  final String? gambarPath;
  @HiveField(9)
  bool isDeleted;
  @HiveField(10) // New field for category
  final String kategori;

  Sepatu({
    required this.barcode,
    required this.nama,
    required this.brand,
    required this.ukuran,
    required this.jumlah,
    required this.detail,
    required this.waktuInput,
    required this.harga,
    this.gambarPath,
    this.isDeleted = false,
    this.kategori = 'Umum', // Default category
  });

  factory Sepatu.fromJson(Map<String, dynamic> json) {
    return Sepatu(
      barcode: json['barcode'],
      nama: json['nama'],
      brand: json['brand'],
      ukuran: json['ukuran'],
      jumlah: json['jumlah'],
      detail: json['detail'],
      waktuInput: json['waktuInput'],
      harga: json['harga'],
      gambarPath: json['gambarPath'],
      isDeleted: json['isDeleted'] ?? false,
      kategori: json['kategori'] ?? 'Umum',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'barcode': barcode,
      'nama': nama,
      'brand': brand,
      'ukuran': ukuran,
      'jumlah': jumlah,
      'detail': detail,
      'waktuInput': waktuInput,
      'harga': harga,
      'gambarPath': gambarPath,
      'isDeleted': isDeleted,
      'kategori': kategori,
    };
  }
}

@HiveType(typeId: 1)
class Pembelian {
  @HiveField(0)
  String namaSepatu;
  @HiveField(1)
  String brandSepatu;
  @HiveField(2)
  String hargaSepatu;
  @HiveField(3)
  String waktuPembelian;
  @HiveField(4)
  String? gambarPath;
  @HiveField(5)
  bool isConfirmed; // New field for purchase status
  @HiveField(6)
  String? pembeliNama; // New field for buyer name
  @HiveField(7)
  String? alamatKirim; // New field for shipping address

  Pembelian({
    required this.namaSepatu,
    required this.brandSepatu,
    required this.hargaSepatu,
    required this.waktuPembelian,
    this.gambarPath,
    this.isConfirmed = false,
    this.pembeliNama,
    this.alamatKirim,
  });

  factory Pembelian.fromJson(Map<String, dynamic> json) {
    return Pembelian(
      namaSepatu: json['namaSepatu'],
      brandSepatu: json['brandSepatu'],
      hargaSepatu: json['hargaSepatu'],
      waktuPembelian: json['waktuPembelian'],
      gambarPath: json['gambarPath'],
      isConfirmed: json['isConfirmed'] ?? false,
      pembeliNama: json['pembeliNama'],
      alamatKirim: json['alamatKirim'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'namaSepatu': namaSepatu,
      'brandSepatu': brandSepatu,
      'hargaSepatu': hargaSepatu,
      'waktuPembelian': waktuPembelian,
      'gambarPath': gambarPath,
      'isConfirmed': isConfirmed,
      'pembeliNama': pembeliNama,
      'alamatKirim': alamatKirim,
    };
  }
}

@HiveType(typeId: 2) // New HiveType for CartItem
class CartItem {
  @HiveField(0)
  final Sepatu sepatu;
  @HiveField(1)
  int quantity;
  @HiveField(2) // New field for selection status
  bool isSelected;

  CartItem(
      {required this.sepatu,
      this.quantity = 1,
      this.isSelected = true}); // Default true
}

@HiveType(typeId: 3) // New HiveType for FavoriteItem
class FavoriteItem {
  @HiveField(0)
  final String sepatuBarcode; // Store barcode to link to Sepatu
  @HiveField(1)
  final String addedTime;

  FavoriteItem({required this.sepatuBarcode, required this.addedTime});
}

@HiveType(typeId: 4) // New HiveType for Review
class Review {
  @HiveField(0)
  final String sepatuBarcode; // Link review to a specific shoe
  @HiveField(1)
  final String userName;
  @HiveField(2)
  final int rating; // 1-5 stars
  @HiveField(3)
  final String comment;
  @HiveField(4)
  final String reviewTime;

  Review({
    required this.sepatuBarcode,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.reviewTime,
  });
}

class SepatuAdapter extends TypeAdapter<Sepatu> {
  @override
  final int typeId = 0;

  @override
  Sepatu read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Sepatu(
      barcode: fields[0] as String,
      nama: fields[1] as String,
      brand: fields[2] as String,
      ukuran: fields[3] as String,
      jumlah: fields[4] as String,
      detail: fields[5] as String,
      waktuInput: fields[6] as String,
      harga: fields[7] as String,
      gambarPath: fields[8] as String?,
      isDeleted: fields[9] as bool,
      kategori: fields[10] as String, // Read new field
    );
  }

  @override
  void write(BinaryWriter writer, Sepatu obj) {
    writer
      ..writeByte(11) // Update byte count
      ..writeByte(0)
      ..write(obj.barcode)
      ..writeByte(1)
      ..write(obj.nama)
      ..writeByte(2)
      ..write(obj.brand)
      ..writeByte(3)
      ..write(obj.ukuran)
      ..writeByte(4)
      ..write(obj.jumlah)
      ..writeByte(5)
      ..write(obj.detail)
      ..writeByte(6)
      ..write(obj.waktuInput)
      ..writeByte(7)
      ..write(obj.harga)
      ..writeByte(8)
      ..write(obj.gambarPath)
      ..writeByte(9)
      ..write(obj.isDeleted)
      ..writeByte(10) // Write new field
      ..write(obj.kategori);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SepatuAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PembelianAdapter extends TypeAdapter<Pembelian> {
  @override
  final int typeId = 1;

  @override
  Pembelian read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Pembelian(
      namaSepatu: fields[0] as String,
      brandSepatu: fields[1] as String,
      hargaSepatu: fields[2] as String,
      waktuPembelian: fields[3] as String,
      gambarPath: fields[4] as String?,
      isConfirmed: fields[5] as bool,
      pembeliNama: fields[6] as String?,
      alamatKirim: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Pembelian obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.namaSepatu)
      ..writeByte(1)
      ..write(obj.brandSepatu)
      ..writeByte(2)
      ..write(obj.hargaSepatu)
      ..writeByte(3)
      ..write(obj.waktuPembelian)
      ..writeByte(4)
      ..write(obj.gambarPath)
      ..writeByte(5)
      ..write(obj.isConfirmed)
      ..writeByte(6)
      ..write(obj.pembeliNama)
      ..writeByte(7)
      ..write(obj.alamatKirim);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PembelianAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CartItemAdapter extends TypeAdapter<CartItem> {
  @override
  final int typeId = 2;

  @override
  CartItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CartItem(
      sepatu: fields[0] as Sepatu,
      quantity: fields[1] as int,
      isSelected: fields[2] as bool, // Read new field
    );
  }

  @override
  void write(BinaryWriter writer, CartItem obj) {
    writer
      ..writeByte(3) // Update byte count to 3
      ..writeByte(0)
      ..write(obj.sepatu)
      ..writeByte(1)
      ..write(obj.quantity)
      ..writeByte(2) // Write new field
      ..write(obj.isSelected);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FavoriteItemAdapter extends TypeAdapter<FavoriteItem> {
  @override
  final int typeId = 3;

  @override
  FavoriteItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteItem(
      sepatuBarcode: fields[0] as String,
      addedTime: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteItem obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.sepatuBarcode)
      ..writeByte(1)
      ..write(obj.addedTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReviewAdapter extends TypeAdapter<Review> {
  @override
  final int typeId = 4;

  @override
  Review read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Review(
      sepatuBarcode: fields[0] as String,
      userName: fields[1] as String,
      rating: fields[2] as int,
      comment: fields[3] as String,
      reviewTime: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Review obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.sepatuBarcode)
      ..writeByte(1)
      ..write(obj.userName)
      ..writeByte(2)
      ..write(obj.rating)
      ..writeByte(3)
      ..write(obj.comment)
      ..writeByte(4)
      ..write(obj.reviewTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SepatuProvider extends ChangeNotifier {
  late Box<Sepatu> _sepatuBox;
  late Box<Pembelian> _pembelianBox;
  late Box<CartItem> _cartBox;
  late Box<FavoriteItem> _favoriteBox; // New box for favorites
  late Box<Review> _reviewBox; // New box for reviews

  List<Sepatu> get dataSepatu =>
      _sepatuBox.values.where((s) => !s.isDeleted).toList();

  List<Sepatu> get allSepatu => _sepatuBox.values.toList();

  List<Pembelian> get riwayatBeli => _pembelianBox.values.toList();

  List<CartItem> get cart => _cartBox.values.toList();

  // New getter for favorite items (returns Sepatu objects)
  List<Sepatu> get favoriteSepatu {
    final favoriteBarcodes =
        _favoriteBox.values.map((f) => f.sepatuBarcode).toSet();
    return _sepatuBox.values
        .where((s) => favoriteBarcodes.contains(s.barcode))
        .toList();
  }

  // New getter for all reviews
  List<Review> get allReviews => _reviewBox.values.toList();

  SepatuProvider() {
    _initBoxes();
  }

  Future<void> _initBoxes() async {
    _sepatuBox = await Hive.openBox<Sepatu>('sepatuBox');
    _pembelianBox = await Hive.openBox<Pembelian>('pembelianBox');
    _cartBox = await Hive.openBox<CartItem>('cartBox');
    _favoriteBox =
        await Hive.openBox<FavoriteItem>('favoriteBox'); // Open favorite box
    _reviewBox = await Hive.openBox<Review>('reviewBox'); // Open review box

    // ... (existing initial data for _sepatuBox) ...
    if (_sepatuBox.isEmpty) {
      _sepatuBox.add(
        Sepatu(
          barcode: "NK001",
          nama: "Nike Air Max 1",
          brand: "Nike",
          ukuran: "42",
          jumlah: "10",
          detail: "Klasik dan nyaman, cocok untuk santai.",
          waktuInput:
              DateTime.now().subtract(const Duration(days: 2)).toString(),
          harga: "1200000",
          gambarPath: "assets/images/nike_air_max_1.png",
          isDeleted: false,
          kategori: "Running", // Example category
        ),
      );
      _sepatuBox.add(
        Sepatu(
          barcode: "AD002",
          nama: "Adidas Ultraboost 22",
          brand: "Adidas",
          ukuran: "43",
          jumlah: "1",
          detail: "Sepatu lari dengan bantalan responsif.",
          waktuInput:
              DateTime.now().subtract(const Duration(days: 5)).toString(),
          harga: "1800000",
          gambarPath: "assets/images/adidas_ultraboost_22.png",
          isDeleted: false,
          kategori: "Running", // Example category
        ),
      );
      _sepatuBox.add(
        Sepatu(
          barcode: "NB003",
          nama: "New Balance 574",
          brand: "New Balance",
          ukuran: "41",
          jumlah: "7",
          detail: "Sepatu kasual klasik dengan kenyamanan sehari-hari.",
          waktuInput:
              DateTime.now().subtract(const Duration(days: 1)).toString(),
          harga: "950000",
          gambarPath: "assets/images/new_balance_574.png",
          isDeleted: false,
          kategori: "Casual", // Example category
        ),
      );
      _sepatuBox.add(
        Sepatu(
          barcode: "CV004",
          nama: "Converse Chuck Taylor All Star",
          brand: "Converse",
          ukuran: "40",
          jumlah: "5",
          detail: "Sepatu ikonik untuk gaya klasik.",
          waktuInput:
              DateTime.now().subtract(const Duration(days: 3)).toString(),
          harga: "700000",
          gambarPath: "assets/images/converce.png",
          isDeleted: false,
          kategori: "Casual", // Example category
        ),
      );
      _sepatuBox.add(
        Sepatu(
          barcode: "PU005",
          nama: "Puma RS-X",
          brand: "Puma",
          ukuran: "44",
          jumlah: "3",
          detail: "Desain retro-futuristik dengan kenyamanan maksimal.",
          waktuInput:
              DateTime.now().subtract(const Duration(days: 6)).toString(),
          harga: "1100000",
          gambarPath: "assets/images/puma.png",
          isDeleted: false,
          kategori: "Lifestyle", // Example category
        ),
      );
    }

    // Add some initial reviews for demonstration
    if (_reviewBox.isEmpty) {
      _reviewBox.add(Review(
        sepatuBarcode: "NK001",
        userName: "Pengguna A",
        rating: 5,
        comment: "Sepatu ini sangat nyaman dan stylish!",
        reviewTime:
            DateTime.now().subtract(const Duration(days: 10)).toString(),
      ));
      _reviewBox.add(Review(
        sepatuBarcode: "NK001",
        userName: "Pengguna B",
        rating: 4,
        comment: "Kualitas bagus, tapi sedikit mahal.",
        reviewTime: DateTime.now().subtract(const Duration(days: 5)).toString(),
      ));
      _reviewBox.add(Review(
        sepatuBarcode: "AD002",
        userName: "Pengguna C",
        rating: 5,
        comment: "Cocok untuk lari jarak jauh, bantalan empuk.",
        reviewTime: DateTime.now().subtract(const Duration(days: 7)).toString(),
      ));
    }

    notifyListeners();
  }

  void tambahSepatu(Sepatu sepatu) {
    _sepatuBox.add(sepatu);
    notifyListeners();
  }

  void hapusSepatu(int index) {
    final sepatuToUpdate = dataSepatu[index];
    final key = _sepatuBox.keys.firstWhere(
        (k) => _sepatuBox.get(k)?.barcode == sepatuToUpdate.barcode);
    final existingSepatu = _sepatuBox.get(key);

    if (existingSepatu != null) {
      existingSepatu.isDeleted = true;

      _sepatuBox.put(key, existingSepatu);
      notifyListeners();
    }
  }

  void restoreSepatu(int index) {
    final sepatuToUpdate = allSepatu[index];
    final key = _sepatuBox.keys.firstWhere(
        (k) => _sepatuBox.get(k)?.barcode == sepatuToUpdate.barcode);
    final existingSepatu = _sepatuBox.get(key);

    if (existingSepatu != null) {
      existingSepatu.isDeleted = false;
      _sepatuBox.put(key, existingSepatu);
      notifyListeners();
    }
  }

  void editSepatu(int index, Sepatu updated) {
    final sepatuToEdit = allSepatu[index];
    final key = _sepatuBox.keys
        .firstWhere((k) => _sepatuBox.get(k)?.barcode == sepatuToEdit.barcode);

    _sepatuBox.put(key, updated);
    notifyListeners();
  }

  // Cart methods
  void addToCart(Sepatu sepatu) {
    // Check if stock is available
    if ((int.tryParse(sepatu.jumlah) ?? 0) <= 0) {
      return; // Cannot add to cart if sold out
    }

    final Map<dynamic, CartItem> cartMap = _cartBox.toMap();
    dynamic foundKey;
    CartItem? foundItem;

    for (var entry in cartMap.entries) {
      if (entry.value.sepatu.barcode == sepatu.barcode) {
        foundKey = entry.key;
        foundItem = entry.value;
        break;
      }
    }

    if (foundItem != null) {
      if (foundItem.quantity < (int.tryParse(sepatu.jumlah) ?? 0)) {
        foundItem.quantity++;
        foundItem.isSelected =
            true; // Pastikan terpilih saat ditambahkan/diperbarui
        _cartBox.put(foundKey, foundItem);
      } else {
        // Optionally show a message that max stock reached in cart
      }
    } else {
      _cartBox.add(CartItem(
          sepatu: sepatu,
          quantity: 1,
          isSelected: true)); // Default isSelected true
    }
    notifyListeners();
  }

  void removeFromCart(CartItem item) {
    final Map<dynamic, CartItem> cartMap = _cartBox.toMap();
    dynamic keyToRemove;
    for (var entry in cartMap.entries) {
      if (entry.value.sepatu.barcode == item.sepatu.barcode) {
        keyToRemove = entry.key;
        break;
      }
    }

    if (keyToRemove != null) {
      _cartBox.delete(keyToRemove);
      notifyListeners();
    }
  }

  void updateCartItemQuantity(CartItem item, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(item);
      return;
    }

    // Ensure newQuantity does not exceed available stock
    if (newQuantity > (int.tryParse(item.sepatu.jumlah) ?? 0)) {
      // Optional: Show a message that you can't add more than available stock
      return;
    }

    final Map<dynamic, CartItem> cartMap = _cartBox.toMap();
    dynamic keyToUpdate;
    for (var entry in cartMap.entries) {
      if (entry.value.sepatu.barcode == item.sepatu.barcode) {
        keyToUpdate = entry.key;
        break;
      }
    }

    if (keyToUpdate != null) {
      final CartItem itemToUpdateInBox = _cartBox.get(keyToUpdate)!;
      itemToUpdateInBox.quantity = newQuantity;
      _cartBox.put(keyToUpdate, itemToUpdateInBox);
      notifyListeners();
    }
  }

  void clearCart() {
    _cartBox.clear();
    notifyListeners();
  }

  // Tambahkan method untuk mengubah status isSelected
  void toggleCartItemSelection(CartItem item) {
    final Map<dynamic, CartItem> cartMap = _cartBox.toMap();
    dynamic keyToUpdate;
    for (var entry in cartMap.entries) {
      if (entry.value.sepatu.barcode == item.sepatu.barcode) {
        keyToUpdate = entry.key;
        break;
      }
    }

    if (keyToUpdate != null) {
      final CartItem itemToUpdateInBox = _cartBox.get(keyToUpdate)!;
      itemToUpdateInBox.isSelected = !itemToUpdateInBox.isSelected;
      _cartBox.put(keyToUpdate, itemToUpdateInBox);
      notifyListeners();
    }
  }

  // Tambahkan method untuk memilih/tidak memilih semua item
  void toggleAllCartItemsSelection(bool selectAll) {
    for (var key in _cartBox.keys) {
      final item = _cartBox.get(key);
      if (item != null) {
        item.isSelected = selectAll;
        _cartBox.put(key, item);
      }
    }
    notifyListeners();
  }

// --- Favorite Methods ---
  bool isFavorite(Sepatu sepatu) {
    return _favoriteBox.values.any((f) => f.sepatuBarcode == sepatu.barcode);
  }

  void toggleFavorite(Sepatu sepatu) {
    if (isFavorite(sepatu)) {
      final keyToRemove = _favoriteBox.keys.firstWhere(
          (k) => _favoriteBox.get(k)?.sepatuBarcode == sepatu.barcode);
      _favoriteBox.delete(keyToRemove);
    } else {
      _favoriteBox.add(FavoriteItem(
        sepatuBarcode: sepatu.barcode,
        addedTime: DateTime.now().toString(),
      ));
    }
    notifyListeners();
  }

  // --- Review Methods ---
  List<Review> getReviewsForSepatu(String sepatuBarcode) {
    return _reviewBox.values
        .where((r) => r.sepatuBarcode == sepatuBarcode)
        .toList();
  }

  double getAverageRatingForSepatu(String sepatuBarcode) {
    final reviews = getReviewsForSepatu(sepatuBarcode);
    if (reviews.isEmpty) return 0.0;
    final totalRating = reviews.fold(0, (sum, review) => sum + review.rating);
    return totalRating / reviews.length;
  }

  void addReview(Review review) {
    _reviewBox.add(review);
    notifyListeners();
  }

  void confirmPurchase(
      List<CartItem> items, String pembeliNama, String alamatKirim) {
    // Filter hanya item yang terpilih
    final selectedItems = items.where((item) => item.isSelected).toList();

    if (selectedItems.isEmpty) {
      // Handle case where no items are selected for purchase
      return;
    }

    for (var cartItem in selectedItems) {
      // Loop hanya pada item yang terpilih
      final sepatuToBuy = cartItem.sepatu;
      final quantityToBuy = cartItem.quantity;

      final key = _sepatuBox.keys.firstWhere(
        (k) {
          final s = _sepatuBox.get(k);
          return s != null && s.barcode == sepatuToBuy.barcode && !s.isDeleted;
        },
        orElse: () => -1,
      );

      if (key != -1) {
        final existingSepatu = _sepatuBox.get(key);
        if (existingSepatu != null) {
          int currentQuantity = int.tryParse(existingSepatu.jumlah) ?? 0;
          if (currentQuantity >= quantityToBuy) {
            existingSepatu.jumlah =
                (currentQuantity - quantityToBuy).toString();
            _sepatuBox.put(key, existingSepatu);

            // Add purchase record for each item in the cart
            for (int i = 0; i < quantityToBuy; i++) {
              _pembelianBox.add(
                Pembelian(
                  namaSepatu: existingSepatu.nama,
                  brandSepatu: existingSepatu.brand,
                  hargaSepatu: existingSepatu.harga,
                  waktuPembelian: DateTime.now().toString(),
                  gambarPath: existingSepatu.gambarPath,
                  isConfirmed: true, // Mark as confirmed
                  pembeliNama: pembeliNama,
                  alamatKirim: alamatKirim,
                ),
              );
            }
          }
        }
      }
    }
    // Hapus hanya item yang terpilih dari keranjang setelah pembelian
    for (var item in selectedItems) {
      removeFromCart(item); // Gunakan fungsi removeFromCart yang sudah ada
    }
    notifyListeners(); // Notify after all removals
  }

  void cancelPurchase(int index) {
    final pembelianToCancel = riwayatBeli[index];
    final key = _pembelianBox.keys.firstWhere((k) =>
        _pembelianBox.get(k) == pembelianToCancel); // Find by object equality
    final existingPembelian = _pembelianBox.get(key);

    if (existingPembelian != null) {
      // Restore stock if it was a confirmed purchase
      if (existingPembelian.isConfirmed) {
        final sepatu = IterableExtension(_sepatuBox.values).firstWhereOrNull(
          (s) =>
              s.nama == existingPembelian.namaSepatu &&
              s.brand == existingPembelian.brandSepatu &&
              s.harga == existingPembelian.hargaSepatu,
        );
        if (sepatu != null) {
          final sepatuKey = _sepatuBox.keys
              .firstWhere((k) => _sepatuBox.get(k)?.barcode == sepatu.barcode);
          final existingSepatu = _sepatuBox.get(sepatuKey);
          if (existingSepatu != null) {
            existingSepatu.jumlah = (int.tryParse(existingSepatu.jumlah)! + 1)
                .toString(); // Assuming 1 quantity per purchase entry
            _sepatuBox.put(sepatuKey, existingSepatu);
          }
        }
      }
      _pembelianBox.delete(key);
      notifyListeners();
    }
  }

  void updatePurchaseStatus(Pembelian pembelian, bool isConfirmed,
      String? pembeliNama, String? alamatKirim) {
    final key =
        _pembelianBox.keys.firstWhere((k) => _pembelianBox.get(k) == pembelian);
    final existingPembelian = _pembelianBox.get(key);

    if (existingPembelian != null) {
      existingPembelian.isConfirmed = isConfirmed;
      existingPembelian.pembeliNama = pembeliNama;
      existingPembelian.alamatKirim = alamatKirim;
      _pembelianBox.put(key, existingPembelian);
      notifyListeners();
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShoesSpeed',
      theme: ThemeData(
        fontFamily: 'Montserrat',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        // UBAH BARIS INI:
        scaffoldBackgroundColor:
            Colors.white, // Mengubah latar belakang menjadi putih
        appBarTheme: const AppBarTheme(
          color: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ... (bagian import dan kelas lainnya tetap sama) ...

// ... (remaining classes) ...

class LoginPage extends StatefulWidget {
  const LoginPage({super.key}); // Tambahkan const constructor

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscureText = true; // State untuk mengontrol visibilitas password

  void login(BuildContext context) {
    String user = usernameController.text;
    String pass = passwordController.text;

    if (user == "admin" && pass == "admin123") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LihatDataPage()),
      );
    } else if (user == "member" && pass == "member123") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ShopPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login gagal. Coba lagi!")),
      );
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;

    return Scaffold(
      body: Center(
        // Memusatkan seluruh konten
        child: SingleChildScrollView(
          // Agar bisa discroll di layar kecil
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment:
                CrossAxisAlignment.center, // Memusatkan secara horizontal
            children: [
              // Image above (e.g., Logo)
              Image.asset(
                "assets/images/blue.png", // Ganti dengan path gambar logo/gambar di atas
                height: isSmallScreen ? 50 : 150, // Sesuaikan tinggi gambar
                width: isSmallScreen ? 300 : 150, // Sesuaikan lebar gambar
                fit: BoxFit.contain,
              ),
              const SizedBox(
                  height: 16), // Jarak antara gambar logo dan teks sambutan

              // Teks "Welcome back!"
              const Text(
                "Welcome back!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.indigo,
                  shadows: [
                    Shadow(
                      blurRadius: 5.0,
                      color: Colors.black26,
                      offset: Offset(1.0, 1.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                  height: 8), // Jarak antara teks sambutan dan teks baru

              // Teks "Enter your username and password"
              Text(
                "Enter your username and password",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600], // Warna abu-abu
                ),
              ),
              const SizedBox(height: 48), // Jarak antara teks baru dan form

              // Username TextField
              SizedBox(
                // Tambahkan SizedBox untuk mengontrol lebar TextField
                width: isSmallScreen ? double.infinity : 400,
                child: TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: "Username",
                    hintText: "Masukkan username Anda",
                    filled: true,
                    fillColor: Colors.grey[50],
                    // UBAH BAGIAN INI UNTUK OUTLINE
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 1.0), // Garis outline default
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 0, 150, 250),
                        width: 2.0, // Garis outline saat fokus lebih tebal
                      ),
                    ),
                    prefixIcon: const Icon(Icons.person, color: Colors.indigo),
                    // Untuk garis pemisah antara ikon dan teks, kita bisa menggunakan `prefix`
                    // yang lebih kompleks atau `VerticalDivider` di dalam `prefixIcon`.
                    // Namun, cara paling umum adalah dengan `prefixIconConstraints`
                    // dan mungkin sedikit padding pada ikon itu sendiri.
                    // Jika Anda ingin garis vertikal yang jelas, Anda bisa menggunakan `prefix` widget.
                    prefixIconConstraints:
                        const BoxConstraints(minWidth: 48, minHeight: 48),
                  ),
                ),
              ),
              const SizedBox(height: 16), // Jarak antara username dan password

              // Password TextField
              SizedBox(
                // Tambahkan SizedBox untuk mengontrol lebar TextField
                width: isSmallScreen ? double.infinity : 400,
                child: TextField(
                  controller: passwordController,
                  obscureText:
                      _obscureText, // Gunakan state _obscureText di sini
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "Masukkan password Anda",
                    filled: true,
                    fillColor: Colors.grey[50],
                    // UBAH BAGIAN INI UNTUK OUTLINE
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 1.0), // Garis outline default
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 0, 150, 250),
                        width: 2.0, // Garis outline saat fokus lebih tebal
                      ),
                    ),
                    prefixIcon: const Icon(Icons.lock, color: Colors.indigo),
                    // Untuk garis pemisah antara ikon dan teks
                    prefixIconConstraints:
                        const BoxConstraints(minWidth: 48, minHeight: 48),
                    // Hapus suffixIcon IconButton yang lama
                  ),
                ),
              ),
              const SizedBox(
                  height: 8), // Jarak antara password dan tombol geser

              // Tombol Geser (Switch) untuk Lihat Password
              SizedBox(
                // Bungkus dengan SizedBox untuk mengontrol lebar
                width: isSmallScreen ? double.infinity : 400,
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.end, // Posisikan ke kanan
                  children: [
                    Text(
                      _obscureText
                          ? "Tampilkan Password"
                          : "Sembunyikan Password",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    Switch(
                      value:
                          !_obscureText, // Value adalah kebalikan dari _obscureText
                      onChanged: (bool newValue) {
                        setState(() {
                          _obscureText = !newValue; // Perbarui _obscureText
                        });
                      },
                      activeColor: Colors.blueAccent, // Warna saat aktif
                      inactiveThumbColor:
                          Colors.grey, // Warna thumb saat tidak aktif
                      inactiveTrackColor:
                          Colors.grey[300], // Warna track saat tidak aktif
                    ),
                  ],
                ),
              ),
              const SizedBox(
                  height: 32), // Jarak antara tombol geser dan tombol login

              // Login Button
              Container(
                // Tetap gunakan Container untuk gradient pada tombol
                width: isSmallScreen
                    ? double.infinity
                    : 400, // Sesuaikan lebar tombol
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 0, 191, 255),
                      Color.fromARGB(255, 0, 150, 250),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () => login(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LihatDataPage extends StatefulWidget {
  const LihatDataPage({super.key});

  @override
  State<LihatDataPage> createState() => _LihatDataPageState();
}

class _LihatDataPageState extends State<LihatDataPage> {
  String searchKeyword = "";

  void _showEditDialog(BuildContext context, int index, Sepatu sepatu) {
    final _formKey = GlobalKey<FormState>();
    final barcodeController = TextEditingController(text: sepatu.barcode);
    final namaController = TextEditingController(text: sepatu.nama);
    final brandController = TextEditingController(text: sepatu.brand);
    final ukuranController = TextEditingController(text: sepatu.ukuran);
    final jumlahController = TextEditingController(text: sepatu.jumlah);
    final detailController = TextEditingController(text: sepatu.detail);
    final hargaController = TextEditingController(text: sepatu.harga);
    final gambarPathController = TextEditingController(text: sepatu.gambarPath);
    String selectedKategori =
        sepatu.kategori; // Initialize with current category

    final List<String> _kategoriOptions = [
      'Umum',
      'Running',
      'Casual',
      'Lifestyle',
      'Basket',
      'Sepak Bola',
    ];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Edit Sepatu'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: barcodeController,
                    decoration: const InputDecoration(
                        labelText: 'Barcode', border: OutlineInputBorder()),
                    validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  TextFormField(
                    controller: namaController,
                    decoration: const InputDecoration(
                        labelText: 'Nama', border: OutlineInputBorder()),
                    validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  TextFormField(
                    controller: brandController,
                    decoration: const InputDecoration(
                        labelText: 'Brand', border: OutlineInputBorder()),
                  ),
                  TextFormField(
                    controller: ukuranController,
                    decoration: const InputDecoration(
                        labelText: 'Ukuran', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: jumlahController,
                    decoration: const InputDecoration(
                        labelText: 'Jumlah', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val!.isEmpty) return 'Wajib diisi';
                      if (int.tryParse(val) == null) return 'Harus angka';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: hargaController,
                    decoration: const InputDecoration(
                      labelText: 'Harga (Rp)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val!.isEmpty) return 'Wajib diisi';
                      if (int.tryParse(val) == null) return 'Harus angka';
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedKategori,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(),
                    ),
                    items: _kategoriOptions.map((String kategori) {
                      return DropdownMenuItem<String>(
                        value: kategori,
                        child: Text(kategori),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      selectedKategori = newValue!;
                    },
                    validator: (val) => val == null || val.isEmpty
                        ? 'Pilih kategori sepatu'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: detailController,
                    decoration: const InputDecoration(
                        labelText: 'Detail', border: OutlineInputBorder()),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: gambarPathController,
                    decoration: const InputDecoration(
                      labelText: 'Path Gambar (e.g., assets/images/sepatu.png)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (sepatu.gambarPath != null &&
                      sepatu.gambarPath!.isNotEmpty)
                    Image.asset(
                      sepatu.gambarPath!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.broken_image,
                          size: 80,
                          color: Colors.red,
                        );
                      },
                    )
                  else
                    Container(
                      height: 100,
                      width: 100,
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.image_outlined,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final updated = Sepatu(
                    barcode: barcodeController.text,
                    nama: namaController.text,
                    brand: brandController.text,
                    ukuran: ukuranController.text,
                    jumlah: jumlahController.text,
                    detail: detailController.text,
                    waktuInput: sepatu.waktuInput,
                    harga: hargaController.text,
                    isDeleted: sepatu.isDeleted,
                    gambarPath: gambarPathController.text.isNotEmpty
                        ? gambarPathController.text
                        : null,
                    kategori: selectedKategori, // Save updated category
                  );
                  final actualIndex = Provider.of<SepatuProvider>(
                    dialogContext,
                    listen: false,
                  ).allSepatu.indexOf(sepatu);

                  if (actualIndex != -1) {
                    Provider.of<SepatuProvider>(
                      dialogContext,
                      listen: false,
                    ).editSepatu(actualIndex, updated);
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('Data sepatu berhasil diupdate!'),
                      ),
                    );
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sepatuProvider = Provider.of<SepatuProvider>(context);
    final allSepatu = sepatuProvider.allSepatu;

    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;

    final dataFiltered = allSepatu.asMap().entries.where((entry) {
      final sepatu = entry.value;
      return sepatu.barcode.toLowerCase().contains(
                searchKeyword.toLowerCase(),
              ) ||
          sepatu.nama.toLowerCase().contains(searchKeyword.toLowerCase());
    }).toList();

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    final timeFormatter = DateFormat('yyyy-MM-dd HH:mm');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'DATA SEPATU',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Cari berdasarkan barcode atau nama...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => searchKeyword = value),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: isSmallScreen ? 8 : 10,
                headingRowColor: MaterialStateProperty.all(
                  Colors.indigo.shade400,
                ),
                headingTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                border: TableBorder.all(color: Colors.grey.shade400),
                columns: [
                  DataColumn(
                    label: Text(
                      'No',
                      style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Barcode',
                      style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Nama',
                      style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Brand',
                      style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Ukuran',
                      style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Jumlah',
                      style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Harga',
                      style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Kategori', // New column
                      style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Detail',
                      style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Waktu Input',
                      style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Status',
                      style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Aksi',
                      style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                    ),
                  ),
                ],
                rows: dataFiltered.map((entry) {
                  final index = allSepatu.indexOf(entry.value);
                  final sepatu = entry.value;
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 11 : 13,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          sepatu.barcode,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 11 : 13,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          sepatu.nama,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 11 : 13,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          sepatu.brand,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 11 : 13,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          sepatu.ukuran,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 11 : 13,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          sepatu.jumlah,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 11 : 13,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          currencyFormatter.format(
                            int.tryParse(sepatu.harga) ?? 0,
                          ),
                          style: TextStyle(
                            fontSize: isSmallScreen ? 11 : 13,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          sepatu.kategori, // Display new field
                          style: TextStyle(
                            fontSize: isSmallScreen ? 11 : 13,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: isSmallScreen ? 80 : 150,
                          child: Text(
                            sepatu.detail,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 11 : 13,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          timeFormatter.format(
                            DateTime.parse(sepatu.waktuInput),
                          ),
                          style: TextStyle(
                            fontSize: isSmallScreen ? 10 : 12,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          sepatu.isDeleted ? 'Dihapus' : 'Aktif',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 11 : 13,
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                if (sepatu.isDeleted) {
                                  sepatuProvider.restoreSepatu(index);
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Data sepatu berhasil direstore!',
                                      ),
                                    ),
                                  );
                                } else {
                                  sepatuProvider.hapusSepatu(index);
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Data sepatu berhasil dihapus!',
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: sepatu.isDeleted
                                    ? Colors.green
                                    : Colors.red,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 4 : 8,
                                  vertical: isSmallScreen ? 2 : 4,
                                ),
                                textStyle: TextStyle(
                                  fontSize: isSmallScreen ? 10 : 12,
                                ),
                              ),
                              child: Text(
                                sepatu.isDeleted ? 'Restore' : 'Hapus',
                              ),
                            ),
                            SizedBox(
                              width: isSmallScreen ? 2 : 4,
                            ),
                            if (!sepatu.isDeleted)
                              ElevatedButton(
                                onPressed: () => _showEditDialog(
                                  context,
                                  index,
                                  sepatu,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    0,
                                    150,
                                    255,
                                  ),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isSmallScreen ? 4 : 8,
                                    vertical: isSmallScreen ? 2 : 4,
                                  ),
                                  textStyle: TextStyle(
                                    fontSize: isSmallScreen ? 10 : 12,
                                  ),
                                ),
                                child: const Text('Edit'),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// HALAMAN TOKO (ShopPage) - Untuk Member
// =============================================================================

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  String _searchQuery = '';
  String? _selectedCategoryFilter; // Null means "All Categories"

  final List<String> _kategoriOptions = [
    'Semua Kategori', // Option to show all
    'Umum',
    'Running',
    'Casual',
    'Lifestyle',
    'Basket',
    'Sepak Bola',
  ];

  @override
  Widget build(BuildContext context) {
    final sepatuProvider = Provider.of<SepatuProvider>(context);
    // Filter sepatu yang tersedia (tidak dihapus)
    List<Sepatu> allShopShoes = sepatuProvider.dataSepatu;

    // Dapatkan lebar layar untuk penyesuaian responsif
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600; // Definisi layar kecil

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      allShopShoes = allShopShoes.where((sepatu) {
        return sepatu.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            sepatu.brand.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply category filter
    if (_selectedCategoryFilter != null &&
        _selectedCategoryFilter != 'Semua Kategori') {
      allShopShoes = allShopShoes.where((sepatu) {
        return sepatu.kategori == _selectedCategoryFilter;
      }).toList();
    }

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Toko ShoeSpeed",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 18 : 20, // Ukuran font disesuaikan
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            tooltip: 'Profil Saya',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner Promosi
          Padding(
            padding: EdgeInsets.all(
                isSmallScreen ? 8.0 : 16.0), // Padding disesuaikan
            child: Container(
              height: isSmallScreen ? 120 : 160, // Tinggi disesuaikan
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                    isSmallScreen ? 15 : 20), // Radius disesuaikan
                image: const DecorationImage(
                  image: AssetImage('assets/images/bcshoes.png'),
                  fit: BoxFit.cover,
                  colorFilter:
                      ColorFilter.mode(Colors.black54, BlendMode.darken),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.6),
                    spreadRadius: 3,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Diskon Spesial Akhir Tahun!\nUp to 50% Off!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize:
                        isSmallScreen ? 20 : 26, // Ukuran font disesuaikan
                    fontWeight: FontWeight.w900,
                    shadows: const [
                      Shadow(
                        blurRadius: 12.0,
                        color: Colors.black,
                        offset: Offset(3.0, 3.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8.0 : 16.0, vertical: 8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari sepatu favoritmu...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            // Clear text field content (requires a TextEditingController)
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(
                    vertical: isSmallScreen ? 12 : 14,
                    horizontal: isSmallScreen ? 12 : 16),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          // Category Filter
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8.0 : 16.0, vertical: 8.0),
            child: DropdownButtonFormField<String>(
              value: _selectedCategoryFilter ?? _kategoriOptions[0],
              decoration: InputDecoration(
                labelText: 'Pilih Kategori',
                labelStyle: TextStyle(color: Colors.grey[700]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(
                    vertical: isSmallScreen ? 12 : 14,
                    horizontal: isSmallScreen ? 12 : 16),
              ),
              items: _kategoriOptions.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategoryFilter =
                      newValue == 'Semua Kategori' ? null : newValue;
                });
              },
            ),
          ),
          // Bagian "Semua Sepatu"
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8.0 : 16.0,
                vertical: isSmallScreen ? 8.0 : 12.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Semua Sepatu',
                style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo),
              ),
            ),
          ),
          Expanded(
            child: allShopShoes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sentiment_dissatisfied,
                          size: isSmallScreen ? 60 : 80,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        Text(
                          'Maaf, tidak ada sepatu yang ditemukan.',
                          style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                              color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Coba cari dengan kata kunci lain atau kategori berbeda.',
                          style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    // Menggunakan GridView.builder
                    padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 8.0 : 12.0, vertical: 8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isSmallScreen
                          ? 2
                          : 3, // 2 kolom di HP, 3 kolom di tablet/desktop
                      crossAxisSpacing:
                          isSmallScreen ? 8.0 : 12.0, // Spasi antar kolom
                      mainAxisSpacing:
                          isSmallScreen ? 8.0 : 12.0, // Spasi antar baris
                      childAspectRatio: isSmallScreen
                          ? 0.7
                          : 0.8, // Rasio aspek untuk tampilan ala Shopee
                    ),
                    itemCount: allShopShoes.length,
                    itemBuilder: (context, index) {
                      final s = allShopShoes[index];
                      final isSoldOut = (int.tryParse(s.jumlah) ?? 0) <= 0;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailPage(sepatu: s),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                15.0), // Semua sudut tumpul
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              Column(
                                // Menggunakan Column untuk gambar di atas, teks di bawah
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Gambar Produk (di bagian atas Card)
                                  Expanded(
                                    flex: 3, // Proporsi untuk gambar
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(
                                                15.0)), // Sudut atas tumpul
                                        border: Border.all(
                                            color: Colors.grey.shade200),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(
                                                15.0)), // Sudut atas tumpul
                                        child: s.gambarPath != null &&
                                                s.gambarPath!.isNotEmpty
                                            ? Image.asset(
                                                s.gambarPath!,
                                                fit: BoxFit
                                                    .cover, // Gambar mengisi area
                                                errorBuilder: (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) {
                                                  return Icon(
                                                    Icons.broken_image,
                                                    size:
                                                        isSmallScreen ? 50 : 70,
                                                    color: Colors.red.shade300,
                                                  );
                                                },
                                              )
                                            : Icon(
                                                Icons.image_not_supported,
                                                size: isSmallScreen ? 50 : 70,
                                                color: Colors.grey[400],
                                              ),
                                      ),
                                    ),
                                  ),
                                  // Detail Teks Produk (di bagian bawah Card)
                                  Expanded(
                                    flex:
                                        2, // Proporsi untuk teks dan informasi
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                          isSmallScreen ? 8.0 : 12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                s.nama,
                                                style: TextStyle(
                                                  fontSize:
                                                      isSmallScreen ? 14 : 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                s.brand,
                                                style: TextStyle(
                                                  fontSize:
                                                      isSmallScreen ? 11 : 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              SizedBox(
                                                  height:
                                                      isSmallScreen ? 4 : 6),
                                              Text(
                                                currencyFormatter.format(
                                                  int.tryParse(s.harga) ?? 0,
                                                ),
                                                style: TextStyle(
                                                  fontSize:
                                                      isSmallScreen ? 16 : 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.deepOrange,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Spacer(), // Mendorong informasi ke bawah
                                          // Informasi Jarak Pengantaran, Diskon, dan Jumlah Terjual
                                          Wrap(
                                            // Menggunakan Wrap agar informasi bisa ke baris baru jika tidak cukup
                                            spacing: isSmallScreen ? 4.0 : 8.0,
                                            runSpacing:
                                                isSmallScreen ? 4.0 : 8.0,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4,
                                                        horizontal: 8),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  'Jarak: 5 km', // Ganti dengan data yang sesuai
                                                  style: TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: isSmallScreen
                                                          ? 10
                                                          : 12),
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4,
                                                        horizontal: 8),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  'Diskon: 20%', // Ganti dengan data yang sesuai
                                                  style: TextStyle(
                                                      color: Colors.green,
                                                      fontSize: isSmallScreen
                                                          ? 10
                                                          : 12),
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4,
                                                        horizontal: 8),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  'Terjual: 50', // Ganti dengan data yang sesuai
                                                  style: TextStyle(
                                                      color: Colors.orange,
                                                      fontSize: isSmallScreen
                                                          ? 10
                                                          : 12),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (isSoldOut)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(
                                          15.0), // Sudut tumpul
                                    ),
                                    child: Center(
                                      child: Text(
                                        'SOLD OUT',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isSmallScreen ? 20 : 28,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing:
                                              isSmallScreen ? 1.5 : 2.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartPage()),
          );
        },
        backgroundColor: Colors.teal,
        child: Stack(
          children: [
            const Icon(Icons.shopping_cart, color: Colors.white, size: 28),
            if (sepatuProvider.cart.isNotEmpty)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 22,
                    minHeight: 22,
                  ),
                  child: Text(
                    '${sepatuProvider.cart.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// HALAMAN DETAIL (DetailPage)
// =============================================================================
class DetailPage extends StatefulWidget {
  // Ubah menjadi StatefulWidget
  final Sepatu sepatu;
  const DetailPage({super.key, required this.sepatu});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    final sepatuProvider = Provider.of<SepatuProvider>(context);
    final isSoldOut = (int.tryParse(widget.sepatu.jumlah) ?? 0) <= 0;
    final isFavorite = sepatuProvider.isFavorite(widget.sepatu);
    final reviews = sepatuProvider.getReviewsForSepatu(widget.sepatu.barcode);
    final averageRating =
        sepatuProvider.getAverageRatingForSepatu(widget.sepatu.barcode);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sepatu.nama),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: () {
              sepatuProvider.toggleFavorite(widget.sepatu);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(isFavorite
                        ? '${widget.sepatu.nama} dihapus dari favorit.'
                        : '${widget.sepatu.nama} ditambahkan ke favorit!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Fungsi Share belum diimplementasikan')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian Gambar Produk dan Nama Sepatu (di kiri)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar Produk (di kiri)
                  Container(
                    width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.grey[100],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Stack(
                        children: [
                          widget.sepatu.gambarPath != null &&
                                  widget.sepatu.gambarPath!.isNotEmpty
                              ? Image.asset(
                                  widget.sepatu.gambarPath!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.broken_image,
                                      size: 80,
                                      color: Colors.red,
                                    );
                                  },
                                )
                              : Icon(
                                  Icons.image,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                          if (isSoldOut)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: const Center(
                                  child: Text(
                                    'SOLD OUT',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Nama Sepatu (di sebelah kanan gambar)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.sepatu.nama,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.sepatu.brand,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currencyFormatter
                              .format(int.tryParse(widget.sepatu.harga) ?? 0),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 18),
                            Text(
                                ' ${averageRating.toStringAsFixed(1)} (${reviews.length} Ulasan)'), // Tampilkan rata-rata rating
                            const SizedBox(width: 16),
                            Text(
                                'Terjual ${100 - (int.tryParse(widget.sepatu.jumlah) ?? 0)}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),

            // Bagian Variasi/Opsi
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Variasi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      Chip(
                        label: Text('Ukuran: ${widget.sepatu.ukuran}'),
                        backgroundColor: Colors.blue.shade100,
                        labelStyle: const TextStyle(color: Colors.blue),
                      ),
                      Chip(
                        label: Text('Stok: ${widget.sepatu.jumlah}'),
                        backgroundColor: Colors.green.shade100,
                        labelStyle: const TextStyle(color: Colors.green),
                      ),
                      Chip(
                        label: Text('Kategori: ${widget.sepatu.kategori}'),
                        backgroundColor: Colors.purple.shade100,
                        labelStyle: const TextStyle(color: Colors.purple),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 24),

            // Bagian Detail Produk
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Deskripsi Produk',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.sepatu.detail,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Barcode: ${widget.sepatu.barcode}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    'Waktu Input: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(widget.sepatu.waktuInput))}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),

            // Bagian Ulasan Pembeli
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ulasan Pembeli',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _showAddReviewDialog(context, widget.sepatu.barcode);
                        },
                        child: const Text('Tambah Ulasan'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (reviews.isEmpty)
                    const Text('Belum ada ulasan untuk produk ini.',
                        style: TextStyle(color: Colors.grey))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(), // Agar tidak scroll sendiri
                      itemCount: reviews.length,
                      itemBuilder: (context, idx) {
                        final review = reviews[idx];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      review.userName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Row(
                                      children: List.generate(5, (i) {
                                        return Icon(
                                          i < review.rating
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors.amber,
                                          size: 16,
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(review.comment),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('dd MMM yyyy').format(
                                      DateTime.parse(review.reviewTime)),
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline,
                  color: Colors.blueAccent),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Fungsi Chat belum diimplementasikan')),
                );
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isSoldOut
                    ? null
                    : () {
                        sepatuProvider.addToCart(widget.sepatu);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "${widget.sepatu.nama} ditambahkan ke keranjang!"),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSoldOut ? Colors.grey : Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                icon: const Icon(Icons.add_shopping_cart),
                label: Text(isSoldOut ? 'Stok Habis' : 'Tambah ke Keranjang'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: isSoldOut
                    ? null
                    : () {
                        sepatuProvider.addToCart(widget.sepatu);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CartPage()),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "${widget.sepatu.nama} ditambahkan ke keranjang dan siap checkout!"),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSoldOut ? Colors.grey : Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: Text(isSoldOut ? 'Stok Habis' : 'Beli Sekarang'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddReviewDialog(BuildContext context, String sepatuBarcode) {
    final _formKey = GlobalKey<FormState>();
    final _commentController = TextEditingController();
    int _selectedRating = 0; // Rating yang dipilih pengguna

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Tambah Ulasan'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Berikan Rating:'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _selectedRating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() {
                            // Perbarui state di dialog
                            _selectedRating = index + 1;
                          });
                          (dialogContext as Element)
                              .markNeedsBuild(); // Paksa rebuild dialog
                        },
                      );
                    }),
                  ),
                  TextFormField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      labelText: 'Komentar Anda',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (val) {
                      if (val!.isEmpty) return 'Komentar tidak boleh kosong';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate() && _selectedRating > 0) {
                  final newReview = Review(
                    sepatuBarcode: sepatuBarcode,
                    userName:
                        "Pengguna Baru", // Ganti dengan nama pengguna asli jika ada sistem login
                    rating: _selectedRating,
                    comment: _commentController.text,
                    reviewTime: DateTime.now().toString(),
                  );
                  Provider.of<SepatuProvider>(dialogContext, listen: false)
                      .addReview(newReview);
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Ulasan berhasil ditambahkan!')),
                  );
                } else if (_selectedRating == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Mohon berikan rating bintang.')),
                  );
                }
              },
              child: const Text('Kirim Ulasan'),
            ),
          ],
        );
      },
    );
  }
}

// =============================================================================
// HALAMAN KERANJANG (CartPage)
// =============================================================================
class CartPage extends StatefulWidget {
  // Ubah menjadi StatefulWidget
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _selectAll = true; // State untuk "Pilih Semua"

  @override
  void initState() {
    super.initState();
    // Inisialisasi _selectAll berdasarkan status item di keranjang
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sepatuProvider =
          Provider.of<SepatuProvider>(context, listen: false);
      if (sepatuProvider.cart.isNotEmpty) {
        _selectAll = sepatuProvider.cart.every((item) => item.isSelected);
      } else {
        _selectAll = false; // Jika keranjang kosong, selectAll juga false
      }
      setState(() {}); // Perbarui UI setelah inisialisasi
    });
  }

  @override
  Widget build(BuildContext context) {
    final sepatuProvider = Provider.of<SepatuProvider>(context);
    final cartItems = sepatuProvider.cart;

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    // Hitung total harga hanya untuk item yang terpilih
    double totalHarga = cartItems.fold(
      0.0,
      (sum, item) => item.isSelected
          ? sum + (int.tryParse(item.sepatu.harga) ?? 0) * item.quantity
          : sum,
    );

    // Cek apakah ada item yang terpilih
    final bool anyItemSelected = cartItems.any((item) => item.isSelected);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Keranjang Saya"),
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Text(
                'Keranjang Anda kosong.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : Column(
              children: [
                // Checkbox "Pilih Semua"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _selectAll,
                        onChanged: (cartItems.isEmpty)
                            ? null
                            : (bool? newValue) {
                                // Nonaktifkan jika keranjang kosong
                                setState(() {
                                  _selectAll = newValue ?? false;
                                });
                                sepatuProvider
                                    .toggleAllCartItemsSelection(_selectAll);
                              },
                      ),
                      const Text('Pilih Semua'),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Checkbox untuk setiap item
                              Checkbox(
                                value: item.isSelected,
                                onChanged: (bool? newValue) {
                                  sepatuProvider.toggleCartItemSelection(item);
                                  // Perbarui status _selectAll jika ada perubahan pada item individual
                                  setState(() {
                                    _selectAll = sepatuProvider.cart.every(
                                        (cartItem) => cartItem.isSelected);
                                  });
                                },
                              ),
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: item.sepatu.gambarPath != null &&
                                          item.sepatu.gambarPath!.isNotEmpty
                                      ? Image.asset(
                                          item.sepatu.gambarPath!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.broken_image,
                                              size: 40,
                                              color: Colors.red,
                                            );
                                          },
                                        )
                                      : Icon(
                                          Icons.image,
                                          size: 40,
                                          color: Colors.grey[400],
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.sepatu.nama,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      item.sepatu.brand,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      currencyFormatter.format(
                                        int.tryParse(item.sepatu.harga) ?? 0,
                                      ),
                                      style: const TextStyle(
                                        color: Colors.deepOrange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                              Icons.remove_circle_outline),
                                          onPressed: () {
                                            sepatuProvider
                                                .updateCartItemQuantity(
                                                    item, item.quantity - 1);
                                          },
                                        ),
                                        Text('${item.quantity}'),
                                        IconButton(
                                          icon: const Icon(
                                              Icons.add_circle_outline),
                                          onPressed: () {
                                            if ((int.tryParse(
                                                        item.sepatu.jumlah) ??
                                                    0) >
                                                item.quantity) {
                                              sepatuProvider
                                                  .updateCartItemQuantity(
                                                      item, item.quantity + 1);
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'Stok tidak cukup.')),
                                              );
                                            }
                                          },
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () {
                                            sepatuProvider.removeFromCart(item);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      '${item.sepatu.nama} dihapus dari keranjang.')),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Harga:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            currencyFormatter.format(totalHarga),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              anyItemSelected // Tombol hanya aktif jika ada item terpilih
                                  ? () {
                                      _showConfirmPurchaseDialog(
                                          context, cartItems);
                                    }
                                  : null, // Nonaktifkan tombol jika tidak ada item terpilih
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Checkout",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _showConfirmPurchaseDialog(BuildContext context, List<CartItem> items) {
    final _formKey = GlobalKey<FormState>();
    final namaController = TextEditingController();
    final alamatController = TextEditingController();

    // Filter item yang terpilih untuk ditampilkan di dialog konfirmasi
    final selectedItemsForDialog =
        items.where((item) => item.isSelected).toList();

    if (selectedItemsForDialog.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Pilih setidaknya satu item untuk checkout.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Pembelian'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tampilkan daftar item yang akan dibeli
                  ...selectedItemsForDialog
                      .map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child:
                                Text('${item.sepatu.nama} x ${item.quantity}'),
                          ))
                      .toList(),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: namaController,
                    decoration:
                        const InputDecoration(labelText: 'Nama Lengkap'),
                    validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: alamatController,
                    decoration:
                        const InputDecoration(labelText: 'Alamat Pengiriman'),
                    maxLines: 3,
                    validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Provider.of<SepatuProvider>(dialogContext, listen: false)
                      .confirmPurchase(
                          items, // Kirim semua item, provider akan memfilter yang terpilih
                          namaController.text,
                          alamatController.text);
                  Navigator.pop(dialogContext); // Close the dialog
                  Navigator.pop(context); // Go back to ShopPage
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Pembelian berhasil dikonfirmasi!')),
                  );
                }
              },
              child: const Text('Konfirmasi'),
            ),
          ],
        );
      },
    );
  }
}

// =============================================================================
// HALAMAN RIWAYAT PEMBELIAN (RiwayatBeliPage)
// =============================================================================

class RiwayatBeliPage extends StatelessWidget {
  const RiwayatBeliPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sepatuProvider = Provider.of<SepatuProvider>(context);
    final riwayatBeli = sepatuProvider.riwayatBeli;

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    final dateFormatter =
        DateFormat('dd MMM yyyy, HH:mm'); // Format lebih lengkap

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Riwayat Pembelian",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0, // Hapus shadow AppBar
      ),
      body: riwayatBeli.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Belum ada riwayat pembelian.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const Text(
                    'Mulai belanja sekarang!',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navigasi kembali ke ShopPage atau halaman utama belanja
                      Navigator.popUntil(
                          context, (route) => route.isFirst); // Kembali ke root
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const ShopPage())); // Atau langsung ke ShopPage
                    },
                    icon: const Icon(Icons.store),
                    label: const Text('Belanja Sekarang'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12.0), // Padding lebih besar
              itemCount: riwayatBeli.length,
              itemBuilder: (context, index) {
                final pembelian = riwayatBeli[index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 6, // Shadow lebih jelas
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15), // Sudut lebih membulat
                  ),
                  clipBehavior: Clip.antiAlias, // Penting untuk gambar
                  child: Padding(
                    padding: const EdgeInsets.all(
                        16.0), // Padding internal lebih besar
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Gambar Produk
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: pembelian.gambarPath != null &&
                                        pembelian.gambarPath!.isNotEmpty
                                    ? Image.asset(
                                        pembelian.gambarPath!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(
                                            Icons.broken_image,
                                            size: 50,
                                            color: Colors.red.shade300,
                                          );
                                        },
                                      )
                                    : Icon(
                                        Icons.image_not_supported,
                                        size: 50,
                                        color: Colors.grey[400],
                                      ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Detail Produk
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pembelian.namaSepatu,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    pembelian.brandSepatu,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    currencyFormatter.format(
                                      int.tryParse(pembelian.hargaSepatu) ?? 0,
                                    ),
                                    style: const TextStyle(
                                      color: Colors.deepOrange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(
                            height: 24,
                            thickness: 1), // Divider yang lebih baik

                        // Status Pembelian (Badge)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: pembelian.isConfirmed
                                  ? Colors.green.shade100
                                  : Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              pembelian.isConfirmed
                                  ? 'Dikonfirmasi'
                                  : 'Menunggu Konfirmasi',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: pembelian.isConfirmed
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Detail Pembeli (jika sudah dikonfirmasi)
                        if (pembelian.isConfirmed) ...[
                          const Text(
                            'Detail Pengiriman:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.person_outline,
                                  size: 18, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  pembelian.pembeliNama ?? 'N/A',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 18, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  pembelian.alamatKirim ?? 'N/A',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Waktu Pembelian
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                size: 16, color: Colors.grey[500]),
                            const SizedBox(width: 8),
                            Text(
                              'Waktu Beli: ${dateFormatter.format(DateTime.parse(pembelian.waktuPembelian))}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Tombol Aksi
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (!pembelian.isConfirmed)
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    _showConfirmDialog(
                                        context, index, pembelian);
                                  },
                                  icon: const Icon(Icons.check_circle_outline),
                                  label: const Text('Konfirmasi'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                  ),
                                ),
                              ),
                            if (!pembelian.isConfirmed)
                              const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  _showCancelConfirmationDialog(context, index);
                                },
                                icon: const Icon(Icons.cancel_outlined),
                                label: const Text('Batalkan'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showConfirmDialog(
      BuildContext context, int index, Pembelian pembelian) {
    final _formKey = GlobalKey<FormState>();
    final namaController = TextEditingController(text: pembelian.pembeliNama);
    final alamatController = TextEditingController(text: pembelian.alamatKirim);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Pembelian'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: namaController,
                    decoration: const InputDecoration(
                        labelText: 'Nama Lengkap Pembeli',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person)),
                    validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: alamatController,
                    decoration: const InputDecoration(
                        labelText: 'Alamat Pengiriman',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on)),
                    maxLines: 3,
                    validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Provider.of<SepatuProvider>(dialogContext, listen: false)
                      .updatePurchaseStatus(pembelian, true,
                          namaController.text, alamatController.text);
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Pembelian berhasil dikonfirmasi!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Konfirmasi'),
            ),
          ],
        );
      },
    );
  }

  void _showCancelConfirmationDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Batalkan Pembelian?'),
          content: const Text(
              'Apakah Anda yakin ingin membatalkan pembelian ini? Stok akan dikembalikan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Tidak'),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<SepatuProvider>(dialogContext, listen: false)
                    .cancelPurchase(index);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Pembelian berhasil dibatalkan.')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ya, Batalkan'),
            ),
          ],
        );
      },
    );
  }
}

// Add this extension for firstWhereOrNull if not already available
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}

// =============================================================================
// HALAMAN FAVORIT (FavoritePage) - BARU
// =============================================================================
class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    final sepatuProvider = Provider.of<SepatuProvider>(context);
    final favoriteItems = sepatuProvider.favoriteSepatu;

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Favorit'),
      ),
      body: favoriteItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Belum ada sepatu di daftar favorit Anda.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const Text(
                    'Tambahkan sepatu yang Anda suka!',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: favoriteItems.length,
              itemBuilder: (context, index) {
                final sepatu = favoriteItems[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[100],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: sepatu.gambarPath != null &&
                                sepatu.gambarPath!.isNotEmpty
                            ? Image.asset(
                                sepatu.gambarPath!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.broken_image,
                                      size: 40, color: Colors.red);
                                },
                              )
                            : Icon(Icons.image,
                                size: 40, color: Colors.grey[400]),
                      ),
                    ),
                    title: Text(
                      sepatu.nama,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(sepatu.brand),
                        Text(
                          currencyFormatter
                              .format(int.tryParse(sepatu.harga) ?? 0),
                          style: const TextStyle(
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () {
                        sepatuProvider.toggleFavorite(sepatu);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('${sepatu.nama} dihapus dari favorit.')),
                        );
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DetailPage(sepatu: sepatu)),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

// =============================================================================
// HALAMAN PROFIL SAYA (MyProfilePage) - Dengan Navigasi Favorit
// =============================================================================
class MyProfilePage extends StatelessWidget {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contoh Informasi Pengguna (bisa diperluas)
            const Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.person, size: 80, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Informasi Akun',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: const Text('member@example.com'), // Placeholder
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Telepon'),
              subtitle: const Text('+62 812-3456-7890'), // Placeholder
            ),
            const SizedBox(height: 32),
            // Navigasi ke Riwayat Pembelian
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: const Icon(Icons.history, color: Colors.blueGrey),
                title: const Text('Riwayat Pembelian',
                    style: TextStyle(fontSize: 16)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RiwayatBeliPage()),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Navigasi ke Daftar Favorit (BARU)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: const Icon(Icons.favorite, color: Colors.redAccent),
                title: const Text('Daftar Favorit',
                    style: TextStyle(fontSize: 16)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FavoritePage()),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Tombol Logout
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
