INCLUDE Irvine32.inc
INCLUDELIB winmm.lib

PlaySound PROTO STDCALL :PTR BYTE, :DWORD, :DWORD
SND_ASYNC     = 0001h
SND_LOOP      = 0008h
SND_FILENAME  = 00020000h

Beep PROTO, dwFreq:DWORD, dwDuration:DWORD

mapWidth          = 20
mapHeight         = 20
road              = 0
wall              = 1
obstacle          = 2
PICKUP_RANGE      = 1 

pointLosforYellow = 4
pointLosforRed    = 2
bonusp            = 10
dropP             = 10
MAX_PASSENGERS    = 4
NUM_OBSTACLES     = 3
NUM_CARS          = 3
NUM_BONUS         = 2

.data

; --- SYSTEM VARIABLES ---
cursorInfo       CONSOLE_CURSOR_INFO <>
outHandle        DWORD ?
timeMsg          BYTE  " Time: ", 0
filename         BYTE "highscores.txt", 0
bgmFile          BYTE "bgm.wav", 0  
fileHandle       DWORD ?
fileBuffer       BYTE 5000 DUP(0)
writeBuffer      BYTE 100 DUP(0)    
newLineStr       BYTE 0Dh, 0Ah, 0 
saveFileName     BYTE "savegame.bin", 0
saveHandle       DWORD ?
sepStr           BYTE " : ", 0


leaderboardNames  BYTE 300 DUP(0) 
leaderboardScores DWORD 10 DUP(0)     


starLine1  BYTE "   * +        * .      +     * .   + ", 0
starLine2  BYTE " +    .       * +      .     * +       * ", 0
starLine3  BYTE "    * +       .      * +      .      * ", 0

; Yellow "RUSH HOUR" ASCII Art Title
titleBorder BYTE "    $ ================================================ $ ", 0
    title1  BYTE "    $ .---. .---. .---. .---. .---. .---. .---. .---.  $ ", 0
    title2  BYTE "    $  |R|   |U|   |S|   |H|   |H|   |O|   |U|   |R|   $ ", 0
    title3  BYTE "    $ `---' `---' `---' `---' `---' `---' '---' '---'  $ ", 0
    title4  BYTE "    $ ================================================ $ ", 0
     

optBracketL BYTE "          [", 0
optBracketR BYTE "] ", 0
opt1 BYTE "1. START NEW GAME ", 0
opt6 BYTE "2  SET DIFFICULTY", 0
opt2 BYTE "3. INSTRUCTIONS   ", 0
opt3 BYTE "4. LEADERBOARD    ", 0
opt4 BYTE "5. EXIT           ", 0
opt5 BYTE "6. CONTINUE GAME  ", 0

menuPrompt  BYTE " Select Choice > ", 0



;  GAME OVER MENU STRINGS
gameOverTitle    BYTE "------- G A M E O V E R -------- ", 0
gameOverOption1  BYTE "[1] RESTART GAME", 0
gameOverOption2  BYTE "[2] MAIN MENU", 0
gameOverPrompt   BYTE "Select Option: ", 0

; DIFFICULTY MENU STRINGS 
diffMenu1     BYTE "   --- SELECT DIFFICULTY ---   ", 0
diffMenu2     BYTE "[1] EASY   (Slow Speed)", 0
diffMenu3     BYTE "[2] NORMAL (Medium Speed)", 0
diffMenu4     BYTE "[3] HARD   (Fast Speed)", 0

; WIN MESSAGE 
winTitle      BYTE "      CONGRATULATIONS!       ", 0
winMsg        BYTE "   YOU REACHED 100 POINTS!   ", 0

; OTHER MENUS & MESSAGES 
instBorder       BYTE "  +---------------- INSTRUCTIONS --------------+", 0
instLine1        BYTE "  | 1. Use Arrow Keys or WASD to Move.         |", 0
instLine2        BYTE "  | 2. Press SPACEBAR to Pick Up/Drop Pass.    |", 0
instLine3        BYTE "  | 3. Avoid Walls, Cars (X), Trees (T).       |", 0
instLine4        BYTE "  | 4. Watch out for Pedestrians (&)!          |", 0
instLine5        BYTE "  | 5. Collect Bonuses ($) for points.         |", 0
instFooter       BYTE "  +--------------------------------------------+", 0
lbBorder         BYTE "  +--------------- LEADERBOARD ----------------+", 0
pressKey         BYTE "  Press any key to return...", 0
gameOverMsg      BYTE "GAME OVER!", 0
modeMenu1        BYTE " - - - CHOOSE GAME MODE - - - ", 0
modeMenu2        BYTE "1. Endless", 0
modeMenu3        BYTE "2. Time Mode (60s Limit)", 0
modeMenu4        BYTE "3. CAREER MODE (Win at 100 Points)", 0 ; 
modeSel          BYTE "Select: ", 0
taxiMenu1        BYTE " - - - CHOOSE YOUR TAXI - - - ", 0
taxiMenu2        BYTE "1. YELLOW TAXI (Fast, High Obstacle Penalty - 4)", 0
taxiMenu3        BYTE "2. RED TAXI (Slow, Low Obstacle Penalty - 2)", 0
taxiMenu4        BYTE "3. RANDOM TAXI", 0
taxiSel          BYTE "Select: ", 0
askName          BYTE "Enter Driver Name: ", 0
score            BYTE " Score: ", 0
pass             BYTE " | Pass: ", 0
saveMsg          BYTE "Game Data Saved!", 0
scoreSavedMsg    BYTE "New High Score Recorded!", 0
crashMsg         BYTE " CRASH Penalty: - ", 0
obsMsg           BYTE " OBSTACLE HIT! Penalty: - ", 0
hitCarMsg        BYTE " HIT CAR Penalty: - ", 0
pedMsg           BYTE " HIT PERSON! Penalty: - 5 ", 0
bonusMsg         BYTE " BONUS + 10 Points!", 0
pauseMsg         BYTE " Game Paused ", 0
pickMsg          BYTE " Passenger Picked Up! ", 0
dropMsg          BYTE " Passenger Dropped! ", 0
dropsForSpeed DWORD 0


