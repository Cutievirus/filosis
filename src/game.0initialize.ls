
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
        download: tle("Download a native version of this game from {0}. Run the game executable.","<a href='http://filosis.cutievirus.com/\#download'>filosis.cutievirus.com</a>")
        report: tle("To report this bug, the you can contact me on {0}.","<a href='https://discord.gg/4SJ5dFN'>Discord</a>")
    switch type 
    |\sameOrigin
        text="<h2>"+tle("The game cannot be played right now.")+"</h2>"+
        "<p>"+tle("This probably happened because your browser blocked a cross-origin request.")+"<br>"+
        tle("Some web browsers heavily restrict what can be done in the file protocol, and don't allow access to files in sub folders.")+"<br>"+
        tle("There are a few things you can do to fix this.")+"</p>"+
        "<p>1. "+fatalerror.advices.download+"</p>"+
        "<p>2. "+tle("Try a different browser. Chromium browsers won't work. Firefox will. If you want to play using this browser, read further.")+"</p>"+
        "<p>3. "+tle("Disable web security. This isn't reccomended unless you know what you're doing.")+"</p>"
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