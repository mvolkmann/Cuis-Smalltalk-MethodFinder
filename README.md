# Cuis-Smalltalk-FindByExample

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
that has the class method `find:`.
That method must be passed an array where:

- the first element is a receiver object
- the last element is the expected result
- other objects, if any, are method arguments

It finds all matching methods and prints them in the Transcript.

The following examples find instance methods:

- `MethodFinder find: #('foo' 'FOO')` prints `asUppercase` and `translateToUppercase`.
- `MethodFinder find: #('foo', 'Foo')` prints `capitalized`.
- `MethodFinder find: #('foo' 'bar' 'foobar')` prints `,` and `append`.
- `MethodFinder find: #('foo bar' #('foo' 'bar'))` prints `substrings`.
- `MethodFinder find: #('foobar' 'foo' true)` prints `beginsWith:` and more.
- `MethodFinder find: #('foobar' 'bar' true)` prints `endsWith:` and more.
- `MethodFinder find: #('foobar' 'ob' true)` prints `includesString` and more.
- `MethodFinder find: #(1 2 3)` prints ``.
- `MethodFinder find: #(#(1 2 3 4) 2.5)` prints `+` and more.
- `MethodFinder find: #(#(1 2 3 4) 2.5)` prints `average` and `mean`.
- `MethodFinder find: #(#('banana' 'cherry' 'apple') #('apple' 'banana' 'cherry'))` prints `shuffled`, `sort`, and `sorted`.
- `double := [:x | x * 2]. MethodFinder find: { #(1 2 3). double. #(2 4 6) }.` prints `collect:` and 4 more surprising results

The following example finds a class method:

- `MethodFinder find: { Fraction. 2. 314 }` prints `piDigitsAsInteger:`
