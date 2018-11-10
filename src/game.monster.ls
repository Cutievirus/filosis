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