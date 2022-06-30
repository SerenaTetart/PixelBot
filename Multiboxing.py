from PIL import ImageGrab
import numpy as np
import mouse
import time

import win32gui, win32con, win32api

PATH_WoW = "C:\Program Files (x86)\World of Warcraft\WoW1.12.1\WoW.exe" #Put your game path here !
NBR_ACCOUNT = 5

PIXEL_COORD = [(613, 580), (330, 2190), (330, 3148), (850, 3148), (850, 2190)]
MOVEMENT_KEY = [win32con.VK_RIGHT, win32con.VK_UP, win32con.VK_DOWN, win32con.VK_LEFT]

running = True; running2 = False
InMovement = [0, 0, 0, 0]
    
def stopWhile():
    global running; global running2
    if(running2):
        running2 = False
        for i in range(NBR_ACCOUNT):
            if(InMovement[i-1] > 0):
                for y in range(len(MOVEMENT_KEY)):
                    win32api.PostMessage(hwndACC[i], win32con.WM_KEYUP, MOVEMENT_KEY[y], 0)
                InMovement[i-1] = 0
        print("Stop")
    else:
        running2 = True
        print("Running")
        
mouse.on_middle_click(stopWhile)

hwndACC = [] #Get windows handle
listCoord = [(1920-7, 0, 974, 568), (1920+974-23, 0, 974, 568), (1920+974-23, 1080-568+10, 974, 568), (1920-7, 1080-568+10, 974, 568)]
for i in range(NBR_ACCOUNT):
    win32api.WinExec(PATH_WoW)
    hwnd = win32gui.FindWindow(None, "World of Warcraft")
    print(hwnd)
    hwndACC.append(hwnd)
    win32gui.SetWindowText(hwnd, "WoW"+str(i+1))
    if(i > 0): win32gui.MoveWindow(hwnd, listCoord[i-1][0], listCoord[i-1][1], listCoord[i-1][2], listCoord[i-1][3], True)
    else: win32gui.ShowWindow(hwnd, win32con.SW_MAXIMIZE)

while(running):
    time.sleep(0.5)
    while(running2):
        img_rgb = np.array(ImageGrab.grab(bbox=None, include_layered_windows=False, all_screens=True))
        for i in range(NBR_ACCOUNT):
            bluePixel = img_rgb[PIXEL_COORD[i][0], PIXEL_COORD[i][1], 2]
            if(i > 0):
                if(bluePixel == 0 and InMovement[i-1] > 0):
                    for y in range(len(MOVEMENT_KEY)):
                        win32api.PostMessage(hwndACC[i], win32con.WM_KEYUP, MOVEMENT_KEY[y], 0)
                    InMovement[i-1] = 0
                elif(bluePixel == 3): #Turn on the Right
                    InMovement[i-1] = 1
                    win32api.PostMessage(hwndACC[i], win32con.WM_KEYDOWN, MOVEMENT_KEY[0], 0)
                elif(bluePixel == 4): #Walk Forward
                    InMovement[i-1] = 2
                    win32api.PostMessage(hwndACC[i], win32con.WM_KEYDOWN, MOVEMENT_KEY[1], 0)
                elif(bluePixel == 5): #Walk Backward
                    InMovement[i-1] = 3
                    win32api.PostMessage(hwndACC[i], win32con.WM_KEYDOWN, MOVEMENT_KEY[2], 0)
                elif(bluePixel == 6): #Walk Backward briefly
                    win32api.PostMessage(hwndACC[i], win32con.WM_KEYDOWN, MOVEMENT_KEY[2], 0)
                    win32api.PostMessage(hwndACC[i], win32con.WM_KEYUP, MOVEMENT_KEY[2], 0)
                elif(bluePixel == 7): #Strafe Left
                    InMovement[i-1] = 4
                    win32api.PostMessage(hwndACC[i], win32con.WM_KEYDOWN, MOVEMENT_KEY[3], 0)
                elif(bluePixel == 8): #Jump !
                    win32api.PostMessage(hwndACC[i], win32con.WM_KEYDOWN, win32con.VK_SPACE, 0)
                    win32api.PostMessage(hwndACC[i], win32con.WM_KEYUP, win32con.VK_SPACE, 0)
            win32api.PostMessage(hwndACC[i], win32con.WM_KEYDOWN, win32con.VK_NEXT, 0)
            win32api.PostMessage(hwndACC[i], win32con.WM_KEYUP, win32con.VK_NEXT, 0)
        time.sleep(0.3)
print('Quitting')
