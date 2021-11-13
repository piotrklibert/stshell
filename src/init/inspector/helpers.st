Object subclass: NamespaceHelper [
    | wrappedNamespace |
    NamespaceHelper class [
        on: aNamespace [
            ^(self new)
                wrappedNamespace: aNamespace.
        ]
    ]

    isRootClass: cls [
        cls superclass ifNil: [ ^true ].
        ^('.' in: (cls superclass nameIn: Smalltalk)) not.
    ]

    rootClasses [
        ^wrappedNamespace allClasses select: [ :cls |
            self isRootClass: cls
        ].
    ]
]
NamespaceHelper createAccessors: 'wrappedNamespace'.





Object subclass: FullTextSearchHelper [
    | pattern |

    MethodsWithSource := Dictionary new.

    FullTextSearchHelper class [
        initialize [
            (CompiledMethod allInstances select: #isNonNil) do: [ :cm |
                MethodsWithSource at: cm methodSourceString put: cm.
                Processor yield.
            ]
        ]

        withPattern: pat [
            ^(self new)
                pattern: pat.
        ]
    ]
]
FullTextSearchHelper classInit: [ :cls |
    cls createAllAccessors.
].
FullTextSearchHelper extend [
    matchingClassesWithMethods [
        | stream classes |
        classes := Dictionary new.
        stream := WriteStream on: Array new.
        MethodsWithSource keysAndValuesDo: [ :text :method || sourceCode pat |
            text ifNotNil: [
                sourceCode := ((text asLowercase lines drop: 1) join: String nl).
                pat := pattern asString asLowercase.
                (pat in: sourceCode) ifTrue: [
                    classes at: method methodClass
                            update: [ :ms | ms add: method; yourself ]
                            ifAbsent: [ OrderedCollection new ]
                ]
            ]
        ].
        ^classes.
    ]
]

Eval [
    [ FullTextSearchHelper initialize ]
        forkAt: Processor userBackgroundPriority.
]
