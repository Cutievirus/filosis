!function cinema_start
    #switches.cinema = true
    #switches.cinema2 = switches.cinema = true
    switches.cinema2 = true
    for actor in actors.children
        actor.cancel_movement?!

!function cinema_stop
    #switches.cinema = false
    #switches.cinema2 = switches.cinema = false
    switches.cinema2 = false

!function set_cinema(state)
    if state then cinema_start!
    else cinema_stop!


scenario = {}
scenario.states = {}
scenario_mod=[]

scenario.always=!->
    if temp.nae_reward
        temp.nae_reward=false
        if skills.poisonstrike not in skillbook.all
            say \nae tl("You really are strong. How about I teach you something?")
            learn_skill \poisonstrike
    if temp.leps_reward
        temp.leps_reward=false
        if skills.seizure not in skillbook.all
            say \leps tl("That was a great show! Let me show my appreciation.")
            learn_skill \seizure
    if temp.parvo_reward
        temp.parvo_reward=false
        if skills.lovetap not in skillbook.all
            say \parvo tl("That was fun! let's play again some time.")
            learn_skill \lovetap
    if temp.zika_reward
        temp.zika_reward=false
        if items.shrunkenhead.quantity is 0
            say \zika tl("As promised, here's your reward.")
            acquire items.shrunkenhead
    if switches.map is \deadworld and (switches.famine_cave)
        dood = new Doodad(nodes.secretcave.x, nodes.secretcave.y, \jungle_tiles null false) |> carpet.add-child
        #dood.frame=83
        dood.crop new Phaser.Rectangle TS*5, TS*13, TS,TS
    if switches.map is \delta and switches.revivalllov and llov not in party
        scenario.revivalllov!

scenario.game_start =!->
    solidscreen.alpha = 1
    for member in party
        member.visible = false
    cinema_start!
    #camera_center player.x + 4*TS, player.y
    marb.start_location!
    marb.revive!
    marb.face \left
    music.stop!
    switches.nomusic=true

    switches.llovsick = true

scenario.game_start.0 =!->
    #say \ebby \smile "Hello there! It's nice to finally meet you."
    #say -> switches.name = prompt("What is your name?")
    #say '' tl("What is your name?")
    #number '',"text",13
    #say ->
    #    switches.name=dialog.number.num.join('').replace(/_/g,' ').trim()
    #dialog.locked=true
    dialog.textentry.show 13, tl("What is your name?"),(m)!->
        #dialog.locked=false
        #dialog.next!
        if !m then return scenario.game_start.0!
        switches.name=m.trim()
        items.humanskull2.name=switches.name
        say '' tl("Your name is {0}?",switches.name)
        menu tl("Yes"), ->scenario.game_start.0.1!
        ,tl("No"), ->scenario.game_start.0!
scenario.game_start.0.1 =!->
    if getFiles![switches.name]
        say '' tl("A save file already exists. The new game cannot be saved without overwriting the existing save file.")
        menu tl("Continue without saving"), ->
            switches.nosave=true
        , tl("Delete save file"), ->
    #say '' "Voices can be heard coming from outside."
    #say \marb "It's no use. Ebola-chan refuses to leave the tower."
    #say \mal "That's a shame. Our lives could very well depend on her."
    #say \marb "She'll come around, don't worry."
    #say \mal "How can you be so sure?"
    #say \marb "She's depressed because something important was taken from her."
    #say \marb "If that's the case, then all I need to do is get it back."
    #say \marb "After all, when somebody bullies one of my cute sisters, it's my duty to murder the hell out of them."
    #say \mal "What about Lloviu-tan?"
    #say \marb "You and Plague-sama will take care of her while I'm gone. Remember, if anything happens to her..."
    say ->
        Transition.fade 500 1000 ->
            solidscreen.alpha=0
            camera_center player.x + 4*TS, player.y
            #music.play \2dpassion
            switches.nomusic = false
        , scenario.game_start.1
        ,15 false

#scenario.game_start.0.intro =!->
#    say '' "It was the year 20XX, at the height of human arrogance and pride..."

scenario.game_start.1 =!->
    /*
    say \mal "How is she?"
    say \marb "It's not getting worse, but it's not getting better either."
    say \mal "What about Ebola-chan?"
    say \marb "She's still in the tower. I'm told she's had something important taken from her, and that's why she locked herself in."
    say \mal "What will you do?"
    say \marb "What else can I do? I'm going to get it back."
    say \mal "Do you even know what you're looking for?"
    say \marb "It's in the land of the dead. Aside from that... Well, I think Joki knows more than she's letting on."
    */
    #scene: Llov is in bed, Marburg stands by her side.
    #equip_item items.bow, llov
    say \marb tl("Llov, are you awake?")
    say \marb tl("I'm sorry, I would love nothing more than to stay by your side...")
    say \marb tl("But I must go. Don't worry, I'll be back before you realize.")
    #say "I have to go somewhere now. Don't worry, I'll be back soon."
    #say "That thing they stole... I need to get it back. It's very precious to her."
    #say "Don't worry though, I'll be back soon enough."
    #say "Maybe before I return, you'll even find yourself on an adventure of your own."
    say tl("Plague and Malaria will be here to take care of you. Go to them if you need anything.")
    #say "And remember, if you find yourself in a battle you don't think you can win, there's no shame in running."
    #Marburg exits stage.
    marb.move 0 1.5
    marb.move 2 0
    marb.move 0 1
    marb.path.push ->
        
        marb.kill!
        setTimeout ->
          Transition.wiggle doodads.llovbed, 4 300 1 -> setTimeout ->
            getoutofbed!
          ,100
        , 1400
    !function getoutofbed
        doodads.llovbed.animations.frame = 1
        say \llov \sick tl("Marburg-nee... Llov wants to go too.")
        say ->
            doodads.llovbed.alpha=0
            for member in party
                member.visible = true
            player.face \right
            cinema_stop!
            setswitch \started true

scenario.states.tutorial =!->
    
    if switches.map is \hub
        joki.1?relocate \joki_bridge
        joki.1?face \left

    mal?interact =!->
        if switches.gotmedicine and switches.askaboutmarb
            if not switches.llovmedicine
                say \mal tl("Is that the medicine Plague-sama gave you?")
                say \mal tl("Plague-sama is a doctor, so you should listen to what she says.")
            else
                say \mal tl("Plague-sama told you to get some rest right? Your bed is waiting right through this door.")
            return

        if not switches.talktomal
            say \mal tl("Why if it isn't Lloviu-tan. Are you awake already?")
            setswitch \talktomal true
        if not switches.askaboutmarb
            say \llov \sick tl("Where is Marburg-nee?")
            say \mal tl("I'm afraid she's left already, you just missed her. I'm sure she'll be back soon, though.")
            setswitch \askaboutmarb true
        if not switches.gotmedicine
            say \mal tl("Plague-sama told me she had something for you. You should go see her.")
    jokioverride = joki.1?interact
    joki.1?interact =!->
        if not switches.askjokiaboutmarb
            say \joki tl("Lloviu-san, is it? What might you need?")
            say \llov \sick tl("Did Marburg-nee go this way?")
            say \joki tl("Not this way. I ferried her to the Land of the Dead.")
            say \llov \sick tl("Can you take Llov too?")
            say \joki tl("Hmm, I'm afraid you wouldn't survive the journey in your condition.")
            switches.askaboutmarb = true
            setswitch \askjokiaboutmarb true
        else
            jokioverride ...
    
    bp?interact =!->
        if not switches.gotmedicine
            say \bp tl("Lloviu-tan, there you are. I have something for you.")
            switches.gotmedicine = true
            acquire items.llovmedicine
            say \bp tl("This tonic should help you regain some of your strength. Try to get some rest after you take it.")
        else if not switches.llovmedicine
            say \bp tl("What do you need?")
            menu tl("What is this medicine?"), ->
                @say tl("The vial contains liquid vitae. It is the energy that we need to survive.")
                @say tl("It is secreted by living things, and can also be harvested from human souls.")
                @say tl("This vitae was provided by your sister. She made this tower to harvest vitae from the souls she collected.")
                #@say "Normally it is secreted by living things, but since our primary source of energy was destroyed, we must search for other sources."
            , tl("Why am I sick?"), ->
                #@say "Without a source of energy we  weak."
                @say tl("Put simply, your reservoir was destroyed.")
                @say tl("Without a reliable source of energy, you've gradually grown weak.")
                @say tl("The medicine I gave you should help you regain your strength.")
                #@say "Since you aren't infectious to humans, this means you've been without a source of energy for a long time."
                #@say ""

                #@say "When we found you in the wilderness you had already been without a source of energy for too long."
                #@say "You're lucky you weren't devoured by some beast, or by another virus."
                #@say "Any way, as long as you stay near the tower and drink the medicine I give you, you should recover."
                
                #@say "Unlike your sisters, you are not infectious to humans. Instead, you rely on a reservoir of bats."
                #@say "Unfortunately though, your reservoir was destroyed through the reckless action of humans."
                #@say "For longer than the rest of us, you have been without a reliable source of energy. Coupled with the fact that you were never a powerful virus to begin with."
                #@say \llov \sick "Won't you and the others get sick too?"
                #@say \bp "Not necessarily. For now, the black tower provides us enough energy to live. If only we could find another source though..."
            , tl("How do I take the medicine?"), ->
                @say tl("Open the pause menu by hitting the escape key or right clicking with your mouse. Then, select the \"items\" option.")
                @say tl("You're a smart girl, so I think you should be able to figure out the rest on your own.")
        else
            say \bp tl("You drank the medicine? good. Now you should get some rest.")

    llovbedinteract = doodads.llovbed?interact
    doodads.llovbed?interact =!->
        if switches.llovmedicine and not switches.sleepytime
            music.fadeOut 1000
            cinema_start!
            Transition.fade 500 1000 ->
                switches.llovsick = false
                setswitch \sleepytime true
                for member in party
                    member.visible = false
                doodads.llovbed.alpha=1
                player.start_location!
                camera_center player.x + 4*TS, player.y
            , ->
                setTimeout ->
                    sound.play \boom
                    Transition.shake 8 50 1000 0.95 ->
                        doodads.llovbed.animations.frame = 1
                        say '' tl("Something is happening outside!")
                        say ->
                            doodads.llovbed.alpha=0
                            for member in party
                                member.visible = true
                            player.face \right
                            cinema_stop!
                    ,false
                ,1000

                # One of the pylons is destroyed and the town is under attack
                # Play a sound effect and shake the screen.
            ,15 false
        else if switches.gotmedicine and not switches.sleepytime
            say \llov \sick tl("Not yet, I need to take the medicine first.")
        else if switches.sleepytime
            say '' tl("Can't sleep right now.")
        else
            llovbedinteract!

