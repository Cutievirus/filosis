class Item
    @COMMON = 0
    @CONSUME = 1
    @EQUIP = 2
    @KEY = 3
    (properties)->
        for key of properties
            @[key] = properties[key]
        @quantity ?= 0
        @time ?= 0
        @type ?= Item.COMMON
        @sicon ?= if @type is Item.KEY then 'item_key' else if @type is Item.CONSUME then 'item_pot' else if @type is Item.EQUIP then 'item_equip' else 'item_misc'
        @icon ?= 'item_equip2' if @type is Item.EQUIP
        @iconx ?= 0
        @icony ?= 0
        @target ?= 'ally'
        @attributes ?= []
        @consume =!->
            sound.play \itemget
            @quantity = @quantity - 1 >? 0 if @type is Item.CONSUME and not @dontconsume
            if \glass in @attributes
                if \bomb in @attributes
                    acquire items.shards, 1 true true
                    if game.state.current is \battle
                        drop_item \cumberground 1
                    else acquire items.cumberground, 1 true true
                else acquire items.vial, 1 true true
            save! unless game.state.current is \battle
        @condition ?= -> true
        @unique ?= @type is Item.EQUIP or @type is Item.KEY

    #is_unique:->@type is Item.EQUIP or @type is Item.KEY or @unique

!function acquire (item, q=1, silent=false, nosave=false)
    if !item
        #return alert "Item doesn't exist! Please notify developer."
        fatalerror \missingitem
        return
    item.time=Date.now!
    if silent
        item.quantity += q
        item.quantity=0 if item.quantity<0
        save! unless nosave
        return
    say.call this, ->
        sound.play \itemget 
        item.quantity += q
        item.quantity=0 if item.quantity<0
        save! unless nosave
    #say.call this, '' "Acquired "+(if q>1 then "#{stattext(q,5)} " else '')+"#{item.name}!"
    say.call this, '' tl("Acquired {0} {1}!",stattext(q,5),item.name)

!function exchange
    switch &length
    |2 => qlose=qgain=1; ilose=&0; igain=&1
    |3 => qlose=qgain=&0; ilose=&1; igain=&2
    |4 => qlose=&0; ilose=&1; qgain=&2; igain=&3
    if ilose.quantity < qlose
        warn "Exchange failed, not enough #{ilose.name}!"
        return
    ilose.quantity -= qlose
    igain.quantity += qgain
    igain.time=Date.now!
    save!


#========================================
# Item effects
#----------------------------------------

!function heal (o, hp, showtext=true)
    if o instanceof Player
        o.stats.hp  =  o.stats.hp + hp / (o.get_stat \hp) <? 1
    else
        o.damage -hp, showtext

!function heal_percent (o, hp, showtext=true)
    if o instanceof Player
        o.stats.hp = o.stats.hp + hp <? 1
    else
        o.damage -hp * (o.get_stat \hp), showtext
    return (o.get_stat \hp)*hp

!function item_heal_hybrid (o,n,s, showtext=true)
    if o instanceof Player
        heal o, n, showtext
        heal_percent o, s, showtext
    else
        amt = n + s*o.get_stat \hp
        o.damage -amt, showtext

#========================================
# ITEMS
#----------------------------------------

items = {}
items.steelpipe =
    name: "Steel Pipe"
    iconx: 3
    icony: 2
    type: Item.EQUIP
    mod_atk: (s)->s+18
    mod_speed: (s)->s*0.90
    attack: !->
        calltarget \inflict buffs.dazed if @parent.luckroll!>0.8
    desc: "A crude makeshift weapon. Good for bashing people over the head."
    attributes: <[blunt]>
items.shinai =
    name: "Kendo Stick"
    iconx: 2
    icony: 0
    type: Item.EQUIP
    mod_atk: (s)->s+10
    #desc: "A bamboo sword used in Kendo, a Japanese martial art. It might be better to practice with this before using a real sword."
    desc: "A bamboo sword used in Kendo, a Japanese martial art. Does more damage at lower levels."
    #maybe boost exp gain
items.toyhammer =
    name: "Toy Hammer"
    iconx:2
    icony: 3
    type:Item.EQUIP
    quantity: 0
    mod_atk: (s)->s+6
    mod_luck: (s)->s+9
    attack: !->
        calltarget \inflict buffs.dazed
    desc: "A hammer made of plastic. It doesn't do much damage, but it can be used to stun enemies."
items.bow =
    name: "Lovely Bow"
    iconx:4
    icony:3
    type:Item.EQUIP
    mod_atk: (s)->s*1.02+6
    mod_luck: (s)->s*1.02+4
    desc: "Increases the damage of arrow skills. In skilled hands, unlocks a special skill."
    quantity: 0
    skill: -> if @parent.name is \llov and @parent.forme.stage>0 then skills.leecharrow else null
