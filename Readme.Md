VIM Key bindings for One Note
====

This project brings the power of VIM to the organizing power of Onenote. 

To use this project, you must have [AutoHotKey](http://www.autohotkey.com/) installed. 

To use, the script, launch autohotkey passing vim_onenote as the script name.

```
C:\gits\Vim-Keybindings-For-Onenote>\bin_drop\AutoHotkey.exe vim_onenote.ahk
```

Implemented Bindings
-----
Below are some of the key bindings implemented (if this table is stale, feel free to update it)

| Keys | Name|
|:------|:----|
|ESC | Enter command Mode (makes VIM key bindings active)|
|i| Enter insert mode (makes onenote act normal)|
| hjik | Motion Commands|
| zc/zo| Fold Close/Fold Open|
|C^F/C^B|Page Up/Page Down|
|dd/dw|Erase line/ Erase Word|
|yy|Copy line|
|p|paste|
|o|start typing on ine below|

Quirks
-----
There are lots of quirks because AutoHotKey doesn't know the current cursor location, and OneNote behaves differently based on the cursor location. I'll list some of the bigger ones here
* When in command mode, and you enter a key that isn't a command key, the keys are typed in onenote, but you're still in command mode.
