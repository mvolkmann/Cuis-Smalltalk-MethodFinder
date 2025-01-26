# Cuis-Smalltalk-MethodFinder

This is a package for Cuis Smalltalk that finds methods by example.

It adds the menu item "Method Finder" to the Open submenu of the World Menu.
This opens a window where Smalltalk expressions can be entered,
one for the receiver object, one for an optional array of arguments,
and one for the expected object.
After entering these, click the "Find Methods" button.
Matching methods are displayed in the middle pane.
Selecting one displays the corresponding method implementation in the bottom pane.

<img alt="Method Finder screenshot" src="./cuis-method-finder.png">

The GUI class `MethodFinderWindow` is a subclass of `SearchBrowserWindow`,
created by Mariano Montone. This is ideal because
it enables easliy implementing a nearly identical UI.

This package also defines the class `MethodFinder`
that has the class method `methodFor:`.
That method must be passed an array where:

- the first element is a receiver object
- the last element is the expected result
- other objects, if any, are method arguments

It finds all matching methods and prints them in the Transcript.

The following examples find instance methods:

- `MethodFinder methodFor: #('foo' 'FOO')` prints `asUppercase` and `translateToUppercase`.
- `MethodFinder methodFor: #('foo', 'Foo')` prints `capitalized`.
- `MethodFinder methodFor: #('foo' 'bar' 'foobar')` prints `,` and `append`.
- `MethodFinder methodFor: #('foo bar' #('foo' 'bar'))` prints `substrings`.
- `MethodFinder methodFor: #('foobar' 'foo' true)` prints `beginsWith:` and more.
- `MethodFinder methodFor: #('foobar' 'bar' true)` prints `endsWith:` and more.
- `MethodFinder methodFor: #('foobar' 'ob' true)` prints `includesString` and more.
- `MethodFinder methodFor: #(1 2 3)` prints ``.
- `MethodFinder methodFor: #(#(1 2 3 4) 2.5)` prints `+` and more.
- `MethodFinder methodFor: #(#(1 2 3 4) 2.5)` prints `average` and `mean`.
- `MethodFinder methodFor: #(#('banana' 'cherry' 'apple') #('apple' 'banana' 'cherry'))` prints `shuffled`, `sort`, and `sorted`.
- `double := [:x | x * 2]. MethodFinder methodFor: { #(1 2 3). double. #(2 4 6) }.` prints `collect:` and 4 more surprising results

The following example finds a class method:

- `MethodFinder methodFor: { Fraction. 2. 314 }` prints `piDigitsAsInteger:`

## Float Comparison

When the expected value is a `Float` and a method returns a `Float`,
it will be considered a match if the values are within 0.001 of each other.
For example, enter `2` for Receiver and `1.414` for Expected
will find the method `SmallInteger sqrt`.
