" PackageLoader fileInPackages: #( "
"     'Parser' "
"     'Compiler' "
"     'ClassPublisher' "
    " 'Debugger' "
    " 'ObjectDumper' "
    " 'ProfileTools' "
"     'Sockets' "
"     'Announcements' "
"     'Iconv' "
"     'STTools' "
"     'Sport' "
" ). "
" DynamicVariable subclass: LocalTranscript [ "
"     LocalTranscript class [ "
"         value [ "
"             ^super valueIfAbsent: [ StdOutTranscript ]. "
"         ] "
"     ] "
" ] "

" Object subclass: DynamicTranscript [ "
"      DynamicTranscript class [  "
"         doesNotUnderstand: aMessage [ "
"             StdOutTranscript showCr: aMessage asString. "
"             aMessage sendTo: LocalTranscript value. "
"         ] "
"      ]  "
" ] "

" Smalltalk at: #StdOutTranscript put: (Smalltalk at: #Transcript). "
" Smalltalk at: #Transcript put: DynamicTranscript new. "


" String subclass: AAA [ "
"     ~= a [] "
" ] "
" Object subclass: MethodMatcher [ "
"     | e | "

" ] "
" Object subclass: SelectorMatcher [ "
"     | pattern | "
"     SelectorMatcher class >> forPattern: pattern [ "
"         ^(self new) pattern: pattern. "
"     ] "
"     match: selector [ "
"         ^pattern in: selector. "
"     ] "
"     ifMatch: selector do: aBlock [ "
"         ^(self match: selector) ifTrue: aBlock value. "
"     ] "
" ] "
" SelectorMatcher createAccessors: 'pattern'. "

" Object subclass: MethodMatcher [ "
"     | selectorMatcher | "
" ] "
" MethodMatcher "
"     createAccessors: 'selectorMatcher'. "
" MethodMatcher extend [ "
"     MethodMatcher class >> with: pattern [ "
"         ^self new selectorMatcher: SelectorMatcher forPattern: pattern. "
"     ] "

"     matchingMethodsOf: cls [ "
"         cls hasMethods ifFalse: [ ^Array new ]. "
"         ^cls selectors select: [:sel | selectorMatcher match: sel ]. "
"     ] "
" ] "

" Eval [ "
" Namespace current: Kernel [ "
"     PackageInfo printNl. "
" ] "
" String extend [ "
"     a [] "
" ] "

Object subclass: B [
    "| |"
    "B class []"
]
B classInit: [ :cls |
    "cls createAllAccessors."
].
B extend [
    methodA [
        | a b c |
        self methodB
    ]
    methodB [
        " I c: thisContext sender class. "
        (thisContext allInstVarNames)  printNl
    ]
]

B new methodA.
