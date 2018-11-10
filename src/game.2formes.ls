formes =
    llov:
        default:
            number: 0
            stage: 0
            port: 'llov_battle'
            hp: 106
            atk: 105
            def: 80
            speed: 110
            luck: 110
            skills:
                lovely-arrow: 1
                devil-kiss: 2
                hemorrhage: 5
                angel-rain: 10
                minorheal: 15
                clense: 32
                #coagulate: 30
        koakuma:
            number: 1
            name: "Koakuma"
            desc: "A mischievous devil that plays tricks on her foes."
            stage: 1
            port: 'llov_battle_1'
            unlocked: false
            hp: 110
            atk: 120
            def: 100
            speed: 130
            luck: 138
            skills:
                hemorrhage: 1
                devil-kiss: 2
                bloodburst: 10
                sabotage: 15
                trickpunch: 15
                purge: 25
                coagulate: 27
        cupid:
            number: 2
            name: "Cupid"
            desc: "A sleepy angel that specializes in helping her allies."
            stage: 1
            port: 'llov_battle_2'
            unlocked: false
            hp: 140
            atk: 110
            def: 90
            speed: 130
            luck: 128
            skills:
                lovely-arrow: 1
                hemorrhage: 5
                angel-rain: 10
                quickheal: 10
                heal: 15
                clense: 25
                massheal: 27

    ebby:
        default:
            number: 0
            stage: 0
            port: 'ebby_battle'
            hp: 109
            atk: 105
            def: 100
            speed: 105
            luck: 108
            skills:
                hemorrhage: 1
                bloodburst: 5
                bloodrun: 10
                coagulate: 26
                purge: 27
                infectspread: 28
                pandemic: 28
        angel:
            number: 1
            name: "Balance"
            desc: "A righteous judge who delivers punishment on her foes."
            stage: 1
            port: 'ebby_battle_1'
            unlocked: false
            hp: 130
            atk: 117
            def: 106
            speed: 110
            luck: 120
            skills:
                hemorrhage: 1
                bloodburst: 5
                bloodrun: 10
                clense: 15
                purge: 15
                quickheal: 26
                infectspread: 28
                pandemic: 28
                heal: 30
                massheal: 40
        necro:
            number: 2
            name: "Chaos"
            desc: "A dark caster who rains terrible curses on her foes."
            stage: 1
            port: 'ebby_battle_2'
            unlocked: false
            hp: 110
            atk: 125
            def: 110
            speed: 112
            luck: 125
            skills:
                hemorrhage: 1
                bloodburst: 5
                bloodrun: 10
                purge: 20
                coagulate: 26
                infectspread: 28
                pandemic: 28
                curse: 30
                hex: 32
                healblock: 40
                isolate: 60
                

    marb:
        default:
            number: 0
            stage: 0
            port: 'marb_battle'
            hp: 112
            atk: 110
            def: 118
            speed: 90
            luck: 100
            skills:
                hemorrhage: 1
                bloodburst: 7
                artillery: 12
                hellfire: 14
                rail-cannon: 20
                flare: 25
        siege:
            number: 1
            name: "Siege"
            desc: "Fortified to boost attack and defense capability."
            stage: 1
            port: 'marb_battle_1'
            unlocked: false
            hp: 130
            atk: 155
            def: 160
            speed: 70
            luck: 100
            skills:
                hemorrhage: 1
                bloodburst: 5
                artillery: 10
                rail-cannon: 12
                hellfire: 14
                nuke: 20
                flare: 25
        assault:
            number: 2
            name: "Assault"
            desc: "Sheds all defense to become a swift killing machine."
            stage: 1
            port: 'marb_battle_2'
            unlocked: false
            hp: 100
            atk: 130
            def: 100
            speed: 150
            luck: 100
            skills:
                hemorrhage: 1
                bloodburst: 5
                artillery: 10
                hellfire: 12
                rail-cannon: 14
                nuke: 20
                flare: 25

for p of formes
    for f of formes[p]
        formes[p][f]id = f 

