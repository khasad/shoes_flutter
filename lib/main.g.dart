// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PembelianAdapterGenerated extends TypeAdapter<Pembelian> {
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
      other is PembelianAdapterGenerated &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CartItemAdapterGenerated extends TypeAdapter<CartItem> {
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
    );
  }

  @override
  void write(BinaryWriter writer, CartItem obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.sepatu)
      ..writeByte(1)
      ..write(obj.quantity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItemAdapterGenerated &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
