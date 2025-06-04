import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:kireimics/component/app_routes/routes.dart';

import '../../../component/api_helper/api_helper.dart';
import '../../../component/notification_toast/custom_toast.dart';
import '../../../component/text_fonts/custom_text.dart';
import '../../../component/shared_preferences/shared_preferences.dart';
import '../../../component/utilities/utility.dart';
import '../../../web_desktop_common/add_address_ui/add_address_controller.dart';
import '../../../web_desktop_common/add_address_ui/add_address_ui.dart';

class MyAccountUiDesktop extends StatefulWidget {
  final Function(String)? onWishlistChanged; // Callback to notify parent

  const MyAccountUiDesktop({super.key, this.onWishlistChanged});

  @override
  State<MyAccountUiDesktop> createState() => _MyAccountUiDesktopState();
}

class _MyAccountUiDesktopState extends State<MyAccountUiDesktop> {
  // Sample JSON data for addresses
  // Get the AddAddressController instance
  final AddAddressController addAddressController = Get.put(
    AddAddressController(),
  );
  String? _addressIdToDelete; // Track address ID for deletion
  bool _showDeleteConfirmation = false; // Track banner visibility
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

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String signupMessage = ""; // Add this

  Future<bool> handleSignUp(BuildContext context) async {
    String? userId = await SharedPreferencesHelper.getUserId();

    print("this is the user id $userId");

    if (formKey.currentState!.validate()) {
      String formattedDate = getFormattedDate();

      try {
        final response = await ApiHelper.editRegisterUser(
          userId: userId.toString(),
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          phone: mobileController.text.trim(),
          updatedAt: formattedDate,
        );

        // Print the full API response
        print("Signup Response: $response");

        if (response['error'] == true) {
          // Display error message
          signupMessage = response['message'] ?? "Failed to update details";
          widget.onWishlistChanged?.call(
            signupMessage,
          ); // Optional: Keep if parent needs it
          return false;
        } else {
          // Save updated user data to SharedPreferences
          String userData =
              "${userId}, ${firstNameController.text.trim()} ${lastNameController.text.trim()}, ${mobileController.text.trim()}, ${emailController.text.trim()}";
          await SharedPreferencesHelper.saveUserData(userData);
          print("Saved user data to SharedPreferences: $userData");

          // Reload user data to update UI
          await _loadUserData();

          // Toggle editing state off
          if (mounted) {
            setState(() {
              isEditing = false;
            });
          }

          // Show success message
          widget.onWishlistChanged?.call(
            'Updated Successfully',
          ); // Optional: Keep if parent needs it
          return true;
        }
      } catch (e) {
        print("Signup exception: $e");
        signupMessage = "An error occurred during update";
        widget.onWishlistChanged?.call(
          signupMessage,
        ); // Optional: Keep if parent needs it
        return false;
      }
    }
    signupMessage = "Please fill all fields correctly";
    widget.onWishlistChanged?.call(
      signupMessage,
    ); // Optional: Keep if parent needs it
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

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();

  bool isEditing = false; // Track edit state

  @override
  void initState() {
    super.initState();
    _loadUserData();
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
    return Stack(
      children: [
        SizedBox(
          // color: Colors.green,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: EdgeInsets.only(
              left: 389,
              right: MediaQuery.of(context).size.width * 0.15,
              top: 24,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column - My Details
                SizedBox(
                  width: 370, // Fixed width for left column
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CralikaFont(
                        text: "My Account",
                        fontWeight: FontWeight.w400,
                        fontSize: 32,
                        lineHeight: 36 / 32,
                        letterSpacing: 1.28,
                        color: Color(0xFF414141),
                      ),
                      const SizedBox(height: 13),

                      // Navigation Row
                      Row(
                        children: [
                          _buildNavItem(
                            "My Account",
                            AppRoutes.myAccount,
                            context,
                          ),
                          const SizedBox(width: 32),
                          _buildNavItem(
                            "My Orders",
                            AppRoutes.myOrder,
                            context,
                          ),
                          const SizedBox(width: 32),
                          _buildNavItem(
                            "Wishlist",
                            AppRoutes.wishlist,
                            context,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // My Details Section
                      _buildSectionHeader(
                        title: "My Details",
                        actionText: isEditing ? "SAVE DETAILS" : "EDIT DETAILS",
                        onAction: _toggleEditing,
                      ),
                      const SizedBox(height: 24),

                      // Form Fields
                      _buildFormFields(),
                    ],
                  ),
                ),
                // Right Column - My Addresses
                SizedBox(
                  width: 468, // Fixed width for right column
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 100,
                      ), // Vertical offset to align with left column
                      // My Addresses Section
                      _buildSectionHeader(
                        title: "My Addresses",
                        actionText: "ADD NEW ADDRESS",
                        onAction: () {
                          showDialog(
                            context: context,
                            barrierColor: Colors.transparent,
                            builder:
                                (BuildContext context) => const AddAddressUi(),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Address List
                      _buildAddressList(),
                    ],
                  ),
                ),
              ],
            ),
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

  Widget _buildNavItem(String text, String route, BuildContext context) {
    return BarlowText(
      text: text,
      color: const Color(0xFF3E5B84),
      fontSize: 16,
      fontWeight: FontWeight.w600,
      lineHeight: 1.0,
      letterSpacing: 1 * 0.04,
      route: route,
      enableUnderlineForActiveRoute: true,
      decorationColor: const Color(0xFF3E5B84),
      onTap: () => context.go(route),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CralikaFont(
          text: title,
          fontWeight: FontWeight.w400,
          fontSize: 20,
          lineHeight: 27 / 20,
          letterSpacing: 0.04 * 20,
          color: const Color(0xFF414141),
        ),
        GestureDetector(
          onTap:
              isEditing && title == "My Details"
                  ? () async {
                    bool success = await handleSignUp(context);
                    if (success && mounted) {
                      setState(() {
                        isEditing = false; // Exit edit mode on success
                      });
                    }
                  }
                  : onAction,
          child: BarlowText(
            text: actionText,
            fontWeight: FontWeight.w600,
            fontSize: 16,
            lineHeight: 1.0,
            letterSpacing: 0.04 * 16,
            color: const Color(0xFF414141),
            backgroundColor: Color(0xFFb9d6ff),
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Form(
      key: formKey,
      child: Column(
        children: [
          _buildCustomTextField("FIRST NAME", firstNameController, !isEditing),
          _buildCustomTextField("LAST NAME", lastNameController, !isEditing),
          _buildCustomTextField(
            "EMAIL",
            emailController,
            !isEditing || isEditing,
          ),
          _buildCustomTextField("MOBILE", mobileController, !isEditing),
        ],
      ),
    );
  }

  Widget _buildCustomTextField(
    String hintText,
    TextEditingController controller,
    bool readOnly,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Stack(
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
              border: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF414141)),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF414141)),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF414141)),
              ),
              contentPadding: const EdgeInsets.only(top: 16),
            ),
            style: TextStyle(
              color:
                  isEditing
                      ? Colors.black
                      : Color(0xFF636363), // Change color based on isEditing
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressList() {
    return Obx(
      () =>
          addAddressController.addressList.isEmpty
              ? Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFDDEAFF).withOpacity(0.6),
                      offset: const Offset(20, 20),
                      blurRadius: 20,
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFDDEAFF), width: 1),
                ),
                // width: rightSectionWidth,
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: BarlowText(
                    text: "No addresses found. Add a new address.",
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    lineHeight: 1.4,
                    letterSpacing: 0.0,
                    color: const Color(0xFF636363),
                  ),
                ),
              )
              : Column(
                children:
                    addAddressController.addressList.map((address) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFDDEAFF).withOpacity(0.6),
                                offset: const Offset(20, 20),
                                blurRadius: 20,
                              ),
                            ],
                            border: Border.all(
                              color: const Color(0xFFDDEAFF),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 56,
                                  width: 56,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDDEAFF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      "assets/icons/location.svg",
                                      height: 27,
                                      width: 25,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      BarlowText(
                                        text: address["city"],
                                        fontWeight: FontWeight.w400,
                                        fontSize: 20,
                                        lineHeight: 1.0,
                                        color: const Color(0xFF414141),
                                      ),
                                      const SizedBox(height: 3),
                                      _buildAddressDetail(address["name"]),
                                      _buildAddressDetail(address["address"]),
                                      _buildAddressDetail(
                                        "${address["postalCode"]} - ${address["country"]}",
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          _buildActionButton("EDIT", () {
                                            showDialog(
                                              context: context,
                                              barrierColor: Colors.transparent,
                                              builder: (BuildContext context) {
                                                return AddAddressUi(
                                                  address: address,
                                                  isEditing: true,
                                                );
                                              },
                                            );
                                          }),
                                          const Text(" / "),
                                          _buildActionButton("DELETE", () {
                                            _showDeleteConfirmationBanner(
                                              address["id"].toString(),
                                            );
                                          }),
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
    );
  }

  Widget _buildAddressDetail(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: BarlowText(
        text: text,
        fontWeight: FontWeight.w400,
        fontSize: 14,
        lineHeight: 1.4,
        color: const Color(0xFF636363),
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: BarlowText(
          text: text,
          fontWeight: FontWeight.w600,
          fontSize: 16,
          lineHeight: 1.5,
          color: const Color(0xFF3E5B84),
          hoverBackgroundColor: const Color(0xFFb9d6ff),
          enableHoverBackground: true,
        ),
      ),
    );
  }
}
