import 'package:resqlink_server/src/business/matching_service.dart';
import 'package:test/test.dart';

void main() {
  group('MatchingService distance calculation', () {
    test(
      'calculates correct distance between identical coordinates as 0 km',
      () {
        final distance = MatchingService.calculateDistanceKm(
          12.9716,
          77.5946, // Bangalore
          12.9716,
          77.5946,
        );
        expect(distance, closeTo(0.0, 0.001));
      },
    );

    test('calculates approximate distance between known points', () {
      // Bangalore (12.9716° N, 77.5946° E) to Mysore (12.2958° N, 76.6394° E) is ~128-132 km
      final distance = MatchingService.calculateDistanceKm(
        12.9716,
        77.5946,
        12.2958,
        76.6394,
      );
      expect(distance, inInclusiveRange(125.0, 135.0));
    });

    test('calculates short community distance accurately', () {
      // 0.01 deg latitude is approximately 1.11 km
      final distance = MatchingService.calculateDistanceKm(
        12.9700,
        77.5900,
        12.9800,
        77.5900,
      );
      expect(distance, closeTo(1.11, 0.05));
    });
  });
}
