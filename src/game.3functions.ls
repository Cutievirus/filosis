
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
        if switches.famine
            switches.famine_cave=true
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


#========================================================================
# Misc
#========================================================================

!function findNPC(name)
    for actor in actors.children
        if actor.name is name then return actor
    return null

!function forNPC(name,callback)
    npc = findNPC name
    if npc then callback.call npc, npc

!function parseGID(gid)
    ret={}
    ret.flipX = !!(gid.&.0x80000000)
    ret.flipY = !!(gid.&.0x40000000)
    ret.gid = gid.&.0x1FFFFFFF
    for tileset in map.tilesets
        if tileset.firstgid <= ret.gid < tileset.firstgid+tileset.total
            ret.tileset=tileset
            ret.key=get_tileset_key tileset.name
            ret.frame=ret.gid - tileset.firstgid
            ret.tx = ret.frame%tileset.columns
            ret.ty = Math.floor ret.frame/tileset.columns
    return ret

!function getTileData(tile)
    gid=mapjson.layers.0.data[tile.y*tile.layer.width+tile.x]
    return parseGID gid
