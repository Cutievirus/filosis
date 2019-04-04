var preloader
state.preboot.preload =!->
    batchload [
    [\preloader \preloader.png]
    [\preloader_back \preloader_back.png]
    [\title \title.png]
    #[\logo \logo.png]
    #[\cg_skulls \skulls.png]
    [\loading \loading.png]
    ], \img/gui/

    game.load.json 'test', 'img/misc/test.json'

    #Solid colors
    g = game.add.bitmapData 1 1 \solid true
    g.ctx.begin-path!
    g.ctx.rect 0 0 1 1
    g.ctx.fill-style = \#ffffff
    g.ctx.fill!
    game.load.image \solid g.canvas.toDataURL!

    game.load.image \empty \img/misc/empty.png

state.preboot.create =!-> 
    #if !game.cache._cache.json.test
    if !game.cache.checkJSONKey('test')
        fatalerror \sameOrigin
        #sameoriginmessage!
        return
    game.state.start 'boot'
    bootloader.innerHTML=''

state.boot.preload =!->#load assets needed for preloader
    create_title_background!
    #preloader := gui.frame.create 0, HEIGHT - TS*2, 'preloader'
    #game.load.set-preload-sprite preloader
    #preloader.text = new Phaser.Image game, 1, 209, 'loading'
    preloader := new Phaser.Image game, 1, 209, 'loading'
    gui.frame.add-child preloader

    game.load.image 'logo', 'img/gui/logo.png'
    game.load.bitmapFont('unifont', 'img/font/Filosis.png', 'img/font/Filosis.xml');

state.boot.create =!-> 
    gui.frame.remove preloader
    #gui.frame.remove preloader.text
    scriptloader mod_scripts, !->
        game.state.start 'preload'

state.preload.preload =!->
    #gui.frame.add-child preloader
    preloader := gui.frame.create 0, HEIGHT - TS*2, 'preloader'
    preloader.back = gui.frame.create 0, preloader.y, 'preloader_back'
    game.load.set-preload-sprite preloader
    preloader.text = new Text null, "Loading...",2,210
    gui.frame.add-child preloader.text
    game.load.onFileStart.add (progress,key,url)!->
        #console.log progress,key,url
        if session.debug
            preloader.text.change "Loading "+url
        else if progress is 0
            preloader.text.change "Loading..."
        else
            preloader.text.change "Loading "+game.load.progress+"%"
    preload_assets!
    
state.preload.create =!->
    gui.frame.remove preloader
    gui.frame.remove preloader.back
    gui.frame.remove preloader.text
    game.state.start 'title'
    tlNames!

preload_mod=[];

mod_scripts=[];

scriptloader=!(arr,callback)->
    script = document.createElement \script
    script.src = arr.shift!
    console.log "Loading mod script "+script.src
    if arr.length
        script.onload=state.preload.scriptloader.bind this,arr,callback
    else
        callback!
    document.head.appendChild script

#===========================================================================
# PRELOAD ASSETS
#===========================================================================

