--[[
Player List by aaronlink127 v0.73 (for GTA Online v1.67)
    Provides a customizable Player List akin to the one built into the game.
]]
util.require_natives("2944b")

local function toast(str, toast_flag)
    util.toast($"[{SCRIPT_NAME}] {str}", toast_flag)
end
local curLang = lang.get_current()
local asset_dir = filesystem.resources_dir().."playerlist/"
if not io.isdir(asset_dir) then
    toast("Assets not found, exiting!", TOAST_DEFAULT | TOAST_LOGGER)
    return
end
local gamer_font = directx.create_font(asset_dir.."gamer.spritefont")
local rockstar_font = directx.create_font(asset_dir.."rockstartag.spritefont")
local lang_dir = asset_dir.."lang/"
local function readFile(path, binary = false)
    local f<close> = io.open(path, binary ? "rb" : "r")
    return f:read("a")
end

local function splitByUnescapedNewline(inp)
    return coroutine.wrap(function()
        local buffer = ""
        for line in inp:gmatch("[^\n]*") do
            if line[-1] == '\\' then
                buffer ..= line:sub(1, -2) .. "\n"
            else
                coroutine.yield(buffer .. line)
                buffer = ""
            end
        end
    end)
end
local function parseLangTxt(langCode)
    return coroutine.wrap(function()
        local langPath = lang_dir..langCode..".txt"
        if io.exists(langPath) and (txtConts := readFile(langPath)) then
            for line in splitByUnescapedNewline(txtConts) do
                if line[1] == ";" then continue end
                local label, value = line:match("(.-):%s*(.*)")
                if not label then continue end
                coroutine.yield(label, value)
            end
        end
    end)
end
enum CONTROL_ID begin
    INPUT_FRONTEND_Y = 204, -- TAB
    INPUT_CURSOR_ACCEPT = 237,
    INPUT_CURSOR_CANCEL,
    INPUT_CURSOR_X,
    INPUT_CURSOR_Y,
    INPUT_CURSOR_SCROLL_UP,
    INPUT_CURSOR_SCROLL_DOWN
end
enum StandLabels begin
    L_ON = -1997368184,
    L_OFF = 1626316076,
    L_DOFF = 1626316076,
    L_BGBLUR = 1512605364,
    L_TEXT = 2134593963,
    L_POS = 1202796717,
    L_MOUSEMOVE = 2048209357,
    L_VIS = -582303346,
end
local registerLang = lang.register

local lbls = {}
for key, value in parseLangTxt("en") do
    lbls[key] = lang.register(value)
end

if not lang.is_automatically_translated(curLang) and curLang != "en" then
    lang.set_translate(curLang)
    for key, value in parseLangTxt(curLang) do
        local langHash = lbls[key]
        if not langHash then continue end
        lang.translate(langHash, value)
    end
end

setmetatable(lbls, {
    function __index(key)
        return "!!! "..key.." !!!"
    end
})
-- 1.58 globals
-- local fmHud = 1644209
-- local fmPlayerInfo = 1893548

-- 1.59 globals/1.60 globals
-- local fmHud = 1644218
-- local fmPlayerInfo = 1893551

-- 1.61 globals
-- local fmHud <const> = 1648034
-- local fmPlayerInfo <const> = 1892703

-- 1.64 globals
-- local fmHud <const> = 1653913
-- local fmPedHead<const> = 1666668

-- 1.66 globals
local fmHud <const> = 1654054
local fmPedHead<const> = 1666485

local function getPedHeadshotIds()
    local tbl = {}
    if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(-931834499) == 0 then return tbl end
    for i=0, 31 do
        local pid = memory.read_int(memory.script_global(fmPedHead+1+i*5+1))
        if pid == -1 then continue end
        tbl[pid] = memory.read_int(memory.script_global(fmPedHead+1+i*5+2))
    end
    return tbl
end

local get_boss = players.get_boss
local add_brackets
do
    local tag_brackets_id = menu.ref_by_path("Players>Settings>Tags>Brackets")
    local fmts = {}
    local fmtLen = 0
    for k, v in tag_brackets_id:getChildren() do
        fmts[k] = v.menu_name:gsub("STD", "%%s")
    end
    function add_brackets(str)
        local b = tag_brackets_id.value
        return fmts[b+1]:format(str)
    end