items.fan =
    name: "Fan"
    iconx: 0
    icony: 2
    type: Item.EQUIP
    mod_atk: (s)->s+10
    mod_def: (s)->s+10
    mod_speed: (s)->s+5
    mod_luck: (s)->s+5
    mod_hp: (s)->s+10
    desc: "A fan given by Malaria-sama. Ever so slightly boosts every stat."
items.samsword =
    name: "Sam Sword"
    iconx: 3
    type: Item.EQUIP
    mod_atk: (s)-> (@get_stat \speed)/666 * s + s
    desc: "A curved sword that requires a bit of skill to use. It cuts better the faster you swing it."
    attributes: <[blade]>
items.broadsword =
    name: "Broad Sword"
    iconx: 4
    type: Item.EQUIP
    mod_atk: (s)-> s*1.11
    desc: "A large sword made to cleave through foes."
    attributes: <[blade]>
items.vampsword =
    name: "Vampire Blade"
    type: Item.EQUIP
    iconx: 1
    icony: 3
    mod_atk: (s)-> s*1.3
    mod_luck: (s)-> s*0.1
    step: !->
        @parent.damage deltam*0.02*@parent.get_stat \hp
    desc: "A powerful sword that gradually drains the wielder's life."
    attributes: <[blade]>
items.mistersword =
    name: "Mister Sword"
    type: Item.EQUIP
    icony: 3
    mod_atk: (s)->
        roll = @parent.luckroll or Math.random
        return s*(1+roll.call(@parent)*0.3 - 0.05)
    desc: "A sword with a mind of its own. Attack power varies randomly."
    attributes: <[blade]>
items.pest =
    name: "Pestilent"
    iconx: 5
    type: Item.EQUIP
    mod_atk: (s)-> s*1.1
    mod_luck: (s)-> s*1.1
    attack: !->
        #battle.target.inflict buffs.poison
        calltarget \inflict buffs.poison if @parent.luckroll!>0.9
    desc: "Old Pest's trusty sword. The blade is adorned with runic lettering. Poison seeps from the blade."
    attributes: <[blade]>
items.worldsharp =
    name: 'Worlds Sharp'
    iconx: 5
    icony: 2
    type: Item.EQUIP
    quantity: 0
    mod_atk: (s)-> s*1.06+5
    mod_luck: (s)-> s*1.2
    desc: "The sharpest cheddar cheese knife in the world. It's too stale to eat."
    attributes: <[blade]>
items.newton =
    name: "Flame Razer"
    iconx: 5
    icony: 0
    desc: "The sharpest and hottest laser razor around."
    type: Item.EQUIP
    attack: !->
    # Deals extra damage against non-scientific enemies
    attributes: <[blade]>
items.chainsaw =
    name: "Chainsaw"
    iconx: 1
    icony: 4
    type: Item.EQUIP
    mod_atk: (s)-> s*(if !(@parent instanceof Monster) and items.oil.quantity then 1.3 else 1)
    attack: !->
        if !(@parent instanceof Monster) and items.oil.quantity
            acquire items.oil, -1, true, true
    desc: "A very powerful weapon. Consumes 1 oil every attack to remain effective."
    attributes: <[tech]>

items.torndress =
    name: "Torn Dress"
    desc: "It's torn at several parts, but it's still somehow wearable."
    type: Item.EQUIP
    iconx:3
    icony:3
    mod_def: (s)-> s+5
    mod_luck: (s)-> s+20
items.leatherarmor =
    name: "Leather Armor"
    iconx: 2
    icony: 1
    desc: "Armor made from hardened leather. It offers light protection."
    type: Item.EQUIP
    #Most armor will lower your speed at least a little. This one won't.
    mod_def: (s)-> s*1.1+10
items.thornarmor =
    name: "Thorn Armor"
    iconx: 4
    icony: 1
    desc: "Thorns coat this armor, causing harm to attackers."
    type: Item.EQUIP
    ondamage: (damage, source)!->
        if source is @parent then return damage
        source?damage damage*0.25, (Math.floor damage)>0, @parent
        return damage
    mod_def: (s)-> s*1.05+10
items.magicarmor =
    name: "Magic Armor"
    desc: "Defends well against magic, but restricts movement."
    type: Item.EQUIP
items.platearmor =
    name: "Plate Armor"
    iconx: 3
    icony: 1
    desc: "Armor made from solid metal plates. It offers high protection but is heavy."
    type: Item.EQUIP
    mod_def: (s)-> s*1.3+30
    mod_speed: (s)-> s*0.9
items.deathsmantle =
    name: "Death's Mantle"
    type: Item.EQUIP
    icony: 4
    desc: "The shroud worn by death itself. Provides immunity to death as long as you have allies."
    mod_luck: (s)-> s/2
