############################################################################################               
#	AUTHOR : SOURABH KUSHWAHA
#	CREATED DATE : 30-01-2018
#	MODIFIED ON  : 30-01-2018
#	VERSION : 0.0.1
############################################################################################

!define APP_NAME "Mission Control 3.0"
!define APP_FILES_DIR "$%WORKSPACE%\Deploy\"
!define COMP_NAME "Asteria Aerospace"
!define COPYRIGHT "Asteria © 2017"
!define INSTALLER_NAME "$%WORKSPACE%\Installer\Mission_Control_v${VERSION}_$%BUILD_NUMBER%.exe"
!define MAIN_APP_EXE "Mission Control 3.0.exe"
!define MUI_ICON "asteria_logo_64x64.ico"
!define MUI_UNICON "asteria_logo_64x64.ico"
!define WEB_SITE "http://www.asteria.co.in/"

!define DESCRIPTION "Application"
!define INSTALL_TYPE "SetShellVarContext current"
!define REG_ROOT "HKCU"
!define REG_APP_PATH "Software\Microsoft\Windows\CurrentVersion\App Paths\${APP_NAME}"
!define UNINSTALL_PATH "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"

######################################################################

VIProductVersion  "3.0.0.0"
VIAddVersionKey "ProductName"  "${APP_NAME}"
VIAddVersionKey "CompanyName"  "${COMP_NAME}"
VIAddVersionKey "LegalCopyright"  "${COPYRIGHT}"
VIAddVersionKey "FileDescription"  "${DESCRIPTION}"
VIAddVersionKey "FileVersion"  "${VERSION}"

######################################################################

SetCompressor ZLIB
Name "${APP_NAME}"
Caption "${APP_NAME}"
OutFile "${INSTALLER_NAME}"
BrandingText "${APP_NAME}"
XPStyle on
InstallDirRegKey "${REG_ROOT}" "${REG_APP_PATH}" ""
InstallDir "$PROGRAMFILES\${APP_NAME}"

######################################################################

!include "MUI.nsh"

!define MUI_ABORTWARNING
!define MUI_UNABORTWARNING

!insertmacro MUI_PAGE_WELCOME

!ifdef LICENSE_TXT
!insertmacro MUI_PAGE_LICENSE "${LICENSE_TXT}"
!endif

!ifdef REG_START_MENU
!define MUI_STARTMENUPAGE_NODISABLE
!define MUI_STARTMENUPAGE_DEFAULTFOLDER ${APP_NAME}
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "${REG_ROOT}"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "${UNINSTALL_PATH}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "${REG_START_MENU}"
!insertmacro MUI_PAGE_STARTMENU Application $SM_Folder
!endif

!insertmacro MUI_PAGE_INSTFILES

!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM

!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_UNPAGE_FINISH

!insertmacro MUI_LANGUAGE "English"

RequestExecutionLevel admin

ShowInstDetails Show
 
#Page InstFiles
 
######################################################################
;Kill running applications and uninstall already existing installation
Function .onInit
    IfFileExists "$INSTDIR\Mission Control 3.0.exe" 0 +6
		MessageBox MB_OKCANCEL "An older version of Mission Control 3.0 is already installed. Click OK to uninstall or click Cancel to exit" IDOK lbl_OK IDCANCEL lbl_ABORT
            lbl_ABORT:
                Quit
            lbl_OK:
                ExecWait '"$INSTDIR\uninstall.exe" /S _?=$INSTDIR'
				nsExec::Exec  'taskkill /f /im "Mission Control 3.0.exe"'
				nsExec::Exec  'taskkill /f /im "AsteriaWatchDog.exe"'
				nsExec::Exec  'taskkill /f /im "ffmpeg.exe"'
FunctionEnd

######################################################################
; These are the programs that are needed by Application.
Section -Prerequisites
  SetOutPath $INSTDIR\Prerequisites
	File "$%GDAL_INSTALLER%"
	ExecWait "$INSTDIR\Prerequisites\OSGeo4W64.exe"
SectionEnd

######################################################################

Section -AddGDALPath
  #Set to HKLM
  EnVar::SetHKLM
  #Add a value
  EnVar::AddValue "Path" "C:\OSGeo4W64\bin"
  EnVar::AddValue "GDAL_DATA" "C:\OSGeo4W64\share\gdal"
SectionEnd

######################################################################

Section -MainProgram
${INSTALL_TYPE}
SetOverwrite ifnewer
SetOutPath "$INSTDIR"
    File /nonfatal /r "${APP_FILES_DIR}"
	
	RmDir /r "$PROFILE\${COMP_NAME}\${APP_NAME}\PayloadProfiles"
	CreateDirectory "$PROFILE\${COMP_NAME}\${APP_NAME}\PayloadProfiles"
	CopyFiles "$INSTDIR\PayloadProfiles\*.xml" "$PROFILE\${COMP_NAME}\${APP_NAME}\PayloadProfiles"
	CreateDirectory "$PROFILE\${COMP_NAME}\${APP_NAME}\TerrainData"
	
	IfFileExists $INSTDIR\AsteriaWatchDog.exe 0 +2
	ShellExecAsUser::ShellExecAsUser "" "$INSTDIR\AsteriaWatchDog.exe" ""
