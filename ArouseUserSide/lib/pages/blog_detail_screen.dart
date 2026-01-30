import 'dart:typed_data';
import 'package:arouse_ecommerce_frontend/common_widgets/C_AppBar.dart';
import 'package:flutter/material.dart';

class BlogDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> blog;

  const BlogDetailsScreen({super.key, required this.blog});

  // Extract image bytes from MongoDB Buffer
  Uint8List? getImageBytes(Map<String, dynamic> blog) {
    try {
      if (blog["image"] != null &&
          blog["image"]["data"] != null &&
          blog["image"]["data"]["data"] != null) {
        List<int> bytes = List<int>.from(blog["image"]["data"]["data"]);
        return Uint8List.fromList(bytes);
      }
    } catch (e) {
      print("Failed to parse image: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final imageBytes = getImageBytes(blog);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CAppbar(screenName: blog['excerpt']),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER IMAGE
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  child: imageBytes != null
                      ? Image.memory(
                          imageBytes,
                          width: double.infinity,
                          height: screenWidth > 600 ? 350 : 250,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          "assets/placeholder.png",
                          width: double.infinity,
                          height: screenWidth > 600 ? 350 : 250,
                          fit: BoxFit.cover,
                        ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      blog['tag'] ?? 'Car Blog',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // TITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                blog['title'] ?? 'Blog Title',
                style: TextStyle(
                  fontSize: screenWidth > 600 ? 28 : 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'DMSans',
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // AUTHOR & DATE ROW
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey.shade300,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    blog['author'] ?? 'Admin',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.circle, size: 6, color: Colors.grey.shade400),
                  const SizedBox(width: 12),
                  Text(
                    formatDate(blog['updatedAt']),
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // BLOG CONTENT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                blog['content'] ?? '',
                style: TextStyle(
                  fontSize: screenWidth > 600 ? 18 : 16,
                  height: 1.6,
                  color: Colors.black87,
                  fontFamily: 'DMSans',
                ),
              ),
            ),
            const SizedBox(height: 20),

            // READ MORE / RELATED TAGS (Optional)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8,
                children: [
                  Chip(
                    label: Text(blog['tag'] ?? 'Car'),
                    backgroundColor: Colors.blue.shade50,
                  ),
                  Chip(
                    label: Text(blog['title'] ?? 'title'),
                    backgroundColor: Colors.blue,
                  ),
                  Chip(
                    label: Text(blog['slug'] ?? "slug"),
                    backgroundColor: Colors.blue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Simple date formatting
  String formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    return "${date.day}-${date.month}-${date.year}";
  }
}
