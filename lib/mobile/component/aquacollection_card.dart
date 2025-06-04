import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:kireimics/component/text_fonts/custom_text.dart';
import '../../component/app_routes/routes.dart';

class AquaCollectionCard extends StatefulWidget {
  const AquaCollectionCard({super.key});

  @override
  State<AquaCollectionCard> createState() => _AquaCollectionCardState();
}

class _AquaCollectionCardState extends State<AquaCollectionCard> {
  String bannerImg = '';
  String bannerText = '';
  String bannerQuantity = '';
  int? bannerId;

  // Add a boolean to track if the widget is disposed
  bool _isDisposed = false;

  Future getCollectionBanner() async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://vedvika.com/v1/apis/common/collection_list/get_collection_banner.php",
        ),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        var bannerData = data['data'][0];
        List<String> productIds = bannerData['product_id'].toString().split(
          ',',
        );

        // Check if the widget is still mounted before calling setState
        if (mounted && !_isDisposed) {
          setState(() {
            bannerImg = bannerData['banner_img'].toString();
            bannerText = bannerData['name'].toString();
            bannerId = bannerData['id'];
            bannerQuantity = productIds.length.toString();
          });
        }
      } else {
        print('Error: Status code ${response.statusCode}');
      }
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  @override
  void initState() {
    super.initState();
    getCollectionBanner();
  }

  @override
  void dispose() {
    // Mark the widget as disposed to avoid further setState calls
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 14.0, right: 14, top: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            'assets/home_page/PanelTitle.svg',
            height: 85,
            fit: BoxFit.cover,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.network(
                  bannerImg.isNotEmpty
                      ? bannerImg
                      : 'https://via.placeholder.com/150', // Fallback image
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200, // Adjust height as needed
                      color: Colors.grey[300],
                      child: Center(
                        child: Text(
                          'Failed to load image',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(child: CircularProgressIndicator());
                  },
                ),
                SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CralikaFont(
                          text: bannerText,
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          lineHeight: 1.0,
                          letterSpacing: 0.72,
                          color: Color(0xFF30578E),
                        ),
                        SizedBox(height: 8),
                        BarlowText(
                          text: "$bannerQuantity Pieces",
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          lineHeight: 1.0,
                          letterSpacing: 0.56,
                          color: Color(0xFF30578E),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        BarlowText(
                          text: "VIEW",
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          lineHeight: 1.0,
                          letterSpacing: 0.0,
                          color: Color(0xFF30578E),
                          onTap: () async {
                            if (bannerId != null) {
                              context.go(AppRoutes.idCollectionView(bannerId!));
                            }
                          },
                        ),
                        SizedBox(height: 24),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
