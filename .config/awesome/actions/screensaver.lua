local screensaver = {}

function screensaver:lock()
    io.popen("qdbus org.freedesktop.ScreenSaver /org/freedesktop/ScreenSaver org.freedesktop.ScreenSaver.Lock"):close()
end

return screensaver
