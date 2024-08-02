import 'package:encrypt/encrypt.dart' as encrypt;

class MyEnDe {

  static String en(String data) {
    final key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');
    // Custom IV - Must be 16 bytes (128 bits) for AES
    final iv = encrypt.IV.fromUtf8('1234567890123456');
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    if (data.isNotEmpty) {
      final encryptedData = encrypter.encrypt(data, iv: iv);
      return encryptedData.base64;
    } else {
      // Handle empty data case
      return '';
    }
  }

  static String de(String data) {
    final key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');
    // Custom IV - Must be 16 bytes (128 bits) for AES
    final iv = encrypt.IV.fromUtf8('1234567890123456');
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    if (data.isNotEmpty) {
      final encrypted = encrypt.Encrypted.fromBase64(data);
      final decryptedData = encrypter.decrypt(encrypted, iv: iv);
      return decryptedData;
    } else {
      // Handle empty data case
      return '';
    }
  }



  // Fernet Algorithm ye real time me hash key different-different change hota hai
  static final keyFernet = encrypt.Key.fromUtf8('cdaccdaccdaccdaccdaccdaccdaccdac'); // 32bit character
  static final fernet = encrypt.Fernet(keyFernet);
  static final encrypterFernet = encrypt.Encrypter(fernet);

  static enFernet(String data){
    final encrypted = encrypterFernet.encrypt(data);
    return encrypted;
  }
  static deFernet(String data){
    return encrypterFernet.decrypt(data as encrypt.Encrypted);
  }

}