on run argv
    set projectPath to item 1 of argv

    tell application "System Events"
        set isRunning to (name of processes) contains "Xcode"
    end tell

    if isRunning then
        tell application "Xcode"
            activate
            open POSIX file projectPath
        end tell
    else
        tell application "Xcode"
            open POSIX file projectPath
            activate
        end tell
    end if

    delay 5 -- 等待项目打开

    tell application "System Events"
        tell process "Xcode"
            keystroke "r" using {command down}
        end tell
    end tell
end run