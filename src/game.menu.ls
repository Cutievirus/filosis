var pause_screen, shop_screen, refresh_shop

options_mod=[]
pause_menu_mod=[]
!function get_option_menu
    ret=
        'Back', \back
        type:\slider min:0 max:1 label:'Sound Volume',desc:"The volume of regular sound effects.", accessor sound, \volume
        type:\slider min:0 max:1 label:'Music Volume',desc:"The volume of the game music.", onswitch:(!->music.updatevolume!), accessor music, \volume
        type:\slider min:0 max:1 label:'Menu Volume',desc:"The volume of the menu sounds.", accessor menusound, \volume
        type:\slider min:0 max:1 label:'Dialog Volume',desc:"The volume of the speech effect.", accessor voicesound, \volume
        type:\slider min:0 max:100 label:'Text Speed',desc:"The speed at which dialog text is displayed.", accessor gameOptions, \textspeed
        #type:\switch label:'Instant Text', accessor gameOptions, \quicktext
        type:\switch label:'Battle Text',desc:"Enables battle text.", accessor gameOptions, \battlemessages
        type:\switch label:'Pause on Unfocus',desc:"Pauses the game when focus is lost.", onswitch:(!->game.stage.disableVisibilityChange=!gameOptions.pauseidle), accessor gameOptions, \pauseidle
        type:\switch label:'Exact Scaling',desc:"Good for screenshots.", onswitch:resize-game, accessor gameOptions, \exactscaling
        #'Sound Volume' 0
        #'Music Volume' 0
    return ret++options_mod

!function create_option_menu screen, x, y, leftside 
    #option_screen := new Screen! |> gui.frame.add-child
    #option_screen.pauseactors=true
    #option_screen.lockdialog=true
    screen.option_desc=screen.create-window x+(if leftside then -6.5 else 5.5)*WS,y+WS*2, 7,6
    screen.option_desc.text=screen.option_desc.add-text 'font', 'Option Text', HWS+2, HWS, false, 16
    screen.option_menu = screen.create-menu x,y, 6,11
    screen.option_menu.set.apply screen.option_menu, get_option_menu!
    screen.option_menu.on-change-selection=!->
        ii=@selected+@offset
        @parent.option_desc.text.change tl(@options[ii]desc)||''
    screen.option_menu.on-change-selection.call screen.option_menu

!function launch_option_menu screen
    screen.nest screen.option_menu, screen.option_desc


!function create_shop_menu
    shop_screen := new Screen! |> gui.frame.add-child
    shop_screen.pauseactors=true
    shop_screen.lockdialog=true
    shop_window = shop_screen.add-window WS, 0, 18, 11
    shop_menu = shop_screen.add-menu 2*WS, 0, 11,9, true, true

    shop_menu.inbag = shop_menu.add-text null, '', -HWS, WS*9
    shop_menu.currency = shop_menu.add-text null, '', 4*WS, WS*9

    var item_list

    !function purchase (item, cost)
        cost = Math.round cost*0.9 if player is llov or player is ebby
        item_list.push item
        return [[pad_item_name3(item, cost, null, false)+'c', {key:item.sicon, x:item.iconx, y:item.icony}], if item.unique and item.quantity>0 then 0 else ->
            exchange cost, items.cumberground, 1 item
            refresh_shop!
        ]

    shop_menu.on-change-selection=!->
        i=shop_menu.selected+shop_menu.offset-1
        if i<0
            shop_menu.inbag.change ''
        else if item_list[i].unique and item_list[i].quantity>0
            shop_menu.inbag.change 'Sold out'
        else
            shop_menu.inbag.change "Owned:"+(stattext item_list[i]quantity, 5)
        if item_list[i]
            say_now item_list[i].desc
            dialog.message.empty_buffer!

    refresh_shop :=!->
        item_list := []
        args = [\Exit callback: shop_screen.back, context: shop_screen] ++
            (purchase items.leatherarmor, 20) ++
            (purchase items.platearmor, 50) ++
            (purchase items.woodshield, 20) ++
            (purchase items.towershield, 50) ++
            (purchase items.broadsword, 30) ++
            #(purchase items.shinai, 10) ++
            (purchase items.waterbottle, 2) ++
            (purchase items.teleport, 5) ++
            (purchase items.medicine, 1) ++
            (purchase items.vial, 2) ++
            (purchase items.pinesap, 3) ++
            (purchase items.nectar, 6) ++
            (purchase items.oil, 6) ++
            (purchase items.hp1, 5) ++
            (purchase items.hp2, 10) ++
            (purchase items.sp1, 6) ++
            (purchase items.sp2, 14)
        shop_menu.set.apply shop_menu, args

        shop_menu.currency.change items.cumberground.name+":"+(stattext items.cumberground.quantity, 5)
        shop_menu.on-change-selection!


    shop_screen.kill!

