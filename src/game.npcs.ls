class NPC extends Actor
    (x,y,key, speed, nobody)->
        super x,y,key,nobody
        @add_facing_animation speed
        @add_simple_animation speed
        @@list.push @
    @list = []
    @clear = !-> for item in @@list
        item.destroy!

var mal, herpes, bp, merch, nae, pox, leps, cure, zmapp, sars, rab, ammit, parvo
joki = []
aids = []

!function new_npc (object, key, speed) 
    n = new NPC object.x, object.y, key, speed
    object.properties.facing ?= \down
    n.face object.properties.facing
    return n

!function node_npc (node, key, speed) 
    n = new NPC node.x+HTS, node.y+TS, key, speed
    node.properties.facing ?= \down
    n.face node.properties.facing
    return n

!function create_npc (o, key)
    object = x: o.x + HTS, y: o.y+TS, properties: o.properties
    npc=new_npc
    switch key
    when \mal
        break if switches.map is \earth and !switches.beat_game
        break if switches.llovsick1 is -2
        break if switches.map is \hub and switches.beat_game
        mal := npc object, \mal
    when \bp 
        break if switches.map is \hub and switches.towerfall_bp
        break if switches.map is \earth and switches.beat_game
        break if switches.map is \lab and !switches.beat_game
        bp := npc object, \bp
    when \joki
        break if switches.map is \castle and switches.beat_joki
        joki.1 := npc object, \joki
    when \joki_2 then joki.2 := npc object, \joki
    when \marb then marb.relocate object if marb not in party
    when \ebby then ebby.relocate object if ebby not in party
    when \merchant
        break if switches.map is \hub and (switches.progress2<9 or switches.llovsick1 is -2)
        break if switches.map is \earth and !switches.beat_game
        temp.herpes_map = if switches.progress2<9 then \deadworld else if switches.progress2<21 then \hub else if !switches.beat_game then \delta else null
        merch := npc object, (if switches.map is temp.herpes_map then \merchant1 else \merchant2), 2
        merch.setautoplay!
    when \herpes
        break if !switches.beat_game
        herpes := npc object, \herpes
    when \wraith
        break if switches.beat_wraith
        n = npc object, \wraith
        n.setautoplay 5
    when \nae
        if switches.map is \earth
            break if !switches.beat_game
            break if !switches.revivalnae
            nae := npc object, \naegleria
            nae.setautoplay 2
            break
        break if switches.beat_nae
        nae := npc object, \mob_naegleria
        nae.battle=encounter.naegleria
        nae.setautoplay 2
    when \war
        n = npc object,\war
        n.body.setSize 3*TS, 2*TS
        n.interact=scenario.war
    when \darkllov
        break if switches.beat_llov
        n = npc object,\mob_llov
        n.battle=encounter.darkllov
        n.setautoplay 8
    when \pox
        break if switches.map is \earth and !switches.beat_game
        break if switches.map is \pox_cabin and switches.confronting_joki
        break if switches.map is \hub and switches.progress2<16
        break if switches.map is \hub and switches.beat_game
        break if switches.llovsick1 is -2
        pox := npc object, \pox
    when \leps then leps := npc object, \leps
    when \parvo then parvo := npc object, \parvo
    when \cure
        #break if switches.beat_cure
        break if switches.progress2>=9 and switches.map is \deadworld and !(switches.curefate>0)
        break if switches.map is \labdungeon and switches.curefate
        cure := npc object,  \cure
    when \zmapp
        #break unless switches.beat_zmapp<1
        #break if switches.beat_zmapp2
        break if switches.map is \towertop and !(switches.progress is \zmappbattle or switches.progress is \zmappbeat)
        break if switches.map is \labdungeon and switches.curefate
        break if switches.map is \deadworld and !(switches.curefate>0)
        zmapp := npc object,  \zmapp
    when \aids1
        aids.1 := npc object, \aids1
        aids.1.kill! if switches.beat_aids
    when \aids2
        aids.2 := npc object, \aids2
        aids.2.kill! if switches.beat_aids
    when \aids3 
        break if switches.map is \earth and !switches.beat_game
        break if switches.map is \earth and !switches.revivalaids
        aids.0 := npc object, \aids3
    when \sars
        break if switches.map is \earth and !switches.beat_game
        break if switches.map is \earth and !switches.revivalsars
        sars := npc object, \sars
        sars.kill! if switches.beat_sars and switches.map is \delta
    when \rab
        break if switches.map is \earth and !switches.beat_game
        break if switches.map is \earth and !switches.revivalrab
        rab := npc object, \rab
        rab.kill! if switches.beat_rab and switches.map is \delta
    when \ammit then ammit := npc object, \ammit