items.scythe =
    name: "Scythe"
    type: Item.EQUIP
    iconx: 2
    icony: 4
    desc: "Capable of slaying monsters with death immunity."
    mod_atk: (s)->s*1.1
    mod_luck: (s)->s*1.1
    attack: !->
        calltarget !->
            @attributes.push \mortal if \mortal not in @attributes
items.woodshield =
    name: "Wood Shield"
    icony: 1
    desc: "Provides defense, but is weak to fire."
    type: Item.EQUIP
    #Burns up when hit by a fire attack
    mod_def: (s)-> s*1.2+20
items.towershield =
    name: "Tower Shield"
    iconx: 1
    icony: 1
    desc: "Provides great defense at the cost of offense and mobility."
    type: Item.EQUIP
    mod_def: (s)-> s*1.35+50
    mod_speed: (s)-> s*0.8
    mod_atk: (s)-> s*0.9
items.glassshield =
    name: "Glass Shield"
    desc: "A shield that defends great against magic. It shatters easily, but regenerates after battle."
    type: Item.EQUIP
items.swiftshoe =
    name: "Swift Shoe"
    iconx: 2
    icony: 2
    desc: "Slightly raises speed and greatly increases chance of escape."
    type: Item.EQUIP
    mod_speed: (s)-> s*1.2
    mod_escape: (s)-> s*2

items.heartpin =
    name: "Heart Pin"
    iconx: 1
    icony: 2
    desc: "A cute heart-shaped pin to be worn in the hair. Its magical properties increases the wearer's health."
    type: Item.EQUIP
    mod_hp: (s)->s*1.1+5
    quantity: 0

items.kill =
    name: "Kill"
    desc: "Dev item. Kills target."
    type: Item.KEY
    quantity: 0
    usebattle: (target)->
        target.damage target.stats.hp_max
    target: 'any'

items.riverfilter =
    name: "River Filter"
    #desc: "A special filter designed by Joki to remove contaminants from the black river's water."
    desc: "Allows collection of water from the Tuonen river without assistance from Joki."
    type: Item.KEY
    iconx: 5
    useoverworld: !->
        if player.water_depth
            q = items.vial.quantity
            if q
                say '' tl("Collect Black Water?")
                number tl("Max:{0}",q), 0 q
                say ->
                    q= dialog.number.num
                    unless q>0
                        return say '' tl("Collected nothing.")
                    sludgecount=0
                    for from 0 til q then sludgecount++ if Math.random!<0.1
                    say '' tl("Collected {0} Black Water.",q)
                    acquire items.sludge, sludgecount, false, true if sludgecount
                    exchange q, items.vial, items.tuonen
                    sound.play \itemget
                    pause_screen.inventory.revive!
            else
                say '' tl("Vials are needed to collect water.")
        else
            say '' tl("No water to collect.")
        #if in water fill one vial with black water.
        #occasionally give 1 poison sludge as well
    target: 'none'

items.jokicharm =
    name: "River Boots"
    #desc: "A special filter designed by Joki to remove contaminants from the black river's water."
    desc: "Not an actual pair of boots, but actually a trinket. It seems this allows you to wade through the waters of the Tuonen River."
    type: Item.KEY
    iconx: 4

items.vial =
    name: "Glass Vial"
    type: Item.COMMON
    sicon: \item_pot
    iconx: 1
    desc: "Can be used to collect various liquids to use as potion bases."
items.oil =
    name: "Volatile Oil"
    type: Item.COMMON
    sicon: \item_pot
    iconx: 4
    #desc: "Can be used as a base to create potions with sustained effects."
    desc: "Can be used as a base to create throwing potions."
    attributes: <[glass]>
items.pinesap =
    name: "Pine Sap"
    type: Item.COMMON
    sicon: \item_pot
    iconx: 2
    #desc: "Can be used as a base to create potions with sustained effects."
    desc: "Can be used as a base to create basic potions. Gathered from pine trees."
    attributes: <[glass]>
items.nectar =
    name: "Sweet Nectar"
    type: Item.COMMON
    sicon: \item_pot
    iconx: 3
    desc: "Can be used as a base to create high quality potions. Gathered from flowers."
    attributes: <[glass]>
items.tuonen =
    name: "Black Water"
    type: Item.COMMON
    sicon: \item_pot
    iconx: 5
    #desc: "Can be used as a base to create elixirs."
    desc: "Water pulled from the Tuonen River. Used as a potion base to remove status conditions. Consuming it raw may cause severe amnesia."
    attributes: <[glass]>

items.medicine =
    name: "Medical Waste"
    type: Item.COMMON
    iconx: 4
    desc: "Discarded medical supplies. It could probably be used to make healing items."

items.sludge =
    name: "Poison Sludge"
    type: Item.COMMON
    desc: "A highly toxic substance. Handle with care."
    iconx: 1
    icony: 2
items.gravedust =
    name: "Grave Dust"
    type: Item.COMMON
    desc: "Cursed residue left behind from an undead creature."
    icony: 2