!function start_shop_menu
    refresh_shop!
    shop_screen.show!
    @say "What are you looking for?"; dialog.click \ignorelock

!function create_pause_menu
    #pause_screen := new Menu 0, 0, 6, 6 |> gui.frame.add-child
    #pause_screen.kill!
    #override_cancel = pause_screen.cancel
    create_costume_menu!
    create_excel_menu!

    pause_screen := new Screen! |> gui.frame.add-child

    pause_window = pause_screen.create-window 0, 0, 14, 15
    status_window2 = pause_screen.create-window WS*6 0, 9 15, true
    status_window = pause_screen.add-window 224 0, 6 14, true
    status_menu = pause_screen.create-menu 0 0, 6 8
    skill_menu = pause_screen.create-menu 0 0, 6 9
    skill_window = pause_screen.create-window WS*6, 0, 8 15
    skill_window.skillname = skill_window.add-text null '', WS, HWS
    skill_window.skilldesc = skill_window.add-text null '', 7 WS+HWS, null 19
    item_window = pause_screen.create-window 0, 0, 14, 15
    item_window.icon = new Phaser.Sprite game, WS+5 WS+5 \item_equip |> item_window.add-child
    item_window.icon.anchor.set 0.5
    item_window.itemname = item_window.add-text null, '', IS+5, WS
    item_window.itemdesc = item_window.add-text null, '', 8, IS+WS, null, 19

    create_option_menu pause_screen, 64, 16

    pause_menu_back = callback: pause_screen.back, context: pause_screen
    pause_screen.menu=pause_menu = pause_screen.add-menu 64,32,6,8
    pause_screen.inventory=inventory_menu = pause_screen.create-menu WS*2,0, 11,15, true, true
    item_menu = pause_screen.create-menu item_window.x + 128,WS, 6,14, true
    item_menu.item = items.hp1

    pause_screen.crafting=crafting_menu = pause_screen.create-menu WS*2,WS*4, 11,11, true, true
    crafting_menu.item = items.hp1
    crafting_menu.lastitem = items.hp1
    crafting_menu.lastquantity = 0

    yicon = -WS*3
    ytext = -WS*3 - FH/2
    #crafting_menu.combinewith = crafting_menu.add-text null, 'Combine with...', -WS, -WS*3 - 5
    #item1
    crafting_menu.itemicon = new Phaser.Sprite game, 0, yicon, \item_pot |> crafting_menu.add-child
    crafting_menu.itemicon.anchor.set 0.5
    crafting_menu.itemname = crafting_menu.add-text null, '', WS, ytext#-WS*2 - 5
    # +
    crafting_menu.plus = crafting_menu.add-text null, '+', WS*2, ytext+14
    #item2
    crafting_menu.item2icon = new Phaser.Sprite game, 0, yicon+24, \item_pot |> crafting_menu.add-child
    crafting_menu.item2icon.anchor.set 0.5
    crafting_menu.item2name = crafting_menu.add-text null, '', WS, ytext+24
    # =
    crafting_menu.equal = crafting_menu.add-text null, '=', WS*2, ytext+38
    #result
    #crafting_menu.created = crafting_menu.add-text null, 'Created:', WS*5, -WS - 5
    crafting_menu.resulticon = new Phaser.Sprite game, 0, yicon+48, \item_pot |> crafting_menu.add-child
    crafting_menu.resulticon.anchor.set 0.5
    crafting_menu.resultname = crafting_menu.add-text null, '? ? ?', WS, ytext+48
    crafting_menu.resulticon.kill!
    #crafting_menu.created.kill! ; crafting_menu.resulticon.kill! ; crafting_menu.resultname.kill!

    cards = {}
    heads = {}
    for player, i in players
        head = heads[player.name] = new Phaser.Image game, 0 0 "head_#{player.name}" |> inventory_menu.add-child
        head.anchor.set 0, 9 / head.height
        head.kill!
        head.x = 110
        head.player = player
        card = cards[player.name] = new Status-Card 0 0, player |> status_window.add-child
        card.details = new Window 0 0, 9 5 |> status_window2.add-child
        card.details.card = card
        card.details.base = card.base
        for key, i in <[atk def spd lck]>
            card.details[key+1] = card.details.add-text null '', HWS+5, WS*i+9
            card.details[key+2] = card.details.add-text \font_gray '', WS*5, WS*i+9

        card.details.updatestattext =(key)!->
            switch key
            |\atk => stat=\atk;label=\ATK
            |\def => stat=\def;label=\DEF
            |\spd => stat=\speed;label=\SPD
            |\lck => stat=\luck;label=\LCK
            value = Math.ceil @card.get_stat stat
            @[key+1]change label+': '+ stattext value, 5
            return value


    status_window_revive =!->
        for key, card of cards
            card.kill! if card.alive
            card.details.kill! if status_window2.alive and card.details.alive
        for player, i in party
            card = cards[player.name]
            card.revive!
            card.y = [0,80,160][i]
            card.calc_stats!
            if status_window2.alive
                card.details.revive!
                card.details.y = card.y
                for key in <[atk def spd lck]>
                    card['old_'+key] = card.details.updatestattext key
                    card.details[key+2].change ''
                card.old_hp = Math.ceil card.get_stat \hp
            card.hptext.change ''
            card.update_stats!
    status_window.on-revive =!->
        status_window_revive ...

    status_window_revive.call status_window

    #pause_menu.set \Resume pause_menu_back,
    #    \Items launch_inventory_menu
    #    \Skills launch_skill_menu
    #    \Status launch_status_menu
    #    \Options callback:launch_option_menu, arguments:[pause_screen]
    #    \Quit quitgame
    pause_menu.set.apply pause_menu, [
        tl("Resume"), pause_menu_back,
        tl("Items"), launch_inventory_menu
        tl("Skills"), launch_skill_menu
        tl("Status"), launch_status_menu
        tl("Options"), callback:launch_option_menu, arguments:[pause_screen]
        tl("Quit"), quitgame
    ] ++ pause_menu_mod

    pause_screen.kill!

    !function launch_inventory_menu (filter={})
        pause_screen.nest filter, pause_window, inventory_menu, status_window

    #!function launch_option_menu
    #    #pause_menu.nest.apply pause_menu, get_option_menu!
    #    #option_screen.show!

    skill_menu.on-revive =!->
        forme = pause_screen.windows.0.forme
        player = pause_screen.windows.0.player
        skillset = player.skills[forme.id] if player and forme
        mode = pause_screen.windows.0.mode
        skill = pause_screen.windows.0.skill
        args = [if mode is \moveskill or mode is \placeskill then \Cancel else \Back, pause_menu_back]
        @resize @w, if mode is \addskill then 15 else if not mode then 9 else 8
        if mode is \placeskill then skill_menu.on-change-selection =(i)!->
            for ii from 1 til @buttons.length
                @buttons[ii]change @options[ii]
            if i > 0
                @buttons[i]change skill.name
        else if mode is \moveskill then skill_menu.on-change-selection =(i)!->
            ii = @objects.indexOf skill
            list = @objects.slice!
            list.splice ii, 1
            for from 0 til 5 - @objects.length
                list.push name: ' -'
            list.splice (i||ii+1) - 1, 0, skill
            for ii from 1 til @buttons.length
                @buttons[ii]change list[ii - 1]name
        else if mode is \dowhat then skill_menu.on-change-selection =(i)!->
        else skill_menu.on-change-selection =(--i)!->
            if i >= 0 and i < @objects.length
                name=@objects[i]name
                desc=(access @objects[i]desc) || ''
                desc += "\nSP:#{access @objects[i]sp}%"
                #desc += "\nEX:#{access @objects[i]ex}%" if player.excel_unlocked!
            skill_window.skillname.change name || ''
            skill_window.skilldesc.change desc || 'No skill selected'
        if mode is \addskill
            skillist = []
            for key, level of forme.skills
                skillist.push skills[key] if player.level >= level
            skillist ++= skillbook[player.name][forme.id] ++ skillbook[player.name]all ++ skillbook.all
            for sk, i in skillist by -1
                if skillist.indexOf(sk) isnt i then skillist.splice(i,1)
            skillist.sort (a,b)-> a.name.localeCompare b.name
            @objects = skillist
            for sk, i in skillist
                if sk in skillset
                    args.push sk.name, 0
                else
                    args.push sk.name, callback:launch_skill_menu, arguments:[player:player,forme:forme,mode:\placeskill,skill:sk]
        else if mode is \dowhat
            args.push \Move callback:launch_skill_menu, arguments:[player:player,forme:forme,mode:\moveskill,skill:skill],
                \Remove [(!->skillset.splice skillset.indexOf(skill), 1; save!),pause_menu_back]
        else
            if mode is \placeskill
                action = (i,skill)!->skillset[i<?skillset.length]=skill; save!
            else if mode is \moveskill
                action = (i,skill)!->skillset.splice skillset.indexOf(skill),1; skillset.splice i, 0, skill; save!
            @objects = skillset
            for sk, i in skillset
                if mode is \placeskill or mode is \moveskill
                    args.push sk.name, [callback:action,arguments:[i,skill],pause_menu_back,pause_menu_back]
                else
                    args.push sk.name, callback:launch_skill_menu, arguments:[player:player,forme:forme,mode:\dowhat,skill:sk]
            for i from 0 til 5 - skillset.length
                if mode is \placeskill or mode is \moveskill
                    args.push ' -', [callback:action,arguments:[i+skillset.length,skill],pause_menu_back,pause_menu_back]
                else
                    args.push ' -', 0
            if not mode
                args.push 'Add skill...', callback:launch_skill_menu, arguments:[player:player,forme:forme,mode:\addskill]
        @set.apply @, args
        @on-change-selection @selected


    !function launch_skill_menu (properties={})
        if properties.forme
            pause_screen.nest properties, skill_window, skill_menu, status_window
        else if p=properties.player
            if p.excel_unlocked!
                args = [\Back callback:pause_menu.cancel, context:pause_menu, \Default callback:launch_skill_menu, arguments:[player:p,forme:formes[p.name]default]]
                for key, f of formes[p.name]
                    args.push f.name, callback:launch_skill_menu, arguments:[player:p,forme:f] if f.unlocked
                pause_menu.nest.apply pause_menu, args
            else
                launch_skill_menu player:p, forme:formes[p.name]default
        else
            if party.length > 1
                args = [\Back callback:pause_menu.cancel, context:pause_menu]
                for p in party
                    args.push speakers[p.name]display, callback:launch_skill_menu, arguments:[player:p]
                pause_menu.nest.apply pause_menu, args
            else launch_skill_menu player:party.0
        skill_menu.on-change-selection skill_menu.selected

    status_menu.on-revive =!->
        item = pause_screen.windows.0.item
        mode = pause_screen.windows.0.mode
        if item
            args = [tl("Cancel"), pause_menu_back]
            for player in party
                args.push speakers[player.name]display
                args.push [callback: equip_item, arguments: [item, player], pause_menu_back]
            args.push tl("Unequip"), [callback: equip_item, arguments: [item, null], pause_menu_back] if item.equip
            @set.apply @, args
            @on-change-selection=(--i)!->
                for k, card of cards
                    if i>=0 and card.base.equip.id is item.id then card.item.load_buff!
                    else card.item.load_buff card.base.equip
                cards[party[i]name]item.load_buff item if i>=0 and i<party.length
                for k, card of cards
                    for key in <[atk def spd lck]>
                        card['new_'+key] = card.details.updatestattext key
                        diff = card['new_'+key] - card['old_'+key]
                        card.details[key+2]change (if diff<0 then '' else \+)+(stattext diff,5), (if diff<0 then \font_red else if diff>0 then \font_green else \font_gray)
                    card.new_hp = Math.ceil card.get_stat \hp
                    diff = card.new_hp - card.old_hp
                    card.hptext.change (if diff<0 then '' else \+)+(stattext diff,5), (if diff<0 then \font_red else if diff>0 then \font_green else \font_gray)
                    card.update_stats!
            @on-change-selection @selected
        else if mode is \leader
            args = [tl("Cancel"), 'back']
            for player in party
                args.push speakers[player.name]display
                args.push [callback: change_leader, arguments: [player], pause_menu_back]
            @set.apply @, args
        else
            @set tl("Back"), pause_menu_back,
                tl("Equipment"), callback: launch_inventory_menu, arguments: [sortmode:\bytype type:Item.EQUIP, action:\equip]
                tl("Change Leader"), callback: launch_status_menu, arguments: [mode:\leader]
            @on-change-selection=!->

    !function launch_status_menu (properties={})
        pause_screen.nest properties, status_window2, status_window, status_menu

    item_menu.on-revive =!->
        pause_screen.back! if @item.quantity <= 0

    inventory_menu.on-refresh =!->
        for key, head of heads
            head.kill!
            for button, i in inventory_menu.buttons
                continue unless item = inventory_menu.actions[i+inventory_menu.offset]?arguments?0
                if item.equip is head.player
                    head.y = button.y
                    head.revive!
                    break

    inventory_menu.on-revive =!->
        #status_window_revive.call status_window
        sort = pause_screen.windows.0
        args = [\Back pause_menu_back]

        if sort.sortmenu
            #SORTING MODES
            args.push \Alphabet callback: launch_inventory_menu, arguments: [sortmode:\alphabet]
            args.push \Equipment callback: launch_inventory_menu, arguments: [sortmode:\bytype type:Item.EQUIP]
            #args.push 'Key Items' callback: launch_inventory_menu, arguments: [sortmode:\bytype type:Item.KEY]
            args.push 'Special Items' callback: launch_inventory_menu, arguments: [sortmode:\special]
            args.push 'Common Items' callback: launch_inventory_menu, arguments: [sortmode:\bytype type:Item.COMMON]
            args.push \Consumables callback: launch_inventory_menu, arguments: [sortmode:\bytype type:Item.CONSUME]
            args.push \Crafting callback: launch_inventory_menu, arguments: [sortmode:\crafting]
            @set.apply @, args
            return

        #sort
        if not sort.sortmode then args.push \Sort... callback:launch_inventory_menu, arguments:[sortmenu:true]

        #inventory
        inventory = []
        for key, item of items
            continue if sort.sortmode is \bytype and item.type isnt sort.type
            continue if sort.sortmode is \crafting and not item.craft
            continue if sort.sortmode is \special and item.type isnt Item.KEY and !item.special
            inventory.push item if item.quantity > 0

        #sort by time or alphabet
        if sort.sortmode is \alphabet
            inventory.sort (a,b)-> a.name.localeCompare b.name
        else
            inventory.sort (a,b)-> b.time - a.time

        for item, i in inventory
            args.push [pad_item_name3(item), {key:item.sicon, x:item.iconx, y:item.icony}]
            if sort.action is \equip
                args.push callback:launch_status_menu, arguments:[item:item]
            else args.push callback: launch_item_menu, arguments: [item]

        @set.apply @, args

        !function launch_item_menu (item)
            item_menu.item = item
            pause_screen.nest item_window, item_menu, status_window
            args = [\Back pause_menu_back]
            if use = item.use or item.useoverworld
                switch item.target
                when \ally then args.push \Use callback:item_use_menu, arguments:[item]
                when \allies, \all then args.push \Use [callback:!->(for member in party then use member), {callback:item_used, arguments:[item]}]
                default args.push \Use [use, {callback:item_used, arguments:[item]}]
            #if item.type is Item.EQUIP then args ++= [\Equip callback:item_equip_menu, arguments:[item]]
            if item.type is Item.EQUIP
                args.push \Equip callback:launch_status_menu, arguments:[item:item]
                args.push \Unequip callback: equip_item, arguments: [item, null] if item.equip
            if item.craft?
                args.push \Combine callback: launch_crafting_menu, arguments: [item]

            item_menu.set.apply item_menu, args
            item_window.icon.load-texture item.icon || item.sicon
            item_window.icon.frame=item.iconx
            setrow item_window.icon, item.icony
            item_window.itemname.change item.name
            item_window.itemdesc.change (access item.desc) || ''

        !function launch_crafting_menu (item)
            pause_screen.nest pause_window, crafting_menu, status_window
            crafting_menu.item = item
            refresh_crafting_menu.call crafting_menu
            crafting_change_selection.call crafting_menu
            crafting_menu.on-change-selection = crafting_change_selection

        !function refresh_crafting_menu
            #if @item.quantity <= 0
            #    pause_screen.back! ; pause_screen.back!
            craftinv = []
            for key, item of inventory
                craftinv.push item if item.craft?

            args = [\Back pause_menu_back]
            for item, i in craftinv
                continue if item is @item
                args.push [pad_item_name3(item), {key:item.sicon, x:item.iconx, y:item.icony}]
                if @item.quantity<=0 or item.quantity<=0 then args.push 0
                else args.push callback: craft, arguments: [@item, item]

            @set.apply @, args
            @itemicon.load-texture @item.icon || @item.sicon
            @itemicon.frame=@item.iconx
            setrow @itemicon, @item.icony
            @itemname.change pad_item_name3(@item)

        !function crafting_change_selection
            if item2=@actions[@selected+@offset]arguments?1
                setresult.call @, @item, item2
            else
                @item2icon.kill!
                @item2name.change ''
                @resulticon.kill!
                @resultname.change ''

        !function craft (item1, item2)
            result = item1.craft[item2.name] 
            or (\glass in item1.attributes or \glass in item2.attributes) and items.shards 
            or items.cumberground
            learn_recipe item1.id, item2.id, result.id
            acquire item1, -1 true true
            acquire item2, -1 true true
            acquire result, 1 true true
            if result==items.shards
                acquire items.cumberground, 2 true true
                items.cumberground.time+=1
            result.time+=2
            #result.quantity++
            #item1.quantity --
            #item2.quantity --
            refresh_crafting_menu.call crafting_menu
            save!

            if crafting_menu.lastitem is result then crafting_menu.lastquantity++
            else crafting_menu.lastquantity = 1
            crafting_menu.lastitem = result
            #crafting_menu.created.revive!
            #crafting_menu.resultname.revive!
            #crafting_menu.resulticon.revive!
            setresult.call crafting_menu, item1, item2

        !function setresult (item1, item2)
            @item2icon.revive!
            @item2icon.load-texture item2.icon || item2.sicon
            @item2icon.frame=item2.iconx
            setrow @item2icon, item2.icony
            @item2name.change pad_item_name3(item2)
            #result=items.cumberground
            if recipebook[item1.id] and result=recipebook[item1.id][item2.id]
                result=items[result]
                @resulticon.revive!
                @resultname.change pad_item_name3(result, result.quantity)
                @resulticon.load-texture result.icon || result.sicon
                @resulticon.frame=result.iconx
                setrow @resulticon, result.icony
            else
                @resulticon.kill!
                @resultname.change '? ? ?'



        /*
        !function item_equip_menu (item)
            args = ['Equip to...' callback:item_menu.cancel, context:item_menu]
            for player in party
                continue if player.equip is item
                args.push speakers[player.name]display
                args.push callback: equip_item, arguments: [item, player]
            args.push \Unequip callback: equip_item, arguments: [item, null] if item.equip
            item_menu.nest.apply item_menu, args
            #@refresh!
        */
        !function item_use_menu (item)
            args = ['Cancel' callback:item_menu.cancel, context:item_menu]
            for player in party
                args.push speakers[player.name]display
                args.push [{callback:item.use || item.useoverworld, arguments:[player], context:item}, {callback:item_used, arguments:[item]}]
            item_menu.nest.apply item_menu, args

    !function item_used (item)
        item.consume!
        item.time=Date.now!
        pause_screen.inventory.offset=0
        pause_screen.back!
    !function equip_item (item, player)
        itemequip = item.equip
        player?equip.equip = null
        itemequip?equip = buffs.null
        player?equip = item
        item.equip = player
        pause_screen.back!
        save!

    pause_screen.pauseactors=true
    pause_screen_show =(e)!->
        return if actors.paused or switches.cinema or e?button not in [undefined,2]
        pause_screen.show!
        return false
    keyboard.cancel.onDown.add pause_screen_show, pause_screen, 1
    game.input.onDown.add pause_screen_show, pause_screen, 1

