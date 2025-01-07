'From Cuis7.3 [latest update: #6962] on 7 January 2025 at 8:40:24 am'!
'Description '!
!provides: 'FindByExample' 1 58!
SystemOrganization addCategory: #FindByExample!


!classDefinition: #Finder category: #FindByExample!
Object subclass: #Finder
	instanceVariableNames: ''
	classVariableNames: 'SkipSet'
	poolDictionaries: ''
	category: 'FindByExample'!
!classDefinition: 'Finder class' category: #FindByExample!
Finder class
	instanceVariableNames: ''!


!Finder class methodsFor: 'as yet unclassified' stamp: 'RMV 1/7/2025 08:39:35'!
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

!Finder class methodsFor: 'as yet unclassified' stamp: 'RMV 1/7/2025 08:40:16'!
methodsByExample: values
	"Find all methods that return the last value when
	the first value is the receiver and the other values are arguments."
	| actual argCount arguments argumentsCopy expected matches receiver receiverCopy selectors |

	values size < 2 ifTrue: [
		Error signal: 'requires at least two values'
	].

	receiver := values first.
	expected := values last.
	arguments := values allButFirst allButLast.
	argCount := arguments size.

	"Find all the selectors in the receiver class and its subclasses."	
	selectors := receiver class allSelectors.

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
		"selector logAs: 'selector'.
		self halt."
			
		"Some methods modified the receiver, so we operate on a copy."
		receiverCopy := receiver veryDeepCopy.
		
		"Some methods modify arguments, so we operate on a copy."
		argumentsCopy := arguments veryDeepCopy.

		actual := [receiverCopy perform: selector withArguments: argumentsCopy] on: Error do: [ :ex | nil ].
		actual = expected.
	].

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
Finder initialize!
