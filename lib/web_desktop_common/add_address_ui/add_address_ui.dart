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
    // Populate form fields if editing
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
                              color: Color(0xFF3E5B84),
                              fontWeight: FontWeight.w600,
                              fontSize: 16.0,
                              lineHeight: 1.0,
                              letterSpacing: 0.64,
                              hoverBackgroundColor: Color(0xFFb9d6ff),
                              enableHoverBackground: true,
                            ),
                          ),
                          if (showSuccessBanner || showErrorBanner)
                            NotificationBanner(
                              message:
                                  showSuccessBanner
                                      ? (widget.isEditing
                                          ? "Updated successfully!"
                                          : "Added successfully!")
                                      : errorMessage,
                              bannerColor:
                                  showSuccessBanner ? Colors.green : Colors.red,
                              textColor: Colors.black,
                              onClose: () {
                                setState(() {
                                  showSuccessBanner = false;
                                  showErrorBanner = false;
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
                                SizedBox(width: 32),
                                Expanded(
                                  child: Obx(
                                    () => customTextFormField(
                                      hintText:
                                          controller.isPincodeLoading.value
                                              ? "Loading..."
                                              : "STATE*",
                                      controller: controller.stateController,
                                      enabled:
                                          !controller.isPincodeLoading.value,
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
                            Row(
                              children: [
                                Expanded(
                                  child: Obx(
                                    () => customTextFormField(
                                      hintText:
                                          controller.isPincodeLoading.value
                                              ? "Loading..."
                                              : "CITY*",
                                      controller: controller.cityController,
                                      enabled:
                                          !controller.isPincodeLoading.value,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your city';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(width: 32),
                                Expanded(
                                  child: customTextFormField(
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
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Obx(
                                  () => Checkbox(
                                    value: controller.isChecked.value,
                                    onChanged: controller.toggleCheckbox,
                                    activeColor: Color(0xFF3E5B84),
                                  ),
                                ),
                                SizedBox(width: 19),
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
                                        color: Color(0xFF3E5B84),
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
  }) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 13,
          child: Text(
            hintText,
            style: GoogleFonts.barlow(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Color(0xFF414141),
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
            errorStyle: TextStyle(color: Colors.red),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF414141)),
            ),
            hintText: '',
            hintStyle: GoogleFonts.barlow(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              height: 1.0,
              letterSpacing: 0.0,
              color: Color(0xFF414141),
            ),
            contentPadding: EdgeInsets.only(top: 16),
          ),
          style: TextStyle(color: Color(0xFF414141)),
        ),
      ],
    );
  }
}