end
local window_to_screen = directx.pos_client_to_hud
local my_root = menu.my_root()
local rPtr = memory.alloc(16)
local gPtr = rPtr+4
local bPtr = gPtr+4
local aPtr = bPtr+4
--region Utility Functions
    local function game_clr_to_float(r,g,b,a)
        return r/255, g/255, b/255, a/255
    end
    local function GET_HUD_COLOUR(id)
        HUD.GET_HUD_COLOUR(id, rPtr, gPtr, bPtr, aPtr)
        return memory.read_int(rPtr), memory.read_int(gPtr), memory.read_int(bPtr), memory.read_int(aPtr)
    end
    local function GET_HUD_COLOUR_FLOAT(id)
        return game_clr_to_float(GET_HUD_COLOUR(id))
    end

    -- I get the freemode color from the menu rather than from the game, because the game likes to override FREEMODE a lot
    -- but instead of hardcoding the color i still want it to respect overrides done in Stand, so here's a compromise.
    local fmR = menu.ref_by_path("Game>Edit HUD/UI Colours>FREEMODE>Red")
    local fmG = menu.ref_by_path("Game>Edit HUD/UI Colours>FREEMODE>Green")
    local fmB = menu.ref_by_path("Game>Edit HUD/UI Colours>FREEMODE>Blue")
    local fmA = menu.ref_by_path("Game>Edit HUD/UI Colours>FREEMODE>Opacity")
    local function get_fm_clr()
        return game_clr_to_float(
            menu.get_value(fmR),
            menu.get_value(fmG),
            menu.get_value(fmB),
            menu.get_value(fmA)
        )
    end
--endregion

--region Assets
    filesystem.mkdirs(asset_dir.."flag_dl")
    local function texAsset(filename)
        local path = asset_dir..filename
        return directx.create_texture(path)
    end
    local voice_tex = {
        texAsset "voice1.dds",
        texAsset "voice2.dds",
        texAsset "voice3.dds"
    }
    local plug_tex = texAsset "plug.dds"
    local load_tex = texAsset "load.dds"
    local mouse_tex = texAsset "mouse.dds"
    local controller_tex = texAsset "pad_controller.dds"
    local flag_error = texAsset "flagerror.png"
    local org_tex = {
        texAsset "securoserv.dds",
        texAsset "mc.dds",
    }
    local lang_ids = {
        "us",
        "fr",
        "de",
        "it",
        "es",
        "br",
        "pl",
        "ru",
        "kr",
        "tw",
        "jp",
        "mx",
        "cn",
    }
    local rp_tex = texAsset "rp.dds"

    local crew_1_tex = texAsset "crew1.dds"
    local crew_2_tex = texAsset "crew2.dds"
    local getFlagTexture
    do
        local flag_tex_ids = {}
        function getFlagTexture(ctry)
            ctry = ctry:lower()
            if (flag_tex := flag_tex_ids[ctry]) then
                if flag_tex == -1 then
                    return
                end
                return flag_tex
            end
            local dir = asset_dir.."flag_dl/"..ctry..".png"
            if filesystem.exists(dir) then
                local flag_tex = directx.create_texture(dir)
                flag_tex_ids[ctry] = flag_tex
                return flag_tex
            end
            flag_tex_ids[ctry] = -1
            async_http.init($"https://s.rsg.sc/sc/images/common/flags/24/{ctry}.png", "", function(response, header, status_code)
                if status_code != 200 then
                    return
                end
                local f<close> = io.open(dir, "wb")
                f:write(response)
                flag_tex_ids[ctry] = nil
            end, function() end)
            async_http.dispatch()
        end
    end
--endregion

