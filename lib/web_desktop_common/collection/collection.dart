import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../component/app_routes/routes.dart';
import '../../component/text_fonts/custom_text.dart';
import 'collection_controller.dart';
import 'collection_modal.dart';

class CollectionGrid extends StatefulWidget {
  final List<CollectionModal> collectionList;

  const CollectionGrid({super.key, required this.collectionList});

  @override
  State<CollectionGrid> createState() => _CollectionGridState();
}

class _CollectionGridState extends State<CollectionGrid> {
  final CollectionViewController controller = Get.put(
    CollectionViewController(),
  );
  final List<bool> _isHovered = [];

  @override
  void initState() {
    super.initState();
    _isHovered.addAll(List<bool>.filled(widget.collectionList.length, false));
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 30,
        childAspectRatio: 2.3,
      ),
      itemCount: widget.collectionList.length,
      itemBuilder: (context, index) {
        final collection = widget.collectionList[index];

        return MouseRegion(
          onEnter: (_) => setState(() => _isHovered[index] = true),
          onExit: (_) => setState(() => _isHovered[index] = false),
          child: Container(
            width: 1600,
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Stack(
              children: [
                // ✅ Only Image is wrapped with AnimatedScale
                Positioned.fill(
                  child: ClipRect(
                    child: AnimatedScale(
                      scale: _isHovered[index] ? 1.1 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Image.network(
                        collection.bannerImg!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                // 🔒 This part stays static
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    width: 282,
                    padding: const EdgeInsets.all(12),
                    color: Colors.white.withOpacity(0.8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CralikaFont(
                          text: collection.name ?? 'Unnamed Collection',
                          fontWeight: FontWeight.w400,
                          fontSize: 20,
                          lineHeight: 36 / 20,
                          letterSpacing: 0.04 * 20,
                          color: Color(0xFF30578E),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${collection.productCount ?? 0} Pieces',
                          style: TextStyle(
                            fontFamily: GoogleFonts.barlow().fontFamily,
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            height: 1.0,
                            letterSpacing: 0.0,
                            color: const Color(0xFF30578E),
                          ),
                        ),
                        const SizedBox(height: 14),
                        BarlowText(
                          text: "VIEW",
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          lineHeight: 1.0,
                          letterSpacing: 0.04 * 16,
                          color: const Color(0xFF30578E),
                          enableHoverBackground: true,
                          hoverBackgroundColor: const Color(0xFF30578E),
                          hoverTextColor: Colors.white,
                          onTap: () {
                            context.go(
                              '${AppRoutes.idCollectionView(collection.id!)}?collection_name=${collection.name}',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
