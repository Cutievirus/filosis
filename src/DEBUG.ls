
var pixel, game, pentagrams
const WIDTH = 320
const HEIGHT = 240
const HWIDTH = WIDTH/2
const HHEIGHT = HEIGHT/2
const RADIUS = Math.sqrt(WIDTH^2 + HEIGHT^2)/2
const TS = 16 # Tile size
const HTS = TS/2
const WS = 16 # Window tile size
const HWS = WS/2 # Half window size
const BS = 16 # Buff size
const IS = 32 # Item size
const FW = 6 # Font Width
const FW2 = 12 # Font Width*2
const FH = 10
const HPI = Math.PI/2

textinput=document.get-element-by-id \textinput
textinput.value=''
saveman = document.get-element-by-id \saveman
errordiv=document.get-element-by-id \errordiv
bootloader=document.get-element-by-id \bootloader

#compatibility
String.prototype.codePointAt || (String.prototype.codePointAt=String.prototype.charCodeAt)

state =
    preboot:{}
    boot:{}
    preload:{}
    reload:{}
    title:{}
    overworld:{}
    battle:{}
    load:{}

window.onload =!-> #Not true any more? -> #Phaser.AUTO doesn't seem to work on my tablet :)
    renderer=Phaser.AUTO
    for h in window.location.hash.split '#'
        if h is \canvas then renderer=Phaser.CANVAS
        else if h is \webgl then renderer=Phaser.WEBGL
        else if h.indexOf('lang=')>=0 then gameOptions.language=h.split(\=)1
        else if h is \debug then session.debug=true
    game := new Phaser.Game WIDTH, HEIGHT, renderer, '',
        null, false, false
    pixel := scale:1, canvas:null, context:null, width:0, height:0
    game.state.add 'preboot', state.preboot
    game.state.add 'boot', state.boot
    game.state.add 'preload', state.preload
    game.state.add 'reload', state.reload
    game.state.add 'title', state.title
    game.state.add 'overworld', state.overworld
    game.state.add 'battle', state.battle
    game.state.add 'load', state.load
    game.state.start 'preboot'
    
window.onresize = resize-game
!function resize-game
    return if not pixel.canvas?
    screen-height = window.inner-height
    screen-width = window.inner-width
    
    aspect = screen-width / screen-height

    #determine pixel scale
    scale = (screen-width / WIDTH .|. 0) <? (screen-height / HEIGHT .|. 0)
    if gameOptions.exactscaling# or session.test
        pixel.scale = scale >? 1
    else
        pixel.scale = scale+1

    if aspect > WIDTH/HEIGHT
        game.width = HEIGHT * aspect .|. 0
        game.height = HEIGHT
    else
        game.width = WIDTH
        game.height = WIDTH / aspect .|. 0
    
    if gameOptions.exactscaling
        game.width = (screen-width/pixel.scale/2 .|. 0)*2
        game.height = (screen-height/pixel.scale/2 .|. 0)*2
        pixel.canvas.style.width=''
        pixel.canvas.style.height=''
    else
        pixel.canvas.style.width='100%'
        pixel.canvas.style.height='100%'
    
    pixel.width = pixel.canvas.width = game.width*pixel.scale
    pixel.height = pixel.canvas.height = game.height*pixel.scale
    
    game.renderer.resize game.width, game.height
    Phaser.Canvas.setSmoothingEnabled(game.context, false) if game.renderType is Phaser.CANVAS
    Phaser.Canvas.setSmoothingEnabled(pixel.context, false)
    
    game.camera.view.width = game.width
    game.camera.view.height = game.height
    
    set_gui_frame!
    #battle_update_frame!
    
    if map? then for name, layer of map.named-layers
        #layer.canvas.width = game.width
        #layer.canvas.height = game.height
        #if game.renderType is Phaser.WEBGL
        #    layer.width = game.width
        #    layer.height = game.height
        #else
        #    layer.frame.width = game.width
        #    layer.frame.height = game.height
        #    layer.setFrame layer.frame
        #    #layer.resize(game.width, game.height)
        #layer.renderFull!
        layer.width = game.width
        layer.height = game.height
        layer.resize(game.width,game.height)
        layer.scale.set(1)
        
    if backdrop?
        backdrop.water.width = game.width + backdrop.water.margin-x
        backdrop.water.height = game.height + backdrop.water.margin-y
        
        
    
    reset-canvas!
!function reset-canvas
    #game.canvas.style.width = pixel.width+'px'
    #game.canvas.style.height = pixel.height+'px'
    game.canvas.style.width = '100%'
    game.canvas.style.height = '100%'

state.preboot.init =!->
    #create scaled canvas
    pixel.canvas = Phaser.Canvas.create game.width, game.height
    pixel.context = pixel.canvas.getContext '2d'
    Phaser.Canvas.addToDOM pixel.canvas, document.get-element-by-id "main"
    #add some class
    game.canvas.id = "gamecanvas"
    pixel.canvas.id = "pixelcanvas"
    game.canvas.style.z-index = '1'
    game.canvas.style.opacity = '0'
    #Dynamic sizing & scaling!
    #resize-game!
    try 
        localStorage.getItem('test')
    catch e
        fatalerror \localStorage
    load_options!
    game.stage.disableVisibilityChange = true
    #override reset canvas function
    override-reset-canvas = game.scale.resetCanvas
    game.scale.resetCanvas =!->
        override-reset-canvas ...
        reset-canvas!
    resize-game!
    override-tilesprite = Phaser.TileSprite
    Phaser.TileSprite =(game,x,y,width,height,key,frame)!->
        override-tilesprite ...
        @width = width if width?; @height = height if height?
    Phaser.TileSprite.prototype = override-tilesprite.prototype
    override-tilesprite-update-transform=Phaser.TileSprite::updateTransform
    Phaser.TileSprite::updateTransform=!-> #fix alph in webgl
        if game.renderType is Phaser.WEBGL
            @alpha=@parent.alpha*(@ownalpha||1)
        else
            @alpha=@ownalpha||1
        override-tilesprite-update-transform ...
       
    /* #not needed any more 
    Phaser.FrameData::getFrame =(index)!->
        if index>= @_frames.length
            index=0
        return @_frames[index]
    */

    # Fix body offsets
    Phaser.Physics.Arcade.Body.prototype.setSize = override Phaser.Physics.Arcade.Body.prototype.setSize,(width,height,offsetX,offsetY)!->
        adjustBodyOffset.apply @, &
    Phaser.Sprite.prototype.crop = override Phaser.Sprite.prototype.crop,(rect,copy)->
        if @body then adjustBodyOffset.apply @body, &

    # Add css for font
    css=document.createElement \style
    css.type='text/css'
    css.innerHTML="@font-face { 
    font-family: 'Filosis'; 
    src: url('font/Filosis.ttf') format('truetype'); 
    }"
    document.head.appendChild css

!function adjustBodyOffset(width,height,offsetX,offsetY)
    if @sprite.bodyoffset
        @sprite.bodyoffset.x=if offsetX~=null then @sprite.bodyoffset.x||0 else offsetX
        @sprite.bodyoffset.y=if offsetY~=null then @sprite.bodyoffset.y||0 else offsetY
    else @sprite.bodyoffset={x:offsetX||0,y:offsetY||0}
    @offset.set(
        @sprite.width*@sprite.anchor.x - @width*@sprite.anchor.x + @sprite.bodyoffset.x
        , @sprite.height*@sprite.anchor.y - @height*@sprite.anchor.y + @sprite.bodyoffset.y
    )

init_mod=[]
!function tlNames

    #interpret language file
    if game.cache.checkJSONKey('lang_'+gameOptions.language)
        lang=game.cache.getJSON('lang_'+gameOptions.language)
        tl.dictionary=lang.dictionary if typeof lang.dictionary is \object
    #items
    for k,o of items
        o.unlocalized_name=o.name
        o.name=tl(o.name)
        if typeof o.desc is \string
            o.unlocalized_desc=o.desc
            o.desc=tl(o.desc)
        if typeof o.soulname is \string
            o.unlocalized_soulname=o.soulname
            o.soulname=tl(o.soulname) 
        if typeof o.desc_battle is \string
            o.unlocalized_desc_battle=o.desc_battle
            o.desc_battle=tl(o.desc_battle) 
    #skills
    for k,o of skills
        o.unlocalized_name=o.name
        o.name=tl(o.name)
        if typeof o.desc is \string
            o.unlocalized_desc=o.desc
            o.desc=tl(o.desc)
        if typeof o.desc_battle is \string
            o.unlocalized_desc_battle=o.desc_battle
            o.desc_battle=tl(o.desc_battle) 
    #formes
    for p of formes
        for f,o of formes[p]
            if o.name
                o.unlocalized_name=o.name
                o.name=tl(o.name)
            if o.desc
                o.unlocalized_desc=o.desc
                o.desc=tl(o.desc) if o.desc
    #speakers
    for k,o of speakers
        #continue if o.tl #prevent double translation for aliases
        o.unlocalized_display=o.display
        o.display=tl(o.display)
        #o.tl=true
    #monsters
    for k,o of Monster.types
        o.unlocalized_name=o.name
        o.name=tl(o.name)
    #warp names
    for o in warpzones
        o.unlocalized_name=o.name
        o.name=tl(o.name)
    #teleport names
    tl_pentagrams={}
    for k of pentagrams
        o=tl_pentagrams[tl(k)]=pentagrams[k]
        unlocalized_zones.push k
        for k2 of o
            unlocalized_pentagrams.push o[k2]
            o[k2]=tl(o[k2])
    pentagrams := tl_pentagrams


    for f in init_mod
        f?!

# Fatal errors
!function fatalerror(type)
    text=''
    greater=true
    fatalerror.advices ?=
        download: tle("Download a native version of this game from {0}. Run the game executable.","<a href='https://cutievirus.itch.io/super-filovirus-sisters'>itch.io</a>")
        report: tle("To report this bug, the you can contact me on {0}.","<a href='https://discord.gg/4SJ5dFN'>Discord</a>")
    switch type 
    |\sameOrigin
        text="<h2>"+tle("The game cannot be played right now.")+"</h2>"+
        "<p>"+tle("This probably happened because your browser blocked a cross-origin request.")+"<br>"+
        tle("Some web browsers heavily restrict what can be done in the file protocol, and don't allow access to files in sub folders.")+"<br>"+
        tle("There are a few things you can do to fix this.")+"</p>"+
        "<p>1. "+fatalerror.advices.download+"</p>"+
        "<p>2. "+tle("Try a different browser. Chromium browsers won't work. Firefox will. If you want to play using this browser, read further.")+"</p>"+
        "<p>3. "+tle("Disable web security. This isn't reccomended unless you know what you're doing.")+"</p>"+
        "<p>4. <a href='https://www.npmjs.com/package/http-server'>"+tle("Get a web server!")+"</a></p>"
    |\localStorage
        text="<h2>"+tle("Local Storage Error")+"</h2>"+
        "<p>"+tle("This probably happened because you're using a browser that doesn't support localStorage, or localStorage is disabled.")+"<br>"+
        tle("There are a few things you can do to fix this.")+"</p>"+
        "<p>1. "+fatalerror.advices.download+"</p>"+
        "<p>2. "+tle("Get a better browser.")+"</p>"
    |\missingitem
        text="<h2>"+tle("Missing item")+"</h2>"+
        "<p>"+tle("The game tried to access an item that doesn't exist.")+"</p>"+
        "<p>"+tle("This is definitely a bug.")+"</p>"
    |_
        greater=false
        if game.state.current in [\preboot, \boot, \preload, '']
            text="<h2>Error! #{&1}</h2>"+
            "<p>"+tle("An error occurred while loading the game. Here's a few things you can try to fix it:")+"</p>"+
            "<p>1. "+tle("Try changing the renderer. Add {0} or {1} to the url to try a different renderer.","<a href='\#canvas' onclick='location.reload()'>\#canvas</a>","<a href='\#webgl' onclick='location.reload()'>\#webgl</a>")+"</p>"+
            "<p>2. "+tle("Some errors happen only on certain browsers. You can try using a different browser, or download a native version of the game from {0}.","<a href='http://filosis.cutievirus.com/\#download'>filosis.cutievirus.com</a>")+"</p>"
        else
            text="<h2>Error! #{&1}</h2>"+
            "<p>"+tle("An error occurred while the game was playing. This is probably a bug.")+"</p>"+
            "<p>"+fatalerror.advices.report+"</p>"
        text+="<p>"+tle("You can check the console for more information.")+
        "<br><small>#{&2} : #{&3}</small></p>"
    text += "<p><a href='javaScript:void \'Dismiss Error\';' onclick='dismissError(this); return false;'>Dismiss this error</a></p>"
    for ed in document.get-elements-by-class-name 'errordiv' by -1
        if !ed.getAttribute('data-greater')
            if greater then ed.parentNode.removeChild(ed)
        else if !greater then return

    div=document.createElement('div')
    div.innerHTML=text
    div.className='errordiv'
    if greater then div.setAttribute('data-greater','true')
    #div.style.position=\absolute
    #div.style.top=0
    errordiv.appendChild(div)
    errordiv.style.display='block'
    #pixel.canvas.style.display=game.canvas.style.display='none'
    #document.body.style.overflow='auto'

!function dismissError (a)
    ed=a.parentNode.parentNode
    ed.parentNode.removeChild(ed)
    if (document.get-elements-by-class-name 'errordiv').length is 0
        errordiv.style.display='none'
    

window.onerror =(msg,url,ln)!->
    #alert("Uncaught error!\n"+msg+'\n'+url+' : '+ln)
    fatalerror \unknown, msg, url, ln

for item in document.get-elements-by-class-name \close_overlay
    item.href="javaScript:void 'Close';"
    item.onclick=!->
        this.parentNode.style.display='none';

STARTMAP = 'shack2'
version = "Release"
version_number = '1.1.1'
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

var preloader
state.preboot.preload =!->
    batchload [
    [\preloader \preloader.png]
    [\preloader_back \preloader_back.png]
    [\title \title.png]
    #[\logo \logo.png]
    #[\cg_skulls \skulls.png]
    [\loading \loading.png]
    ], \img/gui/

    game.load.json 'test', 'img/misc/test.json'

    #Solid colors
    g = game.add.bitmapData 1 1 \solid true
    g.ctx.begin-path!
    g.ctx.rect 0 0 1 1
    g.ctx.fill-style = \#ffffff
    g.ctx.fill!
    game.load.image \solid g.canvas.toDataURL!

    game.load.image \empty \img/misc/empty.png

state.preboot.create =!-> 
    #if !game.cache._cache.json.test
    if !game.cache.checkJSONKey('test')
        fatalerror \sameOrigin
        #sameoriginmessage!
        return
    game.state.start 'boot'
    bootloader.innerHTML=''

state.boot.preload =!->#load assets needed for preloader
    create_title_background!
    #preloader := gui.frame.create 0, HEIGHT - TS*2, 'preloader'
    #game.load.set-preload-sprite preloader
    #preloader.text = new Phaser.Image game, 1, 209, 'loading'
    preloader := new Phaser.Image game, 1, 209, 'loading'
    gui.frame.add-child preloader

    game.load.image 'logo', 'img/gui/logo.png'
    game.load.bitmapFont('unifont', 'img/font/Filosis.png', 'img/font/Filosis.xml');

state.boot.create =!-> 
    gui.frame.remove preloader
    #gui.frame.remove preloader.text
    game.state.start 'preload'

state.preload.preload =!->
    #gui.frame.add-child preloader
    preloader := gui.frame.create 0, HEIGHT - TS*2, 'preloader'
    preloader.back = gui.frame.create 0, preloader.y, 'preloader_back'
    game.load.set-preload-sprite preloader
    preloader.text = new Text null, "Loading...",2,210
    gui.frame.add-child preloader.text
    game.load.onFileStart.add (progress,key,url)!->
        #console.log progress,key,url
        if session.debug
            preloader.text.change "Loading "+url
        else if progress is 0
            preloader.text.change "Loading..."
        else
            preloader.text.change "Loading "+game.load.progress+"%"
    preload_assets!
    
state.preload.create =!->
    gui.frame.remove preloader
    gui.frame.remove preloader.back
    gui.frame.remove preloader.text
    game.state.start 'title'
    tlNames!

preload_mod=[];

#===========================================================================
# PRELOAD ASSETS
#===========================================================================

!function preload_assets

    #===================================================
    # NPCs and Players
    #---------------------------------------------------

    batchload [
    [\llov \llov.png 20 25]
    [\ebby \ebby.png 22 25]
    [\marb \marb.png 22 28]
    [\mal \mal.png 22 28]
    [\bp \bp.png 22 28]
    [\joki \joki.png 22 25]
    [\herpes \herpes.png 22 25]
    [\pox \pox.png 22 25]
    [\leps \leps.png 22 26]
    [\sars \sars.png 22 26]
    [\aids1 \eidzu1.png 20 25]
    [\aids2 \eidzu2.png 20 25]
    [\aids3 \eidzu3.png 29 28]
    [\rab \rabies.png 22 26]
    [\chikun \chikun.png 22 26]

    [\ammit \ammit.png 20 25]
    [\parvo \parvo.png 20 25]
    [\zika \zika.png 22 25]

    [\cure \cure.png 22 28]
    [\zmapp \zmapp.png 22 26]
    [\who \who.png 22 36]
    #[\draco \draco.png 20 25]

    [\min \min.png 20 25]
    [\dead \dead.png 20 25]

    [\merchant1 \merchant1.png 22 28]
    [\merchant2 \merchant2.png 22 28]

    [\shiro \shiro.png 20 25]

    ], 'img/char/', \spritesheet
    
    #costumes
    /*
    batchload_battler [\llov nurse:0 swim:0 swim2:0 \pumpkin \christmas \valentine \punk],
        [\ebby cheer:0 bat:0 santa:1 witch:0]
        [\marb nurse:0 \maid \bunny \demon]
    */

    batchload [
    [\ebby_battle \ebby.png 96 86]
    [\marb_battle \marb.png 96 86]
    [\marb_battle_1 \marb_1.png 96 96]
    [\marb_battle_2 \marb_2.png 106 86]
    [\llov_battle \llov.png 96 86]
    [\llov_battle_christmas \llov_christmas.png 102 86]

    ], 'img/battle/', \spritesheet

    batchload [
    [\llov_base \llov_base.png 120 130]
    [\llov_base2 \llov_base2.png 120 140]
    [\llov_face \llov_face.png 35 33]
    [\ebby_base \ebby_base.png 112 145]
    [\ebby_base2 \ebby_base2.png 112 155]
    [\ebby_face \ebby_face.png 37 33]
    [\marb_base \marb_base.png 140 160]
    [\marb_base2 \marb_base2.png 140 175]
    [\marb_face \marb_face.png 37 31]
    ], 'img/port/', \spritesheet
    
    batchload [
    #['ebby_port' 'ebby.png']
    #['ebby_smile' 'ebby happy.png']
    #['ebby_concern' 'ebby concern.png']
    #['ebby_cry' 'ebby cry.png']
    #['llov_port' 'llov.png']
    #['llov_scared' 'llov scared.png']
    #['llov_sick' 'llov sick.png']
    #['llov_smile' 'llov happy.png']
    #['marb_port' 'marb.png']
    #['marb_smile' 'marb smile.png']
    #['marb_troubled' 'marb troubled.png']
    #['marb_grief' 'marb grief.png']
    ['mal_port' 'mal.png']
    ['bp_port' 'bp.png']
    ['joki_port' 'joki.png']
    #['joki_tits' 'joki tits.png']
    ['herpes_port' 'herpes.png']
    #['herpes_tits' 'herpes tits.png']
    ['merchant_port' 'merchant.png']
    #['merchant_tits' 'merchant tits.png']
    ['pox_port' 'pox.png']
    ['pox_injured' 'pox injured.png']
    ['leps_port' 'leps.png']
    ['sars_port' 'sars.png']
    ['sars_mad' 'sars mad.png']
    ['rab_port' 'rabies.png']
    ['rab_mad' 'rabies mad.png']
    ['rab2_port' 'rabies2.png']
    ['aids1_port' 'eidzu1.png']
    ['aids1_mad' 'eidzu1 mad.png']
    ['aids2_port' 'eidzu2.png']
    ['aids2_mad' 'eidzu2 mad.png']
    ['aids3_port' 'eidzu3.png']
    ['nae_port' 'nae.png']
    ['ammit_port' 'ammit.png']
    ['chikun_port' 'chikun.png']
    ['parvo_port' 'parvo.png']
    ['zika_port' 'zika.png']

    ['cure_port' 'cure.png']
    ['zmapp_port' 'zmapp.png']
    ['zmapp_healthy' 'zmapp healthy.png']
    ['who_port' 'who.png']
    #['draco_port' 'draco.png']

    ['min_port' 'min.png']
    ['wraith_port' 'wraith.png']
    ['war_port' 'war.png']

    ['slime_port' 'slime.png']

    ['shiro_port' 'shiro.png']

    ], 'img/port/'

    #===================================================
    # Monsters
    #---------------------------------------------------

    #mobs
    batchload [
    [\mob_slime \mob_slime.png 16 17]
    [\mob_ghost \mob_ghost.png 16 17]
    [\mob_bat \mob_bat.png 26 18]
    [\mob_flytrap \mob_flytrap.png 17 19]
    [\mob_corpse \mob_corpse.png 17 19]
    [\mob_wisp \mob_wisp.png 22 22]
    [\mob_ripple \mob_ripple.png 16 5]
    [\mob_arrow \mob_arrow.png 14 20]
    [\mob_glitch \mob_glitch.png 24 25]

    [\mob_naegleria \naegleria_mob.png 22 28]
    [\naegleria \naegleria.png 22 28]
    [\wraith \wraith.png 22 28]
    [\mob_wraith \wraith_mob.png 22 28]
    [\mob_chikun \chikun_mob.png 24 28]
    [\mob_llov \darkllov.png 24 25]

    ], 'img/char/', \spritesheet

    #static battlers
    batchload [
    ['monster_mimic' 'mimick.png']
    ['monster_sanishark' 'sanishark.png']
    ['monster_wolf' 'wolf.png']
    ['monster_wraith' 'wraith.png']
    ['monster_naegleria' 'naegleria.png']
    ['monster_cure0' 'cure0.png']
    ['monster_cure1' 'cure1.png']
    ['monster_zmapp0' 'zmapp0.png']
    ['monster_zmapp1' 'zmapp1.png']
    ['monster_zmappX' 'zmappX.png']
    ['monster_sars' 'sars.png']
    ['monster_rabies' 'rabies.png']
    ['monster_rabies2' 'rabies_2.png']
    ['monster_eidzu1' 'eidzu1.png']
    ['monster_eidzu1_2' 'eidzu1_2.png']
    ['monster_eidzu2' 'eidzu2.png']
    ['monster_eidzu2_2' 'eidzu2_2.png']
    ['monster_chikun' 'chikun.png']
    ['monster_who' 'who.png']
    ['monster_lepsy' 'lepsy.png']
    ['monster_parvo' 'parvo.png']
    ['monster_zika' 'zika.png']
    ['monster_joki' 'joki.png']
    ['monster_voideye' 'voideye.png']
    ['monster_voidgast' 'voidgast.png']
    ['monster_voidtofu' 'voidtofu.png']
    ['monster_voidskel' 'voidskel.png']
    ['monster_darkllov' 'darkllov.png']
    ['monster_mutant' 'mutant.png']
    ['monster_throne' 'throne.png']
    ], 'img/battle/'

    #animated battlers
    batchload [
    ['monster_slime' 'slime_chibi.png' 40 27]
    ['monster_slime2' 'slime.png' 56 46]
    ['monster_ghost' 'eyeball.png' 52 64]
    ['monster_skullghost' 'skullghost1.png' 64 64]
    ['monster_graven' 'graven.png' 64 64]
    ['monster_eel' 'eel.png' 56 56]
    ['monster_cancer' 'cancer.png' 64 64]
    ['monster_lurker' 'lurker.png' 64 64]
    ['monster_bat' 'bat.png' 64 64]
    ['monster_doggie' 'doggie.png' 64 64]
    ['monster_mantrap' 'mantrap.png' 64 64]
    ['monster_greblin' 'greblin.png' 51 44]
    ['monster_polyduck' 'polyduck.png' 64 64]
    ['monster_rhinosaurus' 'rhinosaurus.png' 83 72]
    ['monster_woolyrhino' 'woolyrhino.png' 83 72]
    ['monster_skulmander' 'skulmander.png' 64 64]
    ['monster_tengu' 'tengu.png' 71 79]

    ['monster_sars_summon' 'sars_summon.png' 20 20]
    ], 'img/battle/', \spritesheet

    #===================================================
    # ETC
    #---------------------------------------------------

    batchload [
    [\head_llov \head_llov.png]
    [\head_ebby \head_ebby.png]
    [\head_marb \head_marb.png]
    [\trigger \trigger.png]
    [\boat \boat.png]
    [\deadllov \deadllov.png]
    [\deadmal \deadmal.png]
    [\deadpox \deadpox.png]
    [\war \war.png]
    [\bp_shiro \bp_shiro.png]
    ], 'img/misc/'

    batchload [
    [\dust \dust.png 21 19]
    [\flame \fire.png 16 16]
    [\flameg \fireg.png 16 16]
    [\tv \tv.png 16 16]
    [\pent \pent.png 32 32]
    [\pent_fire \pent_fire.png 32 32]
    [\llovsick \llovsick.png 20 26]
    [\poxsick \poxsick.png 20 26]
    [\joki_fireball \joki_fireball.png 25 25]

    [\z \z.png 16 16]
    [\zburst \zburst.png 32 32]
    [\pest \pest.png 73 36]
    [\bloodpool \bloodpool.png 22 16]
    [\who_die \who_die.png 22 36]
    [\ripple \ripple.png 16 5]
    ], 'img/misc/', \spritesheet
    
    game.load.image 'water', 'img/map/water.png'
    game.load.spritesheet 'sun', 'img/map/sun.png', 105, 53

    game.load.spritesheet 'bars', 'img/gui/bars.png', 1, 10
    game.load.spritesheet 'window', 'img/gui/window.png', 16, 16
    game.load.image 'arrow', 'img/gui/arrow.png'
    game.load.image 'arrowd', 'img/gui/arrowd.png'
    game.load.image 'arrowu', 'img/gui/arrowu.png'
    game.load.image 'target', 'img/gui/target.png'
    #game.load.image 'font', 'img/gui/font.png'
    #game.load.image 'font_yellow', 'img/gui/font_yellow.png'
    #game.load.image 'font_gray', 'img/gui/font_gray.png'
    #game.load.image 'font_red', 'img/gui/font_red.png'
    #game.load.image 'font_green', 'img/gui/font_green.png'

    #game.load.bitmapFont('unifont', 'img/font/Filosis.png', 'img/font/Filosis.xml');

    batchload [
    #['item_sword', 'sword.png']
    #['item_key', 'key.png']

    #['item_misc', 'misc.png']
    #['item_misc2', 'misc2.png']
    #['item_misc3', 'misc3.png']
    #['item_misc4', 'misc4.png']

    #['item_shards', 'shards.png']
    #['item_vial', 'pot_empty.png']
    #['item_tuonen', 'pot_tuonen.png']
    ['item_lovejuice', 'pot_love.png']
    ['item_water', 'pot_water.png']
    #['item_nectar', 'pot_nectar.png']
    #['item_oil', 'pot_oil.png']
    #['item_sap', 'pot_sap.png']
    #['item_soul', 'soul.png']

    #['item_pot', 'pot.png']
    #['item_hp1', 'pot_hp_1.png']
    #['item_hp2', 'pot_hp_2.png']
    #['item_hp3', 'pot_hp_3.png']
    #['item_hp4', 'pot_hp_4.png']
    #['item_sp1', 'pot_sp_1.png']
    #['item_sp2', 'pot_sp_2.png']
    #['item_antidote', 'pot_antidote.png']
    #['item_burnheal', 'pot_antifire.png']
    #['item_antifreeze', 'pot_antifreeze.png']
    #['item_anticurse', 'pot_anticurse.png']

    #['item_poisonbom', 'bom_poison.png']
    #['item_cursebom', 'bom_curse.png']
    #['item_firebom', 'bom_fire.png']
    #['item_icebom', 'bom_ice.png']

    #[\item_leatherarmor \armorleather.png]
    #[\equip_leatherarmor \armorleather_e.png]
    #[\item_platearmor \armorplate.png]
    #[\equip_platearmor \armorplate_e.png]
    #[\item_thornarmor \armorthorn.png]
    #[\equip_thornarmor \armorthorn_e.png]
    #[\item_woodshield \shieldwood.png]
    #[\equip_woodshield \shieldwood_e.png]
    #[\item_towershield \shieldtower.png]
    #[\equip_towershield \shieldtower_e.png]
    #[\item_speedboot \speedboot.png]
    #[\equip_speedboot \speedboot_e.png]

    #[\item_heartpin \heartpin.png]
    #[\equip_heartpin \heartpin_e.png]
    #[\item_shinai \shinai.png]
    #[\equip_shinai \shinai_e.png]
    #['item_pest', 'pest.png']
    #['equip_pest_0', 'pest_e0.png']
    #['equip_pest_1', 'pest_e1.png']
    #['item_newton', 'newton.png']
    #['equip_newton', 'newton_e.png']
    #[\item_worldsharp \worldsharp.png]
    #[\equip_worldsharp \worldsharp_e.png]
    #[\item_samsword \samsword.png]
    #[\equip_samsword \samsword_e.png]
    #[\item_fan \fan.png]
    #[\equip_fan \fan_e.png]
    #[\item_broadsword \broadsword.png]
    #[\equip_broadsword \broadsword_e.png]
    #[\item_steelpipe \steelpipe.png]
    #[\equip_steelpipe \steelpipe_e.png]
    ], 'img/item/'

    batchload [
    [\item_misc \sheet_common.png 16 16]
    [\item_pot \sheet_pot.png 16 16]
    [\item_key \sheet_key.png 16 16]
    [\item_equip \sheet_equip.png 16 16]
    [\item_equip2 \sheet_equip2.png 32 32]
    [\buffs \sheet_buffs.png 16 16]
    ], \img/item/ \spritesheet
    /*
    batchload [
    [\buff_blister, \blister.png]
    [\buff_scab, \scab.png]
    [\buff_fever, \fever.png]
    [\buff_burn1, \burn1.png]
    [\buff_burn2, \burn2.png]
    [\buff_burn3, \burn3.png]
    [\buff_chill, \chill.png]
    [\buff_skull, \skull.png]
    [\buff_lips, \lips.png]
    [\buff_blood, \blood.png]
    [\buff_recover, \recover.png]
    [\buff_seizure, \seizure.png]
    [\buff_shieldbreak, \shieldbreak.png]
    [\buff_weak, \weak.png]
    [\buff_wing, \wing.png]
    ], \img/buff/
    */
    #Backgrounds
    batchload [
    [\bg_0_0 \0_0.png]
    [\bg_0_1 \0_1.png]
    [\bg_1_0 \1_0.png]
    [\bg_1_1 \1_1.png]
    [\bg_2_0 \2_0.png]
    [\bg_2_1 \2_1.png]
    [\bg_3_0 \3_0.png]
    [\bg_3_1 \3_1.png]
    [\bg_4_0 \4_0.png]
    [\bg_4_1 \4_1.png]
    [\bg_5_0 \5_0.png]
    [\bg_5_1 \5_1.png]
    [\bg_5_0a \5_0a.png]
    [\bg_5_1a \5_1a.png]
    [\bg_5_0b \5_0b.png]
    [\bg_5_1b \5_1b.png]
    [\bg_6_0 \6_0.png]
    [\bg_6_1 \6_1.png]
    [\bg_7_0 \7_0.png]
    [\bg_7_1 \7_1.png]
    [\bg_7_0s \7_0s.png]
    [\bg_7_1s \7_1s.png]
    [\bg_8_0 \8_0.png]
    [\bg_9_0 \9_0.png]
    ], \img/bg/

    #CGs
    batchload [
    [\cg_pest \pest.png]
    [\cg_pest_night \pest_night.png]
    [\cg_earth \earth.png]
    [\cg_tower0 \tower0.png]
    [\cg_tower1 \tower1.png]
    [\cg_tower2 \tower2.png]
    [\cg_jungle \jungle.png]
    [\cg_abyss \abyss.png]
    ],\img/cg/

    game.load.spritesheet 'cg_border', 'img/cg/border.png', 8, 8


    #===================================================
    # Battle Animations
    #---------------------------------------------------
    batchload [
    [\anim_slash \slash.png 36 42]
    [\anim_flame \flame.png 42 42]
    [\anim_curse \curse.png 42 42]
    [\anim_heal \heal.png 42 42]
    [\anim_blood1 \blood1.png 42 42]
    [\anim_blood2 \blood2.png 42 42]
    [\anim_water \water.png 48 48]
    [\anim_arrow \arrow.png 16 42]
    [\anim_flies \flies.png 48 48]
    ], \img/anim/ \spritesheet

    #===================================================
    # Music and Sound
    #---------------------------------------------------
    /*
    batchload [
    [\battle [\battle.ogg \battle.m4a]]
    ], \music/ \audio
    */

    batchload [
    [\blip [\textblip.ogg \textblip.m4a]]
    [\itemget [\itemget.ogg \itemget.m4a]]
    [\encounter [\encounter.ogg \encounter.m4a]]
    [\boom [\boom.ogg \boom.m4a]]
    [\defeat [\defeat.ogg \defeat.m4a]]
    [\candle [\candle.ogg \candle.m4a]]
    [\strike [\strike.ogg \strike.m4a]]
    [\flame [\flame.ogg \flame.m4a]]
    [\water [\water.ogg \water.m4a]]
    [\swing [\swing.ogg \swing.m4a]]
    [\laser [\laser.ogg \laser.m4a]]
    [\run [\run.ogg \run.m4a]]
    [\stair [\stair.ogg \stair.m4a]]
    [\door [\door.ogg \door.m4a]]
    [\groan [\groan.ogg \groan.m4a]]
    [\voice [\voice.ogg \voice.m4a]]
    [\voice2 [\voice2.ogg \voice2.m4a]]
    [\voice3 [\voice3.ogg \voice3.m4a]]
    [\voice4 [\voice4.ogg \voice4.m4a]]
    [\voice5 [\voice5.ogg \voice5.m4a]]
    [\voice6 [\voice6.ogg \voice6.m4a]]
    [\voice7 [\voice7.ogg \voice7.m4a]]
    [\voice8 [\voice8.ogg \voice8.m4a]]
    [\rope [\ROPE.ogg \ROPE.m4a]]
    ], \sound/ \audio

    #===================================================
    # Tilemap
    #---------------------------------------------------
    load_map \hub \hub.json
    load_map \shack1 \shack1.json
    load_map \shack2 \shack2.json
    load_map \pox_cabin \pox_cabin.json
    load_map \tunnel \tunnel.json
    load_map \tunnel_entrance \tunnel_entrance.json
    load_map \deadworld \deadworld.json
    load_map \tower0 \tower0.json
    load_map \tower1 \tower1.json
    load_map \tower2 \tower2.json
    load_map \towertop \towertop.json
    load_map \ebolaroom \ebolaroom.json
    load_map \delta \delta.json
    load_map \deltashack \deltashack.json
    load_map \deltashack2 \deltashack2.json
    load_map \deltashack3 \deltashack3.json
    load_map \earth \earth.json
    load_map \earth2 \earth2.json
    load_map \earth3 \earth3.json
    load_map \basement1 \basement1.json
    load_map \basement2 \basement2.json
    #load_map \voidtunnel \voidtunnel.json
    load_map \necrohut \necrohut.json
    load_map \shrine \shrine.json
    load_map \labdungeon \labdungeon.json
    load_map \lab \lab.json
    load_map \labhall \labhall.json
    load_map \tunneldeep \tunneldeep.json
    load_map \shack3 \shack3.json
    load_map \deathtunnel \deathtunnel.json
    load_map \deathdomain \deathdomain.json
    load_map \castle \castle.json
    load_map \void \void.json

    batchload [
    [\tiles \tiles.png]
    [\tiles_night \tiles_night.png]
    [\tower_tiles \tower.png]
    [\tower_tiles_night \tower_night.png]
    [\towerin_tiles \towerin.png]
    [\townhouse_tiles \townhouse.png]
    [\townhouse_tiles_night \townhouse_night.png]
    [\dungeon_tiles \dungeon.png]
    [\jungle_tiles \jungle.png]
    [\home_tiles \home.png]
    [\delta_tiles \delta.png]
    [\delta_tiles_night \delta_night.png]
    [\earth_tiles \earth.png]
    [\lab_tiles \lab.png]
    [\castle_tiles \castle.png]
    [\void_tiles \void.png]

    ], \img/map/

    batchload [
    [\1x1 \1x1.png 16 16]
    [\1x1_night \1x1_night.png 16 16]
    [\1x2 \1x2.png 16 32]
    [\1x2_night \1x2_night.png 16 32]
    [\2x2 \2x2.png 32 32]
    [\2x3 \2x3.png 32 48]
    [\3x3 \3x3.png 48 48]
    ], \img/map/ \spritesheet


    for f in preload_mod
        f?!

var gui
gui_mod=[]
!function create_gui
    return if gui?
    gui := game.add.group null, 'gui', true
    gui.classType = Phaser.Image
    gui.title = game.add.group gui, 'gui_title'
    gui.title.classType = Phaser.Image
    gui.dock = game.add.group gui, 'gui_bottom'
    gui.dock.classType = Phaser.Image
    gui.frame = game.add.group gui, 'gui_frame'
    gui.frame.classType = Phaser.Image
    
    #gui.cg = new Phaser.Image game, 0 0 '' |> gui.add-child
    set_gui_frame!
    for f in gui_mod
        f?!
    
!function set_gui_frame
    resize_callbacks!
    return unless gui?
    #gui.cg.x = gui.frame.x = Math.floor (game.width - WIDTH) / 2
    #gui.cg.y = gui.frame.y = Math.floor (game.height - HEIGHT) / 2
    gui.title.x = gui.frame.x = Math.floor (game.width - WIDTH) / 2
    gui.title.y = gui.frame.y = Math.floor (game.height - HEIGHT) / 2
    gui.dock.x = Math.floor game.width / 2
    gui.dock.y = game.height

resize_callback.list = []
!function resize_callback (context, callback, args)
    resize_callback.list.push context:context, callback:callback, arguments:args
!function resize_callbacks
    for c, i in resize_callback.list by -1
        if c.context.alive
            process_callbacks c
        else
            resize_callback.list.splice i, 1

    
var dialog
!function start_dialog_controller
    dialog := new Dialog-Window! |> gui.dock.add-child
    dialog.kill!
    #cg := new CG-Window! |> gui.frame.add-child
    #cg.kill!
    
!function say
    if typeof &0 is \function
        if this instanceof Menu
            @queue.push &0
        else
            dialog.say &0
        return
    switch &length
    |1 => message=&0
    |2 => speaker=&0; message=&1
    |3 => speaker=&0; pose=&1; message=&2
    if this instanceof Menu
        @queue.push speaker: speaker, message: message, pose: pose
    else
        dialog.say speaker, message, pose

!function say_now
    switch &length
    |1 => message=&0
    |2 => speaker=&0; message=&1
    |3 => speaker=&0; pose=&1; message=&2
    dialog.say_now speaker, message, pose
    
!function menu
    return unless dialog.menu.check_arguments.apply dialog.menu, arguments
    #last = dialog.queue[dialog.queue.length-1]
    #unless last?
    #    console.warn 'Cannot call menu when dialog queue is empty!'
    #    return
    options = []; actions = []
    for option, i in arguments by 2
        action = arguments[i+1]
        options.push option
        actions.push action
    if this instanceof Menu
        @queue.push options:options, actions:actions
    else
        dialog.queue.push options:options, actions:actions
    #if last is dialog.queue[0]
    #    dialog.next_menu!
        
!function show (pose='default')
    dialog.queue.push pose:pose

!function number (note,min=0,max=999)
    (if this instanceof Menu then this else dialog
    )queue.push numberdialog:note, min:min, max:max
    #dialog.number.show note,min,max

!function textentry (limit,message,callback)
    f=!->dialog.textentry.show limit, message, !->
        callback ...
        dialog.click \ignorelock
    f.autocall=true
    (if this instanceof Menu then this else dialog
    )queue.push f

class Window extends Phaser.Group
    (x,y,@w,@h, @nowindow=false)->
        super game, null, 'window'
        @x=x;@y=y
        unless @nowindow
            @add-child @tile_tl = new Phaser.TileSprite game, 0, 0, WS,WS, 'window', 0 # top left
            @add-child @tile_t  = new Phaser.TileSprite game, WS, 0, 0, WS, 'window', 1 # top
            @add-child @tile_tr = new Phaser.TileSprite game, 0, 0, WS,WS, 'window', 2 # top right
            @add-child @tile_l  = new Phaser.TileSprite game, 0, WS, WS, 0, 'window', 3 # left
            @add-child @tile_c = new Phaser.TileSprite game, WS, WS, 0, 0, 'window', 4 # center
            @add-child @tile_r = new Phaser.TileSprite game, 0, WS, WS, 0, 'window', 5 # right
            @add-child @tile_bl = new Phaser.TileSprite game, 0, 0, WS,WS, 'window', 6 # bottom left
            @add-child @tile_b = new Phaser.TileSprite game, WS, 0, 0, WS, 'window', 7 # bottom
            @add-child @tile_br = new Phaser.TileSprite game, 0, 0, WS,WS, 'window', 8 # bottom right
            @@::resize.call this, @w, @h
            @tiles=[@tile_tl, @tile_t, @tile_tr, @tile_l, @tile_c, @tile_r, @tile_bl, @tile_b, @tile_br]
    add-text: (font, string, x, y, teletype, line-width, line-height)->
        @add-child new Text font, string, x, y, teletype, line-width, line-height
    update: !->
        if @alive then for child in @children
            child.update!
    kill: Phaser.Sprite.prototype.kill
    revive: !->
        Phaser.Sprite.prototype.revive ...
        @on-revive!
    on-revive: !->

    resize: (@w,@h)!->
        return if @nowindow
        @tile_t.width = @tile_c.width = @tile_b.width = (@w-2)*WS
        @tile_l.height = @tile_c.height = @tile_r.height = (@h-2)*WS
        @tile_tr.x = @tile_r.x = @tile_br.x = (@w-1)*WS
        @tile_bl.y = @tile_b.y = @tile_br.y = (@h-1)*WS

class CG-Window extends Phaser.Group
    ->
        super game, null, 'cg'
        @cg2= new Phaser.Image game, 0 0 \cg_pest |> @add-child
        @cg= new Phaser.Image game, 0 0 \cg_pest |> @add-child
        @cg2.kill!
        #@BS=BS=game.cache._images.cg_border.frameWidth
        @BS=BS=(get-cached-image \cg_border)frameWidth
        @bl = new Phaser.TileSprite game, -BS+1, 0, BS,BS, 'cg_border', 1 |> @add-child # left
        @br = new Phaser.TileSprite game, 0, 0, BS,BS, 'cg_border', 1 |> @add-child # right
        @bt = new Phaser.TileSprite game, 0, -BS+1, BS,BS, 'cg_border', 0 |> @add-child # top
        @bb = new Phaser.TileSprite game, 0, 0, BS,BS, 'cg_border', 0 |> @add-child # bottom
        @btl = new Phaser.TileSprite game, -BS+1, -BS+1, BS,BS, 'cg_border', 2 |> @add-child # topleft
        @bbl = new Phaser.TileSprite game, -BS+1, 0, BS,BS, 'cg_border', 4 |> @add-child # bottomleft
        @btr = new Phaser.TileSprite game, 0, -BS+1, BS,BS, 'cg_border', 3 |> @add-child # topright
        @bbr = new Phaser.TileSprite game, 0, 0, BS,BS, 'cg_border', 5 |> @add-child # bottomright
        @resize @cg.width, @cg.height

        @border=[@btl,@bt,@btr,@bl,@br,@bbl,@bb,@bbr]

    resize: (@w,@h)!->
        @br.height=@bl.height=@h
        @bb.width=@bt.width=@w
        @bbr.x=@btr.x=@br.x=@w - 1
        @bbr.y=@bbl.y=@bb.y=@h - 1

    crop: (x,y,w,h)!->
        @resize w, h if @w isnt w or @h isnt h
        @cg.crop x:x, y:y, width:w, height:h

    kill: Phaser.Sprite.prototype.kill
    revive: Phaser.Sprite.prototype.revive

    show: (key, fin)!->
        dialog.move_to_frame!
        @revive!
        @alpha=0
        #solidscreen.alpha=0.8
        cinema_start!
        @cg.load-texture key if key
        transition = new Transition 500, (t)->
            solidscreen.alpha=0.8*t
            @alpha=t
        , -> fin?!
        , null, true, @, @

    hide: (fin)!->
        transition = new Transition 500, (t)->
            solidscreen.alpha=0.8*(1-t)
            @alpha=1-t
        , ->
            dialog.move_to_bottom!
            @kill!
            #solidscreen.alpha=0
            cinema_stop!
            fin?!
        , null, true, @, @

    showfast: (key)!-> #show with no transition. For loading screen.
        @revive!
        @cg.load-texture key if key
        @alpha=1

    fade: (key, fin)!->
        @cg2.revive!
        @cg2.load-texture @cg.key
        @cg.alpha=0
        @cg.load-texture key
        transition = new Transition 500, (t)->
            @cg.alpha=t
        , !->
            @cg2.kill!
            fin?!
        ,null, true, @, @

class Dialog-Window extends Window
    ->
        super -144, -80, 18, 4
        @speaker = @add-text 'font_yellow', '', 10, 8
        @message = @add-text null, '', 8, 20, true, 45, 12
        @port = @add-child new Portrait WS*18, 0, null
        @port.anchor.set 1.0
        @menu = @add-child new Menu 0, -WS*6.5, 12, 6
        @number = @add-child new Number_Dialog 0, -WS*6.5
        @textentry = gui.frame.add-child new TextEntry WS, WS*4
        @textentry.kill!
        @port.kill!
        @menu.kill!
        @number.kill!
        @queue = []
        @menu.queue = []
        #@actorspaused = actors.paused
        game.input.onDown.add @click, @
        keyboard.confirm.onDown.add @click, @
    say: (speaker=null, message='', pose=null)!->
        reviveme = @queue.length is 0
        #for t in Transition.list then if t.cinematic
        #    reviveme=t.duration
        @revive! if reviveme is true
        if typeof speaker is \function #function in dialog queue
            @queue.push speaker
        else
            @queue.push speaker: speaker, message: message, pose: pose
        if reviveme isnt false
            actors?paused = true
            #if typeof t is \number
            #    self=this
            #    setTimeout (!->self.revive!;self.next!),reviveme
            #else
            @next!
    update: !->
        super ...
        h=if @message.string and @message.height>40 then 5 else 4
        if @h isnt h then @resize @w, h
    say_now: (speaker=null,message='',pose=null)!->
        @menu.history=[]
        @queue.shift!
        @queue.unshift speaker: speaker, message: message, pose: pose
        @next!
    next: !->
        @queue.0?!
        name = @queue.0.speaker?to-lower-case!
        portpose = @queue.0.pose
        #portpose = 'default' unless portpose?
        @port.change name, portpose
        if @queue.0.options?
            @next_menu!
        else if @queue.0.numberdialog?
            dialog.number.show @queue.0.numberdialog, @queue.0.min, @queue.0.max
        unless @queue.0.message?
            @click!
            return
        if speakers[name]?
            @speaker.change speakers[name]display
            @speaker_key=name
        else if name?
            @speaker.change @queue.0.speaker #empty or unique name
            @speaker_key=''
        @message.change @queue.0.message
        console.log @speaker.get_text!+' says "'+@queue.0.message+'"'
    next_menu: !->
        if @queue.0.options?
            @menu.offset=0
            @menu.revive!
            @menu.options = @queue.0.options
            @menu.actions = @queue.0.actions
            @menu.refresh!
            #xsize=2
            @resize_menu!
        else
            @menu.kill!
    resize_menu: !->
            longestoption=0
            for option in @menu.options
                longestoption=option.length*FW+20 >? longestoption
            @menu.resize (Math.ceil longestoption/WS), @menu.options.length+2 <? 6
    click: (e={})!->
        return if (@locked or @textentry?alive) and e isnt \ignorelock
        #or @menu.alive
        return unless @alive and nullbutton e.button
        
        return true if @menu.alive and e isnt \ignorelock
        return true if @number.alive

        if @message.textbuffer.length > 0 and e isnt \ignorelock
            @message.empty_buffer!
            @click! if @queue.1?options? or @queue.1?numberdialog? or @queue.1?autocall
            return true
        
        @queue.shift!
        for item in @menu.queue
            @queue.unshift @menu.queue.pop!
        if @queue.length is 0
            @kill!
        else
            @next!
        menusound.play 'blip'
        return false # end input
    kill: !->
        super ...
        @menu.kill!
        #actors.paused = false unless @actorspaused
        if pause_screen.alive then pause_screen.visible=true
        @port.change null, 'default'
    revive: !->
        super ...
        #@actorspaused = actors.paused
        if pause_screen.alive then pause_screen.visible=false
        menusound.play 'blip'

    move_to_frame: (nowindow=true, @hideport=false)!->
        #if @tiles then for tile in @tiles
        for tile in @tiles
            tile.visible=!nowindow
        @port.y=HEIGHT
        @x=0
        @y=0
        gui.frame.add-child @parent.remove-child @
        @menu.y=64
        for tile in @menu.tiles
            tile.visible=!nowindow

    move_to_bottom: (nowindow=false, @hideport=false)!->
        #if @tiles then for tile in @tiles
        for tile in @tiles
            tile.visible=!nowindow
        @port.y=0
        @x=-144
        @y=-80
        gui.dock.add-child @parent.remove-child @
        @menu.y=-104
        for tile in @menu.tiles
            tile.visible=!nowindow

#new text class for unifont
class Text extends Phaser.Image
    (color='font',@string='',x=0,y=0, @teletype = false, @line-width = 0, @line-height=12)->
        #super game, null, @string.substr(0,4)
        super game,x,y
        color=@font_to_color color
        @font='unifont'
        @bitmap = new Phaser.BitmapText game, 0,0,@font,'',10
        #texture=@face.generateTexture!
        @add-child <| @shadow1 = new Phaser.Image game, -1, 0, 'empty'
        @add-child <| @shadow2 = new Phaser.Image game, 0, -1, 'empty'
        @add-child <| @face = new Phaser.Image game, -1, -1, 'empty'
        @shadow1.anchorlink=@shadow2.anchorlink=@face.anchorlink=true
        #@add-child <| @shadow3 = new Phaser.Image game, 1, 1, null
        #@add-child @face
        if game.renderType is Phaser.WEBGL
            @bitmap.tint=color
        @shadow1.tint=@shadow2.tint=@tint=0
        @timer = 0
        @textbuffer = []
        @real_anchor = new Phaser.Point!
        @change string, color
        Object.defineProperty @anchor,'x',
            set:(v)~>for child in @children then if child.anchorlink then child.anchor.x=Math.ceil(@width*v)/(@width||1);@real_anchor.x=v
            get:~>@face.anchor.x
        Object.defineProperty @anchor,'y',
            set:(v)~>for child in @children then if child.anchorlink then child.anchor.y=Math.ceil(@height*v)/(@height||1);@real_anchor.y=v
            get:~>@face.anchor.y
        @anchor.set=(x,y)!~>
            @anchor.x=x; @anchor.y=y
            return @anchor
    font_to_color: (font)->
        switch font
        | 'font' => @@WHITE
        | 'font_gray' => @@GRAY
        | 'font_green' => @@GREEN
        | 'font_red' => @@RED
        | 'font_yellow' => @@YELLOW
        default font
    change: (text,color)!->
        if @textbuffer.length > 0
            @empty_buffer!
        text ?= @string
        #break lines
        text = break-lines3 text, @line-width, @font
        #teletype
        teletype = if gameOptions.quicktext then false else @teletype
        @textbuffer = if teletype then text/'' else []
        @string = if teletype then '' else text
        #update text
        color=@font_to_color color
        @bitmap.color=color
        if game.renderType is Phaser.WEBGL
            @bitmap.tint=color if color? and @bitmap.tint isnt color
        else
            #@face.tint=color if color? and @face.tint isnt color
            #@face.alpha=(togray color)/Text.WHITE
            @face.alpha=if color is Text.RED or color is Text.GRAY then 0.5 else 1
        @update_text!
    buffer: (text)!->
        @textbuffer = @textbuffer ++ text/''
    empty_buffer: !->
        @string += @textbuffer.join ''
        @textbuffer.length=0
        @update_text!

    update: !->
        return if @textbuffer.length is 0
        for t in Transition.list then if t.cinematic then return
        speed = (100 - gameOptions.textspeed)#*1.5
        if speed is 0
            @empty_buffer!
        else
            @timer += game.time.elapsed
            count = Math.floor(game.time.elapsed / speed) >? 1
            if @timer > speed*count
                if Date.now! - voicesound.lastplayedtime > (speed*2.5 >? 100)
                    soundkey=if @parent is dialog and speakers[dialog.speaker_key]?voice?
                    then speakers[dialog.speaker_key].voice else \blip
                    voicesound.play soundkey, true
                    #voicesound[soundkey]_sound.playbackRate.value=if soundkey is \blip then Math.random!*0.1+0.95 else Math.random!*0.2+0.9
                    if soundkey isnt \blip
                        voicesound[soundkey]_sound.playbackRate.value=Math.random!*0.2+0.9
                for from 1 to count
                    @string += @textbuffer.shift!
                    break if @textbuffer.length is 0
                @timer -= speed*count
                @update_text!
        if @parent instanceof Dialog-Window and @textbuffer.length is 0 and (@parent.queue.1?options or @parent.queue.1?numberdialog? or @parent.queue.1?autocall)
            @parent.click!

    update_text: !->
        #PIXI.BitmapText.fonts[@font].line-height=@line-height
        #@bitmap.maxWidth=@line-width*FW
        game.cache.getBitmapFont(@font).font.lineHeight=@line-height
        #IMPORTANT TODO: fix line height
        @bitmap.setText @string
        @bitmap.updateText!
        if @monospace
            for char,i in @bitmap.children
                char.x=i*@monospace
        if game.renderType is Phaser.WEBGL
            stripstring=@string.replace(/\r?\n|\r/g,'')
            stripstring=(if Array.from then Array.from(stripstring) else stripstring)
            for char,i in @bitmap.children
                if @@colormap[stripstring[i]]?
                    char.tint=@@colormap[stripstring[i]]
                if i>0 and (c=@@dualcolors[stripstring[i-1]+stripstring[i]])
                    c.0&&(@bitmap.children[i-1].tint=c.0)
                    c.1&&(@bitmap.children[i].tint=c.1)

        
        texture=@bitmap.generateTexture!
        @shadow1.load-texture texture
        @shadow2.load-texture texture
        @face.load-texture texture
        @load-texture texture
        @anchor.set @real_anchor.x, @real_anchor.y


    hover: ->
        mouse.x>=@worldTransform.tx - @width*@anchor.x - 2
        and mouse.x<@worldTransform.tx + @width*(1-@anchor.x)
        and mouse.y>=@worldTransform.ty - @height*@anchor.y - 2
        and mouse.y<@worldTransform.ty + @height*(1-@anchor.y)
    kill: Phaser.Sprite::kill
    revive: Phaser.Sprite::revive

    get_text: -> @string

    @WHITE=0xd8d8d8
    @GRAY=0x787878
    @GREEN=0x58d858
    @RED=0xf85858
    @ORANGE=0xf8aa33
    @YELLOW=0xf8d878
    @BLUE=0x78f8ef
    @PURPLE=0xaf5996
    @INDIGO=0x816ee2
    @BLACK=0x475381
    @CRIMSON=0xc4321a

    @colormap=
        '♥':@RED, '♡':@RED
        '🧡':@ORANGE
        '💛':@YELLOW
        '💚':@GREEN
        '💙':@BLUE
        '💜':@PURPLE
        '🖤':@BLACK
        '👺':@RED
        '⚕':@RED #Asclepius
        '★':@YELLOW,'☆':@YELLOW
        '♩':@BLUE,'♪':@BLUE,'♫':@BLUE,'♬':@BLUE
        '✚':@GREEN
        '\ueb00':@WHITE,'\ueb02':@WHITE
        '\ueb06':@WHITE,'\ueb07':@WHITE
        '\ueb01':@RED, '\ueb03':@RED
        '💧':@BLUE
        '✖':@INDIGO

    @dualcolors=
        '\ueb00⚕':[@RED,null]#Cure sigil left
        '⚕\ueb02':[null,@RED]#Cure sigil right
        #'\ueb04♥':[@RED,@ORANGE]
        #'♥\ueb05':[@ORANGE,@RED]
        '\ueb09🧡':[@RED,@ORANGE]
        '🧡\ueb0A':[@ORANGE,@RED]
        '\ueb04✖':[@GRAY,@INDIGO]
        '\ueb01\ueb05':[@INDIGO,@GRAY]
        '\ueb04\ueb01':[@GRAY,@INDIGO]
        '✖\ueb05':[@INDIGO,@GRAY]
        '\ueb06\ueb01':[null,@PURPLE]


    invalid_chars: (c)!->
        code=c.codePointAt(0)
        #return c if game.cache._bitmapFont[@font]chars[code]
        return c if game.cache.getBitmapFont(@font).font.chars[code]
        #return "\u200b" #for non-display characters.

        return "\ufffd"
        #return '?'
        

class Floating-Text extends Text
    (font, string, x, y, @life=2, @speed)->
        super font, string, x, y
        @anchor.set 0.5 1.0
    pre-update: !-> #for life span
        super ...
        return if !@alive
        if @lifespan<1000
            @alpha=@lifespan/1000
        @y -= 10*game.time.physicsElapsed
        if @lifespan > 0
            @lifespan -= @game.time.physicsElapsedMS;
            if @lifespan <= 0
                @kill!
                return false
        return true
    show: (@x,@y,text,font)!->
        @alpha=1
        @lifespan = @life*2000
        @revive!
        @change text, font
    callback: ->
    kill: ->
        @callback!
        super ...

class TextEntry extends Window
    (x,y,@limit=140)->
        w=18; h=6
        super x,y,w,h
        @string=''
        @prompt=''
        @entry= @add-text 'font_yellow', '_', HWS, HWS, false, (w-1)*WS/FW, 12
        @limit_text= @add-text 'font', ''+@limit, (w-0.5)*WS, (h-1)*WS
        @limit_text.anchor.set 1 0
        @confirm = @add-text null, 'Confirm', HWS, (h-1)*WS
        @caret_start=0
        @caret_end=0
        #@caret=@add-child new Phaser.Image game, HWS, HWS, 'solid'
        #@caret.width=2; @caret.height=13
        #@caret.tint=0
        #@caret.face = @caret.add-child new Phaser.Image game, 0 0, 'solid'
        #@caret.face.width=1; @caret.face.height=12
        #@resize!
        game.input.onDown.add @click, @
    update: !->
        return if not @alive
        textinput.focus!
        if @string isnt textinput.value
        or @caret_start isnt textinput.selectionStart
        or @caret_end isnt textinput.selectionEnd
            @caret_start=textinput.selectionStart
            @caret_end=textinput.selectionEnd
            if textinput.value.length>@limit
                textinput.value=textinput.value.substr(0,@limit)
            newstring=''
            for c in (if Array.from then Array.from(textinput.value) else textinput.value)
                newstring+=@entry.invalid_chars c
            @string=textinput.value=newstring
            @entry.change @string || @prompt
            @limit_text.change ''+(@limit - @string.length)
            for i from @caret_start to @caret_end
                break unless char=@entry.bitmap.children[i]
                char.tint=if i is @caret_end then 0xffffff else Text.BLUE
            @entry.face.load-texture @entry.bitmap.generateTexture!
            @resize!
        if @confirm.hover!
            if @confirm.bitmap.color isnt Text.YELLOW
                @confirm.change null 'font_yellow' 
                menusound.play 'blip'
        else
            @confirm.change null 'font' if @confirm.bitmap.color isnt Text.WHITE
    click: !->
        return unless @alive
        if @confirm.hover!
            @enter!
            return false
    enter: !->
        return if not @alive
        @kill!
        @callback @string
    show: (@limit=140,message='Say something!',@callback)!->
        reset_keyboard();
        @revive!
        @string=textinput.value=''
        @caret_start=@caret_end=0
        @prompt=message
        @entry.change message
        @limit_text.change ''+@limit
        @resize!
        menusound.play 'blip'

    resize: !->
        h= Math.max 3, Math.ceil (@entry.height+WS+@entry.line-height)/WS
        h=3 if !@entry.string
        if h isnt @h then super @w, h
        @y=HHEIGHT - h*HWS
        @limit_text.y=@confirm.y=(@h-1)*WS
        

class Menu_Base extends Window
    (x,y,w,h,nowindow)->
        super ...
        @arrowd = @add-child new Phaser.Sprite game, 0 5, 'arrowd', 0
        @arrowu = @add-child new Phaser.Sprite game, 0 5, 'arrowu', 0
        @arrowd.anchor.set 0.54 1.0
        @arrowu.anchor.set 0.54 0
        @arrowd.oy = @arrowd.y; @arrowu.oy = @arrowu.y

        game.input.onDown.add @click, @
        keyboard.up.keyDown.add @ーup, @
        keyboard.down.keyDown.add @ーdown, @
        keyboard.left.keyDown.add @ーleft, @
        keyboard.right.keyDown.add @ーright, @
        keyboard.confirm.onDown.add @select, @
        keyboard.cancel.onDown.add -> (@cancel ...), @
        Menu.list.push @

    click:->
    select:->
    cancel:->
    ーup:->
    ーdown:->
    ーleft:->
    ーright:->
    scroll:->

    destroy: !->
        super ...
        Menu.list.splice Menu.list.indexOf(@), 1


class Number_Dialog extends Menu_Base
    (x,y)->
        w=12; h=4
        super x,y,w,h,false
        @num=0
        @number = @add-text 'font_yellow', '0 0 0', 10, WS+HWS
        @number.anchor.set 0 0
        @number.monospace=FW2
        @note = @add-text null, 'Max', (w-0.5)*WS, (h-1)*WS
        @note.anchor.set 1 0
        @confirm = @add-text null, 'Confirm', 8, (h-1)*WS
        @min=0; @max=999; @digits=3
        @selected=0

        @letters1='ABCDEFGHIJKLMNOPQRSTUVWXYZ'
        @letters2='_abcdefghijklmnopqrstuvwxyz'

        @arrowu.y=HWS+4
        @arrowd.y=3*WS-4
        @arrowd.oy = @arrowd.y; @arrowu.oy = @arrowu.y

        @show 'Max 999' 0 999 #test


    update: !->
        return if not @alive
        if (s=@hover_number!) isnt false and @selected is not s
            @change_selection s
            menusound.play 'blip'

        hover = @hover_arrow!
        @arrowd.y = @arrowd.oy
        @arrowu.y = @arrowu.oy
        if hover is \down
            menusound.play 'blip' unless @arrowd.hover or not @arrowd.alive
            @arrowd.hover = true
            @arrowd.y += 2
        else @arrowd.hover = false
        if hover is \up
            menusound.play 'blip' unless @arrowu.hover or not @arrowu.alive
            @arrowu.hover = true
            @arrowu.y -= 2
        else @arrowu.hover = false

        if (@mode is \string) or (@num<=@max and @num>=@min)
            if @confirm.hover!
                #if @confirm.font_key isnt 'font_yellow'
                if @confirm.bitmap.color isnt Text.YELLOW
                    @confirm.change null 'font_yellow' 
                    menusound.play 'blip'
            else
                #@confirm.change null 'font' if @confirm.font_key isnt 'font'
                @confirm.change null 'font' if @confirm.bitmap.color isnt Text.WHITE
        else
            #@confirm.change null 'font_gray' if @confirm.font_key isnt 'font_gray'
            @confirm.change null 'font_gray' if @confirm.bitmap.color isnt Text.GRAY

    click: !->
        return unless @alive
        if (hover = @hover_arrow!)
            @shift 1 if hover is \up
            @shift -1 if hover is \down

        @select! if @confirm.hover!

    select: !->
        return true unless (@mode is \string) or (@num<=@max and @num>=@min)
        @kill!
        #if @parent instanceof Dialog-Window
            #@parent.queue.shift!
            #@parent.next!
        return true

    hover_number: !->
        if mouse.x >= @worldTransform.tx+@number.x - FW
        #and mouse.x< @worldTransform.tx+@number.x+@number.font.width
        and mouse.x< @worldTransform.tx+@number.x+@number.width
        and mouse.y>= @worldTransform.ty+@number.y - 12
        #and mouse.y< @worldTransform.ty+@number.y+@number.font.height + 10
        and mouse.y< @worldTransform.ty+@number.y+@number.height + 12
            return (mouse.x - (@worldTransform.tx+@number.x  - FW))/FW2 .|.0
        return false

    hover_arrow: !->
        if mouse.x >= @worldTransform.tx+@number.x - FW
        #and mouse.x< @worldTransform.tx+@number.x+@number.font.width
        and mouse.x< @worldTransform.tx+@number.x+@number.width
            #n=(mouse.x - (@worldTransform.tx+@number.x))/FW2 .|.0
            if mouse.y>= @worldTransform.ty+@number.y - 12
            and mouse.y< @worldTransform.ty+@number.y
                #return d:\up, n:n
                return \up
            #if mouse.y>= @worldTransform.ty+@number.y+@number.font.height
            #and mouse.y< @worldTransform.ty+@number.y+@number.font.height + 10
            if mouse.y>= @worldTransform.ty+@number.y+@number.height
            and mouse.y< @worldTransform.ty+@number.y+@number.height + 12
                #return d:\down, n:n
                return \down
        return false

    show: (note,@min=0,@max=999)!->
        @revive!
        @note.change note
        @mode = typeof @min
        if @mode is \string
            @digits=max || 13
            @num=repeatString$(@letters2[0],@digits).split('')
            @num[0]=@letters1[0]
            @number.change @num.join('')
        else #number
            @num=0
            @digits=@max.to-string!length
            @number.change ('0'*@digits)#.split('').join(' ')

        #@number.x = @w*HWS - @number.font.width/2
        @number.x = @w*HWS - @number.width/2
        @change_selection 0

    scroll: !(e)->
        if game.input.mouse.wheelDelta > 0
            @shift 1
        else
            @shift -1

    ーup: !-> @shift 1
    ーdown: !-> @shift -1
    ーleft: !->
        return if not @alive
        #@selected=@digits-1 if --@selected < 0
        @shift_selection -1
        menusound.play 'blip'
    ーright: !->
        return if not @alive
        #@selected=0 if ++@selected >= @digits
        @shift_selection 1
        menusound.play 'blip'

    shift: (amount)!->
        return if not @alive
        #num=+@num.to-string![@selected]+amount
        #while num<0 then num+=10
        #while num>9 then num-=10
        #text = @num.to-string!substr(0,@selected)+num+@num.to-string!substr(@selected+1)
        if @mode is \string
            letters=if @selected is 0 then @letters1 else @letters2
            n=letters.indexOf(@num[@selected])+amount
            while n<0 then n+=letters.length
            while n>letters.length-1 then n-=letters.length
            @num[@selected]=letters[n]
            @number.change @num.join('')
        else
            alreadymax=@num is @max
            pn=pad '0'*@digits, @num, true
            n=+pn[@selected]+amount
            while n<0 then n+=10
            while n>9 then n-=10
            text = pn.substr(0,@selected)+n+pn.substr(@selected+1)
            if alreadymax and +text>@max then @num=@min
            else @num=Math.min(Math.max(+text,@min),@max)
            text=pad '0'*@digits, @num, true
            @number.change text#.split('').join(' ')
        menusound.play 'blip'

    shift_selection: (amount)!->
        @change_selection @selected+amount

    change_selection: (@selected)!->
        while @selected<0 then @selected+=@digits
        while @selected>=@digits then @selected-=@digits
        @arrowd.x=@arrowu.x=@number.x+2 + @selected*FW2


class Menu extends Menu_Base
    (x,y,w,h,@nowindow, @iconmode=false, @BH=WS)->
        super ...
        @arrow = @add-child new Phaser.Sprite game, -2, 0, 'arrow', 0
        @arrow.anchor.set 0 0.54
        #@arrowd = @add-child new Phaser.Sprite game, 0 5, 'arrowd', 0
        #@arrowu = @add-child new Phaser.Sprite game, 0 5, 'arrowu', 0
        #@arrowd.anchor.set 0.54 1.0
        #@arrowu.anchor.set 0.54 0
        #@arrowd.oy = @arrowd.y; @arrowu.oy = @arrowu.y
        @history = []
        @dontkill = false
        @donteverkill = false
        @options = []
        @actions = []
        @buttonlist = []
        @icons = []
        @sliders=[]
        @slider_width=@width - 16
        @selected = 0
        @offset = 0
        @resize_menu!
        @inscreen = false

        #game.input.onDown.add @click, @
        #keyboard.up.keyDown.add @up, @
        #keyboard.down.keyDown.add @down, @
        #keyboard.left.keyDown.add @left, @
        #keyboard.right.keyDown.add @right, @
        #keyboard.confirm.onDown.add @select, @
        #keyboard.cancel.onDown.add -> (@cancel ...), @
        #Menu.list.push @
    @list = []

    resize: !->
        super ...
        @resize_menu!
    resize_menu: !->
        @arrowu.x = @arrowd.x = @w*WS/2
        @arrowd.oy = @arrowd.y = @h*WS - 5
        for button in @buttonlist
            button.kill!
        @buttons = []
        for i from 0 til (@h-2)*WS / @BH #@h - 3
            @add-button! if not @buttonlist[i]?
            @buttonlist[i]revive!
            #@buttonlist[i].line-width = Math.floor (WS/6)*(@w-1)
            @buttons.push @buttonlist[i]
        @refresh!
        ## push arrow to front
        #@children.push @children.splice((@children.indexOf @arrow),1)0

    add-button: !->
        xpos = if @iconmode then 26 else 10
        @buttonlist.push text = @add-text null '' xpos, (@buttonlist.length)*@BH+WS+@BH/2, false, 0
        text.anchor.set 0, 0.5
        text.kill!
        if @iconmode
            text.icon = new Phaser.Sprite game, -18, -8, 'item_misc' |> text.add-child
            text.icon.kill!

    #destroy: !->
    #    super ...
    #    Menu.list.splice Menu.list.indexOf(@), 1
    refresh: !->
        for slider in @sliders
            slider.0.visible=false; slider.1.visible=false
        for option, i in @options
            ii = i - @offset
            continue if ii < 0
            break unless @buttons[ii]?
            font = if typeof @actions[i] in ['function', 'object'] then 'font' else 'font_gray'
            font = 'font' if @actions[i] is 'back'
            @buttons[ii].change if option.label then that else option, font
            #special controls
            switch option.type
            |\slider => @slider i,ii
            |\switch =>
                @buttons[ii].change null, if @actions[i].get! then 'font_green' else 'font_red'
            #
            @buttons[ii].icon.kill! if @iconmode and not @icons[i]?
            if @iconmode and @icons[i]?
                @buttons[ii].icon.revive!
                if typeof @icons[i] is \string
                    @buttons[ii].icon.load-texture @icons[i]
                else if typeof @icons[i] is \object
                    @buttons[ii].icon.load-texture @icons[i].key
                    @buttons[ii].icon.frame=@icons[i].x
                    setrow @buttons[ii].icon, @icons[i].y
        for j from ii+1 til @buttons.length
            @buttons[j].change ''
            @buttons[j].icon.kill! if @iconmode
        selected=@selected
        @selected = 0 >? @selected
        @selected = @options.length - 1 <? @buttons.length - 1 <? @selected
        if selected isnt @selected
            @on-change-selection @selected

        @arrowu.kill!
        @arrowd.kill!
        @arrowu.revive! if @offset > 0
        @arrowd.revive! if @offset < @options.length - @buttons.length
        @on-refresh!
    on-refresh: !->
    get_slider: !->
        for slider in @sliders
            return slider unless slider.0.visible
            slider=null
        unless slider
            slider =
                @add-child-at (new Phaser.TileSprite game, 5 0, @slider_width, 10, 'bars', 1),@children.indexOf(@arrow)
                @add-child-at (new Phaser.TileSprite game, 5 0, @slider_width, 10, 'bars', 2),@children.indexOf(@arrow)
            @sliders.push slider
        return slider
    slider: (i,ii)!->
        b=@buttons[ii]
        slider=@get_slider!
        b.slider=slider
        for s in slider
            s.y = b.y - 6
            s.visible=true
        o=@options[i]
        slider.1.width=@slider_width*(@actions[i].get!-o.min)/(o.max - o.min)
    slide_value: (v)!->
        i=@selected + @offset
        o=@options[i]
        @dontkill=true
        return unless o.type is \slider
        if !v?
            rect = @get_button_rect!
            #return unless point_in_body mouse, rect
            v = (mouse.x - rect.x)/rect.width
        v = 0>? v <? 1
        vv = (o.max - o.min)*v + o.min
        #@actions[i]? v
        @actions[i].set vv
        @buttons[@selected].slider.1.width=@slider_width*v
        o.onswitch?!
        #save!
        save_options!
    switch_value: !->
        i=@selected+@offset
        o=@options[i]
        @dontkill=true
        return unless o.type is \switch
        @actions[i].set !@actions[i].get!
        @buttons[@selected].change null, if @actions[i].get! then 'font_green' else 'font_red'
        save_options!
        o.onswitch?!
    revive: !->
        super ...
        @refresh!

    select: !->
        i = @selected + @offset
        return if @inscreen and dialog?alive and !@parent.lockdialog
        or not @alive 
        return if typeof @actions[i] not in ['function', 'object'] and @actions[i] isnt 'back'
        #empty text buffer
        if @parent instanceof Dialog-Window and !@parent.locked
            @parent.message.empty_buffer!
        #perform action
        if @options[i].type is \slider then result=true; @slide_value!
        else if @options[i].type is \switch then result=true; @switch_value!
        else if @actions[i] is \back then return @cancel!
        else result = process_callbacks.call @, @actions[i]
        #kill menu
        if @dontkill or @donteverkill
            @dontkill = false
        else
            @history=[]
            @kill!
        menusound.play 'blip'
        #return result if dialog?alive
        return result if @parent is dialog
        return @parent is dialog
    click: (e={})!->
        return if not @alive
        or @inscreen and dialog?alive and !@parent.lockdialog
        if nullbutton e.button
            if @adjust_arrows! then hover = @hover_scroll @arrowu.height
            else hover = @hover_scroll!
            if hover
                if hover is @arrowd and @arrowd.alive
                    menusound.play 'blip'
                    return @scrolldown!
                if hover is @arrowu and @arrowu.alive
                    menusound.play 'blip'
                    return @scrollup!
            return @select! if @hover_button!?
        else if e.button is 2
            return @cancel!
    cancel: !->
        return true if not @alive
        or @inscreen and dialog?alive and !@parent.lockdialog
        return if @history.length is 0
        revert = @history.pop!
        @options = revert.options
        @actions = revert.actions
        @offset=0
        @queue = []
        @refresh!
        if dialog and this is dialog.menu then dialog.resize_menu!
        menusound.play 'blip'
        return false
    shift_slider: (v)!->
        i=@selected+@offset
        o=@options[i]
        return unless o.type is \slider
        @slide_value (@actions[i].get!-o.min)/(o.max - o.min) + v
    ーleft: !->
        return unless @alive;
        if @horizontalmove then return @ーup!
        if @options[@selected+@offset].type is \slider
            @shift_slider -0.1; menusound.play 'blip'
    ーright: !->
        return unless @alive;
        if @horizontalmove then return @ーdown!
        if @options[@selected+@offset].type is \slider
            @shift_slider 0.1; menusound.play 'blip'
    ーup: !->
        return if not @alive
        or @inscreen and dialog?alive and !@parent.lockdialog
        @selected--
        if @selected < 0
            @scrollup true
        @on-change-selection @selected
        menusound.play 'blip'
    scrollup: !(wrap=false)->
        if @offset > 0
            @selected++
            @offset --
            s=true
        else if @options.length > @buttons.length and wrap
            @offset = @options.length - @buttons.length
            @selected = @buttons.length - 1
        else if wrap
            @selected = @options.length - 1
        @refresh!
        return s

    ーdown: !->
        return if not @alive
        or @inscreen and dialog?alive and !@parent.lockdialog
        @selected++
        if @selected >= @buttons.length <? @options.length
            @scrolldown true
        @on-change-selection @selected
        menusound.play 'blip'
    scrolldown: !(wrap=false)->
        if @offset < @options.length - @buttons.length
            @selected --
            @offset++
            s=true
        else if wrap
            @offset = 0
            @selected = 0
        @refresh!
        return s
    scroll: !(e)->
        return if @inscreen and dialog?alive and !@parent.lockdialog
        if game.input.mouse.wheelDelta > 0
            if @hover_selected! and @options[@selected+@offset]?type is \slider then return @ーright!
            else s=@scrollup!
        else
            if @hover_selected! and @options[@selected+@offset]?type is \slider then return @ーleft!
            else s=@scrolldown!
        if @options.length > @buttons.length and s
            menusound.play 'blip'
    update: !->
        return if not @alive
        or @inscreen and dialog?alive and !@parent.lockdialog
        hover = @hover_button!
        if @options[hover]? and @selected is not hover
            menusound.play 'blip'
            @selected = hover
            @on-change-selection @selected
        #@arrow.y = (@selected)*@BH+WS+@BH/2
        if @buttons[@selected]
            @arrow.y = @buttons[@selected].y
            @arrow.x = @buttons[@selected].x - 12 - (if @iconmode then 16 else 0)

        @arrowd.y = @arrowd.oy
        @arrowu.y = @arrowu.oy
        # make sure arrows are on screen
        if @adjust_arrows!
            @arrowu.y+=@arrowu.height
            @arrowd.y-=@arrowd.height
            hover = @hover_scroll @arrowu.height
        else
            hover = @hover_scroll!

        if hover is @arrowd
            menusound.play 'blip' unless @arrowd.hover or not @arrowd.alive
            @arrowd.hover = true
            @arrowd.y += 2
        else @arrowd.hover = false
        if hover is @arrowu
            menusound.play 'blip' unless @arrowu.hover or not @arrowu.alive
            @arrowu.hover = true
            @arrowu.y -= 2
        else @arrowu.hover = false
    adjust_arrows: ->
        @arrowu.parent.worldTransform.ty+@arrowu.y < 0
        or @arrowd.parent.worldTransform.ty+@arrowd.y > game.height
    get_button_rect: (i=@selected)!->
        #return x: @worldTransform.tx+5, y: @worldTransform.ty+(i)*@BH+WS, width: @w*WS - 10, height: @BH
        return x: @worldTransform.tx+@buttons[i].x-5, y: @worldTransform.ty+@buttons[i].y - (@buttons[i].BH or @BH)/2, width: @buttons[i].BW or @w*WS - 10, height: @buttons[i].BH or @BH
    hover_scroll: (offset=0)!->
        rect = x: @worldTransform.tx+HWS, y: @worldTransform.ty + offset, width: (@w-1)*WS, height: WS
        return @arrowu if point_in_body mouse, rect
        rect.y = @worldTransform.ty+(@buttons.length)*@BH+WS - offset
        return @arrowd if point_in_body mouse, rect
        return null
    hover_button: !->
        for button, i in @buttons
            rect = @get_button_rect i
            return i if point_in_body mouse, rect
        return null
    hover_selected: !->
        return point_in_body mouse, @get_button_rect @selected
    on-change-selection: (i)!->
    nest: !->
        #??? What is going on here?
        if !dialog? this isnt dialog.menu or (@queue.length is 0 and dialog.queue.0?options?) #previous is menu
            @change ...
        else
            @history = []
            menu ...
        if dialog and this is dialog.menu then dialog.resize_menu!
    menu: !->
        @history=[]
        menu ...
    change: !-> # nested menu
        hist = options: @options, actions: @actions
        @history.push hist if @set ...
        @dontkill = true
    set: !->
        return false unless @check_arguments ...
        #@offset=0
        @options = []; @actions = []; @icons = []
        for option, i in arguments by 2
            action = arguments[i+1]
            if option instanceof Array
                @options.push option[0]
                @icons[@options.length - 1] = option[1]
            #else if typeof option is \object
            #    @options.push option.label
            else @options.push option
            @actions.push action
        @refresh!
        return true
    check_arguments: !->
        if arguments.length % 2 is not 0
            console.warn 'Menu arguments must be even!'
            console.log &
            return false
        return true
    say: say
    number: number
    show: (pose='default')!->
        @queue.push pose:pose
        
class Portrait extends Phaser.Sprite
    (x,y,key)->
        super game, x, y, key
        @anchor.set 1.0 0.5
        @mad=false
        @add-child <| @face=new Phaser.Sprite game, 0,0, ''
        @face.load_port = @load_port
    change: (name=@name, pose)!->
        pose = 'default' if name is not @name and not pose?
        or not speakers[name]?[pose]? and pose?
        pose = @pose unless pose?
        if name of speakers
            speaker=speakers[name]
            @revive! unless @parent.hideport
            @name = name; @pose = pose
            pose = access speaker[pose]
            if !speaker.default?
                @kill!
            else if speaker.composite
                @face.revive!
                p=speaker.composite.player
                #load base
                if pose.base
                    @load-texture access pose.base
                    @frame=(access pose.baseframe) or 0
                else if speaker.composite.base
                    @load_port access speaker.composite.base
                else if p
                    @load-texture get_costume p,null,players[p]costume,\psheet
                    @frame=get_costume p,null,players[p]costume,\pframe
                #load face
                if costumes[p] and f=get_costume p,null,players[p]costume, \fsheet
                    @face.load_port pose, (access f)
                else
                    @face.load_port pose, (access speaker.composite.face)
                if costumes[p] and f=get_costume p,null,players[p]costume, \frecolor
                    recolor @face, f.0, f.1
                @face.x=speaker.composite.x
                @face.y=speaker.composite.y
                @face.x += pose.offx if pose.offx
                @face.y += pose.offy if pose.offy
            else
                @face.kill!
                if speaker.base and typeof pose is \number
                    @load-texture access speaker.base
                    @frame=pose
                else
                    @load_port pose
        else
            @name = ''; @pose = ''
            @kill!
    load_port: (kf,base)!->
        if typeof kf is \function
            kf=access kf
        if typeof kf is \number
            @load-texture base if base
            @frame=kf
        else if typeof kf is \string
            @load-texture kf
        else if kf instanceof Array
            @load-texture kf.0
            @frame=kf.1
        else if typeof kf is \object
            temp.kfsheet=access kf.sheet
            @load-texture temp.kfsheet or base if temp.kfsheet or base
            @frame=(access kf.frame) or 0
    update: !->
        return if not @mad or not speakers[@name]?mad
        if Math.random! < @mad/50
            @load-texture speakers[@name]mad unless @key is speakers[@name]mad
        else
            @load-texture speakers[@name][@pose] unless @key is speakers[@name][@pose]


class Screen extends Phaser.Group
    ->
        super game, null, 'screen'
        @windows = []
        @history = []
    @list=[]
    for_windows: (fun, ...args)!->
        for win in @windows
            win[fun]apply win, args if win instanceof Window
    show: !->
        @revive!
        @for_windows \revive
        menusound.play 'blip'
        #if @pauseactors
        #    actors.paused = true
            #dialog.actorspaused = true if dialog.alive
        if @lockdialog and dialog?
            dialog.locked = true
        @@list.push @
    nest: !->
        @history.push @windows
        @for_windows \kill
        @windows = []
        for arg in arguments
            @windows.push arg
            arg.revive! if arg instanceof Window
    exit: !->
        #@kill!
        for entry in @history
            @back true
        @back true

    back: (force)!->
        return if @nocancel and @history.length is 0 and not force
        @for_windows \kill
        if @history.length is 0
            return @kill!
        @windows = @history.pop!
        @for_windows \revive
        return false
    add-menu: ->
        @windows.push <| menu = @create-menu ...
        menu
    add-window: -> @windows.push <| r = @create-window ... ; r
    create-menu: ->
        menu = construct Menu, & |> @add-child
        menu.inscreen = true
        override_cancel = menu.cancel
        menu.cancel =!->
            historylength = @history.length
            result = override_cancel ...
            return true if result
            menusound.play 'blip'
            @parent.back! if historylength is 0
            return false
        menu.kill!
        menu.donteverkill = true
        menu
    create-window: -> r = construct Window, & |> @add-child ; r.kill! ; r

    kill: ->
        @for_windows \kill
        Phaser.Sprite.prototype.kill ...
        if @lockdialog and dialog?
            dialog.locked = false
            dialog.click \ignorelock
        #actors.paused = false if @pauseactors and not dialog?alive
        i=@@list.indexOf @
        @@list.splice i, 1 if i>-1
    revive: ->
        @for_windows \revive
        Phaser.Sprite.prototype.revive ...
    destroy: ->
        super ...
        i=@@list.indexOf @
        @@list.splice i, 1 if i>-1

state.load.preload =!->
    #console.log("loading...")
    gui.bringToTop(gui.frame) #??? What?
    cg.showfast access zones[getmapdata \zone]cg
    solidscreen.alpha=1
    #preloader := gui.frame.create 0, HEIGHT - TS*2, 'preloader'
    gui.frame.add-child preloader.back
    gui.frame.add-child preloader
    #if !state.load.loadtext
    #    state.load.loadtext = new Text null, "Loading...",0,208
    #gui.frame.add-child state.load.loadtext
    game.load.set-preload-sprite preloader
    gui.frame.add-child preloader.text
    
    load_load!
    temp.opacity=pixel.canvas.style.opacity
    pixel.canvas.style.opacity=1
    
state.load.create =!->
    gui.frame.remove preloader
    gui.frame.remove preloader.back
    gui.frame.remove preloader.text
    #gui.frame.remove state.load.loadtext
    if switches.portal then switches.portal.loaded=true
    game.state.start 'overworld' false
    cg.kill!
    solidscreen.alpha=0
    load_done!
    pixel.canvas.style.opacity=temp.opacity

musicmap=
    battle: [\battle [\battle.ogg \battle.m4a]]
    '2dpassion': [\2dpassion [\2DPassion.ogg \2DPassion.m4a]]
    towertheme: [\towertheme [\towertheme.ogg \towertheme.m4a]]
    deserttheme: [\deserttheme [\deserttheme.ogg \deserttheme.m4a]]
    hidingyourdeath: [\hidingyourdeath ['Hiding Your Death.ogg' 'Hiding Your Death.m4a']]
    distortion: [\distortion [\distortion.ogg \distortion.m4a]]

!function load_load
    musiclist = zones[getmapdata \zone]musiclist++zones.default.musiclist
    loadlist=[]
    for item in musiclist
        loadlist.push musicmap[item] if !game.cache.checkSoundKey(musicmap[item]0)
    batchload loadlist, \music/ \audio

!function load_done
    musiclist = zones[getmapdata \zone]musiclist++zones.default.musiclist
    #create music
    for item in musiclist
        music.add item, 1 true if !music[item]?

!function mod_music(key,path)
    if(path instanceof Array) then for null,p in path
        path[p]="../"+path[p]
    else
        path="../"+path
    musicmap[key]=[key,path]

var actors, carpet, triggers, fringe
updatelist=[]
updatelist.remove=(o)!->
    i=@indexOf o
    if i>-1 then @splice i, 1

class Actor extends Phaser.Sprite
    (x,y,key,@nobody=false)->
        @water_depth = 0
        @row=0
        super game,x,y,key
        @anchor.set-to 0.5 1.0
        game.physics.arcade.enable @, false
        @body.set-size 10, 10, 0, 2
        @override_physics_update!
        @y -= @bodyoffset.y
        #@bbox = 
        #    x: -5, y: -8, w: 10, h:10
        #    tx: 8, ty: 11 #offset for centering in tile
        #@previous = x: @x, y: @y
        @goal = x: @x, y: @y
        @drift = 0
        @moving = false
        @speed = 60
        @facing = 'down'
        @facing_changed = Date.now()
        @follow_object = null
        @name = key
        @@[key] = @
        @autoplay = false
        @path = []
        @bridgemode='under'
        @terrain='grass'
        @@list.push @
        updatelist.push @
        actors.add-child @
        @lastrelocate=0
    add_facing_animation: (speed=7)!->
        @animations.add 'downleft', [4,3,5,3], speed, true
        @animations.add 'left', [7,6,8,6], speed, true
        @animations.add 'upleft', [10,9,11,9], speed, true
        @animations.add 'up', [13,12,14,12], speed, true
        @animations.add 'upright', [16,15,17,15], speed, true
        @animations.add 'right', [19,18,20,18], speed, true
        @animations.add 'downright', [22,21,23,21], speed, true
        @animations.add 'down', [1,0,2,0], speed, true
    add_simple_animation: (speed=7)!->
        @animations.add 'simple', null, speed, true
    relocate: (x,y)!-> 
        if distance @, x:x,y:y>HWIDTH
            @lastrelocate=Date.now!
        if typeof x is \string
            unless node = nodes[x]
                warn "Node '#x' doesn't exist!"
                return
            x = node.x+HTS; y = node.y+TS
        if y? then @x=x; @y=y
        else @x=x.x; @y=x.y
        @y -= @bodyoffset.y
        @cancel_movement?!
        @revive! if not @alive
        if x?properties?facing then @face x.properties.facing
        update_water_depth(@) if @ripple
    shift: (x,y)!->
        @x += x if x?
        @y += y if y?
        @cancel_movement!
    setautoplay: (animation, speed)!->
        @autoplay = true
        if typeof animation is \number
            speed = animation
            animation = null
        animation ?= @animations.currentAnim.name
        @animations.play animation
        @animations.currentAnim.speed = speed if speed?
    @list = []
    destroy: !->
        super ...
        i = @@list.indexOf @
        @@list.splice i, 1 if i isnt -1
        updatelist.remove @

    poof: !->
        @kill!
        Dust.summon @

    loadTexture: !->
        super ...
        if @body then @body.set-size @body.width, @body.height
        @row=0
        update_water_depth this, true
        #Transition.timeout 0, !-> update_water_depth this, true
        #,false,this

    setrow: (r)!->
        #return unless im=game.cache._images[@key]
        return unless im=(get-cached-image @key)
        if im.data.height>= im.frameHeight*(r+1)
            @row=r
        else @row=0
        update_water_depth this, true

!function create_actors
    triggers := game.add.group undefined, 'triggers'
    carpet := game.add.group undefined, 'carpet'
    actors := game.add.group undefined, 'actors'
    fringe := game.add.group undefined, \fringe
    actors.class-type = Actor
    
    actors.paused = false
    actors.setpaused=!->
        return true if dialog and (dialog.alive or dialog.textentry.alive)
        for s in Screen.list
            return true if s.pauseactors
        return false
    override = actors.update
    actors.update =!->
        return unless game.state.current is 'overworld'
        @paused=@setpaused!
        switches.cinema = switches.cinema2
        #log Transition.list.length
        for t in Transition.list
            (switches.cinema=true; break) if t.cinematic
        unless @paused
            #override ...
            #for child in @children by -1
            #    child.update! unless child.isdoodad
            for child in updatelist by -1
                child.update!
            return
        mouse.down=false
        #for child in @children
        #    child.update-paused?!
        for child in updatelist by -1
            if child.nobody
                child.update!
            else
                child.update-paused?!
    actors.preUpdate=!->
        for child in updatelist by -1
            #continue if child.isdoodad and (child.x<game.camera.x or child.x>game.camera.x+game.width or child.y<game.camera.y or child.y>game.camera.y+game.height)
            child.preUpdate!
    actors.postUpdate=!->
        for child in updatelist by -1
            child.postUpdate!
    #carpet.preUpdate=!->
    #    for child in @children by -1
    #        child.preUpdate! unless child.isdoodad
    triggers.update=carpet.update=fringe.update=!->
    triggers.preUpdate=carpet.preUpdate=fringe.preUpdate=!->
    triggers.postUpdate=carpet.postUpdate=fringe.postUpdate=!->
            
    create_players!

!function sort_actor_groups
    carpet |> game.world.bring-to-top
    actors |> game.world.bring-to-top
    fringe |> game.world.bring-to-top
    dustclouds |> game.world.bring-to-top
    solidscreen |> gui.send-to-back
    
Actor::update-paused =!->
    @stop! unless @autoplay
    #@cancel_movement!

Actor::update =!->
    if @body.deltaAbsX! is 0 and @body.deltaAbsY! is 0
        @moving = false 
    @follow_path!
    @apply_movement!
    
function tile_collision_recoil (o, layer, water, land)
    #sides={0:0,1:0,2:0,3:0,valueOf:->false}
    #return sides unless tile_collision o, layer, water, land
    #sides.valueOf=->true
    return false unless tile_collision o, layer, water, land
    unless tile_point_collision o, x: o.x - o.body.deltaX!, y: o.y, layer, water, land
        #sides[if o.body.deltaX!>0 then 1 else 3]=1
        o.x -= o.body.deltaX!
    else unless tile_point_collision o, x: o.x, y: o.y - o.body.deltaY!, layer, water, land
        #sides[if o.body.deltaY!>0 then 2 else 0]=1
        o.y -= o.body.deltaY!
    else unless tile_point_collision o, x: o.x - o.body.deltaX!, y: o.y - o.body.deltaY!, layer, water, land
        #sides[if o.body.deltaX!>0 then 1 else 3]=1
        #sides[if o.body.deltaY!>0 then 2 else 0]=1
        o.x -= o.body.deltaX!
        o.y -= o.body.deltaY!
    o.cancel_movement!
    #o.update_body!
    #console.debug sides
    #return sides
    return true

function actor_collision_recoil (p, a)
    unless body_collision p.body, a.body, x:-p.body.deltaX!, y:0
        p.x -= p.body.deltaX!
    else unless body_collision p.body, a.body, x:0, y:-p.body.deltaY!
        p.y -= p.body.deltaY!
    else unless body_collision p.body, a.body, x:-p.body.deltaX!, y:-p.body.deltaY!
        p.x -= p.body.deltaX!
        p.y -= p.body.deltaY!
/*
function over_water2 (o)
    tiles = Actor::getTiles.call o
    water_depth=2
    for tile in tiles
        if tile and tile.properties.terrain
            if tile.properties.terrain is 'wall'
                ;
            else if tile.properties.dcol # and check_dcol tile, body_to_rect o.body
                water_depth = (over_water_single o) <? water_depth
            else if tile.properties.terrain is 'water'
                water_depth = 1 <? water_depth
            else if tile.properties.terrain is 'fringe'
                water_depth = (over_water_single x:tile.worldX, y:tile.worldY - TS) <? water_depth
            else
                water_depth = 0 <? water_depth
    return water_depth
function over_water_single2 (o)
    #tile = map.getTile(o.x,o.y, map.tile_layer,true)
    tile = map.getTile(o.x/TS.|.0, o.y/TS.|.0, map.tile_layer, true)
    if not tile? or tile is false or not tile.properties.terrain? or tile.properties.terrain is 'water'
        return if tile?properties.terrain is 'water' then 1 else 2
    if tile.properties.terrain is 'fringe'
        return over_water_single x:o.x, y:o.y - TS
        #return over_water_single x:o.x, y:o.y - 1
    return 0
*/
function over_water (o)
    tile = map.getTile(o.x/TS.|.0, o.y/TS.|.0, map.tile_layer, true)
    if not tile? or tile is false or not tile.properties.terrain? or tile.properties.terrain is 'water'
        return if tile?properties.terrain is 'water' then 1 else 2
    if tile.properties.terrain is 'overpass' and tile.properties.dcol is '0,1,0,1' and o.bridgemode is \under
        return over_water x:o.x+1, y:o.y
    if tile.properties.terrain is 'fringe' or tile.properties.terrain is 'overpass' and o.bridgemode is \under
        return over_water x:o.x, y:o.y - TS
    return 0

/* #Unused?
Actor::update_body =!->
    @body.x = (@x - (@anchor.x * @body.width)) + @body.offset.x
    @body.y = (@y - (@anchor.y * @body.width)) + @body.offset.y

Actor::collides =(o, block=false)->
    return false unless @colliding o
    unless @colliding_point o, x:@previous.x, y:@y
        @x = @previous.x
    else unless @colliding_point o, x:@x, y:@previous.y
        @y = @previous.y
    else if block or not @colliding_point o, @previous
        @x = @previous.x
        @y = @previous.y
    @cancel_movement!
    return true
    
Actor::colliding =(o)->
    @colliding_point o, @
Actor::colliding_point =(o,p)->
    rect_collision x: p.x+@bbox.x, y: p.y+@bbox.y, w: @bbox.w, h: @bbox.h,
        x: o.x+o.bbox.x, y: o.y+o.bbox.y, w: o.bbox.w, h: o.bbox.h
*/

Actor::apply_movement =(stop_dist=1)!->
    @move_toward_point @goal
    if @moving or Math.abs(@goal.x - @x) >= stop_dist or Math.abs(@goal.y - @y) >= stop_dist
        @moving = true
        @face_point @goal
    else
        @face_point @follow_object if @follow_object? and not @path.length and not switches.cinema
        @stop! unless @autoplay

Actor::stop =!->
    if @path? and @path.length and not actors.paused
        @path.shift!
        return
    return unless @animations.currentAnim
    @frame = @animations.currentAnim._frames[3]
    @animations.stop!
    return
    
Actor::cancel_movement =!-> 
    @goal = x: @x, y: @y
    @moving = false
    
Actor::face_point =(p)!->
    if (distance @, p) is 0
    or game.time.elapsed-since(@facing_changed) < 100
    or @autoplay
    or !@animations.currentAnim
        return
    a = angleDEG @, p
    if a <= 22 or a > 337 then facing = 'right'
    else if a <= 67 then facing = 'downright'
    else if a <= 112 then facing = 'down'
    else if a <= 157 then facing = 'downleft'
    else if a <= 202 then facing = 'left'
    else if a <= 245 then facing = 'upleft'
    else if a <= 293 then facing = 'up'
    else if a <= 337 then facing = 'upright'
    #facing = \down if @animations.frameTotal <= 3
    return if !@animations.getAnimation(facing) or !@animations.getAnimation(facing)_frames.length
    #don't change facing too rapidly
    if facing != @facing
        @facing_changed = Date.now()
        @facing = facing
    @animations.play @facing

Actor::face =(direction)!->
    @animations.play direction

Actor::override_physics_update =!->
    override = @body.preUpdate
    @body.preUpdate =!->
        if not actors.paused and game.state.current is 'overworld'
            #if @sprite.drift and !(tile_passable (tile=getTileUnder x:@sprite.x,y:@sprite.y - TS) and !tile.dcol)
            #    @sprite.drift = 0
            if @sprite.drift isnt 0
                @sprite.goal.y +=  @sprite.drift*game.time.physics-elapsed
            m = x: @sprite.goal.x - @sprite.x, y: @sprite.goal.y - @sprite.y
            n = normalize m
            n.x *= @sprite.speed; n.y *= @sprite.speed
            m.x /= game.time.physics-elapsed; m.y /= game.time.physics-elapsed
            v = {}
            v.x = if Math.abs(m.x) < Math.abs(n.x) then m.x else n.x
            v.y = if Math.abs(m.y) < Math.abs(n.y) then m.y else n.y
            if @sprite.drift isnt 0
                v.y += @sprite.drift
                @sprite.drift = 0
            @velocity.set-to v.x, v.y
        else @velocity.set-to 0
        override ...
        @sprite.physics_update?! if game.state.current is 'overworld'
        
    
Actor::physics_update =!->
    if @moving and !@nobody
        tile_collision_recoil @, map.named-layers.tile_layer, @waterwalking

Actor::move_toward_point =(p,speed=@speed)!->
    @body.goal = p

Actor::follow_path =!->
    while @path.length and (typeof @path.0 is \function or @path.0.callback)
        process_callbacks @path.0
        @path.shift!
    if @path.length
        @goal.x = if isFinite(@path.0.x) then @path.0.x else @x
        @goal.y = if isFinite(@path.0.y) then @path.0.y else @y

Actor::move =(mx,my)!->
    ox= if @path.length then @path[@path.length - 1]x else @x
    oy= if @path.length then @path[@path.length - 1]y else @y
    @path.push x:ox+mx*TS, y:oy+my*TS

Actor::getTiles =!->
    rect = body_to_rect @body
    return getTiles.call map.named-layers.tile_layer, rect, true

formes =
    llov:
        default:
            number: 0
            stage: 0
            port: 'llov_battle'
            hp: 106
            atk: 105
            def: 80
            speed: 110
            luck: 110
            skills:
                lovely-arrow: 1
                devil-kiss: 2
                hemorrhage: 5
                angel-rain: 10
                minorheal: 15
                clense: 32
                #coagulate: 30
        koakuma:
            number: 1
            name: "Koakuma"
            desc: "A mischievous devil that plays tricks on her foes."
            stage: 1
            port: 'llov_battle_1'
            unlocked: false
            hp: 110
            atk: 120
            def: 100
            speed: 130
            luck: 138
            skills:
                hemorrhage: 1
                devil-kiss: 2
                bloodburst: 10
                sabotage: 15
                trickpunch: 15
                purge: 25
                coagulate: 27
        cupid:
            number: 2
            name: "Cupid"
            desc: "A sleepy angel that specializes in helping her allies."
            stage: 1
            port: 'llov_battle_2'
            unlocked: false
            hp: 140
            atk: 110
            def: 90
            speed: 130
            luck: 128
            skills:
                lovely-arrow: 1
                hemorrhage: 5
                angel-rain: 10
                quickheal: 10
                heal: 15
                clense: 25
                massheal: 27

    ebby:
        default:
            number: 0
            stage: 0
            port: 'ebby_battle'
            hp: 109
            atk: 105
            def: 100
            speed: 105
            luck: 108
            skills:
                hemorrhage: 1
                bloodburst: 5
                bloodrun: 10
                coagulate: 26
                purge: 27
                infectspread: 28
                pandemic: 28
        angel:
            number: 1
            name: "Balance"
            desc: "A righteous judge who delivers punishment on her foes."
            stage: 1
            port: 'ebby_battle_1'
            unlocked: false
            hp: 130
            atk: 117
            def: 106
            speed: 110
            luck: 120
            skills:
                hemorrhage: 1
                bloodburst: 5
                bloodrun: 10
                clense: 15
                purge: 15
                quickheal: 26
                infectspread: 28
                pandemic: 28
                heal: 30
                massheal: 40
        necro:
            number: 2
            name: "Chaos"
            desc: "A dark caster who rains terrible curses on her foes."
            stage: 1
            port: 'ebby_battle_2'
            unlocked: false
            hp: 110
            atk: 125
            def: 110
            speed: 112
            luck: 125
            skills:
                hemorrhage: 1
                bloodburst: 5
                bloodrun: 10
                purge: 20
                coagulate: 26
                infectspread: 28
                pandemic: 28
                curse: 30
                hex: 32
                healblock: 40
                isolate: 60
                

    marb:
        default:
            number: 0
            stage: 0
            port: 'marb_battle'
            hp: 112
            atk: 110
            def: 118
            speed: 90
            luck: 100
            skills:
                hemorrhage: 1
                bloodburst: 7
                artillery: 12
                hellfire: 14
                rail-cannon: 20
                flare: 25
        siege:
            number: 1
            name: "Siege"
            desc: "Fortified to boost attack and defense capability."
            stage: 1
            port: 'marb_battle_1'
            unlocked: false
            hp: 130
            atk: 155
            def: 160
            speed: 70
            luck: 100
            skills:
                hemorrhage: 1
                bloodburst: 5
                artillery: 10
                rail-cannon: 12
                hellfire: 14
                nuke: 20
                flare: 25
        assault:
            number: 2
            name: "Assault"
            desc: "Sheds all defense to become a swift killing machine."
            stage: 1
            port: 'marb_battle_2'
            unlocked: false
            hp: 100
            atk: 130
            def: 100
            speed: 150
            luck: 100
            skills:
                hemorrhage: 1
                bloodburst: 5
                artillery: 10
                hellfire: 12
                rail-cannon: 14
                nuke: 20
                flare: 25

for p of formes
    for f of formes[p]
        formes[p][f]id = f 

costumes = 
    llov:
        default: name:'Siesta' 
        , bsheet:\llov_battle, bframe:[0,1,2]
        , csheet:\llov, psheet:\llov_base
        nurse: name:'Nurse', bframe:[3,4,5]
        , crow: 7, psheet:\llov_base2
        swim: name:'Bikini', bframe:[12,13,14]
        , crow:5, pframe:3
        swim2: name:'Sukumizu', bframe:[15,16,17]
        , crow:6, pframe:4
        pumpkin: name:'Pumpkin', bframe:[6,7,8]
        , crow:3, pframe:2
        christmas: name:'Holly', bsheet:\llov_battle_christmas
        , crow:2, psheet:\llov_base2, pframe:1
        valentine: name:'Ribbon', bframe:[18,19,20]
        , crow:4, pframe:5
        punk: name:'Punk', bframe:[9,10,11]
        , crow:1, pframe:1
    ebby:
        default: name:'Nurse'
        , bsheet:\ebby_battle, bframe:[0,1,2]
        , csheet:\ebby, psheet:\ebby_base
        cheer: name:'Cheer', bframe:[6,7,8]
        , crow:2, pframe:1
        bat: name:'Bat', bframe:[3,4,5]
        , crow:1, psheet:\ebby_base2
        fairy: name:'Fairy', bframe:[9,10,11]
        , crow:3, pframe:2
        witch: name:'Witch', bframe:[15,16,17]
        , crow:5, psheet:\ebby_base2, pframe:1
        santa: name:'Santa', bframe:[12,13,14]
        , crow:4, pframe:3
    marb:
        default: name:'Uniform'
        , bsheet:[\marb_battle, \marb_battle_1, \marb_battle_2]
        , csheet:\marb, psheet:\marb_base
        nurse: name:'Nurse', bframe:4
        , crow:1, pframe:2
        maid: name:'Maid', bframe:3
        , crow:2, pframe:1
        bunny: name:'Bunny', bframe:1
        , crow:3, psheet:\marb_base2
        demon: name:'Demon', bframe:2
        , crow:4, psheet:\marb_base2, pframe:1
        , frecolor: [[0x9b87a3,0xe35000,0xf8b800],[0x8a87a3,0xb62e31,0xf7c631]]
        queen: name:'Regal', bframe:5
        , crow:5, psheet:\marb_base2, pframe:2

for p of costumes then for c of costumes[p] then for k in [\bsheet, \bframe]
    continue if typeof costumes[p][c][k] is \object
    filling=costumes[p][c][k]
    costumes[p][c][k]=[filling,filling,filling]

!function get_costume (n,f,c='default',key='bsheet')
    return null unless n?
    if typeof f is \undefined then f = 0
    else if f and typeof f is \object then f = f.number
    if costumes[n][c] and costumes[n][c][key]
        sheet=access costumes[n][c][key]
        if f isnt null and typeof sheet is \object then sheet=sheet[f]
    if sheet~=null
        sheet=access costumes[n]default[key]
        if f isnt null and typeof sheet is \object then sheet=sheet[f]
    return sheet


!function get_costume_old (name, forme, costume)
    if typeof forme is \object then forme = forme.number
    forme = if forme > 0 then "_#forme" else ''
    costume = if costume then "_#costume" else ''
    return "#{name}_battle#costume#forme" if game.cache.checkImageKey("#{name}_battle#costume#forme")
    return "#{name}_battle#forme"
    

!function learn_skills (p, level1, level2)
    if p instanceof Player then p = p.name
    basicskills = []
    excelskills = []
    messages = []
    excelmessages = []
    for key, level of formes[p]default.skills
        if level > level1 and level <= level2
            if players[p]skills.default.length < 5 and skills[key] not in players[p]skills.default then players[p]skills.default.push skills[key]
            #messages.push "#{speakers[p]display} learned skill #{skills[key]name}!"
            messages.push tl("{0} learned skill {1}!", speakers[p]display, skills[key]name)
            basicskills.push key
    for f, forme of formes[p]
        continue unless forme.unlocked
        for key, level of forme.skills
            if level > level1 and level <= level2
                if players[p]skills[f]length < 5 and skills[key] not in players[p]skills[f] then players[p]skills[f]push skills[key]
                continue if key in basicskills
                if (index = excelskills.indexOf key) is -1
                    #excelmessages.push "#{forme.name} forme learned Excel skill #{skills[key]name}!"
                    excelmessages.push tl("{0} forme learned Excel skill {1}!", forme.name, skills[key]name)
                    excelskills.push key
                #else excelmessages[index] = "#{speakers[p]display} learned Excel skill #{skills[key]name}!"
                else excelmessages[index] = tl("{0} learned Excel skill {1}!", speakers[p]display, skills[key]name)
    return messages ++ excelmessages

!function learn_skill (skill,p,f=\all)
    if typeof skill is \string then skill = skills[skill]
    say ->
        if p?
            skillbook[p][f].push skill
        else skillbook.all.push skill
        save!
        sound.play \itemget
    #say '' "#{if f isnt \all and f isnt \default then formes[p][f]name+' forme l' else if p? then speakers[p]display+' l' else 'L'}earned skill #{skill.name}!"
    if f isnt \all and f isnt \default
        say '' tl("{0} forme learned Excel skill {1}!", formes[p][f]name, skill.name)
    else if p?
        say '' tl("{0} learned skill {1}!", speakers[p]display, skill.name)
    else
        say '' tl("Learned skill {0}!", skill.name)


class Player extends Actor
    (x,y,key)->
        super x,y,key
        @follow_dist = 0
        #@start_location!
        #@relocate @x+x, @y+y
        @add_facing_animation!
        
        @equip = buffs.null

        @stats =
            hp: 1
            xp: 0
        @level = 1
        @skills = {}
        for f of formes[@name]
            @skills[f] = []
        @costume = null

        @ripple = new Phaser.Sprite game, -8 0 'ripple' |> @add-child
        @ripple.animations.add 'simple', null, 7, true
        @ripple.animations.play 'simple'
        @ripple.kill!
        @kill!
        @previous = x: @x, y: @y
    set_xp:(xp,silent)!->
        unless silent
            for message in learn_skills @, @level, xp-to-level xp
                say '' message
        @stats.xp = xp
        @level = xp-to-level xp
    add_xp:(xp,silent)!->
        @set_xp @stats.xp+xp, silent
    luckroll: luckroll

    get_stat: (key)!->
        stat = formes[@name]default[key]
        switch key
        |\speed => s=calc_stat @level, stat, 2
        |\luck  => s=calc_stat @level, stat, 6.1
        |_      => s=new_calc_stat @level, stat
        return if @equip["mod_#key"]? then that s else s

    excel_unlocked: !->
        for key, forme of formes[@name]
            return true if forme.unlocked
        return false

var player, party, players, llov, ebby, marb
    
!function create_players
    llov := new Player 0,0,'llov'
    ebby := new Player 20,0,'ebby'
    marb := new Player 40,0,'marb'
    players := [llov, ebby, marb]
    for p in players
        players[p.name] = p
    party := []

    create_skillbook!

!function kill_players
    for actor in players
        actor.kill! if actor not in party
    
!function set_party
    #move actor to end of party if dead
    for actor, i in party by -1
        party.push party.splice(i, 1)0 if not actor.alive
    #make first party member the player
    player := party.0
    #game.camera.follow player
    player.follow_object = null
    player.follow_dist = 10
    party.1?follow_dist = 15
    party.2?follow_dist = 30
    for i from 1 til party.length
        party[i].follow_object = player

!function join_party (p, options={})
    if party.length >= 3
        warn "Party is full!"
        return
    if players[p] in party
        warn "p is already in the party!"
        return
    #get average level
    alevel=averagelevel!
    #add player to front or back of party
    party[if options.front then \unshift else \push] players[p]
    #revive player
    players[p].revive! unless players[p].alive
    #learn starter skills
    if options.startlevel and players[p]level < alevel >? options.startlevel
        players[p].set_xp (levelToXp alevel >? options.startlevel), true
    
    for f of formes[p]
        if players[p].skills[f].length==0 and !switches.loadgame and (f is \default or formes[p][f]unlocked) then starter_skills p,f

    set_party!
    save! if options.save

!function leave_party (p)
    return false if party.length <= 1
    p=players[p] if typeof p is \string
    return false if not p or party.indexOf(p)<0
    party.splice(party.indexOf(p),1)
    set_party!
    p.water_depth=Math.min(p.water_depth,4)
    update_water_depth p
    #p.crop x:0 y:0 width: game.cache._images[p.key].frame-width, height: game.cache._images[p.key].frame-height - p.water_depth

!function change_leader (p)
    if typeof p is \string then p=players[p] 
    else if typeof p is \number then p=party[p]
    return false if not p or party.indexOf(p)<0
    party.unshift(party.splice(party.indexOf(p),1)[0])
    set_party!
    return p


!function unlock_forme (p, f)
    formes[p][f]unlocked = true
    if players[p] in party then starter_skills p,f, true
    save!

#================================================================
# PLAYER PHYSICS UPDATE
#================================================================

Player::physics_update =!->
    return if switches.noclip
    if @ is party.0
        physics_update_player ...
    else if @ in party   
        physics_update_follower ...
    else
        Actor.prototype.physics_update ...

!function physics_update_follower
    tile_collision_recoil @, map.named-layers.tile_layer
    for actor in actors.children
        continue if not actor.body?
        continue if actor.nobody
        game.physics.arcade.overlap @, actor, player_actor_handle_collision, follower_actor_process_collision, @
    #    and follower_actor_process_collision @, actor
    #        if Math.abs(@body.center.x - actor.body.center.x) > Math.abs(@body.center.y - actor.body.center.y)
    #            sides[if actor.x>@x then 1 else 3]=1
    #        else
    #            sides[if actor.y>@y then 2 else 0]=1
    #if sides ~= true
    #    #g=@follow_object.get_facing_point(-@follow_dist)
    #    #g.x += @follow_object.x; g.y += @follow_object.y
    #    if Math.abs(@x - @goal.x) > Math.abs(@y - @goal.y)
    #        if sides[if @goal.x>@x then 1 else 3] then @newgoal={x:@x,y:@goal.y}
    #    else
    #        if sides[if @goal.y>@y then 2 else 0] then @newgoal={x:@goal.x,y:@y}

!function physics_update_player
    tile_collision_recoil @, map.named-layers.tile_layer
    for actor in actors.children
        continue if not actor.body?
        continue if actor.nobody
        game.physics.arcade.overlap @, actor, player_actor_handle_collision, player_actor_process_collision, @
    
#================================================================
# UPDATE PLAYERS
#================================================================

Player::update =!->
    #@previous.x = @x
    #@previous.y = @y
    @terrain=t=getTileUnder(@)?properties.terrain
    if t is \mountain then @bridgemode=\over
    else if t isnt \mountain and t isnt \overpass then @bridgemode=\under
    if switches.cinema
        update_player_cinema ...
        return
    if @ is party.0
        update_player ...
    else if @ in party
        update_follower ...
    else
        Actor.prototype.update ...
        
Player::update-paused =!->
    @stop!
    @cancel_movement!

!function update_player_cinema
    if @body.deltaAbsX! is 0 and @body.deltaAbsY! is 0
        @moving = false 
    @follow_path!
    @apply_movement 1
    ## maybe comment out?
    #water_sink ...
    ##

!function update_follower
    @update_follow_behind!
    #@moving = false if @goal.x - @x == 0 and @goal.y - @y == 0
    if @previous.x - @x is 0 and @previous.y - @y is 0
        notmoving=true
        #@moving = false 
    @previous.x=@x; @previous.y=@y;
    @follow_path!
    @apply_movement 1
    #when a party member gets too far away, teleport
    #target = @follow_object or @goal
    if @alive and distance(@, player) > @follow_dist*3# and distance(@, @goal) > 50 and not tile_point_collision @, @goal, map.tile_layer, switches.water_walking, true
    #and !tile_line(@, player)
        #target = if tile_line(@, @goal) then @goal else player
        Dust.summon @
        Dust.summon player
        @x = player.x
        @y = player.y

    water_sink ...

    if notmoving
        @stop!

# NOTE
# There's a bug that lets you walk through walls if you're almost all the way sunk.
# I don't know why it happens or how to fix it, so I'm not going to.
!function water_sink
    cache=(get-cached-image @key)
    keyheight=cache.frame-height or cache.frame.height
    prevdepth = @water_depth
    switch water_depth = over_water @
    case 0
        @water_depth = 0
    case 1
        @water_depth = 4 >? @water_depth - 92*deltam if @water_depth > 4
        @water_depth = 4 <? @water_depth + 6*deltam if @water_depth < 4
    case 2
        @water_depth = keyheight <? @water_depth + 6*deltam >? 4
    if @water_depth is not prevdepth
        update_water_depth @,true
        #@crop x:0 y: 0 width: game.cache._images[@key].frame-width, height: game.cache._images[@key].frame-height - @water_depth

    if prevdepth is 0 and @water_depth > 0
        @ripple.revive!
    if @water_depth is 0 and prevdepth is not 0
        @ripple.kill!

    if water_depth > 1
        @drift = -12 unless switches.cinema
        #@y -= current
        #@goal.y -= TS*deltam

    #drowning
    if @alive and @water_depth is keyheight
        @stats.hp=0
        @kill!
        set_party!
        log @name+" drowned!"

        for p in carpet.children
            if p.key is \pent and p.flame
                p.flame.visible=false

        drowned=true
        for p in party
            if p.stats.hp>0
                drowned=false
        if drowned
            quitgame!
            #if switches.checkpoint_map is switches.map then for p in carpet.children
            #    p.flame.visible=true if p.key is \pent and p.flame and p.name is switches.checkpoint
            #for p in party
            #    p.start_location true
            #    p.water_depth=0
            #    p.ripple.kill!
            #    update_water_depth p,true
            #    #p.crop x:0 y:0 width: game.cache._images[p.key].frame-width, height: game.cache._images[p.key].frame-height

!function update_water_depth(p,justcrop)
    cache=(get-cached-image p.key)
    keyheight=cache.frame-height or cache.frame.height
    keywidth=cache.frame-width or cache.frame.width
    p.crop x:0 y:p.row*keyheight, width: keywidth, height: keyheight - p.water_depth
    return if justcrop
    t=getTileUnder(p)?properties.terrain or \water
    if t is \water then p.ripple.revive!
    else p.ripple.kill!
#============================================
# Update Player
#--------------------------------------------

!function update_player
    now=Date.now!
    #move
    @speed=60
    mousedist = distance mouse.world, player
    if mouse.down and player.follow_dist < mousedist 
    and now - @lastrelocate > 1000
    #and mousedist < distance {x:0,y:0}, {x:game.width/2,y:game.height/2}
        @speed=Math.min 25*mousedist/HHEIGHT+50, 75
        @goal = x: mouse.world.x, y: mouse.world.y 
    @update_follow_object!
    move = x:0, y:0, dist: 5
    move.y-=move.dist if keyboard.up!
    move.y+=move.dist if keyboard.down!
    move.x-=move.dist if keyboard.left!
    move.x+=move.dist if keyboard.right!
    if move.x != 0 or move.y != 0
        @speed=80 if keyboard.dash!
        @goal = x: @x + move.x, y: @y + move.y
        @path = [] if @path.length
        @follow_object = null
    player.animations.currentAnim.speed=7/60*@speed
    #@moving = false if @goal.x - @x == 0 and @goal.y - @y == 0
    @moving = false if @body.deltaAbsX! < 0.1 and @body.deltaAbsY! < 0.1
    @follow_path!
    @apply_movement move.dist
    #collision
    for trigger in triggers.children
        game.physics.arcade.collide @, trigger, player_trigger_handle_collision, player_trigger_process_collision, @

    if @follow_object? and distance(@, @follow_object) < body_radius(@follow_object.body)+body_diameter(@body)
        @interact_with @follow_object
    #game.physics.arcade.collide @, map.tile_layer

    water_sink ...

!function start_camera
    game.camera.center = x:@x,y:@y
    game.camera.x = @x - game.width/2
    game.camera.y = @y - game.height/2
!function update_camera
    game.camera.center.x = @x; game.camera.center.y = @y
    #camera
    camera_dest = x: @x - game.width/2, y: @y - game.height/2
    camera_dist = x: camera_dest.x - game.camera.x, y: camera_dest.y - game.camera.y
    if Math.abs(camera_dist.x) > 1 or Math.abs(camera_dist.y) > 1
        game.camera.x += camera_dist.x * deltam*5
        game.camera.y += camera_dist.y * deltam*5
    else
        game.camera.x = camera_dest.x; game.camera.y = camera_dest.y

!function camera_center (x,y,instant)
    game.camera.center.x = x; game.camera.center.y = y
    if instant
        game.camera.x = x - game.width/2; game.camera.y = y - game.height/2

Player::interact_with =(actor)!->
    return unless actor.alive
    @follow_object = null if actor is @follow_object
    actor.interact?!
    if actor instanceof Actor
        @face_point actor
        actor.face_point @
    if actor instanceof Doodad and actor.body
        if !actor.body then console.warn "Object doesn't have a body!"
        @face_point actor.body.center
        
!function player_actor_handle_collision (player, actor)
    actor_collision_recoil player, actor
    @cancel_movement!
    @path = [] if @path.length
    if actor.battle? and actor.alive and !actor.dontcheck and !temp.enteringbattle
        actor.onbattle?!
        start_battle actor.battle, actor.toughness, actor.terrain
        #actor.kill!
    else actor.oncollide?!
!function player_actor_process_collision (player, actor)
    return actor not in party

!function follower_actor_process_collision (player, actor)
    return actor not in party and actor not instanceof Mob

!function player_trigger_handle_collision (player, trigger)
    return trigger.handle!
    
!function player_trigger_process_collision (player, trigger)
    return trigger.process!
    
!function mousewheel_player (e)
    if (e.wheel-delta || e.deltaY) > 0
        player_wheel_up!
    else
        player_wheel_down!
    save!
    
!function player_wheel_up
    for i from 1 til party.length
        if party[i]alive
            party[i]goal = x:player.x, y:player.y
            break
    i=0; do
        party.push party.shift!
        i++
    while not party.0.alive and i<3
    set_party!
    
!function player_wheel_down
    for i from party.length-1 til 0 by -1
        if party[i]alive
            party[i]goal = x:player.x, y:player.y
            break
    i=0; do
        party.unshift party.pop!
        i++
    while not party.0.alive and i<3
    set_party!
    
!function mousetap_player (e)
    return unless nullbutton e.button
    #mouse tap

!function mousedown_player (e)
    return if actors.paused or switches.cinema
    if nullbutton e.button
        player.follow_object = null
        #click npc to follow!
        for actor in actors.children
            continue if actor.nointeract
            if actor instanceof Actor and actor not in party and actor.alive and !actor.nobody and point_in_sprite mouse.world, actor
                player.follow_object = actor
        for doodad in Doodad.list
            continue if doodad.nointeract
            if doodad.body? and point_in_body mouse.world, doodad.body and distance(doodad.body.center, player) < body_radius(doodad.body)+body_diameter(player.body)
                player.interact_with doodad
                return false

!function player_confirm_button
    return if actors.paused or switches.cinema
    g = player.get_facing_point body_diameter player.body
    g = x: player.x+g.x, y: player.y+g.y
    for actor in actors.children
        continue if actor.nointeract
        if actor instanceof Actor and actor not in party and distance(g, actor) < body_diameter actor.body
            player.interact_with actor
            return false # end input
    for doodad in Doodad.list
        continue if doodad.nointeract
        if doodad.body? and point_in_body {x:g.x,y:g.y-6}, doodad.body
            player.interact_with doodad
            return false

Player::start_location =(heal=false)!->
    name = if switches.map is switches.checkpoint_map then switches.checkpoint else \player_start
    unless node = nodes[name] #destination is on another map
        if switches.checkpoint
            mapname = switches.checkpoint_map
            name = switches.checkpoint
        else
            mapname = STARTMAP
            name = \player_start
        schedule_teleport(pmap:mapname, pport:name, pdir:'down', pnode:true)
        #warn "Node '#name' doesn't exist!"
        return
    else #destination on this map
        @x = node.x+HTS; @y = node.y - @bodyoffset.y + TS
    @stats.hp=1 if heal
    @revive! if heal
    @cancel_movement!

Player::update_follow_behind =!->
    return unless @follow_object?
    #if @newgoal
    #    @goal=@newgoal
    #    delete! @newgoal
    #    return
    #if tile_line(@, @follow_object)
    g = @follow_object.get_facing_point(-@follow_dist)
    g.x += @follow_object.x; g.y += @follow_object.y
    #else
        ##g=normalize x: @x - @follow_object.x, @y - @follow_object.y
        ##g.x*=@follow_dist; g.y*=@follow_dist
        ##g=x:@follow_object.x - g.x*@follow_dist, y:@follow_object.y - g.y*@follow_dist
        #g=x:@follow_object.x, y:@follow_object.y
    if (dist=distance @, g) > 1 #MAGIC NUMBER
        @speed=Math.min 25*dist/@follow_dist+50, 80
        @goal = g
    
Player::get_facing_point =(dist)!->
    switch @facing
        when 'up' then f = x:0, y:-1 
        when 'upright' then f = x:0.707, y:-0.707
        when 'right' then f = x:1, y:0
        when 'downright' then f = x:0.707, y:0.707
        when 'down' then f = x:0, y:1
        when 'downleft' then f = x:-0.707, y:0.707
        when 'left' then f = x:-1, y:0
        when 'upleft' then f = x:-0.707, y:-0.707
        else f = x:0, y:0
    return x: f.x*dist, y: f.y*dist
        
    
Player::update_follow_object =!->
    return unless @follow_object?
    @goal = x: @follow_object.x, y: @follow_object.y
    #check if colliding with follow object. If so, stop moving.



class Skill
    (properties)->
        for key of properties
            @[key] = properties[key]
        #@xp ?= 10
        #@ex ?= 10
        @xp ?= 0
        @ex ?= 0
        @sp ?= 100
        @action ?=!->
        @target ?= \enemy
        @attributes ?= <[attack]>
        #default weight is 5

#========================================
# Animations
#----------------------------------------

animations = 
    slash: sprite: 'anim_slash', frames: [0,1,2,3,4,5], anchor: [1/3, 1.0]
    flame: sprite: 'anim_flame', frames: [0,1,2,3,4,5,6], anchor: [0.5,0.5]
    curse: sprite: 'anim_curse', frames: [0,1,2,3,4,5,6,7,8,9,10], anchor: [0.5,0.5]
    heal: sprite: 'anim_heal', frames: [0,1,2,3,4,5], anchor: [0.5,0.5]
    blood1: sprite: 'anim_blood1', frames: [0,1,2,3,4,5,6,7], anchor: [0,12/42]
    blood2: sprite: 'anim_blood2', frames: [0,1,2,3,4], anchor: [0.5,0.5]
    water: sprite: 'anim_water', frames: [0,1,2,3,4,5,6,7,8,9], anchor: [0.5,0.5]
    flies: sprite: 'anim_flies', frames: [0 to 14], anchor: [0.5,0.5]

#========================================
# Skill effects
#----------------------------------------

function damage (t,n)
    t.damage (Math.round calc_damage battle.actor, t, n), true, battle.actor

function damage_target (n)
    if battle.target instanceof Array
        targets=battle.target
    else
        targets=[battle.target]
    for target in targets
        #target.damage (Math.round (battle.actor.get_stat \atk)*n / (10*target.get_stat \def)), true, battle.actor
        target.damage (Math.round calc_damage battle.actor, target, n), true, battle.actor
function calc_damage(a,d,n)
        atk=a.get_stat \atk
        def=d.get_stat \def
        return atk*atk*n/(def*500)

function heal_target (n)
    if battle.target instanceof Array
        for target in battle.target
            target.damage -n, true, battle.actor
    else
        battle.target.damage -n, true, battle.actor
function heal_scaled (n)
    heal_target (battle.actor.get_stat \hp)*n/100
function heal_hybrid (n,s)
    heal_target n+(battle.actor.get_stat \hp)*s/100
function reward_xp (n)
    return unless battle.actor instanceof Battler
    battle.actor.reward_xp n 

#========================================
# Skills
#----------------------------------------

skills = {}
skills.attack =
    name: "Attack"
    animation: 'slash'
    action: ->
        damage_target 75
    attributes: <[attack]>
    desc: 'Default attack move.'
skills.strike =
    name: "Strike"
    animation: 'slash'
    action: ->
        damage_target 100
    attributes: <[attack]>
    desc: 'Basic attack move.'
skills.lovetap =
    name: "Love Tap"
    animation: 'slash'
    action: ->
        damage_target 10
    attributes: <[attack]>
    desc: 'A weak attack lacking any malice. It can be used to bide for time.'
    sp: 10
skills.hemorrhage =
    name: "Hemorrhage"
    animation: 'blood1'
    sp: 100
    action: ->
        #damage_target 50
        battle.target.inflict buffs.bleed
    target: 'enemy'
    attributes: <[blood attack magic]>
    desc: "Causes the enemy to lose health over time."
    aitarget: ->
        enemylist = enemy_list!
        list = []
        for enemy in enemylist
            list.push enemy if enemy.has_buff buffs.null
        list = enemylist if list.length is 0
        battle.target = list[Math.floor Math.random!*list.length]
skills.bloodburst =
    name: "Blood Burst"
    animation: 'blood2'
    sp: 100
    action: ->
        if battle.target.has_buff buffs.bleed
            battle.target.remedy buffs.bleed
            damage_target 160
        else return damage_target 10
    aitarget: ->
        enemylist = enemy_list!
        list = []
        for enemy in enemylist
            list.push enemy if enemy.has_buff buffs.bleed
        list = enemylist if list.length is 0
        battle.target = list[Math.floor Math.random!*list.length]
    target: 'enemy'
    attributes: <[blood attack magic]> 
    desc: "Effective against bleeding enemies."
skills.coagulate =
    name: "Coagulate"
    animation: 'slash'
    sp: 100
    xp: 10
    action: ->
        #if battle.target.has_buff buffs.bleed
        #    battle.target.remedy buffs.bleed
        #    for from 1 to 5
        #        battle.target.inflict buffs.coagulate
        for buff in battle.target.buffs
            if buff.name is \bleed
                buff.load_buff buffs.coagulate
    aitarget: skills.bloodburst.aitarget
    target: 'enemy'
    attributes: <[blood status magic]> 
    desc: "Converts bleed effects into scabs, hindering the enemy."
skills.bloodrun =
    name: "Blood Run"
    animation: 'blood1'
    sp: 100
    xp: 10
    action: ->
        for buff in battle.target.buffs
            if buff.name is \bleed and buff.duration<3 and !buff.extended
                buff.duration=3
                buff.extended=true
                buff.frame=4
                setrow buff, 3
            if buff.name is \coagulate then buff.load_buff buffs.bleed
    aitarget: ->
        enemylist = enemy_list!
        list = []
        for enemy in enemylist
            if enemy.has_buff buffs.coagulate
                list.push enemy
                continue
            for buff in enemy.buffs
                if buff.base is buffs.bleed and !buff.extended
                    list.push enemy
                    break
        list = enemylist if list.length is 0
        battle.target = list[Math.floor Math.random!*list.length]
    target: 'enemy'
    attributes: <[blood status magic]> 
    desc: "Extends the duration of bleeding effects. Also undoes any coagulants, making them bleed again."
skills.bloodboost =
    name: "Blood Boost"
    animation: 'blood2'
    sp: 100
    action:!-> battle.target.inflict buffs.bloodboost
    target: 'self'
    attributes: <[status]>
skills.bloodlet =
    name: "Blood Let"
    animation: 'blood2'
    sp: 10
    action:!->
        for buff in battle.target.buffs
            if buff.name is \bloodboost or buff.name is \coagulate
                buff.load_buff buffs.bleed
                buff.duration=999
                return
        battle.target.inflict buffs.bleed
    target: 'self'
    attributes: <[status]>
skills.trickpunch =
    name: "Trick Punch"
    animation: 'slash'
    sfx: \strike
    sp: 30
    action: ->
        damage_target 22
        battle.target.inflict buffs.dazed
    attributes: <[attack]>
    desc: 'Surprises the enemy, lowering their speed for a short time.'
skills.lovely-arrow =
    name: "Lavuri Aero" #"Lovely Arrow"
    animation: 'slash'
    sfx: \swing
    custom_animation: !->
        a=get_animation!
        a.revive!
        actor=x:battle.actor.x, y:battle.actor.y
        target=x:battle.target.x, y:battle.target.y
        if battle.actor instanceof Battler then actor.x+=WS*3; actor.y+=WS*3
        if battle.target instanceof Battler then target.x+=WS*3; target.y+=WS*3
        a.x=actor.x
        a.y=actor.y
        a.loadTexture \anim_arrow
        time=0
        sound.play \swing
        a.update=!->
            time+=delta
            a.x=actor.x+(target.x - actor.x)*(time/500)
            if time <= 250
                a.y=actor.y - actor.y*Math.sin(HPI*time/250)
            else
                a.scale.y=-1
                a.y=target.y - target.y*Math.sin(HPI*time/250)
            if time>500
                a.update=!->
                a.scale.y=1
                a.kill!
                process_callbacks battle.animation.callback
    sp: -> 50
    #ex: 10
    #xp: 10
    action: ->
        d=55
        d+=10 if battle.target.has_buff buffs.charmed
        d+=10 if battle.actor.item is items.bow
        damage_target d
    target: 'enemy'
    attributes: <[arrow attack]>
    desc_battle: "A fast and light attack."
    desc: "Lets loose a single arrow to quickly strike the enemy."
    #Does extra damage against charmed enemies?
    #The target will not attack Llov?
skills.angel-rain =
    name: "Enjel Rain"
    animation: 'slash'
    sp: 100
    #ex: 10
    #xp: 10
    /*
    custom_animation: !->
        count=0
        done=false
        setanimation=!->
            return if done
            count++
            a=get_animation!
            a.callback=setanimation
            (done:=true; a.callback=battle.animation.callback) if count > 12
            #a.play!
            a.play 'slash', random_dice(2)*WIDTH, random_dice(2)*HHEIGHT+(if battle.actor instanceof Monster then HHEIGHT else 0)+16
            sound.play \strike
        for i til 3
            setTimeout setanimation, 500*i
            #setanimation!
    */
    custom_animation: !->
        actor=x:battle.actor.x, y:battle.actor.y
        if battle.actor instanceof Battler then actor.x+=WS*3; actor.y+=WS*3
        count=0
        done=false
        newarrow=!->
            a=get_animation!
            a.revive!
            a.target=x:0,y:0
            a.loadTexture \anim_arrow
            a.time=0
            a.update=!->
                @time+=delta
                @x=actor.x+(@target.x - actor.x)*(@time/500)
                if @time <= 250
                    @y=actor.y - actor.y*Math.sin(HPI*@time/250)
                else
                    @scale.y=-1
                    @y=@target.y - @target.y*Math.sin(HPI*@time/250)
                if @time>500
                    @scale.y=1
                    if count>12
                        @update=!->
                        @kill!
                        if !done
                            done := true
                            process_callbacks battle.animation.callback
                    else
                        @iterate!
            a.iterate=!->
                @target.x=random_dice(2)*WIDTH
                @target.y=random_dice(2)*HHEIGHT+(if battle.actor instanceof Monster then HHEIGHT else 0)+16
                @x=actor.x
                @y=actor.y
                @time=0
                count++
                sound.play \swing
            a.iterate!

        for i til 3
            setTimeout newarrow, 300*i

    action: ->
        #damage_target 50
        d=55
        d+=10 if battle.actor.item is items.bow
        for target in battle.target
            damage target, if target.has_buff buffs.charmed then d+10 else d
    target: 'enemies'
    attributes: <[arrow attack]>
    #desc_battle: "Hits all enemies."
    desc: "A holy rain of arrows that strikes every enemy."
skills.hellfire =
    name: "Hellfire"
    animation: 'flame'
    sp: 200
    #ex: 10
    #xp: 10
    custom_animation: !->
        count=0
        done=false
        setanimation=!->
            return if done
            count++
            a=get_animation!
            a.callback=setanimation
            (done:=true; a.callback=battle.animation.callback) if count > 12
            #a.play!
            a.play 'flame', random_dice(2)*WIDTH, random_dice(2)*HHEIGHT+(if battle.actor instanceof Monster then HHEIGHT else 0)+16
            sound.play \flame
        for i til 3
            setTimeout setanimation, 500*i
            #setanimation!
    action: -> damage_target 105
    target: 'enemies'
    attributes: <[fire tech attack]>
    #desc_battle: "Hits all enemies."
    desc: "Rains heavy fire from the sky, striking all enemies."
skills.devil-kiss =
    name: "Debiru Kiss" #"Devil's Kiss"
    animation: 'slash'
    sfx: \voice
    sp: 100
    xp: 10
    action: ->
        battle.target.inflict buffs.charmed
    target: 'enemy'
    attributes: <[status magic]>
    desc: "Charms the target, reducing its stats and making it less likely to attack Lloviu-tan. Also makes it take slightly more damage from arrow attacks. Does not stack."
    desc_battle: "Charms the target, reducing its stats. Does not stack."
skills.pandemic =
    name: "Pandemic"
    animation: 'blood1'
    sp: 150
    action: ->
        for target in battle.target
            target.inflict buffs.bleed
    target: 'enemies'
    attributes: <[blood attack magic]>
    desc: "Infects all enemies with hemorrhages."
skills.infectspread =
    name: "Spread Infection"
    animation: 'blood1'
    sp: 100
    action: ->
        #bleedcount=0
        #for buff in battle.target.buffs
        #    bleedcount++ if buff.name is \bleed
        #for from 0 til bleedcount
        #    for enemy in enemy_list!
        #        continue if enemy is battle.target
        #        enemy.inflict buffs.bleed
        for enemy in enemy_list!
            continue if enemy is battle.target
            #if !enemy.has_buff buffs.bleed
                #enemy.inflict buffs.bleed
            enemy.inflict buffs.bleed
            #battle.target.remedy buffs.bleed
    target: 'enemy'
    aitarget: skills.bloodburst.aitarget
    attributes: <[blood status magic]>
    desc: "Spreads a bleeding effect to other enemies."
skills.skullbeam =
    name: "Skull Beam"
    animation: \blood1
    custom_animation: !->
        actor=x:battle.actor.x, y:battle.actor.y
        target=x:battle.target.x, y:battle.target.y
        if battle.actor instanceof Battler then actor.x+=WS*3; actor.y+=WS*3
        if battle.target instanceof Battler then target.x+=WS*3; target.y+=WS*3
        done=false
        duration=1000
        quantity=12
        count=0
        newarrow=(i,i2)!->
            a=get_animation!
            a.revive!
            a.loadTexture \solid
            a.time=0
            a.origin=
                x: actor.x + (target.x - actor.x)*(i/i2)
                y: actor.y + (target.y - actor.y)*(i/i2)
            a.update=!->
                @time+=delta
                @x=@origin.x + random_dice(2)*10 - 5
                @y=@origin.y + random_dice(2)*10 - 5
                @scale.x=@scale.y=12*Math.sin(Math.PI*@time/duration)
                @rotation=Math.random!*HPI*4
                c=r: Math.random!*255, g:0, b:0
                c.g=Math.random!*c.r
                c.b=Math.random!*c.r
                @tint=makecolor c
                if @time>duration
                    @scale.set 1 1
                    @tint=0xffffff
                    @rotation=0
                    @update=!->
                    @kill!
                    count++
                    if count is quantity
                        process_callbacks battle.animation.callback
        count2=0
        for i til quantity
            setTimeout (->newarrow(count2++,quantity - 1)), 50*i
        sound.play \laser
    sp: 100
    action: ->
        bloodcount=0
        for buff in battle.target.buffs
            bloodcount++ if buff.name is \bleed
        if bloodcount > 0
            damage_target 100+bloodcount*20
        else
            damage_target 50
    target: \enemy
    attributes: <[blood attack magic]>
    desc: "Shoots lasers from the eyes of the skull, dealing more damage for each bleed effect on the target."

skills.eyebeam =
    name: "Eye Beam"
    custom_animation: skills.skullbeam.custom_animation
    sp: 100
    action: -> damage_target 100
    target: \enemy
    attributes: <[magic attack]>
skills.hex =
    name: "Hex"
    animation: \curse
    sfx: \groan
    sp: 100
    action: ->
        buffcount=0
        for buff in battle.target.buffs
            buffcount++ if buff.name isnt \null
        damage_target [25,75,100,120,140,160][buffcount]
    target: \enemy
    attributes: <[attack magic]>
    desc: "Does more damage for each status effect on the enemy."
    aitarget: ->
        enemylist = enemy_list!
        list = null
        highest=0
        for enemy in enemylist
            buffcount=0
            for buff in enemy.buffs
                buffcount++ if buff.name isnt \null
            if !list or buffcount>highest
                list=[enemy]
                highest=buffcount
            else if buffcount is highest
                list.push enemy
        list ?= enemylist
        battle.target = list[Math.floor Math.random!*list.length]

skills.swarm =
    name: "Swarm"
    sfx: \groan
    animation: \flies
    sp: 50
    action: ->
        battle.target.inflict buffs.swarm
    target: 'enemy'
    weight: 2
    attributes: <[status magic]>
    aitarget: skills.hemorrhage.aitarget

skills.swarmdrain =
    name: "Swarm Drain"
    sfx: \groan
    animation: \flies
    sp: 50
    action: ->
        battle.actor.inflict buffs.swarmdrain
    target: 'self'
    weight: 1
    attributes: <[status heal magic]>

skills.leecharrow =
    name: "Vital Aero"
    custom_animation: skills.lovely-arrow.custom_animation
    sp: 100
    action: ->
        d=100
        h=0.05
        if battle.target.has_buff buffs.charmed
            d+=20 
            h+=0.05
        #d+=10 if battle.actor.item is items.bow
        damage_target d
        for ally in ally_list!
            continue if ally is battle.actor
            ally.damage -(battle.actor.get_stat \hp)*h, true, battle.actor
    target: \enemy
    attributes: <[arrow heal attack]>

skills.sabotage =
    name: "Sabotage"
    sp:50
    action: ->
        battle.target.inflict buffs.sabotage
        damage_target 10
    target: \enemy
    desc: "Sabotages the enemy, greatly lowering their attack for a short time."
    attributes: <[status]>
    aitarget: -> #target enemy with highest sp
        enemylist = enemy_list!
        target=null
        for enemy in enemylist
            if target
                if enemy.stats.sp_level - enemy.stats.sp > target.stats.sp_level - target.stats.sp then target=enemy
            else target=enemy
        battle.target = target
skills.seizure =
    name: "Seizure"
    animation: 'curse'
    sfx: \groan
    custom_animation: !->
        #actor=x:battle.actor.x, y:battle.actor.y
        target=x:battle.target.x, y:battle.target.y
        #if battle.actor instanceof Battler then actor.x+=WS*3; actor.y+=WS*3
        if battle.target instanceof Battler then target.x+=WS*3; target.y+=WS*3
        duration=1000
        a=get_animation!
        a.revive!
        a.loadTexture \solid
        a.time=0
        a.x=target.x
        a.y=target.y
        a.update=!->
            @time+=delta
            @rotation=Math.random!*HPI*4
            @width = 32+Math.random!*32
            @height = 32+Math.random!*32
            @tint=[0xffffff,0xff0000,0x0000ff][Math.random!*3.|.0]
            if Date.now! - sound.lastplayedtime > 100
                #sound.stop!
                #sound.play \laser, true
                sound.play \strike, true
                sound.strike._sound.playbackRate.value=2
            if @time>duration
                sound.stop!
                @tint=0xffffff
                @scale.set 1 1
                @rotation=0
                @update=!->
                @kill!
                process_callbacks battle.animation.callback
    sp: 100
    xp: 10
    action: ->
        battle.target.inflict buffs.seizure
    target: 'enemy'
    attributes: <[status magic]>
    desc: "Seizes control of the target's mind, reducing their speed. Does not stack."
skills.seizure2 =
    name: "Flashing Lights"
    animation: 'curse'
    sfx: \groan
    custom_animation: !->
        duration=1750
        a=get_animation!
        a.revive!
        a.loadTexture \solid
        a.time=0
        a.x=HWIDTH
        a.y=HHEIGHT
        a.width=game.width
        a.height=game.height
        sound.play \laser
        a.update=!->
            @time+=delta
            @tint=[0xffffff,0xff0000,0x0000ff][Math.random!*3.|.0]
            @alpha=Math.random!/2
            if @time>duration
                #sound.stop!
                @tint=0xffffff
                @scale.set 1 1
                @alpha=1
                @update=!->
                @kill!
                process_callbacks battle.animation.callback
    sp: 100
    xp: 10
    action: ->
        for target in battle.target
            target.inflict buffs.seizure
    target: 'enemies'
    attributes: <[status magic]>
skills.devastate =
    name: "Devastate"
    animation: 'curse'
    sfx: \groan
    sp: 100
    xp: 10
    action: ->
        battle.target.inflict buffs.aids
    target: 'enemy'
    attributes: <[status magic]>
    desc: "Devastates the target's immune system, lowering defense to zero."
    aitarget: ->
        enemylist = enemy_list!
        list = []
        for enemy in enemylist
            list.push enemy unless enemy.has_buff buffs.null
        list = enemylist if list.length is 0
        battle.target = list[Math.floor Math.random!*list.length]
skills.dekopin =
    name: "Dekopin"
    sp: 100
    action: !-> damage_target 50
    target: 'enemy'
    attributes: <[attack]>
    desc: "Flicks the target in the forehead, dealing minimal damage."
    aitarget: !->
        enemylist = enemy_list!
        list = []
        for enemy in enemylist
            for buff in enemy.buffs
                list.push enemy if buff.name is \aids
            #list.push enemy if enemy.has_buff buffs.aids
        list = enemylist if list.length is 0
        battle.target = list[Math.floor Math.random!*list.length]
skills.sharepain =
    name: "Share Pain"
    animation: 'heal'
    sfx: \itemget
    sp: 50
    action: !->
        hp=(battle.actor.stats.hp + battle.target.stats.hp)/2
        #battle.target.stats.hp=battle.actor.stats.hp=hp
        battle.target.damage (battle.target.stats.hp - hp)*(battle.target.get_stat \hp),true,battle.actor
        battle.actor.damage (battle.actor.stats.hp - hp)*(battle.actor.get_stat \hp),true,battle.actor
    target: 'ally'
    aitarget: !->
        allylist=ally_list!
        hp=1
        target=null
        for ally in allylist
            continue if ally is battle.actor
            if ally.stats.hp<hp
                hp=ally.stats.hp
                target=ally
        return battle.target = target if target
        return battle.target = battle.actor
skills.twinflight =
    name: "Twin Flight"
    animation: 'heal'
    sfx: \itemget
    sp: 100
    action: !->
        battle.target.inflict buffs.twinflight
    target: 'ally'
    aitarget: !->
        allylist = ally_list!
        list = []
        for ally in allylist
            continue if ally is battle.actor
            continue if ally.has_buff buffs.twinflight
            list.push ally
        list = allylist if list.length is 0
        battle.target = list[Math.floor Math.random!*list.length]
skills.heal =
    name: "Aurum Vital"
    animation: 'heal'
    sfx: \itemget
    sp: 100
    action: ->
        #heal_scaled 25
        #heal_target 50
        heal_hybrid 50, 25
        #heal battle.target, 50,false
        #battle.target.show_text "+#{Math.round 50+heal_percent battle.target, 0.25,false}", 'font_green'
    target: 'ally'
    attributes: <[status heal magic]>
    desc: "A strong healing skill."
    aitarget: !->
        allylist=ally_list!
        hp=1
        target=null
        for ally in allylist
            if ally.stats.hp<hp
                hp=ally.stats.hp
                target=ally
        return battle.target = target if target
        return battle.target = battle.actor
skills.quickheal =
    name: "Argent Vital"
    animation: 'heal'
    sfx: \itemget
    sp: 50
    action: ->
        #heal_scaled 12.5
        #heal_target 25
        heal_hybrid 25, 12.5
        #heal battle.target, 25,false
        #battle.target.show_text "+#{Math.round 25+heal_percent battle.target, 0.125,false}", 'font_green'
    target: 'ally'
    attributes: <[status heal magic]>
    desc: "A fast healing skill."
    aitarget: skills.heal.aitarget
skills.minorheal =
    name: "Aes Vital"
    animation: 'heal'
    sfx: \itemget
    sp: 80
    action: ->
        #heal_scaled 12.5
        #heal_target 25
        heal_hybrid 25, 12.5
        #heal battle.target, 25,false
        #battle.target.show_text "+#{Math.round 25+heal_percent battle.target, 0.125,false}", 'font_green'
    target: 'ally'
    attributes: <[status heal magic]>
    desc: "A weak healing spell."
    aitarget: skills.heal.aitarget
skills.massheal =
    name: "Platina Vital"
    animation: 'heal'
    sfx: \itemget
    sp: 99
    action: ->
        #heal_scaled 12.5
        #heal_target 25
        heal_hybrid 25, 12.5
        #heal battle.target, 25,false
        #battle.target.show_text "+#{Math.round 25+heal_percent battle.target, 0.125,false}", 'font_green'
    target: 'allies'
    attributes: <[status heal magic]>
    desc: "Heals all allies."
skills.healblock =
    name: "Malus Vital"
    animation: 'heal'
    sfx: \groan
    sp:100
    action: ->
        for target in battle.target
            target.inflict buffs.healblock
    target: 'enemies'
    attributes: <[status magic]>
    desc: "Prevents the target from being healed, and redirects heals to the user instead."
skills.regenerate =
    name: "Regenerate"
    animation: 'heal'
    sfx: \itemget
    sp: 100
    action: -> battle.actor.inflict buffs.regen
    target: 'self'
    attributes: <[status heal magic]>
    desc: "A slow self-heal that restores all health."
#skills.reversal =
#    name: "Reversal"
#    animation: 'slash'
#    sp: 100
#    action: ->
#
#    target: 'enemy'
#    attributes: <[status magic]>
#    desc: "Switches buffs with the target."
skills.clense =
    name: "Cleanse"
    animation: 'heal'
    sfx: \itemget
    sp: 99
    action: ->
        bufflist=[]
        for buff in battle.target.buffs
            bufflist.push buff if buff.name isnt \null
        return if bufflist.length is 0
        bufflist[Math.random!*bufflist.length.|.0]remedy!
    target: 'ally'
    attributes: <[status magic]>
    desc: "Removes one random effect from an ally."
    aitarget: !->
        allylist=ally_list!
        target=null
        highest=0
        for ally in allylist
            negcount=0
            for buff in ally.buffs
                negcount++ if buff.negative
            if negcount>0
                highest=negcount
                target=ally
        if !target then return battle.target=battle.actor
        return battle.target=target
skills.mega-clense =
    name: "Cleanse Wave"
    animation: 'heal'
    sfx: \itemget
    sp: 110
    ex: 20
    action: ->
    target: 'allies'
    attributes: <[status magic]>
    desc: "Cures all ailments."
skills.purge =
    name: "Purge"
    animation: \heal
    sfx: \itemget
    sp: 99
    action: skills.clense.action
    target: \enemy
    attributes: <[status magic]>
    desc: "Removes one random effect from an enemy."
skills.cure =
    #Used by cure-chan
    name: "Cure"
    animation: 'heal'
    sfx: \itemget
    sp: 50
    action: ->
        for buff in battle.target.buffs
            buff.remedy! unless buff.name is \coagulate
    target: 'self'
    attributes: <[status magic]>
    desc: "Cures all ailments."
skills.artillery =
    #name: "Altileri Shel"
    name: "Artillery Shot"
    animation: 'flame'
    sfx: \flame
    sp: 100
    ex: 50
    action: ->
        damage_target 100
    target: 'enemy'
    attributes: <[tech attack]>
    desc: "Blasts the target with a shot from a cannon."
skills.rail-cannon =
    name: "Rail Cannon"
    animation: 'flame'
    sfx: \flame
    custom_animation: !->
        actor=x:battle.actor.x, y:battle.actor.y
        target=x:battle.target.x, y:battle.target.y
        if battle.actor instanceof Battler then actor.x+=WS*3; actor.y+=WS*3
        if battle.target instanceof Battler then target.x+=WS*3; target.y+=WS*3
        quantity=12
        setanimation=(i)->
            a=get_animation!
            if i is quantity then a.callback=battle.animation.callback
            a.play 'flame', actor.x + (target.x - actor.x)*(i/quantity), actor.y + (target.y - actor.y)*(i/quantity)
            sound.play \flame
        count=0
        for i til quantity
            setTimeout (->setanimation(++count)), 100*i
    sp: 200
    ex: 50
    action: ->
        damage_target 220
    target: 'enemy'
    attributes: <[tech attack]>
    desc: "Propels a projectile forward at amazing speeds using magnetic force."
skills.nuke =
    name: "Tactical Nuke"
    animation: 'flame'
    sfx: \flame
    custom_animation: !->
        target=x:battle.target.x, y:battle.target.y
        if battle.target instanceof Battler then target.x+=WS*3; target.y+=WS*3
        quantity=24
        done=false
        setanimation=(i)->
            a=get_animation!
            if i is quantity and not done
                done = true
                a.callback=battle.animation.callback
            radius=WIDTH*i/quantity;
            angle=Phaser.Math.PI2*Math.random();
            a.play 'flame', target.x+Math.sin(angle)*radius, target.y+Math.cos(angle)*radius
            sound.play \flame
        count=0
        for i til quantity
            ++count
            for j til 6
                setTimeout ((count)->setanimation(count)).bind(this,count), 100*i
    sp: 400
    ex: 50
    action: ->
        damage_target 500
        for enemy in enemy_list(true)
            continue if enemy is battle.target
            damage enemy, 100
        for ally in ally_list(true)
            damage ally, 15
    target: 'enemy'
    attributes: <[tech attack]>
    desc: "A super powerful blast. The shockwave damages everyone on the field."
skills.flare =
    name: "Wing Flare"
    animation: 'flame'
    sfx: \flame
    sp: 50
    xp: 10
    action: ->
        battle.target.inflict buffs.decoy
    target: 'self'
    attributes: <[status tech]>
    desc: "Makes enemies more likely to attack the user."
skills.vbite =
    name: "Vampire Bite"
    animation: 'slash'
    sp: -> 100
    action: ->
        damage_target 75
        heal battle.actor, (Math.round calc_damage battle.actor, battle.target, 25), true
    target: 'enemy'
    attributes: <[blood attack]>
    desc: "Sucks life out of the enemy."
skills.curse =
    name: "Haunt"
    sfx: \groan
    animation: 'curse'
    sp: 50
    action: ->
        battle.target.inflict buffs.curse
    target: 'enemy'
    aitarget: ->
        enemylist = enemy_list!
        list = []
        for enemy in enemylist
            list.push enemy unless enemy.has_buff buffs.curse
        list = enemylist if list.length is 0
        battle.target = list[Math.floor Math.random!*list.length]
    weight: 2
    attributes: <[status magic]>
    desc: "Sends an evil spirit to haunt the target, cutting its max HP."
skills.slowness =
    name: "Slowness"
    action: !->
        target.inflict buffs.chill
skills.wanko =
    name: "Wanko Mayem"
    sfx: \groan
    animation: 'curse'
    sp: 100
    action: ->
        battle.target.inflict buffs.wanko
    target: 'ally'
    aitarget: ->
        allylist=ally_list!
        for ally in allylist
            if ally.monstertype is Monster.types.parvo
                return battle.target=ally
        battle.target = allylist[Math.floor Math.random!*allylist.length]
    weight: 3
    attributes: <[status magic]>
skills.isolate=
    name: "Isolate"
    sfx: \groan
    animation: 'curse'
    sp: 100
    action: ->
        for target in battle.target then target.inflict buffs.isolated
    target: 'enemies'
    attributes: <[status magic]>
skills.poison =
    name: 'Poison'
    animation: 'curse'
    sfx: \groan
    sp: 100
    action: ->
        battle.target.inflict buffs.poison
    target: 'enemy'
    aitarget: ->
        enemylist = enemy_list!
        list = []
        for enemy in enemylist
            list.push enemy unless enemy.has_buff buffs.poison
        list = enemylist if list.length is 0
        battle.target = list[Math.floor Math.random!*list.length]
    weight: 2
    attributes: <[status magic]>
skills.poisonwave =
    name: 'Poison Wave'
    animation: 'curse'
    sfx: \groan
    sp: 100
    action: !->
        for target in battle.target
            target.inflict buffs.poison
    target: 'enemies'
    attributes: <[status magic]>
skills.poisonstrike =
    name: 'Poison Strike'
    sp: 100
    action: !->
        if battle.target.has_buff buffs.poison
            damage_target 120
        else
            damage_target 60
            if battle.actor.luckroll!>80 then battle.target.inflict buffs.poison
    target: 'enemy'
    desc: 'Does more damage against poisoned foes.'
    attributes: <[attack]>
skills.drown =
    name: 'Rip Current'
    animation: 'water'
    sfx: \water
    sp: 100
    action: ->
        battle.target.inflict buffs.drown
    target: 'enemy'
    weight: 2
    attributes: <[status magic]>
skills.lick =
    name: 'Lick'
    animation: 'water'
    sfx: \water
    sp: 100
    action: ->
        damage_target 20
        battle.target.inflict buffs.licked
    target: 'enemy'
    weight: 2
    attributes: <[status magic]>
skills.burn =
    name: 'Blaze'
    animation: 'flame'
    sfx: \flame
    sp: 60
    action: -> battle.target.inflict buffs.burn
    aitarget: skills.hemorrhage.aitarget
    target: \enemy
    attributes: <[magic fire attack]>
skills.burn2 =
    name: 'Char'
    animation: 'flame'
    sfx: \flame
    sp: 30
    action: skills.burn.action
    aitarget: skills.burn.aitarget
    target: \enemy 
    attributes: <[magic fire attack]>
skills.inferno =
    name: 'Inferno'
    animation: 'flame'
    custom_animation: skills.hellfire.custom_animation
    sfx: \flame
    sp: 100
    action: ->
        for target in battle.target
            for buff in target.buffs
                if buff.name is \burn
                    buff.intensity=3
                    buff.duration=1
                    buff.frame=2
    target: \enemies
    attributes: <[magic fire status]>
skills.sarssummon =
    name: 'Summon'
    sfx: \groan
    animation: \curse
    sp:100
    action: ->
        for from 0 til monsters.length
            x=if Math.random!<0.5 then 0 else WIDTH*2/3
            battle.addmonster (new Monster x+random_dice(2)*WIDTH/3, random_dice(2)*HHEIGHT, \sarssummon, battle.actor.level)
    target: \self
    attributes: <[summon]>
skills.slimesummon =
    name: 'Summon'
    sfx: \groan
    animation: \curse
    sp: 100
    action: ->
        for i from 0 to 1
            x=battle.actor.x + (i*2-1)*WIDTH/4
            battle.addmonster(new Monster x, battle.actor.y, \slime2, battle.actor.level) 
    target: \self
    attributes: <[summon]>
skills.lepsysummon =
    name: 'Summon'
    sfx: \groan
    animation: \curse
    sp:100
    action: ->
        for i from 0 to 1
            x=battle.actor.x + (i*2-1)*WIDTH/4
            battle.addmonster(new Monster x, battle.actor.y, \polyduck, battle.actor.level) 
    target: \self
    attributes: <[summon]>
skills.parvosummon =
    name: 'Summon'
    sfx: \groan
    animation: \curse
    sp: 100
    action: ->
        for i from 0 to 1
            x=battle.actor.x + (i*2-1)*WIDTH/4
            battle.addmonster(new Monster x, battle.actor.y, \doggie, battle.actor.level) 
    target: \self
    attributes: <[summon]>
skills.martingale =
    name: 'Martingale'
    sp: 100
    delay: 0
    action: ->
        if battle.lastskillhero isnt skills.martingale or battle.actor.lastskill isnt skills.martingale
            skills.martingale.delay = 0
        if battle.actor.luckroll! < 0.66
            skills.martingale.delay++
        else
            damage_target 100 + (100 * skills.martingale.delay * 2)
            skills.martingale.delay = 0
    target: 'enemy'
    desc: "Has a chance of being delayed, and becomes more powerful each time it is."
    # Meant to be used in repition. Very powerful. Affected by luck. 50% chance of success
    # Upon failure, costs a small amount of HP. Next failure will cost twice as much HP
    # Upon success, heals all hp lost by using this move.
    # when successful, does more damage for every previous failure. Total damage should be as though it hit every time.
skills.trickortreat =
    name: 'Tricker Treat'
    desc: "Randomly grants some effect to an ally or enemy."

skills.joki_thief=
    name: 'Thief'
    sfx: \groan
    animation: \curse
    custom_animation:!->
        battle.monstergroup.bringToTop battle.actor
        origin=x:battle.actor.x,y:battle.actor.y
        itemorigin=x:battle.target.item.x,y:battle.target.item.y
        battle.target.originalitem=battle.target.item.base if battle.target.item.base isnt buffs.null
        Transition.move battle.actor, battle.target, 1000, !->
            Transition.move battle.target.item, battle.actor.item,500,!->
                battle.target.item.x=itemorigin.x
                battle.target.item.y=itemorigin.y
                battle.actor.item.load_buff battle.target.item.base
                battle.target.item.load_buff buffs.null
                Transition.move battle.actor, origin, 1000, !->
                    battle.monstergroup.sort 'x', Phaser.Group.SORT_DESCENDING
                    process_callbacks battle.animation.callback
    sp: 100
    target:\enemy
    aitarget: ->
        enemylist = enemy_list!
        list = []
        for enemy in enemylist
            list.push enemy if enemy.item.base isnt buffs.null
        list = enemylist if list.length is 0
        battle.target = list[Math.floor Math.random!*list.length]
    #"Joki's 3 clones steal the players' items."
skills.joki_split=
    name: 'Split'
    sfx: \groan
    animation: \curse
    sp: 100
    target:\self
    custom_animation:!->
        for from monsters.length to 3
            battle.addmonster(new Monster battle.actor.x, battle.actor.y, \jokiclone, battle.actor.level) 
        skills.joki_shuffle.custom_animation!
    #"Joki summons up to 3 clones"
skills.joki_shuffle=
    name: 'Shuffle'
    sfx: \groan
    animation: \curse
    weight: 1
    sp: 100
    target:\self
    custom_animation:!->
        shuffle monsters
        shuffle battle.monstergroup.children
        pos=
            {x:HWIDTH+7.5*WS,y:HHEIGHT-1*WS}
            {x:HWIDTH+2.5*WS,y:HHEIGHT-2*WS}
            {x:HWIDTH-2.5*WS,y:HHEIGHT-2*WS}
            {x:HWIDTH-7.5*WS,y:HHEIGHT-1*WS}
        #TODO: shuffle items
        itemlist=[]
        for monster in monsters then itemlist.push monster.item.base
        shuffle itemlist
        for monster, i in monsters
            monster.item.load_buff itemlist[i]
            monster.item.visible=false
            Transition.move monster, pos[i], 2000, !->
                @item.visible=true if @item.alive
                if this is monsters[0]
                    battle.monstergroup.sort 'x', Phaser.Group.SORT_DESCENDING
                    process_callbacks battle.animation.callback
    #"Joki and her clones shuffle around the screen. the monster array is also shuffled"

skills.shroud =
    name: "Shroud"
    sfx: \groan
    animation: \curse
    weight: 1
    sp: 100
    target: \allies
    action:!->
        for target in battle.target
            target.inflict buffs.obscure
    #desc: "Covers the user's team in a mysterious fog, hiding their status from the enemy."

#----------------------------------------
for key, properties of skills
    skills[key] = new Skill properties
    skills[key]id = key

#========================================
# Skill Book
#----------------------------------------
# for skills learned by means other than level

skillbook =
    all: []

!function create_skillbook
    skillbook := {all:[]}
    for p in players
        skillbook[p.name] = {}
        for f of formes[p.name]
            skillbook[p.name][f] = []
        skillbook[p.name]all = []


#========================================================================
# Math
#========================================================================

function distance (p1, p2)
    Math.sqrt <| Math.pow(p2.x - p1.x, 2) + Math.pow(p2.y - p1.y, 2)
    
function manhattan (p1, p2)
    Math.abs(p2.x - p1.x) + Math.abs(p2.y - p1.y)

function normalize (v)
    dist = distance x:0, y:0, v
    if dist==0 then x:0, y:0 else x: v.x/dist, y: v.y/dist

#function rand (seed)
#    (1103515245 * seed + 12345) % 4294967296 / 4294967296

function rand (seed)
    rand.seed=seed if seed?
    (t=Math.sin(rand.seed++)*1000)-Math.floor(t)
rand.seed=1

#========================================================================
# Angles
#========================================================================

function angleDEG (p1, p2)
    a = Math.atan2(p2.y - p1.y, p2.x - p1.x) * 180 / Math.PI
    return if a < 0 then a + 360 else a
function angleRAD (p1, p2)
    a = Math.atan2(p2.y - p1.y, p2.x - p1.x)
    return if a < 0 then a + Math.PI*2 else a
    
DEGtoRAD =(a)-> a * Math.PI / 180
RADtoDEG =(a)-> a * 180 / Math.PI

#========================================================================
# Collision
#========================================================================

function rect_collision (r1, r2)
    return r1.x < r2.x+r2.w and r1.x+r1.w > r2.x and r1.y < r2.y+r2.h and r1.y+r1.h > r2.y
    
function point_in_rect (point, x, y, w, h)
    return point.x < x+w and point.x > x and point.y < y+h and point.y > y

function point_in_body (point, body)
    return point.x < body.x+body.width and point.x > body.x and point.y < body.y+body.height and point.y > body.y
    
function point_in_sprite (point, sprite)
    rect =
        x: sprite.world.x - sprite.anchor.x * sprite.width
        y: sprite.world.y - sprite.anchor.y * sprite.height
        width: sprite.width, height: sprite.height
    return point_in_body point, rect

function body_to_rect(body)
    x: body.position.x - body.tile-padding.x
    y: body.position.y - body.tile-padding.y
    w: body.width + body.tile-padding.x
    h: body.height + body.tile-padding.y

function body_radius (body)
    return Math.sqrt(Math.pow(body.width,2)+Math.pow(body.height,2))/2
function body_diameter (body)
    return Math.sqrt(Math.pow(body.width,2)+Math.pow(body.height,2))
    
function body_collision (b1, b2, o=x:0 y:0)
    return rect_collision {x:b1.x+o.x, y:b1.y+o.y, w:b1.width+o.x, h:b1.height+o.y}, {x:b2.x, y:b2.y, w:b2.width, h:b2.height}

/* #Was used for pathfinding. Now unused
compare_field = (f,a,b)-->
    return -1 if a[f] < b[f]
    return 1 if a[f] > b[f]
    return 0
    
*/

#========================================================================
# Dialog

!function break-lines3 (string, line-width,font)
    return string if line-width is 0
    chars=game.cache.getBitmapFont(font).font.chars
    spacewidth=chars[' '.codePointAt(0)]xAdvance
    line-width*=FW
    text=''
    #split on newline
    olines=string.split('\n')
    for l in olines
        lwidth=0
        nline=''
        #split on space
        words=l.split(' ')
        for w in words
            wwidth=0
            #calculate width of word
            warray=(if Array.from then Array.from(w) else  w.split(''))
            for null,i in warray
                char=chars[warray[i]codePointAt(0)]
                if char then wwidth+=char.xAdvance
            #add word to line
            if lwidth+wwidth<=line-width
                nline+=w+' '
                lwidth+=wwidth+spacewidth
            #break long words up
            else if wwidth>line-width
                #for null,i in warray
                while warray.length
                    char=chars[warray[0].codePointAt(0)]
                    wwidth=if char then char.xAdvance else 0
                    if lwidth+wwidth<=line-width
                        nline+=warray.shift!
                        lwidth+=wwidth
                    else
                        text+=nline+'\n'
                        nline=''
                        lwidth=0
                nline+=' '
                lwidth+=spacewidth

            #create new line
            else
                text+=nline+'\n'
                nline=w+' '
                lwidth=wwidth+spacewidth
        #finish printing line
        text+=nline+'\n'
    return text.trimRight!


#========================================================================
# Utility
#========================================================================

!function shuffle a
    for i from 0 til a.length
        j=Math.floor Math.random!*a.length
        t=a[i]
        a[i]=a[j]
        a[j]=t
    return a

!function get-cached-image key
    #return game.cache._cache.image[key]
    return game.cache.getImage(key,true)

!function charlen(char,font='unifont')
    char=game.cache.getBitmapFont(font).font.chars[char.codePointAt(0)]
    return if char then char.xAdvance else 0

!function random_dice(dice=1)
    ret=0
    for til dice
        ret+=Math.random!
    return ret/dice


!function process_callbacks (c)
    if c instanceof Array then for callback in c
        process_callback.call @, callback
    else
        return process_callback.call @, c
    !function process_callback (c)
        if typeof c is \function
            return c.call @
        else if c and typeof c is \object
            return c.callback.apply c.context || @, c.arguments || []

!function access (property, ...args)
    if typeof property is \function
        return property.apply @, args
    return property

!function accessor (object,property)
    return 
        object:object
        property:property
        get:->@object[@property]
        set:(v)!->@object[@property]=v

!function callfor (a,f,...args)
    if a instanceof Array
        ret=false
        for o in a
            if typeof f is \function
                ret=true if f.apply o, args
            else
                ret=true if o[f]apply o, args
        return ret
    else
        if typeof f is \function
            return f.apply a, args
        else
            return a[f]apply a, args 

!function calltarget
    Array.prototype.unshift.call arguments, battle.target
    callfor ...


!function implement (obj, src)
    for key of src
        if obj[key]?
            console.warn "Key #{key} already exists on object. Skipping."
            continue 
        if typeof src[key] is \object
            obj[key] = JSON.parse JSON.stringify src[key]
        else
            obj[key] = src[key]

function clone (obj)
    JSON.parse JSON.stringify obj


function construct (@@, args)
    function CONSTRUCT
        @@apply @, args
    CONSTRUCT.prototype = @@prototype
    new CONSTRUCT

!function batchload (data, dir='', type='image')
    for argl in data
        if argl.1 instanceof Array
            for part, i in argl.1
                argl.1[i] = dir+part
        else
            argl.1 = dir+argl.1

        game.load[type]apply game.load, argl

!function batchload_battler
    args=[]
    for battler in arguments #for each battler
        for data, i in battler
            if i is 0 #basic sprite
                name = data
                args.push ["#{name}_battle" "#{name}.png"]
                for forme from 1 to 2
                    args.push ["#{name}_battle_#{forme}" "#{name}_#{forme}.png"]
            else #costumes
                if typeof data is \object
                    for costume,forme of data
                        args.push ["#{name}_battle_#{costume}" "#{name}_#{costume}.png"]
                        args.push ["#{name}_battle_#{costume}_#{forme}" "#{name}_#{costume}_#{forme}.png"] if forme>0
                        if typeof forme is \string
                            args.push ["#{name}_battle_#{costume}_1" "#{name}_#{costume}_1.png"] 
                            args.push ["#{name}_battle_#{costume}_2" "#{name}_#{costume}_2.png"]
                else
                    args.push ["#{name}_battle_#{n}" "#{name}_#{n}.png"]
                    for forme from 1 to 2
                        args.push ["#{name}_battle_#{data}_#{forme}" "#{name}_#{data}_#{forme}.png"]
    batchload.call @, args, \img/battle/
        

!function pad (padding, string, padleft)
    return padding unless string
    if padleft
        return (padding + string)slice(-padding.length)
    else
        return (string + padding)substring(0, padding.length)

!function reset_treasure
    for key, value of switches
        delete! switches[key] if key.index-of("treasure_")>-1

!function require_switch s
    if !s.properties then return true
    if s.properties.off_switch and switches[s.properties.off_switch]
    or s.properties.require_switch and !switches[s.properties.require_switch]
        return false
    return true

!function setrow o, r
    return unless o.key
    w=(get-cached-image o.key)frameWidth or o.texture.width
    h=(get-cached-image o.key)frameHeight or o.texture.height
    o.crop x:0, y: r*h, width: w, height: h
    #o.crop x:0, y:r*o.height, width:o.width, height:o.height

!function override o,n
    return -> o.apply(@,&); n.apply(@,&)

!function override_before o,n
    return -> n.apply(@,&); o.apply(@,&)

tl.dictionary={}
!function tl t
    #use t to find translated text from language file
    t = tl.dictionary[t] if tl.dictionary[t]?
    #make text substitutions
    for i from 1 til &length
        t=t.replace new RegExp("\\{"+(i-1)+"\\}",'g'), &[i]
    return t

!function tle t # a version of tl that escapes html characters
    t = escape-html(tl.dictionary[t]) if tl.dictionary[t]?
    for i from 1 til &length
        t=t.replace new RegExp("\\{"+(i-1)+"\\}",'g'), &[i]
    return t

!function escape-html t
    (div=document.createElement \div).appendChild document.createTextNode t
    return div.innerHTML

!function unifywidth s
    #converts full-width letters and numbers to standard half-width
    s=s.replace /[\uff01-\uff5e]/g
    , (ch)-> String.fromCharCode(ch.charCodeAt(0) - 0xfee0)
    return s

#========================================================================
# Stats and XP
#========================================================================
function xp-to-level (xp)
    #Math.floor (5+Math.sqrt(25+20*xp))/10
    Math.floor -4 + Math.sqrt(25+xp)
function level-to-xp (level)
    #5*Math.pow(level,2)-5*level
    Math.pow(level,2) + 8*level - 9 # y = (x-1)^2 + 10(x-1)

function calc_stat (level, base_stat, mult=1.11)
    #base_stat /= 5
    (-base_stat/mult)*Math.pow(2,-0.03*level)+base_stat
/*
function linear_calc_stat (level, base_stat)
    base_stat /= 7
    #base_stat * Math.pow(level,0.5) + base_stat
    base_stat * level + base_stat / level
*/
function new_calc_stat (level, base_stat)
    base_stat /= 100
    ((Math.pow level, 1.5) + 5*level + 20)*base_stat
/*
function new_calc_stat (level, base_stat)
    base_stat /= 100
    (level*level + 7*level + 20)*base_stat
*/
function xp_needed (level)
    (level-to-xp level+1) - (level-to-xp level)

function xp_process (actor, skill, target)
    xpn = xp_needed actor.level
    xpa = (xpn * skill.xp) <? target.xpwell
    target.xpwell -= xpa
    actor.reward_xp xpa

function luckroll #context should be a battler, monster, or player.
    Math.pow Math.random!, 100/@get_stat \luck

#Should party luck be based on an average, the leader, or the highest?
pluckroll=pluckroll_leader
function pluckroll_average
    lucktotal=0
    for p in party
        lucktotal += p.get_stat \luck
    Math.pow Math.random!, 100*party.length/lucktotal

function pluckroll_leader
    player.luckroll!

function pluckroll_highest
    highestluck = 1
    for p in party
        highestluck = (p.get_stat \luck) >? highestluck
    Math.pow Math.random!, 100/highestluck

function pluckroll_battle
    highestluck = 1
    for p in heroes
        continue unless p.alive
        highestluck = (p.get_stat \luck) >? highestluck
    Math.pow Math.random!, 100/highestluck

function pluckroll_gamble
    luck=100
    if player.equip isnt buffs.null and player.equip.mod_luck?
        luck = player.equip.mod_luck luck
    Math.pow Math.random!, 100/luck

function stattext (num,digits)
    num = (Math.ceil num).toString!
    fin = num
    if num.length > digits and num.length >= 4
        fin = (num.substr 0, num.length - 3)+'K'
        if fin.length > digits and num.length >= 7
            fin = (num.substr 0, num.length - 6)
            places = digits - (fin.length+2)
            if places > 0
                places = (num.substr num.length - 6, places)
                for char in places by -1
                    if char is '0' then places = places.slice(0,-1)
                    else break
                fin += '.'+places if places.length > 0
            fin += 'M'
    return fin

function hpstattext (hp,max,digits)
    budget = digits*2
    digits2 = budget - (Math.ceil hp).toString!length >? digits
    digits = budget - digits2
    hp = stattext hp, digits
    max = stattext max, digits2
    slash = if hp.length + max.length <= budget - 2 then ' / ' else '/'
    return hp+slash+max

function levelrange_old(l1,l2)
    rl= Math.round Math.random!*(l2 - l1)+l1
    dif=(averagelevel! - rl)/2
    nl=rl+((Math.ceil Math.abs dif)*Math.sign dif)
    return Math.min (Math.max nl,l1),l2
    #return Math.min Math.max(l1,averagelevel!),l2

function levelrange(l1,l2)
    return averagelevel! if switches.beat_game
    return l1 >? averagelevel! <? l2

function averagelevel
    totallevel=0
    for p in party
        totallevel+=p.level
    return Math.round(totallevel/party.length)

#========================================================================
# Log
#========================================================================

!function warn
    console.warn.apply console, &
!function log
    console.log.apply console, &

#========================================================================
# Colors
#========================================================================

!function togray color
    c=breakcolor color
    c.r=c.g=c.b=(c.r+c.g+c.b)/3
    return makecolor c

!function oldmultcolor (color, mult)
    return (color.&.0xff0000)*mult.|.(color.&.0x00ff00)*mult.|.(color.&.0x0000ff)*mult

!function breakcolor (color, power)
    rgb = 
        r:((color.&.0xff0000).>>.16)
        g:((color.&.0x00ff00).>>.8)
        b:(color.&.0x0000ff)
    if power
        rgb.r = rgb.r*rgb.r; rgb.g = rgb.g*rgb.g; rgb.b = rgb.b*rgb.b
    return rgb

!function makecolor (rgb, power)
    if power
        rgb.r = Math.sqrt rgb.r; rgb.g = Math.sqrt rgb.g; rgb.b = Math.sqrt rgb.b
    return rgb.r.<<.16.|.rgb.g.<<.8.|.rgb.b

!function gradient (color1, color2, i, power=true)
    color1 = breakcolor color1, power
    color2 = breakcolor color2, power
    color3 = r:0,g:0,b:0
    for c of color3
        color3[c] = (color2[c] - color1[c]) * i + color1[c]
    return makecolor color3, power

!function recolormonster(sprite)
    if sprite.monstertype?pal
        recolormonster1 sprite
    else
        recolormonster2 sprite if battle.encounter.toughness>0
        recolormonster2 sprite if battle.encounter.toughness>1
    sprite.animate?!

!function recolormonster1(sprite)
    return if battle.encounter.toughness is 0 and !sprite.monstertype.pal1
    colors=sprite.monstertype.pal
    colors2=sprite.monstertype[
        if battle.encounter.toughness>1 then \pal3
        else if battle.encounter.toughness>0 then \pal2
        else \pal1
    ]
    bmd=game.make.bitmapData(sprite.texture.baseTexture.width,sprite.texture.baseTexture.height);bmd.draw(sprite.texture.baseTexture.source,0,0);bmd.update();
    for c,i in colors
        c2=colors2[i]
        bmd.replaceRGB c.>>.16,c.>>.8.&.255,c.&.255,255,  c2.>>.16,c2.>>.8.&.255,c2.&.255,255
    bmd.frameData=sprite.animations.frameData
    sprite.load-texture bmd

!function recolormonster2(sprite)
    colors=[]
    bmd=game.make.bitmapData(sprite.texture.baseTexture.width,sprite.texture.baseTexture.height);bmd.draw(sprite.texture.baseTexture.source,0,0);bmd.update();
    for x from 0 til bmd.width
        for y from 0 til bmd.height
            c=bmd.getPixel x,y
            continue if c.a is 0
            colors.push color if colors.index-of(color=(c.r.<<.16)+(c.g.<<.8)+c.b) is -1
    for c in colors
        bmd.replaceRGB c.>>.16,c.>>.8.&.255,c.&.255,255, c.>>.8.&.255,c.&.255,c.>>.16,255
    bmd.frameData=sprite.animations.frameData
    sprite.load-texture bmd

!function recolor(sprite,colors1,colors2)
    bmd=game.make.bitmapData(sprite.width,sprite.height);bmd.draw(sprite.texture.baseTexture.source,0,0);bmd.update();
    for c,i in colors1
        c2=colors2[i]
        bmd.replaceRGB c.>>.16,c.>>.8.&.255,c.&.255,255, c2.>>.16,c2.>>.8.&.255,c2.&.255,255
    sprite.load-texture bmd

#========================================================================
# Saving and Loading
#========================================================================

!function setswitch (key,value,nosave=false)
    switches[key] = value
    save! if not nosave

!function dyslexia (string)
    try
        JSON.parse string
    catch
        string=String.fromCharCode.apply @, string.split('').map (a)-> a.charCodeAt!.^.255
    return string

!function saveHandler (key,value)
    try 
        localStorage.setItem key, value
    catch e 
        (if session.localStorageError then warn else alert) "The game could not be saved!\n"+e.message
        session.localStorageError=true

saveslug = "filosis"
!function save (name=switches.name, force)
    return if switches.nosave and not force or !switches.started
    return if game.state.current is \battle
    console.log("Saved!")
    setFile name
    saveHandler("#{saveslug}_#{name}", dyslexia saveString!)
    save_options!

!function battlesave (name=switches.name, force)
    return if switches.nosave and not force or !switches.started
    console.log("Saved!")
    setFile name
    saveHandler("#{saveslug}_#{name}", dyslexia saveString!)
    save_options!

function loadString (name=switches.name)
    dyslexia localStorage.getItem "#{saveslug}_#{name}"

function getFiles
    if file = localStorage.getItem "#{saveslug}-files" then file = dyslexia file else file='{}'
    JSON.parse file

!function setFile (name)
    files = getFiles!
    file = party:[]
    for p in party
        file.party.push name:p.name, xp:p.stats.xp, item:p.equip.id, costume:p.costume
    files[name] = file
    saveHandler "#{saveslug}-files", dyslexia JSON.stringify files

!function deleteFile (name)
    files = getFiles!
    delete! files[name]
    localStorage.removeItem "#{saveslug}_#{name}"
    saveHandler "#{saveslug}-files", dyslexia JSON.stringify files

save_options_mod=[]
load_options_mod=[]
!function save_options
    options=
        sound: sound.volume
        music: music.volume
        menusound: menusound.volume
        voicesound: voicesound.volume
        #quicktext: gameOptions.quicktext
        textspeed: gameOptions.textspeed
        battlemessages: gameOptions.battlemessages
        pauseidle: gameOptions.pauseidle
        exactscaling: gameOptions.exactscaling
    for f in save_options_mod
        f(options) if typeof f is \function
    saveHandler "#{saveslug}-options", JSON.stringify options

!function load_options
    return unless options = localStorage.getItem "#{saveslug}-options"
    options = JSON.parse options
    sound.volume = options.sound
    music.volume = options.music
    menusound.volume = options.menusound if options.menusound?
    voicesound.volume = options.voicesound if options.voicesound?
    #gameOptions.quicktext = options.quicktext if options.quicktext?
    gameOptions.textspeed = options.textspeed if options.textspeed?
    gameOptions.battlemessages = options.battlemessages
    game.stage.disableVisibilityChange=!gameOptions.pauseidle=options.pauseidle if options.pauseidle?
    gameOptions.exactscaling = options.exactscaling
    for f in load_options_mod
        f(options) if typeof f is \function
gameOptions=
    battlemessages:true
    pauseidle:false
    #quicktext:false
    textspeed:67
    exactscaling:false
    #hash options
    language:''
    gameSpeed:1

!function saveString
    file = {}
    file.players={}
    file.skills=all:[]
    for skill in skillbook.all
        file.skills.all.push skill.id
    for p in players
        file.players[p.name] = {}
        file.players[p.name]xp = p.stats.xp
        file.players[p.name]equip = p.equip.id
        file.players[p.name]skills = {}
        file.players[p.name]costume = p.costume
        file.skills[p.name]=all:[]
        for skill in skillbook[p.name]all
            file.skills[p.name]all.push skill.id
        for f of p.skills
            file.players[p.name]skills[f]=[]
            for skill in p.skills[f]
                file.players[p.name]skills[f]push skill.id
            file.skills[p.name][f]=[]
            for skill in skillbook[p.name][f]
                file.skills[p.name][f]push skill.id
        file.players[p.name]formes = {}
        for f of formes[p.name]
            file.players[p.name]formes[f] = formes[p.name][f]unlocked if f isnt \default
    file.party = []
    for p in party
        file.party.push p.name
    file.items = {}
    for i of items
        if items[i]quantity>0
            #file.items[i] = items[i]quantity 
            file.items[i] = q:items[i]quantity, t:items[i]time
    #file.switches = clone switches
    #for key in nosave_switches
    #    delete! file.switches[key]
    file.switches={}
    for key of switches
        file.switches[key]=switches[key] if key not in nosave_switches
    return JSON.stringify file

nosave_switches=
    \cinema
    \cinema2
    \portal
    \spawning
    \noclip
    \nomusic
    \loadgame
    \newgame

!function load (name)
    return if load.clicked
    switches.loadgame=true
    create_actors!
    create_mobs!
    #- interpret localStorage ---
    file = JSON.parse loadString name
    for s in file.skills.all
        skillbook.all.push skills[s]
    for p of file.players
        pp=players[p]; fp=file.players[p]
        continue unless pp
        pp.set_xp fp.xp, true
        if fp.equip
            pp.equip = items[that]
            items[that]equip = pp
        for s in file.skills[p]all
            continue unless skills[s]
            skillbook[p]all.push skills[s]
        for f of fp.skills
            for s in fp.skills[f]
                continue unless skills[s]
                pp.skills[f]push skills[s]
            for s in file.skills[p][f]
                continue unless skills[s]
                skillbook[p][f] = skills[s]
        pp.costume = fp.costume
        update_costume pp, pp.costume
        for f of fp.formes
            continue if !formes[p] or !formes[p][f]
            formes[p][f]unlocked = fp.formes[f]
    party := []
    for p in file.party
        continue unless players[p]
        party.push players[p]
        players[p].revive!
    if party.length is 0
        party.push ebby
        ebby.revive!
    set_party()
    reset_items!
    for i of file.items
        #compatability
        #if typeof file.items[i] is \number 
        #    items[i]quantity = file.items[i]
        #new
        #else
        continue unless items[i]
        items[i]quantity=file.items[i]q
        items[i]time=file.items[i]t
    oldswitches = switches
    switches := file.switches
    items.humanskull2.name=switches.name
    #- start world --------------
    switches.map = switches.checkpoint_map || STARTMAP
    load.clicked = true
    Transition.fade 500, 0 ->
        load.clicked = false
        #game.state.start \overworld false
        game.state.start \load false
        ## FOR OLD VERSIONS
        switch switches.version
        case "Halloween 2016"
            switches.ate_nae=\llov if switches.ate_nae
            switches.bp_has_nae=true if switches.beat_nae and !switches.ate_nae and items.naesoul.quantity<1
            items.excel.quantity+=3
            fallthrough
        case "New Year 2017"
            /*misnamed November 2016*/
            if switches.zmapp?
                items.humanskull2.quantity=1
            switches.water_walking=false unless items.jokicharm.quantity
            #switches.version=version
            fallthrough
        case "Delta 2017" ,"Final Demo", "Release"
            switches.version=version
        #case "Final Demo"
        if typeof switches.sp_limit is \number
            old_sp_limit=switches.sp_limit
            switches.sp_limit={}
            for p in players
                switches.sp_limit[p.name]=old_sp_limit
        #if switches.beat_game and !switches.nogoop
        #    switches.nogoop=true
        if switches.checkpoint_map is \earth and switches.checkpoint is \cp1 and !switches.necrotoxin and !items.necrotoxin.quantity
            items.necrotoxin.quantity=5
        ##
    , null, 10 false
    delete! switches.loadgame

!function newgame
    return if newgame.clicked
    switches.newgame=true
    #- reset values -------------
    skillbook := all: []
    create_actors!
    create_mobs!
    switches := clone switch_defaults
    reset_items true
    #- set party ----------------
    join_party \llov false
    #join_party \ebby false
    #set_party!
    #- start world --------------
    newgame.clicked = true
    Transition.fade 500, 0 ->
        newgame.clicked = false
        #game.state.start \overworld false
        game.state.start \load false
    , scenario.game_start.0, 10 false
    delete! switches.newgame

!function starter_skills (p,f, force)
    ps = players[p]skills[f]
    return if ps.length isnt 0 and not force
    ps.length=0
    fs = formes[p][f]skills
    return unless fs?
    skillist = Object.keys(fs).sort((a,b)->fs[b]-fs[a])
    for s in skillist
        ps.unshift skills[s] if fs[s] <= players[p]level
        break if ps.length is 5
##################################################################
#============================ MIXINS ============================#
##################################################################

var battle_encounter
!function start_battle (enc,toughness=0,terrain)
    Transition.battle 1000 500 20
    log "Entering Battle!"
    enc ?= encounter.sanishark
    enc.toughness=toughness
    enc.terrain=terrain
    battle_encounter := enc
    music.stop!
    temp.enteringbattle=true

!function start_battle2
    dialog.kill!
    game.state.start \battle false
    music.play \battle

!function end_battle (result)
    battle.result=result
    return unless game.state.current is \battle
    battle.mode = \end
    return if battle.ended
    battle.ended=true
    battle.screen.exit!
    /*
    if result in <[victory defeat]>
        for hero in heroes
            hero.export!
    else
        for hero in heroes
            hero.export true false
    */
    for hero in heroes
        hero.export!
    battle.text.text.teletype = true
    music.stop!
    ###TODO: Battle conclusion jingle
    sound.play [{
        victory:''
        defeat:''
        run:'run'
        }[result]]
    messages = [{
        victory:'Enemies Vanquished!'
        defeat:'Heroes Defeated...'
        run:'Escaped from battle!'
        }[result]]
    battle.results.items=[]
    battle.results.skills=[]
    for hero in heroes
        #messages ++= learn_skills hero.name, hero.startlevel, hero.level
        battle.results.skills=learn_skills hero.name, hero.startlevel, hero.level
    #DROPS
    if result is \victory
        if temp.mimic
            battle.drops[temp.mimic.item] ?= {item:items[temp.mimic.item],q:0}
            battle.drops[temp.mimic.item].q+=temp.mimic.quantity
            switches[temp.mimic.name]=true
        for key,drop of battle.drops
            #messages.push "Acquired "+(if drop.q>1 then stattext(drop.q,5)+' ' else '')+drop.item.name+"!"
            battle.results.items.push drop
            acquire items[key], drop.q, true true 
    delete! temp.mimic if temp.mimic
    #
    if result is \run
        temp.runnode=battle.encounter.runnode
    battle.encounter.onvictory! if battle.encounter.onvictory && result is \victory
    battle.encounter.ondefeat! if battle.encounter.ondefeat && result is \defeat
    if result isnt \defeat
        battlesave!
    #game.input.onDown.add end_battle_next_message
    #keyboard.confirm.onDown.add end_battle_next_message
    var end_battle_timeout
    end_battle_messages!
    !function end_battle_messages
        battle.text.show messages.shift!
        #end_battle_timeout := set-timeout (if messages.length>0 then end_battle_messages else battle_result_summary), 3000 
        battle.text.timeout_fire=(if messages.length>0 then end_battle_messages else battle_result_summary)
        battle.text.timeout=set-timeout battle.text.clear-timeout, 3000
    #!function end_battle_next_message
    #    clear-timeout end_battle_timeout
    #    if messages.length>0 then end_battle_messages! else battle_result_summary!
!function end_battle_2
    #clear-timeout end_battle_timeout
    return if game.state.current is not \battle or battle.mode is \transition
    #game.state.start 'overworld', false
    if battle.result is \defeat
        #load switches.name
        quitgame!
    else
        battle.mode = \transition
        Transition.fade 300 0 ->
            game.state.start \overworld false
        , null, 5 true
!function battle_result_summary
    battle.text.kill!
    #clear-timeout end_battle_timeout
    if !battle.results.items.length and !battle.results.skills.length
        battle.screen.exit!
        return end_battle_2!
    battle.screen.show!
    battle.screen.nest battle.results
    if battle.results.items.length
        text=tl("Acquired items")+'\n'
        for icon in battle.results.icons
            drop=battle.results.items.shift!
            if !drop
                icon.kill!
            else
                icon.revive!
                icon.load-texture drop.item.sicon
                icon.frame=drop.item.iconx
                setrow icon, drop.item.icony
                text+=pad_item_name3(drop.item,drop.q)+'\n'
        if battle.results.items.length
            text+=tl("And {0} more...",battle.results.items.length)
    else if battle.results.skills.length
        text=tl("Learned Skills")+'\n'
        for icon in battle.results.icons
            icon.kill!
            if battle.results.skills[0]
                text += battle.results.skills.shift! + '\n'
        if battle.results.skills.length
            text+=tl("And {0} more...",battle.results.skills.length)
    #else end_battle_2!
    battle.results.summary.change text
    battle.results.resize(Math.ceil(battle.results.summary.width/WS+1.5),battle.results.h)
    battle.results.x = HWIDTH - battle.results.w*HWS
!function battle_update_frame
    return unless game.state.current is \battle
    marginwidth = (game.width - WIDTH)/2
    marginheight = (game.height - HEIGHT)/2
    #battle.bg2.width = battle.bg1.width = marginwidth
    #battle.bg1.tile-position.set marginwidth, 0
    #battle.bg4.x = battle.bg3.x = -marginwidth
    #battle.bg4.height = battle.bg3.height = marginheight
    #battle.bg4.width = battle.bg3.width = game.width
    bgoffset = battle.bgoffset
    battle.bg2.width = battle.bg1.width = marginwidth - bgoffset.x
    battle.bg1.tile-position.set marginwidth - bgoffset.x, 0
    battle.bg4.x = battle.bg3.x = -marginwidth
    battle.bg4.height = battle.bg3.height = marginheight
    battle.bg4.width = battle.bg3.width = game.width

var battle, heroes, monsters
state.battle.create =!->
    temp.enteringbattle=false
    input_battle!
    
    battle := game.add.group gui.frame, 'battle'
    battle.mode = 'wait'
    battle.encounter = battle_encounter

    battle.drops={}

    bg = encounter.bg[access (getmapdata \bg), battle.encounter.terrain]
    bg = encounter.bg[access battle.encounter.bg] if battle.encounter.bg

    battle.bg0 = new Phaser.Image game, 0 0 bg.0 |> battle.add-child
    battle.bgoffset = bgoffset = x:(battle.bg0.width - WIDTH)/2 y:battle.bg0.height - HEIGHT
    battle.bg0.x -= bgoffset.x; battle.bg0.y -= bgoffset.y
    marginwidth = (game.width - WIDTH)/2
    #bg1=if typeof bg.1 is \number then \solid else bg.1
    battle.bg1 = new Phaser.TileSprite game, -bgoffset.x, -bgoffset.y, 1, HEIGHT+bgoffset.y, bg.1 |> battle.add-child
    battle.bg1.anchor.set 1 0
    #battle.bg1.tint=bg.1 if typeof bg.1 is \number
    battle.bg2 = new Phaser.TileSprite game, WIDTH+bgoffset.x, -bgoffset.y, 1, HEIGHT+bgoffset.y, bg.1 |> battle.add-child
    #battle.bg2.tint=bg.1 if typeof bg.1 is \number
    battle.bg3 = new Phaser.Image game, 0, -bgoffset.y, \solid |> battle.add-child
    battle.bg3.anchor.set 0 1; battle.bg3.tint = bg.2
    battle.bg4 = new Phaser.Image game, 0 HEIGHT, \solid |> battle.add-child
    battle.bg4.tint = bg.3
    battle_update_frame!
    resize_callback battle, battle_update_frame
    #===============
    # Monsters
    #---------------
    battle.monstergroup=game.add.group battle, 'monstergroup'
    monsters := []
    l=0
    for monster in battle.encounter.monsters
        ll=(levelrange monster.l1, monster.l2)+(battle.encounter.toughness*3)
        ll += battle.encounter.lmod if battle.encounter.lmod
        ll=1 if ll<1
        monsters.push <| battle.monstergroup.add-child <| newmonster = new Monster WIDTH/2 + monster.x*WS, HEIGHT/2 - monster.y*WS, monster.id, ll
        l+=newmonster.level
        recolormonster newmonster
    l=Math.round l/monsters.length
    #new Monster 160, 120, "monster_slime" |> battle.add-child |> monsters.push
    #===============
    # Heroes
    #---------------
    heroes := [] 
    xposition = [[112],[56,168],[8,112,216]][party.length - 1]
    for member, i in party by -1
        new Battler xposition[i], 144, party[i] |> battle.add-child |> heroes.push
    for member in heroes
        member.death! if member.stats.hp is 0
    #---------------
    #encounter level
    battle.encounterlevel = new Text 'font_yellow', "", WIDTH - WS*3, 2 |> battle.add-child
    battle.encounterlevel.anchor.set 1 0
    #l=0
    #for member in monsters
    #    l+=member.level
    #l=Math.round l/monsters.length
    battle.encounterlevel.change tl("Level {0}",l)
    #battle text
    battle.text = new Window 8,0,19,2 |> battle.add-child
    battle.text.text = battle.text.add-text null '' 8 WS
    battle.text.text.anchor.set 0 0.5
    battle.text.show =!->
        @text.teletype = battle.mode==\end or battle.mode==\action or battle.mode==\text
        @revive!;
        @text.change.apply @text, arguments
    battle.text.kill!
    battle.text.skip=!->
        if battle.text.text.textbuffer.length
            battle.text.text.empty_buffer!
        else if battle.text.timeout
            battle.text.clear-timeout!
        else if battle.results.alive
            battle_result_summary!
    battle.text.clear-timeout=!->
        return unless battle.text.timeout
        t=battle.text.timeout
        tf=battle.text.timeout_fire
        battle.text.timeout=null
        battle.text.timeout_fire=null
        clear-timeout t
        tf!
    game.input.onDown.add battle.text.skip
    keyboard.confirm.onDown.add battle.text.skip
    #bring monsters to front
    battle.bring-to-top battle.monstergroup
    for member in heroes
        #member.bring-to-top!
        battle.bring-to-top member
    battle.add-child battle.text.text
    battle.text.text.x=WS
    battle.text.text.update=override battle.text.text.update, !->
        @visible = battle.text.alive
    #battle menus
    battle.screen = new Screen! |> battle.add-child
    battle.screen.nocancel = true
    battle.menu = battle.screen.add-menu 0,8,6,7
    battle.summary = battle.screen.create-window 0,8,7,7
    battle.summary.text = battle.summary.add-text null, 'summary', 8, 8, null, 14
    battle.skill_menu = battle.screen.create-menu 0,8,6,7
    battle.item_menu = battle.screen.create-menu 0,8,8,7, false, true
    battle.item_menu.on-change-selection = battle.skill_menu.on-change-selection =!->
        o = @objects[@selected+@offset]
        text = (access o.desc_battle) || (access o.desc) || ''
        text += "\nSP:#{access o.sp}%" if o.sp?
        #text += "\nEX:#{access o.ex}%" if o.ex? and battle.actor.excel_unlocked!
        battle.summary.text.change text
    battle.results=battle.screen.create-window WS*4,0,12,8
    battle.results.summary=battle.results.add-text('font',"Result Summry",WS+2,HWS,false,0,WS)
    battle.results.icons=[];
    for i from 1 til battle.results.h-1
        battle.results.icons.push <| battle.results.add-child <| new Phaser.Sprite game, 0, WS*i
    #battle.menu = new Menu 0,8,6,7 |> battle.add-child
    #battle.menu.kill!

    battle.animation = new Animation! |> battle.add-child
    battle.animationlist=[]
    battle.targeter = new Phaser.Image game, 0 0 'target' |> battle.add-child
    battle.targeter.update =!->
        if battle.target? and battle.mode.index-of(\target) > -1
            @revive! if not @alive
            t = battle.target
            if t instanceof Monster
                @x = t.x
                @y = t.y - t.height/2
            else if t instanceof Battler
                @x = t.x+t.w/2*WS
                @y = t.y+t.h/2*WS
        else @kill! if @alive
    battle.targeter.anchor.set 0.5

    game.input.onDown.add battle_click, @
    keyboard.confirm.onDown.add battle_select, @
    keyboard.cancel.onDown.add battle_cancel, @, 10
    keyboard.left.onDown.add battle_left, @
    keyboard.up.onDown.add battle_left, @
    keyboard.right.onDown.add battle_right, @
    keyboard.down.onDown.add battle_right, @

    #battle.addmonster=(monster,index=1+@children.index-of @text)!->
    battle.addmonster=(monster)!->
        #monsters.push battle.add-child-at monster, index
        monsters.push battle.monstergroup.add-child monster
        recolormonster monster

    check_trigger!

state.battle.shutdown =!->
    battle.alive = false
    battle.destroy!

!function triggertext text
    battle.mode=\text
    triggertext.list.push text
    if triggertext.list.length is 1
        triggertext.next 0

triggertext.next =(delay)!->
    battle.text.timeout_fire=->
        delay=Math.max 1500,(100 - gameOptions.textspeed)*triggertext.list[0].length
        battle.text.show triggertext.list[0]
        triggertext.list.shift!
        if triggertext.list.length>0
            triggertext.next delay
        else
            battle.text.timeout_fire=->
                battle.mode=\next
                battle.text.kill!
            battle.text.timeout=set-timeout battle.text.clear-timeout, delay
    battle.text.timeout=set-timeout battle.text.clear-timeout, delay
triggertext.list=[]

!function get_animation
    for a in battle.animationlist
        if a.alive then a=null else break
    if !a
        (a = new Animation!) |> battle.add-child |> battle.animationlist.push
    a.callback=null
    return a


!function battle_left
    change_battle_target 1

!function battle_right
    change_battle_target -1

!function change_battle_target (n)
    return unless target_mode!
    list = target_list(true)
    selected = list.index-of battle.target
    if selected is -1 then selected = 0
    selected += n
    if selected < 0 then selected = list.length - 1
    if selected > list.length - 1 then selected = 0
    battle.target = list[selected]
    menusound.play \blip

!function target_list ignorecharm
    targeter = battle.skill || battle.item
    list = []
    list ++= enemy_list(ignorecharm) if targeter.target in <[enemy any]>
    list ++= ally_list! if targeter.target in <[ally any]>
    return list
!function enemy_list ignorecharm, actor=battle.actor
    if actor instanceof Battler then return monster_list!
    if !ignorecharm
        if actor.has_buff buffs.charmed and hero_list!length>1
            list=[]
            for hero in hero_list!
                if hero.name isnt \llov or Math.random!<0.5
                then list.push hero
            return list
        for hero in hero_list!
            if hero.has_buff buffs.decoy
            and Math.random!<0.5 then return [hero]
    return hero_list!
!function ally_list ignorecharm, actor=battle.actor
    allylist=if actor instanceof Battler then hero_list! else monster_list!
    if ignorecharm then return allylist
    if actor.has_buff buffs.isolated then return [actor]
    retlist=[]
    for ally in allylist
        continue if ally isnt actor and ally.has_buff buffs.isolated
        retlist.push ally
    return if retlist.length then retlist else [actor]
!function hero_list
    list = []
    for hero in heroes
        list.push hero unless hero.dead
    return list
!function monster_list
    list=[]
    for monster in monsters
        list.push monster unless monster.dead
    return list

!function battle_cancel
    return unless target_mode!
    #end_turn!
    #battle.mode = 'next'
    battle.target = null
    battle.skill = null
    battle.item = null
    battle.text.kill!
    battle.screen.revive!
    battle.mode = \command
    menusound.play \blip
    return false

!function use_skill
    battle.actor.stats.sp -= (access battle.skill.sp)/100
    #battle.actor.reward_ex? -access battle.skill.ex
    #battle.actor.reward_ex? access battle.skill.ex
    battle.actor.reward_xp? (access battle.skill.xp), battle.target
    if battle.actor instanceof Battler and battle.actor.luckroll!>0.95
        battle.critical = true
    battle.actor.sp_check!

    battle.lastskill = battle.skill
    battle.actor.lastskill = battle.skill
    battle.target?lastskillonme = battle.skill
    if battle.actor instanceof Battler
        battle.lastskillhero = battle.skill
    else battle.lastskillmonster = battle.skill

    if gameOptions.battlemessages and !battle.actor.monstertype?minion
        battle.mode = \action
        text=tl("{0} used {1}!",battle.actor.displayname, battle.skill.name)
        battle.text.show text
        delay=Math.max 1000,(100 - gameOptions.textspeed)*text.length
        battle.text.timeout_fire=->
            use_skill2!
        battle.text.timeout=set-timeout battle.text.clear-timeout, delay
        #set-timeout(use_skill2, delay)
    else
        use_skill2!

    !function use_skill2
        battle.animation.callback = [battle.skill.action]
        if \attack in battle.skill.attributes
            battle.actor.call_buffs !-> battle.animation.callback.push {callback:@attack,context:@}
        battle.animation.callback.push end_turn
        if battle.skill.custom_animation
            battle.skill.custom_animation!
        else
            battle.animation.play (access battle.skill.animation), battle.target.x, battle.target.y
            sound.play if battle.skill.sfx then that else \strike

!function use_item
    if gameOptions.battlemessages
        battle.mode = \action
        text=tl("{0} used {1}!",battle.actor.displayname, battle.item.name)
        battle.text.show text
        delay=Math.max 1000,(100 - gameOptions.textspeed)*text.length
        battle.text.timeout_fire=->
            use_item2!
        battle.text.timeout=set-timeout battle.text.clear-timeout, delay
        #set-timeout(use_item2, delay)
    else
        use_item2!

    !function use_item2
        if battle.item.usebattle? then that battle.target else battle.item.use battle.target
        battle.actor.stats.sp -= 1
        battle.actor.sp_check!
        battle.item.consume!
        battle.item.time=Date.now!
        battle.item_menu.offset=0
        end_turn!

!function battle_select
    return unless target_mode!
    if battle.target?
        battle.mode = \action
        battle.text.kill!
        use_skill! if battle.skill?
        use_item! if battle.item?
    else
        battle.target = target_list(true)0
        menusound.play \blip

!function battle_click (e)
    return battle_cancel! if e.button is 2 
    if battle.mode in <[target_enemy target_any]> then for monster in monsters
        continue if monster.dead
        if point_in_sprite mouse.world, monster
            battle.target = monster
            battle_select!
    if battle.mode in <[target_ally target_any]> then for hero in heroes
        continue if hero.dead
        continue if battle.actor.has_buff buffs.isolated and hero isnt battle.actor
        continue if hero.has_buff buffs.isolated and hero isnt battle.actor
        if point_in_rect mouse.world, hero.worldTransform.tx, hero.worldTransform.ty, hero.w*WS, hero.h*WS
            battle.target = hero
            battle_select!

function target_mode
    battle.mode.index-of(\target) > -1


!function end_turn
    if !battle.actor
        return console.warn "End Turn was called when it shouldn't have been."
    battle.animation.callback.length=0
    battle.actor.call_buffs \turn
    battle.screen.exit!
    unless battle.mode is \text
        battle.mode = 'next'
    battle.text.kill!
    battle.target = null
    battle.actor = null
    battle.critical = false
    battle.skill = null
    battle.item = null
    battle.menu.history = []
    battle.menu.offset=0

    for monster in monster_list!
        monster.update_stats!
    check_trigger!

    check_death!
    check_battle_end!

!function check_trigger
    for monster in monster_list!
        monster.monstertype.trigger?call monster

function undying o
    return false if \mortal in o.attributes
    return (o.monstertype and typeof o.monstertype.undying is \function and o.monstertype.undying.call o)
    or (o.item?base is items.deathsmantle
    and ally_list(null,o)length>1)

!function check_death
    for battler in heroes ++ monsters
        continue if battler.dead
        continue if undying battler
        if battler.stats.hp <= 0 and not battler.dead
            battler.dead=true
            battler.stats.sp = 0
            battler.stats.ex = 0 if battler.stats.ex?
            battler.update_stats!
            battle.mode = 'transition'
            sound.play \defeat
            transition = Transition.fadeout (if battler instanceof Battler then battler.port else battler), 1000 ->
                return unless game.state.current is \battle
                @battler.death!
                @battler.port.alpha = 1 if @battler instanceof Battler
                battle.mode = 'next'
                check_trigger!
                check_battle_end!
            transition.battler = battler

!function check_battle_end
    #living = 0
    #for hero in heroes
    #    living++ unless hero.dead

    if hero_list!length is 0 then end_battle 'defeat'
    else if monsters.length is 0 then end_battle 'victory'


state.battle.update =!->
    main_update!
    if battle.mode in ['wait','next']
        mode = battle.mode
        for hero in heroes
            #continue if hero.dead
            continue if hero.stats.hp<=0 and not undying hero
            #set_actor hero if hero.update_sp! if mode is \wait
            if mode is \wait
                set_actor hero if hero.update_sp!
            else
                set_actor hero if hero.update_sp true
            hero.update_stats!
            return if battle.actor
        for monster in monsters
            continue if monster.stats.hp<=0 and not undying monster
            #monster.attack! if battle.mode is \wait if monster.update_sp! if mode is \wait
            monster.attack! if mode is \wait and monster.update_sp! and battle.mode is \wait
            monster.update_stats!
            return if battle.actor
        battle.mode = \wait if battle.mode is \next
    else 
        if battle.mode in <[target_enemy target_any]>
            prevtarget=battle.target
            for monster in monsters
                if battle.target is not monster and point_in_sprite mouse.world, monster
                    battle.target = monster
            if battle.target isnt prevtarget
                menusound.play 'blip'
        if battle.mode in <[target_ally target_any]>
            for hero in heroes
                continue if hero.dead
                continue if battle.actor.has_buff buffs.isolated and hero isnt battle.actor
                continue if hero.has_buff buffs.isolated and hero isnt battle.actor
                if battle.target is not hero and point_in_rect mouse.world, hero.worldTransform.tx, hero.worldTransform.ty, hero.w*WS, hero.h*WS
                    battle.target = hero
                    menusound.play 'blip'

    !function set_actor (actor)
        battle.actor = actor
        battle.mode = 'command'
        battle.menu.x = actor.x
        #battle.menu.revive!
        battle.screen.show!
        if actor.skills.length > 0
            menuset = [\Skills skill_menu]
        else menuset = [\Attack callback:choose_skill, arguments: [skills.attack]]
        if itemskill = access.call actor.item, actor.item.skill
            menuset ++= [itemskill.name, callback:choose_skill, arguments:[itemskill]]
        menuset ++= [\Items item_menu]
        if excel_count! > 0
            if battle.actor.forme.stage is 0
                if battle.actor.stats.ex >= battle.actor.forme.stage+1
                    menuset ++= ['★Excel', excel_menu]
                else
                    menuset ++= ['Excel', 0]
        else if actor.forme and actor.forme.stage>0
            menuset ++= ['Reversion',->battle.actor.excel \default; battle.actor.stats.sp++; end_turn!]
        #if battle.actor.stats.sp_limit > 1
        #    menuset ++= ['Wait', if battle.actor.stats.sp_limit > battle.actor.stats.sp_level then battle_wait else 0]
        if battle.actor.stats.sp_limit > battle.actor.stats.sp_level
            menuset ++= ['Charge', battle_charge]
        else
            menuset ++= ['Pass', battle_wait]
        #menuset ++= ['Run' callback: end_battle, arguments: <[run]>]
        menuset ++= ['Run' run]
        battle.menu.set.apply battle.menu, menuset
    !function run
        battle.mode = \action
        runchance=100
        for monster in monsters
            if monster.monstertype.escape? then runchance = monster.monstertype.escape <? runchance
        if runchance is 0
            battle.text.show("Escape is impossible!")
            battle.menu.kill!
            return set-timeout(end_turn, 1000)
        if runchance is 100
            return end_battle \run
        itemboost=100
        for hero in heroes
            if hero.item.mod_escape? then itemboost = hero.item.mod_escape itemboost
        #if Math.random!*itemboost > 100-runchance
        if battle.actor.luckroll!*itemboost > 100-runchance
            return end_battle \run
        else
            battle.text.show("Failed to escape!")
            battle.menu.kill!
            return set-timeout(battle_wait, 1000)

    !function choose_skill (skill)
        battle.screen.kill!
        battle.skill = skill
        if skill.target in <[ally enemy any]>
            battle.mode = "target_#{skill.target}"
            battle.text.show target_message[skill.target]
        else
            battle.target = battle.actor #if skill.target is \self
            battle.target = enemy_list(true) if skill.target is \enemies
            battle.target = ally_list! if skill.target is \allies
            use_skill!
    !function skill_menu
        args = []
        battle.skill_menu.objects = []
        for skill in battle.actor.skills
            battle.skill_menu.objects.push skill
            args.push skill.name
            args.push if battle.actor.stats.sp >= (access skill.sp)/100 then callback: choose_skill, arguments: [skill] else 0
        battle.skill_menu.set.apply battle.skill_menu, args
        battle.screen.nest battle.skill_menu, battle.summary
        battle.skill_menu.x = battle.actor.x
        battle.skill_menu |> setup_summary
        battle.skill_menu.on-change-selection!

    !function setup_summary (parentmenu)
        battle.summary.x = parentmenu.x + (parentmenu.w - 1)*WS
        battle.summary.text.x = 20
        if battle.summary.x + battle.summary.w*WS >= WIDTH
            battle.summary.x -= parentmenu.w*WS + (battle.summary.w - 2)*WS
            battle.summary.text.x = 8

    !function choose_item (item)
        battle.screen.kill!
        battle.item = item
        if item.target in <[ally enemy any]>
            battle.mode = "target_#{item.target}"
            battle.text.show target_message[item.target]
        else
            battle.target = battle.actor
            battle.target = enemy_list(true) if item.target is \enemies
            battle.target = ally_list! if item.target is \allies
            use_item!
    !function item_menu
        inventory = []
        for key, item of items
            inventory.push item if item.quantity > 0 and (item.use? or item.usebattle?)
        #sort
        inventory.sort (a,b)-> b.time - a.time
        args = [\Back -> @dontkill = true; battle.screen.back!]
        battle.item_menu.objects = [0]
        #dizzy=battle.actor.has_buff buffs.dizzy
        for item, i in inventory
            #break if i+1 >= battle.item_menu.buttons.length
            battle.item_menu.objects.push item
            #args.push [pad_item_name(item,null,2), item.sicon]
            args.push [pad_item_name4(item,16), {key:item.sicon, x:item.iconx, y:item.icony}]
            #if dizzy and item.nodizzy
            #    args.push 0
            #else
            args.push callback: choose_item, arguments: [item]
        for j from inventory.length+1 til battle.item_menu.buttons.length
            button = battle.item_menu.buttons[j]
            button.icon.kill!
        battle.item_menu.set.apply battle.item_menu, args
        battle.screen.nest battle.item_menu, battle.summary
        battle.item_menu.x = 0 >? battle.actor.x - WS <? WIDTH - battle.item_menu.w*WS
        battle.item_menu |> setup_summary
        battle.item_menu.on-change-selection!

    !function excel_menu
        actor = battle.actor
        options = [\Back -> battle.menu.back!]
        for key, forme of formes[battle.actor.name]
            continue if forme.stage is not actor.forme.stage+1 or not forme.unlocked
            options ++= [forme.name, [callback: actor.excel, arguments: [key], context: actor, end_turn]]
        @nest.apply @, options

    !function battle_charge
        battle.actor.stats.sp_level++
        end_turn!
    !function battle_wait
        battle.actor.stats.sp -= 1
        end_turn!

!function excel_count actor=battle.actor
    count = 0
    for key, forme of formes[actor.name]
        count++ if forme.stage is actor.forme.stage+1 and forme.unlocked
    return count

const target_message = 
    enemy:'Select an Enemy'
    ally:'Select an Ally'
    any:'Select a Target'

battle_mixin =
    level: 1
    xpwell: 100
    xpwell_max: 100
    stats:
        hp: 1
        hp_max: 20
        hp_base: 100
        def: 20
        def_base: 100
        atk: 20
        atk_base: 100
        luck_base: 100
        luck: 100
        speed: 50
        speed_base: 100
        sp: 0
        sp_level: 1
        Sp_limit: 1
    dead: false
    damage: (damage=0, showtext=false, source=null)!->
        damage is NaN and damage=0
        this_undying = undying this
        return if @stats.hp<=0 and not this_undying
        #heal block
        if damage<0 and buff=@has_buff buffs.healblock
            if buff.inflictor and not buff.inflictor.has_buff buffs.healblock
                buff.inflictor.damage damage/2, showtext, @
            damage=0
        #item and buffs damage trigger
        @call_buffs !-> damage:= @ondamage damage, source
        maxhp = @get_stat \hp
        if source instanceof Battler
            source.reward_xp Math.abs(damage/maxhp)*100, this
            #source.reward_ex Math.abs(damage/maxhp)*100
        #if this instanceof Battler
        #    @reward_ex Math.abs(damage/maxhp)*100
        if battle.critical
            damage*=2 
        if battle.critical and showtext
            if this instanceof Battler
                Transition.critical(0.01,100,@x+@w*HWS,@y+@h*HWS)
            else
                Transition.critical(0.01,100,@x,@y)
        @stats.hp -= damage / maxhp
        @stats.hp = 0 >? @stats.hp <? 1
        if showtext
            @floating-text.scale.set if battle.critical then 2 else 1
            if damage < 0 then @show_text "+#{-Math.floor damage}", 'font_green'
            else @show_text "-#{Math.floor damage}", 'font_red'
        if @stats.hp is 0 and source instanceof Battler and not this_undying
            #source.reward_xp_weighted @xpwell + @xpwell_max/4, @ #Killing blow reward
            source.reward_xp_weighted @xpwell + @xpkill, @ #Killing blow reward
            @xpwell = 0
        if @stats.hp is 0
            check_death!
    update_common_stats: !->
        @bars.hp.width = @stats.hp*@bars.length
        @bars.sp0.width = (@stats.sp<?1) *@bars.length
        @bars.sp1.width = (0>?@stats.sp-1<?1) *@bars.length
        @bars.sp2.width = (0>?@stats.sp-2<?1) *@bars.length
        @bars.sp3.width = (0>?@stats.sp-3<?1) *@bars.length
        if @has_buff buffs.obscure
            @bars.hp.width=@bars.sp0.width=@bars.sp2.width=@bars.sp3.width=0
    calc_stats: !->
        hp_ratio = @stats.hp || @base.stats.hp
        @stats.hp_max = new_calc_stat @level, @stats.hp_base
        #@stats.hp = (@get_stat \hp) * hp_ratio
        @stats.atk = new_calc_stat @level, @stats.atk_base
        @stats.def = new_calc_stat @level, @stats.def_base
        @stats.speed = calc_stat @level, @stats.speed_base, 2
        @stats.luck = calc_stat @level, @stats.luck_base, 6.1
    update_sp: (noupdate)!->
        if !noupdate
            @call_buffs \step
            @stats.sp += (1 - Math.pow(2, -0.05*(0.2 * @get_stat \speed)))*(delta/1000)*Math.pow(@stats.sp_level,0.1)
            if (excel_count @) > 0
                @stats.ex += delta/20000
                @stats.ex=1 if @stats.ex>1
            else if @forme and @forme.stage>0
                @stats.ex -= delta/20000
                if @stats.ex<0
                    @stats.ex=0
                    @excel \default
        if @stats.sp >= @stats.sp_level
            @stats.sp = @stats.sp_level
            return true
        return false
    sp_check: !->
        while (Math.ceil @stats.sp) < @stats.sp_level
            unless @stats.sp_level is 1
                @stats.sp_level--
            else
                break
    call_buffs: (callback, ...args)!->
        for buff in @buffs
            buff.remedy! if buff.inflictor and (buff.inflictor.dead or !buff.inflictor.alive)

        if typeof callback is \string then for buff in @buffs
            buff[callback].apply buff, args
        else if typeof callback is \function then for buff in @buffs
            callback.apply buff, args
    create_buffs: (x,y)!->
        @buffs = []
        for i from 0 til 5
            @buffs.push <| new Buff x+i*BS, y |> @.add-child

    inflict: (buff)!->
        return if buff.nostack and @has_buff buff
        for slot, key in @buffs
            if slot.name is \null
                slot.load_buff buff, battle.actor
                return slot

    remedy: (buff)!->
        for slot in @buffs
            if slot.name is buff.name
                slot.load_buff buffs.null

    has_buff: (buff)!->
        for slot in @buffs
            return slot if slot.name is buff.name
        return false

    get_stat: (key)!->
        buff_get_stat.gotten = [] if buff_get_stat.gotten.length > 0
        stat = @stats[if key is \hp then key+"_max" else key]
        @call_buffs !-> stat:= @["mod_#key"] stat
        return stat

    luckroll: luckroll

class Battler extends Window
    (x,y,@base)->
        super x,y,6,6
        @name = @base.name
        @displayname=speakers[@name]display
        implement @, battle_mixin

        @forme = formes[@name]default

        @stats.sp_limit = switches.sp_limit[@name] || 1
        @stats.xp = 0
        @stats.ex = 0
        @attributes=[]
            
        barlength = 86
        @bars= 
            length: barlength
            empty: @add-child new Phaser.TileSprite game, 5, 8, barlength, 40, 'bars', 1
            hp: @add-child new Phaser.TileSprite game, 5, 8, barlength, 10, 'bars', 2
            sp0: @add-child new Phaser.TileSprite game, 5, 18, 0, 10, 'bars', 4
            sp1: @add-child new Phaser.TileSprite game, 5, 18, 0, 10, 'bars', 5
            sp2: @add-child new Phaser.TileSprite game, 5, 18, 0, 10, 'bars', 6
            sp3: @add-child new Phaser.TileSprite game, 5, 18, 0, 10, 'bars', 7
            xp: @add-child new Phaser.TileSprite game, 5, 28, 0, 10, 'bars', 3
            ex: @add-child new Phaser.TileSprite game, 5, 28, 0, 10, 'bars', 8
        
        @port = @add-child new Phaser.Sprite game, 5, 5, get_costume @name, @forme, @base.costume
        @port.frame=get_costume @name, @forme, @base.costume, \bframe

        @text = @add-text null, "", 7, 10, null,null, 10
        @item = new Buff 5, @h*WS - BS, @base.equip |> @add-child
        @create_buffs  BS/2, @h*WS
        
        
        @stats.xp = @base.stats.xp
        @level = @base.level
        @startlevel = @level
        @import!
        @calc_stats!
        @calc_xp!
        @xpwell = (@stats.xp_next)*0.5
        @xpwell_max = @xpwell
        @xpkill = @xpwell/4
        @stats.hp = @base.stats.hp
        @update_stats!
        
        @nameplate = @add-text 'font_yellow', @displayname, 3*WS, 0
        @nameplate.anchor.set 0.5 1.0

        @floating-text = new Floating-Text! |> @add-child
        @floating-text.kill!

    calc_xp: !->
        levelup = false
        xp_cur = level-to-xp @level
        xp_next = level-to-xp @level+1
        if @stats.xp >= xp_next
            @level = xp-to-level @stats.xp
            @show_text "Level Up!", 'font_yellow'
            @calc_stats!
            xp_cur = level-to-xp @level
            xp_next = level-to-xp @level+1
            levelup = true
        @stats.xp_pro = @stats.xp - xp_cur
        @stats.xp_next = xp_next - xp_cur
        return levelup


    show_text: (text, font)!->
        @floating-text?show @w/2*WS, @h/2*WS, text, font

    reward_xp: (xp, source)!->
        return if !xp
        if source instanceof Array
            for s in source
                @reward_xp(xp,s)
            return
        #xp = @stats.xp_next * xp/100 * source.xpwell/source.xpwell_max <? source.xpwell
        xp = source.xpwell_max * xp/100 <? source.xpwell
        source.xpwell -= xp
        @reward_xp_weighted xp,source
    reward_xp_weighted: (xp,source)!->
        while xp>0
            diff=Math.max(@level - source.level, 0) #for xp scaling
            xpo=xp
            xp_need = @stats.xp_next - @stats.xp_pro
            xp *= Math.pow 9/11,diff
            xpr = Math.min(xp, xp_need)
            #Share xp with lower level heroes
            if @level > source.level
                xpor = (xpo - xp)*xpr/xp
                xpshare=[]
                lowestlevel=@level
                for h in heroes
                    continue if h.dead
                    if h.level < lowestlevel
                        lowestlevel=h.level
                        xpshare.length=0
                    if h.level is lowestlevel and lowestlevel < @level
                        xpshare.push h
                if xpshare.length>0
                    for h in xpshare
                        h.reward_xp_raw xpor/xpshare.length
            #
            @reward_xp_raw(xpr)
            xp -= xpr
            xp *= Math.pow 11/9,diff
    reward_xp_raw: (xp)!->
        @stats.xp += xp
        switches.gxp += xp*0.3
        if (excel_count @) > 0
            @stats.ex += xp*1.5/@stats.xp_next
        #@show_text "#xp XP", 'font_yellow'
        if @calc_xp! #levelup
            battle.critical = true
        @update_stats!

    reward_ex: (ex)!-> #deprecated
        return unless ex? and @excel_unlocked!
        @stats.ex += ex/100
        if @stats.ex <= 0
            @stats.ex=0
            @excel \default 0


    excel: (forme, spcost=0)!->
        @forme = formes[@name][forme]
        @port.load-texture get_costume @name, @forme, @base.costume
        @port.frame=get_costume @name, @forme, @base.costume, \bframe
        @stats.sp -= spcost
        @sp_check!
        @import!
        @calc_stats!

    excel_unlocked: Player::excel_unlocked

    pre-update: !->
        super ...
        @floating-text.pre-update!

    update: !->
        @y = if /* battle.mode is \command and */ @ is battle.actor then 136 else 144
        
    update_stats: !->
        excel = @excel_unlocked!
        hp_max = @get_stat \hp
        if @has_buff buffs.obscure
            lines=["???", "???", "???"]
        else
            lines=
                hpstattext @stats.hp*hp_max, hp_max, 5
                (Math.floor @stats.sp*100)+"%"
                (Math.floor @stats.ex*100)+"%"
        text ="""HP:#{lines.0}
                 SP:#{lines.1}"""
        text += if excel then "\nEX:#{lines.2}" else ''
        text += "\nLevel #{@level}"
        @text.change text
        @update_common_stats!
        @bars.xp.width = @stats.xp_pro/@stats.xp_next*@bars.length
        @bars.xp.y = if excel then 38 else 28
        @bars.empty.height = if excel then 40 else 30
        @bars.ex.width = if excel then (@stats.ex<?1)*@bars.length else 0

    call_buffs: (callback, ...args)!->
        battle_mixin.call_buffs ...
        if typeof callback is \string then @item[callback].apply @item, args
        else if typeof callback is \function then callback.apply @item, args

    import: !->
        @stats.hp_base = @forme.hp
        @stats.def_base = @forme.def
        @stats.atk_base = @forme.atk
        @stats.speed_base = @forme.speed
        @stats.luck_base = @forme.luck
        @skills = @base.skills[@forme.id]

    export: (e_hp=true, e_xp=true)!->
        @base.stats.hp = @stats.hp if e_hp
        @base.stats.xp = @stats.xp if e_xp
        @base.level = @level if e_xp

    death: !->
        @update_stats!
        @dead = true
        @port.kill!
    resurrect: !->
        @dead = false
        @port.revive!
        @stats.hp = @stats.hp_max

class Status-Card extends Window
    (x,y,@base)->
        super x,y,6,5
        @name = @base.name
        #implement @, battle_mixin
        @forme = formes[@name]default
        @stats = clone battle_mixin.stats

        barlength = 86
        @bars= 
            length: barlength
            empty: @add-child new Phaser.TileSprite game, 5, 8, barlength, 20, 'bars', 1
            hp: @add-child new Phaser.TileSprite game, 5, 8, barlength, 10, 'bars', 2
            xp: @add-child new Phaser.TileSprite game, 5, 18, 0, 10, 'bars', 3
        @port = @add-child new Phaser.Sprite game, 5, 5-WS, get_costume @name, 0, @base.costume
        @port.frame=get_costume @name, 0, @base.costume, \bframe
        @item = new Buff 5, @h*WS - BS, @base.equip |> @add-child
        @text = @add-text null, "", 7, 10, null,null, 10
        @hptext = @add-text \font_gray, '', WS*3+FW, 10
        #@nameplate = @add-text 'font_yellow', speakers[@name]display, 8, 5*WS-5
        #@nameplate.anchor.set 0 1.0

        @import!
        @calc_stats!
        @update_stats!

    update_stats: !->
        hp_max = @get_stat \hp
        text ="""HP:#{if pause_screen.windows.0.item then stattext hp_max, 5 else hpstattext @stats.hp*hp_max, hp_max, 5}
                Level #{@level}"""
        @text.change text
        @bars.hp.width = @stats.hp*@bars.length
        @bars.xp.width = @stats.xp_pro/@stats.xp_next*@bars.length

    calc_stats: !->
        @level = @base.level
        /*
        @stats.hp_max = new_calc_stat @level, formes[@name]default.hp
        @stats.hp = (@get_stat \hp) * @base.stats.hp
        */
        @stats.hp = @base.stats.hp
        @stats.xp = @base.stats.xp
        xp_cur = level-to-xp @level
        xp_next = level-to-xp @level+1
        @stats.xp_pro = @stats.xp - xp_cur
        @stats.xp_next = xp_next - xp_cur

        battle_mixin.calc_stats ...

        @item.load_buff @base.equip
        @port.load-texture get_costume @name, 0, @base.costume
        @port.frame=get_costume @name, 0, @base.costume, \bframe


    import: Battler::import

    get_stat: battle_mixin.get_stat
    call_buffs: (callback, ...args)!->
        if typeof callback is \string then @item[callback].apply @item, args
        else if typeof callback is \function then callback.apply @item, args

class Monster extends Phaser.Sprite
    (x,y,id,level=1)->
        @monstertype = type = Monster.types[id] or Monster.types.sanishark
        super game,x,y, type.key
        implement @, battle_mixin
        @displayname=type.name

        @anchor.set Math.round(@width*0.5)/@width, 1

        @level = level
        xpwell_base=type.xpwell or type.xp or 0
        xpkill_base=type.xpkill or type.xp/4 or 0
        @xpwell = (xp_needed @level) * xpwell_base*2/300
        @xpwell_max = @xpwell
        @xpkill = (xp_needed @level) * xpkill_base*2/300

        #xp_cur = level-to-xp @level
        #xp_next = level-to-xp @level+1
        #@stats.xp_next = xp_next - xp_cur

        #stats
        @stats.hp_base = type.hp || 100
        @stats.def_base = type.def || 100
        @stats.atk_base = type.atk || 100
        @stats.speed_base = type.speed || 100
        @stats.luck_base = type.luck || 100
        @skills=type.skills
        @attributes = type.attributes || []

        @drops=access type.drops

        @floating-text = new Floating-Text! |> @add-child
        @floating-text.kill!
        
        x = - Math.floor @width/2
        y = 0
        @bars= 
            length: @width
            empty: @add-child new Phaser.TileSprite game, x,y, @width, 20, 'bars', 0
            hp: @add-child new Phaser.TileSprite game, x,y, @width, 10, 'bars', 2
            sp0: @add-child new Phaser.TileSprite game, x,y+10, 0, 10, 'bars', 4
            sp1: @add-child new Phaser.TileSprite game, x,y+10, 0, 10, 'bars', 5
            sp2: @add-child new Phaser.TileSprite game, x,y+10, 0, 10, 'bars', 6
            sp3: @add-child new Phaser.TileSprite game, x,y+10, 0, 10, 'bars', 7
        
        @text = @add-child new Text null, "", x+1, y+1

        @item = new Buff x - IS/2, 0, buffs.null |> @add-child
        @create_buffs -BS*2.5,y

        @calc_stats!
        @update_stats!

        @monstertype.start?call this

        @animData = Monster.animData[@monstertype.key] || {}
        @animations.add \anim, @animData.frames, access.call(@,@animData.speed)||7, true
        @animate!
        
    animate: !->
        @animations.play \anim
        @animations.currentAnim._frameIndex = Math.floor Math.random!*@animations.currentAnim.frameTotal


    damage: undefined # replace with battle mixin

    update: !->
        if typeof @animData.getFrame is \function
            @animations.frame = @animData.getFrame.call @

    pre-update: !->
        super ...
        @floating-text.pre-update!

    show_text: (text, font)!->
            @floating-text.show 0, -BS, text, font
        
    update_stats: !->
        if @has_buff buffs.obscure
            lines=["???", "???"]
        else
            lines=
                (Math.ceil @stats.hp*100)+"%"
                (Math.floor @stats.sp*100)+"%"
        @text.change """HP:#{lines.0}
                        SP:#{lines.1}"""
        @update_common_stats!

    target: !->
        return battle.target=this if battle.skill.target is \self
        return battle.target=enemy_list(true) if battle.skill.target is \enemies
        return battle.target=ally_list! if battle.skill.target is \allies
        list = target_list!
        return battle.target = list[Math.floor Math.random!*list.length]

    attack: !->
        battle.actor = @
        if @plan_skill
            battle.skill=@plan_skill
            @plan_skill=null
        else unless @monstertype.ai? and (battle.skill = @monstertype.ai.call this)
            skilllist = []
            for skill in @skills
                for from 1 to skill.weight || 5
                    skilllist.push skill
            battle.skill = skilllist[Math.floor Math.random!*skilllist.length]
        
        # charge sp
        if battle.skill.sp > @stats.sp*100
            @plan_skill=battle.skill
            @stats.sp_level+=1
            return end_turn!

        if battle.skill.aitarget? then that! else @target!
        use_skill!

    death: !->
        @dead = true
        if @drops
            for drop in @drops
                item = items[drop.item]
                if item.unique
                    continue if item.quantity>0
                    continue if battle.drops[drop.item]
                #if Math.random!*100<drop.chance
                if (typeof drop.condition is not \function or drop.condition!) 
                and item.condition! 
                and 100-pluckroll_battle!*100<(drop.chance*[1,1.5,2][battle.encounter.toughness])
                    quantity = Math.round drop.quantity*[1,2,4][battle.encounter.toughness]
                    quantity = 1 if item.unique
                    if battle.drops[drop.item]
                        battle.drops[drop.item].q+=quantity
                    else
                        battle.drops[drop.item]={item:items[drop.item],q:quantity}
        @monstertype.ondeath.call @ if typeof @monstertype.ondeath is \function
        @destroy!

    destroy: !->
        index = monsters.index-of @
        monsters.splice index, 1 if index > -1
        super ...

!function drop_item (item, q=1)
    return if game.state.current isnt \battle
    if battle.drops[item]
        battle.drops[item].q+=q
    else
        battle.drops[item]={item:items[item],q:q}

class Animation extends Phaser.Sprite
    ->
        super game, 0,0, 'anim_slash'
        for key, anim of animations
            @animations.add key, anim.frames, if anim.speed then that else 20, false
        @anchor.set 0.5
        @kill!
        @events.on-animation-complete.add @animation-complete, @
    animation-complete: !->
        process_callbacks.call @, @callback
        @kill!
    play: (animation='slash',@x,@y,t=battle.target)!->
        if t instanceof Battler
            @x += t.w/2*WS
            @y += t.h/2*WS
        else if t instanceof Monster
            @y -= t.height/2
        else if !x? or !y?
            targeter = battle.skill || battle.item
            @x=HWIDTH
            if targeter.target in <[enemies allies]>
                side=1
                side*=-1 if battle.actor instanceof Monster
                side*=-1 if targeter.target is \enemies
                if side<0 then @y=80 else @y=192
        anim = animations[animation]
        #battle.mode = \action
        @revive!
        @anchor.set.apply @anchor, if anim.anchor? then (if anim.anchor instanceof Array then anim.anchor else [anim.anchor]) else [0.5]
        @load-texture anim.sprite
        @animations.play animation
    callback: !->

class Buff extends Phaser.Sprite
    (x,y,buff=buffs.null)->
        super game, x, y, access buff.icon
        @anchor.set 0 1
        @load_buff buff
        @get_stat = buff_get_stat
    load_buff: (buff=buffs.null,inflictor)!->
        @inflictor = if inflictor then inflictor else if game.state.current is \battle then battle.actor else null
        @onremedy?!
        @base=buff
        if @parent?has_buff? buffs.obscure
            if @key isnt \buffs then @load-texture \buffs
            @frame=2
            setrow @, 4
        else
            icon = (access buff.icon) or \buffs
            if icon is not @key then @load-texture icon
            @frame=buff.iconx or 0
            setrow @, (buff.icony or 0)
        @name = buff.name || 'null'
        @id = buff.id || 'null'
        @negative = buff.negative || false
        for key in <[step attack battle_end start end turn onremedy]>
            @[key] = if buff[key]? then that else !->
        for key in <[ondamage mod_hp mod_def mod_atk mod_speed mod_luck]>
            @[key] = if buff[key]? then that else (s)->s
        @attributes = buff.attributes or []
        @skill = buff.skill or null
        @revive!
        @start!
    remedy: !->
        @load_buff buffs.null
    damage: (n)!->
        return unless @inflictor
        #@parent.damage (@inflictor.get_stat \atk)*n / (20*@parent.get_stat \def), false, @inflictor
        @parent.damage (calc_damage @inflictor, @parent, n), false, @inflictor
    kill: !->
        ret=super ...
        if @parent?has_buff? buffs.obscure
            @visible=true
        return ret

!function buff_get_stat (key)
    stat = @parent.stats[if key is \hp then key+"_max" else key]
    return stat if key in buff_get_stat.gotten
    buff_get_stat.gotten.push key
    @parent.call_buffs !-> stat:= @["mod_#key"] stat
    return stat

buff_get_stat.gotten = []

#========================================
# Buffs
#----------------------------------------

buffs = {}
buffs.null =
    name: 'null'
    #icon: 'buff_skull'
    start: !->
        @kill!

buffs.poison =
    name: 'poison'
    #icon: 'buff_skull'
    start: !->
        @temporal=@inflictor instanceof Battler
        @duration=if \poison in @parent.attributes then 1 else 5
    step: !->
        #@parent.damage @parent.stats.hp_max / 20 * deltam
        @damage 20*deltam
        @duration -= deltam if @temporal
        @remedy! if @duration<=0
    negative: true
    attributes:<[disease]>

buffs.regen =
    name: 'regen'
    #icon: 'buff_recover'
    iconx: 3
    start: !->
        @duration=10
    step: !->
        @duration -= deltam
        heal_percent @parent, 0.05*deltam, false
        #@parent.damage @parent.stats.hp_max / 10 * deltam
        #@damage 50*deltam
        @remedy! if @duration<=0
    negative: false

buffs.healblock =
    name: 'healblock'
    iconx:2
    icony:3
    negative: true
    start: !-> @duration=5
    step: !->
        @duration -= deltam
        @remedy! if @duration<=0
    nostack:true
    attributes:<[curse]>

buffs.isolated =
    name: 'isolated'
    iconx:3
    icony:3
    negative:true
    mod_speed: (s)->s*0.9
    start: !-> @duration=5
    step: !->
        @duration -= deltam
        @remedy! if @duration<=0
    nostack:true
    attributes:<[curse]>

buffs.bloodboost =
    name:'bloodboost'
    iconx:1
    icony:3
    mod_atk: (s)->
        bleedcount=0
        for buff in @parent.buffs then bleedcount++ if buff.name is \bleed
        return s+s*0.1*bleedcount
    mod_speed: (s)->
        bleedcount=0
        for buff in @parent.buffs then bleedcount++ if buff.name is \bleed
        return s+s*bleedcount

buffs.bleed =
    name: 'bleed'
    #icon: 'buff_blood'
    iconx: 2
    start: !->
        @duration=2
        @severity=if @inflictor instanceof Battler and @parent instanceof Battler then 20 else 50
        @extended=false
    step: !->
        @duration -= deltam
        #@parent.damage @parent.stats.hp_max / 10 * deltam
        @damage @severity*deltam #*(if @parent.attributes? and \blood in @parent.attributes then -1 else 1)
        @remedy! if @duration<=0
    negative: true
    attributes:<[disease]>

buffs.coagulate =
    name: 'coagulate'
    #icon: 'buff_scab'
    icony: 2
    negative: true
    #start: !-> @duration=10
    #step: !->
        #@duration -= deltam
        #@remedy! if @duration<=0
    mod_speed: (s)->s*0.95
    attributes:<[disease]>

buffs.charmed =
    name: 'charmed'
    #icon: 'buff_lips'
    iconx: 1
    mod_atk: (s)->s*0.85
    mod_def: (s)->s*0.90
    mod_speed: (s)->s*0.98
    negative: true
    nostack: true
    attributes:<[curse]>

buffs.decoy =
    name: 'decoy'
    iconx:5
    icony:3
    nostack:true

buffs.weak =
    name: 'weak'
    #icon: 'buff_weak'
    iconx: 5
    mod_atk: (s)->s*0.75
    mod_def: (s)->s*0.75
    negative: true
    nostack: true

buffs.wanko =
    name: 'wanko'
    iconx: 1
    icony: 4
    mod_atk: (s)->s*1.2
    #mod_def: (s)->s*1.2
    mod_speed: (s)->s*1.2
    mod_luck: (s)->s*1.2
    #mod_hp: (s)->s*1.2

buffs.seizure =
    name: 'seizure'
    #icon: 'buff_seizure'
    iconx: 2
    icony: 2
    start: !->
        @duration=2
    step: !->
        @duration -= deltam
        @remedy! if @duration<=0
        @parent.stats.sp += ((Math.random!*3.|.0)-1)*deltam
    mod_speed: (s)->s*0.1
    negative: true
    nostack: true
    attributes:<[disease]>

buffs.burn =
    name: 'burn'
    #icon: 'buff_burn3'
    iconx: 2
    icony: 1
    start: !->
        @intensity=3
        for buff in @parent.buffs
            if buff.name is \burn and buff.intensity<2
                buff.intensity=2
                buff.duration=2
                buff.frame=1
        for buff in @parent.buffs
            if buff.name is \chill
                buff.remedy!
                break
        @duration=1
        @temporal=@inflictor instanceof Battler
        @plant=\plant in @parent.attributes
        @supereffective= @plant or \fish in @parent.attributes or (@parent.item and @parent.item.base is items.woodshield)
        @temporal=false if @supereffective
    #mod_def: (s)->s/(1+@supereffective)
    mod_def: (s)->s/(1+@plant)
    step: !->
        #@parent.damage @parent.stats.hp_max / 20 * deltam
        @duration -= deltam if @temporal or @intensity>1
        if @duration<=0
            @intensity--
            @duration=4-@intensity
            if @intensity<=0
                #if @temporal then @remedy! else @intensity=1
                @remedy!
            else
                #@load-texture "buff_burn"+@intensity
                @frame = @intensity - 1
        @damage 10*deltam*@intensity*(1+@supereffective)
    #attack: !->
    #    @parent.damage 10 #Placeholder effect
    negative: true

buffs.blister =
    name: 'blister'
    #icon: 'buff_blister'
    iconx: 1
    icony: 2
    step: !->
        @parent.damage @parent.stats.hp_max / 20 * deltam
    attack: !->
        @parent.damage 10 #Placeholder effect
    negative: true
    attributes:<[disease]>

buffs.drown =
    name: 'drown'
    iconx: 5
    icony: 2
    start: !->
        @duration=2
        for buff in @parent.buffs
            continue if buff is this
            buff.load_buff buffs.chill if buff.name is \drown
    step: !->
        @duration -= deltam
        @damage 50*deltam 
        if @duration<=0
            #@remedy! 
            @load_buff buffs.chill
    mod_speed: (s)->0
    negative: true

buffs.licked =
    name: 'licked'
    iconx: 5
    icony: 2
    start: !->
        @duration=2
    step: !->
        @duration -= deltam
        if @duration<=0
            @remedy!
    mod_speed: (s)->0
    negative: true

buffs.chill =
    name: 'chill'
    #icon: 'buff_chill'
    iconx: 4
    icony: 2
    start: !->
        @severity=if @inflictor instanceof Battler then 0.85 else 0.65
        @duration = if @inflictor instanceof Battler then 10 else Infinity
        chillcount=0
        burncount=0
        for buff in @parent.buffs
            chillcount++ if buff.name is \chill
            if buff.name is \burn
                buff.intensity -= 1
                buff.duration=4-buff.intensity
                if buff.intensity<=0 then buff.remedy!
                else
                    buff.frame = buff.intensity - 1
                    burncount++
        if chillcount == 5 and @parent instanceof Battler then @parent.damage @parent.stats.hp_max
        if burncount>0 then @remedy!
    mod_speed: (s)-> s*@severity
    step: !->
        @duration -= deltam
        @remedy! if @duration<=0
    #lower speed
    negative: true

buffs.slow =
    name: 'slow'
    iconx: 5
    icony: 4
    start: !->
        @severity=if @inflictor instanceof Battler then 0.85 else 0.65
    mod_speed: (s)-> s*@severity
    nostack: true
    negative: true
    attributes:<[curse]>

buffs.curse =
    name: 'curse'
    #icon: 'buff_weak'
    iconx: 5
    start: !->
        @severity=if @inflictor instanceof Battler then 0.75 else 0.5
    mod_hp: (s)->s*@severity
    negative: true
    nostack: true
    attributes:<[curse]>

buffs.fever =
    name: 'fever'
    #icon: 'buff_fever'
    iconx: 4
    icony: 1
    mod_speed: (s)-> s*1.1
    #raise effectiveness of fire moves. Lower effectiveness of non-fire moves.
    negative: false
    attributes:<[disease]>

buffs.speed =
    name: 'speed'
    #icon: 'buff_wing'
    iconx: 4
    mod_speed: (s)-> s*2
    negative: false
    start: !->
        @duration=4
    step: !->
        @duration -= deltam
        @remedy! if @duration<=0

buffs.aids =
    name: 'aids'
    #icon: 'buff_shieldbreak'
    iconx: 3
    icony: 2
    mod_def: (s)->s/3
    negative: true
    #nostack: true
    attributes:<[disease]>

buffs.twinflight =
    name: 'twinflight'
    iconx: 4
    mod_speed: (s)->
        return s if @inflictor.has_buff buffs.twinflight
        return @inflictor.get_stat \speed
    start: !->
        @duration=4
    step: !->
        @duration -= deltam
        @remedy! if @duration<=0

buffs.sabotage =
    name: 'sabotage'
    icony: 4
    mod_atk: (s)->s/2
    start: !->
        @duration=1.5
    step: !->
        @duration -= deltam
        if @duration<=0
            @remedy! 
    negative: true
    nostack: true
    attributes:<[curse]>

buffs.baited =
    name: 'baited'
    icon: \item_misc
    iconx: 1
    icony: 1
    start: !->
        @duration=2
    step: !->
        @duration -= deltam
        if @duration<=0
            @remedy! 
    mod_speed: (s)->0
    negative: true

buffs.dizzy =
    name: 'dizzy'
    icony: 3
    start: !-> @duration=2
    step: !->
        @duration -= deltam
        if @duration<=0
            @remedy!
    negative: true

buffs.dazed =
    name: 'dazed'
    icony: 3
    start: !-> @duration=1
    step: !->
        @duration -= deltam
        if @duration<=0
            @remedy!
    mod_speed: (s)-> s/2
    negative: true

buffs.swarm =
    name: 'swarm'
    iconx: 3
    icony: 4
    start: !->
        @duration=1
    step: !->
        @duration -= deltam
        @damage 20*deltam
        if @duration<=0
            return if @parent.has_buff buffs.isolated
            jumplist = if @parent instanceof Battler then hero_list! else monster_list!
            jumplist2=[]
            for battler in jumplist
                continue if battler.has_buff buffs.isolated
                or !battler.has_buff buffs.null
                jumplist2.push battler
            return unless jumplist2.length
            @remedy!
            jumplist2[Math.random!*jumplist2.length.|.0].inflict buffs.swarm
    negative: true
    attributes:<[disease]>

buffs.swarmdrain =
    name: 'swarmdrain'
    iconx: 4
    icony: 4
    start: !->
        @duration=3
    step: !->
        @duration -= deltam
        enemylist = if @parent instanceof Battler then monster_list! else hero_list!
        for battler in enemylist
            for buff in battler.buffs
                @damage -10*deltam if buff.name is \swarm
        @remedy! if @duration<=0

buffs.obscure =
    name: 'obscure'
    iconx: 2
    icony: 4
    start: !->
        @duration=6
        for buff in @parent.buffs
            buff.visible=true
            if buff.key isnt \buffs then buff.load-texture \buffs
            buff.frame=2
            setrow buff, 4
    onremedy: !->
        for buff in @parent.buffs
            buff.visible=false if buff.base is buffs.null
            icon = (access buff.base.icon) or \buffs
            if icon is not buff.key then buff.load-texture icon
            buff.frame=buff.base.iconx or 0
            setrow buff, (buff.base.icony or 0)
    step: !->
        @duration -= deltam
        @remedy! if @duration<=0
    #hides the inflicted's health, sp, buffs, and item.

nodes={}
doodads={}
class Doodad extends Phaser.Sprite
    (x,y,key='empty',name,collide=true)->
        #@isdoodad=true
        if not switches.soulcluster and (getmapdata \hasnight)
            switch key
            |\1x1 => key=\1x1_night
            |\1x2 => key=\1x2_night
        super game, x, y, key
        if name
            @name = name
            doodads[name] = @
        if collide
            game.physics.arcade.enable @, false
            @body.set-size TS, TS if not key
        @@list.push @
        #@overrideplay=@animations.play
        #@animations.play=!->
        #    @sprite.isdoodad=false
        #    @sprite.overrideplay ...
    simple_animation: (speed=7,loops)!->
        @animations.add \simple, null, speed, true
        @animations.play \simple, null, loops
    random_frame: !-> @animations.currentAnim.setFrame Math.random!*@animations.currentAnim.frameTotal.|.0 true
    @list = []
    @clear = !->
        nodes := {}
        doodads := {}
        for item in @@list
            item.destroy!
        @@list = []
    destroy: !->
        super ...
        updatelist.remove @

class Treasure extends Actor
    (x,y,name,@item,@quantity,@mimic=false,properties={})->
        super x,y,\1x1
        @name = name
        @toughness=properties.toughness
        @@list.push @
    interact: !->
        if @mimic
            temp.mimic=item:@item,quantity:@quantity,name:@name
            start_battle encounter.mimic, @toughness
            return
        #switches['treasure_'+@name] = true
        switches[@name]=true
        acquire items[@item], @quantity
        @destroy!
    @list = []
    @clear = !->
        for item in @@list
            item.destroy!
        @@list = []


class Trigger extends Phaser.Sprite
    (x,y,w,h,ow,oh)->
        super game,x,y,'empty'
        game.physics.arcade.enable @, false
        @body.set-size w,h,ow,oh
        @body.immovable = true
        #@preUpdate!
        @@list.push @
    @list = []
    @clear = !-> for item in @@list
        item.destroy!

    process: !->
    handle: !->

!function initUpdate(o)
    o.preUpdate!
    o.postUpdate!

# Holidays
holiday = {}
## FOR FINAL GAME
holiday.now = new Date!
## FOR HALLOWEEN DEMO
#holiday.now=new Date "October 31 2016"
##

holiday.month = holiday.now.get-month! + 1
holiday.date = holiday.now.getDate!
holiday.easter = holiday.month is 3 and holiday.date>=22 or holiday.month is 4 and holiday.date<=25
holiday.halloween = holiday.month is 10
holiday.turkey = holiday.month is 11
holiday.christmas = holiday.month is 12

!function map_objects
    flower_count=0
    oil_count=0
    treasure_count=0
    mimic_count=0
    goop_count=0

    for o in map.object_cache
        object = x:o.x.|.0, y:o.y - TS.|.0, type:o.type, name:o.name, properties:o.properties, width:o.width, height:o.height
        switch object.type
        case \npc
            create_npc object, object.name
            nodes[object.name] = object
        case \flame
            continue unless require_switch object
            dood = new Doodad(object.x+HTS, object.y+TS, \flame null false) |> actors.add-child
            dood.anchor.set 0.5 1.0
            dood.simple_animation 7
            dood.random_frame!
            updatelist.push dood
        case \boat
            dood = new Doodad(object.x+HTS,object.y+TS, \boat null true) |> actors.add-child
            dood.anchor.set 0.5 1.0
            dood.body.set-size TS*2, TS
            initUpdate dood
            Doodad.boat=dood
        case \pest
            dood = new Doodad object.x+HTS, object.y+TS, \pest, null, false |> carpet.add-child
            dood.anchor.set 0.5 1.0
            #dood.frame = 0+(if switches.soulcluster then 0 else 2)+(if switches.beat_game then 1 else 0)
            dood.frame = if switches.soulcluster then 0 else 2
        case \anim 
            dood = new Doodad(object.x+HTS, object.y+TS, object.name, null, object.properties.block) |> actors.add-child
            dood.anchor.set 0.5 1.0
            dood.simple_animation object.properties.speed ? 5
            dood.random_frame!
            dood.body.set-size +(object.properties.xsize ? HTS), +(object.properties.ysize ? HTS)
            dood.scale.x=-1 if object.properties.flip?
            updatelist.push dood
        case \player_start \node
            nodes[object.name] = object
        case \checkpoint
            continue unless require_switch object
            nodes[object.name] = object
            check = new Doodad(object.x, object.y, \pent, object.name) |> carpet.add-child
            trig = new Trigger(object.x, object.y, TS, TS, 0 0,) |> triggers.add-child
            check.flame = trig.flame = new Doodad(0 0 \pent_fire null false) |> check.add-child
            #check.isdoodad=false
            updatelist.push check
            trig.flame.simple_animation 7
            check.anchor.set 0.25
            trig.flame.anchor.set 0.25
            trig.name = check.name = object.name
            trig.process=!->
                fullhealth = true
                for p in party
                    fullhealth = false if p.stats.hp < 1
                return !(switches.map is switches.checkpoint_map
                and switches.checkpoint is @name
                and fullhealth)
            trig.handle=!->
                for p in party
                    p.stats.hp = 1
                    #p.revive!
                    p.relocate player
                    Dust.summon p
                for key, doodad of doodads
                    doodad.flame.visible = false if doodad.key is \pent
                switches.checkpoint_map = switches.map
                switches.checkpoint = @name
                switches["visited_#{switches.map}_#{@name}"] = true
                save!
                @flame.visible = true
                sound.play \candle
            trig.flame.visible = not trig.process!
            trig.flame.visible = true if switches.defeated && switches.checkpoint==object.name && switches.checkpoint_map==switches.map
        case \portal
            nodes[object.name] = object
            portal = new Trigger(object.x,object.y,10,10,3,3) |> triggers.add-child
            #portal.preUpdate!
            initUpdate portal
            portal.name = object.name
            portal.isportal = true
            for key in <[pdir pmap pport item_lock switch_lock lock_scenario sfx]>
                portal[key] = object.properties[key]
            portal.handle=!->
                if @item_lock and !items[@item_lock].quantity
                or @switch_lock and !switches[@switch_lock]
                    scenario[@lock_scenario]! if @lock_scenario
                    return 
                player.cancel_movement!
                Transition.fade 300 0 -> schedule_teleport @
                , null 5 true @
                if @sfx then sound.play @sfx
        case \nospawn
            spawn_controller.nospawn.push object
        case \spawn
            spawn_controller.spawners.push object
        case \sign
            continue unless require_switch object
            (create_doodad object, carpet).interact=!->
                if @properties.message
                    say '' tl(@properties.message)
                else if @properties.scenario
                    scenario[@properties.scenario]!
        case \carpet
            create_doodad object, carpet
        case \trigger 
            new Trigger(object.x, object.y, TS, TS, 0, 0)
        case \scenario
            continue unless require_switch object
            nodes[object.name] = object
            trig = new Trigger(object.x, object.y, TS, TS, 0, 0) |> triggers.add-child
            trig.name = object.name
            trig.condition = object.properties.condition
            if object.properties.width
                trig.body.width=object.properties.width*TS
            if object.properties.height
                trig.body.height=object.properties.height*TS
            initUpdate trig
            trig.properties=object.properties
            trig.process=!->
                return not switches[@name] and (!@condition or !!switches[@condition])
            trig.handle=!->
                scenario[@name]!
                setswitch @name, true, @properties.nosave unless @properties.dontswitch?
        case \flower
            if Date.now! - switches["flower_#{switches.map}_#{flower_count}"] < 43200000
                flower_count++
            else
                delete! switches["flower_#{switches.map}_#{flower_count}"]
                create_tree object, object.properties.sheet ?\1x1, object.properties.frame ?8, true, \flower
        case \oil 
            if Date.now! - switches["oil_#{switches.map}_#{oil_count}"] < 43200000
                create_tree object, \1x1, 14, true, \oil_empty
            else
                delete! switches["oil_#{switches.map}_#{oil_count}"]
                create_tree object, \1x1, 15, true, \oil
        case \tree
            create_tree object, object.properties.sheet ?\1x2, object.properties.frame ?2, true, true
        case \tree2
            create_tree object, object.properties.sheet ?\1x2, object.properties.frame ?2, true, false
        case \foliage
            create_tree object, object.properties.sheet ?\1x2, object.properties.frame ?3, false
        case \fringe
            dood=create_fringe object, object.properties.sheet ?\2x2, object.properties.frame ?0
            #dood.kill!
        case \pylon
            create_tree object, \1x2, if object.name is \pylon2 and switches.sleepytime and not switches.pylonfixed then 1 else 0, true
        case \falsewall
            dood = new Doodad object.x, object.y+TS, object.properties.sheet, null, true |> actors.add-child
            if object.properties.frame?
                dood.frame = +object.properties.frame
            else if object.properties.frame_x? and object.properties.frame_y?
                dood.crop new Phaser.Rectangle TS*object.properties.frame_x, TS*object.properties.frame_y, TS,TS
            dood.x+=dood.width/2
            dood.anchor.set 0.5 1.0
            dood.body?set-size TS, TS
            #dood.preUpdate!
            initUpdate dood
            dood.falsewall=object.properties.on_switch or object.properties.off_switch
            #if switches[object.properties.require_switch] then dood.revive! else dood.kill!
            dood.properties=object.properties
            if switches[object.properties.on_switch] or (!object.properties.on_switch? and !switches[object.properties.off_switch]) then dood.revive! else dood.kill!
            if switches[object.properties.on_switch] and switches[object.properties.off_switch] then dood.kill!
        case \switch
            #dood = create_doodad object, carpet
            dood = create_tree object, object.properties.sheet, 0, true
            dood.properties=object.properties
            dood.frame=if switches[object.properties.switch] then +object.properties.frame2 else +object.properties.frame
            dood.body.set-size +(object.properties.xsize ? HTS), +(object.properties.ysize ? HTS)
            dood.interact=!->
                sound.play 'candle'
                state=switches[@properties.switch]=!switches[@properties.switch]
                save!
                @frame=if state then +@properties.frame2 else +@properties.frame
                for actor in actors.children
                    if actor.falsewall
                        if switches[actor.properties.on_switch] or (!actor.properties.on_switch? and !switches[actor.properties.off_switch]) then actor.revive! else actor.kill!
                        if switches[actor.properties.on_switch] and switches[actor.properties.off_switch] then actor.kill!
        case \holiday
            create_holiday object
        case \item
            name="treasure_#{switches.map}_#{treasure_count++}"
            break if switches[name]
            new Treasure(object.x+HTS, object.y+TS, name, object.properties.item, ~~object.properties.quantity) |> actors.add-child
            #break if switches['treasure_'+object.name]
            #new Treasure(object.x+HTS, object.y+TS, object.name, object.properties.item, ~~object.properties.quantity) |> actors.add-child
        case \mimic
            name="mimic_#{switches.map}_#{mimic_count++}"
            break if switches[name]
            new Treasure(object.x+HTS, object.y+TS, name, object.properties.item, ~~object.properties.quantity, true, object.properties) |> actors.add-child
        case \waygate
            dood = create_tree object, \1x2, 13, true, \waygate
        case \finaldoor, \labdoor
            dood = new Doodad object.x+HTS, object.y+TS, '3x3', 'finaldoor', true |> actors.add-child
            dood.frame=4
            dood.anchor.set 0.5, 1
            dood.body.set-size(TS*3,TS)
            initUpdate dood
            dood.properties = object.properties
            dood.properties.labdoor=true
            if object.type is \finaldoor and switches.finaldoor or switches[object.properties.open] or switches.doorswitch is object.properties.open or switches.beat_game
                dood.frame=5
                dood.body.enable=false
        case \morgue
            dood = new Doodad object.x, object.y, 'lab_tiles',null,true |> carpet.add-child
            dood.name='morgue'
            dood.crop new Phaser.Rectangle 0, TS*13, TS,TS
            dood.body.set-size TS, TS
            dood.properties = object.properties
            if !session.morgue_next
                session.morgue_next = 1
            if switches[object.properties.open]
            or (session.morgue_next>object.properties.order and session.morgue_set is object.properties.set)
                rect = new Phaser.Rectangle (if object.properties.last then 2 else 1)*TS, TS*13, TS,TS
                dood.open=true
                dood.crop rect
            dood.interact =!->
                if @open then return
                if @properties.order ~= session.morgue_next
                    session.morgue_set = @properties.set
                    rect = new Phaser.Rectangle (if @properties.last then 2 else 1)*TS, TS*13, TS,TS
                    @open=true
                    @crop rect
                    if @properties.last
                        session.morgue_next=1
                        for a in actors.children
                            continue unless a.properties and a.properties.labdoor and a.properties.open is @properties.open
                            a.frame=5
                            a.body.enable=false
                        setswitch @properties.open, true 
                        sound.play \door
                    else
                        session.morgue_next++
                        sound.play \candle
                else if session.morgue_next ~= 1
                    say '' tl("It won't open.")
                else
                    rect = new Phaser.Rectangle 0, TS*13, TS,TS
                    for n in carpet.children then if n.name is 'morgue' and n.properties.set is @properties.set
                        n.open=false
                        n.crop rect
                        session.morgue_next=1
                        sound.play \candle
            initUpdate dood
        case \goop
            #break
            name="goop_#{switches.map}_#{goop_count++}"
            break if switches[name]
            #break if switches.nogoop
            dood = new Doodad object.x+HTS+TS, object.y+TS, '3x3', null, false |> actors.add-child
            dood.collider = new Doodad object.x+2, object.y - 20, null, null, true |> actors.add-child
            dood.collider.base=dood
            #dood.collider.nointeract=true
            dood.frame=6
            dood.anchor.set 0.5, 1
            dood.collider.body.set-size(44,36)
            dood.name=name
            dood.collider.interact=!->@base.interact!
            dood.interact=!->
                say '' tl("An unnatural growth blocks the way.")
                if items.necrotoxin.quantity
                    say '' tl("Use Necrotoxin?")
                    goop=this
                    menu tl("Yes"), !->
                        scenario.burningflesh goop
                        acquire items.necrotoxin, -1, true, true
                        setswitch goop.name, true
                    ,tl("No"),!->
            dood.origin=x:dood.x,y:dood.y
            dood.goal=x:dood.x,y:dood.y,s:Math.random!*0.2+0.9
            dood.timer=Date.now! - (Math.random!*5000.|.0)
            dood.prev=x:dood.x,y:dood.y,s:1
            dood.update-paused=dood.update=!->
                t = (Date.now! - @timer)/5000
                smoothness=20
                t = (t*smoothness.|.0)/smoothness
                if t>1
                    @prev=x:@x,y:@y,s:@scale.x
                    @goal=x:@origin.x+Math.random!*8-4, y:@origin.y+Math.random!*8-4, s:Math.random!*0.2+0.9
                    @timer=Date.now!
                    return
                @x=@prev.x + (@goal.x - @prev.x)*t
                @y=@prev.y + (@goal.y - @prev.y)*t
                @scale.set @prev.s + (@goal.s - @prev.s)*t

            #initUpdate dood
            updatelist.push dood
            #goop_count++
        case \gallows
            dood = new Doodad object.x+TS, object.y+TS, '2x3', null, true |> actors.add-child
            dood.frame=1
            dood.anchor.set 0.5, 1
            dood.body.set-size 32, 23
            initUpdate dood
    #create_npcs!
    #npc_events!

    !function create_fringe (object, sheet, frame)
        tree = new Doodad(object.x, object.y+TS, sheet, null, false) |> fringe.add-child
        tree.x+=tree.width/2
        tree.anchor.set 0.5 1.0
        #tree.preUpdate!
        initUpdate tree
        tree.frame = +frame
        return tree

    !function create_tree (object, sheet, frame, collide, sap=false)
        #unless collide?
        #    collide=frame;frame=sheet;sheet=\1x2
        tree = new Doodad object.x, object.y+TS, sheet, null, collide |> actors.add-child
        tree.x+=tree.width/2
        tree.anchor.set 0.5 1.0
        tree.body?set-size TS, TS
        #tree.preUpdate!
        tree.frame = +frame
        tree.properties=object.properties
        switch sap
        |true
            tree.interact =!->
                unless items.vial.quantity>0
                    say '' "Glass vials can be used to collect Pine Sap."
                    return
                say '' "Collect Pine Sap?"
                #args=["Nevermind", (->),"Collect 1", (!->exchange items.vial, items.pinesap)]
                #args.push "Collect 3", (!->exchange 3, items.vial, items.pinesap) if items.vial.quantity>=3
                #args.push "Collect 10", (!->exchange 10, items.vial, items.pinesap) if items.vial.quantity>=10
                #args.push "Collect 33", (!->exchange 33, items.vial, items.pinesap) if items.vial.quantity>=33
                #args.push "Collect 100", (!->exchange 100, items.vial, items.pinesap) if items.vial.quantity>=100
                #menu.apply @,args
                q= items.vial.quantity
                number tl("Max:{0}",q), 0 q
                say ->
                    q= dialog.number.num
                    unless q>0
                        return say '' tl("Collected nothing.")
                    exchange q, items.vial, items.pinesap
                    sound.play \itemget
                    say '' tl("Collected {0} Pine Sap.",q)
        |\flower
            tree.name="flower_#{switches.map}_#{flower_count++}"
            tree.interact =!->
                unless items.vial.quantity>0
                    say '' tl("Glass vials can be used to collect Nectar.")
                    return
                flower=this
                say '' tl("Collect Nectar?")
                menu tl("Yes"), ->
                    switches[flower.name]=Date.now!
                    sound.play \itemget
                    say '' tl("Filled vial with Nectar.")
                    exchange items.vial, items.nectar
                    flower.kill!
                ,tl("No"), ->
        |\oil
            tree.name="oil_#{switches.map}_#{oil_count}"
            tree.interact =!->
                unless items.vial.quantity>0
                    say '' tl("Glass vials can be used to collect Oil.")
                    return
                oil=this
                say '' "Collect Oil?"
                menu tl("Yes"), ->
                    switches[oil.name]=Date.now!
                    sound.play \itemget
                    say '' tl("Filled vial with Oil.")
                    exchange items.vial, items.oil
                    oil.frame=14
                    delete! oil.interact
                ,tl("No"), ->
            fallthrough
        |\oil_empty
            oil_count++
            tree.body.set-size 12 12
        |\waygate
            tree.waygate=object.name
            tree.interact=!->
                if !items.voidcrystal.quantity
                    return say '' tl("Void Crystals are required to use the waygate.")
                for actor in actors.children
                    if actor.waygate is @properties.dest
                        Dust.summon player
                        for p in party
                            p.relocate actor.x, actor.y+TS
                        items.voidcrystal.quantity --
                        Dust.summon player
                        return
        default
            if object.properties.message
                tree.interact=!->
                    say '' tl(@properties.message)
            else if object.properties.scenario
                tree.interact=!->
                    scenario[@properties.scenario](this)
        tree.scale.x=-1 if object.properties.flip?
        initUpdate tree
        return tree

    !function create_holiday (object)
        return if switches.map is \hub and switches.llovsick1 is -2
        if holiday.halloween
            switch object.name
            |\holiday1 => create_tree object, \1x1, 1, true
            |\holiday2 => create_tree object, \1x1, 2, true
            |\centerpiece =>
                o=create_tree object, \1x2, 4, true
                o.interact =!->
                    say '' "The stack of jack-o'-lanterns stares back spoopily."
                    #if not switches.trickortreat
                    #    switches.trickortreat = true
                    #    learn_skill \trickortreat
        else if holiday.turkey
            void
            #if object.name is \centerpiece
            #   o=create_tree object, \table, 0, true
            #   o.interact=!->
            #       say '' "It's a feast!"
        else if holiday.christmas
            switch object.name
            |\holiday1 => create_tree object, \1x1, 3, true
            |\holiday2 => create_tree object, \1x1, 4, true
            |\centerpiece =>
                o=create_tree object, \1x2, 5, true
                o.interact =!->
                    say '' "It's a happy little tree."

        else if holiday.easter
            switch object.name
            |\holiday1 => create_tree object, \1x1, 6, true
            |\holiday2 => create_tree object, \1x1, 5, true


    !function create_doodad (object, group=carpet)
        doodad = new Doodad(object.x, object.y, object.properties.sprite, object.name) |> group.add-child
        doodad.body.set-size (object.properties.width||1)*TS, (object.properties.height||1)*TS
        switch doodad.name
        |\llovbed
            doodad.alpha=0 if switches.started
            doodad.body.set-size 20 31 0 1
            doodad.interact=!->
                if switches.pylonfixed
                    say '' "No need to sleep right now."
                else
                    say '' "Can't sleep."
        #|\fireplace
        #    doodad.interact=!->
        #        say '' "A pink flame erupts from the brazier, filling the room with vital energy."
        |\dresser
            doodad.interact=!->
                if party.length is 1
                    costume_screen.launch player
                else
                    say '' "Change clothes for whom?"
                    args=[]
                    for p in party
                        args.push speakers[p.name]display, callback:costume_screen.launch, arguments:[p]
                    menu.apply window, args
        |\game
            doodad.interact=!->
                say '' "It's a game system!"
                say '' "...It's not plugged in."
        |\medicine
            doodad.interact=!->
                unless Date.now! - switches.medic < 43200000
                    switches.medic=Date.now!
                    acquire items.medicine, 5
        |\grave1
            doodad.interact=!->
                unless Date.now! - switches.grave1 < 43200000
                    switches.grave1=Date.now!
                    acquire items.gravedust, 5
                else
                    #say '' tl("The grave is empty.")
                    say '' tl("Nothing but remains.")
        |\grave2
            doodad.interact=!->
                unless Date.now! - switches.grave2 < 43200000
                    switches.grave2=Date.now!
                    acquire items.gravedust, 5
                say '' tl("A note was found on the body.")
                say '' tl("\"38014\"")
        |\pc
            doodad.interact=scenario.pc
        |\portal
            doodad.interact=!->
                teleport_action false, true
        |\bloodsamples
            doodad.interact =!->
                return if player.y < this.y
                if items.bloodsample.quantity or items.bloodsample2.quantity
                    say '' tl("Returned Blood Sample.")
                items.bloodsample.quantity=0
                items.bloodsample2.quantity=0
                if !session.bloodsample then session.bloodsample=1+Math.random!*5.|.0
                if @properties.number ~= session.bloodsample then (acquire items.bloodsample2) else (acquire items.bloodsample)
        |\bloodlock
            doodad.interact =!->
                return if switches[@properties.open]
                if items.bloodsample2.quantity
                    say '' tl("DNA confirmed. Access granted.")
                    say !~>
                        sound.play \door
                        for a in actors.children
                            continue unless a.properties and a.properties.labdoor and a.properties.open is @properties.open
                            a.frame=5
                            a.body.enable=false
                        setswitch @properties.open, true 
                else if items.bloodsample.quantity
                    say '' tl("DNA mismatch. Access denied.")
                else
                    say '' tl("Please insert blood sample.")
        |\bookswitch
            doodad.loadTexture \lab_tiles
            if !session.book_next
                session.book_next=1
            if switches[object.properties.open] or session.book_next>object.properties.order
                doodad.crop new Phaser.Rectangle TS, TS*15, TS,TS*2
                doodad.open=true
            else
                doodad.crop new Phaser.Rectangle 0, TS*15, TS,TS*2
            doodad.interact =!->
                return if player.y < this.y
                or @open
                if @properties.order ~= session.book_next
                    @crop new Phaser.Rectangle TS, TS*15, TS,TS*2
                    @open=true
                    session.book_next++
                    if @properties.last
                        for a in actors.children
                            continue unless a.properties and a.properties.labdoor and a.properties.open is @properties.open
                            a.frame=5
                            a.body.enable=false
                        setswitch @properties.open, true 
                        sound.play \door
                    else
                        sound.play \candle
                else# if session.book_next ~= 1
                    say '' tl("It won't move.")
        |\labmessage1
            doodad.interact =!->
                say '' tl("There's a diagram illustrating a book switch mechanism.")
                say '' tl("The switches are labeled from 1 to 5, from north to south.")
        |\labmessage2
            doodad.interact =!->
                say '' tl("There are some notes scribbled on a piece of paper.")
                say '' tl("\"3214, 13542, 416532, 4371265\"")
                say '' tl("\"Don't forget... Don't forget!\"")
        |\labmessage3
            doodad.interact =!->
                say '' tl("There are some notes scribbled on a piece of paper.")
                say '' tl("\"Even if the project is successful, I will be dead before she reaches maturity.\"")
                say '' tl("\"I can't do this on my own any more. The project is cancelled. There's no point.\"")
                say '' tl("\"There's no hope.\"")
        doodad.properties=object.properties
        initUpdate doodad
        return doodad

!function create_prop node, key, collide=true, group=actors
    d=group.addChild new Doodad node.x+HTS,node.y+TS,key,null,collide
    d.anchor.set 0.5 1
    initUpdate d
    return d

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

class Item
    @COMMON = 0
    @CONSUME = 1
    @EQUIP = 2
    @KEY = 3
    (properties)->
        for key of properties
            @[key] = properties[key]
        @quantity ?= 0
        @time ?= 0
        @type ?= Item.COMMON
        @sicon ?= if @type is Item.KEY then 'item_key' else if @type is Item.CONSUME then 'item_pot' else if @type is Item.EQUIP then 'item_equip' else 'item_misc'
        @icon ?= 'item_equip2' if @type is Item.EQUIP
        @iconx ?= 0
        @icony ?= 0
        @target ?= 'ally'
        @attributes ?= []
        @consume =!->
            sound.play \itemget
            @quantity = @quantity - 1 >? 0 if @type is Item.CONSUME and not @dontconsume
            if \glass in @attributes
                if \bomb in @attributes
                    acquire items.shards, 1 true true
                    if game.state.current is \battle
                        drop_item \cumberground 1
                    else acquire items.cumberground, 1 true true
                else acquire items.vial, 1 true true
            save! unless game.state.current is \battle
        @condition ?= -> true
        @unique ?= @type is Item.EQUIP or @type is Item.KEY

    #is_unique:->@type is Item.EQUIP or @type is Item.KEY or @unique

!function acquire (item, q=1, silent=false, nosave=false)
    if !item
        #return alert "Item doesn't exist! Please notify developer."
        fatalerror \missingitem
        return
    item.time=Date.now!
    if silent
        item.quantity += q
        item.quantity=0 if item.quantity<0
        save! unless nosave
        return
    say.call this, ->
        sound.play \itemget 
        item.quantity += q
        item.quantity=0 if item.quantity<0
        save! unless nosave
    #say.call this, '' "Acquired "+(if q>1 then "#{stattext(q,5)} " else '')+"#{item.name}!"
    say.call this, '' tl("Acquired {0} {1}!",stattext(q,5),item.name)

!function exchange
    switch &length
    |2 => qlose=qgain=1; ilose=&0; igain=&1
    |3 => qlose=qgain=&0; ilose=&1; igain=&2
    |4 => qlose=&0; ilose=&1; qgain=&2; igain=&3
    if ilose.quantity < qlose
        warn "Exchange failed, not enough #{ilose.name}!"
        return
    ilose.quantity -= qlose
    igain.quantity += qgain
    igain.time=Date.now!
    save!


#========================================
# Item effects
#----------------------------------------

!function heal (o, hp, showtext=true)
    if o instanceof Player
        o.stats.hp  =  o.stats.hp + hp / (o.get_stat \hp) <? 1
    else
        o.damage -hp, showtext

!function heal_percent (o, hp, showtext=true)
    if o instanceof Player
        o.stats.hp = o.stats.hp + hp <? 1
    else
        o.damage -hp * (o.get_stat \hp), showtext
    return (o.get_stat \hp)*hp

!function item_heal_hybrid (o,n,s, showtext=true)
    if o instanceof Player
        heal o, n, showtext
        heal_percent o, s, showtext
    else
        amt = n + s*o.get_stat \hp
        o.damage -amt, showtext

#========================================
# ITEMS
#----------------------------------------

items = {}
items.steelpipe =
    name: "Steel Pipe"
    iconx: 3
    icony: 2
    type: Item.EQUIP
    mod_atk: (s)->s+18
    mod_speed: (s)->s*0.90
    attack: !->
        calltarget \inflict buffs.dazed if @parent.luckroll!>0.8
    desc: "A crude makeshift weapon. Good for bashing people over the head."
    attributes: <[blunt]>
items.shinai =
    name: "Kendo Stick"
    iconx: 2
    icony: 0
    type: Item.EQUIP
    mod_atk: (s)->s+10
    #desc: "A bamboo sword used in Kendo, a Japanese martial art. It might be better to practice with this before using a real sword."
    desc: "A bamboo sword used in Kendo, a Japanese martial art. Does more damage at lower levels."
    #maybe boost exp gain
items.toyhammer =
    name: "Toy Hammer"
    iconx:2
    icony: 3
    type:Item.EQUIP
    quantity: 0
    mod_atk: (s)->s+6
    mod_luck: (s)->s+9
    attack: !->
        calltarget \inflict buffs.dazed
    desc: "A hammer made of plastic. It doesn't do much damage, but it can be used to stun enemies."
items.bow =
    name: "Lovely Bow"
    iconx:4
    icony:3
    type:Item.EQUIP
    mod_atk: (s)->s*1.02+6
    mod_luck: (s)->s*1.02+4
    desc: "Increases the damage of arrow skills. In skilled hands, unlocks a special skill."
    quantity: 0
    skill: -> if @parent.name is \llov and @parent.forme.stage>0 then skills.leecharrow else null
items.fan =
    name: "Fan"
    iconx: 0
    icony: 2
    type: Item.EQUIP
    mod_atk: (s)->s+10
    mod_def: (s)->s+10
    mod_speed: (s)->s+5
    mod_luck: (s)->s+5
    mod_hp: (s)->s+10
    desc: "A fan given by Malaria-sama. Ever so slightly boosts every stat."
items.samsword =
    name: "Sam Sword"
    iconx: 3
    type: Item.EQUIP
    mod_atk: (s)-> (@get_stat \speed)/666 * s + s
    desc: "A curved sword that requires a bit of skill to use. It cuts better the faster you swing it."
    attributes: <[blade]>
items.broadsword =
    name: "Broad Sword"
    iconx: 4
    type: Item.EQUIP
    mod_atk: (s)-> s*1.11
    desc: "A large sword made to cleave through foes."
    attributes: <[blade]>
items.vampsword =
    name: "Vampire Blade"
    type: Item.EQUIP
    iconx: 1
    icony: 3
    mod_atk: (s)-> s*1.3
    mod_luck: (s)-> s*0.1
    step: !->
        @parent.damage deltam*0.02*@parent.get_stat \hp
    desc: "A powerful sword that gradually drains the wielder's life."
    attributes: <[blade]>
items.mistersword =
    name: "Mister Sword"
    type: Item.EQUIP
    icony: 3
    mod_atk: (s)->
        roll = @parent.luckroll or Math.random
        return s*(1+roll.call(@parent)*0.3 - 0.05)
    desc: "A sword with a mind of its own. Attack power varies randomly."
    attributes: <[blade]>
items.pest =
    name: "Pestilent"
    iconx: 5
    type: Item.EQUIP
    mod_atk: (s)-> s*1.1
    mod_luck: (s)-> s*1.1
    attack: !->
        #battle.target.inflict buffs.poison
        calltarget \inflict buffs.poison if @parent.luckroll!>0.9
    desc: "Old Pest's trusty sword. The blade is adorned with runic lettering. Poison seeps from the blade."
    attributes: <[blade]>
items.worldsharp =
    name: 'Worlds Sharp'
    iconx: 5
    icony: 2
    type: Item.EQUIP
    quantity: 0
    mod_atk: (s)-> s*1.06+5
    mod_luck: (s)-> s*1.2
    desc: "The sharpest cheddar cheese knife in the world. It's too stale to eat."
    attributes: <[blade]>
items.newton =
    name: "Flame Razer"
    iconx: 5
    icony: 0
    desc: "The sharpest and hottest laser razor around."
    type: Item.EQUIP
    attack: !->
    # Deals extra damage against non-scientific enemies
    attributes: <[blade]>
items.chainsaw =
    name: "Chainsaw"
    iconx: 1
    icony: 4
    type: Item.EQUIP
    mod_atk: (s)-> s*(if !(@parent instanceof Monster) and items.oil.quantity then 1.3 else 1)
    attack: !->
        if !(@parent instanceof Monster) and items.oil.quantity
            acquire items.oil, -1, true, true
    desc: "A very powerful weapon. Consumes 1 oil every attack to remain effective."
    attributes: <[tech]>

items.torndress =
    name: "Torn Dress"
    desc: "It's torn at several parts, but it's still somehow wearable."
    type: Item.EQUIP
    iconx:3
    icony:3
    mod_def: (s)-> s+5
    mod_luck: (s)-> s+20
items.leatherarmor =
    name: "Leather Armor"
    iconx: 2
    icony: 1
    desc: "Armor made from hardened leather. It offers light protection."
    type: Item.EQUIP
    #Most armor will lower your speed at least a little. This one won't.
    mod_def: (s)-> s*1.1+10
items.thornarmor =
    name: "Thorn Armor"
    iconx: 4
    icony: 1
    desc: "Thorns coat this armor, causing harm to attackers."
    type: Item.EQUIP
    ondamage: (damage, source)!->
        if source is @parent then return damage
        source?damage damage*0.25, (Math.floor damage)>0, @parent
        return damage
    mod_def: (s)-> s*1.05+10
items.magicarmor =
    name: "Magic Armor"
    desc: "Defends well against magic, but restricts movement."
    type: Item.EQUIP
items.platearmor =
    name: "Plate Armor"
    iconx: 3
    icony: 1
    desc: "Armor made from solid metal plates. It offers high protection but is heavy."
    type: Item.EQUIP
    mod_def: (s)-> s*1.3+30
    mod_speed: (s)-> s*0.9
items.deathsmantle =
    name: "Death's Mantle"
    type: Item.EQUIP
    icony: 4
    desc: "The shroud worn by death itself. Provides immunity to death as long as you have allies."
    mod_luck: (s)-> s/2
items.scythe =
    name: "Scythe"
    type: Item.EQUIP
    iconx: 2
    icony: 4
    desc: "Capable of slaying monsters with death immunity."
    mod_atk: (s)->s*1.1
    mod_luck: (s)->s*1.1
    attack: !->
        calltarget !->
            @attributes.push \mortal if \mortal not in @attributes
items.woodshield =
    name: "Wood Shield"
    icony: 1
    desc: "Provides defense, but is weak to fire."
    type: Item.EQUIP
    #Burns up when hit by a fire attack
    mod_def: (s)-> s*1.2+20
items.towershield =
    name: "Tower Shield"
    iconx: 1
    icony: 1
    desc: "Provides great defense at the cost of offense and mobility."
    type: Item.EQUIP
    mod_def: (s)-> s*1.35+50
    mod_speed: (s)-> s*0.8
    mod_atk: (s)-> s*0.9
items.glassshield =
    name: "Glass Shield"
    desc: "A shield that defends great against magic. It shatters easily, but regenerates after battle."
    type: Item.EQUIP
items.swiftshoe =
    name: "Swift Shoe"
    iconx: 2
    icony: 2
    desc: "Slightly raises speed and greatly increases chance of escape."
    type: Item.EQUIP
    mod_speed: (s)-> s*1.2
    mod_escape: (s)-> s*2

items.heartpin =
    name: "Heart Pin"
    iconx: 1
    icony: 2
    desc: "A cute heart-shaped pin to be worn in the hair. Its magical properties increases the wearer's health."
    type: Item.EQUIP
    mod_hp: (s)->s*1.1+5
    quantity: 0

items.kill =
    name: "Kill"
    desc: "Dev item. Kills target."
    type: Item.KEY
    quantity: 0
    usebattle: (target)->
        target.damage target.stats.hp_max
    target: 'any'

items.riverfilter =
    name: "River Filter"
    #desc: "A special filter designed by Joki to remove contaminants from the black river's water."
    desc: "Allows collection of water from the Tuonen river without assistance from Joki."
    type: Item.KEY
    iconx: 5
    useoverworld: !->
        if player.water_depth
            q = items.vial.quantity
            if q
                say '' tl("Collect Black Water?")
                number tl("Max:{0}",q), 0 q
                say ->
                    q= dialog.number.num
                    unless q>0
                        return say '' tl("Collected nothing.")
                    sludgecount=0
                    for from 0 til q then sludgecount++ if Math.random!<0.1
                    say '' tl("Collected {0} Black Water.",q)
                    acquire items.sludge, sludgecount, false, true if sludgecount
                    exchange q, items.vial, items.tuonen
                    sound.play \itemget
                    pause_screen.inventory.revive!
            else
                say '' tl("Vials are needed to collect water.")
        else
            say '' tl("No water to collect.")
        #if in water fill one vial with black water.
        #occasionally give 1 poison sludge as well
    target: 'none'

items.jokicharm =
    name: "River Boots"
    #desc: "A special filter designed by Joki to remove contaminants from the black river's water."
    desc: "Not an actual pair of boots, but actually a trinket. It seems this allows you to wade through the waters of the Tuonen River."
    type: Item.KEY
    iconx: 4

items.vial =
    name: "Glass Vial"
    type: Item.COMMON
    sicon: \item_pot
    iconx: 1
    desc: "Can be used to collect various liquids to use as potion bases."
items.oil =
    name: "Volatile Oil"
    type: Item.COMMON
    sicon: \item_pot
    iconx: 4
    #desc: "Can be used as a base to create potions with sustained effects."
    desc: "Can be used as a base to create throwing potions."
    attributes: <[glass]>
items.pinesap =
    name: "Pine Sap"
    type: Item.COMMON
    sicon: \item_pot
    iconx: 2
    #desc: "Can be used as a base to create potions with sustained effects."
    desc: "Can be used as a base to create basic potions. Gathered from pine trees."
    attributes: <[glass]>
items.nectar =
    name: "Sweet Nectar"
    type: Item.COMMON
    sicon: \item_pot
    iconx: 3
    desc: "Can be used as a base to create high quality potions. Gathered from flowers."
    attributes: <[glass]>
items.tuonen =
    name: "Black Water"
    type: Item.COMMON
    sicon: \item_pot
    iconx: 5
    #desc: "Can be used as a base to create elixirs."
    desc: "Water pulled from the Tuonen River. Used as a potion base to remove status conditions. Consuming it raw may cause severe amnesia."
    attributes: <[glass]>

items.medicine =
    name: "Medical Waste"
    type: Item.COMMON
    iconx: 4
    desc: "Discarded medical supplies. It could probably be used to make healing items."

items.sludge =
    name: "Poison Sludge"
    type: Item.COMMON
    desc: "A highly toxic substance. Handle with care."
    iconx: 1
    icony: 2
items.gravedust =
    name: "Grave Dust"
    type: Item.COMMON
    desc: "Cursed residue left behind from an undead creature."
    icony: 2
items.silverdust =
    name: "Silver Dust"
    type: Item.COMMON
    desc: "Overexposure may turn skin blue."
    icony: 3
items.starpuff =
    name: "Star Puff"
    type: Item.COMMON
    desc: "A puffy sea star, made of dreams and magic."
    iconx: 1
    icony: 3
items.venom =
    name: "Venom Gland"
    type: Item.COMMON
    desc: "Taken from a venomous beast."
    iconx: 2
    icony: 2
items.aloevera = 
    name: "Aloe Vera"
    type: Item.COMMON
    desc: "Can be used to heal minor burns or as a medical ingredient."
    iconx: 3
    icony: 2
    usebattle: (target)->
        for buff in target.buffs
            if buff.name is \burn and buff.intensity is 1
                buff.remedy!
items.plantfiber = 
    name: "Plant Fiber"
    type: Item.COMMON
    desc: "Fibrous plant parts. It can probably be woven into parchment"
    iconx: 3
    icony: 2
items.fur = 
    name: "Clumpy Fur"
    desc: "Matted clumps of fur taken from a beast of some sort."
    iconx: 4
    icony: 1
items.cloth = 
    name: "Cloth Scraps"
    desc: "Ripped scraps of cloth."
    iconx: 3
    icony: 1
items.cinder = 
    name: "Cinders"
    desc: "Burning bits of something. They're still very hot."
    iconx: 2
    icony: 1
items.frozenflesh = 
    name: "Frozen Flesh"
    desc: "Frozen bits of flesh."
    icony: 1
items.meat = 
    name: "Meat"
    desc: "Succulent bits of meat. They can be used to distract certain enemies."
    type: Item.CONSUME
    sicon: \item_misc
    iconx: 1
    icony: 1
    usebattle: !(target)->
        if \carnivore in target.attributes
            target.inflict buffs.baited
            target.stats.sp=0
            triggertext target.displayname+" was baited!"
        else
            triggertext "It had no effect."
    target: 'enemy'

items.teleport =
    #name: "Teleport"
    name: "Portal Scroll"
    type: Item.CONSUME
    dontconsume: true
    sicon: \item_misc
    iconx: 5
    icony: 1
    desc: "Teleports the user to any previously activated pentagram."
    useoverworld: ->
        teleport_action true, false
    target: 'none'
!function teleport_action consume, ignorelock
    if switches.lockportals and !ignorelock
        return say '' tl("A magical influence prevents the spell from working!")
    zones=[]
    for zone of pentagrams
        for pent of pentagrams[zone]
            if switches["visited_#{pent}"]
                zones.push zone
                break
    if zones.length is 0
        return say '' tl("There are no suitable destinations.")
    menuset=[tl("Cancel"), ->]
    for zone in zones
        menuset.push tl(zone), callback:teleportmenu, context:dialog.menu, arguments:[zone]
    say '' tl("Choose a destination")
    menu.apply window, menuset
    !function teleportmenu zone
        pents=[]
        menuset=[tl("Back"),'back']
        for pent of pentagrams[zone]
            if switches["visited_#{pent}"]
                menuset.push tl(pentagrams[zone][pent]), [!->
                    pause_screen.exit!
                    items.teleport.quantity -- if consume
                ,callback:warp_node,arguments:pent.split /_(?!.*_)/]
        @nest.apply @, menuset

items.swarmscroll =
    name: "Swarm Scroll"
    type: Item.CONSUME
    sicon: \item_misc
    iconx: 5
    icony: 2
    desc: "Casts Swarm on the target."
    usebattle: (target)->
        target.inflict buffs.swarm
    target: 'enemy'
    attributes: <[spell]>

items.plaguescroll =
    name: "Plague Scroll"
    type: Item.CONSUME
    sicon: \item_misc
    iconx: 5
    icony: 3
    desc: "Makes the target spread its diseases to its allies."
    usebattle: (target)->
        diseaselist=[]
        for buff in target.buffs
            #if buff.name in <[poison bleed swarm seizure blister aids]>
            if 'disease' in buff.attributes
            and buff.name not in diseaselist
                diseaselist.push buff.name
        for enemy in enemy_list!
            for buff in diseaselist
                continue if enemy.has_buff buffs[buff]
                enemy.inflict buffs[buff]
    target: 'enemy'
    attributes: <[spell]>

items.slowscroll =
    name: "Slow Scroll"
    type: Item.CONSUME
    sicon: \item_misc
    iconx: 4
    icony: 3
    desc: "Slows the target."
    usebattle: (target)->
        target.inflict buffs.slow
    target: 'enemy'
    attributes: <[spell]>

items.parchment = 
    name: "Parchment"
    desc: "Used for the creation of scrolls."
    iconx: 3
    icony: 3

items.bugbits = 
    name: "Bug Parts"
    desc: "Broken bits of bugs."
    iconx: 2
    icony: 3

items.blistercream =
    name: "Ointment"
    type: Item.CONSUME
    sicon: 'item_misc'
    iconx: 1
    desc: "Removes 1 negative status effect."
    target: 'ally'
    usebattle: (target)->
        for buff in target.buffs
            if buff.negative
                buff.remedy!
                break
items.antidote =
    name: "Antidote"
    type: Item.CONSUME
    icony: 2
    desc: "Heals poison effects when ingested."
    usebattle: (target)->
        target.remedy buffs.poison
    target: 'ally'
    attributes: <[glass]>
items.burnheal =
    name: "Burn Heal"
    type: Item.CONSUME
    iconx: 2
    icony: 2
    desc: "Heals burns."
    usebattle: (target)->
        target.remedy buffs.burn
    target: 'ally'
    attributes: <[glass]>
items.anticurse =
    name: "Anticurse"
    type: Item.CONSUME
    iconx: 1
    icony: 2
    desc: "Removes all sorts of curses."
    usebattle: (target)->
        #target.remedy buffs.curse
        #target.remedy buffs.isolated
        for buff in target.buffs then if 'curse' in buff.attributes
            buff.remedy!
    target: 'ally'
    attributes: <[glass]>
items.antifreeze =
    name: "Antifreeze"
    type: Item.CONSUME
    iconx: 3
    icony: 2
    desc: "Remove all cold effects."
    usebattle: (target)->
        target.remedy buffs.chill
    target: 'ally'
    attributes: <[glass]>
items.bleach =
    name: "Bleach"
    type: Item.CONSUME
    iconx: 4
    icony: 2
    desc: "Remove all status effects from the target."
    usebattle: (target)->
        for buff in target.buffs
            buff.remedy!
    target: 'any'
    #attributes: <[glass]>
items.repel =
    name: "Repel"
    type: Item.CONSUME
    iconx: 5
    icony: 2
    desc: "Keeps monsters away for a short time."
    useoverworld: !->
        temp.repel = 20000
    target: 'none'
items.lifecrystal =
    name: "Life Crystal"
    type: Item.CONSUME
    sicon: 'item_misc'
    iconx: 3
    desc: "Restores health."
    use: (target)->
        item_heal_hybrid target, 50, 0.25
    target: 'ally'
items.darkcrystal =
    name: "Dark Crystal"
    type: Item.CONSUME
    sicon: 'item_misc'
    iconx: 2
    desc: "Removes curses."
    usebattle: (target)->
        target.remedy buffs.curse
    target: 'ally'
items.voidcrystal =
    name: "Void Crystal"
    type: Item.COMMON
    sicon: 'item_misc'
    iconx: 2
    desc: "Used to operate void gates."
items.bandage =
    name: "Bandage"
    desc: "Restores health and stops bleeding."
    type: Item.CONSUME
    sicon: 'item_misc'
    iconx: 4
    icony: 2
    use: (target)->
        item_heal_hybrid target, 50, 0.25
        target.remedy? buffs.bleed
items.hp1 =
    name: "Health Drink"
    type: Item.CONSUME
    icony: 1
    desc: "Restores a moderate amount of health."
    use: (target)->
        item_heal_hybrid target, 100, 0.25
        #heal target, 100,false
        #target.show_text "+#{Math.round 100+heal_percent target, 0.25,false}", 'font_green'
    target: 'ally'
    attributes: <[glass]>
items.hp2 =
    name: "Health Tonic"
    type: Item.CONSUME
    iconx: 1
    icony: 1
    desc: "Restores a lot of health."
    use: (target)->
        item_heal_hybrid target, 200, 0.50
        #heal target, 200,false
        #target.show_text "+#{Math.round 200+heal_percent target, 0.5,false}", 'font_green'
    target: 'ally'
    attributes: <[glass]>

items.sp1 =
    name: "Speed Potion"
    type: Item.CONSUME
    iconx: 2
    icony: 1
    desc: "Raises speed for a short time."
    usebattle: (target)->
        target.inflict buffs.speed
    target: 'ally'
    attributes: <[glass]>
items.sp2 =
    name: "Burst Potion"
    type: Item.CONSUME
    iconx: 3
    icony: 1
    desc: "Provides a quick burst of speed."
    usebattle: (target)->
        if target.has_buff buffs.dizzy
            triggertext "It had no effect."
            return
        target.stats.sp+=2
        target.stats.sp_level=Math.ceil target.stats.sp - 1
        target.inflict buffs.dizzy
    target: 'ally'
    attributes: <[glass]>
    #nodizzy:true

items.ex1 =
    name: "Excel Potion"
    type: Item.CONSUME
    iconx: 4
    icony: 1
    desc: "Fills the excel meter by half."
    usebattle: (target)-> target.stats.ex+=0.5
items.ex2 =
    name: "Excel Tonic"
    type: Item.CONSUME
    iconx: 5
    icony: 1
    desc: "Fills the excel meter to the top!"
    usebattle: (target)-> target.stats.ex+=1

items.poisonbom =
    name: "Poison Bomb"
    type: Item.CONSUME
    icony: 3
    desc: "Poisons the target."
    usebattle: (target)->
        target.inflict buffs.poison
    target: 'enemy'
    attributes: <[glass bomb]>
items.cursebom =
    name: "Curse Bomb"
    type: Item.CONSUME
    iconx: 1
    icony: 3
    desc: "Curses the target."
    usebattle: (target)->
        target.inflict buffs.curse
    target: 'enemy'
    attributes: <[glass bomb]>
items.firebom =
    name: "Fire Bomb"
    type: Item.CONSUME
    iconx: 2
    icony: 3
    desc: "Burns the target."
    usebattle: (target)->
        target.inflict buffs.burn
    target: 'enemy'
    attributes: <[glass bomb]>
items.icebom =
    name: "Ice Bomb"
    type: Item.CONSUME
    iconx: 3
    icony: 3
    desc: "Chills the target."
    usebattle: (target)->
        target.inflict buffs.chill
    target: 'enemy'
    attributes: <[glass bomb]>

items.cumberground =
    name: "Cumberground"
    desc: "A useless piece of garbage. Maybe someone else can find value in this item."
    type: Item.COMMON
    quantity: 0
items.shards =
    name: "Glass Shards"
    desc: "Jagged shards of glass. Can be reformed into glass vials through glass blowing."
    type: Item.COMMON
    iconx: 5

items.waterbottle =
    name: "Water Bottle"
    desc: "Used to spray water at things."
    type: Item.KEY
    iconx: 2
    usebattle: (target)->
        if target.monstertype is Monster.types.rabies
            triggertext "Rabies: NO! WATER IS BAD!"
            unless target.triggered
                target.triggered = true
                target.loadTexture 'monster_rabies2'
                target.stats.atk /= 2
        else
            triggertext "It had no effect."
    target: 'any'

items.tunnel_key =
    name: "Tunnel Key"
    desc: "Opens up Smallpox's maintenance tunnel. The entrance to the tunnel is in a building south of the black tower."
    type: Item.KEY

items.basement_key =
    name: "Trapdoor Key"
    desc: "Opens up the trapdoors on Earth."
    type: Item.KEY
    iconx: 1

items.bloodsample =
    name: "Blood Sample"
    desc: "A sample of human blood. It is marked with a white band."
    type: Item.KEY
    icony: 2
items.bloodsample2 =
    name: "Blood Sample"
    desc: "A sample of human blood. It is marked with a black band."
    type: Item.KEY
    icony: 2

items.necrotoxin =
    name: "Necrotoxin"
    desc: "A substance specially developed to destroy living flesh."
    special: true
    sicon: 'item_key'
    iconx: 4
    icony: 1
    #useoverworld: !->
    #    say '' tl("Nothing to use it on.")
    target: 'none'

items.necrotoxinrecipe =
    name: "Necrotoxin Recipe"
    desc: "Allows War to synthesize additional necrotoxin."
    type: Item.KEY
    iconx: 5
    icony: 1

items.llovmedicine =
    name: "Love Tonic"
    type: Item.CONSUME
    desc: "Medicine to help Lloviu-tan feel better."
    use: (target)->
        setswitch \llovmedicine true
    target: 'ally'
    attributes: <[glass]>

items.humansoul =
    name: "Human Soul"
    sicon: 'item_key'
    icony: 1
    type: Item.COMMON
    desc: "The souls of humanity."

!function eat_soul (target, name)
    level=target.level
    xp=((levelToXp level+1)-(levelToXp level))*2
    target.add_xp xp, true
    message=if target.level>level then tl("Level up!") else tl("{0} xp gained.",xp)
    say '' tl("The soul of {0} has been devoured. {1}",name, message)

items.naesoul =
    name: "Nae's Soul"
    soulname: "Naegleria"
    sicon: 'item_key'
    icony: 1
    type: Item.CONSUME
    useoverworld: (target)!->
        switches.llovsick=false if target is llov
        setswitch \ate_nae target.name
        eat_soul target, \Naegleria
    #desc: "Naegleria's soul. It's sure to contain lots of experience."
    desc: "Naegleria's soul. If consumed it will grant experience. If kept it can be used to revive Naegleria."
    target: \ally
    unique: true
    special: true

items.chikunsoul =
    name: "Chikun's Soul"
    soulname: "Chikungunya"
    sicon: 'item_key'
    icony: 1
    type: Item.CONSUME
    useoverworld: (target)!->
        switches.llovsick=false if target is llov
        setswitch \ate_chikun target.name
        eat_soul target, \Chikungunya
    #desc: "Naegleria's soul. It's sure to contain lots of experience."
    desc: "Chikungunya's soul. If consumed it will grant experience. If kept it can be used to revive Chikungunya."
    target: \ally
    unique: true
    special: true

items.aidssoul =
    name: "Eidzu's Soul"
    soulname: "Eidzu"
    sicon: 'item_key'
    icony: 1
    iconx: 1
    type: Item.CONSUME
    useoverworld: (target)!->
        switches.llovsick=false if target is llov
        setswitch \ate_eidzu target.name
        eat_soul target, \Eidzu
    #desc: "Naegleria's soul. It's sure to contain lots of experience."
    desc: "Eidzu's soul. If consumed it will grant experience. If kept it can be used to revive Eidzu."
    target: \ally
    unique: true
    special: true

items.sarssoul =
    name: "Sars' Soul"
    soulname: "Sars"
    sicon: 'item_key'
    icony: 1
    type: Item.CONSUME
    useoverworld: (target)!->
        switches.llovsick=false if target is llov
        setswitch \ate_sars target.name
        eat_soul target, \Sars
    #desc: "Naegleria's soul. It's sure to contain lots of experience."
    desc: "Sars' soul. If consumed it will grant experience. If kept it can be used to revive Sars."
    target: \ally
    unique: true
    special: true

items.rabiessoul =
    name: "Rabies' Soul"
    soulname: "Rabies"
    sicon: 'item_key'
    icony: 1
    type: Item.CONSUME
    useoverworld: (target)!->
        switches.llovsick=false if target is llov
        setswitch \ate_rabies target.name
        eat_soul target, \Rabies
    #desc: "Naegleria's soul. It's sure to contain lots of experience."
    desc: "Rabies' soul. If consumed it will grant experience. If kept it can be used to revive Rabies."
    target: \ally
    unique: true
    special: true

items.llovsoul =
    name: "Lloviu's Soul"
    soulname: "Lloviu"
    sicon: 'item_key'
    icony: 1
    type: Item.CONSUME
    useoverworld: (target)!->
        setswitch \ate_llov target.name
        eat_soul target, \Lloviu
    #desc: "Naegleria's soul. It's sure to contain lots of experience."
    desc: "Lloviu's soul. If consumed it will grant experience. If kept it can be used to revive Lloviu."
    target: \ally
    unique: true
    special: true

items.soulshard =
    name: "Soul Shard"
    sicon: 'item_key'
    iconx: 2
    icony: 1
    type: Item.CONSUME
    useoverworld: (target)!->
        level=target.level
        xp=((levelToXp level+1)-(levelToXp level))/2
        target.add_xp xp, true
        message=if target.level>level then "Level up!" else "#xp gained."
        say '' "Devoured soul shard. #message"
    desc: "A fragment of a broken soul. It probably contains a bit of experience."
    target: \ally
    unique: false

items.excel =
    name: "Excel Orb"
    sicon: 'item_key'
    iconx: 3
    type: Item.CONSUME
    dontconsume: true
    unique: false
    useoverworld: (target)!->
        excel_screen.launch target
    desc: "Permanently unlocks a super-powered transformation for one of your heroes."
    target: \ally
    condition: !->
        unlockcount=0
        excelcount=0
        for i of formes then for j,f of formes[i]
            continue if j is \default
            unlockcount++ if f.unlocked
            excelcount++
        return unlockcount + items.excel.quantity < excelcount
    special: true

items.sporb =
    name: "SP Orb"
    sicon: 'item_key'
    iconx: 3
    icony: 1
    type: Item.CONSUME
    useoverworld: (target)!->
        name=target.name
        switches.sp_limit[name] ?= 1
        switches.sp_limit[name]++
        say '' tl("{0}'s limit has raised to {1}!",speakers[name]display, switches.sp_limit[name]*100+'%')
    target: \ally
    desc: !->
        text=tl("Raises the maximum SP a hero can charge to beyond 100%.\n\nCurrent levels:\n")
        for p in party
            text+=speakers[p.name]display+'\u2002'+(switches.sp_limit[p.name]||1)*100+'%\n'
        return text
    special: true
items.humanskull =
    name: "Human Skull"
    sicon: 'item_equip'
    iconx: 4
    icony: 2
    type: Item.KEY
    desc: "Property of Ebola-chan."

items.humanskull2 =
    name: "Human Skull"
    desc: "When held by Ebola-chan it can be used to shoot lasers from the eyes, dealing extra damage for each bleed effect on the enemy."
    #sicon: 'buff_skull'
    iconx: 4
    icony: 2
    type: Item.EQUIP
    mod_hp: (s)->s*1.1+5
    skill: -> if @parent.name is \ebby then skills.skullbeam else null

items.shrunkenhead =
    name: "Shrunken Head"
    type: Item.EQUIP
    iconx: 5
    icony: 3
    desc: "A gift from Zika-chan. Grants a special skill that deals more damage for each status effect on the enemy."
    mod_luck: (s)->s*1.1
    skill: -> skills.hex
    #reward for beating Zika-chan

items.spellbook =
    name: "Spell Book"
    type: Item.CONSUME
    useoverworld: !->
        learn_skill \poison
    desc: "For testing purposes."
    target: \none

items.coagulate =
    name: "Coagulat Tome"
    type: Item.CONSUME
    useoverworld: !->
        learn_skill \coagulate
    condition: -> \coagulate not in skillbook.all
    desc: "Teaches the coagulate skill, which locks effect slots when used after Hemorrhage."
    target: \none
    unique: true

items.healblock =
    name: "Malus Vital Tome"
    sicon: \item_misc
    iconx: 5
    icony: 4
    type: Item.CONSUME
    useoverworld: (target)!->
        learn_skill \healblock, target.name
    desc: "Teaches the Malus Vital skill, which prevents targets from healing."
    target: \ally
    unique: true


#----------------------------------------
for key, properties of items
    items[key] = new Item properties
    items[key]id = key


#CRAFTING
crafting =
    # {item1: items.water, item2: items.medicine, result: items.hp1}
    # {item1: items.pinesap, item2: items.medicine, result: items.regen}
    {item1: \pinesap, item2: \medicine, result: \hp1}
    {item1: \nectar, item2: \medicine, result: \hp2}
    {item1: \aloevera, item2: \medicine, result: \blistercream}
    {item1: \pinesap, item2: \silverdust, result: \sp1}
    {item1: \nectar, item2: \silverdust, result: \sp2}
    {item1: \pinesap, item2: \starpuff, result: \ex1}
    {item1: \nectar, item2: \starpuff, result: \ex2}

    {item1: \fur, item2: \medicine, result: \bandage}
    {item1: \cloth, item2: \medicine, result: \bandage}
    {item1: \plantfiber, item2: \medicine, result: \bandage}
    {item1: \parchment, item2: \medicine, result: \bandage}

    {item1: \fur, item2: \cloth, result: \parchment}
    {item1: \cloth, item2: \plantfiber, result: \parchment}
    {item1: \plantfiber, item2: \fur, result: \parchment}

    {item1: \parchment, item2: \gravedust, result: \teleport}
    {item1: \parchment, item2: \silverdust, result: \slowscroll}
    {item1: \parchment, item2: \bugbits, result: \swarmscroll}
    {item1: \parchment, item2: \sludge, result: \plaguescroll}
    {item1: \parchment, item2: \venom, result: \plaguescroll}

    # {item1: \fur, item2: \gravedust, result: \teleport}
    # {item1: \cloth, item2: \gravedust, result: \teleport}
    # {item1: \plantfiber, item2: \gravedust, result: \teleport}

    {item1: \frozenflesh, item2: \cinder, result: \meat}

    {item1: \tuonen, item2: \sludge, result: \antidote}
    {item1: \tuonen, item2: \venom, result: \antidote}
    {item1: \tuonen, item2: \gravedust, result: \anticurse}
    {item1: \tuonen, item2: \cinder, result: \burnheal}
    {item1: \tuonen, item2: \frozenflesh, result: \antifreeze}

    {item1: \oil, item2: \sludge, result: \poisonbom}
    {item1: \oil, item2: \venom, result: \poisonbom}
    {item1: \oil, item2: \gravedust, result: \cursebom}
    {item1: \oil, item2: \cinder, result: \firebom}
    {item1: \oil, item2: \frozenflesh, result: \icebom}

    {item1: \silverdust, item2: \bugbits, result: \repel}

for recipe in crafting
    if typeof recipe.item1 is \string then recipe.item1 = items[recipe.item1]
    if typeof recipe.item2 is \string then recipe.item2 = items[recipe.item2]
    if typeof recipe.result is \string then recipe.result = items[recipe.result]
    recipe.item1.craft ?= {}
    recipe.item2.craft ?= {}
    recipe.item1.craft[recipe.item2.name] = recipe.result
    recipe.item2.craft[recipe.item1.name] = recipe.result

recipebook=JSON.parse(localStorage.getItem('filosis-recipes')) or {}

!function learn_recipe (item1, item2, result)
    recipebook[item1] ?= {}
    recipebook[item2] ?= {}
    return if recipebook[item1][item2] is result and recipebook[item2][item1] is result
    recipebook[item1][item2]=result
    recipebook[item2][item1]=result
    saveHandler "#{saveslug}-recipes", JSON.stringify recipebook

#initial
items_initial = {}
for key, item of items
    if item.quantity > 0
        items_initial[key] = item.quantity

!function reset_items (initialize)
    for key of items
        items[key].quantity = 0
    return if not initialize
    for key, q of items_initial
        items[key]quantity = q

var pause_screen, shop_screen, refresh_shop

options_mod=[]
pause_menu_mod=[]
!function get_option_menu
    ret=
        'Back', \back
        type:\slider min:0 max:1 label:'Sound Volume',desc:"The volume of regular sound effects.", accessor sound, \volume
        type:\slider min:0 max:1 label:'Music Volume',desc:"The volume of the game music.", onswitch:(!->music.updatevolume!), accessor music, \volume
        type:\slider min:0 max:1 label:'Menu Volume',desc:"The volume of the menu sounds.", accessor menusound, \volume
        type:\slider min:0 max:1 label:'Dialog Volume',desc:"The volume of the speech effect.", accessor voicesound, \volume
        type:\slider min:0 max:100 label:'Text Speed',desc:"The speed at which dialog text is displayed.", accessor gameOptions, \textspeed
        #type:\switch label:'Instant Text', accessor gameOptions, \quicktext
        type:\switch label:'Battle Text',desc:"Enables battle text.", accessor gameOptions, \battlemessages
        type:\switch label:'Pause on Unfocus',desc:"Pauses the game when focus is lost.", onswitch:(!->game.stage.disableVisibilityChange=!gameOptions.pauseidle), accessor gameOptions, \pauseidle
        type:\switch label:'Exact Scaling',desc:"Good for screenshots.", onswitch:resize-game, accessor gameOptions, \exactscaling
        #'Sound Volume' 0
        #'Music Volume' 0
    return ret++options_mod

!function create_option_menu screen, x, y, leftside 
    #option_screen := new Screen! |> gui.frame.add-child
    #option_screen.pauseactors=true
    #option_screen.lockdialog=true
    screen.option_desc=screen.create-window x+(if leftside then -6.5 else 5.5)*WS,y+WS*2, 7,6
    screen.option_desc.text=screen.option_desc.add-text 'font', 'Option Text', HWS+2, HWS, false, 16
    screen.option_menu = screen.create-menu x,y, 6,11
    screen.option_menu.set.apply screen.option_menu, get_option_menu!
    screen.option_menu.on-change-selection=!->
        ii=@selected+@offset
        @parent.option_desc.text.change tl(@options[ii]desc)||''
    screen.option_menu.on-change-selection.call screen.option_menu

!function launch_option_menu screen
    screen.nest screen.option_menu, screen.option_desc


!function create_shop_menu
    shop_screen := new Screen! |> gui.frame.add-child
    shop_screen.pauseactors=true
    shop_screen.lockdialog=true
    shop_window = shop_screen.add-window WS, 0, 18, 11
    shop_menu = shop_screen.add-menu 2*WS, 0, 11,9, true, true

    shop_menu.inbag = shop_menu.add-text null, '', -HWS, WS*9
    shop_menu.currency = shop_menu.add-text null, '', 4*WS, WS*9

    var item_list

    !function purchase (item, cost)
        cost = Math.round cost*0.9 if player is llov or player is ebby
        item_list.push item
        return [[pad_item_name3(item, cost, null, false)+'c', {key:item.sicon, x:item.iconx, y:item.icony}], if item.unique and item.quantity>0 then 0 else ->
            exchange cost, items.cumberground, 1 item
            refresh_shop!
        ]

    shop_menu.on-change-selection=!->
        i=shop_menu.selected+shop_menu.offset-1
        if i<0
            shop_menu.inbag.change ''
        else if item_list[i].unique and item_list[i].quantity>0
            shop_menu.inbag.change 'Sold out'
        else
            shop_menu.inbag.change "Owned:"+(stattext item_list[i]quantity, 5)
        if item_list[i]
            say_now item_list[i].desc
            dialog.message.empty_buffer!

    refresh_shop :=!->
        item_list := []
        args = [\Exit callback: shop_screen.back, context: shop_screen] ++
            (purchase items.leatherarmor, 20) ++
            (purchase items.platearmor, 50) ++
            (purchase items.woodshield, 20) ++
            (purchase items.towershield, 50) ++
            (purchase items.broadsword, 30) ++
            #(purchase items.shinai, 10) ++
            (purchase items.waterbottle, 2) ++
            (purchase items.teleport, 5) ++
            (purchase items.medicine, 1) ++
            (purchase items.vial, 2) ++
            (purchase items.pinesap, 3) ++
            (purchase items.nectar, 6) ++
            (purchase items.oil, 6) ++
            (purchase items.hp1, 5) ++
            (purchase items.hp2, 10) ++
            (purchase items.sp1, 6) ++
            (purchase items.sp2, 14)
        shop_menu.set.apply shop_menu, args

        shop_menu.currency.change items.cumberground.name+":"+(stattext items.cumberground.quantity, 5)
        shop_menu.on-change-selection!


    shop_screen.kill!

!function start_shop_menu
    refresh_shop!
    shop_screen.show!
    @say "What are you looking for?"; dialog.click \ignorelock

!function create_pause_menu
    #pause_screen := new Menu 0, 0, 6, 6 |> gui.frame.add-child
    #pause_screen.kill!
    #override_cancel = pause_screen.cancel
    create_costume_menu!
    create_excel_menu!

    pause_screen := new Screen! |> gui.frame.add-child

    pause_window = pause_screen.create-window 0, 0, 14, 15
    status_window2 = pause_screen.create-window WS*6 0, 9 15, true
    status_window = pause_screen.add-window 224 0, 6 14, true
    status_menu = pause_screen.create-menu 0 0, 6 8
    skill_menu = pause_screen.create-menu 0 0, 6 9
    skill_window = pause_screen.create-window WS*6, 0, 8 15
    skill_window.skillname = skill_window.add-text null '', WS, HWS
    skill_window.skilldesc = skill_window.add-text null '', 7 WS+HWS, null 19
    item_window = pause_screen.create-window 0, 0, 14, 15
    item_window.icon = new Phaser.Sprite game, WS+5 WS+5 \item_equip |> item_window.add-child
    item_window.icon.anchor.set 0.5
    item_window.itemname = item_window.add-text null, '', IS+5, WS
    item_window.itemdesc = item_window.add-text null, '', 8, IS+WS, null, 19

    create_option_menu pause_screen, 64, 16

    pause_menu_back = callback: pause_screen.back, context: pause_screen
    pause_screen.menu=pause_menu = pause_screen.add-menu 64,32,6,8
    pause_screen.inventory=inventory_menu = pause_screen.create-menu WS*2,0, 11,15, true, true
    item_menu = pause_screen.create-menu item_window.x + 128,WS, 6,14, true
    item_menu.item = items.hp1

    pause_screen.crafting=crafting_menu = pause_screen.create-menu WS*2,WS*4, 11,11, true, true
    crafting_menu.item = items.hp1
    crafting_menu.lastitem = items.hp1
    crafting_menu.lastquantity = 0

    yicon = -WS*3
    ytext = -WS*3 - FH/2
    #crafting_menu.combinewith = crafting_menu.add-text null, 'Combine with...', -WS, -WS*3 - 5
    #item1
    crafting_menu.itemicon = new Phaser.Sprite game, 0, yicon, \item_pot |> crafting_menu.add-child
    crafting_menu.itemicon.anchor.set 0.5
    crafting_menu.itemname = crafting_menu.add-text null, '', WS, ytext#-WS*2 - 5
    # +
    crafting_menu.plus = crafting_menu.add-text null, '+', WS*2, ytext+14
    #item2
    crafting_menu.item2icon = new Phaser.Sprite game, 0, yicon+24, \item_pot |> crafting_menu.add-child
    crafting_menu.item2icon.anchor.set 0.5
    crafting_menu.item2name = crafting_menu.add-text null, '', WS, ytext+24
    # =
    crafting_menu.equal = crafting_menu.add-text null, '=', WS*2, ytext+38
    #result
    #crafting_menu.created = crafting_menu.add-text null, 'Created:', WS*5, -WS - 5
    crafting_menu.resulticon = new Phaser.Sprite game, 0, yicon+48, \item_pot |> crafting_menu.add-child
    crafting_menu.resulticon.anchor.set 0.5
    crafting_menu.resultname = crafting_menu.add-text null, '? ? ?', WS, ytext+48
    crafting_menu.resulticon.kill!
    #crafting_menu.created.kill! ; crafting_menu.resulticon.kill! ; crafting_menu.resultname.kill!

    cards = {}
    heads = {}
    for player, i in players
        head = heads[player.name] = new Phaser.Image game, 0 0 "head_#{player.name}" |> inventory_menu.add-child
        head.anchor.set 0, 9 / head.height
        head.kill!
        head.x = 110
        head.player = player
        card = cards[player.name] = new Status-Card 0 0, player |> status_window.add-child
        card.details = new Window 0 0, 9 5 |> status_window2.add-child
        card.details.card = card
        card.details.base = card.base
        for key, i in <[atk def spd lck]>
            card.details[key+1] = card.details.add-text null '', HWS+5, WS*i+9
            card.details[key+2] = card.details.add-text \font_gray '', WS*5, WS*i+9

        card.details.updatestattext =(key)!->
            switch key
            |\atk => stat=\atk;label=\ATK
            |\def => stat=\def;label=\DEF
            |\spd => stat=\speed;label=\SPD
            |\lck => stat=\luck;label=\LCK
            value = Math.ceil @card.get_stat stat
            @[key+1]change label+': '+ stattext value, 5
            return value


    status_window_revive =!->
        for key, card of cards
            card.kill! if card.alive
            card.details.kill! if status_window2.alive and card.details.alive
        for player, i in party
            card = cards[player.name]
            card.revive!
            card.y = [0,80,160][i]
            card.calc_stats!
            if status_window2.alive
                card.details.revive!
                card.details.y = card.y
                for key in <[atk def spd lck]>
                    card['old_'+key] = card.details.updatestattext key
                    card.details[key+2].change ''
                card.old_hp = Math.ceil card.get_stat \hp
            card.hptext.change ''
            card.update_stats!
    status_window.on-revive =!->
        status_window_revive ...

    status_window_revive.call status_window

    #pause_menu.set \Resume pause_menu_back,
    #    \Items launch_inventory_menu
    #    \Skills launch_skill_menu
    #    \Status launch_status_menu
    #    \Options callback:launch_option_menu, arguments:[pause_screen]
    #    \Quit quitgame
    pause_menu.set.apply pause_menu, [
        tl("Resume"), pause_menu_back,
        tl("Items"), launch_inventory_menu
        tl("Skills"), launch_skill_menu
        tl("Status"), launch_status_menu
        tl("Options"), callback:launch_option_menu, arguments:[pause_screen]
        tl("Quit"), quitgame
    ] ++ pause_menu_mod

    pause_screen.kill!

    !function launch_inventory_menu (filter={})
        pause_screen.nest filter, pause_window, inventory_menu, status_window

    #!function launch_option_menu
    #    #pause_menu.nest.apply pause_menu, get_option_menu!
    #    #option_screen.show!

    skill_menu.on-revive =!->
        forme = pause_screen.windows.0.forme
        player = pause_screen.windows.0.player
        skillset = player.skills[forme.id] if player and forme
        mode = pause_screen.windows.0.mode
        skill = pause_screen.windows.0.skill
        args = [if mode is \moveskill or mode is \placeskill then \Cancel else \Back, pause_menu_back]
        @resize @w, if mode is \addskill then 15 else if not mode then 9 else 8
        if mode is \placeskill then skill_menu.on-change-selection =(i)!->
            for ii from 1 til @buttons.length
                @buttons[ii]change @options[ii]
            if i > 0
                @buttons[i]change skill.name
        else if mode is \moveskill then skill_menu.on-change-selection =(i)!->
            ii = @objects.indexOf skill
            list = @objects.slice!
            list.splice ii, 1
            for from 0 til 5 - @objects.length
                list.push name: ' -'
            list.splice (i||ii+1) - 1, 0, skill
            for ii from 1 til @buttons.length
                @buttons[ii]change list[ii - 1]name
        else if mode is \dowhat then skill_menu.on-change-selection =(i)!->
        else skill_menu.on-change-selection =(--i)!->
            if i >= 0 and i < @objects.length
                name=@objects[i]name
                desc=(access @objects[i]desc) || ''
                desc += "\nSP:#{access @objects[i]sp}%"
                #desc += "\nEX:#{access @objects[i]ex}%" if player.excel_unlocked!
            skill_window.skillname.change name || ''
            skill_window.skilldesc.change desc || 'No skill selected'
        if mode is \addskill
            skillist = []
            for key, level of forme.skills
                skillist.push skills[key] if player.level >= level
            skillist ++= skillbook[player.name][forme.id] ++ skillbook[player.name]all ++ skillbook.all
            for sk, i in skillist by -1
                if skillist.indexOf(sk) isnt i then skillist.splice(i,1)
            skillist.sort (a,b)-> a.name.localeCompare b.name
            @objects = skillist
            for sk, i in skillist
                if sk in skillset
                    args.push sk.name, 0
                else
                    args.push sk.name, callback:launch_skill_menu, arguments:[player:player,forme:forme,mode:\placeskill,skill:sk]
        else if mode is \dowhat
            args.push \Move callback:launch_skill_menu, arguments:[player:player,forme:forme,mode:\moveskill,skill:skill],
                \Remove [(!->skillset.splice skillset.indexOf(skill), 1; save!),pause_menu_back]
        else
            if mode is \placeskill
                action = (i,skill)!->skillset[i<?skillset.length]=skill; save!
            else if mode is \moveskill
                action = (i,skill)!->skillset.splice skillset.indexOf(skill),1; skillset.splice i, 0, skill; save!
            @objects = skillset
            for sk, i in skillset
                if mode is \placeskill or mode is \moveskill
                    args.push sk.name, [callback:action,arguments:[i,skill],pause_menu_back,pause_menu_back]
                else
                    args.push sk.name, callback:launch_skill_menu, arguments:[player:player,forme:forme,mode:\dowhat,skill:sk]
            for i from 0 til 5 - skillset.length
                if mode is \placeskill or mode is \moveskill
                    args.push ' -', [callback:action,arguments:[i+skillset.length,skill],pause_menu_back,pause_menu_back]
                else
                    args.push ' -', 0
            if not mode
                args.push 'Add skill...', callback:launch_skill_menu, arguments:[player:player,forme:forme,mode:\addskill]
        @set.apply @, args
        @on-change-selection @selected


    !function launch_skill_menu (properties={})
        if properties.forme
            pause_screen.nest properties, skill_window, skill_menu, status_window
        else if p=properties.player
            if p.excel_unlocked!
                args = [\Back callback:pause_menu.cancel, context:pause_menu, \Default callback:launch_skill_menu, arguments:[player:p,forme:formes[p.name]default]]
                for key, f of formes[p.name]
                    args.push f.name, callback:launch_skill_menu, arguments:[player:p,forme:f] if f.unlocked
                pause_menu.nest.apply pause_menu, args
            else
                launch_skill_menu player:p, forme:formes[p.name]default
        else
            if party.length > 1
                args = [\Back callback:pause_menu.cancel, context:pause_menu]
                for p in party
                    args.push speakers[p.name]display, callback:launch_skill_menu, arguments:[player:p]
                pause_menu.nest.apply pause_menu, args
            else launch_skill_menu player:party.0
        skill_menu.on-change-selection skill_menu.selected

    status_menu.on-revive =!->
        item = pause_screen.windows.0.item
        mode = pause_screen.windows.0.mode
        if item
            args = [tl("Cancel"), pause_menu_back]
            for player in party
                args.push speakers[player.name]display
                args.push [callback: equip_item, arguments: [item, player], pause_menu_back]
            args.push tl("Unequip"), [callback: equip_item, arguments: [item, null], pause_menu_back] if item.equip
            @set.apply @, args
            @on-change-selection=(--i)!->
                for k, card of cards
                    if i>=0 and card.base.equip.id is item.id then card.item.load_buff!
                    else card.item.load_buff card.base.equip
                cards[party[i]name]item.load_buff item if i>=0 and i<party.length
                for k, card of cards
                    for key in <[atk def spd lck]>
                        card['new_'+key] = card.details.updatestattext key
                        diff = card['new_'+key] - card['old_'+key]
                        card.details[key+2]change (if diff<0 then '' else \+)+(stattext diff,5), (if diff<0 then \font_red else if diff>0 then \font_green else \font_gray)
                    card.new_hp = Math.ceil card.get_stat \hp
                    diff = card.new_hp - card.old_hp
                    card.hptext.change (if diff<0 then '' else \+)+(stattext diff,5), (if diff<0 then \font_red else if diff>0 then \font_green else \font_gray)
                    card.update_stats!
            @on-change-selection @selected
        else if mode is \leader
            args = [tl("Cancel"), 'back']
            for player in party
                args.push speakers[player.name]display
                args.push [callback: change_leader, arguments: [player], pause_menu_back]
            @set.apply @, args
        else
            @set tl("Back"), pause_menu_back,
                tl("Equipment"), callback: launch_inventory_menu, arguments: [sortmode:\bytype type:Item.EQUIP, action:\equip]
                tl("Change Leader"), callback: launch_status_menu, arguments: [mode:\leader]
            @on-change-selection=!->

    !function launch_status_menu (properties={})
        pause_screen.nest properties, status_window2, status_window, status_menu

    item_menu.on-revive =!->
        pause_screen.back! if @item.quantity <= 0

    inventory_menu.on-refresh =!->
        for key, head of heads
            head.kill!
            for button, i in inventory_menu.buttons
                continue unless item = inventory_menu.actions[i+inventory_menu.offset]?arguments?0
                if item.equip is head.player
                    head.y = button.y
                    head.revive!
                    break

    inventory_menu.on-revive =!->
        #status_window_revive.call status_window
        sort = pause_screen.windows.0
        args = [\Back pause_menu_back]

        if sort.sortmenu
            #SORTING MODES
            args.push \Alphabet callback: launch_inventory_menu, arguments: [sortmode:\alphabet]
            args.push \Equipment callback: launch_inventory_menu, arguments: [sortmode:\bytype type:Item.EQUIP]
            #args.push 'Key Items' callback: launch_inventory_menu, arguments: [sortmode:\bytype type:Item.KEY]
            args.push 'Special Items' callback: launch_inventory_menu, arguments: [sortmode:\special]
            args.push 'Common Items' callback: launch_inventory_menu, arguments: [sortmode:\bytype type:Item.COMMON]
            args.push \Consumables callback: launch_inventory_menu, arguments: [sortmode:\bytype type:Item.CONSUME]
            args.push \Crafting callback: launch_inventory_menu, arguments: [sortmode:\crafting]
            @set.apply @, args
            return

        #sort
        if not sort.sortmode then args.push \Sort... callback:launch_inventory_menu, arguments:[sortmenu:true]

        #inventory
        inventory = []
        for key, item of items
            continue if sort.sortmode is \bytype and item.type isnt sort.type
            continue if sort.sortmode is \crafting and not item.craft
            continue if sort.sortmode is \special and item.type isnt Item.KEY and !item.special
            inventory.push item if item.quantity > 0

        #sort by time or alphabet
        if sort.sortmode is \alphabet
            inventory.sort (a,b)-> a.name.localeCompare b.name
        else
            inventory.sort (a,b)-> b.time - a.time

        for item, i in inventory
            args.push [pad_item_name3(item), {key:item.sicon, x:item.iconx, y:item.icony}]
            if sort.action is \equip
                args.push callback:launch_status_menu, arguments:[item:item]
            else args.push callback: launch_item_menu, arguments: [item]

        @set.apply @, args

        !function launch_item_menu (item)
            item_menu.item = item
            pause_screen.nest item_window, item_menu, status_window
            args = [\Back pause_menu_back]
            if use = item.use or item.useoverworld
                switch item.target
                when \ally then args.push \Use callback:item_use_menu, arguments:[item]
                when \allies, \all then args.push \Use [callback:!->(for member in party then use member), {callback:item_used, arguments:[item]}]
                default args.push \Use [use, {callback:item_used, arguments:[item]}]
            #if item.type is Item.EQUIP then args ++= [\Equip callback:item_equip_menu, arguments:[item]]
            if item.type is Item.EQUIP
                args.push \Equip callback:launch_status_menu, arguments:[item:item]
                args.push \Unequip callback: equip_item, arguments: [item, null] if item.equip
            if item.craft?
                args.push \Combine callback: launch_crafting_menu, arguments: [item]

            item_menu.set.apply item_menu, args
            item_window.icon.load-texture item.icon || item.sicon
            item_window.icon.frame=item.iconx
            setrow item_window.icon, item.icony
            item_window.itemname.change item.name
            item_window.itemdesc.change (access item.desc) || ''

        !function launch_crafting_menu (item)
            pause_screen.nest pause_window, crafting_menu, status_window
            crafting_menu.item = item
            refresh_crafting_menu.call crafting_menu
            crafting_change_selection.call crafting_menu
            crafting_menu.on-change-selection = crafting_change_selection

        !function refresh_crafting_menu
            #if @item.quantity <= 0
            #    pause_screen.back! ; pause_screen.back!
            craftinv = []
            for key, item of inventory
                craftinv.push item if item.craft?

            args = [\Back pause_menu_back]
            for item, i in craftinv
                continue if item is @item
                args.push [pad_item_name3(item), {key:item.sicon, x:item.iconx, y:item.icony}]
                if @item.quantity<=0 or item.quantity<=0 then args.push 0
                else args.push callback: craft, arguments: [@item, item]

            @set.apply @, args
            @itemicon.load-texture @item.icon || @item.sicon
            @itemicon.frame=@item.iconx
            setrow @itemicon, @item.icony
            @itemname.change pad_item_name3(@item)

        !function crafting_change_selection
            if item2=@actions[@selected+@offset]arguments?1
                setresult.call @, @item, item2
            else
                @item2icon.kill!
                @item2name.change ''
                @resulticon.kill!
                @resultname.change ''

        !function craft (item1, item2)
            result = item1.craft[item2.name] 
            or (\glass in item1.attributes or \glass in item2.attributes) and items.shards 
            or items.cumberground
            learn_recipe item1.id, item2.id, result.id
            acquire item1, -1 true true
            acquire item2, -1 true true
            acquire result, 1 true true
            if result==items.shards
                acquire items.cumberground, 2 true true
                items.cumberground.time+=1
            result.time+=2
            #result.quantity++
            #item1.quantity --
            #item2.quantity --
            refresh_crafting_menu.call crafting_menu
            save!

            if crafting_menu.lastitem is result then crafting_menu.lastquantity++
            else crafting_menu.lastquantity = 1
            crafting_menu.lastitem = result
            #crafting_menu.created.revive!
            #crafting_menu.resultname.revive!
            #crafting_menu.resulticon.revive!
            setresult.call crafting_menu, item1, item2

        !function setresult (item1, item2)
            @item2icon.revive!
            @item2icon.load-texture item2.icon || item2.sicon
            @item2icon.frame=item2.iconx
            setrow @item2icon, item2.icony
            @item2name.change pad_item_name3(item2)
            #result=items.cumberground
            if recipebook[item1.id] and result=recipebook[item1.id][item2.id]
                result=items[result]
                @resulticon.revive!
                @resultname.change pad_item_name3(result, result.quantity)
                @resulticon.load-texture result.icon || result.sicon
                @resulticon.frame=result.iconx
                setrow @resulticon, result.icony
            else
                @resulticon.kill!
                @resultname.change '? ? ?'



        /*
        !function item_equip_menu (item)
            args = ['Equip to...' callback:item_menu.cancel, context:item_menu]
            for player in party
                continue if player.equip is item
                args.push speakers[player.name]display
                args.push callback: equip_item, arguments: [item, player]
            args.push \Unequip callback: equip_item, arguments: [item, null] if item.equip
            item_menu.nest.apply item_menu, args
            #@refresh!
        */
        !function item_use_menu (item)
            args = ['Cancel' callback:item_menu.cancel, context:item_menu]
            for player in party
                args.push speakers[player.name]display
                args.push [{callback:item.use || item.useoverworld, arguments:[player], context:item}, {callback:item_used, arguments:[item]}]
            item_menu.nest.apply item_menu, args

    !function item_used (item)
        item.consume!
        item.time=Date.now!
        pause_screen.inventory.offset=0
        pause_screen.back!
    !function equip_item (item, player)
        itemequip = item.equip
        player?equip.equip = null
        itemequip?equip = buffs.null
        player?equip = item
        item.equip = player
        pause_screen.back!
        save!

    pause_screen.pauseactors=true
    pause_screen_show =(e)!->
        return if actors.paused or switches.cinema or e?button not in [undefined,2]
        pause_screen.show!
        return false
    keyboard.cancel.onDown.add pause_screen_show, pause_screen, 1
    game.input.onDown.add pause_screen_show, pause_screen, 1

!function equip_item (item, player, nosave=false)
    itemequip = item.equip
    player?equip.equip = null
    itemequip?equip = buffs.null
    player?equip = item
    item.equip = player
    save! unless nosave

function trim_quantity (quantity, digits=2)
    return if quantity >= Math.pow(10,digits) then '*'+quantity.toString!slice quantity.toString!length - digits + 1 else quantity
function pad_item_name (item, quantity=item.quantity, digits=5, hide_unique=true)
    #quantity = trim_quantity quantity, digits
    quantity = stattext quantity, digits
    pad('             ', item.name) + if item.unique and hide_unique then '' else " #{quantity}"
#function item_has_quantity (item)
#    return false if item.unique or item.type in [Item.EQUIP, Item.KEY]
#    return true
function pad_item_name2 (item, places=16, quantity=item.quantity, hide_unique=true)
    return item.name if item.unique and hide_unique
    digits= places - item.name.length
    q=stattext quantity, digits
    q=trim_quantity quantity, digits if q.toString!length>digits
    return item.name+pad(' '*digits,q,true)
#pads according to pixel length instead of char count.
!function pad_item_name3(item,quantity=item.quantity,digits=5,hide_unique=true,plen=13*FW)
    text=item.name
    spacewidth=charlen(' ')
    nspacewidth=charlen("\u2009")
    width=0
    for char in text
        width+=charlen(char)
    while width < plen
        if plen - width > spacewidth
            text+=' '
            width+=spacewidth
        else
            text+="\u2009"
            width+=nspacewidth
    if !item.unique or !hide_unique then text+=" "+stattext quantity, digits
    return text
!function pad_item_name4 (item, places=16, quantity=item.quantity,hide_unique=true)
    return item.name if item.unique and hide_unique
    width=0
    for char in item.name
        width+=charlen(char)
    digits=(places*FW - width)/FW.|.0
    q=stattext quantity, digits
    q=trim_quantity quantity, digits if q.toString>digits
    return item.name+pad("\u2007"*digits,q,true)


var title_screen
!function create_title_menu
    title_screen := new Screen! |> gui.title.add-child
    title_screen.nocancel = true
    title_menu = title_screen.add-menu WIDTH - WS*6 HEIGHT - WS*6 6 6
    load_window = title_screen.create-window 0 0 20 15 true
    load_menu = title_screen.create-menu 0, -WS, 20 17 true null 5*WS

    create_option_menu title_screen, WIDTH - WS*6, HEIGHT - WS*11, true

    largs = []
    files = getFiles!
    filelist = []
    filecount = Object.keys(files)length <? 3
    for name, file of files
        filelist.push file
        largs.push name, callback:load_from_menu, arguments:[name]
    load_menu.set.apply load_menu, largs
    load_menu.y = (3 - filecount)*40 - WS
    #largs.length/2 * load_menu.BH - WS
    windows = []
    for i from 0 til filecount
        windows.push <| win = new Window 0 (3 - filecount)*40 + i*load_menu.BH, 20, 5 |> load_window.add-child
        win.ports=[]
        for j from 0 til 3
            win.ports.push <| new Phaser.Sprite game, 5*WS*j+WS*3, -WS+5, '' |> win.add-child
            win.ports[j]item = new Phaser.Sprite game, WS, WS*3, '' |> win.ports[j]add-child
            (win.ports[j]level = new Text \font_yellow 'Level' WS*5, WS*5 |> win.ports[j]add-child)anchor.set 0.5, 0
    args = ['New Game' newgame]
    if filecount>1 #multiplesaves
        args.unshift 'Continue' launch_load_menu if largs.length>0
    else
        args.unshift 'Continue' callback:load, arguments:[Object.keys(getFiles!)0] if largs.length>0
    args.push 'Options' callback:launch_option_menu, arguments:[title_screen]
    #if filecount>1 #multiplesaves
    #    args.push 'Delete' callback:launch_load_menu, arguments:['delete'] if largs.length>0
    args.push 'Manage Saves' !->
        savemanager.readFiles();
        saveman.style.display='block'
    title_menu.set.apply title_menu, args
    title_screen.show!

    !function launch_load_menu(properties)
        title_screen.nest properties, load_window, load_menu

    !function load_from_menu (file)
        if title_screen.windows.0 is 'delete'
            deleteFile file
            quitgame!
        else
            load file

    #!function launch_option_menu
    #    #title_menu.nest.apply title_menu, get_option_menu!
    #    #option_screen.show!
    

    load_menu.on-refresh =!->
        for win, i in windows
            for j from 0 til 3
                if fp = filelist[i+@offset]party[j]
                    win.ports[j]revive!
                    win.ports[j]load-texture get_costume fp.name, 0, fp.costume
                    win.ports[j].frame=get_costume fp.name, 0, fp.costume, \bframe
                    win.ports[j]level.change ''+xp-to-level fp.xp
                    item = win.ports[j]item
                    win.ports[j]item.load-texture access items[fp.item]?icon
                    win.ports[j]item.frame=items[fp.item]?iconx or 0
                    setrow win.ports[j]item, (items[fp.item]?icony or 0)
                else
                    win.ports[j]kill!



var costume_screen
!function create_costume_menu
    costume_screen := new Screen! |> gui.frame.add-child
    costume_screen.pauseactors=true

    costume_window =  costume_screen.add-window WIDTH-7*WS, 0 7 15 true
    costume_menu = costume_screen.add-menu WIDTH-7*WS, -WS, 7 17 true null 5*WS

    costume_menu.windows = []
    for i from 0 til 3
        costume_menu.windows.push <| w = new Window 0 i*5*WS, 7 5 |> costume_window.add-child
        w.port = new Phaser.Sprite game, (w.w-6)*WS+5, 5-WS, '' |> w.add-child

    costume_screen.launch =(p)!->
        if typeof p is \object then p = p.name
        costume_menu.player = p
        costume_menu.offset = 0
        #args = [\Default callback:set_costume, arguments:[p,null]]
        args = []
        costume_menu.costumes = []
        for key,costume of costumes[p]
            #continue unless costume.unlocked
            args.push costume.name, callback:set_costume, arguments:[p,key]
            costume_menu.costumes.push key
        costume_menu.set.apply costume_menu, args
        costume_screen.show!

    costume_menu.on-refresh =!->
        for win, i in @windows
            win.revive!
            i = i+@offset
            if i >= @costumes.length then win.kill!
            else
                win.port.load-texture get_costume @player, 0, @costumes[i]
                win.port.frame=get_costume @player, 0, @costumes[i], \bframe

    set_costume =(p,c)!->
        if typeof p is \string then p = players[p]
        p.costume = c
        update_costume p, c
        save!
        costume_screen.back!

!function update_costume p, c
    #console.debug p.name
    if !c
        if p.key isnt p.name then p.load-texture p.name
        p.setrow 0
        return 
    costume=costumes[p.name][c]
    if not costume
        return console.warn "costume #c doesn't exist."
    if costume.csheet and costume.csheet isnt p.key
        p.load-texture costume.sheet
    if costume.crow then p.setrow costume.crow
    else p.setrow 0

var excel_screen
!function create_excel_menu
    excel_screen := new Screen! |> gui.frame.add-child
    excel_screen.pauseactors=true

    excel_window = excel_screen.add-window 0 WS*3.5 20 8 false
    excel_menu = excel_screen.add-menu 0 WS*3 20 5 true null
    excel_menu.horizontalmove=true

    for b, i in excel_menu.buttons
        if i is 0
            b.BH=WS
            continue
        else
            b.BW=excel_menu.w*HWS - 10
            b.x = b.BW*(i-1) + 10*i
            b.y = 5*WS
            b.BH = WS*7
            #b.y=excel_menu.buttons[1].y
        #excel_menu.windows.push <| w = new Window 0 i*5*WS, 7 5 |> excel_window.add-child
        b.port = new Phaser.Sprite game, WS*3, -2*WS-3, '' |> b.add-child
        b.formname = b.add-child new Text null, 'NAME', WS, -WS*3+4
        b.formdesc = b.add-child new Text null, 'DESC', 0, -WS*2, null, 16
    #excel_menu.windows.0.resize 7 15

    excel_screen.launch =(p)!->
        if typeof p is \object then p = p.name
        excel_menu.player = players[p]
        excel_menu.offset = 0
        args = [\Cancel callback: @back, context: @]
        excel_menu.forms = []
        for key,form of formes[p]
            continue if key is \default
            excel_menu.forms.push key
            if formes[p][key]unlocked
                args.push '', 0
                continue
            args.push '', callback:unlock_form, arguments:[p,key]
        excel_menu.set.apply excel_menu, args
        for b, i in excel_menu.buttons
            continue if i is 0
            form=formes[p][excel_menu.forms[i-1]]
            b.formname.change form.name, if excel_menu.actions[i] then 'font_yellow' else 'font_gray'
            b.formdesc.change form.desc, if excel_menu.actions[i] then 'font' else 'font_gray'
        excel_screen.show!
        pause_screen.exit!

    excel_menu.on-refresh =!->
        for b, i in @buttons
            continue if i is 0
            #if i >= @costumes.length then win.kill!
            #else win.port.load-texture get_costume @player, 0, @costumes[i]
            b.port.load-texture get_costume @player.name, i, @player.costume
            b.port.frame=get_costume @player.name, i, @player.costume, \bframe
    unlock_form =(p,c)!->
        #formes[p][c]unlocked=true
        sound.play \itemget
        unlock_forme p, c
        items.excel.quantity--
        #switches.sp_limit++
        save!
        excel_screen.back!

#========================================================================
# Overworld Mobs
#========================================================================
class Mob extends Actor
    ->
        super 0,0,'mob_slime'
        @kill!
        @animations.add 'simple', null, 3, true
        @battle = encounter.sanishark
        @setautoplay true
        @pattern = @@patterns.basic
        @waterwalk = false
        @landwalk = true
        @flying = false
        @lifetime=0
        @prevtime=0
        @dontcheck=0 #hopefully this fixes the bug
        @toughness=0
    @patterns = {}
    @types = {}
    spawn: (@x,@y,type)!->
        if Math.random!<0.04 #or true
            if switches.llovsick1 is 4 and switches.beat_game and llov not in party and switches.map isnt \void
                type=Mob.types.llov
            #else if switches.revivalchikun
        @anchor.set 0.5 1.0
        @rotation=0
        Dust.summon @
        @lifetime=0
        @prevtime=Date.now!
        @revive!
        @loadTexture type.key, 0 unless @key is key
        @toughness=0+(if Math.random!<0.07 then 1+(if Math.random!<0.25 then 1 else 0) else 0)
        @tint= if @toughness>0 then 0xff0000 else 0xffffff
        @pattern = Mob.patterns[type.pattern]
        @pattern.start?call @
        #encounterlist = access.call @, type.encounters
        #@battle = encounter[encounterlist[Math.floor Math.random! * encounterlist.length]]
        @mobtype=type
        if type.oncollide
            @battle=null
            @oncollide=type.oncollide
        else
            @battle=true
            @oncollide=undefined
        @waterwalk = type.waterwalk ?false
        @landwalk = type.landwalk ?true
        @flying = type.flying ?false
        @speed = type.speed ?60
        @add_simple_animation type.aspeed ?3
        if type.frames
            @animations.add 'simple', type.frames, type.aspeed ?3, true
        @animations.play 'simple'
        @random_frame!
        @cancel_movement!
        @dontcheck=5 #hopefully this fixes the bug

    random_frame: Doodad::random_frame

    onbattle: !->
        @terrain=getTileUnder(@)?properties.terrain or \water
        encounterlist = access.call @, @mobtype.encounters
        @battle = encounter[encounterlist[Math.floor Math.random! * encounterlist.length]]

    update: !->
        if @alive
            @lifetime += (Date.now! - @prevtime) <? 100
            @prevtime=Date.now!
            if switches.cinema or distance(@, player) > RADIUS or @lifetime > 10000
                @poof!
            else if switches.llovsick1 is true and distance(@,llov)<100
                @poof!
            else if temp.repel>0 and distance(@,player)<100
                @poof!
            else
                for nospawn in spawn_controller.nospawn
                    continue unless require_switch nospawn
                    @poof! if distance(@, nospawn) < nospawn.properties.radius*TS
        return if not @alive
        @pattern!
        #if typeof @mobtype.update is \function
        #    @mobtype.update.call @
        --@dontcheck if @dontcheck>0 #hopefully this fixes the bug
    update-paused: !->
        @prevtime=Date.now!

    physics_update: !->
        if not @flying and (tile_collision_recoil @, map.named-layers.tile_layer, @waterwalk, @landwalk) ~= true
            @pattern.retry? ...

#========================================================================
# Mob Patterns
#========================================================================

Mob.patterns.basic =!->
    @timer ?= 1000
    @timer += delta
    if @timer > 1000
        @pattern.retry ...
Mob.patterns.basic.retry =!->
    @goal.x = @x; @goal.y = @y
    mov = 4*TS
    switch Math.floor Math.random!*4
    | 0 => @goal.x += mov
    | 1 => @goal.y += mov
    | 2 => @goal.x -= mov
    | 3 => @goal.y -= mov
    #gravitate
    @goal.x += (player.x - @x)/10
    @goal.y += (player.y - @y)/10
    #reset timer
    @timer = 0
Mob.patterns.basic.start =!->
    @timer=1000
Mob.patterns.swoop =!->
    return unless @goal.x is @x and @goal.y is @y
    @goal.x = player.x*2 - @x
    @goal.y = player.y*2 - @y
Mob.patterns.fly =!->
    return unless @goal.x is @x and @goal.y is @y
    @goal.x = player.x + Math.random!*TS*12 - TS*6
    @goal.y = player.y + Math.random!*TS*12 - TS*6
Mob.patterns.guard =!->
    @goal.x = @x; @goal.y = @y
Mob.patterns.circle =!->
    @timer += delta
    if @timer > 4000
        @timer -= 4000
    @goal.x = player.x + Math.sin(HPI*@timer/1000+@offset)*TS*6
    @goal.y = player.y + Math.cos(HPI*@timer/1000+@offset)*TS*6
Mob.patterns.circle.start =!->
    @timer=1000
    @offset=Math.random!*4000
Mob.patterns.arrow =!->
    if not @launched
        @rotation=angleRAD(player,@)+HPI
    if (distance @, player) < 64 and not @launched
        @launched=true
        @goal.x = player.x*2 - @x
        @goal.y = player.y*2 - @y
    else if @launched and @goal.x is @x and @goal.y is @y
        @poof!
Mob.patterns.arrow.start =!->
    @launched=false
    @anchor.set 0.5 0.5
Mob.patterns.jitter =!->
    @goal.x = player.x + Math.random!*TS*12 - TS*6
    @goal.y = player.y + Math.random!*TS*12 - TS*6

#========================================================================
# Mob Types
#========================================================================

Mob.types.slime =
    pattern: \basic
    encounters: ->
        return <[cancer3 sally sally sally_throne]> if switches.map is \labdungeon
        return <[greblin4 greblin5]> if switches.map is \deathtunnel or switches.map is \deathdomain
        return <[earth_slime cancer]> if switches.map in <[earth earth2 basement1]>
        return <[deadworld_slime deadworld_megaslime deadworld_megaslime]> if switches.map is \deadworld
        return <[delta_slime delta_megaslime]> if !switches.soulcluster or switches.map is \delta
        return <[slime]> if averagelevel!<3
        return <[slime slime2]> if averagelevel!<6
        return <[slime2 megaslime]>
    key: \mob_slime

Mob.types.ghost =
    pattern: \fly
    encounters: ->
        return <[skullghost3]> if switches.map in <[earth deathtunnel deathdomain]>
        return <[dw_ghost2 skullghost skullghost]> if switches.map is \deadworld
        return <[ghost ghost ghost2]>
    key: \mob_ghost
    aspeed: 10
    flying: true

Mob.types.wisp =
    pattern: \circle
    encounters: ->
        terrain=getTileUnder(@)?properties.terrain or \water
        return <[skulurker]> if terrain is \water
        return <[skulmander skulmander2]>
    key: \mob_wisp
    aspeed: 10
    speed: 50
    flying: true

Mob.types.fish =
    pattern: \basic
    encounters: ->
        return <[eel]> if switches.map is \tunneldeep
        terrain=getTileUnder(@)?properties.terrain or \water
        return <[lurker lurker2]> if terrain is \water
        return <[sanishark]>
    key: \mob_ripple
    aspeed: 7
    waterwalk: true
    landwalk: false

Mob.types.bat =
    pattern: \fly
    encounters: <[bat bat2]>
    key: \mob_bat
    aspeed: 8
    flying: true

Mob.types.flytrap =
    pattern: \guard
    encounters:->
        return <[delta_mantrap]> if switches.map is \delta
        return <[mantrap]>
    key: \mob_flytrap
    aspeed: 8

Mob.types.corpse =
    pattern: \guard
    encounters: <[graven]>
    key: \mob_corpse
    aspeed: 2

Mob.types.wraith =
    pattern: \fly
    encounters: <[wraith]>
    key: \mob_wraith
    flying: true
    aspeed: 5

Mob.types.arrow =
    pattern: \arrow
    encounters: ->
        return <[tengu wolf cancer wolf]> if switches.map is \earth2
        return <[woolyrhino wolf rhinowolf]> if switches.map is \earth
        terrain=getTileUnder(@)?properties.terrain or \water
        return <[tengu]> if terrain is \water
        return <[tengu rhinosaurus rhinosaurus rhinosaurus]>
    key: \mob_arrow
    aspeed: 3
    speed: 160
    flying: true

Mob.types.glitch =
    pattern: \jitter
    encounters: ->
        return <[throne]> if switches.map is \labdungeon
        return <[void0 void1 void2 void3 void4]> if switches.map is \void
        return <[polyduck]>
    key: \mob_glitch
    flying: true
    aspeed: 8    

Mob.types.llov =
    pattern: \guard
    key: \mob_llov
    aspeed: 8
    frames: [0,1,0,2]
    oncollide: !->
        warp_node 'void', 'landing', 'down'
    #update: !->
    #    @frame= if Math.random!<0.5 then 0 else Math.random!*3.|.0
    #    #@frame=Math.random!*3.|.0

#========================================================================
# ETC
#========================================================================

class Dust extends Phaser.Sprite
    ->
        super game, 0 0 'dust'
        @anchor.set 0.5 1.0
        @animations.add 'simple', null, 7, false
        Dust.list.push @
        @kill!
    @list = []
    @summon = (x,y)!->
        if not y?
            y = x.y
            x = x.x
        dust = null
        for d in Dust.list
            dust = d unless d.alive
        return unless dust?
        dust.revive!
        dust.animations.play 'simple' null false true
        dust.x = x
        dust.y = y
        
var mobs, dustclouds
!function create_mobs
    mobs := []
    for from 0 til 10
        mobs.push <| new Mob!
    dustclouds := game.add.group undefined, 'dustclouds'
    for from 0 til 14
        new Dust! |> dustclouds.add-child
!function set_mobs
    for mob in mobs
        mob.kill!
    dustclouds |> game.world.bring-to-top
    spawn_controller.nospawn = []
    spawn_controller.spawners = []

spawn_controller.timer = 10000
!function spawn_controller
    return if not player.moving or switches.cinema or not switches.spawning
    or player.terrain is \overpass or player.terrain is \bridge
    spawn_controller.timer -= delta
    if temp.repel then temp.repel -= delta
    #if game.time.elapsed-since(spawn_controller.timer) > 10000 and Math.random! > 0.9
    if spawn_controller.timer < 0
        spawned=0
        for from 0 til 10
            if spawn_mob! then spawned++
        if spawned>0
            #spawn_controller.timer = 9000 + Math.random!*400 .|. 0
            spawn_controller.timer = (getmapdata \mobtime) + Math.random!*400 .|. 0
            sound.play \flame
        
!function spawn_mob (key)
    for mob, i in mobs
        return if i>= getmapdata \mobcap
        break unless mob.alive
    return if mob.alive
    radius=96
    s = normalize x: Math.random!*10 - 5, y: Math.random!*10 - 5
    s.x = player.x + s.x*radius; s.y = player.y + s.y*radius
    if s.x is player.x and s.y is player.y
        warn "MONSTER SPAWNED IN SAME PLACE AS PLAYER"
    for nospawn in spawn_controller.nospawn
        continue unless require_switch nospawn
        return if distance(s, nospawn) < nospawn.properties.radius*TS
    type=access switches.spawning, map.getTile(s.x/TS.|.0, s.y/TS.|.0, map.tile_layer, true)
    return unless type
    for spawner in spawn_controller.spawners
        continue unless require_switch spawner
        type = Mob.types[spawner.properties.type] if distance(s, spawner) < spawner.properties.radius*TS
    return if not type.flying and tile_point_collision mob, s, map.tile_layer, type.waterwalk ?false, type.landwalk ?true
    mob.spawn s.x, s.y, type
    return true

#========================================================================
# Monster types
#========================================================================
palette=
    slime1: [0x94d1d2,0x993eff,0x9999ff]#regular
    slime2: [0xb7ec9a,0x2f8d88,0x6fcfa3]#green
    slime3: [0xf185b3,0xd42c50,0xfe6881]#red/pink
    #slime4: [0xf0b576,0xe42f1c,0xfe7a68]#orange
    slime4: [0xfed568,0xe41c75,0xff9567]#yellow
    slime5: [0xa32ee6,0x282b70,0x9668fe]#purple
    slime6: [0xb3618d,0x481a28,0x944c6a]#gray
    mantrap1: [0x5eb600,0x216b4b,0xf34f23,0x8e002f,0xb1ff3b,0x2ec438]
    mantrap2: [0xb0b600,0x6b4b21,0xa34343,0x6c0a18,0xe0b0df,0xc22e96]
    mantrap3: [0xb62b00,0x800c3a,0xa050c6,0x4d008e,0xb0dae0,0x2e85c2]
    skulliki1: [0xcbbb82,0x712f77,0xb20e15]
    skulliki2: [0xe4bfe5,0x881010,0x780e68]
    skulliki3: [0xf28aa0,0x271f65,0x2f8600]
    bat1: [0xdedd48,0x775d67,0x3c3747]
    bat2: [0xde484c,0x785b50,0x482828]
    bat3: [0xe67700,0x873c8c,0x421858]
    skulmander1: [0xcbbb82,0x712f77,0xb62b00]
    skulmander2: [0xd2d2d2,0x2f3277,0x22b600]
    skulmander3: [0xca92a1,0x772f3e,0x4909ff]
    lurker1: [0xd248c7, 0x47458f, 0xc4dddd]
    lurker2: [0xf9213a, 0x811d43, 0xeec775]
    lurker3: [0xac6ab6, 0x17432a, 0x8fb284]
    tengu1: [0xc52f11, 0x348e4c, 0x7d3048, 0xfffc93]
    tengu2: [0xebd9e4, 0xc14545, 0x63307e, 0xa3ffef]
    tengu3: [0xd6b018, 0x596fa7, 0x2c663e, 0xfe90a4]
    rhino1: [0xa4a4a4, 0x67627e, 0x5e415f, 0x7d3048]
    rhino2: [0xc08484, 0x8c3c5a, 0x5549a1, 0x820a2f]
    rhino3: [0xaa8db7, 0x594880, 0x289d1f, 0x820a21]
    wrhino1: [0xaba9cb, 0x4f607b, 0xd19e67, 0x5e2d2a]
    wrhino2: [0xe1a6a6, 0x8f3b61, 0xb56c68, 0x7d3048]
    wrhino3: [0xc8cba9, 0x7b6b4f, 0x676cd1, 0x2a455e]
    wolf1: [0xfc3900,0xcac6dc,0xab76c6]
    wolf2: [0xff8e00,0x5d5872,0x332a38]
    wolf3: [0x0173ff,0x8a6d54,0x502e40]

Monster.animData={}
Monster.animData.monster_slime=
    speed:9
Monster.animData.monster_slime2=
    frames:[0,1,2,1]
Monster.animData.monster_graven=
    getFrame:-> if Math.random()<@stats.sp/2 then 1 else if Math.random()>=0.1 then 0 else if Math.random()<0.5 then 2 else 3 
Monster.animData.monster_lurker=
    frames:[0,1,2,3,4,5,6,7,8,9,10,11,12,13,13,13,13,13,13]
    speed:10
Monster.animData.monster_bat=
    frames:[
        0 0 1 1 2 2 1 1, 0 0 1 1 2 2 1 1, 0 0 1 1 2 2 1 1, 0 0 1 1 2 2 1 1
        3 4 5 4 3 1, 3 4 5 4 3 1
        0 0 1 1 2 2 1 1, 0 0 1 1 2 2 1 1, 0 0 1 1 2 2 1 1, 0 0 1 1 2 2 1 1, 0 0 1 1 2 2 1 1
        3 4 5 4 3 1, 3 4 5 4 3 1, 3 4 5 4 3 1
    ]
    speed:16

Monster.animData.monster_mantrap=
    frames1:[0 1 2 3 2 1]
    frames2:[4 5 6]
    getFrame:->
        @animData_cycle ?= @animData.frames1
        @animData_frame ?= Math.floor(Math.random()*@animData_cycle.length)
        @animData_time ?= 0

        @animData_time+=delta
        frametime = 120-80*@stats.sp
        if @animData_time>=frametime
            @animData_time=0
            @animData_frame++
        if @animData_frame>=@animData_cycle.length
            @animData_cycle = if Math.random()<0.8 then @animData.frames1 else @animData.frames2
            @animData_frame=0
        @animData_cycle[@animData_frame]

Monster.animData.monster_polyduck=
    getFrame:->
        @animData_frame ?= Math.floor(Math.random()*12)
        @animData_time ?= 0
        @animData_time+=delta
        if @animData_time >= 100
            @animData_time=0
            @animData_frame++
            @animData_glitch=Math.random()<0.1
        if @animData_frame>=12
            @animData_frame=0
        if @animData_glitch then (if @animData_frame%4==3 then 13 else @animData_frame%4+12) else @animData_frame

Monster.animData.monster_woolyrhino= Monster.animData.monster_rhinosaurus=
    frames:[0,1,2,1]
    speed:4

Monster.animData.monster_tengu=
    frames:[
        0 0 1 1 2 2 3 3 2 2 1 1, 0 0 1 1 2 2 3 3 2 2 1 1, 0 0 1 1 2 2 3 3 2 2 1 1
        0 1 2 3 2 1, 0 1 2 3 2 1
    ]
    speed:14


Monster.types={}
Monster.types.slime =
    name: 'Slime'
    key: 'monster_slime'
    skills: [skills.attack, skills.poison]
    drops: 
        {item:\sludge, chance:50, quantity:1}
        {item:\medicine, chance:25, quantity:1}
        {item:\starpuff, chance:2, quantity:1}
    xp: 60
    hp:80
    atk:80
    def:50
    attributes: <[poison]>
    pal: palette.slime1
    pal2: palette.slime2
    pal3: palette.slime3

Monster.types.slimex =
    name: 'Slime'
    key: 'monster_slime'
    skills: [skills.attack, skills.poison]
    drops: 
        {item:\sludge, chance:100, quantity:1}
        {item:\medicine, chance:50, quantity:1}
        {item:\starpuff, chance:5, quantity:1}
    xp: 75
    hp:90
    atk:90
    def:60
    attributes: <[poison]>
    pal: palette.slime1
    pal1: palette.slime2
    pal2: palette.slime3
    pal3: palette.slime4

Monster.types.slimexx =
    name: 'Slime'
    key: 'monster_slime'
    skills: [skills.attack, skills.poison]
    drops: 
        {item:\sludge, chance:100, quantity:1}
        {item:\sludge, chance:50, quantity:1}
        {item:\medicine, chance:75, quantity:1}
        {item:\medicine, chance:50, quantity:1}
        {item:\starpuff, chance:10, quantity:1}
    xp: 90
    hp:100
    atk:100
    def:70
    attributes: <[poison]>
    pal: palette.slime1
    pal1: palette.slime3
    pal2: palette.slime4
    pal3: palette.slime5

Monster.types.slime2 =
    name: 'Mega Slime'
    key: 'monster_slime2'
    skills: [skills.strike, skills.poison]
    drops: [item:\sludge, chance:100, quantity:1]
    xp: 85
    speed:90
    def:60
    attributes: <[poison]>
    ondeath: ->
        #monsters.push <| battle.add-child-at (new Monster this.x - 2*WS, this.y, \slime, this.level),battle.children.indexOf this
        #monsters.push <| battle.add-child-at (new Monster this.x + 2*WS, this.y, \slime, this.level),battle.children.indexOf this
        #battle.monsters.push new Monster
        battle.addmonster (new Monster this.x - 2*WS, this.y, \slime, this.level),battle.children.indexOf this
        battle.addmonster (new Monster this.x + 2*WS, this.y, \slime, this.level),battle.children.indexOf this
    pal: palette.slime1
    pal2: palette.slime2
    pal3: palette.slime3

Monster.types.slime2x =
    name: 'Mega Slime'
    key: 'monster_slime2'
    skills: [skills.strike, skills.poison]
    drops: [item:\sludge, chance:100, quantity:1]
    xp: 92
    hp:110
    speed:100
    def:70
    attributes: <[poison]>
    ondeath: ->
        battle.addmonster (new Monster this.x - 2*WS, this.y, \slimex, this.level),battle.children.indexOf this
        battle.addmonster (new Monster this.x + 2*WS, this.y, \slimex, this.level),battle.children.indexOf this
    pal: palette.slime1
    pal1: palette.slime2
    pal2: palette.slime3
    pal3: palette.slime4

Monster.types.slime2xx =
    name: 'Mega Slime'
    key: 'monster_slime2'
    skills: [skills.strike, skills.poison]
    drops: [item:\sludge, chance:100, quantity:1]
    xp: 100
    hp:120
    speed:100
    def:80
    attributes: <[poison]>
    ondeath: ->
        battle.addmonster (new Monster this.x - 2*WS, this.y, \slimexx, this.level),battle.children.indexOf this
        battle.addmonster (new Monster this.x + 2*WS, this.y, \slimexx, this.level),battle.children.indexOf this
    pal: palette.slime1
    pal1: palette.slime3
    pal2: palette.slime4
    pal3: palette.slime5

Monster.types.slimez =
    name: 'Slime'
    key: 'monster_slime'
    skills: [skills.attack, skills.poison]
    drops: 
        {item:\sludge, chance:100, quantity:1}
        {item:\sludge, chance:50, quantity:1}
        {item:\medicine, chance:75, quantity:1}
        {item:\medicine, chance:50, quantity:1}
        {item:\starpuff, chance:15, quantity:1}
    xp: 90
    hp:100
    atk:100
    def:100
    attributes: <[poison]>
    pal: palette.slime1
    pal1: palette.slime4
    pal2: palette.slime5
    pal3: palette.slime6

Monster.types.slime2z =
    name: 'Mega Slime'
    key: 'monster_slime2'
    skills: [skills.strike, skills.poison]
    drops: [item:\sludge, chance:100, quantity:2]
    xp: 100
    hp:150
    speed:100
    def:100
    attributes: <[poison]>
    ondeath: ->
        battle.addmonster (new Monster this.x - 3*WS, this.y - HWS, \slimez, this.level),battle.children.indexOf this
        battle.addmonster (new Monster this.x, this.y+HWS, \slimez, this.level),battle.children.indexOf this
        battle.addmonster (new Monster this.x + 3*WS, this.y - HWS, \slimez, this.level),battle.children.indexOf this
    pal: palette.slime1
    pal1: palette.slime4
    pal2: palette.slime5
    pal3: palette.slime6

Monster.types.ghost =
    name: 'Beholden'
    key: 'monster_ghost'
    skills: [skills.attack]
    drops:
        {item:\gravedust, chance:25, quantity:1}
        {item:\gravedust, chance:25, quantity:1}
        {item:\cloth, chance:25, quantity:1}
        {item:\starpuff, chance:5, quantity:1}
    xp: 75
    hp:80
    atk:75
    def:70
    attributes: <[ghost]>
    escape: 70

Monster.types.skullghost =
    name: 'Skulliki'
    key: 'monster_skullghost'
    skills: [skills.strike, skills.curse]
    drops:
        {item:\gravedust, chance:75, quantity:1}
        {item:\cloth, chance:50, quantity:1}
        {item:\starpuff, chance:5, quantity:1}
    xp: 87
    hp:95
    atk:90
    def:80
    attributes: <[ghost]>
    escape: 80
    pal: palette.skulliki1
    pal2: palette.skulliki2
    pal3: palette.skulliki3

Monster.types.skulmander =
    name: 'Skulmanter'
    key: 'monster_skulmander'
    skills: [skills.burn]
    drops:
        {item:\gravedust, chance:70, quantity:1}
        {item:\gravedust, chance:20, quantity:1}
        {item:\cinder, chance:100, quantity:1}
        {item:\cinder, chance:50, quantity:1}
        {item:\starpuff, chance:10, quantity:1}
    xp: 100
    hp:100
    atk:120
    def:120
    speed:120
    attributes: <[ghost]>
    escape: 90
    pal: palette.skulmander1
    pal2: palette.skulmander2
    pal3: palette.skulmander3

Monster.types.lurker =
    name: 'Lurker'
    key: 'monster_lurker'
    skills: [skills.drown]
    xp: 100
    hp:115
    atk:80
    def:115
    speed:100
    attributes: <[fish carnivore]>
    escape: 60
    drops:
        {item:\frozenflesh, chance:100, quantity:1}
        {item:\frozenflesh, chance:50, quantity:1}
        {item:\silverdust, chance:60, quantity:1}
        {item:\starpuff, chance:10, quantity:1}
    pal: palette.lurker1
    pal2: palette.lurker2
    pal3: palette.lurker3

Monster.types.bat =
    name: 'Vampire Bat'
    key: 'monster_bat'
    skills: [skills.attack, skills.vbite]
    drops:
        {item:\venom, chance:50, quantity:1}
        {item:\fur, chance:100, quantity:1}
        {item:\fur, chance:50, quantity:1}
        {item:\silverdust, chance:20, quantity:1}
        {item:\starpuff, chance:10, quantity:1}
    xp: 90
    hp:100
    atk:95
    def:60
    speed:200
    escape: 75
    pal: palette.bat1
    pal2: palette.bat2
    pal3: palette.bat3

Monster.types.mantrap =
    name: 'Mantrap'
    key: 'monster_mantrap'
    skills: [skills.strike]
    drops:
        {item:\plantfiber, chance:100, quantity:3}
        {item:\plantfiber, chance:50, quantity:3}
        {item:\aloevera, chance:100, quantity:2}
        {item:\aloevera, chance:66, quantity:2}
        {item:\aloevera, chance:66, quantity:1}
        {item:\thornarmor, chance:100, quantity:1}
        {item:\starpuff, chance:10, quantity:1}
        {item:\bugbits, chance:66, quantity:3}
        {item:\bugbits, chance:66, quantity:2}
    xp: 150
    hp:200
    atk:500
    def:200
    speed:25
    attributes: <[plant carnivore]>
    escape:40
    pal: palette.mantrap1
    pal2: palette.mantrap2
    pal3: palette.mantrap3

Monster.types.graven =
    name: 'Graven'
    key: 'monster_graven'
    skills: [skills.attack]
    drops:
        {item:\gravedust, chance:100, quantity:1}
        {item:\gravedust, chance:75, quantity:1}
        {item:\gravedust, chance:50, quantity:2}
        {item:\gravedust, chance:25, quantity:3}
        {item:\starpuff, chance:10, quantity:1}
        {item:\bugbits, chance:66, quantity:1}
    xp: 120
    hp:60
    atk:200
    def:200
    speed:60
    attributes: <[zombie carnivore]>
    escape:70

Monster.types.mimic =
    name: 'Mimick'
    key: 'monster_mimic'
    skills:[skills.strike]
    hp: 111
    speed: 105
    xp: 100
    #drops: -> [item:temp.mimic.item, chance:100, quantity:temp.mimic.quantity]

Monster.types.sanishark =
    name: 'Sanishark'
    key: 'monster_sanishark'
    skills:[skills.strike]
    xp:100
    drops:
        {item:\silverdust, chance:100, quantity:1}
        {item:\starpuff, chance:10, quantity:1}
    attributes: <[carnivore]>

Monster.types.rhinosaurus =
    name: 'Rhinosaurus'
    key: 'monster_rhinosaurus'
    skills:[skills.strike]
    def:150
    xp:100
    drops:
        {item:\silverdust, chance:100, quantity:1}
        {item:\silverdust, chance:20, quantity:1}
        {item:\starpuff, chance:10, quantity:1}
        {item:\parchment, chance:50, quantity:1}
    attributes: <[carnivore]>
    pal: palette.rhino1
    pal2: palette.rhino2
    pal3: palette.rhino3

Monster.types.woolyrhinosaurus =
    #name: 'Wooly Rhinosaurus'
    name: 'Wooly Rhino'
    key: 'monster_woolyrhino'
    skills:[skills.strike]
    def:150
    hp:120
    xp:100
    drops:
        {item:\silverdust, chance:80, quantity:1}
        {item:\silverdust, chance:20, quantity:1}
        {item:\frozenflesh, chance:90, quantity:1}
        {item:\fur, chance:100, quantity:1}
        {item:\fur, chance:20, quantity:1}
        {item:\starpuff, chance:10, quantity:1}
    attributes: <[carnivore]>
    pal: palette.wrhino1
    pal2: palette.wrhino2
    pal3: palette.wrhino3

Monster.types.wolf =
    #name: 'Wooly Rhinosaurus'
    name: 'Wolven'
    key: 'monster_wolf'
    skills:[skills.strike]
    speed:130
    atk:120
    hp:120
    xp:100
    attributes: <[carnivore]>
    drops:
        {item:\silverdust, chance:100, quantity:1}
        {item:\silverdust, chance:20, quantity:1}
        {item:\frozenflesh, chance:80, quantity:1}
        {item:\fur, chance:100, quantity:1}
        {item:\fur, chance:50, quantity:1}
        {item:\starpuff, chance:16, quantity:1}
    pal: palette.wolf1
    pal2: palette.wolf2
    pal3: palette.wolf3

Monster.types.tengu =
    name: 'Tengarot'
    key: 'monster_tengu'
    skills:[skills.strike]
    xp:100
    drops:
        {item:\silverdust, chance:100, quantity:1}
        {item:\silverdust, chance:20, quantity:1}
        {item:\parchment, chance:50, quantity:1}
        {item:\starpuff, chance:10, quantity:1}
        {item:\venom, chance:10, quantity:1}
        {item:\bugbits, chance:10, quantity:1}
    pal: palette.tengu1
    pal2: palette.tengu2
    pal3: palette.tengu3

Monster.types.wraith =
    name: 'Wraith'
    key: 'monster_wraith'
    skills: [skills.strike]
    drops: 
        {item:\lifecrystal, chance:50, quantity:1}
        {item:\darkcrystal, chance:50, quantity:1}
        {item:\starpuff, chance:10, quantity:1}
        {item:\cloth, chance:50, quantity:1}
    xp: 100
    speed: 120
    escape: 70

Monster.types.polyduck =
    name: 'Polyduck'
    key: 'monster_polyduck'
    skills: [skills.strike, skills.seizure]
    drops:
        {item:\silverdust, chance:50, quantity:1}
        {item:\starpuff, chance:12, quantity:1}
        {item:\fur, chance:30, quantity:1}
    xp: 100
    speed: 100

Monster.types.eel =
    name: 'Eel'
    key: 'monster_eel'
    skills: [skills.strike]
    drops:
        {item:\venom, chance:50, quantity:1}
        {item:\starpuff, chance:12, quantity:1}
        {item:\silverdust, chance:30, quantity:1}
    xp: 100
    speed: 120
    attributes: <[fish carnivore]>

Monster.types.doggie =
    name: 'Doggie'
    key: 'monster_doggie'
    skills: [skills.attack, skills.wanko]
    drops:
        {item:\gravedust, chance:70, quantity:1}
        {item:\gravedust, chance:70, quantity:1}
        {item:\fur, chance:70, quantity:1}
        {item:\fur, chance:70, quantity:1}
        {item:\starpuff, chance:8, quantity:1}
        {item:\bugbits, chance:50, quantity:1}
    xp: 100
    speed: 120

Monster.types.greblin =
    name: 'Greblin'
    key: 'monster_greblin'
    skills: [skills.attack]
    drops:
        {item:\silverdust, chance:70, quantity:2}
        {item:\silverdust, chance:70, quantity:2}
        {item:\cumberground, chance:100, quantity:1}
        {item:\cumberground, chance:50, quantity:1}
        {item:\fur, chance:70, quantity:1}
        {item:\fur, chance:70, quantity:1}
        {item:\starpuff, chance:20, quantity:1}
        {item:\bugbits, chance:50, quantity:2}
        {item:\bugbits, chance:50, quantity:1}
    xp: 100
    hp: 70

Monster.types.cancer =
    name: 'Cancer'
    key: 'monster_cancer'
    skills: [skills.strike]
    drops:
        {item:\silverdust, chance:70, quantity:2}
        {item:\silverdust, chance:70, quantity:2}
        {item:\starpuff, chance:20, quantity:1}
        {item:\bugbits, chance:50, quantity:2}
        {item:\bugbits, chance:50, quantity:1}
        {item:\sludge, chance:20, quantity:1}
        {item:\sludge, chance:20, quantity:1}
    xp: 100
    atk: 110
    hp: 100
    escape: 90

Monster.types.mutant =
    name: 'Sally'
    key: 'monster_mutant'
    skills: [skills.poisonwave, skills.curse, skills.poisonstrike]
    drops:
        {item:\gravedust, chance:100, quantity:2}
        {item:\sludge, chance:100, quantity:2}
        {item:\starpuff, chance:20, quantity:1}
        {item:\bugbits, chance:50, quantity:2}
        {item:\bugbits, chance:50, quantity:1}
        {item:\darkcrystal, chance:20, quantity:1}
    xp: 150
    atk: 110
    speed: 120
    hp: 140
    escape: 80

Monster.types.throne =
    name: 'Throne'
    key: 'monster_throne'
    skills: [skills.heal, skills.burn, skills.nuke]
    drops:
        {item:\silverdust, chance:100, quantity:2}
        {item:\medicine, chance:70, quantity:1}
        {item:\medicine, chance:60, quantity:1}
        {item:\starpuff, chance:20, quantity:1}
        {item:\cinder, chance:50, quantity:2}
        {item:\cinder, chance:50, quantity:1}
        {item:\lifecrystal, chance:20, quantity:1}
    xp: 160
    atk: 110
    hp: 170
    escape: 50

Monster.types.naegleria =
    name: 'Naegleria'
    key: 'monster_naegleria'
    skills: [skills.strike, skills.poison]
    drops:
        {item:\naesoul, chance:100, quantity:1}
        {item:\excel, chance: 100, quantity:1}
        {item:\sporb, chance: 100, quantity:1}
    xp: 200
    speed: 130
    hp:200
    def:95
    attributes: <[poison]>

Monster.types.naegleria_r =
    name: 'Naegleria'
    key: 'monster_naegleria'
    skills: [skills.poisonstrike, skills.poisonwave]
    xp: 200
    speed: 130
    hp:300
    def:150
    attributes: <[poison]>
    ai:!->
        list=[]
        for enemy in enemy_list!
            for buff in enemy.buffs
                list.push skills.poisonstrike if buff.name is \poison
                list.push skills.poisonwave if buff.name is \null
        #if @stats.hp<0.5 and monsters.length is 1 then return skills.slimesummon
        if monsters.length is 1 then return skills.slimesummon
        return null if list.length is 0
        return list[Math.random!*list.length.|.0]

Monster.types.eidzu1 =
    name: 'Eidzu I'
    key: 'monster_eidzu1'
    skills: [skills.devastate, skills.strike]
    drops: 
        {item:\aidssoul, chance:100, quantity:1}
        {item:\sporb, chance: 100, quantity:1}
        {item:\humansoul, chance: 100, quantity: 225000}
    xp: 300
    speed: 70
    hp:300
    atk:110
    trigger:!->
        return if @triggered
        if monsters.length is 1
            @triggered = true
            @loadTexture 'monster_eidzu1_2'
    ai:!->
        return null if monsters.length is 1
        for ally in ally_list!
            #continue if ally is this
            continue if ally.dead
            if ally.stats.hp / @stats.hp <= 0.5
                return skills.sharepain
        for enemy in enemy_list!
            return skills.devastate if enemy.has_buff buffs.null
        #return skills.devastate if monsters.length>1
        return skills.strike


Monster.types.eidzu2 =
    name: 'Eidzu II'
    key: 'monster_eidzu2'
    skills: [skills.dekopin]
    drops:
        {item:\excel, chance: 100, quantity:1}
        {item:\sporb, chance: 100, quantity:1}
        {item:\humansoul, chance: 100, quantity: 225000}
    xp: 300
    speed: 130
    hp:300
    trigger:!->
        return if @triggered
        if monsters.length is 1
            @triggered = true
            @loadTexture 'monster_eidzu2_2'
    ai:!->
        allylist=ally_list!
        for ally in allylist
            #continue if ally is this
            if ally.stats.hp / @stats.hp <= 0.5
            #if ally.stats.hp<0.5 and @stats.hp>0.5
                return skills.sharepain
        for enemy in enemy_list!
            return skills.dekopin if enemy.has_buff buffs.aids
        for ally in allylist
            continue if ally is this
            return skills.twinflight if ally.has_buff buffs.null and !ally.has_buff buffs.twinflight
        return skills.strike


Monster.types.sars =
    name: 'Sars'
    key: 'monster_sars'
    skills: [skills.sarssummon]
    drops:
        {item:\sarssoul, chance:100, quantity:1}
        {item:\excel, chance: 100, quantity:1}
        {item:\sporb, chance: 100, quantity:1}
        {item:\humansoul, chance: 100, quantity: 450000}
    xp: 300
    speed: 130
    hp:300
    trigger:!->
        @stats.def=new_calc_stat @level, 100+(10*monsters.length)
        @stats.speed=calc_stat @level, (100+100/monsters.length), 2
    ai:!->
        return skills.sarssummon if monsters.length<8
        return skills.strike

Monster.types.sarssummon =
    name: 'Sarsagent'
    key: 'monster_sars_summon'
    skills: [skills.attack]
    xp: 0
    speed: 1000
    hp:50
    atk: 40
    minion: true #battle text won't be shown

Monster.types.rabies =
    name: 'Rabies'
    key: 'monster_rabies'
    skills: [skills.burn, skills.inferno]
    drops:
        {item:\rabiessoul, chance:100, quantity:1}
        {item:\excel, chance: 100, quantity:1}
        {item:\sporb, chance: 100, quantity:1}
        {item:\humansoul, chance: 100, quantity: 450000}
        {item:\bugbits, chance:100, quantity:3}
        {item:\fur, chance:100, quantity: 4}
    xp: 300
    speed: 150
    hp:300
    atk: 130
    def: 120
    attributes: <[carnivore]>
    ai:!->
        return skills.strike if @triggered
        list=[]
        for enemy in enemy_list!
            for buff in enemy.buffs
                list.push skills.inferno if buff.name is \burn
                list.push skills.burn2 if buff.name is \null
        return null if list.length is 0
        return list[Math.random!*list.length.|.0]

Monster.types.chikun =
    name: 'Chikungunya'
    key: 'monster_chikun'
    skills: [skills.strike, skills.healblock]
    xpwell: 600
    xpkill: 75
    drops:
        {item:\healblock, chance:100, quantity:1}
        {item:\chikunsoul, chance:100, quantity:1}
        {item:\humansoul, chance: 100, quantity: 450000}
    hp: 300
    def: 300
    speed: 200
    atk: 120
    ai:!->
        list=[]
        enemylist=enemy_list!
        nullcount=0
        for enemy in enemylist
            list.push skills.healblock unless enemy.has_buff buffs.healblock
            if enemylist.length>1 and !enemy.has_buff buffs.isolated then list.push skills.isolate
            nullcount++ if enemy.has_buff buffs.null
        list.length=0 if nullcount is 0
        list.push skills.vbite
        if @has_buff buffs.bleed and @has_buff buffs.null
            return skills.bloodboost
        if @stats.hp<0.5 and !@has_buff buffs.bleed
            if @has_buff buffs.bloodboost
                return skills.bloodlet
            else if @has_buff buffs.null
                list.push skills.bloodlet
        return null if list.length is 0
        return list[Math.random!*list.length.|.0]
    #escape:0

Monster.types.cure =
    name: 'Cure-chan'
    key: 'monster_cure0'
    skills: [skills.strike]
    drops: 
        {item:\humanskull, chance:100, quantity:1}
        {item:\medicine, chance:100, quantity:20}
        {item:\excel, chance: 100, quantity:1}
        {item:\sporb, chance: 100, quantity:2}
    xpwell: 400
    xpkill: 75
    speed: 100
    hp:300
    def: 115
    trigger:!->
        return if @triggered
        if @stats.hp <= 0.33
            @triggered = true
            @loadTexture 'monster_cure1'
            @stats.speed *= 2
            @stats.def += 20
            triggertext tl("Cure-chan became triggered!")
        else if averagelevel!<17 and !@message1
            @message1 = true
            triggertext tl("Cure-chan: You are not prepared!")
    ai:!->
        return skills.strike if @triggered
        list=[skills.strike]
        for buff in @buffs
            list.push skills.cure if buff.negative and buff.name isnt \coagulate
        list.push skills.regenerate if not @has_buff buffs.regen and @stats.hp<=0.75 and list.length<2
        return list[Math.floor Math.random!*list.length]
        #return null
Monster.types.zmapp =
    name: 'Zmapp'
    key: 'monster_zmapp0'
    skills: [skills.strike]
    drops:
        {item:\excel, chance: 100, quantity:1}
        {item:\sporb, chance: 100, quantity:3}
    #xp: 300
    xpwell: 600
    xpkill: 75
    atk: 100
    speed: 120
    hp:300
    trigger:!->
        return if @triggered
        if @stats.hp <= 0.5
            @triggered = true
            @loadTexture 'monster_zmapp1'
            @stats.speed *= 3
            @stats.def *= 2
            triggertext tl("Zmapp became triggered!")
    ai:!->
        list=[skills.strike,skills.curse]
        if @stats.hp <= 0.5
            list=[skills.hemorrhage, skills.hellfire]
        for enemy in enemy_list!
            if enemy.has_buff buffs.bleed
                list=[skills.bloodburst]
                break
        return list[Math.floor Math.random!*list.length]
    #attributes: <[blood]>
    escape:0

Monster.types.cureX =
    name: 'Cure-chan'
    key: 'monster_cure0'
    skills: [skills.quickheal]
    xpwell: 1000
    xpkill: 100
    hp:300
    ai:!->
        list=[skills.quickheal]
        for enemy in enemy_list!
            for buff in enemy.buffs
                if buff.base is buffs.bleed and buff.duration<1
                    return skills.coagulate
        if monsters.length is 1 then list=[skills.quickheal,skills.strike]
        :outer for ally in ally_list!
            for buff in ally.buffs
                if buff.negative
                    list.push skills.clense
                    break outer
        return list[Math.floor Math.random!*list.length]
    escape:0

Monster.types.zmappX =
    name: 'Zmapp'
    key: 'monster_zmappX'
    skills: [skills.hemorrhage]
    xpwell: 1000
    xpkill: 100
    hp:300
    speed:150
    ai:!->
        list=[]
        nullcount=0
        bleedcount=0
        for enemy in enemy_list!
            nullcount++ if enemy.has_buff buffs.null
            bleedcount++ if enemy.has_buff buffs.bleed
            if enemy.has_buff buffs.coagulate and !enemy.has_buff buffs.null
                list.push skills.bloodrun
        if bleedcount>0 and nullcount>0
            list.push skills.infectspread
        else if nullcount>0
            list.push skills.hemorrhage
        list.push skills.pandemic if nullcount>1
        return skills.strike if !list.length
        return list[Math.floor Math.random!*list.length]
    escape:0

Monster.types.who =
    name: 'WHO-chan'
    key: 'monster_who'
    skills: [skills.angel-rain, skills.hellfire]
    drops:
        [{item:\humansoul, chance: 100, quantity: 1200000}]
    xpwell: 1000
    xpkill: 100
    hp:600
    speed:75
    undying: -> monsters.length>1
    trigger:!->
        return if @triggered
        if @stats.hp <= 0
            @triggered = true
            #@loadTexture 'monster_zmapp1'
            @stats.speed *= 0.8
            @stats.atk *= 0.8
            #@stats.def *= 2
            triggertext tl("Who-chan: I cannot die.")
    ai:!->
        if @stats.hp<=0
            if @has_buff buffs.bleed and @has_buff buffs.null then return skills.bloodboost
        if @triggered and @stats.hp>0 and @has_buff buffs.null then return skills.bloodlet
        return null
    escape:0

Monster.types.joki =
    name: 'Joki'
    key: 'monster_joki'
    skills: [skills.strike, skills.joki_shuffle]
    xpwell: 1000
    xpkill: 100
    hp: 500
    drops:
        {item:\humansoul, chance: 100, quantity: 3000000}
        {item:\deathsmantle, chance: 100, quantity: 1}
        {item:\scythe, chance:100, quantity: 1}
    ai:!->
        return skills.joki_split if monsters.length <= 3
        if @item.base is buffs.null then for battler in hero_list!
            return skills.joki_thief if battler.item.base isnt buffs.null
        if !@has_buff buffs.obscure and Math.random!<0.33
            return skills.shroud
        return null
    #start:!->
    #    @item.load_buff items.deathsmantle
    ondeath:!->
        for hero in hero_list!
            if hero.originalitem is @item.base and hero.item.base is buffs.null
                return hero.item.load_buff @item.base

Monster.types.jokiclone =
    name: 'Joki'
    key: 'monster_joki'
    skills: [skills.strike, skills.joki_shuffle]
    xp: 100
    ai:!->
        if @item.base is buffs.null then for battler in hero_list!
            return skills.joki_thief if battler.item.base isnt buffs.null
        if !@has_buff buffs.obscure and Math.random!<0.33
            return skills.shroud
        return null
    ondeath: Monster.types.joki.ondeath

Monster.types.lepsy =
    name: 'Epilepsy'
    key: 'monster_lepsy'
    skills: [skills.strike, skills.seizure2]
    xpwell: 300
    xpkill: 100
    drops:
        {item:\silverdust, chance:100, quantity:4}
        {item:\starpuff, chance:100, quantity:2}
    hp: 250
    def: 150
    speed: 120
    atk: 100
    ai:!->
        if monsters.length is 1 then return skills.lepsysummon
        list=[]
        enemylist=enemy_list!
        for enemy in enemylist
            if enemy.has_buff buffs.seizure
                list.push skills.strike
            else list.push skills.seizure2 
        return list[Math.random!*list.length.|.0]

Monster.types.parvo =
    name: 'Parvo'
    key: 'monster_parvo'
    skills: [skills.lovetap, skills.lick]
    xpwell: 300
    xpkill: 100
    drops:
        {item:\fur, chance:100, quantity: 8}
        {item:\bugbits, chance:100, quantity:4}
    hp: 200
    def: 200
    speed: 70
    atk: 100
    ai:!->
        if monsters.length is 1 then return skills.parvosummon
        enemylist=enemy_list!
        for enemy in enemylist
            if enemy.stats.sp_level - enemy.stats.sp>0.9
                return skills.sabotage
        return null

Monster.types.zika =
    name: 'Zika'
    key: 'monster_zika'
    skills: [skills.strike]
    xpwell: 300
    xpkill: 100
    drops:
        {item:\medicine, chance:100, quantity: 4}
        {item:\bleach, chance:60, quantity: 2}
        {item:\swarmscroll, chance:100, quantity: 5}
    hp: 250
    def: 250
    speed: 120
    atk: 100
    ai:!->
        list=[]
        for enemy in enemy_list!
            for buff in enemy.buffs
                list.push if buff.name is \null then skills.swarm else skills.hex
                if @stats.hp<=0.5 and buff.name is \swarm then list.push skills.swarmdrain
        return null if list.length is 0
        return list[Math.random!*list.length.|.0]

Monster.types.voideye =
    name: 'E̢̡͡͞y҉̢̢̡e̛҉̀҉ ̡̕͢͠͡S̡͜͞͝t͟a҉҉̵́l̡k̷̵͝'
    key: 'monster_voideye'
    skills: [skills.eyebeam]
    xp: 100
    hp:80
    atk:75
    def:70
    attributes: <[void]>
    escape: 70
    drops:
        {item:\gravedust, chance:75, quantity:1}
        {item:\gravedust, chance:25, quantity:1}
        {item:\voidcrystal, chance:50, quantity:1}
        {item:\teleport, chance:25, quantity:1}
        {item:\starpuff, chance:5, quantity:1}
    undying: !->
        return true if averagelevel!<=@level
        for monster in monsters
            return true if monster.xpwell>0
        return false
Monster.types.voidtofu =
    name: 'T҉̛̕͢ơ͡f̸̀͝ù͟͞͡'
    #name: 'T҉͜͢͠o̶̢̢͝f̴͟ú̸̸̢̢'
    key: 'monster_voidtofu'
    skills: [skills.attack, skills.curse]
    xp: 100
    speed: 90
    drops:
        {item:\gravedust, chance:50, quantity:1}
        {item:\gravedust, chance:50, quantity:1}
        {item:\voidcrystal, chance:75, quantity:1}
        {item:\teleport, chance:20, quantity:1}
        {item:\starpuff, chance:10, quantity:1}
    undying: !->
        if switches.ate_nae or switches.ate_chikun or switches.ate_eidzu or switches.ate_sars or switches.ate_rabies or switches.ate_llov
            return false
        return !battle.critical
Monster.types.voidgast =
    name: ' ̸̸́͠ ̧̢ ̢̛ ̸̵͢'
    key: 'monster_voidgast'
    skills: [skills.vbite]
    xp: 100
    atk: 120
    drops:
        {item:\gravedust, chance:75, quantity:1}
        {item:\gravedust, chance:75, quantity:1}
        {item:\voidcrystal, chance:100, quantity:1}
        {item:\teleport, chance:25, quantity:1}
        {item:\starpuff, chance:10, quantity:1}
    undying: !->
        hp=0
        for hero in heroes
            hp+=hero.stats.hp
        return hp/heroes.length>0.25
Monster.types.voidskel =
    #name: '͡҉̶S҉̷̢͢͜ķ̸͞e͝҉l̴̡̢͟͡e̢̛҉̶'
    name: '\\̀͝_̸̧̨͞o҉̧̀'
    key: 'monster_voidskel'
    skills: [skills.attack]
    xp: 80
    hp:80
    atk:70
    def:70
    speed: 120
    escape: 50
    drops:
        {item:\gravedust, chance:50, quantity:1}
        {item:\gravedust, chance:50, quantity:1}
        {item:\voidcrystal, chance:25, quantity:1}
        {item:\teleport, chance:10, quantity:1}
        {item:\starpuff, chance:5, quantity:1}
    undying: !->
        for monster in monsters
            if monster.monstertype is Monster.types.voidskel and monster.stats.hp>0
                return true
        return false
Monster.types.darkllov =
    name: 'Lloviu-tan'
    key: 'monster_darkllov'
    skills: [skills.strike]
    xpwell: 1000
    xpkill: 100
    #speed: 999999
    speed: 400
    luck: 200
    hp: 800
    drops:
        {item:\llovsoul, chance: 100, quantity: 1}
        {item:\humansoul, chance: 100, quantity: 1000000}
    trigger:!->
        if !@trigger
            @trigger=1
            triggertext tl("Lloviu-tan: Who are you? Stay away...")
    ai: !->
        list=[skills.lovely-arrow]
        enemylist=enemy_list!
        charmcount=0
        for enemy in enemylist
            charmcount++ if enemy.has_buff buffs.charmed
        if charmcount<enemylist.length
            list.push skills.devil-kiss
        if @stats.hp<0.5
            list.push skills.heal
        #return null if list.length is 0
        return list[Math.random!*list.length.|.0]




#========================================================================
# Battle Encounters
#========================================================================

encounter = {}
encounter.bg =
    #forest: [\bg_0_0 \bg_0_1 0xf1953b 0x020501]
    forest: [\bg_0_0 \bg_0_1 0x898989 0x020501]
    forest_night: [\bg_4_0 \bg_4_1 0x080808 0x020501]
    water: [\bg_5_0 \bg_5_1 0x666666 0x020501]
    water_night: [\bg_5_0a \bg_5_1a 0x020501 0x020501]
    water_dead: [\bg_5_0b \bg_5_1b 0x9e3a3a 0x020501]
    dungeon: [\bg_1_0 \bg_1_1 0x080808 0x080808]
    jungle: [\bg_2_0 \bg_2_1 0xc34b4b 0x020501]
    tower: [\bg_3_0 \bg_3_1 0xfcfcfc 0x090709]
    castle: [\bg_6_0 \bg_6_1 0x080808 0x080808]
    earth: [\bg_7_0 \bg_7_1 0x3c55b3 0x020501]
    earth_snow: [\bg_7_0s \bg_7_1s 0x3c55b3 0x020501]
    lab: [\bg_8_0 \bg_6_1 0x080808 0x080808]
    void: [\bg_9_0 \bg_6_1 0x080808 0x080808]

encounter.slime = #s is for scaling (unused)
    monsters : 
        [id:\slime x:0 y:1 s:1 l1:1 l2:6]
    #bg : \forest

encounter.slime2 = 
    monsters : 
        {id:\slime x:2 y:2 s:1 l1:3 l2:8}
        {id:\slime x:-2 y:2 s:1 l1:3 l2:8}
    #bg : \forest

encounter.slime3 = 
    monsters : 
        {id:\slime x:2.5 y:2 s:1 l1:3 l2:7}
        {id:\slime x:-2.5 y:2 s:1 l1:3 l2:7}
        {id:\slime x:0 y:1 s:1 l1:3 l2:7}
    lmod: -1

encounter.deadworld_slime = 
    monsters : 
        {id:\slimex x:2.5 y:2 s:1 l1:6 l2:18}
        {id:\slimex x:-2.5 y:2 s:1 l1:6 l2:18}
        {id:\slimex x:0 y:1 s:1 l1:6 l2:18}

encounter.delta_slime = 
    monsters : 
        {id:\slimexx x:2.5 y:2 s:1 l1:20 l2:30}
        {id:\slimexx x:-2.5 y:2 s:1 l1:20 l2:30}
        {id:\slimexx x:0 y:1 s:1 l1:20 l2:30}

encounter.delta_megaslime = 
    monsters : 
        [id:\slime2xx x:0 y:1 s:1 l1:20 l2:30]

encounter.deadworld_megaslime = 
    monsters : 
        [id:\slime2x x:0 y:1 s:1 l1:8 l2:17]

encounter.megaslime = 
    monsters : 
        [id:\slime2 x:0 y:1 s:1 l1:6 l2:15]

encounter.earth_slime =
    monsters:
        {id:\slime2z x:3 y:1.5 s:1 l1:35 l2:45}
        {id:\slime2z x:-3 y:1.5 s:1 l1:35 l2:45}

encounter.naegleria =
    monsters : 
        [id:\naegleria x:0 y:1 s:1 l1:5 l2:5]
    onvictory: ->
        #switches.sp_limit++
        switches.beat_nae=true
    runnode: \naerun
encounter.naegleria_r =
    monsters : 
        [id:\naegleria_r x:0 y:1 s:1 l1:0 l2:Infinity]
    onvictory: ->
        temp.nae_reward=true

encounter.sars =
    monsters : 
        [id:\sars x:0 y:0.5 s:1 l1:30 l2:40]
    onvictory: ->
        #switches.sp_limit++
        switches.beat_sars=true

encounter.rabies =
    monsters : 
        [id:\rabies x:0 y:1 s:1 l1:30 l2:40]
    onvictory: ->
        #switches.sp_limit++
        switches.beat_rab=true

encounter.aids =
    monsters : 
        {id:\eidzu1 x:-2 y:1 s:1 l1:30 l2:40}
        {id:\eidzu2 x:1.5625 y:0.3125 s:1 l1:30 l2:40}
    onvictory: ->
        #switches.sp_limit++
        switches.beat_aids=true

encounter.ghost =
    monsters : 
        [id:\ghost x:0 y:1 s:1 l1:8 l2:10]
    #bg : \dungeon

encounter.ghost2 =
    monsters : 
        {id:\ghost x:2 y:2 s:1 l1:8 l2:10}
        {id:\ghost x:-2 y:2 s:1 l1:8 l2:10}
    lmod: -1
    #bg : \dungeon

encounter.dw_ghost2 =
    monsters : 
        {id:\ghost x:2 y:2 s:1 l1:8 l2:17}
        {id:\ghost x:-2 y:2 s:1 l1:8 l2:17}

encounter.skullghost =
    monsters : 
        [id:\skullghost x:0 y:1 s:1 l1:8 l2:17]
    #bg : \dungeon

encounter.skullghost3 =
    monsters : 
        {id:\skullghost x:0 y:2 s:1 l1:35 l2:50}
        {id:\skullghost x:-3 y:1 s:1 l1:35 l2:50}
        {id:\skullghost x:3 y:1 s:1 l1:35 l2:50}

encounter.greblin4 =
    monsters :
        {id:\greblin x:-1.5 y:2 s:1 l1:35 l2:50}
        {id:\greblin x:1.5 y:2 s:1 l1:35 l2:50}
        {id:\greblin x:-3 y:1 s:1 l1:35 l2:50}
        {id:\greblin x:3 y:1 s:1 l1:35 l2:50}
    lmod: -1

encounter.greblin5 =
    monsters :
        {id:\greblin x:-1.5 y:2 s:1 l1:35 l2:50}
        {id:\greblin x:1.5 y:2 s:1 l1:35 l2:50}
        {id:\greblin x:0 y:1 s:1 l1:35 l2:50}
        {id:\greblin x:-3 y:0 s:1 l1:35 l2:50}
        {id:\greblin x:3 y:0 s:1 l1:35 l2:50}
    lmod: -1

encounter.skulmander =
    monsters : 
        [id:\skulmander x:0 y:1 s:1 l1:25 l2:35]
encounter.skulmander2 =
    monsters : 
        {id:\skulmander x:2 y:1 s:1 l1:25 l2:35}
        {id:\skulmander x:-2 y:2 s:1 l1:25 l2:35}

encounter.lurker =
    monsters : 
        [id:\lurker x:0 y:1 s:1 l1:25 l2:35]
    bg: waterbg
encounter.lurker2 = 
    monsters : 
        {id:\lurker x:2 y:1 s:1 l1:25 l2:35}
        {id:\lurker x:-2 y:2 s:1 l1:25 l2:35}
    bg: waterbg

encounter.skulurker = 
    monsters : 
        {id:\skulmander x:2 y:2 s:1 l1:25 l2:35}
        {id:\lurker x:-2 y:1 s:1 l1:25 l2:35}
    bg: waterbg

encounter.bat = #s is for scaling (unused)
    monsters : 
        [id:\bat x:0 y:1 s:1 l1:8 l2:25]

encounter.bat2 = 
    monsters : 
        {id:\bat x:2 y:2 s:1 l1:8 l2:23}
        {id:\bat x:-2 y:2 s:1 l1:8 l2:23}
    lmod: -1

encounter.graven =
    monsters : 
        [id:\graven x:0 y:1 s:1 l1:8 l2:20]
    #bg : \dungeon

encounter.mantrap =
    monsters : 
        [id:\mantrap x:0 y:1 s:1 l1:8 l2:20]

encounter.delta_mantrap =
    monsters : 
        [id:\mantrap x:0 y:1 s:1 l1:25 l2:35]

encounter.mimic =
    monsters:
        [id:\mimic x:0 y:1 s:1 l1:0 l2:Infinity]

encounter.rhinosaurus =
    monsters : 
        [id:\rhinosaurus x:0 y:1 s:1 l1:25 l2:35]
encounter.woolyrhino =
    monsters : 
        [id:\woolyrhinosaurus x:0 y:1 s:1 l1:35 l2:45]
encounter.wolf =
    monsters : 
        {id:\wolf x:-3 y:1 s:1 l1:35 l2:45}
        {id:\wolf x:3 y:1 s:1 l1:35 l2:45}
encounter.rhinowolf =
    monsters : 
        {id:\woolyrhinosaurus x:-3 y:1 s:1 l1:35 l2:45}
        {id:\wolf x:3 y:1 s:1 l1:35 l2:45}

encounter.polyduck =
    monsters : 
        [id:\polyduck x:0 y:1 s:1 l1:10 l2:20]

encounter.eel =
    monsters :
        [id:\eel x:0 y:1 s:1 l1:20,l2:35]

encounter.cancer =
    monsters :
        {id:\cancer x:-3 y:1 s:1 l1:35 l2:45}
        {id:\cancer x:3 y:1 s:1 l1:35 l2:45}

encounter.cancer3 =
    monsters :
        {id:\cancer x:0 y:1.5 s:1 l1:40 l2:47}
        {id:\cancer x:-3 y:0.5 s:1 l1:40 l2:47}
        {id:\cancer x:3 y:0.5 s:1 l1:40 l2:47}

encounter.sally =
    monsters :
        {id:\mutant x:-3 y:1 s:1 l1:40 l2:47}
        {id:\mutant x:3 y:1 s:1 l1:40 l2:47}

encounter.throne =
    monsters :
        [id:\throne x:0 y:1 s:1 l1:40 l2:47]

encounter.sally_throne =
    monsters :
        {id:\throne x:0 y:1.5 s:1 l1:40 l2:48}
        {id:\mutant x:-3 y:0.5 s:1 l1:40 l2:47}
        {id:\mutant x:3 y:0.5 s:1 l1:40 l2:48}
    lmod: -1

encounter.sanishark =
    monsters : 
        [id:\sanishark x:0 y:0 s:1 l1:0 l2:Infinity]

encounter.tengu =
    monsters : 
        [id:\tengu x:0 y:1 s:1 l1:25 l2:35]

encounter.wraith = 
    monsters : 
        [id:\wraith x:0 y:1 s:1 l1:20 l2:22]
    #bg : \forest

encounter.wraith_door = 
    monsters : 
        [id:\wraith x:0 y:1 s:1 l1:22 l2:22]
    onvictory: ->
        switches.beat_wraith=true

encounter.chikun =
    monsters:
        [id:\chikun x:0 y:0.5 s:1 l1:0 l2:Infinity]
    onvictory: ->
        switches.beat_chikun=true
    runnode: \landing

encounter.cure =
    monsters : 
        [id:\cure x:0 y:0 s:1 l1:19 l2:20]
    #bg : \jungle
    onvictory: ->
        #switches.sp_limit++
        #switches.beat_cure=true
        switches.progress=\curebeat
        switches.progress2=9

encounter.cure_single =
    monsters : 
        [id:\cure x:0 y:0 s:1 l1:20 l2:20]
    #bg : \jungle
    onvictory: ->
        #switches.sp_limit++
        join_party \marb save:false front:true startlevel:10
        #switches.beat_cure=true
        switches.progress=\curebeat
        switches.progress2=9

encounter.zmapp =
    monsters : 
        [id:\zmapp x:0 y:0 s:1 l1:25 l2:25]
    #bg : \jungle
    onvictory: ->
        #switches.sp_limit++
        switches.zmapp=\victory
        switches.progress=\zmappbeat
        for p in party
            p.stats.hp=1
    ondefeat: ->
        switches.zmapp--
        if switches.zmapp<=-9
            switches.zmapp=\defeat 
            switches.progress=\zmappbeat

encounter.who =
    monsters:
        {id:\who x:0 y:1 s:1 l1:40 l2:Infinity}
        {id:\zmappX x:-6 y:0 s:1 l1:40 l2:Infinity}
        {id:\cureX x:6 y:0 s:1 l1:40 l2:Infinity}
    onvictory: ->
        switches.progress2=32
        switches.finale=true
    ondefeat: ->
        switches.progress2=31

encounter.joki =
    monsters : 
        [id:\joki x:0 y:0 s:1 l1:0 l2:Infinity]
    onvictory: ->
        switches.beat_joki=true
    bg: \castle

encounter.lepsy =
    monsters : 
        [id:\lepsy x:0 y:0 s:1 l1:0 l2:Infinity]
    onvictory: ->
        switches.beat_lepsy=true
        session.beat_lepsy=true
        temp.leps_reward=true
        switches.lepsy_timer=Date.now!

encounter.parvo =
    monsters : 
        [id:\parvo x:0 y:0 s:1 l1:0 l2:Infinity]
    onvictory: ->
        switches.beat_parvo=true
        temp.parvo_reward=true
        switches.parvo_timer=Date.now!

encounter.zika =
    monsters : 
        [id:\zika x:0 y:0 s:1 l1:0 l2:Infinity]
    onvictory: ->
        switches.beat_zika=true
        temp.zika_reward=true
        switches.zika_timer=Date.now!

encounter.void0 =
    monsters :
        {id:\voidtofu x:0 y:2 s:1 l1:35 l2:50}
        {id:\voideye x:-3 y:1 s:1 l1:35 l2:50}
        {id:\voideye x:3 y:1 s:1 l1:35 l2:50}
encounter.void1 =
    monsters :
        {id:\voidgast x:0 y:2 s:1 l1:35 l2:50}
        {id:\voideye x:-3 y:1 s:1 l1:35 l2:50}
        {id:\voideye x:3 y:1 s:1 l1:35 l2:50}
encounter.void2 =
    monsters :
        {id:\voidskel x:-2 y:2 s:1 l1:35 l2:50}
        {id:\voidskel x:2 y:2 s:1 l1:35 l2:50}
        {id:\voideye x:0 y:1 s:1 l1:35 l2:50}
        {id:\voidskel x:-4 y:0 s:1 l1:35 l2:50}
        {id:\voidskel x:4 y:0 s:1 l1:35 l2:50}
encounter.void3 =
    monsters :
        {id:\voidskel x:-2 y:2 s:1 l1:35 l2:50}
        {id:\voidskel x:2 y:2 s:1 l1:35 l2:50}
        {id:\voidtofu x:0 y:1 s:1 l1:35 l2:50}
        {id:\voidskel x:-4 y:0 s:1 l1:35 l2:50}
        {id:\voidskel x:4 y:0 s:1 l1:35 l2:50}
encounter.void4 =
    monsters :
        {id:\voidskel x:-2 y:2 s:1 l1:35 l2:50}
        {id:\voidskel x:2 y:2 s:1 l1:35 l2:50}
        {id:\voidgast x:0 y:1 s:1 l1:35 l2:50}
        {id:\voidskel x:-4 y:0 s:1 l1:35 l2:50}
        {id:\voidskel x:4 y:0 s:1 l1:35 l2:50}

encounter.darkllov =
    monsters : 
        [id:\darkllov x:0 y:0 s:1 l1:0 l2:Infinity]
    onvictory: ->
        switches.beat_llov=true

class Audio
    ->
        @volume = 0.5
        @volumes = {}
        @sounds = []
        @lastplayedtime=Date.now!
        @lastplayedsound=null
    @volume = 1.0
    add: (key, volume=1, looping=false)!->
        @sounds.push <| sound = @[key] = game.sound.add key, volume, looping 
        @volumes[key] = volume
        sound.onLoop.add -> @play!
        , sound
    play: (name, settime)!->
        return unless (sound = @[name])?
        sound.play null null @volumes[name]*@volume*Audio.volume, sound.loop
        @lastplayedtime=Date.now! if settime
        @lastplayedsound=sound
    playifnotplaying: (name)!->
        return if !@[name]? or @[name]isPlaying
        @stop!
        @play name
    stop: !->
        for sound in @sounds
            sound.stop!
    refresh: !->for sound in @sounds
        @play sound.key if sound.isPlaying
    fadeOut: (d)!-> for sound in @sounds 
        sound.fadeOut d if sound.isPlaying
    fadeIn: (name, d)!->
        sound = @[name]
        sound.play null null 0 sound.loop
        sound.fadeTo d, @volumes[name]*@volume*Audio.volume
    updatevolume:!->
        return unless @lastplayedsound
        @lastplayedsound.volume=@volumes[@lastplayedsound.name]*@volume*Audio.volume

        
sound = new Audio!
music = new Audio!
menusound = new Audio!
voicesound = new Audio!

!function create_audio
    #music.add \battle 1 true
    menusound.add \blip 0.5
    voicesound.add \blip 0.5
    sound.add \itemget
    sound.add \encounter 
    sound.add \boom
    sound.add \defeat
    sound.add \candle
    sound.add \strike
    sound.add \flame
    sound.add \water
    sound.add \swing
    sound.add \laser
    sound.add \run
    sound.add \stair
    sound.add \door
    sound.add \groan
    sound.add \voice 0.5
    voicesound.add \groan
    voicesound.add \voice 0.5
    voicesound.add \voice2 0.5
    voicesound.add \voice3 0.5
    voicesound.add \voice4 0.5
    voicesound.add \voice5 0.5
    voicesound.add \voice6 0.5
    voicesound.add \voice7 0.5
    voicesound.add \voice8 0.5
    voicesound.add \rope 0.5

!function zonemusic
    return if switches.nomusic
    if (access zones[getmapdata \zone].music) then music.playifnotplaying that
    #switch getmapdata \zone
    #|\tuonen
    #    music.playifnotplaying if switches.soulcluster
    #        then \2dpassion else \towertheme
    #|\tower
    #    music.playifnotplaying if switches.zmapp
    #        then \towertheme else \hidingyourdeath
    #|\deadworld
    #    music.playifnotplaying \deserttheme
    #|\earth
    #    music.playifnotplaying \hidingyourdeath

class NPC extends Actor
    (x,y,key, speed, nobody)->
        super x,y,key,nobody
        @add_facing_animation speed
        @add_simple_animation speed
        @@list.push @
    @list = []
    @clear = !-> for item in @@list
        item.destroy!

var mal, herpes, bp, merch, nae, pox, leps, cure, zmapp, sars, rab, ammit, parvo
joki = []
aids = []

!function new_npc (object, key, speed) 
    n = new NPC object.x, object.y, key, speed
    object.properties.facing ?= \down
    n.face object.properties.facing
    return n

!function node_npc (node, key, speed) 
    n = new NPC node.x+HTS, node.y+TS, key, speed
    node.properties.facing ?= \down
    n.face node.properties.facing
    return n

!function create_npc (o, key)
    object = x: o.x + HTS, y: o.y+TS, properties: o.properties
    npc=new_npc
    switch key
    when \mal
        break if switches.map is \earth and !switches.beat_game
        break if switches.llovsick1 is -2
        break if switches.map is \hub and switches.beat_game
        mal := npc object, \mal
    when \bp 
        break if switches.map is \hub and switches.towerfall_bp
        break if switches.map is \earth and switches.beat_game
        break if switches.map is \lab and !switches.beat_game
        bp := npc object, \bp
    when \joki
        break if switches.map is \castle and switches.beat_joki
        joki.1 := npc object, \joki
    when \joki_2 then joki.2 := npc object, \joki
    when \marb then marb.relocate object if marb not in party
    when \ebby then ebby.relocate object if ebby not in party
    when \merchant
        break if switches.map is \hub and (switches.progress2<9 or switches.llovsick1 is -2)
        break if switches.map is \earth and !switches.beat_game
        temp.herpes_map = if switches.progress2<9 then \deadworld else if switches.progress2<21 then \hub else if !switches.beat_game then \delta else null
        merch := npc object, (if switches.map is temp.herpes_map then \merchant1 else \merchant2), 2
        merch.setautoplay!
    when \herpes
        break if !switches.beat_game
        herpes := npc object, \herpes
    when \wraith
        break if switches.beat_wraith
        n = npc object, \wraith
        n.setautoplay 5
    when \nae
        if switches.map is \earth
            break if !switches.beat_game
            break if !switches.revivalnae
            nae := npc object, \naegleria
            nae.setautoplay 2
            break
        break if switches.beat_nae
        nae := npc object, \mob_naegleria
        nae.battle=encounter.naegleria
        nae.setautoplay 2
    when \war
        n = npc object,\war
        n.body.setSize 3*TS, 2*TS
        n.interact=scenario.war
    when \darkllov
        break if switches.beat_llov
        n = npc object,\mob_llov
        n.battle=encounter.darkllov
        n.setautoplay 8
    when \pox
        break if switches.map is \earth and !switches.beat_game
        break if switches.map is \pox_cabin and switches.confronting_joki
        break if switches.map is \hub and switches.progress2<16
        break if switches.map is \hub and switches.beat_game
        break if switches.llovsick1 is -2
        pox := npc object, \pox
    when \leps then leps := npc object, \leps
    when \parvo then parvo := npc object, \parvo
    when \cure
        #break if switches.beat_cure
        break if switches.progress2>=9 and switches.map is \deadworld and !(switches.curefate>0)
        break if switches.map is \labdungeon and switches.curefate
        cure := npc object,  \cure
    when \zmapp
        #break unless switches.beat_zmapp<1
        #break if switches.beat_zmapp2
        break if switches.map is \towertop and !(switches.progress is \zmappbattle or switches.progress is \zmappbeat)
        break if switches.map is \labdungeon and switches.curefate
        break if switches.map is \deadworld and !(switches.curefate>0)
        zmapp := npc object,  \zmapp
    when \aids1
        aids.1 := npc object, \aids1
        aids.1.kill! if switches.beat_aids
    when \aids2
        aids.2 := npc object, \aids2
        aids.2.kill! if switches.beat_aids
    when \aids3 
        break if switches.map is \earth and !switches.beat_game
        break if switches.map is \earth and !switches.revivalaids
        aids.0 := npc object, \aids3
    when \sars
        break if switches.map is \earth and !switches.beat_game
        break if switches.map is \earth and !switches.revivalsars
        sars := npc object, \sars
        sars.kill! if switches.beat_sars and switches.map is \delta
    when \rab
        break if switches.map is \earth and !switches.beat_game
        break if switches.map is \earth and !switches.revivalrab
        rab := npc object, \rab
        rab.kill! if switches.beat_rab and switches.map is \delta
    when \ammit then ammit := npc object, \ammit

speakers = 
    #marb: display:\Marburg-sama default:\marb_port
    #,smile:\marb_smile troubled:\marb_troubled angry:\marb_troubled grief:\marb_grief
    marb: display:\Marburg-sama composite:{x:-96,y:-129,player:\marb, face:\marb_face}, default:0, smile:1, troubled:2, angry:3, grief:4, aroused:5
    ,voice:\voice2
    #ebby: display:\Ebola-chan default:\ebby_port
    #, smile:\ebby_smile, concern:\ebby_concern, shock:\ebby_concern, cry:\ebby_cry
    ebby: display:\Ebola-chan composite:{x:-81,y:-118,player:\ebby, face:\ebby_face}, default:1, smile:0, concern:2, shock:3, cry:4
    ,voice:\voice7
    #examples: test1:{base:\joki_port, sheet:\llov_face,offx:50,offy:100,frame:1}, test2:[\llov_face, 2]
    #llov: display:\Lloviu-tan default: -> if switches.llovsick then \llov_sick else \llov_port
    #, scared:\llov_scared sick:\llov_sick smile:\llov_smile
    llov: display:\Lloviu-tan composite:{x:-77,y:-115,player:\llov, face:\llov_face}, default: -> if switches.llovsick then 2 else 0
    , scared: 3, sick: 2, smile: 1
    mal: display:\Malaria-sama default:\mal_port
    ,voice:\voice2
    joki: display:\Joki default:\joki_port #tits:\joki_tits
    ,voice: \voice5
    herpes: display:\Herpes-chan default:\herpes_port #tits:\herpes_tits
    ,voice: \voice5
    merch: display:'Agent of Herpes' default:\merchant_port #tits:\merchant_tits
    ,voice: \voice6
    bp: display:\Plague-sama default:\bp_port
    ,voice:\voice3
    pox: display:"Smallpox" default:\pox_port injured:\pox_injured
    ,voice: \voice6
    leps: display:\Lepsy-tan default:\leps_port
    ,voice: \voice7
    parvo: display:\Parvo-tan default:\parvo_port
    ,voice: \voice6
    zika: display:\Zika-chan default:\zika_port
    ,voice: \voice7

    nae: display:'Nae-tan' default:\nae_port
    ,voice: \voice6
    aids1: display:'Eidzu I' default:\aids1_port mad:\aids1_mad fused:\aids3_port
    ,voice: \voice6
    aids2: display:'Eidzu II' default:\aids2_port mad:\aids2_mad fused:\aids3_port
    ,voice: \voice8
    sars: display:'Sars-chan' default:\sars_port mad:\sars_mad
    ,voice: \voice5
    rab: display:'Rabies-chan' default:\rab_port mad:\rab_mad young:\rab2_port
    ,voice: \voice8
    chikun: display:'Chikun-chan' default:\chikun_port
    ,voice:\voice5

    ammit: display:'Ammit-chan' default:\ammit_port
    ,voice:\rope
    shiro: display:'Shiro' default:\shiro_port
    ,voice: \voice6

    wraith: display:\Wraith default:\wraith_port voice:\groan
    pest: display:\Pestilence voice:\groan
    famine: display:\Famine voice:\groan
    war: display:\War default:\war_port voice:\groan

    cure: display:\Cure-chan default:\cure_port
    ,voice:\voice4
    zmapp: display:\Zmapp-chan default: -> if switches.progress2<16 then \zmapp_port else \zmapp_healthy
    ,voice:\voice5
    who: display:\WHO-chan default:\who_port
    ,voice:\rope

    min: display: \Minion default:\min_port
    ,voice: \voice6

    slime: display:\Slime default:\slime_port voice:\groan

for key of speakers
    speakers[key]voice=\voice unless speakers[key]voice?

#speakers.alias =(speaker, alias)!-> @[alias] = @[speaker]
#speakers.alias \marburg \marb
#speakers.alias \ebola \ebby
#speakers.alias \lloviu \llov
#speakers.alias \malaria \mal
#speakers.alias \plague \bp
#speakers.alias \smallpox \pox

!function npc_events
    #========================================================================================
    # Default Chat
    #========================================================================================
    marb?interact =!->
        say \marb \troubled tl("Llov? What are you doing here?")
        say \llov tl("Llov is here to help!")
        say \marb \troubled tl("You came here all by yourself?")
        say \marb \smile tl("Ah well, come along. We'll search together.")
        say \marb tl("We're looking for Cure. She has something that doesn't belong to her.")
        #marb.set_xp levelToXp averagelevel! >? 10
        #party.unshift marb
        #set_party!
        join_party \marb save:true front:true startlevel:12
        #save!
        void /*
        say 'Marburg' "Should I join your team?"
        menu 'yes' ->
            say "Let's get going then!"
            party.push marb
            set_party!
        , 'exit' ->
            say 'Marburg' "Maybe another time."
        */

    mal?interact =!->
        if switches.beat_game
            say \mal tl("I wonder how Zika-chan is doing.")
            return
        say \mal tl("Hello again.")
        #say 'Malaria' "Hi there. This is a test."
        #say "null speaker."
        #say '' "empty string"
        #say 'Malaria', "Here's a menu."
        #menu 'nested' -> 
        #    @menu 'yes' ->
        #    ,'no' ->
        #, 'exit' ->
        #say 'Malaria' "That's about it. Thank you for your time."

    bp?interact =!->
        if switches.beat_game
            if switches.humanfate>0
                if scenario.childAge2!
                    scenario.shiro!
                else if scenario.childAge1!
                    say \bp tl("Isn't she beautiful? She's growing stronger every day.")
                else
                    say \bp tl("I will stay here and help raise the child.")
                
            else
                say \bp tl("I will continue my research in this lab.")
            return
        if switches.progress is \towerfall
            say \bp tl("I'm searching for alternate sources of energy.")
            say \bp tl("Most life on earth is gone now, but there are still traces.")
            say \bp tl("If only we had a way to revive extinct species.")
            return
        say \bp tl("Please, just do what I say.")

    for j in joki
        if j instanceof NPC
            j.interact=joki_interact

    herpes?interact =!->
        herpes_chat ...

    merch?interact =!->
        if @key is \merchant2 then merch_agent ...
        else merch_herpes ...

    merch_agent =!->
        say \merch tl("Um... can I get something for you?")
        menu tl("Let me browse your goods."), start_shop_menu
        , tl("Glass Blowing"), merch_glassblowing
        , tl("Gambling"), merch_gambling
        , tl("Nevermind"), ->

    merch_herpes =!->
        #if switches.map is \hub and !switches.setupshop
        #    say \herpes "Hey, I've decided to set up shop over here now."
        #    say -> setswitch \setupshop true
        if player is llov or player is ebby
            #say \herpes "I'm not supposed to be here until later in the game}"
            say \herpes tl("Hey cutie, what brings you here?")
        else
            say \herpes tl("Do you need something?")
        menu tl("Let me browse your goods."), start_shop_menu
        , tl("Glass Blowing"), herpes_glassblowing
        , tl("Gambling"), herpes_gambling
        #, "Let's chat." herpes_chat
        , tl("Nevermind"), ->
        #say "Have a nice day."

    herpes_gambling =!->
        unless session.gamble_rules
            @say \herpes tl("All right, here's how it works. You choose how much cumberground you want to bet, and I'll flip a coin.")
            @say tl("If it's heads, you win double your bet. If it's tails, I keep it all.")
            @say tl("Simple, right?")
            session.gamble_rules=true
        unless items.cumberground.quantity>0
            return @say \herpes tl("Come back when you have some cumberground to gamble with.")
        @say \herpes tl("How much cumberground will you bet?")
        @number tl("Max:{0}",items.cumberground.quantity), 0 items.cumberground.quantity
        @say ->
            bet=dialog.number.num
            unless bet>0
                return say \herpes tl("Not feeling lucky? That's all right, come back any time.")
            say tl("Flipping the coin...")
            #if pluckroll_leader!>0.55
            #if pluckroll_gamble!>0.505
            if pluckroll_gamble!>0.5
                say tl("Heads, you win! Here's your prize, {0} cumberground!",bet*2)
                #items.cumberground.quantity+=bet
                acquire items.cumberground, bet, true, true
            else
                say tl("Tails. Sorry, you lost {0} cumberground.",bet)
                items.cumberground.quantity-=bet
            save!

    merch_gambling =!->
        unless session.gamble_rules
            @say \merch tl("...You know the rules, right?")
            @say tl("I flip a coin. Heads you win double your bet. Tails I keep everything.")
            session.gamble_rules=true
        unless items.cumberground.quantity>0
            return @say \herpes tl("...But you don't have anything to bet. Come back with some cumberground.")
        @say \merch tl("How much cumberground will you bet?")
        @number tl("Max:{0}",items.cumberground.quantity), 0 items.cumberground.quantity
        @say ->
            bet=dialog.number.num
            unless bet>0
                return say \merch tl("...That's okay.")
            say tl("Flipping the coin...")
            #if pluckroll_leader!>0.55
            #if pluckroll_gamble!>0.505
            if pluckroll_gamble!>0.5
                say tl("Heads. You win {0} cumberground.",bet*2)
                #items.cumberground.quantity+=bet
                acquire items.cumberground, bet, true, true
            else
                say tl("Sorry, it's tails. You lose {0} cumberground.",bet)
                items.cumberground.quantity-=bet
            save!

    herpes_glassblowing =!->
        @say \herpes tl("I can turn your glass shards into glass vials. It will also cost one cumberground each.")
        return unless items.shards.quantity>0 and items.cumberground.quantity>0
        @say tl("How many vials should I make?")
        q= items.cumberground.quantity <? items.shards.quantity
        @number tl("Max:{0}",q), 0 q
        @say ->
            q= dialog.number.num
            unless q>0
                return say \herpes tl("Come back any time.")
            items.cumberground.quantity -= q; exchange q, items.shards, items.vial
            #say \herpes "Here you go, #q glass vial#{if q>1 then 's' else ''}."
            say '' tl("Acquired {0} {1}!",stattext(q,5),items.vial.name)
        #args=["Nevermind", (->),"Create 1", (!->items.cumberground.quantity-=1;exchange items.shards, items.vial)]
        #args.push "Create 3", (!->items.cumberground.quantity-=3;exchange 3, items.shards, items.vial) if items.shards.quantity>=3 and items.cumberground.quantity>=3
        #args.push "Create 10", (!->items.cumberground.quantity-=10;exchange 10, items.shards, items.vial) if items.shards.quantity>=10 and items.cumberground.quantity>=10
        #args.push "Create 33", (!->items.cumberground.quantity-=33;exchange 33, items.shards, items.vial) if items.shards.quantity>=33 and items.cumberground.quantity>=33
        #args.push "Create 100", (!->items.cumberground.quantity-=100;exchange 100, items.shards, items.vial) if items.shards.quantity>=100 and items.cumberground.quantity>=100
        #@menu.apply @,args

    merch_glassblowing =!->
        @say \merch tl("One cumberground and one glass shard makes one vial.")
        return unless items.shards.quantity>0 and items.cumberground.quantity>0
        @say tl("...How many do you need?")
        q= items.cumberground.quantity <? items.shards.quantity
        @number tl("Max:{0}",q), 0 q
        @say ->
            q= dialog.number.num
            unless q>0
                return say \merch tl("...That's okay.")
            items.cumberground.quantity -= q; exchange q, items.shards, items.vial
            #say \merch "#q glass vial#{if q>1 then 's' else ''}... For you."
            say '' tl("Acquired {0} {1}!",stattext(q,5),items.vial.name)
        
    herpes_intro =!->

    herpes_chat =!->
        #if player is marb
        #    say \marb tl( "I've seen the way you look at my sisters. Keep your tail to yourself and there won't be any trouble.")
        #    say \herpes tl( "You know, you're cute when you get jealous like that, Marburg.")
        #else
        #    say \herpes tl( "Isn't it tough walking around in such thick clothing all day? I don't know how you do it.")
        say \herpes tl("Since my agents will run my shops for me, I can just take it easy.")
        #if false #high winnings from gambling
        #    say \herpes tl("Hey, I know you've been a real good customer. Let me teach you something.")
        #    learn_skill \martingale

    Actor.wraith?interact =!->
        #say \wraith "The tower is off-limits. Only the goddess and her followers may enter."
        say \wraith tl("The tower is off-limits. Ebola-chan is not taking visitors at the moment.")
        /*
        say \wraith "The tower is off-limits to all but the goddess."
        menu "Who are you?" ->
            @say "In life we were the followers of our goddess. In death we are her servants and protectors."
        , "Who is the goddess?" ->
            @say "She who kills and is thanked for it. Our master is the one who brought mankind to its knees."
            @say "She is our savior and our reaper. The one who saved the world by destroying it."
        , "What is this tower?" ->
            @say "This tower was created by the will of our goddess."
            @say "There are many who seek to steal her power, and this tower serves to house and protect her."
        , "Why is the tower off-limits?" ->
            @say "Because our goddess wills it to be. Family, friends, or otherwise. None are to enter the tower."
        */

    leps?interact =!->
        unless Date.now! - switches.lepsy_timer < 43200000
            if session.beat_lepsy or switches.beat_game
                say \leps tl("Hey friend, are you here for another show?")
            else
                say \leps tl("Hey friend, what brings you here? Let's put on a show!")
            say \leps tl("★SEIZURE WARNING★ This battle may trigger seizures. Continue at your own risk.")
            menu tl("Continue"), ->
                say \leps tl("All right! Let me see you dance!")
                say -> start_battle encounter.lepsy
            ,tl("Abort"), ->
                say \leps tl("Well thanks for dropping by.")
                if switches.progress2<9
                    say \leps "If you're looking for Cure-chan, I saw her skulking around northwest of here."
        else
            say \leps tl("Hey, thanks for dropping by.")
            if switches.progress2<9
                say \leps "If you're looking for Cure-chan, I saw her skulking around northwest of here."

    parvo?interact =!->
        unless Date.now! - switches.parvo_timer < 43200000
            say \parvo tl("...Oh, it's you. I don't get many visitors down here.")
            say \parvo tl("Did you come to play?")
            menu tl("Yes"), -> start_battle encounter.parvo
            ,tl("No"),->
                say \parvo tl("...Oh.")
        else
            say \parvo tl("Thanks for playing with me... It was fun.")

    pox?interact =!->
        if switches.beat_game
            say \pox tl("It's kind of cold out here isn't it?")
            return
        if !switches.soulcluster
            say \pox tl("Who turned out the lights?")
        else
            say \pox tl("Hey, the light's on!")
    zmapp?interact =!->
        if switches.curefate
            say \zmapp tl("I'm surprised you decided to let us live. You know I wouldn't do the same for you, right?")
            say \marb tl("You're lucky. If it were up to me, you'd be dead now.")
            say \zmapp tl("Why did you spare us anyway?")
            say \ebby tl("{0} told me it was the right thing to do.", switches.name)
            return
    cure?interact =!->
        if switches.curefate
            say \cure tl("We're definitely not working on another scheme. Don't worry about it!")
            say \cure tl("By the way, can you let me see that skull of yours again? I promise I won't do anything funny.")
            say \ebby \concern tl("I don't trust you...")
            return
        if marb in party
            #TODO make this dialog less stupid
            #say \cure "You're finally here, Marburg. I was getting tired of waiting for you."
            #say \marb "You're still wearing that? You must really like it."
            #say \cure "Shut up, I can't take it off! That little witch sister of yours cursed me!"
            #say \marb "You know why I'm here Cure. I can give Ebola-chan one skull, or I can give her two. Decide fast."
            #say \cure "You'll give her nothing, because I'm going to cure you! I'll cure Ebola too! I'll cure everyone!"
            #say \llov "Um... Llov doesn't want to be cured."
            #say \marb "Don't listen to her Llov, she won't be curing anyone. Let's hurry up and dispose of her."

            say \cure tl("You're finally here, Marburg. I was getting tired of waiting for you.")
            say \cure tl("How nice, you even brought your sister with you. Now I can cure both of you.")
            say \marb tl("Llov, are you ready? It's time to deliver divine punishment.")
            say ->
                start_battle encounter.cure
        else
            say \cure tl("What's a cute little virus like you doing out here all alone?")
            if switches.ate_nae isnt \llov
                say tl("Are you all right? You seem ill. I see the destruction hasn't been kind to you.")
            say tl("Don't worry, I will cure you.")
            say ->
                start_battle encounter.cure_single

    ammit?interact =!->
        say \ammit tl("Love and Justice, friend.")
        unless Date.now! - switches.ammitgift < 3600000
            say \ammit tl("This washed up earlier. You can have it.")
            itemlist=[items.starpuff, items.bleach, items.lifecrystal, items.bandage, items.blistercream, items.teleport, items.plaguescroll, items.slowscroll, items.swarmscroll, items.ex2, items.sp2, items.hp2]
            acquire itemlist[Math.random!*itemlist.length.|.0], (Math.min 5, Math.ceil (Date.now! - switches.ammitgift)/10800000)||5, false, true
            switches.ammitgift=Date.now!
            save!
    aids.2?interact=!->
        dialog.port.mad=true
        music.fadeOut 1000
        say \aids2 tl("Look brother, some filthy insects have come to our doorstep.")
        say \aids1 tl("I wonder what they want?")
        say \aids2 tl("No doubt they're here to impede our pure love.")
        aidstalk!
    aids.1?interact=!->
        dialog.port.mad=true
        music.fadeOut 1000
        say \aids1 tl("Nee-chan look, we have visitors.")
        say \aids2 tl("Filthy insects. Go away, you're impeding our pure love.")
        aidstalk!
    !function aidstalk
        say \ebby tl("We want to help you. Can you come with us?")
        say \aids1 tl("Insect? Is that your name? I can't come with you. Onee-chan told me to never follow strangers.")
        say \aids2 tl("Good girl, I'll have to reward you later.")
        if llov in party then say \llov tl("They don't even recognize us...")
        say -> dialog.port.mad=10
        say \aids2 tl("Now get out of here you insects, before I stomp you out of existance!")
        #say \aids2 "No doubt they're here to put an end to our pure love."
        #say \ebby "Don't you recognize us? We're friends. We want to help you!"
        #say \aids2 "We don't need your help. There's nothing wrong with us."
        #say \aids1 "That's right! The one who is wrong is everyone else!"
        #say \ebby "That's not what I mean..."
        say \marb tl("There's no talking sense into them. They've gone maverick. We have to fight.")
        say ->
            dialog.port.mad=false
            start_battle encounter.aids
    aids.0?interact=!->
        say \aids1 \fused tl("Are you wondering why we're off on our own, away from everyone else?")
        say \aids2 \fused tl("Don't be silly. You know why.")

    rab?interact=!->
        if switches.beat_game
            say \rab \young tl("I wonder what all this cold white stuff is. I've never seen it before.")
            menu tl("Tell her it's water"), !->
                say player.name, tl("It's water.")
                say \rab \young tl("Don't be silly, I know it's not water.")
            ,tl("Say nothing."), !->
                say player.name, tl("...")
            return
        dialog.port.mad=true
        music.fadeOut 1000
        say \rab tl("My, you look tasty.")
        if llov in party
            say \llov tl("Why are you saying? Don't you remember us?")
            say \rab tl("I think I would remember seeing such a tasty piece of meat.")
        say \ebby \concern tl("We need to take you somewhere. Will you follow us?")
        say -> dialog.port.mad=8
        say \rab tl("Oh, you're not going anywhere. 'cept in my stomach.")
        say \marb \angry tl("All you're going to be eating is your own words.")
        say ->
            dialog.port.mad=false
            start_battle encounter.rabies

    sars?interact=!->
        if switches.beat_game
            say \sars tl("Wasn't there supposed to be a visual novel or something? What happened to that?")
            return
        dialog.port.mad=true
        music.fadeOut 1000
        if llov in party
            say \llov tl("Sars-chan, do you remember me? We used to be roommates.")
        else
            say \ebby tl("Sars-chan? Do you have a moment?")
        say \sars tl("Can you please not breathe the same air as me? It's major gross yo.")
        say \ebby tl("Please, we want to help you.")
        say -> dialog.port.mad=3
        say \sars tl("Who you callin' a pipsqueak, eh? Do you want to stop breathing?")
        say \marb tl("Nobody called you short yet, little bug.")
        say -> dialog.port.mad=12
        say \sars tl("That's it! I'll make sure you never take another breath again!")
        say ->
            dialog.port.mad=false
            start_battle encounter.sars


    if switches.beat_game and nae then nae.interact=!->
        say \nae tl("Were you looking for a voluptuous slime girl? You found her.")

    if switches.map is \delta and switches.beat_aids and switches.soulcluster
        # spawn Zika
        zika = new NPC nodes.aids2.x, nodes.aids2.y+TS, \zika
        zika.face \down
        zika.interact=!->
            unless Date.now! - switches.zika_timer < 43200000
                if switches.beat_zika
                    say \zika tl("Hey sweetie. You here for another battle?")
                else
                    say \zika tl("If you can beat me, I'll give you something special.  What do you say?")
                menu tl("Yes"), -> start_battle encounter.zika
                ,tl("No"), -> @say \zika tl("Another time, then.")
            else
                say \zika tl("The view is nice from here. I can almost see the end of the river.")



    #========================================================================================
    # Event Chat
    #========================================================================================

    #if not switches.sleepytime then scenario.states.tutorial!
    #if switches.sleepytime then scenario.states.slimes_everywhere!


    switch switches.progress
    #|\slimeattack => scenario.states.slimes_everywhere!
    #|\pylonfixed => scenario.states.pylonfixed!
    |\curebeat,\zmappbattle => scenario.states.returnfromdeadworld!
    |\zmappbeat => scenario.states.zmappbeat!
    |\towerfall => scenario.states.towerfall!
    |\endgame => scenario.states.endgame!
    default =>
        ss=scenario.states.tutorial
        ss=scenario.states.slimes_everywhere if switches.sleepytime
        ss=scenario.states.pylonfixed if switches.pylonfixed
        #ss=scenario.states.returnfromdeadworld if switches.beat_cure>1
        #ss=scenario.states.towerfall if typeof switches.beat_zmapp is \string
        ss!

    if switches.map is \towertop and !switches.soulcluster and switches.progress2>=16
        scenario.soulcluster!

    scenario.always!

    for f in scenario_mod
        f?!
/*
!function joki_guidance
    #Joki will remind you what you should be doing
    say \joki "TODO"
*/
!function joki_interact
    say \joki tl("Can I help you with anything?")
    args=
        tl("Black Water"), ->
            @say \joki tl("I can fill your vials with Black Water for you. It will cost 1 cumberground each.")
            if items.vial.quantity>0 and items.cumberground.quantity>0
                @say \joki tl("How many vials should I fill?")
                #args=["Nevermind", (->),"Fill 1", (!->items.cumberground.quantity-=1;exchange items.vial, items.tuonen)]
                #args.push "Fill 3", (!->items.cumberground.quantity-=3;exchange 3, items.vial, items.tuonen) if items.vial.quantity>=3 and items.cumberground.quantity>=3
                #args.push "Fill 10", (!->items.cumberground.quantity-=10;exchange 10, items.vial, items.tuonen) if items.vial.quantity>=10 and items.cumberground.quantity>=10
                #args.push "Fill 33", (!->items.cumberground.quantity-=33;exchange 33, items.vial, items.tuonen) if items.vial.quantity>=33 and items.cumberground.quantity>=33
                #args.push "Fill 100", (!->items.cumberground.quantity-=100;exchange 100, items.vial, items.tuonen) if items.vial.quantity>=100 and items.cumberground.quantity>=100
                #@menu.apply @,args
                q= items.cumberground.quantity <? items.vial.quantity
                @number tl("Max:{0}",q), 0 q
                @say ->
                    q= dialog.number.num
                    unless q>0
                        return say \joki tl("You don't want any?")
                    items.cumberground.quantity -= q; exchange q, items.vial, items.tuonen
                    #say \joki "I've filled #q vial#{if q>1 then 's' else ''} for you."
                    say '' tl("Acquired {0} {1}!",stattext(q,5),items.tuonen.name)
        tl("Help"), ->
            @say \joki tl("If there's anything you'd like to know, I can certainly help.")
            @menu tl("Skills"), ->
                @say \joki tl("Even if you know more skills, you can only use 5 of them in combat.")
                @say tl("Use the skills menu to choose which 5 skills you want to use in combat.")
                @say tl("It might be smart to reconsider your active skills before each major battle.")
            ,tl("Crafting"), ->
                @say \joki tl("You can craft items in your inventory to create more useful items, such as potions.")
                #@say \joki "Not every combination makes something useful though. Failed recipes give you cumberground, which can be used as currency."
                @say \joki tl("You should experiment with different recipes. Even if you don't make something useful, you can sell the cumberground you get.")
                @say \joki tl("Cumberground is a byproduct of failed recipes, and can be used as a currency.")
                @say \joki tl("Most reagents are dropped by enemies, but you can also harvest them from trees or flowers.")
            ,tl("Excel"), ->
                @say \joki tl("Excel is a power that lets you accelerate evolution. It grants you new strength and abilites during battle.")
            ,tl("Travel"), ->
                @say \joki tl("The waters here in the Tuonen are a bit hazardous, so travel can be difficult.")
                @say tl("Luckily, it's my job to help transport people such as you between the various realms.")
                @say tl("Alternatively you can use Portal Scrolls to travel on your own. They are made by inscribing Grave Dust upon parchment.")
                @say tl("Parchment can be made by combining any two of cloth, fur, or plant fiber together.")
                if not switches.jokigavescrolls
                    @say tl("Here's a free sample.")
                    switches.jokigavescrolls=true
                    acquire.call @, items.teleport, 5
            ,tl("Nevermind"), ->
        #'Guidance' joki_guidance
    (args.push tl("Transport"), ->
        @say \joki tl("Where do you want to go?")
        args= [tl("Nevermind"), ->]
        for w in warpzones
            (args.push w.name, callback:warp_node, arguments:[w.map, w.node, w.dir]) if switches["warp_#{w.id}"]
        @menu.apply @, args
    ) if switches.warpzones
    args.push tl("Nevermind"), ->
    menu.apply @, args
    void /*
    menu 'Show me your tits, Joki.' ->
        @show 'tits'
        @say "You like what you see?"
    ,'Say something funny.' ->
        @say "My hips are moving on their own{|}"
    ,'Nevermind' ->
    say "Farewell"
    */
    show!

!function cinema_start
    #switches.cinema = true
    #switches.cinema2 = switches.cinema = true
    switches.cinema2 = true
    for actor in actors.children
        actor.cancel_movement?!

!function cinema_stop
    #switches.cinema = false
    #switches.cinema2 = switches.cinema = false
    switches.cinema2 = false

!function set_cinema(state)
    if state then cinema_start!
    else cinema_stop!


scenario = {}
scenario.states = {}
scenario_mod=[]

scenario.always=!->
    if temp.nae_reward
        temp.nae_reward=false
        if skills.poisonstrike not in skillbook.all
            say \nae tl("You really are strong. How about I teach you something?")
            learn_skill \poisonstrike
    if temp.leps_reward
        temp.leps_reward=false
        if skills.seizure not in skillbook.all
            say \leps tl("That was a great show! Let me show my appreciation.")
            learn_skill \seizure
    if temp.parvo_reward
        temp.parvo_reward=false
        if skills.lovetap not in skillbook.all
            say \parvo tl("That was fun! let's play again some time.")
            learn_skill \lovetap
    if temp.zika_reward
        temp.zika_reward=false
        if items.shrunkenhead.quantity is 0
            say \zika tl("As promised, here's your reward.")
            acquire items.shrunkenhead
    if switches.map is \deadworld and switches.famine
        dood = new Doodad(nodes.secretcave.x, nodes.secretcave.y, \jungle_tiles null false) |> carpet.add-child
        #dood.frame=83
        dood.crop new Phaser.Rectangle TS*5, TS*13, TS,TS
    if switches.map is \delta and switches.revivalllov and llov not in party
        scenario.revivalllov!

scenario.game_start =!->
    solidscreen.alpha = 1
    for member in party
        member.visible = false
    cinema_start!
    #camera_center player.x + 4*TS, player.y
    marb.start_location!
    marb.revive!
    marb.face \left
    music.stop!
    switches.nomusic=true

    switches.llovsick = true

scenario.game_start.0 =!->
    #say \ebby \smile "Hello there! It's nice to finally meet you."
    #say -> switches.name = prompt("What is your name?")
    #say '' tl("What is your name?")
    #number '',"text",13
    #say ->
    #    switches.name=dialog.number.num.join('').replace(/_/g,' ').trim()
    #dialog.locked=true
    dialog.textentry.show 13, tl("What is your name?"),(m)!->
        #dialog.locked=false
        #dialog.next!
        if !m then return scenario.game_start.0!
        switches.name=m.trim()
        items.humanskull2.name=switches.name
        say '' tl("Your name is {0}?",switches.name)
        menu tl("Yes"), ->scenario.game_start.0.1!
        ,tl("No"), ->scenario.game_start.0!
scenario.game_start.0.1 =!->
    if getFiles![switches.name]
        say '' tl("A save file already exists. The new game cannot be saved without overwriting the existing save file.")
        menu tl("Continue without saving"), ->
            switches.nosave=true
        , tl("Delete save file"), ->
    #say '' "Voices can be heard coming from outside."
    #say \marb "It's no use. Ebola-chan refuses to leave the tower."
    #say \mal "That's a shame. Our lives could very well depend on her."
    #say \marb "She'll come around, don't worry."
    #say \mal "How can you be so sure?"
    #say \marb "She's depressed because something important was taken from her."
    #say \marb "If that's the case, then all I need to do is get it back."
    #say \marb "After all, when somebody bullies one of my cute sisters, it's my duty to murder the hell out of them."
    #say \mal "What about Lloviu-tan?"
    #say \marb "You and Plague-sama will take care of her while I'm gone. Remember, if anything happens to her..."
    say ->
        Transition.fade 500 1000 ->
            solidscreen.alpha=0
            camera_center player.x + 4*TS, player.y
            #music.play \2dpassion
            switches.nomusic = false
        , scenario.game_start.1
        ,15 false

#scenario.game_start.0.intro =!->
#    say '' "It was the year 20XX, at the height of human arrogance and pride..."

scenario.game_start.1 =!->
    /*
    say \mal "How is she?"
    say \marb "It's not getting worse, but it's not getting better either."
    say \mal "What about Ebola-chan?"
    say \marb "She's still in the tower. I'm told she's had something important taken from her, and that's why she locked herself in."
    say \mal "What will you do?"
    say \marb "What else can I do? I'm going to get it back."
    say \mal "Do you even know what you're looking for?"
    say \marb "It's in the land of the dead. Aside from that... Well, I think Joki knows more than she's letting on."
    */
    #scene: Llov is in bed, Marburg stands by her side.
    #equip_item items.bow, llov
    say \marb tl("Llov, are you awake?")
    say \marb tl("I'm sorry, I would love nothing more than to stay by your side...")
    say \marb tl("But I must go. Don't worry, I'll be back before you realize.")
    #say "I have to go somewhere now. Don't worry, I'll be back soon."
    #say "That thing they stole... I need to get it back. It's very precious to her."
    #say "Don't worry though, I'll be back soon enough."
    #say "Maybe before I return, you'll even find yourself on an adventure of your own."
    say tl("Plague and Malaria will be here to take care of you. Go to them if you need anything.")
    #say "And remember, if you find yourself in a battle you don't think you can win, there's no shame in running."
    #Marburg exits stage.
    marb.move 0 1.5
    marb.move 2 0
    marb.move 0 1
    marb.path.push ->
        
        marb.kill!
        setTimeout ->
          Transition.wiggle doodads.llovbed, 4 300 1 -> setTimeout ->
            getoutofbed!
          ,100
        , 1400
    !function getoutofbed
        doodads.llovbed.animations.frame = 1
        say \llov \sick tl("Marburg-nee... Llov wants to go too.")
        say ->
            doodads.llovbed.alpha=0
            for member in party
                member.visible = true
            player.face \right
            cinema_stop!
            setswitch \started true

scenario.states.tutorial =!->
    
    if switches.map is \hub
        joki.1?relocate \joki_bridge
        joki.1?face \left

    mal?interact =!->
        if switches.gotmedicine and switches.askaboutmarb
            if not switches.llovmedicine
                say \mal tl("Is that the medicine Plague-sama gave you?")
                say \mal tl("Plague-sama is a doctor, so you should listen to what she says.")
            else
                say \mal tl("Plague-sama told you to get some rest right? Your bed is waiting right through this door.")
            return

        if not switches.talktomal
            say \mal tl("Why if it isn't Lloviu-tan. Are you awake already?")
            setswitch \talktomal true
        if not switches.askaboutmarb
            say \llov \sick tl("Where is Marburg-nee?")
            say \mal tl("I'm afraid she's left already, you just missed her. I'm sure she'll be back soon, though.")
            setswitch \askaboutmarb true
        if not switches.gotmedicine
            say \mal tl("Plague-sama told me she had something for you. You should go see her.")
    jokioverride = joki.1?interact
    joki.1?interact =!->
        if not switches.askjokiaboutmarb
            say \joki tl("Lloviu-san, is it? What might you need?")
            say \llov \sick tl("Did Marburg-nee go this way?")
            say \joki tl("Not this way. I ferried her to the Land of the Dead.")
            say \llov \sick tl("Can you take Llov too?")
            say \joki tl("Hmm, I'm afraid you wouldn't survive the journey in your condition.")
            switches.askaboutmarb = true
            setswitch \askjokiaboutmarb true
        else
            jokioverride ...
    
    bp?interact =!->
        if not switches.gotmedicine
            say \bp tl("Lloviu-tan, there you are. I have something for you.")
            switches.gotmedicine = true
            acquire items.llovmedicine
            say \bp tl("This tonic should help you regain some of your strength. Try to get some rest after you take it.")
        else if not switches.llovmedicine
            say \bp tl("What do you need?")
            menu tl("What is this medicine?"), ->
                @say tl("The vial contains liquid vitae. It is the energy that we need to survive.")
                @say tl("It is secreted by living things, and can also be harvested from human souls.")
                @say tl("This vitae was provided by your sister. She made this tower to harvest vitae from the souls she collected.")
                #@say "Normally it is secreted by living things, but since our primary source of energy was destroyed, we must search for other sources."
            , tl("Why am I sick?"), ->
                #@say "Without a source of energy we  weak."
                @say tl("Put simply, your reservoir was destroyed.")
                @say tl("Without a reliable source of energy, you've gradually grown weak.")
                @say tl("The medicine I gave you should help you regain your strength.")
                #@say "Since you aren't infectious to humans, this means you've been without a source of energy for a long time."
                #@say ""

                #@say "When we found you in the wilderness you had already been without a source of energy for too long."
                #@say "You're lucky you weren't devoured by some beast, or by another virus."
                #@say "Any way, as long as you stay near the tower and drink the medicine I give you, you should recover."
                
                #@say "Unlike your sisters, you are not infectious to humans. Instead, you rely on a reservoir of bats."
                #@say "Unfortunately though, your reservoir was destroyed through the reckless action of humans."
                #@say "For longer than the rest of us, you have been without a reliable source of energy. Coupled with the fact that you were never a powerful virus to begin with."
                #@say \llov \sick "Won't you and the others get sick too?"
                #@say \bp "Not necessarily. For now, the black tower provides us enough energy to live. If only we could find another source though..."
            , tl("How do I take the medicine?"), ->
                @say tl("Open the pause menu by hitting the escape key or right clicking with your mouse. Then, select the \"items\" option.")
                @say tl("You're a smart girl, so I think you should be able to figure out the rest on your own.")
        else
            say \bp tl("You drank the medicine? good. Now you should get some rest.")

    llovbedinteract = doodads.llovbed?interact
    doodads.llovbed?interact =!->
        if switches.llovmedicine and not switches.sleepytime
            music.fadeOut 1000
            cinema_start!
            Transition.fade 500 1000 ->
                switches.llovsick = false
                setswitch \sleepytime true
                for member in party
                    member.visible = false
                doodads.llovbed.alpha=1
                player.start_location!
                camera_center player.x + 4*TS, player.y
            , ->
                setTimeout ->
                    sound.play \boom
                    Transition.shake 8 50 1000 0.95 ->
                        doodads.llovbed.animations.frame = 1
                        say '' tl("Something is happening outside!")
                        say ->
                            doodads.llovbed.alpha=0
                            for member in party
                                member.visible = true
                            player.face \right
                            cinema_stop!
                    ,false
                ,1000

                # One of the pylons is destroyed and the town is under attack
                # Play a sound effect and shake the screen.
            ,15 false
        else if switches.gotmedicine and not switches.sleepytime
            say \llov \sick tl("Not yet, I need to take the medicine first.")
        else if switches.sleepytime
            say '' tl("Can't sleep right now.")
        else
            llovbedinteract!

scenario.states.slimes_everywhere =!->
    if switches.map is \hub
        joki.1.relocate \joki_bridge
        if switches.jokistepsaside
            joki.1.y -= TS
            joki.1.cancel_movement!
        joki.1.face \left

        neutral_slime mal.x, mal.y
        mal.shift -TS, 0
        mal.face \right

        bp.face \downright
        bp.shift -TS, -TS
        neutral_slime bp.x, bp.y+TS
        neutral_slime bp.x+TS, bp.y

        for node in [nodes.mob1, nodes.mob2, nodes.mob3, nodes.mob4, nodes.mob5, nodes.mob6]
            neutral_slime node.x, node.y+TS

    mal?interact =!->
        say \mal tl("Please, just go inside. We can handle this.")
        say tl("If something were to happen to you, Marburg would...")
        say -> mal.face \right

    bp?interact =!->
        unless session.talktobp
            say \bp tl("Damn, they're everywhere.")
            say \llov tl("What can Llov do to help?")
            say \bp tl("Listen, I know you're feeling better, but you're still ill.")
            say \bp tl("Go back inside and rest.")
            session.talktobp=1
        else
            say \bp tl("Didn't you hear me? Go and hide. It's not safe out here.")


        say -> bp.face \downright
        


    !function neutral_slime (x,y)
        slime = new NPC x, y, \mob_slime, Math.random!*2+5
        slime.setautoplay \simple
        slime.interact =!->
            #sound.play \groan
            say 'Slime' tl("Wub wub wub...")
            say \llov \scared tl("...!")

    doodads.llovbed?interact =!->
        say '' tl("Can't sleep right now.")

    jokioverride = joki.1?interact
    joki.1?interact =!->
        if switches.jokistepsaside
            say \joki tl("Find Smallpox. She can fix the pylon.")
            jokioverride ...
            return
        unless switches.whatcanllovdotohelp
            say \joki tl("Lloviu-san, such a pleasure.")
            say \llov tl("What happened?")
            #say \joki "The pylons that protect this area. One was damaged."
            say \joki tl("One of the pylons that protect this area was damaged.")
            say \llov tl("What can Llov do to help?")
        else
            say \llov tl("Llov wants to help after all!")
        setswitch \whatcanllovdotohelp true
        say \joki tl("It will be dangerous. Are you sure?")
        menu 'Yes' ->
            @say \joki tl("Smallpox built the pylons. she can fix them. Find her.")
            @say \joki tl("Remember, you are the sister of Marburg and Ebola. You are stronger than you think.")
            @say \joki tl("Go now, cross this bridge. Have no fear, I am already waiting for you on the other side.")
            @say ->
                setswitch \jokistepsaside true
                joki.1.move 0 -1
                joki.1.path.push ->
                    joki.1.face \left
        , 'No' ->
            @say \joki tl("Understandable.")
    joki.2?interact =!->
        if !switches.beat_nae
            say \joki tl("Smallpox should be in this cabin, but there's a problem.")
            say \joki tl("The person standing in front of the door. Do you recognize her?")
            say \joki tl("It's Naegleria, and it looks like she's gone mad.")
            say \joki tl("We have no choice but to put her down. I can't take her on my own though, not with this body.")
            if items.shinai.quantity<1
                say \joki tl("I left a kendo stick in one of the houses near the tower.")
            say \joki tl("If you're going to fight her, be careful.")
        else
            jokioverride ...

    pox?interact =!->
        if switches.pylonfixed
            say \pox \injured tl("Hurry on back to the tower. I'll be going there soon too.")
            return
        #say \pox \injured "Lloviu-nya, why are you here? What happened to Nae?"
        say \pox \injured tl("Lloviu-nya, what are you doing are you here?")
        say \llov tl("You're hurt! What happened?")
        say \pox \injured tl("I was trying to fix the pylon... when I was ambushed by an old friend.")
        say \pox tl("What happened to her anyway? Naeglera.")
        if switches.ate_nae
            say \llov tl("Nae-tan? Llov ate her.")
            say \pox \injured tl("You ate her? I hope you don't get a stomach ache.")
        else
            say \llov tl("Nae-tan is... Llov had no choice.")
            say \pox \injured tl("I see, that's unfortunate. She used to be such a good friend.")
        #say \llov "Joki said Smallpox can fix the pylon."
        #say \pox \injured "Ah yes, it was damaged wasn't it? Don't worry, I'll fix it."
        #say \pox \injured "After I fix it, I hope you don't mind if I borrow your bed. I could use some rest."
        say \pox \injured tl("Well, at least now I can get back to fixing the pylon.")
        say \pox \injured tl("After I'm done, I hope you won't mind if I borrow your bed. I need some time to recover.")
        say ->
            switches.checkpoint_map='hub'
            switches.checkpoint='nae'
            switches.lockportals=true
            setswitch \pylonfixed true

    if switches.map is \hub and not switches.slimes_everywhere
        scenario.slimes_everywhere!
        setswitch \slimes_everywhere true

    if switches.map is \hub and switches.beat_nae and not switches.beat_nae2
        scenario.beat_nae!
        setswitch \beat_nae2 true

scenario.slimes_everywhere =!->
    player.face_point mal
    mal.face \left
    say \mal tl("Lloviu! Don't come out, it's dangerous right now!")
    say -> mal.face \right

scenario.beat_nae =!->
    cinema_start!
    player.relocate \nae
    joki.2.move 0 4
    joki.2.move -5 0
    joki.2.path.push ->
        player.face_point joki.2
        say \joki tl("You beat her? Good. I knew you had it in you.")
        say \joki tl("You got a soul for beating her right? If you hang on to it, she can probably be saved.")
        say \joki tl("I'll let you decide what to do with it, we have more urgent matters at hand.")
        say ->
            cinema_stop!

scenario.states.pylonfixed =!->
    if switches.map is \hub
        joki.1.relocate \joki_bridge
        joki.1.y -= TS
        joki.1.cancel_movement!
        joki.1.face \left
        unless switches.pylonfixed>=2
            joki.2.relocate \pox_cabin
            joki.2.x+=TS; joki.2.y+=TS
            joki.2.cancel_movement!
            joki.2.face \left
            player.face \right
            say \joki tl("Good job, it looks like the pylon is already operational again.")
            say \llov tl("Llov wants to find Marburg-nee")
            say \joki tl("I took Marburg to the land of the dead by her request.")
            say \joki tl("You seem like you've recovered your strength. All right, I'll take you to her.")
            say \joki tl("Meet me back at the docks near the tower.")
            say -> setswitch \pylonfixed 2
        scenario.spawn_minion_bridge! if switches.confronting_joki
    if not switches.confronting_joki and switches.map is \hub
        bp.relocate \joki_bridge
        bp.y -= TS
        bp.x -= TS*3
        bp.cancel_movement!
    if switches.confronting_joki and switches.map is \hub
        joki.1.kill!
        Actor::relocate.call Doodad.boat, \boat2

    scenario.poxbed!

    pox?interact =!->
        say \pox \injured tl("Hurry on back to the tower. I'll be going there soon too.")

    jokioverride = joki.1?interact
    #joki.1?interact =!->
    #    if switches.map is \deadworld
    #        say \joki "Marburg is somewhere nearby. You want to find her right?"
    #        return

    joki.2?interact =!->
        if switches.map is \deadworld or marb in party
            jokioverride ...
            return
        if !switches.confronting_joki
            say \joki tl("Meet me back at the docks near the tower.")
            return
        unless switches.confronting_joki>=2
            say \joki tl("Sorry about that, it seems I was killed.")
            say \joki tl("I can still take you to Marburg if you want. Are you ready?")
            setswitch \confronting_joki 2
        else
            say \joki tl("You'll find Marburg in the land of the dead. Want me to take you there?")
        menu tl("Yes"), ->
            warp_node \deadworld \landing \up
            switches.warpzones=true
            switches.warp_deadworld=true
            switches.warp_hub2=true
            save!
        ,tl("No"), ->

    bp?interact =!->
        if marb in party
            if switches.bp_has_nae
                scenario.bp_nae_soul2!
                return
            if player is marb
                say \bp tl("Marburg, did you find what you're looking for?")
            else
                say \bp tl("I don't know how you slipped away, but Marburg doesn't seem angry so I suppose it's fine.")
                #say \bp "Thank goodness you're okay. If you were hurt Marburg would kill us."
            return
        if items.naesoul.quantity>0
            scenario.bp_nae_soul!
            if items.tunnel_key.quantity<1
                say \bp tl("By the way, Smallpox came by earlier. You should greet her.")
                say \bp tl("She's waiting for you in your house.")
            return
        if items.tunnel_key.quantity<1
            say \bp tl("Have you greeted Smallpox yet? She's waiting for you in your house.")
            return
        if !session.pylonfixedbp or Math.random!<0.7
            say \llov tl("Let Llov go to Marburg-nee.")
            say \bp tl("I'm keeping you here for your own good. Don't you understand?")
            say \llov tl("The one who doesn't understand is Plague-sama!")
            session.pylonfixedbp=true
            return
        say \bp tl("Please, just stay put until Marburg gets back.")
        say \llov tl("But... Llov wants to go help Marburg-nee.")
        say \bp tl("Why won't you understand?")

    mal?interact =!->
        if marb in party
            if player is marb
                say \mal tl("Marburg! You're back already?")
            else
                say \mal tl("Oh good, I see you found Marburg.")
            return
        unless switches.talktomal>=2
            if items.tunnel_key.quantity<1
                say \mal tl("Smallpox came by earlier. She's resting in your bed now.")
            say \mal tl("We really were worried about you, you know?")
            say \llov tl("Because you were told to protect Llov?")
            say \mal tl("Well, that's also true, but we're friends right? I'd protect you even if I wasn't ordered to.")
            #show llov determined
            say \llov tl("Then come with Llov.")
            say \mal tl("I don't know, that sounds dangerous. You should just do what Plague-sama tells you.")
            say -> 
                setswitch \talktomal 2
            return
        unless switches.talktomal>=3
            say \mal tl("You're really not going to listen to us are you? You always were so stubborn...")
            say tl("Since there's nothing I can do to stop you, at least take this.")
            say -> 
                acquire items.fan, 1 false true
                setswitch \talktomal 3
            return
        if items.tunnel_key.quantity<1
            say \mal tl("I think Smallpox wants to talk with you. She's inside here.")
        else
            say \mal tl("Please don't be reckless.")

scenario.tunneldoorlocked =!->
    say '' tl("The door is locked.")
    if switches.pylonfixed
        say \llov tl("Smallpox's maintenance tunnel...")
        say \llov tl("If Llov could get in here, then Llov could go where Marburg-nee is!")
        say \llov tl("Smallpox should be in Llov's bed right now.")
    player.move 0, 0.5
scenario.poxbed =!->
    if switches.map is \shack2
        doodads.llovbed.alpha=1
        doodads.llovbed.load-texture \poxsick
        doodads.llovbed.interact =!->
            doodads.llovbed.animations.frame=1
            if player is llov
                say \pox tl("Oh, Lloviu-nya. Thanks again for lending me your bed.")
            else
                say \pox tl("Don't mind me, I'll be recovered soon.")
            if not items.tunnel_key.quantity
                say \llov tl("Llov needs to find Joki-tan.")
                say \pox tl("Joki? Doesn't she just hang around everywhere? I think I saw one of her outside the cabin where you found me.")
                say \llov tl("The bridge is blocked, Llov can't get there.")
                say \pox tl("I guess you'll need to find another way then. Here, take this.")
                switches.lockportals=false
                acquire items.tunnel_key
                say \pox tl("This key opens up the maintenance tunnel. The entrance is in a building to the south. It should take you where you need to go.")
            say -> doodads.llovbed.animations.frame=0

scenario.spawn_minion_bridge =!->
    return if marb in party
    min = new_npc nodes.confronting_joki, \min
    min.x+=TS*2
    min.y+=TS
    min.cancel_movement!
    min.face \left
    min.interact=!->
        if player.x>@x
            sound.play \strike
            dood.revive!
            @kill!
            session.minionsplat=true
            return
        say \min tl("Order from Plague-sama. Bridge blockade.")
        say \llov tl("Please, let Llov through.")
        say \min tl("Cannot comply. Please speak with Plague-sama.")
    dood = new Doodad(min.x, min.y, \1x1 null false) |> carpet.add-child
    dood.kill!
    dood.frame=13
    dood.anchor.set 0.5, 1
    initUpdate dood
    if session.minionsplat
        dood.revive!
        min.kill!
    return min

scenario.confronting_joki =!->
    cinema_start!
    bp.move 2 0
    bp.path.push ->
        say \bp tl("What were you thinking? You could have got her killed!")
        say \joki tl("I only did what she wished.")
        say \bp tl("Marburg told us to keep her safe!")
        #say \joki "You're not really concerned for Lloviu's safety, you're just afraid or Marburg's wrath."
        say \joki tl("You do not fear for the girl's safety, you only fear Marburg's wrath.")
        say \bp tl("Enough of this. If you're going to get in our way, then you're not welcome here.")
        say ->
            switches.checkpoint_map=switches.checkpoint=\hub
            joki.1.waterwalking=true
            save!
            joki.1.load-texture \joki_fireball
            joki.1.add_simple_animation!
            #joki.1.animations.play \simple
            joki.1.setautoplay \simple 12
            joki.1.move 3 0
            joki.1.animations.currentAnim.onLoop.addOnce (->
                @kill!
                bp.move -3 0
                bp.path.push ->
                    min=scenario.spawn_minion_bridge!
                    Dust.summon(min.x,min.y)
                    cinema_stop!
            ), joki.1

scenario.states.returnfromdeadworld =!->
    scenario.poxbed!

    if switches.map is \deadworld
        if switches.progress2 is 9
            say '' tl("Cure-chan's soul escaped into the distance.")
            say \marb tl("We got the skull, let's deliver it to Ebola-chan.")
            say tl("She's waiting for us in the Black Tower.")
            switches.warp_hub1=true
            switches.warp_curecamp=true
            setswitch \progress2 10

    bp?interact =!->
        say \bp tl("I see you found what you were looking for. Ebola-chan is probably waiting for you.")

    mal?interact =!->
        say \mal tl("You're going into the tower?")
        say tl("I know the tower is what gives us energy, but still... It's kind of spooky.")

    Actor.wraith?interact =!->
        say \wraith tl("The tower is off-limits. Ebola-chan is not taking visitors at the moment.")
        say \marb tl("We have important business with Ebola-chan. Let us through.")
        say \wraith tl("Hostility detected. Cannot comply.")
        say \llov tl("Please mister wraith, this skull is important to Ebola-chan. Let us deliver it.")
        say \wraith tl("Hostility detected. Cannot comply.")
        say \marb tl("The damn creature must be broken. I don't think it'll listen to reason, we're going to have to force our way in.")
        say ->
            start_battle encounter.wraith_door

    if switches.map is \towertop and switches.progress is \zmappbattle
        dood = new Doodad(nodes.down.x+HTS, nodes.down.y+TS, \flameg null true) |> actors.add-child
        dood.anchor.set 0.5 1.0
        dood.simple_animation 7
        dood.random_frame!
        updatelist.push dood
        zmapp?interact=!->
            switch switches.zmapp
            | -1 => say \zmapp tl("Still haven't had enough?")
            default => say \zmapp tl("Stay down.")
            say -> start_battle encounter.zmapp
        for node in [nodes.wraith1, nodes.wraith2, nodes.wraith3, nodes.wraith4]
            w = new NPC node.x, node.y, \wraith
            w.setautoplay \down
            w.interact =!->
                say \wraith tl("Care for a battle?")
                menu \Yes -> start_battle encounter.wraith
                ,\No ->
    ebby?interact=scenario.ebbytower1

scenario.states.zmappbeat =!->
    setTimeout !->
        cinema_start!
        camera_center zmapp.x, zmapp.y

        for p,i in party
            p.y=zmapp.y - TS*3
            p.x=zmapp.x + (i+1)%3*TS - TS
            p.face_point zmapp
            #p.revive!
            #p.stats.hp=1
    , 1
    if switches.zmapp is \victory
        say \zmapp tl("You may have defeated me, but it's too late.")
    else
        say \zmapp tl("Pathetic. Is that really all the power you can muster?")
        say tl("Oh well, it doesn't really matter.")
    say \zmapp tl("I've already destabilized the soul cluster.")
    say !-> cg.show 'cg_tower0', !-> Transition.timeout 1000, !->
        #TODO: remove this line once water boots are in
        #switches.water_walking=true
        #
        cg.showfast 'cg_tower1'
        switches.soulcluster=false
        switches.progress2=16
        setswitch \progress \towerfall
        sound.play \boom
        Transition.shake 8 50 1000 0.95 !->
            cg.showfast 'cg_tower2'
            for f in Doodad.list
                newkey=fringe_swap f.key
                if f.key isnt newkey
                    oldframe=f.frame
                    f.load-texture newkey
                    f.frame=oldframe
            tile_swap!
            Transition.timeout 1000, !-> cg.hide !->
                say \zmapp tl("Ah, that feels better.")
                say \ebby \concern tl("No way! She stole all the human souls!")
                say \marb \angry tl("That bitch! She won't get away with this!")
                say \zmapp tl("Now that I have what I came for, I'll be on my way. I have grand designs to fulfill.")
                #say \zmapp "Sayonara!"
                say ->
                    Dust.summon zmapp.x, zmapp.y
                    zmapp.kill!
                    Transition.timeout 1000, ->
                        say \marb \troubled tl("She got away!")
                        say \ebby \concern tl("They're so far away now. I can hear them calling for me.")
                        say \marb tl("Don't worry, we'll get them back.")
                        say \llov tl("That's right! Zmapp is a bully. When we find her we'll beat her up!")
                        say \marb tl("Do you know where she went?")
                        say \ebby \concern tl("She only absorbed a fraction of the souls. Most of them escaped from her.")
                        say \marb tl("We'll get those ones first. I'm sure Joki can take us where they landed.")
                        #say '' "This is the end of the demo. Thanks for playing!"
                        #say '' "By the way, you can walk in water now."
                        
                        say ->
                            cinema_stop!
                            scenario.soulcluster!
                    ,true
                
        ,false


scenario.bp_nae_soul =!->
    say \bp tl("What is that? A soul?")
    say \llov tl("It came out from Nae-tan")
    say \bp tl("Give it here. You have no business handling something so dangerous.")
    menu tl("Give her the soul"), ->
        items.naesoul.quantity=0
        #save!
        setswitch \bp_has_nae true
        @say \bp tl("Good. Now stay away from dangerous things from now on.")
    , tl("Do not"), ->
        @say \bp tl("...")

scenario.bp_nae_soul2 =!->
    say \bp tl("Marburg, there you are.")
    say \bp tl("I took this from Llov earlier, but I don't have any use for it.")
    say \bp tl("I think you should decide what to do with it.")
    switches.bp_has_nae=false
    acquire items.naesoul
    if llov in party
        say \marb tl("Is this Naegleria? Where did you find this?")
        say \llov tl("It came out of Nae-tan...")
        say \bp tl("From what I hear, Naegleria was taken by the madness.")
    else
        say \marb tl("Is this Naegleria? I wonder where she got it from.")
        say \bp tl("From what I hear, Naegleria was taken by the madness. Llov is the one who stopped her.")
    say \marb tl("The madness... How unsettling.")
 
scenario.ebbytower1 =!->
    ebby.face \down
    #say \ebby "!"
    say \ebby tl("Lloviu-tan, Marburg-nee! What a surprise!")
    say \ebby tl("What brings you here? Just visiting?")
    say \llov tl("We're here on a delivery!")
    say \ebby tl("A delivery? What did you bring?")
    say \marb \smile tl("Something lost. Can you guess what it is?")
    say \ebby \smile tl("Hold on, yes! I can sense it!")
    say \ebby tl("It's {0}! You brought {0} back to me!",switches.name)
    say ->
        items.humanskull.quantity=0
        acquire items.humanskull2, 1, true, true
    say '' tl("Marburg gave the human skull back to Ebola-chan.")
    say \ebby \smile tl("Oh, thank you so much! I love both of you!")
    #say \llov \smile "Yay! Llov loves Ebola-chan too!"
    say \marb \smile tl("Ebola-chan just isn't complete without her signature skull, isn't that right?")
    say \ebby tl("I missed you so much, {0}! Cure-chan didn't do anything strange to you did she?",switches.name)
    say \ebby \concern tl("Hold on, something's not right.")
    say ->
        #stop the music
        music.fadeOut 1000
    say \ebby tl("What's that inside you?")
    #Zmapp comes out
    say ->
        #switches.ebbytower0=false
        cinema_start!
        z = new Phaser.Sprite game, ebby.x, ebby.y, \z, 0 |> fringe.add-child
        z.animations.add \simple, null, 7, true
        z.animations.play \simple
        z.anchor.set(0.5,0.5)
        z.sx=z.x; z.sy=z.y; z.time=Date.now!
        updatelist.push z
        z.update=!->
            i=(Date.now! - @time)/2000 <? 1
            @x=@sx + game.math.bezierInterpolation([0,-128,0],i)
            @y=@sy + game.math.bezierInterpolation([0,-128,0,64],i)
            game.camera.center.x = @x; game.camera.center.y = @y
            if i is 1
                @update=!->
                @load-texture \zburst
                z.animations.add \simple, null, 7, false
                z.animations.play \simple
                z.animations.currentAnim.onComplete.add !->
                    z.update-paused=!-> @destroy!; updatelist.remove @
                    scenario.ebbytower2!
                zmapp := new NPC z.x, z.y+HTS, \zmapp
                zmapp.face \up
                for p in players
                    p.face_point zmapp
scenario.ebbytower2 =!->
    say \zmapp tl("Surprise!")
    say \zmapp tl("A trojan horse. Pretty ironic right?")
    say \ebby \shock tl("Zmapp!? You're still alive?")
    say \zmapp tl("This tower belongs to me now. All the human souls here too!")
    say ->
        switches.checkpoint_map=switches.map
        switches.checkpoint=\cp
        switches.zmapp=0
        join_party \ebby save:false front:true startlevel:26
        equip_item items.humanskull2, ebby, true
        switches.progress=\zmappbattle
        switches.lockportals=true
        #cinema_stop!
        start_battle encounter.zmapp

scenario.soulcluster =!->
    return unless switches.map is \towertop and !switches.soulcluster and switches.progress2>=16
    dood = new Doodad(nodes.zmapp.x+TS, nodes.zmapp.y+TS+TS, \flame null true) |> actors.add-child
    dood.anchor.set 0.5 1.0
    dood.simple_animation 7
    updatelist.push dood
    dood.interact =!->
        if items.humansoul.quantity<1000000
            say '' tl("1 million souls required to rekindle the soul cluster.")
        else
            items.humansoul.quantity -= 1000000
            switches.llovsick1=4 if switches.llovsick1>0
            switches.soulcluster=true
            cg.show 'cg_tower2', !-> Transition.timeout 1000, !->
                cg.fade 'cg_tower0', !->
                    schedule_teleport pmap:switches.map
                    Transition.timeout 1000, !-> cg.hide !->
                        say '' tl("The soul cluster bursts back to life, illuminating the river.")
                        scenario.delta_finished2!

scenario.talk_pest =!->
    cg.show (if switches.soulcluster then \cg_pest else \cg_pest_night), ->
        revivalmenu=true
        if switches.progress2 < 23
            say \pest tl("It's been a long time. It's good to see you again.")
            say \pest tl("As you can see, I'm not in the best of shapes. But you seem well enough.")
            say \pest tl("Since you're here, maybe you can help me with something.")
            #say \pest "The viruses in this land are afflicted with madness."
            say \pest tl("The viruses in this land have fallen into madness.")
            say \pest tl("They have lost themselves. I can help them, but you must bring them to me.")
            say \pest tl("If they won't cooperate, just bringing their souls should be enough. I can reconstitute them.")
            say \pest tl("One more thing.")
            #say \pest "If nothing is done soon, the madness will take them completely."
            say \pest tl("You cannot travel this region by land. There are no bridges to connect many of the islands.")
            say \pest tl("You must speak to Joki. She can properly equip you.")
            say ->
                setswitch \progress2 23
            #return
        else if switches.progress2<24
            say \pest tl("You must speak to Joki. She can properly equip you.")
            #return
        else if switches.llovsick and llov not in party and switches.llovsick1 is true
            say \pest tl("Where is miss Llov? Wasn't she with you?")
            revivalmenu=false
        else if switches.llovsick1 is 2
            session.pestypleasehelpllov=1;
            say \ebby \concern tl("Llov is sick. Please, can you help her?")
            say \pest tl("It's probably just malnourishment.")
            say \pest tl("If you provide me with human souls, I can extract the energy from them and feed it to her.")
            say \pest tl("1000 souls should be enough. That would sustain her for quite a while.")
            if items.humansoul.quantity >= 1000
                menu tl("Feed her 1000 souls"), scenario.llovsick2
                ,tl("Do not"), !->
            revivalmenu=false
        else if switches.llovsick1 is 3
            scenario.llovsick3!
            revivalmenu=false
        else if switches.llovsick1 is 4 and !session.mourning and switches.progress is \towerfall
            scenario.llovsick4!
            revivalmenu=false
            session.mourning=true
        else if switches.ate_sars or switches.ate_rabies or switches.ate_eidzu
            say \pest tl("I asked you to help me save them, and you ate them instead.")
            say \pest tl("If I didn't know better, I would think you were going mad too.")
        else if switches.revivalsars and switches.revivalsars and switches.revivalrab and !items.pest.quantity
            say \pest tl("You've done what I asked. I think you deserve a reward.")
            acquire items.pest, 1
            say \pest tl("This is my sword. Take good care of it.")
        else if switches.llovsick1 is 4
            say \pest tl("I can only revive someone if I have their soul.")
        else if switches.beat_sars and switches.beat_rab and switches.beat_aids
            say \pest tl("Thank you for helping me with this task.")
        else
            say \pest tl("The viruses in this land have fallen into madness.")
            #say \pest "The viruses in this land are afflicted with madness."
            say \pest tl("They have lost themselves. I can help them, but you must bring them to me.")
            say \pest tl("If they won't cooperate, just bringing their souls should be enough. I can reconstitute them.")
            #return
        if revivalmenu
            if items.naesoul.quantity>0 and switches.beat_nae2 isnt 2
                #session.naesoul=true
                switches.beat_nae2=2
                say tl("What's this? You already have a soul with you. Is that Naegleria?")
            souls=[]
            souls.push items.llovsoul if items.llovsoul.quantity
            souls.push items.naesoul if items.naesoul.quantity
            souls.push items.sarssoul if items.sarssoul.quantity
            souls.push items.aidssoul if items.aidssoul.quantity
            souls.push items.rabiessoul if items.rabiessoul.quantity
            souls.push items.chikunsoul if items.chikunsoul.quantity
            if souls.length>0 and not nodes.revival.occupied
                say \pest tl("Should I revive someone?")
                menuset=[tl("Cancel"), ->]
                for soul in souls then menuset.push soul.soulname, callback:revivesoul, arguments:[soul]
                menu.apply null, menuset
        #say \pest "I won't lie to you, I am dying."
        #say \pest "Ah, Ebola-chan-tachi. I'm glad to see you're still yourselves."
        #say "The viruses in this land have fallen into madness."
        #say "I'm not sure what's causing it, but I suspect they've been vaccinated."
        #say "It's sad, but they must be destroyed. Don't worry though, they can still be saved."
        #say "If you bring them to me then I can reconstitute them. If they won't come, then bringing their souls will also work."
        #say "If you bring me their souls, we can probably reconstitute them."
        say ->
            cg.hide temp.oncghide
            delete! temp.oncghide if temp.oncghide
            player.move(0,0.5)
    !function revivesoul soul 
        soul.quantity = 0
        switch soul
        |items.naesoul
            @say !->
                setswitch \revivalnae true
                nae := node_npc(nodes.revival,'naegleria',2)
                nae.setautoplay('down')
                nae.interact =!->
                    say \nae tl("It feels good to be myself again. Thank you.")
                    say \nae tl("I'll be around, if you need me.")
                    say warp
        |items.sarssoul
            @say !->
                setswitch \revivalsars true
                sars.relocate \revival
                sars.interact=!->
                    #say \sars "Onee-sama! Please forgive my earlier rudeness, I just wasn't myself."
                    #say \marb "Who are you calling \"Onee-sama\"? I only have two sisters, little bug."
                    #say \sars "Ahn~ Your cold words cut like swords in my heart, Onee-sama!"
                    say \sars tl("I'm sorry for my rudeness earlier. You know I treasure your friendship more than anything.")
                    if switches.revivalaids
                        say \marb tl("That's strange. The other ones changed after they were reconstituted, but this one looks the same.")
                        say \sars tl("I did change! I'm 1cm taller now! I swear!")
                    say warp
        |items.aidssoul
            @say \pest tl("Their souls have become entangled. It might be difficult to separate them...")
            @say tl("Oh well, I'm sure it will be fine.")
            @say !->
                setswitch \revivalaids true
                #aids.1.relocate nodes.revival.x, nodes.revival.y+TS
                #aids.2.relocate nodes.revival.x+TS, nodes.revival.y+TS
                aids.0 = node_npc(nodes.revival,'aids3')
                aids.0.interact=!->
                    say \aids1 \fused tl("Onee-chan and I are stuck together. What happened?")
                    say \aids2 \fused tl("Don't worry, this just means we'll be together forever.")
                    say \aids1 \fused tl("Onee-chan... I think I could get used to this.")
                    say warp
        |items.rabiessoul
            @say !->
                setswitch \revivalrab true
                rab.relocate \revival
                rab.interact=!->
                    say \rab \young tl("I do know what Pestilence did, but it worked wonders. I feel so young!")
                    say tl("Most of my clothes don't seem to fit any more though. Did I lose weight?")
                    say tl("Here, you can have this.")
                    acquire items.torndress, 1
                    say \rab \young tl("Now if you'll excuse me, I'm going to find something to eat.")
                    say warp
        |items.chikunsoul
            @say !->
                setswitch \revivalchikun true
                chikun=node_npc(nodes.revival,'chikun')
                chikun.interact=!->
                    say \chikun tl("Resurrecting me was a mistake, you know.")
                    say \chikun tl("Do you think I only killed them because I was mad?")
                    say \chikun tl("No, I willingly fell into madness.")
                    say \chikun tl("You should hope that we never meet again.")
                    acquire items.soulshard, 2
                    say warp
        |items.llovsoul
            @say scenario.revivalllov
        nodes.revival.occupied=true
        @say \pest tl("It's done. {0} has been reconstituted. You should speak with her.",soul.soulname)
        @say save

scenario.revivalllov =!->
    switches.llovsick=false
    switches.llovsick1=0
    switches.revivalllov=true
    #llov.relocate nodes.revival
    llov.relocate \llovsick
    llov.face \down
    llov.interact=!->
        say \marb \smile tl("Welcome back to the team, little sister.")
        say \llov \smile tl("Llov is feeling great now! Pesty really knows how to treat a lady.")
        say -> join_party \llov save:true front:false # startlevel:10

scenario.states.towerfall =!->

    for j in joki then if j then j.interact=!->
        if switches.llovsick1 is -1 and switches.beat_sars and switches.beat_rab and switches.beat_aids and switches.map isnt \hub
            say \joki tl("Something terrible has happened. You should see.")
            say ->
                setswitch \llovsick1 -2
                warp_node \hub \landing
            return
        else if switches.llovsick1 is true and llov not in party
            say \joki tl("Lloviu isn't with you. You should speak with her.")
            return
        else if switches.progress2<21 and switches.map is \hub
            say \ebby \concern tl("Joki, the soul cluster was scattered. We need to get the souls back!")
            say \joki tl("Yes, I saw where they landed. I will take you there.")
            say ->
                warp_node \delta \landing
                switches.warp_delta=true
                setswitch \progress2 21
            return
        else if switches.progress2 is 23
            say \joki tl("Pesty told me to give you something? Yeah, I got the memo.")
            acquire items.jokicharm, 1, false, true
            acquire items.riverfilter, 1, false, true
            switches.water_walking=true
            switches.progress2=24
            say ->
                save!
            say \joki tl("Try not to drown in the river.")
        else joki_interact ...

    if switches.revivalnae and switches.map is \delta
        nae := node_npc(nodes.nae,'naegleria',2)
        nae.setautoplay('down')
        nae.interact =!->
            if llov not in party
                say \nae tl("Where has Lloviu-tan gone? Are you not travelling together any more?")
            else
                say \nae tl("It's good to see you. Thanks again for saving me.")
            say \nae tl("Why don't we have a friendly little battle, what do you say?")
            menu tl("Yes"), -> start_battle encounter.naegleria_r
            ,tl("No"), ->
    if switches.revivalrab and switches.map is \delta
        rab.relocate \rab2
        rab.interact =!->
            say \rab \young tl("I don't know why, but Herpes-chan has been hanging around me a lot more than usual lately.")
            say tl("She's also given me a lot of sweet discounts, so I'm not complaining.")
    if switches.revivalsars and switches.map is \delta
        sars.relocate \sars2
        sars.interact =!->
            if ebby.equip is items.humanskull2
                say \sars tl("Ebola-chan are you still carrying that skull around?")
                say tl("You know, I never did like {0}.",switches.name)
            else
                say \sars tl("Marburg-sama, please make me one of your sisters.")
    if switches.revivalaids and switches.map is \delta
        aids.0 = node_npc(nodes.aids3,'aids3')
        aids.0.interact=!->
            say \aids1 \fused tl("If conjoined twins have sex, is it incest or masturbation?")
            say \aids2 \fused tl("Does it matter?")

    if switches.llovsick1 is true
        switches.llovsick1=2
    if switches.map is \delta
        if switches.llovsick1 is 4
            temp.deadllov=create_prop nodes.llovsick, \deadllov
            temp.deadllov.interact=!->
                say '' tl("Her soul is missing.")
        else if switches.llovsick1>1
            llov.relocate \llovsick
            llov.interact=!->
                say \llov \sick tl("Uuu...")
                if !session.pestypleasehelpllov
                    say \ebby \concern tl("Llov is sick Marburg. What should we do?")
                    say \marb \troubled tl("I'm sure Pestilence can help us.")
                else
                    say '' tl("Lloviu-tan's condition shows no sign of improvement.")

    if switches.map is \hub and switches.llovsick1 is -2
        temp.deadmal=create_prop nodes.bp, \deadmal
        temp.deadpox=create_prop nodes.mob2, \deadpox
        temp.deadmal.interact=temp.deadpox.interact=!->
            say '', tl("Her soul is missing.")
        if !switches.beat_chikun
            chikun = new NPC nodes.chikun.x+HTS, nodes.chikun.y+TS, \mob_chikun, 7
            chikun.update=!->
                @frame= if Math.random!<0.9 then 0 else Math.random!*4.|.0
            chikun.battle=encounter.chikun

    if (switches.beat_sars or switches.beat_rab or switches.beat_aids) and !switches.llovsick1
    and switches.ate_nae isnt true and switches.ate_nae isnt \llov
    and switches.ate_eidzu isnt \llov and switches.ate_sars isnt \llov and switches.ate_rabies isnt \llov
        switches.llovsick=true
    if switches.beat_sars and switches.beat_rab and switches.beat_aids and !switches.delta_finished
        scenario.delta_finished!

    if switches.delta_finished>1
        switches.warp_earth=true
    /*
    if switches.map is \delta and switches.progress2<22
        say \joki "Here we are. We should be pretty close to where the souls landed."
        say \joki "By the way, you should take these. You won't get very far without them."
        acquire items.jokicharm, 1, false, true
        acquire items.riverfilter, 1, false, true
        switches.water_walking=true
        switches.progress2=22
        say ->
            save!
        say \joki "Try not to drown in the river."
    */

    if switches.map is \labhall or switches.map is \labdungeon
        #music.fadeOut 2000
        scenario.labhall!
    #if switches.map is \lab
    #    music.fadeOut 2000
    scenario.states.towerfall_earth!

scenario.delta_finished=!->
    if switches.llovsick and !switches.llovsick1
        switches.lockportals=true
        switches.checkpoint_map=\delta
        switches.checkpoint=\cp1
    setswitch \delta_finished true
    say \ebby tl("We've collected all of the souls in this area.")
    if switches.llovsick1>0
        say \ebby tl("We need to rekindle the soul cluster, and we need to save Llov. But we only have enough souls to do one of those right now.")
    else if switches.llovsick1<0 and items.humansoul.quantity<1000000
        scenario.delta_finished2!
    else
        say \ebby tl("We have enough souls to rekindle the soul cluster now. We should return to the tower.")
scenario.delta_finished2=!->
    return if switches.delta_finished>1
    switches.delta_finished=2
    say \marb tl("Where to next?")
    say \ebby tl("Zmapp is on Earth. She has many souls with her.")
    say \marb tl("Then we're going to Earth. Joki can take us there.")
    #say '' "This is the end of Demo 2!"
    #if switches.llovsick1 is -1 or switches.llovsick1 is 4
    #    say '' "...Or is it?"
    switches.warp_earth=true
    setswitch \progress2 30

scenario.towerfall_bp =!->
    setswitch \lockportals false
    cinema_start!
    bp.move 4,-2
    bp.path.push ->
        for p in party
            p.face_point bp
        bp.face \up
        say \bp tl("What happened? Why is the tower dark?")
        say \ebby \concern tl("The light was stolen.")
        say \bp tl("What about the energy that used to flow from the tower?")
        say \ebby \concern tl("It won't flow any more.")
        say \bp tl("...")
        say \bp tl("I see. Then I don't have any reason to stay here.")
        say \bp tl("I'm going to search for a more sustainable source of energy.")
        say \llov tl("Plese wait, We'll restore the tower! We're going to find the souls right now!")
        #say \llov "We'll restore the tower though! We're going to get the souls back now!"
        say \bp tl("It doesn't matter, I'd been meaning to leave anyway. The tower was never sustainable in the first place.")
        #bp starts to walk away.
        say ->
            bp.move 6, 0
            bp.path.push ->
                bp.face \upright
                mal.face \downleft
                #camera_center bp.x, bp.y
                say \bp tl("Malaria, come with me.")
                say \mal tl("Well...")
                say \bp tl("What's wrong, aren't you coming?")
                say \mal tl("I think I'm going to wait here. The sisters will restore the tower, I have faith in them.")
                say \bp tl("...")
                say \bp tl("Suit yourself.")
                say ->
                    bp.move 7, 3
                    bp.path.push ->
                        Dust.summon bp
                        bp.kill!
                        cinema_stop!
        #bp leaves.

scenario.llovsick1 =!->
    #after beating the first boss in the delta, when approaching Pestilence,
    #llov stops following, because she's become sick again.
    switches.lockportals=false
    leave_party llov
    llov.interact=!->
        if player is ebby
            say \ebby \concern tl("Llov? What's wrong?")
        else
            say \marb \troubled tl("Llov? What's wrong?")
        say \llov \sick tl("Llov... Doesn't feel very well.")
        say \marb \troubled tl("It must be her sickness. I thought she was better.")
        say \ebby \concern tl("We should take her to Pestilence. He'll know what to do.")
        say ->
            switches.llovsick1=2
            warp_node \delta \revival
            temp.callback=!->
                player.move(-1,-2)

scenario.llovsick2 =!->
    items.humansoul.quantity -= 1000
    @say \pest tl("All right, I'll extract the energy from the souls and feed it to Lloviu-tan.")
    @say \pest tl("...")
    @say \pest tl("This is rather... Unexpected.")
    @say \ebby \concern tl("What's the matter?")
    #say \pest "She's malnourished. She needs energy. It's simple, 1000 souls should be plenty."
    @say \pest tl("Something is wrong. I can't heal her. Something is blocking me, some kind of barrier.")
    @say \pest tl("I'm afraid it will take a lot more energy to break the barrier.")
    #say \pest "It will take many more souls than I thought. 1 million, at the least."
    @say \pest tl("It will take 1 million souls.")
    @say \ebby \concern tl("That's so many...")
    @say \pest tl("There is an alternative. Not all souls are equal. A strong soul, such as the soul from a virus. That would also work.")
    if switches.ate_nae isnt \ebby and switches.ate_rabies isnt \ebby and switches.ate_sars isnt \ebby and switches.ate_eidzu isnt \ebby
        @say \ebby \concern tl("But that's terrible...")
        @say \pest tl("I'm sorry, it's the only way I know to save her.")
    @say ->
        switches.llovsick1=3
    if items.humansoul.quantity>=1000000
        scenario.llovsick3.call @

scenario.llovsick3 =!->
    s= if this instanceof Menu then @say else say
    souls=[]
    souls.push items.naesoul if items.naesoul.quantity
    souls.push items.sarssoul if items.sarssoul.quantity
    souls.push items.aidssoul if items.aidssoul.quantity
    souls.push items.rabiessoul if items.rabiessoul.quantity
    if souls.length>0 or items.humansoul.quantity>=1000000
        s.call @, \pest tl("Which cost should be paid to save Lloviu?")
        menuset=[\Cancel ->]
        if items.humansoul.quantity>=1000000 then menuset.push tl("1 million human souls"), !->
            items.humansoul.quantity -= 1000000
            scenario.llovheal.call @
        else menuset.push tl("1 million human souls"), 0
        for soul in souls then menuset.push soul.soulname, callback:scenario.llovheal, arguments:[soul]
        menu.apply @, menuset

scenario.llovheal =(soul)!->
    if soul
        soul.quantity = 0
    join_party \llov
    switches.llovsick=false
    switches.llovsick1=-1
    switches.llovsick1=-3 if soul
    save!
    @say \pest tl("It's done. The cost was great, but Lloviu's soul was healed.")
    if switches.beat_aids and switches.beat_rab and switches.beat_sars
        temp.oncghide = scenario.llovheal2
scenario.llovheal2 =!->
    cinema_start!
    for p in party
        continue if p is player
        p.update_follow_behind!
    setTimeout !->
        cinema_stop!
        for p in party
            if p is llov
                llov.face_point player
            else
                p.face_point llov
        say \marb \smile tl("Welcome back to the team, little sister.")
        say \llov \smile tl("Llov is feeling great now! Pesty really knows how to treat a lady.")
        scenario.delta_finished2!
    , 1000
    
scenario.llovsick4 =!->
    #after llov dies
    say \ebby \cry tl("Llov isn't moving! Pestilence, please! Please save her!")
    #say \marb \pain "..."
    say \pest tl("There's nothing I can do.")
    #say \pest "I'm afraid there's nothing I can do. Her soul has alredy left her body."
    say \pest tl("I'm sorry.")
    say \marb \grief tl("This can't be real.")

scenario.pc =(skipwelcome)!->
    # TODO think of 2 new puzzles.
    # 1st puzzle is computer based, to open the 4 surrounding doors
    # 2nd puzzle is described in the written logs, to open one of the final doors

    say '' tl("Booting up interface. Welcome to Last Hope.") unless skipwelcome
    if !switches.mainpass # Passcode hasn't been entered
        #say '' tl("Enter Mainframe Password.")
        textentry 140, tl("Enter Mainframe Password."),(m)!->
            if unifywidth(m) ~= '38014'
                #setswitch \finaldoor true
                setswitch \mainpass true
                #sound.play \door
                #doodads.finaldoor.frame=5
                #doodads.finaldoor.body.enable=false
                scenario.pc true
            else
                say '' tl("Wrong password.")
                say \ebby tl("We should explore some more to find the password.")
                session.wrongpass=true
        return
    # Passcode has been entered
    say '' tl("Please select an option.")
    doorlist=
        *switch:'door0',display:tl("Entry Door")
        *switch:'door_sw',display:tl("Southwest Door")
        *switch:'door_se',display:tl("Southeast Door")
        *switch:'door_nw',display:tl("Northwest Door")
        *switch:'door_ne',display:tl("Northeast Door")
    for door, i in doorlist by -1
        if switches[door.switch] or switches.doorswitch is door.switch then doorlist.splice(i,1)
    menuset =
        tl("Digital Logs"),!->
            @menu tl("Entry 1"),!->
                @say '' tl("\"To protect the facility, a mult-level security system is being phased in.\"")
                @say '' tl("\"With one of the new lock systems, DNA from one of the lab employees will be needed to open certain doors.\"")
            ,tl("Entry 2"),!->
                @say '' tl("\"There are hidden switches in the morgue drawers. They must be opened in a particular order unlock the doors.\"")
                @say '' tl("\"These new security systems are very impractical.\"")
            ,tl("Entry 3"),!->
                @say '' tl("\"Sally broke out of containment again. She's very violent and destructive.\"")
                @say '' tl("\"A mixture of chitin and silver seems to form an effective deterrent. It makes recovery a lot easier.\"")
            ,tl("Entry 4"),!->
                @say '' tl("\"The new infected blood samples are ready for analysis.\"")
                @say '' tl("\"Remember that civilian blood is marked with a white band, while employee blood is marked with a black band.\"")
            ,tl("Entry 5"),!->
                @say '' tl("\"The winged ones have taken an interest in this lab. I don't think anyone is left who can't see them.\"")
                @say '' tl("\"Some of my comrades have cast aside their humanity to go with them, but not I.\"")
                @say '' tl("\"When I die, it will be as a human.\"")
        tl("Exit"),!->
    if !switches.beat_game then menuset.unshift(tl("Door Controller"),!->
        menuset=
            tl("Cancel"),!->
            ...
        for door in doorlist by -1
            menuset.unshift door.display, arguments:[door], callback:(door)!->
                for a in actors.children
                    continue unless a.properties and a.properties.doorcontroller
                    a.frame=4
                    a.body.enable=true
                    if door.switch is a.properties.open
                        door.object = a
                if !door.object then console.warn("Warning! Door #{door.switch} wasn't found :(")
                sound.play \door
                door.object.frame=5
                door.object.body.enable=false
                #setswitch door.switch, true
                setswitch \doorswitch, door.switch
                say '' tl("{0} was opened.",door.display)
        @menu.apply @, menuset
    )
    menu.apply @, menuset

scenario.labdoormessage =!->
    say '' tl("To open the door, enter the passcode into the nearby terminal.")

scenario.enterlab =!->
    return if switches.enterlab
    zmapp.relocate \zmapp_gate
    cure.relocate \cure_gate
    #party walks up to door so cure and zmapp can be seen
    cinema_start!
    player.move 0, -11
    Transition.pan x: player.x, y: player.y - TS*11, 2000
    for i from 1 til party.length
        party[i].move i*2-3, -10.5
    player.path.push !->
        say \ebby \smile tl("Little pig, little pig, let us in.")
        say \cure tl("Hey Zmapp, it looks like someone is at our door.")
        say \zmapp tl("It's fine, they'll never get in. The only person besides us who knows the password is dead.")
        say \cure tl("You hear that intruders? You'll never find the password hidden in the graveyard.")
        say \cure tl("And you'll never be able to solve the series of puzzles waiting for you in here.")
        say !->
            setswitch \enterlab true
            say cinema_stop
            cure.move 0, -11
            zmapp.move 0, -11
            cure.path.push !->
                Dust.summon cure
                cure.relocate \cure
                cure.face \down
            zmapp.path.push !->
                Dust.summon zmapp
                zmapp.relocate \zmapp
                zmapp.face \down
    #introduce the dungeon

scenario.labhall =!->
    if !switches.enterlab
        return scenario.enterlab!
    return if switches.curefate
    if switches.progress2>31
        return scenario.curefate!

scenario.finale =!->
    return if switches.curefate
    #say \cure "Come on Zmapp, you have all that soul power. Break this cow curse already!"
    #say \zmapp "I don't think I will. The cow suit looks rather nice on you."
    #say \cure "Y-You really think so?"
    #The two notice the players
    /*
    cure.interact=!->
        say \cure "It's useless. There's nothing you can do to stop us now."
        say \cure "Face your fate. You will be cured."
    zmapp.interact=!->
        say \zmapp "I was created to destroy you. It's my destiny."
        if switches.zmapp isnt \defeat
            say \zmapp "But I can't beat you in a fair fight."
    */
    /*
    if switches.progress2 is 31
        who = new NPC nodes.who.x+HTS, nodes.who.y+TS, \who
        who.setautoplay \down
        who.battle=encounter.who
        dood = new Doodad(nodes.lab.x+HTS, nodes.lab.y+TS, \flameg null true) |> actors.add-child
        dood.anchor.set 0.5 1.0
        dood.simple_animation 7
        dood.random_frame!
        updatelist.push dood
        return
    */
    cinema_start!
    /*
    setTimeout ->
        for p,i in party
            continue if i is 0
            p.x -= (i-1.5)*2*TS
        camera_center(player.x,player.y - TS*2)
    ,0
    */
    music.fadeOut 2000
    Transition.pan(x:nodes.who.x+HTS, y:nodes.who.y+TS*3,1000,null,null,false)
    if switches.progress2 isnt 31
        say \zmapp tl("Look who finally showed up! It took you long enough.")
        say \cure tl("They're always so slow, let me tell you.")
        say \zmapp tl("You're just in time to witness our ultimate plan come to fruition.")
        say \cure tl("Oh! Let me tell them about the plan!")
        say \cure tl("You see, we're going to cure all of you!")
        say \cure tl("Every single disease that has ever existed. All cured!")
        say \zmapp tl("It's more than that. We're creating a new breed of human.")
        say \zmapp tl("One that is immune to all disease!")
        say \zmapp tl("All the energy that you need to live will be ours, and you can't have any of it!")
        say \cure tl("I think it's time we introduce them to our boss.")
        say \zmapp tl("We just finished working on her. Those souls of yours were the final ingredient.")
    say ->
        dood = new Doodad(nodes.who.x+HTS, nodes.who.y+TS, \bloodpool null false) |> carpet.add-child
        dood.anchor.set 0.5 0.5
        dood.simple_animation 14
        dood.scale.set 0 0
        updatelist.push dood
        dood.update=!->
            grow=0.25*deltam
            @scale.x+=grow
            @scale.y+=grow
            #if Date.now! - sound.lastplayedtime > 100
            #    sound.play \candle, true
            #    sound.candle._sound.playbackRate.value=@scale.x+0.5
            if @scale.x>1 or @scale.y>1
                @scale.set 1 1
                @update=!->
                scenario.finale2!

    #say \zmapp "Yes. It's time to unveil our grand design."
    #say \zmapp "Say Hello to the new and improved... WHO-chan!"
scenario.finale2 =!->
    #say \zmapp "Here she comes now. Meet the daughter of Asclepius, the herald of new man-kind, or as we call her..."
    if switches.progress2 isnt 31
        say \zmapp tl("Here she comes now.")
    say !-> music.play \towertheme
    who = new NPC nodes.who.x+HTS, nodes.who.y+TS, \who
    who.setautoplay \down
    who.speed=15
    who.battle=encounter.who
    who.keyheight=(get-cached-image who.key)frame-height
    who.keywidth=(get-cached-image who.key)frame-width
    who.crop x:0 y:0 width: who.keywidth, height: 0
    whoupdate=who.update
    who.update=!->
        whoupdate ...
        rise=@keyheight*deltam/6
        if @height+rise > @keyheight
            rise=@keyheight - @height
        @crop x:0 y:0 width:@keywidth, height:@height+rise
        if @height >= @keyheight
            @update=whoupdate
            #say \zmapp "The new and improved... WHO-chan!"
            if switches.progress2 isnt 31
                say \zmapp tl("Meet the new and improved... WHO-chan!")
                say \who tl("At long last, I live.")
                say \who tl("You... I recognize you. You're the one who killed me, Ebola-chan.")
                say \who tl("Tell me, how does it feel knowing that everything you've worked for will soon be undone?")
                say \who tl("My cute subordinates have done an excellent job luring you here. Now it's time for you to die.")
                say \who tl("Bow down to your new god.")
            say ->
                who.goal.x=player.x
                who.goal.y=player.y
    who.onbattle=cinema_stop


scenario.curefate =!->
    setTimeout !->
        for p,i in party
            p.relocate \who
            p.y+=TS*2
            p.face \up
            if i>0 then p.x -= (i-1.5)*2*TS
            p.cancel_movement!
        camera_center(player.x,player.y - TS*2)
    ,0
    cinema_start!
    #who melts
    carpet.add-child <| who=new Doodad nodes.who.x+HTS,nodes.who.y+TS,'who_die',null,false
    who.anchor.set 0.5 1.0
    updatelist.push who
    setTimeout !->
        who.simple_animation 7, false
        who.animations.currentAnim.onComplete.addOnce !->
            who.animations.stop!
            setTimeout scenario.curefate2, 500
    ,500
scenario.curefate2 =!->
    if switches.llovsick1 is 4
        say \marb tl("Before we destroy you, I need to ask you something.")
        say \marb tl("My little sister, Llov. Were you the ones who did that to her?")
        say \cure tl("Huh? Now that you mention it, I guess she isn't with you.")
        say \zmapp tl("Look, I don't know what happened, but we didn't have anything to do with it.")
    else 
        say \zmapp tl("So you foiled our grand designs. No hard feelings though, right? You win.")
    menu tl("Spare them."), ->
        setswitch \curefate, 1
        zmapp.move -0.5, 1.5
        zmapp.move 0, 1
        zmapp.move 2, 3
        zmapp.move 0, 1
        zmapp.path.push !-> zmapp.kill!
        setTimeout !->
            cure.move 0.5, 1.5
            cure.move 0, 1
            cure.move -2, 3
            cure.move 0, 1
            cure.path.push !->
                cure.kill!
                cinema_stop!
        ,1000
    ,tl("Destroy them."), ->
        setswitch \curefate, -1
        ebby.path.push x:zmapp.x, y:zmapp.y+TS
        ebby.path.push !->
            ebby.face \up
            sound.play \defeat
            zmapp.update=override zmapp.update, !->
                @alpha -= deltam
                if @alpha >0 then return
                @destroy!
                acquire items.soulshard, 4
                cure.move 0, -2
                cure.path.push !->
                    cure.face \down
                    say \cure tl("No! This can't be happening!")
                    say ->
                        ebby.path.push x:cure.x, y:cure.y+TS
                        ebby.path.push !->
                            ebby.face \up
                            sound.play \defeat
                            cure.update=override cure.update, !->
                                @alpha -= deltam
                                if @alpha >0 then return
                                @destroy!
                                acquire items.soulshard, 4
                                cinema_stop!


scenario.beat_game =!->
    cinema_start!
    #bp enters from the bottom
    sound.play \door
    bp := node_npc nodes.hall, \bp
    i=0
    n={x:nodes.beat_game.x+HTS,y:nodes.beat_game.y+TS}
    for p in party
        if p is ebby
            p.path.push n
        else
            p.path.push {x:n.x - TS*(i++*2-1),y:n.y+TS}
        p.path.push callback:p.face_point, context:p, arguments:[bp]
    bp.move(0,-4)
    bp.path.push ->
        for p in players
            p.face_point bp
        say \bp tl("This is what I've been searching for.")
        #say \bp tl("Our reservoirs can finally be restored.")
        say \bp tl("This lab holds the secret to bringing back extinct species. Do you know what that means?")
        say \bp tl("Our energy problem has been solved. We can create new hosts and farm them for energy.")
        say \bp tl("It doesn't have to be human, but they are the most effective source.")
        #say \bp tl("Our reservoirs which the humans destroyed can finally be restored.")
        #say \bp tl("Cure was even kind enough to create a new human for us. It could become a great source of energy.")
        say \bp tl("I think you sisters should be the ones to decide this human's fate.")
        say ->
            for p in party
                continue if p is ebby
                p.face_point ebby
            if party.length is 2
                ebby.face_point if player is ebby then party.1 else player
            setTimeout scenario.beat_game2, 1000
scenario.beat_game2 =!->
    say \marb tl("After everything the humans have done, they deserve their fate.")
    if llov in party
        say \llov tl("Not all humans are bad. Remember {0}?",switches.name)
        say \llov tl("Llov thinks they deserve a second chance.")
    else if switches.llovsick1 is 4
        say \marb tl("What happened to Llov was ultimately their fault.")
    say \ebby tl("It's true that what they've done can't easily be forgiven.")
    say \ebby tl("But this one wasn't part of that. She isn't even born yet.")
    say \marb tl("Even if this one is innocent, humanity is not. Even if she does no evil, her children certainly will.")
    #say \ebby tl("I have taken the lives of many humans, and they are still with me now.")
    #say \ebby tl("I remember their words of encouragement.")
    #say \ebby tl("They told me \"I love you,\" and \"Good Luck.\"")
    #say \ebby tl("And finally, when it was all over, they told me\n\"Thank you.\"")
    #say \ebby tl("I know not all humans are evil, but do they deserve a second chance? Is it worth the risk?")
    #say \ebby tl("There are good humans and there are bad humans. But does the good justify the bad?")
    #say \ebby tl("Would it even be right of me to bring them back?")
    say \ebby tl("I don't know what to do. {0}, what do you think?",switches.name)
    #interacting with the tube.
    #Choose the fate of the human embryo.
    menu tl("Spare humanity."), ->
        switches.dead = if switches.llovsick1 is -2 then 'malpox' else if switches.llovsick1 is 4 then 'llov' else ''
        switches.progress='endgame'
        switches.beat_game=Date.now!
        setswitch \humanfate, 1

    ,tl("Abort humanity."), ->
        switches.dead = if switches.llovsick1 is -2 then 'malpox' else if switches.llovsick1 is 4 then 'llov' else ''
        switches.progress='endgame'
        switches.beat_game=Date.now!
        setswitch \humanfate, -1
    say !-> ebby.face \up
    say \ebby tl("...All right. I've decided.")
    say !->
        if switches.humanfate is 1
            for n in carpet.children then if n.name in <[tubeleft tubecenter tuberight]>
                n.load-texture 'lab_tiles'
                n.crop new Phaser.Rectangle TS*n.properties.frame_x, TS, TS,TS
                n.alpha=0
                updatelist.push n
                n.update=!->
                    @alpha += deltam/3
                    if @alpha >= 1
                        @alpha=1
                        @update=!->
                        if @name is \tubecenter
                            setTimeout scenario.credits, 1000
        else
            sound.play('water');sound.play('strike');sound.play('flame');
            for n in carpet.children then if n.name in <[tubeleft tubecenter tuberight]>
                n.load-texture 'lab_tiles'
                n.crop new Phaser.Rectangle TS*n.properties.frame_x, 0, TS,TS
                setTimeout scenario.credits, 2000 if n.name is \tubecenter

scenario.credits =!->
    credits=
        *m:tl("Super Filovirus Sisters"), s:2, t:5000
        *m:tl("Game by Dread-chan"), t:3000
        #*m:tl("Powered by Phaser"), t:2000
        #*m:tl("Special thanks to /ebola/, /pol/, and /monster/"), t:4000
        #*m:tl("In loving memory of the old VN team."), t:4000
        #*m:tl("This game is my love letter to Ebola-chan."), t:4000
        *m:tl("Thank you for playing!"), t:3000
        ...
    #cinema_start!
    solidscreen.alpha=1
    text = new Text 'font', ''
    gui.frame.add-child text
    temp.credits=text
    text.anchor.set 0.5 0.5
    text.x=HWIDTH
    text.y=HHEIGHT
    i=0
    newcredit=!->
        if credits[i]
            text.scale.set credits[i]s||1, credits[i]s||1
            text.change credits[i]m||credits[i]
            setTimeout newcredit, credits[i]t||5000
            i++
        #else scenario.credits2!
        else
            warp_node \earth \aftercredits
    newcredit!
    #text.change tl("Game by Dread-chan")
    #text.change tl("Thank you for playing!")

    #After short credit sequence, game resumes outside the lab where the other characters can be found gathered.
    #If llov is dead, then Malaria and Smallpox will arrive with a coffin. They will bury Llov.

scenario.childAge1 =!->
    return Date.now! - switches.beat_game > 2629746000 # 1 month
scenario.childAge2 =!->
    return Date.now! - switches.beat_game > 31556952000 # 1 year

scenario.states.endgame =!->
    if switches.map is \lab
        if switches.humanfate>0
            y=TS
            if scenario.childAge1!
                y+=TS
            if scenario.childAge2!
                bp.shiro = shiro = node_npc nodes.bp,'shiro'
                shiro.relocate(nodes.bp.x+1.5*TS, nodes.bp.y+TS)
                shiro.face 'down'
                shiro.interact=!->
                    scenario.shiro!
                    #say 'shiro' tl("...")
                    #say 'bp' tl("Shiro, say hello.")
                    #say 'shiro' tl("...Hello")
            else if scenario.childAge1!
                bp.load-texture \bp_shiro
        else y=0
        for c in carpet.children
            if c.name in <[tubeleft tubecenter tuberight]>
                c.load-texture 'lab_tiles'
                c.crop new Phaser.Rectangle TS*c.properties.frame_x, y, TS,TS
    if switches.map is \earth
        if switches.dead is \malpox
            dood = new Doodad(nodes.llovgrave.x, nodes.llovgrave.y+TS, \1x2 null true) |> actors.add-child
            dood.anchor.set 0.5 1.0
            dood.frame=11
            dood.body.setSize TS, TS
            initUpdate dood
            dood.interact=!->
                say '' tl("Here lies Malaria.")
            dood = new Doodad(nodes.llovgrave.x+TS, nodes.llovgrave.y+TS, \1x2 null true) |> actors.add-child
            dood.anchor.set 0.5 1.0
            dood.frame=11
            dood.body.setSize TS, TS
            initUpdate dood
            dood.interact=!->
                say '' tl("Here lies Smallpox.")
        else if switches.dead is \llov
            dood = new Doodad(nodes.llovgrave.x+HTS, nodes.llovgrave.y+TS, \1x2 null true) |> actors.add-child
            dood.anchor.set 0.5 1.0
            dood.frame=10
            dood.body.setSize TS, TS
            initUpdate dood
            dood.interact=!->
                say '' tl("Here lies Lloviu-tan.")
    if temp.credits and switches.map is \earth
        for p,i in party
            continue if p is player
            p.x += TS*i
        temp.credits.destroy?!
        delete! temp.credits
        solidscreen.alpha=0
        cinema_start!
        camera_center nodes.cam0.x, nodes.cam0.y, true
        Transition.pan nodes.aftercredits, 5000,!->
            if !switches.beat_joki or switches.llovsick1 is 4
                if !switches.soulcluster
                    say \ebby tl("We've recovered enough souls to restore the soul cluster.")
                    say \ebby \concerned tl("But some of them are still missing. I can hear them calling for me.")
                else
                    say \ebby \concerned tl("Some of the human souls are still out there. I can hear them calling for me.")
            else
                say \ebby tl("We've recovered all of the missing human souls.")
                if !switches.soulcluster
                    say \ebby tl("Now it's time to return them to the tower.")
            say cinema_stop
        ,null,false
    if switches.map is \earth2 and (switches.llovsick1 isnt -2 or switches.beat_chikun and switches.revivalchikun)
        chikun = node_npc(nodes.chikun, 'chikun')
        chikun.interact=!->
            say \chikun tl("You're not supposed to be able to get out here.")

scenario.shiro =!->
    say \bp tl("This is the child you chose to save. Her name is Shiro.")
    say \bp tl("Shiro, say hello. These are your mothers.")
    say \shiro tl("...Hello.")
    say \marb \aroused tl("She's cute. I'd like to take her home with me.")
    say \ebby \smile tl("Yay! My new favorite human. Sorry {0}.", switches.name)
    if llov in party
        say \llov \smile tl("Does this mean Llov is a big sister now? Can Llov do big sister things?")
    say \bp tl("We'll need to create more for a breeding population, but this is a good start.")

scenario.joki_castle =!->
    say \joki tl("What a surprise. I didn't expect you would find your way here.")
    if llov in party
        say \llov tl("Uncle Famine told us how to get here.")
    else
        say \marb tl("Famine told us you took over Death's castle.")
    say \joki tl("Oh Famine, such a gossip.")
    say \joki tl("Yes, this is my castle now. Nice place isn't it?")
    say \joki tl("You should stay a while, I'll make some tea.")
    say \ebby \concern tl("Joki, why are you hiding my friends from me?")
    say \joki tl("...So you can sense them.")
    say \ebby \concern tl("Please, give them back to me.")
    say \joki tl("Ebola-chan, I can understand why you would think that these are yours. After all, you're the one who killed them.")
    say \joki tl("But the dead belong to Death, and that's me.")
    say \joki tl("I'll make you a deal though. We'll both bet all the souls we have... And whoever wins takes it all.")
    say \marb \smile tl("Oh, I like the sound of that. How about you Ebby?")
    say \ebby tl("I'll do whatever it takes to get them back!")
    ##
    #say \joki tl ("So you've found this place.")
    #say \joki tl ("Yes, it is true. I am Death.")
    #say \joki tl ("As I am Death, all human souls are rightfully my property.")
    #say \joki tl ("I was content to let you live in ignorance, but now that you know the truth, it's time that I collect what you owe me.")
    say -> start_battle encounter.joki

scenario.grave_message=(o)!->
    say '' "deprecated"

scenario.grave_message1=!->
    say '' tl("John Doe was a stranger in this town. He was found dead in the river.")
    say '' tl("Nobody knew his real name.")
scenario.grave_message2=!->
    say '' tl("Jane Doe shared a room with John. She was 20 years younger than him.")
    say '' tl("Not long after John's death, she was found hanging from the ceiling.")
scenario.grave_message3=!->
    say '' tl("Sherry Stillwater was married to the pastor.")
    say '' tl("Desperate for water, she drank the blood of neighborhood children.")
    say '' tl("She died of bloodborne illness.")
scenario.grave_message4=!->
    say '' tl("Melissa Goth didn't listen to the pastor.")
    say '' tl("She fell ill and died hunched over a toilet.")
scenario.grave_message5=!->
    say '' tl("Ethan Stillwater was a pastor for the local church.")
    say '' tl("He claimed that the water was poisoned, and died of dehydration.")
scenario.grave_message6=!->
    say '' tl("Jordan Smith survived the blast, but died from fallout.")
scenario.grave_message7=!->
    say '' tl("Pete Park was bit by a radioactive spider.")
    say '' tl("He didn't get super powers.")
scenario.grave_message8=!->
    say '' tl("Doctor White examined John Doe's body.")
    say '' tl("It was infected with ebola. And now he was too.")
scenario.grave_message9=!->
    say '' tl("Miss White worked in an orphanage. She was very close with the children.")
    say '' tl("The disease spread easily.")
scenario.grave_message10=!->
    say '' tl("Bob Markus found one of his tenants hanging.")
    say '' tl("He was later found without a head.")
scenario.grave_message11=!->
    say '' tl("Billy Jackson took the blast head-on.")
scenario.grave_message12=!->
    say '' tl("Sally Sordid took shelter underground with her daddy.")
scenario.grave_message13=!->
    say '' tl("Simon Sordid ate his daughter's body.")
    say '' tl("He died soon after.")
scenario.grave_message14=!->
    say '' tl("Maxwell Goth added his sister's blood to the cafeteria food.")
    say '' tl("He died behind bars.")
scenario.grave_message15=!->
    say '' tl("Patty Park gave birth to a malformed child.")
    say '' tl("She drowned it in the river, then took her own life.")
scenario.grave_message16=!->
    say '' tl("Mark Markus was found in possession of a human skull.")
    say '' tl("The next day he had two human skulls, but no head.")
scenario.grave_message17=!->
    say '' tl("Some mysterious robed men came through town.")
    say '' tl("They took John Doe and Jane Doe's bodies and left.")
    say '' tl("One of them stayed behind, and died of ebola.")
scenario.grave_message18=!->
    say '' tl("Nora Gray claimed to communicate with the world beyond.")
    say '' tl("She disappeared for a while, and was later discovered stuffed inside a box.")
scenario.grave_message19=!->
    say '' tl("Kate Park found a box filled with human parts.")
    say '' tl("She was quarantined, and soon died of ebola.")
scenario.grave_message20=!->
    say '' tl("Martin White climbed out of the wreckage and explored the ruins.")
    say '' tl("A charred husk grabbed his leg. He fell cracked his skull.")
scenario.grave_message21=!-> #empty grave
    say '' tl("Hilda Gray liked to spend time in the graveyard.")
    say '' tl("She became a permanent resident when she was found decapitated there.")
scenario.grave_message22=!->
    say '' tl("Robert Baron was caught digging up graves.")
    say '' tl("He was lynched by the town.")
scenario.grave_message23=!->
    say '' tl("Sheriff Brown was investigating a series of mysterious deaths.")
    say '' tl("Gazing into the eyes of the skull, he felt something strange.")
    say '' tl("He realized it was his own skull.")
scenario.grave_message24=!->
    say '' tl("A robed figure ambled through the wastleland, a string of skulls in tow.")
    say '' tl("He clasped his hands in prayer, and accepted his death.")
scenario.grave_message25=!->
    say '' tl("Jerry Fig died of natural causes.")
scenario.grave_message26=!->
    say '' tl("Terry Wisdom willingly infected himself.")
scenario.grave_message27=!->
    say '' tl("Tyrone Cooper infiltrated the shelter.")
    say '' tl("He helped distribute the gift.")
scenario.grave_message28=!->
    say '' tl("Mary Mort refused the gift.")
    say '' tl("She chose to leave the shelter, and died a painful death.")
scenario.grave_message_key=!->
    say '' tl("Hector Stein collected the infected blood and stored it safely underground.")
    say '' tl("He survived to become one of the last humans alive.")
    say '' tl("He rebuilt as much as he could, and began a project to cure his loneliness.")
    say '' tl("He lost hope, and dug his own grave.")
scenario.grave_message_weathered=!->
    say '' tl("The stone is weathered and unreadable.")
scenario.grave_message_unmarked=!->
    say '' tl("Nothing is written.")

scenario.states.towerfall_earth =!->
    if nodes.necrotoxin and !switches.necrotoxin
        item = new Doodad(nodes.necrotoxin.x, nodes.necrotoxin.y, '1x1') |> actors.add-child
        item.name = 'necrotoxin'
        item.interact=!->
            acquire items.necrotoxin, 5, false, true
            acquire items.necrotoxinrecipe, 1, false, true
            #say save
            say !-> setswitch \necrotoxin true
            @destroy!

scenario.burningflesh =(o)!->
    o.collider.destroy!
    o.timer=Date.now!
    o.prev.s=o.scale.x
    o.goal.s=0.75
    o.goal.y-=12
    sound.play 'defeat'
    o.update-paused=o.update=!->
        t = (Date.now! - @timer)/2000
        #smoothness=20
        #t = (t*smoothness.|.0)/smoothness
        if t>1
            @destroy!
        @scale.set @prev.s + (@goal.s - @prev.s)*t
        @alpha = 1 - t



scenario.war =!->
    if !items.basement_key.quantity
        say \war tl("I trust you've seen the cancerous lesions that cover this land.")
        say \war tl("It is the remnant of a bio-weapon created by the humans.")
        say \war tl("No doubt all this goop everywhere is in your way right? So how about you lend me a hand.")
        say \war tl("The humans created a special toxin to destroy the bio-weapon. It should be aroud here somewhere.")
        say \war tl("Take this, maybe it will help.")
        acquire items.basement_key
        return
    if session.wrongpass and !switches.mainpass
        say \ebby tl("We're looking for a password to enter the lab. Do you know it?")
        say \war tl("I don't know the password, but I know someone who does.")
        say \war tl("He used to tend that lab. Problem is, he died a while back.")
        say \war tl("You should check his body. it might have what you're looking for.")
        if !switches.necrotoxinrecipe then return
    if items.necrotoxinrecipe.quantity
        items.necrotoxinrecipe.quantity=0
        setswitch \necrotoxinrecipe true
        say \war tl("I see you found the Necrotoxin Recipe. Let me see it.")
        say '' tl("Gave the Necrotoxin Recipe to War.")
    if switches.necrotoxinrecipe
        say \war tl("Do you need more Necrotoxin? I can make you some, but it will take 3 cumberground each.")
    if switches.necrotoxinrecipe and items.cumberground.quantity>=3
        menu tl("Yes"), !->
            q=items.cumberground.quantity/3.|.0
            number tl("Max:{0}",q), 0 q
            say ->
                q= dialog.number.num
                unless q>0
                    return say '' tl("Created nothing.")
                exchange 3*q, items.cumberground, q, items.necrotoxin
                sound.play \itemget
                say '' tl("Created {0} Necrotoxin.",q)
        ,tl("No"), !->
    if !switches.necrotoxinrecipe
        say \war tl("It's been real quiet around here.")
        say \war tl("Now that the apocalypse is over, we don't have much of a job any more.")
        say \war tl("Tell old pesty that I would love to ride again some day.")

scenario.famine =!->
    if switches.famine
        say \famine tl("That girl Joki, she's taken over Death's old castle.")
        say \famine tl("It's in the northern reaches of the dead world.")
        return
    say '' tl("Here lies famine. He starved to death.")
    say -> setswitch \famine true
    say \famine tl("Hey, just between you and me... I'm not actually dead. Just sleeping.")
    say \famine tl("The only horseman that's actually dead is Death. He's been replaced by that maid of his.")
    say \famine tl("Oh, and Conquest is dead too. But that happened a long time ago.")

scenario.ebolashrine =!->
    for p in party
        p.stats.hp=1
        p.revive!
    if ebby in party
        say \ebby \smile tl("It's a picture of me!")
        say !-> sound.play \itemget
        say '' tl("The shrine fills you with love.")
        if !session.sisterletter
            session.sisterletter=true
            say \ebby \shock tl("What's this? Someone left a letter here!")
            scenario.sisterletter!
            say \ebby \default tl("I wonder what that means.")

scenario.delta_lock =!->
    say '' tl("The door is frozen shut.")
    player.move 0, 0.5


scenario.lorebook_delta =!->
    say '' tl("The gods are certainly mad at us. That's why this is happening.")
    say '' tl("If the gods want to destroy us, then what choice do we have?")
    say '' tl("We must create our own gods, and slay the gods that want to kill us.")
    say '' tl("WHO was our most recent creation. She is our last hope.")

scenario.lorebook_delta2 =!->
    say '' tl("Why did you choose her over me? Together we could have saved the world.")
    say '' tl("Instead, you condemned humanity to excruciating death. I will never forgive you.")

scenario.lorebook_delta3 =!->
    say '' tl("Last night we recieved another shipment of god blood.")
    say '' tl("I can't see the one who delivers it to us, but one of my collegues can. He describes her as a young woman dressed in black and white.")
    say '' tl("My daughter has been chosen as the next candidate. She has shown high potential, but I've seen this go wrong too many times.")
    say '' tl("I can only pray that everything goes well.")

scenario.lorebook_deep =!->
    say '' tl("He showed high affinity for the disease.")
    say '' tl("Where most would wither and die, he only grew stronger.")
    say '' tl("There's something special about people like this. I think they have a special bond with the gods.")
    say '' tl("They are the prime candidates for ascension.")

scenario.sisterletter =!->
    say '' tl("Dear {0},",switches.name)
    say '' tl("Thank you for choosing me.")
    say '' tl("Love, your sister.")

scenario.basementlocked=!->
    return if Date.now! - temp.locktimer < 5000
    say '' tl("The hatch is locked.")
    say -> temp.locktimer = Date.now!


mapdefaults =
    edges: 'normal'
    outside: false
    spawning: false
    bg: \forest
    hasnight:false
    mobcap:4
    mobtime:7000
    zone:\tuonen
zones=
    default:
        musiclist: [\battle]
        #cg: \cg_pest
    tuonen:
        music: ->if switches.soulcluster then \2dpassion else \towertheme
        musiclist: [\2dpassion \towertheme]
        cg: -> if switches.soulcluster then \cg_tower0 else \cg_tower2
    delta:
        music: ->if switches.soulcluster then \2dpassion else \towertheme
        musiclist: [\2dpassion \towertheme]
        cg: -> if switches.soulcluster then \cg_pest else \cg_pest_night
    tower:
        music: ->if switches.zmapp then \towertheme else \hidingyourdeath
        musiclist: [\towertheme \hidingyourdeath]
        cg: -> if switches.soulcluster then \cg_tower0 else \cg_tower2
    deadworld:
        music: \deserttheme
        musiclist: [\deserttheme]
        cg: \cg_jungle
    earth:
        #music: ->if (switches.map is \lab or switches.map is \labhall) and switches.progress is \towerfall then null else \hidingyourdeath
        music: \hidingyourdeath
        musiclist: [\hidingyourdeath \towertheme]
        cg: \cg_earth
    void:
        music: \distortion
        musiclist: [\distortion]
        cg: \cg_abyss
mapdata =
    hub:
        outside: true
        spawning: Mob.types.slime
        #bg: -> if_in_water \water \forest
        bg: (t)->
            if player.water_depth>0 and t is \water then waterbg!
            else if !switches.soulcluster then \forest_night 
            else \forest
        hasnight:true
        sun: !->
            @scale = x:1 y:1
            return true

    tunnel:
        spawning: Mob.types.ghost
        bg: \dungeon

    tunneldeep:
        spawning: Mob.types.fish
        mobcap:6
        mobtime:6000
        bg: \dungeon

    deadworld:
        edges: \clamp
        outside: true
        bg: (t)->
            if player.water_depth>0 and t is \water then waterbg!
            else \jungle
        mobcap:5
        #spawning: -> Mob.types[(a=<[ghost slime]>)[Math.random!*a.length.|.0]]
        spawning: (tile)->  switch (if tile?properties?terrain then that else \water)
            #|null,false => fallthrough
            |\water =>Mob.types.bat
            |\gravel =>Mob.types[(a=<[slime corpse]>)[Math.random!*a.length.|.0]]
            |_=>Mob.types[(a=<[ghost slime flytrap]>)[Math.random!*a.length.|.0]]
        sun: !->
            @x = 50
            @y = game.height/2 - 50
            @scale = x:0.75 y:0.48
        zone: \deadworld

    deathtunnel:
        zone: \deadworld
        spawning: ->  Mob.types[(a=<[ghost slime slime]>)[Math.random!*a.length.|.0]]
        mobcap:5
        bg: \dungeon
    deathdomain:
        edges: \clamp
        outside: true
        zone: \deadworld
        spawning: ->  Mob.types[(a=<[ghost slime slime]>)[Math.random!*a.length.|.0]]
        mobcap:5
        bg: \jungle
        sun: !->
            @x = 50
            @y = game.height/2 - 50
            @scale = x:0.75 y:0.48
    castle:
        zone: \deadworld
        bg: \castle

    towertop:
        edges: \clamp
        hasnight:true
        bg: \tower
        zone: \tower
    tower0:
        zone: \tower
    tower2:
        zone: \tower
    tower1:
        zone: \tower
        spawning: ->
            if switches.progress is \curebeat then Mob.types.wraith
            else false
        bg: \dungeon
        mobtime: 9000
    ebolaroom:
        zone: \tower

    delta:
        zone: \delta
        outside:true
        bg: (t)->
            if player.water_depth>0 and t is \water then waterbg!
            else if !switches.soulcluster then \forest_night 
            else \forest
        mobcap:5
        mobtime:9000
        hasnight:true
        sun: !->
            @x = game.width/2
            @y = game.height - 30
            @scale = x:0.75 y:0.48
        spawning: (tile)->
            switch (if tile?properties?terrain then that else \water)
            |\water =>Mob.types[(a=<[fish fish wisp arrow]>)[Math.random!*a.length.|.0]]
            |\mountain =>Mob.types[(a=<[arrow arrow arrow slime]>)[Math.random!*a.length.|.0]]
            |_=>Mob.types[(a=<[arrow arrow arrow wisp wisp wisp slime]>)[Math.random!*a.length.|.0]]

    earth:
        zone: \earth
        edges: \clamp
        bg: (t)->
            if t is \snow then \earth_snow
            else \earth
        mobcap:3
        mobtime:9000
        spawning: (tile)->
            switch (if tile?properties?terrain then that else \ground)
            |\snow =>Mob.types.arrow
            |_=>Mob.types.slime

    earth2:
        zone: \earth
        edges: \clamp
        bg: \earth
        spawning: (tile)->
            switch (if tile?properties?terrain then that else \ground)
            |\mountain =>Mob.types.arrow
            |_=>Mob.types.slime

    earth3:
        zone: \earth
        edges: \clamp
        bg: \earth

    basement1:
        zone: \earth
        spawning: Mob.types.slime
        bg: \dungeon
    basement2:
        zone: \earth
        bg: \dungeon

    necrohut:
        zone: \earth
    shrine:
        zone: \earth
    labdungeon:
        zone: \earth
        bg: \lab
        mobcap:3
        mobtime:10000
        spawning: (tile)->
            switch (if tile?properties?terrain then that else \ground)
            |\floor =>Mob.types.slime
            |_=>Mob.types[(a=<[slime slime glitch]>)[Math.random!*a.length.|.0]]
    labhall:
        zone: \earth
        bg: \lab
    lab:
        zone: \earth
        bg: \lab
    void:
        zone: \void
        edges: \clamp
        bg: \void
        outside: true
        mobtime:9000
        spawning: Mob.types.glitch
        sun: !->
            @scale = x:0 y:0

function getmapdata(map, field)
    if not field?
        field = map 
        map = switches.map
    if mapdata[map]?[field]? then that else mapdefaults[field]

function if_in_water(bg1,bg2)
    if player.water_depth>0 then bg1 else bg2

function waterbg
    if (getmapdata \zone) is \deadworld then \water_dead
    else if !switches.soulcluster then \water_night
    else \water

var backdrop, map
tiledata = {}
!function create_backdrop
    if backdrop?
        game.stage.add-child backdrop
        game.stage.set-child-index backdrop, 0
        return
    backdrop := game.add.group null, 'backdrop', true
    game.stage.set-child-index backdrop, 0
    
    backdrop.destroy =!->
        @parent.remove-child @
    
    backdrop.water = water-tile = new Phaser.TileSprite game, 0 0 320 320 'water'
    backdrop.add-child water-tile
    water-tile.margin-x = TS*11
    water-tile.margin-y = TS*12
    water-tile.width = game.width + water-tile.margin-x
    water-tile.height = game.height + water-tile.margin-y
    
    water-tile.timer = Date.now!
    water-tile.psuedo-frame = 0
    water-tile.update =!->
        if game.time.elapsed-since(this.timer) > 333
            this.timer = Date.now!
            if this.psuedo-frame < 3 then this.psuedo-frame++ else this.psuedo-frame = 0
        this.x = -64 - game.camera.x % 64 - this.psuedo-frame*TS #176
        this.y = -64 - game.camera.y % 64 - (game.time.now/100.|.0)*100/70%(TS*4) #128
        
    # the position of the sun's reflection should indicate the direction of ebola-chan's resting place.
    backdrop.sun = sun = backdrop.create game.width/2, 30, 'sun'
    sun.animations.add 'simple', null, 6, true
    sun.animations.play 'simple'
    sun.anchor.set-to 0.5
    sun.update=!->
        if getmapdata \sun
            return unless true is that ...
        return unless nodes.sun
        #@x=player.x - nodes.sun.x
        hgw=game.width/2
        hgh=game.height/2
        x=nodes.sun.x - (game.camera.x+hgw)
        y=nodes.sun.y - (game.camera.y+hgh)
        x=WIDTH*Math.sign(x) if Math.abs(x)>WIDTH
        y=HEIGHT*Math.sign(y) if Math.abs(y)>HEIGHT
        @x=hgw + x/2
        @y=hgh + y/2

!function tile_swap
    return if switches.soulcluster or !(getmapdata \hasnight)
    for tileset in map.tilesets
        n=null
        switch tileset.name
        |\tiles => n=\tiles_night
        |\townhouse => n=\townhouse_tiles_night 
        |\tower => n=\tower_tiles_night 
        |\delta => n=\delta_tiles_night 
        if n
            #tileset.setImage(game.cache.getImage(n,true))
            tileset.setImage(game.cache.getImage(n))
            map.tile_layer.dirty=true;

!function fringe_swap(n)
    return n if switches.soulcluster or !(getmapdata \hasnight)
    switch n 
    |\tiles => return \tiles_night
    |\townhouse_tiles => return \townhouse_tiles_night 
    |\tower_tiles => return \tower_tiles_night
    |\1x1 => return \1x1_night
    |\1x2 => return \1x2_night
    |\delta_tiles => return \delta_tiles_night
    default => return n

!function load_map (name, filename)
    game.load.tilemap name, "maps/#filename", null, Phaser.Tilemap.TILED_JSON
    
function create_map (name)
    map = game.add.tilemap name
    map.named-layers = {}
    for layer in game.cache.getTilemapData(name).data.layers
        switch
        when layer.type is \tilelayer
            map[layer.name] = map.named-layers[layer.name] = map.createLayer layer.name
            if (getmapdata \edges) is \loop then map[layer.name].wrap=true;
        when layer.name is \object_layer
            map.object_cache = layer.objects
    for tileset in game.cache.getTilemapData(name).data.tilesets
        map.add-tileset-image tileset.name, (if game.cache.checkImageKey(tileset.name) then tileset.name else "#{tileset.name}_tiles" )
    return map

!function create_tilemap
    switches.map=STARTMAP unless game.cache.checkTilemapKey switches.map
    map := create_map switches.map
    override = map.destroy
    map.destroy =!->
        for layer of map.named-layers
            override ...
            map.named-layers[layer]destroy!

    for null, y in map.tile_layer.layer.data
        for tile, x in map.tile_layer.layer.data[y]
            if (tp = tile.properties)terrain is \fringe or tp.terrain is \overpass
                ftile = new Doodad(x*TS, y*TS, (fringe_swap tp.fringe_key), null false) |> fringe.add-child
                ftile.crop new Phaser.Rectangle TS*tp.fringe_x, TS*tp.fringe_y, TS,TS
                if tp.terrain is \overpass
                    updatelist.push ftile
                    ftile.update=!->
                        @visible = player.bridgemode is \under
    tile_swap!
    
function tile_point_collision (o, point, layer, water, land)
    tile_offset_collision o, x: point.x - o.x, y: point.y - o.y, layer, water, land
function tile_offset_collision (o, offset, layer, water, land)
    return unless o.body
    o2 =
        body:
            position: x: o.body.position.x+offset.x, y: o.body.position.y+offset.y
            tile-padding: o.body.tile-padding
            width: o.body.width
            height: o.body.height
        bridgemode: o.bridgemode
    tile_collision o2, layer, water, land, o
function tile_collision (o, layer=map.named-layers.tile_layer, water, land, oo=o)
    return unless o.body
    rect = 
        x: o.body.position.x - o.body.tile-padding.x
        y: o.body.position.y - o.body.tile-padding.y
        w: o.body.width + o.body.tile-padding.x
        h: o.body.height + o.body.tile-padding.y
    tiles = getTiles.call layer, rect, true

    for tile, i in tiles
        return true if not tile_passable tile, water, land, oo
        return true if check_dcol tile, rect, oo
        #if tile?properties.dcol?
        #    dcol = that/\,
        #    for d, i in dcol
        #       dcol[i] = +d
        #    return true if dcol.0>0 and rect_collision rect, x: tile.left, y: tile.top, w: tile.width, h: dcol.0
        #    return true if dcol.1>0 and rect_collision rect, x: tile.right - dcol.1, y: tile.top, w: dcol.1, h: tile.height
        #    return true if dcol.2>0 and rect_collision rect, x: tile.left, y: tile.bottom - dcol.2, w: tile.width, h: dcol.2
        #    return true if dcol.3>0 and rect_collision rect, x: tile.left, y: tile.top, w: dcol.3, h: tile.height
    return false

function check_dcol(tile,rect, o=player)
    return false unless tile
    if tile.properties.terrain is 'fringe' or tile.properties.terrain is \overpass and o.bridgemode is \under
        if tile.properties.dcol is '0,1,0,1'
            return  check_dcol map.getTile(tile.x+1,tile.y,map.tile_layer), x:rect.x+TS, y:rect.y, w:rect.w,h:rect.h, o
        else
            return  check_dcol map.getTile(tile.x,tile.y - 1,map.tile_layer), x:rect.x, y:rect.y - TS, w:rect.w,h:rect.h, o
    if tile.properties.dcol #and !(tile.properties.terrain is \overpass and player.bridgemode is \under)
        dcol = tile.properties.dcol/\,
        for d, i in dcol
           dcol[i] = +d
        return true if dcol.0>0 and rect_collision rect, x: tile.left, y: tile.top, w: tile.width, h: dcol.0
        return true if dcol.1>0 and rect_collision rect, x: tile.right - dcol.1, y: tile.top, w: dcol.1, h: tile.height
        return true if dcol.2>0 and rect_collision rect, x: tile.left, y: tile.bottom - dcol.2, w: tile.width, h: dcol.2
        return true if dcol.3>0 and rect_collision rect, x: tile.left, y: tile.top, w: dcol.3, h: tile.height
    return false

function getTiles (rect, returnnull = true)
    tx=Math.floor rect.x/TS
    ty=Math.floor rect.y/TS
    tw=Math.ceil((rect.x+rect.w)/TS)-tx
    th=Math.ceil((rect.y+rect.h)/TS)-ty
    results=[]
    for yy from ty til ty+th
        for xx from tx til tx+tw
            #row = @layer.data[yy]
            #if row and row[xx] then results.push row[xx]
            #else if returnnull then results.push null
            results.push(map.getTile(xx,yy,map.tile_layer,!returnnull));
    return results

override_getTile = Phaser.Tilemap::getTile
Phaser.Tilemap::getTile=(x,y,layer,nonNull=false)!->
    switch getmapdata \edges
    |\loop
        if y>=@height then y%=@height
        else while y<0 then y += @height
        if x>=@width then x%=@width
        else while x<0 then x += @width
    |\clamp
        if y>=@height then y=@height - 1
        else if y<0 then y=0
        if x>=@width then x=@width - 1
        else if x<0 then x=0

    return override_getTile ...

function tile_passable (tile, water=switches.water_walking, land=true, o=player)
    if not tile? or tile is false or not tile.properties.terrain?
        return water and switches.outside
    if tile.properties.terrain is 'water'
        return water
    if tile.properties.terrain is 'overpass' and tile.properties.dcol is '0,1,0,1' and o.bridgemode is \under
        return tile_passable(map.getTile(tile.x+1, tile.y, map.tile_layer), water, land, o)
    if tile.properties.terrain is 'fringe' or tile.properties.terrain is 'overpass' and o.bridgemode is \under
        return tile_passable(map.getTile(tile.x, tile.y - 1, map.tile_layer), water, land, o)
    return false if tile.properties.terrain is 'wall'
    return false if (getmapdata \edges) is \clamp and
        (tile.x is 0 or tile.x is map.width - 1 or tile.y is 0 or tile.y is map.height - 1)
    return false if tile.properties.terrain is 'mountain' and getTileUnder(o)?properties.terrain is \overpass and o.bridgemode is \under
    return land

!function getTileUnder(o)
    #if (getmapdata \edges) is \loop
    #    return (getTiles.call map.tile_layer, x:o.x, y:o.y, w:0, h:0).0
    #else
    return map.getTile(o.x/TS.|.0, o.y/TS.|.0, map.tile_layer, true)

/* #UNUSED
function tile_line (p1, p2)
    #returns all tiles along a line betwixt two points
    if p1.worldX? then p1 = x: p1.x, y: p1.y
    else p1 = x: Math.floor(p1.x/TS), y: Math.floor(p1.y/TS)
    if p2.worldX? then p2 = x: p2.x, y: p2.y
    else p2 = x: Math.floor(p2.x/TS), y: Math.floor(p2.y/TS)
    while p1.x is not p2.x and p1.y is not p2.y
        tile = map.get-tile p1.x, p1.y, map.tile_layer, true
        return false if !tile
        return false unless tile_passable tile
        return false if tile.properties.dcol?
        dist = x: p2.x - p1.x, y: p2.y - p1.y
        if Math.abs(dist.x) > Math.abs(dist.y)
            p1.x += Math.sign dist.x
        else
            p1.y += Math.sign dist.y
    #end when we're at the end point
    return true
*/

/*
gettilesoverride=Phaser.TilemapLayer::getTiles
Phaser.TilemapLayer::getTiles=!(x, y, width, height, collides=false, interestingFace=false)->
    #return null
    #return gettilesoverride ...
    fetchAll = not(collides or interestingFace)
    x=@_fixX x
    y=@_fixY y
    tx=Math.floor x/@_mc.cw*@scale.x
    ty=Math.floor y/@_mc.ch*@scale.y
    tw=(Math.ceil (x+width)/@_mc.cw*@scale.x) - tx
    th=(Math.ceil (y+height)/@mc.ch*@scale.y) - ty
    while @_results.length
        @_results.pop!
    for wy from ty til ty+th
        for wx from tx til tx+tw
            if wx<0 then wx=0
            else if wx>=@map.width then wx=@map.width - 1
            if wy<0 then wy=0
            else if wy>=@map.height then wy=@map.height - 1
            row=@layer.data[wy]
            if row && row[wx]
                if fetchAll or row[wx].isInteresting collides interestingFace
                    @_results.push row[wx]
    return @_results.slice!
*/

renderregionoverride=Phaser.TilemapLayer::renderRegion
Phaser.TilemapLayer::renderRegion=(scrollX,scrollY,left,top,right,bottom)!->
    if (getmapdata \edges) is \loop then return renderregionoverride ...
    context=@context
    width=@layer.width
    height=@layer.height
    tw=@_mc.tileWidth
    th=@_mc.tileHeight
    tilesets=@_mc.tilesets
    lastAlpha=NaN
    if not @_wrap and (getmapdata \edges) is not \clamp
        if left <= right
            left=Math.max 0,left
            right=Math.min width - 1,right
        if top <= bottom
            top = Math.max 0,top
            bottom = Math.min height - 1,bottom
    baseX=left*tw - scrollX
    baseY=top*th - scrollY
    #normStartX=(left+(1.<<.20)*width)%width
    #normStartY=(top+(1.<<.20)*height)%height
    normStartX=left
    normStartY=top

    #log left,top,right,bottom

    context.fillStyle=@tileColor
    y=normStartY; ymax=bottom - top; ty = baseY;
    while ymax >= 0
        #if y>=height then y -= height
        ##NEW
        yy=y
        if yy>=height then yy=height - 1
        else if yy<0 then yy=0
        ##
        row = @layer.data[yy]
        x=normStartX; xmax = right - left; tx=baseX
        while xmax>=0
            #if x>=width then x -= width
            ##NEW
            xx=x
            if xx>=width then xx=width - 1
            else if xx<0 then xx=0
            ##
            tile = row[xx]
            if !tile or tile.index < 0
                x++; xmax--; tx += tw
                continue
            index = tile.index
            set = tilesets[index]
            if set is undefined
                set = @resolveTileset index
            if tile.alpha is not lastAlpha and not @debug
                context.globalAlpha = tile.alpha
                lastAlpha = tile.alpha
            if set
                if tile.rotation or tile.flipped
                    context.save!
                    context.translate tx + tile.centerX, ty +tile.centerY
                    context.rotate tile.rotation
                    if tile.flipped
                        context.scale -1, 1
                    set.draw context, -tile.centerX, -tile.centerY, index
                    context.restore!
                else
                    set.draw context, tx, ty, index
            else if @debugSettings.missingImageFill
                context.fillStyle=@debugSettings.missingImageFill
                context.fillRect tx, ty, tw, th
            if tile.debug and this.debugSettings.debuggedTileOverfill
                context.fillStyle = @debugSettings.debuggedTileOverfill
                context.fillRect tx, ty, tw, th

            x++; xmax--; tx += tw

        y++; ymax--; ty += th

class Transition
    (@duration,@step,@finish,@smoothness=0,@cinematic=true,@context1=@,@context2=@)->
        @starttime=Date.now!
        @@list.push @
        #@cinema_state=switches.cinema
        #cinema_start! if @cinematic
        #@smoothness=0
    @list = []
    @update=!->
        #console.log "Updating"
        for item in @@list by -1
            item.update!
    update:!->
        t = (Date.now! - @starttime) / @duration
        t = (t*@smoothness.|.0)/@smoothness if @smoothness > 0
        @step?call @context1, 1 <? t
        #console.debug t, @duration
        if t >= 1
            #set_cinema(@cinema_state) if @cinematic
            @@list.splice @@list.indexOf(@), 1
            @finish?call @context2

    @timeout=(dur,fin,cinematic=false,context)!->
        transition = new Transition dur, null, fin, null, cinematic, null, context

    @battle=(dur1, dur2, smoothness=5)!->
        sound.play \encounter
        transition = new Transition dur1, (t)->
            scale = t*5+1
            rot = t*45
            pixel.canvas.style.transform = "scale(#{scale},#{scale}) rotate(#{rot}deg)"
            pixel.canvas.style.opacity = -Math.pow(t,4)+1
        , ->
            pixel.canvas.style.opacity = 0
            setTimeout !->
                pixel.canvas.style.transform = ""
                start_battle2!
                new Transition dur2, (t)->
                    pixel.canvas.style.opacity = t
                ,null, smoothness
            ,500
        ,smoothness
        transition.dur2 = dur2
        return transition

    @critical=(amplitude,duration,cx,cy)!->
        pixel.canvas.style.transform-origin=(cx*100/WIDTH.|.0)+'% '+(cy*100/HEIGHT.|.0)+'%'
        transition = new Transition duration, (t)->
            scale=1+(Math.sin Math.PI*t)*amplitude
            pixel.canvas.style.transform = "scale(#{scale},#{scale})"
        ,->
            pixel.canvas.style.transform = ''
            pixel.canvas.style.transform-origin=''
        ,0,false

    @fade=(fadetime, sleeptime, midcall, fincall, smoothness, cinematic, context)!->
        transition = new Transition fadetime, (t)->
            pixel.canvas.style.opacity = 1 - t
        , ->
            @midcall.call @context3 if typeof @midcall is \function
            #setTimeout ~>
            Transition.timeout @sleeptime, ~>
                transition2 = new Transition @fadetime, (t)->
                    pixel.canvas.style.opacity = t
                , ->
                    @fincall.call @context3 if typeof @fincall is \function
                ,@smoothness, @cinematic
                transition2.context3 = @context3
                transition2.fincall = @fincall
            ,cinematic
            #,@sleeptime
        , smoothness, cinematic
        transition.midcall = midcall
        transition.fincall = fincall
        transition.fadetime = fadetime
        transition.sleeptime = sleeptime
        transition.context3 = context or transition
        return transition

    @shake=(amplitude, wavelength, duration, decay=1, fincall, cinematic, context)!->
        #pos = x:game.camera.center.x, y:game.camera.center.y
        time = 0
        #cinema_state=switches.cinema
        #cinema_start! if cinematic
        setTimeout shakeit, 200

        !function shakeit
            if time >= duration
                #camera_center pos.x, pos.y
                pixel.canvas.style.transform = ""
                #set_cinema(@cinema_state) if cinematic
                fincall?call context
                return
            p = x:Math.random!-0.5, y:Math.random!-0.5
            p = normalize p
            #camera_center pos.x+p.x*amplitude, pos.y+p.y*amplitude
            pixel.canvas.style.transform = "translate(#{p.x*amplitude*pixel.scale}px,#{p.y*amplitude*pixel.scale}px)"
            amplitude *= decay
            time += wavelength
            setTimeout shakeit, wavelength

    @wiggle=(o, times, delay, shift=1, fincall)!->
        if times > 0
            o.x += shift
            setTimeout ~> @wiggle o, times - 1, delay, shift*-1, fincall
            ,delay
        else fincall!

    @fadeout=(o, duration, fincall, context)!->
        transition = new Transition duration, (t)->
            @alpha = 1 - t
        , fincall
        , null, false, o, context or transition
        return transition

    @fadein=(o, duration, fincall, context)!->
        transition = new Transition duration, (t)->
            @alpha = t
        , fincall
        , null, false, o, context or transition
        return transition

    @move=(o,dest, duration, fincall)!->
        origin=x:o.x,y:o.y
        transition = new Transition duration, (t)->
            @x=(dest.x - origin.x)*t+origin.x
            @y=(dest.y - origin.y)*t+origin.y
        ,fincall,null,false,o,o
        return transition

    @pan=(dest, duration,fincall,context,cinematic=false)!->
        origin=x:game.camera.center.x, y:game.camera.center.y
        transition = new Transition duration, (t)->
            camera_center origin.x+(dest.x - origin.x)*t, origin.y+(dest.y - origin.y)*t
        ,fincall,null,cinematic,context,context
        return transition