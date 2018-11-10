class Transition
    (@duration,@step,@finish,@smoothness=0,@cinematic=true,@context1=@,@context2=@)->
        @starttime=Date.now!
        @@list.push @
        #@cinema_state=switches.cinema
        #cinema_start! if @cinematic
        #@smoothness=0
    @list = []
    @update=!->
        #console.log "Updating"
        for item in @@list by -1
            item.update!
    update:!->
        t = (Date.now! - @starttime) / @duration
        t = (t*@smoothness.|.0)/@smoothness if @smoothness > 0
        @step?call @context1, 1 <? t
        #console.debug t, @duration
        if t >= 1
            #set_cinema(@cinema_state) if @cinematic
            @@list.splice @@list.indexOf(@), 1
            @finish?call @context2

    @timeout=(dur,fin,cinematic=false,context)!->
        transition = new Transition dur, null, fin, null, cinematic, null, context

    @battle=(dur1, dur2, smoothness=5)!->
        sound.play \encounter
        transition = new Transition dur1, (t)->
            scale = t*5+1
            rot = t*45
            pixel.canvas.style.transform = "scale(#{scale},#{scale}) rotate(#{rot}deg)"
            pixel.canvas.style.opacity = -Math.pow(t,4)+1
        , ->
            pixel.canvas.style.opacity = 0
            setTimeout !->
                pixel.canvas.style.transform = ""
                start_battle2!
                new Transition dur2, (t)->
                    pixel.canvas.style.opacity = t
                ,null, smoothness
            ,500
        ,smoothness
        transition.dur2 = dur2
        return transition

    @critical=(amplitude,duration,cx,cy)!->
        pixel.canvas.style.transform-origin=(cx*100/WIDTH.|.0)+'% '+(cy*100/HEIGHT.|.0)+'%'
        transition = new Transition duration, (t)->
            scale=1+(Math.sin Math.PI*t)*amplitude
            pixel.canvas.style.transform = "scale(#{scale},#{scale})"
        ,->
            pixel.canvas.style.transform = ''
            pixel.canvas.style.transform-origin=''
        ,0,false

    @fade=(fadetime, sleeptime, midcall, fincall, smoothness, cinematic, context)!->
        transition = new Transition fadetime, (t)->
            pixel.canvas.style.opacity = 1 - t
        , ->
            @midcall.call @context3 if typeof @midcall is \function
            #setTimeout ~>
            Transition.timeout @sleeptime, ~>
                transition2 = new Transition @fadetime, (t)->
                    pixel.canvas.style.opacity = t
                , ->
                    @fincall.call @context3 if typeof @fincall is \function
                ,@smoothness, @cinematic
                transition2.context3 = @context3
                transition2.fincall = @fincall
            ,cinematic
            #,@sleeptime
        , smoothness, cinematic
        transition.midcall = midcall
        transition.fincall = fincall
        transition.fadetime = fadetime
        transition.sleeptime = sleeptime
        transition.context3 = context or transition
        return transition

    @shake=(amplitude, wavelength, duration, decay=1, fincall, cinematic, context)!->
        #pos = x:game.camera.center.x, y:game.camera.center.y
        time = 0
        #cinema_state=switches.cinema
        #cinema_start! if cinematic
        setTimeout shakeit, 200

        !function shakeit
            if time >= duration
                #camera_center pos.x, pos.y
                pixel.canvas.style.transform = ""
                #set_cinema(@cinema_state) if cinematic
                fincall?call context
                return
            p = x:Math.random!-0.5, y:Math.random!-0.5
            p = normalize p
            #camera_center pos.x+p.x*amplitude, pos.y+p.y*amplitude
            pixel.canvas.style.transform = "translate(#{p.x*amplitude*pixel.scale}px,#{p.y*amplitude*pixel.scale}px)"
            amplitude *= decay
            time += wavelength
            setTimeout shakeit, wavelength

    @wiggle=(o, times, delay, shift=1, fincall)!->
        if times > 0
            o.x += shift
            setTimeout ~> @wiggle o, times - 1, delay, shift*-1, fincall
            ,delay
        else fincall!

    @fadeout=(o, duration, fincall, context)!->
        transition = new Transition duration, (t)->
            @alpha = 1 - t
        , fincall
        , null, false, o, context or transition
        return transition

    @fadein=(o, duration, fincall, context)!->
        transition = new Transition duration, (t)->
            @alpha = t
        , fincall
        , null, false, o, context or transition
        return transition

    @move=(o,dest, duration, fincall)!->
        origin=x:o.x,y:o.y
        transition = new Transition duration, (t)->
            @x=(dest.x - origin.x)*t+origin.x
            @y=(dest.y - origin.y)*t+origin.y
        ,fincall,null,false,o,o
        return transition

    @pan=(dest, duration,fincall,context,cinematic=false)!->
        origin=x:game.camera.center.x, y:game.camera.center.y
        transition = new Transition duration, (t)->
            camera_center origin.x+(dest.x - origin.x)*t, origin.y+(dest.y - origin.y)*t
        ,fincall,null,cinematic,context,context
        return transition