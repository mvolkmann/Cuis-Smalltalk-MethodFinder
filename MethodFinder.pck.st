'From Cuis7.3 [latest update: #7045] on 9 February 2025 at 3:18:32 pm'!
'Description '!
!provides: 'MethodFinder' 1 175!
!requires: 'SearchBrowser' 1 45 nil!
SystemOrganization addCategory: #MethodFinder!


!classDefinition: #MethodFinder category: #MethodFinder!
MethodSet subclass: #MethodFinder
	instanceVariableNames: ''
	classVariableNames: 'SkipSet'
	poolDictionaries: ''
	category: 'MethodFinder'!
!classDefinition: 'MethodFinder class' category: #MethodFinder!
MethodFinder class
	instanceVariableNames: ''!

!classDefinition: #LabelledInput category: #MethodFinder!
LayoutMorph subclass: #LabelledInput
	instanceVariableNames: 'label textModelMorph'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'MethodFinder'!
!classDefinition: 'LabelledInput class' category: #MethodFinder!
LabelledInput class
	instanceVariableNames: 'label model'!

!classDefinition: #MethodFinderWindow category: #MethodFinder!
SearchBrowserWindow subclass: #MethodFinderWindow
	instanceVariableNames: 'argumentsInput expectedInput findButton receiverInput statusLabel'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'MethodFinder'!
!classDefinition: 'MethodFinderWindow class' category: #MethodFinder!
MethodFinderWindow class
	instanceVariableNames: ''!


!MethodFinder methodsFor: 'initialization' stamp: 'RMV 1/26/2025 09:34:22'!
initialize

	super initialize.
	
	messageList := Array new. "Why doesn't MethodSet initialize this?"! !

!MethodFinder class methodsFor: 'class initialization' stamp: 'RMV 1/21/2025 07:16:30'!
initialize
	"Populate the SkipSet class variable."
	
	"Skip these selectors because they have
	side effects that are bad for this method.
	In addition to these, the ? method also skips all methods
	defined in the Behavior, ChangeSet, and ClassDescription classes."
	SkipSet := IdentitySet newFrom: #(
		#addSharedPool:
		#allBroadcastAccessesTo:
		#at:
		#basicInspect
		#become
		#benchmark
		#browseClassHierarchy
		#caseError
		#changed:
		#chooseAlignment
		#chooseColor
		#chooseInstanceVariable
		#chooseRecentClipping
		#confirm:
		#confirm:orCancel:
		#copyToClipboard
		#deprecatedMethod
		#edit
		#editLabel:
		#errorImproperStore
		#executeMethod:
		#explore
		#inboundPointers
		#inform:
		#inspect
		#inspectWithLabel:
		#logAs:
		#longPrintString
		#longPrintText
		#mourn
		#mustBeBoolean
		#newFrom:
		#nextInstance
		#nextObject
  		#notify:
		#notYetImplemented
		#outboundPointers
		#pin
		#print
		#primitiveError:
		#profilerFriendlyCall:
		#removeFromSystem
		#removeFromSystem:
		#removeFromSystemUnlogged
		#removeUnmodifiedCategories
		#removeUnmodifiedClasses
		#removeUnmodifiedMethods
		#removeUnmodifiedMethods:
		#removeUnreferencedKeys
		#removeUnusedTempRange:with:
		#removeUnusedTempsOf:
		#removeUnusedTempsRanges:
		#removeUpToDate
		#setName:
		#shouldFileOutPool:
		#shouldFileOutPools
		#shouldNotHappen
		#shouldNotImplement
		#shutdown
		#someObject
		#subclassResponsibility
		#tinyBenchmarks
		#tryPrimitive:withArgs:
		#unload
		#unpin
		#withCaption:chooseFrom:
		#yourself
		#zapSourcePointer
		#->
	).! !

