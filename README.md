# Cuis-Smalltalk-FindByExample

This is a package for Cuis Smalltalk that finds methods by example.
It defines the class `Finder` that has the class method `methodsByExample:`.
That method is passed an array where:

- the first element is a receiver object
- the last element is the expected result
- other objects, if any, are method arguments

It finds all matching method selectors and prints them in the Transcript.

The following examples find instance methods:

- `MethodFinder methodsByExample: #('foo' 'FOO')` prints `asUppercase` and `translateToUppercase`.
- `MethodFinder methodsByExample: #('foo', 'Foo')` prints `capitalized`.
- `MethodFinder methodsByExample: #('foo' 'bar' 'foobar')` prints `,` and `append`.
- `MethodFinder methodsByExample: #('foo bar' #('foo' 'bar'))` prints `substrings`.
- `MethodFinder methodsByExample: #('foobar' 'foo' true)` prints `beginsWith:` and more.
- `MethodFinder methodsByExample: #('foobar' 'bar' true)` prints `endsWith:` and more.
- `MethodFinder methodsByExample: #('foobar' 'ob' true)` prints `includesString` and more.
- `MethodFinder methodsByExample: #(1 2 3)` prints ``.
- `MethodFinder methodsByExample: #(#(1 2 3 4) 2.5)` prints `+` and more.
- `MethodFinder methodsByExample: #(#(1 2 3 4) 2.5)` prints `average` and `mean`.
- `MethodFinder methodsByExample: #(#('banana' 'cherry' 'apple') #('apple' 'banana' 'cherry'))` prints `shuffled`, `sort`, and `sorted`.
- `double := [:x | x * 2]. MethodFinder methodsByExample: { #(1 2 3). double. #(2 4 6) }.` prints `collect:` and 4 more surprising results

The following example finds a class method:

- `MethodFinder methodsByExample: { Fraction. 2. 314 }` prints `piDigitsAsInteger:`
