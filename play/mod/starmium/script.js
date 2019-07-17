preload_mod.push(function(){
    game.load.spritesheet('starmium','mod/starmium/starmium.png',16,16);
});

if(!window.starmium){
	var starmium = Number(localStorage.getItem("starmium"))||0;
}

scenario_mod.push(function(){
	// add starmium
	if(!switches.starmium){
		switches.starmium=0;
	}
	var amount = Math.floor((starmium - switches.starmium)*10)/10;
	if(amount>0){
		items.starmium.quantity += amount*10;
		switches.starmium 		+= amount;
	}
});

items.starmium = {
  name: "Starmium Shard",
  type: Item.COMMON,
  sicon: 'starmium',
  iconx: 0,
  icony: 0,
  desc: "A shimmering red star fragment.",
};