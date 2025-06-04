import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:kireimics/component/app_routes/routes.dart';

import '../../../component/notification_toast/custom_toast.dart';
import '../../../component/text_fonts/custom_text.dart';
import '../../../web_desktop_common/add_address_ui/add_address_controller.dart';

class AddAddressUiMobile extends StatefulWidget {
  final Function(String)? onWishlistChanged; // Callback to notify parent
  final Map<String, dynamic>? address;
  final bool isEditing;

  const AddAddressUiMobile({
    super.key,
    this.onWishlistChanged,
    this.address,
    this.isEditing = false,
  });

  @override
  State<AddAddressUiMobile> createState() => _AddAddressUiMobileState();
}

class _AddAddressUiMobileState extends State<AddAddressUiMobile> {
  final AddAddressController controller = Get.put(AddAddressController());

  bool showLoginBox = true; // initially show the login container
  bool isChecked = false;
  bool showSuccessBanner = false; // Add this line
  bool showErrorBanner = false;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    // Populate form fields if editing
    if (widget.isEditing && widget.address != null) {
      controller.populateFormForEdit(widget.address!);
    } else {
      controller.clearForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.only(top: 70.0, left: 22, right: 22),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: SvgPicture.asset(
                    "assets/icons/closeIcon.svg",
                    height: 18,
                    width: 18,
                  ),
                ),

                const SizedBox(height: 20),
                if (showSuccessBanner || showErrorBanner)
                  NotificationBanner(
                    message:
                        showSuccessBanner
                            ? (widget.isEditing
                                ? "Updated successfully!"
                                : "Added successfully!")
                            : errorMessage,
                    bannerColor: showSuccessBanner ? Colors.green : Colors.red,
                    textColor: Colors.black,
                    onClose: () {
                      setState(() {
                        showSuccessBanner = false;
                        showErrorBanner = false;
                      });
                    },
                  ),
                const SizedBox(height: 20),
                CralikaFont(
                  text: widget.isEditing ? "Update Address" : "Add New Address",
                  color: const Color(0xFF414141),
                  fontWeight: FontWeight.w600,
                  fontSize: 24.0,
                  lineHeight: 1.0,
                  letterSpacing: 0.128,
                ),

                const SizedBox(height: 44),
                Form(
                  key: controller.formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      customTextFormField(
                        hintText: "FIRST NAME*",
                        controller: controller.firstNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your first name';
                          }
                          if (value.length < 2) {
                            return 'First name too short';
                          }
                          return null;
                        },
                      ),
                      customTextFormField(
                        hintText: "LAST NAME*",
                        controller: controller.lastNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your last name';
                          }
                          if (value.length < 2) {
                            return 'Last name too short';
                          }
                          return null;
                        },
                      ),
                      customTextFormField(
                        hintText: "EMAIL*",
                        controller: controller.emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      customTextFormField(
                        hintText: "ADDRESS LINE 1*",
                        controller: controller.addressLine1Controller,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your ADDRESS LINE 1';
                          }

                          return null;
                        },
                      ),
                      customTextFormField(
                        hintText: "ADDRESS LINE 2",
                        controller: controller.addressLine2Controller,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: customTextFormField(
                              hintText: "ZIP*",
                              controller: controller.zipController,
                              onChanged: (value) {
                                if (value.length == 6) {
                                  controller.fetchPincodeData(value);
                                } else {
                                  controller.stateController.text = '';
                                  controller.cityController.text = '';
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your Zip';
                                }

                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 32), // spacing between fields
                          Expanded(
                            child: Obx(
                              () => customTextFormField(
                                hintText:
                                    controller.isPincodeLoading.value
                                        ? "Loading..."
                                        : "STATE*",
                                controller: controller.stateController,
                                enabled: !controller.isPincodeLoading.value,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your state';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      customTextFormField(
                        hintText:
                            controller.isPincodeLoading.value
                                ? "Loading..."
                                : "CITY*",
                        controller: controller.cityController,
                        enabled: !controller.isPincodeLoading.value,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your city';
                          }
                          return null;
                        },
                      ),
                      SizedBox(width: 32), // spacing between fields
                      customTextFormField(
                        hintText: "PHONE*",
                        controller: controller.phoneController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }

                          final phoneRegExp = RegExp(
                            r'^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$',
                          );

                          if (!phoneRegExp.hasMatch(value)) {
                            return 'Please enter a valid phone number';
                          }

                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Obx(
                            () => Checkbox(
                              value: controller.isChecked.value,
                              onChanged: controller.toggleCheckbox,
                              activeColor: Color(0xFF30578E),
                            ),
                          ),
                          SizedBox(width: 11),
                          BarlowText(
                            text: "Save as my default shipping address.",
                          ),
                        ],
                      ),
                      SizedBox(height: 44),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    bool success = await controller
                                        .handleAddAddress(
                                          context,
                                          isEditing: widget.isEditing,
                                          addressId:
                                              widget.isEditing
                                                  ? widget.address!['id']
                                                      .toString()
                                                  : null,
                                        );

                                    if (mounted) {
                                      setState(() {
                                        if (success) {
                                          showSuccessBanner = true;
                                          showErrorBanner = false;
                                          widget.onWishlistChanged?.call(
                                            "Added successful!",
                                          );
                                        } else {
                                          showSuccessBanner = false;
                                          showErrorBanner = true;
                                          errorMessage =
                                              controller.addressMessage;
                                          widget.onWishlistChanged?.call(
                                            errorMessage,
                                          );
                                        }
                                      });
                                    }
                                  },
                                  child: BarlowText(
                                    text:
                                        widget.isEditing
                                            ? "UPDATE ADDRESS"
                                            : "SAVE NEW ADDRESS",
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    lineHeight: 1.0,
                                    letterSpacing: 0.64,
                                    color: const Color(0xFF30578E),
                                    backgroundColor: const Color(0xFFb9d6ff),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget customTextFormField({
    required String hintText,
    TextEditingController? controller,
    bool enabled = true,

    Function(String)? onChanged,
    String? Function(String?)? validator, // Add validator parameter
  }) {
    return Stack(
      children: [
        // Hint text positioned on the left
        Positioned(
          left: 0,
          top: 16, // Adjust this value to align vertically
          child: Text(
            hintText,
            style: GoogleFonts.barlow(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: const Color(0xFF414141),
            ),
          ),
        ),
        // Text field with right-aligned input
        TextFormField(
          validator: validator, // Use the provided validator

          controller: controller,
          textAlign: TextAlign.right,
          cursorColor: Color(0xFF414141),
          enabled: enabled,
          onChanged: onChanged,
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
            errorStyle: TextStyle(color: Colors.red),

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
          style: const TextStyle(color: Color(0xFF414141)),
        ),
      ],
    );
  }
}