costumes = 
    llov:
        default: name:'Siesta' 
        , bsheet:\llov_battle, bframe:[0,1,2]
        , csheet:\llov, psheet:\llov_base
        nurse: name:'Nurse', bframe:[3,4,5]
        , crow: 7, psheet:\llov_base2
        swim: name:'Bikini', bframe:[12,13,14]
        , crow:5, pframe:3
        swim2: name:'Sukumizu', bframe:[15,16,17]
        , crow:6, pframe:4
        pumpkin: name:'Pumpkin', bframe:[6,7,8]
        , crow:3, pframe:2
        christmas: name:'Holly', bsheet:\llov_battle_christmas
        , crow:2, psheet:\llov_base2, pframe:1
        valentine: name:'Ribbon', bframe:[18,19,20]
        , crow:4, pframe:5
        punk: name:'Punk', bframe:[9,10,11]
        , crow:1, pframe:1
    ebby:
        default: name:'Nurse'
        , bsheet:\ebby_battle, bframe:[0,1,2]
        , csheet:\ebby, psheet:\ebby_base
        cheer: name:'Cheer', bframe:[6,7,8]
        , crow:2, pframe:1
        bat: name:'Bat', bframe:[3,4,5]
        , crow:1, psheet:\ebby_base2
        fairy: name:'Fairy', bframe:[9,10,11]
        , crow:3, pframe:2
        witch: name:'Witch', bframe:[15,16,17]
        , crow:5, psheet:\ebby_base2, pframe:1
        santa: name:'Santa', bframe:[12,13,14]
        , crow:4, pframe:3
    marb:
        default: name:'Uniform'
        , bsheet:[\marb_battle, \marb_battle_1, \marb_battle_2]
        , csheet:\marb, psheet:\marb_base
        nurse: name:'Nurse', bframe:4
        , crow:1, pframe:2
        maid: name:'Maid', bframe:3
        , crow:2, pframe:1
        bunny: name:'Bunny', bframe:1
        , crow:3, psheet:\marb_base2
        demon: name:'Demon', bframe:2
        , crow:4, psheet:\marb_base2, pframe:1
        , frecolor: [[0x9b87a3,0xe35000,0xf8b800],[0x8a87a3,0xb62e31,0xf7c631]]
        queen: name:'Regal', bframe:5
        , crow:5, psheet:\marb_base2, pframe:2

for p of costumes then for c of costumes[p] then for k in [\bsheet, \bframe]
    continue if typeof costumes[p][c][k] is \object
    filling=costumes[p][c][k]
    costumes[p][c][k]=[filling,filling,filling]

!function get_costume (n,f,c='default',key='bsheet')
    return null unless n?
    if typeof f is \undefined then f = 0
    else if f and typeof f is \object then f = f.number
    if costumes[n][c] and costumes[n][c][key]
        sheet=access costumes[n][c][key]
        if f isnt null and typeof sheet is \object then sheet=sheet[f]
    if sheet~=null
        sheet=access costumes[n]default[key]
        if f isnt null and typeof sheet is \object then sheet=sheet[f]
    return sheet


!function get_costume_old (name, forme, costume)
    if typeof forme is \object then forme = forme.number
    forme = if forme > 0 then "_#forme" else ''
    costume = if costume then "_#costume" else ''
    return "#{name}_battle#costume#forme" if game.cache.checkImageKey("#{name}_battle#costume#forme")
    return "#{name}_battle#forme"
    

!function learn_skills (p, level1, level2)
    if p instanceof Player then p = p.name
    basicskills = []
    excelskills = []
    messages = []
    excelmessages = []
    for key, level of formes[p]default.skills
        if level > level1 and level <= level2
            if players[p]skills.default.length < 5 and skills[key] not in players[p]skills.default then players[p]skills.default.push skills[key]
            #messages.push "#{speakers[p]display} learned skill #{skills[key]name}!"
            messages.push tl("{0} learned skill {1}!", speakers[p]display, skills[key]name)
            basicskills.push key
    for f, forme of formes[p]
        continue unless forme.unlocked
        for key, level of forme.skills
            if level > level1 and level <= level2
                if players[p]skills[f]length < 5 and skills[key] not in players[p]skills[f] then players[p]skills[f]push skills[key]
                continue if key in basicskills
                if (index = excelskills.indexOf key) is -1
                    #excelmessages.push "#{forme.name} forme learned Excel skill #{skills[key]name}!"
                    excelmessages.push tl("{0} forme learned Excel skill {1}!", forme.name, skills[key]name)
                    excelskills.push key
                #else excelmessages[index] = "#{speakers[p]display} learned Excel skill #{skills[key]name}!"
                else excelmessages[index] = tl("{0} learned Excel skill {1}!", speakers[p]display, skills[key]name)
    return messages ++ excelmessages

!function learn_skill (skill,p,f=\all)
    if typeof skill is \string then skill = skills[skill]
    say ->
        if p?
            skillbook[p][f].push skill
        else skillbook.all.push skill
        save!
        sound.play \itemget
    #say '' "#{if f isnt \all and f isnt \default then formes[p][f]name+' forme l' else if p? then speakers[p]display+' l' else 'L'}earned skill #{skill.name}!"
    if f isnt \all and f isnt \default
        say '' tl("{0} forme learned Excel skill {1}!", formes[p][f]name, skill.name)
    else if p?
        say '' tl("{0} learned skill {1}!", speakers[p]display, skill.name)
    else
        say '' tl("Learned skill {0}!", skill.name)