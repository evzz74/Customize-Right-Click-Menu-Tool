@echo off
setlocal EnableDelayedExpansion
title 通用右键菜单添加工具

:: ==============================
:: 自动获取管理员权限
:: ==============================
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo 请求管理员权限...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"

:: ==============================
:: 用户输入部分
:: ==============================
cls
echo ==========================================
echo      通用右键菜单添加工具 (任意软件)
echo ==========================================
echo.

:AskName
set "MenuName="
echo 请输入要在右键菜单中显示的名称 (例如: 用 Notepad++ 打开):
set /p "MenuName=名称: "
if "!MenuName!"=="" goto AskName

echo.
:AskPath
set "AppPath="
echo 请输入(或拖入)目标软件的 .exe 完整路径:
set /p "AppPath=路径: "
if "!AppPath!"=="" goto AskPath

:: 去除路径可能存在的引号
set "AppPath=!AppPath:"=!"

:: 检查路径是否有效
if not exist "!AppPath!" (
    echo.
    echo [错误] 找不到文件: "!AppPath!"
    echo 请重新输入。
    echo.
    goto AskPath
)

echo.
echo ------------------------------------------
echo 即将添加:
echo 名称: [!MenuName!]
echo 路径: [!AppPath!]
echo ------------------------------------------
pause

:: ==============================
:: 注册表操作
:: ==============================
echo.
echo 正在写入注册表...

:: 1. 添加到文件右键菜单 (参数: "%1")
:: HKEY_CLASSES_ROOT\*\shell
reg add "HKEY_CLASSES_ROOT\*\shell\!MenuName!" /ve /d "!MenuName!" /f >nul
reg add "HKEY_CLASSES_ROOT\*\shell\!MenuName!" /v "Icon" /d "\"!AppPath!\"" /f >nul
reg add "HKEY_CLASSES_ROOT\*\shell\!MenuName!\command" /ve /d "\"!AppPath!\" \"%%1\"" /f >nul

:: 2. 添加到文件夹右键菜单 (参数: "%V")
:: HKEY_CLASSES_ROOT\Directory\shell
reg add "HKEY_CLASSES_ROOT\Directory\shell\!MenuName!" /ve /d "!MenuName!" /f >nul
reg add "HKEY_CLASSES_ROOT\Directory\shell\!MenuName!" /v "Icon" /d "\"!AppPath!\"" /f >nul
reg add "HKEY_CLASSES_ROOT\Directory\shell\!MenuName!\command" /ve /d "\"!AppPath!\" \"%%V\"" /f >nul

:: 3. 添加到文件夹背景空白处右键菜单 (参数: "%V")
:: HKEY_CLASSES_ROOT\Directory\Background\shell
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\!MenuName!" /ve /d "!MenuName!" /f >nul
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\!MenuName!" /v "Icon" /d "\"!AppPath!\"" /f >nul
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\!MenuName!\command" /ve /d "\"!AppPath!\" \"%%V\"" /f >nul

echo.
echo ? 添加完成！
echo 请在任意文件或文件夹上点击右键测试。
echo.
echo 按任意键退出...
pause >nul