speakers = 
    #marb: display:\Marburg-sama default:\marb_port
    #,smile:\marb_smile troubled:\marb_troubled angry:\marb_troubled grief:\marb_grief
    marb: display:\Marburg-sama composite:{x:-96,y:-129,player:\marb, face:\marb_face}, default:0, smile:1, troubled:2, angry:3, grief:4, aroused:5
    ,voice:\voice2
    #ebby: display:\Ebola-chan default:\ebby_port
    #, smile:\ebby_smile, concern:\ebby_concern, shock:\ebby_concern, cry:\ebby_cry
    ebby: display:\Ebola-chan composite:{x:-81,y:-118,player:\ebby, face:\ebby_face}, default:1, smile:0, concern:2, shock:3, cry:4
    ,voice:\voice7
    #examples: test1:{base:\joki_port, sheet:\llov_face,offx:50,offy:100,frame:1}, test2:[\llov_face, 2]
    #llov: display:\Lloviu-tan default: -> if switches.llovsick then \llov_sick else \llov_port
    #, scared:\llov_scared sick:\llov_sick smile:\llov_smile
    llov: display:\Lloviu-tan composite:{x:-77,y:-115,player:\llov, face:\llov_face}, default: -> if switches.llovsick then 2 else 0
    , scared: 3, sick: 2, smile: 1
    mal: display:\Malaria-sama default:\mal_port
    ,voice:\voice2
    joki: display:\Joki default:\joki_port #tits:\joki_tits
    ,voice: \voice5
    herpes: display:\Herpes-chan default:\herpes_port #tits:\herpes_tits
    ,voice: \voice5
    merch: display:'Agent of Herpes' default:\merchant_port #tits:\merchant_tits
    ,voice: \voice6
    bp: display:\Plague-sama default:\bp_port
    ,voice:\voice3
    pox: display:"Smallpox" default:\pox_port injured:\pox_injured
    ,voice: \voice6
    leps: display:\Lepsy-tan default:\leps_port
    ,voice: \voice7
    parvo: display:\Parvo-tan default:\parvo_port
    ,voice: \voice6
    zika: display:\Zika-chan default:\zika_port
    ,voice: \voice7

    nae: display:'Nae-tan' default:\nae_port
    ,voice: \voice6
    aids1: display:'Eidzu I' default:\aids1_port mad:\aids1_mad fused:\aids3_port
    ,voice: \voice6
    aids2: display:'Eidzu II' default:\aids2_port mad:\aids2_mad fused:\aids3_port
    ,voice: \voice8
    sars: display:'Sars-chan' default:\sars_port mad:\sars_mad
    ,voice: \voice5
    rab: display:'Rabies-chan' default:\rab_port mad:\rab_mad young:\rab2_port
    ,voice: \voice8
    chikun: display:'Chikun-chan' default:\chikun_port
    ,voice:\voice5

    ammit: display:'Ammit-chan' default:\ammit_port
    ,voice:\rope
    shiro: display:'Shiro' default:\shiro_port
    ,voice: \voice6

    wraith: display:\Wraith default:\wraith_port voice:\groan
    pest: display:\Pestilence voice:\groan
    famine: display:\Famine voice:\groan
    war: display:\War default:\war_port voice:\groan

    cure: display:\Cure-chan default:\cure_port
    ,voice:\voice4
    zmapp: display:\Zmapp-chan default: -> if switches.progress2<16 then \zmapp_port else \zmapp_healthy
    ,voice:\voice5
    who: display:\WHO-chan default:\who_port
    ,voice:\rope

    min: display: \Minion default:\min_port
    ,voice: \voice6

    slime: display:\Slime default:\slime_port voice:\groan