scenario.states.slimes_everywhere =!->
    if switches.map is \hub
        joki.1.relocate \joki_bridge
        if switches.jokistepsaside
            joki.1.y -= TS
            joki.1.cancel_movement!
        joki.1.face \left

        neutral_slime mal.x, mal.y
        mal.shift -TS, 0
        mal.face \right

        bp.face \downright
        bp.shift -TS, -TS
        neutral_slime bp.x, bp.y+TS
        neutral_slime bp.x+TS, bp.y

        for node in [nodes.mob1, nodes.mob2, nodes.mob3, nodes.mob4, nodes.mob5, nodes.mob6]
            neutral_slime node.x, node.y+TS

    mal?interact =!->
        say \mal tl("Please, just go inside. We can handle this.")
        say tl("If something were to happen to you, Marburg would...")
        say -> mal.face \right

    bp?interact =!->
        unless session.talktobp
            say \bp tl("Damn, they're everywhere.")
            say \llov tl("What can Llov do to help?")
            say \bp tl("Listen, I know you're feeling better, but you're still ill.")
            say \bp tl("Go back inside and rest.")
            session.talktobp=1
        else
            say \bp tl("Didn't you hear me? Go and hide. It's not safe out here.")


        say -> bp.face \downright
        


    !function neutral_slime (x,y)
        slime = new NPC x, y, \mob_slime, Math.random!*2+5
        slime.setautoplay \simple
        slime.interact =!->
            #sound.play \groan
            say 'Slime' tl("Wub wub wub...")
            say \llov \scared tl("...!")

    doodads.llovbed?interact =!->
        say '' tl("Can't sleep right now.")

    jokioverride = joki.1?interact
    joki.1?interact =!->
        if switches.jokistepsaside
            say \joki tl("Find Smallpox. She can fix the pylon.")
            jokioverride ...
            return
        unless switches.whatcanllovdotohelp
            say \joki tl("Lloviu-san, such a pleasure.")
            say \llov tl("What happened?")
            #say \joki "The pylons that protect this area. One was damaged."
            say \joki tl("One of the pylons that protect this area was damaged.")
            say \llov tl("What can Llov do to help?")
        else
            say \llov tl("Llov wants to help after all!")
        setswitch \whatcanllovdotohelp true
        say \joki tl("It will be dangerous. Are you sure?")
        menu 'Yes' ->
            @say \joki tl("Smallpox built the pylons. she can fix them. Find her.")
            @say \joki tl("Remember, you are the sister of Marburg and Ebola. You are stronger than you think.")
            @say \joki tl("Go now, cross this bridge. Have no fear, I am already waiting for you on the other side.")
            @say ->
                setswitch \jokistepsaside true
                joki.1.move 0 -1
                joki.1.path.push ->
                    joki.1.face \left
        , 'No' ->
            @say \joki tl("Understandable.")
    joki.2?interact =!->
        if !switches.beat_nae
            say \joki tl("Smallpox should be in this cabin, but there's a problem.")
            say \joki tl("The person standing in front of the door. Do you recognize her?")
            say \joki tl("It's Naegleria, and it looks like she's gone mad.")
            say \joki tl("We have no choice but to put her down. I can't take her on my own though, not with this body.")
            if items.shinai.quantity<1
                say \joki tl("I left a kendo stick in one of the houses near the tower.")
            say \joki tl("If you're going to fight her, be careful.")
        else
            jokioverride ...

    pox?interact =!->
        if switches.pylonfixed
            say \pox \injured tl("Hurry on back to the tower. I'll be going there soon too.")
            return
        #say \pox \injured "Lloviu-nya, why are you here? What happened to Nae?"
        say \pox \injured tl("Lloviu-nya, what are you doing are you here?")
        say \llov tl("You're hurt! What happened?")
        say \pox \injured tl("I was trying to fix the pylon... when I was ambushed by an old friend.")
        say \pox tl("What happened to her anyway? Naeglera.")
        if switches.ate_nae
            say \llov tl("Nae-tan? Llov ate her.")
            say \pox \injured tl("You ate her? I hope you don't get a stomach ache.")
        else
            say \llov tl("Nae-tan is... Llov had no choice.")
            say \pox \injured tl("I see, that's unfortunate. She used to be such a good friend.")
        #say \llov "Joki said Smallpox can fix the pylon."
        #say \pox \injured "Ah yes, it was damaged wasn't it? Don't worry, I'll fix it."
        #say \pox \injured "After I fix it, I hope you don't mind if I borrow your bed. I could use some rest."
        say \pox \injured tl("Well, at least now I can get back to fixing the pylon.")
        say \pox \injured tl("After I'm done, I hope you won't mind if I borrow your bed. I need some time to recover.")
        say ->
            switches.checkpoint_map='hub'
            switches.checkpoint='nae'
            switches.lockportals=true
            setswitch \pylonfixed true

    if switches.map is \hub and not switches.slimes_everywhere
        scenario.slimes_everywhere!
        setswitch \slimes_everywhere true

    if switches.map is \hub and switches.beat_nae and not switches.beat_nae2
        scenario.beat_nae!
        setswitch \beat_nae2 true

scenario.slimes_everywhere =!->
    player.face_point mal
    mal.face \left
    say \mal tl("Lloviu! Don't come out, it's dangerous right now!")
    say -> mal.face \right

scenario.beat_nae =!->
    cinema_start!
    player.relocate \nae
    joki.2.move 0 4
    joki.2.move -5 0
    joki.2.path.push ->
        player.face_point joki.2
        say \joki tl("You beat her? Good. I knew you had it in you.")
        say \joki tl("You got a soul for beating her right? If you hang on to it, she can probably be saved.")
        say \joki tl("I'll let you decide what to do with it, we have more urgent matters at hand.")
        say ->
            cinema_stop!

scenario.states.pylonfixed =!->
    if switches.map is \hub
        joki.1.relocate \joki_bridge
        joki.1.y -= TS
        joki.1.cancel_movement!
        joki.1.face \left
        unless switches.pylonfixed>=2
            joki.2.relocate \pox_cabin
            joki.2.x+=TS; joki.2.y+=TS
            joki.2.cancel_movement!
            joki.2.face \left
            player.face \right
            say \joki tl("Good job, it looks like the pylon is already operational again.")
            say \llov tl("Llov wants to find Marburg-nee")
            say \joki tl("I took Marburg to the land of the dead by her request.")
            say \joki tl("You seem like you've recovered your strength. All right, I'll take you to her.")
            say \joki tl("Meet me back at the docks near the tower.")
            say -> setswitch \pylonfixed 2
        scenario.spawn_minion_bridge! if switches.confronting_joki
    if not switches.confronting_joki and switches.map is \hub
        bp.relocate \joki_bridge
        bp.y -= TS
        bp.x -= TS*3
        bp.cancel_movement!
    if switches.confronting_joki and switches.map is \hub
        joki.1.kill!
        Actor::relocate.call Doodad.boat, \boat2

    scenario.poxbed!

    pox?interact =!->
        say \pox \injured tl("Hurry on back to the tower. I'll be going there soon too.")

    jokioverride = joki.1?interact
    #joki.1?interact =!->
    #    if switches.map is \deadworld
    #        say \joki "Marburg is somewhere nearby. You want to find her right?"
    #        return

    joki.2?interact =!->
        if switches.map is \deadworld or marb in party
            jokioverride ...
            return
        if !switches.confronting_joki
            say \joki tl("Meet me back at the docks near the tower.")
            return
        unless switches.confronting_joki>=2
            say \joki tl("Sorry about that, it seems I was killed.")
            say \joki tl("I can still take you to Marburg if you want. Are you ready?")
            setswitch \confronting_joki 2
        else
            say \joki tl("You'll find Marburg in the land of the dead. Want me to take you there?")
        menu tl("Yes"), ->
            warp_node \deadworld \landing \up
            switches.warpzones=true
            switches.warp_deadworld=true
            switches.warp_hub2=true
            save!
        ,tl("No"), ->

    bp?interact =!->
        if marb in party
            if switches.bp_has_nae
                scenario.bp_nae_soul2!
                return
            if player is marb
                say \bp tl("Marburg, did you find what you're looking for?")
            else
                say \bp tl("I don't know how you slipped away, but Marburg doesn't seem angry so I suppose it's fine.")
                #say \bp "Thank goodness you're okay. If you were hurt Marburg would kill us."
            return
        if items.naesoul.quantity>0
            scenario.bp_nae_soul!
            if items.tunnel_key.quantity<1
                say \bp tl("By the way, Smallpox came by earlier. You should greet her.")
                say \bp tl("She's waiting for you in your house.")
            return
        if items.tunnel_key.quantity<1
            say \bp tl("Have you greeted Smallpox yet? She's waiting for you in your house.")
            return
        if !session.pylonfixedbp or Math.random!<0.7
            say \llov tl("Let Llov go to Marburg-nee.")
            say \bp tl("I'm keeping you here for your own good. Don't you understand?")
            say \llov tl("The one who doesn't understand is Plague-sama!")
            session.pylonfixedbp=true
            return
        say \bp tl("Please, just stay put until Marburg gets back.")
        say \llov tl("But... Llov wants to go help Marburg-nee.")
        say \bp tl("Why won't you understand?")

    mal?interact =!->
        if marb in party
            if player is marb
                say \mal tl("Marburg! You're back already?")
            else
                say \mal tl("Oh good, I see you found Marburg.")
            return
        unless switches.talktomal>=2
            if items.tunnel_key.quantity<1
                say \mal tl("Smallpox came by earlier. She's resting in your bed now.")
            say \mal tl("We really were worried about you, you know?")
            say \llov tl("Because you were told to protect Llov?")
            say \mal tl("Well, that's also true, but we're friends right? I'd protect you even if I wasn't ordered to.")
            #show llov determined
            say \llov tl("Then come with Llov.")
            say \mal tl("I don't know, that sounds dangerous. You should just do what Plague-sama tells you.")
            say -> 
                setswitch \talktomal 2
            return
        unless switches.talktomal>=3
            say \mal tl("You're really not going to listen to us are you? You always were so stubborn...")
            say tl("Since there's nothing I can do to stop you, at least take this.")
            say -> 
                acquire items.fan, 1 false true
                setswitch \talktomal 3
            return
        if items.tunnel_key.quantity<1
            say \mal tl("I think Smallpox wants to talk with you. She's inside here.")
        else
            say \mal tl("Please don't be reckless.")

scenario.tunneldoorlocked =!->
    say '' tl("The door is locked.")
    if switches.pylonfixed
        say \llov tl("Smallpox's maintenance tunnel...")
        say \llov tl("If Llov could get in here, then Llov could go where Marburg-nee is!")
        say \llov tl("Smallpox should be in Llov's bed right now.")
    player.move 0, 0.5
scenario.poxbed =!->
    if switches.map is \shack2
        doodads.llovbed.alpha=1
        doodads.llovbed.load-texture \poxsick
        doodads.llovbed.interact =!->
            doodads.llovbed.animations.frame=1
            if player is llov
                say \pox tl("Oh, Lloviu-nya. Thanks again for lending me your bed.")
            else
                say \pox tl("Don't mind me, I'll be recovered soon.")
            if not items.tunnel_key.quantity
                say \llov tl("Llov needs to find Joki-tan.")
                say \pox tl("Joki? Doesn't she just hang around everywhere? I think I saw one of her outside the cabin where you found me.")
                say \llov tl("The bridge is blocked, Llov can't get there.")
                say \pox tl("I guess you'll need to find another way then. Here, take this.")
                switches.lockportals=false
                acquire items.tunnel_key
                say \pox tl("This key opens up the maintenance tunnel. The entrance is in a building to the south. It should take you where you need to go.")
            say -> doodads.llovbed.animations.frame=0

