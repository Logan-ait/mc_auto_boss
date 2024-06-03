@echo off
chcp 65001


@REM 判断当前是否以管理员权限运行，如果不是则提示并退出
net session >nul 2>nul
if %errorlevel% neq 0 (
    echo 请以管理员权限运行此脚本。
    pause
    exit /b 1
)

@REM 检测当前目录路径是否存在中文，如果存在则提示并退出
set "currentDir=%CD%"
set "hasChinese=false"

for %%a in (%currentDir%) do (
    if not "%%~a" == "%%~a" (
        set "hasChinese=true"
        break
    )
)
if "%hasChinese%" == "true" (
    echo 当前目录路径包含中文字符。
    pause
    exit /b 1
)

@REM 判断 py310 文件夹是否存在 如果不存在则下载 https://cloudreve.caiyun.fun/f/x2ux/py310.zip 并解压到 py310 文件夹
if not exist py310 (
    echo 未找到 Python 3.10 环境，正在下载并解压...
@REM     curl -k -L https://hermes981128.oss-cn-shanghai.aliyuncs.com/py310.zip -o py310.zip
    curl -k -L https://cloudreve.caiyun.fun/f/x2ux/py310.zip -o py310.zip
    @REM     判断 是否存在 py310 文件夹，如果不存在则解压
    if not exist py310 (
    rem 创建 py310 文件夹
        mkdir py310
    )
    tar  -xf py310.zip -C py310
    del py310.zip
) else (
    echo Python 3.10 环境已存在
)


rem 管理员启动
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit
chcp 65001
rem 进入当前文件夹
cd /d %~dp0
@REM 添加临时环境变量 python310 目录
set PATH=%~dp0\py310;%PATH%
@REM 判断是否有pip, 如果没有则 运行 python 执行 get-pip.py
if not exist py310\Scripts\pip.exe (
    rem 安装pip
    python get-pip.py
)else (
    rem pip已安装
)
@REM 添加临时环境变量 python310/Scripts 目录
set PATH=%~dp0\py310\Scripts;%PATH%
REM 检查依赖是否已经安装
@REM 遍历 requirements.txt 安装依赖
for /f "delims=" %%i in (requirements.txt) do (
    REM Check if the package is installed
    pip show %%i >nul 2>nul
    if errorlevel 1 (
        REM If the package is not installed, install it
        echo Installing %%i...
        pip install %%i -i https://pypi.tuna.tsinghua.edu.cn/simple
    ) else (
        echo %%i is already installed.
    )
)
@REM 运行程序
python background/main.py
pause
exit
