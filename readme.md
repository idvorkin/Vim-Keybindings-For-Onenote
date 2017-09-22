[![Stories in Ready](https://badge.waffle.io/idvorkin/Vim-Keybindings-For-Onenote.png?label=ready&title=Ready)](https://waffle.io/idvorkin/Vim-Keybindings-For-Onenote?utm_source=badge)
VIM keybindings for OneNote
====

[![Join the chat at https://gitter.im/idvorkin/Vim-Keybindings-For-Onenote](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/idvorkin/Vim-Keybindings-For-Onenote?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
VIM keybindings for OneNote brings the efficiency of VIM to the organizing power of Onenote. 

This project uses [AutoHotKey](http://www.autohotkey.com/). If you don't have autohotkey installed you can still run prebuilt executables. 

You can run the VIM keybinding via autohotkey, or by downloading and running the prebuilt executable.

Run Vim keybindings via prebuilt executable
-----

Download [vim\_onenote.exe](https://github.com/idvorkin/Vim-Keybindings-For-Onenote/raw/master/vim_onenote.exe)



Run Vim keybindings via AutoHotKey script
----

Clone this repo and run the script via AutoHotKey.

```
REM Launch AutoHotKey passing vim_onenote as the script name.
C:\gits\Vim-Keybindings-For-Onenote>\bin_drop\AutoHotkey.exe vim_onenote.ahk
```

Implemented Bindings
-----
Below are some of the key bindings implemented (if this table is stale, feel free to update it)

| Keys | Name|
|:------|:----|
|ESC/jj/ctrl+[| Enter normal mode (makes VIM key bindings active)|
| hjik | (Motion) left down up right|
|C^F/C^B|Page Up/Page Down|
|0/$|(Motion) Start Of Line/End Of Line|
|w|(Motion) Forwards a word|
|e|(Motion) Forward to end of word, before space|
|b|(Motion) Backwards a word|
|i/I| Enter insert mode before cursor/at start of line |
|a/A|Enter insert mode after curser/at end of line|
|o/O|Enter insert mode on line below/above|
|u/C^R|undo/redo|
|dd/D|Erase line|
|yy|Copy line|
|cc/S|Change line|
|d\<motion\>|Erase \<motion\>|
|c\<motion\>|Change \<motion\>|
|y\<motion\>|Copy (yank) \<motion\>|
|r|Replace|
|s|Substitute|
|p/P|Paste after/before caret|
|/|Search|
|?|Reverse search|
|n/N|Continue search forward/backward|
|#/*|Go to next/previous word under caret|
|<number>g|go to line|
|~|invert character|
|<</>>|outdent/indent|
|v|Enter visual (selection) mode|
| zc/zo| Fold Close/Fold Open|

Numbers can be used before a motion to repeat it.

Quirks
-----
There are lots of quirks because AutoHotKey doesn't know the current cursor location, and OneNote behaves differently based on the cursor location. I'll list some of the bigger ones here
* Fold only works in list mode.
