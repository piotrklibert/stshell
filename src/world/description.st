Object subclass: ObjectDescription [
    | sections |

    initialize [
        sections := OrderedCollection new.
    ]

    section: text [
        sections add: text.
    ]

    asString [
        (sections collect: [ :s | s wordWrapAt: 80 ]) join: String nl.
    ]
]
