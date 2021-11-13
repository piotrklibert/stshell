PackageLoader fileInPackage: 'SUnit'.

TestCase subclass: ProcessVariableTestCase [
    | procvar |

    setUp [
        procvar := ProcessVariable new.
    ]

    testIfAbsent [
        | val |
        val := procvar value.
        self should: [ val isNil ].
        val := procvar valueIfAbsent: [ true ].
        self should: [ val = true ].
    ]
]

(ProcessVariableTestCase selector: #testIfAbsent) run