scenario.spawn_minion_bridge =!->
    return if marb in party
    min = new_npc nodes.confronting_joki, \min
    min.x+=TS*2
    min.y+=TS
    min.cancel_movement!
    min.face \left
    min.interact=!->
        if player.x>@x
            sound.play \strike
            dood.revive!
            @kill!
            session.minionsplat=true
            return
        say \min tl("Order from Plague-sama. Bridge blockade.")
        say \llov tl("Please, let Llov through.")
        say \min tl("Cannot comply. Please speak with Plague-sama.")
    dood = new Doodad(min.x, min.y, \1x1 null false) |> carpet.add-child
    dood.kill!
    dood.frame=13
    dood.anchor.set 0.5, 1
    initUpdate dood
    if session.minionsplat
        dood.revive!
        min.kill!
    return min

scenario.confronting_joki =!->
    cinema_start!
    bp.move 2 0
    bp.path.push ->
        say \bp tl("What were you thinking? You could have got her killed!")
        say \joki tl("I only did what she wished.")
        say \bp tl("Marburg told us to keep her safe!")
        #say \joki "You're not really concerned for Lloviu's safety, you're just afraid or Marburg's wrath."
        say \joki tl("You do not fear for the girl's safety, you only fear Marburg's wrath.")
        say \bp tl("Enough of this. If you're going to get in our way, then you're not welcome here.")
        say ->
            switches.checkpoint_map=switches.checkpoint=\hub
            joki.1.waterwalking=true
            save!
            joki.1.load-texture \joki_fireball
            joki.1.add_simple_animation!
            #joki.1.animations.play \simple
            joki.1.setautoplay \simple 12
            joki.1.move 3 0
            joki.1.animations.currentAnim.onLoop.addOnce (->
                @kill!
                bp.move -3 0
                bp.path.push ->
                    min=scenario.spawn_minion_bridge!
                    Dust.summon(min.x,min.y)
                    cinema_stop!
            ), joki.1

scenario.states.returnfromdeadworld =!->
    scenario.poxbed!

    if switches.map is \deadworld
        if switches.progress2 is 9
            say '' tl("Cure-chan's soul escaped into the distance.")
            say \marb tl("We got the skull, let's deliver it to Ebola-chan.")
            say tl("She's waiting for us in the Black Tower.")
            switches.warp_hub1=true
            switches.warp_curecamp=true
            setswitch \progress2 10

    bp?interact =!->
        say \bp tl("I see you found what you were looking for. Ebola-chan is probably waiting for you.")

    mal?interact =!->
        say \mal tl("You're going into the tower?")
        say tl("I know the tower is what gives us energy, but still... It's kind of spooky.")

    Actor.wraith?interact =!->
        say \wraith tl("The tower is off-limits. Ebola-chan is not taking visitors at the moment.")
        say \marb tl("We have important business with Ebola-chan. Let us through.")
        say \wraith tl("Hostility detected. Cannot comply.")
        say \llov tl("Please mister wraith, this skull is important to Ebola-chan. Let us deliver it.")
        say \wraith tl("Hostility detected. Cannot comply.")
        say \marb tl("The damn creature must be broken. I don't think it'll listen to reason, we're going to have to force our way in.")
        say ->
            start_battle encounter.wraith_door

    if switches.map is \towertop and switches.progress is \zmappbattle
        dood = new Doodad(nodes.down.x+HTS, nodes.down.y+TS, \flameg null true) |> actors.add-child
        dood.anchor.set 0.5 1.0
        dood.simple_animation 7
        dood.random_frame!
        updatelist.push dood
        zmapp?interact=!->
            switch switches.zmapp
            | -1 => say \zmapp tl("Still haven't had enough?")
            default => say \zmapp tl("Stay down.")
            say -> start_battle encounter.zmapp
        for node in [nodes.wraith1, nodes.wraith2, nodes.wraith3, nodes.wraith4]
            w = new NPC node.x, node.y, \wraith
            w.setautoplay \down
            w.interact =!->
                say \wraith tl("Care for a battle?")
                menu \Yes -> start_battle encounter.wraith
                ,\No ->
    ebby?interact=scenario.ebbytower1

scenario.states.zmappbeat =!->
    setTimeout !->
        cinema_start!
        camera_center zmapp.x, zmapp.y

        for p,i in party
            p.y=zmapp.y - TS*3
            p.x=zmapp.x + (i+1)%3*TS - TS
            p.face_point zmapp
            #p.revive!
            #p.stats.hp=1
    , 1
    if switches.zmapp is \victory
        say \zmapp tl("You may have defeated me, but it's too late.")
    else
        say \zmapp tl("Pathetic. Is that really all the power you can muster?")
        say tl("Oh well, it doesn't really matter.")
    say \zmapp tl("I've already destabilized the soul cluster.")
    say !-> cg.show 'cg_tower0', !-> Transition.timeout 1000, !->
        #TODO: remove this line once water boots are in
        #switches.water_walking=true
        #
        cg.showfast 'cg_tower1'
        switches.soulcluster=false
        switches.progress2=16
        setswitch \progress \towerfall
        sound.play \boom
        Transition.shake 8 50 1000 0.95 !->
            cg.showfast 'cg_tower2'
            for f in Doodad.list
                newkey=fringe_swap f.key
                if f.key isnt newkey
                    oldframe=f.frame
                    f.load-texture newkey
                    f.frame=oldframe
            tile_swap!
            Transition.timeout 1000, !-> cg.hide !->
                say \zmapp tl("Ah, that feels better.")
                say \ebby \concern tl("No way! She stole all the human souls!")
                say \marb \angry tl("That bitch! She won't get away with this!")
                say \zmapp tl("Now that I have what I came for, I'll be on my way. I have grand designs to fulfill.")
                #say \zmapp "Sayonara!"
                say ->
                    Dust.summon zmapp.x, zmapp.y
                    zmapp.kill!
                    Transition.timeout 1000, ->
                        say \marb \troubled tl("She got away!")
                        say \ebby \concern tl("They're so far away now. I can hear them calling for me.")
                        say \marb tl("Don't worry, we'll get them back.")
                        say \llov tl("That's right! Zmapp is a bully. When we find her we'll beat her up!")
                        say \marb tl("Do you know where she went?")
                        say \ebby \concern tl("She only absorbed a fraction of the souls. Most of them escaped from her.")
                        say \marb tl("We'll get those ones first. I'm sure Joki can take us where they landed.")
                        #say '' "This is the end of the demo. Thanks for playing!"
                        #say '' "By the way, you can walk in water now."
                        
                        say ->
                            cinema_stop!
                            scenario.soulcluster!
                    ,true
                
        ,false


scenario.bp_nae_soul =!->
    say \bp tl("What is that? A soul?")
    say \llov tl("It came out from Nae-tan")
    say \bp tl("Give it here. You have no business handling something so dangerous.")
    menu tl("Give her the soul"), ->
        items.naesoul.quantity=0
        #save!
        setswitch \bp_has_nae true
        @say \bp tl("Good. Now stay away from dangerous things from now on.")
    , tl("Do not"), ->
        @say \bp tl("...")

scenario.bp_nae_soul2 =!->
    say \bp tl("Marburg, there you are.")
    say \bp tl("I took this from Llov earlier, but I don't have any use for it.")
    say \bp tl("I think you should decide what to do with it.")
    switches.bp_has_nae=false
    acquire items.naesoul
    if llov in party
        say \marb tl("Is this Naegleria? Where did you find this?")
        say \llov tl("It came out of Nae-tan...")
        say \bp tl("From what I hear, Naegleria was taken by the madness.")
    else
        say \marb tl("Is this Naegleria? I wonder where she got it from.")
        say \bp tl("From what I hear, Naegleria was taken by the madness. Llov is the one who stopped her.")
    say \marb tl("The madness... How unsettling.")
 
scenario.ebbytower1 =!->
    ebby.face \down
    #say \ebby "!"
    say \ebby tl("Lloviu-tan, Marburg-nee! What a surprise!")
    say \ebby tl("What brings you here? Just visiting?")
    say \llov tl("We're here on a delivery!")
    say \ebby tl("A delivery? What did you bring?")
    say \marb \smile tl("Something lost. Can you guess what it is?")
    say \ebby \smile tl("Hold on, yes! I can sense it!")
    say \ebby tl("It's {0}! You brought {0} back to me!",switches.name)
    say ->
        items.humanskull.quantity=0
        acquire items.humanskull2, 1, true, true
    say '' tl("Marburg gave the human skull back to Ebola-chan.")
    say \ebby \smile tl("Oh, thank you so much! I love both of you!")
    #say \llov \smile "Yay! Llov loves Ebola-chan too!"
    say \marb \smile tl("Ebola-chan just isn't complete without her signature skull, isn't that right?")
    say \ebby tl("I missed you so much, {0}! Cure-chan didn't do anything strange to you did she?",switches.name)
    say \ebby \concern tl("Hold on, something's not right.")
    say ->
        #stop the music
        music.fadeOut 1000
    say \ebby tl("What's that inside you?")
    #Zmapp comes out
    say ->
        #switches.ebbytower0=false
        cinema_start!
        z = new Phaser.Sprite game, ebby.x, ebby.y, \z, 0 |> fringe.add-child
        z.animations.add \simple, null, 7, true
        z.animations.play \simple
        z.anchor.set(0.5,0.5)
        z.sx=z.x; z.sy=z.y; z.time=Date.now!
        updatelist.push z
        z.update=!->
            i=(Date.now! - @time)/2000 <? 1
            @x=@sx + game.math.bezierInterpolation([0,-128,0],i)
            @y=@sy + game.math.bezierInterpolation([0,-128,0,64],i)
            game.camera.center.x = @x; game.camera.center.y = @y
            if i is 1
                @update=!->
                @load-texture \zburst
                z.animations.add \simple, null, 7, false
                z.animations.play \simple
                z.animations.currentAnim.onComplete.add !->
                    z.update-paused=!-> @destroy!; updatelist.remove @
                    scenario.ebbytower2!
                zmapp := new NPC z.x, z.y+HTS, \zmapp
                zmapp.face \up
                for p in players
                    p.face_point zmapp
scenario.ebbytower2 =!->
    say \zmapp tl("Surprise!")
    say \zmapp tl("A trojan horse. Pretty ironic right?")
    say \ebby \shock tl("Zmapp!? You're still alive?")
    say \zmapp tl("This tower belongs to me now. All the human souls here too!")
    say ->
        switches.checkpoint_map=switches.map
        switches.checkpoint=\cp
        switches.zmapp=0
        join_party \ebby save:false front:true startlevel:26
        equip_item items.humanskull2, ebby, true
        switches.progress=\zmappbattle
        switches.lockportals=true
        #cinema_stop!
        start_battle encounter.zmapp

