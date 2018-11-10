devices =
    keyboard: false
    mouse: false
    touch: false
keyboard = {vkeys:{}}
keyboard.addKeys=(vkey, ...keys)!->
    if keyboard[vkey]?
        for key in keyboard[vkey]keys
            key.keyDown.removeAll!
        return
    input =!->
        for key in input.keys
            return true if key.isDown
        return false
    input.keys = []
    for key in keys
        input.keys.push game.input.keyboard.addKey Phaser.Keyboard[key]
    input.newSignal =(signal)!->
        input[signal]=
            signal: signal
            add: (listener, context, priority)!-> for key in input.keys
                key[@signal]add listener, context, priority
            addOnce: (listener, context, priority)!-> for key in input.keys
                key[@signal]addOnce listener, context, priority
    input.newSignal \onDown
    input.newSignal \keyDown
    for key in input.keys
        key.keyDown = new Phaser.Signal!
        key.processKeyDown2 = key.processKeyDown
        key.processKeyDown =!-> @keyDown.dispatch!; @processKeyDown2 ...
    keyboard.vkeys[vkey] = keyboard[vkey] = input

#resets any stuck keyboard keys
!function reset_keyboard
    for k of keyboard.vkeys then for key in keyboard.vkeys[k]keys
        key.isDown=false

input_mod=[]
    
!function input_initialize
    game.input.keyboard.enabled=true
    mouse.down = false
    game.canvas.oncontextmenu = onContextMenu
    game.input.onDown.add onDown_mouse
    game.input.onUp.add onUp_mouse

    keyboard.addKeys 'up', 'UP' 'W'
    keyboard.addKeys 'left', 'LEFT' 'A'
    keyboard.addKeys 'down', 'DOWN' 'S'
    keyboard.addKeys 'right', 'RIGHT' 'D'
    keyboard.addKeys 'confirm', 'SPACEBAR' 'ENTER' 'Z' 'C'
    keyboard.addKeys 'cancel', 'ESC' 'TAB' 'X'
    keyboard.addKeys 'dash', 'SHIFT'

    for f in input_mod
        f?!

    game.input.keyboard.onDownCallback =!-> devices.keyboard = true unless devices.keyboard
    
    game.input.mouse.mouseWheelCallback = mousewheel_controller

!function input_battle 
    input_initialize!
    #game.input.mouse.mouseWheelCallback = mousewheel_controller
    
!function input_overworld
    input_initialize!
    #game.input.mouse.mouseWheelCallback = mousewheel_controller

    game.input.onDown.add mousedown_player
    game.input.onTap.add mousetap_player
    keyboard.confirm.onDown.add player_confirm_button

onDown_up =!->
onDown_left =!->
onDown_down =!->
onDown_right =!->
!function onDown_confirm
    player?confirm_button! unless dialog?click!
onDown_cancel =!->

mouse = x:0, y:0, down:false, world: {x:0, y: 0}
,update: !->
    #mouse tracking
    @x = game.input.x / (window.innerWidth / game.width) .|. 0
    @y = game.input.y / (window.innerHeight / game.height) .|. 0
    @world.x = @x + game.camera.x
    @world.y = @y + game.camera.y
!function onDown_mouse (e)
    #console.log(e.button)
    if e is game.input.mousePointer
        devices.mouse = true unless devices.mouse
    else
        devices.touch = true unless devices.touch

    return unless nullbutton e.button
    mouse.down = true unless actors?paused
    mouse.update! if mouse.down
    #console.log "tap! x:"+mouse.x+" y:"+mouse.y
!function onUp_mouse
    mouse.down = false
    
!function mousewheel_controller (e)
    mousewheel_player e if game.state.current is \overworld and not actors?paused
    for menu in Menu.list
        menu.scroll e if menu.alive
    e.prevent-default!
    return false
    
!function onContextMenu (e)
    e.prevent-default!
    return false

!function nullbutton (button)
    return button in [0,null,undefined]


## SCREENSHOT CODE
# pixel.canvas.toBlob(function(blob){console.log(window.URL.createObjectURL(blob))})