--region Menu Actions
    local showList = true
    my_root:toggle(lbls.SHOW_LIST, {"playerlistshow"}, "", function(st) showList = st end, showList)
    local highlightSelected = false
    my_root:toggle(lbls.HGHLGHT_PLY, {"playerlisthighlight"}, lbls.HGHLGHT_PLY_H, function(st) highlightSelected = st end, highlightSelected)

    local noVanilla = false
    my_root:toggle(lbls.NOVPLYLST, {"playerlistdisablevanilla"}, lbls.NOVPLYLST_H, function(st) noVanilla = st end, noVanilla)
    --region Appearance
        local mouse_move_mnu
        local appearanceList = my_root:list(L_VIS, {}, "", function() end, function()
            mouse_move_mnu.value = false
        end)
        
        --region Accessories
            local accessoryList = menu.list(appearanceList, lbls.ACCS)
                
            local show_voice = 2
            accessoryList:list_select(lbls.SHOWVOICE, {"playerlistshowvoice"}, "", {{L_OFF, {"off"}}, {lbls.SHOWVOICE_2, {"talking"}}, {L_ON, {"on"}}}, show_voice, function(val)
                show_voice = val
            end)
            local show_head = false
            accessoryList:toggle(lbls.SHOWHEAD, {"playerlistshowhead"}, lbls.SHOWHEAD_H, function(st) show_head = st end, show_head)
            local show_rp = 2
            accessoryList:list_select(lbls.SHOWRP, {"playerlistshowrp"}, lbls.SHOWRP_H, {{L_OFF, {"off"}}, {lbls.SHOWRP_2, {"talking"}, lbls.SHOWRP_2_H}, {L_ON, {"on"}}}, show_rp, function(val)
                show_rp = val
            end)
            local show_org = true
            accessoryList:toggle(lbls.SHOWORG, {"playerlistshoworg"}, lbls.SHOWORG_H, function(st) show_org = st end, show_org)
            local show_geoloc = false
            accessoryList:toggle(lbls.SHOWGEOLOC, {"playerlistshowcntry"}, lbls.SHOWGEOLOC_H, function(st) show_geoloc = st end, show_geoloc)
            local show_lang = false
            accessoryList:toggle(lbls.SHOWLANG, {"playerlistshowlang"}, lbls.SHOWLANG_H, function(st) show_lang = st end, show_lang)
            local show_pad = false
            accessoryList:toggle(lbls.SHOWPAD, {"playerlistshowpad"}, lbls.SHOWPAD_H, function(st) show_pad = st end, show_pad)
            local show_fm_status = false
            accessoryList:toggle(lbls.SHOWFMST8, {"playerlistshowfm"}, lbls.SHOWFMST8_H, function(st) show_fm_status = st end, show_fm_status)
        --endregion

        --region Crew Tags
            local crewRoot = appearanceList:list(lbls.CREW)
            local showCrew = true
            crewRoot:toggle(lbls.CREWVIS, {"playerlistcrew"}, "", function(st) showCrew = st end, showCrew)
            local tagUseColor = false
            crewRoot:toggle(lbls.CREWCLR, {"playerlistcrewcolour", "playerlistcrewcolor"}, "", function(st) tagUseColor = st end, tagUseColor)
            -- local crewScale = 24
            -- crewRoot:slider(lbls.CREWTXTSCL, {"playerlistcrewscale"}, "", 0, 100, crewScale, 1, function(val) crewScale = val end)
            local crewOffset = 0
            crewRoot:slider(lbls.CREWTXTOFFS, {"playerlistcrewoffset"}, "", -32768, 32767, 0, 1, function(val) crewOffset = val / 32 end)
        --endregion

        --region Text
            local textList = appearanceList:list(L_TEXT)
            local text_scale = 24
            textList:slider(lbls.TXTSCL, {"playerlisttextscale"}, "", 1, 32767, text_scale, 1, function(val) text_scale = val end)
            -- local rp_scale = 24
            -- textList:slider(lbls.RPTXTSCL, {"playerlistrptextscale"}, "", 1, 32767, rp_scale, 1, function(val) rp_scale = val end)
            -- local rp_text_offset = 0
            -- textList:slider(lbls.RPTXTOFFS, {"playerlistrptextxoffset"}, "", -32768, 32767, rp_text_offset, 1, function(val) rp_text_offset = val / 100 end)
        --endregion
        local posList = appearanceList:list(L_POS, {"playerlistpos"})
        local posX = 0
        local posX_cmd = posList:slider("X", {"playerlistx"}, "", -32768, 32767, posX, 1, function(val) posX = val / 1920 end)
        local posY = 0
        local posY_cmd = posList:slider("Y", {"playerlisty"}, "", -32768, 32767, posY, 1, function(val) posY = val / 1080 end)
        local cur_x, cur_y
        --region Mouse Move Functionality
            local is_mouse_move
            mouse_move_mnu = posList:toggle_loop(L_MOUSEMOVE, {"playerlistmousemove"}, "", function()
                if not is_mouse_move then
                    is_mouse_move = true
                    return
                end
                if not menu.is_open() then return end
                directx.draw_rect(cur_x, cur_y, 16/1920, 16/1080, 1,1,1,1)
                PAD.SET_INPUT_EXCLUSIVE(2,INPUT_CURSOR_ACCEPT)
                PAD.SET_INPUT_EXCLUSIVE(2,INPUT_CURSOR_X)
                PAD.SET_INPUT_EXCLUSIVE(2,INPUT_CURSOR_Y)
                if PAD.IS_CONTROL_JUST_PRESSED(2, INPUT_CURSOR_ACCEPT) then
                    util.create_thread(function()
                        local start_x, start_y = cur_x - posX, cur_y - posY
                        repeat
                            menu.trigger_command(posX_cmd, math.floor((cur_x - start_x)*1920))
                            menu.trigger_command(posY_cmd, math.floor((cur_y - start_y)*1080))
                            -- util.draw_debug_text(cur_x)
                            util.yield()
                        until not PAD.IS_CONTROL_PRESSED(2, INPUT_CURSOR_ACCEPT)
                    end)
                end
            end, function()
                is_mouse_move = false
            end)
        --endregion
        local list_w = 320
        appearanceList:slider(lbls.PLYLSTW, {"playerlistwidth"}, "", -32768, 32767, list_w, 1, function(val) list_w = val / 1920 end)
        list_w = list_w / 1920
        local list_s = 32
        appearanceList:slider(lbls.PLYLSTSCL, {"playerlistscale"}, "", 1, 32767, list_s, 1, function(val) list_s = val end)

        local bar_width = 16
        appearanceList:slider(lbls.PLYLSTBARW, {"playerlistbarwidth"}, "", 0, 100, bar_width, 4, function(val) bar_width = val / 100 end):addValueReplacement(0, lang.get_localised(L_DOFF))
        bar_width = bar_width / 100

        local blur = 0
        appearanceList:slider(L_BGBLUR, {"playerlistblur"}, "", 0, 255, blur, 1, function(val) blur = val end)
    --endregion


