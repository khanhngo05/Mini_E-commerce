import 'package:flutter_test/flutter_test.dart';

import 'package:mini_e_commerce/main.dart';

void main() {
  testWidgets('Hien thi man hinh khoi tao TH4', (WidgetTester tester) async {
    await tester.pumpWidget(const MiniECommerceApp());

    expect(find.text('TH4 - Nhom [So nhom]'), findsOneWidget);
    expect(find.text('Mini E-Commerce - Commit 1 setup'), findsOneWidget);
  });
}