for key of speakers
    speakers[key]voice=\voice unless speakers[key]voice?

#speakers.alias =(speaker, alias)!-> @[alias] = @[speaker]
#speakers.alias \marburg \marb
#speakers.alias \ebola \ebby
#speakers.alias \lloviu \llov
#speakers.alias \malaria \mal
#speakers.alias \plague \bp
#speakers.alias \smallpox \pox

!function npc_events
    #========================================================================================
    # Default Chat
    #========================================================================================
    marb?interact =!->
        say \marb \troubled tl("Llov? What are you doing here?")
        say \llov tl("Llov is here to help!")
        say \marb \troubled tl("You came here all by yourself?")
        say \marb \smile tl("Ah well, come along. We'll search together.")
        say \marb tl("We're looking for Cure. She has something that doesn't belong to her.")
        #marb.set_xp levelToXp averagelevel! >? 10
        #party.unshift marb
        #set_party!
        join_party \marb save:true front:true startlevel:12
        #save!
        void /*
        say 'Marburg' "Should I join your team?"
        menu 'yes' ->
            say "Let's get going then!"
            party.push marb
            set_party!
        , 'exit' ->
            say 'Marburg' "Maybe another time."
        */

    mal?interact =!->
        if switches.beat_game
            say \mal tl("I wonder how Zika-chan is doing.")
            return
        say \mal tl("Hello again.")
        #say 'Malaria' "Hi there. This is a test."
        #say "null speaker."
        #say '' "empty string"
        #say 'Malaria', "Here's a menu."
        #menu 'nested' -> 
        #    @menu 'yes' ->
        #    ,'no' ->
        #, 'exit' ->
        #say 'Malaria' "That's about it. Thank you for your time."

    bp?interact =!->
        if switches.beat_game
            if switches.humanfate>0
                if scenario.childAge2!
                    scenario.shiro!
                else if scenario.childAge1!
                    say \bp tl("Isn't she beautiful? She's growing stronger every day.")
                else
                    say \bp tl("I will stay here and help raise the child.")
                
            else
                say \bp tl("I will continue my research in this lab.")
            return
        if switches.progress is \towerfall
            say \bp tl("I'm searching for alternate sources of energy.")
            say \bp tl("Most life on earth is gone now, but there are still traces.")
            say \bp tl("If only we had a way to revive extinct species.")
            return
        say \bp tl("Please, just do what I say.")

    for j in joki
        if j instanceof NPC
            j.interact=joki_interact

    herpes?interact =!->
        herpes_chat ...

    merch?interact =!->
        if @key is \merchant2 then merch_agent ...
        else merch_herpes ...

    merch_agent =!->
        say \merch tl("Um... can I get something for you?")
        menuset =
            tl("Let me browse your goods."), start_shop_menu
            tl("Glass Blowing"), merch_glassblowing
            tl("Gambling"), merch_gambling
        if starmium_unlocked!
            menuset.push tl("Convert Starmium"), merch_convert_starmium
        menuset.push tl("Nevermind"), ->
        menu.apply @, menuset

    merch_herpes =!->
        if player is llov or player is ebby
            say \herpes tl("Hey cutie, what brings you here?")
        else
            say \herpes tl("Do you need something?")
        menuset =
            tl("Let me browse your goods."), start_shop_menu
            tl("Glass Blowing"), herpes_glassblowing
            tl("Gambling"), herpes_gambling
        if starmium_unlocked!
            menuset.push tl("Convert Starmium"), herpes_convert_starmium
        menuset.push tl("Nevermind"), ->
        menu.apply @, menuset

    herpes_gambling =!->
        unless session.gamble_rules
            @say \herpes tl("All right, here's how it works. You choose how much cumberground you want to bet, and I'll flip a coin.")
            @say tl("If it's heads, you win double your bet. If it's tails, I keep it all.")
            @say tl("Simple, right?")
            session.gamble_rules=true
        unless items.cumberground.quantity>0
            return @say \herpes tl("Come back when you have some cumberground to gamble with.")
        @say \herpes tl("How much cumberground will you bet?")
        @number tl("Max:{0}",items.cumberground.quantity), 0 items.cumberground.quantity
        @say ->
            bet=dialog.number.num
            unless bet>0
                return say \herpes tl("Not feeling lucky? That's all right, come back any time.")
            say tl("Flipping the coin...")
            #if pluckroll_leader!>0.55
            #if pluckroll_gamble!>0.505
            if pluckroll_gamble!>0.5
                say tl("Heads, you win! Here's your prize, {0} cumberground!",bet*2)
                #items.cumberground.quantity+=bet
                acquire items.cumberground, bet, true, true
            else
                say tl("Tails. Sorry, you lost {0} cumberground.",bet)
                items.cumberground.quantity-=bet
            save!

    merch_gambling =!->
        unless session.gamble_rules
            @say \merch tl("...You know the rules, right?")
            @say tl("I flip a coin. Heads you win double your bet. Tails I keep everything.")
            session.gamble_rules=true
        unless items.cumberground.quantity>0
            return @say \merch tl("...But you don't have anything to bet. Come back with some cumberground.")
        @say \merch tl("How much cumberground will you bet?")
        @number tl("Max:{0}",items.cumberground.quantity), 0 items.cumberground.quantity
        @say ->
            bet=dialog.number.num
            unless bet>0
                return say \merch tl("...That's okay.")
            say tl("Flipping the coin...")
            #if pluckroll_leader!>0.55
            #if pluckroll_gamble!>0.505
            if pluckroll_gamble!>0.5
                say tl("Heads. You win {0} cumberground.",bet*2)
                #items.cumberground.quantity+=bet
                acquire items.cumberground, bet, true, true
            else
                say tl("Sorry, it's tails. You lose {0} cumberground.",bet)
                items.cumberground.quantity-=bet
            save!

    herpes_glassblowing =!->
        merch_trade_items.call @, \herpes,
            items.cumberground.quantity <? items.shards.quantity
            "I can turn your glass shards into glass vials. It will also cost one cumberground each."
            "How many vials should I make?"
            "Come back any time."
            (num)!->
                items.cumberground.quantity -= num
                exchange num, items.shards, items.vial
                #say \herpes "Here you go, #q glass vial#{if q>1 then 's' else ''}."
                sound.play \itemget
                say '' tl("Acquired {0} {1}!",stattext(num,5),items.vial.name)


    merch_glassblowing =!->
        merch_trade_items.call @, \merch,
            items.cumberground.quantity <? items.shards.quantity
            "One cumberground and one glass shard makes one vial."
            "...How many do you need?"
            "...That's okay."
            (num)!->
                items.cumberground.quantity -= num
                exchange num, items.shards, items.vial
                #say \merch "#q glass vial#{if q>1 then 's' else ''}... For you."
                sound.play \itemget
                say '' tl("Acquired {0} {1}!",stattext(num,5),items.vial.name)

    merch_convert_starmium =!->
        merch_trade_items.call @, \merch, items.starmium.quantity,
            "One Starmium Shard is worth 10 cumberground."
            "How many Sharmium Shards will you convert?"
            "...That's okay."
            (num)!->
                acquire items.starmium, -num, true, true
                acquire items.cumberground, num*10

    herpes_convert_starmium =!->
        merch_trade_items.call @, \herpes, items.starmium.quantity,
            "One Starmium Shard is worth 10 cumberground."
            "How many Sharmium Shards will you convert?"
            "Come back any time."
            (num)!->
                acquire items.starmium, -num, true, true
                acquire items.cumberground, num*10
                
    merch_trade_items =(speaker,q,welcomemessage,quantitymessage,cancelmessage,successcallback)!->
        @say speaker, tl(welcomemessage)
        return unless q>0
        @say tl(quantitymessage)
        @number tl("Max:{0}",q), 0 q
        @say ->
            num = dialog.number.num
            unless num>0
                return say speaker, tl(cancelmessage)
            successcallback.call @, num

    herpes_intro =!->

    herpes_chat =!->
        #if player is marb
        #    say \marb tl( "I've seen the way you look at my sisters. Keep your tail to yourself and there won't be any trouble.")
        #    say \herpes tl( "You know, you're cute when you get jealous like that, Marburg.")
        #else
        #    say \herpes tl( "Isn't it tough walking around in such thick clothing all day? I don't know how you do it.")
        say \herpes tl("Since my agents will run my shops for me, I can just take it easy.")
        #if false #high winnings from gambling
        #    say \herpes tl("Hey, I know you've been a real good customer. Let me teach you something.")
        #    learn_skill \martingale

    Actor.wraith?interact =!->
        #say \wraith "The tower is off-limits. Only the goddess and her followers may enter."
        say \wraith tl("The tower is off-limits. Ebola-chan is not taking visitors at the moment.")
        /*
        say \wraith "The tower is off-limits to all but the goddess."
        menu "Who are you?" ->
            @say "In life we were the followers of our goddess. In death we are her servants and protectors."
        , "Who is the goddess?" ->
            @say "She who kills and is thanked for it. Our master is the one who brought mankind to its knees."
            @say "She is our savior and our reaper. The one who saved the world by destroying it."
        , "What is this tower?" ->
            @say "This tower was created by the will of our goddess."
            @say "There are many who seek to steal her power, and this tower serves to house and protect her."
        , "Why is the tower off-limits?" ->
            @say "Because our goddess wills it to be. Family, friends, or otherwise. None are to enter the tower."
        */

    leps?interact =!->
        unless Date.now! - switches.lepsy_timer < 43200000
            if session.beat_lepsy or switches.beat_game
                say \leps tl("Hey friend, are you here for another show?")
            else
                say \leps tl("Hey friend, what brings you here? Let's put on a show!")
            say \leps tl("★SEIZURE WARNING★ This battle may trigger seizures. Continue at your own risk.")
            menu tl("Continue"), ->
                say \leps tl("All right! Let me see you dance!")
                say -> start_battle encounter.lepsy
            ,tl("Abort"), ->
                say \leps tl("Well thanks for dropping by.")
                if switches.progress2<9
                    say \leps "If you're looking for Cure-chan, I saw her skulking around northwest of here."
        else
            say \leps tl("Hey, thanks for dropping by.")
            if switches.progress2<9
                say \leps "If you're looking for Cure-chan, I saw her skulking around northwest of here."

    parvo?interact =!->
        unless Date.now! - switches.parvo_timer < 43200000
            say \parvo tl("...Oh, it's you. I don't get many visitors down here.")
            say \parvo tl("Did you come to play?")
            menu tl("Yes"), -> start_battle encounter.parvo
            ,tl("No"),->
                say \parvo tl("...Oh.")
        else
            say \parvo tl("Thanks for playing with me... It was fun.")

    pox?interact =!->
        if switches.beat_game
            say \pox tl("It's kind of cold out here isn't it?")
            return
        if !switches.soulcluster
            say \pox tl("Who turned out the lights?")
        else
            say \pox tl("Hey, the light's on!")
    zmapp?interact =!->
        if switches.curefate
            say \zmapp tl("I'm surprised you decided to let us live. You know I wouldn't do the same for you, right?")
            say \marb tl("You're lucky. If it were up to me, you'd be dead now.")
            say \zmapp tl("Why did you spare us anyway?")
            say \ebby tl("{0} told me it was the right thing to do.", switches.name)
            return
    cure?interact =!->
        if switches.curefate
            say \cure tl("We're definitely not working on another scheme. Don't worry about it!")
            say \cure tl("By the way, can you let me see that skull of yours again? I promise I won't do anything funny.")
            say \ebby \concern tl("I don't trust you...")
            return
        if marb in party
            #TODO make this dialog less stupid
            #say \cure "You're finally here, Marburg. I was getting tired of waiting for you."
            #say \marb "You're still wearing that? You must really like it."
            #say \cure "Shut up, I can't take it off! That little witch sister of yours cursed me!"
            #say \marb "You know why I'm here Cure. I can give Ebola-chan one skull, or I can give her two. Decide fast."
            #say \cure "You'll give her nothing, because I'm going to cure you! I'll cure Ebola too! I'll cure everyone!"
            #say \llov "Um... Llov doesn't want to be cured."
            #say \marb "Don't listen to her Llov, she won't be curing anyone. Let's hurry up and dispose of her."

            say \cure tl("You're finally here, Marburg. I was getting tired of waiting for you.")
            say \cure tl("How nice, you even brought your sister with you. Now I can cure both of you.")
            say \marb tl("Llov, are you ready? It's time to deliver divine punishment.")
            say ->
                start_battle encounter.cure
        else
            say \cure tl("What's a cute little virus like you doing out here all alone?")
            if switches.ate_nae isnt \llov
                say tl("Are you all right? You seem ill. I see the destruction hasn't been kind to you.")
            say tl("Don't worry, I will cure you.")
            say ->
                start_battle encounter.cure_single

    ammit?interact =!->
        say \ammit tl("Love and Justice, friend.")
        unless Date.now! - switches.ammitgift < 3600000
            say \ammit tl("This washed up earlier. You can have it.")
            itemlist=[items.starpuff, items.bleach, items.lifecrystal, items.bandage, items.blistercream, items.teleport, items.plaguescroll, items.slowscroll, items.swarmscroll, items.ex2, items.sp2, items.hp2]
            acquire itemlist[Math.random!*itemlist.length.|.0], (Math.min 5, Math.ceil (Date.now! - switches.ammitgift)/10800000)||5, false, true
            switches.ammitgift=Date.now!
            save!
    aids.2?interact=!->
        dialog.port.mad=true
        music.fadeOut 1000
        say \aids2 tl("Look brother, some filthy insects have come to our doorstep.")
        say \aids1 tl("I wonder what they want?")
        say \aids2 tl("No doubt they're here to impede our pure love.")
        aidstalk!
    aids.1?interact=!->
        dialog.port.mad=true
        music.fadeOut 1000
        say \aids1 tl("Nee-chan look, we have visitors.")
        say \aids2 tl("Filthy insects. Go away, you're impeding our pure love.")
        aidstalk!
    !function aidstalk
        say \ebby tl("We want to help you. Can you come with us?")
        say \aids1 tl("Insect? Is that your name? I can't come with you. Onee-chan told me to never follow strangers.")
        say \aids2 tl("Good girl, I'll have to reward you later.")
        if llov in party then say \llov tl("They don't even recognize us...")
        say -> dialog.port.mad=10
        say \aids2 tl("Now get out of here you insects, before I stomp you out of existance!")
        #say \aids2 "No doubt they're here to put an end to our pure love."
        #say \ebby "Don't you recognize us? We're friends. We want to help you!"
        #say \aids2 "We don't need your help. There's nothing wrong with us."
        #say \aids1 "That's right! The one who is wrong is everyone else!"
        #say \ebby "That's not what I mean..."
        say \marb tl("There's no talking sense into them. They've gone maverick. We have to fight.")
        say ->
            dialog.port.mad=false
            start_battle encounter.aids
    aids.0?interact=!->
        say \aids1 \fused tl("Are you wondering why we're off on our own, away from everyone else?")
        say \aids2 \fused tl("Don't be silly. You know why.")

    rab?interact=!->
        if switches.beat_game
            say \rab \young tl("I wonder what all this cold white stuff is. I've never seen it before.")
            menu tl("Tell her it's water"), !->
                say player.name, tl("It's water.")
                say \rab \young tl("Don't be silly, I know it's not water.")
            ,tl("Say nothing."), !->
                say player.name, tl("...")
            return
        dialog.port.mad=true
        music.fadeOut 1000
        say \rab tl("My, you look tasty.")
        if llov in party
            say \llov tl("Why are you saying? Don't you remember us?")
            say \rab tl("I think I would remember seeing such a tasty piece of meat.")
        say \ebby \concern tl("We need to take you somewhere. Will you follow us?")
        say -> dialog.port.mad=8
        say \rab tl("Oh, you're not going anywhere. 'cept in my stomach.")
        say \marb \angry tl("All you're going to be eating is your own words.")
        say ->
            dialog.port.mad=false
            start_battle encounter.rabies

    sars?interact=!->
        if switches.beat_game
            say \sars tl("Wasn't there supposed to be a visual novel or something? What happened to that?")
            return
        dialog.port.mad=true
        music.fadeOut 1000
        if llov in party
            say \llov tl("Sars-chan, do you remember me? We used to be roommates.")
        else
            say \ebby tl("Sars-chan? Do you have a moment?")
        say \sars tl("Can you please not breathe the same air as me? It's major gross yo.")
        say \ebby tl("Please, we want to help you.")
        say -> dialog.port.mad=3
        say \sars tl("Who you callin' a pipsqueak, eh? Do you want to stop breathing?")
        say \marb tl("Nobody called you short yet, little bug.")
        say -> dialog.port.mad=12
        say \sars tl("That's it! I'll make sure you never take another breath again!")
        say ->
            dialog.port.mad=false
            start_battle encounter.sars


    if switches.beat_game and nae then nae.interact=!->
        say \nae tl("Were you looking for a voluptuous slime girl? You found her.")

    if switches.map is \delta and switches.beat_aids and switches.soulcluster
        # spawn Zika
        zika = new NPC nodes.aids2.x, nodes.aids2.y+TS, \zika
        zika.face \down
        zika.interact=!->
            unless Date.now! - switches.zika_timer < 43200000
                if switches.beat_zika
                    say \zika tl("Hey sweetie. You here for another battle?")
                else
                    say \zika tl("If you can beat me, I'll give you something special.  What do you say?")
                menu tl("Yes"), -> start_battle encounter.zika
                ,tl("No"), -> @say \zika tl("Another time, then.")
            else
                say \zika tl("The view is nice from here. I can almost see the end of the river.")



    #========================================================================================
    # Event Chat
    #========================================================================================

    #if not switches.sleepytime then scenario.states.tutorial!
    #if switches.sleepytime then scenario.states.slimes_everywhere!


    switch switches.progress
    #|\slimeattack => scenario.states.slimes_everywhere!
    #|\pylonfixed => scenario.states.pylonfixed!
    |\curebeat,\zmappbattle => scenario.states.returnfromdeadworld!
    |\zmappbeat => scenario.states.zmappbeat!
    |\towerfall => scenario.states.towerfall!
    |\endgame => scenario.states.endgame!
    default =>
        ss=scenario.states.tutorial
        ss=scenario.states.slimes_everywhere if switches.sleepytime
        ss=scenario.states.pylonfixed if switches.pylonfixed
        #ss=scenario.states.returnfromdeadworld if switches.beat_cure>1
        #ss=scenario.states.towerfall if typeof switches.beat_zmapp is \string
        ss!

    if switches.map is \towertop and !switches.soulcluster and switches.progress2>=16
        scenario.soulcluster!

    scenario.always!

    for f in scenario_mod
        f?!

    game.world.filters = access getmapdata \filters
