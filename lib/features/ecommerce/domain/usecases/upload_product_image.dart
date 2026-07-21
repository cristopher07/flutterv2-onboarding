import 'dart:typed_data';

import '../repositories/ecommerce_repository.dart';

class UploadProductImage {
  const UploadProductImage({required this.repository});

  final EcommerceRepository repository;

  Future<String> call({
    required String productId,
    required Uint8List bytes,
    required String fileName,
    String? contentType,
  }) {
    return repository.uploadProductImage(
      productId: productId,
      bytes: bytes,
      fileName: fileName,
      contentType: contentType,
    );
  }
}
