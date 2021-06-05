PackageLoader fileInPackage: 'Sockets'.

(Directory code / 'server/commands.st') fileIn.
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
        Util log: 'starting server process'.
        socket := Sockets.ServerSocket port: port.
        process := [self run] newProcess.
        process
		    priority: Processor lowIOPriority;
		    name: (self class name , ' Process').
        process resume.
    ]

    stop [
        [
            Util log: 'stopping playerConnections'.
            playerConnections do: #stop.
            process terminate.
            process := nil.
            socket close.
            socket := nil.
            ObjectMemory quit.
        ] fork.
    ]

    run [
        Util log: 'entering main loop'.
        [
            Util log: 'waiting for connection'.
            socket waitForConnection.
            socket isPeerAlive ifFalse: [ ^self stop ].
            Util log: 'accepting connection'.
            self acceptConnection.
        ]
        repeat.
    ]

    acceptConnection [
        self addConnection:
            (PlayerConnection socket: socket accept
                              server: self).
    ]

    addConnection: playerConnection [
        playerConnections add: playerConnection start.
    ]

    removePlayerConnection: player [
        playerConnections remove: player ifAbsent: [].
    ]

    broadcast: msg [
        playerConnections do: [ :p | p socket nextPutAllFlush: (msg, String nl) ].
    ]
].
