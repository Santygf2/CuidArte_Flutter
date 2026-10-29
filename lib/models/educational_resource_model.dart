import '../core/network/api_client.dart';

class EducationalResourceModel {
  final String id;
  final String title;
  final String category;
  final String fileType;
  final String readTime;
  final String summary;
  final String author;
  final String downloadUrl;
  final int downloadsCount;
  final String content;
  final String imageUrl;
  final DateTime? createdAt;

  EducationalResourceModel({
    required this.id,
    required this.title,
    required this.category,
    required this.fileType,
    required this.readTime,
    required this.summary,
    required this.author,
    required this.downloadUrl,
    this.downloadsCount = 0,
    this.content = '',
    this.imageUrl = '',
    this.createdAt,
  });

  factory EducationalResourceModel.fromJson(Map<String, dynamic> json) {
    return EducationalResourceModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      fileType: (json['file_type'] ?? 'Guía').toString(),
      readTime: (json['read_time'] ?? '5 min').toString(),
      summary: (json['summary'] ?? '').toString(),
      author: (json['author'] ?? 'Equipo CuidArte').toString(),
      downloadUrl: ApiClient.resolveUrl(
        (json['download_url'] ?? '').toString(),
      ),
      downloadsCount: (json['downloads_count'] as num?)?.toInt() ?? 0,
      content: (json['content'] ?? '').toString(),
      imageUrl: ApiClient.resolveUrl((json['image_url'] ?? '').toString()),
      createdAt: DateTime.tryParse(
        (json['fecha_creacion'] ?? '').toString(),
      ),
    );
  }
}