!function equip_item (item, player, nosave=false)
    itemequip = item.equip
    player?equip.equip = null
    itemequip?equip = buffs.null
    player?equip = item
    item.equip = player
    save! unless nosave

function trim_quantity (quantity, digits=2)
    return if quantity >= Math.pow(10,digits) then '*'+quantity.toString!slice quantity.toString!length - digits + 1 else quantity
function pad_item_name (item, quantity=item.quantity, digits=5, hide_unique=true)
    #quantity = trim_quantity quantity, digits
    quantity = stattext quantity, digits
    pad('             ', item.name) + if item.unique and hide_unique then '' else " #{quantity}"
#function item_has_quantity (item)
#    return false if item.unique or item.type in [Item.EQUIP, Item.KEY]
#    return true
function pad_item_name2 (item, places=16, quantity=item.quantity, hide_unique=true)
    return item.name if item.unique and hide_unique
    digits= places - item.name.length
    q=stattext quantity, digits
    q=trim_quantity quantity, digits if q.toString!length>digits
    return item.name+pad(' '*digits,q,true)
#pads according to pixel length instead of char count.
!function pad_item_name3(item,quantity=item.quantity,digits=5,hide_unique=true,plen=13*FW)
    text=item.name
    spacewidth=charlen(' ')
    nspacewidth=charlen("\u2009")
    width=0
    for char in text
        width+=charlen(char)
    while width < plen
        if plen - width > spacewidth
            text+=' '
            width+=spacewidth
        else
            text+="\u2009"
            width+=nspacewidth
    if !item.unique or !hide_unique then text+=" "+stattext quantity, digits
    return text