GAME_STATE_START LABEL BYTE
    taxiX          BYTE 2
    taxiY          BYTE 2
    taxiType       BYTE 1
    taxiColor      DWORD 14
    penaltyWall    DWORD 4
    carCrashPenalty DWORD 3
    curScore       SDWORD 0
    passCount      DWORD 0
    hasPass        BYTE 0 
    passStatus     BYTE 5 DUP(0) 
    passX          BYTE 5 DUP(?)
    passY          BYTE 5 DUP(?)
    passDestX      BYTE 5 DUP(?)
    passDestY      BYTE 5 DUP(?)
    enemyX         BYTE 3 DUP(?)
    enemyY         BYTE 3 DUP(?)
    enemyDir       BYTE 3 DUP(?)
    bonusX         BYTE 2 DUP(?)
    bonusY         BYTE 2 DUP(?)
    currentDestX   BYTE ?
    currentDestY   BYTE ?
    enemyTimer     DWORD 0      
    gameMode       DWORD 1
    timeLimit      DWORD 60
    frameCounter   DWORD 0
    gameSpeed      DWORD 50 
    playerNameLen  DWORD ?
    playerName     BYTE 30 DUP(0)
    boardMap       BYTE 400 DUP(0)
GAME_STATE_END LABEL BYTE
GAME_STATE_SIZE = (GAME_STATE_END - GAME_STATE_START)


initialBoardLayout LABEL BYTE
    BYTE 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 
    BYTE 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1 
    BYTE 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    BYTE 1,0,0,1,1,1,1,0,0,0,0,0,1,1,1,1,1,1,1,1
    BYTE 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    BYTE 1,0,0,1,1,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1
    BYTE 1,0,0,0,0,1,0,0,0,0,0,0,1,1,1,1,0,0,0,1
    BYTE 1,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1
    BYTE 1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1
    BYTE 1,0,0,1,0,1,0,1,0,1,0,0,1,0,0,0,0,0,0,1
    BYTE 1,0,0,1,1,1,0,1,1,1,0,0,0,0,0,0,0,0,0,1
    BYTE 1,0,0,1,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,1
    BYTE 1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1
    BYTE 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1
    BYTE 1,0,0,1,1,1,0,0,0,0,0,0,0,0,0,1,0,0,0,1
    BYTE 1,0,0,1,1,1,0,0,0,0,0,0,0,0,0,1,0,0,0,1
    BYTE 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1
    BYTE 1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1
    BYTE 1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1
    BYTE 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 

.code
main          PROC
    call          Randomize
    call          HideCursor      
    call          LoadLeaderboardData 
    call          PlayBackgroundMusic
    call          ShowMenu
    exit
main          ENDP

HideCursor PROC
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov outHandle, eax
    INVOKE GetConsoleCursorInfo, outHandle, ADDR cursorInfo
    mov cursorInfo.bVisible, 0
    INVOKE SetConsoleCursorInfo, outHandle, ADDR cursorInfo
    ret
HideCursor ENDP

PlayBackgroundMusic PROC
    INVOKE PlaySound, OFFSET bgmFile, NULL, SND_ASYNC OR SND_LOOP OR SND_FILENAME
    ret
PlayBackgroundMusic ENDP


ShowMenu  PROC
MenuLoop:
    call Clrscr
    
    mov eax, 11 ; Light Cyan
    call SetTextColor
    mov edx, OFFSET starLine1
    call WriteString
    call Crlf
    mov edx, OFFSET starLine2
    call WriteString
    call Crlf
    call Crlf
    

    mov eax, 14 ; Yellow
    call SetTextColor
    mov edx, OFFSET titleBorder
    call WriteString
    call Crlf
    mov edx, OFFSET title1
    call WriteString
    call Crlf
    mov edx, OFFSET title2
    call WriteString
    call Crlf
    mov edx, OFFSET title3
    call WriteString
    call Crlf
    mov edx, OFFSET title4
    call WriteString
    call Crlf
    call Crlf

    mov eax, 14 ; Yellow
    call SetTextColor
    mov edx, OFFSET optBracketL
    call WriteString
    mov eax, 15 ; White
    call SetTextColor
    mov edx, OFFSET opt1
    call WriteString
    mov eax, 14 ; Yellow
    call SetTextColor
    mov edx, OFFSET optBracketR
    call WriteString
    call Crlf
    
    mov edx, OFFSET optBracketL
    call WriteString
    mov edx, OFFSET opt6
    call WriteString
    mov edx, OFFSET optBracketR
    call WriteString
    call Crlf

    mov edx, OFFSET optBracketL
    call WriteString
    mov eax, 15 ; White
    call SetTextColor
    mov edx, OFFSET opt2
    call WriteString
    mov eax, 14 ; Yellow
    call SetTextColor
    mov edx, OFFSET optBracketR
    call WriteString
    call Crlf

    mov edx, OFFSET optBracketL
    call WriteString
    mov eax, 15 ; White
    call SetTextColor
    mov edx, OFFSET opt3
    call WriteString
    mov eax, 14 ; Yellow
    call SetTextColor
    mov edx, OFFSET optBracketR
    call WriteString
    call Crlf

    mov edx, OFFSET optBracketL
    call WriteString
    mov eax, 15 ; White
    call SetTextColor
    mov edx, OFFSET opt4
    call WriteString
    mov eax, 14 ; Yellow
    call SetTextColor
    mov edx, OFFSET optBracketR
    call WriteString
    call Crlf
    
    ; Option 5 (Continue)
    mov edx, OFFSET optBracketL
    call WriteString
    mov edx, OFFSET opt5
    call WriteString
    mov edx, OFFSET optBracketR
    call WriteString
    call Crlf
    call Crlf

    mov eax, 11 ; Light Cyan
    call SetTextColor
    mov edx, OFFSET starLine3
    call WriteString
    call Crlf
    mov edx, OFFSET starLine1
    call WriteString
    call Crlf
    call Crlf
    
    mov eax, 14 ; Yellow
    call SetTextColor
    mov  edx, OFFSET menuPrompt
    call WriteString
    call ReadInt
    
    cmp eax, 1
    je  PreGameSetup
    cmp eax, 2
    je  SetDifficultyOption
    cmp eax, 3
    je  ShowInst
    cmp eax, 4
    je  ShowLeaderboard
    cmp eax, 5 
    je  ExitApp
    cmp eax, 6
    je   LoadGameOption
    jmp MenuLoop

