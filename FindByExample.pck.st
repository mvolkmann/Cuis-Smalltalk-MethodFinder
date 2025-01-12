'From Cuis7.3 [latest update: #6962] on 12 January 2025 at 8:26:32 am'!
'Description '!
!provides: 'FindByExample' 1 79!
SystemOrganization addCategory: #FindByExample!


!classDefinition: #MethodFinder category: #FindByExample!
MethodSet subclass: #MethodFinder
	instanceVariableNames: ''
	classVariableNames: 'SkipSet'
	poolDictionaries: ''
	category: 'FindByExample'!
!classDefinition: 'MethodFinder class' category: #FindByExample!
MethodFinder class
	instanceVariableNames: ''!

!classDefinition: #LabelledInput category: #FindByExample!
LayoutMorph subclass: #LabelledInput
	instanceVariableNames: 'label textModelMorph'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'FindByExample'!
!classDefinition: 'LabelledInput class' category: #FindByExample!
LabelledInput class
	instanceVariableNames: 'label model'!

!classDefinition: #MethodFinderWindow category: #FindByExample!
SearchBrowserWindow subclass: #MethodFinderWindow
	instanceVariableNames: 'expectedModel receiverModel receiverInput expectedInput findButton'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'FindByExample'!
!classDefinition: 'MethodFinderWindow class' category: #FindByExample!
MethodFinderWindow class
	instanceVariableNames: ''!


!MethodFinder methodsFor: 'as yet unclassified' stamp: 'RMV 1/12/2025 06:39:53'!
findMethods

	| expected methods receiver |
	
	'in FindMethods' print.
	
	receiver := Compiler evaluate: receiverInput text.
	expected := Compiler evaluate: expectedInput text.
	
	methods := MethodFinder methodsOn: receiver arguments: #() expected: expected.
	methods logAs: 'methods'.
! !

!MethodFinder class methodsFor: 'as yet unclassified' stamp: 'RMV 1/7/2025 08:39:35'!
initialize

	"Skip these selectors because they have
	side effects that are bad for this method."
	SkipSet := IdentitySet newFrom: #(
		#addSharedPool:
		#allBroadAccessesTo:
		#allBroadcastAccessesTo:
		#allMethodCategoriesIntegratedThrough:
		#at:
		#basicInspect
		#browseClassHierarchy
		#caseError
		#changed:
		#chooseInstVarAlphabeticallyThenDo:
		#chooseInstVarThenDo:
		#commentStamp:
		#compile:
		#compileAllFrom:
		#confirm:
		#confirm:orCancel:
		#definesInstanceVariableNamedInHierarchy:
		#deprecatedMethod
		#edit
		#editLabel:
		#executeMethod:
		#explore
		#inform:
		#inspect
		#inspectWithLabel:
		#logAs:
		#methodDict:
		#methodDictionary:
		#newFrom:
  		#notify:
		#objectForDataStream:
		#print
		#primitiveError:
		#removeFromSystem
		#removeFromSystem:
		#removeFromSystemUnlogged
		#setName:
		#standardMethodHeaderFor:
		#whichSelectorsReferTo:
		#yourself
		#->
	).! !

!MethodFinder class methodsFor: 'as yet unclassified' stamp: 'RMV 1/10/2025 19:12:11'!
methodsByExample: values
	"Find all methods that return the last value when
	the first value is the receiver and the other values are arguments."
	| arguments expected matches receiver |

	values size < 2 ifTrue: [
		Error signal: 'requires at least two values'
	].

	receiver := values first.
	expected := values last.
	arguments := values allButFirst allButLast.

	matches := self methodsOn: receiver arguments: arguments expected: expected.

	"Write the results to the Transcript."
	matches size = 0
		ifTrue: [ 'no methods found' print ]
		ifFalse: [
			| argString template |
			argString := arguments
				ifEmpty: 'no arguments'
				ifNotEmpty: [ 'arguments {1}' format: { arguments } ].
			template := 'The following methods on {1} with {2} return {3}:'.
			template format: { receiver printString. argString. expected printString} :: print.
			matches asSortedCollection do: [ :match | '- ', match :: print ].
		].! !

