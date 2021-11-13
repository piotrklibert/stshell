Stream extend [
    char: aCharacter [
        <category: 'alias'>
        self nextPut: aCharacter.
    ]

    str: aString [
        <category: 'alias'>
        self nextPutAll: aString.
    ]
]