SetDifficultyOption:       
    call SelectDifficulty
    jmp MenuLoop

LoadGameOption:
    call LoadGameState
    jmp  MenuLoop

PreGameSetup:
    call GetPlayerName
    call SelectTaxiColour
    call SelectGameMode
    call InitialGame
    call PlayGame
    jmp  MenuLoop
    
ShowInst:
    call Clrscr
    mov eax, 11
    call SetTextColor
    mov edx, OFFSET instBorder
    call WriteString
    call Crlf
    
    mov eax, 15
    call SetTextColor
    mov edx, OFFSET instLine1
    call WriteString
    call Crlf
    mov edx, OFFSET instLine2
    call WriteString
    call Crlf
    mov edx, OFFSET instLine3
    call WriteString
    call Crlf
    mov edx, OFFSET instLine4
    call WriteString
    call Crlf
    mov edx, OFFSET instLine5
    call WriteString
    call Crlf
    
    mov eax, 11
    call SetTextColor
    mov edx, OFFSET instFooter
    call WriteString
    call Crlf
    call Crlf
    
    mov eax, 14
    call SetTextColor
    mov edx, OFFSET pressKey
    call WriteString
    call ReadChar
    jmp  MenuLoop
    
ShowLeaderboard:
    call ViewLeaderboard
    jmp  MenuLoop
    
ExitApp:
    ret
ShowMenu      ENDP

GetPlayerName PROC
    call Clrscr
    mov eax, 15
    call SetTextColor
    mov  edx, OFFSET askName
    call WriteString
    mov  edx,OFFSET playerName
    mov  ecx, 29
    call ReadString
    mov  playerNameLen, eax                
    ret
GetPlayerName    ENDP

SelectTaxiColour PROC
    call Clrscr
    mov  edx, OFFSET taxiMenu1
    call WriteString
    call Crlf
    mov  edx, OFFSET taxiMenu2
    call WriteString
    call Crlf
    mov  edx, OFFSET taxiMenu3
    call WriteString
    call Crlf
    mov  edx, OFFSET taxiMenu4
    call WriteString
    call Crlf
    mov  edx, OFFSET taxiSel
    call WriteString
    call ReadInt

    cmp eax, 3
    je  SetRandom
    cmp eax, 2
    je  SetRed
    jmp SetYellow

SetRandom:
    mov eax, 2
    call RandomRange
    cmp eax, 0
    je SetYellow

SetRed:
    mov taxiType,    2
    mov taxiColor,   12
    mov gameSpeed,   60
    mov penaltyWall, pointLosforRed    
    mov carCrashPenalty, 3             
    ret

SetYellow:
    mov taxiType,    1
    mov taxiColor,   14
    mov gameSpeed,   30
    mov penaltyWall, pointLosforYellow 
    mov carCrashPenalty, 2             
    ret
SelectTaxiColour ENDP

SelectGameMode PROC
    call Clrscr
    mov  edx, OFFSET modeMenu1
    call WriteString
    call Crlf
    mov  edx, OFFSET modeMenu2
    call WriteString
    call Crlf
    mov  edx, OFFSET modeMenu3
    call WriteString
    call Crlf
    mov  edx, OFFSET modeMenu4
    call WriteString
    call Crlf
    mov  edx, OFFSET modeSel
    call WriteString
    call ReadInt
    cmp eax, 2
    je  SetTimeMode
    mov gameMode, 1
    ret
SetTimeMode:
    mov gameMode, 2
    mov timeLimit, 60 
    ret
SetCareerMode: 
    mov gameMode, 3   
    ret
SelectGameMode ENDP
SelectDifficulty PROC
    call Clrscr
    mov eax, 14 ; Yellow
    call SetTextColor
    
    mov dl, 30
    mov dh, 8
    call Gotoxy
    mov edx, OFFSET diffMenu1
    call WriteString
    
    mov eax, 15 ; White
    call SetTextColor
    
    mov dl, 30
    mov dh, 10
    call Gotoxy
    mov edx, OFFSET diffMenu2
    call WriteString
    
    mov dl, 30
    mov dh, 12
    call Gotoxy
    mov edx, OFFSET diffMenu3
    call WriteString
    
    mov dl, 30
    mov dh, 14
    call Gotoxy
    mov edx, OFFSET diffMenu4
    call WriteString
    
    mov dl, 30
    mov dh, 16
    call Gotoxy
    mov edx, OFFSET menuPrompt
    call WriteString
    call ReadInt
    
    ; Logic: Higher Delay = Slower Speed
    cmp eax, 1
    je  SetEasy
    cmp eax, 3
    je  SetHard
    
    ; Normal (Default)
    mov gameSpeed, 50
    ret

SetEasy:
    mov gameSpeed, 80 ; Slower
    ret

SetHard:
    mov gameSpeed, 25 ; Faster
    ret
SelectDifficulty ENDP



AtoI PROC
    push ebx
    push ecx
    push edx
    push esi
    push edi 
    mov eax, 0 
    mov ecx, 0 
    mov ebx, 10 
LoopConvert:
    movzx esi, BYTE PTR [edi]
    cmp esi, '0'
    jl DoneConvert
    cmp esi, '9'
    jg DoneConvert
    sub esi, '0' 
    push esi     
    inc ecx
    inc edi
    jmp LoopConvert
DoneConvert:
    mov esi, 1 
LoopSum:
    cmp ecx, 0
    je EndAtoI
    pop edx         
    push eax        
    mov eax, edx    
    mul esi         
    mov edx, eax    
    pop eax         
    add eax, edx    
    push eax        
    mov eax, esi
    mov edx, 10
    mul edx         
    mov esi, eax    
    pop eax         
    loop LoopSum
