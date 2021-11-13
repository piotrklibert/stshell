Object subclass: CommandDispatcher [
    | commands |

    CommandDispatcher class [
        new [
            ^(super new) initialize.
        ]
    ]
]
CommandDispatcher classInit: [ :cls |
    " cls createAllAccessors. "
].
CommandDispatcher extend [
    initialize [
        commands := Dictionary new.
    ]

    register: matcherBlock withAction: actionBlock [
        commands at: matcherBlock put: actionBlock.
    ]

    lookup: line [
        commands keysAndValuesDo: [ :match :action |
            (match value: line) ifTrue: [
                ^action
            ]
        ].
        ^nil.
    ]

    dispatch: line [
        | action |
        action := self lookup: line.
        ^action ifNotNil: [
            action value
        ].
    ]
]
