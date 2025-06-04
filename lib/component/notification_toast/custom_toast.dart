import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NotificationBanner extends StatelessWidget {
  final String message;
  final String? iconPath;
  final Color? bannerColor;
  final Color? textColor;
  final VoidCallback? onClose;
  final bool showCloseButton;
  final bool confirmation;
  final String yesText;
  final String noText;
  final VoidCallback? onYes;
  final VoidCallback? onNo;

  const NotificationBanner({
    super.key,
    required this.message,
    this.iconPath,
    this.bannerColor,
    this.textColor,
    this.onClose,
    this.showCloseButton = true,
    this.confirmation = false,
    this.yesText = 'Yes',
    this.noText = 'No',
    this.onYes,
    this.onNo,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        color: Colors.white,
        height: confirmation ? 100 : 56,
        constraints: const BoxConstraints(minWidth: 200, maxWidth: 350),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  color: bannerColor ?? const Color(0xFF2876E4),
                  height: confirmation ? 100 : 56,
                  width: 10,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  if (iconPath != null)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: SvgPicture.asset(iconPath!),
                                    ),
                                  Expanded(
                                    child: Text(
                                      message,
                                      style: TextStyle(
                                        color: textColor ?? Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!confirmation)
                              if (showCloseButton)
                                IconButton(
                                  icon: const Icon(Icons.close, size: 16),
                                  onPressed: onClose,
                                ),
                          ],
                        ),
                        if (confirmation)
                          Padding(
                            padding: const EdgeInsets.only(top: 12, left: 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                TextButton(
                                  onPressed: onNo,
                                  child: Text(
                                    noText,
                                    style: TextStyle(
                                      color: textColor ?? Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: onYes,
                                  child: Text(
                                    yesText,
                                    style: TextStyle(
                                      color: textColor ?? Colors.black,
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
