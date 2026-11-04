---@param m MarioState
local function act_tornado(m)
    local e = gEvilswagMoveset[m.playerIndex]

    smlua_anim_util_set_animation(m.marioObj, "evilswag_moveset_anim_tornado")

    if m.actionTimer == 0 then
        m.faceAngle.y = m.intendedYaw
        play_character_sound_offset(m, CHAR_SOUND_YAHOO_WAHA_YIPPEE, math.random(0, 4) << 16) -- plays triple jump sound w/ equally weighted yahoo
        if m.input & INPUT_NONZERO_ANALOG ~= 0 then
            m.forwardVel = 5
        end
    elseif m.actionTimer < 35 then
        m.faceAngle.y = approach_s16_symmetric(m.faceAngle.y, m.intendedYaw, 0x200)

        if m.actionTimer <= 20 then
            if (m.actionTimer % 3) == 0 then
                play_sound(SOUND_ACTION_TWIRL, m.marioObj.header.gfx.cameraToObject)
            end
            m.marioBodyState.handState = MARIO_HAND_OPEN
            e.gfx.x = 1.2
            e.gfx.y = 0.8
            e.gfx.z = 1.2
        elseif m.actionTimer == 27 then
            play_sound_with_freq_scale(SOUND_ACTION_TWIRL, m.marioObj.header.gfx.cameraToObject, 0.8)
            e.gfx.x = 1.3
            e.gfx.y = 1.7
            e.gfx.z = 1.3
        end

        if m.actionTimer < 20 then
            if m.actionTimer > -1 then
                m.particleFlags = m.particleFlags | PARTICLE_SPARKLES
                m.vel.y = 18 - (m.actionTimer * (m.forwardVel/25))
            end
        else
            m.vel.y = m.vel.y + 3
        end
    end

    if m.actionTimer < 30 then
        m.marioBodyState.eyeState = MARIO_EYES_CLOSED
    elseif m.actionTimer < 40 then
        m.marioBodyState.eyeState = MARIO_EYES_LOOK_UP
    end

    if (m.input & INPUT_NONZERO_ANALOG) ~= 0 then
        mario_set_forward_vel(m, math.abs(m.forwardVel))
    end

    e.gfx.x = math.lerp(e.gfx.x, 1, 0.3)
    e.gfx.y = math.lerp(e.gfx.y, 1, 0.3)
    e.gfx.z = math.lerp(e.gfx.z, 1, 0.3)
    m.marioObj.header.gfx.scale.x = math.clamp(e.gfx.x, 1, 1.3)
    m.marioObj.header.gfx.scale.y = math.clamp(e.gfx.y, 0.8, 1.7)
    m.marioObj.header.gfx.scale.z = math.clamp(e.gfx.z, 1, 1.3)
    m.marioObj.header.gfx.pos.y = m.pos.y - (50 * e.gfx.y)

    m.actionTimer = m.actionTimer + 1
    return 0
end

---@param m MarioState
local function act_midair_spin(m)
    local e = gEvilswagMoveset[m.playerIndex]

    smlua_anim_util_set_animation(m.marioObj, "evilswag_moveset_anim_midair_spin")
    if m.actionTimer < 5 then
        m.vel.y = math.clamp(m.vel.y, 0, 10)
    end
    if m.actionTimer >= 10 then
        m.marioBodyState.handState = MARIO_HAND_OPEN
        m.marioBodyState.eyeState = MARIO_EYES_LOOK_DOWN
    else
        local handPos = gVec3fZero{}
        get_mario_anim_part_pos(m, MARIO_ANIM_PART_LEFT_HAND, handPos)
        spawn_non_sync_object(id_bhvSparkle, E_MODEL_SPARKLES_ANIMATION, handPos.x, handPos.y, handPos.z, nil)
        m.marioBodyState.handState = MARIO_HAND_FISTS
        m.marioBodyState.eyeState = MARIO_EYES_OPEN
    end
    set_anim_to_frame(m, math.clamp(m.actionTimer, 0, 20))
    m.marioBodyState.punchState = 0
    m.marioObj.header.gfx.angle.y = m.faceAngle.y
    m.actionTimer = m.actionTimer + 1
    return 0
