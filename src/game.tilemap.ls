mapdefaults =
    edges: 'normal'
    outside: false
    spawning: false
    bg: \forest
    hasnight:false
    mobcap:4
    mobtime:7000
    zone:\tuonen
zones=
    default:
        musiclist: [\battle]
        #cg: \cg_pest
    tuonen:
        music: ->if switches.soulcluster then \2dpassion else \towertheme
        musiclist: [\2dpassion \towertheme]
        cg: -> if switches.soulcluster then \cg_tower0 else \cg_tower2
    delta:
        music: ->if switches.soulcluster then \2dpassion else \towertheme
        musiclist: [\2dpassion \towertheme]
        cg: -> if switches.soulcluster then \cg_pest else \cg_pest_night
    tower:
        music: ->if switches.zmapp then \towertheme else \hidingyourdeath
        musiclist: [\towertheme \hidingyourdeath]
        cg: -> if switches.soulcluster then \cg_tower0 else \cg_tower2
    deadworld:
        music: \deserttheme
        musiclist: [\deserttheme]
        cg: \cg_jungle
    earth:
        #music: ->if (switches.map is \lab or switches.map is \labhall) and switches.progress is \towerfall then null else \hidingyourdeath
        music: \hidingyourdeath
        musiclist: [\hidingyourdeath \towertheme]
        cg: \cg_earth
    void:
        music: \distortion
        musiclist: [\distortion]
        cg: \cg_abyss
mapdata =
    hub:
        outside: true
        spawning: Mob.types.slime
        #bg: -> if_in_water \water \forest
        bg: (t)->
            if player.water_depth>0 and t is \water then waterbg!
            else if !switches.soulcluster then \forest_night 
            else \forest
        hasnight:true
        sun: !->
            @scale = x:1 y:1
            return true

    tunnel:
        spawning: Mob.types.ghost
        bg: \dungeon

    tunneldeep:
        spawning: Mob.types.fish
        mobcap:6
        mobtime:6000
        bg: \dungeon

    deadworld:
        edges: \clamp
        outside: true
        bg: (t)->
            if player.water_depth>0 and t is \water then waterbg!
            else \jungle
        mobcap:5
        #spawning: -> Mob.types[(a=<[ghost slime]>)[Math.random!*a.length.|.0]]
        spawning: (tile)->  switch (if tile?properties?terrain then that else \water)
            #|null,false => fallthrough
            |\water =>Mob.types.bat
            |\gravel =>Mob.types[(a=<[slime corpse]>)[Math.random!*a.length.|.0]]
            |_=>Mob.types[(a=<[ghost slime flytrap]>)[Math.random!*a.length.|.0]]
        sun: !->
            @x = 50
            @y = game.height/2 - 50
            @scale = x:0.75 y:0.48
        zone: \deadworld

    deathtunnel:
        zone: \deadworld
        spawning: ->  Mob.types[(a=<[ghost slime slime]>)[Math.random!*a.length.|.0]]
        mobcap:5
        bg: \dungeon
    deathdomain:
        edges: \clamp
        outside: true
        zone: \deadworld
        spawning: ->  Mob.types[(a=<[ghost slime slime]>)[Math.random!*a.length.|.0]]
        mobcap:5
        bg: \jungle
        sun: !->
            @x = 50
            @y = game.height/2 - 50
            @scale = x:0.75 y:0.48
    castle:
        zone: \deadworld
        bg: \castle

    towertop:
        edges: \clamp
        hasnight:true
        bg: \tower
        zone: \tower
    tower0:
        zone: \tower
    tower2:
        zone: \tower
    tower1:
        zone: \tower
        spawning: ->
            if switches.progress is \curebeat then Mob.types.wraith
            else false
        bg: \dungeon
        mobtime: 9000
    ebolaroom:
        zone: \tower

    delta:
        zone: \delta
        outside:true
        bg: (t)->
            if player.water_depth>0 and t is \water then waterbg!
            else if !switches.soulcluster then \forest_night 
            else \forest
        mobcap:5
        mobtime:9000
        hasnight:true
        sun: !->
            @x = game.width/2
            @y = game.height - 30
            @scale = x:0.75 y:0.48
        spawning: (tile)->
            switch (if tile?properties?terrain then that else \water)
            |\water =>Mob.types[(a=<[fish fish wisp arrow]>)[Math.random!*a.length.|.0]]
            |\mountain =>Mob.types[(a=<[arrow arrow arrow slime]>)[Math.random!*a.length.|.0]]
            |_=>Mob.types[(a=<[arrow arrow arrow wisp wisp wisp slime]>)[Math.random!*a.length.|.0]]

    earth:
        zone: \earth
        edges: \clamp
        bg: (t)->
            if t is \snow then \earth_snow
            else \earth
        mobcap:3
        mobtime:9000
        spawning: (tile)->
            switch (if tile?properties?terrain then that else \ground)
            |\snow =>Mob.types.arrow
            |_=>Mob.types.slime

    earth2:
        zone: \earth
        edges: \clamp
        bg: \earth
        spawning: (tile)->
            switch (if tile?properties?terrain then that else \ground)
            |\mountain =>Mob.types.arrow
            |_=>Mob.types.slime

    earth3:
        zone: \earth
        edges: \clamp
        bg: \earth

    basement1:
        zone: \earth
        spawning: Mob.types.slime
        bg: \dungeon
    basement2:
        zone: \earth
        bg: \dungeon

    necrohut:
        zone: \earth
    shrine:
        zone: \earth
    labdungeon:
        zone: \earth
        bg: \lab
        mobcap:3
        mobtime:10000
        spawning: (tile)->
            switch (if tile?properties?terrain then that else \ground)
            |\floor =>Mob.types.slime
            |_=>Mob.types[(a=<[slime slime glitch]>)[Math.random!*a.length.|.0]]
    labhall:
        zone: \earth
        bg: \lab
    lab:
        zone: \earth
        bg: \lab
    void:
        zone: \void
        edges: \clamp
        bg: \void
        outside: true
        mobtime:9000
        spawning: Mob.types.glitch
        sun: !->
            @scale = x:0 y:0

