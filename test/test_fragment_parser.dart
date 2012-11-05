#library('test_fragment_parser');
#import('../lib/fragment_parser.dart');

expectParsesAs(expectedState, text) => () {
  Expect.equals(expectedState, new FragmentParser().append(text).state);
};
incomplete(text) => expectParsesAs(FragmentParser.INCOMPLETE, text);
expression(text) => expectParsesAs(FragmentParser.EXPRESSION, text);
statement(text) => expectParsesAs(FragmentParser.STATEMENT, text);
declaration(text) => expectParsesAs(FragmentParser.DECLARATION, text);

get TESTS => {
  'simpleExpression': expression('2+2'),
  'functionCallExpression': expression('x()'),
  'untypedMapLiteral': expression('{"x": 42}'),
  'singleTypedMapLiteral': expression('<num>{"x": 42}'),
  'doubleTypedMapLiteral': expression('<string, num>{"x": 42}'),
  'lambdaWithoutSemicolonIsExpression': expression('x() => 42'), // Documented issue

  'functionDeclaration': declaration('x() { return 42; }'),
  'lambdaFunctionDeclaration': declaration('x() => 42;'),
  'typedLambdaGetterDeclaration': declaration('int get x => 42;'),
  'class': declaration('class Foo { var x, y; }'),

  'functionCallStatement': statement('print("42");'),
  'compoundStatement': statement('print("42"); x();'),

  'incompleteTripleQuotes': incomplete(r'"""multilinestring'),
  'incompleteFunctionDecl': incomplete(r"main(){"),
  'incompleteParens': incomplete(r"print("),
  'incompleteBrackets': incomplete(r"[1,"),

  'mismatchedBrackets': expression(r"foo())"), // handled by eval
};
