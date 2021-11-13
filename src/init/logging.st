Object subclass: Logger [
    Logger class [
        | colorsMap level levels |

        initialize [
            level := 'DEBUG'.
            levels := #('DEBUG' 'INFO' 'WARN' 'ERROR' 'CRITICAL').
            colorsMap := Dictionary new.
            colorsMap
                at: 'DEBUG'    put: #blue;
                at: 'INFO'     put: #green;
                at: 'WARN'     put: #yellow;
                at: 'ERROR'    put: #red;
                at: 'CRITICAL' put: #red.
        ]

        procId [
            ^Processor activeProcess hash asString.
        ]

        log: obj [
            DeprecationWarning signal: 'Use Logger>>#log1: instead'.
            self log: obj at: 'DEBUG'.
        ]
        log1: obj [
            self log: obj at: 'DEBUG'.
        ]
        log2: obj [
            self log: obj at: 'INFO'.
        ]
        log3: obj [
            self log: obj at: 'WARN'.
        ]
        log4: obj [
            self log: obj at: 'ERROR'.
        ]
        log5: obj [
            self log: obj at: 'CRITICAL'.
        ]

        log: obj at: lvl [
            " Don't call directly, will report wrong file/line loc. "
            | loc ctx msg |
            ctx := thisContext parentContext parentContext.
            loc := (ctx currentFileName , ':' , ctx currentLineInFile asString).
            msg := '%1 %2 [%3]: %4' % {
                (lvl inColor: (colorsMap at: lvl)).
                loc.
                self procId.
                obj asString.
            }.
            StdOutTranscript showCr: msg.
        ]
    ]
]

Eval [
    Logger initialize.
]
