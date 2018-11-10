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