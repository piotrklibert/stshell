Warning subclass: DeprecationWarning [
    defaultAction [
        | loc ctx msg |
        ctx := self signalingContext parentContext parentContext.
        loc := (ctx currentFileName , ':' , ctx currentLineInFile asString).
        msg := 'DeprecationWarning' styledAs: [ :s | s yellow ].
        msg := msg , ' at ' , loc , ' - ' , self messageText.
        msg displayNl.
        self signalingContext backtrace.
        ^super defaultAction.
    ]
]





Object subclass: MyErrorFormatter [
    "| |"
    "MyErrorFormatter class []"
]
MyErrorFormatter classInit: [ :cls |
    "cls createAllAccessors."
].
MyErrorFormatter extend [
    displayError: err [
        | out bt |
        out := WriteStream on: ''.
        out
            nl;
            nextPutAll: ('Error: ' inColor: #red);
            nextPutAll: (err asString inColor: #yellow);
            nextPutAll: ' - ';
            nextPutAll: err messageText;
            nl; nl.
        ((err respondsTo: #message) and: [err message isNonNil]) ifTrue: [
            err message examineOn: out.
            out nl.
        ].
        bt := WriteStream on: ''.
        err signalingContext backtraceOn: bt.
        out nextPutAll: ((bt contents lines take: 10) join: String nl).
        " StackTraceFormatter display: err. "
        out contents displayNl.
    ]

]





Object subclass: StackTraceFormatter [
    "| |"
    StackTraceFormatter class [
        format: err [
            | ctx |
            ctx := err signalingContext.
            [ ctx isNonNil ] whileTrue: [
                " ctx inspect. "
                ctx := ctx parentContext.
            ].
            ^'asdasdsdsad'
        ]
        display: err [
            (self format: err) displayNl.
        ]
    ]
]
StackTraceFormatter classInit: [ :cls |
    "cls createAllAccessors."
].
StackTraceFormatter extend [

]
