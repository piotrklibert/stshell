Object subclass: Z [
    a [
        Namespace current: Kernel.
    ]
    b [
        Kernel whileCurrentDo: [
            ^PackageInfo printNl.
        ]
    ]
    c [
        Namespace current: Smalltalk.
    ]
]