menu.apply_command_states()
--endregion
local function getGamerHandle(pid)
    local gamerHandle = memory.alloc(13)
    NETWORK.NETWORK_HANDLE_FROM_PLAYER(pid, gamerHandle, 13)
    return gamerHandle
end
local clan_desc = memory.alloc(35*8)
local function getClanDesc(pid)
    -- when the game does not consider it to be MP, the game will assume local player. this is to avoid that behavior.
    if pid ~= players.user() and not NETWORK.NETWORK_IS_SESSION_STARTED() then return end
    local gamerHandle = getGamerHandle(pid)
    local hasDesc = NETWORK.NETWORK_CLAN_PLAYER_GET_DESC(clan_desc, 35, gamerHandle)
    -- local clan_desc = memory.script_global(1575090+1+pid*35)
    if hasDesc then
        return {
            id = memory.read_int(clan_desc),
            clanName = memory.read_string(clan_desc+0x8),
            clanTag = memory.read_string(clan_desc+0x88),
            memberCount = memory.read_int(clan_desc+0x90),
            isSystemClan = memory.read_int(clan_desc+0x98) ~= 0,
            isOpenClan = memory.read_int(clan_desc+0xA0) ~= 0,
            rankName = memory.read_string(clan_desc+0xA8),
            rankOrder = memory.read_int(clan_desc+0xF0),
            createdTime = memory.read_int(clan_desc+0xF8),
            clanColorRed = memory.read_int(clan_desc+0x100),
            clanColorGreen = memory.read_int(clan_desc+0x108),
            clanColorBlue = memory.read_int(clan_desc+0x110)
        }
    end
