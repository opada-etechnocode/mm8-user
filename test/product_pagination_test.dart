import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';

void main() {
  group('ProductController pagination deduplication', () {
    test('should keep only unique products when appending the next page', () {
      final page1 = [
        Product(id: 1, name: 'A'),
        Product(id: 2, name: 'B'),
      ];
      final page2 = [
        Product(id: 2, name: 'B'),
        Product(id: 3, name: 'C'),
      ];

      final merged = ProductController.mergeUniqueProducts(page1, page2);

      expect(merged.map((e) => e.id), [1, 2, 3]);
    });
  });
}
