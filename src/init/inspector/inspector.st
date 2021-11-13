(Directory init / 'inspector/formatters.st') fileIn.
(Directory init / 'inspector/matchers.st') fileIn.
(Directory init / 'inspector/finders.st') fileIn.
(Directory init / 'inspector/helpers.st') fileIn.

" thisContext currentFileName printNl. "

" TODO refactor this "
Object subclass: DeepMatchPrinter [
    | mode cls pat |
]
DeepMatchPrinter classInit: [ :cls |
    cls createAllAccessors.
].
DeepMatchPrinter extend [
    displayClass [
        | supers selectors |
        (ClassSectionFormatter fullOn: cls)
            formattedString displayNl.
        selectors := ((MyClassFinder getSuperclasses: cls) collect: #selectors)
            flatten asSet sorted.
        pat ifNotNil: [
            | matcher |
            matcher := SelectorMatcher withPattern: pat.
            selectors := selectors select: [ :sel | matcher match: sel ].
        ].
        selectors := selectors do: [ :sel | self displaySelector: sel ].
        Character nl asString display.
    ]

    displaySelector: sel [
        (mode = #simple) ifTrue: [
            (MethodFormatter oneLineOn: cls withSelector: sel)
                formattedString displayNl.
        ].
        (mode = #full) ifTrue: [
            (MethodFormatter fullOn: cls withSelector: sel)
                formattedString displayNl.
        ]
    ]
]





" TODO: cleanup, long versions for aliases, help "
Object subclass: MyInspector [
    | config |

    DefaultConfiguration := nil.

    MyInspector class [
        gotNilError [
            | out |
            <category: 'private'>
            ('Got nil as a class, it probably doesn''t exist.',
                 ' Hint: check your spelling.')
                displayNl.
        ]

        displayMatches: classes [
            <category: 'private'>
            (Dictionary from: classes) keysAndValuesDo: [ :class :methods |
                (ClassSectionFormatter oneLineOn: class)
                    formattedString displayNl.
                (MethodsSectionFormatter simpleOn: class with: methods)
                    formattedString displayNl.
            ]
        ]

        printClassesOfNamespace: aNamespace matching: pat [
            <category: 'private'>
            | matchingClasses allClasses |
            matchingClasses :=
                MyClassFinder collectClasses: aNamespace allClassesSorted
                            matching: (MethodMatcher withPattern: pat).
            matchingClasses ifNonEmpty: [
                (NamespaceFormatter on: aNamespace)
                    formattedString displayNl.
                self displayMatches: matchingClasses.
            ]
        ]

        showClassesMatching: pat [
            <category: 'private'>
            (MyClassFinder classesMatching: pat) do: [ :cls |
                (ClassSectionFormatter simpleOn: cls)
                    formattedString displayNl.
            ].
        ]

        showClassDetails: class [
            <category: 'private'>
            (ClassSectionFormatter fullOn: class)
                formattedString displayNl.
            (MethodsSectionFormatter simpleOn: class with: class selectors)
                formattedString displayNl.
        ]


        s: pat [
            " Show all methods that match the given pattern across all classes
              and namespaces. "
            self s: pat ns: nil.
        ]
        s: pat ns: ns [
            " Show methods (and classes) matching the given pattern, but only
              if classes belong to the given namespace. Searches all namespaces
              if ns is nil. "
            ns ifNotNil: [
                ^self printClassesOfNamespace: ns matching: pat.
            ].
            self printClassesOfNamespace: Smalltalk matching: pat.
            Smalltalk allSubspaces do: [ :ns |
                self printClassesOfNamespace: ns matching: pat
            ]
        ]


        f: cls [
            " Show all methods that a class or any of its superclasses define. "
            (DeepMatchPrinter new) mode: #simple; cls: cls;
                displayClass.
        ]

        f: cls s: pat [
            " Show all methods that a class or any of its superclasses define,
              and which selectors match a given pattern. "
            (DeepMatchPrinter new) mode: #simple; cls: cls; pat: pat;
                displayClass.
        ]

        fs: cls [
            " Show all methods and their source code that a class or any of its
              superclasses define. "
            (DeepMatchPrinter new) mode: #full; cls: cls; displayClass.
        ]

        fs: cls s: pat [
            " Show all methods and their source code that a class or any of its
              superclasses define, and which selectors match the given pattern. "
            (DeepMatchPrinter new) mode: #full; cls: cls; pat: pat;
                displayClass.
        ]

        t: pat [
            " Show methods (along with their classes) which source code contains
              the given pattern. "
            | dict |
            dict := (FullTextSearchHelper withPattern: pat)
                matchingClassesWithMethods.
            dict keysAndValuesDo: [ :class :ms |
                (ClassSectionFormatter oneLineOn: class)
                    formattedString displayNl.
                (MethodsSectionFormatter simpleOn: class with: (ms collect: #selector) asSet)
                    formattedString displayNl.
            ]
        ]

        cs: cls [
            " Alias for c: cls s: '' - displays source code of all methods in a
              class. "
            <category: 'alias'>
            self c: cls s: ''.
        ]

        h: cls [
            " Show subclasses of a class in a tree. "
            cls printHierarchy.
        ]

        hf: cls [
            " Show both superclasses and subclasses of a class in a tree. "
            cls printFullHierarchy.
        ]

        c: cls [
            " Show class methods, comment, and variables if cls is a class,
              or display a list of classes with names matching a pattern if
              it's a string."
            cls ifNil: [ ^self gotNilError ].
            (cls isKindOf: Behavior)
                ifTrue: [ ^self showClassDetails: cls ].
            (cls isKindOf: String)
                ifTrue: [ ^self showClassesMatching: cls ].
        ]

        s: pat c: cls [
            " Alias for #c:s: "
            <category: 'alias'>
            self c: cls s: pat
        ]

        c: cls s: pat [
            " Show the source code of methods of a class which selectors contain
              a given pattern. Passing empty string as a pattern will display
              all of the methods of a class. "
            | meths |
            cls ifNil: [ ^self gotNilError ].
            meths := (MethodMatcher withPattern: pat) matchingMethodsOf: cls.
            meths := meths sorted.
            (ClassSectionFormatter oneLineOn: cls)
                formattedString displayNl.
            meths do: [ :m | self m: (cls>>m) ]
        ]

        oc: obj [
            " Show details of a class of a given _object_ along with details of
              the object state. Uses #inspect to do the latter. "
            I c: obj class.
            obj inspect.
        ]

        m: aMethod [
            " Show method details and source code. "
            (MethodsSectionFormatter fullOn: aMethod methodClass
                                     with: {aMethod selector})
                formattedString display.

            " I m: Object>>#asString "
        ]

        hns: ns [
            " Show hierarchy of classes contained in a given namespace. "
            (NamespaceHelper on: ns)
                rootClasses do: [ :c | c printHierarchy ].
        ]

        help [
            " Show all methods of MyInspector and their comments. "
            (ClassSectionFormatter fullOn: self)
                displayNl.
            (MethodsSectionFormatter withCommentsOn: self class
                                     with: self class selectors)
                displayNl.
        ]
        reload [
            " Reload the source of MyInspector from disk. "
            A r: 'inspector'.
        ]
    ]
]
Smalltalk at: #I put: MyInspector.

" I s: 'exec'. "
" I c: Set. "
" I cs: Set. "
" I c: 'Set'. "
" I f: Set. "
" I c: Set s: 'find'. "
" I m: Object>>#asString. "
" I m: Set>>#findIndex:. "
" I m: MyInspector class>>#c:. "