EndAtoI:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
AtoI ENDP

LoadLeaderboardData PROC
    mov edx, OFFSET filename
    call OpenInputFile
    cmp eax, INVALID_HANDLE_VALUE
    je NoFileFound
    mov fileHandle, eax
    mov eax, fileHandle
    mov edx, OFFSET fileBuffer
    mov ecx, 5000 
    call ReadFromFile
    mov eax, fileHandle
    call CloseFile
    mov ecx, eax 
    mov edi, OFFSET fileBuffer 
    mov esi, 0 
ParseLoop:
    cmp esi, 10
    jge ParseDone 
    cmp ecx, 0
    jle ParseDone 
    push esi 
    mov eax, esi
    imul eax, 30
    lea edx, leaderboardNames[eax] 
CopyName:
    mov al, [edi]
    cmp al, ':' 
    je NameDone
    cmp al, 0Dh 
    je NameDone
    cmp ecx, 0
    je ParseDone
    mov [edx], al
    inc edi
    inc edx
    dec ecx
    jmp CopyName
NameDone:
    mov BYTE PTR [edx], 0 
    pop esi 
    cmp ecx, 0
    je ParseDone
    inc edi 
    dec ecx
SkipSpaces:
    cmp ecx, 0
    je ParseDone
    mov al, [edi]
    cmp al, ' '
    jne ReadScore
    inc edi
    dec ecx
    jmp SkipSpaces
ReadScore:
    push esi
    mov edx, OFFSET writeBuffer
CopyScoreStr:
    cmp ecx, 0
    je ScoreStrDone
    mov al, [edi]
    cmp al, 0Dh 
    je ScoreStrDone
    cmp al, 0Ah 
    je ScoreStrDone
    mov [edx], al
    inc edi
    inc edx
    dec ecx
    jmp CopyScoreStr
ScoreStrDone:
    mov BYTE PTR [edx], 0 
    pop esi
    push edi
    push ecx
    push esi
    mov edi, OFFSET writeBuffer
    call AtoI
    pop esi
    mov leaderboardScores[esi*4], eax
    pop ecx
    pop edi
SkipCRLF:
    cmp ecx, 0
    je ParseDone
    mov al, [edi]
    cmp al, 0Dh
    je DoSkip
    cmp al, 0Ah
    je DoSkip
    jmp NextEntry
DoSkip:
    inc edi
    dec ecx
    jmp SkipCRLF
NextEntry:
    inc esi
    jmp ParseLoop
ParseDone:
    ret
NoFileFound:
    ret
LoadLeaderboardData ENDP

SaveGameState PROC
    mov  edx, OFFSET saveFileName
    call CreateOutputFile
    mov  saveHandle, eax
    mov  eax, saveHandle
    mov  edx, OFFSET GAME_STATE_START
    mov  ecx, GAME_STATE_SIZE       
    call WriteToFile
    mov  eax, saveHandle
    call CloseFile
    ret
SaveGameState ENDP

LoadGameState PROC
    mov  edx, OFFSET saveFileName
    call OpenInputFile
    cmp  eax, INVALID_HANDLE_VALUE
    je   LoadFailed            
    mov  saveHandle, eax
    mov  eax, saveHandle
    mov  edx, OFFSET GAME_STATE_START
    mov  ecx, GAME_STATE_SIZE
    call ReadFromFile
    mov  eax, saveHandle
    call CloseFile
    call PlayGame             
    ret
LoadFailed:
    ret
LoadGameState ENDP

UpdateLeaderboard PROC

    mov eax, curScore
    
    mov ecx, 10
    mov esi, 0
CheckLoop:
    mov eax, curScore
    cmp eax, leaderboardScores[esi*4]
    jge InsertScore 
    inc esi
    loop CheckLoop
    jmp UpdateDone

InsertScore:
    mov ebx, 9
ShiftLoop:
    cmp ebx, esi
    jle DoInsert
    
    mov edi, ebx
    dec edi         
    
    mov eax, leaderboardScores[edi*4]
    mov leaderboardScores[ebx*4], eax
    
    push esi
    push edi
    push ecx
    
    mov eax, ebx
    imul eax, 30
    lea edi, leaderboardNames[eax] 
    
    mov eax, ebx
    dec eax
    imul eax, 30
    lea esi, leaderboardNames[eax] 
    
    mov ecx, 30
    rep movsb
    
    pop ecx
    pop edi
    pop esi
    
    dec ebx
    jmp ShiftLoop

DoInsert:
    mov eax, curScore
    mov leaderboardScores[esi*4], eax
    
    push esi
    push edi
    push ecx
    
    mov eax, esi
    imul eax, 30
    lea edi, leaderboardNames[eax]
    
    mov  edx, OFFSET playerName
    mov  ecx, playerNameLen
    
    mov esi, edx
    rep movsb
    
    mov ecx, 30
    sub ecx, playerNameLen
    cmp ecx, 0
    jle SkipPad
    mov al, 0
    rep stosb
SkipPad:
    
    pop ecx
    pop edi
    pop esi
    
    call SaveLeaderboardToFile
    
    mov eax, 10
    call SetTextColor
    mov edx, OFFSET scoreSavedMsg
    call WriteString
    mov eax, 1000
    call Delay
    mov eax, 15
    call SetTextColor
    
UpdateDone:
    ret
UpdateLeaderboard ENDP
SaveLeaderboardToFile PROC
    mov  edx, OFFSET filename
    call CreateOutputFile
    mov  fileHandle, eax
    
    mov ecx, 10
    mov esi, 0
SaveLBLoop:
    push ecx
    

    mov eax, esi
    imul eax, 30
    lea edx, leaderboardNames[eax] 
    push edx
    call StrLength
    pop edx
    cmp eax, 0
    je SkipWrite 

    
    mov eax, fileHandle
    push eax 
    mov eax, esi
    imul eax, 30
    lea edx, leaderboardNames[eax] 
    pop eax 
    push edx
    call StrLength
    mov ecx, eax
    pop edx
    call WriteToFile
    
    ; 3. Write Separator " : "
    mov eax, fileHandle
    mov edx, OFFSET sepStr
    mov ecx, 3
    call WriteToFile

    mov eax, leaderboardScores[esi*4]
    mov edi, OFFSET writeBuffer
    call IntToString    
    
    mov eax, fileHandle
    mov edx, OFFSET writeBuffer
    call StrLength
    mov ecx, eax
    call WriteToFile

    mov eax, fileHandle
    mov edx, OFFSET newLineStr
    mov ecx, 2
    call WriteToFile
    
