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