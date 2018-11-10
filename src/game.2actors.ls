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