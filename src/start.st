" Package imports "
" TODO: doesn't work when it's in a namespace "
" PackageLoader loadPackageFromFile: 'vendor/petitparser/package.xml'. "

" File imports "
(Directory vendor / 'petitparser/Extension.st') fileIn.
(Directory vendor / 'petitparser/PetitParser.st') fileIn.


(Directory code / 'utils.st') fileIn.
(Directory code / 'server/output.st') fileIn.
(Directory code / 'server/server.st') fileIn.
(Directory code / 'world/description.st') fileIn.



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
