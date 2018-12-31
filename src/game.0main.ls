STARTMAP = 'shack2'
version = "Release"
version_number = '1.1.2'
switches = 
    sp_limit: {}
    water_walking: false
    map: STARTMAP
    outside: true
    #merchant: false
    checkpoint: ''
    checkpoint_map: ''
    gxp: 0
    cinema: false
    spawning: false
    name: 'Wilhelm'
    soulcluster: true
    progress: \tutorial
    progress2: 0
    version:version
    mode:\story
    #towerswitch1: true
    #towerswitch2: true
session={}
warpzones=
    {id:'earth',name:"Earth",map:\earth,node:\landing,dir:\right}
    {id:'delta',name:"Tuonen Delta",map:\delta,node:\landing,dir:\up}
    {id:'hub1',name:"Tower Village",map:\hub,node:\landing,dir:\down}
    {id:'hub2',name:"Tower Outskirts",map:\hub,node:\landing2,dir:\down}
    {id:'deadworld',name:"Dead World",map:\deadworld,node:\landing,dir:\up}
    {id:'curecamp',name:"Cure Camp",map:\deadworld,node:\landing2,dir:\up}
unlocalized_zones=[];
unlocalized_pentagrams=[];
pentagrams=
    "Abyss":
        void_cp: "Tuonen Falls"
        void_cp2: "The End"
    "Earth":
        earth_cp: "Ruins of Earth"
        earth_cp1: "Last Hope Lab"
        basement1_cp: "Basement"
        earth2_cp: "Wilderness"
        earth3_cp: "Black Meadow"
    "Tuonen Delta":
        delta_cp1: "Delta Landing"
        delta_cprab: "Rabies Hideout"
        delta_cpsars: "Sars Hideout"
        delta_cpaids: "Eidzu Hideout"
    "Tuonen River":
        hub_hub: "Tower Village"
        hub_cp1: "Tower Outskirts"
        tunneldeep_cp: "Tunnel Depths"
    "Black Tower":
        tower0_cp: "Ground Floor"
        towertop_cp: "Rooftop Cemetary"
    "Dead World":
        deadworld_cp0: "Dead Landing"
        deadworld_cp1: "Herpes Shop"
        deadworld_cp2: "Cure Camp"
        deadworld_stage: "Concert Hill"
        deadworld_dt: "Death Tunnel"
        deathdomain_cp: "Death Castle"



temp={}

## DUNGEON MODE (planned)
#switch_dungeon = 
#    sp_limit: 1
#    water_walking: false
#    map: STARTMAP
#    outside: false
#    checkpoint: ''#dungeon start
#    checkpoint_map: ''#dungeon start
#    seed: 0
#    cinema: false
#    spawning: false
#    name: 'Wilhelm'
#    version:version
#    mode:\dungeon

switch_defaults = clone switches
const multiplesaves=false


create_title_background =!->
    create_gui!
    game.camera.roundPx = true
    game.camera.bounds = false
    game.camera.x = 0; game.camera.y = 0;
    #start_camera.call x:WIDTH/2, y:HEIGHT/2

    #----------------------
    # Background
    gs=[]
    divs = 40
    for i from -1 to divs
        gs.unshift gui.title.create 0 (i>?0)*HEIGHT/divs, \solid
        gs.0.height = HEIGHT/divs
    gs[gs.length - 1].anchor.set 0 1
    gs.splice 1 0 gui.title.create 0 HEIGHT, \solid
    gs.1.height = 16 #MAGIC NUMBER!

    colorstart = 0xffaa88
    colorend = 0xfff8f8
    colorstart = makecolor(r:Math.random!*255,g:Math.random!*255,b:Math.random!*255,false)

    for g, i in gs
        g.update =!->
            #@tint += Math.random!*20 - 10
        adjustheight = i is 0 or i is gs.length - 1
        resize_callback g, title_bg, [adjustheight]
        title_bg.call g, adjustheight
        g.ig = i/gs.length <? 0.8
        #g.tint = oldmultcolor 0xffffff (i / gs.length)
        #g.tint = 0xffffff * (i / gs.length)
        #g.tint = gradient 0xffaaaa 0xffffff (i / gs.length)
        #g.tint = gradient colorstart, colorend, Math.floor(10*(g.ig + (Math.sin(100*g.ig^2)/10)))/10
    #gs.1.tint = gradient colorstart, colorend, 0.2
    shiftingcolors!

    !function shiftingcolors
        color1 = colorstart
        color2 = makecolor(r:Math.random!*255,g:Math.random!*255,b:Math.random!*255,false)
        new Transition 30000 (t)->
            return unless game.state.current is \title or game.state.current is \preload or game.state.current is \boot
            color3 = gradient color1, color2, t
            for g in gs
                g.tint = gradient color3, colorend, Math.floor(10*(g.ig + (Math.sin(100*g.ig^2)/10)))/10
            gs.1.tint = gradient color3, colorend, 0.2
        ,->
            return unless game.state.current is \title or game.state.current is \preload or game.state.current is \boot
            colorstart := color2
            shiftingcolors!
        ,0 false

    #----------------------
    # Foreground
    gui.title.create -11 -7 'title'

