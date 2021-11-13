Object subclass: SelectorMatcher [
    | pattern |

    SelectorMatcher class >> withPattern: pattern [
        ^(self new) pattern: pattern.
    ]
]
SelectorMatcher classInit: [ :cls |
    cls createAccessors: 'pattern'.
].
SelectorMatcher extend [
    match: selector [
        ^pattern asString asLowercase in: selector asString asLowercase.
    ]
    ifMatch: selector do: aBlock [
        ^(self match: selector) ifTrue: aBlock value.
    ]
]



Object subclass: MethodMatcher [
    | selectorMatcher |

    MethodMatcher class >> withPattern: pattern [
        ^(self new)selectorMatcher: (SelectorMatcher withPattern: pattern).
    ]
]
MethodMatcher classInit: [ :cls |
    cls createAccessors: 'selectorMatcher'.
].
MethodMatcher extend [
    matchingMethodsOf: cls [
        cls hasMethods ifFalse: [ ^Array new ].
        ^cls selectors select: [:sel | selectorMatcher match: sel ].
    ]
]
