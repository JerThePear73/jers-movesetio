local TEX_EVILSWAG_MOVESET = get_texture_info("evilswag_moveset_title")

local TEX_EVILSWAG_MOVE_GP_CANCEL = get_texture_info("evilswag_moveset_demo_gp_dive")
local TEX_EVILSWAG_MOVE_GP_JUMP = get_texture_info("evilswag_moveset_demo_gp_jump")
local TEX_EVILSWAG_MOVE_SLOW_KICK = get_texture_info("evilswag_moveset_demo_slow_kick")
local TEX_EVILSWAG_MOVE_SPINJUMP = get_texture_info("evilswag_moveset_demo_spinjump")
local TEX_EVILSWAG_MOVE_TORNADO = get_texture_info("evilswag_moveset_demo_tornado")
local TEX_EVILSWAG_MOVE_MIDAIR_SPIN = get_texture_info("evilswag_moveset_demo_midair_spin")

local e = gEvilswagMoveset[0]

local menuEntriesMain = {
    [0] = "Moves",
    [1] = "Menu Colour",
    [2] = "Music Volume",
}

local menuEntriesMoves = {
    [ACT_GP_DIVE]       = {name = "GP DIVE",        input = "Z + B",    tex = TEX_EVILSWAG_MOVE_GP_CANCEL,      desc = "A little hop forward from a \nground pound for some extra \ndistance."},
    [ACT_GP_JUMP]       = {name = "GP JUMP",        input = "Z + A",    tex = TEX_EVILSWAG_MOVE_GP_JUMP,        desc = "Jump as soon as you hit land a \nground pound to get some bonus \nheight."},
    [ACT_SLOW_KICK]     = {name = "SLOW KICK",      input = "B",        tex = TEX_EVILSWAG_MOVE_SLOW_KICK,      desc = "Actions that force you into dive \nwill make you kick instead when \nmoving backwards."},
    [ACT_SPINJUMP]      = {name = "SPINJUMP",       input = "SPIN + A", tex = TEX_EVILSWAG_MOVE_SPINJUMP,       desc = "Spin your stick to do a powerful \njump. Jumping as soon as you \nland lets you triple jump."},
    [ACT_TORNADO]       = {name = "TORNADO",        input = "Z + A",    tex = TEX_EVILSWAG_MOVE_TORNADO,        desc = "A powerful air move that helps \nreach those high up areas. \nGains less height with forward \nmovement."},
    [ACT_MIDAIR_SPIN]   = {name = "MIDAIR SPIN",    input = "A",        tex = TEX_EVILSWAG_MOVE_MIDAIR_SPIN,    desc = "Give yourself a little more time \nto stick that landing with this \nflashy flourish."},
}

local presetColours = {
    [0] = {r = 200, g = 255, b = 150},
    [1] = {r = 255, g = 120, b = 255},
    [2] = {r = 100, g = 200, b = 255},
    [3] = {r = 255, g = 200, b =  80},
    [4] = {r = 255, g = 220, b = 220},
    [5] = {r = 80,  g = 50,  b = 255},
    [6] = {r = 120, g = 100, b =  80},
    [7] = {r = 255, g = 0,   b =   0},
}

local TEX_EVILSWAG_GEAR1 = get_texture_info("evilswag_moveset_background_gear1")
local TEX_EVILSWAG_GEAR2 = get_texture_info("evilswag_moveset_background_gear2")
local SOUND_EVILSWAG_TYPE_BEAT = audio_stream_load("evilswag_moveset_menu_theme.ogg")
audio_stream_set_loop_points(SOUND_EVILSWAG_TYPE_BEAT, 1.525 * 22050, 65.525 * 22050)
audio_stream_set_looping(SOUND_EVILSWAG_TYPE_BEAT, true)

