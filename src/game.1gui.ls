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