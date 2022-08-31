from PIL import ImageTk, Image, ImageGrab
from tkinter import messagebox, filedialog
from playsound import playsound #1.2.2 !!
from pynput import keyboard
from tkinter import ttk
#import multiprocessing
#from gtts import gTTS
import tkinter as tk
import numpy as np
import mouse
import time
import PIL
import os
import re

import win32gui, win32con, win32api #pywin32

import parser

class Interface(tk.Tk):
    def __init__(self):
        super().__init__()
        
         # Window
        self.resizable(False,False)
        self.title('Multibox')
        self.protocol("WM_DELETE_WINDOW", self.quit_program)
        self.iconphoto(True, ImageTk.PhotoImage(Image.open(r"assets/icon.jpg")))
        self.iconWoW = tk.PhotoImage(file='assets/iconWoW.png')
        self.iconScreenshot = ImageTk.PhotoImage(Image.open(r"assets/iconScreenshot.jpg"))
        self.attributes('-topmost', True)
        
         # Variables
        parser.init_config('config.conf')
        self.PATH_WoW = parser.get_value('config.conf', 'PATH_WoW', '=')
        self.PATH_Screenshot = parser.get_value('config.conf', 'PATH_Screenshot', '=')
        self.ACC_Info = parser.get_multiplevalues('config.conf', 'ACC_Infos', '(', ',', ')')
        self.MOVEMENT_KEY = [win32con.VK_RIGHT, win32con.VK_UP, win32con.VK_DOWN, win32con.VK_LEFT]
        
        self.listCoord = []
        self.PIXEL_COORD = []
        self.hwndACC = [] #Get windows handle
        self.script_running = False
        self.InMovement = [0 for x in range(20)]
        self.indexIMG = 0
        if(self.PATH_Screenshot != ''):
            for file in os.listdir(self.PATH_Screenshot):
                nbrTmp = re.findall('[0-9]+', file)
                if(int(nbrTmp[0]) > self.indexIMG): self.indexIMG = int(nbrTmp[0])
        
         # Tabs
        tabControl = ttk.Notebook(self)
        tab1 = ttk.Frame(tabControl)
        tab2 = ttk.Frame(tabControl)
        tabControl.add(tab1, text='Menu')
        tabControl.add(tab2, text='Options')
        tabControl.pack(expand = 1, fill ="both")
        
         # Widgets
        OptionList = ['5', '10', '15', '20']
        self.numberClientsList = tk.StringVar(self)
        self.numberClientsList.set(OptionList[0])
        self.NBR_ACCOUNT = int(self.numberClientsList.get())
        self.WoWDirButton = tk.Button(tab2, image=self.iconWoW, command=lambda: self.selectWoWDir())
        self.WoWDirEntry = tk.Entry(tab2, state='normal', width = 26)
        self.WoWDirEntry.insert(0,self.PATH_WoW)
        self.WoWDirEntry.configure(state='disabled')
        self.ScreenshotDirButton = tk.Button(tab2, image=self.iconScreenshot, command=lambda: self.selectScreenshotDir())
        self.ScreenshotDirEntry = tk.Entry(tab2, state='normal', width = 26)
        self.ScreenshotDirEntry.insert(0,self.PATH_Screenshot)
        self.ScreenshotDirEntry.configure(state='disabled')
        self.ModifyCredentials_Button = tk.Button(tab2, text='Modify credentials', command=lambda: self.open_credentials_tab(), padx=5, pady=5)
        self.LaunchRepair_Button = tk.Button(tab1, text='Launch', command=lambda: self.launch_repair_clients(), padx=5, pady=5)
        self.ToggleIA_Button = tk.Button(tab1, text='Toggle IA', command=lambda: self.toggleIA(), padx=5, pady=5)
        self.ScriptOnOff_Label = tk.Label(tab1, text="OFF", foreground='red')
        self.IAOnOff_Label = tk.Label(tab1, text="OFF", foreground='red')
        self.NbrClient_Menu = tk.OptionMenu(tab1, self.numberClientsList, *OptionList)
        self.NbrClient_Label = tk.Label(tab1, text="Number clients:")
        
         # Config
        self.LaunchRepair_Button.config(width = 6)
        self.NbrClient_Menu.config(width = 2)
        self.IAOnOff_Label.config(width = 3)
        
         # Grid
        self.WoWDirButton.grid(row=0, column=0, sticky=tk.E, padx=2, pady=10)
        self.WoWDirEntry.grid(row=0, column=1, columnspan=2, padx=2)
        self.ScreenshotDirButton.grid(row=1, column=0, sticky=tk.E, padx=2)
        self.ScreenshotDirEntry.grid(row=1, column=1, columnspan=2, padx=2)
        self.ModifyCredentials_Button.grid(row=2, column=1)
        self.ScriptOnOff_Label.grid(row=0, column=4, sticky=tk.E)
        self.LaunchRepair_Button.grid(row=1, column=0, pady=5)
        self.ToggleIA_Button.grid(row=2, column=0, pady=5)
        self.IAOnOff_Label.grid(row=2, column=1)
        self.NbrClient_Label.grid(row=1, column=3)
        self.NbrClient_Menu.grid(row=1, column=4)
        
        self.after(300, self.run_script)
        
    def quit_program(self):
        #Disconnect clients
        self.script_running = False
        for hwnd in self.hwndACC:
            if(win32gui.IsWindow(hwnd)):
                win32api.PostMessage(hwnd, win32con.WM_CLOSE, 0, 0)
        self.destroy()
        
    def selectWoWDir(self):
        tmp = filedialog.askopenfile(title='Select your wow vanilla client', filetypes=[('WoW', ['exe'])], initialdir=self.PATH_WoW)
        if(tmp != None and tmp.name != self.PATH_WoW):
            parser.modify_config('config.conf', path_wow=tmp.name)
            self.PATH_WoW = tmp.name
            self.WoWDirEntry.configure(state='normal')
            self.WoWDirEntry.delete(0,tk.END)
            self.WoWDirEntry.insert(0,tmp.name)
            self.WoWDirEntry.configure(state='disabled')
            
    def selectScreenshotDir(self):
        tmp = filedialog.askdirectory(title='Select your screenshots directory', initialdir=self.PATH_Screenshot)
        if(tmp != '' and tmp != self.PATH_Screenshot):
            self.PATH_Screenshot = tmp
            parser.modify_config('config.conf', path_screen=tmp)
            self.ScreenshotDirEntry.configure(state='normal')
            self.ScreenshotDirEntry.delete(0,tk.END)
            self.ScreenshotDirEntry.insert(0,tmp)
            self.ScreenshotDirEntry.configure(state='disabled')
            self.indexIMG = 0
            for file in os.listdir(self.PATH_Screenshot):
                nbrTmp = re.findall('[0-9]+', file)
                if(int(nbrTmp[0]) > self.indexIMG): self.indexIMG = int(nbrTmp[0])
        
    def open_credentials_tab(self):
        global credentialTab
        global credentials_Entry
        try:
            if(credentialTab.state() == "normal"): credentialTab.focus()
        except:
            credentialTab = tk.Toplevel(self)
            credentialTab.title('Credentials')
            credentialTab.resizable(False,False)
            credentialTab.attributes('-topmost', True)
            account_Label = []; username_Label = []
            password_Label = []; credentials_Entry = []
            validate_Button = tk.Button(credentialTab, text='Validate changes', command=lambda: self.modify_crendentials())
            y = 0
            for i in range(25):
                 # Widgets
                account_Label.append(tk.Label(credentialTab, text="Account "+str(i+1)))
                username_Label.append(tk.Label(credentialTab, text="Username:"))
                password_Label.append(tk.Label(credentialTab, text="Password:"))
                credentials_Entry.append([tk.Entry(credentialTab, width = 15), tk.Entry(credentialTab, width = 15)])
                credentials_Entry[i][0].insert(0, self.ACC_Info[i][0])
                credentials_Entry[i][1].insert(0, self.ACC_Info[i][1])
                # Grid
                col = 0
                if(i >= 20): col = 4
                elif(i >= 10): col = 2
                if(i == 20 or i == 10): y = 0
                account_Label[i].grid(row=y, column=col+1)
                username_Label[i].grid(row=y+1, column=col)
                password_Label[i].grid(row=y+2, column=col)
                credentials_Entry[i][0].grid(row=y+1, column=col+1)
                credentials_Entry[i][1].grid(row=y+2, column=col+1)
                y = y+3
            validate_Button.grid(row=28, column=5, padx=2)
        
    def modify_crendentials(self):
        for i in range(25):
            self.ACC_Info[i] = (credentials_Entry[i][0].get(), credentials_Entry[i][1].get())
        parser.modify_config('config.conf', acc_info=self.ACC_Info)
        credentialTab.destroy()
        
    def send_client_txt(self, hwnd, txt):
        #Send text to window
        for c in txt:
            win32api.PostMessage(hwnd, win32con.WM_CHAR, ord(c), 0)
    
    def on_KeyPress(self, key):
        if(hasattr(key, 'char') and key.char == '²'): self.takeScreenshot()
        elif(key == keyboard.Key.page_up):
            for i in range(int(self.numberClientsList.get())):
                win32api.PostMessage(self.hwndACC[i], win32con.WM_KEYDOWN, win32con.VK_PRIOR, 0)
                win32api.PostMessage(self.hwndACC[i], win32con.WM_KEYUP, win32con.VK_PRIOR, 0)
        
    def adapt_listCoord(self):
        screenWidth = 1920; screenHeight = 1080
        coefPixel = [0.3015, 0.5666]
        coefPixel2 = [0.278, 0.58]
        NBR_ACCOUNT_SCREEN1 = (self.NBR_ACCOUNT//5)
        if(NBR_ACCOUNT_SCREEN1 == 1): wWidth1 = screenWidth
        elif(NBR_ACCOUNT_SCREEN1 == 3): wWidth1 = int((screenWidth//3)*(1+(0.012*2)))
        else: wWidth1 = int((screenWidth//2)*1.018)
        if(NBR_ACCOUNT_SCREEN1 <= 3): wHeight1 = screenHeight
        else: wHeight1 = (screenHeight//2)
        wWidth2 = int((screenWidth//((self.NBR_ACCOUNT - NBR_ACCOUNT_SCREEN1)//2))*(1+(0.018*NBR_ACCOUNT_SCREEN1)))
        wHeight2 = int((screenHeight//2)*1.04)
        self.listCoord = []
        tmp = 0; tmp2 = 0
        for i in range(NBR_ACCOUNT_SCREEN1):
            if(i > 0): tmp2 = tmp2 + 2
            if(i == 0):
                self.listCoord.append((-8, 0, wWidth1, wHeight1))
                self.PIXEL_COORD.append( (int((wWidth1-8)*coefPixel[0]), int(wHeight1*coefPixel[1])) )
            elif(i == 1):
                self.listCoord.append((wWidth1-23, 0, wWidth1, wHeight1))
                self.PIXEL_COORD.append( (int(self.PIXEL_COORD[0][0]+8+wWidth1-23), int(wHeight1*coefPixel[1])) )
            elif(NBR_ACCOUNT_SCREEN1 == 3):
                self.listCoord.append(((wWidth1*2)-int(18.5*2), 0, wWidth1, wHeight1))
                self.PIXEL_COORD.append(( int(self.PIXEL_COORD[0][0]+8+(wWidth1*2)-int(18.5*2)), int(wHeight1*coefPixel[1]) ))
            elif(i == 2):
                self.listCoord.append((wWidth1-23, wHeight1-37, wWidth1, wHeight1))
                self.PIXEL_COORD.append(( int(self.PIXEL_COORD[0][0]+8+wWidth1-23), int(self.PIXEL_COORD[0][1]+wHeight1-37) ))
            elif(i == 3):
                self.listCoord.append((-8, wHeight1-37, wWidth1, wHeight1))
                self.PIXEL_COORD.append(( int((wWidth1-8)*coefPixel[0]), int(self.PIXEL_COORD[0][1]+wHeight1-37) ))
            for y in range(4):
                if(tmp == 0):
                    if(tmp2 == 0):
                        self.listCoord.append((screenWidth+(wWidth2*tmp2)-8, 0, wWidth2, wHeight2))
                        self.PIXEL_COORD.append(( int(int((wWidth2-8)*coefPixel2[0])+screenWidth+(wWidth2*tmp2)), int(wHeight2*coefPixel2[1]) ))
                    else:
                        self.listCoord.append((screenWidth+(wWidth2*tmp2)-(19*tmp2), 0, wWidth2, wHeight2))
                        self.PIXEL_COORD.append(( int(int((wWidth2-8)*coefPixel2[0])+8+screenWidth+(wWidth2*tmp2)-(19*tmp2)), int(wHeight2*coefPixel2[1]) ))
                elif(tmp == 1):
                    if(tmp2 == 0):
                        self.listCoord.append((screenWidth+(wWidth2*(tmp2+1))-23, 0, wWidth2, wHeight2))
                        self.PIXEL_COORD.append(( int(int((wWidth2-8)*coefPixel2[0])+8+screenWidth+(wWidth2*(tmp2+1))-23), int(wHeight2*coefPixel2[1]) ))
                    else:
                        self.listCoord.append((screenWidth+(wWidth2*(tmp2+1))-int(18.5*(tmp2+1)), 0, wWidth2, wHeight2))
                        self.PIXEL_COORD.append(( int(int((wWidth2-8)*coefPixel2[0])+8+screenWidth+(wWidth2*(tmp2+1))-int(18.5*(tmp2+1))), int(wHeight2*coefPixel2[1]) ))
                elif(tmp == 2):
                    if(tmp2 == 0):
                        self.listCoord.append((screenWidth+(wWidth2*(tmp2+1))-23, wHeight2-37, wWidth2, wHeight2))
                        self.PIXEL_COORD.append(( int(int((wWidth2-8)*coefPixel2[0])+8+screenWidth+(wWidth2*(tmp2+1))-23), int(int(wHeight2*coefPixel2[1])+wHeight2-37) ))
                    else:
                        self.listCoord.append((screenWidth+(wWidth2*(tmp2+1))-int(18.5*(tmp2+1)), wHeight2-37, wWidth2, wHeight2))
                        self.PIXEL_COORD.append(( int(int((wWidth2-8)*coefPixel2[0])+8+screenWidth+(wWidth2*(tmp2+1))-int(18.5*(tmp2+1))), int(int(wHeight2*coefPixel2[1])+wHeight2-37) ))
                else:
                    if(tmp2 == 0):
                        self.listCoord.append((screenWidth+(wWidth2*tmp2)-8, wHeight2-37, wWidth2, wHeight2))
                        self.PIXEL_COORD.append(( int(int((wWidth2-8)*coefPixel2[0])+screenWidth+(wWidth2*tmp2)), int(int(wHeight2*coefPixel2[1])+wHeight2-37) ))
                    else:
                        self.listCoord.append((screenWidth+(wWidth2*tmp2)-(19*tmp2), wHeight2-37, wWidth2, wHeight2))
                        self.PIXEL_COORD.append(( int(int((wWidth2-8)*coefPixel2[0])+8+screenWidth+(wWidth2*tmp2)-(19*tmp2)), int(int(wHeight2*coefPixel2[1])+wHeight2-37) ))
                if(tmp >= 3): tmp = 0
                else: tmp = tmp+1
        
    def launch_repair_clients(self):
        #Launch or Repair clients
        """global background_music"""
        if self.LaunchRepair_Button.config('text')[-1] == 'Launch':
            """text = "Let's go!"
            tts = gTTS(text=text, lang='en', tld='com.au', slow=False)
            os.remove("tmp.mp3")
            tts.save("tmp.mp3")
            playsound('tmp.mp3', False)
            background_music.terminate()"""
            self.LaunchRepair_Button.config(text='Repair')
            self.NBR_ACCOUNT = int(self.numberClientsList.get())
            self.adapt_listCoord()
            for i in range(self.NBR_ACCOUNT):
                win32api.WinExec(self.PATH_WoW)
                hwnd = win32gui.FindWindow(None, "World of Warcraft")
                self.hwndACC.append(hwnd)
                win32gui.SetWindowText(hwnd, "WoW"+str(i+1))
                if(i == 0 and self.NBR_ACCOUNT == 5): win32gui.ShowWindow(hwnd, win32con.SW_MAXIMIZE)
                else: win32gui.MoveWindow(hwnd, self.listCoord[i][0], self.listCoord[i][1], self.listCoord[i][2], self.listCoord[i][3], True)
            for i in range(self.NBR_ACCOUNT): #Enter username/password
                self.send_client_txt(self.hwndACC[i], self.ACC_Info[i][0])
                win32api.PostMessage(self.hwndACC[i], win32con.WM_KEYDOWN, win32con.VK_TAB, 0)
                win32api.PostMessage(self.hwndACC[i], win32con.WM_KEYUP, win32con.VK_TAB, 0)
                self.send_client_txt(self.hwndACC[i], self.ACC_Info[i][1])
                win32api.PostMessage(self.hwndACC[i], win32con.WM_KEYDOWN, win32con.VK_RETURN, 0)
                win32api.PostMessage(self.hwndACC[i], win32con.WM_KEYUP, win32con.VK_RETURN, 0)
        else: #Repair
            for i in range(self.NBR_ACCOUNT):
                if(not win32gui.IsWindow(self.hwndACC[i])):
                    win32api.WinExec(self.PATH_WoW)
                    hwnd = win32gui.FindWindow(None, "World of Warcraft")
                    self.hwndACC[i] = hwnd
                    win32gui.SetWindowText(hwnd, "WoW"+str(i+1))
                    self.send_client_txt(self.hwndACC[i], self.ACC_Info[i][0])
                    win32api.PostMessage(self.hwndACC[i], win32con.WM_KEYDOWN, win32con.VK_TAB, 0)
                    win32api.PostMessage(self.hwndACC[i], win32con.WM_KEYUP, win32con.VK_TAB, 0)
                    self.send_client_txt(self.hwndACC[i], self.ACC_Info[i][1])
                    win32api.PostMessage(self.hwndACC[i], win32con.WM_KEYDOWN, win32con.VK_RETURN, 0)
                    win32api.PostMessage(self.hwndACC[i], win32con.WM_KEYUP, win32con.VK_RETURN, 0)
                if(i == 0 and self.NBR_ACCOUNT == 5): win32gui.ShowWindow(self.hwndACC[i], win32con.SW_MAXIMIZE)
                else: win32gui.MoveWindow(self.hwndACC[i], self.listCoord[i][0], self.listCoord[i][1], self.listCoord[i][2], self.listCoord[i][3], True)
        
    def toggleIA(self):
        #Activate or disable the use of I.A
        if self.IAOnOff_Label.config('text')[-1] == 'OFF':
            self.IAOnOff_Label.config(text='ON')
            self.IAOnOff_Label.config(foreground='green')
        else:
            self.IAOnOff_Label.config(text='OFF')
            self.IAOnOff_Label.config(foreground='red')
            
    def stopWhile(self):
        self.MOVEMENT_KEY = [win32con.VK_RIGHT, win32con.VK_UP, win32con.VK_DOWN, win32con.VK_LEFT]
        if(self.script_running):
            self.script_running = False
            self.ScriptOnOff_Label.config(text='OFF')
            self.ScriptOnOff_Label.config(foreground='red')
            for i in range(int(self.numberClientsList.get())):
                if(self.InMovement[i-1] > 0):
                    for y in range(len(self.MOVEMENT_KEY)):
                        win32api.PostMessage(self.hwndACC[i], win32con.WM_KEYUP, self.MOVEMENT_KEY[y], 0)
                    self.InMovement[i-1] = 0
            print("Stop")
        else:
            self.script_running = True
            self.ScriptOnOff_Label.config(text='ON')
            self.ScriptOnOff_Label.config(foreground='green')
            print("Running")
            
    def takeScreenshot(self):
        if(self.listCoord != []):
            playsound('assets/screenshot.mp3', False)
            img_rgb = ImageGrab.grab(bbox=None, include_layered_windows=False, all_screens=True)
            for i in range(self.NBR_ACCOUNT):
                img = img_rgb.crop((self.listCoord[i][0]+8, self.listCoord[i][1], self.listCoord[i][0]+self.listCoord[i][2]-8, self.listCoord[i][1]+self.listCoord[i][3]))
                img.save(self.PATH_Screenshot + '\\' + str(self.indexIMG+1) + '_' + str(i+1) + '.jpg')
            self.indexIMG = self.indexIMG + 1
        
    def run_script(self):
        while(self.script_running):
            if(self.PIXEL_COORD != []):
                img_rgb = np.array(ImageGrab.grab(bbox=None, include_layered_windows=False, all_screens=True))
                for i in range(self.NBR_ACCOUNT):
                    bluePixel = img_rgb[self.PIXEL_COORD[i][1], self.PIXEL_COORD[i][0], 2]
                    if(i > 0):
                        if(bluePixel == 0 and self.InMovement[i-1] > 0):
                            for y in range(len(self.MOVEMENT_KEY)):
                                win32api.PostMessage(self.hwndACC[i], win32con.WM_KEYUP, self.MOVEMENT_KEY[y], 0)
                            self.InMovement[i-1] = 0
                        elif(bluePixel == 3): #Turn on the Right
                            self.InMovement[i-1] = 1
                            win32api.PostMessage(self.hwndACC[i], win32con.WM_KEYDOWN, self.MOVEMENT_KEY[0], 0)
                        elif(bluePixel == 4): #Walk Forward
                            self.InMovement[i-1] = 2
                            win32api.PostMessage(self.hwndACC[i], win32con.WM_KEYDOWN, self.MOVEMENT_KEY[1], 0)
                        elif(bluePixel == 5): #Walk Backward
                            self.InMovement[i-1] = 3
                            win32api.PostMessage(self.hwndACC[i], win32con.WM_KEYDOWN, self.MOVEMENT_KEY[2], 0)
                        elif(bluePixel == 6): #Walk Backward briefly
                            win32api.PostMessage(self.hwndACC[i], win32con.WM_KEYDOWN, self.MOVEMENT_KEY[2], 0)
                            win32api.PostMessage(self.hwndACC[i], win32con.WM_KEYUP, self.MOVEMENT_KEY[2], 0)
                        elif(bluePixel == 7): #Strafe Left
                            self.InMovement[i-1] = 4
                            win32api.PostMessage(self.hwndACC[i], win32con.WM_KEYDOWN, self.MOVEMENT_KEY[3], 0)
                        elif(bluePixel == 8): #Jump !
                            win32api.PostMessage(self.hwndACC[i], win32con.WM_KEYDOWN, win32con.VK_SPACE, 0)
                            win32api.PostMessage(self.hwndACC[i], win32con.WM_KEYUP, win32con.VK_SPACE, 0)
                    win32api.PostMessage(self.hwndACC[i], win32con.WM_KEYDOWN, win32con.VK_NEXT, 0)
                    win32api.PostMessage(self.hwndACC[i], win32con.WM_KEYUP, win32con.VK_NEXT, 0)
                time.sleep(0.3)
        self.after(300, self.run_script)
    
"""def play_background():
    playsound('assets/music_theme.mp3', True)"""
        
    #Main :
if __name__== "__main__" :

    """text = "Error cringe detected!"
    tts = gTTS(text=text, lang='en', tld='com.au', slow=False)
    tts.save("tmp.mp3")
    background_music = multiprocessing.Process(name="playsound", target=play_background)
    background_music.daemon = True
    background_music.start()
    time.sleep(2)
    playsound('tmp.mp3', False)"""
    
    interface = Interface()
    
    mouse.on_middle_click(interface.stopWhile)

    listener = keyboard.Listener(on_press=interface.on_KeyPress)
    listener.start()

    interface.mainloop()