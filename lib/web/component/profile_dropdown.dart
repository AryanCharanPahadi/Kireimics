import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../component/routes.dart' show AppRoutes;

class ProfileDropdown extends StatefulWidget {
  final bool isVisible;
  final VoidCallback onClose;

  const ProfileDropdown({
    super.key,
    required this.isVisible,
    required this.onClose,
  });

  @override
  State<ProfileDropdown> createState() => _ProfileDropdownState();
}

class _ProfileDropdownState extends State<ProfileDropdown> {
  final GlobalKey _dropdownKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapDown: (details) {
              final RenderBox? dropdownBox =
                  _dropdownKey.currentContext?.findRenderObject() as RenderBox?;
              if (dropdownBox != null) {
                final dropdownPosition = dropdownBox.localToGlobal(Offset.zero);
                final dropdownSize = dropdownBox.size;
                final tapPosition = details.globalPosition;
                final isInDropdown =
                    tapPosition.dx >= dropdownPosition.dx &&
                    tapPosition.dx <=
                        dropdownPosition.dx + dropdownSize.width &&
                    tapPosition.dy >= dropdownPosition.dy &&
                    tapPosition.dy <= dropdownPosition.dy + dropdownSize.height;
                if (isInDropdown) {
                  return;
                }
              }
              widget.onClose();
            },
          ),
        ),
        Positioned(
          top: 99,
          right: 32,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: Material(
              elevation: 4,
              child: Container(
                key: _dropdownKey,
                width: 180,
                padding: const EdgeInsets.symmetric(vertical: 16),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          print("Log In / Sign Up tapped (external)");
                          widget.onClose();
                          context.go('/log-in');
                        },
                        child: const Text(
                          'LOG IN / SIGN UP',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF3E5B84),
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(color: Color(0xFF3E5B84)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          print("My Account tapped (external)");
                          widget.onClose();
                          context.go(AppRoutes.myAccount);
                        },
                        child: const Text(
                          'My Account',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF3E5B84),
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          print("My Orders tapped (external)");
                          widget.onClose();
                          context.go(AppRoutes.myOrder); // Placeholder route
                        },
                        child: const Text(
                          'My Orders',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF3E5B84),
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          print("My Wishlist tapped (external)");
                          widget.onClose();
                          context.go(AppRoutes.wishlist); // Placeholder route
                        },
                        child: const Text(
                          'My Wishlist',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF3E5B84),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
