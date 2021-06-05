### Notes

inotify wait i reload !

```
    Behavior>>#evaluate:to:
    Behavior>>#createGetMethod:
    Behavior>>#createSetMethod:

    Object printHierarchy


[19189]> p := (FileStream popen: '/bin/cat' dir: 'w+')
<Pipe on /bin/cat>
[19189]> p nextPutAll: ('asdasdasd',String nl)
'asdasdasd
'
[19189]> p nextLine
'asdasdasd'
[19189]> die
nil
[19189]> p close
<Pipe on /bin/cat>
[19189]> p close
<Pipe on /bin/cat>
[19189]> p
<Pipe on /bin/cat>
[19189]> p isOpen
false

```

### TODO

- browse senders - RBBracketedParser on methodSourceString
~/portless/versions/smalltalk/gnu-smalltalk-git/packages/stinst/parser/RBParser.st

- track variables in evals - create a class and object for each player
~/portless/versions/smalltalk/gnu-smalltalk-git/packages/visualgst/WorkspaceVariableTracker.st

- FileStream class>>#popen:dir: accepts `'w+'` for read-write communication

- allSelectors - better display, filtering, source code

- inspector help

- DirPackage investigation
    - http://www.educery.com/papers/modules/

- deep into pharo - exceptions and blocks

- smalltalk/x - minidebugger is better there

- smalltalk/x - has --repl !

- diff after loading / after parsing - check if there's a need to remove methods

- remove wildcard accessor generation

- string - visible width / without invisible escape sequences /
String subclass: ColorizedString

- improve fileIn - parsing

    - make #subclass: msg sends clear the methods in the subclass
