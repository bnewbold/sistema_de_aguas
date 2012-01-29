#!/usr/bin/env python

import wx
import serial
 
class MyForm(wx.Frame):
 
    def __init__(self):
        wx.Frame.__init__(self, None, wx.ID_ANY, "Keygrabber")

        self.serial = serial.Serial('/dev/ttyACM0', 19200, timeout=1)
        self.state = {
            'up': False,
            'down': False,
            'left': False,
            'right': False,
            'space': False,
            'c': False,
            'v': False,
            'escape': False,
        }
 
        # Add a panel so it looks the correct on all platforms
        panel = wx.Panel(self, wx.ID_ANY)
        panel.Bind(wx.EVT_KEY_DOWN, self.onKeyDown)
        panel.Bind(wx.EVT_KEY_UP, self.onKeyUp)
        self.send_update()

    def onKeyDown(self, event):
        keycode = event.GetKeyCode()
        print keycode
        if keycode == wx.WXK_RIGHT:
            self.state['right'] = True
        elif keycode == wx.WXK_LEFT:
            self.state['left'] = True
        elif keycode == wx.WXK_UP:
            self.state['up'] = True
        elif keycode == wx.WXK_DOWN:
            self.state['down'] = True
        elif keycode == wx.WXK_SPACE:
            self.state['space'] = True
        elif keycode == wx.WXK_ESCAPE:
            self.state['escape'] = True
        elif keycode == 67: # 'c'
            self.state['c'] = True
        elif keycode == 86: # 'v'
            self.state['v'] = True
        self.send_update()
        event.Skip()

    def onKeyUp(self, event):
        keycode = event.GetKeyCode()
        print keycode
        if keycode == wx.WXK_RIGHT:
            self.state['right'] = False
        elif keycode == wx.WXK_LEFT:
            self.state['left'] = False
        elif keycode == wx.WXK_UP:
            self.state['up'] = False
        elif keycode == wx.WXK_DOWN:
            self.state['down'] = False
        elif keycode == wx.WXK_SPACE:
            self.state['space'] = False
        elif keycode == wx.WXK_ESCAPE:
            self.state['escape'] = False
        elif keycode == 67: # 'c'
            self.state['c'] = False
        elif keycode == 86: # 'v'
            self.state['v'] = False
        self.send_update()
        event.Skip()

    def send_update(self):
        #print self.state
        state_str = ''.join(map(str, map(int, [
            self.state['up'],
            self.state['down'],
            self.state['left'],
            self.state['right'],
            self.state['c'],
            self.state['v'],
            self.state['space'],
            self.state['escape'], ])))
        print state_str
        state_byte = chr(int(state_str, 2))
        self.serial.write(state_byte)

# Run the program
if __name__ == "__main__":
    app = wx.PySimpleApp()
    frame = MyForm()
    frame.Show()
    app.MainLoop()
