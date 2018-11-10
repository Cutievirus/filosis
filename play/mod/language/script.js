preload_mod.push(function(){
    batchload([
    ['lang_en', 'en.txt'],
    ['lang_jp', 'jp.txt']
    ], 'mod/language/', 'json')
});

//Change default language like this:
gameOptions.language='jp';

// Everything below is for generating the default language file.
language={};

language.getFile=function(file,callback){
	var xmlhttp = new XMLHttpRequest();
	xmlhttp.onreadystatechange=function(){
		if (xmlhttp.readyState!==XMLHttpRequest.DONE){ return; }
		if (xmlhttp.status===200){
			callback(xmlhttp.responseText);
		}else{alert(xmlhttp.status);}
	};
	xmlhttp.open("GET",file,true);
	xmlhttp.responseType="text";
	xmlhttp.send();
};
language.generate=function(){
	language.getFile("game.js",function(text){
		language.gamefile=text;
		language.dictionary = {};
		language.outfile = '{"info":{\n	"contributors":[],\n	"description":"The default language file."\n},"dictionary":{\n';
		language.firstline=true;

		language.section_speakers();
		language.section_formes();
		language.section_items();
		language.section_skills();
		language.section_monsters();
		language.section_zones();
		language.section_warps();
		language.section_pentagrams();
		language.section_main();
		language.section_errors();

		language.outfile+='\n}}';
		language.savefile();
	});
};
language.generate_mod=function(file){
	language.getFile(file,function(text){
		language.gamefile=text;
		language.dictionary = {};
		language.outfile = '';
		language.firstline=true;
		
		language.section_main();

		language.savefile();
	});
};

language.write_line=function(s){
  if (s in language.dictionary || typeof s !== 'string'){ return; }
  language.dictionary[s]=s;
  language.outfile+='\n	'+(language.firstline?'':',')+'"'+s+'":\n	"'+s+'"\n';
  language.firstline=false;
}
language.write_section=function(s){
  language.outfile+='\n'+(language.firstline?'':',')+'"_section": "'+s+'"\n';
  language.firstline=false;
}

language.section_main=function(){
  language.write_section('main');
  var matches = language.gamefile.match(/tl\("(?:\\"|[^"])*"/g);
  for (var i=0; i<matches.length; i++){
    var s = matches[i].slice(4,-1);
    language.write_line(s);
  }
}
language.section_errors=function(){
  language.write_section('error messages');
  var matches = language.gamefile.match(/tle\("(?:\\"|[^"])*"/g);
  for (var i=0; i<matches.length; i++){
    var s = matches[i].slice(5,-1);
    language.write_line(s);
  }
}
language.section_items=function(){
	language.write_section('items');
	for (var key in items) {
		var item = items[key];
		language.write_line(item.unlocalized_name);
		language.write_line(item.unlocalized_soulname);
		language.write_line(item.unlocalized_desc);
		language.write_line(item.unlocalized_desc_battle);
	}
}
language.section_skills=function(){
	language.write_section('skills');
	for (var key in skills) {
		var skill = skills[key];
		language.write_line(skill.unlocalized_name);
		language.write_line(skill.unlocalized_desc);
		language.write_line(skill.unlocalized_desc_battle);
	}
}
language.section_formes=function(){
	language.write_section('formes');
	for (var p in formes) for (var f in formes[p]){
		language.write_line(formes[p][f].unlocalized_name);
		language.write_line(formes[p][f].unlocalized_desc);
	}
}
language.section_speakers=function(){
	language.write_section('speakers');
	for (var key in speakers) {
		language.write_line(speakers[key].unlocalized_display);
	}
}
language.section_monsters=function(){
	language.write_section('monsters');
	for (var key in Monster.types) {
		language.write_line(Monster.types[key].unlocalized_name);
	}
}
language.section_warps=function(){
	language.write_section('warps');
	for (var i=0; i<warpzones.length; i++) {
		language.write_line(warpzones[i].unlocalized_name);
	}
}
language.section_zones=function(){
	language.write_section('zones');
	for (var i=0; i<unlocalized_zones.length; i++) {
		language.write_line(unlocalized_zones[i]);
	}
}
language.section_pentagrams=function(){
	language.write_section('pentagrams');
	for (var i=0; i<unlocalized_pentagrams.length; i++) {
		language.write_line(unlocalized_pentagrams[i]);
	}
}

language.savefile=function(){
	window.location = window.URL.createObjectURL(new Blob(["\ufeff"+language.outfile],{type:"text/plain"}));
};