SkipWrite:
    inc esi
    pop ecx
    dec ecx
    jnz SaveLBLoop
    
    mov eax, fileHandle
    call CloseFile
    ret
SaveLeaderboardToFile ENDP

IntToString PROC
    
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    mov ebx, eax 
    
    
    cmp eax, 0
    jge IsPositive

    mov BYTE PTR [edi], '-' 
    inc edi
    neg ebx      
    
IsPositive:
    mov eax, ebx 
    mov ebx, 10
    mov ecx, 0
    
    ; Handle 0 explicitly
    cmp eax, 0
    jnz PushDigits
    mov dl, '0'
    push dx
    inc ecx
    jmp PopDigits
    
PushDigits:
    mov edx, 0
    div ebx      
    add dl, '0'  
    push dx
    inc ecx
    test eax, eax
    jnz PushDigits
    
PopDigits:
    pop dx
    mov [edi], dl
    inc edi
    loop PopDigits
    
    mov BYTE PTR [edi], 0 
    
    pop edi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
IntToString ENDP

ViewLeaderboard PROC
    call Clrscr
    mov eax, 11
    call SetTextColor
    mov  edx, OFFSET lbBorder
    call WriteString
    call Crlf
    call Crlf
    mov eax, 15
    call SetTextColor
    mov ecx, 10
    mov esi, 0
ViewLoop:
    mov eax, leaderboardScores[esi*4]
    cmp eax, 0
    je  SkipView
    mov eax, esi
    imul eax, 30
    lea edx, leaderboardNames[eax]
    call WriteString
    mov edx, OFFSET sepStr
    call WriteString
    mov eax, leaderboardScores[esi*4]
    call WriteDec
    call Crlf
SkipView:
    inc esi
    loop ViewLoop
    call Crlf
    mov eax, 11
    call SetTextColor
    mov edx, OFFSET instFooter
    call WriteString
    call Crlf
    call Crlf
    mov eax, 14
    call SetTextColor
    mov edx, OFFSET pressKey
    call WriteString
    call ReadChar
    ret
ViewLeaderboard ENDP


GameOver PROC
    call Clrscr
    
    ; 1. Display Title (Red)
    mov eax, 12 ; Red color
    call SetTextColor
    
    mov dl, 30 ; Center X position
    mov dh, 5
    call Gotoxy
    mov edx, OFFSET gameOverTitle
    call WriteString
    call Crlf
    call Crlf

    ; 2. Display Final Score and Name
    mov eax, 15 ; White color
    call SetTextColor
    
    mov dl, 25 
    mov dh, 8
    call Gotoxy
    mov edx, OFFSET playerName
    call WriteString
    mov edx, OFFSET score
    call WriteString
    mov eax, curScore
    call WriteInt
    call Crlf
    
    mov eax, 14 ; Yellow color for menu options
    call SetTextColor
    
    mov dl, 35
    mov dh, 12
    call Gotoxy
    mov edx, OFFSET gameOverOption1
    call WriteString
    
    mov dl, 35
    mov dh, 14
    call Gotoxy
    mov edx, OFFSET gameOverOption2
    call WriteString
    
    ; 5. Get User Input
    mov dl, 35
    mov dh, 16
    call Gotoxy
    mov edx, OFFSET gameOverPrompt
    call WriteString
    call ReadInt
    
    cmp eax, 1
    je RestartGame      
    jmp ReturnToMenu     

RestartGame:
    
    call InitialGame 
    call PlayGame    
    jmp FinishGameOver
    
ReturnToMenu:
    ret              

FinishGameOver:
    ret
GameOver ENDP


InitialGame PROC
    mov  taxiX,     2
    mov  taxiY,     2
    mov  curScore,  0
    mov  passCount, 0
    mov  hasPass,   0
    mov  timeLimit, 60 
    call mapGen
    call SpawnStaticObjects
    call RanObj
    ret
InitialGame ENDP

mapGen PROC
    mov esi, OFFSET initialBoardLayout
    mov edi, OFFSET boardMap
    mov ecx, 400        
    rep movsb           
    ret
mapGen ENDP

SpawnStaticObjects PROC
    mov ecx, NUM_OBSTACLES
ObsLoop:
    push ecx
    call RandomPos 
    movzx eax, dh
    imul  eax, 20
    movzx ebx, dl
    add   eax, ebx
    mov boardMap[eax], obstacle
    pop ecx
    loop ObsLoop
    ret

SpawnStaticObjects ENDP
    
RanObj PROC
    mov ecx, MAX_PASSENGERS
    mov esi, 0
InitPassLoop:
    push ecx
    call RandomPos
    mov  passX[esi], dl
    mov  passY[esi], dh
    call RandomPos
    mov  passDestX[esi], dl
    mov  passDestY[esi], dh
    mov  passStatus[esi], 1
    inc esi
    pop ecx
    loop InitPassLoop
    mov ecx, NUM_BONUS
    mov esi, 0
InitBonusLoop:
    push ecx
    push esi
    call RandomPos
    pop esi
    mov bonusX[esi], dl
    mov bonusY[esi], dh
    inc esi
    pop ecx
    loop InitBonusLoop
    mov ecx, NUM_CARS
    mov esi, 0
InitCarLoop:
    push ecx
    push esi
    call RandomPos
    pop esi
    mov enemyX[esi], dl
    mov enemyY[esi], dh
    mov eax, 4
    call RandomRange
    mov enemyDir[esi], al
    inc esi
    pop ecx
    loop InitCarLoop
    ret
RanObj    ENDP

