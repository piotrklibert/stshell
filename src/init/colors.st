Object subclass: ColorCodes [
    colorCodes := Dictionary from: {
        'black'         -> 0.
        'green'         -> 2.
        'blue'          -> 4.
        'cyan'          -> 6.
        'red'           -> 1.
        'yellow'        -> 3.
        'magenta'       -> 5.
        'white'         -> 7.
        'brightBlack'   -> 8.
        'brightGreen'   -> 10.
        'brightBlue'    -> 12.
        'brightCyan'    -> 14.
        'brightRed'     -> 9.
        'brightYellow'  -> 11.
        'brightMagenta' -> 13.
        'brightWhite'   -> 15.
    }.
]
ColorCodes classInit: [ :cls |
    cls class createGetMethod: 'colorCodes'.
    cls colorCodes keysAndValuesDo: [ :k :v |
        cls compile: k , ' [ ^' , v asString , ' ]' classified: 'access'.
    ].
].





Object subclass: TextStyle [
    | styles end csiBeg csiEnd hasFg hasBg |

    colors := ColorCodes new.
    TextStyle class [
        doesNotUnderstand: aMessage [
            ^aMessage sendTo: self new.
        ]
    ]
]
TextStyle classInit: [ :cls |
    " Generate methods for every known color name, to set the color as
      foreground or background (with 'bg' prefix).
    "
    ColorCodes colorCodes keysAndValuesDo: [ :k :v || src |
        src := k  , ' [' , String nl , 'self foreground: ' , v asString , ' ]'.
        cls compile: src classified: 'foreground'.
        src := 'bg' , k asUpperCamelCase , ' [',String nl,'self background: ' , v asString , ' ]'.
        cls compile: src classified: 'background'.
    ].
].
TextStyle extend [
    initialize [
        <category: 'initialization'>
        super initialize.
        styles := OrderedCollection new.
        csiBeg := Character esc asString , '['.
        csiEnd := 'm'.
        hasFg := false.
        hasBg := false.
    ]

    reset     [
        <category: 'public'>
        styles add: '0'.
    ]
    italic    [
        <category: 'public'>
        styles add: '3'.
    ]
    bold      [
        <category: 'public'>
        styles add: '1'.
    ]
    underline [
        <category: 'public'>
        styles add: '4'.
    ]
    blink     [
        <category: 'public'>
        styles add: '5'.
    ]

    foreground: color [
        <category: 'public'>
        styles add: '38;5;' , (self translateColor: color).
    ]

    background: color [
        <category: 'public'>
        styles add: '48;5;' , (self translateColor: color).
    ]

    with: aString [
        <category: 'public'>
        ^StyledString
            withAll: (self asControlSequence , aString , self resetSequence).
    ]

    fg: color [
        <category: 'alias'>
        self foreground: color.
    ]
    bg: color [
        <category: 'alias'>
        self background: color.
    ]

    fg: color with: aString [
        <category: 'convenience'>
        ^self fg: color; with: aString.
    ]
    fg: color bg: bgColor with: aString [
        <category: 'convenience'>
        ^self fg: color; bg: bgColor; with: aString.
    ]
    bg: color with: aString [
        <category: 'convenience'>
        ^self bg: color; with: aString.
    ]

    r [
        <category: 'alias'>
        self reset.
    ]
    i [
        <category: 'alias'>
        self italic.
    ]
    b [
        <category: 'alias'>
        self bold.
    ]
    u [
        <category: 'alias'>
        self underline.
    ]

    resetSequence [
        <category: 'private'>
        ^csiBeg , '0' , csiEnd.
    ]

    asControlSequence [
        <category: 'private'>
        ^String streamContents: [ :stream |
            styles do: [ :style |
                stream
                    nextPutAll: csiBeg;
                    nextPutAll: style;
                    nextPutAll: csiEnd.
            ]
        ]
    ]

    translateColor: color [
        <category: 'private'>
        ^(color isKindOf: Number)
             ifTrue: [
                 (color between: 0 and: 255) ifFalse: [
                     self error: ('Bad color: ' , color asString).
                 ].
                 color
             ]
             ifFalse: [ colors perform: color asSymbol ].
    ]
]





String extend [
    inColor: color [
        ^TextStyle new fg: color with: self.
    ]
    asStyledString [
        ^StyledString withAll: self.
    ]
    styledAs: aBlock [
        ^self asStyledString styledAs: aBlock.
    ]
    realSize [
        ^self size.
    ]
    visibleSize [
        ^self size.
    ]
]





String subclass: StyledString [
    <shape: #inherit>
]
StyledString classInit.
StyledString extend [
    asStyledString [
        ^self.
    ]

    styledAs: aBlock [
        ^(aBlock value: TextStyle new) with: self.
    ]

    realSize [ ^super size. ]

    visibleSize [ ^self removeStyles size. ]

    removeStyles  [
        | inControl stream |
        inControl := false.
        stream := WriteStream on: ''.
        self do: [ :char |
            (char = Character esc) ifTrue: [ inControl := true ].
            inControl ifFalse: [ stream nextPut: char ].
            (inControl & char = $m) ifTrue: [ inControl := false ].
        ].
        ^stream contents.
    ]
]
