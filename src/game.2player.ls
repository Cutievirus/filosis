
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
