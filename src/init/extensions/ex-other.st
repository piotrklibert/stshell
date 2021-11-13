UndefinedObject extend [
    isNonNil [
        ^false
    ]
]


Object subclass: OptionSet [
    | args |

    OptionSet class [
        with: arg1 with: arg2 [
            ^(self new) args: (OrderedCollection with: arg1 with: arg2).
        ]
    ]
]
OptionSet classInit: [ :cls |
    cls createGetMethod: 'args'.
    cls createFinalSetter: 'args'.
].
OptionSet extend [
    initialize [
        args := FinalSetterSentinelValue new.
    ]

    ,, option [
        args add: option.
    ]
    ++ option [
        args add: option.
    ]
    printString [
        ^String streamContents: [ :s |
            s
                str: self class name; str: '(';
                str: ((args collect: #asString) join: ', ');
                str: ')'.
        ]
    ]
]


Object extend [
    ,, option [
        ^OptionSet with: self with: option.
    ]
    ++ option [
        ^OptionSet with: self with: option.
    ]
    isNonNil [
        ^true.
    ]

    asString [
        <category: 'conversion'>
        ^self displayString.
    ]
]



Number extend [
    wait [
        (Delay forSeconds: self) wait.
    ]
]
