'From Cuis7.3 [latest update: #6968] on 5 January 2025 at 2:16:13 pm'!
'Description '!
!provides: 'FindByExample' 1 18!
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


!Finder class methodsFor: 'as yet unclassified' stamp: 'RMV 1/5/2025 14:16:12'!
methodsByExample: values
	"Find all methods that return the last value when
	the first value is the receiver and the other values are arguments."
	| actual argCount arguments expected matches receiver receiverCopy selectors skipSet |

	values size < 2 ifTrue: [
		Error signal: 'requires at least two values'
	].

	receiver := values first.
	expected := values last.
	arguments := values allButFirst allButLast.
	argCount := arguments size.
	
	"Skip these selectors because they have
	side effects that are bad for this method."
	skipSet := Set newFrom: #(
		#basicInspect
		#browseClassHierarchy
		#caseError
		#confirm:
		#confirm:orCancel:
		#deprecatedMethod
		#edit
		#editLabel:
		#executeMethod:
		#explore
		#inform:
		#inspect
		#inspectWithLabel:
		#logAs:
		#notify:
		#print
		#primitiveError:
		#yourself
	).

	"Find all the selectors in the receiver class and its subclasses."	
	selectors := receiver class allSelectors.

	"Remove the selectors that do not take the number of arguments provided,
	are ones we want to skip (due to side effects), or are related to halting."
	selectors := selectors reject: [ :selector |
		| thisArgCount |
		thisArgCount := selector first isAlphaNumeric ifTrue: [ selector occurrencesOf: $: ] ifFalse: 1.
		thisArgCount ~= argCount ::
			or: [ skipSet includes: selector ] ::
			or: [ selector asLowercase includesSubString: 'halt' ]
	].

	"Find all the selectors that return the expected value
	when sent to the receiver with the provided arguments."
	"count := 0."
	matches := selectors select: [ :selector |
		"count := count + 1.
		count > 210 ifTrue: [
			selector logAs: 'selector'.
			self halt.
		]."
		"Some methods modified the receiver, so we need to save and restore it."
		receiverCopy := receiver veryDeepCopy.
		actual := [receiver perform: selector withArguments: arguments] on: Error do: [ :ex | nil ].
		receiver := receiverCopy.
		actual = expected.
	].

	"Write the results to the Transcript."
	matches size = 0
		ifTrue: [ 'no methods found' print ]
		ifFalse: [
			| template |
			template := 'The following methods on {1} with arguments {2} return {3}:'.
			template format: { receiver printString. arguments printString. expected printString} :: print.
			matches asSortedCollection do: [ :match | '- ', match :: print ].
		].! !
