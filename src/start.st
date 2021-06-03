" Package imports "
" TODO: doesn't work when it's in a namespace "
" PackageLoader loadPackageFromFile: 'vendor/petitparser/package.xml'. "

" File imports "
(Directory image / 'vendor/petitparser/Extension.st') fileIn.
(Directory image / 'vendor/petitparser/PetitParser.st') fileIn.

(Directory image / 'src/utils.st') fileIn.

(Directory image / 'src/server/output.st') fileIn.
(Directory image / 'src/server/server.st') fileIn.

(Directory image / 'src/world/description.st') fileIn.


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

Smalltalk at: #StdOutTranscript put: (Smalltalk at: #Transcript).
Smalltalk at: #Transcript put: DynamicTranscript new.

Smalltalk at: #DebugMode put: true.

Eval [
    | server args |
    Processor activeProcess terminateOnQuit.
    server := Server startOn: 8500.
    args := Smalltalk arguments.
    (args size > 0)
        ifTrue: [
            ((args at: 1) = 'RELEASE')
                ifTrue: [ [ [stdin nextLine] repeat ] on: Error do: [  ] ]
                ifFalse: [ [ [1 wait] repeat ] on: Error do: [  ]. ].
        ]
        ifFalse: [
            [ [1 wait] repeat ] on: Error do: [  ].
        ].
    server stop.
]
