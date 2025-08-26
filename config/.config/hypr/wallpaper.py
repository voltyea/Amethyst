#!/usr/bin/env python3

import gi
import subprocess

gi.require_version("Gtk", "3.0")
gi.require_version("GtkLayerShell", "0.1")
from gi.repository import Gtk, Gdk, GtkLayerShell

def on_button_press(widget, event):
    # Left mouse button double-click
    if event.type == Gdk.EventType._2BUTTON_PRESS and event.button == 1:
        print("Double-click detected")
        subprocess.Popen(["waypaper"])

# Transparent fullscreen layer
window = Gtk.Window()
window.set_title("Desktop Click Layer")
window.set_app_paintable(True)
window.set_decorated(False)
window.set_accept_focus(False)
window.set_skip_taskbar_hint(True)
window.set_skip_pager_hint(True)
window.set_keep_above(False)
window.set_resizable(False)
window.stick()

# Setup layer shell
GtkLayerShell.init_for_window(window)
GtkLayerShell.set_layer(window, GtkLayerShell.Layer.BACKGROUND)

display = Gdk.Display.get_default()
monitor = display.get_primary_monitor()
if monitor is None:
    if display.get_n_monitors() > 0:
        monitor = display.get_monitor(0)
    else:
        print("No monitors found.")
        exit(1)

GtkLayerShell.set_monitor(window, monitor)
GtkLayerShell.auto_exclusive_zone_enable(window)

geometry = monitor.get_geometry()
window.set_default_size(geometry.width, geometry.height)
window.fullscreen()

# Enable button press and double-click events
window.set_events(Gdk.EventMask.BUTTON_PRESS_MASK)
window.connect("button-press-event", on_button_press)

window.show_all()
Gtk.main()

