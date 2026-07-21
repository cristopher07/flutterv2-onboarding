import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../../../core/http/api_exception.dart';

class ProductImageStorageDatasource {
  const ProductImageStorageDatasource({
    required this.cloudName,
    required this.uploadPreset,
  });

  final String cloudName;
  final String uploadPreset;

  Future<String> uploadProductImage({
    required String productId,
    required Uint8List bytes,
    required String fileName,
    String? contentType,
  }) async {
    if (cloudName.isEmpty || uploadPreset.isEmpty) {
      throw ApiException(
        message:
            'Configura cloudinary_cloud_name y cloudinary_upload_preset en env_dev.json.',
      );
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload'),
    );

    request.fields['upload_preset'] = uploadPreset;
    request.fields['folder'] = 'product-images/$productId';
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
        contentType: null,
      ),
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        message: 'Cloudinary rechazo la imagen: $responseBody',
        statusCode: response.statusCode,
      );
    }

    final responseJson = jsonDecode(responseBody) as Map<String, dynamic>;
    final secureUrl = responseJson['secure_url']?.toString();
    if (secureUrl == null || secureUrl.isEmpty) {
      throw ApiException(message: 'Cloudinary no devolvio secure_url.');
    }

    return secureUrl;
  }
}
