import 'package:test/test.dart';

final Matcher isAssertionError = isA<AssertionError>();
final Matcher throwsAssertionError = throwsA(isAssertionError);
