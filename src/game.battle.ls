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

    battle.bglayer = game.add.group battle, 'battle_bg'
    battle.bglayer.filters = access getmapdata \battle_filters

    battle.bg0 = new Phaser.Image game, 0 0 bg.0
    |> battle.bglayer.add-child
    battle.bgoffset = bgoffset = x:(battle.bg0.width - WIDTH)/2 y:battle.bg0.height - HEIGHT
    battle.bg0.x -= bgoffset.x; battle.bg0.y -= bgoffset.y
    marginwidth = (game.width - WIDTH)/2
    #bg1=if typeof bg.1 is \number then \solid else bg.1
    battle.bg1 = new Phaser.TileSprite game, -bgoffset.x, -bgoffset.y, 1, HEIGHT+bgoffset.y, bg.1
    |> battle.bglayer.add-child
    battle.bg1.anchor.set 1 0
    #battle.bg1.tint=bg.1 if typeof bg.1 is \number
    battle.bg2 = new Phaser.TileSprite game, WIDTH+bgoffset.x, -bgoffset.y, 1, HEIGHT+bgoffset.y, bg.1
    |> battle.bglayer.add-child
    #battle.bg2.tint=bg.1 if typeof bg.1 is \number
    battle.bg3 = new Phaser.Image game, 0, -bgoffset.y, \solid
    |> battle.bglayer.add-child
    battle.bg3.anchor.set 0 1; battle.bg3.tint = bg.2
    battle.bg4 = new Phaser.Image game, 0 HEIGHT, \solid
    |> battle.bglayer.add-child
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

    if battle.bglayer.filters then for filter in battle.bglayer.filters
        filter.update!
        filter.setResolution game.width, game.height

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