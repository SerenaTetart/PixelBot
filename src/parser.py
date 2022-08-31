import os

def init_config(file_path):
    if not os.path.isfile(file_path):
        with open(file_path, 'w') as file:
            file.write("PATH_WoW=\nPATH_Screenshot=\nACC_Infos=[")
            for i in range(25):
                file.write("('','')")
                if(i+1 < 25): file.write(", ")
            file.write("]")

def get_value(file_path, info, start):
    with open(file_path, 'r') as file:
        for line in file:
            if(line.find(info) >= 0):
                start_pos = line.find(start)
                if(start_pos >= 0):
                    end_pos = line.find('\n')
                    if(end_pos >= 0): tmp = line[start_pos+1:end_pos]
                    else: tmp = line[start_pos+1::]
                    if(tmp != "\n"): return tmp
    return ''
    
def get_multiplevalues(file_path, info, start, bet, end):
    tmpTab = []
    with open(file_path, 'r') as file:
        for line in file:
            if(line.find(info) >= 0 and line.find(start) >= 0 and line.find(end) >= 0):
                while(line.find(start) >= 0 and line.find(end) >= 0):
                    start_pos = line.find(start)
                    bet_pos = line.find(bet)
                    end_pos = line.find(end)
                    tmp = line[start_pos+2:bet_pos-1]
                    tmp2 = line[bet_pos+2:end_pos-1]
                    if(tmp2 != "\n"):
                        tmpTab.append((tmp,tmp2))
                    line = line[end_pos+2::]
                return tmpTab
    for i in range(25): tmpTab.append(('', ''))
    return tmpTab
    
def modify_config(file_path, path_wow='', path_screen='', acc_info=''):
    if(path_wow == ''): path_wow = get_value('config.conf', 'PATH_WoW', '=')
    if(path_screen == ''): path_screen = get_value('config.conf', 'PATH_Screenshot', '=')
    if(acc_info == ''): acc_info = get_multiplevalues('config.conf', 'ACC_Infos', '(', ',', ')')
    with open(file_path, 'w') as file:
        file.write("PATH_WoW="+path_wow+"\nPATH_Screenshot="+path_screen+"\nACC_Infos=[")
        for i in range(len(acc_info)):
            file.write("('"+acc_info[i][0]+"','"+acc_info[i][1]+"')")
            if(i+1 < len(acc_info)): file.write(", ")
        file.write("]")