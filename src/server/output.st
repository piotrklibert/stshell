DynamicVariable subclass: LocalTranscript [
    LocalTranscript class [
        value [
            ^super valueIfAbsent: [ StdOutTranscript ].
        ]
    ]
]

Object subclass: DynamicTranscript [
    doesNotUnderstand: aMessage [
        aMessage sendTo: LocalTranscript value.
    ]
]
