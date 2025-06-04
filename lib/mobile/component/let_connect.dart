import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../component/text_fonts/custom_text.dart';
import '../../component/custom_text_form_field/custom_text_form_field.dart';

class LetConnect extends StatefulWidget {
  const LetConnect({super.key});

  @override
  State<LetConnect> createState() => _LetConnectState();
}

class _LetConnectState extends State<LetConnect> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _anotherMessageController =
  TextEditingController();
  FocusNode _messageFocusNode = FocusNode();
  FocusNode _anotherMessageFocusNode = FocusNode();
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();

    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Form is valid, proceed with submission
      // You can access the values using:
      // _nameController.text, _emailController.text, _messageController.text

      // Show success message or perform submission logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form submitted successfully!')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 550,
      margin: const EdgeInsets.only(top: 27),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage("assets/home_page/background.png"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            const Color(0xFF2472e3).withOpacity(0.9),
            BlendMode.srcATop,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 44),
        child: Center(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Ensures left alignment
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: 300,

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Ensures left alignment
                  children: [
                    CralikaFont(
                     text:  "Let's Connect!",
                      fontWeight: FontWeight.w400,
                      fontSize: 24,
                      lineHeight: 1.5,
                      letterSpacing: 0.96,
                      color: Color(0xFFFFFFFF),

                    ),
                    SizedBox(height: 7.0),
                    BarlowText(
                    text:   "Looking for gifting options, or want to get a piece commissioned? Let's connect and create something wonderful!",
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      lineHeight: 1.0,
                      letterSpacing: 0.0,
                    ),
                  ],
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Ensures left alignment
                  children: [
                    SizedBox(
                      width: 300,
                      child:  CustomTextFormField(
                        hintText: "YOUR NAME",
                        maxLength: 20,
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 300,
                      child: CustomTextFormField(
                        hintText: "YOUR EMAIL",
                        isEmail: true,
                        controller: _emailController,
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
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 300,
                      child: CustomTextFormField(
                        hintText: "MESSAGE",
                        controller: _messageController,
                        isMessageField: true,
                        focusNode: _messageFocusNode,
                        nextFocusNode: _anotherMessageFocusNode,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a message';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 300,
                      child: CustomTextFormField(
                        hintText:
                        "", // Empty hint text for continuation
                        controller: _anotherMessageController,
                        focusNode: _anotherMessageFocusNode,
                        maxLength: 40,
                      ),
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: 300,

                      child: Align(
                        alignment:
                        Alignment
                            .centerRight, // Aligns the submit button to the left
                        child:  GestureDetector(
                          onTap: () {
                            _submitForm();
                          },
                          child: BarlowText(
                            text: "SUBMIT",
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            lineHeight: 1.0,
                            letterSpacing: 0.64,
                            backgroundColor: Color(0xFFb9d6ff),
                            enableHoverBackground: true,
                            color: Color(0xFF30578E),
                            hoverTextColor: Color(0xFFb9d6ff),
                          ),
                        ),
                      ),
                    ),


                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget customTextFormField({
    required String hintText,
    TextEditingController? controller,
  }) {
    return Stack(
      children: [
        // Hint text positioned on the left
        Positioned(
          left: 0,
          top: 16, // Adjust this value to align vertically
          child: Text(
            hintText,
            style: GoogleFonts.barlow(fontSize: 14, color: Colors.white),
          ),
        ),
        // Text field with right-aligned input
        TextFormField(
          controller: controller,
          cursorColor: Colors.white,
          textAlign: TextAlign.right, // Align user input to the right
          decoration: InputDecoration(
            hintStyle: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontFamily: GoogleFonts.barlow().fontFamily,
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            contentPadding: const EdgeInsets.only(top: 16),
          ),
          style: TextStyle(
            color: Colors.white,
            fontFamily: GoogleFonts.barlow().fontFamily,
          ),
        ),
      ],
    );
  }
}
