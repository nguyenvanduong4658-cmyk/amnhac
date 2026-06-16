import 'package:flutter/material.dart';
import '../../models/product.dart';
import 'package:intl/intl.dart';
import '../../constants/app_assets.dart' as appsetting;

class CartItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const CartItem({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.purple,
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: Colors.blue),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class CardItemList extends StatelessWidget {
  CardItemList({super.key, required this.p});

  final Product p;
  final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: Image.asset(
          appsetting.AppAssets.getImage(p.image!),
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        ),
        title: Text(p.name!, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(formatter.format(p.price)),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}