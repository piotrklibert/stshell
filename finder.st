" Package imports "
" PackageLoader fileInPackages: #( "
    " 'DebugTools' "
    " 'Sockets' "
    " 'Cairo' "
    " 'NetClients' "
    " 'Iconv' "
" ). "

" FileStream fileIn: '/home/cji/portless/versions/smalltalk/petitparser/Extension.st'. "
" FileStream fileIn: '/home/cji/portless/versions/smalltalk/petitparser/PetitParser.st'. "

" File imports "
" FileStream fileIn: '/home/cji/portless/versions/smalltalk/petitparser/Extension.st'. "
" FileStream fileIn: '/home/cji/portless/versions/smalltalk/petitparser/PetitParser.st'. "

" Behavior>>#evaluate:to: "
" Object printHierarchy "

" | o arg | "
" arg := Smalltalk arguments at: 1 ifAbsent: [ "
"     ObjectMemory quit "
" ]. "
" Ins sel: arg. "
Eval [
    PackageLoader loadPackageFromFile: '/home/cji/priv/mtr/st/vendor/stinst/parser/package.xml'.
]

| r |
r := 'method1: a2d <Type> arg2: a3d <asd> [
<category: ''asd''>

]'.
r := STInST.RBBracketedMethodParser parseMethod: r.
t := r tags first.
(r source copyFrom: t first to: t last) printNl.
r inspect.