local function render_moveset_menu()
    local m = gMarioStates[0]
    local key = m.controller.buttonPressed
    local targetEase = e.menu_is_open and 1 or 0
    local red = presetColours[e.menuCol].r
    local gre = presetColours[e.menuCol].g
    local blu = presetColours[e.menuCol].b

    if (not is_game_paused() or (charSelect ~= nil and charSelect.is_menu_open())) and e.menu_is_open then
        audio_stream_stop(SOUND_EVILSWAG_TYPE_BEAT)
        e.menuEaseFactor = 0
        e.menu_screen = 0
        e.menu_is_open = false
        return
    end

    djui_hud_set_resolution(RESOLUTION_N64)
    local width = djui_hud_get_screen_width() + 1
    local height = djui_hud_get_screen_height() + 1
    local fac = e.menuEaseFactor
    local inc = 180
    local offsetX = 10 + (e.menuOption.opacity * -inc) + (width * (1 - fac))

    if m.pos.y == m.floorHeight and is_game_paused() and not djui_hud_is_pause_menu_created() and m.action ~= ACT_EXIT_LAND_SAVE_DIALOG then
        djui_hud_set_color(255, 255, 255, 255*(1 - fac))
        djui_hud_set_font(FONT_NORMAL)
        djui_hud_print_text("D-Pad Up - Evilswag Menu", width/2 - 30, 12, 0.25)
        if key & U_JPAD ~= 0 and not e.menu_is_open then
            e.menu_is_open = true
            e.menu_screen = 0
            play_sound(SOUND_MENU_CAMERA_ZOOM_IN, m.marioObj.header.gfx.cameraToObject)
            audio_stream_play(SOUND_EVILSWAG_TYPE_BEAT, false, 0)
        end
    end

    if e.menuEaseFactor > 0.05 then
        audio_stream_set_volume(SOUND_EVILSWAG_TYPE_BEAT, fac * (e.menuMusicVol/100))
        if e.menuBeatTimer % 15 == 0 then
            e.menuBeatSquish = 0.5
        end
        e.menuBeatTimer = e.menuBeatTimer + 1
        if (e.menuBeatTimer % 2) == 0 then
            local frame = e.menuDemoFrame
            frame.x = frame.x + 1
            if frame.x > 7 then
                frame.x = 0
                frame.y = frame.y + 1
                if frame.y > 3 then
                    frame.y = 0
                end
            end
        end

        djui_hud_set_color(0, 0, 0, 230*fac) -- background
        djui_hud_render_rect(0, 0, width, height)
        djui_hud_set_color(red*0.5, gre*0.5, blu*0.5, 50*fac) -- gears
        djui_hud_set_rotation(e.menuBeatTimer * 100, 0.5, 0.5)
        djui_hud_render_texture(TEX_EVILSWAG_GEAR1, width/2 - 96 - (e.menuOption.opacity * 80), 40, 3, 3)
        djui_hud_set_rotation((e.menuBeatTimer + 20) * -200, 0.5, 0.5)
        djui_hud_render_texture(TEX_EVILSWAG_GEAR2, width/2 + 40 - (e.menuOption.opacity * 80), 0, 3, 3)
        djui_hud_set_rotation(0, 0, 0)
        djui_hud_set_font(FONT_RECOLOR_HUD)
        -- menu entries
        djui_hud_set_color(red, gre, blu, (e.menuBeatSquish - 0.5) * 150 * fac)
        local menuCheck = e.menu_screen == 0 and menuEntriesMain[e.menuOption.main] or menuEntriesMoves[e.menuOption.move].name
        djui_hud_render_rect(8, height/2 - 2, 6 + #menuCheck * 12, 20)

        djui_hud_set_color(red, gre, blu, (((1 - e.menuOption.opacity) * 205) + 50) * fac)
        local spacing = 40
        for i=0, #menuEntriesMain do
            djui_hud_print_text(menuEntriesMain[i], offsetX, (height/2) + (-e.menuOption.mainlerp * spacing) + i*spacing, 1)
        end
        for i=0, #menuEntriesMoves do
            djui_hud_set_color(red, gre, blu, (((e.menuOption.opacity) * 205) + 50) * fac)
            djui_hud_print_text(menuEntriesMoves[i].name, offsetX + inc, (height/2) + (-e.menuOption.movelerp * spacing) + i*spacing, 1)--(e.menuOption.opacity/2 + 0.5) * fac)
            djui_hud_set_color(255, 255, 255, (((e.menuOption.opacity) * 205) + 50) * fac)
            if e.menuCol == 7 then djui_hud_set_color(255, 0, 0, (((e.menuOption.opacity) * 205) + 50) * fac) end -- nefarious blue
            djui_hud_render_texture((e.movesEnabled[i] and gTextures.star or gTextures.no_camera), offsetX + inc + (#menuEntriesMoves[i].name * 12) + 6, (height/2) + (-e.menuOption.movelerp * spacing) + i*spacing, 1, 1)
        end

        djui_hud_set_color(255, 255, 255, 255) -- demos
        if e.menuCol == 7 then djui_hud_set_color(255, 0, 0, 255) end -- nefarious blue
        djui_hud_render_texture_tile(menuEntriesMoves[e.menuOption.move].tex, width + offsetX + 30, 35, 1, 1, e.menuDemoFrame.x*128, e.menuDemoFrame.y*128, 128, 128)
        djui_hud_set_font(FONT_HUD)
        djui_hud_set_text_alignment(0.5, 0)
        djui_hud_print_text(menuEntriesMoves[e.menuOption.move].input, width + offsetX + 30 + 64, 166, 1, 1)
        djui_hud_set_text_alignment(0, 0)
        djui_hud_set_font(FONT_NORMAL)
        local descTextScale = 0.4
        djui_hud_print_text((menuEntriesMoves[e.menuOption.move].desc), width + offsetX + 30, 182, descTextScale, descTextScale)
        djui_hud_set_font(FONT_RECOLOR_HUD)

        djui_hud_set_color(red*0.5, gre*0.5, blu*0.5, 255) -- banner
        djui_hud_render_rect(-20, 0, (width + 20) * fac, 30)
        djui_hud_set_color(red, gre, blu, 255) -- title
        local stretch = (1.1 - (e.menuBeatSquish/4))
        --djui_hud_print_text("EVILSWAG MOVESET", width/2 - (96 * stretch) - ((1 - fac) * width), 24 - (16 * e.menuBeatSquish * 1.2), 1 * stretch, (1 - ((1 - fac))) * e.menuBeatSquish * 1.2)
        djui_hud_render_texture(TEX_EVILSWAG_MOVESET, width/2 - (128 * stretch) - ((1 - fac) * width), 28 - (32 * e.menuBeatSquish * 0.9), 1 * stretch, e.menuBeatSquish * 0.9)
    elseif not e.menu_is_open then
        e.menuEaseFactor = 0
        e.menuBeatTimer = 0
        audio_stream_stop(SOUND_EVILSWAG_TYPE_BEAT)
    end


    if e.menu_is_open and not djui_hud_is_pause_menu_created() then
        if e.menu_screen == 0 then
            if key & B_BUTTON ~= 0 then
                e.menu_is_open = false
                play_sound(SOUND_MENU_CAMERA_ZOOM_OUT, m.marioObj.header.gfx.cameraToObject)
            end
            if key & U_JPAD ~= 0 and e.menuOption.main > 0 then
                e.menuOption.main = e.menuOption.main - 1
                play_sound(SOUND_MENU_MESSAGE_APPEAR, m.marioObj.header.gfx.cameraToObject)
            elseif key & D_JPAD ~= 0 and e.menuOption.main < #menuEntriesMain then
                e.menuOption.main = e.menuOption.main + 1
                play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, m.marioObj.header.gfx.cameraToObject)
            end

            if e.menuOption.main == 0 then
                if key & R_JPAD ~= 0 and e.menuBeatTimer > 10 then
                    e.menu_screen = 1
                    play_sound(SOUND_MENU_ENTER_HOLE, m.marioObj.header.gfx.cameraToObject)
                end
            elseif e.menuOption.main == 1 then
                if key & L_JPAD ~= 0 or key & R_JPAD ~= 0 then
                    e.menuCol = e.menuCol + (key & L_JPAD ~= 0 and -1 or 1)
                    play_sound(SOUND_MENU_EXIT_A_SIGN, m.marioObj.header.gfx.cameraToObject)
                    if e.menuCol < 0 then
                        e.menuCol = #presetColours
                    elseif e.menuCol > #presetColours then
                        e.menuCol = 0
                    end
                    mod_storage_save_integer("col", e.menuCol)
                end
            elseif e.menuOption.main == 2 then
                if key & L_JPAD ~= 0 and e.menuMusicVol > 0 then
                    e.menuMusicVol = e.menuMusicVol - 10
                    play_sound(SOUND_MENU_EXIT_A_SIGN, m.marioObj.header.gfx.cameraToObject)
                    mod_storage_save_integer("vol", e.menuMusicVol)
                elseif key & R_JPAD ~= 0 and e.menuMusicVol < 200  then
                    e.menuMusicVol = e.menuMusicVol + 10
                    play_sound(SOUND_MENU_EXIT_A_SIGN, m.marioObj.header.gfx.cameraToObject)
                    mod_storage_save_integer("vol", e.menuMusicVol)
                end
                djui_hud_print_text("- "..string.format("%.0f", e.menuMusicVol).."%", 160, (height/2) + (e.menuOption.mainlerp * -32) + 64, 1)
            end
        elseif e.menu_screen == 1 then
            if key & L_JPAD ~= 0 then
                e.menu_screen = 0
                play_sound(SOUND_MENU_EXIT_A_SIGN, m.marioObj.header.gfx.cameraToObject)
            elseif key & U_JPAD ~= 0 and e.menuOption.move > 0 then
                e.menuOption.move = e.menuOption.move - 1
                play_sound(SOUND_MENU_MESSAGE_APPEAR, m.marioObj.header.gfx.cameraToObject)
            elseif key & D_JPAD ~= 0 and e.menuOption.move < #menuEntriesMoves then
                e.menuOption.move = e.menuOption.move + 1
                play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, m.marioObj.header.gfx.cameraToObject)
            elseif key & R_JPAD ~= 0 then
                if e.movesEnabled[e.menuOption.move] then
                    e.movesEnabled[e.menuOption.move] = false
                    play_sound(SOUND_MENU_CAMERA_BUZZ, m.marioObj.header.gfx.cameraToObject)
                else
                    e.movesEnabled[e.menuOption.move] = true
                    play_sound(SOUND_MENU_CLICK_FILE_SELECT, m.marioObj.header.gfx.cameraToObject)
                end
                mod_storage_save_bool(menuEntriesMoves[e.menuOption.move].name, e.movesEnabled[e.menuOption.move])
            end
        end
    end

    e.menuEaseFactor = math.lerp(e.menuEaseFactor, targetEase, 0.1)
    e.menuBeatSquish = math.lerp(e.menuBeatSquish, 1, 0.1)
    e.menuOption.mainlerp = math.lerp(e.menuOption.mainlerp, e.menuOption.main, 0.3)
    e.menuOption.movelerp = math.lerp(e.menuOption.movelerp, e.menuOption.move, 0.3)
    e.menuOption.opacity = math.lerp(e.menuOption.opacity, e.menu_screen, 0.1)
end
hook_event(HOOK_ON_HUD_RENDER, render_moveset_menu)