state.reload.create =!->
    gui.frame.removeAll true
    game.stage.disableVisibilityChange = true
    create_title_background!
    game.state.start 'title'


!function title_bg (adjustheight)
    @width = game.width
    @x = -(game.width - WIDTH)/2
    @height = (game.height - HEIGHT)/2 if adjustheight

var solidscreen, cg
state.title.create =!->
    game.stage.disableVisibilityChange = !gameOptions.pauseidle
    input_initialize!
    create_audio!

    logo = gui.title.create 0 0 \logo
    logo.update=!->
        @x=-Math.round @parent.x/2;
        @y=-Math.round @parent.y/2;
    gui.title.add-child <| versiontext=new Text 'font_yellow', version_number,WIDTH - WS*6,HEIGHT
    versiontext.anchor.set 1 1
    #menu = new Menu WIDTH - TS*6 HEIGHT - TS*6 6 6 |> gui.frame.add-child
    #args = ['New Game' newgame]
    #args.unshift if true then load else 0
    #args.unshift 'Continue'
    #menu.set.apply menu, args
    create_title_menu!
    #create_option_menu!
    #music.play \title

    #game.state.start 'overworld', false

    #additional one time setup
    solidscreen := new Phaser.Image game, 0 0 \solid |> gui.add-child
    resize_callback solidscreen, solidscreenresize
    solidscreenresize.call solidscreen
    solidscreen.alpha = 0
    solidscreen.tint = 0
    !function solidscreenresize
        @width = game.width
        @height = game.height

    #create cg window
    cg := new CG-Window! |> gui.frame.add-child
    cg.kill!

state.title.shutdown =!->
    #gui.frame.removeAll true
    gui.title.removeAll true

state.title.update =!-> main_update!

state.overworld.create =!->
    switches.cinema2=false
    teleporting = switches.portal? and not switches.portal.loaded
    input_overworld! unless teleporting # input must be set individually for all game states.
    
    create_backdrop!
    switches.outside = backdrop.visible = getmapdata \outside
    backdrop.sun.visible = switches.soulcluster
    switches.spawning = getmapdata \spawning
    create_tilemap!

    #defeated=false
    #for p in party
    #    if p.stats.hp==0
    #        switches.defeated=defeated=true
    #        break
    defeated=true
    for p in party
        if p.stats.hp>0
            defeated=false
        else
            p.kill!
    if defeated
        switches.defeated=defeated
    else
        set_party!

    create_pause_menu! unless teleporting
    create_shop_menu! unless teleporting
    start_dialog_controller! unless teleporting
    set_mobs!
    map_objects!
    npc_events! unless switches.portal?
    fringe.sort \y

    if !state.overworld.create.started || defeated
        for p in party
            p.start_location(true)
        state.overworld.create.started = true
        delete! switches.defeated if defeated
    
    sort_actor_groups!
    start_camera.call player

    if temp.runnode
        player.relocate temp.runnode
        delete! temp.runnode

    for p in party
        continue if p is player or !p.alive
        p.relocate player

    #win = create_window -144, -80, 18, 4, gui.bottom
    #port = create_portrait 144 -80 'marb_port'

    scenario.game_start! unless switches.started

    zonemusic!


!function quitgame
    return if quitgame.clicked
    quitgame.clicked = true
    music.fadeOut 500
    Transition.fade 500, 0 ->
        quitgame.clicked = false
        game.state.start 'reload', true
        state.overworld.create.started = false
        reset_items!
        session := {}
        for p of players then for f of formes[p]
            continue if f is \default
            formes[p][f]unlocked=false
    , null, 10 false

!function warp_node(pmap,pport,pdir)
    warp pmap, pport, pdir, true