function getmapdata(map, field)
    if not field?
        field = map 
        map = switches.map
    if mapdata[map]?[field]? then that else mapdefaults[field]

function if_in_water(bg1,bg2)
    if player.water_depth>0 then bg1 else bg2

function waterbg
    if (getmapdata \zone) is \deadworld then \water_dead
    else if !switches.soulcluster then \water_night
    else \water

var backdrop, map
tiledata = {}
!function create_backdrop
    if backdrop?
        game.stage.add-child backdrop
        game.stage.set-child-index backdrop, 0
        return
    backdrop := game.add.group null, 'backdrop', true
    game.stage.set-child-index backdrop, 0
    
    backdrop.destroy =!->
        @parent.remove-child @
    
    backdrop.water = water-tile = new Phaser.TileSprite game, 0 0 320 320 'water'
    backdrop.add-child water-tile
    water-tile.margin-x = TS*11
    water-tile.margin-y = TS*12
    water-tile.width = game.width + water-tile.margin-x
    water-tile.height = game.height + water-tile.margin-y
    
    water-tile.timer = Date.now!
    water-tile.psuedo-frame = 0
    water-tile.update =!->
        if game.time.elapsed-since(this.timer) > 333
            this.timer = Date.now!
            if this.psuedo-frame < 3 then this.psuedo-frame++ else this.psuedo-frame = 0
        this.x = -64 - game.camera.x % 64 - this.psuedo-frame*TS #176
        this.y = -64 - game.camera.y % 64 - (game.time.now/100.|.0)*100/70%(TS*4) #128
        
    # the position of the sun's reflection should indicate the direction of ebola-chan's resting place.
    backdrop.sun = sun = backdrop.create game.width/2, 30, 'sun'
    sun.animations.add 'simple', null, 6, true
    sun.animations.play 'simple'
    sun.anchor.set-to 0.5
    sun.update=!->
        if getmapdata \sun
            return unless true is that ...
        return unless nodes.sun
        #@x=player.x - nodes.sun.x
        hgw=game.width/2
        hgh=game.height/2
        x=nodes.sun.x - (game.camera.x+hgw)
        y=nodes.sun.y - (game.camera.y+hgh)
        x=WIDTH*Math.sign(x) if Math.abs(x)>WIDTH
        y=HEIGHT*Math.sign(y) if Math.abs(y)>HEIGHT
        @x=hgw + x/2
        @y=hgh + y/2

!function tile_swap
    return if switches.soulcluster or !(getmapdata \hasnight)
    for tileset in map.tilesets
        n=null
        switch tileset.name
        |\tiles => n=\tiles_night
        |\townhouse => n=\townhouse_tiles_night 
        |\tower => n=\tower_tiles_night 
        |\delta => n=\delta_tiles_night 
        if n
            #tileset.setImage(game.cache.getImage(n,true))
            tileset.setImage(game.cache.getImage(n))
            map.tile_layer.dirty=true;

