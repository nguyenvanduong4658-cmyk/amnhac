import 'package:flutter/material.dart';
import 'card_widget.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      // đúng chiều cao của grid
      physics: const NeverScrollableScrollPhysics(),
      // không cho phép cuộn
      childAspectRatio: 1.2,
      // width = 1.2 x height
      children: [
        CartItem(icon: Icons.phone_android, title: "Phone"),
        CartItem(icon: Icons.laptop, title: "Laptop"),
        CartItem(icon: Icons.watch, title: "Watch"),
        CartItem(icon: Icons.tv, title: "TV"),
      ],
    );
  }
}