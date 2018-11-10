
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