!function fringe_swap(n)
    return n if switches.soulcluster or !(getmapdata \hasnight)
    switch n 
    |\tiles => return \tiles_night
    |\townhouse_tiles => return \townhouse_tiles_night 
    |\tower_tiles => return \tower_tiles_night
    |\1x1 => return \1x1_night
    |\1x2 => return \1x2_night
    |\delta_tiles => return \delta_tiles_night
    default => return n

!function load_map (name, filename)
    game.load.tilemap name, "maps/#filename", null, Phaser.Tilemap.TILED_JSON
    
!function mod_load_map(name,path)
    game.load.tilemap name, path, null, Phaser.Tilemap.TILED_JSON

function create_map (name)
    map = game.add.tilemap name
    map.named-layers = {}
    for layer in game.cache.getTilemapData(name).data.layers
        switch
        when layer.type is \tilelayer
            map[layer.name] = map.named-layers[layer.name] = map.createLayer layer.name
            if (getmapdata \edges) is \loop then map[layer.name].wrap=true;
        when layer.name is \object_layer
            map.object_cache = layer.objects
    for tileset in game.cache.getTilemapData(name).data.tilesets
        map.add-tileset-image tileset.name, (get_tileset_key tileset.name)
    return map

function get_tileset_key (name)
    tiles="#{name}_tiles"
    return if game.cache.checkImageKey(tiles) then tiles else name

!function create_tilemap
    switches.map=STARTMAP unless game.cache.checkTilemapKey switches.map
    map := create_map switches.map
    override = map.destroy
    map.destroy =!->
        for layer of map.named-layers
            override ...
            map.named-layers[layer]destroy!

    for null, y in map.tile_layer.layer.data
        for tile, x in map.tile_layer.layer.data[y]
            if (tp = tile.properties)terrain is \fringe or tp.terrain is \overpass
                data=getTileData tile
                ftile = new Doodad(x*TS, y*TS, (fringe_swap data.key), null false) |> fringe.add-child
                ftile.crop new Phaser.Rectangle TS*data.tx, TS*data.ty, TS,TS
                if tp.terrain is \overpass
                    updatelist.push ftile
                    ftile.update=!->
                        @visible = player.bridgemode is \under
    tile_swap!
    
function tile_point_collision (o, point, layer, water, land)
    tile_offset_collision o, x: point.x - o.x, y: point.y - o.y, layer, water, land
function tile_offset_collision (o, offset, layer, water, land)
    return unless o.body
    o2 =
        body:
            position: x: o.body.position.x+offset.x, y: o.body.position.y+offset.y
            tile-padding: o.body.tile-padding
            width: o.body.width
            height: o.body.height
        bridgemode: o.bridgemode
    tile_collision o2, layer, water, land, o
function tile_collision (o, layer=map.named-layers.tile_layer, water, land, oo=o)
    return unless o.body
    rect = 
        x: o.body.position.x - o.body.tile-padding.x
        y: o.body.position.y - o.body.tile-padding.y
        w: o.body.width + o.body.tile-padding.x
        h: o.body.height + o.body.tile-padding.y
    rect = clampPosition rect
    tiles = getTiles.call layer, rect, true

    for tile, i in tiles
        return true if not tile_passable tile, water, land, oo
        return true if check_dcol tile, rect, oo
        #if tile?properties.dcol?
        #    dcol = that/\,
        #    for d, i in dcol
        #       dcol[i] = +d
        #    return true if dcol.0>0 and rect_collision rect, x: tile.left, y: tile.top, w: tile.width, h: dcol.0
        #    return true if dcol.1>0 and rect_collision rect, x: tile.right - dcol.1, y: tile.top, w: dcol.1, h: tile.height
        #    return true if dcol.2>0 and rect_collision rect, x: tile.left, y: tile.bottom - dcol.2, w: tile.width, h: dcol.2
        #    return true if dcol.3>0 and rect_collision rect, x: tile.left, y: tile.top, w: dcol.3, h: tile.height
    return false