scenario.soulcluster =!->
    return unless switches.map is \towertop and !switches.soulcluster and switches.progress2>=16
    dood = new Doodad(nodes.zmapp.x+TS, nodes.zmapp.y+TS+TS, \flame null true) |> actors.add-child
    dood.anchor.set 0.5 1.0
    dood.simple_animation 7
    updatelist.push dood
    dood.interact =!->
        if items.humansoul.quantity<1000000
            say '' tl("1 million souls required to rekindle the soul cluster.")
        else
            items.humansoul.quantity -= 1000000
            switches.llovsick1=4 if switches.llovsick1>0
            switches.soulcluster=true
            cg.show 'cg_tower2', !-> Transition.timeout 1000, !->
                cg.fade 'cg_tower0', !->
                    schedule_teleport pmap:switches.map
                    Transition.timeout 1000, !-> cg.hide !->
                        say '' tl("The soul cluster bursts back to life, illuminating the river.")
                        scenario.delta_finished2!

scenario.talk_pest =!->
    cg.show (if switches.soulcluster then \cg_pest else \cg_pest_night), ->
        revivalmenu=true
        if switches.progress2 < 23
            say \pest tl("It's been a long time. It's good to see you again.")
            say \pest tl("As you can see, I'm not in the best of shapes. But you seem well enough.")
            say \pest tl("Since you're here, maybe you can help me with something.")
            #say \pest "The viruses in this land are afflicted with madness."
            say \pest tl("The viruses in this land have fallen into madness.")
            say \pest tl("They have lost themselves. I can help them, but you must bring them to me.")
            say \pest tl("If they won't cooperate, just bringing their souls should be enough. I can reconstitute them.")
            say \pest tl("One more thing.")
            #say \pest "If nothing is done soon, the madness will take them completely."
            say \pest tl("You cannot travel this region by land. There are no bridges to connect many of the islands.")
            say \pest tl("You must speak to Joki. She can properly equip you.")
            say ->
                setswitch \progress2 23
            #return
        else if switches.progress2<24
            say \pest tl("You must speak to Joki. She can properly equip you.")
            #return
        else if switches.llovsick and llov not in party and switches.llovsick1 is true
            say \pest tl("Where is miss Llov? Wasn't she with you?")
            revivalmenu=false
        else if switches.llovsick1 is 2
            session.pestypleasehelpllov=1;
            say \ebby \concern tl("Llov is sick. Please, can you help her?")
            say \pest tl("It's probably just malnourishment.")
            say \pest tl("If you provide me with human souls, I can extract the energy from them and feed it to her.")
            say \pest tl("1000 souls should be enough. That would sustain her for quite a while.")
            if items.humansoul.quantity >= 1000
                menu tl("Feed her 1000 souls"), scenario.llovsick2
                ,tl("Do not"), !->
            revivalmenu=false
        else if switches.llovsick1 is 3
            scenario.llovsick3!
            revivalmenu=false
        else if switches.llovsick1 is 4 and !session.mourning and switches.progress is \towerfall
            scenario.llovsick4!
            revivalmenu=false
            session.mourning=true
        else if switches.ate_sars or switches.ate_rabies or switches.ate_eidzu
            say \pest tl("I asked you to help me save them, and you ate them instead.")
            say \pest tl("If I didn't know better, I would think you were going mad too.")
        else if switches.revivalsars and switches.revivalsars and switches.revivalrab and !items.pest.quantity
            say \pest tl("You've done what I asked. I think you deserve a reward.")
            acquire items.pest, 1
            say \pest tl("This is my sword. Take good care of it.")
        else if switches.llovsick1 is 4
            say \pest tl("I can only revive someone if I have their soul.")
        else if switches.beat_sars and switches.beat_rab and switches.beat_aids
            say \pest tl("Thank you for helping me with this task.")
        else
            say \pest tl("The viruses in this land have fallen into madness.")
            #say \pest "The viruses in this land are afflicted with madness."
            say \pest tl("They have lost themselves. I can help them, but you must bring them to me.")
            say \pest tl("If they won't cooperate, just bringing their souls should be enough. I can reconstitute them.")
            #return
        if revivalmenu
            if items.naesoul.quantity>0 and switches.beat_nae2 isnt 2
                #session.naesoul=true
                switches.beat_nae2=2
                say tl("What's this? You already have a soul with you. Is that Naegleria?")
            souls=[]
            souls.push items.llovsoul if items.llovsoul.quantity
            souls.push items.naesoul if items.naesoul.quantity
            souls.push items.sarssoul if items.sarssoul.quantity
            souls.push items.aidssoul if items.aidssoul.quantity
            souls.push items.rabiessoul if items.rabiessoul.quantity
            souls.push items.chikunsoul if items.chikunsoul.quantity
            if souls.length>0 and not nodes.revival.occupied
                say \pest tl("Should I revive someone?")
                menuset=[tl("Cancel"), ->]
                for soul in souls then menuset.push soul.soulname, callback:revivesoul, arguments:[soul]
                menu.apply null, menuset
        #say \pest "I won't lie to you, I am dying."
        #say \pest "Ah, Ebola-chan-tachi. I'm glad to see you're still yourselves."
        #say "The viruses in this land have fallen into madness."
        #say "I'm not sure what's causing it, but I suspect they've been vaccinated."
        #say "It's sad, but they must be destroyed. Don't worry though, they can still be saved."
        #say "If you bring them to me then I can reconstitute them. If they won't come, then bringing their souls will also work."
        #say "If you bring me their souls, we can probably reconstitute them."
        say ->
            cg.hide temp.oncghide
            delete! temp.oncghide if temp.oncghide
            player.move(0,0.5)
    !function revivesoul soul 
        soul.quantity = 0
        switch soul
        |items.naesoul
            @say !->
                setswitch \revivalnae true
                nae := node_npc(nodes.revival,'naegleria',2)
                nae.setautoplay('down')
                nae.interact =!->
                    say \nae tl("It feels good to be myself again. Thank you.")
                    say \nae tl("I'll be around, if you need me.")
                    say warp
        |items.sarssoul
            @say !->
                setswitch \revivalsars true
                sars.relocate \revival
                sars.interact=!->
                    #say \sars "Onee-sama! Please forgive my earlier rudeness, I just wasn't myself."
                    #say \marb "Who are you calling \"Onee-sama\"? I only have two sisters, little bug."
                    #say \sars "Ahn~ Your cold words cut like swords in my heart, Onee-sama!"
                    say \sars tl("I'm sorry for my rudeness earlier. You know I treasure your friendship more than anything.")
                    if switches.revivalaids
                        say \marb tl("That's strange. The other ones changed after they were reconstituted, but this one looks the same.")
                        say \sars tl("I did change! I'm 1cm taller now! I swear!")
                    say warp
        |items.aidssoul
            @say \pest tl("Their souls have become entangled. It might be difficult to separate them...")
            @say tl("Oh well, I'm sure it will be fine.")
            @say !->
                setswitch \revivalaids true
                #aids.1.relocate nodes.revival.x, nodes.revival.y+TS
                #aids.2.relocate nodes.revival.x+TS, nodes.revival.y+TS
                aids.0 = node_npc(nodes.revival,'aids3')
                aids.0.interact=!->
                    say \aids1 \fused tl("Onee-chan and I are stuck together. What happened?")
                    say \aids2 \fused tl("Don't worry, this just means we'll be together forever.")
                    say \aids1 \fused tl("Onee-chan... I think I could get used to this.")
                    say warp
        |items.rabiessoul
            @say !->
                setswitch \revivalrab true
                rab.relocate \revival
                rab.interact=!->
                    say \rab \young tl("I do know what Pestilence did, but it worked wonders. I feel so young!")
                    say tl("Most of my clothes don't seem to fit any more though. Did I lose weight?")
                    say tl("Here, you can have this.")
                    acquire items.torndress, 1
                    say \rab \young tl("Now if you'll excuse me, I'm going to find something to eat.")
                    say warp
        |items.chikunsoul
            @say !->
                setswitch \revivalchikun true
                chikun=node_npc(nodes.revival,'chikun')
                chikun.interact=!->
                    say \chikun tl("Resurrecting me was a mistake, you know.")
                    say \chikun tl("Do you think I only killed them because I was mad?")
                    say \chikun tl("No, I willingly fell into madness.")
                    say \chikun tl("You should hope that we never meet again.")
                    acquire items.soulshard, 2
                    say warp
        |items.llovsoul
            @say scenario.revivalllov
        nodes.revival.occupied=true
        @say \pest tl("It's done. {0} has been reconstituted. You should speak with her.",soul.soulname)
        @say save

scenario.revivalllov =!->
    switches.llovsick=false
    switches.llovsick1=0
    switches.revivalllov=true
    #llov.relocate nodes.revival
    llov.relocate \llovsick
    llov.face \down
    llov.interact=!->
        say \marb \smile tl("Welcome back to the team, little sister.")
        say \llov \smile tl("Llov is feeling great now! Pesty really knows how to treat a lady.")
        say -> join_party \llov save:true front:false # startlevel:10

