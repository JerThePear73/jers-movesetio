-- name: \\#0f0\\Ev\\#0f8\\il\\#0fa\\sw\\#0ff\\ag Moveset [WIP]
-- description: A very customizable, vanilla friendly moveset mod.

local ANGLE_QUEUE_SIZE = 9
local SPIN_TIMER_SUCCESSFUL_INPUT = 4

ACT_GP_DIVE     = 0
ACT_GP_JUMP     = 1
ACT_SLOW_KICK   = 2
ACT_SPINJUMP    = 3
ACT_TORNADO     = 4
ACT_MIDAIR_SPIN = 5

-- allocate actions to m.actionArg to save action slots
ARG_GP_DIVE     = 1336
ARG_GP_JUMP     = 1337
ARG_SPINJUMP    = 73
ARG_TORNADO     = 1349
ARG_MIDAIR_SPIN = 1350

gEvilswagMoveset = {}
for i = 0, MAX_PLAYERS - 1 do
    gEvilswagMoveset[i] = {}
    local e = gEvilswagMoveset[i]
    e.gfx = gVec3fZero{}
    e.movesEnabled = {
        [ACT_GP_DIVE]       = mod_storage_load_bool("GP DIVE", true),
        [ACT_GP_JUMP]       = mod_storage_load_bool("GP JUMP", true),
        [ACT_SLOW_KICK]     = mod_storage_load_bool("SLOW KICK", true),
        [ACT_SPINJUMP]      = mod_storage_load_bool("SPINJUMP", true),
        [ACT_TORNADO]       = mod_storage_load_bool("ACT_TORNADO", true),
        [ACT_MIDAIR_SPIN]   = mod_storage_load_bool("ACT_MIDAIR_SPIN", true),
    }
    e.canTornado = true
    e.prevVel = 0
    -- menu
    e.menu_is_open = false
    e.menu_screen = 0
    e.menuOffsetX = 0
    e.menuOption = {
        main = 0,
        move = 0,
        mainlerp = 0,
        movelerp = 0,
        opacity = 0,
    }
    e.menuEaseFactor = 0
    e.menuMusicVol = mod_storage_load_integer("vol", 100)
    e.menuCol = mod_storage_load_integer("col", 0)
    e.menuBeatTimer = 0
    e.menuBeatSquish = 0
    e.menuDemoFrame = {
        x = 0,
        y = 0,
    }
    -- spin
    e.stickLastAngle = 0
    e.spinDirection = 0
    e.spinBufferTimer = 0
    e.spinInput = 0
    e.lastStickMag = 0
    e.angleDeltaQueue = {}
    for j=0,(ANGLE_QUEUE_SIZE-1) do gEvilswagMoveset[i].angleDeltaQueue[j] = 0 end
    gPlayerSyncTable[i].midairSpin = false
end

function mario_update_spin_input(m) -- taken from extended moveset
    local e = gEvilswagMoveset[m.playerIndex]
    local rawAngle = atan2s(-m.controller.stickY, m.controller.stickX)
    e.spinInput = 0

    -- prevent issues due to the frame going out of the dead zone registering the last angle as 0
    if e.lastStickMag > 60 and m.controller.stickMag > 60 then
        local angleOverFrames = 0
        local thisFrameDelta = 0
        local i = 0

        local newDirection = e.spinDirection
        local signedOverflow = 0

        if rawAngle < e.stickLastAngle then
            if e.stickLastAngle - rawAngle > 0x8000 then
                signedOverflow = 1
            end
            if signedOverflow ~= 0 then
                newDirection = 1
            else
                newDirection = -1
            end
        elseif rawAngle > e.stickLastAngle then
            if rawAngle - e.stickLastAngle > 0x8000 then
                signedOverflow = 1
            end
            if signedOverflow ~= 0 then
                newDirection = -1
            else
                newDirection = 1
            end
        end

        if e.spinDirection ~= newDirection then
            for i=0,(ANGLE_QUEUE_SIZE-1) do
                e.angleDeltaQueue[i] = 0
            end
            e.spinDirection = newDirection
        else
            for i=(ANGLE_QUEUE_SIZE-1),1,-1 do
                e.angleDeltaQueue[i] = e.angleDeltaQueue[i-1]
                angleOverFrames = angleOverFrames + e.angleDeltaQueue[i]
            end
        end

        if e.spinDirection < 0 then
            if signedOverflow ~= 0 then
                thisFrameDelta = math.floor((1.0*e.stickLastAngle + 0x10000) - rawAngle)
            else
                thisFrameDelta = e.stickLastAngle - rawAngle
            end
        elseif e.spinDirection > 0 then
            if signedOverflow ~= 0 then
                thisFrameDelta = math.floor(1.0*rawAngle + 0x10000 - e.stickLastAngle)
            else
                thisFrameDelta = rawAngle - e.stickLastAngle
            end
        end

        e.angleDeltaQueue[0] = thisFrameDelta
        angleOverFrames = angleOverFrames + thisFrameDelta

        if angleOverFrames >= 0xA000 then
            e.spinBufferTimer = SPIN_TIMER_SUCCESSFUL_INPUT
        end


        -- allow a buffer after a successful input so that you can switch directions
        if e.spinBufferTimer > 0 then
            e.spinInput = 1
            e.spinBufferTimer = e.spinBufferTimer - 1
        end
    else
        e.spinDirection = 0
        e.spinBufferTimer = 0
    end

    e.stickLastAngle = rawAngle
    e.lastStickMag = m.controller.stickMag
end