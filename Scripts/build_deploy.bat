REM MCS build process using cmd line
REM AUTHOR : SOURABH KUSHWAHA, Ramkumar CREATED DATE : 30-01-2018, LAST MODIFIED ON : 18/Nov/2020, VERSION : 0.1.0
REM Add VC_DIR,QTBIN_DIR,NSIS_DIR,GIT_BIN,MCSKEYGEN to system environment variables

REM Build tools n Compiler configs
ECHO "VC_DIR=%VC_DIR%"
ECHO "QT_DIR=%QT_DIR%"
ECHO "NSIS_DIR=%NSIS_DIR%"
ECHO "GIT_BIN=%GIT_BIN%"

REM Workspace n 3rd party lib path
ECHO "WORKSPACE=%WORKSPACE%"


REM "---------------------- Env setup --------------------------"

REM setting project directories
SET PRO_DIR=%WORKSPACE%

REM Set up \Microsoft Visual Studio 2019, where <arch> is \c amd64.
CALL %VC_DIR%\"vcvarsall.bat" amd64

REM 3rd party libraries, requires for project compilation
SET OPENCV=%MCS_LIB_BASE_DIR%\opencv
SET FFMPEG=%MCS_LIB_BASE_DIR%\ffmpeg
SET MAVLINK2=%MCS_LIB_BASE_DIR%\mavlinkLibrary2
SET MAVLINK3=%MCS_LIB_BASE_DIR%\mavlinkLibrary3
SET MAVLINK436=%MCS_LIB_BASE_DIR%\mavlinkLibrary436
SET MAVLINK444=%MCS_LIB_BASE_DIR%\mavlinkLibrary444
SET SDL=%MCS_LIB_BASE_DIR%\sdl
SET SMTPEmail=%MCS_LIB_BASE_DIR%\SMTPEmail
SET SSL=%MCS_LIB_BASE_DIR%\OpenSSL
SET SSH_LIB=%MCS_LIB_BASE_DIR%\libssh
SET KAFKA=%MCS_LIB_BASE_DIR%\librdkafka
SET QUAZIP=%MCS_LIB_BASE_DIR%\quazip
SET RTKLib=%MCS_LIB_BASE_DIR%\rtkLib

REM Set build tools & 3rdparty lib path into system path variable
SET PATH=%PATH%;%QT_DIR%\bin;%QT_DIR%\lib;%NSIS_DIR%;%GIT_BIN%
SET PATH=%PATH%;%FFMPEG%;%MAVLINK2%;%MAVLINK3%;%MAVLINK436%;%SDL%;%SMTPEmail%
SET PATH=%PATH%;%MCSKEYGEN%;%SSH_LIB%;%KAFKA%;%QUAZIP%;%RTKLib%
echo %PATH%
cd %PRO_DIR%



REM "---------------------- Build process --------------------------"

REM Extracting version from git tag
FOR /f "tokens=*" %%i IN ('git --work-tree $$PWD describe --always --tags --abbrev^=0') DO SET version=%%i

REM Preparing the extra param config
echo MAVLINK_VERSION=%MAVLINK_VERSION%
SET PARAMS="DEFINES+=DEBUG_ENABLE"
SET MAVLINK_PARAM="DEFINES+=%MAVLINK_VERSION%"
SET PRODUCTION_PARAM="DEFINES+=PRODUCTION"
SET PARAMS=%PARAMS% %MAVLINK_PARAM%
IF "%PRODUCTION_FLAG%"=="ENABLE" SET PARAMS=%PARAMS% %PRODUCTION_PARAM%
echo QMAKE_PARAMS=%PARAMS%

REM Compile project and generate executable
CALL qmake -recursive "CONFIG-=debug" "CONFIG+=release" %PARAMS%
if not %ERRORLEVEL% == 0 goto :endofscript
CALL nmake
if not %ERRORLEVEL% == 0 goto :endofscript



REM "---------------------- Deployment --------------------------"

REM Preparation for deployments
mkdir "%WORKSPACE%\Installer"
mkdir "%WORKSPACE%\Deploy"

REM Copy built DLLs & Exe together into Deploy Directory
xcopy /d /y /s "%WORKSPACE%\Binary\*.exe" %WORKSPACE%"\Deploy"
xcopy /d /y /s "%WORKSPACE%\Binary\*.dll" %WORKSPACE%"\Deploy"
xcopy /d /y /s "%WORKSPACE%\Application\Data\*.py" %WORKSPACE%"\Deploy"
xcopy /i /y /s "%WORKSPACE%\Application\Data\PayloadProfiles" %WORKSPACE%"\Deploy\PayloadProfiles"
xcopy /i /y /s "%WORKSPACE%\Application\Data\PreflightChecklist" %WORKSPACE%"\Deploy\PreflightChecklist"
xcopy /i /y /s "%WORKSPACE%\Application\Data\India_airports.csv" %WORKSPACE%"\Deploy"
xcopy /i /y /s "%WORKSPACE%\Application\Data\SRTMConfig.xml" %WORKSPACE%"\Deploy"
xcopy /i /y /s "%WORKSPACE%\Application\Data\PathPlannerConfig.json" %WORKSPACE%"\Deploy"
xcopy /i /y /s "%WORKSPACE%\Application\Data\Config" %WORKSPACE%"\Deploy\Config"


