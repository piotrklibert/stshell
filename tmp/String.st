'From Cuis 5.0 [latest update: #4607] on 27 May 2021 at 9:08:06 pm'!

ArrayedCollection subclass: #String
	instanceVariableNames: ''
	classVariableNames: 'CSLineEnders CSNonSeparators CSSeparators CaseInsensitiveOrder CaseSensitiveOrder LowercasingTable Tokenish UppercasingTable'
	poolDictionaries: ''
	category: 'Kernel-Text'!
!String commentStamp: '<historical>' prior: 0!
A String is an indexed collection of Characters. In Cuis, Characters are represented in the Latin-9 (ISO 8859-15) encoding. Each character takes 1 byte.

String support a vast array of useful methods, which can best be learned by browsing and trying out examples as you find them in the code.

Here are a few useful methods to look at...
	String match:
	String contractTo:

String also inherits many useful methods from its hierarchy, such as
	SequenceableCollection ,
	SequenceableCollection copyReplaceAll:with:

Cuis includes limited support for Unicode. A ByteArray can hold any Unicode string in utf-8. There is support for converting to and from instances of String. As String can not hold all Unicode code points, (just the ISO 8859-15 subset), others are converted to NCRs. See #fromUtf8:hex:trimLastNull: and #asUtf8: .!


!String methodsFor: 'accessing' stamp: 'jmv 9/2/2016 11:03:45'!
at: index
	"Primitive. Answer the Character stored in the field of the receiver
	indexed by the argument. Fail if the index argument is not an Integer or
	is out of bounds. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 63>
	^Character numericValue: (super at: index)! !

