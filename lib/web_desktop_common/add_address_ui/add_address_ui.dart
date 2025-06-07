import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../component/text_fonts/custom_text.dart';
import '../../component/notification_toast/custom_toast.dart';
import '../../component/utilities/utility.dart';
import 'add_address_controller.dart';

class AddAddressUi extends StatefulWidget {
  final Map<String, dynamic>? address;
  final bool isEditing;

  const AddAddressUi({super.key, this.address, this.isEditing = false});

  @override
  State<AddAddressUi> createState() => _AddAddressUiState();
}

class _AddAddressUiState extends State<AddAddressUi> {
  final AddAddressController controller = Get.put(AddAddressController());

  bool showSuccessBanner = false;
  bool showErrorBanner = false;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.address != null) {
      controller.populateFormForEdit(widget.address!);
    } else {
      controller.clearForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1400;

    return Stack(
      children: [
        BlurredBackdrop(),
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: isLargeScreen ? 600 : 550,
            child: Material(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(left: 32.0, top: 22, right: 44),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: BarlowText(
                              text: "Close",
                              color: Color(0xFF30578E),
                              fontWeight: FontWeight.w600,
                              fontSize: 16.0,
                              lineHeight: 1.0,
                              letterSpacing: 0.64,
                              hoverTextColor: const Color(0xFF2876E4),
                            ),
                          ),
                          if (showSuccessBanner || showErrorBanner)
                            NotificationBanner(
                              iconPath:
                                  showSuccessBanner
                                      ? "assets/icons/success.svg"
                                      : "assets/icons/error.svg",
                              message:
                                  showSuccessBanner
                                      ? (widget.isEditing
                                          ? "Updated successfully!"
                                          : "Added successfully!")
                                      : errorMessage,
                              bannerColor:
                                  showSuccessBanner
                                      ? Color(0xFF268FA2)
                                      : Color(0xFFF46856),
                              textColor: Color(0xFF28292A),
                              onClose: () {
                                setState(() {
                                  showSuccessBanner = false;
                                  showErrorBanner = false;
                                  errorMessage = "";
                                });
                              },
                            ),
                        ],
                      ),
                      SizedBox(height: 33),
                      CralikaFont(
                        text:
                            widget.isEditing
                                ? "Update Address"
                                : "Add New Address",
                        color: Color(0xFF414141),
                        fontWeight: FontWeight.w600,
                        fontSize: 32.0,
                        lineHeight: 1.0,
                        letterSpacing: 0.128,
                      ),
                      SizedBox(height: 32),
                      Form(
                        key: controller.formKey,
                        child: Column(
                          children: [
                            customTextFormField(
                              hintText: "FIRST NAME",
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
                              isRequired: true,
                            ),
                            SizedBox(height: 32),
                            customTextFormField(
                              hintText: "LAST NAME",
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
                              isRequired: true,
                            ),
                            SizedBox(height: 32),
                            customTextFormField(
                              hintText: "EMAIL",
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
                              isRequired: true,
                            ),
                            SizedBox(height: 32),
                            customTextFormField(
                              hintText: "ADDRESS LINE 1",
                              controller: controller.addressLine1Controller,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your ADDRESS LINE 1';
                                }
                                return null;
                              },
                              isRequired: true,
                            ),
                            SizedBox(height: 32),
                            customTextFormField(
                              hintText: "ADDRESS LINE 2",
                              controller: controller.addressLine2Controller,
                            ),
                            SizedBox(height: 32),
                            Row(
                              children: [
                                Expanded(
                                  child: customTextFormField(
                                    hintText: "ZIP",
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
                                    isRequired: true,
                                  ),
                                ),
                                SizedBox(width: 32),
                                Expanded(
                                  child: Obx(
                                    () => customTextFormField(
                                      hintText:
                                          controller.isPincodeLoading.value
                                              ? "Loading..."
                                              : "STATE",
                                      controller: controller.stateController,
                                      enabled:
                                          !controller.isPincodeLoading.value,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your state';
                                        }
                                        return null;
                                      },
                                      isRequired: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 32),
                            Row(
                              children: [
                                Expanded(
                                  child: Obx(
                                    () => customTextFormField(
                                      hintText:
                                          controller.isPincodeLoading.value
                                              ? "Loading..."
                                              : "CITY",
                                      controller: controller.cityController,
                                      enabled:
                                          !controller.isPincodeLoading.value,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your city';
                                        }
                                        return null;
                                      },
                                      isRequired: true,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 32),
                                Expanded(
                                  child: customTextFormField(
                                    hintText: "PHONE",
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
                                    isRequired: true,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 32),
                            Row(
                              children: [
                                Obx(
                                  () => GestureDetector(
                                    onTap:
                                        () => controller.toggleCheckbox(
                                          !controller.isChecked.value,
                                        ),
                                    child: SvgPicture.asset(
                                      controller.isChecked.value
                                          ? "assets/icons/filledCheckbox.svg"
                                          : "assets/icons/emptyCheckbox.svg",
                                      height: 24,
                                      width: 24,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Save as my default shipping address.",
                                  style: GoogleFonts.barlow(),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        // Collect validation errors
                                        List<String> errors = [];
                                        if (controller
                                            .firstNameController
                                            .text
                                            .isEmpty) {
                                          errors.add(
                                            'Please enter your first name',
                                          );
                                        } else if (controller
                                                .firstNameController
                                                .text
                                                .length <
                                            2) {
                                          errors.add('First name too short');
                                        }
                                        if (controller
                                            .lastNameController
                                            .text
                                            .isEmpty) {
                                          errors.add(
                                            'Please enter your last name',
                                          );
                                        } else if (controller
                                                .lastNameController
                                                .text
                                                .length <
                                            2) {
                                          errors.add('Last name too short');
                                        }
                                        if (controller
                                            .emailController
                                            .text
                                            .isEmpty) {
                                          errors.add('Please enter your email');
                                        } else if (!RegExp(
                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                        ).hasMatch(
                                          controller.emailController.text,
                                        )) {
                                          errors.add(
                                            'Please enter a valid email',
                                          );
                                        }
                                        if (controller
                                            .addressLine1Controller
                                            .text
                                            .isEmpty) {
                                          errors.add(
                                            'Please enter your ADDRESS LINE 1',
                                          );
                                        }
                                        if (controller
                                            .zipController
                                            .text
                                            .isEmpty) {
                                          errors.add('Please enter your Zip');
                                        }
                                        if (controller
                                            .stateController
                                            .text
                                            .isEmpty) {
                                          errors.add('Please enter your state');
                                        }
                                        if (controller
                                            .cityController
                                            .text
                                            .isEmpty) {
                                          errors.add('Please enter your city');
                                        }
                                        if (controller
                                            .phoneController
                                            .text
                                            .isEmpty) {
                                          errors.add(
                                            'Please enter your phone number',
                                          );
                                        } else if (!RegExp(
                                          r'^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$',
                                        ).hasMatch(
                                          controller.phoneController.text,
                                        )) {
                                          errors.add(
                                            'Please enter a valid phone number',
                                          );
                                        }

                                        if (errors.isNotEmpty) {
                                          // Set state to show the first error in the NotificationBanner
                                          setState(() {
                                            showErrorBanner = true;
                                            showSuccessBanner = false;
                                            errorMessage =
                                                errors
                                                    .first; // Display the first error
                                          });
                                          return; // Exit the callback to prevent further processing
                                        }

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
                                              errorMessage = "";
                                            } else {
                                              showSuccessBanner = false;
                                              showErrorBanner = true;
                                              errorMessage =
                                                  controller.addressMessage;
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
                                        color: Color(0xFF30578E),
                                        backgroundColor: Color(0xFFb9d6ff),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget customTextFormField({
    required String hintText,
    TextEditingController? controller,
    bool enabled = true,
    Function(String)? onChanged,
    String? Function(String?)? validator,
    bool isRequired = false,
  }) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 13,
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: hintText,
                  style: GoogleFonts.barlow(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFF414141),
                  ),
                ),
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: GoogleFonts.barlow(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
          ),
        ),
        TextFormField(
          validator: validator,
          controller: controller,
          textAlign: TextAlign.right,
          cursorColor: Color(0xFF414141),
          enabled: enabled,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF414141)),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF414141)),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF414141)),
            ),
            focusedErrorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF414141)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF414141)),
            ),
            errorStyle: TextStyle(height: 0, color: Colors.transparent),
            hintText: '',
            hintStyle: GoogleFonts.barlow(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              height: 1.0,
              letterSpacing: 0.0,
              color: Color(0xFF414141),
            ),
          ),
          style: TextStyle(color: Color(0xFF414141)),
        ),
      ],
    );
  }

  // Placeholder for onWishlistError widget (to be defined based on your codebase)
  Widget onWishlistError(BuildContext context, String errorMessage) {
    // Example implementation, replace with actual onWishlistError widget
    return NotificationBanner(
      iconPath: "assets/icons/error.svg",
      message: errorMessage,
      bannerColor: Color(0xFFF46856),
      textColor: Color(0xFF28292A),
      onClose: () {
        setState(() {
          showErrorBanner = false;
          errorMessage = "";
        });
      },
    );
  }
}
