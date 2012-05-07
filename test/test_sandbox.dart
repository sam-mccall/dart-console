#library('test_sandbox');
#import('../lib/sandbox.dart');

test(callback(sandbox)) => (){ callback(new Sandbox()); };

get TESTS() => {
  'simpleStatement': test((sandbox) {
    Expect.equals(4, sandbox.execute('return 2+2;'));
  }),
  'compoundStatement': test((sandbox) {
    Expect.equals(4, sandbox.execute('x = 3; return 4; x = 5;'));
    Expect.equals(3, sandbox.variables['x']);
  }),
  'throwStatement': test((sandbox) {
    Expect.throws(() => sandbox.execute('throw 42;'), (e) => (e == 42));
  }),
  'statementSetVariable': test((sandbox) {
    sandbox.execute('x = 42;');
    Expect.equals(42, sandbox.variables['x']);
  }),
  'statementGetVariable': test((sandbox) {
    sandbox.variables['x'] = 42;
    Expect.equals(44, sandbox.execute('return x + 2;'));
  }),
  'statementSetVariableThroughList': test((sandbox) {
    sandbox.execute('VARIABLES["x"] = 42;');
    Expect.equals(42, sandbox.variables['x']);
  }),
  'statementGetVariableThroughList': test((sandbox) {
    sandbox.variables['x'] = 42;
    Expect.equals(44, sandbox.execute('return VARIABLES["x"] + 2;'));
  }),

  'simpleExpression': test((sandbox) {
    Expect.equals(4, sandbox.eval('2+2'));
  }),
  'throwExpression': test((sandbox) {
    Expect.throws(() => sandbox.eval('(){throw 42;}()'), (e) => (e == 42));
  }),
  'expressionSetVariable': test((sandbox) {
    Expect.equals(44, sandbox.eval('(x = 42) + 2'));
    Expect.equals(42, sandbox.variables['x']);
  }),
  'expressionGetVariable': test((sandbox) {
    sandbox.variables['x'] = 42;
    Expect.equals(44, sandbox.eval('x + 2'));
  }),

  'simpleDeclaration': test((sandbox) {
    sandbox.declare('x() { return 42; }');
    Expect.equals(42, sandbox.eval('x()'));
  }),
  'lambdaDeclaration': test((sandbox) {
    sandbox.declare('x() => 42;');
    Expect.equals(42, sandbox.eval('x()'));
  }),

  'redeclarationFails': test((sandbox) { // Documented issue
    sandbox.declare('x() => 42;');
    Expect.throws(() => sandbox.declare('x() => 42;'));
  }),
  'closureReassignment': test((sandbox) { // Documented workaround
    sandbox.execute('x = () => 42;');
    Expect.equals(42, sandbox.eval('x()'));
    sandbox.execute('x = () => 43;');
    Expect.equals(43, sandbox.eval('x()'));
  }),

  'assignToGlobalWithinDeclarationFails': test((sandbox) { // Documented issue
    sandbox.declare('foo() { x = 42; }');
    Expect.throws(() => sandbox.execute('foo();'));
  }),
  'assignToGlobalWithinDeclarationAfterInitialization': test((sandbox) { // Documented workaround
    sandbox.execute('x = null;');
    sandbox.declare('foo() { x = 42; }');
    sandbox.execute('foo();');
    Expect.equals(42, sandbox.variables['x']);
  }),
  'assignToGlobalWithinDeclarationUsingMap': test((sandbox) { // Documented workaround
    sandbox.declare('foo() { VARIABLES["x"] = 42; }');
    sandbox.execute('foo();');
    Expect.equals(42, sandbox.variables['x']);
  }),

  'writeToVariableFromDeclarationThenReadFromAnotherDeclaration': test((sandbox) { // bugfix
    sandbox.declare('foo() { VARIABLES["x"] = 42; }');
    sandbox.declare('bar() => x;');
    sandbox.execute('foo();');
    Expect.equals(42, sandbox.eval('bar()'));
  }),

  'importFails': test((sandbox) { // Documented issue
    Expect.throws(() => sandbox.import('bar.dart'));
  }),
  'ioAvailable': test((sandbox) { // Documented workaround
    Expect.isNotNull(sandbox.eval('io.stdout'));
  }),
};