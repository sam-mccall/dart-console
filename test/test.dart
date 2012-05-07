#import('dart:io');
#import('test_sandbox.dart', prefix: 'sandbox');
#import('test_fragment_parser.dart', prefix: 'fragment_parser');

main() {
  var pass = true;
  pass = test('sandbox', sandbox.TESTS) && pass;
  pass = test('fragment_parser', fragment_parser.TESTS) && pass;
  if (!pass) exit(1);
}

test(suitename, tests) {
  var failures = [];
  stdout.writeString('$suitename [');
  tests.forEach((name, test) {
    try {
      test();
      stdout.writeString('.');
    } catch (Object e) {
      stdout.writeString('X');
      failures.add([name, e]);
    }
  });
  stdout.writeString(']\n');
  failures.forEach((failure) {
    print("=== ${failure[0]} ===");
    print(failure[1]);
    print("");
  });
}