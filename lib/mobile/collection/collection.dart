import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../component/text_fonts/custom_text.dart';
import '../../component/app_routes/routes.dart';
import '../../web_desktop_common/collection/collection_modal.dart';

class CollectionMobile extends StatefulWidget {
  final List<CollectionModal> collectionList;

  const CollectionMobile({super.key, required this.collectionList});

  @override
  State<CollectionMobile> createState() => _CollectionMobileState();
}

class _CollectionMobileState extends State<CollectionMobile> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 22),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 5,
                    childAspectRatio: 1.17,
                  ),
                  itemCount: widget.collectionList.length,
                  itemBuilder: (context, index) {
                    final collection = widget.collectionList[index];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 196,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Image.network(
                                  collection.bannerImg!,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  collection.name ?? 'Unnamed Collection',
                                  style: const TextStyle(
                                    fontFamily: "Cralika",
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    height: 1.2,
                                    letterSpacing: 0.64,
                                    color: Color(0xFF3E5B84),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '${collection.productCount ?? 0} Pieces',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.barlow(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    height: 1.2,
                                    color: const Color(0xFF3E5B84),
                                  ),
                                ),
                                const SizedBox(height: 10),

                                BarlowText(
                                 text:  "VIEW",
                                  fontSize: 14,
                                  lineHeight: 1.2,
                                  letterSpacing: 0.56,
                                  color: const Color(0xFF3E5B84),
                                  onTap: () async {
                                    context.go(
                                      AppRoutes.idCollectionView(collection.id!),
                                    );
                                  },

                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