items.silverdust =
    name: "Silver Dust"
    type: Item.COMMON
    desc: "Overexposure may turn skin blue."
    icony: 3
items.starpuff =
    name: "Star Puff"
    type: Item.COMMON
    desc: "A puffy sea star, made of dreams and magic."
    iconx: 1
    icony: 3
items.venom =
    name: "Venom Gland"
    type: Item.COMMON
    desc: "Taken from a venomous beast."
    iconx: 2
    icony: 2
items.aloevera = 
    name: "Aloe Vera"
    type: Item.COMMON
    desc: "Can be used to heal minor burns or as a medical ingredient."
    iconx: 3
    icony: 2
    usebattle: (target)->
        for buff in target.buffs
            if buff.name is \burn and buff.intensity is 1
                buff.remedy!
items.plantfiber = 
    name: "Plant Fiber"
    type: Item.COMMON
    desc: "Fibrous plant parts. It can probably be woven into parchment"
    iconx: 3
    icony: 2
items.fur = 
    name: "Clumpy Fur"
    desc: "Matted clumps of fur taken from a beast of some sort."
    iconx: 4
    icony: 1
items.cloth = 
    name: "Cloth Scraps"
    desc: "Ripped scraps of cloth."
    iconx: 3
    icony: 1
items.cinder = 
    name: "Cinders"
    desc: "Burning bits of something. They're still very hot."
    iconx: 2
    icony: 1
items.frozenflesh = 
    name: "Frozen Flesh"
    desc: "Frozen bits of flesh."
    icony: 1
items.meat = 
    name: "Meat"
    desc: "Succulent bits of meat. They can be used to distract certain enemies."
    type: Item.CONSUME
    sicon: \item_misc
    iconx: 1
    icony: 1
    usebattle: !(target)->
        if \carnivore in target.attributes
            target.inflict buffs.baited
            target.stats.sp=0
            triggertext target.displayname+" was baited!"
        else
            triggertext "It had no effect."
    target: 'enemy'

items.teleport =
    #name: "Teleport"
    name: "Portal Scroll"
    type: Item.CONSUME
    dontconsume: true
    sicon: \item_misc
    iconx: 5
    icony: 1
    desc: "Teleports the user to any previously activated pentagram."
    useoverworld: ->
        teleport_action true, false
    target: 'none'
!function teleport_action consume, ignorelock
    if switches.lockportals and !ignorelock
        return say '' tl("A magical influence prevents the spell from working!")
    zones=[]
    for zone of pentagrams
        for pent of pentagrams[zone]
            if switches["visited_#{pent}"]
                zones.push zone
                break
    if zones.length is 0
        return say '' tl("There are no suitable destinations.")
    menuset=[tl("Cancel"), ->]
    for zone in zones
        menuset.push tl(zone), callback:teleportmenu, context:dialog.menu, arguments:[zone]
    say '' tl("Choose a destination")
    menu.apply window, menuset
    !function teleportmenu zone
        pents=[]
        menuset=[tl("Back"),'back']
        for pent of pentagrams[zone]
            if switches["visited_#{pent}"]
                menuset.push tl(pentagrams[zone][pent]), [!->
                    pause_screen.exit!
                    items.teleport.quantity -- if consume
                ,callback:warp_node,arguments:pent.split /_(?!.*_)/]
        @nest.apply @, menuset

items.swarmscroll =
    name: "Swarm Scroll"
    type: Item.CONSUME
    sicon: \item_misc
    iconx: 5
    icony: 2
    desc: "Casts Swarm on the target."
    usebattle: (target)->
        target.inflict buffs.swarm
    target: 'enemy'
    attributes: <[spell]>

items.plaguescroll =
    name: "Plague Scroll"
    type: Item.CONSUME
    sicon: \item_misc
    iconx: 5
    icony: 3
    desc: "Makes the target spread its diseases to its allies."
    usebattle: (target)->
        diseaselist=[]
        for buff in target.buffs
            #if buff.name in <[poison bleed swarm seizure blister aids]>
            if 'disease' in buff.attributes
            and buff.name not in diseaselist
                diseaselist.push buff.name
        for enemy in enemy_list!
            for buff in diseaselist
                continue if enemy.has_buff buffs[buff]
                enemy.inflict buffs[buff]
    target: 'enemy'
    attributes: <[spell]>

items.slowscroll =
    name: "Slow Scroll"
    type: Item.CONSUME
    sicon: \item_misc
    iconx: 4
    icony: 3
    desc: "Slows the target."
    usebattle: (target)->
        target.inflict buffs.slow
    target: 'enemy'
    attributes: <[spell]>

items.parchment = 
    name: "Parchment"
    desc: "Used for the creation of scrolls."
    iconx: 3
    icony: 3

items.bugbits = 
    name: "Bug Parts"
    desc: "Broken bits of bugs."
    iconx: 2
    icony: 3

