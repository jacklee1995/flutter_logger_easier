import 'dart:io' show File;
import 'dart:convert' show utf8, base64;
import 'dart:typed_data' show Uint8List;
import 'package:crypto/crypto.dart' show Hmac, sha256;
import 'package:encrypt/encrypt.dart';

/// 日志加密器，用于加密和解密日志文件
class LogEncryptor {
  final Key _key;
  final IV _iv;
  late final Encrypter _encrypter;

  /// 构造函数
  ///
  /// [key] 必须是32字节的密钥字符串
  LogEncryptor(String key)
      : _key = Key(utf8.encode(key.padRight(32, '0')).sublist(0, 32)),
        _iv = IV.fromLength(16) {
    _encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
  }

  /// 加密日志文件
  ///
  /// [source] 源文件
  /// [target] 目标文件
  Future<void> encrypt(File source, File target) async {
    try {
      final content = await source.readAsString();
      final encrypted = _encryptContent(content);
      await target.writeAsString(encrypted);
    } catch (e) {
      throw EncryptionException('Failed to encrypt file: $e');
    }
  }

  /// 解密日志文件
  ///
  /// [source] 源文件
  /// [target] 目标文件
  Future<void> decrypt(File source, File target) async {
    try {
      final content = await source.readAsString();
      final decrypted = _decryptContent(content);
      await target.writeAsString(decrypted);
    } catch (e) {
      throw EncryptionException('Failed to decrypt file: $e');
    }
  }

  /// 加密内容
  String _encryptContent(String content) {
    try {
      final encrypted = _encrypter.encrypt(content, iv: _iv);
      return base64
          .encode(_combineIvAndEncryptedData(_iv.bytes, encrypted.bytes));
    } catch (e) {
      throw EncryptionException('Encryption failed: $e');
    }
  }

  /// 解密内容
  String _decryptContent(String content) {
    try {
      final combined = base64.decode(content);
      final (iv, encryptedData) = _separateIvAndEncryptedData(combined);
      final ivObj = IV(iv);
      final encrypted = Encrypted(encryptedData);
      return _encrypter.decrypt(encrypted, iv: ivObj);
    } catch (e) {
      throw EncryptionException('Decryption failed: $e');
    }
  }

  /// 合并IV和加密数据
  Uint8List _combineIvAndEncryptedData(
    Uint8List iv,
    Uint8List encryptedData,
  ) {
    final combined = Uint8List(iv.length + encryptedData.length);
    combined.setAll(0, iv);
    combined.setAll(iv.length, encryptedData);
    return combined;
  }

  /// 分离IV和加密数据
  (Uint8List, Uint8List) _separateIvAndEncryptedData(Uint8List combined) {
    final iv = combined.sublist(0, 16);
    final encryptedData = combined.sublist(16);
    return (iv, encryptedData);
  }
}

/// 加密异常
class EncryptionException implements Exception {
  final String message;
  EncryptionException(this.message);

  @override
  String toString() => 'EncryptionException: $message';
}
