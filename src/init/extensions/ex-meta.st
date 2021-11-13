"
Object
    Behavior
        ClassDescription
            Class
"

Behavior extend [
    allSubinstances [
        | stream |
        stream := WriteStream on: Array new.
        self allSubinstancesDo: [ :inst | stream nextPut: inst ].
        ^stream contents.
    ]

    ignore: anObject [
        "Literally ignores whatever gets passed; useful for commenting out
         bodies of classes"
    ]

    classInit [
        self resetMethodsDictionary.
    ]

    classInit: aBlock [
        self resetMethodsDictionary.
        ^aBlock value: self.
    ]

    resetMethodsDictionary [
        self hasMethods ifTrue: [ self methodDictionary empty ].
    ]

    browse [
        ^I c: self.
    ]

    edit: selector [
        self emacs: selector.
    ]

    emacs: selector [
        "Open Emacs to edit the method with the passed selector, then compile it"
        | method sourceFile sourcePos cmd lineNumber |
        <category: 'editing'>
        [
            method := self>>selector.
        ]
        on: Exception do: [ :err |
            err inspect.
            ^nil
        ].
        sourceFile := method methodSourceFile.
        sourceFile isNil ifTrue: [
            ^self error: 'decompiler can''t edit methods without source'
        ].
        lineNumber := method methodLineNumber.
        cmd := 'emacsclient -c  +%1 %2' % {
            lineNumber printString.
            sourceFile.
        }.
        Smalltalk system: cmd.
        ('Reloading ' , sourceFile , '...') displayNl.
        sourceFile asFile fileIn.
        '...done' displayNl.
    ]
]


CompiledCode extend [
    methodLineNumber [
        | pos file line |
        pos := self methodSourcePos.
        file := self methodSourceFile asFile.
        line := 0.
        pos printNl.
        file contents lines inject: 0 into: [ :acc :str |
            line := line + 1.
            (acc < pos & (acc + str size > pos)) ifTrue: [
                ^line.
            ].
            acc + str size + 1.
        ].
        ^1.
    ]

]

Object subclass: FinalSetterSentinelValue [
    "| |"
    "FinalSetterSentinelValue class []"
]
FinalSetterSentinelValue classInit: [ :cls |
    "cls createAllAccessors."
].
FinalSetterSentinelValue extend [

]


Exception subclass: FinalSetterCalledTwiceError [
    "| |"
    "FinalSetterCalledTwiceError class []"
]
FinalSetterCalledTwiceError classInit: [ :cls |
    "cls createAllAccessors."
].
FinalSetterCalledTwiceError extend [

]



ClassDescription extend [
    createAccessors: varName [
        self createGetMethod: varName asString.
        self createSetMethod: varName asString.
    ]

    createAccessors: varName default: val [
        self createGetMethod: varName asString default: val.
        self createSetMethod: varName asString.
    ]

    createVarsAccessors: varNames [
        varNames do: [ :var | self createAccessors: var asString ]
    ]

    createVarsAccessors: varNames default: val [
        varNames do: [ :var |
            self createAccessors: var asString default: val
        ]
    ]

    createAllAccessors [
        self createVarsAccessors: self instVarNames
    ]

    createAllAccessorsExcluding: varNames [
        self createVarsAccessors: (self instVarNames asSet - varNames asSet)
    ]

    createFinalSetter: var [
        | source varName |
        varName := var asString.
        source := String streamContents: [ :s |
            s
                str: varName; str: ': value ['; nl;
                str: '" One-time setter for '; str: varName; str: '"'; nl;
                str: '('; str: varName; str: ' isKindOf: FinalSetterSentinelValue)'; nl;
                str: '    ifFalse: [ FinalSetterCalledTwiceError signal ].'; nl;
                str: varName; str: ' := value.'; nl;
                str: ']'.
        ].
        self compile: source.
    ]
]


Exception extend [
    Exception class [
        handle: handler in: aBlock [
            ^aBlock on: self do: handler.
        ]
    ]
]
