
AbstractNamespace extend [
    allClasses [
        | classes |
        classes := WriteStream on: Array new.
        self allClassesDo: [ :cls | classes nextPut: cls].
        ^classes contents.
    ]

    allClassesSorted [
        ^self allClasses sorted: [ :a :b | a asString < b asString].
    ]

    asString [
        ^self name asString.
    ]
]