SectionEnd

######################################################################

Section -Icons_Reg
SetOutPath "$INSTDIR"
WriteUninstaller "$INSTDIR\uninstall.exe"

#Writes into HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Run\" "Asteria WatchDog" '"$INSTDIR\AsteriaWatchDog.exe"'

!ifdef REG_START_MENU
!insertmacro MUI_STARTMENU_WRITE_BEGIN Application
CreateDirectory "$SMPROGRAMS\$SM_Folder"
CreateShortCut "$SMPROGRAMS\$SM_Folder\${APP_NAME}.lnk" "$INSTDIR\${MAIN_APP_EXE}"
CreateShortCut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\${MAIN_APP_EXE}"
CreateShortCut "$SMPROGRAMS\$SM_Folder\Uninstall ${APP_NAME}.lnk" "$INSTDIR\uninstall.exe"

!ifdef WEB_SITE
WriteIniStr "$INSTDIR\${APP_NAME} website.url" "InternetShortcut" "URL" "${WEB_SITE}"
CreateShortCut "$SMPROGRAMS\$SM_Folder\${APP_NAME} Website.lnk" "$INSTDIR\${APP_NAME} website.url"
!endif
!insertmacro MUI_STARTMENU_WRITE_END
!endif

!ifndef REG_START_MENU
CreateDirectory "$SMPROGRAMS\${APP_NAME}"
CreateShortCut "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk" "$INSTDIR\${MAIN_APP_EXE}"
CreateShortCut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\${MAIN_APP_EXE}"
CreateShortCut "$SMPROGRAMS\${APP_NAME}\Uninstall ${APP_NAME}.lnk" "$INSTDIR\uninstall.exe"

!ifdef WEB_SITE
WriteIniStr "$INSTDIR\${APP_NAME} website.url" "InternetShortcut" "URL" "${WEB_SITE}"
CreateShortCut "$SMPROGRAMS\${APP_NAME}\${APP_NAME} Website.lnk" "$INSTDIR\${APP_NAME} website.url"
!endif
!endif

WriteRegStr ${REG_ROOT} "${REG_APP_PATH}" "" "$INSTDIR\${MAIN_APP_EXE}"
WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}"  "DisplayName" "${APP_NAME}"
WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}"  "UninstallString" "$INSTDIR\uninstall.exe"
WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}"  "DisplayIcon" "$INSTDIR\${MAIN_APP_EXE}"
WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}"  "DisplayVersion" "${VERSION}"
WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}"  "Publisher" "${COMP_NAME}"
WriteRegStr "${REG_ROOT}" "Software\${COMP_NAME}\${APP_NAME}" "SystemIdentification" "false"

!ifdef WEB_SITE
WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}"  "URLInfoAbout" "${WEB_SITE}"
!endif
SectionEnd

######################################################################

Section Uninstall
nsExec::Exec  'taskkill /f /im "Mission Control 3.0.exe"'
nsExec::Exec  'taskkill /f /im "AsteriaWatchDog.exe"'
nsExec::Exec  'taskkill /f /im "ffmpeg.exe"'
${INSTALL_TYPE}
RmDir /r "$INSTDIR"
 
!ifdef WEB_SITE
Delete "$INSTDIR\${APP_NAME} website.url"
!endif

RmDir "$INSTDIR"
RmDir /r "$PROFILE\${COMP_NAME}\${APP_NAME}\PayloadProfiles"

!ifdef REG_START_MENU
!insertmacro MUI_STARTMENU_GETFOLDER "Application" $SM_Folder
Delete "$SMPROGRAMS\$SM_Folder\${APP_NAME}.lnk"
Delete "$SMPROGRAMS\$SM_Folder\Uninstall ${APP_NAME}.lnk"
!ifdef WEB_SITE
Delete "$SMPROGRAMS\$SM_Folder\${APP_NAME} Website.lnk"
!endif
Delete "$DESKTOP\${APP_NAME}.lnk"

RmDir "$SMPROGRAMS\$SM_Folder"
!endif

!ifndef REG_START_MENU
Delete "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk"
Delete "$SMPROGRAMS\${APP_NAME}\Uninstall ${APP_NAME}.lnk"
!ifdef WEB_SITE
Delete "$SMPROGRAMS\${APP_NAME}\${APP_NAME} Website.lnk"
!endif
Delete "$DESKTOP\${APP_NAME}.lnk"

RmDir "$SMPROGRAMS\${APP_NAME}"
!endif

DeleteRegKey ${REG_ROOT} "${REG_APP_PATH}"
DeleteRegKey ${REG_ROOT} "${UNINSTALL_PATH}"

#Deletes from HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run
DeleteRegValue HKEY_LOCAL_MACHINE "SOFTWARE\Microsoft\Windows\CurrentVersion\Run\" "Asteria WatchDog"
SectionEnd

######################################################################