!String methodsFor: 'accessing' stamp: 'jmv 6/11/2019 12:14:25'!
at: index put: aCharacter
	"Primitive. Store the Character in the field of the receiver indicated by
	the index. Fail if the index is not an Integer or is out of bounds, or if
	the argument is not a Character. Essential. See Object documentation
	whatIsAPrimitive."

	<primitive: 64>
	(aCharacter is: #Character)
		ifTrue: [
			index isInteger
				ifTrue: [self errorSubscriptBounds: index]
				ifFalse: [self errorNonIntegerIndex]]
		ifFalse: [self error: 'Strings only store Characters']! !

!String methodsFor: 'accessing' stamp: 'jmv 9/5/2016 17:14:38'!
byteAt: index
	<primitive: 60>
	^(self at: index) numericValue! !

!String methodsFor: 'accessing' stamp: 'ar 12/27/1999 13:44'!
byteAt: index put: value
	<primitive: 61>
	self at: index put: value asCharacter.
	^value! !

!String methodsFor: 'accessing' stamp: 'tk 12/26/97 11:09'!
findAnySubStr: delimiters startingAt: start
	"Answer the index of the character within the receiver, starting at start, that begins a substring matching one of the delimiters.  delimiters is an Array of Strings (Characters are permitted also).  If the receiver does not contain any of the delimiters, answer size + 1."

	| min ind |
	min := self size + 1.
	delimiters do: [:delim |	"May be a char, a string of length 1, or a substring"
		delim class == Character
			ifTrue: [ind := self indexOfSubCollection: (String with: delim)
						startingAt: start ifAbsent: [min]]
			ifFalse: [ind := self indexOfSubCollection: delim
						startingAt: start ifAbsent: [min]].
			min := min min: ind].
	^ min! !

!String methodsFor: 'accessing' stamp: 'dew 11/15/2000 15:02'!
findBetweenSubStrs: delimiters
	"Answer the collection of String tokens that result from parsing self.  Tokens are separated by 'delimiters', which can be a collection of Strings, or a collection of Characters.  Several delimiters in a row are considered as just one separation."

	| tokens keyStart keyStop |
	tokens := OrderedCollection new.
	keyStop := 1.
	[keyStop <= self size] whileTrue:
		[keyStart := self skipAnySubStr: delimiters startingAt: keyStop.
		keyStop := self findAnySubStr: delimiters startingAt: keyStart.
		keyStart < keyStop
			ifTrue: [tokens add: (self copyFrom: keyStart to: (keyStop - 1))]].
	^tokens! !

!String methodsFor: 'accessing'!
findDelimiters: delimiters startingAt: start
	"Answer the index of the character within the receiver, starting at start, that matches one of the delimiters. If the receiver does not contain any of the delimiters, answer size + 1."

	start to: self size do: [:i |
		delimiters do: [:delim | delim = (self at: i) ifTrue: [^ i]]].
	^ self size + 1! !

!String methodsFor: 'accessing' stamp: 'nice 10/5/2009 03:15'!
findLastOccurrenceOfString: subString startingAt: start
	"Answer the index of the last occurrence of subString within the receiver, starting at start. If
	the receiver does not contain subString, answer 0.  Case-sensitive match used."

	| last now |
	last := self findString: subString startingAt: start.
	last = 0 ifTrue: [^ 0].
	[last > 0] whileTrue:
		[now := last.
		last := self findString: subString startingAt: last + 1].

	^ now
! !

!String methodsFor: 'accessing' stamp: 'ar 4/11/1999 22:15'!
findString: subString
	"Answer the index of subString within the receiver, starting at start. If
	the receiver does not contain subString, answer 0."
	^self findString: subString startingAt: 1.! !

!String methodsFor: 'accessing' stamp: 'di 11/15/1998 16:43'!
findString: subString startingAt: start
	"Answer the index of subString within the receiver, starting at start. If
	the receiver does not contain subString, answer 0."

	^ self findSubstring: subString in: self startingAt: start matchTable: CaseSensitiveOrder! !

!String methodsFor: 'accessing' stamp: 'di 11/15/1998 16:45'!
findString: key startingAt: start caseSensitive: caseSensitive
	"Answer the index in this String at which the substring key first occurs, at or beyond start.  The match can be case-sensitive or not.  If no match is found, zero will be returned."

	caseSensitive
	ifTrue: [^ self findSubstring: key in: self startingAt: start matchTable: CaseSensitiveOrder]
	ifFalse: [^ self findSubstring: key in: self startingAt: start matchTable: CaseInsensitiveOrder]! !

!String methodsFor: 'accessing' stamp: 'tk 8/10/2000 09:14'!
findTokens: delimiters
	"Answer the collection of tokens that result from parsing self.  Return strings between the delimiters.  Any character in the Collection delimiters marks a border.  Several delimiters in a row are considered as just one separation.  Also, allow delimiters to be a single character."

	| tokens keyStart keyStop separators |

	tokens := OrderedCollection new.
	separators := delimiters class == Character
		ifTrue: [Array with: delimiters]
		ifFalse: [delimiters].
	keyStop := 1.
	[keyStop <= self size] whileTrue:
		[keyStart := self skipDelimiters: separators startingAt: keyStop.
		keyStop := self findDelimiters: separators startingAt: keyStart.
		keyStart < keyStop
			ifTrue: [tokens add: (self copyFrom: keyStart to: (keyStop - 1))]].
	^tokens! !

!String methodsFor: 'accessing' stamp: 'tk 6/19/97 10:05'!
findTokens: delimiters keep: keepers
	"Answer the collection of tokens that result from parsing self.  The tokens are seperated by delimiters, any of a string of characters.  If a delimiter is also in keepers, make a token for it.  (Very useful for carriage return.  A sole return ends a line, but is also saved as a token so you can see where the line breaks were.)"

	| tokens keyStart keyStop |
	tokens := OrderedCollection new.
	keyStop := 1.
	[keyStop <= self size] whileTrue:
		[keyStart := self skipDelimiters: delimiters startingAt: keyStop.
		keyStop to: keyStart-1 do: [:ii |
			(keepers includes: (self at: ii)) ifTrue: [
				tokens add: (self copyFrom: ii to: ii)]].	"Make this keeper be a token"
		keyStop := self findDelimiters: delimiters startingAt: keyStart.
		keyStart < keyStop
			ifTrue: [tokens add: (self copyFrom: keyStart to: (keyStop - 1))]].
	^tokens! !

!String methodsFor: 'accessing' stamp: 'sw 8/12/97 12:37'!
includesSubString: subString
	^ (self findString: subString startingAt: 1) > 0! !

!String methodsFor: 'accessing' stamp: 'di 11/15/1998 16:53'!
includesSubstring: aString caseSensitive: caseSensitive

	^ (self findString: aString startingAt: 1 caseSensitive: caseSensitive) > 0! !

!String methodsFor: 'accessing' stamp: 'jmv 9/5/2016 21:15:58'!
indexOf: aCharacter

	(aCharacter class == Character) ifFalse: [^ 0].
	^ String indexOfByte: aCharacter numericValue inString: self startingAt: 1! !

!String methodsFor: 'accessing' stamp: 'jmv 9/5/2016 21:16:01'!
indexOf: aCharacter  startingAt: start

	(aCharacter class == Character) ifFalse: [^ 0].
	^ String indexOfByte: aCharacter numericValue inString: self startingAt: start! !

!String methodsFor: 'accessing' stamp: 'jmv 9/5/2016 21:16:04'!
indexOf: aCharacter  startingAt: start  ifAbsent: aBlock
	| ans |
	(aCharacter class == Character) ifFalse: [ ^ aBlock value ].
	ans := String indexOfByte: aCharacter numericValue inString: self  startingAt: start.
	^ans = 0
		ifTrue: [ aBlock value ]
		ifFalse: [ ans ]! !

!String methodsFor: 'accessing' stamp: 'jmv 4/2/2016 14:35'!
indexOfAnyOf: aCharacterSet
	"returns the index of the first character in the given set, starting from start"

	^String findFirstInString: self inSet: aCharacterSet byteArrayMap startingAt: 1! !

!String methodsFor: 'accessing' stamp: 'jmv 3/14/2012 08:14'!
indexOfAnyOf: aCharacterSet  startingAt: start ifAbsent: aBlock
	"returns the index of the first character in the given set, starting from start"

	| answer |
	answer := String findFirstInString: self inSet: aCharacterSet byteArrayMap startingAt: start.

	^answer = 0
		ifTrue: [ aBlock value ]
		ifFalse: [ answer]! !

!String methodsFor: 'accessing' stamp: 'di 11/15/1998 17:02'!
indexOfSubCollection: sub startingAt: start ifAbsent: exceptionBlock
	| index |
	index := self findSubstring: sub in: self startingAt: start matchTable: CaseSensitiveOrder.
	index = 0 ifTrue: [^ exceptionBlock value].
	^ index! !

!String methodsFor: 'accessing' stamp: 'jmv 3/13/2012 22:06'!
lineCount
	"Answer the number of lines represented by the receiver, where every cr adds one line.  5/10/96 sw"


	| i |
	i := 0.
	self lineIndicesDo: [ :start :endWithoutDelimiters :end |
		i := i + 1 ].
	^i

"
'Fred
the
Bear' lineCount
"! !

!String methodsFor: 'accessing' stamp: 'jmv 8/28/2013 10:27'!
lineIndicesDo: aBlock
	"execute aBlock with 3 arguments for each line:
	- start index of line
	- end index of line without line delimiter
	- end index of line including line delimiter(s) CR, LF or CRLF"

	| start end endWithoutDelimiters |
	start := 1.
	[
		end := self indexOfAnyOf: CSLineEnders startingAt: start ifAbsent: [ 0 ].
		end = 0
			ifTrue: [
				"Last line was found. Evaluate and exit.
				Note. If last char in receiver is a line separator, there's an extra empty line"
				endWithoutDelimiters := end := self size.
				aBlock value: start value: endWithoutDelimiters value: end.
				^self ].

		"Account for CrLf sequence"
		endWithoutDelimiters := end - 1.
		(end < self size
			and: [(self at: end + 1) = Character lf
			and: [(self at: end) = Character cr ]])
				ifTrue: [ end := end + 1].

		aBlock value: start value: endWithoutDelimiters value: end.
		start := end + 1 ] repeat! !

!String methodsFor: 'accessing' stamp: 'jmv 3/13/2012 22:05'!
lineNumber: anIndex
	"Answer a string containing the characters in the given line number. "
	| i |
	i := 1.
	self lineIndicesDo: [ :start :endWithoutDelimiters :end |
		i = anIndex ifTrue: [
			^ self copyFrom: start to: endWithoutDelimiters ].
		i := i + 1 ].
	^nil

"
'Fred
the
Bear' lineNumber: 3
".! !

!String methodsFor: 'accessing' stamp: 'jmv 3/13/2012 22:08'!
lines
	"Answer an array of lines composing this receiver without the line ending delimiters."

	^Array
		streamContents: [ :lines | self linesDo: [ :aLine | lines nextPut: aLine ]]
		estimatedSize: (self size // 60 max: 16)! !

!String methodsFor: 'accessing' stamp: 'jmv 3/13/2012 22:08'!
linesDo: aBlock
	"execute aBlock with each line in this string.  The terminating CR's are not included in what is passed to aBlock"

	self lineIndicesDo: [ :start :endWithoutDelimiters :end |
		aBlock value: (self copyFrom: start  to: endWithoutDelimiters) ]
		! !

!String methodsFor: 'accessing' stamp: 'BJP 6/12/2000 18:53'!
skipAnySubStr: delimiters startingAt: start
	"Answer the index of the last character within the receiver, starting at
	start, that does NOT match one of the delimiters. delimiters is a Array of
	substrings (Characters also allowed). If the receiver is all delimiters,
	answer size + 1."

	| any this ind ii |
	ii := start-1.
	[(ii := ii + 1) <= self size] whileTrue: [ "look for char that does not match"
		any := false.
		delimiters do: [:delim |
			delim class == Character
				ifTrue: [(self at: ii) == delim ifTrue: [any := true]]
				ifFalse: ["a substring"
					delim size > (self size - ii + 1) ifFalse: "Here's where the one-off error was."
						[ind := 0.
						this := true.
						delim do: [:dd |
							dd == (self at: ii+ind) ifFalse: [this := false].
							ind := ind + 1].
						this ifTrue: [ii := ii + delim size - 1.  any := true]]
							ifTrue: [any := false] "if the delim is too big, it can't match"]].
		any ifFalse: [^ ii]].
	^ self size + 1! !

!String methodsFor: 'accessing'!
skipDelimiters: delimiters startingAt: start
	"Answer the index of the character within the receiver, starting at start,
	that does NOT match one of the delimiters. If the receiver does not contain
	any of the delimiters, answer size + 1. Assumes the delimiters to be a
	non-empty string."

	start to: self size do: [:i |
		delimiters detect: [:delim | delim = (self at: i)]
				ifNone: [^ i]].
	^ self size + 1! !

!String methodsFor: 'accessing' stamp: 'jmv 3/20/2013 23:10'!
string
	"Compatibility with Text"
	^self! !


!String methodsFor: 'comparing' stamp: 'jmv 10/6/2010 18:06'!
< aString
	"Answer whether the receiver sorts before aString.
	The collation order is case sensitive."

	^ (self compare: self with: aString collated: CaseSensitiveOrder) = 1! !

!String methodsFor: 'comparing' stamp: 'jmv 10/6/2010 18:07'!
<= aString
	"Answer whether the receiver sorts before or equal to aString.
	The collation order is case sensitive."

	^ (self compare: self with: aString collated: CaseSensitiveOrder) <= 2! !

!String methodsFor: 'comparing' stamp: 'jmv 6/11/2019 16:23:20'!
= aString
	"Answer whether the receiver sorts equally as aString.
	This means same characters in same order."

	"Any object is equal to itself"
	self == aString ifTrue: [ ^ true ].

	"If argument is not a String or Symbol, maybe it is a Text?"
	aString species == String ifFalse: [
		(aString is: #Text) ifTrue: [ ^ self = aString string ].
		^ false].

	self size = aString size ifFalse: [
		^false ].

	self size > 256 ifTrue: [
		self hashQuick = aString hashQuick ifFalse: [ ^false ]].

	^ (self compare: self with: aString collated: CaseSensitiveOrder) = 2! !

!String methodsFor: 'comparing' stamp: 'jmv 10/6/2010 18:07'!
> aString
	"Answer whether the receiver sorts after aString.
	The collation order is case sensitive."

	^ (self compare: self with: aString collated: CaseSensitiveOrder) = 3! !

!String methodsFor: 'comparing' stamp: 'jmv 10/6/2010 18:07'!
>= aString
	"Answer whether the receiver sorts after or equal to aString.
	The collation order is case sensitive."

	^ (self compare: self with: aString collated: CaseSensitiveOrder) >= 2! !

!String methodsFor: 'comparing' stamp: 'jmv 9/5/2016 17:13:56'!
alike: aString
	"Answer some indication of how alike the receiver is to the argument, 0 is
	no match, twice aString size is best score. Case is ignored."

	| i j k minSize bonus |
	minSize := (j := self size) min: (k := aString size).
	bonus := (j - k) abs < 2 ifTrue: [ 1 ] ifFalse: [ 0 ].
	i := 1.
	[(i <= minSize) and: [((super at: i) bitAnd: 16rDF)  = ((aString at: i) numericValue bitAnd: 16rDF)]]
		whileTrue: [ i := i + 1 ].
	[(j > 0) and: [(k > 0) and:
		[((super at: j) bitAnd: 16rDF) = ((aString at: k) numericValue bitAnd: 16rDF)]]]
			whileTrue: [ j := j - 1.  k := k - 1. ].
	^ i - 1 + self size - j + bonus. ! !

!String methodsFor: 'comparing' stamp: 'jmv 2/22/2013 07:41'!
beginsWith: prefix
	"Answer whether the receiver begins with the given prefix string.
	The comparison is case-sensitive."

	^self is: prefix substringAt: 1! !

!String methodsFor: 'comparing' stamp: 'sw 4/19/1999 12:11'!
caseInsensitiveLessOrEqual: aString
	"Answer whether the receiver sorts before or equal to aString.
	The collation order is case insensitive."

	^ (self compare: self with: aString collated: CaseInsensitiveOrder) <= 2! !

!String methodsFor: 'comparing' stamp: 'di 9/20/1998 14:33'!
caseSensitiveLessOrEqual: aString
	"Answer whether the receiver sorts before or equal to aString.
	The collation order is case sensitive."

	^ (self compare: self with: aString collated: CaseSensitiveOrder) <= 2! !

!String methodsFor: 'comparing' stamp: 'jmv 6/23/2011 09:53'!
commonPartWith: aString startAt: startIndex stopAt: stopIndexRequested applying: aBlock
	"Return the size of the longest common subsequence with aString, only
	between startIndex and stopIndex. Apply aBlock to each character before
	comparing.

	Do a character-by-character comparison between the receiver and aString.
	Return the index of the final character that matched exactly."

	| stopIndex |
	stopIndex := stopIndexRequested min: aString size.
	startIndex
		to: stopIndex
		do: [ :i |
			(aBlock value: (self at: i)) = (aBlock value: (aString at: i)) ifFalse: [ ^ i - 1 ]].
	^ stopIndex! !

!String methodsFor: 'comparing' stamp: 'jmv 6/23/2011 09:54'!
commonPrefixWith: aString
	"Return the size of the longest common prefix with aString.
	Do a character-by-character comparison between the receiver and aString.  Return the index of the final character that matched exactly.
	'this is a string' commonPrefixWith: 'this is another'
	'this is a string' commonPrefixWith: ''
	'' commonPrefixWith: 'this is another'
	't' commonPrefixWith: 'this is another'
	'txxxxxxxxx' commonPrefixWith: 'this is another'
		"
	^ self commonPartWith: aString startAt: 1 stopAt: self size applying: [ :c | c ]! !

!String methodsFor: 'comparing' stamp: 'di 2/27/98 12:41'!
compare: aString
	"Answer a comparison code telling how the receiver sorts relative to aString:
		1 - before
		2 - equal
		3 - after.
	The collation sequence is ascii with case differences ignored.
	To get the effect of a <= b, but ignoring case, use (a compare: b) <= 2."

	^ self compare: self with: aString collated: CaseInsensitiveOrder! !

!String methodsFor: 'comparing' stamp: 'ar 4/10/2005 16:42'!
compare: aString caseSensitive: aBool
	"Answer a comparison code telling how the receiver sorts relative to aString:
		1 - before
		2 - equal
		3 - after.
	"
	| map |
	map := aBool ifTrue:[CaseSensitiveOrder] ifFalse:[CaseInsensitiveOrder].
	^self compare: self with: aString collated: map! !

!String methodsFor: 'comparing' stamp: 'jmv 9/5/2016 21:14:24'!
crc16
	"Compute a 16 bit cyclic redundancy check."

	| crc |
	crc := 0.
	self do: [:c |
		crc := (crc bitShift: -8) bitXor: (
		 #(	16r0000	16rC0C1	16rC181	16r0140	16rC301	16r03C0	16r0280	16rC241
			16rC601	16r06C0	16r0780	16rC741	16r0500	16rC5C1	16rC481	16r0440
			16rCC01	16r0CC0	16r0D80	16rCD41	16r0F00	16rCFC1	16rCE81	16r0E40
			16r0A00	16rCAC1	16rCB81	16r0B40	16rC901	16r09C0	16r0880	16rC841
			16rD801	16r18C0	16r1980	16rD941	16r1B00	16rDBC1	16rDA81	16r1A40
			16r1E00	16rDEC1	16rDF81	16r1F40	16rDD01	16r1DC0	16r1C80	16rDC41
			16r1400	16rD4C1	16rD581	16r1540	16rD701	16r17C0	16r1680	16rD641
			16rD201	16r12C0	16r1380	16rD341	16r1100	16rD1C1	16rD081	16r1040
			16rF001	16r30C0	16r3180	16rF141	16r3300	16rF3C1	16rF281	16r3240
			16r3600	16rF6C1	16rF781	16r3740	16rF501	16r35C0	16r3480	16rF441
			16r3C00	16rFCC1	16rFD81	16r3D40	16rFF01	16r3FC0	16r3E80	16rFE41
			16rFA01	16r3AC0	16r3B80	16rFB41	16r3900	16rF9C1	16rF881	16r3840
			16r2800	16rE8C1	16rE981	16r2940	16rEB01	16r2BC0	16r2A80	16rEA41
			16rEE01	16r2EC0	16r2F80	16rEF41	16r2D00	16rEDC1	16rEC81	16r2C40
			16rE401	16r24C0	16r2580	16rE541	16r2700	16rE7C1	16rE681	16r2640
			16r2200	16rE2C1	16rE381	16r2340	16rE101	16r21C0	16r2080	16rE041
			16rA001	16r60C0	16r6180	16rA141	16r6300	16rA3C1	16rA281	16r6240
			16r6600	16rA6C1	16rA781	16r6740	16rA501	16r65C0	16r6480	16rA441
			16r6C00	16rACC1	16rAD81	16r6D40	16rAF01	16r6FC0	16r6E80	16rAE41
			16rAA01	16r6AC0	16r6B80	16rAB41	16r6900	16rA9C1	16rA881	16r6840
			16r7800	16rB8C1	16rB981	16r7940	16rBB01	16r7BC0	16r7A80	16rBA41
			16rBE01	16r7EC0	16r7F80	16rBF41	16r7D00	16rBDC1	16rBC81	16r7C40
			16rB401	16r74C0	16r7580	16rB541	16r7700	16rB7C1	16rB681	16r7640
			16r7200	16rB2C1	16rB381	16r7340	16rB101	16r71C0	16r7080	16rB041
			16r5000	16r90C1	16r9181	16r5140	16r9301	16r53C0	16r5280	16r9241
			16r9601	16r56C0	16r5780	16r9741	16r5500	16r95C1	16r9481	16r5440
			16r9C01	16r5CC0	16r5D80	16r9D41	16r5F00	16r9FC1	16r9E81	16r5E40
			16r5A00	16r9AC1	16r9B81	16r5B40	16r9901	16r59C0	16r5880	16r9841
			16r8801	16r48C0	16r4980	16r8941	16r4B00	16r8BC1	16r8A81	16r4A40
			16r4E00	16r8EC1	16r8F81	16r4F40	16r8D01	16r4DC0	16r4C80	16r8C41
			16r4400	16r84C1	16r8581	16r4540	16r8701	16r47C0	16r4680	16r8641
			16r8201	16r42C0	16r4380	16r8341	16r4100	16r81C1	16r8081	16r4040)
			 at: ((crc bitXor: c numericValue) bitAnd: 16rFF) + 1) ].
	^crc! !

!String methodsFor: 'comparing' stamp: 'jmv 2/22/2013 07:41'!
endsWith: suffix
	"Answer whether the tail end of the receiver is the same as suffix.
	The comparison is case-sensitive."

	^self is: suffix substringAt: self size - suffix size + 1
"
  'Elvis' endsWith: 'vis'
"! !

!String methodsFor: 'comparing' stamp: 'jmv 6/11/2019 16:13:53'!
hash
	"#hash is implemented, because #= is implemented"
	self size > 256 ifTrue: [ ^ self hashQuick ].
	^ByteArray
		hashBytes: self
		startingWith: self species hash! !

!String methodsFor: 'comparing' stamp: 'len 11/15/2015 04:23'!
is: aString substringAt: index
	"Answer whether the receiver includes aString as a subcollection at position index.
	The comparison is case-sensitive."
	| sequenceSize |
	index < 1 ifTrue: [ ^false ].
	sequenceSize := aString size.
	sequenceSize = 0 ifTrue: [ ^true].
	self size - index + 1 < sequenceSize ifTrue: [ ^false ].
	"The following method uses a suboptimal algorithm (brute force pattern
	matching with O(n^2) worst case runtime), but the primitive in C is so fast
	(assuming large alphabets), that it's still worth using it instead of linear
	time pure smalltalk implementation. There are some obvious cases when the
	brute force algorithm is suboptimal, e.g. when the first elements don't
	match, so let's compare them here before using the primitive."

	(self basicAt: index) = (aString basicAt: 1) ifFalse: [ ^false ].
	^(self findSubstring: aString in: self startingAt: index matchTable: CaseSensitiveOrder) = index! !

!String methodsFor: 'comparing' stamp: 'di 11/19/1998 13:37'!
match: text
	"Answer whether text matches the pattern in this string.
	Matching ignores upper/lower case differences.
	Where this string contains #, text may contain any character.
	Where this string contains *, text may contain any sequence of characters."

	^ self startingAt: 1 match: text startingAt: 1
"
	'*'			match: 'zort' true
	'*baz'		match: 'mobaz' true
	'*baz'		match: 'mobazo' false
	'*baz*'		match: 'mobazo' true
	'*baz*'		match: 'mozo' false
	'foo*'		match: 'foozo' true
	'foo*'		match: 'bozo' false
	'foo*baz'	match: 'foo23baz' true
	'foo*baz'	match: 'foobaz' true
	'foo*baz'	match: 'foo23bazo' false
	'foo'		match: 'Foo' true
	'foo*baz*zort' match: 'foobazort' false
	'foo*baz*zort' match: 'foobazzort' false
	'*foo#zort'	match: 'afoo3zortthenfoo3zort' true
	'*foo*zort'	match: 'afoodezortorfoo3zort' true
"! !

!String methodsFor: 'comparing' stamp: 'di 2/27/98 12:19'!
sameAs: aString
	"Answer whether the receiver sorts equal to aString. The
	collation sequence is ascii with case differences ignored."

	^ (self compare: self with: aString collated: CaseInsensitiveOrder) = 2! !

!String methodsFor: 'comparing' stamp: 'ul 11/14/2010 06:02'!
startingAt: keyStart match: text startingAt: textStart
	"Answer whether text matches the pattern in this string.
	Matching ignores upper/lower case differences.
	Where this string contains #, text may contain any character.
	Where this string contains *, text may contain any sequence of characters."
	| anyMatch matchStart matchEnd i matchStr j ii jj |
	i := keyStart.
	j := textStart.

	"Check for any #'s"
	[i > self size ifTrue: [^ j > text size "Empty key matches only empty string"].
	(self at: i) = $#] whileTrue:
		["# consumes one char of key and one char of text"
		j > text size ifTrue: [^ false "no more text"].
		i := i+1.  j := j+1].

	"Then check for *"
	(self at: i) = $*
		ifTrue: [i = self size ifTrue:
					[^ true "Terminal * matches all"].
				"* means next match string can occur anywhere"
				anyMatch := true.
				matchStart := i + 1]
		ifFalse: ["Otherwise match string must occur immediately"
				anyMatch := false.
				matchStart := i].

	"Now determine the match string"
	matchEnd := self size.
	(ii := self indexOf: $* startingAt: matchStart) > 0 ifTrue:
		[ii = matchStart ifTrue: [self error: '** not valid -- use * instead'].
		matchEnd := ii-1].
	(ii := self indexOf: $# startingAt: matchStart) > 0 ifTrue:
		[ii = matchStart ifTrue: [self error: '*# not valid -- use #* instead'].
		matchEnd := matchEnd min: ii-1].
	matchStr := self copyFrom: matchStart to: matchEnd.

	"Now look for the match string"
	[jj := text findString: matchStr startingAt: j caseSensitive: false.
	anyMatch ifTrue: [jj > 0] ifFalse: [jj = j]]
		whileTrue:
		["Found matchStr at jj.  See if the rest matches..."
		(self startingAt: matchEnd+1 match: text startingAt: jj + matchStr size) ifTrue:
			[^ true "the rest matches -- success"].
		"The rest did not match."
		anyMatch ifFalse: [^ false].
		"Preceded by * -- try for a later match"
		j := j+1].
	^ false "Failed to find the match string"! !


!String methodsFor: 'copying' stamp: 'KenD 9/4/2016 16:50:54'!
, aStringOrText
	^ aStringOrText appendToString: self! !

!String methodsFor: 'copying' stamp: 'KenD 9/4/2016 15:49:17'!
append: aStringOrText

	^ aStringOrText appendToString: self! !

!String methodsFor: 'copying' stamp: 'KenD 9/4/2016 16:21:53'!
appendToString: aString

	| stringSize |
	stringSize := aString size.
	^ aString copyReplaceFrom: stringSize + 1
		 	    to: stringSize
		   	    with: self! !

!String methodsFor: 'copying' stamp: 'KenD 9/4/2016 18:22:51'!
appendToText: aText

	| textStringSize |
	textStringSize := aText string size.
	^ aText replaceFrom: textStringSize + 1
			 to: textStringSize
			 with: self asText! !

!String methodsFor: 'copying'!
copyReplaceTokens: oldSubstring with: newSubstring
	"Replace all occurrences of oldSubstring that are surrounded
	by non-alphanumeric characters"
	^ self copyReplaceAll: oldSubstring with: newSubstring asTokens: true
	"'File asFile Files File''s File' copyReplaceTokens: 'File' with: 'Snick'"! !

!String methodsFor: 'copying' stamp: 'HAW 3/4/2019 15:30:11'!
copyReplacing: rangesToNewStrings

	^self class streamContents: [ :replacementStream | self copyReplacing: rangesToNewStrings into: replacementStream ].! !

!String methodsFor: 'copying' stamp: 'HAW 3/4/2019 15:30:14'!
copyReplacing: rangesToNewStrings into: replacementStream

	| lastFrom |

	lastFrom := rangesToNewStrings inject: 1 into: [ :from :aRangeToNewString |
		self
			newFromAfterAppending: aRangeToNewString value
			into: replacementStream
			keepingFrom: from
			skipping: aRangeToNewString key ].

	replacementStream nextPutAll: (self copyFrom: lastFrom to: self size).
! !

!String methodsFor: 'copying' stamp: 'HAW 3/4/2019 15:30:18'!
copyReplacing: ranges with: newString

	"Ranges must be in order, with first ranges first. If not, result is unexpected - Hernan"

	^ self class streamContents: [ :replacementStream | self copyReplacing: ranges with: newString into: replacementStream ]
		! !

!String methodsFor: 'copying' stamp: 'HAW 3/4/2019 15:30:22'!
copyReplacing: ranges with: newString into: replacementStream

	| lastFrom |

	lastFrom := ranges
		inject: 1
		into: [ :from :aRange |
			self newFromAfterAppending: newString into: replacementStream keepingFrom: from skipping: aRange ].

	replacementStream nextPutAll: (self copyFrom: lastFrom to: self size).! !

!String methodsFor: 'copying' stamp: 'HAW 5/18/2019 17:10:29'!
flattenTo: flattenedStream

	flattenedStream nextPut: self! !

!String methodsFor: 'copying' stamp: 'hjh 5/9/2015 16:32'!
join: aCollection
	"'*' join: #('WWWWW' 'W  EW' 'zzzz')
		->  'WWWWW*W  EW*zzzz' "

	| w |
	w := WriteStream on: String new.
	aCollection do: [ :elem | w nextPutAll: elem asString] separatedBy: [w nextPutAll: self].
	^String fromString: w contents! !

!String methodsFor: 'copying' stamp: 'HAW 3/4/2019 15:30:28'!
newFromAfterAppending: aNewString into: replacementStream keepingFrom: from skipping: aRange

	replacementStream
		nextPutAll: (self copyFrom: from to: aRange first - 1);
		nextPutAll: aNewString.

	^ aRange last + 1! !

!String methodsFor: 'copying' stamp: 'di 2/15/98 22:54'!
padded: leftOrRight to: length with: char
	leftOrRight = #left ifTrue:
		[^ (String new: (length - self size max: 0) withAll: char) , self].
	leftOrRight = #right ifTrue:
		[^ self , (String new: (length - self size max: 0) withAll: char)].! !


!String methodsFor: 'converting' stamp: 'di 11/6/1998 13:47'!
adaptToCollection: rcvr andSend: selector
	"If I am involved in arithmetic with a collection, convert me to a number."

	^ rcvr perform: selector with: self asNumber! !

!String methodsFor: 'converting' stamp: 'jmv 5/28/2015 10:03'!
adaptToNumber: rcvr andSend: selector
	"If I am involved in arithmetic with a number, convert me to a number."

"	^ rcvr perform: selector with: self asNumber"
	self shouldNotImplement.! !

!String methodsFor: 'converting' stamp: 'jmv 5/28/2015 10:03'!
adaptToPoint: rcvr andSend: selector
	"If I am involved in arithmetic with a point, convert me to a number."

"	^ rcvr perform: selector with: self asNumber"
	self shouldNotImplement.! !

!String methodsFor: 'converting' stamp: 'HAW 8/3/2018 10:57:30'!
afterBlanksEndsWith: aTail

	^(self endsWith: aTail) and: [ self firstNoBlankIndex = (self size - aTail size + 1) ]
! !

!String methodsFor: 'converting' stamp: 'jmv 11/30/2010 19:39'!
asCamelCase
	"Answer a new String, without any whitespace, and with words capitalized (Except for the first one)
	' how do you do? ' asCamelCase
	"
	^ String streamContents: [ :outStream | | inStream capitalize wroteSome |
		wroteSome := false.
		capitalize := false.
		inStream := self readStream.
		[ inStream atEnd ] whileFalse: [ | c |
			c := inStream next.
			c isSeparator
				ifTrue: [ capitalize := true ]
				ifFalse: [
					capitalize & wroteSome ifTrue: [ c := c asUppercase ].
					outStream nextPut: c.
					wroteSome := true.
					capitalize := false ]]]! !

!String methodsFor: 'converting' stamp: 'jmv 5/12/2017 11:22:17'!
asDate
	"Many allowed forms, see Date>>#readFrom:
		'2014/6/30' asDate.
		'70/12/30' asDate.
		'12/30/70' asDate.
		'30/12/70' asDate.
		'4/5/6' asDate.
		'15 April 1982' asDate.
	"

	^ Date fromString: self! !

!String methodsFor: 'converting' stamp: 'pb 5/25/2016 01:21'!
asFileName
	"Answer a String made up from the receiver that is an acceptable file
	name."

	^FileIOAccessor default checkName: self fixErrors: true! !

!String methodsFor: 'converting' stamp: 'nk 2/21/2001 20:06'!
asHex
	| stream |
	stream := WriteStream on: (String new: self size * 2).
	self do: [ :ch | stream nextPutAll: ch hex ].
	^stream contents! !

!String methodsFor: 'converting' stamp: 'jmv 3/6/2018 17:19:56'!
asIdentifier: shouldBeCapitalized
	"Return a legal identifier, with first character in upper case if shouldBeCapitalized is true, else lower case.  This will always return a legal identifier, even for an empty string"

	| aString |
	aString := self select: [ :el | el isValidInIdentifiers ].
	(aString size = 0 or: [aString first isValidStartOfIdentifiers not])
		ifTrue:	 [aString := 'a', aString].
	^ shouldBeCapitalized ifTrue: [ aString capitalized ] ifFalse: [ aString uncapitalized ]

"
'234Fred987' asIdentifier: false
'235Fred987' asIdentifier: true
'' asIdentifier: true
'()87234' asIdentifier: false
'())z>=PPve889  U >' asIdentifier: false
"! !

!String methodsFor: 'converting' stamp: 'sma 6/12/2000 11:40'!
asLowercase
	"Answer a String made up from the receiver whose characters are all
	lowercase."

	^ self copy asString translateToLowercase! !

!String methodsFor: 'converting' stamp: 'jmv 5/12/2017 11:24:09'!
asMonth
	"Many allowed forms, see Month>>#readFrom:
		'July 1998' asMonth.
		'1998/7'asMonth.
	"

	^ Month fromString: self! !

!String methodsFor: 'converting' stamp: 'jmv 6/2/2011 08:51'!
asNumber
	"Answer the Number created by interpreting the receiver as the string
	representation of a number."
	^Number readFrom: self readStream! !

!String methodsFor: 'converting' stamp: 'ls 10/28/2003 12:24'!
asSmalltalkComment
	"return this string, munged so that it can be treated as a comment in Smalltalk code.  Quote marks are added to the beginning and end of the string, and whenever a solitary quote mark appears within the string, it is doubled"

	^String streamContents:  [ :str |
		| quoteCount first |

		str nextPut: $".

		quoteCount := 0.
		first := true.
		self do: [ :char |
			char = $"
				ifTrue: [
					first ifFalse: [
						str nextPut: char.
						quoteCount := quoteCount + 1 ] ]
				ifFalse: [
					quoteCount odd ifTrue: [
						"add a quote to even the number of quotes in a row"
						str nextPut: $" ].
					quoteCount := 0.
					str nextPut: char ].
			first := false ].

		quoteCount odd ifTrue: [
			"check at the end"
			str nextPut: $". ].

		str nextPut: $".
	].
	! !

!String methodsFor: 'converting' stamp: 'jm 5/14/1998 10:40'!
asString
	"Answer this string."

	^ self
! !

!String methodsFor: 'converting'!
asSymbol
	"Answer the unique Symbol whose characters are the characters of the
	string."

	^Symbol intern: self! !

!String methodsFor: 'converting'!
asText
	"Answer a Text whose string is the receiver."

	^Text fromString: self! !

!String methodsFor: 'converting' stamp: 'jmv 9/2/2016 11:03:36'!
asUnHtml
	"Strip out all Html stuff (commands in angle brackets <>) and convert
the characters &<> back to their real value.  Leave actual cr and tab as
they were in text."
	| in out char rest did inString |

	"Hack in some minimal workaround for Unicode stuff"
	inString := self copyReplaceAll: 'â€™' with: $' asString.
	"Check if we can handle this in #safeValue: in some way..."
	inString = self ifFalse: [ self halt ].

	in := ReadStream on: inString.
	out := WriteStream on: (String new: self size).
	[ in atEnd ] whileFalse: [
		in peek = $<
			ifTrue: [in unCommand] 	"Absorb <...><...>"
			ifFalse: [(char := in next) = $&
						ifTrue: [rest := in upTo: $;.
								did := out position.
								rest = 'lt' ifTrue: [out nextPut: $<].
								rest = 'gt' ifTrue: [out nextPut: $>].
								rest = 'amp' ifTrue: [out nextPut: $&].
								rest = 'deg' ifTrue: [out nextPut: $¡].
								rest = 'quot' ifTrue: [out nextPut: $"].
								rest first = $# ifTrue: [ out nextPut: (Character numericValue: rest asInteger) ].
								did = out position ifTrue: [
									out nextPut: $&; nextPutAll: rest.
									"self error: 'unknown encoded HTML char'."
									"Please add it to this method"]]
						ifFalse: [out nextPut: char]].
		].
	^ out contents! !

!String methodsFor: 'converting' stamp: 'jmv 4/10/2015 22:42'!
asUnaccented
	"
	'Hello' asUnaccented
	'áéîôóü' asUnaccented
	"
	^(self anySatisfy: [ :c | c isAccented])
		ifFalse: [ self ]
		ifTrue: [ self collect: [ :c | c asUnaccented ]]! !

!String methodsFor: 'converting' stamp: 'SqR 6/13/2000 20:10'!
asUppercase
	"Answer a String made up from the receiver whose characters are all
	uppercase."

	^self copy asString translateToUppercase! !

!String methodsFor: 'converting' stamp: 'jmv 2/8/2013 08:40'!
asUtf8
	"Convert the given string to UTF-8 from the internal encoding: ISO Latin 9 (ISO 8859-15)
	Answer a ByteArray.

	See #fromUtf8: "

	^self asUtf8: false! !

!String methodsFor: 'converting' stamp: 'jmv 9/4/2016 13:12:15'!
asUtf8: convertEmbeddedNCRs
	"Convert the given string to UTF-8 from the internal encoding: ISO Latin 9 (ISO 8859-15)
	Answer a ByteArray.

	If convertEmbeddedNCRs, then convert embedded NCRs such as '&#956;' (decimal) or '&#x03BC;' (hex) to CodePoints.
	See http://en.wikipedia.org/wiki/Numeric_character_reference


	Note: The conversion of NCRs is reversible. See #fromUtf8:hex:trimLastNull:
	This allows handling the full Unicode in Cuis tools, that can only display the Latin alphabet, by editing the NCRs.
	The conversions can be done when reading / saving files, or when pasting from Clipboard and storing back on it.

Copy the following and paste in your external text editor
&#913;&#945; 	Alpha
&#914;&#946; 	Beta
&#915;&#947; 	Gamma
&#916;&#948; 	Delta
&#917;&#949; 	Epsilon
&#918;&#950; 	Zeta
&#919;&#951; 	Eta
&#920;&#952; 	Theta
&#921;&#953; 	Iota
&#922;&#954; 	Kappa
&#923;&#955; 	Lambda
&#924;&#956; 	Mu
&#925;&#957; 	Nu
&#926;&#958; 	Xi
&#927;&#959; 	Omicron
&#928;&#960; 	Pi
&#929;&#961; 	Rho
&#931;&#963;&#962; 	Sigma
&#932;&#964; 	Tau
&#933;&#965; 	Upsilon
&#934;&#966; 	Phi
&#935;&#967; 	Chi
&#936;&#968; 	Psi
&#937;&#969; 	Omega
&# 937;&# 969; 	Not a NCR, just regular ASCII chars!!
	"

	| str |
	^ByteArray streamContents: [ :outStream | | inStream nextChar prevPos maybeUnicodeNCR ncrEnd codePoint |
		inStream := self readStream.
		[ inStream atEnd ] whileFalse: [
			nextChar := inStream next.
			(convertEmbeddedNCRs and: [ nextChar = $& ])
				ifTrue: [
					prevPos := inStream position.
					ncrEnd := 0.
					maybeUnicodeNCR := inStream next: 9.
					(maybeUnicodeNCR notEmpty and: [ maybeUnicodeNCR first = $# ]) ifTrue: [
						ncrEnd := maybeUnicodeNCR indexOf: $; ].
					ncrEnd = 0
						ifFalse: [
							maybeUnicodeNCR second = $x
								ifTrue: [
									str := (maybeUnicodeNCR copyFrom: 3 to: ncrEnd) asUppercase.
									(str first isDigit or: [ str first asciiValue between: $A asciiValue and: $F asciiValue])
										ifTrue: [ codePoint :=  ('16r', str) asNumber ]
										ifFalse: [ ncrEnd := 0 ]]
								ifFalse: [
									str := maybeUnicodeNCR copyFrom: 2 to: ncrEnd.
									str first isDigit
										ifTrue: [ codePoint :=  codePoint := str asNumber ]
										ifFalse: [ ncrEnd := 0 ]]].
					ncrEnd = 0
						ifTrue: [
							"Not an NCR after all. Just add the $& and continue from there"
							codePoint := nextChar codePoint ].
					Character
						evaluate: [ :byte | outStream nextPut: byte ]
						withUtf8BytesOfUnicodeCodePoint: codePoint.
					inStream position: prevPos + ncrEnd ]
				ifFalse: [
					codePoint := nextChar codePoint.
					Character
						evaluate: [ :byte | outStream nextPut: byte ]
						withUtf8BytesOfUnicodeCodePoint: codePoint ]]]! !

!String methodsFor: 'converting' stamp: 'jmv 3/6/2018 17:40:38'!
asValidInstanceVariableName
	| answer |
	answer := self asIdentifier: false.
	(Scanner pseudoVariableNames includes: answer)
		ifTrue: [ answer := answer , 'x' ].
	^ answer

"
'234znak 43 ) 2' asValidInstanceVariableName
'234 xx\ Uml /ler42342380-4' asValidInstanceVariableName
"! !

!String methodsFor: 'converting' stamp: 'jmv 3/6/2018 17:32:02'!
asValidSelector
	^ self asIdentifier: false

"
'234znak 43 ) 2' asValidSelector
"! !

!String methodsFor: 'converting' stamp: 'jmv 5/12/2017 16:39:13'!
asWeek
	"
		'2008-W52' asWeek.
		'2008-W53' asWeek. 'Invalid format!!'.
		'2009-W01' asWeek
		'2009-W02' asWeek
		'2009-W53' asWeek
		'2010-W01' asWeek
		'2010-W02' asWeek
		'2008-W52' asWeek start.
		'2009-W01' asWeek start
		'2009-W02' asWeek start
		'2009-W53' asWeek start
		'2010-W01' asWeek start
		'2010-W02' asWeek start
	"

	^ Week fromString: self! !

!String methodsFor: 'converting' stamp: 'jmv 5/12/2017 16:37:23'!
asYear
	"
		'2008' asYear.
		'2008' asYear start.
	"

	^ Year fromString: self! !

!String methodsFor: 'converting' stamp: 'jmv 9/19/2016 09:33:15'!
base64Decoded
	"Decode the receiver from base 64"
	"
	'SGVsbG8gV29ybGQ=' base64Decoded
	'SGVsbG8gV29ybGQ=' base64Decoded asString
	"
	^(Base64MimeConverter mimeDecode: self)! !

!String methodsFor: 'converting' stamp: 'ls 9/10/1998 08:48'!
capitalized
	"Return a copy with the first letter capitalized"
	| cap |
	self isEmpty ifTrue: [ ^self copy ].
	cap := self copy.
	cap at: 1 put: (cap at: 1) asUppercase.
	^ cap! !

!String methodsFor: 'converting' stamp: 'di 1/16/98 16:33'!
contractTo: smallSize
	"return myself or a copy shortened by ellipsis to smallSize"
	| leftSize |
	self size <= smallSize
		ifTrue: [^ self].  "short enough"
	smallSize < 5
		ifTrue: [^ self copyFrom: 1 to: smallSize].    "First N characters"
	leftSize := smallSize-2//2.
	^ self copyReplaceFrom: leftSize+1		"First N/2 ... last N/2"
		to: self size - (smallSize - leftSize - 3)
		with: '...'
"
	'A clear but rather long-winded summary' contractTo: 18
"! !

!String methodsFor: 'converting'!
correctAgainst: wordList
	"Correct the receiver: assume it is a misspelled word and return the (maximum of five) nearest words in the wordList.  Depends on the scoring scheme of alike:"
	| results |
	results := self correctAgainst: wordList continuedFrom: nil.
	results := self correctAgainst: nil continuedFrom: results.
	^ results! !

!String methodsFor: 'converting' stamp: 'jmv 3/2/2010 16:36'!
correctAgainst: wordList continuedFrom: oldCollection
	"Like correctAgainst:.  Use when you want to correct against several lists, give nil as the first oldCollection, and nil as the last wordList."

	^ wordList
		ifNil: [
			self correctAgainstEnumerator: nil continuedFrom: oldCollection ]
		ifNotNil: [
			self
				correctAgainstEnumerator: [ :action | wordList do: action without: nil]
				continuedFrom: oldCollection ]! !

!String methodsFor: 'converting' stamp: 'jmv 3/2/2010 16:37'!
correctAgainstDictionary: wordDict continuedFrom: oldCollection
	"Like correctAgainst:continuedFrom:.  Use when you want to correct against a dictionary."

	^ wordDict
		ifNil: [
			self correctAgainstEnumerator: nil continuedFrom: oldCollection ]
		ifNotNil: [
			self
				correctAgainstEnumerator: [ :action | wordDict keysDo: action ]
				continuedFrom: oldCollection ]! !

!String methodsFor: 'converting' stamp: 'jmv 1/7/2014 22:05'!
displayStringOrText
	"To be used in the UI"
	"Answer this string."

	^ self
! !

!String methodsFor: 'converting' stamp: 'jmv 1/6/2021 11:51:13'!
findPositiveInteger
	"Answer the Integer created by interpreting the receiver as the string representation of an integer.
	Answer nil if no digits, else find the first digit and then all consecutive digits after that"

	| startPosition tail endPosition |
	startPosition := self findFirst: [:ch | ch isDigit].
	startPosition = 0 ifTrue: [^ nil].
	tail := self copyFrom: startPosition to: self size.
	endPosition := tail findFirst: [:ch | ch isDigit not].
	endPosition = 0 ifTrue: [endPosition := tail size + 1].
	^ Number readFrom: (tail copyFrom: 1 to: endPosition - 1) readStream

"
'1796exportFixes-tkMX' findPositiveInteger
'1848recentLogFile-sw'  findPositiveInteger
'donald' findPositiveInteger
'abc234def567' findPositiveInteger
"! !

!String methodsFor: 'converting' stamp: 'jmv 12/30/2020 14:38:23'!
findSelector
	"Revised to use scanner for better removal of extraneous stuff"
	| potentialSelector colonIndex |
	potentialSelector := self withBlanksTrimmed withoutEnclosing: $".
	colonIndex := potentialSelector indexOf: $:.
	"possible keyword selector"
	(colonIndex > 1 and: [ (potentialSelector at: colonIndex - 1) isValidInIdentifiers ]) ifTrue: [
		potentialSelector := [ Scanner findSelectorIn: potentialSelector ] on: Error do: [ :anError |
			anError messageText = Scanner unmatechedCommentQuoteErrorDescription
				ifTrue: [
					potentialSelector := potentialSelector copyWithout: $".
					anError retry ]
				ifFalse: [ anError return: '']]].

	potentialSelector isEmpty ifTrue: [ ^ nil ].
	Symbol
		hasInterned: potentialSelector
		ifTrue: [ :aSymbol | ^ aSymbol ].

	^ nil.! !

!String methodsFor: 'converting' stamp: 'HAW 8/3/2018 11:12:15'!
firstNoBlankIndex

	^self findFirst: [:aChar | aChar isSeparator not ]! !

!String methodsFor: 'converting' stamp: 'jmv 12/8/2008 15:44'!
initialIntegerOrNil
	"Answer the integer represented by the leading digits of the receiver, or nil if the receiver does not begin with a digit"
	| firstNonDigit |
	(self size = 0 or: [self first isDigit not]) ifTrue: [^ nil].
	firstNonDigit := (self findFirst: [:m | m isDigit not]).
	firstNonDigit = 0 ifTrue: [firstNonDigit := self size + 1].
	^ (self copyFrom: 1  to: (firstNonDigit - 1)) asNumber
"
'234Whoopie' initialIntegerOrNil
'wimpy' initialIntegerOrNil
'234' initialIntegerOrNil
'2N' initialIntegerOrNil
'2' initialIntegerOrNil
'  89Ten ' initialIntegerOrNil
'78 92' initialIntegerOrNil
"
! !

!String methodsFor: 'converting' stamp: 'HAW 12/17/2018 18:03:42'!
keywords
	"Answer an array of the keywords that compose the receiver."
	| kwd char keywords isAllValidInIdentifiers |
	keywords := Array streamContents: [ :kwds |
		kwd := WriteStream on: (String new: 16).
		isAllValidInIdentifiers := true.
		1
			to: self size
			do: [ :i |
				char := self at: i.
				kwd nextPut: char.
				char = $: & isAllValidInIdentifiers
					ifTrue: [
						kwds nextPut: kwd contents.
						kwd reset.
						isAllValidInIdentifiers := true ]
					ifFalse: [
						char isValidInIdentifiers ifFalse: [ isAllValidInIdentifiers := false ]]].
		kwd isEmpty ifFalse: [ kwds nextPut: kwd contents ]].

	^ keywords.! !

!String methodsFor: 'converting' stamp: 'HAW 8/3/2018 11:12:25'!
lastNoBlankIndex

	^ self findLast: [:aChar | aChar isSeparator not].
	! !

!String methodsFor: 'converting' stamp: 'jmv 12/6/2011 10:34'!
prefixAndSuffix: aCharacter
	"Answer an array with the prefix up to the last occurrence of aCharacter, and the suffix after it.
	Answer nil if aCharacter is not in self
	'1164-ReferenceStreamFix-jmv.1.cs' prefixAndSuffix: $-
	"
	| i |
	i := self findLast: [ :c | c = aCharacter ].
	i = 0 ifTrue: [ ^ nil ].
	^ { self copyFrom: 1 to: i-1 . self copyFrom: i+1 to: self size }! !

!String methodsFor: 'converting' stamp: 'sma 5/20/2000 17:17'!
romanNumber
	| value v1 v2 |
	value := v1 := v2 := 0.
	self reverseDo:
		[:each |
		v1 := #(1 5 10 50 100 500 1000) at: ('IVXLCDM' indexOf: each).
		v1 >= v2
			ifTrue: [value := value + v1]
			ifFalse: [value := value - v1].
		v2 := v1].
	^ value! !

!String methodsFor: 'converting' stamp: 'jmv 6/14/2012 22:01'!
squeezedTo: n
	"
Examples:
	Do nothing:
		'This one is a rather long phrase' squeezedTo: 32

	1-remove blanks (result can be shorter than asked):
		'This one is a rather long phrase' squeezedTo: 30

	2-remove necessary trailing vowels
		'This one is a rather long phrase' squeezedTo: 24

	3-truncate as needed (and add ellipsis)
		'This one is a rather long phrase' squeezedTo: 15

	4-avoid ellipsis
		'This one is a rather long phrase' squeezedTo: 5
	"
	| vowelCount read write i char allowedVowels str desiredSize postFix j |
	str := self.
	desiredSize := n.
	str size <= n ifTrue: [^str].
	str := str asCamelCase.
	str size <= n ifTrue: [^str].
	postFix := ''.
	desiredSize := n - postFix size.
	vowelCount := str
		inject: 0
		into: [:prev :each | each isVowel ifTrue: [prev + 1] ifFalse: [prev]].
	str size - vowelCount <= desiredSize
		ifTrue: [allowedVowels := vowelCount - (str size - desiredSize)]
		ifFalse: [
			allowedVowels := 0.
			postFix := '...'.
			n - postFix size < 5 ifTrue: [postFix := ''].
			desiredSize := n - postFix size].

	read := str readStream.
	write := String new writeStream.
	i := 0.
	j := 0.
	[read atEnd not and: [j < desiredSize]] whileTrue: [
		char := read next.
		(char isVowel not or: [i < allowedVowels]) ifTrue: [
			char isVowel ifTrue: [i := i + 1].
			write nextPut: char.
			j := j + 1]].
	str := write contents , postFix.
	^ str! !

!String methodsFor: 'converting' stamp: 'jmv 3/2/2010 10:10'!
substrings
	"Answer an array of the substrings that compose the receiver."
	| result end beginning |

	result := WriteStream on: (Array new: 10).



	end := 0.
	"find one substring each time through this loop"
	[
		"find the beginning of the next substring"
		beginning := self indexOfAnyOf: CSNonSeparators startingAt: end+1 ifAbsent: nil.
		beginning notNil ]
	whileTrue: [
		"find the end"
		end := self indexOfAnyOf: CSSeparators startingAt: beginning ifAbsent: [ self size + 1 ].
		end := end - 1.

		result nextPut: (self copyFrom: beginning to: end).

	].

	^result contents! !

!String methodsFor: 'converting' stamp: 'sw 11/25/96'!
surroundedBySingleQuotes
	"Answer the receiver with leading and trailing quotes.  "

	^ $' asString, self, $' asString! !

!String methodsFor: 'converting' stamp: 'ls 8/15/1998 10:31'!
translateFrom: start  to: stop  table: table
	"translate the characters in the string by the given table, in place"
	String translate: self  from: start to: stop table: table! !

!String methodsFor: 'converting' stamp: 'ls 8/18/1998 07:44'!
translateToLowercase
	"Translate all characters to lowercase, in place"

	self translateWith: LowercasingTable! !

!String methodsFor: 'converting' stamp: 'SqR 6/13/2000 20:10'!
translateToUppercase
	"Translate all characters to lowercase, in place"

	self translateWith: UppercasingTable! !

!String methodsFor: 'converting' stamp: 'ls 8/15/1998 08:30'!
translateWith: table
	"translate the characters in the string by the given table, in place"
	^self translateFrom: 1 to: self size table: table! !

!String methodsFor: 'converting'!
truncateTo: smallSize
	"return myself or a copy shortened to smallSize.  1/18/96 sw"

	^ self size <= smallSize
		ifTrue:
			[self]
		ifFalse:
			[self copyFrom: 1 to: smallSize]! !

!String methodsFor: 'converting' stamp: 'sw 9/2/1998 17:09'!
truncateWithElipsisTo: maxLength
	"Return myself or a copy suitably shortened but with elipsis added"

	^ self size <= maxLength
		ifTrue:
			[self]
		ifFalse:
			[(self copyFrom: 1 to: (maxLength - 3)), '...']


	"'truncateWithElipsisTo:' truncateWithElipsisTo: 20"! !

!String methodsFor: 'converting' stamp: 'jmv 3/6/2018 17:15:13'!
uncapitalized
	"Answer an object like the receiver but with first character downshifted if necesary"
	"'MElViN' uncapitalized"
	"#Will uncapitalized"
	| answer |
	self isEmpty ifTrue: [^ self].
	answer := self isString
				ifTrue: ["don't modify receiver"
					self copy]
				ifFalse: [self asString].
	answer at: 1 put: (answer at: 1) asLowercase.
	^ self isString
		ifTrue: [answer]
		ifFalse: [answer as: self class]! !

!String methodsFor: 'converting' stamp: 'jmv 3/13/2012 16:10'!
withBlanksCondensed
	"Return a copy of the receiver with leading/trailing blanks removed
	 and consecutive white spaces condensed as a single space."

	| trimmed lastWasBlank |
	trimmed := self withBlanksTrimmed.
	^String streamContents: [ :stream |
		lastWasBlank := false.
		trimmed do: [ :c |
			c isSeparator
				ifTrue: [ lastWasBlank ifFalse: [ stream space ]]
				ifFalse: [ stream nextPut: c ].
			lastWasBlank := c isSeparator ]].

	"
	' abc  d   ' withBlanksCondensed
	' abc  d
	s
	as   zz 	q 			q' withBlanksCondensed
	"! !

!String methodsFor: 'converting' stamp: 'HAW 8/3/2018 11:13:24'!
withBlanksTrimmed
	"Return a copy of the receiver from which leading and trailing blanks have been trimmed."

	| first |

	first := self firstNoBlankIndex.
	first = 0 ifTrue: [^ ''].  "no non-separator character"

	^ self copyFrom: first to: self lastNoBlankIndex

	" ' abc  d   ' withBlanksTrimmed"
! !

!String methodsFor: 'converting' stamp: 'jmv 4/25/2012 10:59'!
withCuisLineEndings
	"assume the string is textual, and that CR, LF, and CRLF are all
	valid line endings.  Replace each occurence with a single Lf
	('aLine', String crlfString, 'anotherOne') withCuisLineEndings
	"

	^ self withLineEndings: String newLineString! !

!String methodsFor: 'converting' stamp: 'jmv 1/18/2015 10:05'!
withDescriptiveLineEndings
	^ self withLineEndings: '[enter]'! !

!String methodsFor: 'converting' stamp: 'jmv 8/28/2013 10:27'!
withLineEndings: lineEndingString
	"assume the string is textual, and that CR, LF, and CRLF are all valid line endings.
	Answer a new String, where each occurence with is replaced with lineEndingString"
	| cr lf crlf inPos outPos outString lineEndPos newOutPos lineEndingSize |
	cr := Character cr.
	lf := Character lf.
	crlf := CharacterSet new.
	crlf add: cr; add: lf.

	inPos := 1.
	outPos := 1.
	lineEndingSize := lineEndingString size.
	"This could be extremely inefficient if lineEndingString size > 1"
	outString := String new: self size * lineEndingSize.

	[
		lineEndPos := self indexOfAnyOf: crlf startingAt: inPos ifAbsent: [0].
		lineEndPos ~= 0 ] whileTrue: [
			newOutPos := outPos + (lineEndPos - inPos).
			outString replaceFrom: outPos to: newOutPos - 1 with: self startingAt: inPos.
			1 to: lineEndingSize do: [ :i |
				outString at: newOutPos put: (lineEndingString at: i).
				newOutPos := newOutPos + 1 ].
			outPos := newOutPos.
			((self at: lineEndPos) = cr and: [ lineEndPos < self size and: [ (self at: lineEndPos+1) = lf ] ]) ifTrue: [
				"CRLF ending"
				inPos := lineEndPos + 2 ]
			ifFalse: [
				"CR or LF ending"
				inPos := lineEndPos + 1 ]. ].

	"no more line endings.  copy the rest"
	newOutPos := outPos + (self size - inPos).
	outString replaceFrom: outPos to: newOutPos with: self startingAt: inPos.

	^outString copyFrom: 1 to: newOutPos! !

!String methodsFor: 'converting' stamp: 'jmv 3/14/2012 09:14'!
withNewLines
	"Return a copy of the receiver in which backslash (\) characters have been replaced with newLine (i.e. Lf)."

	^ self collect: [ :c | c = $\ ifTrue: [ Character newLineCharacter ] ifFalse: [ c ]].! !

!String methodsFor: 'converting' stamp: 'jmv 12/29/2020 16:46:01'!
withoutEnclosing: aCharacter
	"
	'*Hello*' withoutEnclosing: $*
	"
	| s |
	s := self size.
	s = 0 ifTrue: [ ^ self ].
	^((self at: 1) = aCharacter and: [ (self at: s) = aCharacter ])
		ifTrue: [ self copyFrom: 2 to: s-1 ]
		ifFalse: [ self ]! !

!String methodsFor: 'converting' stamp: 'HAW 8/3/2018 11:02:05'!
withoutLeadingBlanks

	"Return a copy of the receiver from which leading blanks have been trimmed."

	| first |

	first := self firstNoBlankIndex.
	first = 0 ifTrue: [^ ''].
	first = 1 ifTrue: [^ self ].

	"no non-separator character"
	^ self copyFrom: first to: self size

	" '    abc  d  ' withoutLeadingBlanks"
! !

!String methodsFor: 'converting' stamp: 'jmv 10/18/2016 10:57:38'!
withoutPrefix: aString
	"
	'Elvis' withoutPrefix: 'El'
	'Elvis' withoutPrefix: 'Paul'
	"
	^(self beginsWith: aString)
		ifTrue: [ self copyFrom: aString size+1 to: self size ]! !

!String methodsFor: 'converting' stamp: 'HAW 6/8/2019 18:20:03'!
withoutSeparators

	^self reject: [ :aCharacter | aCharacter isSeparator ]! !

!String methodsFor: 'converting' stamp: 'jmv 12/16/2013 22:51'!
withoutSuffix: aString
	"
	'Elvis' withoutSuffix: 'vis'
	'Elvis' withoutSuffix: 'Paul'
	"
	^(self endsWith: aString)
		ifTrue: [ self copyFrom: 1 to: self size - aString size ]! !

!String methodsFor: 'converting' stamp: 'HAW 8/3/2018 11:08:59'!
withoutTrailingBlanks
	"Return a copy of the receiver from which trailing blanks have been trimmed."

	| last |

	last := self lastNoBlankIndex.
	last = 0 ifTrue: [^ ''].  "no non-separator character"
	last = self size ifTrue: [ ^self ].

	^ self copyFrom: 1 to: last

	" ' abc  d   ' withoutTrailingBlanks"
! !


!String methodsFor: 'enumerating' stamp: 'jmv 6/11/2019 12:23:44'!
collect: aBlock
	"Refer to the comment in Collection|collect:."
	| result value stillAString |
	result := self species new: self size.
	stillAString := true.
	1 to: self size do: [ :index |
		value := aBlock value: (self at: index).
		(stillAString and: [ (value is: #Character) not]) ifTrue: [
			result := result asArray.
			stillAString := false ].
		result at: index put: value].
	^ result! !


!String methodsFor: 'displaying' stamp: 'jmv 7/27/2015 17:13'!
displayAt: aPoint
	"Display the receiver as a DisplayText at aPoint on the display screen."

	self displayOn: Display at: aPoint.
	DisplayScreen screenUpdateRequired: nil! !

!String methodsFor: 'displaying' stamp: 'jmv 3/12/2018 15:56:28'!
displayOn: aDisplayMedium
	"Display the receiver on the given DisplayMedium.  5/16/96 sw"

	self displayOn: aDisplayMedium at: `0 @ 0`! !

!String methodsFor: 'displaying' stamp: 'jmv 4/5/2020 21:19:20'!
displayOn: aDisplayMedium at: aPoint
	"Show a representation of the receiver as a DisplayText at location aPoint on aDisplayMedium, using black-colored text."

	^self displayOn: aDisplayMedium at: aPoint textColor: `Color black`
	"
	'Display' displayOn: Display at: 10@10. Display forceToScreen.
	"! !

!String methodsFor: 'displaying' stamp: 'jmv 5/12/2015 14:51'!
displayOn: aDisplayMedium at: aPoint textColor: aColor
	"Show a representation of the receiver as a DisplayText at location aPoint on aDisplayMedium, rendering the text in the designated color"

	^aDisplayMedium getCanvas drawString: self at: aPoint font: nil color: aColor! !

!String methodsFor: 'displaying' stamp: 'jmv 7/17/2017 15:41:46'!
displayProgressAt: aPoint from: minVal to: maxVal during: workBlock
	"Display this string as a caption over a progress bar while workBlock is evaluated.

EXAMPLE (Select next 6 lines and Do It)

'Now here''s some Real Progress'
	displayProgressAt: Sensor mousePoint
	from: 0 to: 100
	during: [:barBlock |
		1 to: 100 do: [:x |
			(Delay forMilliseconds: 10) wait.
			barBlock value: x.]].

['Now here''s some Real Progress'
	displayProgressAt: Sensor mousePoint
	from: 0 to: 100
	during: [:barBlock |
	1 to: 100 do: [:x | barBlock value: x.
			(Delay forMilliseconds: 100) wait]].] fork

['Now here''s some Real Progress'
	displayProgressAt: Sensor mousePoint
	from: 0 to: 10
	during: [:barBlock |
	1 to: 30 do: [:x | barBlock value: x \\ 11.
			(Delay forMilliseconds: 100) wait]]] fork

'Now here''s some Real Progress'
	displayProgressAt: Sensor mousePoint
	from: 0 to: 10
	during: [:barBlock |
	1 to: 30 do: [:x | barBlock value: nil.
			(Delay forMilliseconds: 200) wait]].

HOW IT WORKS (Try this in any other language :-)
Since your code (the last 2 lines in the above example) is in a block,
this method gets control to display its heading before, and clean up
the screen after, its execution.
The key, though, is that the block is supplied with an argument,
named 'bar' in the example, which will update the bar image every
it is sent the message value: x, where x is in the from:to: range.

The use of ProgressInitiationException allows for avoiding actual
progress display, by catching the exception.
"
	^ProgressInitiationException
		display: self
		at: aPoint
		from: minVal
		to: maxVal
		during: workBlock! !


!String methodsFor: 'printing'!
isLiteral

	^true! !

!String methodsFor: 'printing' stamp: 'jmv 3/13/2012 12:48'!
print
	Transcript show: self; newLine! !

!String methodsFor: 'printing' stamp: 'sma 6/1/2000 09:48'!
printOn: aStream
	"Print inside string quotes, doubling inbedded quotes."

	self storeOn: aStream! !

!String methodsFor: 'printing'!
storeOn: aStream
	"Print inside string quotes, doubling inbedded quotes."
	| x |
	aStream nextPut: $'.
	1 to: self size do:
		[:i |
		aStream nextPut: (x := self at: i).
		x == $' ifTrue: [aStream nextPut: x]].
	aStream nextPut: $'! !


!String methodsFor: 'private' stamp: 'jmv 3/2/2010 16:38'!
correctAgainstEnumerator: wordBlock continuedFrom: oldCollection
	"The guts of correction, instead of a wordList, there is a block that should take another block and enumerate over some list with it."

	| choices scoreMin results score maxChoices |
	scoreMin := self size // 2 min: 3.
	maxChoices := 10.
	choices := oldCollection
		ifNil: [ SortedCollection sortBlock: [ :x :y | x value > y value ] ].
	wordBlock
		ifNil: [
			results := OrderedCollection new.
			1 to: (maxChoices min: choices size) do: [ :i | results add: (choices at: i) key ] ]
		ifNotNil: [
			wordBlock value: [ :word |
				(score := self alike: word) >= scoreMin ifTrue: [
					choices add: (Association key: word value: score).
						(choices size >= maxChoices) ifTrue: [ scoreMin := (choices at: maxChoices) value] ] ].
			results := choices ].
	^ results! !

!String methodsFor: 'private' stamp: 'dgd 8/27/2003 19:42'!
evaluateExpression: aString parameters: aCollection
	"private - evaluate the expression aString with
	aCollection as the parameters and answer the
	evaluation result as an string"
	| index |
	index := ('0' , aString) asNumber.

	index isZero
		ifTrue: [^ '[invalid subscript: {1}]' format: {aString}].

	index > aCollection size
		ifTrue: [^ '[subscript is out of bounds: {1}]' format: {aString}].

	^ (aCollection at: index) asString! !

!String methodsFor: 'private' stamp: 'dgd 8/27/2003 19:41'!
getEnclosedExpressionFrom: aStream
	"private - get the expression enclosed between '{' and
	'}' and remove all the characters from the stream"
	| result currentChar |
	result := String new writeStream.

	[aStream atEnd
		or: [(currentChar := aStream next) == $}]]
		whileFalse: [result nextPut: currentChar].

	^ result contents withBlanksTrimmed! !

!String methodsFor: 'private' stamp: 'jmv 1/13/2017 09:58:04'!
replaceFrom: start to: stop with: replacement startingAt: repStart
	"Primitive. This destructively replaces elements from start to stop in the receiver starting at index, repStart, in the collection, replacement. Answer the receiver. Range checks are performed in the primitive only. Optional. See Object documentation whatIsAPrimitive."

	<primitive: 105 error: ec>
	super replaceFrom: start to: stop with: replacement startingAt: repStart! !


!String methodsFor: 'system primitives' stamp: 'ar 2/3/2001 16:12'!
compare: string1 with: string2 collated: order
	"Return 1, 2 or 3, if string1 is <, =, or > string2, with the collating order of characters given by the order array."

	| len1 len2 c1 c2 |
	<primitive: 'primitiveCompareString' module: 'MiscPrimitivePlugin'>
	self var: #string1 declareC: 'unsigned char *string1'.
	self var: #string2 declareC: 'unsigned char *string2'.
	self var: #order declareC: 'unsigned char *order'.

	len1 := string1 size.
	len2 := string2 size.
	1 to: (len1 min: len2) do:
		[:i |
		c1 := order at: (string1 basicAt: i) + 1.
		c2 := order at: (string2 basicAt: i) + 1.
		c1 = c2 ifFalse:
			[c1 < c2 ifTrue: [^ 1] ifFalse: [^ 3]]].
	len1 = len2 ifTrue: [^ 2].
	len1 < len2 ifTrue: [^ 1] ifFalse: [^ 3].
! !

!String methodsFor: 'system primitives' stamp: 'jmv 9/5/2016 17:14:46'!
findSubstring: key in: body startingAt: start matchTable: matchTable
	"Answer the index in the string body at which the substring key first occurs, at or beyond start.  The match is determined using matchTable, which can be used to effect, eg, case-insensitive matches.  If no match is found, zero will be returned.

	The algorithm below is not optimum -- it is intended to be translated to C which will go so fast that it wont matter."
	| index |
	<primitive: 'primitiveFindSubstring' module: 'MiscPrimitivePlugin'>
	self var: #key declareC: 'unsigned char *key'.
	self var: #body declareC: 'unsigned char *body'.
	self var: #matchTable declareC: 'unsigned char *matchTable'.

	key size = 0 ifTrue: [^ 0].
	start to: body size - key size + 1 do:
		[:startIndex |
		index := 1.
			[(matchTable at: (body at: startIndex+index-1) numericValue + 1)
				= (matchTable at: (key at: index) numericValue + 1)]
				whileTrue:
				[index = key size ifTrue: [^ startIndex].
				index := index+1]].
	^ 0
"
' ' findSubstring: 'abc' in: 'abcdefabcd' startingAt: 1 matchTable: CaseSensitiveOrder 1
' ' findSubstring: 'abc' in: 'abcdefabcd' startingAt: 2 matchTable: CaseSensitiveOrder 7
' ' findSubstring: 'abc' in: 'abcdefabcd' startingAt: 8 matchTable: CaseSensitiveOrder 0
' ' findSubstring: 'abc' in: 'abcdefABcd' startingAt: 2 matchTable: CaseSensitiveOrder 0
' ' findSubstring: 'abc' in: 'abcdefABcd' startingAt: 2 matchTable: CaseInsensitiveOrder 7
"! !

!String methodsFor: 'system primitives' stamp: 'jmv 12/14/2018 15:27:30'!
numArgs
	"Answer either the number of arguments that the receiver would take if considered a selector.
	Answer -1 if it couldn't be a selector.
		Note that currently this will answer -1 for anything begining with an uppercase letter even though
		the system will accept such symbols as selectors.  It is intended mostly for the assistance of spelling correction."
	| firstChar numColons start ix |
	self size = 0 ifTrue: [ ^ -1 ].
	"Binary messages"
	(self allSatisfy: [ :c | c isValidInBinarySelectors ])
		ifTrue: [ ^1 ].
	"Unary and keyword messages"
	firstChar := self at: 1.
	firstChar isValidStartOfIdentifiers ifTrue: [
		"Fast reject if any chars are non-alphanumeric"
		(self
			findSubstring: '~'
			in: self
			startingAt: 1
			matchTable: Tokenish) > 0 ifTrue: [ ^ -1 ].
		"Fast colon count"
		numColons := 0.
		start := 1.
		[
		(ix := self
			findSubstring: ':'
			in: self
			startingAt: start
			matchTable: CaseSensitiveOrder) > 0 ] whileTrue: [
			numColons := numColons + 1.
			start := ix + 1 ].
		^ numColons ].
	^ -1.! !


!String methodsFor: 'testing' stamp: 'RAA 6/21/1999 11:28'!
hasContentsInExplorer

	^false! !

!String methodsFor: 'testing' stamp: 'jpb 8/3/2019 00:01:22'!
is: aSymbol
	"Note: Senders might prefer #isString for perfomance reasons. Still, Cuis tries to keep isXXX testing selectors to a minimum."
	^#String = aSymbol or: [ super is: aSymbol]! !

!String methodsFor: 'testing' stamp: 'len 11/26/2016 09:05:35'!
isAlphaNumeric
	"Answer true if the receiver contains only letters or digits."
	^ self allSatisfy: [:each| each isAlphaNumeric]! !

!String methodsFor: 'testing' stamp: 'jmv 7/4/2016 22:01'!
isRemote
	^false! !

!String methodsFor: 'testing' stamp: 'sma 6/15/2000 15:48'!
isString
	^ true! !


!String methodsFor: 'paragraph support' stamp: 'jmv 3/14/2012 08:22'!
encompassLine: anInterval
	"Return an interval that includes anInterval, and that comprises one or several whole paragraphs in the receiver.
	Answer starts at the position following a newLine (or eventually 1) and ends before a newLine (or eventually at self size)
	See also encompassParagraph:"
	| left rightCr rightNull |
	left := (self lastIndexOf: Character newLineCharacter startingAt: anInterval first - 1 ifAbsent:[0]) + 1.
	rightCr := (self indexOf: Character newLineCharacter startingAt: (anInterval last max: anInterval first) ifAbsent: [self size+1])-1.
	rightNull := (self indexOf: Character null startingAt: (anInterval last max: anInterval first) ifAbsent: [self size+1])-1.
	^left to: (rightCr min: rightNull)! !

!String methodsFor: 'paragraph support' stamp: 'jmv 3/14/2012 08:22'!
encompassParagraph: anInterval
	"Return an interval that includes anInterval, and that comprises one or several whole paragraphs in the receiver.
	Answer starts at the position following a newLine (or eventually 1) and ends at a newLine (or eventually at self size).
	Look also for null characters. Never include null characters in the answer.
	See also #encompassLine:"
	| left rightCr rightNull |
	left := (self lastIndexOf: Character newLineCharacter startingAt: anInterval first - 1 ifAbsent:[0]) + 1.
	rightCr := (self indexOf: Character newLineCharacter startingAt: (anInterval last max: anInterval first) ifAbsent: [self size]).
	rightNull := (self indexOf: Character null startingAt: (anInterval last max: anInterval first) ifAbsent: [self size+1])-1.
	^left to: (rightCr min: rightNull)! !

!String methodsFor: 'paragraph support' stamp: 'jmv 3/14/2012 08:34'!
endOfParagraphBefore: aNumber
	"Return the index of the last Character newLineCharacter before position aNumber, or zero if this is the first paragraph.
	'ddd' endOfParagraphBefore: 3
	'dd
	d' endOfParagraphBefore: 4
	"
	^ self lastIndexOf: Character newLineCharacter startingAt: aNumber - 1 ifAbsent: [ 0 ]! !

!String methodsFor: 'paragraph support' stamp: 'jmv 3/16/2012 12:12'!
indentationIfBlank: aBlock
	"Answer the number of leading tabs in the receiver.  If there are
	 no visible characters, pass the number of tabs to aBlock and return its value."
	| reader leadingTabs lastSeparator tab ch |
	tab := Character tab.
	reader := ReadStream on: self.
	leadingTabs := 0.
	[ reader atEnd not and: [ (ch := reader next) == tab ]] whileTrue: [
		leadingTabs := leadingTabs + 1 ].
	lastSeparator := leadingTabs + 1.
	[ reader atEnd not and: [
		ch isSeparator and: [ ch isLineSeparator not ]]] whileTrue: [
			lastSeparator := lastSeparator + 1.
			ch := reader next ].
	lastSeparator = self size | (ch notNil and: [ch isLineSeparator]) ifTrue: [
		^ aBlock value: leadingTabs ].
	^ leadingTabs! !


!String methodsFor: 'arithmetic' stamp: 'jmv 9/7/2011 07:30'!
* arg

	self shouldNotImplement.
"	^ arg adaptToString: self andSend: #*"! !

!String methodsFor: 'arithmetic' stamp: 'jmv 9/7/2011 07:29'!
+ arg

	self shouldNotImplement.
"	^ arg adaptToString: self andSend: #+"! !

!String methodsFor: 'arithmetic' stamp: 'jmv 9/7/2011 07:30'!
- arg

	self shouldNotImplement.
"	^ arg adaptToString: self andSend: #-"! !

!String methodsFor: 'arithmetic' stamp: 'pb 5/25/2016 01:13'!
/ arg
	"If working with file paths, just use $/
	Or better yet, use DirectoryEntry protocol"

	self shouldNotImplement! !

!String methodsFor: 'arithmetic' stamp: 'jmv 9/7/2011 07:30'!
// arg

	self shouldNotImplement.
"	^ arg adaptToString: self andSend: #//"! !

!String methodsFor: 'arithmetic' stamp: 'jmv 9/7/2011 07:30'!
\\ arg

	self shouldNotImplement.
"	^ arg adaptToString: self andSend: #\\"! !


!String methodsFor: 'user interface' stamp: 'jmv 1/2/2013 15:26'!
edit

	self editLabel: 'Text Editor'! !

!String methodsFor: 'user interface' stamp: 'jmv 1/2/2013 15:26'!
editLabel: labelString

	TextModel new contents: self; openLabel: labelString! !


!String methodsFor: 'formatting' stamp: 'dgd 8/27/2003 19:49'!
format: aCollection
	"format the receiver with aCollection

	simplest example:
	'foo {1} bar' format: {Date today}.

	complete example:
	'\{ \} \\ foo {1} bar {2}' format: {12. 'string'}.
	"
	| result stream |
	result := String new writeStream.
	stream := self readStream.

	[stream atEnd]
		whileFalse: [| currentChar |
			currentChar := stream next.
			currentChar == ${
				ifTrue: [| expression |
					expression := self getEnclosedExpressionFrom: stream.
					result
						nextPutAll: (self evaluateExpression: expression parameters: aCollection)]
				ifFalse: [
					currentChar == $\
						ifTrue: [stream atEnd
								ifFalse: [result nextPut: stream next]]
						ifFalse: [result nextPut: currentChar]]].

	^ result contents! !


!String methodsFor: 'uCompletion' stamp: 'jmv 11/1/2011 23:20'!
separateKeywords

	^self, ' '! !


!String methodsFor: 'fileman-converting' stamp: 'pb 5/25/2016 01:21'!
asAbsolutePathName
	"See comment at #isAbsolutePathName"

	| slash |
	slash := FileIOAccessor default slash.
	^ String streamContents: [ :childPath |
		childPath nextPutAll: slash.
		(FileIOAccessor default absolutePathComponentsFor: self)
			do: [ :each | childPath nextPutAll: each]
			separatedBy: [childPath nextPutAll: slash]]! !

!String methodsFor: 'fileman-converting' stamp: 'jmv 8/1/2018 16:17:21'!
asDirectoryEntry
	"See examples in #asFileEntry method comment"
	^DirectoryEntry withPathName: self! !

!String methodsFor: 'fileman-converting' stamp: 'pb 5/25/2016 01:21'!
asDriveName
	"Answer a real drive name, or else answer nil.
	(Original FileMan implementation would answer first token on Mac even if it is not a Drive Name,
	and self in any case in other Unix variants)

Windows
	'C:\' asDriveName 'C:'
	'NotAChance' asDriveName nil

Linux
	'/media/cdrom' asDriveName nil

MacOsX
    '/SanDisk32-NTFS' asDriveName nil

	"

	| candidate |
	FileIOAccessor default onWindows ifTrue: [
		self beginsWithWindowsDriveName ifTrue: [
		^self copyFrom: 1 to: 2 ]].

	(FileIOAccessor default onMacClassic) ifTrue: [
		candidate := self upToFirstPathSeparator.
		"Aparently on Mac Classic,
			xxx/yyy means xxx must be a drive name
			/xxx/yyy means xxx could be any folder in root. Check to make sure!!
		"
		('/' asDirectoryEntry directoryNames includes: candidate) ifTrue: [
			^candidate ]].

	^ nil! !

!String methodsFor: 'fileman-converting' stamp: 'jmv 8/1/2018 16:17:23'!
asFileEntry
	"

Windows
	'C:\Windows' asFileEntry exists false
	'C:\Windows' asDirectoryEntry exists true
	'/' asFileEntry exists false
	'/' asDirectoryEntry exists false
	'C:\' asFileEntry exists false
	'C:\' asDirectoryEntry exists true
	('C:' asDirectoryEntry // 'Windows') exists false
	('C:' asDirectoryEntry / 'Windows') exists true

Linux
    '/var' asFileEntry exists
    '/var' asDirectoryEntry exists true
    '/' asFileEntry exists false
    '/' asDirectoryEntry exists true
    '/media/cdrom' asFileEntry exists false
    '/media/cdrom' asDirectoryEntry exists true
    ('/bin' asDirectoryEntry / 'more') exists false
    ('/bin' asDirectoryEntry // 'more') exists true

MacOsX
    '/var' asFileEntry exists false
    '/var' asDirectoryEntry exists true
    '/' asFileEntry exists false
    '/' asDirectoryEntry exists  true
    '/Volumes/SanDisk32-NTFS' asFileEntry exists false
    '/Volumes/SanDisk32-NTFS' asDirectoryEntry exists true
    'SanDisk32-NTFS' asFileEntry exists false
    'SanDisk32-NTFS' asDirectoryEntry exists false

	"
	self isRelativeMark ifTrue: [ ^self error: 'Maybe you need to call #asDirectoryEntry!!' ].
	^FileEntry withPathName: self! !

!String methodsFor: 'fileman-converting' stamp: 'mu 3/4/2007 11:04'!
asPathComponents
	| tokens |

	self isRelativePathName ifTrue: [self error: 'relative form is invaild!!'].

	tokens := self asPathTokens.
	^tokens! !

!String methodsFor: 'fileman-converting' stamp: 'jmv 6/6/2015 23:56'!
asPathTokens

	^self beginsWithWindowsDriveName
		ifTrue: [
			(OrderedCollection with: (self copyFrom: 1 to: 2)),
				((self copyFrom: 3 to: self size) findTokens: String pathSeparators) ]
		ifFalse: [
			self findTokens: String pathSeparators ]! !

!String methodsFor: 'fileman-converting' stamp: 'jmv 6/6/2015 23:44'!
withoutWindowsDriveName
	^self beginsWithWindowsDriveName
		ifFalse: [ self ]
		ifTrue: [ self copyFrom: 3 to: self size ]! !


!String methodsFor: 'fileman-testing' stamp: 'mu 3/4/2007 10:22'!
beginsWithPathSeparator
	self ifEmpty: [^false].
	^self first isPathSeparator! !

!String methodsFor: 'fileman-testing' stamp: 'jmv 9/17/2015 10:36'!
beginsWithWindowsDriveName
	"Answer doesn't depend on running on Windows or not"
	self size < 2 ifTrue: [ ^false ].
	^self first isDriveLetter
		and: [ self second isDriveSeparator
			and: [ self size = 2 or: [ self third isPathSeparator ]]]! !

!String methodsFor: 'fileman-testing' stamp: 'pb 5/25/2016 01:21'!
isAbsolutePathName
	"Note: On Windows, both 'C:\Users\Someone\file.txt' and '\Users\Someone\file.txt'
	and even '/Users/Someone/file.txt' are considered an absolute pathName.
	This is essentially because FilePlugin can handle them. The gained uniformity with Unix is nice."
	| upperName |
	self isEmpty ifTrue: [^ false].
	self first isPathSeparator ifTrue: [^ true].

	FileIOAccessor default onWindows
		ifTrue: [
			^ self beginsWithWindowsDriveName and: [ self size = 2 or: [ (self at: 3) isPathSeparator ]]].

	FileIOAccessor default onMacClassic ifTrue: [
		upperName := self asUppercase.
		^'/' asDirectoryEntry directoryNames anySatisfy: [ :each |
			(upperName beginsWith: each)
					and: [| nextPos |
						nextPos := each size + 1 min: self size max: 1.
						(self at: nextPos) isPathSeparator ]]].

	^ false! !

!String methodsFor: 'fileman-testing' stamp: 'pb 5/25/2016 01:21'!
isDriveName
	FileIOAccessor default onWindows
		ifTrue: [
			^ (self size between: 2 and: 3)
				and: [self beginsWithWindowsDriveName]].

	FileIOAccessor default onMacClassic ifTrue: [
		^'/' asDirectoryEntry directoryNames includes: self].

	^false! !

!String methodsFor: 'fileman-testing' stamp: 'mu 3/2/2007 22:05'!
isPathSeparator
	self = '\' ifTrue: [^true].
	self = ':' ifTrue: [^true].
	self = '/' ifTrue: [^true].
	^false! !

!String methodsFor: 'fileman-testing' stamp: 'mu 6/11/2006 22:41'!
isRelativeMark

	self = '.' ifTrue: [^true].
	self = '..' ifTrue: [^true].

	^false! !

!String methodsFor: 'fileman-testing' stamp: 'mu 3/4/2007 10:46'!
isRelativePathName
	self ifEmpty: [^false].
	self isRelativeMark ifTrue: [^true].
	^#('.' '..') includes: self upToFirstPathSeparator ! !


!String methodsFor: 'fileman-actions' stamp: 'mu 6/11/2006 22:12'!
fileContents
	^self asFileEntry fileContents! !

!String methodsFor: 'fileman-actions' stamp: 'mu 6/11/2006 22:19'!
fileContents: aString
	self asFileEntry fileContents: aString.
	^aString! !


!String methodsFor: 'fileman-accessing' stamp: 'jmv 4/2/2016 23:07'!
indexOfFirstPathSeparator
	self
		withIndexDo: [:each :idx | each isPathSeparator
				ifTrue: [^ idx]].
	^ 0! !

!String methodsFor: 'fileman-accessing' stamp: 'jmv 10/16/2015 14:21'!
indexOfLastPathSeparator
	"
	'pp.txt' indexOfLastPathSeparator
	'/pp.txt' indexOfLastPathSeparator
	'a/pp.txt' indexOfLastPathSeparator
	'b/a/pp.txt' indexOfLastPathSeparator
	'/b/a/pp.txt' indexOfLastPathSeparator
	"
	^self findLast: [ :char | char isPathSeparator ]! !

!String methodsFor: 'fileman-accessing' stamp: 'mu 5/7/2007 15:55'!
pathAndLocalName
	| index path localName |
	index := self indexOfLastPathSeparator.
	index = 0 ifTrue: [^{''. self}].

	path := self copyFrom: 1 to: index-1.
	localName := self copyFrom: index+1 to: self size.

	^{path. localName}

	! !

!String methodsFor: 'fileman-accessing' stamp: 'mu 3/4/2007 10:45'!
upToFirstPathSeparator
	| index |
	self ifEmpty: [^self].
	index := self indexOfFirstPathSeparator.
	index = 0 ifTrue: [^self].
	^self copyFrom: 1 to: index - 1
	! !

!String methodsFor: 'fileman-accessing' stamp: 'mu 5/7/2007 15:49'!
upToLastPathSeparator
	| index |
	self ifEmpty: [^self].
	index := self indexOfLastPathSeparator.
	index = 0 ifTrue: [^self].
	^self copyFrom: 1 to: index - 1
	! !


!String methodsFor: 'text conversion emphasis' stamp: 'len 6/3/2019 10:24:00'!
bold
	"Stuff like
	('X' italic, '2' super, ' + ', 'H' bold, 'ij' sub, ' + ', 'lim' italic under, 'z  ' sub, '(1 / z)' ) edit
	"
	^self asText bold! !

!String methodsFor: 'text conversion emphasis' stamp: 'len 6/3/2019 10:24:16'!
italic
	"Stuff like
	('X' italic, '2' super, ' + ', 'H' bold, 'ij' sub, ' + ', 'lim' italic under, 'z  ' sub, '(1 / z)' ) edit
	"
	^self asText italic! !

!String methodsFor: 'text conversion emphasis' stamp: 'jmv 9/3/2019 10:17:21'!
pointSize: pointSize
	"Stuff like
	('Hello World' pointSize: 22) edit
	"
	^self asText pointSize: pointSize! !

!String methodsFor: 'text conversion emphasis' stamp: 'len 6/6/2016 02:14'!
struck
	^self asText struck! !

!String methodsFor: 'text conversion emphasis' stamp: 'len 6/3/2019 10:24:18'!
sub
	"Stuff like
	('X' italic, '2' super, ' + ', 'H' bold, 'ij' sub, ' + ', 'lim' italic under, 'z  ' sub, '(1 / z)' ) edit
	"
	^self asText sub! !

!String methodsFor: 'text conversion emphasis' stamp: 'len 6/3/2019 10:24:20'!
super
	"Stuff like
	('X' italic, '2' super, ' + ', 'H' bold, 'ij' sub, ' + ', 'lim' italic under, 'z  ' sub, '(1 / z)' ) edit
	"
	^self asText super! !

!String methodsFor: 'text conversion emphasis' stamp: 'len 6/3/2019 10:24:24'!
under
	"Stuff like
	('X' italic, '2' super, ' + ', 'H' bold, 'ij' sub, ' + ', 'lim' italic under, 'z  ' sub, '(1 / z)' ) edit
	"
	^self asText under! !


!String methodsFor: 'text conversion attributes' stamp: 'jmv 9/3/2019 10:08:21'!
centered
	"Stuff like
	('Hello world' centered ) edit
	"
	^self asText centered! !

!String methodsFor: 'text conversion attributes' stamp: 'jmv 9/3/2019 10:08:52'!
justified
	"Stuff like
	('Hello world' justified ) edit
	"
	^self asText justified! !

!String methodsFor: 'text conversion attributes' stamp: 'jmv 9/3/2019 10:09:50'!
leftFlush
	"Stuff like
	('Hello world' leftFlush ) edit
	"
	^self asText leftFlush! !

!String methodsFor: 'text conversion attributes' stamp: 'jmv 9/3/2019 10:10:05'!
rightFlush
	"Stuff like
	('Hello world' rightFlush ) edit
	"
	^self asText rightFlush! !


!String methodsFor: 'text conversion color' stamp: 'jmv 9/3/2019 10:29:49'!
black
	"Stuff like
	'Hello world' black edit
	"
	^self asText black! !

!String methodsFor: 'text conversion color' stamp: 'jmv 9/3/2019 10:29:58'!
blue
	"Stuff like
	'Hello world' blue edit
	"
	^self asText blue! !

!String methodsFor: 'text conversion color' stamp: 'jmv 9/3/2019 10:30:04'!
cyan
	"Stuff like
	'Hello world' cyan edit
	"
	^self asText cyan! !

!String methodsFor: 'text conversion color' stamp: 'jmv 9/3/2019 10:30:11'!
gray
	"Stuff like
	'Hello world' gray edit
	"
	^self asText gray! !

!String methodsFor: 'text conversion color' stamp: 'jmv 9/3/2019 10:30:19'!
green
	"Stuff like
	'Hello world' green edit
	"
	^self asText green! !

!String methodsFor: 'text conversion color' stamp: 'jmv 9/3/2019 10:31:04'!
magenta
	"Stuff like
	'Hello world' magenta edit
	"
	^self asText magenta! !

!String methodsFor: 'text conversion color' stamp: 'jmv 9/3/2019 10:31:17'!
red
	"Stuff like
	'Hello world' red edit
	"
	^self asText red! !

!String methodsFor: 'text conversion color' stamp: 'jmv 9/3/2019 10:31:27'!
yellow
	"Stuff like
	'Hello world' yellow edit
	"
	^self asText yellow! !


!String methodsFor: 'grammar' stamp: 'LC 7/5/2020 16:47:58'!
article
	| article first letter second |
	self isEmpty ifTrue: [^self].
	article := self first isVowel ifTrue: ['an'] ifFalse: ['a'].
	first := self first asLowercase.
	letter := self size = 1.
	second := letter ifFalse: [self second asLowercase].
	(first = $f and: [letter orNot: ['aeiloru' includes: second]])
		ifTrue: [^'an'].
	first = $u ifTrue: [
		(letter or: ['cks' includes: second]) ifTrue: [^'a'].
		second = $n
			ifTrue: [(self size = 2 or: [self third isVowel]) ifTrue: [^'a']]].
	(first = $e and: [second = $u]) ifTrue: [^'a'].
	^article! !

!String methodsFor: 'grammar' stamp: 'LC 4/25/2020 10:29:48'!
asPlural
	| k trimmed plural n |
	k := self findFirst: [:ch | ch isSeparator not].
	k > 1
		ifTrue: [^(self copyFrom: 1 to: k - 1) , (self allButFirst: k - 1) asPlural].
	trimmed := self withBlanksTrimmed.
	trimmed isEmpty ifTrue: [^''].
	plural := trimmed asLowercase lowercasePlural.
	n := trimmed size min: plural size.
	1 to: n do: [:i |
		(trimmed at: i) isUppercase
			ifTrue: [plural at: i put: (plural at: i) asUppercase]].
	^plural! !

!String methodsFor: 'grammar' stamp: 'LC 6/19/2020 12:52:49'!
exceptionalPlural
	| singular plural index |
	singular := #(
		'addendum' 'aircraft' 'alga' 'alumna' 'alumnus' 'amoeba' 'antenna' 'appendix' 'automaton'
		'bacillus' 'bacterium' 'barracks'
		'cactus' 'calculus' 'child' 'cicatrix' 'colossus' 'corpus' 'corrigendum' 'criterion' 'curriculum'
		'datum' 'deer' 'desideratum' 'dwarf'
		'echo' 'embargo' 'ephemeris' 'erratum' 'extremum'
		'fish' 'focus' 'foot' 'forum' 'fungus'
		'gallows' 'genus' 'goose'
		'hero'
		'index' 'infimum' 'is'
		'lacuna' 'larva' 'louse'
		'matrix' 'maximum' 'means' 'memorandum' 'minimum' 'mythos' 'money' 'mouse'
		'nucleus'
		'offspring' 'optimum' 'opus' 'ox'
		'person' 'phenomenon' 'phylum' 'potato' 'proof'
		'quantum'
		'roof'
		'series' 'sheep' 'species' 'spoof' 'stimulus' 'stratum' 'syllabus'
		'tomato' 'tooth' 'torpedo' 'trilby'
		'vertebra' 'vertex' 'veto'
		'was').
	plural := #(
		'addenda' 'aircraft' 'algae' 'alumnae' 'alumni' 'amoebae' 'antennae' 'appendices' 'automata'
		'bacilli' 'bacteria' 'barracks'
		'cacti' 'calculi' 'children' 'cicatrices' 'colossi' 'corpora' 'corrigenda' 'criteria' 'curricula'
		'data' 'deer' 'desiderata' 'dwarfs'
		'echoes' 'embargoes' 'ephemerides' 'errata' 'extrema'
		'fish' 'foci' 'feet' 'fora' 'fungi'
		'gallows' 'genera' 'geese'
		'heroes'
		'indices' 'infima' 'are'
		'lacunae' 'larvae' 'lice'
		'matrices' 'maxima' 'means' 'memoranda' 'minima' 'mythoi' 'moneys' 'mice'
		'nuclei'
		'offspring' 'optima' 'opera' 'oxen'
		'people' 'phenomena' 'phyla' 'potatoes' 'proofs'
		'quanta'
		'roofs'
		'series' 'sheep' 'species' 'spoofs' 'stimuli' 'strata' 'syllabi'
		'tomatoes' 'teeth' 'torpedoes' 'trilbys'
		'vertebrae' 'vertices' 'vetoes'
		'were').
	index := singular indexOf: self.
	^index > 0 ifTrue: [plural at: index]! !

!String methodsFor: 'grammar' stamp: 'LC 4/25/2020 10:25:45'!
isUninflictedNoun
	| nouns |
	nouns := #(
		'bison' 'bream' 'breeches' 'britches'
		'carp' 'chassis' 'clippers' 'cod' 'contretemps' 'corps'
		'debris' 'diabetes' 'djinn'
		'eland' 'elk'
		'flounder'
		'gallows' 'graffiti'
		'headquarters' 'herpes' 'high-jinks' 'homework'
		'innings'
		'jackanapes'
		'mackerel' 'measles' 'mews' 'mumps'
		'news'
		'pincers' 'pliers' 'proceedings'
		'rabies'
		'salmon' 'scissors' 'sea-bass' 'series' 'shears' 'species' 'swine'
		'trout' 'tuna'
		'whiting' 'wildebeest').
	^nouns includes: self! !

!String methodsFor: 'grammar' stamp: 'LC 4/25/2020 10:24:38'!
lowercasePlural
	| last |
	self exceptionalPlural ifNotNil: [:pl | ^pl].
	self isUninflictedNoun ifTrue: [^self].
	last := self last.
	last = $y ifTrue: [
		#('ay' 'ey' 'oy' 'uy') do: [:t |
			(self endsWith: t) ifTrue: [^self , 's'].
			^self allButLast , 'ies']].
	#('zz' 'ch' 'sh') do: [:t | (self endsWith: t) ifTrue: [^self , 'es']].
	last = $s ifTrue: [
		self = 'its' ifTrue: [^'their'].
		#('bs' 'cs' 'ds' 'ks' 'ls' 'ms' 'rs' 'ts' 'ws')
			do: [:t | (self endsWith: t) ifTrue: [^self]].
		#('sis' 'xis')
			do: [:t | (self endsWith: t) ifTrue: [^(self allButLast: 2) , 'es']]].
	last = $z ifTrue: [^self , 'zes'].
	(last = $x or: [last = $s]) ifTrue: [^self , 'es'].
	(self endsWith: 'man') ifTrue: [^(self allButLast: 2) , 'en'].
	last = $f ifTrue: [^self allButLast , 'ves'].
	(self endsWith: 'fe') ifTrue: [^(self allButLast: 2) , 'ves'].
	^self , 's'! !

!String methodsFor: 'grammar' stamp: 'LC 4/25/2020 10:26:19'!
pluralize: aBoolean
	^aBoolean ifTrue: [self asPlural] ifFalse: [self]! !

!String methodsFor: 'grammar' stamp: 'LC 4/25/2020 10:45:49'!
withArticle
	^self article , ' ' , self! !


!String methodsFor: '*squeakCompatibility'!
! !

!String methodsFor: '*squeakCompatibility'!
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'String class' category: #'Kernel-Text'!
String class
	instanceVariableNames: ''!

!String class methodsFor: 'instance creation' stamp: 'jmv 12/29/2020 13:03:32'!
addUnicodeCodePoint: codePoint to: strm hex: useHexForNCRs
	"Convert the given Unicode codePoint to  the internal encoding: ISO Latin 9 (ISO 8859-15)"
	"For unicode chars not in ISO Latin 9 (ISO 8859-15), embed Decimal NCRs or Hexadecimal NCRs according to useHex.

	See http://en.wikipedia.org/wiki/Numeric_character_reference
	See http://rishida.net/tools/conversion/. Tests prepared there.

	Note: The conversion of NCRs is reversible. See #asUtf8:
	This allows handling the full Unicode in Cuis tools, that can only display the Latin alphabet, by editing the NCRs.
	The conversions can be done when reading / saving files, or when pasting from Clipboard and storing back on it."

	(Character codePoint: codePoint trySimilar: true)
		ifNotNil: [ :char | strm nextPut: char]
		ifNil: [
			useHexForNCRs
				ifTrue: [
					strm nextPutAll: '&#x'.
					codePoint printOn: strm base: 16 length: 4 padded: true.
					strm nextPut: $; ]
				ifFalse: [
					strm nextPutAll: '&#'.
					codePoint printOn: strm base: 10.
					strm nextPut: $; ]]! !

!String class methodsFor: 'instance creation' stamp: 'jmv 8/28/2013 10:27'!
crString
	"Answer a string containing a single carriage return character."

	^ self with: Character cr! !

!String class methodsFor: 'instance creation' stamp: 'jmv 8/28/2013 10:27'!
crlfString
	"Answer a string containing a carriage return and a linefeed."

	^ self with: Character cr with: Character lf
! !

!String class methodsFor: 'instance creation' stamp: 'di 1/14/98 10:26'!
fromString: aString
	"Answer an instance of me that is a copy of the argument, aString."

	^ aString copyFrom: 1 to: aString size! !

!String class methodsFor: 'instance creation' stamp: 'jmv 2/14/2013 14:29'!
fromUtf8: aByteArray
	"Convert the given bytes from UTF-8 to  the internal encoding: ISO Latin 9 (ISO 8859-15).
	See #asUtf8 "
	"For any unicode chars not in ISO Latin 9 (ISO 8859-15), embed an NCR.
	See http://en.wikipedia.org/wiki/Numeric_character_reference"

	^self fromUtf8: aByteArray hex: false trimLastNull: false! !

!String class methodsFor: 'instance creation' stamp: 'jmv 8/28/2013 12:09'!
fromUtf8: aByteArray hex: useHexForNCRs trimLastNull: doTrimLastNullChar
	"Convert the given string from UTF-8 to  the internal encoding: ISO Latin 9 (ISO 8859-15)"
	"For unicode chars not in ISO Latin 9 (ISO 8859-15), embed Decimal NCRs or Hexadecimal NCRs according to useHex.

	See http://en.wikipedia.org/wiki/Numeric_character_reference
	See http://rishida.net/tools/conversion/. Tests prepared there.

	Note: The conversion of NCRs is reversible. See #asUtf8:
	This allows handling the full Unicode in Cuis tools, that can only display the Latin alphabet, by editing the NCRs.
	The conversions can be done when reading / saving files, or when pasting from Clipboard and storing back on it."

	^String streamContents: [ :strm | | bytes codePoint |
		bytes := aByteArray readStream.
		[ bytes atEnd ] whileFalse: [
			codePoint := (Character nextUnicodeCodePointFromUtf8: bytes).
			codePoint ifNotNil: [
				"Add just one char if possible, or the apropriate sequence for the NCR"
				self addUnicodeCodePoint: codePoint to: strm hex: useHexForNCRs ]].
			(doTrimLastNullChar and: [ codePoint = 0 ]) ifTrue: [
				strm position: strm position - 1 ]]! !

!String class methodsFor: 'instance creation' stamp: 'jmv 8/28/2013 10:28'!
lfString
	"Answer a string containing a single Lf character."

	^ self with: Character lf! !

!String class methodsFor: 'instance creation' stamp: 'jmv 3/14/2012 08:33'!
newLineString
	"Answer a string containing a single newLine (i.e. Lf) character."

	^ self with: Character newLineCharacter! !

!String class methodsFor: 'instance creation'!
readFrom: inStream
	"Answer an instance of me that is determined by reading the stream,
	inStream. Embedded double quotes become the quote Character."

	| outStream char done |
	outStream := WriteStream on: (String new: 16).
	"go to first quote"
	inStream skipTo: $'.
	done := false.
	[done or: [inStream atEnd]]
		whileFalse:
			[char := inStream next.
			char = $'
				ifTrue:
					[char := inStream next.
					char = $'
						ifTrue: [outStream nextPut: char]
						ifFalse: [done := true]]
				ifFalse: [outStream nextPut: char]].
	^outStream contents! !

!String class methodsFor: 'instance creation' stamp: 'sw 6/15/1999 22:59'!
tab
	"Answer a string containing a single tab character."

	^ self with: Character tab
! !

!String class methodsFor: 'instance creation' stamp: 'jmv 3/25/2021 16:33:56'!
utf32FromUtf8: aByteArray
	"Convert the given string from UTF-8 to UTF-32"

	^WordArray streamContents: [ :strm | | bytes codePoint |
		bytes := aByteArray readStream.
		[ bytes atEnd ] whileFalse: [
			codePoint := (Character nextUnicodeCodePointFromUtf8: bytes).
			codePoint ifNotNil: [
				strm nextPut: codePoint ]]]! !

!String class methodsFor: 'instance creation' stamp: 'jmv 3/25/2021 16:33:31'!
utf8FromUtf32: aWordArray
	"Convert the given string from UTF-8 to UTF-32"

	^ByteArray streamContents: [ :strm |
		aWordArray do: [ :codePoint |
			Character
				evaluate: [ :byte | strm nextPut: byte ]
				withUtf8BytesOfUnicodeCodePoint: codePoint ]]! !


!String class methodsFor: 'initialization' stamp: 'len 5/13/2019 13:50:16'!
initialize
	"
	String initialize
	"

	| order newOrder lowercase |
	"Case insensitive compare sorts null, space, digits, letters, all the rest..."
	newOrder := Array new: 256.
	order := -1.
	newOrder at: 0+1 put:  (order := order+1).
	32 to: 64 do: [ :c |
		newOrder at: c + 1 put: (order := order+1)].
	#(92 94 124 126 183 215 247) do: [ :c | "\^|~·÷×"
		newOrder at: c + 1 put: (order := order+1)].
	16r90 to: 16r9F do: [:c| "special math operators"
		newOrder at: c + 1 put: (order := order+1)].
	Character uppercaseLowercaseAndUnaccentedLetters do: [ :upperAndLowercase |
		order := order+1.
		newOrder at: upperAndLowercase first numericValue + 1 put: order.
		upperAndLowercase size > 1 ifTrue: [
			newOrder at: upperAndLowercase second numericValue + 1 put: order ]].
	1 to: newOrder size do: [ :i |
		(newOrder at: i) ifNil: [
			newOrder at: i put: (order := order+1)]].
	CaseInsensitiveOrder := newOrder asByteArray.

	"Case sensitive compare sorts null, space, digits, letters, all the rest..."
	newOrder := Array new: 256.
	order := -1.
	newOrder at: 0+1 put:  (order := order+1).
	32 to: 64 do: [ :c |
		newOrder at: c + 1 put: (order := order+1)].
	#(92 94 124 126 183 215 247) do: [ :c | "\^|~·÷×"
		newOrder at: c + 1 put: (order := order+1)].
	16r90 to: 16r9F do: [:c| "special math operators"
		newOrder at: c + 1 put: (order := order+1)].
	Character uppercaseLowercaseAndUnaccentedLetters do: [ :upperAndLowercase |
		upperAndLowercase size > 1 ifTrue: [
			newOrder at: upperAndLowercase first numericValue + 1 put: (order := order+1) ]].
	Character uppercaseLowercaseAndUnaccentedLetters do: [ :upperAndLowercase |
		lowercase := upperAndLowercase size = 1
			ifTrue: [ upperAndLowercase first ]
			ifFalse: [ upperAndLowercase second ].
		newOrder at: lowercase numericValue + 1 put: (order := order+1) ].
	1 to: newOrder size do: [ :i |
		(newOrder at: i) ifNil: [
			newOrder at: i put: (order := order+1)]].
	order = 255 ifFalse: [self error: 'order problem'].
	CaseSensitiveOrder := newOrder asByteArray.

	"a table for translating to lower case"
	LowercasingTable := String withAll: (Character characterTable collect: [:c | c asLowercase]).

	"a table for translating to upper case"
	UppercasingTable := String withAll: (Character characterTable collect: [:c | c asUppercase]).

	"a table for testing tokenish (for fast numArgs)"
	Tokenish := String withAll: (Character characterTable collect:
									[:c | c tokenish ifTrue: [c] ifFalse: [$~]]).

	"CR and LF--characters that terminate a line"
	CSLineEnders := CharacterSet new.
	CSLineEnders add: Character cr.
	CSLineEnders add: Character lf.

 	"separators and non-separators"
	CSSeparators := CharacterSet separators.
	CSNonSeparators := CSSeparators complement! !


!String class methodsFor: 'primitives' stamp: 'jmv 9/5/2016 17:15:52'!
findFirstInString: aString  inSet: inclusionMap  startingAt: start
	| i stringSize |
	<primitive: 'primitiveFindFirstInString' module: 'MiscPrimitivePlugin'>
	self var: #aString declareC: 'unsigned char *aString'.
	self var: #inclusionMap  declareC: 'char *inclusionMap'.

	inclusionMap size ~= 256 ifTrue: [ ^0 ].

	i := start.
	stringSize := aString size.
	[ i <= stringSize and: [ (inclusionMap at: (aString at: i) numericValue+1) = 0 ] ] whileTrue: [
		i := i + 1 ].

	i > stringSize ifTrue: [ ^0 ].
	^i! !

!String class methodsFor: 'primitives' stamp: 'jmv 4/18/2018 17:21:32'!
indexOfByte: anInteger inString: aString startingAt: start

	| stringSize |
	<primitive: 'primitiveIndexOfAsciiInString' module: 'MiscPrimitivePlugin'>

	self var: #aCharacter declareC: 'int anInteger'.
	self var: #aString declareC: 'unsigned char *aString'.

	start > 0 ifFalse: [ ^ 0 ].
	stringSize := aString size.
	start to: stringSize do: [:pos |
		(aString at: pos) asciiValue = anInteger ifTrue: [^ pos]].
	^ 0
! !

!String class methodsFor: 'primitives' stamp: 'jmv 9/5/2016 17:16:54'!
stringHash: aString initialHash: speciesHash

	| stringSize hash low |
	<primitive: 'primitiveStringHash' module: 'MiscPrimitivePlugin'>

	self var: #aHash declareC: 'int speciesHash'.
	self var: #aString declareC: 'unsigned char *aString'.

	stringSize := aString size.
	hash := speciesHash bitAnd: 16rFFFFFFF.
	1 to: stringSize do: [:pos |
		hash := hash + (aString at: pos) numericValue.
		"Begin hashMultiply"
		low := hash bitAnd: 16383.
		hash := (16r260D * low + ((16r260D * (hash bitShift: -14) + (16r0065 * low) bitAnd: 16383) * 16384)) bitAnd: 16r0FFFFFFF.
	].
	^ hash! !

!String class methodsFor: 'primitives' stamp: 'jmv 9/5/2016 17:16:57'!
translate: aString from: start  to: stop  table: table
	"translate the characters in the string by the given table, in place"
	<primitive: 'primitiveTranslateStringWithTable' module: 'MiscPrimitivePlugin'>
	self var: #table  declareC: 'unsigned char *table'.
	self var: #aString  declareC: 'unsigned char *aString'.

	start to: stop do: [ :i |
		aString at: i put: (table at: (aString at: i) numericValue+1) ]! !


!String class methodsFor: 'character collation' stamp: 'jmv 9/5/2016 17:15:31'!
does: aCharacter caseInsensitiveCollateBefore: otherCharacter
	"
	String does: $a caseInsensitiveCollateBefore: $b
	String does: $a caseInsensitiveCollateBefore: $B
	String does: $A caseInsensitiveCollateBefore: $b
	"
	^ (CaseInsensitiveOrder at: aCharacter numericValue + 1) < (CaseInsensitiveOrder at: otherCharacter numericValue + 1)! !

!String class methodsFor: 'character collation' stamp: 'jmv 9/5/2016 17:15:39'!
does: aCharacter collateAfter: otherCharacter
	^ (CaseSensitiveOrder at: aCharacter numericValue + 1) > (CaseSensitiveOrder at: otherCharacter numericValue + 1)! !

!String class methodsFor: 'character collation' stamp: 'jmv 9/5/2016 17:15:44'!
does: aCharacter collateBefore: otherCharacter
	^ (CaseSensitiveOrder at: aCharacter numericValue + 1) < (CaseSensitiveOrder at: otherCharacter numericValue + 1)! !


!String class methodsFor: 'fileman-constants' stamp: 'jmv 6/6/2015 23:54'!
pathSeparators
	^'\:/'! !


!String class methodsFor: '*squeakCompatibility'!
! !

!String class methodsFor: '*squeakCompatibility'!
! !

!String class methodsFor: '*squeakCompatibility'!
! !


String initialize!
