'From Cuis7.3 [latest update: #6962] on 12 January 2025 at 10:36:01 am'!
'Description '!
!provides: 'FindByExample' 1 90!
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
	instanceVariableNames: 'argumentsInput expectedInput receiverInput'
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

!LabelledInput methodsFor: 'initialization' stamp: 'RMV 1/12/2025 10:18:01'!
buildMorph: labelString
	
	label := LabelMorph contents: labelString.
	
	textModelMorph := TextModelMorph withModel: (TextModel withText: '').
	textModelMorph askBeforeDiscardingEdits: false.
	
	"self borderColor: Color red; borderWidth: 1."
	self separation: 10.
	self padding: 0. "must set AFTER separation"
	self addMorph: label.
	self addMorph: textModelMorph proportionalWidth: 1.! !

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

!MethodFinderWindow methodsFor: 'GUI building' stamp: 'RMV 1/12/2025 10:15:20'!
buildMorphicWindow
	"This was copied from the SearchBrowserWindow class
	and searchBar was modified."
	| findButton row searchBar listPane |
	
	searchBar := LayoutMorph newColumn.
	searchBar separation: 5.
	
	receiverInput := LabelledInput label: 'Receiver:'.
	argumentsInput := LabelledInput label: 'Arguments:'.
	expectedInput := LabelledInput label: 'Expected:'.
	
	"TODO: Disable findButton if receiverInput or expectedInput are empty."
	findButton := PluggableButtonMorph
		model: self
		action: #findMethods
		label: 'Find Methods'.
	"findButton disable."
	findButton layoutSpec offAxisEdgeWeight: #leftOrTop.
	
	searchBar addMorph: receiverInput.
	row := LayoutMorph newRow.
	row addMorph: argumentsInput; addMorph: (LabelMorph contents: '(dot-separated)').
	row axisEdgeWeight: 0.
	searchBar addMorph: row.
	searchBar addMorph: expectedInput.
	searchBar addMorph: findButton.

	listPane := self buildMorphicMessageList.
		
	self layoutMorph
		addMorph: searchBar fixedHeight: 0; "using minimum height that contains children"
		addAdjusterAndMorph: listPane proportionalHeight: 0.40;
		addAdjusterAndMorph: self buildLowerPanes layoutSpec: LayoutSpec useAll	.
		
	model changed: #editSelection.! !

!MethodFinderWindow methodsFor: 'private' stamp: 'RMV 1/12/2025 10:35:10'!
findMethods

	| arguments cl compiledMethod expected methods receiver selectors |
		
	receiver := Compiler evaluate: receiverInput text.
	arguments := Compiler evaluate: '{', argumentsInput text, '}'.
	expected := Compiler evaluate: expectedInput text.
	
	selectors := MethodFinder methodsOn: receiver arguments: arguments expected: expected.
	"TODO: Indicate in UI when no selectors are found."

	cl := receiver class.
	methods := selectors collect: [ :selector |
		compiledMethod := receiver class lookupSelector: selector.
		MethodReference class: compiledMethod methodClass selector: selector.
	].
	
	"SearchBrowser does not provide a setter method for messageList."
	model instVarNamed: #messageList put: methods sort.
	model changed: #messageList.! !

!MethodFinderWindow methodsFor: 'as yet unclassified' stamp: 'RMV 1/12/2025 10:27:53'!
windowColor

	^ Color yellow twiceDarker! !

!MethodFinderWindow class methodsFor: 'as yet unclassified' stamp: 'RMV 1/12/2025 06:46:34'!
open

	^ self open: SearchBrowser new label: 'Method Finder'.! !

!MethodFinderWindow class methodsFor: 'as yet unclassified' stamp: 'RMV 1/12/2025 09:51:10'!
worldMenuOptions
	^ `{{
			#submenuOf -> TheWorldMenu openLabel.
			#itemGroup -> 10.
			
			"Text Editor is 10.
			Worspace is 20.
			Browser is 30.
			SearchBrowser is 40.
			MessageNames is 40.
			Transcript is 50."
			#itemOrder -> 41.
			
			#label -> 'Method Finder'.
			#object -> MethodFinderWindow.
			#selector -> #open.
			#icon -> #inspectIcon.
			#balloonText -> 'A tool for finding methods that return a given answer.'.
		} asDictionary}`! !
MethodFinder initialize!
