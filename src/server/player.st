Object subclass: PlayerConnection [
    | socket server process transcript commandHandler |

    PlayerConnection class [
        socket: socket server: server [
            ^(self new)
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
    initialize [
        commandHandler := CommandHandler on: self.
        transcript := (TextCollector message: socket->#nextPutAllFlush:).
    ]

    showPrompt [
        socket nextPutAllFlush: ('[%1]> ' bindWith: Util procId).
    ]

    run [
        [ self handleInteraction ] repeat.
    ]

    handleInteraction [
        socket isPeerAlive ifFalse: [
            Util log: 'player: socket closed'.
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
        Util log: 'stopping player process'.
        process ifNotNil: [
            process terminate.
            process := nil.
        ].
        socket ifNotNil: [
            socket close.
            socket := nil.
        ].
        server removePlayerConnection: self.
        Util log: 'player process stopped'.
    ]

    start [
        Util log: 'starting player'.
        process := [self run] newProcess.
        process
            priority: Processor lowIOPriority;
            name: (self class name , ' Process').
        process resume.
    ]
]