items.blistercream =
    name: "Ointment"
    type: Item.CONSUME
    sicon: 'item_misc'
    iconx: 1
    desc: "Removes 1 negative status effect."
    target: 'ally'
    usebattle: (target)->
        for buff in target.buffs
            if buff.negative
                buff.remedy!
                break
items.antidote =
    name: "Antidote"
    type: Item.CONSUME
    icony: 2
    desc: "Heals poison effects when ingested."
    usebattle: (target)->
        target.remedy buffs.poison
    target: 'ally'
    attributes: <[glass]>
items.burnheal =
    name: "Burn Heal"
    type: Item.CONSUME
    iconx: 2
    icony: 2
    desc: "Heals burns."
    usebattle: (target)->
        target.remedy buffs.burn
    target: 'ally'
    attributes: <[glass]>
items.anticurse =
    name: "Anticurse"
    type: Item.CONSUME
    iconx: 1
    icony: 2
    desc: "Removes all sorts of curses."
    usebattle: (target)->
        #target.remedy buffs.curse
        #target.remedy buffs.isolated
        for buff in target.buffs then if 'curse' in buff.attributes
            buff.remedy!
    target: 'ally'
    attributes: <[glass]>
items.antifreeze =
    name: "Antifreeze"
    type: Item.CONSUME
    iconx: 3
    icony: 2
    desc: "Remove all cold effects."
    usebattle: (target)->
        target.remedy buffs.chill
    target: 'ally'
    attributes: <[glass]>
items.bleach =
    name: "Bleach"
    type: Item.CONSUME
    iconx: 4
    icony: 2
    desc: "Remove all status effects from the target."
    usebattle: (target)->
        for buff in target.buffs
            buff.remedy!
    target: 'any'
    #attributes: <[glass]>
items.repel =
    name: "Repel"
    type: Item.CONSUME
    iconx: 5
    icony: 2
    desc: "Keeps monsters away for a short time."
    useoverworld: !->
        temp.repel = 20000
    target: 'none'
items.lifecrystal =
    name: "Life Crystal"
    type: Item.CONSUME
    sicon: 'item_misc'
    iconx: 3
    desc: "Restores health."
    use: (target)->
        item_heal_hybrid target, 50, 0.25
    target: 'ally'
items.darkcrystal =
    name: "Dark Crystal"
    type: Item.CONSUME
    sicon: 'item_misc'
    iconx: 2
    desc: "Removes curses."
    usebattle: (target)->
        target.remedy buffs.curse
    target: 'ally'
items.voidcrystal =
    name: "Void Crystal"
    type: Item.COMMON
    sicon: 'item_misc'
    iconx: 2
    desc: "Used to operate void gates."
items.bandage =
    name: "Bandage"
    desc: "Restores health and stops bleeding."
    type: Item.CONSUME
    sicon: 'item_misc'
    iconx: 4
    icony: 2
    use: (target)->
        item_heal_hybrid target, 50, 0.25
        target.remedy? buffs.bleed
items.hp1 =
    name: "Health Drink"
    type: Item.CONSUME
    icony: 1
    desc: "Restores a moderate amount of health."
    use: (target)->
        item_heal_hybrid target, 100, 0.25
        #heal target, 100,false
        #target.show_text "+#{Math.round 100+heal_percent target, 0.25,false}", 'font_green'
    target: 'ally'
    attributes: <[glass]>
items.hp2 =
    name: "Health Tonic"
    type: Item.CONSUME
    iconx: 1
    icony: 1
    desc: "Restores a lot of health."
    use: (target)->
        item_heal_hybrid target, 200, 0.50
        #heal target, 200,false
        #target.show_text "+#{Math.round 200+heal_percent target, 0.5,false}", 'font_green'
    target: 'ally'
    attributes: <[glass]>

items.sp1 =
    name: "Speed Potion"
    type: Item.CONSUME
    iconx: 2
    icony: 1
    desc: "Raises speed for a short time."
    usebattle: (target)->
        target.inflict buffs.speed
    target: 'ally'
    attributes: <[glass]>
items.sp2 =
    name: "Burst Potion"
    type: Item.CONSUME
    iconx: 3
    icony: 1
    desc: "Provides a quick burst of speed."
    usebattle: (target)->
        if target.has_buff buffs.dizzy
            triggertext "It had no effect."
            return
        target.stats.sp+=2
        target.stats.sp_level=Math.ceil target.stats.sp - 1
        target.inflict buffs.dizzy
    target: 'ally'
    attributes: <[glass]>
    #nodizzy:true

items.ex1 =
    name: "Excel Potion"
    type: Item.CONSUME
    iconx: 4
    icony: 1
    desc: "Fills the excel meter by half."
    usebattle: (target)-> target.stats.ex+=0.5
