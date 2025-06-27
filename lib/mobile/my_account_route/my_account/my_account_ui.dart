import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:kireimics/component/app_routes/routes.dart';
import 'package:kireimics/mobile/address_page/add_address_ui/add_address_ui.dart';

import '../../../component/api_helper/api_helper.dart';
import '../../../component/notification_toast/custom_toast.dart';
import '../../../component/text_fonts/custom_text.dart';
import '../../../component/shared_preferences/shared_preferences.dart';
import '../../../component/utilities/utility.dart';
import '../../../web_desktop_common/add_address_ui/add_address_controller.dart';

class MyAccountUiMobile extends StatefulWidget {
  final Function(String)? onWishlistChanged; // Callback to notify parent

  const MyAccountUiMobile({super.key, this.onWishlistChanged});

  @override
  State<MyAccountUiMobile> createState() => _MyAccountUiMobileState();
}

class _MyAccountUiMobileState extends State<MyAccountUiMobile> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();

  bool isEditing = false; // Track edit state
  final AddAddressController addAddressController = Get.put(
    AddAddressController(),
  );

  @override
  void initState() {
    super.initState();
    _loadUserData();
    addAddressController.fetchAddress();
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
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 32),
              // Left Side
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CralikaFont(
                      text: "My Account",
                      fontWeight: FontWeight.w400,
                      fontSize: 24,
                      lineHeight: 36 / 32,
                      letterSpacing: 1.28,
                      color: Color(0xFF414141),
                    ),
                    SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        BarlowText(
                          text: "My Account",
                          color: Color(0xFF30578E),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          lineHeight: 1.0,
                          letterSpacing: 1 * 0.04,
                          route: AppRoutes.myAccount,
                          enableUnderlineForActiveRoute: true,
                          decorationColor: Color(0xFF30578E),
                          onTap: () {},
                        ),
                        SizedBox(width: 32),
                        BarlowText(
                          text: "My Orders",
                          color: Color(0xFF30578E),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          lineHeight: 1.0,
                          onTap: () {
                            context.go(AppRoutes.myOrder);
                          },
                        ),
                        SizedBox(width: 32),
                        BarlowText(
                          text: "Wishlist",
                          color: Color(0xFF30578E),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          lineHeight: 1.0,
                          onTap: () {
                            context.go(AppRoutes.wishlist);
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CralikaFont(
                          text: "My Details",
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          lineHeight: 27 / 20,
                          letterSpacing: 0.04 * 20,
                          color: Color(0xFF414141),
                        ),
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
                            text: isEditing ? "SAVE DETAILS" : "EDIT DETAILS",
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            lineHeight: 1.0,
                            letterSpacing: 0.04 * 16,
                            color: Color(0xFF3E5B84),
                            backgroundColor: Color(0xFFb9d6ff),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          customTextFormField(
                            hintText: "FIRST NAME",
                            controller: firstNameController,
                            readOnly: !isEditing,
                          ),
                          SizedBox(height: 24),

                          customTextFormField(
                            hintText: "LAST NAME",
                            controller: lastNameController,
                            readOnly: !isEditing,
                          ),
                          SizedBox(height: 24),

                          customTextFormField(
                            hintText: "EMAIL",
                            controller: emailController,
                            readOnly: !isEditing || isEditing,
                          ),
                          SizedBox(height: 24),

                          customTextFormField(
                            hintText: "MOBILE",
                            controller: mobileController,
                            readOnly: !isEditing,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Right Side
              SizedBox(height: 44),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CralikaFont(
                          text: "My Addresses",
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          lineHeight: 27 / 20,
                          letterSpacing: 0.04 * 20,
                          color: Color(0xFF414141),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddAddressUiMobile(),
                              ),
                            );
                          },
                          child: BarlowText(
                            text: "ADD NEW ADDRESS",
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            lineHeight: 1.0,
                            letterSpacing: 0.04 * 16,
                            color: Color(0xFF3E5B84),
                            backgroundColor: Color(0xFFb9d6ff),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    // Dynamic list of address containers
                    Obx(
                      () =>
                          addAddressController.addressList.isEmpty
                              ? Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFFDDEAFF).withOpacity(0.6),
                                      offset: Offset(20, 20),
                                      blurRadius: 20,
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Color(0xFFDDEAFF),
                                    width: 1,
                                  ),
                                ),
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
                                                    color: Color(0xFFDDEAFF),
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
                                                      Row(
                                                        children: [
                                                          BarlowText(
                                                            text:
                                                                address["city"],
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 16,
                                                            lineHeight: 1.0,
                                                            letterSpacing: 0.0,

                                                            color: Color(
                                                              0xFF414141,
                                                            ),
                                                          ),
                                                          if (address['default_address'] ==
                                                              true) ...[
                                                            SizedBox(
                                                              width: 8,
                                                            ), // Space between city and badge
                                                            Text(
                                                              "(DEFAULT)",
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    GoogleFonts.barlow()
                                                                        .fontFamily,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400, // Equivalent to 400
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                                fontSize: 16.0,
                                                                color: Color(
                                                                  0xFF414141,
                                                                ),

                                                                height:
                                                                    1.0, // line-height 100%
                                                                letterSpacing:
                                                                    0.0, // letter-spacing 0%
                                                              ),
                                                            ),
                                                          ],
                                                        ],
                                                      ),
                                                      SizedBox(height: 3),
                                                      BarlowText(
                                                        text: address["name"],
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
                                                                FontWeight.w600,
                                                            fontSize: 14,
                                                            lineHeight: 1.5,
                                                            letterSpacing: 0.0,
                                                            color: Color(
                                                              0xFF30578E,
                                                            ),
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (
                                                                        context,
                                                                      ) => AddAddressUiMobile(
                                                                        address:
                                                                            address,
                                                                        isEditing:
                                                                            true,
                                                                      ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                          BarlowText(
                                                            text: " / ",
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 14,
                                                            lineHeight: 1.5,
                                                            letterSpacing: 0.0,
                                                            color: Color(
                                                              0xFF30578E,
                                                            ),
                                                          ),
                                                          BarlowText(
                                                            text: "DELETE",
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 14,
                                                            lineHeight: 1.5,
                                                            letterSpacing: 0.0,
                                                            color: Color(
                                                              0xFF30578E,
                                                            ),
                                                            onTap: () {
                                                              context.go(
                                                                '${AppRoutes.deleteAddress}?addressId=${address['id'].toString()}',
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
            ],
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
              fontSize: 12,
              color: const Color(0xFF414141),
            ),
          ),
        ),
        TextFormField(
          readOnly: readOnly,
          controller: controller,
          textAlign: TextAlign.right,
          cursorColor: const Color(0xFF414141),
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
              fontSize: 12,
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
