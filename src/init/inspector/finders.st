Object subclass: MyClassFinder [
    <comment: 'Utility methods for searching the classes in the system.'>

    MyClassFinder class [
        collectClasses: classes matching: matcher  [
            <category: 'convenience'>
            ^self collectClasses: classes matching: matcher withMetas: true.
        ]

        collectClasses: classes matching: matcher withMetas: withMetas [
            | res |
            res := classes.
            withMetas ifTrue: [
                res := (res collect: [:cls | {cls. cls class}]) flatten.
            ].
            res := res collect: [ :cls || methods |
                ((methods := matcher matchingMethodsOf: cls) size > 0)
                    ifTrue: [ cls -> methods ]
                    ifFalse: [ nil ].
            ].
            ^res select: #isNonNil.
        ]

        sortedSubclassesOf: cls [
            ^cls allSubclasses sorted: [:a :b | a asString < b asString].
        ]

        classesMatching: pat [
            ^self classesMatching: pat inNamespace: nil
        ]

        classesMatching: pat inNamespace: ns [
            | classes |
            classes := (self sortedSubclassesOf: Object) select: [ :class |
                (pat asLowercase in: class asString asLowercase)
                    & (class isKindOf: Metaclass) not
            ].
            ns ifNotNil: [
                classes := classes select: [ :class | ns includes: class ]
            ].
            ^classes.
        ]

        getSuperclasses: cls [
            | limiter |
            " ignore Object / Class and up ; TODO: make option for this"
            limiter := (cls isKindOf: Metaclass)
                ifTrue: [ Object class ]
                ifFalse: [ Object ].
            ^cls withAllSuperclasses takeUntil: [:x | x = limiter].
        ]
    ]
]
