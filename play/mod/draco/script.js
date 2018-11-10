
preload_mod.push(function(){
    game.load.spritesheet('draco', 'mod/draco/char.png', 20, 25);
    game.load.image('draco_port', 'mod/draco/port.png');
    game.load.image('draco_battle', 'mod/draco/battle.png');
    game.load.spritesheet('draco_alarm', 'mod/draco/alarm.png', 16, 16);
});

scenario_mod.push(function(){
    if(!(switches.map=='earth3' && switches.beat_game)) { return; }
    var draco = new NPC(nodes.cp.x - HTS, nodes.cp.y - TS*6, 'draco');
    draco.face("down");
    draco.interact = draco_interact;
    if (temp.draco_beat){
        say('draco', tl("I'll admit, you're stronger than I anticipated."));
        say('draco', tl("I'm sorry to say there's no reward for beating me though."));
    }
});

function draco_interact(){
    if (!switches.draco_beat){
        say('draco', tl("Don't worry, I don't intend on picking a fight with you."));
        say('marb', tl("What's wrong? are you scared?"));
        say('draco', tl("Don't kid yourself. I'm way stronger than Zmapp you know."));
        menu(tl("Fight"),function(){
            say ('marb', tl("Stronger than Zmapp? That's not saying much."));
            say ('draco', tl("Fine then. see for yourself."));
            say (function(){start_battle(encounter.draco);});
        },tl("Don't Fight"),function(){ });
    }else{
        draco_talk();
    }
}
function draco_talk(){
    say ('ebby', tl("What are you doing out here?"));
    say ('draco', tl("War told you about the goop right?"));
    say ('ebby', tl("She said it was some kind of bio-weapon."));
    say ('draco', tl("They were my sisters. I'm visiting their grave."));
    if (party.indexOf(llov)>=0){
        say ('llov', tl("Llov doesn't understand. What do you mean?"));
        say ('draco', tl("What do you think is the main difference between a Cure and a Virus?"));
        say ('llov', tl("Llov knows. Cure is a meanie!"));
        say ('marb', tl("Viruses kill humans. Cures save them."));
        say ('draco', tl("Valid, but it's not the answer I'm looking for."));
        say ('draco', tl("Cures are artificial gods. We were created by humans, and were once human ourselves."));
        say ('draco', tl("But not all of us survived the transformation."));
        say ('draco', tl("They were consumed by the madness, and their bodies twisted into what you see now."));
    }{
        say ('ebby', 'concern', tl("I see... I'm so sorry."));
    }
}

speakers.draco = {display:'Draco', default:'draco_port' ,voice: 'voice8' };

Monster.types.draco = {
    name: 'Draco',
    key: 'draco_battle',
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
    trigger:function(){},
    ai:function(){
        if (this.has_buff(buffs.draco_timerbomb)){ return skills.draco_reflect; }
        // loop through my buffs
        var mybufflength=0;
        var skilllist=[];
        for (var i=0; i<this.buffs.length; i++) {
            if (this.buffs[i].base !== buffs.null){
                skilllist.push(skills.draco_reflect);
                mybufflength++;
            }
        }
        // loop through enemies
        var enemylist = enemy_list();
        for (i=0; i < enemylist.length; i++) {
            var enemy = enemylist[i];
            // loop through buffs
            for (var j=0; j < enemy.buffs.length; j++) {
                if (enemy.buffs[j].base === buffs.null) {
                    if (mybufflength>0){
                        skilllist.push(skills.draco_reflect);
                    }
                    skilllist.push(skills.draco_timerbomb);
                }else{
                    skilllist.push(skills.hex);
                }
            }
        }
        if (skilllist.length===0){ return null; }
        return skilllist[Math.floor(Math.random() * skilllist.length)];
    }
};

encounter.draco ={
    monsters : [{id:'draco', x:0, y:0, l1:0, l2:Infinity}],
    onvictory: function(){
        switches.draco_beat=true;
        temp.draco_beat=true;
    }
};

skills.draco_reflect = new Skill({
    id:'draco_reflect',
    name: "Reflect",
    desc: "Reflects all status conditions onto the target.",
    sfx: 'groan',
    animation: 'curse',
    sp:100,
    attributes:['status','magic'],
    target:'enemy',
    action:function(){
        for (var i=0; i<battle.actor.buffs.length; i++){
            var buff = battle.actor.buffs[i];
            var data;
            if (buff.base==buffs.draco_timerbomb){
                data={duration:buff.duration, frame:buff.frame};
            }
            var slot = battle.target.inflict(buff.base);
            buff.remedy();
            if (data && slot){
                slot.duration=data.duration;
                slot.frame=data.frame;
            }
            data=null;
        }
    },
    aitarget:function(){
        var enemylist = enemy_list();
        var targetlist;
        var highest = 0;
        // loop through enemies
        for (var i=0; i < enemylist.length; i++) {
            var enemy = enemylist[i];
            var nullcount = 0;
            // loop through buffs
            for (var j=0; j < enemy.buffs.length; j++) {
                if (enemy.buffs[j].base === buffs.null) {
                  nullcount++;
                }
            }
            // get list of enemies with the most null buffs.
            if (!targetlist || nullcount > highest) {
                targetlist = [enemy];
                highest = nullcount;
            } else if (nullcount === highest) {
                targetlist.push(enemy);
            }
        }
        // set the battle target
        if (targetlist===undefined){ targetlist = enemylist; }
        battle.target = targetlist[Math.floor(Math.random() * targetlist.length)];
    }
});

skills.draco_timerbomb = new Skill({
    id: 'draco_timerbomb',
    name: "Timer Bomb",
    desc: "Causes damage to the user after a few seconds.",
    sfx: 'itemget',
    animation: 'curse',
    sp: 100,
    attributes:['status','magic'],
    target:'self',
    action:function(){
        battle.actor.inflict(buffs.draco_timerbomb);
    }
});

buffs.draco_timerbomb = {
    name: 'draco_timerbomb',
    icon: 'draco_alarm',
    iconx: 0,
    icony: 0,
    negative: true,
    start: function(){
        this.duration = 0.8;
    },
    step: function(){
        this.duration -= deltam;
        if (this.duration <= 0) {
            if (this.frame==7){
                this.damage(500);
                this.remedy();
                var a = get_animation();
                a.play('flame', this.parent.x, this.parent.y, this.parent);
                sound.play('flame');
            }else{ this.frame++; this.duration=0.8;}
        }
    },
    attributes: ['curse']
};