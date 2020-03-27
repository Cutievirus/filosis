preload_mod.push(function(){
    game.load.image('madness_title', 'mod/madness/title.png');
    batchload([
        ['madness_battle_bunny', 'monster_bunny.png'],
        ['madness_battle_fish', 'monster_fish.png'],
        ['madness_battle_flower', 'monster_flower.png'],
        ['madness_madhybrid', 'madhybrid.png'],
    ], 'mod/madness/img/');
});


Monster.types.madness_bunny = {
    name: 'Scabbit',
    key: 'madness_battle_bunny',
    skills: [skills.hemorrhage],
    attributes: ['carnivore'],
    drops:[
        {item:'silverdust', chance:20, quantity:1},
        {item:'silverdust', chance:20, quantity:1},
        {item:'meat', chance:80, quantity:1},
        {item:'fur', chance:100, quantity:1},
        {item:'fur', chance:50, quantity:1},
        {item:'starpuff', chance:16, quantity:1},
    ],
    xp: 110,
    atk: 100,
    speed: 160,
    hp:100,
    def:100,
};

Monster.types.madness_fish = {
    name: 'Depth Dweller',
    key: 'madness_battle_fish',
    skills: [skills.strike,skills.drown],
    attributes: ['fish','carnivore'],
    drops:[
        {item:'silverdust', chance:40, quantity:1},
        {item:'frozenflesh', chance:100, quantity:1},
        {item:'frozenflesh', chance:40, quantity:1},
        {item:'starpuff', chance:20, quantity:1},
    ],
    xp: 120,
    atk: 120,
    speed: 110,
    hp:100,
    def:100,
};

Monster.types.madness_flower = {
    name: 'Cactulace',
    key: 'madness_battle_flower',
    skills: [skills.strike,skills.burn],
    attributes: ['plant'],
    drops:[
        {item:'plantfiber', chance:100, quantity:1},
        {item:'plantfiber', chance:66, quantity:1},
        {item:'plantfiber', chance:33, quantity:1},
        {item:'aloevera', chance:100, quantity:1},
        {item:'aloevera', chance:66, quantity:1},
        {item:'aloevera', chance:33, quantity:1},
        {item:'starpuff', chance:20, quantity:1},
        {item:'cinder', chance:80, quantity:1},
        {item:'cinder', chance:50, quantity:1},
        {item:'cinder', chance:20, quantity:1},
    ],
    xp: 130,
    atk: 150,
    speed: 80,
    hp:200,
    def:150,
};

Monster.types.madness_hybrid = {
    name: 'Mad Cow',
    key: 'madness_madhybrid',
    skills: [skills.strike],
    drops:[
        {item:'cinder', chance:100, quantity:5}
    ],
    xpwell: 1000,
    xpkill: 100,
    atk: 125,
    speed: 150,
    hp:450,
    def:300,
    ai:function(){},
};
