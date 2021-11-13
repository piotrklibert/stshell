" TODO: move this to utils or sth "
(thisContext currentFileName asFile stripFileName / 'dispatcher.st') fileIn.
(thisContext currentFileName asFile stripFileName / 'evaluator.st') fileIn.



Object subclass: CommandHandler [
    | playerConnection lastLine dispatcher evaluator |

    CommandHandler class [
        on: playerConnection [
            ^(self basicNew)
                playerConnection: playerConnection;
                initialize.
        ]
    ]

]
CommandHandler classInit: [ :cls |
    cls createAllAccessors.
].
CommandHandler extend [
    initialize [
        <category: 'initialization'>
        dispatcher := CommandDispatcher new.
        dispatcher
               register: [ :s | s = 'q' ]
               withAction: [
                   playerConnection stopMyself
               ];
               register: [ :s | s = 'die' ]
               withAction: [
                   playerConnection server stop
               ];
               register: [ :s | s startsWith: 'ls' ]
               withAction: [
                   self handleLs
               ];
               register: [ :s | (s startsWith: '!') | (s endsWith: '!') ]
               withAction: [
                   self handleShell
               ].
        evaluator := MyEvalHandler on: self.
        Logger log1: 'command handler init'.
    ]

    handleCommand: cmd withOutputTo: aTextCollector [
        [
            ^self primHandleCommand: cmd withOutputTo: aTextCollector
        ]
        on: SystemExceptions.ProcessBeingTerminated do: [ :err |
            Logger log1: 'Got SystemExceptions.ProcessBeingTerminated'.
            err outer.
            ^nil.
        ]
        on: Exception do: [ :err |
            self displayError: err.
            ^nil.
        ].
    ]

    primHandleCommand: cmd withOutputTo: aTextCollector [
        lastLine := cmd.
        LocalTranscript use: aTextCollector during: [
            | action |
            (action := dispatcher lookup: lastLine) ifNotNil: [
                ^action value.
            ].
            Logger log1: action asString.
            self handleEval printString displayNl.
        ]
    ]

    handleShell [
        | cmd q stream |
        q := Character quote.
        cmd := (lastLine trimLeading: '!') trimTrailing: '!'.
        cmd := 'bash -c ' , q , cmd , q.
        stream := FileDescriptor popen: cmd dir: 'r'.
        [
            (stream contents trimTrailing: String nl) displayNl
        ]
        on: SystemExceptions.EndOfStream do: [ :err |
            '<no output>' displayNl.
        ]
    ]

    handleEval [
        ^evaluator handleEval: lastLine.
    ]

    handleLs [
        Directory working entries do: #printNl.
    ]

    "   [
            (DebugMode or: [lastLine first = Character backquote]) ifTrue: [
                ^self.
            ].
                dispatcher dispatch: lastLine.
            ]
            on: Error do: [ :err |
                self displayError: err.
                ^self.
            ].
            'What?' displayNl.
        ]

handleSay [
        | others content |
        <category: 'WiP'>
        content := lastLine drop: 1.
        others := playerConnection server players reject: [ :p | p = playerConnection ].
        others do: [ :p |
            p socket nextPutAllFlush: (playerConnection process hash asString , ' mowi: ', content , String nl).
        ].
        playerConnection socket nextPutAllFlush: (playerConnection process hash asString , ' mowisz: ', content , String nl).
    ]"


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
]
