; LeGGGion.ahk - Pause/resume GGGlide based on device usage
#NoEnv
#Persistent
#SingleInstance Force
SendMode Input
SetWorkingDir %A_ScriptDir%

glideahk := "GGGlide.ahk"

; Add your target VID/PID values
mouseVIDPIDs := ["VID_17EF&PID_61EE"]        ; Mouse VID/PID(s)
touchpadVIDPIDs := ["VID_17EF&PID_61EB", "VID_17EF&PID_61ED"]    ; Touchpad VID/PID(s)

paused := false

; Tray icon
Menu, Tray, Icon, Shell32.dll, 176
Menu, Tray, Tip, LeGGGion

; Launch GGGlide if not already running
IfWinNotExist, %glideahk% - AutoHotkey
    Run, %glideahk%

; Check devices every 2 seconds
SetTimer, MonitorDevices, 2000
return

MonitorDevices:
{
    deviceType := DetectDeviceType()
    if (deviceType = "Mouse" && !paused) {
        paused := true
        ToggleGGGlidePause()
    } else if (deviceType = "Touchpad" && paused) {
        paused := false
        ToggleGGGlidePause()
    }
}
return

; --- Functions ---

DetectDeviceType() {
    global mouseVIDPIDs, touchpadVIDPIDs
    detectedMouse := false
    detectedTouchpad := false

    wmi := ComObjGet("winmgmts:")
    for device in wmi.ExecQuery("SELECT * FROM Win32_PnPEntity WHERE PNPDeviceID LIKE '%VID_%'") {
        for _, vidpid in mouseVIDPIDs {
            if InStr(device.PNPDeviceID, vidpid)
                detectedMouse := true
        }
        for _, vidpid in touchpadVIDPIDs {
            if InStr(device.PNPDeviceID, vidpid)
                detectedTouchpad := true
        }
    }

    if detectedMouse
        return "Mouse"
    else if detectedTouchpad
        return "Touchpad"
    return ""  ; No target device found
}

ToggleGGGlidePause() {
    global glideahk
    DetectHiddenWindows, On
    SetTitleMatchMode, 2
    PostMessage, 0x111, 65306,,, %glideahk% - AutoHotkey
}