items.ex2 =
    name: "Excel Tonic"
    type: Item.CONSUME
    iconx: 5
    icony: 1
    desc: "Fills the excel meter to the top!"
    usebattle: (target)-> target.stats.ex+=1

items.poisonbom =
    name: "Poison Bomb"
    type: Item.CONSUME
    icony: 3
    desc: "Poisons the target."
    usebattle: (target)->
        target.inflict buffs.poison
    target: 'enemy'
    attributes: <[glass bomb]>
items.cursebom =
    name: "Curse Bomb"
    type: Item.CONSUME
    iconx: 1
    icony: 3
    desc: "Curses the target."
    usebattle: (target)->
        target.inflict buffs.curse
    target: 'enemy'
    attributes: <[glass bomb]>
items.firebom =
    name: "Fire Bomb"
    type: Item.CONSUME
    iconx: 2
    icony: 3
    desc: "Burns the target."
    usebattle: (target)->
        target.inflict buffs.burn
    target: 'enemy'
    attributes: <[glass bomb]>
items.icebom =
    name: "Ice Bomb"
    type: Item.CONSUME
    iconx: 3
    icony: 3
    desc: "Chills the target."
    usebattle: (target)->
        target.inflict buffs.chill
    target: 'enemy'
    attributes: <[glass bomb]>

items.cumberground =
    name: "Cumberground"
    desc: "A useless piece of garbage. Maybe someone else can find value in this item."
    type: Item.COMMON
    quantity: 0
items.shards =
    name: "Glass Shards"
    desc: "Jagged shards of glass. Can be reformed into glass vials through glass blowing."
    type: Item.COMMON
    iconx: 5

items.waterbottle =
    name: "Water Bottle"
    desc: "Used to spray water at things."
    type: Item.KEY
    iconx: 2
    usebattle: (target)->
        if target.monstertype is Monster.types.rabies
            triggertext "Rabies: NO! WATER IS BAD!"
            unless target.triggered
                target.triggered = true
                target.loadTexture 'monster_rabies2'
                target.stats.atk /= 2
        else
            triggertext "It had no effect."
    target: 'any'

items.tunnel_key =
    name: "Tunnel Key"
    desc: "Opens up Smallpox's maintenance tunnel. The entrance to the tunnel is in a building south of the black tower."
    type: Item.KEY

items.basement_key =
    name: "Trapdoor Key"
    desc: "Opens up the trapdoors on Earth."
    type: Item.KEY
    iconx: 1

items.bloodsample =
    name: "Blood Sample"
    desc: "A sample of human blood. It is marked with a white band."
    type: Item.KEY
    icony: 2
items.bloodsample2 =
    name: "Blood Sample"
    desc: "A sample of human blood. It is marked with a black band."
    type: Item.KEY
    icony: 2

items.necrotoxin =
    name: "Necrotoxin"
    desc: "A substance specially developed to destroy living flesh."
    special: true
    sicon: 'item_key'
    iconx: 4
    icony: 1
    #useoverworld: !->
    #    say '' tl("Nothing to use it on.")
    target: 'none'

items.necrotoxinrecipe =
    name: "Necrotoxin Recipe"
    desc: "Allows War to synthesize additional necrotoxin."
    type: Item.KEY
    iconx: 5
    icony: 1

items.llovmedicine =
    name: "Love Tonic"
    type: Item.CONSUME
    desc: "Medicine to help Lloviu-tan feel better."
    use: (target)->
        setswitch \llovmedicine true
    target: 'ally'
    attributes: <[glass]>

items.humansoul =
    name: "Human Soul"
    sicon: 'item_key'
    icony: 1
    type: Item.COMMON
    desc: "The souls of humanity."

!function eat_soul (target, name)
    level=target.level
    xp=((levelToXp level+1)-(levelToXp level))*2
    target.add_xp xp, true
    message=if target.level>level then tl("Level up!") else tl("{0} xp gained.",xp)
    say '' tl("The soul of {0} has been devoured. {1}",name, message)
    setswitch target.name+"_tainted", true

items.naesoul =
    name: "Nae's Soul"
    soulname: "Naegleria"
    sicon: 'item_key'
    icony: 1
    type: Item.CONSUME
    useoverworld: (target)!->
        switches.llovsick=false if target is llov
        setswitch \ate_nae target.name
        eat_soul target, \Naegleria
    #desc: "Naegleria's soul. It's sure to contain lots of experience."
    desc: "Naegleria's soul. If consumed it will grant experience. If kept it can be used to revive Naegleria."
    target: \ally
    unique: true
    special: true

items.chikunsoul =
    name: "Chikun's Soul"
    soulname: "Chikungunya"
    sicon: 'item_key'
    icony: 1
    type: Item.CONSUME
    useoverworld: (target)!->
        switches.llovsick=false if target is llov
        setswitch \ate_chikun target.name
        eat_soul target, \Chikungunya
    #desc: "Naegleria's soul. It's sure to contain lots of experience."
    desc: "Chikungunya's soul. If consumed it will grant experience. If kept it can be used to revive Chikungunya."
    target: \ally
    unique: true
    special: true

