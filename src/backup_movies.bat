@echo off
setlocal enabledelayedexpansion

rem
rem デジカメから前回以降の動画をコピーする
rem 前回の続きの連番ファイル名とする
rem

rem 設定事項
set CAMERA_MOVIE_DIR=%1
set WIN_MOVIE_DIR=%2
set extension=%3

rem **********************************************************************

rem このバッチが存在するフォルダをカレントに
cd /d %~dp0
rem cls

rem tempフォルダの準備===============================
set time2=%TIME: =0%
set BACKUPDIR=%~dp0temp%DATE:~-10,4%%DATE:~-5,2%%DATE:~-2%%time2:~0,2%%time2:~3,2%%time2:~6,2%
set temp_original_dir=%BACKUPDIR%\original
set temp_rename_dir=%BACKUPDIR%\rename
mkdir %BACKUPDIR%
mkdir %temp_original_dir%
mkdir %temp_rename_dir%

echo temp folder is ...   %BACKUPDIR%

rem windowsフォルダの最新更新日時を取得==================
for /F "tokens=1* delims=" %%a in ('dir /b /O:D /T:w %WIN_MOVIE_DIR%') do (
   set winfname=%%a
)
for /F "usebackq" %%i in (`dir /s /b %WIN_MOVIE_DIR%\%winfname%`) do (
    set winfname_timestanp=%%~ti
)

echo last modified file is ...   %winfname% %winfname_timestanp%


rem windowsフォルダより新しいファイルをカメラより抽出=============
forfiles /P %CAMERA_MOVIE_DIR% /D +"%winfname_timestanp:~0,10%" /C "cmd /c  @echo off & for /F \"usebackq\" %%i in (`dir /s /b @path`) do (if \"%winfname_timestanp%\" LSS \"%%~ti\" (echo @path %%~ti ok　& xcopy @path %temp_original_dir%))"


rem rename======================================
set /a fileno=1%winfname:~,-4%
for /F "tokens=1* delims=" %%a in ('dir /b /O:D /T:w %temp_original_dir%') do (
    set /a fileno+=1
    echo F | xcopy %temp_original_dir%\%%a %temp_rename_dir%\!fileno:~1!.%extension%
)

rem tempフォルダから出力先へコピー========================
xcopy %temp_rename_dir% %WIN_MOVIE_DIR%


pause

rem tempフォルダの削除===============================
rd /s /q %BACKUPDIR%
rem exit