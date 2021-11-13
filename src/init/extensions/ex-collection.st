Collection extend [
    ifNonEmpty: aBlock [
        self isEmpty ifFalse: [ ^aBlock value ]
    ]

    ifEmpty: aBlock [
        self isEmpty ifTrue: [ ^aBlock value ]
    ]

    isNonEmpty [
        ^self isEmpty not
    ]

    flatten [
        | stream |
        stream := WriteStream on: Array new.
        self do: [ :each |
            ((each isKindOf: Collection) and: [ (each isKindOf: String) not ])
                ifTrue: [stream nextPutAll: each flatten]
                ifFalse: [stream nextPut: each]
        ].
        ^self species withAll: stream contents
    ]
    splitAt: anObject [
        ^self readStream splitAt: anObject.
    ]
]


SequenceableCollection extend [
    takeWhile: aBlock [
        | stream res |
        res := WriteStream on: {}.
        stream := self readStream.
        [ aBlock value: stream peek ]
            whileTrue: [ res nextPut: stream next ].
        ^self species withAll: res contents.
    ]
    takeUntil: aBlock [
        ^self takeWhile: [ :x | (aBlock value: x) not ].
    ]
    take: n [
        ^self copyFrom: 1 to: n.
    ]

    drop: n [
        ^self copyFrom: (n + 1) to: self size.
    ]

    dropRight: n [
        ^self copyFrom: 1 to: (self size - n).
    ]
    rest [
        ^self drop: 1.
    ]
]

Dictionary extend [
    at: key update: update ifAbsent: default [
        ^self at: key put: (update value: (self at: key ifAbsent: default))
    ]
]
