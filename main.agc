// Setup
SetWindowTitle("Glide")
SetWindowSize(640, 480, 0)
SetVirtualResolution(640, 480)
SetSyncRate(60, 0)
SetClearColor(0, 0, 50)

// 3D Camera
SetCameraPosition(1, 0.0, 10.0, -10.0)
SetCameraLookAt(1, 0.0, 0.0, 0.0, 0.0)
SetCameraFOV(1, 75.0)

// Player
global player
global playerSpeed#
global playerX#

// Boxes
dim boxes[100]
global boxCount = 0
global spawnTimer#
global spawnInterval#
global boxSpeed#

// Initialize variables and player
player = CreateObjectBox(1, 1, 1)
SetObjectPosition(player, 0.0, 0.0, -5.0)
SetObjectColor(player, 255, 255, 255, 255)
playerSpeed# = 10.0
playerX# = 0.0
spawnTimer# = 0.0
spawnInterval# = 1.0
boxSpeed# = -10.0

// Functions
function UpdatePlayer()
    move# = 0.0
    if GetRawKeyState(37) or GetRawKeyState(65) 
        move# = -1.0
    endif
    if GetRawKeyState(39) or GetRawKeyState(68)
        move# = 1.0
    endif
    playerX# = playerX# + move# * playerSpeed# * GetFrameTime()
    if playerX# < -10.0 then playerX# = -10.0
    if playerX# > 10.0 then playerX# = 10.0
    SetObjectPosition(player, playerX#, 0.0, -5.0)
endfunction

function SpawnBox()
    if boxCount < 100
        boxID = CreateObjectBox(1, 1, 1)
        SetObjectColor(boxID, Random(100, 255), Random(100, 255), Random(100, 255), 255)
        x# = Random(-10, 10) * 1.0 
        SetObjectPosition(boxID, x#, 0.0, 50.0)
        boxes[boxCount] = boxID
        inc boxCount
    endif
endfunction

function UpdateBoxes()
    i = 0
    while i < boxCount
        boxID = boxes[i]
        if boxID > 0
            z# = GetObjectZ(boxID)
            z# = z# + boxSpeed# * GetFrameTime()
            SetObjectPosition(boxID, GetObjectX(boxID), 0.0, z#)
            if z# < -10.0
                DeleteObject(boxID)
                for j = i to boxCount-2
                    boxes[j] = boxes[j+1]
                next j
                boxes[boxCount-1] = 0
                dec boxCount
            else
                inc i
            endif
        else
            inc i
        endif
    endwhile
endfunction

// Main Loop
do
    spawnTimer# = spawnTimer# + GetFrameTime()
    if spawnTimer# >= spawnInterval#
        SpawnBox()
        spawnTimer# = 0.0
    endif
    UpdatePlayer()
    UpdateBoxes()
    Sync()
loop