!function pad_item_name4 (item, places=16, quantity=item.quantity,hide_unique=true)
    return item.name if item.unique and hide_unique
    width=0
    for char in item.name
        width+=charlen(char)
    digits=(places*FW - width)/FW.|.0
    q=stattext quantity, digits
    q=trim_quantity quantity, digits if q.toString>digits
    return item.name+pad("\u2007"*digits,q,true)


var title_screen
!function create_title_menu
    title_screen := new Screen! |> gui.title.add-child
    title_screen.nocancel = true
    title_menu = title_screen.add-menu WIDTH - WS*6 HEIGHT - WS*6 6 6
    load_window = title_screen.create-window 0 0 20 15 true
    load_menu = title_screen.create-menu 0, -WS, 20 17 true null 5*WS

    create_option_menu title_screen, WIDTH - WS*6, HEIGHT - WS*11, true

    largs = []
    files = getFiles!
    filelist = []
    filecount = Object.keys(files)length <? 3
    for name, file of files
        filelist.push file
        largs.push name, callback:load_from_menu, arguments:[name]
    load_menu.set.apply load_menu, largs
    load_menu.y = (3 - filecount)*40 - WS
    #largs.length/2 * load_menu.BH - WS
    windows = []
    for i from 0 til filecount
        windows.push <| win = new Window 0 (3 - filecount)*40 + i*load_menu.BH, 20, 5 |> load_window.add-child
        win.ports=[]
        for j from 0 til 3
            win.ports.push <| new Phaser.Sprite game, 5*WS*j+WS*3, -WS+5, '' |> win.add-child
            win.ports[j]item = new Phaser.Sprite game, WS, WS*3, '' |> win.ports[j]add-child
            (win.ports[j]level = new Text \font_yellow 'Level' WS*5, WS*5 |> win.ports[j]add-child)anchor.set 0.5, 0
    args = ['New Game' newgame]
    if filecount>1 #multiplesaves
        args.unshift 'Continue' launch_load_menu if largs.length>0
    else
        args.unshift 'Continue' callback:load, arguments:[Object.keys(getFiles!)0] if largs.length>0
    args.push 'Options' callback:launch_option_menu, arguments:[title_screen]
    #if filecount>1 #multiplesaves
    #    args.push 'Delete' callback:launch_load_menu, arguments:['delete'] if largs.length>0
    args.push 'Manage Saves' !->
        savemanager.readFiles();
        saveman.style.display='block'
    title_menu.set.apply title_menu, args
    title_screen.show!

    !function launch_load_menu(properties)
        title_screen.nest properties, load_window, load_menu

    !function load_from_menu (file)
        if title_screen.windows.0 is 'delete'
            deleteFile file
            quitgame!
        else
            load file

    #!function launch_option_menu
    #    #title_menu.nest.apply title_menu, get_option_menu!
    #    #option_screen.show!
    

    load_menu.on-refresh =!->
        for win, i in windows
            for j from 0 til 3
                if fp = filelist[i+@offset]party[j]
                    win.ports[j]revive!
                    win.ports[j]load-texture get_costume fp.name, 0, fp.costume
                    win.ports[j].frame=get_costume fp.name, 0, fp.costume, \bframe
                    win.ports[j]level.change ''+xp-to-level fp.xp
                    item = win.ports[j]item
                    win.ports[j]item.load-texture access items[fp.item]?icon
                    win.ports[j]item.frame=items[fp.item]?iconx or 0
                    setrow win.ports[j]item, (items[fp.item]?icony or 0)
                else
                    win.ports[j]kill!



