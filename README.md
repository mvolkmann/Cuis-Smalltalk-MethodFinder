# Cuis-Smalltalk-FindByExample

This is a package for Cuis Smalltalk that finds methods by example.
It defines the class `Finder` that has the class method `methodsByExample:`.
That method is passed an array where:

- the first element is a receiver object
- the last element is the expected result
- other objects, if any, are method arguments

It finds all matching method selectors and prints them in the Transcript.

For example:

- `Finder methodsByExample: #('foo' 'FOO')` prints `asUppercase` and `translateToUppercase`.
- `Finder methodsByExample: #('foo', 'Foo')` prints `capitalized`.
- `Finder methodsByExample: #('foo' 'bar' 'foobar')` prints `,` and `append`.
- `Finder methodsByExample: #('foo bar' #('foo' 'bar'))` prints `substrings`.
- `Finder methodsByExample: #('foobar' 'foo' true)` prints `beginsWith:` and more.
- `Finder methodsByExample: #('foobar' 'bar' true)` prints `endsWith:` and more.
- `Finder methodsByExample: #('foobar' 'ob' true)` prints `includesString` and more.
- `Finder methodsByExample: #(1 2 3)` prints ``.
- `Finder methodsByExample: #(#(1 2 3 4) 2.5)` prints `+` and more.
- `Finder methodsByExample: #(#(1 2 3 4) 2.5)` prints `average` and `mean`.
- `Finder methodsByExample: #(#('banana' 'cherry' 'apple') #('apple' 'banana' 'cherry'))` prints `shuffled`, `sort`, and `sorted`.