!MethodFinder class methodsFor: 'utilities' stamp: 'RMV 1/27/2025 16:08:47'!
methodFor: anArray

	| arguments compiledMethod expected receiver selectors |
	
	anArray isKindOf: SequenceableCollection :: ifFalse: [
		'argument must be a kind of SequenceableCollection' print.
		^ nil.
	].
	anArray size < 2 ifTrue: [
		'must supply at least two expressions' print.
		^ nil.
	].
	
	receiver := anArray first.
	expected := anArray last.
	arguments := anArray allButFirst allButLast.
	selectors := self selectorsFor: receiver arguments: arguments expected: expected.
		
	self message: selectors :: print.
	
	selectors do: [ :selector |
		compiledMethod := receiver class lookupSelector: selector.
		'- {1} {2}' format: { compiledMethod methodClass. compiledMethod selector } :: print.
	].! !

!MethodFinder class methodsFor: 'private' stamp: 'RMV 1/21/2025 07:00:48'!
class: aClass understands: selector

	^ aClass canUnderstand: selector :: or: [ aClass canUnderstand: selector ]
! !

!MethodFinder class methodsFor: 'private' stamp: 'RMV 1/26/2025 08:20:46'!
matchesIn: selectors receiver: receiverObject arguments: argumentArray expected: expectedObject
	"Find all methods on the receiver object that take the arguments and return expected object."
	| actualObject argumentsCopy matches receiverCopy |
	
	"count := 0."

	"Find all the selectors that return the expected value
	when sent to the receiver with the provided arguments."
	matches := selectors select: [ :selector |
		"count := count + 1.
		'{1}: {2}' format: { count. selector } :: print."
			
		"Some methods modified the receiver, so we operate on a copy."
		receiverCopy := receiverObject veryDeepCopy.
		
		"Some methods modify arguments, so we operate on a copy."
		argumentsCopy := argumentArray veryDeepCopy.
		
		"See comment below.
		startTime := Time now."
		
		actualObject :=
			[receiverCopy perform: selector withArguments: argumentsCopy]
				on: Error
				do: [ :ex | nil ].
		"actualObject logAs: 'actualObject'."
		
		"Use this code to find methods that take too long to run.
		durationNanos := (Time now - startTime) totalNanoSeconds.
		durationNanos > 70000 ifTrue: [
			'{1} ran for {2}' format: { selector. durationNanos } :: print.
		]."
		
		actualObject isKindOf: Float :: and: [ expectedObject isKindOf: Float] ::
			ifTrue: [ actualObject  - expectedObject :: abs <= 0.001 ]
			ifFalse: [ actualObject = expectedObject ].
	].

	^ matches asSortedCollection.
! !

!MethodFinder class methodsFor: 'private' stamp: 'RMV 1/26/2025 07:34:15'!
message: selectorColl

	^ selectorColl size caseOf: {
		[0] -> [ 'No matching methods were found.' ].
		[1] -> [ '1 matching method was found.' ]
	} otherwise: [ '{1} matching methods were found.' format: { selectorColl size } ].! !

!MethodFinder class methodsFor: 'private' stamp: 'RMV 1/21/2025 07:01:34'!
selectorsFor: receiverObject arguments: aNumber
	"Answer all selectors on the receiver object that take a given number of arguments."
	| selectors |

	"Find all the selectors in the receiver class and its subclasses."	
	selectors := receiverObject class allSelectors.

	"Return only the selectors take the number of arguments provided,
	and skip those that have bad side effects."
	^​ selectors reject: [ :selector |
		| thisArgCount |
		thisArgCount := selector first isAlphaNumeric ifTrue: [ selector occurrencesOf: $: ] ifFalse: 1.
		thisArgCount ~= aNumber ::
			or: [ SkipSet includes: selector ] ::
			or: [ self class: Behavior understands: selector] ::
			or: [ self class: ChangeSet understands: selector] ::
			or: [ self class: ClassDescription understands: selector] ::
			or: [ selector asLowercase includesSubString: 'halt' ] ::
			or: [ selector beginsWith: 'fileOut' ] ::
			or: [ selector beginsWith: 'handleFailing' ].
	].! !

