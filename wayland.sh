#!/bin/bash
setid deepin-kwin_wayland --drm --xwayland
export QT_QPA_PLATFORM=wayland
export XDG_SESSION_TYPE=wayland
export DISPLAY=:1
export WAYLAND_DISPLAY=wayland-0
startdde
