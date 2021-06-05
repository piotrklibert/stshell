
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


Object subclass: CommandHandler [
    | player line dispatcher namespace |

    CommandHandler class [
        on: player [
            " Creates a new subclass of CommandHandler for every player. "
            | clsName hash |
            hash := player hash asString.
            clsName := ('CommandHandler#' , hash) asSymbol.
            ^(self subclass: clsName) new
                player: player;
                initialize.
        ]
    ]
]
CommandHandler classInit: [ :cls |
    cls createAllAccessors.
].
CommandHandler extend [
    initialize [
        dispatcher := CommandDispatcher new.
        dispatcher
            register: [ :s | s = 'q' ]
            withAction: [ player stopMyself ];
            register: [ :s | s = 'die' ]
            withAction: [ player server stop ];
            register: [ :s | s startsWith: 'ls' ]
            withAction: [ self handleLs ];
            register: [ :s | s first = Character quote ]
            withAction: [ self handleSay ].
    ]

    handleSay [
        | others content |
        <category: 'WiP'>
        content := line drop: 1.
        others := player server players reject: [ :p | p = player ].
        others do: [ :p |
            p socket nextPutAllFlush: (player process hash asString , ' mowi: ', content , String nl).
        ].
        player socket nextPutAllFlush: (player process hash asString , ' mowisz: ', content , String nl).
    ]

    getVarNames: cmd [
        | parsed vars |
        vars := OrderedCollection new.
        parsed := STInST.RBParser parseExpression: cmd.
        parsed nodesDo: [ :node |
            (node isKindOf: STInST.RBAssignmentNode)
                ifTrue: [ vars add: node variable name ]
        ].
        ^vars.
    ]

    evaluate: command ifError: aBlock [
        | method source cmd |
        cmd := command.
        (self getVarNames: cmd) do: [ :var |
            (self class allInstVarNames includes: var asSymbol)
                ifFalse: [ self class addInstVarName: var ]
        ].
        source := 'DoIt [ ^[ ' , cmd , ' ] value ]'.
        method := self class compile: source ifError: aBlock.
        ^self perform: method.
        " namespace ifNotNil: [Namespace current: namespace.]. "
        " [] ensure: [Namespace current: Smalltalk.] "
    ]

    handleEval [
        | res compErrHandler input |
        input := DebugMode ifTrue: [ line ] ifFalse: [ line drop: 1 ].
        compErrHandler := [ :file :line :err |
            ('Compilation error: ' , err) displayNl.
            ^nil.
        ].
        [
            ^self evaluate: input ifError: compErrHandler.
        ]
        on: Exception do: [ :err |
            self displayError: err.
            ^nil.
        ].
        ^res.
    ]

    q [
        player stopMyself.
    ]

    displayError: err [
        | out |
        out := WriteStream on: ''.
        out
            nl;
            nextPutAll: ('Error: ' inColor: #red);
            nextPutAll: (err asString inColor: #yellow);
            nextPutAll: ' - ';
            nextPutAll: err messageText;
            nl; nl.
        (err respondsTo: #message) ifTrue: [
            err message examineOn: out.
            out nl.
        ].
        err signalingContext backtraceOn: out.
        StackTraceFormatter display: err.
        out contents displayNl.
    ]

    handleCommand: cmd withOutputTo: aTextCollector [
        ^[
            self primHandleCommand: cmd withOutputTo: aTextCollector
        ]
        on: Exception do: [ :err |
            err inspect.
            ^nil.
        ].
    ]
    primHandleCommand: cmd withOutputTo: aTextCollector [
        line := cmd.
        LocalTranscript use: aTextCollector during: [
            (DebugMode or: [line first = Character backquote]) ifTrue: [
                self handleEval printString displayNl.
                ^self.
            ].
            [
                dispatcher dispatch: line.
            ]
            on: Error do: [ :err |
                self displayError: err.
                ^self.
            ].
            'What?' displayNl.
        ]
    ]
]