/*
!function joki_guidance
    #Joki will remind you what you should be doing
    say \joki "TODO"
*/
!function joki_interact
    say \joki tl("Can I help you with anything?")
    args=
        tl("Black Water"), ->
            @say \joki tl("I can fill your vials with Black Water for you. It will cost 1 cumberground each.")
            if items.vial.quantity>0 and items.cumberground.quantity>0
                @say \joki tl("How many vials should I fill?")
                #args=["Nevermind", (->),"Fill 1", (!->items.cumberground.quantity-=1;exchange items.vial, items.tuonen)]
                #args.push "Fill 3", (!->items.cumberground.quantity-=3;exchange 3, items.vial, items.tuonen) if items.vial.quantity>=3 and items.cumberground.quantity>=3
                #args.push "Fill 10", (!->items.cumberground.quantity-=10;exchange 10, items.vial, items.tuonen) if items.vial.quantity>=10 and items.cumberground.quantity>=10
                #args.push "Fill 33", (!->items.cumberground.quantity-=33;exchange 33, items.vial, items.tuonen) if items.vial.quantity>=33 and items.cumberground.quantity>=33
                #args.push "Fill 100", (!->items.cumberground.quantity-=100;exchange 100, items.vial, items.tuonen) if items.vial.quantity>=100 and items.cumberground.quantity>=100
                #@menu.apply @,args
                q= items.cumberground.quantity <? items.vial.quantity
                @number tl("Max:{0}",q), 0 q
                @say ->
                    q= dialog.number.num
                    unless q>0
                        return say \joki tl("You don't want any?")
                    items.cumberground.quantity -= q; exchange q, items.vial, items.tuonen
                    #say \joki "I've filled #q vial#{if q>1 then 's' else ''} for you."
                    say '' tl("Acquired {0} {1}!",stattext(q,5),items.tuonen.name)
        tl("Help"), ->
            @say \joki tl("If there's anything you'd like to know, I can certainly help.")
            @menu tl("Skills"), ->
                @say \joki tl("Even if you know more skills, you can only use 5 of them in combat.")
                @say tl("Use the skills menu to choose which 5 skills you want to use in combat.")
                @say tl("It might be smart to reconsider your active skills before each major battle.")
            ,tl("Crafting"), ->
                @say \joki tl("You can craft items in your inventory to create more useful items, such as potions.")
                #@say \joki "Not every combination makes something useful though. Failed recipes give you cumberground, which can be used as currency."
                @say \joki tl("You should experiment with different recipes. Even if you don't make something useful, you can sell the cumberground you get.")
                @say \joki tl("Cumberground is a byproduct of failed recipes, and can be used as a currency.")
                @say \joki tl("Most reagents are dropped by enemies, but you can also harvest them from trees or flowers.")
            ,tl("Excel"), ->
                @say \joki tl("Excel is a power that lets you accelerate evolution. It grants you new strength and abilites during battle.")
            ,tl("Travel"), ->
                @say \joki tl("The waters here in the Tuonen are a bit hazardous, so travel can be difficult.")
                @say tl("Luckily, it's my job to help transport people such as you between the various realms.")
                @say tl("Alternatively you can use Portal Scrolls to travel on your own. They are made by inscribing Grave Dust upon parchment.")
                @say tl("Parchment can be made by combining any two of cloth, fur, or plant fiber together.")
                if not switches.jokigavescrolls
                    @say tl("Here's a free sample.")
                    switches.jokigavescrolls=true
                    acquire.call @, items.teleport, 5
            ,tl("Nevermind"), ->
        #'Guidance' joki_guidance
    (args.push tl("Transport"), ->
        @say \joki tl("Where do you want to go?")
        args= [tl("Nevermind"), ->]
        for w in warpzones
            (args.push w.name, callback:warp_node, arguments:[w.map, w.node, w.dir]) if switches["warp_#{w.id}"]
        @menu.apply @, args
    ) if switches.warpzones
    args.push tl("Nevermind"), ->
    menu.apply @, args
    void /*
    menu 'Show me your tits, Joki.' ->
        @show 'tits'
        @say "You like what you see?"
    ,'Say something funny.' ->
        @say "My hips are moving on their own{|}"
    ,'Nevermind' ->
    say "Farewell"
    */
    show!