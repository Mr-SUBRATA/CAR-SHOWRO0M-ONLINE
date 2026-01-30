import 'dart:typed_data';
import 'package:arouse_ecommerce_frontend_web/constants/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_AppBar.dart';
import 'blog_details_screen.dart';

class AllBlogsScreen extends StatefulWidget {
  final List allBlogs;

  const AllBlogsScreen({super.key, required this.allBlogs});

  @override
  State<AllBlogsScreen> createState() => _AllBlogsScreenState();
}

class _AllBlogsScreenState extends State<AllBlogsScreen> {
  String searchText = "";
  String? selectedTag;

  List<String> get getAllTags {
    final tags = widget.allBlogs
        .map((e) => e["tag"])
        .where((e) => e != null && e.toString().trim().isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    return tags;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isDesktop = width > 1100;
    final isTablet = width > 700 && width <= 1100;

    // Default → mobile = 2
    int gridCount = 2;

    if (isDesktop) {
      gridCount = 3;
    } else if (isTablet) {
      gridCount = 2;
    }

    // Filter + search blogs
    final filteredBlogs = widget.allBlogs.where((b) {
      final title = (b['title'] ?? '').toString().toLowerCase();
      final tag = (b['tag'] ?? '').toString().toLowerCase();

      final matchesSearch = title.contains(searchText.toLowerCase());
      final matchesTag =
          selectedTag == null || selectedTag!.toLowerCase() == tag;

      return matchesSearch && matchesTag;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: CAppbar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 80 : 16,
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// PAGE TITLE
              Text(
                "Our Blogs",
                style: TextStyle(
                  fontSize: isDesktop ? 34 : 26,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 20),

              /// SEARCH + TAG FILTER BAR
              Row(
                children: [
                  /// SEARCH BOX
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search blog...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (v) => setState(() => searchText = v),
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// TAG DROPDOWN
                  if (getAllTags.isNotEmpty)
                    DropdownButton<String>(
                      hint: const Text("Filter by tag"),
                      value: selectedTag,
                      items: getAllTags
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => selectedTag = v),
                    ),
                ],
              ),

              const SizedBox(height: 20),

              /// BLOG GRID
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredBlogs.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridCount, // 2 mobile, 3 desktop
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,

                  // 👇 fixed card height (controls empty space)
                  mainAxisExtent: isDesktop ? 340 : 300,
                ),
                itemBuilder: (context, index) {
                  final blog = filteredBlogs[index];
                  return BlogCard(blog: blog, allBlogs: widget.allBlogs);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Uint8List? getImageBytes(Map<String, dynamic> blog) {
  try {
    if (blog["image"] != null &&
        blog["image"]["data"] != null &&
        blog["image"]["data"]["data"] != null) {
      List<int> bytes = List<int>.from(blog["image"]["data"]["data"]);
      return Uint8List.fromList(bytes);
    }
  } catch (e) {}
  return null;
}

class BlogCard extends StatelessWidget {
  final Map<String, dynamic> blog;
  final List allBlogs;

  const BlogCard({super.key, required this.blog, required this.allBlogs});

  @override
  Widget build(BuildContext context) {
    final imageBytes = getImageBytes(blog);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlogDetailsScreen(allBlogs: allBlogs, blog: blog),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: imageBytes != null
                  ? Image.memory(
                      imageBytes,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 160,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_not_supported),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TITLE
                  Text(
                    blog["title"] ?? "",
                    maxLines: AppSizes.isDesktop(context) ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// EXCERPT
                  Text(
                    blog["excerpt"] ?? "",
                    maxLines: AppSizes.isDesktop(context) ? 3 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),

                  const SizedBox(height: 10),

                  /// READ MORE
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      "Read More →",
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
