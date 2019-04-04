old_phaser_parseTiledJSON=Phaser.TilemapParser.parseTiledJSON
Phaser.TilemapParser.parseTiledJSON=(json)!->
    for tileset in json.tilesets
        continue unless tileset.tiles instanceof Array
        properties=tileset.tileproperties={}
        for tile in tileset.tiles
            properties[tile.id]={}
            for property in tile.properties
                properties[tile.id][property.name]=property.value

    map = old_phaser_parseTiledJSON ...
    window.mapjson=json
    return map