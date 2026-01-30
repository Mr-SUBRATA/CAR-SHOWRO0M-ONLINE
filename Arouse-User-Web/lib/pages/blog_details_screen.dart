import 'dart:typed_data';

import 'package:arouse_ecommerce_frontend_web/common_widgets/C_AppBar.dart';
import 'package:flutter/material.dart';

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

class BlogDetailsScreen extends StatelessWidget {
  final List allBlogs;
  final Map<String, dynamic> blog;

  const BlogDetailsScreen({
    super.key,
    required this.allBlogs,
    required this.blog,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 1100;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: CAppbar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 80 : 16,
            vertical: 24,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// LEFT - MAIN BLOG
              Expanded(flex: 3, child: _BlogContent(blog: blog)),

              if (isDesktop) const SizedBox(width: 30),

              /// RIGHT - SIDEBAR (DESKTOP ONLY)
              if (isDesktop)
                Expanded(
                  flex: 1,
                  child: _BlogSidebar(blog: blog, allBlogs: allBlogs),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlogContent extends StatelessWidget {
  final Map<String, dynamic> blog;

  const _BlogContent({required this.blog});

  @override
  Widget build(BuildContext context) {
    final imageBytes = getImageBytes(blog);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// HERO IMAGE
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: imageBytes != null
              ? Image.memory(
                  imageBytes,
                  height: 320,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : Icon(Icons.image_not_supported_rounded),
        ),

        const SizedBox(height: 20),

        /// TITLE
        Text(
          blog['title'] ?? '',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.3,
          ),
        ),

        const SizedBox(height: 10),

        /// META INFO
        Row(
          children: [
            const Icon(Icons.person, size: 16, color: Colors.grey),
            const SizedBox(width: 6),
            Text(blog['author'] ?? 'Admin'),
          ],
        ),

        const SizedBox(height: 20),

        /// EXCERPT
        Text(
          blog['excerpt'] ?? '',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            height: 1.6,
          ),
        ),

        const SizedBox(height: 16),

        /// CONTENT
        Text(
          blog['content'] ?? '',
          style: const TextStyle(fontSize: 16, height: 1.7),
        ),

        const SizedBox(height: 24),

        /// TAG
        if (blog['tag'] != null)
          Wrap(spacing: 8, children: [_TagChip(blog['tag'])]),

        const SizedBox(height: 40),
      ],
    );
  }
}

class _BlogSidebar extends StatelessWidget {
  final List allBlogs;
  final Map<String, dynamic> blog;

  const _BlogSidebar({required this.allBlogs, required this.blog});

  @override
  Widget build(BuildContext context) {
    final relatedBlogs = allBlogs
        .where((b) => b['tag'] == blog['tag'] && b['slug'] != blog['slug'])
        .take(3)
        .toList();

    if (relatedBlogs.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Related Blogs",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),

        ...relatedBlogs.map(
          (b) => _RelatedBlogCard(blog: b, allBlogs: allBlogs),
        ),
      ],
    );
  }
}

class _RelatedBlogCard extends StatelessWidget {
  final List allBlogs;

  final Map<String, dynamic> blog;

  const _RelatedBlogCard({required this.blog, required this.allBlogs});

  @override
  Widget build(BuildContext context) {
    final imageBytes = getImageBytes(blog);

    return InkWell(
      onTap: () {
        // Navigate to BlogDetailsScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                BlogDetailsScreen(allBlogs: allBlogs, blog: blog),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            /// IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageBytes != null
                  ? Image.memory(
                      imageBytes,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    )
                  : Icon(Icons.image_not_supported, size: 60),
            ),

            const SizedBox(width: 10),

            /// TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    blog['title'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    blog['excerpt'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label), backgroundColor: const Color(0xFFEFF3FF));
  }
}
