
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
mapdata.madness_desert={
    zone:"deadworld",
    bg: "jungle",
    edges: "loop",
    filters:function(){return [madness_water_filter];},
};
mapdata.madness_earth={
    zone:"madness",
    bg: "jungle",
    edges: "clamp",
    filters:function(){return [madness_water_filter];},
};
mapdata.madness_undersea={
    zone:"madness",
    bg: "jungle",
    edges: "clamp",
    filters:function(){return [madness_undersea_filter];},
};
mapdata.madness_undersea.battle_filters=mapdata.madness_undersea.filters;

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
        ['madness_undersea_light', 'undersea_light.png'],
    ], 'mod/madness/map/');
    batchload([
        ['madness_1x1', '1x1.png', 16, 16],
        ['madness_1x2', '1x2.png', 16, 32],
        ['madness_3x3', '3x3.png', 48, 48],
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

madness_hextovec4=function(hex){
    const r = hex>>16;
    const g = hex>>8&255;
    const b = hex&255;
    return `vec4(${r/255},${g/255},${b/255},1.0)`;
};

init_mod.push(function(){
    madness_undersea_filter = new Phaser.Filter(game,null,`
    precision mediump float;
    uniform float     time;
    uniform vec2      resolution;
    uniform sampler2D iChannel0;
    void main( void ) {
        vec2 uv = gl_FragCoord.xy / resolution.xy;
        uv.x += cos(uv.y+time)*0.01 - cos(uv.x-time*0.7)*0.01 - sin(uv.x+time*4.7)*0.005;
        uv.y += sin(uv.x+time*0.7)*0.01 - cos(uv.y-time*0.47)*0.01 - cos(uv.y+time*4.0)*0.005;
        vec4 base = ( texture2D(iChannel0, uv) + texture2D(iChannel0, uv-0.5/resolution.xy) )/ 2.0;
        vec4 blend = vec4(0.576, 0.651, 0.733, 1.0) +sin(uv.x*10.0+time)*0.2+cos(uv.y*10.7+time)*0.2;
        float average = (base.r+base.g+base.b)/3.0;
        vec4 colorized = vec4(average,average,average,1.0)*blend*2.0;
        gl_FragColor = mix(base,colorized,0.5);
    }
    `);
    madness_water_filter = new Phaser.Filter(game,null,`
    precision mediump float;
    uniform float     time;
    varying vec2      vTextureCoord;
    uniform sampler2D uSampler;
    uniform vec2      resolution;
    bool colorMatch ( in vec4 c1, in vec4 c2, in float thresh){
        return abs(c1.r-c2.r)<thresh
            && abs(c1.g-c2.g)<thresh
            && abs(c1.b-c2.b)<thresh;
    }
    bool colorMatch ( in vec4 c1, in vec4 c2){
        return colorMatch(c1,c2,0.1);
    }
    void main( void ) {
        vec2 coord = vTextureCoord;
        float wave = (sin(coord.x*20.0+time*3.5)+cos(coord.y*20.0+time*3.7))/2.0;
        float wave2 = (cos(coord.x*20.0+time*1.5)+sin(coord.y*20.0+time*1.7))/2.0;
        vec2 adjacent = vec2(coord.x+wave/resolution.x,coord.y+wave2/resolution.y);
        vec4 white = vec4(1.0,1.0,1.0,1.0);
        vec4 blue = ${madness_hextovec4(0x58e1d4)};
        vec4 blue2 = ${madness_hextovec4(0x2ab29e)};
        vec4 color = texture2D(uSampler, coord);
        vec4 adjcolor = texture2D(uSampler, adjacent);
        gl_FragColor = color==white
        && (colorMatch(adjcolor,blue)||colorMatch(adjcolor,blue2))
        || colorMatch(color,blue)&&colorMatch(adjcolor,blue2) ? 
            mix(adjcolor,color,
            0.6-abs(wave)*0.4
            )
        :color;
    }
    `);
});

madness_undersea_light_filter=function(dood){
    var filter;
    if(madness_undersea_light_filter.filter){
        filter = madness_undersea_light_filter.filter;
    }else{
        var uniforms = null;
        filter = new Phaser.Filter(dood.game,uniforms,`
        precision mediump float;
        uniform float     time;
        varying vec2      vTextureCoord;
        uniform sampler2D uSampler;
        uniform vec2      resolution;
        void main( void ) {
            vec2 coord = vTextureCoord;
            coord.x += cos(coord.y*7.0+time)*0.1/resolution.x - cos(coord.x+time*0.47)*0.2/resolution.x;
            coord.y += sin(coord.x*9.7+time)*0.4/resolution.y - cos(coord.y+time*0.40)*0.2/resolution.y;
            vec4 texColor = texture2D(uSampler, coord);
            gl_FragColor = texColor;
        }
        `);
        filter.setResolution(dood.width,dood.height);
        madness_undersea_light_filter.filter = filter;
    }
    dood.filters = [filter];
    madness_undersea_light_filter.dood = dood;
};

update_mod.push(function(){
    /*
    if(game.world.filters && game.world.filters.includes(madness_undersea_filter)){
        madness_undersea_filter.setResolution(game.width,game.height);
        madness_undersea_filter.update();
    }
    */
    if(madness_undersea_light_filter.dood && madness_undersea_light_filter.dood.alive){
        madness_undersea_light_filter.filter.update();
    }
});


madness_undying = undying;
undying=function(monster){
    if(monster.attributes.includes('mortal')){ return false; }
    return madness_undying(monster);
};

// "Chikungunya's tortured soul fractured into 1000 pieces."
// "The souls of Malaria and Smallpox were recovered."