function check_dcol(tile,rect, o=player)
    return false unless tile
    if tile.properties.terrain is 'fringe' or tile.properties.terrain is \overpass and o.bridgemode is \under
        if (fc=tile.properties.fringe_check)
            fc=fc/\,
            fc.x=+fc.0; fc.y=+fc.1
            return  check_dcol map.getTile(tile.x+fc.x,tile.y+fc.y,map.tile_layer), x:rect.x+fc.x*TS, y:rect.y+fc.y*TS, w:rect.w,h:rect.h, o
        else if tile.properties.dcol is '0,1,0,1'
            return  check_dcol map.getTile(tile.x+1,tile.y,map.tile_layer), x:rect.x+TS, y:rect.y, w:rect.w,h:rect.h, o
        else
            return  check_dcol map.getTile(tile.x,tile.y - 1,map.tile_layer), x:rect.x, y:rect.y - TS, w:rect.w,h:rect.h, o
    if tile.properties.dcol #and !(tile.properties.terrain is \overpass and player.bridgemode is \under)
        dcol = tile.properties.dcol/\,
        for d, i in dcol
           dcol[i] = +d
        return true if dcol.0>0 and rect_collision rect, x: tile.left, y: tile.top, w: tile.width, h: dcol.0
        return true if dcol.1>0 and rect_collision rect, x: tile.right - dcol.1, y: tile.top, w: dcol.1, h: tile.height
        return true if dcol.2>0 and rect_collision rect, x: tile.left, y: tile.bottom - dcol.2, w: tile.width, h: dcol.2
        return true if dcol.3>0 and rect_collision rect, x: tile.left, y: tile.top, w: dcol.3, h: tile.height
    return false

function getTiles (rect, returnnull = true)
    tx=Math.floor rect.x/TS
    ty=Math.floor rect.y/TS
    tw=Math.ceil((rect.x+rect.w)/TS)-tx
    th=Math.ceil((rect.y+rect.h)/TS)-ty
    results=[]
    for yy from ty til ty+th
        for xx from tx til tx+tw
            #row = @layer.data[yy]
            #if row and row[xx] then results.push row[xx]
            #else if returnnull then results.push null
            results.push(map.getTile(xx,yy,map.tile_layer,!returnnull));
    return results

override_getTile = Phaser.Tilemap::getTile
Phaser.Tilemap::getTile=(x,y,layer,nonNull=false)!->
    {x,y} = clampPosition(x:x,y:y,true)

    return override_getTile ...

function clampPosition (p,tilemode)
    m = if tilemode then 1 else TS
    switch getmapdata \edges
    |\loop
        if p.y>=map.height*m then p.y%=map.height*m
        else while p.y<0 then p.y += map.height*m
        if p.x>=map.width*m then p.x%=map.width*m
        else while p.x<0 then p.x += map.width*m
    |\clamp
        if p.y>=map.height*m then p.y=map.height*m - 1
        else if p.y<0 then p.y=0
        if p.x>=map.width*m then p.x=map.width*m - 1
        else if p.x<0 then p.x=0
    return p

function tile_passable (tile, water=switches.water_walking, land=true, o=player)
    if not tile? or tile is false or not tile.properties.terrain?
        return water and switches.outside
    if tile.properties.terrain is 'water'
        return water
    if tile.properties.terrain is 'overpass' and (fc=tile.properties.fringe_check) and o.bridgemode is \under
        fc=fc/\,
        fc.x=+fc.0; fc.y=+fc.1
        return tile_passable(map.getTile(tile.x+fc.x, tile.y+fc.y, map.tile_layer), water, land, o)
    if tile.properties.terrain is 'overpass' and tile.properties.dcol is '0,1,0,1' and o.bridgemode is \under
        return tile_passable(map.getTile(tile.x+1, tile.y, map.tile_layer), water, land, o)
    if tile.properties.terrain is 'fringe' or tile.properties.terrain is 'overpass' and o.bridgemode is \under
        return tile_passable(map.getTile(tile.x, tile.y - 1, map.tile_layer), water, land, o)
    return false if tile.properties.terrain is 'wall'
    return false if (getmapdata \edges) is \clamp and
        (tile.x is 0 or tile.x is map.width - 1 or tile.y is 0 or tile.y is map.height - 1)
    return false if tile.properties.terrain is 'mountain' and getTileUnder(o)?properties.terrain is \overpass and o.bridgemode is \under
    return land

!function getTileUnder(o)
    #if (getmapdata \edges) is \loop
    #    return (getTiles.call map.tile_layer, x:o.x, y:o.y, w:0, h:0).0
    #else
    return map.getTile(Math.floor(o.x/TS), Math.floor(o.y/TS), map.tile_layer, true)

