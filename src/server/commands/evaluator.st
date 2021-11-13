Error subclass: MyCompilationError []
Error subclass: MyExecutionError [
    | wrappedError |

    MyExecutionError class >> with: anException [
        ^(self new) wrappedError: anException.
    ]
]
MyExecutionError classInit: [ :cls |
    cls createAccessors: 'wrappedError'.
].
MyExecutionError extend [
    message [
        (wrappedError respondsTo: #message)
            ifTrue: [ ^wrappedError message ]
            ifFalse: [ ^nil ].
    ]
    messageText [ ^wrappedError messageText. ]
]





Object subclass: MyEvalHandler [
    | namespace commandHandler player |

    MyEvalHandler class >> on: aCommandHandler [
        " Creates a new subclass for each created handler. "
        | className subClass |
        className := ('MyEvalHandler' , aCommandHandler playerConnection id).
        subClass := (self subclass: className asSymbol).
        ^(subClass new)
            commandHandler: aCommandHandler;
            namespace: Smalltalk.
    ]
]
MyEvalHandler classInit: [ :cls |
    cls createAllAccessors.
].
MyEvalHandler extend [
    handleEval: cmd [
        ^(MyCommandEvaluator on: self with: cmd in: namespace)
            evaluate.
    ]

    q [
        commandHandler playerConnection stopMyself.
    ]
    die [ A die ]

    in: aNamespace [
        namespace := aNamespace.
    ]
    insm [ namespace := Smalltalk. ]
    inkr [ namespace := Kernel. ]
    inst [ namespace := STInST. ]

    lgbt [
        " lastGeneratedBackTrace "
    ]
]





Object subclass: MyCommandEvaluator [
    | source method target pipePattern namespace targetClass |

    MyCommandEvaluator class [
        on: target with: source in: namespace [
            " Logger log1: 'MyCommandEvaluator with: %1 %2 %3' % {target asString. source. namespace asString.}. "
            ^(self basicNew)
                target: target;
                source: source;
                namespace: namespace;
                initialize.
        ]
    ]

]
MyCommandEvaluator classInit: [ :cls |
    cls createAllAccessors.
].
MyCommandEvaluator extend [

    initialize [
        method := nil.
        targetClass := target class.
        pipePattern := '|>' escapeRegex. " Or maybe `||` ?"
    ]

    evaluate [
        [
            ^self basicEvaluate.
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
        ^nil.
    ]

    basicEvaluate [
        <category: 'private'>
        self rewritePipes.
        self autoDeclareVariables.
        self rewriteExpressionAsMethod.
        self inNamespaceDo: [
            self compileMethod.
            ^self executeMethod.
        ]
    ]

    compileMethod [
        " Logger log1: 'Compiling: ' , source. "
        method := target class
            compile: source
            ifError: [ :file :line :err |
                MyCompilationError signal: (file , ':' , line , ' - ' , err).
            ].
    ]

    executeMethod [
        method ifNil: [ self error: 'compileMethod not called' ].
        [
            ^target perform: method.
        ]
        on: Error do: [ :err |
            (MyExecutionError with: err) signal.
        ]
    ]

    inNamespaceDo: aBlock [
        targetClass environment: self namespace.
        aBlock ensure: [ targetClass environment: Smalltalk ].
    ]

    autoDeclareVariables [
        (self getVarNames: source) do: [ :var |
            (targetClass allInstVarNames includes: var asSymbol)
                ifFalse: [ targetClass addInstVarName: var ]
        ].
    ]

    rewriteExpressionAsMethod [
        source := 'DoIt [ ^[ ' , source , ' ] value ]'.
    ]

    rewritePipes [
        ('|>' in: source)
            ifFalse: [ ^self ].
        source := (source tokenize: pipePattern)
            fold: [ :acc :chunk | '(' ,  acc , ')', chunk ].
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