scenario.states.towerfall =!->

    for j in joki then if j then j.interact=!->
        if switches.llovsick1 is -1 and switches.beat_sars and switches.beat_rab and switches.beat_aids and switches.map isnt \hub
            say \joki tl("Something terrible has happened. You should see.")
            say ->
                setswitch \llovsick1 -2
                warp_node \hub \landing
            return
        else if switches.llovsick1 is true and llov not in party
            say \joki tl("Lloviu isn't with you. You should speak with her.")
            return
        else if switches.progress2<21 and switches.map is \hub
            say \ebby \concern tl("Joki, the soul cluster was scattered. We need to get the souls back!")
            say \joki tl("Yes, I saw where they landed. I will take you there.")
            say ->
                warp_node \delta \landing
                switches.warp_delta=true
                setswitch \progress2 21
            return
        else if switches.progress2 is 23
            say \joki tl("Pesty told me to give you something? Yeah, I got the memo.")
            acquire items.jokicharm, 1, false, true
            acquire items.riverfilter, 1, false, true
            switches.water_walking=true
            switches.progress2=24
            say ->
                save!
            say \joki tl("Try not to drown in the river.")
        else joki_interact ...

    if switches.revivalnae and switches.map is \delta
        nae := node_npc(nodes.nae,'naegleria',2)
        nae.setautoplay('down')
        nae.interact =!->
            if llov not in party
                say \nae tl("Where has Lloviu-tan gone? Are you not travelling together any more?")
            else
                say \nae tl("It's good to see you. Thanks again for saving me.")
            say \nae tl("Why don't we have a friendly little battle, what do you say?")
            menu tl("Yes"), -> start_battle encounter.naegleria_r
            ,tl("No"), ->
    if switches.revivalrab and switches.map is \delta
        rab.relocate \rab2
        rab.interact =!->
            say \rab \young tl("I don't know why, but Herpes-chan has been hanging around me a lot more than usual lately.")
            say tl("She's also given me a lot of sweet discounts, so I'm not complaining.")
    if switches.revivalsars and switches.map is \delta
        sars.relocate \sars2
        sars.interact =!->
            if ebby.equip is items.humanskull2
                say \sars tl("Ebola-chan are you still carrying that skull around?")
                say tl("You know, I never did like {0}.",switches.name)
            else
                say \sars tl("Marburg-sama, please make me one of your sisters.")
    if switches.revivalaids and switches.map is \delta
        aids.0 = node_npc(nodes.aids3,'aids3')
        aids.0.interact=!->
            say \aids1 \fused tl("If conjoined twins have sex, is it incest or masturbation?")
            say \aids2 \fused tl("Does it matter?")

    if switches.llovsick1 is true
        switches.llovsick1=2
    if switches.map is \delta
        if switches.llovsick1 is 4
            temp.deadllov=create_prop nodes.llovsick, \deadllov
            temp.deadllov.interact=!->
                say '' tl("Her soul is missing.")
        else if switches.llovsick1>1
            llov.relocate \llovsick
            llov.interact=!->
                say \llov \sick tl("Uuu...")
                if !session.pestypleasehelpllov
                    say \ebby \concern tl("Llov is sick Marburg. What should we do?")
                    say \marb \troubled tl("I'm sure Pestilence can help us.")
                else
                    say '' tl("Lloviu-tan's condition shows no sign of improvement.")

    if switches.map is \hub and switches.llovsick1 is -2
        temp.deadmal=create_prop nodes.bp, \deadmal
        temp.deadpox=create_prop nodes.mob2, \deadpox
        temp.deadmal.interact=temp.deadpox.interact=!->
            say '', tl("Her soul is missing.")
        if !switches.beat_chikun
            chikun = new NPC nodes.chikun.x+HTS, nodes.chikun.y+TS, \mob_chikun, 7
            chikun.update=!->
                @frame= if Math.random!<0.9 then 0 else Math.random!*4.|.0
            chikun.battle=encounter.chikun

    if (switches.beat_sars or switches.beat_rab or switches.beat_aids) and !switches.llovsick1
    and switches.ate_nae isnt true and switches.ate_nae isnt \llov
    and switches.ate_eidzu isnt \llov and switches.ate_sars isnt \llov and switches.ate_rabies isnt \llov
        switches.llovsick=true
    if switches.beat_sars and switches.beat_rab and switches.beat_aids and !switches.delta_finished
        scenario.delta_finished!

    if switches.delta_finished>1
        switches.warp_earth=true
    /*
    if switches.map is \delta and switches.progress2<22
        say \joki "Here we are. We should be pretty close to where the souls landed."
        say \joki "By the way, you should take these. You won't get very far without them."
        acquire items.jokicharm, 1, false, true
        acquire items.riverfilter, 1, false, true
        switches.water_walking=true
        switches.progress2=22
        say ->
            save!
        say \joki "Try not to drown in the river."
    */

    if switches.map is \labhall or switches.map is \labdungeon
        #music.fadeOut 2000
        scenario.labhall!
    #if switches.map is \lab
    #    music.fadeOut 2000
    scenario.states.towerfall_earth!

scenario.delta_finished=!->
    if switches.llovsick and !switches.llovsick1
        switches.lockportals=true
        switches.checkpoint_map=\delta
        switches.checkpoint=\cp1
    setswitch \delta_finished true
    say \ebby tl("We've collected all of the souls in this area.")
    if switches.llovsick1>0
        say \ebby tl("We need to rekindle the soul cluster, and we need to save Llov. But we only have enough souls to do one of those right now.")
    else if switches.llovsick1<0 and items.humansoul.quantity<1000000
        scenario.delta_finished2!
    else
        say \ebby tl("We have enough souls to rekindle the soul cluster now. We should return to the tower.")
scenario.delta_finished2=!->
    return if switches.delta_finished>1
    switches.delta_finished=2
    say \marb tl("Where to next?")
    say \ebby tl("Zmapp is on Earth. She has many souls with her.")
    say \marb tl("Then we're going to Earth. Joki can take us there.")
    #say '' "This is the end of Demo 2!"
    #if switches.llovsick1 is -1 or switches.llovsick1 is 4
    #    say '' "...Or is it?"
    switches.warp_earth=true
    setswitch \progress2 30

scenario.towerfall_bp =!->
    setswitch \lockportals false
    cinema_start!
    bp.move 4,-2
    bp.path.push ->
        for p in party
            p.face_point bp
        bp.face \up
        say \bp tl("What happened? Why is the tower dark?")
        say \ebby \concern tl("The light was stolen.")
        say \bp tl("What about the energy that used to flow from the tower?")
        say \ebby \concern tl("It won't flow any more.")
        say \bp tl("...")
        say \bp tl("I see. Then I don't have any reason to stay here.")
        say \bp tl("I'm going to search for a more sustainable source of energy.")
        say \llov tl("Plese wait, We'll restore the tower! We're going to find the souls right now!")
        #say \llov "We'll restore the tower though! We're going to get the souls back now!"
        say \bp tl("It doesn't matter, I'd been meaning to leave anyway. The tower was never sustainable in the first place.")
        #bp starts to walk away.
        say ->
            bp.move 6, 0
            bp.path.push ->
                bp.face \upright
                mal.face \downleft
                #camera_center bp.x, bp.y
                say \bp tl("Malaria, come with me.")
                say \mal tl("Well...")
                say \bp tl("What's wrong, aren't you coming?")
                say \mal tl("I think I'm going to wait here. The sisters will restore the tower, I have faith in them.")
                say \bp tl("...")
                say \bp tl("Suit yourself.")
                say ->
                    bp.move 7, 3
                    bp.path.push ->
                        Dust.summon bp
                        bp.kill!
                        cinema_stop!
        #bp leaves.

scenario.llovsick1 =!->
    #after beating the first boss in the delta, when approaching Pestilence,
    #llov stops following, because she's become sick again.
    switches.lockportals=false
    leave_party llov
    llov.interact=!->
        if player is ebby
            say \ebby \concern tl("Llov? What's wrong?")
        else
            say \marb \troubled tl("Llov? What's wrong?")
        say \llov \sick tl("Llov... Doesn't feel very well.")
        say \marb \troubled tl("It must be her sickness. I thought she was better.")
        say \ebby \concern tl("We should take her to Pestilence. He'll know what to do.")
        say ->
            switches.llovsick1=2
            warp_node \delta \revival
            temp.callback=!->
                player.move(-1,-2)

scenario.llovsick2 =!->
    items.humansoul.quantity -= 1000
    @say \pest tl("All right, I'll extract the energy from the souls and feed it to Lloviu-tan.")
    @say \pest tl("...")
    @say \pest tl("This is rather... Unexpected.")
    @say \ebby \concern tl("What's the matter?")
    #say \pest "She's malnourished. She needs energy. It's simple, 1000 souls should be plenty."
    @say \pest tl("Something is wrong. I can't heal her. Something is blocking me, some kind of barrier.")
    @say \pest tl("I'm afraid it will take a lot more energy to break the barrier.")
    #say \pest "It will take many more souls than I thought. 1 million, at the least."
    @say \pest tl("It will take 1 million souls.")
    @say \ebby \concern tl("That's so many...")
    @say \pest tl("There is an alternative. Not all souls are equal. A strong soul, such as the soul from a virus. That would also work.")
    if switches.ate_nae isnt \ebby and switches.ate_rabies isnt \ebby and switches.ate_sars isnt \ebby and switches.ate_eidzu isnt \ebby
        @say \ebby \concern tl("But that's terrible...")
        @say \pest tl("I'm sorry, it's the only way I know to save her.")
    @say ->
        switches.llovsick1=3
    if items.humansoul.quantity>=1000000
        scenario.llovsick3.call @

scenario.llovsick3 =!->
    s= if this instanceof Menu then @say else say
    souls=[]
    souls.push items.naesoul if items.naesoul.quantity
    souls.push items.sarssoul if items.sarssoul.quantity
    souls.push items.aidssoul if items.aidssoul.quantity
    souls.push items.rabiessoul if items.rabiessoul.quantity
    if souls.length>0 or items.humansoul.quantity>=1000000 or starmium_unlocked!
        s.call @, \pest tl("Which cost should be paid to save Lloviu?")
        menuset=[\Cancel ->]
        if items.humansoul.quantity>=1000000 then menuset.push tl("1 million human souls"), !->
            items.humansoul.quantity -= 1000000
            scenario.llovheal.call @
        else menuset.push tl("1 million human souls"), 0
        for soul in souls then menuset.push soul.soulname, callback:scenario.llovheal, arguments:[soul]
        if starmium_unlocked!
            menuset.push tl("50 Starmium Shards"),if items.starmium.quantity>=50 then !->
                @say \ebby tl("Will this work?")
                @say \pest tl("Shimmering fragments of a star? I've never seen anything like them. They seem to exude an extradimensional energy.")
                @say \pest tl("Yes, I think I can make it work.")
                items.starmium.quantity -= 50
                scenario.llovheal.call @
            else 0
        menu.apply @, menuset

scenario.llovheal =(soul)!->
    if soul
        soul.quantity = 0
    join_party \llov
    switches.llovsick=false
    switches.llovsick1=-1
    switches.llovsick1=-3 if soul
    save!
    @say \pest tl("It's done. The cost was great, but Lloviu's soul was healed.")
    #if switches.beat_aids and switches.beat_rab and switches.beat_sars
    #    temp.oncghide = scenario.llovheal2
    temp.oncghide = scenario.llovheal2
scenario.llovheal2 =!->
    cinema_start!
    for p in party
        continue if p is player
        p.update_follow_behind!
    setTimeout !->
        cinema_stop!
        for p in party
            if p is llov
                llov.face_point player
            else
                p.face_point llov
        say \marb \smile tl("Welcome back to the team, little sister.")
        say \llov \smile tl("Llov is feeling great now! Pesty really knows how to treat a lady.")
        #scenario.delta_finished2!
        if switches.beat_aids and switches.beat_rab and switches.beat_sars
            scenario.delta_finished!
    , 1000
    
scenario.llovsick4 =!->
    #after llov dies
    say \ebby \cry tl("Llov isn't moving! Pestilence, please! Please save her!")
    #say \marb \pain "..."
    say \pest tl("There's nothing I can do.")
    #say \pest "I'm afraid there's nothing I can do. Her soul has alredy left her body."
    say \pest tl("I'm sorry.")
    say \marb \grief tl("This can't be real.")