end

local function truncate_text_to_size(txt, size, width, trail)
    trail = trail or ""
    local text_w = directx.get_text_size(txt, size)
    if text_w < width then return txt, false end
    for i=-1, -#txt, -1 do
        local ret_txt = txt:sub(1, i)..trail
        if directx.get_text_size(ret_txt, size) <= width then return ret_txt, true end
    end
    for i=-1, -#trail, -1 do
        local ret_txt = trail:sub(1, i)
        
        if directx.get_text_size(ret_txt, size) <= width then return ret_txt, true end
    end
    return "", true
end
local function sort_players(ply_list)
    local value_list = {}
    for ply_list as pid do
        local boss = get_boss(pid)
        if boss == pid then
            value_list[pid] = boss * 33
        else
            value_list[pid] = (boss == -1 ? 32 : boss) * 33 + (pid + 1)
        end
    end
    
    table.sort(ply_list, function(p1,p2)
        return value_list[p1] < value_list[p2]
    end)
    return ply_list
end
local function get_session_label()
    if NETWORK.NETWORK_IS_SESSION_STARTED() then
        if NETWORK.NETWORK_SESSION_IS_CLOSED_FRIENDS() then return "HUD_LBD_FMF" end
        if NETWORK.NETWORK_SESSION_IS_CLOSED_CREW() then return "HUD_LBD_FMC" end
        if NETWORK.NETWORK_SESSION_IS_SOLO() then return "HUD_LBD_FMS" end
        if NETWORK.NETWORK_SESSION_IS_PRIVATE() then return "HUD_LBD_FMI" end
        return "HUD_LBD_FMP"
    end
    return "PM_PAUSE_HDR"
