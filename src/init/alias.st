"Aliases"
Object subclass: MyAliases [
    "| |"
    MyUserPath := '/home/cji/.st/' asFile.
    MyProjectPath := '/home/cji/priv/mtr/st/' asFile.
    MyKernelPath := '/home/cji/portless/versions/smalltalk/gst/kernel/' asFile.

    "MyAliases class []"
]
MyAliases classInit: [ :cls |
    "cls createAllAccessors."
].
MyAliases extend [
    printString [
        ^'A'.
    ]
    pkg: packageName [
        ^PackageLoader fileInPackage: packageName.
    ]

    v [
        A pkg: 'VisualGST'.
        A class evaluate: '
            VisualGST.GtkLauncher open.
            VisualGST.TaskQueue uniqueInstance run.
            GTK.Gtk main.
        '.
    ]

    die [
        ObjectMemory quit.
    ]

    b: path [
        (MyUserPath / path) fileIn.
    ]

    f: path [
        ('/home/cji/priv/mtr/st/src' asFile / path) fileIn.
    ]

    r: obj [
        (obj isKindOf: String) ifTrue: [
            self reloadFile: obj.
            ^self.
        ]
    ]

    reloadFile: fname [
        { MyProjectPath/'src'. MyProjectPath/'vendor'. } do: [ :dir |
            self reloadFile: fname
                 inDirectory: dir
                 ifFound: [ :fname | ^fname ].
        ]
    ]

    reloadFile: fname inDirectory: dir ifFound: aBlock [
        | entries |
        entries := dir reject: [ :e | e asString endsWith: '.' ].
        (entries select: #isFile) do: [ :f |
            (f stripPath startsWith: fname)
                ifTrue: [
                    ('Reloading "' , f name , '"...') displayNl.
                    f fileIn.
                    '...done.' displayNl.
                    ^aBlock ifNil: [ true ] ifNotNil: [ ^aBlock value: f ].
                ].
        ].
        (entries select: #isDirectory) do: [ :d |
            (self reloadFile: fname inDirectory: d ifFound: aBlock)
                ifTrue: [ ^true ].
        ].
        ^false.
    ]
]

Smalltalk at: #A put: MyAliases new.
