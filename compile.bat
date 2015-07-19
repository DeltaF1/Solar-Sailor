@echo off
set source="%~1"
if "%~1" == "" (set source=src)
echo removing old versions...
del .\build\game_old.love
echo arhiving current...
ren .\build\game.love game_old.love

echo zipping up file...
winrar a -afzip -ep1 -r .\build\game.zip "%source%\*.*"

echo converting...
ren ".\build\game.zip" game.love
echo All done!