RandomPos PROC
Retry:
    mov  eax, 18
    call RandomRange
    inc  eax
    mov  dl,  al
    mov  eax, 18
    call RandomRange
    inc  eax
    mov  dh,  al
    movzx eax,           dh
    imul  eax,           20
    movzx ebx,           dl
    add   eax,           ebx
    cmp   boardMap[eax], road 
    jne   Retry
    ret
RandomPos ENDP


PlayGame  PROC
    call Clrscr                 
Gamloop:
    mov dl, 0
    mov dh, 0
    call Gotoxy                 
    call DrawMap
    call DrawHUD
    call ReadKey          
    cmp al, 'p'
    je  PauseGame
    cmp al, 'P'
    je  PauseGame
    cmp al, ' '
    je  Interact
    cmp al, 0
    jne StandardKey
    cmp ah, 48h
    je GoUp_A
    cmp ah, 50h
    je GoDown_A
    cmp ah, 4Bh
    je GoLeft_A
    cmp ah, 4Dh
    je GoRight_A
    jmp ContinueLoop
StandardKey:
    cmp al, 'w'
    je GoUp_A
    cmp al, 's'
    je GoDown_A
    cmp al, 'a'
    je GoLeft_A
    cmp al, 'd'
    je GoRight_A
    jmp ContinueLoop
GoUp_A:
    mov al, 'w'
    jmp DoMove
GoDown_A:
    mov al, 's'
    jmp DoMove
GoLeft_A:
    mov al, 'a'
    jmp DoMove
GoRight_A:
    mov al, 'd'
    jmp DoMove
DoMove:
    push eax
    call MovePlayer
    pop eax
    jmp ContinueLoop
Interact:
    call InteractSpacebar
    jmp ContinueLoop
PauseGame:
    INVOKE Beep, 800, 100 
PauseLoop:
    call ReadChar               
    cmp  al, 'p'
    je   Unpause
    cmp  al, 'P'
    je   Unpause
    jmp  PauseLoop
Unpause:
    INVOKE Beep, 600, 100
    mov eax, 13
    jmp  Gamloop                
ContinueLoop:
    jz   NoInput                
    cmp al, 'e'
    je  ExitGameHandler
    cmp al, 'E'
    je  ExitGameHandler
NoInput:
    cmp gameMode, 1         
    jne CheckTimeMode       
    cmp curScore, 100       
    jge YouWinHandler       
    cmp gameMode, 2          
    jne SkipTimeLogic
    inc frameCounter
    cmp frameCounter, 2     
    jl  SkipTimeLogic
    mov frameCounter, 0
    dec timeLimit
    cmp timeLimit, 0
    je  GameOverHandler
    jmp Gamloop

CheckTimeMode:
    cmp gameMode, 2          
    jne SkipTimeLogic
    inc frameCounter
    cmp frameCounter, 5
    jl  SkipTimeLogic
    mov frameCounter, 0
    dec timeLimit
    cmp timeLimit, 0
    je  GameOverHandler             
    jmp Gamloop
YouWinHandler:
    call Clrscr
    mov eax, 10 ; Green Color
    call SetTextColor
    
    mov dl, 30
    mov dh, 10
    call Gotoxy
    mov edx, OFFSET winTitle
    call WriteString
    
    inc dh
    call Gotoxy
    mov edx, OFFSET winMsg
    call WriteString
    call SaveGameState
    
    mov eax, 2000 
    call Delay
    
    call GameOver 
    ret
GameOverHandler:
    call UpdateLeaderboard
    call GameOver
    ret

ExitGameHandler:
    call UpdateLeaderboard
    call SaveGameState 
    call GameOver        
    ret

SkipTimeLogic:
    mov eax, gameSpeed        
    call Delay
    inc enemyTimer
    cmp enemyTimer, 5            
    jl  SkipEnemy
    mov enemyTimer, 0
    call MoveEnemy
SkipEnemy:
    jmp  Gamloop                 
PlayGame ENDP

InteractSpacebar PROC
    cmp hasPass, 1
    je  TryDrop        


    mov ecx, MAX_PASSENGERS
    mov esi, 0
LoopPickup:
    cmp passStatus[esi], 1
    jne NextPickup     
    
    ; Calculate |TaxiX - PassX|
    mov al, taxiX
    mov ah, passX[esi]
    sub al, ah
    call AbsoluteValue ; AL now holds |DX|
    cmp al, PICKUP_RANGE
    jg  NextPickup     
    
    ; Calculate |TaxiY - PassY|
    mov al, taxiY
    mov ah, passY[esi]
    sub al, ah
    call AbsoluteValue ; AL now holds |DY|
    cmp al, PICKUP_RANGE
    jg  NextPickup   
   
    mov hasPass, 1
    mov passStatus[esi], 0 
    mov al, passDestX[esi]
    mov currentDestX, al
    mov al, passDestY[esi]
    mov currentDestY, al
    INVOKE Beep, 800,600    
    mov eax, 14
    call SetTextColor
    mov edx, OFFSET pickMsg
    call WriteString
    mov eax, 500
    call Delay
    mov eax, 15
    call SetTextColor
    ret

NextPickup:
    inc esi
    dec ecx
    cmp ecx, 0
    je EndLoopPickup
    jmp LoopPickup
EndLoopPickup:
    ret ; No pickup possible


TryDrop:
    mov al, taxiX
    cmp al, currentDestX
    jne NoDrop ; Not at destination X
    mov al, taxiY
    cmp al, currentDestY
    jne NoDrop ; Not at destination Y
    
 
    add  curScore, dropP
   INVOKE Beep, 1000,600
    inc  passCount
    
    ; Increase speed every 2 drops
    inc dropsForSpeed
    cmp dropsForSpeed, 2
    jl NoSpeedInc
    mov dropsForSpeed, 0
    sub gameSpeed, 5
    cmp gameSpeed, 10 
    jge NoSpeedInc
    mov gameSpeed, 10
NoSpeedInc:

    mov  hasPass, 0
   
    
    mov eax, 10
    call SetTextColor
    mov edx, OFFSET dropMsg
    call WriteString
    mov eax, 500
    call Delay
    mov eax, 15
    call SetTextColor
    
  
    mov ecx, MAX_PASSENGERS
    mov esi, 0
