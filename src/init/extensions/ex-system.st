Directory class extend [
    root [
        ^'/home/cji/priv/mtr/st/' asFile.
    ]
    code [
        ^self root / 'src'.
    ]
    vendor [
        ^self root / 'vendor'.
    ]
    init [
        ^self code / 'init'.
    ]
]


SystemDictionary extend [
    environment [
        | str env n |
        n := 0.
        env := Dictionary new.
        [ (str := self environ at: (n := n + 1)) isNil not ]
            whileTrue: [
                | pos |
                pos := str indexOf: $=.
                env at: (str copyFrom: 1 to: (pos - 1))
                    put: (str copyFrom: (pos + 1)).
            ].
        ^env.
    ]
]

Smalltalk at: #System put: Smalltalk.
