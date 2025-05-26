import 'package:flutter/material.dart';
import '../../models/panic_button_model.dart';

class PanicButtonCard extends StatelessWidget {
  final PanicButtonModel button;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const PanicButtonCard({
    super.key,
    required this.button,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Icon? callIcon;
    switch (button.callTarget) {
      case CallTarget.police:
        callIcon = const Icon(Icons.local_police, color: Colors.white70, size: 20);
        break;
      case CallTarget.ambulance:
        callIcon = const Icon(Icons.local_hospital, color: Colors.white70, size: 20);
        break;
      case CallTarget.contact:
        callIcon = const Icon(Icons.phone, color: Colors.white70, size: 20);
        break;
      default:
        callIcon = null;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Color(button.color),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
                  ],
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      button.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (callIcon != null)
              Positioned(
                bottom: 8,
                left: 16,
                child: callIcon,
              ),
            Positioned(
              top: 4,
              right: 4,
              child: InkWell(
                onTap: onDelete,
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close, color: Colors.white70, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