REM Copy 3rd party dll's & exe  into deploy dir
xcopy /d /y /s "%OPENCV%\bin\opencv_core490.dll" %WORKSPACE%"\Deploy"
xcopy /d /y /s "%OPENCV%\bin\opencv_video490.dll" %WORKSPACE%"\Deploy"
xcopy /d /y /s "%OPENCV%\bin\opencv_videoio490.dll" %WORKSPACE%"\Deploy"
xcopy /d /y /s "%OPENCV%\bin\opencv_imgproc490.dll" %WORKSPACE%"\Deploy"
xcopy /d /y /s "%OPENCV%\bin\opencv_imgcodecs490.dll" %WORKSPACE%"\Deploy"
xcopy /d /y /s "%OPENCV%\bin\opencv_videoio_ffmpeg490_64.dll" %WORKSPACE%"\Deploy"
xcopy /d /y /s "%OPENCV%\bin\libmfx_vs2015.dll" %WORKSPACE%"\Deploy"

xcopy /d /y /s "%OPENCV2%\bin\opencv_core2413.dll" %WORKSPACE%"\Deploy"
xcopy /d /y /s "%OPENCV2%\bin\opencv_imgproc2413.dll" %WORKSPACE%"\Deploy"
xcopy /d /y /s "%OPENCV2%\bin\opencv_highgui2413.dll" %WORKSPACE%"\Deploy"
xcopy /d /y /s "%OPENCV2%\bin\opencv_calib3d2413.dll" %WORKSPACE%"\Deploy"
xcopy /d /y /s "%OPENCV2%\bin\opencv_video2413.dll" %WORKSPACE%"\Deploy"
xcopy /d /y /s "%OPENCV2%\bin\opencv_features2d2413.dll" %WORKSPACE%"\Deploy"
xcopy /d /y /s "%OPENCV2%\bin\opencv_flann2413.dll" %WORKSPACE%"\Deploy"

xcopy /d /y /s "%FFMPEG%\bin\*.dll" %WORKSPACE%"\Deploy"
xcopy /d /y /s "%FFMPEG%\bin\ffmpeg.exe" %WORKSPACE%"\Deploy"
xcopy /d /y /s "%SDL%\lib\x64\*.dll" %WORKSPACE%"\Deploy"
xcopy /d /y /s "%SSL%\*.dll" %WORKSPACE%"\Deploy"
xcopy /d /y /s "%SSH_LIB%\bin\*.dll" %WORKSPACE%"\Deploy"
xcopy /i /y /s "%SMTPEmail%\lib\SMTPEmail.dll" %WORKSPACE%"\Deploy"
xcopy /d /y /s "%MCS_LIB_BASE_DIR%\MSVC140\*.dll" %WORKSPACE%"\Deploy"
xcopy /i /y /s "%MCS_LIB_BASE_DIR%\PPKTool\*" %WORKSPACE%"\Deploy\PPKTool"
xcopy /d /y /s "%KAFKA%\bin\*.dll" %WORKSPACE%"\Deploy"
xcopy /d /y /s "%QUAZIP%\lib\*.dll" %WORKSPACE%"\Deploy"
xcopy /d /y /s "%RTKLib%\lib\*" %WORKSPACE%"\Deploy"

REM Auxillary tools needed by the application
xcopy /i /y /s "%MCS_TOOLS_PATH%\MCSDataUploader" %WORKSPACE%"\Deploy\MCSDataUploader"
xcopy /i /y /s "%MCS_TOOLS_PATH%\Prerequisites\7*exe" %WORKSPACE%"\Deploy"
xcopy /i /y /s "%MCS_TOOLS_PATH%\Prerequisites\7*dll" %WORKSPACE%"\Deploy"
xcopy /i /y /s "%MCS_TOOLS_PATH%\PathPlanner\*" %WORKSPACE%"\Deploy\PathPlanner"
xcopy /i /y /s "%MCS_TOOLS_PATH%\Prerequisites\proxyServer.exe" %WORKSPACE%"\Deploy"
xcopy /d /y /s "%WATCHDOG_BASE_PATH%\Binary\*.exe" %WORKSPACE%"\Deploy"
xcopy /d /y /s "%KEYGEN_BASE_PATH%\Binary\*.dll" %WORKSPACE%"\Deploy"
xcopy /i /y /s "..\mcsDevTools\Binary\MCSVideoConverter.exe" %WORKSPACE%"\Deploy"


REM Bundle Qt libs
cd "%WORKSPACE%\Deploy"
windeployqt.exe "Mission Control 3.0.exe" --qmldir "%WORKSPACE%\Application\Qml" -xml -websockets
if not %ERRORLEVEL% == 0 goto :endofscript



REM "---------------------- Installer creation --------------------------"

REM NSIS Installer creation
cd %PRO_DIR%
makensis /DVERSION=%version% Scripts\installer.nsi
if not %ERRORLEVEL% == 0 goto :endofscript
echo "Installer generated successfully"

REM Cleanup temp files
rmdir /s /q "%WORKSPACE%\Deploy"

:endofscript
echo "Script complete"