items.aidssoul =
    name: "Eidzu's Soul"
    soulname: "Eidzu"
    sicon: 'item_key'
    icony: 1
    iconx: 1
    type: Item.CONSUME
    useoverworld: (target)!->
        switches.llovsick=false if target is llov
        setswitch \ate_eidzu target.name
        eat_soul target, \Eidzu
    #desc: "Naegleria's soul. It's sure to contain lots of experience."
    desc: "Eidzu's soul. If consumed it will grant experience. If kept it can be used to revive Eidzu."
    target: \ally
    unique: true
    special: true

items.sarssoul =
    name: "Sars' Soul"
    soulname: "Sars"
    sicon: 'item_key'
    icony: 1
    type: Item.CONSUME
    useoverworld: (target)!->
        switches.llovsick=false if target is llov
        setswitch \ate_sars target.name
        eat_soul target, \Sars
    #desc: "Naegleria's soul. It's sure to contain lots of experience."
    desc: "Sars' soul. If consumed it will grant experience. If kept it can be used to revive Sars."
    target: \ally
    unique: true
    special: true

items.rabiessoul =
    name: "Rabies' Soul"
    soulname: "Rabies"
    sicon: 'item_key'
    icony: 1
    type: Item.CONSUME
    useoverworld: (target)!->
        switches.llovsick=false if target is llov
        setswitch \ate_rabies target.name
        eat_soul target, \Rabies
    #desc: "Naegleria's soul. It's sure to contain lots of experience."
    desc: "Rabies' soul. If consumed it will grant experience. If kept it can be used to revive Rabies."
    target: \ally
    unique: true
    special: true

items.llovsoul =
    name: "Lloviu's Soul"
    soulname: "Lloviu"
    sicon: 'item_key'
    icony: 1
    type: Item.CONSUME
    useoverworld: (target)!->
        setswitch \ate_llov target.name
        eat_soul target, \Lloviu
    #desc: "Naegleria's soul. It's sure to contain lots of experience."
    desc: "Lloviu's soul. If consumed it will grant experience. If kept it can be used to revive Lloviu."
    target: \ally
    unique: true
    special: true

items.soulshard =
    name: "Soul Shard"
    sicon: 'item_key'
    iconx: 2
    icony: 1
    type: Item.CONSUME
    useoverworld: (target)!->
        level=target.level
        xp=((levelToXp level+1)-(levelToXp level))/2
        target.add_xp xp, true
        message=if target.level>level then "Level up!" else "#xp gained."
        say '' "Devoured soul shard. #message"
    desc: "A fragment of a broken soul. It probably contains a bit of experience."
    target: \ally
    unique: false

items.excel =
    name: "Excel Orb"
    sicon: 'item_key'
    iconx: 3
    type: Item.CONSUME
    dontconsume: true
    unique: false
    useoverworld: (target)!->
        excel_screen.launch target
    desc: "Permanently unlocks a super-powered transformation for one of your heroes."
    target: \ally
    condition: !->
        unlockcount=0
        excelcount=0
        for i of formes then for j,f of formes[i]
            continue if j is \default
            unlockcount++ if f.unlocked
            excelcount++
        return unlockcount + items.excel.quantity < excelcount
    special: true

items.sporb =
    name: "SP Orb"
    sicon: 'item_key'
    iconx: 3
    icony: 1
    type: Item.CONSUME
    useoverworld: (target)!->
        name=target.name
        switches.sp_limit[name] ?= 1
        switches.sp_limit[name]++
        say '' tl("{0}'s limit has raised to {1}!",speakers[name]display, switches.sp_limit[name]*100+'%')
    target: \ally
    desc: !->
        text=tl("Raises the maximum SP a hero can charge to beyond 100%.\n\nCurrent levels:\n")
        for p in party
            text+=speakers[p.name]display+'\u2002'+(switches.sp_limit[p.name]||1)*100+'%\n'
        return text
    special: true
items.humanskull =
    name: "Human Skull"
    sicon: 'item_equip'
    iconx: 4
    icony: 2
    type: Item.KEY
    desc: "Property of Ebola-chan."

items.humanskull2 =
    name: "Human Skull"
    desc: "When held by Ebola-chan it can be used to shoot lasers from the eyes, dealing extra damage for each bleed effect on the enemy."
    #sicon: 'buff_skull'
    iconx: 4
    icony: 2
    type: Item.EQUIP
    mod_hp: (s)->s*1.1+5
    skill: -> if @parent.name is \ebby then skills.skullbeam else null

