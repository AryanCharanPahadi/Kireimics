import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:kireimics/component/app_routes/routes.dart';

import '../../../component/api_helper/api_helper.dart';
import '../../../component/notification_toast/custom_toast.dart';
import '../../../component/shared_preferences/shared_preferences.dart';
import '../../../component/text_fonts/custom_text.dart';
import '../../../component/utilities/utility.dart';
import '../../../web_desktop_common/add_address_ui/add_address_controller.dart';
import '../../../web_desktop_common/add_address_ui/add_address_ui.dart';

class MyAccountUiWeb extends StatefulWidget {
  final Function(String)? onWishlistChanged; // Callback to notify parent

  const MyAccountUiWeb({super.key, this.onWishlistChanged});

  @override
  State<MyAccountUiWeb> createState() => _MyAccountUiWebState();
}

class _MyAccountUiWebState extends State<MyAccountUiWeb> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  String? _addressIdToDelete; // Track address ID for deletion
  bool _showDeleteConfirmation = false; // Track banner visibility
  bool isEditing = false; // Track edit state

  // Get the AddAddressController instance
  final AddAddressController addAddressController = Get.put(
    AddAddressController(),
  );
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String signupMessage = ""; // Add this

  Future<bool> handleSignUp(BuildContext context) async {
    String? userId = await SharedPreferencesHelper.getUserId();
    print("User ID: $userId");

    if (userId == null || userId.isEmpty) {
      signupMessage = "User ID is missing";
      widget.onWishlistChanged?.call(signupMessage);
      return false;
    }

    if (formKey.currentState!.validate()) {
      String formattedDate = getFormattedDate();
      print("Input values: firstName=${firstNameController.text}, lastName=${lastNameController.text}, phone=${mobileController.text}, updatedAt=$formattedDate");

      try {
        final response = await ApiHelper.editRegisterUser(
          userId: userId.toString(),
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          phone: mobileController.text.trim(),
          updatedAt: formattedDate,
        );

        print("Signup Response: $response");

        if (response['error'] == true) {
          signupMessage = response['message'] ?? "Failed to update details";
          widget.onWishlistChanged?.call(signupMessage);
          return false;
        } else {
          String userData =
              "$userId, ${firstNameController.text.trim()} ${lastNameController.text.trim()}, ${mobileController.text.trim()}, ${emailController.text.trim()}";
          await SharedPreferencesHelper.saveUserData(userData);
          print("Saved user data: $userData");

          await _loadUserData();
          widget.onWishlistChanged?.call('Updated Successfully');
          return true;
        }
      } catch (e) {
        print("Signup exception: $e");
        signupMessage = "An error occurred during update: $e";
        widget.onWishlistChanged?.call(signupMessage);
        return false;
      }
    }

    signupMessage = "Please fill all fields correctly";
    widget.onWishlistChanged?.call(signupMessage);
    return false;
  }
  Future<void> _loadUserData() async {
    String? storedUser = await SharedPreferencesHelper.getUserData();

    if (storedUser != null) {
      List<String> userDetails = storedUser.split(', ');

      if (userDetails.length >= 4) {
        // Adjusted to expect at least 4 parts
        List<String> nameParts = userDetails[1].split(' ');
        String firstName = nameParts.isNotEmpty ? nameParts[0] : '';
        String lastName =
            nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
        String phone = userDetails[2];
        String email = userDetails[3];

        if (mounted) {
          setState(() {
            firstNameController.text = firstName;
            lastNameController.text = lastName;
            emailController.text = email;
            mobileController.text = phone;
          });
        }
      } else {
        print('Invalid user data format: $storedUser');
      }
    } else {
      print('No user data found in SharedPreferences');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _showDeleteConfirmationBanner(String addressId) {
    setState(() {
      _addressIdToDelete = addressId;
      _showDeleteConfirmation = true;
    });
  }

  void _hideDeleteConfirmationBanner() {
    setState(() {
      _addressIdToDelete = null;
      _showDeleteConfirmation = false;
    });
  }

  void _confirmDelete() {
    if (_addressIdToDelete != null) {
      addAddressController.deleteAddress(_addressIdToDelete!);
      _hideDeleteConfirmationBanner();
    }
  }

  void _toggleEditing() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final leftPadding = 292.0;
    final rightPadding = screenWidth * 0.07;

    final leftSectionWidth = screenWidth * 0.35;
    final rightSectionWidth = screenWidth * 0.35;

    return Stack(
      children: [
        SizedBox(
          width: screenWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Side - My Details
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(left: leftPadding, top: 24),
                  child: SizedBox(
                    width: leftSectionWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CralikaFont(
                          text: "My Account",
                          fontWeight: FontWeight.w400,
                          fontSize: 32,
                          lineHeight: 36 / 32,
                          letterSpacing: 1.28,
                          color: Color(0xFF414141),
                        ),
                        SizedBox(height: 13),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            BarlowText(
                              text: "My Account",
                              color: Color(0xFF3E5B84),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              lineHeight: 1.0,
                              letterSpacing: 1 * 0.04,
                              route: AppRoutes.myAccount,
                              enableUnderlineForActiveRoute: true,
                              decorationColor: Color(0xFF3E5B84),
                              onTap: () {
                                context.go(AppRoutes.myAccount);
                              },
                            ),
                            SizedBox(width: 32),
                            BarlowText(
                              text: "My Orders",
                              color: Color(0xFF3E5B84),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              lineHeight: 1.0,
                              route: AppRoutes.myOrder,
                              enableUnderlineForActiveRoute: true,
                              decorationColor: Color(0xFF3E5B84),
                              onTap: () {
                                context.go(AppRoutes.myOrder);
                              },
                            ),
                            SizedBox(width: 32),
                            BarlowText(
                              text: "Wishlist",
                              color: Color(0xFF3E5B84),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              lineHeight: 1.0,
                              onTap: () {
                                context.go(AppRoutes.wishlist);
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 32),
                        SizedBox(
                          width: leftSectionWidth * 0.9,
                          child: Row(
                            children: [
                              CralikaFont(
                                text: "My Details",
                                fontWeight: FontWeight.w400,
                                fontSize: 20,
                                lineHeight: 27 / 20,
                                letterSpacing: 0.04 * 20,
                                color: Color(0xFF414141),
                              ),
                              Spacer(),
                              GestureDetector(
                                onTap: () async {
                                  if (isEditing) {
                                    // Call handleSignUp when in editing mode
                                    bool success = await handleSignUp(context);
                                    if (mounted) {
                                      setState(() {
                                        if (success) {
                                          isEditing =
                                              false; // Exit editing mode on success
                                        }
                                      });
                                    }
                                  } else {
                                    // Toggle to editing mode
                                    _toggleEditing();
                                  }
                                },
                                child: BarlowText(
                                  text:
                                      isEditing
                                          ? "SAVE DETAILS"
                                          : "EDIT DETAILS",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  lineHeight: 1.0,
                                  letterSpacing: 0.04 * 16,
                                  color: Color(0xFF414141),
                                  backgroundColor: Color(0xFFb9d6ff),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),
                        SizedBox(
                          width: leftSectionWidth * 0.9,
                          child: Form(
                            key: formKey,
                            child: Column(
                              children: [
                                customTextFormField(
                                  hintText: "FIRST NAME",
                                  controller: firstNameController,
                                  readOnly: !isEditing,
                                ),
                                customTextFormField(
                                  hintText: "LAST NAME",
                                  controller: lastNameController,
                                  readOnly: !isEditing,
                                ),
                                customTextFormField(
                                  hintText: "EMAIL",
                                  controller: emailController,
                                  readOnly: !isEditing || isEditing,
                                ),
                                customTextFormField(
                                  hintText: "MOBILE",
                                  controller: mobileController,
                                  readOnly: !isEditing,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Right Side - My Addresses
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(right: rightPadding, top: 124),
                  child: SizedBox(
                    width: rightSectionWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CralikaFont(
                              text: "My Addresses",
                              fontWeight: FontWeight.w400,
                              fontSize: 20,
                              lineHeight: 27 / 20,
                              letterSpacing: 0.04 * 20,
                              color: Color(0xFF414141),
                            ),
                            Spacer(),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  barrierColor: Colors.transparent,
                                  builder: (BuildContext context) {
                                    return AddAddressUi();
                                  },
                                );
                              },
                              child: BarlowText(
                                text: "ADD NEW ADDRESS",
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                lineHeight: 1.0,
                                letterSpacing: 0.04 * 16,
                                color: Color(0xFF414141),
                                backgroundColor: Color(0xFFb9d6ff),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                        // Use Obx to reactively update UI based on _addressList
                        Obx(
                          () =>
                              addAddressController.addressList.isEmpty
                                  ? Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(
                                            0xFFDDEAFF,
                                          ).withOpacity(0.6),
                                          offset: Offset(20, 20),
                                          blurRadius: 20,
                                        ),
                                      ],
                                      border: Border.all(
                                        color: Color(0xFFDDEAFF),
                                        width: 1,
                                      ),
                                    ),
                                    width: rightSectionWidth,
                                    padding: const EdgeInsets.all(16.0),
                                    child: Center(
                                      child: BarlowText(
                                        text:
                                            "No addresses found. Add a new address.",
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        lineHeight: 1.4,
                                        letterSpacing: 0.0,
                                        color: Color(0xFF636363),
                                      ),
                                    ),
                                  )
                                  : Column(
                                    children:
                                        addAddressController.addressList.map((
                                          address,
                                        ) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 16.0,
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Color(
                                                      0xFFDDEAFF,
                                                    ).withOpacity(0.6),
                                                    offset: Offset(20, 20),
                                                    blurRadius: 20,
                                                  ),
                                                ],
                                                border: Border.all(
                                                  color: Color(0xFFDDEAFF),
                                                  width: 1,
                                                ),
                                              ),
                                              width: rightSectionWidth,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 16.0,
                                                  top: 13,
                                                  bottom: 13,
                                                  right: 10,
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      height: 56,
                                                      width: 56,
                                                      decoration: BoxDecoration(
                                                        color: Color(
                                                          0xFFDDEAFF,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: Center(
                                                        child: SvgPicture.asset(
                                                          "assets/icons/location.svg",
                                                          height: 27,
                                                          width: 25,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 24),
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          BarlowText(
                                                            text:
                                                                address["city"],
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 20,
                                                            lineHeight: 1.0,
                                                            letterSpacing: 0.0,
                                                            color: Color(
                                                              0xFF414141,
                                                            ),
                                                          ),
                                                          SizedBox(height: 3),
                                                          BarlowText(
                                                            text:
                                                                address["name"],
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 14,
                                                            lineHeight: 1.4,
                                                            letterSpacing: 0.0,
                                                            color: Color(
                                                              0xFF636363,
                                                            ),
                                                          ),
                                                          SizedBox(height: 3),
                                                          BarlowText(
                                                            text:
                                                                address["address"],
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 14,
                                                            lineHeight: 1.4,
                                                            letterSpacing: 0.0,
                                                            color: Color(
                                                              0xFF636363,
                                                            ),
                                                          ),
                                                          SizedBox(height: 3),
                                                          BarlowText(
                                                            text:
                                                                "${address["postalCode"]} - ${address["country"]}",
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 14,
                                                            lineHeight: 1.4,
                                                            letterSpacing: 0.0,
                                                            color: Color(
                                                              0xFF636363,
                                                            ),
                                                          ),
                                                          SizedBox(height: 3),
                                                          Row(
                                                            children: [
                                                              BarlowText(
                                                                text: "EDIT",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 16,
                                                                lineHeight: 1.5,
                                                                letterSpacing:
                                                                    0.0,
                                                                color: Color(
                                                                  0xFF3E5B84,
                                                                ),
                                                                hoverBackgroundColor:
                                                                    Color(
                                                                      0xFFb9d6ff,
                                                                    ),
                                                                enableHoverBackground:
                                                                    true,
                                                                onTap: () {
                                                                  showDialog(
                                                                    context:
                                                                        context,
                                                                    barrierColor:
                                                                        Colors
                                                                            .transparent,
                                                                    builder: (
                                                                      BuildContext
                                                                      context,
                                                                    ) {
                                                                      return AddAddressUi(
                                                                        address:
                                                                            address,
                                                                        isEditing:
                                                                            true,
                                                                      );
                                                                    },
                                                                  );
                                                                },
                                                              ),
                                                              BarlowText(
                                                                text: " / ",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 16,
                                                                lineHeight: 1.5,
                                                                letterSpacing:
                                                                    0.0,
                                                                color: Color(
                                                                  0xFF3E5B84,
                                                                ),
                                                              ),
                                                              BarlowText(
                                                                text: "DELETE",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 16,
                                                                lineHeight: 1.5,
                                                                letterSpacing:
                                                                    0.0,
                                                                color: Color(
                                                                  0xFF3E5B84,
                                                                ),
                                                                hoverBackgroundColor:
                                                                    Color(
                                                                      0xFFb9d6ff,
                                                                    ),
                                                                enableHoverBackground:
                                                                    true,
                                                                onTap: () {
                                                                  _showDeleteConfirmationBanner(
                                                                    address["id"]
                                                                        .toString(),
                                                                  );
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        if (_showDeleteConfirmation)
          Positioned(
            top: 0,
            right: 24,
            child: NotificationBanner(
              message: "Are you sure you want to delete this address?",
              iconPath: "assets/icons/i_icons.svg",
              bannerColor: const Color(0xFF2876E4),
              textColor: Colors.black,
              confirmation: true,
              yesText: "Yes",
              noText: "No",
              onYes: _confirmDelete,
              onNo: _hideDeleteConfirmationBanner,
              onClose: _hideDeleteConfirmationBanner,
            ),
          ),
      ],
    );
  }

  Widget customTextFormField({
    required String hintText,
    TextEditingController? controller,
    bool readOnly = true,
  }) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 16,
          child: Text(
            hintText,
            style: GoogleFonts.barlow(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: const Color(0xFF414141),
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          textAlign: TextAlign.right,
          cursorColor: const Color(0xFF414141),
          readOnly: readOnly,
          decoration: InputDecoration(
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFF414141)),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFF414141)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFF414141)),
            ),
            hintText: '',
            hintStyle: GoogleFonts.barlow(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              height: 1.0,
              letterSpacing: 0.0,
              color: const Color(0xFF414141),
            ),
            contentPadding: const EdgeInsets.only(top: 16),
          ),
          style: TextStyle(color: isEditing ? Colors.black : Color(0xFF636363)),
        ),
      ],
    );
  }
}
