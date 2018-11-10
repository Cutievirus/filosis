
end_battle_2 = override_before(end_battle_2,function(){
    if( battle.encounter.allowdefeat ){ battle.result="allowdefeat";}
});
encounter.joki.allowdefeat=true;