var costume_screen
!function create_costume_menu
    costume_screen := new Screen! |> gui.frame.add-child
    costume_screen.pauseactors=true

    costume_window =  costume_screen.add-window WIDTH-7*WS, 0 7 15 true
    costume_menu = costume_screen.add-menu WIDTH-7*WS, -WS, 7 17 true null 5*WS

    costume_menu.windows = []
    for i from 0 til 3
        costume_menu.windows.push <| w = new Window 0 i*5*WS, 7 5 |> costume_window.add-child
        w.port = new Phaser.Sprite game, (w.w-6)*WS+5, 5-WS, '' |> w.add-child

    costume_screen.launch =(p)!->
        if typeof p is \object then p = p.name
        costume_menu.player = p
        costume_menu.offset = 0
        #args = [\Default callback:set_costume, arguments:[p,null]]
        args = []
        costume_menu.costumes = []
        for key,costume of costumes[p]
            #continue unless costume.unlocked
            args.push costume.name, callback:set_costume, arguments:[p,key]
            costume_menu.costumes.push key
        costume_menu.set.apply costume_menu, args
        costume_screen.show!

    costume_menu.on-refresh =!->
        for win, i in @windows
            win.revive!
            i = i+@offset
            if i >= @costumes.length then win.kill!
            else
                win.port.load-texture get_costume @player, 0, @costumes[i]
                win.port.frame=get_costume @player, 0, @costumes[i], \bframe

    set_costume =(p,c)!->
        if typeof p is \string then p = players[p]
        p.costume = c
        update_costume p, c
        save!
        costume_screen.back!

