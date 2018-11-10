state.load.preload =!->
    #console.log("loading...")
    gui.bringToTop(gui.frame) #??? What?
    cg.showfast access zones[getmapdata \zone]cg
    solidscreen.alpha=1
    #preloader := gui.frame.create 0, HEIGHT - TS*2, 'preloader'
    gui.frame.add-child preloader.back
    gui.frame.add-child preloader
    #if !state.load.loadtext
    #    state.load.loadtext = new Text null, "Loading...",0,208
    #gui.frame.add-child state.load.loadtext
    game.load.set-preload-sprite preloader
    gui.frame.add-child preloader.text
    
    load_load!
    temp.opacity=pixel.canvas.style.opacity
    pixel.canvas.style.opacity=1
    
state.load.create =!->
    gui.frame.remove preloader
    gui.frame.remove preloader.back
    gui.frame.remove preloader.text
    #gui.frame.remove state.load.loadtext
    if switches.portal then switches.portal.loaded=true
    game.state.start 'overworld' false
    cg.kill!
    solidscreen.alpha=0
    load_done!
    pixel.canvas.style.opacity=temp.opacity

musicmap=
    battle: [\battle [\battle.ogg \battle.m4a]]
    '2dpassion': [\2dpassion [\2DPassion.ogg \2DPassion.m4a]]
    towertheme: [\towertheme [\towertheme.ogg \towertheme.m4a]]
    deserttheme: [\deserttheme [\deserttheme.ogg \deserttheme.m4a]]
    hidingyourdeath: [\hidingyourdeath ['Hiding Your Death.ogg' 'Hiding Your Death.m4a']]
    distortion: [\distortion [\distortion.ogg \distortion.m4a]]

!function load_load
    musiclist = zones[getmapdata \zone]musiclist++zones.default.musiclist
    loadlist=[]
    for item in musiclist
        loadlist.push musicmap[item] if !game.cache.checkSoundKey(musicmap[item]0)
    batchload loadlist, \music/ \audio

!function load_done
    musiclist = zones[getmapdata \zone]musiclist++zones.default.musiclist
    #create music
    for item in musiclist
        music.add item, 1 true if !music[item]?

!function mod_music(key,path)
    if(path instanceof Array) then for null,p in path
        path[p]="../"+path[p]
    else
        path="../"+path
    musicmap[key]=[key,path]