!MethodFinder class methodsFor: 'as yet unclassified' stamp: 'RMV 1/10/2025 19:16:04'!
methodsOn: receiverObject arguments: argumentArray expected: expectedObject
	"Find all methods on the receiver object that take the arguments and return expected object."
	| actualObject argCount argumentsCopy matches receiverCopy selectors |

	argCount := argumentArray size.

	"Find all the selectors in the receiver class and its subclasses."	
	selectors := receiverObject class allSelectors.

	"Remove the selectors that do not take the number of arguments provided,
	are ones we want to skip (due to side effects), or are related to halting."
	selectors := selectors reject: [ :selector |
		| thisArgCount |
		thisArgCount := selector first isAlphaNumeric ifTrue: [ selector occurrencesOf: $: ] ifFalse: 1.
		thisArgCount ~= argCount ::
			or: [ SkipSet includes: selector ] ::
			or: [ selector asLowercase includesSubString: 'halt' ]
	].

	"Find all the selectors that return the expected value
	when sent to the receiver with the provided arguments."
	matches := selectors select: [ :selector |
		"Some methods modified the receiver, so we operate on a copy."
		receiverCopy := receiverObject veryDeepCopy.
		
		"Some methods modify arguments, so we operate on a copy."
		argumentsCopy := argumentArray veryDeepCopy.

		actualObject := [receiverCopy perform: selector withArguments: argumentsCopy] on: Error do: [ :ex | nil ].
		actualObject = expectedObject.
	].

	^ matches asSortedCollection.
! !

!LabelledInput methodsFor: 'accessing' stamp: 'RMV 1/10/2025 18:40:24'!
text

	^ textModelMorph model actualContents! !

!LabelledInput methodsFor: 'accessing' stamp: 'RMV 1/12/2025 08:05:30'!
text: aString

	textModelMorph model actualContents: aString! !

!LabelledInput methodsFor: 'private' stamp: 'RMV 1/10/2025 18:30:21'!
label: aString

	label := aString! !

!LabelledInput methodsFor: 'initialization' stamp: 'RMV 1/12/2025 07:53:01'!
buildMorph: labelString
	
	label := LabelMorph contents: labelString.
	
	textModelMorph := TextModelMorph withModel: (TextModel withText: '').
	textModelMorph morphHeight: 15. "TODO: Why must this be set?"
	textModelMorph askBeforeDiscardingEdits: false.
	
	"self borderColor: Color red; borderWidth: 1."
	self separation: 10.
	self padding: 0. "must set AFTER separation"
	self addMorph: label.
	self addMorph: textModelMorph.! !

!LabelledInput methodsFor: 'as yet unclassified' stamp: 'RMV 1/10/2025 18:53:44'!
focus

	textModelMorph focusText! !

!LabelledInput class methodsFor: 'instance creation' stamp: 'RMV 1/10/2025 18:41:00'!
label: aString

	| instance |
	instance := self newRow.
	instance buildMorph: aString.
	^ instance.
! !

!MethodFinderWindow methodsFor: 'GUI building' stamp: 'RMV 1/12/2025 08:23:41'!
buildMorphicWindow
	"This was copied from the SearchBrowserWindow class
	and searchBar was modified."
	| searchBar listPane |
	
	searchBar := LayoutMorph newColumn.
	searchBar separation: 5.
	
	receiverInput := LabelledInput label: 'Receiver:'.
	receiverInput text: '''foo'''.
	searchBar addMorph: receiverInput.
	expectedInput := LabelledInput label: 'Expected:'.
	expectedInput text: '''FOO'''.
	searchBar addMorph: expectedInput.
	findButton := PluggableButtonMorph
		model: self
		action: #findMethods
		label: 'Find Methods'.
	findButton layoutSpec offAxisEdgeWeight: #leftOrTop.
	searchBar addMorph: findButton.

	listPane := self buildMorphicMessageList.
		
	self layoutMorph
		addMorph: searchBar fixedHeight: 0; "using minimum height that contains children"
		addAdjusterAndMorph: listPane proportionalHeight: 0.40;
		addAdjusterAndMorph: self buildLowerPanes layoutSpec: LayoutSpec useAll	.
		
	model changed: #editSelection.! !

!MethodFinderWindow methodsFor: 'private' stamp: 'RMV 1/12/2025 08:26:31'!
findMethods

	| cl expected methods receiver selectors |
		
	receiver := Compiler evaluate: receiverInput text.
	expected := Compiler evaluate: expectedInput text.
	
	"TODO: Get the exact classes that implement each selector instead of assuming they are all in the receiver class."
	selectors := MethodFinder methodsOn: receiver arguments: #() expected: expected.
	cl := receiver class.
	methods := selectors collect: [ :selector | MethodReference class: cl selector: selector ].

	"SearchBrowser does not provide a setter method for messageList."
	model instVarNamed: #messageList put: methods sort.
	model changed: #messageList.! !

!MethodFinderWindow methodsFor: 'initialization' stamp: 'RMV 1/12/2025 08:13:31'!
initialize
	
	super initialize.
	messageList := Array new.
	receiverModel := TextModel withText: ''.
	expectedModel := TextModel withText: ''.
	! !

!MethodFinderWindow class methodsFor: 'as yet unclassified' stamp: 'RMV 1/12/2025 06:46:34'!
open

	^ self open: SearchBrowser new label: 'Method Finder'.! !
MethodFinder initialize!
