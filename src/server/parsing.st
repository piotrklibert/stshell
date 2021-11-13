"

Parser
Scanner
ParserDriver
Compiler


STInST.RBScanner
    STInST.STFileScanner
        STInST.SqueakFileInScanner

STInST.RBProgramNodeVisitor
    STInST.ParseTreeSearcher
        STInST.ParseTreeRewriter
    STInST.STFakeCompiler
        STInST.STCompiler

STInST.RBParser
    STInST.RBBracketedMethodParser
    STInST.STFileParser
        STInST.STFileInParser
            STInST.GSTFileInParser

STInST.RBParseTreeRule
    STInST.RBReplaceRule
        STInST.RBBlockReplaceRule
        STInST.RBStringReplaceRule
    STInST.RBSearchRule

STInST.STParsingDriver
    STInST.STEvaluationDriver
        STInST.MyDriver
    STInST.STInterpreter
        STInST.STClassLoader

STInST.STParserScanner

"

Namespace current: STInST [

STInST.STEvaluationDriver subclass: MyDriver [
    | a |
]

MyDriver classInit: [ :cls | ].

MyDriver extend [
    initialize [
        a := 0.
    ]
    evaluate: node [
        <category: 'overrides'>
        | method |
        (String nl * 2) displayNl.
        node inspect.
        self parser printNl.
        self parser inspect.
        evalFor class compilerClass printNl.
        String nl displayNl.
        [
            method := evalFor class compilerClass
                compile: node
                asMethodOf: evalFor class
                classified: 'doIt'
                parser: self
                environment: Namespace current.

            ((method respondsTo: #methodSourceString) and: [ method methodSourceString isNonNil ])
                ifTrue: [ method methodSourceString printNl. ]
                ifFalse: [ ' NO CODE' printNl. ].
            " method inspect. "
            [lastResult := evalFor perform: method] valueWithUnwind.
            " (a = 2) "
            "     ifTrue: [lastResult := self] "
            "     ifFalse: [ "
            "         [lastResult := evalFor perform: method] valueWithUnwind. "
            "     ]. "
            " lastResult inspect. "
        ]
        on: Exception do: [ :srr |
            srr inspect.
            srr signalingContext backtrace printNl.
            'asdasdasd' printNl.
        ].
        ^curClass notNil.
    ]

    MyDriver class [
        a: obj [
            | method node |
            Namespace current: Kernel.
            node := STInST.RBBracketedMethodParser parseMethod: 'doIt [ ^[PackageInfo printNl] value ]'.
            " node inspect. "
            method := obj class compilerClass
                compile: node
                asMethodOf: obj class
                classified: nil
                parser: RBParser new
                environment: STInST.
            ^method.

        ]

        argh: obj [
            | src |
            " src := 'Namespace current: Kernel [PackageInfo displayNl]'. "
            " src := 'Namespace current: Kernel [(self player -> PackageInfo) displayNl]'. "
            src := 'Namespace current: Kernel [ Eval [ | b | b := 3. b printNl ] ]'.
            (String nl * 3) displayNl.
            [
                | res |
                res := STInST.GSTFileInParser
                    parseSmalltalk: src
                    with: (MyDriver new evalFor: obj).
                " with: STInST.STEvaluationDriver new. "
                '----' displayNl.
                res printNl.
                '----' displayNl.

            ]
            on: Exception do: [ :err |
                err printNl.
                err inspect.
                nil.
            ].
            (String nl * 3) displayNl.
        ]
    ]
]

RBParser extend [
    errorLine [
	<category: 'error handling'>
	^[
            (scanner stream copyFrom: 1 to: self errorPosition) readStream lines
                contents size.
        ]
        on: Exception do: [ -1 ].
    ]
]

]

" STParsingDriver subclass: AAA [ "
"     evaluate: node [ "
"         node printNl "
"     ] "
"     compile: node [ "
"         node printNl "
"     ] "
" ] "
""
" (GSTFileInParser parseSmalltalk: (File path: 'src/init/extensions/ex-string.st') contents with: AAA new) "
""
" Namespace current: STInST [ "
"     (File path: '/home/cji/priv/mtr/st/vendor/packages/stinst/parser/STCompiler.st') fileIn. "
" ] "

" Namespace current: STInST [ "

" STParsingDriver subclass: AAA [ "
"     evaluate: node [ "
"         'Evaluating: ' print. "
"         node printNl "
"     ] "
"     compile: node [ "
"         'Compiling: ' print. "
"         node class printNl. "
"         node printNl "
"     ] "
" ] "

" (GSTFileInParser parseSmalltalk: 'Object subclass: FUCK [ a [ ^4 ] ]' with: AAA new) "
" ] "
