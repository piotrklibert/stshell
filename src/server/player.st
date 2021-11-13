Object subclass: PlayerConnection [
    | socket server process transcript commandHandler |

    PlayerConnection class [
        socket: socket server: server [
            ^(self basicNew)
                socket: socket;
                server: server;
                initialize;
                yourself
        ]
    ]
]
PlayerConnection classInit: [ :cls |
    cls createAllAccessors.
].
PlayerConnection extend [
    id [
        ^self hash asString.
    ]

    initialize [
        Logger log1: 'player init'.
        commandHandler := CommandHandler on: self.
        transcript := (TextCollector message: socket->#nextPutAllFlush:).

    ]

    showPrompt [
        socket nextPutAllFlush: ('[%1]> ' bindWith: Logger procId).
    ]

    run [
        [ self handleInteraction ] repeat.
    ]

    handleInteraction [
        socket isPeerAlive ifFalse: [
            Logger log1: 'player: socket closed'.
            ^self stopMyself
        ].
        self showPrompt.
        commandHandler
             handleCommand: socket nextLine
             withOutputTo: transcript.
    ]

    stopMyself [
        "There's some kind of deadlock when terminating current process,
         forking into a separate process fixes it."
        [self stop] fork.
    ]

    stop [
        Logger log1: 'stopping player process'.
        process ifNotNil: [
            process terminate.
            process := nil.
        ].
        socket ifNotNil: [
            socket close.
            socket := nil.
        ].
        server removePlayerConnection: self.
        Logger log2: 'player process stopped'.
    ]

    start [
        Logger log1: 'starting player'.
        process := [self run] newProcess.
        process
            priority: Processor lowIOPriority;
            name: (self class name , ' Process').
        process resume.
    ]
]
