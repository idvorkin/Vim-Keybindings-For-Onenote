VIM Key bindings for One Note
====

This project brings the power of VIM to the organizing power of Onenote. 

To use this project, you must have [AutoHotKey](http://www.autohotkey.com/) installed. 

To use, the script, launch AutoHotKey passing vim_onenote as the script name.

```
C:\gits\Vim-Keybindings-For-Onenote>\bin_drop\AutoHotkey.exe vim_onenote.ahk
```

Implemented Bindings
-----
Below are some of the key bindings implemented (if this table is stale, feel free to update it)

| Keys | Name|
|:------|:----|
|ESC | Enter command Mode (makes VIM key bindings active)|
| hjik | Motion Commands|
|C^F/C^B|Page Up/Page Down|
|0/$|Start Of Line/End Of Line|
|i/I| Enter insert mode before cursor/at start of line |
|a/A|Enter insert mode after curser/at end of line|
|o/O|Enter insert mode on line below/above|
|dd/dw|Erase line/ Erase Word|
|yy|Copy line|
|p|paste|
|~|invert character|
| zc/zo| Fold Close/Fold Open|

Quirks
-----
There are lots of quirks because AutoHotKey doesn't know the current cursor location, and OneNote behaves differently based on the cursor location. I'll list some of the bigger ones here
* Fold only works in list mode.
