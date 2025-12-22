import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Basic CI/CD test - always passes', () {
    expect(1 + 1, equals(2));
    expect('CI/CD', isNotEmpty);
  });

  test('Pipeline stages test', () {
    final stages = ['lint', 'test', 'build', 'deploy'];
    expect(stages.length, 4);
    expect(stages, contains('test'));
  });

  group('Mathematics', () {
    test('addition', () => expect(2 + 2, 4));
    test('multiplication', () => expect(3 * 3, 9));
    test('division', () => expect(10 / 2, 5));
  });
}