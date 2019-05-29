preload_mod.push(function(){
    game.load.image('madness_title', 'mod/madness/title.png');
    batchload([
        ['madness_legionella_port', 'legionella_port.png'],
        ['madness_remedy_port', 'remedy_port.png'],
    ], 'mod/madness/img/');
    batchload([
        ['madness_legionella_char', 'legionella_char.png',22,25],
        ['madness_remedy_char', 'remedy_char.png',22,25],
    ], 'mod/madness/img/', 'spritesheet');
});

speakers.madness_legionella = {
    display:'Legionella',
    default:'madness_legionella_port',
    voice: 'voice8'
};
speakers.madness_remedy = {
    display:'Star Witch Remedy-chan',
    default:'madness_remedy_port',
    voice: 'voice'
};