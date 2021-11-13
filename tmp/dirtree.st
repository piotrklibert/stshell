Eval [
    | b out |
    out := WriteStream on: Array new.
    b := [ :dir :lvl || space |
        ((dir name styledAs: [ :s | s b blue ]) indentedBy: lvl * 3) displayNl.
        dir files do: [ :f |
            (f name endsWith: '.st') ifTrue: [
                [
                    f contents linesDo: [ :l |
                        (('subclass:' in: l) and: [l matchRegex: '\w+ subclass: [#\w]+.*']) ifTrue: [out nextPut: l]]
                ]
                on: Error do: [].
            ].
            ((f asString inColor:'green') indentedBy: lvl + 1 * 3) displayNl.
        ].
        (dir directories reject: [ :d | (d asString endsWith: '.')  ])  do: [ :d | b value: d value: lvl + 1].
    ].

    b value: Directory working value: 0.
    out contents do: #printNl.
]