scenario.pc =(skipwelcome)!->
    # TODO think of 2 new puzzles.
    # 1st puzzle is computer based, to open the 4 surrounding doors
    # 2nd puzzle is described in the written logs, to open one of the final doors

    say '' tl("Booting up interface. Welcome to Last Hope.") unless skipwelcome
    if !switches.mainpass # Passcode hasn't been entered
        #say '' tl("Enter Mainframe Password.")
        textentry 140, tl("Enter Mainframe Password."),(m)!->
            if unifywidth(m) ~= '38014'
                #setswitch \finaldoor true
                setswitch \mainpass true
                #sound.play \door
                #doodads.finaldoor.frame=5
                #doodads.finaldoor.body.enable=false
                scenario.pc true
            else
                say '' tl("Wrong password.")
                say \ebby tl("We should explore some more to find the password.")
                session.wrongpass=true
        return
    # Passcode has been entered
    say '' tl("Please select an option.")
    doorlist=
        *switch:'door0',display:tl("Entry Door")
        *switch:'door_sw',display:tl("Southwest Door")
        *switch:'door_se',display:tl("Southeast Door")
        *switch:'door_nw',display:tl("Northwest Door")
        *switch:'door_ne',display:tl("Northeast Door")
    for door, i in doorlist by -1
        if switches[door.switch] or switches.doorswitch is door.switch then doorlist.splice(i,1)
    menuset =
        tl("Digital Logs"),!->
            @menu tl("Entry 1"),!->
                @say '' tl("\"To protect the facility, a mult-level security system is being phased in.\"")
                @say '' tl("\"With one of the new lock systems, DNA from one of the lab employees will be needed to open certain doors.\"")
            ,tl("Entry 2"),!->
                @say '' tl("\"There are hidden switches in the morgue drawers. They must be opened in a particular order unlock the doors.\"")
                @say '' tl("\"These new security systems are very impractical.\"")
            ,tl("Entry 3"),!->
                @say '' tl("\"Sally broke out of containment again. She's very violent and destructive.\"")
                @say '' tl("\"A mixture of chitin and silver seems to form an effective deterrent. It makes recovery a lot easier.\"")
            ,tl("Entry 4"),!->
                @say '' tl("\"The new infected blood samples are ready for analysis.\"")
                @say '' tl("\"Remember that civilian blood is marked with a white band, while employee blood is marked with a black band.\"")
            ,tl("Entry 5"),!->
                @say '' tl("\"The winged ones have taken an interest in this lab. I don't think anyone is left who can't see them.\"")
                @say '' tl("\"Some of my comrades have cast aside their humanity to go with them, but not I.\"")
                @say '' tl("\"When I die, it will be as a human.\"")
        tl("Exit"),!->
    if !switches.beat_game then menuset.unshift(tl("Door Controller"),!->
        menuset=
            tl("Cancel"),!->
            ...
        for door in doorlist by -1
            menuset.unshift door.display, arguments:[door], callback:(door)!->
                for a in actors.children
                    continue unless a.properties and a.properties.doorcontroller
                    a.frame=4
                    a.body.enable=true
                    if door.switch is a.properties.open
                        door.object = a
                if !door.object then console.warn("Warning! Door #{door.switch} wasn't found :(")
                sound.play \door
                door.object.frame=5
                door.object.body.enable=false
                #setswitch door.switch, true
                setswitch \doorswitch, door.switch
                say '' tl("{0} was opened.",door.display)
        @menu.apply @, menuset
    )
    menu.apply @, menuset

scenario.labdoormessage =!->
    say '' tl("To open the door, enter the passcode into the nearby terminal.")

scenario.enterlab =!->
    return if switches.enterlab
    zmapp.relocate \zmapp_gate
    cure.relocate \cure_gate
    #party walks up to door so cure and zmapp can be seen
    cinema_start!
    player.move 0, -11
    Transition.pan x: player.x, y: player.y - TS*11, 2000
    for i from 1 til party.length
        party[i].move i*2-3, -10.5
    player.path.push !->
        say \ebby \smile tl("Little pig, little pig, let us in.")
        say \cure tl("Hey Zmapp, it looks like someone is at our door.")
        say \zmapp tl("It's fine, they'll never get in. The only person besides us who knows the password is dead.")
        say \cure tl("You hear that intruders? You'll never find the password hidden in the graveyard.")
        say \cure tl("And you'll never be able to solve the series of puzzles waiting for you in here.")
        say !->
            setswitch \enterlab true
            say cinema_stop
            cure.move 0, -11
            zmapp.move 0, -11
            cure.path.push !->
                Dust.summon cure
                cure.relocate \cure
                cure.face \down
            zmapp.path.push !->
                Dust.summon zmapp
                zmapp.relocate \zmapp
                zmapp.face \down
    #introduce the dungeon

scenario.labhall =!->
    if !switches.enterlab
        return scenario.enterlab!
    return if switches.curefate
    if switches.progress2>31
        return scenario.curefate!

scenario.finale =!->
    return if switches.curefate
    #say \cure "Come on Zmapp, you have all that soul power. Break this cow curse already!"
    #say \zmapp "I don't think I will. The cow suit looks rather nice on you."
    #say \cure "Y-You really think so?"
    #The two notice the players
    /*
    cure.interact=!->
        say \cure "It's useless. There's nothing you can do to stop us now."
        say \cure "Face your fate. You will be cured."
    zmapp.interact=!->
        say \zmapp "I was created to destroy you. It's my destiny."
        if switches.zmapp isnt \defeat
            say \zmapp "But I can't beat you in a fair fight."
    */
    /*
    if switches.progress2 is 31
        who = new NPC nodes.who.x+HTS, nodes.who.y+TS, \who
        who.setautoplay \down
        who.battle=encounter.who
        dood = new Doodad(nodes.lab.x+HTS, nodes.lab.y+TS, \flameg null true) |> actors.add-child
        dood.anchor.set 0.5 1.0
        dood.simple_animation 7
        dood.random_frame!
        updatelist.push dood
        return
    */
    cinema_start!
    /*
    setTimeout ->
        for p,i in party
            continue if i is 0
            p.x -= (i-1.5)*2*TS
        camera_center(player.x,player.y - TS*2)
    ,0
    */
    music.fadeOut 2000
    Transition.pan(x:nodes.who.x+HTS, y:nodes.who.y+TS*3,1000,null,null,false)
    if switches.progress2 isnt 31
        say \zmapp tl("Look who finally showed up! It took you long enough.")
        say \cure tl("They're always so slow, let me tell you.")
        say \zmapp tl("You're just in time to witness our ultimate plan come to fruition.")
        say \cure tl("Oh! Let me tell them about the plan!")
        say \cure tl("You see, we're going to cure all of you!")
        say \cure tl("Every single disease that has ever existed. All cured!")
        say \zmapp tl("It's more than that. We're creating a new breed of human.")
        say \zmapp tl("One that is immune to all disease!")
        say \zmapp tl("All the energy that you need to live will be ours, and you can't have any of it!")
        say \cure tl("I think it's time we introduce them to our boss.")
        say \zmapp tl("We just finished working on her. Those souls of yours were the final ingredient.")
    say ->
        dood = new Doodad(nodes.who.x+HTS, nodes.who.y+TS, \bloodpool null false) |> carpet.add-child
        dood.anchor.set 0.5 0.5
        dood.simple_animation 14
        dood.scale.set 0 0
        updatelist.push dood
        dood.update=!->
            grow=0.25*deltam
            @scale.x+=grow
            @scale.y+=grow
            #if Date.now! - sound.lastplayedtime > 100
            #    sound.play \candle, true
            #    sound.candle._sound.playbackRate.value=@scale.x+0.5
            if @scale.x>1 or @scale.y>1
                @scale.set 1 1
                @update=!->
                scenario.finale2!

    #say \zmapp "Yes. It's time to unveil our grand design."
    #say \zmapp "Say Hello to the new and improved... WHO-chan!"
scenario.finale2 =!->
    #say \zmapp "Here she comes now. Meet the daughter of Asclepius, the herald of new man-kind, or as we call her..."
    if switches.progress2 isnt 31
        say \zmapp tl("Here she comes now.")
    say !-> music.play \towertheme
    who = new NPC nodes.who.x+HTS, nodes.who.y+TS, \who
    who.setautoplay \down
    who.speed=15
    who.battle=encounter.who
    who.keyheight=(get-cached-image who.key)frame-height
    who.keywidth=(get-cached-image who.key)frame-width
    who.crop x:0 y:0 width: who.keywidth, height: 0
    whoupdate=who.update
    who.update=!->
        whoupdate ...
        rise=@keyheight*deltam/6
        if @height+rise > @keyheight
            rise=@keyheight - @height
        @crop x:0 y:0 width:@keywidth, height:@height+rise
        if @height >= @keyheight
            @update=whoupdate
            #say \zmapp "The new and improved... WHO-chan!"
            if switches.progress2 isnt 31
                say \zmapp tl("Meet the new and improved... WHO-chan!")
                say \who tl("At long last, I live.")
                say \who tl("You... I recognize you. You're the one who killed me, Ebola-chan.")
                say \who tl("Tell me, how does it feel knowing that everything you've worked for will soon be undone?")
                say \who tl("My cute subordinates have done an excellent job luring you here. Now it's time for you to die.")
                say \who tl("Bow down to your new god.")
            say ->
                who.goal.x=player.x
                who.goal.y=player.y
    who.onbattle=cinema_stop


scenario.curefate =!->
    setTimeout !->
        for p,i in party
            p.relocate \who
            p.y+=TS*2
            p.face \up
            if i>0 then p.x -= (i-1.5)*2*TS
            p.cancel_movement!
        camera_center(player.x,player.y - TS*2)
    ,0
    cinema_start!
    #who melts
    carpet.add-child <| who=new Doodad nodes.who.x+HTS,nodes.who.y+TS,'who_die',null,false
    who.anchor.set 0.5 1.0
    updatelist.push who
    setTimeout !->
        who.simple_animation 7, false
        who.animations.currentAnim.onComplete.addOnce !->
            who.animations.stop!
            setTimeout scenario.curefate2, 500
    ,500
scenario.curefate2 =!->
    if switches.llovsick1 is 4
        say \marb tl("Before we destroy you, I need to ask you something.")
        say \marb tl("My little sister, Llov. Were you the ones who did that to her?")
        say \cure tl("Huh? Now that you mention it, I guess she isn't with you.")
        say \zmapp tl("Look, I don't know what happened, but we didn't have anything to do with it.")
    else 
        say \zmapp tl("So you foiled our grand designs. No hard feelings though, right? You win.")
    menu tl("Spare them."), ->
        setswitch \curefate, 1
        zmapp.move -0.5, 1.5
        zmapp.move 0, 1
        zmapp.move 2, 3
        zmapp.move 0, 1
        zmapp.path.push !-> zmapp.kill!
        setTimeout !->
            cure.move 0.5, 1.5
            cure.move 0, 1
            cure.move -2, 3
            cure.move 0, 1
            cure.path.push !->
                cure.kill!
                cinema_stop!
        ,1000
    ,tl("Destroy them."), ->
        setswitch \curefate, -1
        ebby.path.push x:zmapp.x, y:zmapp.y+TS
        ebby.path.push !->
            ebby.face \up
            sound.play \defeat
            zmapp.update=override zmapp.update, !->
                @alpha -= deltam
                if @alpha >0 then return
                @destroy!
                acquire items.soulshard, 4
                cure.move 0, -2
                cure.path.push !->
                    cure.face \down
                    say \cure tl("No! This can't be happening!")
                    say ->
                        ebby.path.push x:cure.x, y:cure.y+TS
                        ebby.path.push !->
                            ebby.face \up
                            sound.play \defeat
                            cure.update=override cure.update, !->
                                @alpha -= deltam
                                if @alpha >0 then return
                                @destroy!
                                acquire items.soulshard, 4
                                cinema_stop!