end

---@param m MarioState
local function mario_update(m)
    local e = gEvilswagMoveset[m.playerIndex]
    local s = gPlayerSyncTable[m.playerIndex]
    mario_update_spin_input(m)
    if m.pos.y == m.floorHeight then
        e.canTornado = true
    end
    -- if m.action == ACT_WALKING then
    --     m.marioBodyState.torsoAngle.x = math.clamp((m.forwardVel - 10) * 170, -0x1555, 0x1555)
    -- end

    -- gp cancel
    if e.movesEnabled[ACT_GP_DIVE] then
        if m.action == ACT_GROUND_POUND and m.input & INPUT_B_PRESSED ~= 0 then
            m.vel.y = 25
            m.forwardVel = 20
            --m.faceAngle.y = m.intendedYaw
            play_sound(SOUND_GENERAL_SWISH_WATER, m.marioObj.header.gfx.cameraToObject)
            set_mario_action(m, ACT_DIVE, ARG_GP_DIVE)
        end
    end
    if m.action == ACT_DIVE and m.actionArg == ARG_GP_DIVE then
        m.faceAngle.x = 0
        set_anim_to_frame(m, math.clamp(m.marioObj.header.gfx.animInfo.animFrame + 1, 3, 60))
    end

    -- gp jump
    if e.movesEnabled[ACT_GP_JUMP] then
        if m.action == ACT_GROUND_POUND_LAND and m.input & INPUT_A_PRESSED ~= 0 then
            m.pos.y = m.pos.y + 20
            set_mario_action(m, ACT_JUMP, ARG_GP_JUMP)
        end
    end

    local mgfx = m.marioObj.header.gfx

    if m.action == ACT_JUMP and m.actionArg == ARG_GP_JUMP then
        if mgfx.animInfo.animFrame == -1 then
            play_character_sound(m, CHAR_SOUND_YAHOO_WAHA_YIPPEE)
            e.gfx.y = 0x15000
        end
        if m.vel.y > 0 then
            set_mario_particle_flags(m, PARTICLE_DUST, 0)
            m.vel.y = 60 - (m.actionTimer*4)
        end
        e.gfx.y = e.gfx.y * 0.8
        mgfx.angle.y = m.faceAngle.y + e.gfx.y
        m.actionTimer = m.actionTimer + 1
    end

    -- spin jump
    if m.action == ACT_SIDE_FLIP and m.actionArg == ARG_SPINJUMP then
        if m.marioObj.header.gfx.animInfo.animFrame == -1 then
            m.forwardVel = e.prevVel
            play_character_sound_offset(m, CHAR_SOUND_YAHOO_WAHA_YIPPEE, math.random(3, 4) << 16) -- plays triple jump sound w/out yahoo
        end
        if m.actionTimer <= 12 then
            for i=0, m.actionTimer do
                if m.actionTimer % 3 == 0 then
                    play_sound_with_freq_scale(SOUND_ACTION_TWIRL, m.marioObj.header.gfx.cameraToObject, 1 + (i/12)*1.5)
                end
            end
        end

        smlua_anim_util_set_animation(m.marioObj, "evilswag_moveset_anim_spin_jump")
        set_anim_to_frame(m, 0)

        m.marioBodyState.handState = MARIO_HAND_OPEN
        e.gfx.y = e.gfx.y + 0x4000
        m.vel.y = m.vel.y + 1
        m.marioObj.header.gfx.angle.y = m.faceAngle.y + e.gfx.y

        m.actionTimer = m.actionTimer + 1
    end

    -- tornado
    if m.action == ACT_FREEFALL and m.actionArg == ARG_TORNADO then
        act_tornado(m)
    end
    if m.action == ACT_GROUND_POUND and m.input & INPUT_A_PRESSED ~= 0 and e.canTornado and e.movesEnabled[ACT_TORNADO] then
        m.vel.y = 0
        e.gfx.y = 1
        set_mario_action(m, ACT_FREEFALL, ARG_TORNADO)
        e.canTornado = false
    end

    -- midair spin
    local midairTwirlActions = {
        [ACT_JUMP]          = true,
        [ACT_DOUBLE_JUMP]   = true,
        [ACT_TRIPLE_JUMP]   = true,
        [ACT_WALL_KICK_AIR] = true,
        [ACT_BACKFLIP]      = true,
        [ACT_SIDE_FLIP]     = true,
        [ACT_FREEFALL]      = true,
        [ACT_STEEP_JUMP]    = true,
    }
    if midairTwirlActions[m.action] and m.input & INPUT_A_PRESSED ~= 0 and not s.midairSpin and m.vel.y < 10 and e.movesEnabled[ACT_MIDAIR_SPIN] then
        if m.action ~= ACT_FREEFALL or (m.actionArg ~= ARG_MIDAIR_SPIN and m.actionArg ~= ARG_TORNADO) then
            s.midairSpin = true
            m.actionTimer = 0
            m.actionArg = 0
            play_sound_with_freq_scale(SOUND_ACTION_SPIN, m.marioObj.header.gfx.cameraToObject, 3)
            if m.action == ACT_SIDE_FLIP then
                m.action = ACT_DOUBLE_JUMP
            elseif m.action == ACT_JUMP or m.action == ACT_WALL_KICK_AIR or m.action == ACT_STEEP_JUMP then
                m.action = ACT_FREEFALL
            end
        end
    end
    if s.midairSpin then
        act_midair_spin(m)
    end
