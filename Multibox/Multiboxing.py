import time
from pynput.keyboard import Key, Controller
import mouse
import numpy as np
from PIL import ImageGrab
from PIL import Image
from matplotlib import pyplot as plt

NBR_ACCOUNTS = 5
PIXEL_COORD = [(613, 580), (330, 2190), (330, 3148), (850, 3148), (850, 2190)]
MOVEMENT_KEY = [(Key.f1, Key.f2, Key.f3, 'a'), (Key.f4, Key.f5, Key.f6, 'b'), (Key.f7, Key.f8, Key.f9, 'c'), (Key.f10, Key.f11, Key.f12, 'd')]
PATH_SCREENSHOT = ""

running = True; running2 = False
InMovement = [0, 0, 0, 0]
indexScreen = 0

keyboard = Controller()
    
def stopWhile():
    global running; global running2
    if(running2):
        running2 = False
        if(InMovement[i-1] > 0):
            for y in range(len(MOVEMENT_KEY[i-1])):
                keyboard.release(MOVEMENT_KEY[i-1][y])
            InMovement[i-1] = 0
        print("Stop")
    else:
        running2 = True
        print("Running")
        
def screenShot():
    global indexScreen
    acc = []
    img_rgb = np.array(ImageGrab.grab(bbox=None, include_layered_windows=False, all_screens=True))
    acc.append(img_rgb[0:1080, 0:1920, :])
    acc.append(img_rgb[0:560, 1920:2880, :])
    acc.append(img_rgb[0:560, 2880:3840, :])
    acc.append(img_rgb[560:1080, 1920:2880, :])
    acc.append(img_rgb[560:1080, 2880:3840, :])
    for i in range(len(acc)):
        Image.fromarray(acc[i]).save(PATH_SCREENSHOT+str(indexScreen)+".jpg")
        indexScreen += 1
        
mouse.on_middle_click(stopWhile)
#keyboard.add_hotkey("!", lambda: screenShot())

while(running):
    time.sleep(0.5)
    while(running2):
        img_rgb = np.array(ImageGrab.grab(bbox=None, include_layered_windows=False, all_screens=True))
        for i in range(NBR_ACCOUNTS):
            bluePixel = img_rgb[PIXEL_COORD[i][0], PIXEL_COORD[i][1], 2]
            if(i > 0):
                if(bluePixel == 0 and InMovement[i-1] > 0):
                    for y in range(len(MOVEMENT_KEY[i-1])):
                        keyboard.release(MOVEMENT_KEY[i-1][y])
                    InMovement[i-1] = 0
                elif(bluePixel == 3):
                    InMovement[i-1] = 1
                    keyboard.press(MOVEMENT_KEY[i-1][0]) #Turn on the Right
                elif(bluePixel == 4):
                    InMovement[i-1] = 2
                    keyboard.press(MOVEMENT_KEY[i-1][1]) #Walk Forward
                elif(bluePixel == 5):
                    InMovement[i-1] = 3
                    keyboard.press(MOVEMENT_KEY[i-1][2]) #Walk Backward
                elif(bluePixel == 6):
                    keyboard.press(MOVEMENT_KEY[i-1][2]) #Walk Backward briefly
                    keyboard.release(MOVEMENT_KEY[i-1][2])
                elif(bluePixel == 7):
                    InMovement[i-1] = 4
                    keyboard.press(MOVEMENT_KEY[i-1][3]) #Strafe Left
        keyboard.press(Key.page_down)
        keyboard.release(Key.page_down)
        time.sleep(0.3)
print('Quitting')
