'From Cuis7.3 [latest update: #6962] on 17 January 2025 at 4:35:53 pm'!
'Description '!
!provides: 'FindByExample' 1 115!
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
	instanceVariableNames: 'argumentsInput expectedInput findButton receiverInput statusLabel'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'FindByExample'!
!classDefinition: 'MethodFinderWindow class' category: #FindByExample!
MethodFinderWindow class
	instanceVariableNames: ''!


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

!MethodFinder class methodsFor: 'as yet unclassified' stamp: 'RMV 1/17/2025 06:42:06'!
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

	"'evaluating {1} selectors' format: { selectors size } :: print."

	"Find all the selectors that return the expected value
	when sent to the receiver with the provided arguments."
	matches := selectors select: [ :selector |
		"selector print."
		
		"Some methods modified the receiver, so we operate on a copy."
		receiverCopy := receiverObject veryDeepCopy.
		
		"Some methods modify arguments, so we operate on a copy."
		argumentsCopy := argumentArray veryDeepCopy.

		actualObject := [receiverCopy perform: selector withArguments: argumentsCopy] on: Error do: [ :ex | nil ].
		actualObject = expectedObject.
	].

	^ matches asSortedCollection.
! !

!LabelledInput methodsFor: 'accessing' stamp: 'RMV 1/14/2025 19:27:40'!
input

	^ textModelMorph! !

!LabelledInput methodsFor: 'accessing' stamp: 'RMV 1/14/2025 19:28:26'!
keystrokeAction: aBlock

	^ textModelMorph keystrokeAction: aBlock! !

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

!LabelledInput methodsFor: 'as yet unclassified' stamp: 'RMV 1/13/2025 08:39:07'!
model

	^ textModelMorph model! !

!LabelledInput class methodsFor: 'instance creation' stamp: 'RMV 1/10/2025 18:41:00'!
label: aString

	| instance |
	instance := self newRow.
	instance buildMorph: aString.
	^ instance.
! !

!MethodFinderWindow methodsFor: 'GUI building' stamp: 'RMV 1/14/2025 19:45:20'!
buildMorphicWindow
	"This was copied from the SearchBrowserWindow class
	and searchBar was modified."
	| findButtonRow searchBar listPane |
	
	searchBar := LayoutMorph newColumn.
	searchBar separation: 5.
	
	findButton := PluggableButtonMorph
		model: self
		action: #findMethods
		label: 'Find Methods'.
	findButton disable.
	findButton layoutSpec offAxisEdgeWeight: #leftOrTop.
	findButtonRow := LayoutMorph newRow.
	findButtonRow addMorph: findButton.
	findButtonRow addMorph: statusLabel.
	
	searchBar addMorph: receiverInput.
	searchBar addMorph: argumentsInput.
	searchBar addMorph: expectedInput.
	searchBar addMorph: findButtonRow.

	listPane := self buildMorphicMessageList.
		
	self layoutMorph
		addMorph: searchBar fixedHeight: 0; "using minimum height that contains children"
		addAdjusterAndMorph: listPane proportionalHeight: 0.40;
		addAdjusterAndMorph: self buildLowerPanes layoutSpec: LayoutSpec useAll.! !

!MethodFinderWindow methodsFor: 'GUI building' stamp: 'RMV 1/16/2025 07:11:35'!
windowColor

	"SearchBrowserWindow is a subclass of MethodSetWindow
	which defines the isntance method windowColor.
	That reutrns Theme current messageSet.
	A different color is used here."
	^ Color yellow twiceDarker! !

!MethodFinderWindow methodsFor: 'private' stamp: 'RMV 1/16/2025 18:46:24'!
evaluate: aString

	^ [ Compiler evaluate: aString ] on: Error do: [ nil ]! !

!MethodFinderWindow methodsFor: 'private' stamp: 'RMV 1/17/2025 16:35:50'!
findMethods
	| arguments compiledMethod expected message methods receiver selectors |
	
	statusLabel contents:​ 'searching for methods'.

	"TODO: How can you prevent `Compiler evaluate:` from writing error messages to Transcript?"
	receiver := [ Compiler evaluate: receiverInput text ] on: Error do: [ nil ].
	receiver ifNil: [
		statusLabel contents: 'Receiver expression is invalid.'.
		^ nil.
	].

	arguments := argumentsInput text isEmpty
		ifTrue: [ #() ]
		ifFalse: [
			| expression |
			expression := '#(', argumentsInput text, ')'.
			[ Compiler evaluate: expression ] on: Error do: [ nil ]
		].
	arguments ifNil: [
		statusLabel contents: 'Arguments expression is invalid.'.
		^ nil.
	].
	
	expected := [ Compiler evaluate: expectedInput text ] on: Error do: [ nil ].
	expected ifNil: [
		statusLabel contents: 'Expected expression is invalid.'.
		^ nil.
	].

	"The remaining code is in a block and run in a new process by sending it `#fork`.
	This is necessary to allow the change to statusLabel above
	to be seen before the code in this block finishes executing."
	[
		selectors := MethodFinder methodsOn: receiver arguments: arguments expected: expected.

		methods := selectors collect: [ :selector |
			compiledMethod := receiver class lookupSelector: selector.
			MethodReference class: compiledMethod methodClass selector: selector.
		].

		message := methods size caseOf: {
			[0] -> [ 'No matching methods were found.' ].
			[1] -> [ '1 method was found.' ]
		} otherwise: [ '{1} methods were found.' format: { methods size } ].
		statusLabel contents: message.
		
		"SearchBrowser does not provide a setter method for messageList."
		model instVarNamed: #messageList put: methods sort.
		model changed: #messageList.
	] fork.! !

!MethodFinderWindow methodsFor: 'private' stamp: 'RMV 1/14/2025 19:42:50'!
handleKeyboardEvent: anEvent
	
	self updateFindButton.
	
	"Clear the status label if it isn't already empty."
	statusLabel contents isEmpty ifFalse: [ statusLabel contents: '' ]! !

!MethodFinderWindow methodsFor: 'private' stamp: 'RMV 1/16/2025 07:59:03'!
updateFindButton
	| haveExpected haveReceiver |
	
	haveReceiver := receiverInput text isEmpty not.
	haveExpected := expectedInput text isEmpty not.
	findButton enable: (haveReceiver and: [haveExpected]).! !

!MethodFinderWindow methodsFor: 'initialization' stamp: 'RMV 1/14/2025 19:43:37'!
initialize

	super initialize.
	
	receiverInput := LabelledInput label: 'Receiver:'.
	argumentsInput := LabelledInput label: 'Arguments (dot-separated):'.
	expectedInput := LabelledInput label: 'Expected:'.
	statusLabel := LabelMorph contents: ''.
	
	receiverInput keystrokeAction: [ :evt | self handleKeyboardEvent: evt ].
	argumentsInput keystrokeAction: [ :evt | self handleKeyboardEvent: evt ].
	expectedInput keystrokeAction: [ :evt | self handleKeyboardEvent: evt ].

! !

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

!PluggableButtonMorph methodsFor: '*FindByExample' stamp: 'RMV 1/16/2025 07:57:30'!
enable: aBoolean

	aBoolean ifTrue: [ self enable ] ifFalse: [ self disable ]! !
MethodFinder initialize!
