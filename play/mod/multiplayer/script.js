var multiplayer={
	connected:false,
	peers:[],
	timer:Date.now(),
	messages:[],
	position:{x:0,y:0},
	ws_server:"ws://gameserver.cutievirus.com/filosis",
};
multiplayer.avatars=[
'llov','ebby','marb','mal','bp','joki','herpes','pox','leps','sars','aids1','aids2','rab','chikun','cure','zmapp','ammit','wraith','parvo','zika'
,'shiro'
//,'aids3','min' //questionable choices
//,'mob_slime','mob_ghost','mob_bat','mob_corpse' //acceptable mobs
]

//Options
gameOptions.multiplayer=true
gameOptions.multiplayer_avatar=true
options_mod.push(
	//multiplayer toggle
	{type:'switch', label:'Multiplayer', onswitch:function(){
		if (gameOptions.multiplayer){
			multiplayer_connect()
		}else{
			multiplayer.socket.close()
		}
	},desc:"Toggles multiplayer functionality on or off."}
	, accessor(gameOptions, 'multiplayer')
	//avatar guard
	,{type:'switch', label:'Avatar Guard', desc:"Prevents other players from using invalid multiplayer avatars."}
	,accessor(gameOptions, 'multiplayer_avatar')
);
//save and load options
save_options_mod.push(function(options){
	options.multiplayer=gameOptions.multiplayer|gameOptions.multiplayer_avatar<<2
});
load_options_mod.push(function(options){
	if (options.multiplayer==null){ return; }
	gameOptions.multiplayer=options.multiplayer&1
	gameOptions.multiplayer_avatar=options.multiplayer&2
});

function multiplayer_connect(){
	if (multiplayer.connected){ return; }
	if (typeof WebSocket !== 'function'){
		multiplayer.connected=null;
		return console.warn("WebSockets are not supported.");
	}
	multiplayer.connected='connecting';
	var ws = new WebSocket(multiplayer.ws_server);
	multiplayer.socket=ws;
	ws.onopen=function(){
		multiplayer.connected=true;
		console.log("Connected to socket server.");
		//ws.send(JSON.stringify({key:'llov',name:'wilhelm',map:'delta',x:0,y:0,message:'Hi there!'}));
	};
	ws.onclose=function(e){
		console.log("Closing socket.");
		multiplayer.connected=false;
	};

	ws.onmessage=function(e){
		var data
		try{ //parse the data
			multiplayer_process(JSON.parse(e.data));
		}catch(er){
			console.log('Server says "'+e.data+'"');
		}
	};
}

function multiplayer_process(data){
	var d={id:data[0],key:data[1],row:data[2],map:data[3],x:data[4],y:data[5],name:data[6],message:data[7]};
	if (d.map!==switches.map){ return; }
	//verify image key
	if (!game.cache.checkImageKey(d.key)
	|| (gameOptions.multiplayer_avatar && multiplayer.avatars.indexOf(d.key)<0)) {
		newkey='wraith';
		for (i in multiplayer.avatars){
			if (d.key.indexOf(multiplayer.avatars[i])>=0){
				newkey=multiplayer.avatars[i];
				break;
			}
		}
		d.key=newkey;
	}
	//create actor
	var peer=multiplayer.peers[d.id]
	if (!peer || !peer.alive){
		peer=multiplayer.peers[d.id]=new NPC(d.x,d.y,d.key,null,true);
		peer.update=override(peer.update,multiplayer_peer_update)
	}else if (peer.key!==d.key){
		peer.loadTexture(d.key)
	}
	if (peer.row!==d.row){
		peer.setrow(d.row);
	}
	peer.path.push({x:d.x, y:d.y});
	peer.alpha=0.5
	//display message if there is one
	if (d.name){ peer.displayname=d.name; }
	if (d.message){
		multiplayer_chatwindow(peer.displayname,d.message,d.x,d.y)
	}
}

function multiplayer_peer_update(){
	this.alpha -= 0.0125*deltam;
	if (this.alpha<=0){
		this.destroy();
	}
}

update_mod.push(function(){
	if (multiplayer.connected===null || !gameOptions.multiplayer){ return; }
	var now=Date.now();
	if (now - multiplayer.timer < 1500){ return; }
	multiplayer.timer=now;
	if (distance(player,multiplayer.position)<TS && !multiplayer.messages.length){return;}
	if (multiplayer.connected===false){ return multiplayer_connect(); }
	if (multiplayer.connected!==true){ return; }

	multiplayer.position.x=player.x;
	multiplayer.position.y=player.y;
	//multiplayer.socket.send(JSON.stringify({key:player.key,name:switches.name,map:switches.map,x:Math.floor(player.x),y:Math.floor(player.y)}));
	var data=[player.key,player.row,switches.map,Math.floor(player.x),Math.floor(player.y)]
	if (multiplayer.messages.length){
		data.push(switches.name, multiplayer.messages.shift());
	}
	try{
		multiplayer.socket.send(JSON.stringify(data));
	}catch(err){}
});

//CHAT

input_mod.push(function(){
	keyboard.addKeys('chat', 'T', 'QUOTES');
});


input_overworld = override(input_overworld,function(){
	keyboard.chat.onDown.add(function(){
		multiplayer_textentry();
	});
});

multiplayer.player_confirm_button=player_confirm_button
player_confirm_button=function(){
	var ret = multiplayer.player_confirm_button.apply(this,arguments);
	if (ret===false) return false;
	if (game.input.keyboard.isDown(Phaser.KeyCode.ENTER)){
		multiplayer_textentry();
	}
	return ret;
}

function multiplayer_textentry(){
	if (!gameOptions.multiplayer) return;
	if (actors.paused || switches.cinema) return;
	//reset_keyboard();
	dialog.textentry.show(140, tl("Say something!"),function(m){
		if (!m) return;
		multiplayer.messages.push(m);
		multiplayer_chatwindow(switches.name,m,player.x,player.y);
	});
}

textinput.addEventListener("keydown",function(e){
	if (e.keyCode==13){dialog.textentry.enter();}
});

function multiplayer_chatwindow(name,message,x,y){
	chat=new Phaser.Group(game, fringe, 'chat');
	chat.x=x; chat.y=y-25;
	chat_back=chat.addChild(new Phaser.Image(game, 0, 0, 'solid'));
	chat_back.tint=0; chat_back.alpha=0.5;
	chat_name=chat.addChild(new Text('font_yellow',name,0,0));
	chat_message=chat.addChild(new Text('font',message,0,0,false,37,12));
	chat_back.anchor.set(0.5, 1);
	chat_name.anchor.set(0.5,1);
	chat_message.anchor.set(0.5,0);
	chat_message.y=-chat_message.height;
	chat_name.y=-chat_message.height-2;
	chat_back.height=chat_message.height+chat_name.height+4;
	chat_back.width=Math.max(chat_name.width, chat_message.width)+4;
	chat.birth=Date.now();
	chat.duration=5+5*message.length/140;
	chat.nobody=true;
	updatelist.push(chat);
	chat.update=function(){
		now=Date.now();
		this.y-=deltam;
		if (now - this.birth > this.duration*2000){
			this.alpha -= deltam/this.duration;
		}
		if (this.alpha<=0){
			this.destroy();
		}
	};
	chat.destroy=override(chat.destroy,function(){
		updatelist.remove(this);
	});
	return chat;
}