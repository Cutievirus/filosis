
mod_scripts.push(
    'mod/madness/items.js'
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
    madness_desert_cp0: "Desert",
    madness_tundra_cp0: "Tundra",
    madness_deadworld_cp0: "Blighted Marsh",
    madness_earth_cp0: "Earth Haven",
};
pentagrams["Abyss"].madness_void_cp0="Bleating Chasm";
pentagrams["Earth"].madness_earth_cp0="Earth Haven";
pentagrams["Dead World"].madness_deadworld_cp0="Blighted Marsh";

// warp_node('madness_city','cp0');

preload_mod.push(function(){
    game.load.image('madness_title', 'mod/madness/title.png');
    batchload([
        ['madness_city_tiles', 'city.png'],
        ['madness_void_tiles', 'void.png'],
    ], 'mod/madness/map/');
    batchload([
        ['madness_1x2_tiles', '1x2.png', 16, 32],
    ], 'mod/madness/map/', 'spritesheet');
    mod_load_map("madness_city", "mod/madness/map/city.json");
    mod_load_map("madness_void", "mod/madness/map/void.json");
});

scenario_mod.push(function(){
    session.madness_llov_dead = switches.llovsick1===4;
    session.madness_llov_died = session.madness_llov_dead || switches.revivalllov;
    session.madness_chikun_alive = switches.llovsick1!==-2 || switches.beat_chikun&&switches.revivalchikun;
    
    if(switches.map==='madness_void'){
        switches.madness_visited=true;
    }
    if(switches.map==='earth' && switches.madness_visited){
        if(pox){pox.kill();} // pox will play a role in the madness
    }
    if(switches.map==='earth3'){
        forNPC('draco',madness_scenario_draco);
    }
    if(switches.map==='earth2') {
        // modify the tileMap
        var maptiles = map.tile_layer.layer.data;
        maptiles[10][59].copy(maptiles[10][58]);
        maptiles[11][60].copy(maptiles[10][58]);
        maptiles[14][60].copy(maptiles[14][59]);
        map.tile_layer.layer.dirty=true;

        forNPC('chikun',madness_scenario_chikun);
    }

});

madness_scenario_draco = function(draco){
    //if(switches.madness && draco){
    //    draco.kill();
    //}
};

madness_scenario_chikun = function(chikun){
    if(party.length>2){
        chikun.x-=3*TS; chikun.y+=4*TS;
        chikun.cancel_movement();
    }
    chikun.interact = function(){
        if(switches.revivalchikun){
            say('chikun',tl("So came for me after all, event after I warned you?"));
            say('chikun',tl("I really don't know why you revived me. I certainly wouldn't do the same for you."));
            say('marb','angry',tl("Watch your tongue, you'll be lucky if we don't kill you again."));
            say('chikun',tl("Right, listen. I've had some time to think about this, and I'm really sorry. I don't know what's wrong with me."));
            say('chikun',tl("I just hope you can find it in your heart to forgive me."));
            say('marb','angry',tl("..."));
            if(switches.marb_tainted){
                say('marb','smile',tl("I understand. I mean, who hasn't eaten a soul or two?"));
            }else if(switches.ebby_tainted){
                say('ebby',tl("The strong devour the weak Chikun-chan, that's just how it is."));
            }else{
                say('llov',tl("Chikun-chan is Llov's friend, so Llov forgives her."));
                say('marb', 'troubled',tl("Don't be absurd Llov, don't you remember what she's done?"));
                if(switches.llov_tainted){
                    say('llov',tl("She was just hungry Marburg, Llov understands."));
                }else{
                    say('llov',tl("..."));
                    if(switches.curefate>0 || switches.humanfate>0){
                        say('ebby',tl("No Marburg, Llov is right. She deserves a second chance."));
                    }else{
                        say('ebby',tl("Marburg is right Llov. You can't forgive her."));
                    }
                }
            }
        }else{
            if(player==llov){
                say('llov','smile',tl("It's Chikun-chan! Llov missed you!"));
                say('marb','angry',tl("Don't talk to her Llov, she's a bad influence."));
            }else{
                say('marb',tl("Oh no, it's the cringy edgelord. What are you doing here?"));
            }
            say('chikun',tl("Hey, no bully. I have feelings too you know?"));
        }
    };
};

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