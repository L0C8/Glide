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
global playerSprite
global playerSpeed#
global playerX#

// Platform
global platform

// Boxes
dim boxes[100]
dim boxSprites[100]
global boxCount = 0
global spawnTimer#
global spawnInterval#
global boxSpeed#

// Game State
global gameState = 0 // 0: Menu, 1: Playing, 2: Game Over
global startText
global exitText
global gameOverText

// Initialize variables and objects
function InitGame()
    // Player
    player = CreateObjectBox(1, 1, 1)
    SetObjectPosition(player, 0.0, 0.0, -5.0)
    SetObjectColor(player, 255, 255, 255, 255)
    playerSprite = CreateSprite(0) // Invisible sprite for collision
    SetSpriteSize(playerSprite, 20, 20) // Adjusted for world scale
    SetSpritePosition(playerSprite, 320, 240) // Center (maps to X=0, Z=-5)
    SetSpriteVisible(playerSprite, 0) // Hide sprite
    playerSpeed# = 10.0
    playerX# = 0.0
    
    // Platform
    platform = CreateObjectBox(20, 0.5, 10)
    SetObjectPosition(platform, 0.0, -0.75, -5.0)
    SetObjectColor(platform, 100, 100, 100, 255)
    
    // Boxes
    spawnTimer# = 0.0
    spawnInterval# = 1.0
    boxSpeed# = -10.0
    
    // Menu Texts
    startText = CreateText("Press Space To Start")
    SetTextSize(startText, 50)
    SetTextPosition(startText, 320, 200)
    SetTextAlignment(startText, 1)
    
    // exitText = CreateText("Exit")
    // SetTextSize(exitText, 50)
    // SetTextPosition(exitText, 320, 300)
    // SetTextAlignment(exitText, 1)
    
    gameOverText = CreateText("Game Over")
    SetTextSize(gameOverText, 50)
    SetTextPosition(gameOverText, 320, 240)
    SetTextAlignment(gameOverText, 1)
    SetTextVisible(gameOverText, 0)
endfunction

// Update Player
function UpdatePlayer()
    if gameState = 1
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
        // Map 3D X,Z to 2D sprite X,Y
        spriteX# = 320.0 + playerX# * 20.0 // Scale X to screen
        spriteY# = 240.0 // Z=-5 maps to Y=240
        SetSpritePosition(playerSprite, spriteX#, spriteY#)
    endif
endfunction

// Spawn Box
function SpawnBox()
    if boxCount < 100
        boxID = CreateObjectBox(1, 1, 1)
        SetObjectColor(boxID, Random(100, 255), Random(100, 255), Random(100, 255), 255)
        x# = Random(-10, 10) * 1.0 
        SetObjectPosition(boxID, x#, 0.0, 50.0)
        // Create corresponding sprite
        spriteID = CreateSprite(0)
        SetSpriteSize(spriteID, 20, 20) // Same size as player
        spriteX# = 320.0 + x# * 20.0
        spriteY# = 240.0 - (50.0 + 5.0) * 4.0 // Z=50 maps to Y
        SetSpritePosition(spriteID, spriteX#, spriteY#)
        SetSpriteVisible(spriteID, 0)
        boxes[boxCount] = boxID
        boxSprites[boxCount] = spriteID
        inc boxCount
    endif
endfunction

// Update Boxes
function UpdateBoxes()
    i = 0
    while i < boxCount
        boxID = boxes[i]
        spriteID = boxSprites[i]
        if boxID > 0
            z# = GetObjectZ(boxID)
            z# = z# + boxSpeed# * GetFrameTime()
            SetObjectPosition(boxID, GetObjectX(boxID), 0.0, z#)
            // Update sprite position
            spriteX# = 320.0 + GetObjectX(boxID) * 20.0
            spriteY# = 240.0 - (z# + 5.0) * 4.0 // Map Z to Y
            SetSpritePosition(spriteID, spriteX#, spriteY#)
            
            // Collision Detection using sprites
            if gameState = 1 and GetSpriteInBox(playerSprite, GetSpriteX(spriteID) - 10, GetSpriteY(spriteID) - 10, GetSpriteX(spriteID) + 10, GetSpriteY(spriteID) + 10)
                gameState = 2
                SetTextVisible(gameOverText, 1)
                SetTextVisible(startText, 0)
                SetTextVisible(exitText, 0)
            endif
            
            if z# < -10.0
                DeleteObject(boxID)
                DeleteSprite(spriteID)
                for j = i to boxCount-2
                    boxes[j] = boxes[j+1]
                    boxSprites[j] = boxSprites[j+1]
                next j
                boxes[boxCount-1] = 0
                boxSprites[boxCount-1] = 0
                dec boxCount
            else
                inc i
            endif
        else
            inc i
        endif
    endwhile
endfunction

// Handle Menu
function UpdateMenu()
    if gameState = 0
        SetTextVisible(startText, 1)
        SetTextVisible(exitText, 1)
        SetTextVisible(gameOverText, 0)
        
        if GetRawKeyPressed(32) // Space to start
            gameState = 1
            SetTextVisible(startText, 0)
            SetTextVisible(exitText, 0)
        endif
        if GetRawKeyPressed(27) // Escape to exit
            End
        endif
    elseif gameState = 2
        if GetRawKeyPressed(32) // Space to restart
            // Reset game
            for i = 0 to boxCount-1
                DeleteObject(boxes[i])
                DeleteSprite(boxSprites[i])
            next i
            boxCount = 0
            spawnTimer# = 0.0
            playerX# = 0.0
            SetObjectPosition(player, 0.0, 0.0, -5.0)
            SetSpritePosition(playerSprite, 320, 240)
            gameState = 0
        endif
        if GetRawKeyPressed(27) // Escape to exit
            End
        endif
    endif
endfunction

// Main Loop
InitGame()
do
    if gameState = 1
        spawnTimer# = spawnTimer# + GetFrameTime()
        if spawnTimer# >= spawnInterval#
            SpawnBox()
            spawnTimer# = 0.0
        endif
        UpdatePlayer()
        UpdateBoxes()
    endif
    UpdateMenu()
    Sync()
loop