!MethodFinder class methodsFor: 'private' stamp: 'RMV 1/19/2025 08:03:53'!
selectorsFor: receiverObject arguments: argumentArray expected: expectedObject
	"Answer all selectors on the receiver object that take the arguments and return expected object.
	This combines the use of two other class methods in this class."
	| selectors |

	selectors := self selectorsFor: receiverObject arguments: argumentArray size.
	^ self
		matchesIn: selectors
		receiver: receiverObject
		arguments: argumentArray
		expected: expectedObject.! !

!LabelledInput methodsFor: 'accessing' stamp: 'RMV 1/14/2025 19:27:40'!
input

	^ textModelMorph! !

!LabelledInput methodsFor: 'accessing' stamp: 'RMV 1/14/2025 19:28:26'!
keystrokeAction: aBlock

	^ textModelMorph keystrokeAction: aBlock! !

!LabelledInput methodsFor: 'accessing' stamp: 'RMV 1/13/2025 08:39:07'!
model

	^ textModelMorph model! !

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

!LabelledInput class methodsFor: 'instance creation' stamp: 'RMV 1/10/2025 18:41:00'!
label: aString

	| instance |
	instance := self newRow.
	instance buildMorph: aString.
	^ instance.
! !

!MethodFinderWindow methodsFor: 'GUI building' stamp: 'RMV 1/18/2025 10:06:37'!
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

!MethodFinderWindow methodsFor: 'private' stamp: 'RMV 1/18/2025 13:53:20'!
evaluate: aString
		
	^ [ Compiler evaluate: aString ]
		on: Notification do: [ :ex |
			"Prevent Notification from being written to Transcript."
			ex resume: false.
			nil.
		]
		on: Error do: [ :ex | nil ].
! !

!MethodFinderWindow methodsFor: 'private' stamp: 'RMV 1/27/2025 16:08:34'!
findMethods
	| arguments compiledMethod expected message methods receiver selectors |
	
	[ receiver := self evaluate: receiverInput text ] on: Error do: [ :ex |
		statusLabel contents: ex messageText.
		^ nil.
	].
	receiver ifNil: [
		statusLabel contents: 'Receiver expression is invalid.'.
		^ nil.
	].

	arguments := argumentsInput text isEmpty
		ifTrue: [ #() ]
		ifFalse: [ self evaluate: '{', argumentsInput text, '}' ].
	arguments ifNil: [
		statusLabel contents: 'Arguments expression is invalid.'.
		^ nil.
	].
	
	expected := self evaluate: expectedInput text.
	expected ifNil: [
		statusLabel contents: 'Expected expression is invalid.'.
		^ nil.
	].

	selectors := MethodFinder selectorsFor: receiver arguments: arguments size.
	"selectors size logAs: 'selectors size'."
	statusLabel contents: ('evaluating {1} selectors' format: { selectors size }).

	"The remaining code is in a block and run in a new process by sending it `#fork`.
	This is necessary to allow the change to statusLabel above
	to be seen before the code in this block finishes executing."
	[
		selectors := MethodFinder matchesIn: selectors receiver: receiver arguments: arguments expected: expected.

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
		
		self model messageListIndex: 0. "clears code pane"
		
		self redrawNeeded. "TODO: Why is this sometimes, but not always, needed?"
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

!MethodFinderWindow class methodsFor: 'menu-world' stamp: 'RMV 1/24/2025 06:37:49'!
worldMenuOptions
	^ `{{
			#submenuOf -> TheWorldMenu openLabel.
			#itemGroup -> 10.
			
			"Text Editor is 10.
			Workspace is 20.
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

!MethodFinderWindow class methodsFor: 'ui' stamp: 'RMV 1/26/2025 09:35:03'!
open

	^ self open: MethodFinder new label: 'Method Finder'! !

!PluggableButtonMorph methodsFor: '*MethodFinder' stamp: 'RMV 1/16/2025 07:57:30'!
enable: aBoolean

	aBoolean ifTrue: [ self enable ] ifFalse: [ self disable ]! !
MethodFinder initialize!