RespawnLoop:
    cmp passStatus[esi], 0
    jne NextRespawn
    push ecx
    push esi
    call RandomPos
    pop esi
    mov passX[esi], dl
    mov passY[esi], dh
    push esi
    call RandomPos
    pop esi
    mov passDestX[esi], dl
    mov passDestY[esi], dh
    mov passStatus[esi], 1
    pop ecx
    jmp CheckSpeed
NextRespawn:
    inc esi
    dec ecx
    cmp ecx, 0
    je EndRespawnLoop
    jmp RespawnLoop
EndRespawnLoop:
CheckSpeed:
    ret
    
NoDrop:
    ret 
InteractSpacebar ENDP

AbsoluteValue PROC
   
    cmp al, 0
    jge IsPositive
    neg al 
IsPositive:
    ret
AbsoluteValue ENDP

ChkPassHit PROC
    
    mov al, 0 
    push ebx
    push ecx
    push esi
    
    mov ecx, MAX_PASSENGERS
    mov esi, 0
PassHitLoop:

    mov ah, passStatus[esi]
    cmp ah, 1
    jne NextPassHit
   
    mov ah, passX[esi]
    cmp bl, ah
    jne NextPassHit
   
    mov ah, passY[esi]
    cmp bh, ah
    jne NextPassHit
  
    mov al, 1
    jmp HitDone
    
NextPassHit:
    inc esi
    loop PassHitLoop
    
HitDone:
    pop esi
    pop ecx
    pop ebx
    ret
ChkPassHit ENDP

MovePlayer PROC
    mov bl, taxiX
    mov bh, taxiY
    cmp al, 'w'
    je  GoUp
    cmp al, 's'
    je  Godown
    cmp al, 'a'
    je  Goleft
    cmp al, 'd'
    je  GoRight
    ret
GoUp:
    dec bh
    jmp Checker
Godown:
    inc bh
    jmp Checker
Goleft:
    dec bl
    jmp Checker
GoRight:
    inc bl
    jmp Checker
Checker:
    call CheckAccident
    cmp  al,    1
    je   HitWall
    cmp  al,    2
    je   HitObs
    cmp  al,    3
    je   HitPass
    mov  taxiX, bl
    mov  taxiY, bh
    call CheckPickups
    ret
HitWall:
    INVOKE Beep, 1000, 400
    mov  eax, penaltyWall
    sub  curScore, eax
    mov  eax, 12
    call SetTextColor
    mov  edx, OFFSET crashMsg
    call WriteString
    mov  eax, penaltyWall
    call WriteInt
    mov  eax, 500
    call Delay
    mov  eax, 15
    call SetTextColor
    ret
HitObs:
    INVOKE Beep, 400, 150
    mov  eax, penaltyWall
    sub  curScore, eax
    mov  eax, 12
    call SetTextColor
    mov  edx, OFFSET obsMsg
    call WriteString
    mov  eax, penaltyWall
    call WriteInt
    mov  eax, 500
    call Delay
    mov  eax, 15
    call SetTextColor
    ret
HitPass: 
   INVOKE Beep, 1000, 80
    sub  curScore, 5 ; Use the same penalty as pedestrian
    mov  eax, 12
    call SetTextColor
    mov  edx, OFFSET pedMsg ; Reuse the "HIT PERSON!" message
    call WriteString
    mov  eax, 500
    call Delay
    mov  eax, 15
    call SetTextColor
    ret
MovePlayer    ENDP

CheckAccident PROC
    movzx eax,            bh
    imul  eax,            20
    movzx edx,            bl
    add   eax,            edx
    cmp   boardMap[eax], wall
    je    IsW
    cmp   boardMap[eax], obstacle
    je    IsObs

    call  ChkPassHit 
    cmp   al, 1
    je    IsPassHit  

    mov   al, 0
    ret
IsW:
    mov al, 1
    ret
IsObs:
    mov al, 2
    ret
IsPassHit: 
    mov al, 3
    ret
IsPed:
    mov al, 3
    ret
CheckAccident ENDP

ApplyCrashPenalty PROC
    mov eax, carCrashPenalty
    sub curScore, eax
    mov  eax,       12
    call SetTextColor
    mov  edx,       OFFSET hitCarMsg
    call WriteString
    mov  eax, carCrashPenalty
    call WriteInt
    mov  eax, 500
    call Delay
    mov  eax, 15
    call SetTextColor
    ret
ApplyCrashPenalty ENDP

CheckPickups  PROC
    mov ecx, NUM_CARS
    mov esi, 0
ChkCarLoop:
    mov  al,        taxiX
    cmp  al,        enemyX[esi]
    jne  NextCar
    mov  al,        taxiY
    cmp  al,        enemyY[esi]
    jne  NextCar
    call ApplyCrashPenalty
    jmp CheckBonus
NextCar:
    inc esi
    dec ecx
    cmp ecx, 0
    je EndChkCar
    jmp ChkCarLoop
EndChkCar:
CheckBonus:
    mov ecx, NUM_BONUS
    mov esi, 0
BonusLoop:
    mov  al,        taxiX
    cmp  al,        bonusX[esi]
    jne  NextBonus
    mov  al,        taxiY
    cmp  al,        bonusY[esi]
    jne  NextBonus
    add  curScore, bonusp

    mov  eax,       14
    call SetTextColor
    mov  edx,       OFFSET bonusMsg
    call WriteString
    mov  eax,       500
    call Delay
    mov  eax,       15
    call SetTextColor
    push ecx
    push esi
    call RandomPos
    pop esi
    mov bonusX[esi], dl
    mov bonusY[esi], dh
    pop ecx
NextBonus:
    inc esi
    dec ecx
    jnz BonusLoop
    ret
CheckPickups ENDP

MoveEnemy    PROC
    mov ecx, NUM_CARS
    mov esi, 0
