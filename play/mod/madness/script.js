
mod_scripts.push(
    'mod/madness/items.js',
    'mod/madness/characters.js',
    'mod/madness/scenario.js',
);

mod_music('madness_citytheme','mod/madness/music/nogoldenrules.ogg');
mod_music('madness_undertheflesh','mod/madness/music/undertheflesh.ogg');

zones.madness={
    music: "madness_citytheme",
    musiclist: ["madness_citytheme","madness_undertheflesh"],
    //cg: "madness_cg",
    cg: "cg_jungle",
};

mapdata.madness_city={
    zone:"madness",
    bg: "dungeon",
    edges: "loop",
};
mapdata.madness_void=Object.assign({},mapdata.void,{
    edges: "loop",
});

pentagrams["Mad Realm"]={
    madness_void_cp0: "Bleating Chasm",
    madness_city_cp0: "The City",
    madness_desert_cp0: "Desert Plains",
    madness_desert_cp1: "Desert Pit",
    madness_undersea_cp0: "Desert Oasis",
    //madness_tundra_cp0: "Tundra",
    madness_earth_cp0: "Earth Haven",
    madness_undersea_cp1: "Earth Sea",
};

// warp_node('madness_city','cp0');

preload_mod.push(function(){
    game.load.image('madness_title', 'mod/madness/title.png');
    batchload([
        ['madness_city_tiles', 'city.png'],
        ['madness_void_tiles', 'void.png'],
        ['madness_desert_tiles', 'desert.png'],
        ['madness_undersea_tiles', 'undersea.png'],
    ], 'mod/madness/map/');
    batchload([
        ['madness_1x1_tiles', '1x1.png', 16, 16],
        ['madness_1x2_tiles', '1x2.png', 16, 32],
        ['madness_3x3_tiles', '3x3.png', 48, 48],
    ], 'mod/madness/map/', 'spritesheet');
    mod_load_map("madness_city", "mod/madness/map/city.json");
    mod_load_map("madness_void", "mod/madness/map/void.json");
    mod_load_map("madness_desert", "mod/madness/map/desert.json");
    mod_load_map("madness_undersea", "mod/madness/map/undersea.json");
    mod_load_map("madness_earth", "mod/madness/map/earth.json");
});


/*
state.title.create = override(state.title.create, function(){
    var madness_title = new Phaser.Image(game, 59, 70, 'madness_title');
    var logo;
    for(var i=0;i<gui.title.children.length;++i){
        if(gui.title.children[i].key=='logo'){ logo=gui.title.children[i]; }
    }
    logo.addChild(madness_title);
});
*/


madness_undying = undying;
undying=function(monster){
    if(monster.attributes.includes('mortal')){ return false; }
    return madness_undying(monster);
};

// "Chikungunya's tortured soul fractured into 1000 pieces."
// "The souls of Malaria and Smallpox were recovered."