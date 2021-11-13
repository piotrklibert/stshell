PackageLoader fileInPackage: 'Sockets'.

(Directory code / 'server/commands/commands.st') fileIn.
(Directory code / 'server/player.st') fileIn.


Object subclass: Server [
    | socket port process playerConnections |

    Server class [
        startOn: port [
            ^(self new port: port) start.
        ]
    ]
]
Server classInit: [ :cls |
    cls createAllAccessors.
].
Server extend [
    initialize [
        playerConnections := OrderedCollection new.
    ]

    start [
        Logger log2: 'starting server process'.
        socket := Sockets.ServerSocket port: port.
        process := [self run] newProcess.
        process
            priority: Processor lowIOPriority;
            name: (self class name , ' Process').
        process resume.
    ]

    stop [
        [
            Logger log2: 'stopping playerConnections'.
            playerConnections do: #stop.
            process terminate.
            process := nil.
            socket close.
            socket := nil.
            ObjectMemory quit.
        ] fork.
    ]

    run [
        Logger log2: 'entering main loop'.
        [
            Logger log1: 'waiting for connection'.
            socket waitForConnection.
            socket isPeerAlive ifFalse: [ ^self stop ].
            self acceptConnection.
        ]
        repeat.
    ]

    acceptConnection [
        Logger log1: 'accepting connection'.
        self addConnection:
            (PlayerConnection socket: socket accept
                              server: self).
    ]

    addConnection: playerConnection [
        Logger log1: 'Server playerConnection starting'.
        playerConnections add: playerConnection start.
    ]

    removePlayerConnection: player [
        playerConnections remove: player ifAbsent: [].
    ]

    broadcast: msg [
        playerConnections do: [ :p | p socket nextPutAllFlush: (msg, String nl) ].
    ]
].
