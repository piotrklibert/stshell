Object subclass: S [
    | styles |
    initialize [
        styles := #('default' 'emacs' 'friendly' 'colorful' 'autumn' 'murphy' 'manni' 'monokai' 'perldoc' 'pastie' 'borland' 'trac' 'native' 'fruity' 'bw' 'vim' 'vs' 'tango' 'rrt' 'xcode' 'igor' 'paraiso-light' 'paraiso-dark' 'lovelace' 'algol' 'algol_nu' 'arduino' 'rainbow_dash' 'abap' 'solarized-dark' 'solarized-light' 'sas' 'stata' 'stata-light' 'stata-dark' 'inkpot').
        styles := #('monokai' 'trac' 'native' 'fruity' 'inkpot' 'rrt').
    ]

    print: src in: style [
        | fd cmd str |
        cmd := 'pygmentize -O style=' , style , ' -l smalltalk'.
        fd := FileDescriptor popen: cmd dir: 'w+'.
        fd nextPutAll: src.
        fd flush.
        fd shutdown.
        (style styledAs: [ :s | s u red ]) display.
        str := fd contents asStyledString.
        ('  %1 / %2 ' % { str size. str visibleSize }) displayNl.
        str displayNl.
    ]

    printInStyles: src [
        styles do: [ :s | self print: src in: s. ].
    ]
]


""

Eval [
    | src |
    src := 'c: cls [
            " Show class methods, comment, and variables if cls is a class,
              or display a list of classes with names matching a pattern if
              it''s a string."
            cls ifNil: [ ^self gotNilError ].
            (cls isKindOf: Behavior)
                ifTrue: [ ^self showClassDetails: cls ].
            (cls isKindOf: String)
                ifTrue: [ ^self showClassesMatching: cls ].
        ]'.
    (SourceCodeHighlighter on: src) formattedString displayNl.
]
