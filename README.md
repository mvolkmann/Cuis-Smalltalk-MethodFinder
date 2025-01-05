# Cuis-Smalltalk-FindByExample

This is a package for Cuis Smalltalk that finds methods by example.
It defines the class `Finder` that has the class method `methodsByExample:`.
That method is passed an array where:

- the first element is a receiver object
- the last element is the expected result
- other objects, if any, are method arguments

It finds all matching method selectors and prints them in the Transcript.

For example:

- `Finder methodsByExample: #('foo', 'Foo')` prints "capitalized".
- `Finder methodsByExample: #( #(1 2 3 4) 2.5)` prints "average" and "mean".

