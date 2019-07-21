
mod_initmap.push(function(){
    if (!switches.beat_game){ return; }
    if(switches.map in madness_mapinits){
        madness_mapinits[switches.map]();
    }
});

madness_mapinits={};

madness_mapinits.earth2=function(){
    madness_create_portal(nodes.chikun.x-3*TS, nodes.chikun.y+4*TS,"madness_void","earth");
};
madness_mapinits.earth3=function(){
    madness_create_portal(nodes.cp.x+4*TS, nodes.cp.y - 8*TS,"madness_void","meadow");
};
madness_mapinits.tunneldeep=function(){
    madness_create_portal(64,656,"madness_void","sewers");
};
madness_mapinits.deathdomain=function(){
    madness_create_portal(752,146,"madness_void","deadworld");
};

scenario_mod.push(function(){
    //game.world.filters = access(getmapdata('filters'));
    if (!switches.beat_game){ return; }
    session.madness_llov_dead = switches.llovsick1===4;
    session.madness_llov_died = session.madness_llov_dead || switches.revivalllov;
    session.madness_chikun_alive = switches.llovsick1!==-2 || switches.beat_chikun&&switches.revivalchikun;
    session.madness_pox_dead = switches.dead==='malpox';

    if(switches.map in madness_scenarios){
        madness_scenarios[switches.map]();
    }
});

madness_scenarios={};
madness_scenarios.madness_void=function(){
    switches.madness_visited=true;
};
madness_scenarios.earth=function(){
    if(switches.madness_visited){
        if(pox){pox.kill();} // pox will play a role in the madness
    }
};
madness_scenarios.earth2=function(){
    // modify the tileMap
    var maptiles = map.tile_layer.layer.data;
    maptiles[10][59].copy(maptiles[10][58]);
    maptiles[11][60].copy(maptiles[10][58]);
    maptiles[14][60].copy(maptiles[14][59]);
    map.tile_layer.layer.dirty=true;

    forNPC('chikun',madness_scenario_chikun);
};
madness_scenarios.earth3=function(){
    forNPC('draco',madness_scenario_draco);
};

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
            if(switches.marb_tainted || switches.ebby_tainted){
                if(switches.marb_tainted){
                    say('marb','smile',tl("I understand. I mean, who hasn't eaten a soul or two?"));
                }
                if(switches.ebby_tainted){
                    say('ebby',tl("The strong devour the weak Chikun-chan, that's just how it is."));
                }
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

mod_doodads.push(function(object){
    switch (object.type){
    case 'madness_portal':
        madness_create_portal(object.x,object.y,object.properties.map,object.name);
        return true;
    case 'madness_undersea_light':
        dood = new Doodad(object.x+HTS, object.y+TS, 'madness_undersea_light', null, false);
        fringe.addChild(dood);
        dood.anchor.set(0.5,1.0);
        initUpdate(dood);
        madness_undersea_light_filter(dood);
        dood.alpha=0.4;
        return true;
    }
    return false;
});

function madness_create_portal(x,y,mapname,portalname){
    nodes["madness_portal_"+portalname] = {x:x,y:y+TS};
    // new Doodad object.x, object.y+TS, sheet, null, collide |> actors.add-child
    var portal = new Doodad(x+HTS,y+TS,'madness_1x2',null,true);
    portal.anchor.set(0.5,1);
    portal.body.setSize(TS,TS);
    portal.frame=3;
    portal.interact=function(){
        warp_node(mapname,"madness_portal_"+portalname,'down');
    };
    actors.addChild(portal);
}