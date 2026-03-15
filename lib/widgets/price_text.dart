import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PriceText extends StatelessWidget {
  PriceText(this.price, {super.key, this.style, this.currencyRate = 26000});

  final double price;
  final TextStyle? style;
  final double currencyRate;
  final NumberFormat _formatter = NumberFormat('#,###', 'vi_VN');

  @override
  Widget build(BuildContext context) {
    final text = '${_formatter.format(price * currencyRate)}đ';
    return Text(
      text,
      style:
          style ??
          const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFFD32F2F),
          ),
    );
  }
}
