Object subclass: AbstractFormatter [
    | indentSize rightMargin |

    AbstractFormatter class [
        new [
            ^(self basicNew)
                initialize;
                indentSize: 4;
                rightMargin: 120.
        ]
    ]
]
AbstractFormatter classInit: [ :cls |
    cls createAllAccessors.
].
AbstractFormatter extend [
    formattedString [
        self subclassResponsibility.
    ]
    displayNl [
        self formattedString displayNl.
    ]
]




AbstractFormatter subclass: ClassSectionFormatter [
    | wrappedClass showStats showComment showAncestors showVars |

    ClassSectionFormatter class [
        new [
            ^(super new)
                showStats: false;
                showComment: false;
                showAncestors: false;
                showVars: false.
        ]
        on: cls [
            ^self new wrappedClass: cls.
        ]

        simpleOn: cls [
            ^(self on: cls)
                showAncestors: false;
                yourself.
        ]

        oneLineOn: cls [
            ^(self on: cls)
                showAncestors: true;
                yourself.
        ]

        fullOn: cls [
            ^(self on: cls)
                showAncestors: true;
                showStats: true;
                showVars: true;
                showComment: true;
                yourself.
        ]
    ]


    joiner [
        ^' <= ' inColor: #cyan.
    ]
    separator [
        ^('-' repeat: (self rightMargin - self indentSize))
            indentedBy: self indentSize.
    ]


    formattedString [
        <category: 'public'>
        | stream |
        stream := WriteStream on: ''.
        stream nextPutAll: self formatHeadLine.
        showStats ifTrue: [
            stream nl; nextPutAll: self formatStats.
        ].
        showVars ifTrue: [
            stream nl; nextPutAll: self formatVars.
        ].
        showComment ifTrue: [
            stream nl; nextPutAll: self formatComment.
            stream nl; nextPutAll: self separator.
        ].
        ^stream contents
    ]



    formatHeadLine [
        | headLine |
        headLine := self formatClassName.
        (showAncestors
             & (wrappedClass ~= Object)
             & (wrappedClass ~= Object class))
            ifTrue: [
                headLine := headLine , self joiner , self formatSuperclasses.
            ].
        ^headLine.
    ]

    formatClassName [
        | color |
        color := (wrappedClass isKindOf: Metaclass)
            ifTrue: [ #yellow ]
            ifFalse: [ #green ].
        ^wrappedClass asString inColor: color
    ]


    formatSuperclasses [
         ^self allSuperclassesNames join: self joiner.
    ]


    formatStats [
        | line |
        line := '(%1: %2 %3: %4)'.
        line := line % {
            'category' inColor: #yellow.
            wrappedClass category.
            'files' inColor: #yellow.
            self formatDefinitions join: ', '.
        }.
        ^line indentedBy: self indentSize.
    ]

    formatVars [
        | labelLocal labelInherited localVars inheritedVars res |
        labelLocal := 'attrs' inColor: #yellow.
        labelInherited := 'inherits' inColor: #yellow.
        localVars := wrappedClass instVarNames.
        inheritedVars := wrappedClass allInstVarNames asSet - localVars asSet.
        localVars := (localVars size > 0)
             ifTrue: [ localVars sorted join: ', ' ]
             ifFalse: [ '<no attributes>' ].
        (wrappedClass isKindOf: Metaclass) ifTrue: [
            inheritedVars := inheritedVars - Class allInstVarNames asSet.
        ].
        inheritedVars := (inheritedVars size > 0)
             ifTrue: [ inheritedVars sorted join: ', ' ]
             ifFalse: [ '<no attributes>' ].
        res := '(%1: %2 %3: %4)' % {
            labelLocal.
            localVars.
            labelInherited.
            inheritedVars.
        }.
        ^res indentedBy: self indentSize.
    ]

    formatDefinitions [
        | files meths |
        files := Set new.
        meths := wrappedClass methodDictionary ifNil: [Dictionary new].
        " NOTE: I get 'nil' as last value if I do: meths values do: []... "
        meths keysAndValuesDo: [ :s :m | files add: m methodSourceFile].
        ^files asOrderedCollection.
    ]


    formatComment [
        | comment |
        comment := wrappedClass comment ifNil: ['<no class comment yet>'].
        " TODO re-wrap at 74 "
        ^comment indentedBy: (self indentSize * 2).
    ]



    printString [
        <category: 'printing'>
        ^'%1(wrappedClass: %2 showComment: %3 showAncestors: %4)' % {
            self class. wrappedClass. showComment. showAncestors.
        }
    ]


    allSuperclasses [
        <category: 'private'>
        | ancestors |
        ancestors := wrappedClass allSuperclasses.
        (wrappedClass isKindOf: Metaclass) ifTrue: [
            | objPos |
            objPos := ancestors indexOf: Object class.
            ancestors := ancestors copyFrom: 1 to: objPos.
        ].
        ^ancestors
    ]

    allSuperclassesNames [
        <category: 'private'>
        ^self allSuperclasses collect: #asString.
    ]
]

ClassSectionFormatter createVarsAccessors: #('wrappedClass').
ClassSectionFormatter
    createVarsAccessors: #('showStats' 'showComment' 'showAncestors' 'showVars')
    default: false.




AbstractFormatter subclass: MethodFormatter [
    | wrappedClass selector showCategory showSource showClasses showComment |

    "
     (MethodFormatter oneLineOn: Set withSelector: #findIndex:)
         formattedString displayNl.

     (MethodFormatter fullOn: Set withSelector: #findIndex:)
         formattedString displayNl.
     "

    categoryTranslations := Dictionary from: {
        'still unclassified' -> 'unclassified'.
        'testing functionality' -> 'testing'.
    }.

    MethodFormatter class [
        new [
            ^(super new)
                showCategory: false;
                showSource: false;
                showClasses: false;
                showComment: false.
        ]

        on: cls withSelector: sel [
            ^(self new)
                wrappedClass: cls;
                selector: sel.
        ]

        simpleOn: cls withSelector: sel [
            ^(self on: cls withSelector: sel)
                showCategory: true.
        ]

        twoLinesOn: cls withSelector: sel [
            ^(self oneLineOn: cls withSelector: sel)
                showComment: true.
        ]

        oneLineOn: cls withSelector: sel [
            ^(self on: cls withSelector: sel)
                showClasses: true;
                showCategory: true;
                showComment: false.
        ]

        fullOn: cls withSelector: sel [
            ^(self on: cls withSelector: sel)
                showComment: false;
                showCategory: false;
                showClasses: true;
                showSource: true.
        ]
    ]
]
MethodFormatter classInit: [ :cls |
    cls createVarsAccessors: #('wrappedClass' 'selector').
    cls createVarsAccessors: #('showCategory' 'showSource' 'showClasses'
                               'showComment')
        default: false.
].
MethodFormatter extend [

    formattedString [
        | stream |
        stream := WriteStream on: ''.
        stream nextPutAll: self formatFirstLine.
        showComment ifTrue: [ | comment |
            (comment := self formatComment) ifNotNil: [
                stream nl; nextPutAll: comment; nl.
            ]
        ].
        showSource ifTrue: [
            stream nl; nextPutAll: (self formatMethodSource); nl.
        ].
        ^stream contents.
    ]

    formatComment [
        | node src loc |
        src := self getMethodSource.
        node := STInST.RBBracketedMethodParser parseMethod: src.
        node comments size > 0 ifFalse: [ ^nil ].
        loc := node comments first.
        src := src copyFrom: loc first to: loc last.
        src := (src trimTrailing: '"' ) trimLeading: '"'.
        src := src lines collect: [ :l |
            l replacingRegex: '^ +' with: ''.
        ].
        src := src join: ' '.
        ^(src wordWrapAt: 60) indentedBy: indentSize * 2.
    ]

    formatFirstLine [
        | stream |
        stream := WriteStream on: ''.
        (showCategory & showSource not) ifTrue: [
            stream nextPutAll: self formatCategory; space.
        ].
        stream nextPutAll: self formatMethodName.
        showClasses ifTrue: [
            | width visibleSize |
            visibleSize := stream contents asStyledString visibleSize.
            width := (self rightMargin - visibleSize - self indentSize).
            stream space; nextPutAll: (self formatClasses alignRight: width).
        ].
        ^stream contents
            indentedBy: self indentSize.
    ]

    formatCategory [
        | category |
        category := self findNearestImplementation methodCategory.
        category := categoryTranslations at: category ifAbsent: [category].
        ^('<',(category shortenTo: 17),'>') alignLeft: 19.
    ]

    formatMethodName [
        | name n2 |
        name := self getMethodSource lines first.
        name := self highlightMethodName: name.
        name := showSource ifTrue: [ name , '[' ] ifFalse: [ name ].
        ^name.
    ]

    highlightMethodName: name [
        <category: 'private'>
        | parts |
        parts := name readStream upTo: $[.
        parts := parts trimTrailing: ' '.
        parts := parts tokenize: ' +'.
        (parts size = 1) ifTrue: [
            ^(parts first , ' ') styledAs: [:s | s yellow].
        ].
        (parts size > 1) ifTrue: [
            | str out |
            str := parts readStream.
            out := WriteStream on: ''.
            [ str atEnd not ] whileTrue: [
                out
                    str: (str next styledAs: [:s | s yellow]);
                    space;
                    str: (str next styledAs: [:s | s i]);
                    space.
            ].
            ^out contents.
        ].
    ]

    formatClasses [
        <category: 'private'>
        | implementors |
        implementors := self findImplementors collect: #asString.
        ^'[in: %1]' % {implementors join: ', '}.
    ]


    formatMethodSource [
        <category: 'private'>
        | source dedent code |
        source := self getMethodSource.
        " TODO: deal with single-line methods in a better way "
        source := (source lines size = 1) ifTrue: [source lines] ifFalse: [source lines drop: 1].
        dedent := ' ' repeat: ((source first indexOfRegex: '^ +[^ ]') size - 4).
        code := (source asOrderedCollection dropRight: 1) collect: [ :line |
            line trimLeading: dedent
        ].
        code := ExternalSourceCodeHighlighter on: (code join: String nl).
        code := code formattedString.
        code := code , String nl ,  (source last replacingRegex: '^ +' with: '').
        ^code indentedBy: self indentSize.
    ]


    findImplementors [
        <category: 'private'>
        ^wrappedClass withAllSuperclasses select: [ :cls |
            cls includesSelector: selector.
        ]
    ]

    findNearestImplementor [
        <category: 'private'>
        ^self findImplementors first.
    ]

    findNearestImplementation [
        <category: 'private'>
        ^(self findNearestImplementor)>>selector.
    ]

    getMethodSource [
        | errorMsg |
        <category: 'private'>
        errorMsg := selector , String nl , '(no source code)'.
        ^[ self findNearestImplementation methodSourceString
            ifNil: [ errorMsg ]
        ]
            on: Error
            do: [ errorMsg ]
    ]
]





AbstractFormatter subclass: MethodsSectionFormatter [
    | wrappedClass methods mode |

    " TODO: parameterize this... "
    " sorter := [ :a :b | "
    "     (a methodCategory , a selector) <= (b methodCategory , b selector) "
    " ]. "
    sorter := [ :a :b | a selector <= b selector ].

    MethodsSectionFormatter class [
        simpleOn: class with: selectors [
            ^(self new)
                mode: #simple;
                wrappedClass: class;
                methods: selectors.
        ]
        fullOn: class with: selectors [
            ^(self new)
                mode: #full;
                wrappedClass: class;
                methods: selectors.
        ]
        withCommentsOn: class with: selectors [
            ^(self new)
                mode: #comments;
                wrappedClass: class;
                methods: selectors.
        ]
    ]
]
MethodsSectionFormatter classInit: [ :cls |
    cls createVarsAccessors: #('wrappedClass' 'methods').
    cls createVarsAccessors: #('mode') default: #simple.
].
MethodsSectionFormatter extend [
    formattedString [
        <category: 'public'>
        | meths |
        methods isEmpty ifTrue: [ | hint |
            hint := (wrappedClass isKindOf: Metaclass)
                ifFalse: ['Hint: maybe check on the class side?']
                ifTrue: ['Hint: maybe check on the instance side?'].
            ^('<no methods>' , String nl , '    ' , hint)
                indentedBy: self indentSize.
        ].
        meths := methods collect: [ :method | wrappedClass>>method ].
        meths := meths sorted: sorter.
        meths := meths collect: [ :m | self formatMethod: m ].
        ^(meths join: String nl) , String nl.
    ]

    formatMethod: method [
        <category: 'private'>
        | formatter |
        (mode = #simple) ifTrue: [
            ^(MethodFormatter oneLineOn: method methodClass
                              withSelector: method selector) formattedString.
        ].
        (mode = #full) ifTrue: [
            ^(MethodFormatter fullOn: method methodClass
                              withSelector: method selector) formattedString.
        ].
        (mode = #comments) ifTrue: [
            ^(MethodFormatter twoLinesOn: method methodClass
                              withSelector: method selector) formattedString.
        ]
    ]
]





AbstractFormatter subclass: NamespaceFormatter [
    | ns |

    NamespaceFormatter class [
        on: aNamespace [
            ^(self new) ns: aNamespace.
        ]
    ]
]
NamespaceFormatter classInit: [ :cls |
    cls createAllAccessors.
].
NamespaceFormatter extend [
    formattedString [
        | header |
        header := ' ' , ns name asString , ' '.
        header := header inColor: #cyan.
        header := header justifyIn: rightMargin paddingWith: '-'.
        ^header.
    ]
]





Object subclass: ExternalSourceCodeHighlighter [
    | source cmd |
    ExternalSourceCodeHighlighter class [
        on: code [
            ^(self new)
                initialize;
                source: code.
        ]
    ]
]
ExternalSourceCodeHighlighter classInit: [ :cls |
    cls createAllAccessors.
].
ExternalSourceCodeHighlighter extend [
    initialize [
        cmd := 'pygmentize -O style=rrt -l smalltalk'.
    ]

    formattedString [
        | fd |
        fd := FileDescriptor popen: cmd dir: 'w+'.
        fd nextPutAll: source.
        fd flush.
        fd shutdown.
        ^fd contents.
    ]
]