items.shrunkenhead =
    name: "Shrunken Head"
    type: Item.EQUIP
    iconx: 5
    icony: 3
    desc: "A gift from Zika-chan. Grants a special skill that deals more damage for each status effect on the enemy."
    mod_luck: (s)->s*1.1
    skill: -> skills.hex
    #reward for beating Zika-chan

items.spellbook =
    name: "Spell Book"
    type: Item.CONSUME
    useoverworld: !->
        learn_skill \poison
    desc: "For testing purposes."
    target: \none

items.coagulate =
    name: "Coagulat Tome"
    type: Item.CONSUME
    useoverworld: !->
        learn_skill \coagulate
    condition: -> \coagulate not in skillbook.all
    desc: "Teaches the coagulate skill, which locks effect slots when used after Hemorrhage."
    target: \none
    unique: true

items.healblock =
    name: "Malus Vital Tome"
    sicon: \item_misc
    iconx: 5
    icony: 4
    type: Item.CONSUME
    useoverworld: (target)!->
        learn_skill \healblock, target.name
    desc: "Teaches the Malus Vital skill, which prevents targets from healing."
    target: \ally
    unique: true


#----------------------------------------
for key, properties of items
    items[key] = new Item properties
    items[key]id = key


#CRAFTING
crafting =
    # {item1: items.water, item2: items.medicine, result: items.hp1}
    # {item1: items.pinesap, item2: items.medicine, result: items.regen}
    {item1: \pinesap, item2: \medicine, result: \hp1}
    {item1: \nectar, item2: \medicine, result: \hp2}
    {item1: \aloevera, item2: \medicine, result: \blistercream}
    {item1: \pinesap, item2: \silverdust, result: \sp1}
    {item1: \nectar, item2: \silverdust, result: \sp2}
    {item1: \pinesap, item2: \starpuff, result: \ex1}
    {item1: \nectar, item2: \starpuff, result: \ex2}

    {item1: \fur, item2: \medicine, result: \bandage}
    {item1: \cloth, item2: \medicine, result: \bandage}
    {item1: \plantfiber, item2: \medicine, result: \bandage}
    {item1: \parchment, item2: \medicine, result: \bandage}

    {item1: \fur, item2: \cloth, result: \parchment}
    {item1: \cloth, item2: \plantfiber, result: \parchment}
    {item1: \plantfiber, item2: \fur, result: \parchment}

    {item1: \parchment, item2: \gravedust, result: \teleport}
    {item1: \parchment, item2: \silverdust, result: \slowscroll}
    {item1: \parchment, item2: \bugbits, result: \swarmscroll}
    {item1: \parchment, item2: \sludge, result: \plaguescroll}
    {item1: \parchment, item2: \venom, result: \plaguescroll}

    # {item1: \fur, item2: \gravedust, result: \teleport}
    # {item1: \cloth, item2: \gravedust, result: \teleport}
    # {item1: \plantfiber, item2: \gravedust, result: \teleport}

    {item1: \frozenflesh, item2: \cinder, result: \meat}

    {item1: \tuonen, item2: \sludge, result: \antidote}
    {item1: \tuonen, item2: \venom, result: \antidote}
    {item1: \tuonen, item2: \gravedust, result: \anticurse}
    {item1: \tuonen, item2: \cinder, result: \burnheal}
    {item1: \tuonen, item2: \frozenflesh, result: \antifreeze}

    {item1: \oil, item2: \sludge, result: \poisonbom}
    {item1: \oil, item2: \venom, result: \poisonbom}
    {item1: \oil, item2: \gravedust, result: \cursebom}
    {item1: \oil, item2: \cinder, result: \firebom}
    {item1: \oil, item2: \frozenflesh, result: \icebom}

    {item1: \silverdust, item2: \bugbits, result: \repel}

for recipe in crafting
    if typeof recipe.item1 is \string then recipe.item1 = items[recipe.item1]
    if typeof recipe.item2 is \string then recipe.item2 = items[recipe.item2]
    if typeof recipe.result is \string then recipe.result = items[recipe.result]
    recipe.item1.craft ?= {}
    recipe.item2.craft ?= {}
    recipe.item1.craft[recipe.item2.name] = recipe.result
    recipe.item2.craft[recipe.item1.name] = recipe.result

recipebook=JSON.parse(localStorage.getItem('filosis-recipes')) or {}

!function learn_recipe (item1, item2, result)
    recipebook[item1] ?= {}
    recipebook[item2] ?= {}
    return if recipebook[item1][item2] is result and recipebook[item2][item1] is result
    recipebook[item1][item2]=result
    recipebook[item2][item1]=result
    saveHandler "#{saveslug}-recipes", JSON.stringify recipebook

#initial
items_initial = {}
for key, item of items
    if item.quantity > 0
        items_initial[key] = item.quantity

!function reset_items (initialize)
    for key of items
        items[key].quantity = 0
    return if not initialize
    for key, q of items_initial
        items[key]quantity = q