end
-- local function get_player_loadstate(pid)
--     return memory.read_int(memory.script_global(2657704+1+pid*463))
-- end
local mouse_support = menu.ref_by_path("Stand>Settings>Input>Mouse Support>Mouse Support")
local blurrect
util.on_stop(function()
    if blurrect then
        for blurrect as rect do
            blurrect = directx.blurrect_free(rect)
        end
    end
end)
util.yield()
util.yield()
util.create_tick_handler(function()
    local playerHeads
    if noVanilla then
        local offs = memory.script_global(fmHud+68)
        if memory.read_int(offs) == 1 then
            memory.write_int(offs, 2)
        end
    end
    if not showList or menu.is_in_screenshot_mode() then return end
    local focusd = {}
    for k, v in players.get_focused() do
        focusd[v] = true
    end
    local cursor_sel
    local is_mouse_support = menu.is_open() and menu.get_value(mouse_support)
    if is_mouse_move or is_mouse_support then
        cur_x, cur_y = window_to_screen(PAD.GET_CONTROL_NORMAL(2, 239), PAD.GET_CONTROL_NORMAL(2, 240))
        -- util.draw_debug_text(cur_x)
        -- util.draw_debug_text(cur_y)
        cursor_sel = is_mouse_support and cur_x > posX and cur_x < posX + list_w
    end
    local fm_r,fm_g,fm_b,fm_a = get_fm_clr()
    local icon_w = list_s / 1920
    local icon_h = list_s / 1080
    local bar_w = bar_width * icon_w
    local ply_list = players.list()
    ply_list = sort_players(ply_list)
    local menu_height = icon_h * (#ply_list+1)
    local penY = posY
    if posY > 0.5 then
        penY = penY - menu_height
    end
    if blur ~= 0 then
        if not blurrect then
            blurrect = {directx.blurrect_new(), directx.blurrect_new()}
        end
        directx.blurrect_draw(blurrect[1], posX,penY,list_w,icon_h, blur)
        local x_off = 0
        if show_head then
            x_off = icon_w
        end
        directx.blurrect_draw(blurrect[2], posX+x_off,penY+icon_h,list_w-x_off,menu_height - icon_h, blur)
    end
    local label = util.get_label_text(get_session_label()):gsub("~1~", #ply_list)
    directx.draw_rect(posX,penY,list_w,icon_h,{r=0,g=0,b=0,a=0.6})
    directx.draw_text(posX,penY + icon_h / 2,label,ALIGN_CENTRE_LEFT,text_scale*icon_h,1,1,1,1)
    penY += icon_h
    if is_mouse_move or not is_mouse_support or cur_y <= penY then
        cursor_sel = false
    end
    local even = true
    local voice_st = math.floor(os.clock()*6) % 4
    local usr = players.user()
    local total_h = icon_h * #ply_list
    if show_head then
        playerHeads = getPedHeadshotIds()
        HUD.SET_TEXT_RENDER_ID(1)
        HUD.SET_WIDESCREEN_FORMAT(1)
        GRAPHICS.SET_SCRIPT_GFX_DRAW_ORDER(8)
        GRAPHICS.SET_SCRIPT_GFX_DRAW_BEHIND_PAUSEMENU(true)
        GRAPHICS.DRAW_RECT(posX + icon_w/2,penY + total_h/2, icon_w, total_h, 0, 0, 0, 255, false)
    end
    local spectate_stack = 0
    for k,pid in ply_list do
        local ply_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local is_me = usr == pid
        local stats_ready = players.are_stats_ready(pid) or is_me
        local nextPenY = penY + icon_h
        local is_cursor_here = false
        if cursor_sel and cur_y <= nextPenY then
            is_cursor_here = true
            cursor_sel = false
        end
        if is_cursor_here and PAD.IS_DISABLED_CONTROL_JUST_PRESSED(2, 237) then
            menu.trigger_command(menu.player_root(pid))
        end
        even = not even
        local player_clr_id
        local org_clr_id = players.get_org_colour(pid)
        local boss_id = get_boss(pid)
        if org_clr_id == 2 then
            player_clr_id = 12
        elseif org_clr_id ~= -1 then
            player_clr_id = 192 + org_clr_id
        elseif boss_id ~= -1 then
            player_clr_id = 9
        end
        local left_offset = 0
        local bg_r, bg_g, bg_b, bg_a
        if player_clr_id then
            bg_r, bg_g, bg_b, bg_a = GET_HUD_COLOUR_FLOAT(player_clr_id)
        else
            bg_r, bg_g, bg_b, bg_a = fm_r,fm_g,fm_b,fm_a
        end

        local is_participant = NETWORK.NETWORK_IS_PLAYER_A_PARTICIPANT_ON_SCRIPT(pid, "freemode", -1)
        if show_head then
            if is_participant then
                local pedHead = playerHeads[pid]
                if pedHead then
                    local pedHeadTex = PED.GET_PEDHEADSHOT_TXD_STRING(playerHeads[pid])
                    if pedHeadTex then
                        GRAPHICS.DRAW_SPRITE(pedHeadTex, pedHeadTex, left_offset + posX + icon_w/2,penY + icon_h/2, icon_w, icon_h, 0, 255, 255, 255, 255, false, 0)
                    end
                end
            end
            left_offset += icon_w
        end
        directx.draw_rect(left_offset + posX,penY,bar_w,icon_h,bg_r, bg_g, bg_b, bg_a)
        -- local max_health = PED.GET_PED_MAX_HEALTH(ply_ped) - 100
        -- local health = (ENTITY.GET_ENTITY_HEALTH(ply_ped) - 100) / max_health
        -- directx.draw_rect(left_offset + posX,penY,bar_w,icon_h*health,1, 0, 1, 1)
        left_offset += bar_w
        local lightness = even and 0.6 or 0.7
        if is_cursor_here then
            lightness = 1
            bg_a = 1
        elseif highlightSelected and focusd[pid] then
            bg_a = 0.6 + (math.sin(os.clock()*10) + 1) / 2 * 0.4
        else
            bg_a = 0.4
        end
        bg_r *= lightness * bg_a
        bg_g *= lightness * bg_a
        bg_b *= lightness * bg_a
        directx.draw_rect(left_offset + posX,penY,list_w - left_offset,icon_h,bg_r,bg_g,bg_b,bg_a)
        
        local spectateTarget = players.get_spectate_target(pid)
        if spectateTarget ~= -1 then
            local idxInList = table.contains(ply_list, spectateTarget)
            if idxInList then
                local mainOffs = 0
                local lineX = icon_w * (12/32) + (icon_w * (8/32) * spectate_stack)
                local lineW = icon_w * (4/32)
                local triX = posX + list_w + mainOffs
                local triY = posY + idxInList * icon_h + icon_h / 2
                local triW = icon_w / 2
                local triH = icon_h/4
                directx.draw_rect(posX + list_w + mainOffs - lineW, penY + icon_h / 2, lineX + lineW + triW, icon_h * (4/32), 1, 0, 1, 1)
                directx.draw_rect(posX + list_w + mainOffs - lineW + triW, posY + idxInList * icon_h + icon_h / 2, lineX + lineW, icon_h * (4/32), 1, 0, 1, 1)
                directx.draw_rect(posX + list_w + mainOffs + triW - lineW + lineX, penY + icon_h / 2, lineW, icon_h * (idxInList - k), 1, 0, 1, 1)
                directx.draw_triangle(triX + mainOffs, triY, triX + triW, triY - triH, triX + triW, triY + triH, 255,0,255,255)
                spectate_stack += 1
            end
        end
        local clanDesc = showCrew and getClanDesc(pid)
        local right_pen = posX + list_w - icon_w / 2
        local acc_w = 0
        local voice_anim_state = 0
        local accY = penY + icon_h / 2
        local is_talking = is_me ? NETWORK.NETWORK_IS_PUSH_TO_TALK_ACTIVE() : NETWORK.NETWORK_IS_PLAYER_TALKING(pid)
        local rank = players.get_rank(pid)
        if show_rp ~= 1 and not (show_rp == 2 and (is_talking or show_voice == 3)) then
            local rw, rh = directx.get_text_size(rank, 60, gamer_font)
            rw = math.max(rw, 1)
            directx.draw_texture(rp_tex, icon_w / 2, icon_h, 0.5, 0.5, right_pen, accY, 0, fm_r,fm_g,fm_b,fm_a)
            directx.draw_text(right_pen + -0.11 * icon_w, accY + 0.06 * icon_h, rank, ALIGN_CENTRE, 30 * icon_h / rw, 1,1,1,1, false, gamer_font)
            right_pen = right_pen - icon_w
            acc_w += icon_w
        end
        -- if (blip := HUD.GET_BLIP_FROM_ENTITY(ply_ped)) ~= 0 then
        --     local txt = HUD.GET_BLIP_SPRITE(blip)
        --     local r_w, r_h = directx.get_text_size(txt,rp_scale*2)
        --     r_w = math.max(1,r_w)
        --     directx.draw_text(right_pen + rp_text_offset * icon_w, accY, txt, ALIGN_CENTRE, 1, 1,1,1,1)
        --     right_pen = right_pen - icon_w
        --     acc_w += icon_w
        -- end
        if is_talking or show_voice == 3 then
            if is_talking then
                voice_anim_state = voice_st
            end
            for i=1,3 do
                directx.draw_texture(voice_tex[i], icon_w / 2, icon_h, 0.5, 0.5, right_pen, accY, 0, 1,1,1,voice_anim_state < i and 0.3 or 1)
            end
            right_pen = right_pen - icon_w
            acc_w += icon_w
        end
        if show_lang then
            local texAsset
            if stats_ready and (texAsset := getFlagTexture(lang_ids[players.get_language(pid)+1])) then
                directx.draw_texture(texAsset, icon_w * 0.8 / 2, icon_h, 0.5, 0.5, right_pen, accY, 0, 1,1,1,1)
            else
                directx.draw_texture(load_tex, icon_w / 2, 0, 0.5, 0.5, right_pen, accY, os.clock() / 2, 1,1,1,1)
            end
            right_pen = right_pen - icon_w
            acc_w += icon_w
        end
        if show_geoloc then
            local texAsset
            local ip = players.get_connect_ip(pid)
            if ip == 0xffffffff then
                texAsset = flag_error
            elseif util.is_soup_netintel_inited() and (loc := soup.netIntel.getLocationByIp(ip)):isValid() then
                texAsset = getFlagTexture(loc.country_code)
            end
            if texAsset then
                directx.draw_texture(texAsset, icon_w * 0.8 / 2, icon_h, 0.5, 0.5, right_pen, accY, 0, 1,1,1,1)
            else
                directx.draw_texture(load_tex, icon_w / 2, 0, 0.5, 0.5, right_pen, accY, os.clock() / 2, 1,1,1,1)
            end
            right_pen = right_pen - icon_w
            acc_w += icon_w
        end
        if show_pad and stats_ready then
            directx.draw_texture(players.is_using_controller(pid) and controller_tex or mouse_tex, icon_w / 2, icon_h, 0.5, 0.5, right_pen, accY, 0, 1,1,1,1)
            right_pen = right_pen - icon_w
            acc_w += icon_w
        end
        if show_org then
            local org_type = players.get_org_type(pid)
            if org_type ~= -1 then
                local texAsset = org_tex[org_type+1]
                if texAsset then
                    directx.draw_texture(texAsset, icon_w / 2, icon_h, 0.5, 0.5, right_pen, accY, 0, 1,1,1,1)
                    right_pen = right_pen - icon_w
                    acc_w += icon_w
                end
            end
        end
        if show_fm_status and not is_participant then
            directx.draw_texture(plug_tex, icon_w * 0.8 / 2, icon_h, 0.5, 0.5, right_pen, accY, 0, 1,1,1,1)
            right_pen = right_pen - icon_w
            acc_w += icon_w
        end
        local name_scale = text_scale * icon_h
        local name = players.get_name(pid)
        local tags = players.get_tags_string(pid)
        local tag_w = 0
        if tags ~= "" then
            tags = add_brackets(tags)
            tag_w = directx.get_text_size(tags, name_scale)
            tags = " "..tags
        end
        if clanDesc then
            tag_w = tag_w + icon_w*2
        end
        local did_truncate
        name, did_truncate = truncate_text_to_size(name, name_scale, list_w-acc_w-tag_w-left_offset, ".")
        local text_w
        if did_truncate then
            text_w = list_w-acc_w - left_offset
            local tag_left = text_w
            if clanDesc then
                tag_left = tag_left - icon_w * 2
            end
            text_w -= icon_w * 2
            directx.draw_text(left_offset + posX + tag_left,penY + icon_h / 2,tags,ALIGN_CENTRE_RIGHT,name_scale,1,1,1,1)
        else
            name = name.. tags
            text_w = directx.get_text_size(name, name_scale)
        end
        directx.draw_text(left_offset + posX,penY + icon_h / 2,name,ALIGN_CENTRE_LEFT,name_scale,1,1,1,1)
        if showCrew and clanDesc then
            local clan_r, clan_g, clan_b = clanDesc.clanColorRed, clanDesc.clanColorGreen, clanDesc.clanColorBlue
            local txt_col = 0
            if tagUseColor then
                clan_r = clan_r / 255
                clan_g = clan_g / 255
                clan_b = clan_b / 255
                if clan_r + clan_g + clan_b < (0.5 * 3) then
                    txt_col = 1
                end
            else
                clan_r = 1
                clan_g = 1
                clan_b = 1
            end
            directx.draw_texture(clanDesc.isOpenClan and crew_2_tex or crew_1_tex, icon_w, icon_h / 2, 0.5, 0.5, left_offset + posX + text_w + crewOffset * icon_w + icon_w,penY + icon_h / 2, 0, clan_r, clan_g, clan_b,1)
            directx.draw_text(left_offset + posX + text_w + crewOffset * icon_w + icon_w - icon_w * 0.05,penY + icon_h / 2 + icon_h * 0.05,clanDesc.clanTag,ALIGN_CENTRE,icon_h * 28,txt_col,txt_col,txt_col,1, false, rockstar_font)
        end
        penY = nextPenY
    end
    return true
end)