!function update_costume p, c
    #console.debug p.name
    if !c
        if p.key isnt p.name then p.load-texture p.name
        p.setrow 0
        return 
    costume=costumes[p.name][c]
    if not costume
        return console.warn "costume #c doesn't exist."
    if costume.csheet and costume.csheet isnt p.key
        p.load-texture costume.sheet
    if costume.crow then p.setrow costume.crow
    else p.setrow 0

var excel_screen
!function create_excel_menu
    excel_screen := new Screen! |> gui.frame.add-child
    excel_screen.pauseactors=true

    excel_window = excel_screen.add-window 0 WS*3.5 20 8 false
    excel_menu = excel_screen.add-menu 0 WS*3 20 5 true null
    excel_menu.horizontalmove=true

    for b, i in excel_menu.buttons
        if i is 0
            b.BH=WS
            continue
        else
            b.BW=excel_menu.w*HWS - 10
            b.x = b.BW*(i-1) + 10*i
            b.y = 5*WS
            b.BH = WS*7
            #b.y=excel_menu.buttons[1].y
        #excel_menu.windows.push <| w = new Window 0 i*5*WS, 7 5 |> excel_window.add-child
        b.port = new Phaser.Sprite game, WS*3, -2*WS-3, '' |> b.add-child
        b.formname = b.add-child new Text null, 'NAME', WS, -WS*3+4
        b.formdesc = b.add-child new Text null, 'DESC', 0, -WS*2, null, 16
    #excel_menu.windows.0.resize 7 15

    excel_screen.launch =(p)!->
        if typeof p is \object then p = p.name
        excel_menu.player = players[p]
        excel_menu.offset = 0
        args = [\Cancel callback: @back, context: @]
        excel_menu.forms = []
        for key,form of formes[p]
            continue if key is \default
            excel_menu.forms.push key
            if formes[p][key]unlocked
                args.push '', 0
                continue
            args.push '', callback:unlock_form, arguments:[p,key]
        excel_menu.set.apply excel_menu, args
        for b, i in excel_menu.buttons
            continue if i is 0
            form=formes[p][excel_menu.forms[i-1]]
            b.formname.change form.name, if excel_menu.actions[i] then 'font_yellow' else 'font_gray'
            b.formdesc.change form.desc, if excel_menu.actions[i] then 'font' else 'font_gray'
        excel_screen.show!
        pause_screen.exit!

    excel_menu.on-refresh =!->
        for b, i in @buttons
            continue if i is 0
            #if i >= @costumes.length then win.kill!
            #else win.port.load-texture get_costume @player, 0, @costumes[i]
            b.port.load-texture get_costume @player.name, i, @player.costume
            b.port.frame=get_costume @player.name, i, @player.costume, \bframe
    unlock_form =(p,c)!->
        #formes[p][c]unlocked=true
        sound.play \itemget
        unlock_forme p, c
        items.excel.quantity--
        #switches.sp_limit++
        save!
        excel_screen.back!