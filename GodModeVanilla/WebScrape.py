import requests
import os


def getValue(v_name, indice1, indice2):
    if(indice2 == -1):
        ind12 = page_info.find('});', indice1)
        ind1 = page_info.find(v_name, indice1, ind12)
    else:
        ind1 = page_info.find(v_name, indice1, indice2)
    if(ind1 != -1):
        ind12 = page_info.find('}', ind1, ind1+len(v_name)+7)
        if(ind12 == -1):
            ind12 = page_info.find(',', ind1, ind1+len(v_name)+7)
        return int(page_info[ind1+len(v_name)+2:ind12])
    else:
        return 0
        

dir_path = os.path.dirname(os.path.realpath(__file__))
file = open(dir_path+'\Database.lua', 'w')
file.write("item_stat = {")
nbrItems = 0
itemIDtab = []

url = ['armor?filter=123;1;0', 'armor?filter=123:50;3:1;0:0', 'armor?filter=123:50:49;3:3:1;0:0:0', 'armor?filter=123:50:49:61;3:3:3:1;0:0:0:0'
, 'armor?filter=24:24;4:1;8:0', 'armor?filter=24;1;8', 'armor?filter=24:23;3:1;0:0', 'armor?filter=24:23:21;3:3:1;0:0:0'
, 'armor?filter=24:23:21:20;3:3:3:1;0:0:0:0', 'armor?filter=24:23:21:20:22;3:3:3:3:1;0:0:0:0:0', 'weapons?filter=123;1;0', 'weapons?filter=123:50;3:1;0:0'
, 'weapons?filter=123:50:49;3:3:1;0:0:0', 'weapons?filter=123:50:49:61;3:3:3:1;0:0:0:0', 'weapons?filter=24:24;4:1;8:0', 'weapons?filter=24;1;8'
, 'weapons?filter=24:23;3:1;0:0', 'weapons?filter=24:23:21;3:3:1;0:0:0', 'weapons?filter=24:23:21:20;3:3:3:1;0:0:0:0', 'weapons?filter=24:23:21:20:22;3:3:3:3:1;0:0:0:0:0']
for i in range(0, len(url)):
    response = requests.get(('https://classic.wowhead.com/items/'+url[i]), timeout=5)
    if(response):
        page_info = str(response.content)
        indice = page_info.find('":{"name_enus"')
        while(indice != -1):
            tmp = indice
            ind = page_info[tmp-10:tmp].find('"')
            item_id = page_info[tmp-9+ind:tmp]
            indice = page_info.find('":{"name_enus"', tmp+1)
            okbool = True
            for y in itemIDtab:
                if(y == item_id):
                    okbool = False
            if(okbool):
                nbrItems += 1
                itemIDtab.append(item_id)
                it_sp = getValue('"splpwr', tmp, indice)
                it_spH = it_sp + getValue('"splheal', tmp, indice)
                it_spCrit = getValue('"splcritstrkpct', tmp, indice)
                it_mp5 = getValue('"manargn', tmp, indice)
                it_int = getValue('"int', tmp, indice)
                it_spi = getValue('"spi', tmp, indice)
                it_agi = getValue('"agi', tmp, indice)
                it_str = getValue('"str', tmp, indice)
                it_sta = getValue('"sta', tmp, indice)
                if(nbrItems%2 == 0):
                    file.write("\n     ")
                if((i == len(url)-1) and (indice == -1)):
                    file.write("[" + str(item_id) + "]={['stamina']=" + str(it_sta) + ",['strength']=" + str(it_str) + ",['agi']=" + str(it_agi) + ",['intel']=" + str(it_int) + ",['spirit']=" + str(it_spi) + ",['hsp']=" + str(it_spH) + ",['mp5']=" + str(it_mp5) + ", ['spCrit']=" + str(it_spCrit) + "}")
                else:
                    file.write("[" + str(item_id) + "]={['stamina']=" + str(it_sta) + ",['strength']=" + str(it_str) + ",['agi']=" + str(it_agi) + ",['intel']=" + str(it_int) + ",['spirit']=" + str(it_spi) + ",['hsp']=" + str(it_spH) + ",['mp5']=" + str(it_mp5) + ", ['spCrit']=" + str(it_spCrit) + "},")
                print("ID:", item_id, "| Stamina:", it_sta, "| Strength:", it_str, "| Agi:", it_agi, "| Intel:", it_int, "| Spirit:", it_spi, "| Heal SP:", it_spH, "| Spell Crit:", it_spCrit, "| MP5:", it_mp5)

print("Nombre d'items scannés:", nbrItems)
file.write(" }")
file.close()