MoveCarLoop:
    push ecx
    push esi
    mov bl, enemyX[esi]
    mov bh, enemyY[esi]
    cmp enemyDir[esi], 0
    je GoUp
    cmp enemyDir[esi], 1
    je GoDown
    cmp enemyDir[esi], 2
    je GoLeft
    cmp enemyDir[esi], 3
    je GoRight
GoUp:
    dec bh
    jmp CheckMove
GoDown:
    inc bh
    jmp CheckMove
GoLeft:
    dec bl
    jmp CheckMove
GoRight:
    inc bl
    jmp CheckMove
CheckMove:
    cmp bl, taxiX
    jne WallCheck
    cmp bh, taxiY
    jne WallCheck
    call ApplyCrashPenalty
WallCheck:
    movzx eax, bh
    imul  eax, 20
    movzx edx, bl
    add   eax, edx
    cmp   boardMap[eax], wall
    jne   ValidMove
    xor enemyDir[esi], 1
    jmp DoneMove
ValidMove:
    mov enemyX[esi], bl
    mov enemyY[esi], bh
DoneMove:
    pop esi
    pop ecx
    inc esi
    dec ecx
    cmp ecx, 0
    je EndMoveCar
    jmp MoveCarLoop
EndMoveCar:
    ret
MoveEnemy ENDP


DrawMap PROC
    mov esi, 0 
    mov ecx, 0 
R_L:
    mov ebx, 0 
C_L:
    movzx eax, taxiY
    cmp   ecx, eax
    jne   ChkEnemy
    movzx eax, taxiX
    cmp   ebx, eax
    jne   ChkEnemy
    mov   eax, taxiColor
    call  SetTextColor
    mov   al,  219
    call  WriteChar
    call  WriteChar
    jmp   NextTile
ChkEnemy:
    push ecx
    push ebx
    push esi
    mov ecx, NUM_CARS
    mov esi, 0
DrawCarLoop:
    movzx eax, enemyY[esi]
    cmp eax, [esp+8] 
    jne NextCarDraw
    movzx eax, enemyX[esi]
    cmp eax, [esp+4] 
    jne NextCarDraw
    mov eax, 9 
    call SetTextColor
    mov al, 'X'
    call WriteChar
    mov al, ' '
    call WriteChar
    pop esi
    pop ebx
    pop ecx
    jmp NextTile
NextCarDraw:
    inc esi
    dec ecx
    cmp ecx, 0
    je EndDrawCar
    jmp DrawCarLoop
EndDrawCar:
    pop esi
    pop ebx
    pop ecx
ChkPass:
    push ecx 
    push ebx 
    push esi 
    mov ecx, MAX_PASSENGERS
    mov esi, 0
DrawPassLoop:
    cmp passStatus[esi], 1 
    jne NextPassDraw
    movzx eax, passY[esi]
    cmp eax, [esp+8] 
    jne NextPassDraw
    movzx eax, passX[esi]
    cmp eax, [esp+4] 
    jne NextPassDraw
    mov eax, 11 
    call SetTextColor
    mov al, 'P'
    call WriteChar
    mov al, ' '
    call WriteChar
    pop esi
    pop ebx
    pop ecx
    jmp NextTile
NextPassDraw:
    inc esi
    dec ecx
    cmp ecx, 0
    je EndDrawPass
    jmp DrawPassLoop
EndDrawPass:
    pop esi
    pop ebx
    pop ecx
    cmp hasPass, 1
    jne ChkBonus
    movzx eax, currentDestY
    cmp ecx, eax
    jne ChkBonus
    movzx eax, currentDestX
    cmp ebx, eax
    jne ChkBonus
    mov eax, 10 
    call SetTextColor
    mov al, 'D'
    call WriteChar
    mov al, ' '
    call WriteChar
    jmp NextTile
ChkBonus:
    push ecx
    push ebx
    push esi
    mov ecx, NUM_BONUS
    mov esi, 0
DrawBonusLoop:
    movzx eax, bonusY[esi]
    cmp eax, [esp+8]
    jne NextBonusDraw
    movzx eax, bonusX[esi]
    cmp eax, [esp+4]
    jne NextBonusDraw
    mov eax, 13 
    call SetTextColor
    mov al, '$'
    call WriteChar
    mov al, ' '
    call WriteChar
    pop esi
    pop ebx
    pop ecx
    jmp NextTile
NextBonusDraw:
    inc esi
    dec ecx
    cmp ecx, 0
    je EndDrawBonus
    jmp DrawBonusLoop
EndDrawBonus:
    pop esi
    pop ebx
    pop ecx
DrawTile:
    cmp  boardMap[esi], wall
    je   D_W
    cmp  boardMap[esi], obstacle
    je   D_Obs
    mov  eax,            8
    call SetTextColor
    mov  al,             '.'
    call WriteChar
    mov  al,             ' '
    call WriteChar
    jmp  NextTile
D_W:
    mov  eax, 7
    call SetTextColor
    mov  al,  219
    call WriteChar
    call WriteChar
    jmp NextTile
D_Obs:
    mov  eax, 2 
    call SetTextColor
    mov  al,  'T' 
    call WriteChar
    mov  al,  ' '
    call WriteChar
    jmp NextTile

NextTile:
    inc  esi
    inc  ebx
    cmp  ebx, mapWidth
    jl   C_L
    call Crlf
    inc  ecx
    cmp  ecx, mapHeight
    jl   R_L
    mov  eax, 15
    call SetTextColor
    ret
DrawMap ENDP

DrawHUD PROC
    call Crlf
    mov  edx, OFFSET playerName
    call WriteString
    mov  al, ' '
    call WriteChar
    mov  edx, OFFSET score
    call WriteString
    mov  eax, curScore
    call WriteInt
    cmp gameMode, 2
    jne SkipTimeDisplay
    mov  edx, OFFSET timeMsg
    call WriteString
    mov  eax, timeLimit
    call WriteDec
SkipTimeDisplay:
    mov  edx, OFFSET pass
    call WriteString
    mov  eax, passCount
    call WriteDec
    mov  al, ' '
    call WriteChar
    call WriteChar
    call WriteChar
    call WriteChar
    call Crlf
    ret
DrawHUD  ENDP

END main
