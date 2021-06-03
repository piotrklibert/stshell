Object subclass: Util [
    Util class [
        procId [
            ^Processor activeProcess hash asString.
        ]
        log: obj [
            StdOutTranscript showCr: ('[' , Util procId , ']: ' , obj asString).
        ]
    ]
]
