'From Cuis7.3 [latest update: #6968] on 5 January 2025 at 10:19:04 am'!
'Description '!
!provides: 'FindByExample' 1 1!
SystemOrganization addCategory: 'FindByExample'!


!classDefinition: #Finder category: 'FindByExample'!
Object subclass: #Finder
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'FindByExample'!
!classDefinition: 'Finder class' category: 'FindByExample'!
Finder class
	instanceVariableNames: ''!


!Finder class methodsFor: 'as yet unclassified' stamp: 'RMV 1/5/2025 10:19:01'!
methodsByExample: values
	"Find all methods that return the last value when first value is the receiver and the other values are arguments."
	| actual argCount arguments expected matches receiver receiverCopy selectors skip |

	values size < 2 ifTrue: [
		Error signal: 'requires at least two values'
	].

	receiver := values first.
	expected := values last.
	arguments := values allButFirst allButLast.
	argCount := arguments size.
	selectors := receiver class allSelectors.
	
	"Skip these methods."
	skip := Set newFrom: #(
		#basicInspect
		#browseClassHierarchy
		#caseError
		#deprecatedMethod
		#edit
		#explore
		#inspect
		#print
		#yourself
	).
	
	selectors := selectors reject: [ :selector |
		| thisArgCount |
		thisArgCount := selector first isAlphaNumeric ifTrue: [ selector occurrencesOf: $: ] ifFalse: 1.
		thisArgCount ~= argCount ::
			or: [ skip includes: selector ] ::
			or: [ selector asLowercase includesSubString: 'halt' ]
	].

	matches := selectors select: [ :selector |
		"Some methods modified the receiver, so we need to save and restore it."
		receiverCopy := receiver veryDeepCopy.
		actual := [receiver perform: selector withArguments: arguments] on: Error do: [ :ex | nil ].
		receiver := receiverCopy.
		actual = expected.
	].

	matches size = 0
		ifTrue: [ 'no methods found' print ]
		ifFalse: [
			'The following methods match:' print.
			matches asSortedCollection do: [ :match | '- ', match :: print ].
		].! !
