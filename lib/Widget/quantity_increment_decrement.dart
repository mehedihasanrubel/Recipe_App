import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/quantity_provider.dart';

class QuantityIncrementDecrement extends StatelessWidget {
  const QuantityIncrementDecrement({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final quantityProvider = Provider.of<QuantityProvider>(context);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => quantityProvider.decreaseQuantity(),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: quantityProvider.currentNumber > 1
                      ? Theme.of(context).cardColor
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.remove,
                  size: 18,
                  color: quantityProvider.currentNumber > 1
                      ? (isDark ? Colors.white : Colors.black87)
                      : Colors.grey,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${quantityProvider.currentNumber}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => quantityProvider.increaseQuantity(),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, size: 18, color: isDark ? Colors.white : Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }
}