scenario.beat_game =!->
    cinema_start!
    #bp enters from the bottom
    sound.play \door
    bp := node_npc nodes.hall, \bp
    i=0
    n={x:nodes.beat_game.x+HTS,y:nodes.beat_game.y+TS}
    for p in party
        if p is ebby
            p.path.push n
        else
            p.path.push {x:n.x - TS*(i++*2-1),y:n.y+TS}
        p.path.push callback:p.face_point, context:p, arguments:[bp]
    bp.move(0,-4)
    bp.path.push ->
        for p in players
            p.face_point bp
        say \bp tl("This is what I've been searching for.")
        #say \bp tl("Our reservoirs can finally be restored.")
        say \bp tl("This lab holds the secret to bringing back extinct species. Do you know what that means?")
        say \bp tl("Our energy problem has been solved. We can create new hosts and farm them for energy.")
        say \bp tl("It doesn't have to be human, but they are the most effective source.")
        #say \bp tl("Our reservoirs which the humans destroyed can finally be restored.")
        #say \bp tl("Cure was even kind enough to create a new human for us. It could become a great source of energy.")
        say \bp tl("I think you sisters should be the ones to decide this human's fate.")
        say ->
            for p in party
                continue if p is ebby
                p.face_point ebby
            if party.length is 2
                ebby.face_point if player is ebby then party.1 else player
            setTimeout scenario.beat_game2, 1000
scenario.beat_game2 =!->
    say \marb tl("After everything the humans have done, they deserve their fate.")
    if llov in party
        say \llov tl("Not all humans are bad. Remember {0}?",switches.name)
        say \llov tl("Llov thinks they deserve a second chance.")
    else if switches.llovsick1 is 4
        say \marb tl("What happened to Llov was ultimately their fault.")
    say \ebby tl("It's true that what they've done can't easily be forgiven.")
    say \ebby tl("But this one wasn't part of that. She isn't even born yet.")
    say \marb tl("Even if this one is innocent, humanity is not. Even if she does no evil, her children certainly will.")
    #say \ebby tl("I have taken the lives of many humans, and they are still with me now.")
    #say \ebby tl("I remember their words of encouragement.")
    #say \ebby tl("They told me \"I love you,\" and \"Good Luck.\"")
    #say \ebby tl("And finally, when it was all over, they told me\n\"Thank you.\"")
    #say \ebby tl("I know not all humans are evil, but do they deserve a second chance? Is it worth the risk?")
    #say \ebby tl("There are good humans and there are bad humans. But does the good justify the bad?")
    #say \ebby tl("Would it even be right of me to bring them back?")
    say \ebby tl("I don't know what to do. {0}, what do you think?",switches.name)
    #interacting with the tube.
    #Choose the fate of the human embryo.
    menu tl("Spare humanity."), ->
        switches.dead = if switches.llovsick1 is -2 then 'malpox' else if switches.llovsick1 is 4 then 'llov' else ''
        switches.progress='endgame'
        switches.beat_game=Date.now!
        switches.famine_cave=true
        setswitch \humanfate, 1

    ,tl("Abort humanity."), ->
        switches.dead = if switches.llovsick1 is -2 then 'malpox' else if switches.llovsick1 is 4 then 'llov' else ''
        switches.progress='endgame'
        switches.beat_game=Date.now!
        switches.famine_cave=true
        setswitch \humanfate, -1
    say !-> ebby.face \up
    say \ebby tl("...All right. I've decided.")
    say !->
        if switches.humanfate is 1
            for n in carpet.children then if n.name in <[tubeleft tubecenter tuberight]>
                n.load-texture 'lab_tiles'
                n.crop new Phaser.Rectangle TS*n.properties.frame_x, TS, TS,TS
                n.alpha=0
                updatelist.push n
                n.update=!->
                    @alpha += deltam/3
                    if @alpha >= 1
                        @alpha=1
                        @update=!->
                        if @name is \tubecenter
                            setTimeout scenario.credits, 1000
        else
            sound.play('water');sound.play('strike');sound.play('flame');
            for n in carpet.children then if n.name in <[tubeleft tubecenter tuberight]>
                n.load-texture 'lab_tiles'
                n.crop new Phaser.Rectangle TS*n.properties.frame_x, 0, TS,TS
                setTimeout scenario.credits, 2000 if n.name is \tubecenter

scenario.credits =!->
    credits=
        *m:tl("Super Filovirus Sisters"), s:2, t:5000
        *m:tl("Game by Dread-chan"), t:3000
        #*m:tl("Powered by Phaser"), t:2000
        #*m:tl("Special thanks to /ebola/, /pol/, and /monster/"), t:4000
        #*m:tl("In loving memory of the old VN team."), t:4000
        #*m:tl("This game is my love letter to Ebola-chan."), t:4000
        *m:tl("Thank you for playing!"), t:3000
        ...
    #cinema_start!
    solidscreen.alpha=1
    text = new Text 'font', ''
    gui.frame.add-child text
    temp.credits=text
    text.anchor.set 0.5 0.5
    text.x=HWIDTH
    text.y=HHEIGHT
    i=0
    newcredit=!->
        if credits[i]
            text.scale.set credits[i]s||1, credits[i]s||1
            text.change credits[i]m||credits[i]
            setTimeout newcredit, credits[i]t||5000
            i++
        #else scenario.credits2!
        else
            warp_node \earth \aftercredits
    newcredit!
    #text.change tl("Game by Dread-chan")
    #text.change tl("Thank you for playing!")

    #After short credit sequence, game resumes outside the lab where the other characters can be found gathered.
    #If llov is dead, then Malaria and Smallpox will arrive with a coffin. They will bury Llov.

scenario.childAge1 =!->
    return Date.now! - switches.beat_game > 2629746000 # 1 month
scenario.childAge2 =!->
    return Date.now! - switches.beat_game > 31556952000 # 1 year

scenario.states.endgame =!->
    if switches.map is \lab
        if switches.humanfate>0
            y=TS
            if scenario.childAge1!
                y+=TS
            if scenario.childAge2!
                bp.shiro = shiro = node_npc nodes.bp,'shiro'
                shiro.relocate(nodes.bp.x+1.5*TS, nodes.bp.y+TS)
                shiro.face 'down'
                shiro.interact=!->
                    scenario.shiro!
                    #say 'shiro' tl("...")
                    #say 'bp' tl("Shiro, say hello.")
                    #say 'shiro' tl("...Hello")
            else if scenario.childAge1!
                bp.load-texture \bp_shiro
        else y=0
        for c in carpet.children
            if c.name in <[tubeleft tubecenter tuberight]>
                c.load-texture 'lab_tiles'
                c.crop new Phaser.Rectangle TS*c.properties.frame_x, y, TS,TS
    if switches.map is \earth
        if switches.dead is \malpox
            dood = new Doodad(nodes.llovgrave.x, nodes.llovgrave.y+TS, \1x2 null true) |> actors.add-child
            dood.anchor.set 0.5 1.0
            dood.frame=11
            dood.body.setSize TS, TS
            initUpdate dood
            dood.interact=!->
                say '' tl("Here lies Malaria.")
            dood = new Doodad(nodes.llovgrave.x+TS, nodes.llovgrave.y+TS, \1x2 null true) |> actors.add-child
            dood.anchor.set 0.5 1.0
            dood.frame=11
            dood.body.setSize TS, TS
            initUpdate dood
            dood.interact=!->
                say '' tl("Here lies Smallpox.")
        else if switches.dead is \llov
            dood = new Doodad(nodes.llovgrave.x+HTS, nodes.llovgrave.y+TS, \1x2 null true) |> actors.add-child
            dood.anchor.set 0.5 1.0
            dood.frame=10
            dood.body.setSize TS, TS
            initUpdate dood
            dood.interact=!->
                say '' tl("Here lies Lloviu-tan.")
    if temp.credits and switches.map is \earth
        for p,i in party
            continue if p is player
            p.x += TS*i
        temp.credits.destroy?!
        delete! temp.credits
        solidscreen.alpha=0
        cinema_start!
        camera_center nodes.cam0.x, nodes.cam0.y, true
        Transition.pan nodes.aftercredits, 5000,!->
            if !switches.beat_joki or switches.llovsick1 is 4
                if !switches.soulcluster
                    say \ebby tl("We've recovered enough souls to restore the soul cluster.")
                    say \ebby \concerned tl("But some of them are still missing. I can hear them calling for me.")
                else
                    say \ebby \concerned tl("Some of the human souls are still out there. I can hear them calling for me.")
            else
                say \ebby tl("We've recovered all of the missing human souls.")
                if !switches.soulcluster
                    say \ebby tl("Now it's time to return them to the tower.")
            say cinema_stop
        ,null,false
    if switches.map is \earth2 and (switches.llovsick1 isnt -2 or switches.beat_chikun and switches.revivalchikun)
        chikun = node_npc(nodes.chikun, 'chikun')
        chikun.interact=!->
            say \chikun tl("You're not supposed to be able to get out here.")

scenario.shiro =!->
    say \bp tl("This is the child you chose to save. Her name is Shiro.")
    say \bp tl("Shiro, say hello. These are your mothers.")
    say \shiro tl("...Hello.")
    say \marb \aroused tl("She's cute. I'd like to take her home with me.")
    say \ebby \smile tl("Yay! My new favorite human. Sorry {0}.", switches.name)
    if llov in party
        say \llov \smile tl("Does this mean Llov is a big sister now? Can Llov do big sister things?")
    say \bp tl("We'll need to create more for a breeding population, but this is a good start.")

scenario.joki_castle =!->
    say \joki tl("What a surprise. I didn't expect you would find your way here.")
    if switches.famine
        if llov in party
            say \llov tl("Uncle Famine told us how to get here.")
        else
            say \marb tl("Famine told us you took over Death's castle.")
        say \joki tl("Oh Famine, such a gossip.")
    say \joki tl("Yes, this is my castle now. Nice place isn't it?")
    say \joki tl("You should stay a while, I'll make some tea.")
    say \ebby \concern tl("Joki, why are you hiding my friends from me?")
    say \joki tl("...So you can sense them.")
    say \ebby \concern tl("Please, give them back to me.")
    say \joki tl("Ebola-chan, I can understand why you would think that these are yours. After all, you're the one who killed them.")
    say \joki tl("But the dead belong to Death, and that's me.")
    say \joki tl("I'll make you a deal though. We'll both bet all the souls we have... And whoever wins takes it all.")
    say \marb \smile tl("Oh, I like the sound of that. How about you Ebby?")
    say \ebby tl("I'll do whatever it takes to get them back!")
    ##
    #say \joki tl ("So you've found this place.")
    #say \joki tl ("Yes, it is true. I am Death.")
    #say \joki tl ("As I am Death, all human souls are rightfully my property.")
    #say \joki tl ("I was content to let you live in ignorance, but now that you know the truth, it's time that I collect what you owe me.")
    say -> start_battle encounter.joki