end
hook_event(HOOK_MARIO_UPDATE, mario_update)

---@param m MarioState
local function mario_set_action(m)
    local e = gEvilswagMoveset[m.playerIndex]
    local s = gPlayerSyncTable[m.playerIndex]

    if m.action == ACT_GROUND_POUND then
        m.marioObj.header.gfx.angle.y = m.faceAngle.y
    end

    -- spin jump
    if e.movesEnabled[ACT_SPINJUMP] then
        if (m.action == ACT_JUMP or m.action == ACT_DOUBLE_JUMP or (m.action == ACT_SIDE_FLIP and m.actionArg ~= ARG_SPINJUMP)) and e.spinInput ~= 0 and m.prevAction ~= ACT_GROUND_POUND then
            set_mario_action(m, ACT_SIDE_FLIP, ARG_SPINJUMP)
            m.vel.y = 55
        end
    end

    -- midair spin
    if s.midairSpin then
        s.midairSpin = false
    end
end
hook_event(HOOK_ON_SET_MARIO_ACTION, mario_set_action)

local function mario_before_set_action(m, act)
    local e = gEvilswagMoveset[m.playerIndex]

    -- slow kick
    if e.movesEnabled[ACT_SLOW_KICK] then
        local velCheck = e.movesEnabled.slow_kick == 2 and 29 or 0

        if act == ACT_DIVE and m.pos.y > m.floorHeight and m.forwardVel <= 15 + velCheck and m.actionArg ~= ARG_TORNADO then --and m.actionArg ~= ARG_SPINJUMP then
            return ACT_JUMP_KICK
        end
    end

    -- spin jump
    if e.movesEnabled[ACT_SPINJUMP] then
        if act == ACT_SIDE_FLIP then
            e.prevVel = m.forwardVel
        end
        if m.action == ACT_SIDE_FLIP and m.actionArg == ARG_SPINJUMP and act == ACT_SIDE_FLIP_LAND then
            return ACT_DOUBLE_JUMP_LAND
        end
    end
end
hook_event(HOOK_BEFORE_SET_MARIO_ACTION, mario_before_set_action)


-- debugging
-- hook_event(HOOK_ON_HUD_RENDER_BEHIND, function()
--     local m = gMarioStates[0]

--     djui_hud_set_color(255, 255, 255, 255)
--     djui_hud_set_font(FONT_ALIASED)
--     djui_hud_set_resolution(RESOLUTION_DJUI)

--     djui_hud_print_text(tostring(m.actionTimer), 50, 250, 1, 1)
-- end)