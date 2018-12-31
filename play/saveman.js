(function(){
var filebox=document.getElementById('filebox');
var files
function readFiles(){
	files=localStorage.getItem('filosis-files') || '{}';
	if (files){
		files=JSON.parse(files);
		filebox.innerHTML='';
		for (var key in files){
			var div=filebox.appendChild(document.createElement('div'));
			div.className='window'; div.appendChild(document.createTextNode(key+':\u00a0'));
			var a = div.appendChild(document.createElement('a'));
			//a.setAttribute('data-name',key);
			a.appendChild(document.createTextNode('export\u00a0'));
			a.href=window.URL.createObjectURL(new Blob([localStorage.getItem('filosis_'+key)],{type:"text/plain"}));
			a.download=key+'.filosis';
			a=div.appendChild(document.createElement('a'));
			a.appendChild(document.createTextNode('delete'));
			//a.href="javascript:delete_save('"+key+"');";
			a.href="javascript:void 'Delete Save'";
			a.onclick=function(){delete_save(key)};
			//filebox.innerHTML+="<div class='window'>"+key+" <a href='javascript:'></div>";
		}
	}
}
readFiles();
var import_save=document.getElementById('import_save');
import_save.addEventListener('change',function(ev){
	if (!this.files){return;}
	var fr=new FileReader();
	fr.onload=function(ev){
		var file
		try{
			file=JSON.parse(ev.target.result);
		}catch (er){
			alert('Invalid file');
			return
		}
		console.log(file)
		setFile(file);
		saveHandler("filosis_"+file.switches.name, JSON.stringify(file));
		//location.reload();
		readFiles();
		quitgame();
		saveman.style.display='none';
	}
	fr.readAsText(this.files[0], "UTF-8");
});

function setFile(savefile){
  var file, name;
  //files = getFiles();
  file = {
    party: []
  };
  for (var i in savefile.party){
  	name=savefile.party[i]
  	file.party.push({
  		name: name,
  		xp: savefile.players[name].xp,
  		item: savefile.players[name].equip,
  		costume: savefile.players[name].costume
  	});
  }
  files[savefile.switches.name] = file;
  saveHandler("filosis-files", JSON.stringify(files));
}

function delete_save(name){
	if(!confirm('Really delete save "'+name+'"?')){return;}
	delete files[name];
	localStorage.removeItem("filosis_"+name);
	saveHandler("filosis-files", JSON.stringify(files));
	//location.reload();
	readFiles();
	quitgame();
	saveman.style.display='none';
}

function saveHandler(key, value){
  try {
    localStorage.setItem(key, value);
  } catch (er) {
    (session.localStorageError ? console.warn : alert)("The game could not be saved!\n" + er.message);
  }
}
window.savemanager={
	readFiles:readFiles,
};
})();