scenario.grave_message=(o)!->
    say '' "deprecated"

scenario.grave_message1=!->
    say '' tl("John Doe was a stranger in this town. He was found dead in the river.")
    say '' tl("Nobody knew his real name.")
scenario.grave_message2=!->
    say '' tl("Jane Doe shared a room with John. She was 20 years younger than him.")
    say '' tl("Not long after John's death, she was found hanging from the ceiling.")
scenario.grave_message3=!->
    say '' tl("Sherry Stillwater was married to the pastor.")
    say '' tl("Desperate for water, she drank the blood of neighborhood children.")
    say '' tl("She died of bloodborne illness.")
scenario.grave_message4=!->
    say '' tl("Melissa Goth didn't listen to the pastor.")
    say '' tl("She fell ill and died hunched over a toilet.")
scenario.grave_message5=!->
    say '' tl("Ethan Stillwater was a pastor for the local church.")
    say '' tl("He claimed that the water was poisoned, and died of dehydration.")
scenario.grave_message6=!->
    say '' tl("Jordan Smith survived the blast, but died from fallout.")
scenario.grave_message7=!->
    say '' tl("Pete Park was bit by a radioactive spider.")
    say '' tl("He didn't get super powers.")
scenario.grave_message8=!->
    say '' tl("Doctor White examined John Doe's body.")
    say '' tl("It was infected with ebola. And now he was too.")
scenario.grave_message9=!->
    say '' tl("Miss White worked in an orphanage. She was very close with the children.")
    say '' tl("The disease spread easily.")
scenario.grave_message10=!->
    say '' tl("Bob Markus found one of his tenants hanging.")
    say '' tl("He was later found without a head.")
scenario.grave_message11=!->
    say '' tl("Billy Jackson took the blast head-on.")
scenario.grave_message12=!->
    say '' tl("Sally Sordid took shelter underground with her daddy.")
scenario.grave_message13=!->
    say '' tl("Simon Sordid ate his daughter's body.")
    say '' tl("He died soon after.")
scenario.grave_message14=!->
    say '' tl("Maxwell Goth added his sister's blood to the cafeteria food.")
    say '' tl("He died behind bars.")
scenario.grave_message15=!->
    say '' tl("Patty Park gave birth to a malformed child.")
    say '' tl("She drowned it in the river, then took her own life.")
scenario.grave_message16=!->
    say '' tl("Mark Markus was found in possession of a human skull.")
    say '' tl("The next day he had two human skulls, but no head.")
scenario.grave_message17=!->
    say '' tl("Some mysterious robed men came through town.")
    say '' tl("They took John Doe and Jane Doe's bodies and left.")
    say '' tl("One of them stayed behind, and died of ebola.")
scenario.grave_message18=!->
    say '' tl("Nora Gray claimed to communicate with the world beyond.")
    say '' tl("She disappeared for a while, and was later discovered stuffed inside a box.")
scenario.grave_message19=!->
    say '' tl("Kate Park found a box filled with human parts.")
    say '' tl("She was quarantined, and soon died of ebola.")
scenario.grave_message20=!->
    say '' tl("Martin White climbed out of the wreckage and explored the ruins.")
    say '' tl("A charred husk grabbed his leg. He fell cracked his skull.")
scenario.grave_message21=!-> #empty grave
    say '' tl("Hilda Gray liked to spend time in the graveyard.")
    say '' tl("She became a permanent resident when she was found decapitated there.")
scenario.grave_message22=!->
    say '' tl("Robert Baron was caught digging up graves.")
    say '' tl("He was lynched by the town.")
scenario.grave_message23=!->
    say '' tl("Sheriff Brown was investigating a series of mysterious deaths.")
    say '' tl("Gazing into the eyes of the skull, he felt something strange.")
    say '' tl("He realized it was his own skull.")
scenario.grave_message24=!->
    say '' tl("A robed figure ambled through the wastleland, a string of skulls in tow.")
    say '' tl("He clasped his hands in prayer, and accepted his death.")
scenario.grave_message25=!->
    say '' tl("Jerry Fig died of natural causes.")
scenario.grave_message26=!->
    say '' tl("Terry Wisdom willingly infected himself.")
scenario.grave_message27=!->
    say '' tl("Tyrone Cooper infiltrated the shelter.")
    say '' tl("He helped distribute the gift.")
scenario.grave_message28=!->
    say '' tl("Mary Mort refused the gift.")
    say '' tl("She chose to leave the shelter, and died a painful death.")
scenario.grave_message_key=!->
    say '' tl("Hector Stein collected the infected blood and stored it safely underground.")
    say '' tl("He survived to become one of the last humans alive.")
    say '' tl("He rebuilt as much as he could, and began a project to cure his loneliness.")
    say '' tl("He lost hope, and dug his own grave.")
scenario.grave_message_weathered=!->
    say '' tl("The stone is weathered and unreadable.")
scenario.grave_message_unmarked=!->
    say '' tl("Nothing is written.")

scenario.states.towerfall_earth =!->
    if nodes.necrotoxin and !switches.necrotoxin
        item = new Doodad(nodes.necrotoxin.x, nodes.necrotoxin.y, '1x1') |> actors.add-child
        item.name = 'necrotoxin'
        item.interact=!->
            acquire items.necrotoxin, 5, false, true
            acquire items.necrotoxinrecipe, 1, false, true
            #say save
            say !-> setswitch \necrotoxin true
            @destroy!

scenario.burningflesh =(o)!->
    o.collider.destroy!
    o.timer=Date.now!
    o.prev.s=o.scale.x
    o.goal.s=0.75
    o.goal.y-=12
    sound.play 'defeat'
    o.update-paused=o.update=!->
        t = (Date.now! - @timer)/2000
        #smoothness=20
        #t = (t*smoothness.|.0)/smoothness
        if t>1
            @destroy!
        @scale.set @prev.s + (@goal.s - @prev.s)*t
        @alpha = 1 - t



scenario.war =!->
    if !items.basement_key.quantity
        say \war tl("I trust you've seen the cancerous lesions that cover this land.")
        say \war tl("It is the remnant of a bio-weapon created by the humans.")
        say \war tl("No doubt all this goop everywhere is in your way right? So how about you lend me a hand.")
        say \war tl("The humans created a special toxin to destroy the bio-weapon. It should be aroud here somewhere.")
        say \war tl("Take this, maybe it will help.")
        acquire items.basement_key
        return
    if session.wrongpass and !switches.mainpass
        say \ebby tl("We're looking for a password to enter the lab. Do you know it?")
        say \war tl("I don't know the password, but I know someone who does.")
        say \war tl("He used to tend that lab. Problem is, he died a while back.")
        say \war tl("You should check his body. it might have what you're looking for.")
        if !switches.necrotoxinrecipe then return
    if items.necrotoxinrecipe.quantity
        items.necrotoxinrecipe.quantity=0
        setswitch \necrotoxinrecipe true
        say \war tl("I see you found the Necrotoxin Recipe. Let me see it.")
        say '' tl("Gave the Necrotoxin Recipe to War.")
    if switches.necrotoxinrecipe
        say \war tl("Do you need more Necrotoxin? I can make you some, but it will take 3 cumberground each.")
    if switches.necrotoxinrecipe and items.cumberground.quantity>=3
        menu tl("Yes"), !->
            q=items.cumberground.quantity/3.|.0
            number tl("Max:{0}",q), 0 q
            say ->
                q= dialog.number.num
                unless q>0
                    return say '' tl("Created nothing.")
                exchange 3*q, items.cumberground, q, items.necrotoxin
                sound.play \itemget
                say '' tl("Created {0} Necrotoxin.",q)
        ,tl("No"), !->
    if !switches.necrotoxinrecipe
        say \war tl("It's been real quiet around here.")
        say \war tl("Now that the apocalypse is over, we don't have much of a job any more.")
        say \war tl("Tell old pesty that I would love to ride again some day.")

scenario.famine =!->
    if switches.famine
        say \famine tl("That girl Joki, she's taken over Death's old castle.")
        say \famine tl("It's in the northern reaches of the dead world.")
        return
    say '' tl("Here lies famine. He starved to death.")
    say ->
        setswitch \famine true
        setswitch \famine_cave true
    say \famine tl("Hey, just between you and me... I'm not actually dead. Just sleeping.")
    say \famine tl("The only horseman that's actually dead is Death. He's been replaced by that maid of his.")
    say \famine tl("Oh, and Conquest is dead too. But that happened a long time ago.")

scenario.ebolashrine =!->
    for p in party
        p.stats.hp=1
        p.revive!
    if ebby in party
        say \ebby \smile tl("It's a picture of me!")
        say !-> sound.play \itemget
        say '' tl("The shrine fills you with love.")
        if !session.sisterletter
            session.sisterletter=true
            say \ebby \shock tl("What's this? Someone left a letter here!")
            scenario.sisterletter!
            say \ebby \default tl("I wonder what that means.")

scenario.delta_lock =!->
    say '' tl("The door is frozen shut.")
    player.move 0, 0.5


scenario.lorebook_delta =!->
    say '' tl("The gods are certainly mad at us. That's why this is happening.")
    say '' tl("If the gods want to destroy us, then what choice do we have?")
    say '' tl("We must create our own gods, and slay the gods that want to kill us.")
    say '' tl("WHO was our most recent creation. She is our last hope.")

scenario.lorebook_delta2 =!->
    say '' tl("Why did you choose her over me? Together we could have saved the world.")
    say '' tl("Instead, you condemned humanity to excruciating death. I will never forgive you.")

scenario.lorebook_delta3 =!->
    say '' tl("Last night we recieved another shipment of god blood.")
    say '' tl("I can't see the one who delivers it to us, but one of my collegues can. He describes her as a young woman dressed in black and white.")
    say '' tl("My daughter has been chosen as the next candidate. She has shown high potential, but I've seen this go wrong too many times.")
    say '' tl("I can only pray that everything goes well.")

scenario.lorebook_deep =!->
    say '' tl("He showed high affinity for the disease.")
    say '' tl("Where most would wither and die, he only grew stronger.")
    say '' tl("There's something special about people like this. I think they have a special bond with the gods.")
    say '' tl("They are the prime candidates for ascension.")

scenario.sisterletter =!->
    say '' tl("Dear {0},",switches.name)
    say '' tl("Thank you for choosing me.")
    say '' tl("Love, your sister.")

scenario.basementlocked=!->
    return if Date.now! - temp.locktimer < 5000
    say '' tl("The hatch is locked.")
    say -> temp.locktimer = Date.now!
