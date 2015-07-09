VIM keybindings for OneNote
====
VIM keybindings for OneNote brings the efficiency of VIM to the organizing power of Onenote. 

This project uses [AutoHotKey](http://www.autohotkey.com/). If you don't have autohotkey installed you can still run prebuilt executables. 

You can run the VIM keybinding via autohotkey, or by downloading and running the prebuilt executable.

Run Vim keybindings via prebuilt executable
-----

Download [vim\_onenote.exe](https://github.com/idvorkin/Vim-Keybindings-For-Onenote/raw/master/vim_onenote.exe)

```
REM Launch the checked in binary
C:\users\Igor\Downloads>vim_onenote.exe
```

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
|ESC | Enter normal mode (makes VIM key bindings active)|
| hjik | Motion Commands|
|C^F/C^B|Page Up/Page Down|
|0/$|Start Of Line/End Of Line|
|i/I| Enter insert mode before cursor/at start of line |
|a/A|Enter insert mode after curser/at end of line|
|o/O|Enter insert mode on line below/above|
|u/C^R|undo/redo|
|dd/dw|Erase line/ Erase Word|
|yy|Copy line|
|p|paste|
|~|invert character|
| zc/zo| Fold Close/Fold Open|

Quirks
-----
There are lots of quirks because AutoHotKey doesn't know the current cursor location, and OneNote behaves differently based on the cursor location. I'll list some of the bigger ones here
* Fold only works in list mode.
