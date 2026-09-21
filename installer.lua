-- GameHub 128 Installer
-- Self-contained installer: installs the OS and flashes its EEPROM boot loader.
local component=require("component")
local computer=require("computer")
local gpu=component.gpu
local screen=component.screen
if not gpu or not screen then error("GameHub 128 installer requires a GPU and screen.") end
local maxW,maxH=gpu.maxResolution()
if maxW<50 or maxH<16 then error("GameHub 128 installer requires a GPU/screen that supports at least 50x16.") end
gpu.bind(screen.address);pcall(gpu.setDepth,8)
local W,H=gpu.getResolution()

local OS_CODE=[==[
-- GameHub 128 OS
-- Cursor-driven OpenComputers desktop for tier-2/3 touch screens.

local gpu = component.gpu
local screen = component.screen
if not gpu or not screen then error("GameHub 128 requires a GPU and screen.") end
local maxW,maxH=gpu.maxResolution()
if maxW<80 or maxH<25 then error("GameHub 128 requires a tier-2 or tier-3 graphics setup for cursor input.") end

gpu.bind(screen.address)
pcall(gpu.setDepth, 8)

local BOOT = rawget(_G, "GH_BOOT_ADDRESS")
local function findBoot()
  if BOOT and component.proxy(BOOT) then return component.proxy(BOOT) end
  for address in component.list("filesystem") do
    local fs = component.proxy(address)
    if not fs.isReadOnly() and fs.exists("/init.lua") then
      BOOT = address
      return fs
    end
  end
  for address in component.list("filesystem") do
    local fs = component.proxy(address)
    if fs.exists("/init.lua") then BOOT = address return fs end
  end
  error("GameHub 128 cannot find its system disk.")
end
local disk = findBoot()

local supported = {
  {50,16},{80,25},{160,50},{190,60}
}
local W,H = gpu.getResolution()
local function applyResolution(w,h)
  local ok = pcall(gpu.setResolution,w,h)
  if ok then W,H = gpu.getResolution() return true end
  return false
end

local lang = "English"
local cfgPath = "/GameHub128.cfg"
local function readConfig()
  local h = disk.open(cfgPath,"r")
  if not h then return end
  local s = ""
  while true do
    local b = disk.read(h,4096)
    if not b then break end
    s=s..b
  end
  disk.close(h)
  local l = s:match("language=([^\n]+)")
  local r = s:match("resolution=(%d+)x(%d+)")
  local valid = {English=true,German=true,Russian=true,Ukrainian=true,Polish=true,Spanish=true,LOLCAT=true,Italian=true}
  if valid[l] then lang=l end
  if r then
    local a,b=tonumber(r:match("^(%d+)")),tonumber(r:match("x(%d+)$"))
    if a and b then applyResolution(a,b) end
  end
end
local function writeConfig()
  local h,e=disk.open(cfgPath,"w")
  if not h then return false,e end
  disk.write(h,"language="..lang.."\nresolution="..W.."x"..H.."\n")
  disk.close(h)
  return true
end
readConfig()

local T={
  English={
    start="Start",shutdown="Shutdown",reboot="Reboot",settings="Settings",about="About",
    language="Language",disk="System Disk",rename="Rename Disk",resolution="Resolution",
    close="Close",save="Save",cancel="Cancel",typeName="Type a new disk name:",
    system="GameHub 128",version="Version 1.0",subtitle="An OpenComputers desktop OS",
    chooseLang="Choose Language",available="Available resolutions",saved="Saved.",
    renamed="Disk renamed.",invalid="Invalid name.",rebooting="Rebooting...",shutting="Shutting down...",
    confirm="Are you sure?",yes="Yes",no="No",ready="Ready",change="Change",back="Back"
  },
  German={
    start="Start",shutdown="Herunterfahren",reboot="Neustart",settings="Einstellungen",about="Uber",
    language="Sprache",disk="Systemdatentrager",rename="Datentrager umbenennen",resolution="Auflosung",
    close="Schliessen",save="Speichern",cancel="Abbrechen",typeName="Neuen Datentragernamen eingeben:",
    system="GameHub 128",version="Version 1.0",subtitle="Ein OpenComputers-Betriebssystem",
    chooseLang="Sprache wahlen",available="Verfugbare Auflosungen",saved="Gespeichert.",
    renamed="Datentrager umbenannt.",invalid="Ungultiger Name.",rebooting="Neustart...",shutting="Wird heruntergefahren...",
    confirm="Bist du sicher?",yes="Ja",no="Nein",ready="Bereit",change="Andern",back="Zuruck"
  },
  Russian={
    start="Пуск",shutdown="Выключение",reboot="Перезагрузка",settings="Настройки",about="О системе",
    language="Язык",disk="Системный диск",rename="Переименовать диск",resolution="Разрешение",
    close="Закрыть",save="Сохранить",cancel="Отмена",typeName="Введите новое имя диска:",
    system="GameHub 128",version="Версия 1.0",subtitle="ОС для OpenComputers",
    chooseLang="Выберите язык",available="Доступные разрешения",saved="Сохранено.",
    renamed="Диск переименован.",invalid="Недопустимое имя.",rebooting="Перезагрузка...",shutting="Выключение...",
    confirm="Вы уверены?",yes="Да",no="Нет",ready="Готово",change="Изменить",back="Назад"
  },
  Ukrainian={
    start="Пуск",shutdown="Вимкнути",reboot="Перезавантажити",settings="Налаштування",about="Про систему",
    language="Мова",disk="Системний диск",rename="Перейменувати диск",resolution="Роздільна здатність",
    close="Закрити",save="Зберегти",cancel="Скасувати",typeName="Введіть нову назву диска:",
    system="GameHub 128",version="Версія 1.0",subtitle="ОС для OpenComputers",
    chooseLang="Виберіть мову",available="Доступні роздільні здатності",saved="Збережено.",
    renamed="Диск перейменовано.",invalid="Неприпустима назва.",rebooting="Перезавантаження...",shutting="Вимкнення...",
    confirm="Ви впевнені?",yes="Так",no="Ні",ready="Готово",change="Змінити",back="Назад"
  },
  Polish={
    start="Start",shutdown="Wylacz",reboot="Uruchom ponownie",settings="Ustawienia",about="O systemie",
    language="Jezyk",disk="Dysk systemowy",rename="Zmien nazwe dysku",resolution="Rozdzielczosc",
    close="Zamknij",save="Zapisz",cancel="Anuluj",typeName="Wpisz nowa nazwe dysku:",
    system="GameHub 128",version="Wersja 1.0",subtitle="System operacyjny OpenComputers",
    chooseLang="Wybierz jezyk",available="Dostepne rozdzielczosci",saved="Zapisano.",
    renamed="Zmieniono nazwe dysku.",invalid="Nieprawidlowa nazwa.",rebooting="Ponowne uruchamianie...",shutting="Wylaczanie...",
    confirm="Na pewno?",yes="Tak",no="Nie",ready="Gotowe",change="Zmien",back="Wstecz"
  },
  Spanish={
    start="Inicio",shutdown="Apagar",reboot="Reiniciar",settings="Ajustes",about="Acerca de",
    language="Idioma",disk="Disco del sistema",rename="Renombrar disco",resolution="Resolucion",
    close="Cerrar",save="Guardar",cancel="Cancelar",typeName="Escribe un nuevo nombre de disco:",
    system="GameHub 128",version="Version 1.0",subtitle="Un sistema operativo para OpenComputers",
    chooseLang="Elegir idioma",available="Resoluciones disponibles",saved="Guardado.",
    renamed="Disco renombrado.",invalid="Nombre no valido.",rebooting="Reiniciando...",shutting="Apagando...",
    confirm="Estas seguro?",yes="Si",no="No",ready="Listo",change="Cambiar",back="Atras"
  },
  LOLCAT={
    start="STRT",shutdown="shutdwn",reboot="reboOt",settings="setup",about="abt me",
    language="lang",disk="sys disk",rename="rename disk",resolution="res",
    close="closez",save="sAve",cancel="nope",typeName="gib new disk name:",
    system="GameHub 128",version="v1.0",subtitle="ur OpenComputers OS lol",
    chooseLang="pick ur lang",available="res u can haz",saved="sAveD!",
    renamed="disk namez changed!",invalid="bad name, kitteh.",rebooting="reboOt nao...",shutting="shutdwn nao...",
    confirm="u sure bout dis?",yes="YA",no="NAW",ready="readyz",change="chAnge",back="go bak"
  },
  Italian={
    start="Avvio",shutdown="Spegni",reboot="Riavvia",settings="Impostazioni",about="Informazioni",
    language="Lingua",disk="Disco di sistema",rename="Rinomina disco",resolution="Risoluzione",
    close="Chiudi",save="Salva",cancel="Annulla",typeName="Inserisci un nuovo nome del disco:",
    system="GameHub 128",version="Versione 1.0",subtitle="Un sistema operativo per OpenComputers",
    chooseLang="Scegli lingua",available="Risoluzioni disponibili",saved="Salvato.",
    renamed="Disco rinominato.",invalid="Nome non valido.",rebooting="Riavvio...",shutting="Spegnimento...",
    confirm="Sei sicuro?",yes="Si",no="No",ready="Pronto",change="Cambia",back="Indietro"
  }
}
local languageNames={"English","German","Russian","Ukrainian","Polish","Spanish","LOLCAT","Italian"}
local function t(k) return T[lang][k] or k end

local mx,my=math.floor(W/2),math.floor(H/2)
local startOpen,settingsOpen,aboutOpen=false,false,false
local confirmAction=nil
local renameMode=false
local renameText=""
local status=""

local function clampCursor(x,y)
  mx=math.max(1,math.min(W,x or mx)); my=math.max(1,math.min(H-3,y or my))
end
local function fill(bg,x,y,w,h)
  gpu.setBackground(bg);gpu.fill(x,y,w,h," ")
end
local function txt(x,y,s,fg,bg)
  if y<1 or y>H then return end
  gpu.setForeground(fg);gpu.setBackground(bg);gpu.set(x,y,tostring(s))
end
local function center(y,s,fg,bg)
  txt(math.floor((W-#tostring(s))/2)+1,y,s,fg,bg)
end
local function box(x,y,w,h,fg,bg)
  gpu.setBackground(bg);gpu.setForeground(fg);gpu.fill(x,y,w,h," ")
  if w>2 and h>2 then gpu.setBackground(fg);gpu.fill(x,y,w,1," ");gpu.fill(x,y+h-1,w,1," ");gpu.fill(x,y,1,h," ");gpu.fill(x+w-1,y,1,h," ") end
end
local function hit(x,y,w,h)
  return mx>=x and mx<x+w and my>=y and my<y+h
end
local function button(x,y,w,h,label,active)
  local bg=active and 0x3478F6 or 0x273141
  local fg=active and 0xFFFFFF or 0xE8ECF4
  gpu.setBackground(bg);gpu.fill(x,y,w,h," ")
  txt(x+math.floor((w-#label)/2),y+math.floor(h/2),label,fg,bg)
end
local function dock()
  local dw=28;local dh=3;local dx=math.floor((W-dw)/2)+1;local dy=H-dh+1
  box(dx,dy,dw,dh,0xAAB3C2,0x1B2230)
  button(dx+2,dy+1,5,1,"[G]",hit(dx+2,dy+1,5,1))
  button(dx+9,dy+1,5,1,"[S]",hit(dx+9,dy+1,5,1))
  button(dx+16,dy+1,5,1,"[?]",hit(dx+16,dy+1,5,1))
  txt(dx+22,dy+1,"GH128",0xFFFFFF,0x1B2230)
end

local function drawCursor()
  if my>=H-2 then return end
  txt(mx,my,">",0xFFFFFF,0x111827)
end

local function desktop()
  fill(0x101827,1,1,W,H)
  for y=2,H-4,3 do fill(0x121C2E,1,y,W,1) end
  center(4,t("system"),0x8AB4FF,0x101827)
  center(6,"128",0x536B90,0x101827)
  dock();drawCursor()
end

local function startGeom()
  local w=math.min(30,W-4);local h=math.min(16,H-3);local x=2;local y=math.max(1,H-h-3)
  return x,y,w,h
end
local function startMenu()
  local x,y,w,h=startGeom()
  box(x,y,w,h,0xD9E0EA,0x172131)
  txt(x+2,y+2,t("system"),0x1A2433,0xD9E0EA)
  local items={t("shutdown"),t("reboot"),t("settings"),t("about")}
  for i,v in ipairs(items) do
    button(x+2,y+4+(i-1)*2,w-4,1,v,hit(x+2,y+4+(i-1)*2,w-4,1))
  end
  drawCursor()
end

local languageOpen=false
local function settingsWindow()
  local w=math.min(64,W-4);local h=math.min(16,H-4);local x=math.floor((W-w)/2)+1;local y=math.floor((H-h)/2)+1
  box(x,y,w,h,0xE9EDF3,0x172131)
  txt(x+2,y+1,t("settings"),0x152033,0xE9EDF3)
  txt(x+2,y+3,t("language")..": "..lang,0x526176,0xE9EDF3)
  button(x+2,y+4,20,1,t("change"),hit(x+2,y+4,20,1))
  txt(x+2,y+6,t("disk")..": "..(disk.getLabel() or "(unnamed)"),0x526176,0xE9EDF3)
  button(x+2,y+7,24,1,t("rename"),hit(x+2,y+7,24,1))
  txt(x+2,y+9,t("resolution"),0x526176,0xE9EDF3)
  local rwid=math.min(14,math.floor((w-8)/4));local gap=1;local bx=x+2
  for _,r in ipairs(supported) do
    local rw,rh=r[1],r[2];local mw,mh=gpu.maxResolution()
    if rw<=mw and rh<=mh then
      local on=(W==rw and H==rh);button(bx,y+10,rwid,1,rw.."x"..rh,on);bx=bx+rwid+gap
    end
  end
  button(x+w-10,y+h-2,8,1,t("close"),hit(x+w-10,y+h-2,8,1))
  if status~="" then txt(x+2,y+h-3,status,0x3478F6,0xE9EDF3) end
  if renameMode then
    box(x+5,y+2,w-10,7,0xEAF0F8,0x3478F6)
    center(y+3,t("typeName"),0x152033,0xEAF0F8)
    txt(x+8,y+5,renameText,0x152033,0xEAF0F8)
    button(x+math.floor(w/2)-5,y+7,10,1,t("save"),hit(x+math.floor(w/2)-5,y+7,10,1))
  end
  if languageOpen then
    box(x+3,y+2,w-6,h-4,0xEAF0F8,0x3478F6)
    center(y+3,t("chooseLang"),0x152033,0xEAF0F8)
    local cols=2;local bw=math.floor((w-10)/cols);local yy=y+5
    for i,name in ipairs(languageNames) do
      local col=(i-1)%cols;local row=math.floor((i-1)/cols)
      button(x+5+col*(bw+2),yy+row*2,bw,1,name,lang==name)
    end
    button(x+w-12,y+h-3,8,1,t("back"),hit(x+w-12,y+h-3,8,1))
  end
  drawCursor()
end

local function aboutWindow()
  local w=48;local h=12;local x=math.floor((W-w)/2)+1;local y=math.floor((H-h)/2)+1
  box(x,y,w,h,0xE9EDF3,0x172131)
  center(y+2,t("system"),0x3478F6,0xE9EDF3)
  center(y+4,t("version"),0x152033,0xE9EDF3)
  center(y+6,t("subtitle"),0x526176,0xE9EDF3)
  center(y+8,"OpenComputers / Lua",0x526176,0xE9EDF3)
  button(x+20,y+h-2,8,1,t("close"),hit(x+20,y+h-2,8,1))
  drawCursor()
end

local function confirmWindow()
  local w=38;local h=7;local x=math.floor((W-w)/2)+1;local y=math.floor((H-h)/2)+1
  box(x,y,w,h,0xE9EDF3,0x172131);center(y+2,t("confirm"),0x152033,0xE9EDF3)
  button(x+8,y+4,8,1,t("yes"),hit(x+8,y+4,8,1));button(x+22,y+4,8,1,t("no"),hit(x+22,y+4,8,1));drawCursor()
end

local function redraw()
  desktop()
  if startOpen then startMenu()
  elseif settingsOpen then settingsWindow()
  elseif aboutOpen then aboutWindow() end
  if confirmAction then confirmWindow() end
end

local function clickAction(x,y)
  mx,my=x,y
  local dw=28;local dx=math.floor((W-dw)/2)+1;local dy=H-2
  if not startOpen and not settingsOpen and not aboutOpen and hit(dx+2,dy,5,1) then startOpen=true;redraw();return end
  if not startOpen and not settingsOpen and not aboutOpen and hit(dx+9,dy,5,1) then settingsOpen=true;redraw();return end
  if not startOpen and not settingsOpen and not aboutOpen and hit(dx+16,dy,5,1) then aboutOpen=true;redraw();return end

  if confirmAction then
    local w=38;local x0=math.floor((W-w)/2)+1;local y0=math.floor((H-7)/2)+1
    if hit(x0+8,y0+4,8,1) then
      local a=confirmAction;confirmAction=nil;redraw()
      if a=="reboot" then computer.shutdown(true) else computer.shutdown(false) end
    elseif hit(x0+22,y0+4,8,1) then confirmAction=nil;redraw() end
    return
  end

  if startOpen then
    local x0,y0,w,h=startGeom()
    if hit(x0+2,y0+4,w-4,1) then confirmAction="shutdown";redraw()
    elseif hit(x0+2,y0+6,w-4,1) then confirmAction="reboot";redraw()
    elseif hit(x0+2,y0+8,w-4,1) then startOpen=false;settingsOpen=true;redraw()
    elseif hit(x0+2,y0+10,w-4,1) then startOpen=false;aboutOpen=true;redraw() end
    return
  end

  if settingsOpen then
    local w=math.min(64,W-4);local h=math.min(16,H-4);local x0=math.floor((W-w)/2)+1;local y0=math.floor((H-h)/2)+1
    if renameMode then
      local rx=x0+math.floor(w/2)-5
      if hit(rx,y0+7,10,1) then
        local name=renameText:gsub("[%c\n\r]",""):sub(1,24)
        if #name>0 then local ok,e=pcall(disk.setLabel,name);status=ok and t("renamed") or tostring(e);renameMode=false end
        redraw();return
      end
      return
    end
    if languageOpen then
      local cols=2;local bw=math.floor((w-10)/cols);local yy=y0+5
      for i,name in ipairs(languageNames) do
        local col=(i-1)%cols;local row=math.floor((i-1)/cols)
        if hit(x0+5+col*(bw+2),yy+row*2,bw,1) then lang=name;languageOpen=false;writeConfig();status=t("saved");redraw();return end
      end
      if hit(x0+w-12,y0+h-3,8,1) then languageOpen=false;redraw();return end
      return
    end
    if hit(x0+2,y0+4,20,1) then languageOpen=true;redraw();return end
    if hit(x0+2,y0+7,24,1) then renameMode=true;renameText=disk.getLabel() or "";redraw();return end
    local rwid=math.min(14,math.floor((w-8)/4));local gap=1;local bx=x0+2
    for _,r in ipairs(supported) do
      local rw,rh=r[1],r[2];local mw,mh=gpu.maxResolution()
      if rw<=mw and rh<=mh then
        if hit(bx,y0+10,rwid,1) then applyResolution(rw,rh);writeConfig();status=rw.."x"..rh;mx,my=math.floor(W/2),math.floor(H/2);redraw();return end
        bx=bx+rwid+gap
      end
    end
    if hit(x0+w-10,y0+h-2,8,1) then settingsOpen=false;status="";redraw();return end
  end

  if aboutOpen then
    local w=48;local x0=math.floor((W-w)/2)+1;local y0=math.floor((H-12)/2)+1
    if hit(x0+20,y0+10,8,1) then aboutOpen=false;redraw() end
  end
end

redraw()
while true do
  local e,a,b,c,d=computer.pullSignal()
  if e=="touch" or e=="drag" then
    clampCursor(b,c)
    if e=="touch" then clickAction(b,c) else redraw() end
  elseif e=="scroll" then
    clampCursor(b,c);redraw()
  elseif e=="key_down" and renameMode then
    local char,code=c,d
    if code==0x1C then renameMode=false;redraw()
    elseif code==0x0E then renameText=renameText:sub(1,-2);redraw()
    elseif char and char>0 and #renameText<24 then renameText=renameText..string.char(char);redraw() end
  end
end

]==]
local BOOT_CODE=[==[
-- GameHub 128 EEPROM boot code template.
-- The installer replaces __DISK_ADDRESS__ with the selected filesystem address.
local component = component
local address = "__DISK_ADDRESS__"
local function boot(a)
  local h, reason = component.invoke(a, "open", "/init.lua", "r")
  if not h then error(reason or "GameHub 128: cannot open /init.lua") end
  local data = ""
  while true do
    local chunk, err = component.invoke(a, "read", h, 4096)
    if not chunk then
      if err then component.invoke(a, "close", h); error(err) end
      break
    end
    data = data .. chunk
  end
  component.invoke(a, "close", h)
  GH_BOOT_ADDRESS = a
  local fn, err = load(data, "=GameHub128")
  if not fn then error(err) end
  return fn()
end
return boot(address)

]==]
local function tr(a,b)
  if type(a)=="table" then return a[lang] or a.English end
  return lang=="English" and a or b
end
local languageNames={"English","German","Russian","Ukrainian","Polish","Spanish","LOLCAT","Italian"}

-- Installer state. These must be initialized before the first draw().
local page=1
local lang="English"
local diskAddress=nil
local installStep=0
local okEEPROM=false
local errorText=""
local countdown=5
local cursorX=math.floor(W/2)
local cursorY=math.floor(H/2)

local function clear(bg) gpu.setBackground(bg);gpu.fill(1,1,W,H," ") end
local function text(x,y,s,fg,bg) gpu.setForeground(fg);gpu.setBackground(bg);gpu.set(x,y,tostring(s)) end
local function center(y,s,fg,bg) text(math.floor((W-#tostring(s))/2)+1,y,s,fg,bg) end
local function box(x,y,w,h,bg,edge)
  gpu.setBackground(edge);gpu.fill(x,y,w,h," ")
  if w>2 and h>2 then gpu.setBackground(bg);gpu.fill(x+1,y+1,w-2,h-2," ") else gpu.setBackground(bg);gpu.fill(x,y,w,h," ") end
end
local function btn(x,y,w,s,active)
  local bg=active and 0x3478F6 or 0x273141
  gpu.setBackground(bg);gpu.fill(x,y,w,1," ")
  text(x+math.floor((w-#s)/2),y,s,0xFFFFFF,bg)
end
local function hit(x,y,w,h) return cursorX>=x and cursorX<x+w and cursorY>=y and cursorY<y+h end
local function base(title,sub)
  clear(0x101827);center(3,"GameHub 128",0x8AB4FF,0x101827);center(5,title,0xFFFFFF,0x101827);center(6,sub,0x94A3B8,0x101827)
end
local function draw()
  if page==1 then
    base("Installer","OpenComputers operating system installer")
    center(9,"Welcome to GameHub 128!",0xFFFFFF,0x101827)
    btn(W/2-10,H-4,20,tr({English="Continue",German="Weiter",Russian="Далее",Ukrainian="Продовжити",Polish="Dalej",Spanish="Continuar",LOLCAT="gooo",Italian="Continua"}),hit(W/2-10,H-4,20,1))
  elseif page==2 then
    local title=tr({English="Choose Language",German="Sprache wahlen",Russian="Выберите язык",Ukrainian="Виберіть мову",Polish="Wybierz jezyk",Spanish="Elegir idioma",LOLCAT="pick ur lang",Italian="Scegli lingua"})
    local sub=tr({English="Choose a language for the installed system",German="Wahlen Sie die Sprache fur das installierte System",Russian="Выберите язык устанавливаемой системы",Ukrainian="Виберіть мову для встановленої системи",Polish="Wybierz jezyk instalowanego systemu",Spanish="Elige el idioma del sistema instalado",LOLCAT="pick lang 4 da shiny sys",Italian="Scegli la lingua del sistema"})
    base(title,sub)
    local bw=18;local gap=2;local start=math.floor((W-(bw*4+gap*3))/2)+1
    for i,name in ipairs(languageNames) do
      local col=(i-1)%4;local row=math.floor((i-1)/4)
      btn(start+col*(bw+gap),10+row*2,bw,name,lang==name)
    end
    btn(W/2-10,H-4,20,tr({English="Continue",German="Weiter",Russian="Далее",Ukrainian="Продовжити",Polish="Dalej",Spanish="Continuar",LOLCAT="gooo",Italian="Continua"}),hit(W/2-10,H-4,20,1))
  elseif page==3 then
    base(tr({English="Choose installation disk",German="Installationsdisk wahlen",Russian="Выберите диск для установки",Ukrainian="Виберіть диск для встановлення",Polish="Wybierz dysk instalacyjny",Spanish="Elegir disco de instalacion",LOLCAT="pick da install disk",Italian="Scegli disco di installazione"}),tr({English="Select a writable filesystem",German="Schreibbares Dateisystem auswahlen",Russian="Выберите доступную для записи файловую систему",Ukrainian="Оберіть доступну для запису файлову систему",Polish="Wybierz zapisywalny system plikow",Spanish="Selecciona un sistema de archivos escribible",LOLCAT="pick writable disk",Italian="Scegli un filesystem scrivibile"}))
    local y=9
    for address in component.list("filesystem") do
      local fs=component.proxy(address)
      if not fs.isReadOnly() then
        local label=fs.getLabel() or "(unnamed)"
        local s="[ ] "..label.."  "..address:sub(1,8)
        if #s>W-8 then s=s:sub(1,W-8) end
        btn(4,y,W-8,s,diskAddress==address)
        y=y+2
      end
    end
    if not diskAddress then center(math.min(H-6,y+1),tr({English="Click a disk above.",German="Klicke oben auf einen Datentrager.",Russian="Нажмите на диск выше.",Ukrainian="Натисніть на диск вище.",Polish="Kliknij dysk powyzej.",Spanish="Haz clic en un disco arriba.",LOLCAT="click disk up thar",Italian="Fai clic su un disco sopra."}),0xF0B35A,0x101827) end
    btn(4,H-4,14,tr({English="Back",German="Zuruck",Russian="Назад",Ukrainian="Назад",Polish="Wstecz",Spanish="Atras",LOLCAT="bak",Italian="Indietro"}),hit(4,H-4,14,1))
    btn(W-24,H-4,18,tr({English="Install",German="Installieren",Russian="Установить",Ukrainian="Встановити",Polish="Zainstaluj",Spanish="Instalar",LOLCAT="installz",Italian="Installa"}),hit(W-24,H-4,18,1))
  elseif page==4 then
    base(tr({English="Installing GameHub 128",German="GameHub 128 wird installiert",Russian="Установка GameHub 128",Ukrainian="Встановлення GameHub 128",Polish="Instalowanie GameHub 128",Spanish="Instalando GameHub 128",LOLCAT="installin GameHub 128",Italian="Installazione di GameHub 128"}),tr({English="Please do not power off the computer.",German="Bitte den Computer nicht ausschalten.",Russian="Не выключайте компьютер.",Ukrainian="Не вимикайте комп'ютер.",Polish="Nie wylaczaj komputera.",Spanish="No apagues el ordenador.",LOLCAT="plz dont bonk da power",Italian="Non spegnere il computer."}))
    local steps={
      {"Preparing disk","Підготовка диска"},
      {"Writing system","Запис системи"},
      {"Writing configuration","Запис конфігурації"}
    }
    for i,s in ipairs(steps) do
      text(4,8+(i-1)*2,s[1].." / "..s[2],installStep>=i and 0x7EE787 or 0x94A3B8,0x101827)
      gpu.setBackground(installStep>=i and 0x3478F6 or 0x273141);gpu.fill(4,9+(i-1)*2,W-8,1," ")
    end
    center(H-3,tr({English="Installing...",German="Installation...",Russian="Установка...",Ukrainian="Встановлення...",Polish="Instalowanie...",Spanish="Instalando...",LOLCAT="installin...",Italian="Installazione..."}),0xFFFFFF,0x101827)
  elseif page==5 then
    base(tr({English="EEPROM flashing",German="EEPROM wird geflasht",Russian="Прошивка EEPROM",Ukrainian="Прошивання EEPROM",Polish="Flashowanie EEPROM",Spanish="Flasheando EEPROM",LOLCAT="flashin da EEPROM",Italian="Flash EEPROM"}),tr({English="Installing the GameHub 128 boot loader",German="GameHub 128 Bootloader wird installiert",Russian="Установка загрузчика GameHub 128",Ukrainian="Встановлення завантажувача GameHub 128",Polish="Instalowanie bootloadera GameHub 128",Spanish="Instalando el cargador de GameHub 128",LOLCAT="puttin boot stuff in",Italian="Installazione del bootloader GameHub 128"}))
    center(9,okEEPROM and tr({English="EEPROM flashed successfully.",German="EEPROM erfolgreich geflasht.",Russian="EEPROM успешно прошита.",Ukrainian="EEPROM успішно прошито.",Polish="EEPROM zostalo pomyslnie sflashowane.",Spanish="EEPROM flasheada correctamente.",LOLCAT="EEPROM flashd gud!",Italian="EEPROM flashato correttamente."}) or tr({English="Flashing EEPROM...",German="EEPROM wird geflasht...",Russian="Прошивка EEPROM...",Ukrainian="Прошивання EEPROM...",Polish="Flashowanie EEPROM...",Spanish="Flasheando EEPROM...",LOLCAT="flashin EEPROM...",Italian="Flash EEPROM..."}),okEEPROM and 0x7EE787 or 0xFFFFFF,0x101827)
    if errorText~="" then center(11,errorText,0xFF7777,0x101827) end
    if okEEPROM then btn(W/2-10,H-4,20,tr({English="Continue",German="Weiter",Russian="Далее",Ukrainian="Продовжити",Polish="Dalej",Spanish="Continuar",LOLCAT="gooo",Italian="Continua"}),hit(W/2-10,H-4,20,1)) end
  else
    base(tr({English="Ready",German="Bereit",Russian="Готово",Ukrainian="Готово",Polish="Gotowe",Spanish="Listo",LOLCAT="readyz",Italian="Pronto"}),"")
    center(10,tostring(countdown),0xFFFFFF,0x101827)
    center(12,tr({English="5 Seconds remaining until reboot",German="Noch 5 Sekunden bis zum Neustart",Russian="До перезагрузки осталось 5 секунд",Ukrainian="Залишилося 5 секунд до перезавантаження",Polish="5 sekund do ponownego uruchomienia",Spanish="5 segundos hasta reiniciar",LOLCAT="5 secz til reboOt",Italian="5 secondi al riavvio"}),0x8AB4FF,0x101827)
  end
  if cursorY<H-2 then text(cursorX,cursorY,">",0xFFFFFF,0x101827) end
end

local function writeFile(fs,path,data)
  local h,e=fs.open(path,"w");if not h then return false,e end
  local ok,e2=pcall(function()
    local i=1
    while i<=#data do
      local n=math.min(4096,#data-i+1)
      assert(fs.write(h,data:sub(i,i+n-1)))
      i=i+n
    end
  end)
  fs.close(h);return ok,e2
end
local function installOS()
  local fs=component.proxy(diskAddress)
  if fs.isReadOnly() then return false,"Disk is read-only." end
  installStep=1;draw();computer.pullSignal(0.35)
  local ok,e=writeFile(fs,"/init.lua",OS_CODE);if not ok then return false,e end
  installStep=2;draw();computer.pullSignal(0.35)
  local h,e2=fs.open("/GameHub128.cfg","w");if not h then return false,e2 end
  fs.write(h,"language="..lang.."\nresolution="..W.."x"..H.."\n")
  fs.close(h);fs.setLabel("GameHub 128")
  installStep=3;draw();computer.pullSignal(0.5);return true
end
local function flashEEPROM()
  local ep=component.eeprom;if not ep then return false,"EEPROM not found." end
  local code=BOOT_CODE:gsub("__DISK_ADDRESS__",diskAddress)
  local ok,e=ep.set(code);if not ok then return false,e end
  local ok2,e2=pcall(ep.setLabel,"EEPROM (GameHub 128)");if not ok2 then return false,e2 end
  pcall(ep.setData,diskAddress)
  return true
end

draw()
while true do
  local e,a,b,c,d=computer.pullSignal()
  if e=="touch" or e=="drag" then
    cursorX,cursorY=b,c;draw()
    if e=="touch" then
      if page==1 and hit(W/2-10,H-4,20,1) then page=2;draw()
      elseif page==2 then
        local bw=18;local gap=2;local start=math.floor((W-(bw*4+gap*3))/2)+1
        for i,name in ipairs(languageNames) do
          local col=(i-1)%4;local row=math.floor((i-1)/4)
          if hit(start+col*(bw+gap),10+row*2,bw,1) then lang=name;draw();break end
        end
        if hit(W/2-10,H-4,20,1) then page=3;draw() end
      elseif page==3 then
        if hit(4,H-4,14,1) then page=2;draw()
        elseif hit(W-24,H-4,18,1) and diskAddress then
          page=4;draw();local ok,e2=installOS()
          if not ok then errorText=tostring(e2);page=3;draw()
          else page=5;draw();local ok3,e3=flashEEPROM();okEEPROM=ok3
            if not ok3 then errorText=tostring(e3) end
            draw()
          end
        else
          local y=9
          for address in component.list("filesystem") do
            local fs=component.proxy(address)
            if not fs.isReadOnly() then
              if hit(4,y,W-8,1) then diskAddress=address;draw();break end
              y=y+2
            end
          end
        end
      elseif page==5 and okEEPROM and hit(W/2-10,H-4,20,1) then
        page=6;draw()
        for i=5,1,-1 do countdown=i;draw();computer.pullSignal(1) end
        computer.shutdown(true);return
      end
    end
  end
end
