import 'dart:convert';
import 'dart:typed_data';

class Product {
  final String id;
  final String imagePath;
  final Uint8List? imageBytes;
  final String status;
  final double confidence;
  final String defectType;
  final String? defectDescription;
  final String? defectImpact;
  final String buyer;
  final String shippingCompany;
  final DateTime inspectedAt;

  const Product({
    required this.id,
    required this.imagePath,
    this.imageBytes,
    required this.status,
    required this.confidence,
    required this.defectType,
    this.defectDescription,
    this.defectImpact,
    required this.buyer,
    required this.shippingCompany,
    required this.inspectedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'imageBytes': imageBytes != null ? base64Encode(imageBytes!) : null,
        'status': status,
        'confidence': confidence,
        'defectType': defectType,
        'defectDescription': defectDescription,
        'defectImpact': defectImpact,
        'buyer': buyer,
        'shippingCompany': shippingCompany,
        'inspectedAt': inspectedAt.toIso8601String(),
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        imagePath: json['imagePath'],
        imageBytes: json['imageBytes'] != null
            ? base64Decode(json['imageBytes'])
            : null,
        status: json['status'],
        confidence: (json['confidence'] as num).toDouble(),
        defectType: json['defectType'],
        defectDescription: json['defectDescription'],
        defectImpact: json['defectImpact'],
        buyer: json['buyer'],
        shippingCompany: json['shippingCompany'],
        inspectedAt: DateTime.parse(json['inspectedAt']),
      );
}
