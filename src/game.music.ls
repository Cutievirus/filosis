class Audio
    ->
        @volume = 0.5
        @volumes = {}
        @sounds = []
        @lastplayedtime=Date.now!
        @lastplayedsound=null
    @volume = 1.0
    add: (key, volume=1, looping=false)!->
        @sounds.push <| sound = @[key] = game.sound.add key, volume, looping 
        @volumes[key] = volume
        sound.onLoop.add -> @play!
        , sound
    play: (name, settime)!->
        return unless (sound = @[name])?
        sound.play null null @volumes[name]*@volume*Audio.volume, sound.loop
        @lastplayedtime=Date.now! if settime
        @lastplayedsound=sound
    playifnotplaying: (name)!->
        return if !@[name]? or @[name]isPlaying
        @stop!
        @play name
    stop: !->
        for sound in @sounds
            sound.stop!
    refresh: !->for sound in @sounds
        @play sound.key if sound.isPlaying
    fadeOut: (d)!-> for sound in @sounds 
        sound.fadeOut d if sound.isPlaying
    fadeIn: (name, d)!->
        sound = @[name]
        sound.play null null 0 sound.loop
        sound.fadeTo d, @volumes[name]*@volume*Audio.volume
    updatevolume:!->
        return unless @lastplayedsound
        @lastplayedsound.volume=@volumes[@lastplayedsound.name]*@volume*Audio.volume

        
sound = new Audio!
music = new Audio!
menusound = new Audio!
voicesound = new Audio!

!function create_audio
    #music.add \battle 1 true
    menusound.add \blip 0.5
    voicesound.add \blip 0.5
    sound.add \itemget
    sound.add \encounter 
    sound.add \boom
    sound.add \defeat
    sound.add \candle
    sound.add \strike
    sound.add \flame
    sound.add \water
    sound.add \swing
    sound.add \laser
    sound.add \run
    sound.add \stair
    sound.add \door
    sound.add \groan
    sound.add \voice 0.5
    voicesound.add \groan
    voicesound.add \voice 0.5
    voicesound.add \voice2 0.5
    voicesound.add \voice3 0.5
    voicesound.add \voice4 0.5
    voicesound.add \voice5 0.5
    voicesound.add \voice6 0.5
    voicesound.add \voice7 0.5
    voicesound.add \voice8 0.5
    voicesound.add \rope 0.5

!function zonemusic
    return if switches.nomusic
    if (access zones[getmapdata \zone].music) then music.playifnotplaying that
    #switch getmapdata \zone
    #|\tuonen
    #    music.playifnotplaying if switches.soulcluster
    #        then \2dpassion else \towertheme
    #|\tower
    #    music.playifnotplaying if switches.zmapp
    #        then \towertheme else \hidingyourdeath
    #|\deadworld
    #    music.playifnotplaying \deserttheme
    #|\earth
    #    music.playifnotplaying \hidingyourdeath