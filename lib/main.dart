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
  Hive.registerAdapter(CartItemAdapter()); // Register new adapter

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

class SepatuProvider extends ChangeNotifier {
  late Box<Sepatu> _sepatuBox;
  late Box<Pembelian> _pembelianBox;
  late Box<CartItem> _cartBox; // New box for cart items

  List<Sepatu> get dataSepatu =>
      _sepatuBox.values.where((s) => !s.isDeleted).toList();

  List<Sepatu> get allSepatu => _sepatuBox.values.toList();

  List<Pembelian> get riwayatBeli => _pembelianBox.values.toList();

  List<CartItem> get cart => _cartBox.values.toList();

  SepatuProvider() {
    _initBoxes();
  }

  Future<void> _initBoxes() async {
    _sepatuBox = await Hive.openBox<Sepatu>('sepatuBox');
    _pembelianBox = await Hive.openBox<Pembelian>('pembelianBox');
    _cartBox = await Hive.openBox<CartItem>('cartBox'); // Open cart box

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
        scaffoldBackgroundColor: const Color.fromARGB(255, 245, 245, 255),
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

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void login(BuildContext context) {
    String user = usernameController.text;
    String pass = passwordController.text;

    if (user == "admin" && pass == "admin123") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainPage()),
      );
    } else if (user == "member" && pass == "member123") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ShopPage()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login gagal. Coba lagi!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;

    return Scaffold(
      body: isSmallScreen
          ? SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Halo!\nSelamat datang di ShoeSpeed 👋",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Selamat Datang!",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: usernameController,
                            decoration: InputDecoration(
                              labelText: "Username",
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Colors.blue, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Password",
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Colors.blue, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => login(context),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                              backgroundColor: const Color.fromARGB(
                                255,
                                0,
                                191,
                                255,
                              ),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Login",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: const AssetImage("assets/images/images.png"),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.45),
                            BlendMode.darken,
                          ),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 10.0,
                            offset: Offset(0, 5),
                          ),
                        ],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.zero,
                          bottomLeft: Radius.zero,
                          topRight:
                              Radius.circular(20.0), // Keep right side rounded
                          bottomRight:
                              Radius.circular(20.0), // Keep right side rounded
                        ),
                      ),
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            "Halo!\nSelamat datang di ShoeSpeed 👋\n\nLogin untuk melanjutkan.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Container(
                      width: 350,
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Selamat Datang!",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: usernameController,
                            decoration: InputDecoration(
                              labelText: "Username",
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Colors.blue, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Password",
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Colors.blue, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => login(context),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                              backgroundColor: const Color.fromARGB(
                                255,
                                0,
                                191,
                                255,
                              ),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Login",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedPage = 0;
  bool sidebarOpen = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setSidebarOpenBasedOnOnWidth();
  }

  void _setSidebarOpenBasedOnOnWidth() {
    final screenWidth = MediaQuery.of(context).size.width;
    setState(() {
      sidebarOpen = screenWidth > 700;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 700;
    final List<Widget> pages = [
      const StokInPage(),
      const LihatDataPage(),
    ];

    return Scaffold(
      appBar: !isLargeScreen
          ? AppBar(
              title: const Text('ShoesSpeed - Admin'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginPage()),
                    );
                  },
                  child: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            )
          : null,
      drawer: !isLargeScreen
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  const DrawerHeader(
                    decoration: BoxDecoration(color: Colors.indigo),
                    child: Text(
                      'Admin Menu',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.add_box),
                    title: const Text('Tambah Data Sepatu'),
                    selected: selectedPage == 0,
                    onTap: () {
                      setState(() => selectedPage = 0);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.view_list),
                    title: const Text('Lihat Data Sepatu'),
                    selected: selectedPage == 1,
                    onTap: () {
                      setState(() => selectedPage = 1);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => LoginPage()),
                      );
                    },
                  ),
                ],
              ),
            )
          : null,
      body: Column(
        children: [
          if (isLargeScreen)
            Container(
              width: double.infinity,
              color: Colors.indigo,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ShoesSpeed - Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => LoginPage()),
                      );
                    },
                    child: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: isLargeScreen
                ? Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: sidebarOpen ? 200 : 60,
                        color: const Color.fromARGB(255, 40, 42, 60),
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            IconButton(
                              icon: Icon(
                                sidebarOpen
                                    ? Icons.arrow_back_ios
                                    : Icons.arrow_forward_ios,
                                color: Colors.white,
                              ),
                              onPressed: () => setState(
                                () => sidebarOpen = !sidebarOpen,
                              ),
                            ),
                            MenuButton(
                              icon: Icons.add_box,
                              title: 'Tambah',
                              selected: selectedPage == 0,
                              sidebarOpen: sidebarOpen,
                              onTap: () => setState(() => selectedPage = 0),
                            ),
                            MenuButton(
                              icon: Icons.view_list,
                              title: 'Data',
                              selected: selectedPage == 1,
                              sidebarOpen: sidebarOpen,
                              onTap: () => setState(() => selectedPage = 1),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: pages[selectedPage],
                      ),
                    ],
                  )
                : pages[selectedPage],
          ),
          Container(
            width: double.infinity,
            color: const Color.fromARGB(255, 200, 220, 255),
            padding: const EdgeInsets.all(8),
            child: const Center(
              child: Text(
                'V1 - Aplikasi CRUD Sepatu',
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;
  final bool sidebarOpen;

  const MenuButton({
    super.key,
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
    required this.sidebarOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.blueAccent : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: sidebarOpen
            ? Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}

class StokInPage extends StatefulWidget {
  const StokInPage({super.key});

  @override
  State<StokInPage> createState() => _StokInPageState();
}

class _StokInPageState extends State<StokInPage> {
  final _formKey = GlobalKey<FormState>();
  final _barcodeController = TextEditingController();
  final _namaController = TextEditingController();
  final _brandController = TextEditingController();
  final _ukuranController = TextEditingController();
  final _jumlahController = TextEditingController();
  final _detailController = TextEditingController();
  final _hargaController = TextEditingController();
  final _gambarPathController = TextEditingController();
  String _selectedKategori = 'Umum'; // Default value for new field

  final List<String> _kategoriOptions = [
    'Umum',
    'Running',
    'Casual',
    'Lifestyle',
    'Basket',
    'Sepak Bola',
  ];

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final sepatu = Sepatu(
        barcode: _barcodeController.text,
        nama: _namaController.text,
        brand: _brandController.text,
        ukuran: _ukuranController.text,
        jumlah: _jumlahController.text,
        detail: _detailController.text,
        waktuInput: DateTime.now().toString(),
        harga: _hargaController.text,
        gambarPath: _gambarPathController.text.isNotEmpty
            ? _gambarPathController.text
            : null,
        kategori: _selectedKategori, // Save new field
      );
      // Panggil method tambahSepatu dari provider
      Provider.of<SepatuProvider>(context, listen: false).tambahSepatu(sepatu);
      _formKey.currentState!.reset();
      _gambarPathController.clear();
      setState(() {
        _selectedKategori = 'Umum'; // Reset category
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data sepatu berhasil ditambahkan!')),
      );
    }
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _namaController.dispose();
    _brandController.dispose();
    _ukuranController.dispose();
    _jumlahController.dispose();
    _detailController.dispose();
    _hargaController.dispose();
    _gambarPathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;

    return Center(
      child: SizedBox(
        width: isSmallScreen ? double.infinity : 600,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: EdgeInsets.all(isSmallScreen ? 16 : 24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  const Text(
                    'TAMBAH DATA SEPATU',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _barcodeController,
                    decoration: const InputDecoration(labelText: 'Barcode'),
                    validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _namaController,
                    decoration: const InputDecoration(labelText: 'Nama'),
                    validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _brandController,
                    decoration: const InputDecoration(labelText: 'Brand'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _ukuranController,
                          decoration: const InputDecoration(
                            labelText: 'Ukuran',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _jumlahController,
                          decoration: const InputDecoration(
                            labelText: 'Jumlah',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if (val!.isEmpty) return 'Wajib diisi';
                            if (int.tryParse(val) == null) return 'Harus angka';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _hargaController,
                    decoration: const InputDecoration(labelText: 'Harga (Rp)'),
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val!.isEmpty) return 'Wajib diisi';
                      if (int.tryParse(val) == null) return 'Harus angka';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedKategori,
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
                      setState(() {
                        _selectedKategori = newValue!;
                      });
                    },
                    validator: (val) => val == null || val.isEmpty
                        ? 'Pilih kategori sepatu'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _detailController,
                    decoration: const InputDecoration(labelText: 'Detail'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _gambarPathController,
                    decoration: const InputDecoration(
                      labelText: 'Path Gambar (e.g., assets/images/sepatu.png)',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          _formKey.currentState!.reset();
                          _gambarPathController.clear();
                          setState(() {
                            _selectedKategori = 'Umum';
                          });
                        },
                        child: const Text('Batal'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Simpan'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
                    decoration: const InputDecoration(labelText: 'Barcode'),
                    validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  TextFormField(
                    controller: namaController,
                    decoration: const InputDecoration(labelText: 'Nama'),
                    validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  TextFormField(
                    controller: brandController,
                    decoration: const InputDecoration(labelText: 'Brand'),
                  ),
                  TextFormField(
                    controller: ukuranController,
                    decoration: const InputDecoration(labelText: 'Ukuran'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: jumlahController,
                    decoration: const InputDecoration(labelText: 'Jumlah'),
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
                    decoration: const InputDecoration(labelText: 'Detail'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: gambarPathController,
                    decoration: const InputDecoration(
                      labelText: 'Path Gambar (e.g., assets/images/sepatu.png)',
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
        title: const Text("Toko ShoeSpeed"),
        actions: [
          // TOMBOL PROFIL SAYA (menggantikan Riwayat Pembelian & Logout)
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
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: const DecorationImage(
                  image: AssetImage(
                      'assets/images/bcshoes.png'), // Ganti dengan path gambar banner Anda
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Diskon Spesial Akhir Tahun!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Search Bar
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari sepatu...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
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
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: DropdownButtonFormField<String>(
              value: _selectedCategoryFilter ??
                  _kategoriOptions[0], // Default to "Semua Kategori"
              decoration: InputDecoration(
                labelText: 'Pilih Kategori',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
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
          // Bagian "Semua Sepatu" (sesuai gambar, tidak ada "Top Sale" terpisah)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Semua Sepatu',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo),
              ),
            ),
          ),
          Expanded(
            child: allShopShoes.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada sepatu tersedia saat ini.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: allShopShoes.length,
                    itemBuilder: (context, index) {
                      final s = allShopShoes[index];
                      final isSoldOut = (int.tryParse(s.jumlah) ?? 0) <= 0;

                      return GestureDetector(
                        onTap: () {
                          // NAVIGASI KE DETAIL PAGE SAAT SEPATU DITEKAN
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailPage(sepatu: s),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 4.0,
                          ),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            // Gunakan Stack untuk menempatkan label SOLD OUT
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: s.gambarPath != null &&
                                                s.gambarPath!.isNotEmpty
                                            ? Image.asset(
                                                s.gambarPath!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) {
                                                  return const Icon(
                                                    Icons.broken_image,
                                                    size: 60,
                                                    color: Colors.red,
                                                  );
                                                },
                                              )
                                            : Icon(
                                                Icons.image,
                                                size: 60,
                                                color: Colors.grey[400],
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
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
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                s.brand,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                currencyFormatter.format(
                                                  int.tryParse(s.harga) ?? 0,
                                                ),
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.deepOrange,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: ElevatedButton(
                                              onPressed: isSoldOut
                                                  ? null
                                                  : () {
                                                      sepatuProvider
                                                          .addToCart(s);
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            "${s.nama} ditambahkan ke keranjang!",
                                                          ),
                                                        ),
                                                      );
                                                    },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: isSoldOut
                                                    ? Colors.grey
                                                    : Colors.blueAccent,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                  vertical: 10,
                                                ),
                                              ),
                                              child: Text(isSoldOut
                                                  ? "Stok Habis"
                                                  : "Tambah ke Keranjang"),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSoldOut) // Label "SOLD OUT" jika stok 0
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'SOLD OUT',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2,
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
            const Icon(Icons.shopping_cart, color: Colors.white),
            if (sepatuProvider.cart.isNotEmpty)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '${sepatuProvider.cart.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
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
class DetailPage extends StatelessWidget {
  final Sepatu sepatu;
  const DetailPage({super.key, required this.sepatu});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    final sepatuProvider = Provider.of<SepatuProvider>(context, listen: false);
    final isSoldOut = (int.tryParse(sepatu.jumlah) ?? 0) <= 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(sepatu.nama),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Fungsi Share belum diimplementasikan')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons
                .favorite_border), // Atau Icons.favorite jika sudah difavoritkan
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Fungsi Favorit belum diimplementasikan')),
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
                // Menggunakan Row untuk menempatkan gambar dan nama berdampingan
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align items to the top
                children: [
                  // Gambar Produk (di kiri)
                  Container(
                    width: 150, // Lebar tetap untuk gambar
                    // height: 150, // Hapus atau sesuaikan jika ingin tinggi tetap
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
                          sepatu.gambarPath != null &&
                                  sepatu.gambarPath!.isNotEmpty
                              ? Image.asset(
                                  sepatu.gambarPath!,
                                  fit: BoxFit
                                      .contain, // Sesuaikan agar gambar pas di dalam box
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
                                      fontSize:
                                          20, // Ukuran font lebih kecil agar muat
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
                  const SizedBox(width: 16), // Jarak antara gambar dan teks
                  // Nama Sepatu (di sebelah kanan gambar)
                  Expanded(
                    // Menggunakan Expanded agar teks tidak overflow
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sepatu.nama,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2, // Batasi jumlah baris
                          overflow: TextOverflow
                              .ellipsis, // Tambahkan ellipsis jika teks terlalu panjang
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sepatu.brand,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currencyFormatter
                              .format(int.tryParse(sepatu.harga) ?? 0),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 18),
                            const Text(' 4.9 (1.2k Rating)'),
                            const SizedBox(width: 16),
                            Text(
                                'Terjual ${100 - (int.tryParse(sepatu.jumlah) ?? 0)}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 24), // Divider setelah bagian gambar dan nama

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
                    runSpacing: 8.0, // Jarak antar baris chip
                    children: [
                      Chip(
                        label: Text('Ukuran: ${sepatu.ukuran}'),
                        backgroundColor: Colors.blue.shade100,
                        labelStyle: const TextStyle(color: Colors.blue),
                      ),
                      Chip(
                        label: Text('Stok: ${sepatu.jumlah}'),
                        backgroundColor: Colors.green.shade100,
                        labelStyle: const TextStyle(color: Colors.green),
                      ),
                      Chip(
                        label: Text('Kategori: ${sepatu.kategori}'),
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
                    sepatu.detail,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Barcode: ${sepatu.barcode}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    'Waktu Input: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(sepatu.waktuInput))}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),

            // Bagian Ulasan (Placeholder)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ulasan Pembeli',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Belum ada ulasan untuk produk ini.',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(
                height:
                    16), // Tambahkan sedikit padding di bagian bawah sebelum bottom bar
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
                        sepatuProvider.addToCart(sepatu);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "${sepatu.nama} ditambahkan ke keranjang!"),
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
                        sepatuProvider.addToCart(sepatu);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CartPage()),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "${sepatu.nama} ditambahkan ke keranjang dan siap checkout!"),
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
    final dateFormatter = DateFormat('dd MMM, HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Pembelian")),
      body: riwayatBeli.isEmpty
          ? const Center(
              child: Text(
                'Belum ada riwayat pembelian.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: riwayatBeli.length,
              itemBuilder: (context, index) {
                final pembelian = riwayatBeli[index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: pembelian.gambarPath != null &&
                              pembelian.gambarPath!.isNotEmpty
                          ? Image.asset(
                              pembelian.gambarPath!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.broken_image,
                                  size: 60,
                                  color: Colors.red,
                                );
                              },
                            )
                          : Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.shopping_bag,
                                size: 30,
                                color: Colors.grey[400],
                              ),
                            ),
                      title: Text(
                        pembelian.namaSepatu,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Brand: ${pembelian.brandSepatu}"),
                          Text(
                            currencyFormatter.format(
                              int.tryParse(pembelian.hargaSepatu) ?? 0,
                            ),
                            style: const TextStyle(
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Status: ${pembelian.isConfirmed ? 'Dikonfirmasi' : 'Menunggu Konfirmasi'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: pembelian.isConfirmed
                                  ? Colors.green
                                  : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (pembelian.isConfirmed &&
                              pembelian.pembeliNama != null)
                            Text('Pembeli: ${pembelian.pembeliNama}'),
                          if (pembelian.isConfirmed &&
                              pembelian.alamatKirim != null)
                            Text(
                              'Alamat: ${pembelian.alamatKirim}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          Text(
                            'Waktu Beli: ${dateFormatter.format(DateTime.parse(pembelian.waktuPembelian))}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!pembelian.isConfirmed)
                            ElevatedButton(
                              onPressed: () {
                                _showConfirmDialog(context, index, pembelian);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                              ),
                              child: const Text('Konfirmasi'),
                            ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              sepatuProvider.cancelPurchase(index);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Pembelian dibatalkan.')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                            ),
                            child: const Text('Batalkan'),
                          ),
                        ],
                      ),
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
                        labelText: 'Nama Lengkap Pembeli'),
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
                      .updatePurchaseStatus(pembelian, true,
                          namaController.text, alamatController.text);
                  Navigator.pop(dialogContext);
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
// HALAMAN PROFIL SAYA (MyProfilePage) - BARU
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