/* #UNUSED
function tile_line (p1, p2)
    #returns all tiles along a line betwixt two points
    if p1.worldX? then p1 = x: p1.x, y: p1.y
    else p1 = x: Math.floor(p1.x/TS), y: Math.floor(p1.y/TS)
    if p2.worldX? then p2 = x: p2.x, y: p2.y
    else p2 = x: Math.floor(p2.x/TS), y: Math.floor(p2.y/TS)
    while p1.x is not p2.x and p1.y is not p2.y
        tile = map.get-tile p1.x, p1.y, map.tile_layer, true
        return false if !tile
        return false unless tile_passable tile
        return false if tile.properties.dcol?
        dist = x: p2.x - p1.x, y: p2.y - p1.y
        if Math.abs(dist.x) > Math.abs(dist.y)
            p1.x += Math.sign dist.x
        else
            p1.y += Math.sign dist.y
    #end when we're at the end point
    return true
*/

/*
gettilesoverride=Phaser.TilemapLayer::getTiles
Phaser.TilemapLayer::getTiles=!(x, y, width, height, collides=false, interestingFace=false)->
    #return null
    #return gettilesoverride ...
    fetchAll = not(collides or interestingFace)
    x=@_fixX x
    y=@_fixY y
    tx=Math.floor x/@_mc.cw*@scale.x
    ty=Math.floor y/@_mc.ch*@scale.y
    tw=(Math.ceil (x+width)/@_mc.cw*@scale.x) - tx
    th=(Math.ceil (y+height)/@mc.ch*@scale.y) - ty
    while @_results.length
        @_results.pop!
    for wy from ty til ty+th
        for wx from tx til tx+tw
            if wx<0 then wx=0
            else if wx>=@map.width then wx=@map.width - 1
            if wy<0 then wy=0
            else if wy>=@map.height then wy=@map.height - 1
            row=@layer.data[wy]
            if row && row[wx]
                if fetchAll or row[wx].isInteresting collides interestingFace
                    @_results.push row[wx]
    return @_results.slice!
*/

renderregionoverride=Phaser.TilemapLayer::renderRegion
Phaser.TilemapLayer::renderRegion=(scrollX,scrollY,left,top,right,bottom)!->
    if (getmapdata \edges) is \loop then return renderregionoverride ...
    context=@context
    width=@layer.width
    height=@layer.height
    tw=@_mc.tileWidth
    th=@_mc.tileHeight
    tilesets=@_mc.tilesets
    lastAlpha=NaN
    if not @_wrap and (getmapdata \edges) is not \clamp
        if left <= right
            left=Math.max 0,left
            right=Math.min width - 1,right
        if top <= bottom
            top = Math.max 0,top
            bottom = Math.min height - 1,bottom
    baseX=left*tw - scrollX
    baseY=top*th - scrollY
    #normStartX=(left+(1.<<.20)*width)%width
    #normStartY=(top+(1.<<.20)*height)%height
    normStartX=left
    normStartY=top

    #log left,top,right,bottom

    context.fillStyle=@tileColor
    y=normStartY; ymax=bottom - top; ty = baseY;
    while ymax >= 0
        #if y>=height then y -= height
        ##NEW
        yy=y
        if yy>=height then yy=height - 1
        else if yy<0 then yy=0
        ##
        row = @layer.data[yy]
        x=normStartX; xmax = right - left; tx=baseX
        while xmax>=0
            #if x>=width then x -= width
            ##NEW
            xx=x
            if xx>=width then xx=width - 1
            else if xx<0 then xx=0
            ##
            tile = row[xx]
            if !tile or tile.index < 0
                x++; xmax--; tx += tw
                continue
            index = tile.index
            set = tilesets[index]
            if set is undefined
                set = @resolveTileset index
            if tile.alpha is not lastAlpha and not @debug
                context.globalAlpha = tile.alpha
                lastAlpha = tile.alpha
            if set
                if tile.rotation or tile.flipped
                    context.save!
                    context.translate tx + tile.centerX, ty +tile.centerY
                    context.rotate tile.rotation
                    if tile.flipped
                        context.scale -1, 1
                    set.draw context, -tile.centerX, -tile.centerY, index
                    context.restore!
                else
                    set.draw context, tx, ty, index
            else if @debugSettings.missingImageFill
                context.fillStyle=@debugSettings.missingImageFill
                context.fillRect tx, ty, tw, th
            if tile.debug and this.debugSettings.debuggedTileOverfill
                context.fillStyle = @debugSettings.debuggedTileOverfill
                context.fillRect tx, ty, tw, th

            x++; xmax--; tx += tw

        y++; ymax--; ty += th