Object subclass: WorldObject [
    | noun adjectives description env |
    "WorldObject class []"
]
WorldObject classInit: [ :cls |
    cls createAllAccessors.
].
WorldObject extend [
    initialize [
        env := nil.
        noun := 'thing'.
        adjectives := OrderedCollection with: 'some'.
        description := ObjectDescription new.
        description section: 'A thing that has no recognizable features.'.
    ]

    printString [
        ^(adjectives join: ' ') , ' ' , noun.
    ]
]


WorldObject subclass: Container [
    | inventory |
    "Container class []"
]
Container classInit: [ :cls |
    "cls createAllAccessors."
].
Container extend [
    initialize [
        super initialize.
        inventory := OrderedCollection new.
    ]
]


Container subclass: Room [
    "| |"
    "Room class []"
]
Room classInit: [ :cls |
    "cls createAllAccessors."
].
Room extend [
    "initialize []"
]
