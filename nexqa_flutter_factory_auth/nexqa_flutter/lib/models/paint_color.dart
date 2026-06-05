import 'dart:convert';
import 'dart:typed_data';

class PaintColor {
  final String id;
  final Uint8List? imageBytes;
  final String hexCode;
  final int r;
  final int g;
  final int b;
  final String colorName;
  final String recipeMarkdown;
  final DateTime createdAt;

  const PaintColor({
    required this.id,
    this.imageBytes,
    required this.hexCode,
    required this.r,
    required this.g,
    required this.b,
    required this.colorName,
    required this.recipeMarkdown,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'imageBytes': imageBytes != null ? base64Encode(imageBytes!) : null,
        'hexCode': hexCode,
        'r': r,
        'g': g,
        'b': b,
        'colorName': colorName,
        'recipeMarkdown': recipeMarkdown,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PaintColor.fromJson(Map<String, dynamic> json) => PaintColor(
        id: json['id'],
        imageBytes: json['imageBytes'] != null
            ? base64Decode(json['imageBytes'])
            : null,
        hexCode: json['hexCode'],
        r: json['r'],
        g: json['g'],
        b: json['b'],
        colorName: json['colorName'],
        recipeMarkdown: json['recipeMarkdown'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}
