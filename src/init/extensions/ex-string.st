"
Object
    Iterable
        Collection
            SequenceableCollection
                ArrayedCollection
                    CharacterArray
                        String
                            StyledString
                            Symbol
"

Character extend [
    Character class [
        quote [
            ^$'
        ]
        backquote [
            ^$`.
        ]
    ]
]


CharacterArray extend [
    Ellipsis := '...'.

    shortenTo: n [
        | res |
        (self size <= n) ifTrue: [ ^self ].
        res := self copyFrom: 1 to: (n - Ellipsis size).
        ^res , Ellipsis
    ]
]


String extend [
    String class >> nl [
        ^Character nl asString
    ]

    asLowerCamelCase [
        ^(self take: 1) asLowercase , (self drop: 1).
    ]

    asUpperCamelCase [
        ^(self take: 1) asUppercase , (self drop: 1).
    ]

    trimTrailing: str [
        (self endsWith: str) ifTrue: [
            ^self copyFrom: 1 to: (self size - str size).
        ]
    ]

    trimLeading: str [
        (self startsWith: str) ifTrue: [
            ^self copyFrom: (str size + 1) to: self size.
        ]
    ]

    alignLeft: cols [
        | pad |
        (self size > cols) ifTrue: [^self].
        pad := ' ' repeat: (cols - self size).
        ^self , pad.
    ]

    alignRight: cols [
        | pad |
        (self size > cols) ifTrue: [^self].
        pad := ' ' repeat: (cols - self size).
        ^pad , self.
    ]

    justifyIn: cols [
        ^self justifyIn: cols paddingWith: ' '.
    ]

    justifyIn: cols paddingWith: padding [
        | pad |
        (self visibleSize > cols) ifTrue: [^self].
        pad := self species withAll: padding.
        pad := pad * ((cols - self visibleSize) / 2).
        " TODO: this could be better written "
        ^((self visibleSize rem: 2) = 1)
            ifTrue: [pad,self,pad]
            ifFalse: [pad,self,pad,padding]
    ]

    indentedBy: cols [
        | indentStr res |
        indentStr := ' ' repeat: cols.
        res := WriteStream on: Array new.
        self linesDo: [ :line | res nextPut: (indentStr , line)].
        ^res contents join: String nl.
    ]

    removeIndent [
        | first indent res |
        first := (self lines reject: #isEmpty) first.
        indent := ' ' repeat: ((first indexOfRegex: '^ +[^ ]') size - 1).
        res := self lines collect: [ :line | line trimLeading: indent ].
        ^res join: String nl.
    ]

    normalizeIndentTo: cols [
        ^self removeIndent indentedBy: cols.
    ]

    repeat: aNumber [
        (aNumber <= 0) ifTrue: [ ^'' ].
        ^((1 to: aNumber) collect: [:n | self]) join
    ]
    * aNumber [
        <category: 'alias'>
        ^self repeat: aNumber
    ]

    in: aString [
        ^0 ~= (aString indexOfSubCollection: self)
    ]

    , other [
        " Copy from String.st to allow 'other' being a Character "
        <category: 'basic'>
        | newString mySize aString |
        (other class == String)
            ifTrue: [ aString := other ]
            ifFalse: [ aString := other asString ].
        newString := self copyEmpty: (mySize := self size) + aString size.
        newString
            replaceFrom: 1
            to: mySize
            with: self
            startingAt: 1.
        newString
            replaceFrom: mySize + 1
            to: newString size
            with: aString
            startingAt: 1.
        ^newString
    ]

    removeAll: pattern [
        ^self replaceAll: pattern with: ''.
    ]

    replaceAll: pattern with: replacement [
        ^self replaceAll: pattern with: replacement startingAt: 1.
    ]

    replaceAll: pattern with: replacement startingAt: startingAt [
        | index prefix suffix |
        index := self indexOfSubCollection: pattern startingAt: startingAt.
        (index = 0) ifTrue: [ ^self ].
        prefix := (self copyFrom: 1 to: (index - 1)).
        suffix := (self copyFrom: (index + pattern size) to: self size).
        ^(prefix , replacement , suffix)
            replaceAll: pattern
            with: replacement
            startingAt: (index + replacement size).
    ]

    wordWrapAt: lineLength [
        | res lines |
        lineLength ifNil: [ ^self ].
        res := self readStream splitAt: Character space.
        lines := OrderedCollection new.
        lines add: (WriteStream on: '').
        res do: [ :word || w |
            (lines last contents size + word size < lineLength) ifTrue: [
                w := word.
                (lines last contents size = 0) ifFalse: [
                    w := ' ', w.
                ].
                lines last nextPutAll: w.
            ] ifFalse: [
                lines add: (WriteStream on: '').
                lines last nextPutAll: word.
            ]
        ].
        ^(lines collect: #contents) join: String nl.
    ]
]



Symbol extend [
    value: anObject [
        ^anObject perform: self.
    ]
]
