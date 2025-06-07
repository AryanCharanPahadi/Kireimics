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
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 5,
                    childAspectRatio: () {
                      double width = MediaQuery.of(context).size.width;
                      if (width > 300 && width <= 337) {
                        return 1.0;
                      } else if (width > 338 && width <= 350) {
                        return 1.1;
                      } else if (width > 351 && width <= 360) {
                        return 1.1;
                      } else if (width > 361 && width <= 370) {
                        return 1.2;
                      } else if (width > 371 && width <= 400) {
                        return 1.2;
                      } else if (width > 401 && width <= 450) {
                        return 1.4;
                      } else if (width > 451 && width <= 500) {
                        return 1.6;
                      } else if (width > 501 && width <= 550) {
                        return 1.7;
                      } else if (width > 551 && width <= 600) {
                        return 1.8;
                      } else if (width > 601 && width <= 650) {
                        return 2.0;
                      } else if (width > 651 && width <= 700) {
                        return 2.1;
                      } else if (width > 701 && width <= 750) {
                        return 2.2;
                      } else if (width > 751 && width <= 800) {
                        return 2.4;
                      } else {
                        return 0.50;
                      }
                    }(),
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
                                    color: Color(0xFF30578E),
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
                                    color: const Color(0xFF30578E),
                                  ),
                                ),
                                const SizedBox(height: 10),

                                BarlowText(
                                  text: "VIEW",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  lineHeight: 1.2,
                                  letterSpacing: 0.56,
                                  color: const Color(0xFF30578E),
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