!function warp(pmap=switches.map, pport, pdir=\down, pnode=false)
    Transition.fade 300 0 -> schedule_teleport pmap:pmap, pport:pport, pdir:pdir, pnode:pnode
    , null 5 true null

!function schedule_teleport(portal)
    return if switches.portal
    newzone = (getmapdata portal.pmap, \zone) isnt getmapdata \zone
    switches.map = portal.pmap
    switches.portal = portal
    player.cancel_movement!
    if newzone
        game.state.start 'load' false
    #if portal.sfx then sound.play portal.sfx

!function change_map(portal)
    log "Switching to map '#{portal.pmap}'"
    unless portal.loaded
        state.overworld.shutdown!
        state.overworld.create!

    px=player.x
    py=player.y
    if portal.pnode
        if node=nodes[portal.pport]
            px=node.x+TS/2
            py=node.y+TS - player.bodyoffset.y
    else
        #for trigger in triggers.children
        for n of nodes
            trigger=nodes[n]
            #if trigger.isportal? and trigger.name is portal.pport
            if trigger.name is portal.pport
                px=trigger.x+TS/2
                py=trigger.y+TS - player.bodyoffset.y
                switch portal.pdir
                when \up then py -= TS
                when \down then py += TS
                when \left then px -= TS
                when \right then px += TS
                break
    for actor in party
        actor.x=px
        actor.y=py
        actor.face portal.pdir
        update_water_depth actor
        actor.cancel_movement!
    
    #player.cancel_movement!
    start_camera.call player
    npc_events!
    
    if typeof temp.callback is \function
        temp.callback!
        delete! temp.callback
    
state.overworld.shutdown =!->
    player.cancel_movement!
    dialog.destroy! unless switches.portal?
    #cg.destroy! unless switches.portal?
    pause_screen.destroy! unless switches.portal?
    backdrop.destroy!
    map.destroy!
    Doodad.clear!
    NPC.clear!
    kill_players!
    Trigger.clear!
    Treasure.clear!
    
    delete! dialog
    delete! map

previous_time = Date.now!
var delta, deltam
!function main_update

    Transition.update!

    now = Date.now!
    delta := now - previous_time <? 60
    deltam := delta/1000
    previous_time := now
    #console.log game.time.elapsed, delta

    #desire the real fps
    #game.time.desiredFps=(game.time.desiredFps*2+1000/game.time.elapsed/gameOptions.gameSpeed)/3
    game.time.physicsElapsed=Math.min(game.time.elapsedMS/1000*gameOptions.gameSpeed,0.1)
    game.time.physicsElapsedMS = game.time.physicsElapsed * 1000
    #game.canvas.focus!
    mouse.update!

update_mod=[];

state.overworld.update =!->
    if switches.portal?
        change_map switches.portal
        delete! switches.portal
    main_update!

    if switches.cinema
        update_camera.call game.camera.center
        #log \cinema
    else
        update_camera.call player
        #log "not cinema"
    
    spawn_controller!

    game.input.keyboard.enabled = !dialog.textentry.alive if game.input.keyboard.enabled is dialog.textentry.alive
    
    if (getmapdata \edges) is \loop 
        bounds = 
            left   : player.x - map.widthInPixels/2
            right  : player.x + map.widthInPixels/2
            top    : player.y - map.heightInPixels/2
            bottom : player.y + map.heightInPixels/2
        for group in game.world.children then if group instanceof Phaser.Group then for object in group.children
            continue if object is player
            if object.x < bounds.left   then object.x += map.widthInPixels
            if object.x > bounds.right  then object.x -= map.widthInPixels
            if object.y < bounds.top    then object.y += map.heightInPixels
            if object.y > bounds.bottom then object.y -= map.heightInPixels

    #sort
    actors.sort 'y'

    for f in update_mod
        f?!
    
state.load.render = state.load.load-render = \
state.overworld.render = state.battle.render = state.title.render =!->
    copycanvas!

state.boot.load-render = state.preload.load-render  =!->
    #console.log 'load render '+game.state.current
    Transition.update!
    copycanvas!

    #copy unscaled canvas onto scaled canvas
!function copycanvas
    pixel.context.drawImage game.canvas, 0, 0, game.width, game.height, 0, 0, pixel.width, pixel.height

    #pixel.context.font = "30px Arial";
    #pixel.context.fillStyle = "red";
    #pixel.context.fillText("!!!"+Math.random!,10,50);