!function preload_assets

    #===================================================
    # NPCs and Players
    #---------------------------------------------------

    batchload [
    [\llov \llov.png 20 25]
    [\ebby \ebby.png 22 25]
    [\marb \marb.png 22 28]
    [\mal \mal.png 22 28]
    [\bp \bp.png 22 28]
    [\joki \joki.png 22 25]
    [\herpes \herpes.png 22 25]
    [\pox \pox.png 22 25]
    [\leps \leps.png 22 26]
    [\sars \sars.png 22 26]
    [\aids1 \eidzu1.png 20 25]
    [\aids2 \eidzu2.png 20 25]
    [\aids3 \eidzu3.png 29 28]
    [\rab \rabies.png 22 26]
    [\chikun \chikun.png 22 26]

    [\ammit \ammit.png 20 25]
    [\parvo \parvo.png 20 25]
    [\zika \zika.png 22 25]

    [\cure \cure.png 22 28]
    [\zmapp \zmapp.png 22 26]
    [\who \who.png 22 36]
    #[\draco \draco.png 20 25]

    [\min \min.png 20 25]
    [\dead \dead.png 20 25]

    [\merchant1 \merchant1.png 22 28]
    [\merchant2 \merchant2.png 22 28]

    [\shiro \shiro.png 20 25]

    ], 'img/char/', \spritesheet
    
    #costumes
    /*
    batchload_battler [\llov nurse:0 swim:0 swim2:0 \pumpkin \christmas \valentine \punk],
        [\ebby cheer:0 bat:0 santa:1 witch:0]
        [\marb nurse:0 \maid \bunny \demon]
    */

    batchload [
    [\ebby_battle \ebby.png 96 86]
    [\marb_battle \marb.png 96 86]
    [\marb_battle_1 \marb_1.png 96 96]
    [\marb_battle_2 \marb_2.png 106 86]
    [\llov_battle \llov.png 96 86]
    [\llov_battle_christmas \llov_christmas.png 102 86]

    ], 'img/battle/', \spritesheet

    batchload [
    [\llov_base \llov_base.png 120 130]
    [\llov_base2 \llov_base2.png 120 140]
    [\llov_face \llov_face.png 35 33]
    [\ebby_base \ebby_base.png 112 145]
    [\ebby_base2 \ebby_base2.png 112 155]
    [\ebby_face \ebby_face.png 37 33]
    [\marb_base \marb_base.png 140 160]
    [\marb_base2 \marb_base2.png 140 175]
    [\marb_face \marb_face.png 37 31]
    ], 'img/port/', \spritesheet
    
    batchload [
    #['ebby_port' 'ebby.png']
    #['ebby_smile' 'ebby happy.png']
    #['ebby_concern' 'ebby concern.png']
    #['ebby_cry' 'ebby cry.png']
    #['llov_port' 'llov.png']
    #['llov_scared' 'llov scared.png']
    #['llov_sick' 'llov sick.png']
    #['llov_smile' 'llov happy.png']
    #['marb_port' 'marb.png']
    #['marb_smile' 'marb smile.png']
    #['marb_troubled' 'marb troubled.png']
    #['marb_grief' 'marb grief.png']
    ['mal_port' 'mal.png']
    ['bp_port' 'bp.png']
    ['joki_port' 'joki.png']
    #['joki_tits' 'joki tits.png']
    ['herpes_port' 'herpes.png']
    #['herpes_tits' 'herpes tits.png']
    ['merchant_port' 'merchant.png']
    #['merchant_tits' 'merchant tits.png']
    ['pox_port' 'pox.png']
    ['pox_injured' 'pox injured.png']
    ['leps_port' 'leps.png']
    ['sars_port' 'sars.png']
    ['sars_mad' 'sars mad.png']
    ['rab_port' 'rabies.png']
    ['rab_mad' 'rabies mad.png']
    ['rab2_port' 'rabies2.png']
    ['aids1_port' 'eidzu1.png']
    ['aids1_mad' 'eidzu1 mad.png']
    ['aids2_port' 'eidzu2.png']
    ['aids2_mad' 'eidzu2 mad.png']
    ['aids3_port' 'eidzu3.png']
    ['nae_port' 'nae.png']
    ['ammit_port' 'ammit.png']
    ['chikun_port' 'chikun.png']
    ['parvo_port' 'parvo.png']
    ['zika_port' 'zika.png']

    ['cure_port' 'cure.png']
    ['zmapp_port' 'zmapp.png']
    ['zmapp_healthy' 'zmapp healthy.png']
    ['who_port' 'who.png']
    #['draco_port' 'draco.png']

    ['min_port' 'min.png']
    ['wraith_port' 'wraith.png']
    ['war_port' 'war.png']

    ['slime_port' 'slime.png']

    ['shiro_port' 'shiro.png']

    ], 'img/port/'

    #===================================================
    # Monsters
    #---------------------------------------------------

    #mobs
    batchload [
    [\mob_slime \mob_slime.png 16 17]
    [\mob_ghost \mob_ghost.png 16 17]
    [\mob_bat \mob_bat.png 26 18]
    [\mob_flytrap \mob_flytrap.png 17 19]
    [\mob_corpse \mob_corpse.png 17 19]
    [\mob_wisp \mob_wisp.png 22 22]
    [\mob_ripple \mob_ripple.png 16 5]
    [\mob_arrow \mob_arrow.png 14 20]
    [\mob_glitch \mob_glitch.png 24 25]

    [\mob_naegleria \naegleria_mob.png 22 28]
    [\naegleria \naegleria.png 22 28]
    [\wraith \wraith.png 22 28]
    [\mob_wraith \wraith_mob.png 22 28]
    [\mob_chikun \chikun_mob.png 24 28]
    [\mob_llov \darkllov.png 24 25]

    ], 'img/char/', \spritesheet

    #static battlers
    batchload [
    ['monster_mimic' 'mimick.png']
    ['monster_sanishark' 'sanishark.png']
    ['monster_wolf' 'wolf.png']
    ['monster_wraith' 'wraith.png']
    ['monster_naegleria' 'naegleria.png']
    ['monster_cure0' 'cure0.png']
    ['monster_cure1' 'cure1.png']
    ['monster_zmapp0' 'zmapp0.png']
    ['monster_zmapp1' 'zmapp1.png']
    ['monster_zmappX' 'zmappX.png']
    ['monster_sars' 'sars.png']
    ['monster_rabies' 'rabies.png']
    ['monster_rabies2' 'rabies_2.png']
    ['monster_eidzu1' 'eidzu1.png']
    ['monster_eidzu1_2' 'eidzu1_2.png']
    ['monster_eidzu2' 'eidzu2.png']
    ['monster_eidzu2_2' 'eidzu2_2.png']
    ['monster_chikun' 'chikun.png']
    ['monster_who' 'who.png']
    ['monster_lepsy' 'lepsy.png']
    ['monster_parvo' 'parvo.png']
    ['monster_zika' 'zika.png']
    ['monster_joki' 'joki.png']
    ['monster_voideye' 'voideye.png']
    ['monster_voidgast' 'voidgast.png']
    ['monster_voidtofu' 'voidtofu.png']
    ['monster_voidskel' 'voidskel.png']
    ['monster_darkllov' 'darkllov.png']
    ['monster_mutant' 'mutant.png']
    ['monster_throne' 'throne.png']
    ], 'img/battle/'

    #animated battlers
    batchload [
    ['monster_slime' 'slime_chibi.png' 40 27]
    ['monster_slime2' 'slime.png' 56 46]
    ['monster_ghost' 'eyeball.png' 52 64]
    ['monster_skullghost' 'skullghost1.png' 64 64]
    ['monster_graven' 'graven.png' 64 64]
    ['monster_eel' 'eel.png' 56 56]
    ['monster_cancer' 'cancer.png' 64 64]
    ['monster_lurker' 'lurker.png' 64 64]
    ['monster_bat' 'bat.png' 64 64]
    ['monster_doggie' 'doggie.png' 64 64]
    ['monster_mantrap' 'mantrap.png' 64 64]
    ['monster_greblin' 'greblin.png' 51 44]
    ['monster_polyduck' 'polyduck.png' 64 64]
    ['monster_rhinosaurus' 'rhinosaurus.png' 83 72]
    ['monster_woolyrhino' 'woolyrhino.png' 83 72]
    ['monster_skulmander' 'skulmander.png' 64 64]
    ['monster_tengu' 'tengu.png' 71 79]

    ['monster_sars_summon' 'sars_summon.png' 20 20]
    ], 'img/battle/', \spritesheet

    #===================================================
    # ETC
    #---------------------------------------------------

    batchload [
    [\head_llov \head_llov.png]
    [\head_ebby \head_ebby.png]
    [\head_marb \head_marb.png]
    [\trigger \trigger.png]
    [\boat \boat.png]
    [\deadllov \deadllov.png]
    [\deadmal \deadmal.png]
    [\deadpox \deadpox.png]
    [\war \war.png]
    [\bp_shiro \bp_shiro.png]
    ], 'img/misc/'

    batchload [
    [\dust \dust.png 21 19]
    [\flame \fire.png 16 16]
    [\flameg \fireg.png 16 16]
    [\tv \tv.png 16 16]
    [\pent \pent.png 32 32]
    [\pent_fire \pent_fire.png 32 32]
    [\llovsick \llovsick.png 20 26]
    [\poxsick \poxsick.png 20 26]
    [\joki_fireball \joki_fireball.png 25 25]

    [\z \z.png 16 16]
    [\zburst \zburst.png 32 32]
    [\pest \pest.png 73 36]
    [\bloodpool \bloodpool.png 22 16]
    [\who_die \who_die.png 22 36]
    [\ripple \ripple.png 16 5]
    ], 'img/misc/', \spritesheet
    
    game.load.image 'water', 'img/map/water.png'
    game.load.spritesheet 'sun', 'img/map/sun.png', 105, 53

    game.load.spritesheet 'bars', 'img/gui/bars.png', 1, 10
    game.load.spritesheet 'window', 'img/gui/window.png', 16, 16
    game.load.image 'arrow', 'img/gui/arrow.png'
    game.load.image 'arrowd', 'img/gui/arrowd.png'
    game.load.image 'arrowu', 'img/gui/arrowu.png'
    game.load.image 'target', 'img/gui/target.png'
    #game.load.image 'font', 'img/gui/font.png'
    #game.load.image 'font_yellow', 'img/gui/font_yellow.png'
    #game.load.image 'font_gray', 'img/gui/font_gray.png'
    #game.load.image 'font_red', 'img/gui/font_red.png'
    #game.load.image 'font_green', 'img/gui/font_green.png'

    #game.load.bitmapFont('unifont', 'img/font/Filosis.png', 'img/font/Filosis.xml');

    batchload [
    #['item_sword', 'sword.png']
    #['item_key', 'key.png']

    #['item_misc', 'misc.png']
    #['item_misc2', 'misc2.png']
    #['item_misc3', 'misc3.png']
    #['item_misc4', 'misc4.png']

    #['item_shards', 'shards.png']
    #['item_vial', 'pot_empty.png']
    #['item_tuonen', 'pot_tuonen.png']
    ['item_lovejuice', 'pot_love.png']
    ['item_water', 'pot_water.png']
    #['item_nectar', 'pot_nectar.png']
    #['item_oil', 'pot_oil.png']
    #['item_sap', 'pot_sap.png']
    #['item_soul', 'soul.png']

    #['item_pot', 'pot.png']
    #['item_hp1', 'pot_hp_1.png']
    #['item_hp2', 'pot_hp_2.png']
    #['item_hp3', 'pot_hp_3.png']
    #['item_hp4', 'pot_hp_4.png']
    #['item_sp1', 'pot_sp_1.png']
    #['item_sp2', 'pot_sp_2.png']
    #['item_antidote', 'pot_antidote.png']
    #['item_burnheal', 'pot_antifire.png']
    #['item_antifreeze', 'pot_antifreeze.png']
    #['item_anticurse', 'pot_anticurse.png']

    #['item_poisonbom', 'bom_poison.png']
    #['item_cursebom', 'bom_curse.png']
    #['item_firebom', 'bom_fire.png']
    #['item_icebom', 'bom_ice.png']

    #[\item_leatherarmor \armorleather.png]
    #[\equip_leatherarmor \armorleather_e.png]
    #[\item_platearmor \armorplate.png]
    #[\equip_platearmor \armorplate_e.png]
    #[\item_thornarmor \armorthorn.png]
    #[\equip_thornarmor \armorthorn_e.png]
    #[\item_woodshield \shieldwood.png]
    #[\equip_woodshield \shieldwood_e.png]
    #[\item_towershield \shieldtower.png]
    #[\equip_towershield \shieldtower_e.png]
    #[\item_speedboot \speedboot.png]
    #[\equip_speedboot \speedboot_e.png]

    #[\item_heartpin \heartpin.png]
    #[\equip_heartpin \heartpin_e.png]
    #[\item_shinai \shinai.png]
    #[\equip_shinai \shinai_e.png]
    #['item_pest', 'pest.png']
    #['equip_pest_0', 'pest_e0.png']
    #['equip_pest_1', 'pest_e1.png']
    #['item_newton', 'newton.png']
    #['equip_newton', 'newton_e.png']
    #[\item_worldsharp \worldsharp.png]
    #[\equip_worldsharp \worldsharp_e.png]
    #[\item_samsword \samsword.png]
    #[\equip_samsword \samsword_e.png]
    #[\item_fan \fan.png]
    #[\equip_fan \fan_e.png]
    #[\item_broadsword \broadsword.png]
    #[\equip_broadsword \broadsword_e.png]
    #[\item_steelpipe \steelpipe.png]
    #[\equip_steelpipe \steelpipe_e.png]
    ], 'img/item/'

    batchload [
    [\item_misc \sheet_common.png 16 16]
    [\item_pot \sheet_pot.png 16 16]
    [\item_key \sheet_key.png 16 16]
    [\item_equip \sheet_equip.png 16 16]
    [\item_equip2 \sheet_equip2.png 32 32]
    [\buffs \sheet_buffs.png 16 16]
    ], \img/item/ \spritesheet
    /*
    batchload [
    [\buff_blister, \blister.png]
    [\buff_scab, \scab.png]
    [\buff_fever, \fever.png]
    [\buff_burn1, \burn1.png]
    [\buff_burn2, \burn2.png]
    [\buff_burn3, \burn3.png]
    [\buff_chill, \chill.png]
    [\buff_skull, \skull.png]
    [\buff_lips, \lips.png]
    [\buff_blood, \blood.png]
    [\buff_recover, \recover.png]
    [\buff_seizure, \seizure.png]
    [\buff_shieldbreak, \shieldbreak.png]
    [\buff_weak, \weak.png]
    [\buff_wing, \wing.png]
    ], \img/buff/
    */
    #Backgrounds
    batchload [
    [\bg_0_0 \0_0.png]
    [\bg_0_1 \0_1.png]
    [\bg_1_0 \1_0.png]
    [\bg_1_1 \1_1.png]
    [\bg_2_0 \2_0.png]
    [\bg_2_1 \2_1.png]
    [\bg_3_0 \3_0.png]
    [\bg_3_1 \3_1.png]
    [\bg_4_0 \4_0.png]
    [\bg_4_1 \4_1.png]
    [\bg_5_0 \5_0.png]
    [\bg_5_1 \5_1.png]
    [\bg_5_0a \5_0a.png]
    [\bg_5_1a \5_1a.png]
    [\bg_5_0b \5_0b.png]
    [\bg_5_1b \5_1b.png]
    [\bg_6_0 \6_0.png]
    [\bg_6_1 \6_1.png]
    [\bg_7_0 \7_0.png]
    [\bg_7_1 \7_1.png]
    [\bg_7_0s \7_0s.png]
    [\bg_7_1s \7_1s.png]
    [\bg_8_0 \8_0.png]
    [\bg_9_0 \9_0.png]
    ], \img/bg/

    #CGs
    batchload [
    [\cg_pest \pest.png]
    [\cg_pest_night \pest_night.png]
    [\cg_earth \earth.png]
    [\cg_tower0 \tower0.png]
    [\cg_tower1 \tower1.png]
    [\cg_tower2 \tower2.png]
    [\cg_jungle \jungle.png]
    [\cg_abyss \abyss.png]
    ],\img/cg/

    game.load.spritesheet 'cg_border', 'img/cg/border.png', 8, 8


    #===================================================
    # Battle Animations
    #---------------------------------------------------
    batchload [
    [\anim_slash \slash.png 36 42]
    [\anim_flame \flame.png 42 42]
    [\anim_curse \curse.png 42 42]
    [\anim_heal \heal.png 42 42]
    [\anim_blood1 \blood1.png 42 42]
    [\anim_blood2 \blood2.png 42 42]
    [\anim_water \water.png 48 48]
    [\anim_arrow \arrow.png 16 42]
    [\anim_flies \flies.png 48 48]
    ], \img/anim/ \spritesheet

    #===================================================
    # Music and Sound
    #---------------------------------------------------
    /*
    batchload [
    [\battle [\battle.ogg \battle.m4a]]
    ], \music/ \audio
    */

    batchload [
    [\blip [\textblip.ogg \textblip.m4a]]
    [\itemget [\itemget.ogg \itemget.m4a]]
    [\encounter [\encounter.ogg \encounter.m4a]]
    [\boom [\boom.ogg \boom.m4a]]
    [\defeat [\defeat.ogg \defeat.m4a]]
    [\candle [\candle.ogg \candle.m4a]]
    [\strike [\strike.ogg \strike.m4a]]
    [\flame [\flame.ogg \flame.m4a]]
    [\water [\water.ogg \water.m4a]]
    [\swing [\swing.ogg \swing.m4a]]
    [\laser [\laser.ogg \laser.m4a]]
    [\run [\run.ogg \run.m4a]]
    [\stair [\stair.ogg \stair.m4a]]
    [\door [\door.ogg \door.m4a]]
    [\groan [\groan.ogg \groan.m4a]]
    [\voice [\voice.ogg \voice.m4a]]
    [\voice2 [\voice2.ogg \voice2.m4a]]
    [\voice3 [\voice3.ogg \voice3.m4a]]
    [\voice4 [\voice4.ogg \voice4.m4a]]
    [\voice5 [\voice5.ogg \voice5.m4a]]
    [\voice6 [\voice6.ogg \voice6.m4a]]
    [\voice7 [\voice7.ogg \voice7.m4a]]
    [\voice8 [\voice8.ogg \voice8.m4a]]
    [\rope [\ROPE.ogg \ROPE.m4a]]
    ], \sound/ \audio

    #===================================================
    # Tilemap
    #---------------------------------------------------
    load_map \hub \hub.json
    load_map \shack1 \shack1.json
    load_map \shack2 \shack2.json
    load_map \pox_cabin \pox_cabin.json
    load_map \tunnel \tunnel.json
    load_map \tunnel_entrance \tunnel_entrance.json
    load_map \deadworld \deadworld.json
    load_map \tower0 \tower0.json
    load_map \tower1 \tower1.json
    load_map \tower2 \tower2.json
    load_map \towertop \towertop.json
    load_map \ebolaroom \ebolaroom.json
    load_map \delta \delta.json
    load_map \deltashack \deltashack.json
    load_map \deltashack2 \deltashack2.json
    load_map \deltashack3 \deltashack3.json
    load_map \earth \earth.json
    load_map \earth2 \earth2.json
    load_map \earth3 \earth3.json
    load_map \basement1 \basement1.json
    load_map \basement2 \basement2.json
    #load_map \voidtunnel \voidtunnel.json
    load_map \necrohut \necrohut.json
    load_map \shrine \shrine.json
    load_map \labdungeon \labdungeon.json
    load_map \lab \lab.json
    load_map \labhall \labhall.json
    load_map \tunneldeep \tunneldeep.json
    load_map \shack3 \shack3.json
    load_map \deathtunnel \deathtunnel.json
    load_map \deathdomain \deathdomain.json
    load_map \castle \castle.json
    load_map \void \void.json

    batchload [
    [\tiles \tiles.png]
    [\tiles_night \tiles_night.png]
    [\tower_tiles \tower.png]
    [\tower_tiles_night \tower_night.png]
    [\towerin_tiles \towerin.png]
    [\townhouse_tiles \townhouse.png]
    [\townhouse_tiles_night \townhouse_night.png]
    [\dungeon_tiles \dungeon.png]
    [\jungle_tiles \jungle.png]
    [\home_tiles \home.png]
    [\delta_tiles \delta.png]
    [\delta_tiles_night \delta_night.png]
    [\earth_tiles \earth.png]
    [\lab_tiles \lab.png]
    [\castle_tiles \castle.png]
    [\void_tiles \void.png]

    ], \img/map/

    batchload [
    [\1x1 \1x1.png 16 16]
    [\1x1_night \1x1_night.png 16 16]
    [\1x2 \1x2.png 16 32]
    [\1x2_night \1x2_night.png 16 32]
    [\2x2 \2x2.png 32 32]
    [\2x3 \2x3.png 32 48]
    [\3x3 \3x3.png 48 48]
    ], \img/map/ \spritesheet


    for f in preload_mod
        f?!