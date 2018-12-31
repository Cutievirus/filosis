var pixel, game, pentagrams, WIDTH, HEIGHT, HWIDTH, HHEIGHT, RADIUS, TS, HTS, WS, HWS, BS, IS, FW, FW2, FH, HPI, textinput, saveman, errordiv, bootloader, state, init_mod, i$, ref$, len$, item, STARTMAP, version, version_number, switches, session, warpzones, unlocalized_zones, unlocalized_pentagrams, temp, switch_defaults, multiplesaves, create_title_background, solidscreen, cg, previous_time, delta, deltam, update_mod, preloader, preload_mod, gui, gui_mod, dialog, Window, CGWindow, DialogWindow, Text, FloatingText, TextEntry, Menu_Base, Number_Dialog, Menu, Portrait, Screen, musicmap, actors, carpet, triggers, fringe, updatelist, Actor, formes, p, f, costumes, c, k, filling, Player, player, party, players, llov, ebby, marb, Skill, animations, skills, key, properties, skillbook, DEGtoRAD, RADtoDEG, pluckroll, saveslug, save_options_mod, load_options_mod, gameOptions, nosave_switches, battle_encounter, battle, heroes, monsters, target_message, battle_mixin, Battler, StatusCard, Monster, Animation, Buff, buffs, nodes, doodads, Doodad, Treasure, Trigger, holiday, devices, keyboard, input_mod, onDown_up, onDown_left, onDown_down, onDown_right, onDown_cancel, mouse, Item, items, crafting, recipe, recipebook, items_initial, pause_screen, shop_screen, refresh_shop, options_mod, pause_menu_mod, title_screen, costume_screen, excel_screen, Mob, Dust, mobs, dustclouds, palette, encounter, Audio, sound, music, menusound, voicesound, NPC, mal, herpes, bp, merch, nae, pox, leps, cure, zmapp, sars, rab, ammit, parvo, joki, aids, speakers, scenario, scenario_mod, mapdefaults, zones, mapdata, backdrop, map, tiledata, override_getTile, renderregionoverride, Transition, split$ = ''.split;
WIDTH = 320;
HEIGHT = 240;
HWIDTH = WIDTH / 2;
HHEIGHT = HEIGHT / 2;
RADIUS = Math.sqrt(Math.pow(WIDTH, 2) + Math.pow(HEIGHT, 2)) / 2;
TS = 16;
HTS = TS / 2;
WS = 16;
HWS = WS / 2;
BS = 16;
IS = 32;
FW = 6;
FW2 = 12;
FH = 10;
HPI = Math.PI / 2;
textinput = document.getElementById('textinput');
textinput.value = '';
saveman = document.getElementById('saveman');
errordiv = document.getElementById('errordiv');
bootloader = document.getElementById('bootloader');
String.prototype.codePointAt || (String.prototype.codePointAt = String.prototype.charCodeAt);
state = {
  preboot: {},
  boot: {},
  preload: {},
  reload: {},
  title: {},
  overworld: {},
  battle: {},
  load: {}
};
window.onload = function(){
  var renderer, i$, ref$, len$, h;
  renderer = Phaser.AUTO;
  for (i$ = 0, len$ = (ref$ = window.location.hash.split('#')).length; i$ < len$; ++i$) {
    h = ref$[i$];
    if (h === 'canvas') {
      renderer = Phaser.CANVAS;
    } else if (h === 'webgl') {
      renderer = Phaser.WEBGL;
    } else if (h.indexOf('lang=') >= 0) {
      gameOptions.language = h.split('=')[1];
    } else if (h === 'debug') {
      session.debug = true;
    }
  }
  game = new Phaser.Game(WIDTH, HEIGHT, renderer, '', null, false, false);
  pixel = {
    scale: 1,
    canvas: null,
    context: null,
    width: 0,
    height: 0
  };
  game.state.add('preboot', state.preboot);
  game.state.add('boot', state.boot);
  game.state.add('preload', state.preload);
  game.state.add('reload', state.reload);
  game.state.add('title', state.title);
  game.state.add('overworld', state.overworld);
  game.state.add('battle', state.battle);
  game.state.add('load', state.load);
  game.state.start('preboot');
};
window.onresize = resizeGame;
function resizeGame(){
  var screenHeight, screenWidth, aspect, scale, ref$, ref1$, name, layer;
  if (pixel.canvas == null) {
    return;
  }
  screenHeight = window.innerHeight;
  screenWidth = window.innerWidth;
  aspect = screenWidth / screenHeight;
  scale = (ref$ = screenWidth / WIDTH | 0) < (ref1$ = screenHeight / HEIGHT | 0) ? ref$ : ref1$;
  if (gameOptions.exactscaling) {
    pixel.scale = scale > 1 ? scale : 1;
  } else {
    pixel.scale = scale + 1;
  }
  if (aspect > WIDTH / HEIGHT) {
    game.width = HEIGHT * aspect | 0;
    game.height = HEIGHT;
  } else {
    game.width = WIDTH;
    game.height = WIDTH / aspect | 0;
  }
  if (gameOptions.exactscaling) {
    game.width = (screenWidth / pixel.scale / 2 | 0) * 2;
    game.height = (screenHeight / pixel.scale / 2 | 0) * 2;
    pixel.canvas.style.width = '';
    pixel.canvas.style.height = '';
  } else {
    pixel.canvas.style.width = '100%';
    pixel.canvas.style.height = '100%';
  }
  pixel.width = pixel.canvas.width = game.width * pixel.scale;
  pixel.height = pixel.canvas.height = game.height * pixel.scale;
  game.renderer.resize(game.width, game.height);
  if (game.renderType === Phaser.CANVAS) {
    Phaser.Canvas.setSmoothingEnabled(game.context, false);
  }
  Phaser.Canvas.setSmoothingEnabled(pixel.context, false);
  game.camera.view.width = game.width;
  game.camera.view.height = game.height;
  set_gui_frame();
  if (typeof map != 'undefined' && map !== null) {
    for (name in ref$ = map.namedLayers) {
      layer = ref$[name];
      layer.width = game.width;
      layer.height = game.height;
      layer.resize(game.width, game.height);
      layer.scale.set(1);
    }
  }
  if (typeof backdrop != 'undefined' && backdrop !== null) {
    backdrop.water.width = game.width + backdrop.water.marginX;
    backdrop.water.height = game.height + backdrop.water.marginY;
  }
  resetCanvas();
}
function resetCanvas(){
  game.canvas.style.width = '100%';
  game.canvas.style.height = '100%';
}
state.preboot.init = function(){
  var e, overrideResetCanvas, overrideTilesprite, overrideTilespriteUpdateTransform, css;
  pixel.canvas = Phaser.Canvas.create(game.width, game.height);
  pixel.context = pixel.canvas.getContext('2d');
  Phaser.Canvas.addToDOM(pixel.canvas, document.getElementById("main"));
  game.canvas.id = "gamecanvas";
  pixel.canvas.id = "pixelcanvas";
  game.canvas.style.zIndex = '1';
  game.canvas.style.opacity = '0';
  try {
    localStorage.getItem('test');
  } catch (e$) {
    e = e$;
    fatalerror('localStorage');
  }
  load_options();
  game.stage.disableVisibilityChange = true;
  overrideResetCanvas = game.scale.resetCanvas;
  game.scale.resetCanvas = function(){
    overrideResetCanvas.apply(this, arguments);
    resetCanvas();
  };
  resizeGame();
  overrideTilesprite = Phaser.TileSprite;
  Phaser.TileSprite = function(game, x, y, width, height, key, frame){
    overrideTilesprite.apply(this, arguments);
    if (width != null) {
      this.width = width;
    }
    if (height != null) {
      this.height = height;
    }
  };
  Phaser.TileSprite.prototype = overrideTilesprite.prototype;
  overrideTilespriteUpdateTransform = Phaser.TileSprite.prototype.updateTransform;
  Phaser.TileSprite.prototype.updateTransform = function(){
    if (game.renderType === Phaser.WEBGL) {
      this.alpha = this.parent.alpha * (this.ownalpha || 1);
    } else {
      this.alpha = this.ownalpha || 1;
    }
    overrideTilespriteUpdateTransform.apply(this, arguments);
  };
  /* #not needed any more 
  Phaser.FrameData::getFrame =(index)!->
      if index>= @_frames.length
          index=0
      return @_frames[index]
  */
  Phaser.Physics.Arcade.Body.prototype.setSize = override(Phaser.Physics.Arcade.Body.prototype.setSize, function(width, height, offsetX, offsetY){
    adjustBodyOffset.apply(this, arguments);
  });
  Phaser.Sprite.prototype.crop = override(Phaser.Sprite.prototype.crop, function(rect, copy){
    if (this.body) {
      return adjustBodyOffset.apply(this.body, arguments);
    }
  });
  css = document.createElement('style');
  css.type = 'text/css';
  css.innerHTML = "@font-face { font-family: 'Filosis'; src: url('font/Filosis.ttf') format('truetype'); }";
  document.head.appendChild(css);
};
function adjustBodyOffset(width, height, offsetX, offsetY){
  if (this.sprite.bodyoffset) {
    this.sprite.bodyoffset.x = offsetX == null ? this.sprite.bodyoffset.x || 0 : offsetX;
    this.sprite.bodyoffset.y = offsetY == null ? this.sprite.bodyoffset.y || 0 : offsetY;
  } else {
    this.sprite.bodyoffset = {
      x: offsetX || 0,
      y: offsetY || 0
    };
  }
  this.offset.set(this.sprite.width * this.sprite.anchor.x - this.width * this.sprite.anchor.x + this.sprite.bodyoffset.x, this.sprite.height * this.sprite.anchor.y - this.height * this.sprite.anchor.y + this.sprite.bodyoffset.y);
}
init_mod = [];
function tlNames(){
  var lang, k, ref$, o, p, f, i$, len$, tl_pentagrams, k2;
  if (game.cache.checkJSONKey('lang_' + gameOptions.language)) {
    lang = game.cache.getJSON('lang_' + gameOptions.language);
    if (typeof lang.dictionary === 'object') {
      tl.dictionary = lang.dictionary;
    }
  }
  for (k in ref$ = items) {
    o = ref$[k];
    o.unlocalized_name = o.name;
    o.name = tl(o.name);
    if (typeof o.desc === 'string') {
      o.unlocalized_desc = o.desc;
      o.desc = tl(o.desc);
    }
    if (typeof o.soulname === 'string') {
      o.unlocalized_soulname = o.soulname;
      o.soulname = tl(o.soulname);
    }
    if (typeof o.desc_battle === 'string') {
      o.unlocalized_desc_battle = o.desc_battle;
      o.desc_battle = tl(o.desc_battle);
    }
  }
  for (k in ref$ = skills) {
    o = ref$[k];
    o.unlocalized_name = o.name;
    o.name = tl(o.name);
    if (typeof o.desc === 'string') {
      o.unlocalized_desc = o.desc;
      o.desc = tl(o.desc);
    }
    if (typeof o.desc_battle === 'string') {
      o.unlocalized_desc_battle = o.desc_battle;
      o.desc_battle = tl(o.desc_battle);
    }
  }
  for (p in formes) {
    for (f in ref$ = formes[p]) {
      o = ref$[f];
      if (o.name) {
        o.unlocalized_name = o.name;
        o.name = tl(o.name);
      }
      if (o.desc) {
        o.unlocalized_desc = o.desc;
        if (o.desc) {
          o.desc = tl(o.desc);
        }
      }
    }
  }
  for (k in ref$ = speakers) {
    o = ref$[k];
    o.unlocalized_display = o.display;
    o.display = tl(o.display);
  }
  for (k in ref$ = Monster.types) {
    o = ref$[k];
    o.unlocalized_name = o.name;
    o.name = tl(o.name);
  }
  for (i$ = 0, len$ = (ref$ = warpzones).length; i$ < len$; ++i$) {
    o = ref$[i$];
    o.unlocalized_name = o.name;
    o.name = tl(o.name);
  }
  tl_pentagrams = {};
  for (k in pentagrams) {
    o = tl_pentagrams[tl(k)] = pentagrams[k];
    unlocalized_zones.push(k);
    for (k2 in o) {
      unlocalized_pentagrams.push(o[k2]);
      o[k2] = tl(o[k2]);
    }
  }
  pentagrams = tl_pentagrams;
  for (i$ = 0, len$ = (ref$ = init_mod).length; i$ < len$; ++i$) {
    f = ref$[i$];
    if (typeof f == 'function') {
      f();
    }
  }
}
function fatalerror(type){
  var text, greater, ref$, i$, ed, div;
  text = '';
  greater = true;
  fatalerror.advices == null && (fatalerror.advices = {
    download: tle("Download a native version of this game from {0}. Run the game executable.", "<a href='https://cutievirus.itch.io/super-filovirus-sisters'>itch.io</a>"),
    report: tle("To report this bug, the you can contact me on {0}.", "<a href='https://discord.gg/4SJ5dFN'>Discord</a>")
  });
  switch (type) {
  case 'sameOrigin':
    text = "<h2>" + tle("The game cannot be played right now.") + "</h2>" + "<p>" + tle("This probably happened because your browser blocked a cross-origin request.") + "<br>" + tle("Some web browsers heavily restrict what can be done in the file protocol, and don't allow access to files in sub folders.") + "<br>" + tle("There are a few things you can do to fix this.") + "</p>" + "<p>1. " + fatalerror.advices.download + "</p>" + "<p>2. " + tle("Try a different browser. Chromium browsers won't work. Firefox will. If you want to play using this browser, read further.") + "</p>" + "<p>3. " + tle("Disable web security. This isn't reccomended unless you know what you're doing.") + "</p>" + "<p>4. <a href='https://www.npmjs.com/package/http-server'>" + tle("Get a web server!") + "</a></p>";
    break;
  case 'localStorage':
    text = "<h2>" + tle("Local Storage Error") + "</h2>" + "<p>" + tle("This probably happened because you're using a browser that doesn't support localStorage, or localStorage is disabled.") + "<br>" + tle("There are a few things you can do to fix this.") + "</p>" + "<p>1. " + fatalerror.advices.download + "</p>" + "<p>2. " + tle("Get a better browser.") + "</p>";
    break;
  case 'missingitem':
    text = "<h2>" + tle("Missing item") + "</h2>" + "<p>" + tle("The game tried to access an item that doesn't exist.") + "</p>" + "<p>" + tle("This is definitely a bug.") + "</p>";
    break;
  default:
    greater = false;
    if ((ref$ = game.state.current) === 'preboot' || ref$ === 'boot' || ref$ === 'preload' || ref$ === '') {
      text = ("<h2>Error! " + arguments[1] + "</h2>") + "<p>" + tle("An error occurred while loading the game. Here's a few things you can try to fix it:") + "</p>" + "<p>1. " + tle("Try changing the renderer. Add {0} or {1} to the url to try a different renderer.", "<a href='#canvas' onclick='location.reload()'>#canvas</a>", "<a href='#webgl' onclick='location.reload()'>#webgl</a>") + "</p>" + "<p>2. " + tle("Some errors happen only on certain browsers. You can try using a different browser, or download a native version of the game from {0}.", "<a href='http://filosis.cutievirus.com/#download'>filosis.cutievirus.com</a>") + "</p>";
    } else {
      text = ("<h2>Error! " + arguments[1] + "</h2>") + "<p>" + tle("An error occurred while the game was playing. This is probably a bug.") + "</p>" + "<p>" + fatalerror.advices.report + "</p>";
    }
    text += "<p>" + tle("You can check the console for more information.") + ("<br><small>" + arguments[2] + " : " + arguments[3] + "</small></p>");
  }
  text += "<p><a href='javaScript:void 'Dismiss Error';' onclick='dismissError(this); return false;'>Dismiss this error</a></p>";
  for (i$ = (ref$ = document.getElementsByClassName('errordiv')).length - 1; i$ >= 0; --i$) {
    ed = ref$[i$];
    if (!ed.getAttribute('data-greater')) {
      if (greater) {
        ed.parentNode.removeChild(ed);
      }
    } else if (!greater) {
      return;
    }
  }
  div = document.createElement('div');
  div.innerHTML = text;
  div.className = 'errordiv';
  if (greater) {
    div.setAttribute('data-greater', 'true');
  }
  errordiv.appendChild(div);
  errordiv.style.display = 'block';
}
function dismissError(a){
  var ed;
  ed = a.parentNode.parentNode;
  ed.parentNode.removeChild(ed);
  if (document.getElementsByClassName('errordiv').length === 0) {
    errordiv.style.display = 'none';
  }
}
window.onerror = function(msg, url, ln){
  fatalerror('unknown', msg, url, ln);
};
for (i$ = 0, len$ = (ref$ = document.getElementsByClassName('close_overlay')).length; i$ < len$; ++i$) {
  item = ref$[i$];
  item.href = "javaScript:void 'Close';";
  item.onclick = fn$;
}
STARTMAP = 'shack2';
version = "Release";
version_number = '1.1.1';
switches = {
  sp_limit: {},
  water_walking: false,
  map: STARTMAP,
  outside: true,
  checkpoint: '',
  checkpoint_map: '',
  gxp: 0,
  cinema: false,
  spawning: false,
  name: 'Wilhelm',
  soulcluster: true,
  progress: 'tutorial',
  progress2: 0,
  version: version,
  mode: 'story'
};
session = {};
warpzones = [
  {
    id: 'earth',
    name: "Earth",
    map: 'earth',
    node: 'landing',
    dir: 'right'
  }, {
    id: 'delta',
    name: "Tuonen Delta",
    map: 'delta',
    node: 'landing',
    dir: 'up'
  }, {
    id: 'hub1',
    name: "Tower Village",
    map: 'hub',
    node: 'landing',
    dir: 'down'
  }, {
    id: 'hub2',
    name: "Tower Outskirts",
    map: 'hub',
    node: 'landing2',
    dir: 'down'
  }, {
    id: 'deadworld',
    name: "Dead World",
    map: 'deadworld',
    node: 'landing',
    dir: 'up'
  }, {
    id: 'curecamp',
    name: "Cure Camp",
    map: 'deadworld',
    node: 'landing2',
    dir: 'up'
  }
];
unlocalized_zones = [];
unlocalized_pentagrams = [];
pentagrams = {
  "Abyss": {
    void_cp: "Tuonen Falls",
    void_cp2: "The End"
  },
  "Earth": {
    earth_cp: "Ruins of Earth",
    earth_cp1: "Last Hope Lab",
    basement1_cp: "Basement",
    earth2_cp: "Wilderness",
    earth3_cp: "Black Meadow"
  },
  "Tuonen Delta": {
    delta_cp1: "Delta Landing",
    delta_cprab: "Rabies Hideout",
    delta_cpsars: "Sars Hideout",
    delta_cpaids: "Eidzu Hideout"
  },
  "Tuonen River": {
    hub_hub: "Tower Village",
    hub_cp1: "Tower Outskirts",
    tunneldeep_cp: "Tunnel Depths"
  },
  "Black Tower": {
    tower0_cp: "Ground Floor",
    towertop_cp: "Rooftop Cemetary"
  },
  "Dead World": {
    deadworld_cp0: "Dead Landing",
    deadworld_cp1: "Herpes Shop",
    deadworld_cp2: "Cure Camp",
    deadworld_stage: "Concert Hill",
    deadworld_dt: "Death Tunnel",
    deathdomain_cp: "Death Castle"
  }
};
temp = {};
switch_defaults = clone(switches);
multiplesaves = false;
create_title_background = function(){
  var gs, divs, i$, i, colorstart, colorend, len$, g, adjustheight, ref$;
  create_gui();
  game.camera.roundPx = true;
  game.camera.bounds = false;
  game.camera.x = 0;
  game.camera.y = 0;
  gs = [];
  divs = 40;
  for (i$ = -1; i$ <= divs; ++i$) {
    i = i$;
    gs.unshift(gui.title.create(0, (i > 0 ? i : 0) * HEIGHT / divs, 'solid'));
    gs[0].height = HEIGHT / divs;
  }
  gs[gs.length - 1].anchor.set(0, 1);
  gs.splice(1, 0, gui.title.create(0, HEIGHT, 'solid'));
  gs[1].height = 16;
  colorstart = 0xffaa88;
  colorend = 0xfff8f8;
  colorstart = makecolor({
    r: Math.random() * 255,
    g: Math.random() * 255,
    b: Math.random() * 255
  }, false);
  for (i$ = 0, len$ = gs.length; i$ < len$; ++i$) {
    i = i$;
    g = gs[i$];
    g.update = fn$;
    adjustheight = i === 0 || i === gs.length - 1;
    resize_callback(g, title_bg, [adjustheight]);
    title_bg.call(g, adjustheight);
    g.ig = (ref$ = i / gs.length) < 0.8 ? ref$ : 0.8;
  }
  shiftingcolors();
  function shiftingcolors(){
    var color1, color2;
    color1 = colorstart;
    color2 = makecolor({
      r: Math.random() * 255,
      g: Math.random() * 255,
      b: Math.random() * 255
    }, false);
    new Transition(30000, function(t){
      var color3, i$, ref$, len$, g;
      if (!(game.state.current === 'title' || game.state.current === 'preload' || game.state.current === 'boot')) {
        return;
      }
      color3 = gradient(color1, color2, t);
      for (i$ = 0, len$ = (ref$ = gs).length; i$ < len$; ++i$) {
        g = ref$[i$];
        g.tint = gradient(color3, colorend, Math.floor(10 * (g.ig + Math.sin(100 * Math.pow(g.ig, 2)) / 10)) / 10);
      }
      return gs[1].tint = gradient(color3, colorend, 0.2);
    }, function(){
      if (!(game.state.current === 'title' || game.state.current === 'preload' || game.state.current === 'boot')) {
        return;
      }
      colorstart = color2;
      return shiftingcolors();
    }, 0, false);
  }
  gui.title.create(-11, -7, 'title');
  function fn$(){}
};
state.reload.create = function(){
  gui.frame.removeAll(true);
  game.stage.disableVisibilityChange = true;
  create_title_background();
  game.state.start('title');
};
function title_bg(adjustheight){
  this.width = game.width;
  this.x = -(game.width - WIDTH) / 2;
  if (adjustheight) {
    this.height = (game.height - HEIGHT) / 2;
  }
}
state.title.create = function(){
  var logo, versiontext;
  game.stage.disableVisibilityChange = !gameOptions.pauseidle;
  input_initialize();
  create_audio();
  logo = gui.title.create(0, 0, 'logo');
  logo.update = function(){
    this.x = -Math.round(this.parent.x / 2);
    this.y = -Math.round(this.parent.y / 2);
  };
  gui.title.addChild(versiontext = new Text('font_yellow', version_number, WIDTH - WS * 6, HEIGHT));
  versiontext.anchor.set(1, 1);
  create_title_menu();
  solidscreen = gui.addChild(
  new Phaser.Image(game, 0, 0, 'solid'));
  resize_callback(solidscreen, solidscreenresize);
  solidscreenresize.call(solidscreen);
  solidscreen.alpha = 0;
  solidscreen.tint = 0;
  function solidscreenresize(){
    this.width = game.width;
    this.height = game.height;
  }
  cg = gui.frame.addChild(
  new CGWindow());
  cg.kill();
};
state.title.shutdown = function(){
  gui.title.removeAll(true);
};
state.title.update = function(){
  main_update();
};
state.overworld.create = function(){
  var teleporting, defeated, i$, ref$, len$, p;
  switches.cinema2 = false;
  teleporting = switches.portal != null && !switches.portal.loaded;
  if (!teleporting) {
    input_overworld();
  }
  create_backdrop();
  switches.outside = backdrop.visible = getmapdata('outside');
  backdrop.sun.visible = switches.soulcluster;
  switches.spawning = getmapdata('spawning');
  create_tilemap();
  defeated = true;
  for (i$ = 0, len$ = (ref$ = party).length; i$ < len$; ++i$) {
    p = ref$[i$];
    if (p.stats.hp > 0) {
      defeated = false;
    } else {
      p.kill();
    }
  }
  if (defeated) {
    switches.defeated = defeated;
  } else {
    set_party();
  }
  if (!teleporting) {
    create_pause_menu();
  }
  if (!teleporting) {
    create_shop_menu();
  }
  if (!teleporting) {
    start_dialog_controller();
  }
  set_mobs();
  map_objects();
  if (switches.portal == null) {
    npc_events();
  }
  fringe.sort('y');
  if (!state.overworld.create.started || defeated) {
    for (i$ = 0, len$ = (ref$ = party).length; i$ < len$; ++i$) {
      p = ref$[i$];
      p.start_location(true);
    }
    state.overworld.create.started = true;
    if (defeated) {
      delete switches.defeated;
    }
  }
  sort_actor_groups();
  start_camera.call(player);
  if (temp.runnode) {
    player.relocate(temp.runnode);
    delete temp.runnode;
  }
  for (i$ = 0, len$ = (ref$ = party).length; i$ < len$; ++i$) {
    p = ref$[i$];
    if (p === player || !p.alive) {
      continue;
    }
    p.relocate(player);
  }
  if (!switches.started) {
    scenario.game_start();
  }
  zonemusic();
};
function quitgame(){
  if (quitgame.clicked) {
    return;
  }
  quitgame.clicked = true;
  music.fadeOut(500);
  Transition.fade(500, 0, function(){
    var p, lresult$, f, results$ = [];
    quitgame.clicked = false;
    game.state.start('reload', true);
    state.overworld.create.started = false;
    reset_items();
    session = {};
    for (p in players) {
      lresult$ = [];
      for (f in formes[p]) {
        if (f === 'default') {
          continue;
        }
        lresult$.push(formes[p][f].unlocked = false);
      }
      results$.push(lresult$);
    }
    return results$;
  }, null, 10, false);
}
function warp_node(pmap, pport, pdir){
  warp(pmap, pport, pdir, true);
}
function warp(pmap, pport, pdir, pnode){
  pmap == null && (pmap = switches.map);
  pdir == null && (pdir = 'down');
  pnode == null && (pnode = false);
  Transition.fade(300, 0, function(){
    return schedule_teleport({
      pmap: pmap,
      pport: pport,
      pdir: pdir,
      pnode: pnode
    });
  }, null, 5, true, null);
}
function schedule_teleport(portal){
  var newzone;
  if (switches.portal) {
    return;
  }
  newzone = getmapdata(portal.pmap, 'zone') !== getmapdata('zone');
  switches.map = portal.pmap;
  switches.portal = portal;
  player.cancel_movement();
  if (newzone) {
    game.state.start('load', false);
  }
}
function change_map(portal){
  var px, py, node, n, trigger, i$, ref$, len$, actor;
  log("Switching to map '" + portal.pmap + "'");
  if (!portal.loaded) {
    state.overworld.shutdown();
    state.overworld.create();
  }
  px = player.x;
  py = player.y;
  if (portal.pnode) {
    if (node = nodes[portal.pport]) {
      px = node.x + TS / 2;
      py = node.y + TS - player.bodyoffset.y;
    }
  } else {
    for (n in nodes) {
      trigger = nodes[n];
      if (trigger.name === portal.pport) {
        px = trigger.x + TS / 2;
        py = trigger.y + TS - player.bodyoffset.y;
        switch (portal.pdir) {
        case 'up':
          py -= TS;
          break;
        case 'down':
          py += TS;
          break;
        case 'left':
          px -= TS;
          break;
        case 'right':
          px += TS;
        }
        break;
      }
    }
  }
  for (i$ = 0, len$ = (ref$ = party).length; i$ < len$; ++i$) {
    actor = ref$[i$];
    actor.x = px;
    actor.y = py;
    actor.face(portal.pdir);
    update_water_depth(actor);
    actor.cancel_movement();
  }
  start_camera.call(player);
  npc_events();
  if (typeof temp.callback === 'function') {
    temp.callback();
    delete temp.callback;
  }
}
state.overworld.shutdown = function(){
  player.cancel_movement();
  if (switches.portal == null) {
    dialog.destroy();
  }
  if (switches.portal == null) {
    pause_screen.destroy();
  }
  backdrop.destroy();
  map.destroy();
  Doodad.clear();
  NPC.clear();
  kill_players();
  Trigger.clear();
  Treasure.clear();
  delete dialog;
  delete map;
};
previous_time = Date.now();
function main_update(){
  var now, ref$;
  Transition.update();
  now = Date.now();
  delta = (ref$ = now - previous_time) < 60 ? ref$ : 60;
  deltam = delta / 1000;
  previous_time = now;
  game.time.physicsElapsed = Math.min(game.time.elapsedMS / 1000 * gameOptions.gameSpeed, 0.1);
  game.time.physicsElapsedMS = game.time.physicsElapsed * 1000;
  mouse.update();
}
update_mod = [];
state.overworld.update = function(){
  var bounds, i$, ref$, len$, group, j$, ref1$, len1$, object, f;
  if (switches.portal != null) {
    change_map(switches.portal);
    delete switches.portal;
  }
  main_update();
  if (switches.cinema) {
    update_camera.call(game.camera.center);
  } else {
    update_camera.call(player);
  }
  spawn_controller();
  if (game.input.keyboard.enabled === dialog.textentry.alive) {
    game.input.keyboard.enabled = !dialog.textentry.alive;
  }
  if (getmapdata('edges') === 'loop') {
    bounds = {
      left: player.x - map.widthInPixels / 2,
      right: player.x + map.widthInPixels / 2,
      top: player.y - map.heightInPixels / 2,
      bottom: player.y + map.heightInPixels / 2
    };
    for (i$ = 0, len$ = (ref$ = game.world.children).length; i$ < len$; ++i$) {
      group = ref$[i$];
      if (group instanceof Phaser.Group) {
        for (j$ = 0, len1$ = (ref1$ = group.children).length; j$ < len1$; ++j$) {
          object = ref1$[j$];
          if (object === player) {
            continue;
          }
          if (object.x < bounds.left) {
            object.x += map.widthInPixels;
          }
          if (object.x > bounds.right) {
            object.x -= map.widthInPixels;
          }
          if (object.y < bounds.top) {
            object.y += map.heightInPixels;
          }
          if (object.y > bounds.bottom) {
            object.y -= map.heightInPixels;
          }
        }
      }
    }
  }
  actors.sort('y');
  for (i$ = 0, len$ = (ref$ = update_mod).length; i$ < len$; ++i$) {
    f = ref$[i$];
    if (typeof f == 'function') {
      f();
    }
  }
};
state.load.render = state.load.loadRender = state.overworld.render = state.battle.render = state.title.render = function(){
  copycanvas();
};
state.boot.loadRender = state.preload.loadRender = function(){
  Transition.update();
  copycanvas();
};
function copycanvas(){
  pixel.context.drawImage(game.canvas, 0, 0, game.width, game.height, 0, 0, pixel.width, pixel.height);
}
state.preboot.preload = function(){
  var g;
  batchload([['preloader', 'preloader.png'], ['preloader_back', 'preloader_back.png'], ['title', 'title.png'], ['loading', 'loading.png']], 'img/gui/');
  game.load.json('test', 'img/misc/test.json');
  g = game.add.bitmapData(1, 1, 'solid', true);
  g.ctx.beginPath();
  g.ctx.rect(0, 0, 1, 1);
  g.ctx.fillStyle = '#ffffff';
  g.ctx.fill();
  game.load.image('solid', g.canvas.toDataURL());
  game.load.image('empty', 'img/misc/empty.png');
};
state.preboot.create = function(){
  if (!game.cache.checkJSONKey('test')) {
    fatalerror('sameOrigin');
    return;
  }
  game.state.start('boot');
  bootloader.innerHTML = '';
};
state.boot.preload = function(){
  create_title_background();
  preloader = new Phaser.Image(game, 1, 209, 'loading');
  gui.frame.addChild(preloader);
  game.load.image('logo', 'img/gui/logo.png');
  game.load.bitmapFont('unifont', 'img/font/Filosis.png', 'img/font/Filosis.xml');
};
state.boot.create = function(){
  gui.frame.remove(preloader);
  game.state.start('preload');
};
state.preload.preload = function(){
  preloader = gui.frame.create(0, HEIGHT - TS * 2, 'preloader');
  preloader.back = gui.frame.create(0, preloader.y, 'preloader_back');
  game.load.setPreloadSprite(preloader);
  preloader.text = new Text(null, "Loading...", 2, 210);
  gui.frame.addChild(preloader.text);
  game.load.onFileStart.add(function(progress, key, url){
    if (session.debug) {
      preloader.text.change("Loading " + url);
    } else if (progress === 0) {
      preloader.text.change("Loading...");
    } else {
      preloader.text.change("Loading " + game.load.progress + "%");
    }
  });
  preload_assets();
};
state.preload.create = function(){
  gui.frame.remove(preloader);
  gui.frame.remove(preloader.back);
  gui.frame.remove(preloader.text);
  game.state.start('title');
  tlNames();
};
preload_mod = [];
function preload_assets(){
  var i$, ref$, len$, f;
  batchload([['llov', 'llov.png', 20, 25], ['ebby', 'ebby.png', 22, 25], ['marb', 'marb.png', 22, 28], ['mal', 'mal.png', 22, 28], ['bp', 'bp.png', 22, 28], ['joki', 'joki.png', 22, 25], ['herpes', 'herpes.png', 22, 25], ['pox', 'pox.png', 22, 25], ['leps', 'leps.png', 22, 26], ['sars', 'sars.png', 22, 26], ['aids1', 'eidzu1.png', 20, 25], ['aids2', 'eidzu2.png', 20, 25], ['aids3', 'eidzu3.png', 29, 28], ['rab', 'rabies.png', 22, 26], ['chikun', 'chikun.png', 22, 26], ['ammit', 'ammit.png', 20, 25], ['parvo', 'parvo.png', 20, 25], ['zika', 'zika.png', 22, 25], ['cure', 'cure.png', 22, 28], ['zmapp', 'zmapp.png', 22, 26], ['who', 'who.png', 22, 36], ['min', 'min.png', 20, 25], ['dead', 'dead.png', 20, 25], ['merchant1', 'merchant1.png', 22, 28], ['merchant2', 'merchant2.png', 22, 28], ['shiro', 'shiro.png', 20, 25]], 'img/char/', 'spritesheet');
  /*
  batchload_battler [\llov nurse:0 swim:0 swim2:0 \pumpkin \christmas \valentine \punk],
      [\ebby cheer:0 bat:0 santa:1 witch:0]
      [\marb nurse:0 \maid \bunny \demon]
  */
  batchload([['ebby_battle', 'ebby.png', 96, 86], ['marb_battle', 'marb.png', 96, 86], ['marb_battle_1', 'marb_1.png', 96, 96], ['marb_battle_2', 'marb_2.png', 106, 86], ['llov_battle', 'llov.png', 96, 86], ['llov_battle_christmas', 'llov_christmas.png', 102, 86]], 'img/battle/', 'spritesheet');
  batchload([['llov_base', 'llov_base.png', 120, 130], ['llov_base2', 'llov_base2.png', 120, 140], ['llov_face', 'llov_face.png', 35, 33], ['ebby_base', 'ebby_base.png', 112, 145], ['ebby_base2', 'ebby_base2.png', 112, 155], ['ebby_face', 'ebby_face.png', 37, 33], ['marb_base', 'marb_base.png', 140, 160], ['marb_base2', 'marb_base2.png', 140, 175], ['marb_face', 'marb_face.png', 37, 31]], 'img/port/', 'spritesheet');
  batchload([['mal_port', 'mal.png'], ['bp_port', 'bp.png'], ['joki_port', 'joki.png'], ['herpes_port', 'herpes.png'], ['merchant_port', 'merchant.png'], ['pox_port', 'pox.png'], ['pox_injured', 'pox injured.png'], ['leps_port', 'leps.png'], ['sars_port', 'sars.png'], ['sars_mad', 'sars mad.png'], ['rab_port', 'rabies.png'], ['rab_mad', 'rabies mad.png'], ['rab2_port', 'rabies2.png'], ['aids1_port', 'eidzu1.png'], ['aids1_mad', 'eidzu1 mad.png'], ['aids2_port', 'eidzu2.png'], ['aids2_mad', 'eidzu2 mad.png'], ['aids3_port', 'eidzu3.png'], ['nae_port', 'nae.png'], ['ammit_port', 'ammit.png'], ['chikun_port', 'chikun.png'], ['parvo_port', 'parvo.png'], ['zika_port', 'zika.png'], ['cure_port', 'cure.png'], ['zmapp_port', 'zmapp.png'], ['zmapp_healthy', 'zmapp healthy.png'], ['who_port', 'who.png'], ['min_port', 'min.png'], ['wraith_port', 'wraith.png'], ['war_port', 'war.png'], ['slime_port', 'slime.png'], ['shiro_port', 'shiro.png']], 'img/port/');
  batchload([['mob_slime', 'mob_slime.png', 16, 17], ['mob_ghost', 'mob_ghost.png', 16, 17], ['mob_bat', 'mob_bat.png', 26, 18], ['mob_flytrap', 'mob_flytrap.png', 17, 19], ['mob_corpse', 'mob_corpse.png', 17, 19], ['mob_wisp', 'mob_wisp.png', 22, 22], ['mob_ripple', 'mob_ripple.png', 16, 5], ['mob_arrow', 'mob_arrow.png', 14, 20], ['mob_glitch', 'mob_glitch.png', 24, 25], ['mob_naegleria', 'naegleria_mob.png', 22, 28], ['naegleria', 'naegleria.png', 22, 28], ['wraith', 'wraith.png', 22, 28], ['mob_wraith', 'wraith_mob.png', 22, 28], ['mob_chikun', 'chikun_mob.png', 24, 28], ['mob_llov', 'darkllov.png', 24, 25]], 'img/char/', 'spritesheet');
  batchload([['monster_mimic', 'mimick.png'], ['monster_sanishark', 'sanishark.png'], ['monster_wolf', 'wolf.png'], ['monster_wraith', 'wraith.png'], ['monster_naegleria', 'naegleria.png'], ['monster_cure0', 'cure0.png'], ['monster_cure1', 'cure1.png'], ['monster_zmapp0', 'zmapp0.png'], ['monster_zmapp1', 'zmapp1.png'], ['monster_zmappX', 'zmappX.png'], ['monster_sars', 'sars.png'], ['monster_rabies', 'rabies.png'], ['monster_rabies2', 'rabies_2.png'], ['monster_eidzu1', 'eidzu1.png'], ['monster_eidzu1_2', 'eidzu1_2.png'], ['monster_eidzu2', 'eidzu2.png'], ['monster_eidzu2_2', 'eidzu2_2.png'], ['monster_chikun', 'chikun.png'], ['monster_who', 'who.png'], ['monster_lepsy', 'lepsy.png'], ['monster_parvo', 'parvo.png'], ['monster_zika', 'zika.png'], ['monster_joki', 'joki.png'], ['monster_voideye', 'voideye.png'], ['monster_voidgast', 'voidgast.png'], ['monster_voidtofu', 'voidtofu.png'], ['monster_voidskel', 'voidskel.png'], ['monster_darkllov', 'darkllov.png'], ['monster_mutant', 'mutant.png'], ['monster_throne', 'throne.png']], 'img/battle/');
  batchload([['monster_slime', 'slime_chibi.png', 40, 27], ['monster_slime2', 'slime.png', 56, 46], ['monster_ghost', 'eyeball.png', 52, 64], ['monster_skullghost', 'skullghost1.png', 64, 64], ['monster_graven', 'graven.png', 64, 64], ['monster_eel', 'eel.png', 56, 56], ['monster_cancer', 'cancer.png', 64, 64], ['monster_lurker', 'lurker.png', 64, 64], ['monster_bat', 'bat.png', 64, 64], ['monster_doggie', 'doggie.png', 64, 64], ['monster_mantrap', 'mantrap.png', 64, 64], ['monster_greblin', 'greblin.png', 51, 44], ['monster_polyduck', 'polyduck.png', 64, 64], ['monster_rhinosaurus', 'rhinosaurus.png', 83, 72], ['monster_woolyrhino', 'woolyrhino.png', 83, 72], ['monster_skulmander', 'skulmander.png', 64, 64], ['monster_tengu', 'tengu.png', 71, 79], ['monster_sars_summon', 'sars_summon.png', 20, 20]], 'img/battle/', 'spritesheet');
  batchload([['head_llov', 'head_llov.png'], ['head_ebby', 'head_ebby.png'], ['head_marb', 'head_marb.png'], ['trigger', 'trigger.png'], ['boat', 'boat.png'], ['deadllov', 'deadllov.png'], ['deadmal', 'deadmal.png'], ['deadpox', 'deadpox.png'], ['war', 'war.png'], ['bp_shiro', 'bp_shiro.png']], 'img/misc/');
  batchload([['dust', 'dust.png', 21, 19], ['flame', 'fire.png', 16, 16], ['flameg', 'fireg.png', 16, 16], ['tv', 'tv.png', 16, 16], ['pent', 'pent.png', 32, 32], ['pent_fire', 'pent_fire.png', 32, 32], ['llovsick', 'llovsick.png', 20, 26], ['poxsick', 'poxsick.png', 20, 26], ['joki_fireball', 'joki_fireball.png', 25, 25], ['z', 'z.png', 16, 16], ['zburst', 'zburst.png', 32, 32], ['pest', 'pest.png', 73, 36], ['bloodpool', 'bloodpool.png', 22, 16], ['who_die', 'who_die.png', 22, 36], ['ripple', 'ripple.png', 16, 5]], 'img/misc/', 'spritesheet');
  game.load.image('water', 'img/map/water.png');
  game.load.spritesheet('sun', 'img/map/sun.png', 105, 53);
  game.load.spritesheet('bars', 'img/gui/bars.png', 1, 10);
  game.load.spritesheet('window', 'img/gui/window.png', 16, 16);
  game.load.image('arrow', 'img/gui/arrow.png');
  game.load.image('arrowd', 'img/gui/arrowd.png');
  game.load.image('arrowu', 'img/gui/arrowu.png');
  game.load.image('target', 'img/gui/target.png');
  batchload([['item_lovejuice', 'pot_love.png'], ['item_water', 'pot_water.png']], 'img/item/');
  batchload([['item_misc', 'sheet_common.png', 16, 16], ['item_pot', 'sheet_pot.png', 16, 16], ['item_key', 'sheet_key.png', 16, 16], ['item_equip', 'sheet_equip.png', 16, 16], ['item_equip2', 'sheet_equip2.png', 32, 32], ['buffs', 'sheet_buffs.png', 16, 16]], 'img/item/', 'spritesheet');
  /*
  batchload [
  [\buff_blister, \blister.png]
  [\buff_scab, \scab.png]
  [\buff_fever, \fever.png]
  [\buff_burn1, \burn1.png]
  [\buff_burn2, \burn2.png]
  [\buff_burn3, \burn3.png]
  [\buff_chill, \chill.png]
  [\buff_skull, \skull.png]
  [\buff_lips, \lips.png]
  [\buff_blood, \blood.png]
  [\buff_recover, \recover.png]
  [\buff_seizure, \seizure.png]
  [\buff_shieldbreak, \shieldbreak.png]
  [\buff_weak, \weak.png]
  [\buff_wing, \wing.png]
  ], \img/buff/
  */
  batchload([['bg_0_0', '0_0.png'], ['bg_0_1', '0_1.png'], ['bg_1_0', '1_0.png'], ['bg_1_1', '1_1.png'], ['bg_2_0', '2_0.png'], ['bg_2_1', '2_1.png'], ['bg_3_0', '3_0.png'], ['bg_3_1', '3_1.png'], ['bg_4_0', '4_0.png'], ['bg_4_1', '4_1.png'], ['bg_5_0', '5_0.png'], ['bg_5_1', '5_1.png'], ['bg_5_0a', '5_0a.png'], ['bg_5_1a', '5_1a.png'], ['bg_5_0b', '5_0b.png'], ['bg_5_1b', '5_1b.png'], ['bg_6_0', '6_0.png'], ['bg_6_1', '6_1.png'], ['bg_7_0', '7_0.png'], ['bg_7_1', '7_1.png'], ['bg_7_0s', '7_0s.png'], ['bg_7_1s', '7_1s.png'], ['bg_8_0', '8_0.png'], ['bg_9_0', '9_0.png']], 'img/bg/');
  batchload([['cg_pest', 'pest.png'], ['cg_pest_night', 'pest_night.png'], ['cg_earth', 'earth.png'], ['cg_tower0', 'tower0.png'], ['cg_tower1', 'tower1.png'], ['cg_tower2', 'tower2.png'], ['cg_jungle', 'jungle.png'], ['cg_abyss', 'abyss.png']], 'img/cg/');
  game.load.spritesheet('cg_border', 'img/cg/border.png', 8, 8);
  batchload([['anim_slash', 'slash.png', 36, 42], ['anim_flame', 'flame.png', 42, 42], ['anim_curse', 'curse.png', 42, 42], ['anim_heal', 'heal.png', 42, 42], ['anim_blood1', 'blood1.png', 42, 42], ['anim_blood2', 'blood2.png', 42, 42], ['anim_water', 'water.png', 48, 48], ['anim_arrow', 'arrow.png', 16, 42], ['anim_flies', 'flies.png', 48, 48]], 'img/anim/', 'spritesheet');
  /*
  batchload [
  [\battle [\battle.ogg \battle.m4a]]
  ], \music/ \audio
  */
  batchload([['blip', ['textblip.ogg', 'textblip.m4a']], ['itemget', ['itemget.ogg', 'itemget.m4a']], ['encounter', ['encounter.ogg', 'encounter.m4a']], ['boom', ['boom.ogg', 'boom.m4a']], ['defeat', ['defeat.ogg', 'defeat.m4a']], ['candle', ['candle.ogg', 'candle.m4a']], ['strike', ['strike.ogg', 'strike.m4a']], ['flame', ['flame.ogg', 'flame.m4a']], ['water', ['water.ogg', 'water.m4a']], ['swing', ['swing.ogg', 'swing.m4a']], ['laser', ['laser.ogg', 'laser.m4a']], ['run', ['run.ogg', 'run.m4a']], ['stair', ['stair.ogg', 'stair.m4a']], ['door', ['door.ogg', 'door.m4a']], ['groan', ['groan.ogg', 'groan.m4a']], ['voice', ['voice.ogg', 'voice.m4a']], ['voice2', ['voice2.ogg', 'voice2.m4a']], ['voice3', ['voice3.ogg', 'voice3.m4a']], ['voice4', ['voice4.ogg', 'voice4.m4a']], ['voice5', ['voice5.ogg', 'voice5.m4a']], ['voice6', ['voice6.ogg', 'voice6.m4a']], ['voice7', ['voice7.ogg', 'voice7.m4a']], ['voice8', ['voice8.ogg', 'voice8.m4a']], ['rope', ['ROPE.ogg', 'ROPE.m4a']]], 'sound/', 'audio');
  load_map('hub', 'hub.json');
  load_map('shack1', 'shack1.json');
  load_map('shack2', 'shack2.json');
  load_map('pox_cabin', 'pox_cabin.json');
  load_map('tunnel', 'tunnel.json');
  load_map('tunnel_entrance', 'tunnel_entrance.json');
  load_map('deadworld', 'deadworld.json');
  load_map('tower0', 'tower0.json');
  load_map('tower1', 'tower1.json');
  load_map('tower2', 'tower2.json');
  load_map('towertop', 'towertop.json');
  load_map('ebolaroom', 'ebolaroom.json');
  load_map('delta', 'delta.json');
  load_map('deltashack', 'deltashack.json');
  load_map('deltashack2', 'deltashack2.json');
  load_map('deltashack3', 'deltashack3.json');
  load_map('earth', 'earth.json');
  load_map('earth2', 'earth2.json');
  load_map('earth3', 'earth3.json');
  load_map('basement1', 'basement1.json');
  load_map('basement2', 'basement2.json');
  load_map('necrohut', 'necrohut.json');
  load_map('shrine', 'shrine.json');
  load_map('labdungeon', 'labdungeon.json');
  load_map('lab', 'lab.json');
  load_map('labhall', 'labhall.json');
  load_map('tunneldeep', 'tunneldeep.json');
  load_map('shack3', 'shack3.json');
  load_map('deathtunnel', 'deathtunnel.json');
  load_map('deathdomain', 'deathdomain.json');
  load_map('castle', 'castle.json');
  load_map('void', 'void.json');
  batchload([['tiles', 'tiles.png'], ['tiles_night', 'tiles_night.png'], ['tower_tiles', 'tower.png'], ['tower_tiles_night', 'tower_night.png'], ['towerin_tiles', 'towerin.png'], ['townhouse_tiles', 'townhouse.png'], ['townhouse_tiles_night', 'townhouse_night.png'], ['dungeon_tiles', 'dungeon.png'], ['jungle_tiles', 'jungle.png'], ['home_tiles', 'home.png'], ['delta_tiles', 'delta.png'], ['delta_tiles_night', 'delta_night.png'], ['earth_tiles', 'earth.png'], ['lab_tiles', 'lab.png'], ['castle_tiles', 'castle.png'], ['void_tiles', 'void.png']], 'img/map/');
  batchload([['1x1', '1x1.png', 16, 16], ['1x1_night', '1x1_night.png', 16, 16], ['1x2', '1x2.png', 16, 32], ['1x2_night', '1x2_night.png', 16, 32], ['2x2', '2x2.png', 32, 32], ['2x3', '2x3.png', 32, 48], ['3x3', '3x3.png', 48, 48]], 'img/map/', 'spritesheet');
  for (i$ = 0, len$ = (ref$ = preload_mod).length; i$ < len$; ++i$) {
    f = ref$[i$];
    if (typeof f == 'function') {
      f();
    }
  }
}
gui_mod = [];
function create_gui(){
  var i$, ref$, len$, f;
  if (gui != null) {
    return;
  }
  gui = game.add.group(null, 'gui', true);
  gui.classType = Phaser.Image;
  gui.title = game.add.group(gui, 'gui_title');
  gui.title.classType = Phaser.Image;
  gui.dock = game.add.group(gui, 'gui_bottom');
  gui.dock.classType = Phaser.Image;
  gui.frame = game.add.group(gui, 'gui_frame');
  gui.frame.classType = Phaser.Image;
  set_gui_frame();
  for (i$ = 0, len$ = (ref$ = gui_mod).length; i$ < len$; ++i$) {
    f = ref$[i$];
    if (typeof f == 'function') {
      f();
    }
  }
}
function set_gui_frame(){
  resize_callbacks();
  if (gui == null) {
    return;
  }
  gui.title.x = gui.frame.x = Math.floor((game.width - WIDTH) / 2);
  gui.title.y = gui.frame.y = Math.floor((game.height - HEIGHT) / 2);
  gui.dock.x = Math.floor(game.width / 2);
  gui.dock.y = game.height;
}
resize_callback.list = [];
function resize_callback(context, callback, args){
  resize_callback.list.push({
    context: context,
    callback: callback,
    arguments: args
  });
}
function resize_callbacks(){
  var i$, ref$, i, c;
  for (i$ = (ref$ = resize_callback.list).length - 1; i$ >= 0; --i$) {
    i = i$;
    c = ref$[i$];
    if (c.context.alive) {
      process_callbacks(c);
    } else {
      resize_callback.list.splice(i, 1);
    }
  }
}
function start_dialog_controller(){
  dialog = gui.dock.addChild(
  new DialogWindow());
  dialog.kill();
}
function say(){
  var message, speaker, pose;
  if (typeof arguments[0] === 'function') {
    if (this instanceof Menu) {
      this.queue.push(arguments[0]);
    } else {
      dialog.say(arguments[0]);
    }
    return;
  }
  switch (arguments.length) {
  case 1:
    message = arguments[0];
    break;
  case 2:
    speaker = arguments[0];
    message = arguments[1];
    break;
  case 3:
    speaker = arguments[0];
    pose = arguments[1];
    message = arguments[2];
  }
  if (this instanceof Menu) {
    this.queue.push({
      speaker: speaker,
      message: message,
      pose: pose
    });
  } else {
    dialog.say(speaker, message, pose);
  }
}
function say_now(){
  var message, speaker, pose;
  switch (arguments.length) {
  case 1:
    message = arguments[0];
    break;
  case 2:
    speaker = arguments[0];
    message = arguments[1];
    break;
  case 3:
    speaker = arguments[0];
    pose = arguments[1];
    message = arguments[2];
  }
  dialog.say_now(speaker, message, pose);
}
function menu(){
  var options, actions, i$, len$, i, option, action;
  if (!dialog.menu.check_arguments.apply(dialog.menu, arguments)) {
    return;
  }
  options = [];
  actions = [];
  for (i$ = 0, len$ = (arguments).length; i$ < len$; i$ += 2) {
    i = i$;
    option = (arguments)[i$];
    action = arguments[i + 1];
    options.push(option);
    actions.push(action);
  }
  if (this instanceof Menu) {
    this.queue.push({
      options: options,
      actions: actions
    });
  } else {
    dialog.queue.push({
      options: options,
      actions: actions
    });
  }
}
function show(pose){
  pose == null && (pose = 'default');
  dialog.queue.push({
    pose: pose
  });
}
function number(note, min, max){
  min == null && (min = 0);
  max == null && (max = 999);
  (this instanceof Menu ? this : dialog).queue.push({
    numberdialog: note,
    min: min,
    max: max
  });
}
function textentry(limit, message, callback){
  var f;
  f = function(){
    dialog.textentry.show(limit, message, function(){
      callback.apply(this, arguments);
      dialog.click('ignorelock');
    });
  };
  f.autocall = true;
  (this instanceof Menu ? this : dialog).queue.push(f);
}
Window = (function(superclass){
  var prototype = extend$((import$(Window, superclass).displayName = 'Window', Window), superclass).prototype, constructor = Window;
  function Window(x, y, w, h, nowindow){
    this.w = w;
    this.h = h;
    this.nowindow = nowindow != null ? nowindow : false;
    Window.superclass.call(this, game, null, 'window');
    this.x = x;
    this.y = y;
    if (!this.nowindow) {
      this.addChild(this.tile_tl = new Phaser.TileSprite(game, 0, 0, WS, WS, 'window', 0));
      this.addChild(this.tile_t = new Phaser.TileSprite(game, WS, 0, 0, WS, 'window', 1));
      this.addChild(this.tile_tr = new Phaser.TileSprite(game, 0, 0, WS, WS, 'window', 2));
      this.addChild(this.tile_l = new Phaser.TileSprite(game, 0, WS, WS, 0, 'window', 3));
      this.addChild(this.tile_c = new Phaser.TileSprite(game, WS, WS, 0, 0, 'window', 4));
      this.addChild(this.tile_r = new Phaser.TileSprite(game, 0, WS, WS, 0, 'window', 5));
      this.addChild(this.tile_bl = new Phaser.TileSprite(game, 0, 0, WS, WS, 'window', 6));
      this.addChild(this.tile_b = new Phaser.TileSprite(game, WS, 0, 0, WS, 'window', 7));
      this.addChild(this.tile_br = new Phaser.TileSprite(game, 0, 0, WS, WS, 'window', 8));
      constructor.prototype.resize.call(this, this.w, this.h);
      this.tiles = [this.tile_tl, this.tile_t, this.tile_tr, this.tile_l, this.tile_c, this.tile_r, this.tile_bl, this.tile_b, this.tile_br];
    }
  }
  Window.prototype.addText = function(font, string, x, y, teletype, lineWidth, lineHeight){
    return this.addChild(new Text(font, string, x, y, teletype, lineWidth, lineHeight));
  };
  Window.prototype.update = function(){
    var i$, ref$, len$, child;
    if (this.alive) {
      for (i$ = 0, len$ = (ref$ = this.children).length; i$ < len$; ++i$) {
        child = ref$[i$];
        child.update();
      }
    }
  };
  Window.prototype.kill = Phaser.Sprite.prototype.kill;
  Window.prototype.revive = function(){
    Phaser.Sprite.prototype.revive.apply(this, arguments);
    this.onRevive();
  };
  Window.prototype.onRevive = function(){};
  Window.prototype.resize = function(w, h){
    this.w = w;
    this.h = h;
    if (this.nowindow) {
      return;
    }
    this.tile_t.width = this.tile_c.width = this.tile_b.width = (this.w - 2) * WS;
    this.tile_l.height = this.tile_c.height = this.tile_r.height = (this.h - 2) * WS;
    this.tile_tr.x = this.tile_r.x = this.tile_br.x = (this.w - 1) * WS;
    this.tile_bl.y = this.tile_b.y = this.tile_br.y = (this.h - 1) * WS;
  };
  return Window;
}(Phaser.Group));
CGWindow = (function(superclass){
  var prototype = extend$((import$(CGWindow, superclass).displayName = 'CGWindow', CGWindow), superclass).prototype, constructor = CGWindow;
  function CGWindow(){
    var BS;
    CGWindow.superclass.call(this, game, null, 'cg');
    this.cg2 = this.addChild(
    new Phaser.Image(game, 0, 0, 'cg_pest'));
    this.cg = this.addChild(
    new Phaser.Image(game, 0, 0, 'cg_pest'));
    this.cg2.kill();
    this.BS = BS = getCachedImage('cg_border').frameWidth;
    this.bl = this.addChild(
    new Phaser.TileSprite(game, -BS + 1, 0, BS, BS, 'cg_border', 1));
    this.br = this.addChild(
    new Phaser.TileSprite(game, 0, 0, BS, BS, 'cg_border', 1));
    this.bt = this.addChild(
    new Phaser.TileSprite(game, 0, -BS + 1, BS, BS, 'cg_border', 0));
    this.bb = this.addChild(
    new Phaser.TileSprite(game, 0, 0, BS, BS, 'cg_border', 0));
    this.btl = this.addChild(
    new Phaser.TileSprite(game, -BS + 1, -BS + 1, BS, BS, 'cg_border', 2));
    this.bbl = this.addChild(
    new Phaser.TileSprite(game, -BS + 1, 0, BS, BS, 'cg_border', 4));
    this.btr = this.addChild(
    new Phaser.TileSprite(game, 0, -BS + 1, BS, BS, 'cg_border', 3));
    this.bbr = this.addChild(
    new Phaser.TileSprite(game, 0, 0, BS, BS, 'cg_border', 5));
    this.resize(this.cg.width, this.cg.height);
    this.border = [this.btl, this.bt, this.btr, this.bl, this.br, this.bbl, this.bb, this.bbr];
  }
  CGWindow.prototype.resize = function(w, h){
    this.w = w;
    this.h = h;
    this.br.height = this.bl.height = this.h;
    this.bb.width = this.bt.width = this.w;
    this.bbr.x = this.btr.x = this.br.x = this.w - 1;
    this.bbr.y = this.bbl.y = this.bb.y = this.h - 1;
  };
  CGWindow.prototype.crop = function(x, y, w, h){
    if (this.w !== w || this.h !== h) {
      this.resize(w, h);
    }
    this.cg.crop({
      x: x,
      y: y,
      width: w,
      height: h
    });
  };
  CGWindow.prototype.kill = Phaser.Sprite.prototype.kill;
  CGWindow.prototype.revive = Phaser.Sprite.prototype.revive;
  CGWindow.prototype.show = function(key, fin){
    var transition;
    dialog.move_to_frame();
    this.revive();
    this.alpha = 0;
    cinema_start();
    if (key) {
      this.cg.loadTexture(key);
    }
    transition = new Transition(500, function(t){
      solidscreen.alpha = 0.8 * t;
      return this.alpha = t;
    }, function(){
      return typeof fin == 'function' ? fin() : void 8;
    }, null, true, this, this);
  };
  CGWindow.prototype.hide = function(fin){
    var transition;
    transition = new Transition(500, function(t){
      solidscreen.alpha = 0.8 * (1 - t);
      return this.alpha = 1 - t;
    }, function(){
      dialog.move_to_bottom();
      this.kill();
      cinema_stop();
      return typeof fin == 'function' ? fin() : void 8;
    }, null, true, this, this);
  };
  CGWindow.prototype.showfast = function(key){
    this.revive();
    if (key) {
      this.cg.loadTexture(key);
    }
    this.alpha = 1;
  };
  CGWindow.prototype.fade = function(key, fin){
    var transition;
    this.cg2.revive();
    this.cg2.loadTexture(this.cg.key);
    this.cg.alpha = 0;
    this.cg.loadTexture(key);
    transition = new Transition(500, function(t){
      return this.cg.alpha = t;
    }, function(){
      this.cg2.kill();
      if (typeof fin == 'function') {
        fin();
      }
    }, null, true, this, this);
  };
  return CGWindow;
}(Phaser.Group));
DialogWindow = (function(superclass){
  var prototype = extend$((import$(DialogWindow, superclass).displayName = 'DialogWindow', DialogWindow), superclass).prototype, constructor = DialogWindow;
  function DialogWindow(){
    DialogWindow.superclass.call(this, -144, -80, 18, 4);
    this.speaker = this.addText('font_yellow', '', 10, 8);
    this.message = this.addText(null, '', 8, 20, true, 45, 12);
    this.port = this.addChild(new Portrait(WS * 18, 0, null));
    this.port.anchor.set(1.0);
    this.menu = this.addChild(new Menu(0, -WS * 6.5, 12, 6));
    this.number = this.addChild(new Number_Dialog(0, -WS * 6.5));
    this.textentry = gui.frame.addChild(new TextEntry(WS, WS * 4));
    this.textentry.kill();
    this.port.kill();
    this.menu.kill();
    this.number.kill();
    this.queue = [];
    this.menu.queue = [];
    game.input.onDown.add(this.click, this);
    keyboard.confirm.onDown.add(this.click, this);
  }
  DialogWindow.prototype.say = function(speaker, message, pose){
    var reviveme;
    speaker == null && (speaker = null);
    message == null && (message = '');
    pose == null && (pose = null);
    reviveme = this.queue.length === 0;
    if (reviveme === true) {
      this.revive();
    }
    if (typeof speaker === 'function') {
      this.queue.push(speaker);
    } else {
      this.queue.push({
        speaker: speaker,
        message: message,
        pose: pose
      });
    }
    if (reviveme !== false) {
      if (typeof actors != 'undefined' && actors !== null) {
        actors.paused = true;
      }
      this.next();
    }
  };
  DialogWindow.prototype.update = function(){
    var h;
    superclass.prototype.update.apply(this, arguments);
    h = this.message.string && this.message.height > 40 ? 5 : 4;
    if (this.h !== h) {
      this.resize(this.w, h);
    }
  };
  DialogWindow.prototype.say_now = function(speaker, message, pose){
    speaker == null && (speaker = null);
    message == null && (message = '');
    pose == null && (pose = null);
    this.menu.history = [];
    this.queue.shift();
    this.queue.unshift({
      speaker: speaker,
      message: message,
      pose: pose
    });
    this.next();
  };
  DialogWindow.prototype.next = function(){
    var ref$, name, portpose;
    if (typeof (ref$ = this.queue)[0] == 'function') {
      ref$[0]();
    }
    name = (ref$ = this.queue[0].speaker) != null ? ref$.toLowerCase() : void 8;
    portpose = this.queue[0].pose;
    this.port.change(name, portpose);
    if (this.queue[0].options != null) {
      this.next_menu();
    } else if (this.queue[0].numberdialog != null) {
      dialog.number.show(this.queue[0].numberdialog, this.queue[0].min, this.queue[0].max);
    }
    if (this.queue[0].message == null) {
      this.click();
      return;
    }
    if (speakers[name] != null) {
      this.speaker.change(speakers[name].display);
      this.speaker_key = name;
    } else if (name != null) {
      this.speaker.change(this.queue[0].speaker);
      this.speaker_key = '';
    }
    this.message.change(this.queue[0].message);
    console.log(this.speaker.get_text() + ' says "' + this.queue[0].message + '"');
  };
  DialogWindow.prototype.next_menu = function(){
    if (this.queue[0].options != null) {
      this.menu.offset = 0;
      this.menu.revive();
      this.menu.options = this.queue[0].options;
      this.menu.actions = this.queue[0].actions;
      this.menu.refresh();
      this.resize_menu();
    } else {
      this.menu.kill();
    }
  };
  DialogWindow.prototype.resize_menu = function(){
    var longestoption, i$, ref$, len$, option, ref1$;
    longestoption = 0;
    for (i$ = 0, len$ = (ref$ = this.menu.options).length; i$ < len$; ++i$) {
      option = ref$[i$];
      longestoption = (ref1$ = option.length * FW + 20) > longestoption ? ref1$ : longestoption;
    }
    this.menu.resize(Math.ceil(longestoption / WS), (ref$ = this.menu.options.length + 2) < 6 ? ref$ : 6);
  };
  DialogWindow.prototype.click = function(e){
    var ref$, ref1$, ref2$, ref3$, i$, ref4$, len$, item;
    e == null && (e = {});
    if ((this.locked || ((ref$ = this.textentry) != null && ref$.alive)) && e !== 'ignorelock') {
      return;
    }
    if (!(this.alive && nullbutton(e.button))) {
      return;
    }
    if (this.menu.alive && e !== 'ignorelock') {
      return true;
    }
    if (this.number.alive) {
      return true;
    }
    if (this.message.textbuffer.length > 0 && e !== 'ignorelock') {
      this.message.empty_buffer();
      if (((ref1$ = this.queue[1]) != null ? ref1$.options : void 8) != null || ((ref2$ = this.queue[1]) != null ? ref2$.numberdialog : void 8) != null || ((ref3$ = this.queue[1]) != null && ref3$.autocall)) {
        this.click();
      }
      return true;
    }
    this.queue.shift();
    for (i$ = 0, len$ = (ref4$ = this.menu.queue).length; i$ < len$; ++i$) {
      item = ref4$[i$];
      this.queue.unshift(this.menu.queue.pop());
    }
    if (this.queue.length === 0) {
      this.kill();
    } else {
      this.next();
    }
    menusound.play('blip');
    return false;
  };
  DialogWindow.prototype.kill = function(){
    superclass.prototype.kill.apply(this, arguments);
    this.menu.kill();
    if (pause_screen.alive) {
      pause_screen.visible = true;
    }
    this.port.change(null, 'default');
  };
  DialogWindow.prototype.revive = function(){
    superclass.prototype.revive.apply(this, arguments);
    if (pause_screen.alive) {
      pause_screen.visible = false;
    }
    menusound.play('blip');
  };
  DialogWindow.prototype.move_to_frame = function(nowindow, hideport){
    var i$, ref$, len$, tile;
    nowindow == null && (nowindow = true);
    this.hideport = hideport != null ? hideport : false;
    for (i$ = 0, len$ = (ref$ = this.tiles).length; i$ < len$; ++i$) {
      tile = ref$[i$];
      tile.visible = !nowindow;
    }
    this.port.y = HEIGHT;
    this.x = 0;
    this.y = 0;
    gui.frame.addChild(this.parent.removeChild(this));
    this.menu.y = 64;
    for (i$ = 0, len$ = (ref$ = this.menu.tiles).length; i$ < len$; ++i$) {
      tile = ref$[i$];
      tile.visible = !nowindow;
    }
  };
  DialogWindow.prototype.move_to_bottom = function(nowindow, hideport){
    var i$, ref$, len$, tile;
    nowindow == null && (nowindow = false);
    this.hideport = hideport != null ? hideport : false;
    for (i$ = 0, len$ = (ref$ = this.tiles).length; i$ < len$; ++i$) {
      tile = ref$[i$];
      tile.visible = !nowindow;
    }
    this.port.y = 0;
    this.x = -144;
    this.y = -80;
    gui.dock.addChild(this.parent.removeChild(this));
    this.menu.y = -104;
    for (i$ = 0, len$ = (ref$ = this.menu.tiles).length; i$ < len$; ++i$) {
      tile = ref$[i$];
      tile.visible = !nowindow;
    }
  };
  return DialogWindow;
}(Window));
Text = (function(superclass){
  var prototype = extend$((import$(Text, superclass).displayName = 'Text', Text), superclass).prototype, constructor = Text;
  function Text(color, string, x, y, teletype, lineWidth, lineHeight){
    var this$ = this;
    color == null && (color = 'font');
    this.string = string != null ? string : '';
    x == null && (x = 0);
    y == null && (y = 0);
    this.teletype = teletype != null ? teletype : false;
    this.lineWidth = lineWidth != null ? lineWidth : 0;
    this.lineHeight = lineHeight != null ? lineHeight : 12;
    Text.superclass.call(this, game, x, y);
    color = this.font_to_color(color);
    this.font = 'unifont';
    this.bitmap = new Phaser.BitmapText(game, 0, 0, this.font, '', 10);
    this.addChild(this.shadow1 = new Phaser.Image(game, -1, 0, 'empty'));
    this.addChild(this.shadow2 = new Phaser.Image(game, 0, -1, 'empty'));
    this.addChild(this.face = new Phaser.Image(game, -1, -1, 'empty'));
    this.shadow1.anchorlink = this.shadow2.anchorlink = this.face.anchorlink = true;
    if (game.renderType === Phaser.WEBGL) {
      this.bitmap.tint = color;
    }
    this.shadow1.tint = this.shadow2.tint = this.tint = 0;
    this.timer = 0;
    this.textbuffer = [];
    this.real_anchor = new Phaser.Point();
    this.change(string, color);
    Object.defineProperty(this.anchor, 'x', {
      set: function(v){
        var i$, ref$, len$, child, results$ = [];
        for (i$ = 0, len$ = (ref$ = this$.children).length; i$ < len$; ++i$) {
          child = ref$[i$];
          if (child.anchorlink) {
            child.anchor.x = Math.ceil(this$.width * v) / (this$.width || 1);
            results$.push(this$.real_anchor.x = v);
          }
        }
        return results$;
      },
      get: function(){
        return this$.face.anchor.x;
      }
    });
    Object.defineProperty(this.anchor, 'y', {
      set: function(v){
        var i$, ref$, len$, child, results$ = [];
        for (i$ = 0, len$ = (ref$ = this$.children).length; i$ < len$; ++i$) {
          child = ref$[i$];
          if (child.anchorlink) {
            child.anchor.y = Math.ceil(this$.height * v) / (this$.height || 1);
            results$.push(this$.real_anchor.y = v);
          }
        }
        return results$;
      },
      get: function(){
        return this$.face.anchor.y;
      }
    });
    this.anchor.set = function(x, y){
      this$.anchor.x = x;
      this$.anchor.y = y;
      return this$.anchor;
    };
  }
  Text.prototype.font_to_color = function(font){
    switch (font) {
    case 'font':
      return constructor.WHITE;
    case 'font_gray':
      return constructor.GRAY;
    case 'font_green':
      return constructor.GREEN;
    case 'font_red':
      return constructor.RED;
    case 'font_yellow':
      return constructor.YELLOW;
    default:
      return font;
    }
  };
  Text.prototype.change = function(text, color){
    var teletype;
    if (this.textbuffer.length > 0) {
      this.empty_buffer();
    }
    text == null && (text = this.string);
    text = breakLines3(text, this.lineWidth, this.font);
    teletype = gameOptions.quicktext
      ? false
      : this.teletype;
    this.textbuffer = teletype
      ? split$.call(text, '')
      : [];
    this.string = teletype ? '' : text;
    color = this.font_to_color(color);
    this.bitmap.color = color;
    if (game.renderType === Phaser.WEBGL) {
      if (color != null && this.bitmap.tint !== color) {
        this.bitmap.tint = color;
      }
    } else {
      this.face.alpha = color === Text.RED || color === Text.GRAY ? 0.5 : 1;
    }
    this.update_text();
  };
  Text.prototype.buffer = function(text){
    this.textbuffer = this.textbuffer.concat(split$.call(text, ''));
  };
  Text.prototype.empty_buffer = function(){
    this.string += this.textbuffer.join('');
    this.textbuffer.length = 0;
    this.update_text();
  };
  Text.prototype.update = function(){
    var i$, ref$, len$, t, speed, count, soundkey, ref1$, ref2$, ref3$;
    if (this.textbuffer.length === 0) {
      return;
    }
    for (i$ = 0, len$ = (ref$ = Transition.list).length; i$ < len$; ++i$) {
      t = ref$[i$];
      if (t.cinematic) {
        return;
      }
    }
    speed = 100 - gameOptions.textspeed;
    if (speed === 0) {
      this.empty_buffer();
    } else {
      this.timer += game.time.elapsed;
      count = (ref$ = Math.floor(game.time.elapsed / speed)) > 1 ? ref$ : 1;
      if (this.timer > speed * count) {
        if (Date.now() - voicesound.lastplayedtime > ((ref$ = speed * 2.5) > 100 ? ref$ : 100)) {
          soundkey = this.parent === dialog && ((ref$ = speakers[dialog.speaker_key]) != null ? ref$.voice : void 8) != null ? speakers[dialog.speaker_key].voice : 'blip';
          voicesound.play(soundkey, true);
          if (soundkey !== 'blip') {
            voicesound[soundkey]._sound.playbackRate.value = Math.random() * 0.2 + 0.9;
          }
        }
        for (i$ = 1; i$ <= count; ++i$) {
          this.string += this.textbuffer.shift();
          if (this.textbuffer.length === 0) {
            break;
          }
        }
        this.timer -= speed * count;
        this.update_text();
      }
    }
    if (this.parent instanceof DialogWindow && this.textbuffer.length === 0 && (((ref1$ = this.parent.queue[1]) != null && ref1$.options) || ((ref2$ = this.parent.queue[1]) != null ? ref2$.numberdialog : void 8) != null || ((ref3$ = this.parent.queue[1]) != null && ref3$.autocall))) {
      this.parent.click();
    }
  };
  Text.prototype.update_text = function(){
    var i$, ref$, len$, i, char, stripstring, c, texture;
    game.cache.getBitmapFont(this.font).font.lineHeight = this.lineHeight;
    this.bitmap.setText(this.string);
    this.bitmap.updateText();
    if (this.monospace) {
      for (i$ = 0, len$ = (ref$ = this.bitmap.children).length; i$ < len$; ++i$) {
        i = i$;
        char = ref$[i$];
        char.x = i * this.monospace;
      }
    }
    if (game.renderType === Phaser.WEBGL) {
      stripstring = this.string.replace(/\r?\n|\r/g, '');
      stripstring = Array.from ? Array.from(stripstring) : stripstring;
      for (i$ = 0, len$ = (ref$ = this.bitmap.children).length; i$ < len$; ++i$) {
        i = i$;
        char = ref$[i$];
        if (constructor.colormap[stripstring[i]] != null) {
          char.tint = constructor.colormap[stripstring[i]];
        }
        if (i > 0 && (c = constructor.dualcolors[stripstring[i - 1] + stripstring[i]])) {
          c[0] && (this.bitmap.children[i - 1].tint = c[0]);
          c[1] && (this.bitmap.children[i].tint = c[1]);
        }
      }
    }
    texture = this.bitmap.generateTexture();
    this.shadow1.loadTexture(texture);
    this.shadow2.loadTexture(texture);
    this.face.loadTexture(texture);
    this.loadTexture(texture);
    this.anchor.set(this.real_anchor.x, this.real_anchor.y);
  };
  Text.prototype.hover = function(){
    return mouse.x >= this.worldTransform.tx - this.width * this.anchor.x - 2 && mouse.x < this.worldTransform.tx + this.width * (1 - this.anchor.x) && mouse.y >= this.worldTransform.ty - this.height * this.anchor.y - 2 && mouse.y < this.worldTransform.ty + this.height * (1 - this.anchor.y);
  };
  Text.prototype.kill = Phaser.Sprite.prototype.kill;
  Text.prototype.revive = Phaser.Sprite.prototype.revive;
  Text.prototype.get_text = function(){
    return this.string;
  };
  Text.WHITE = 0xd8d8d8;
  Text.GRAY = 0x787878;
  Text.GREEN = 0x58d858;
  Text.RED = 0xf85858;
  Text.ORANGE = 0xf8aa33;
  Text.YELLOW = 0xf8d878;
  Text.BLUE = 0x78f8ef;
  Text.PURPLE = 0xaf5996;
  Text.INDIGO = 0x816ee2;
  Text.BLACK = 0x475381;
  Text.CRIMSON = 0xc4321a;
  Text.colormap = {
    '♥': Text.RED,
    '♡': Text.RED,
    '🧡': Text.ORANGE,
    '💛': Text.YELLOW,
    '💚': Text.GREEN,
    '💙': Text.BLUE,
    '💜': Text.PURPLE,
    '🖤': Text.BLACK,
    '👺': Text.RED,
    '⚕': Text.RED,
    '★': Text.YELLOW,
    '☆': Text.YELLOW,
    '♩': Text.BLUE,
    '♪': Text.BLUE,
    '♫': Text.BLUE,
    '♬': Text.BLUE,
    '✚': Text.GREEN,
    '\ueb00': Text.WHITE,
    '\ueb02': Text.WHITE,
    '\ueb06': Text.WHITE,
    '\ueb07': Text.WHITE,
    '\ueb01': Text.RED,
    '\ueb03': Text.RED,
    '💧': Text.BLUE,
    '✖': Text.INDIGO
  };
  Text.dualcolors = {
    '\ueb00⚕': [Text.RED, null],
    '⚕\ueb02': [null, Text.RED],
    '\ueb09🧡': [Text.RED, Text.ORANGE],
    '🧡\ueb0A': [Text.ORANGE, Text.RED],
    '\ueb04✖': [Text.GRAY, Text.INDIGO],
    '\ueb01\ueb05': [Text.INDIGO, Text.GRAY],
    '\ueb04\ueb01': [Text.GRAY, Text.INDIGO],
    '✖\ueb05': [Text.INDIGO, Text.GRAY],
    '\ueb06\ueb01': [null, Text.PURPLE]
  };
  Text.prototype.invalid_chars = function(c){
    var code;
    code = c.codePointAt(0);
    if (game.cache.getBitmapFont(this.font).font.chars[code]) {
      return c;
    }
    return "\ufffd";
  };
  return Text;
}(Phaser.Image));
FloatingText = (function(superclass){
  var prototype = extend$((import$(FloatingText, superclass).displayName = 'FloatingText', FloatingText), superclass).prototype, constructor = FloatingText;
  function FloatingText(font, string, x, y, life, speed){
    this.life = life != null ? life : 2;
    this.speed = speed;
    FloatingText.superclass.call(this, font, string, x, y);
    this.anchor.set(0.5, 1.0);
  }
  FloatingText.prototype.preUpdate = function(){
    superclass.prototype.preUpdate.apply(this, arguments);
    if (!this.alive) {
      return;
    }
    if (this.lifespan < 1000) {
      this.alpha = this.lifespan / 1000;
    }
    this.y -= 10 * game.time.physicsElapsed;
    if (this.lifespan > 0) {
      this.lifespan -= this.game.time.physicsElapsedMS;
      if (this.lifespan <= 0) {
        this.kill();
        return false;
      }
    }
    return true;
  };
  FloatingText.prototype.show = function(x, y, text, font){
    this.x = x;
    this.y = y;
    this.alpha = 1;
    this.lifespan = this.life * 2000;
    this.revive();
    this.change(text, font);
  };
  FloatingText.prototype.callback = function(){};
  FloatingText.prototype.kill = function(){
    this.callback();
    return superclass.prototype.kill.apply(this, arguments);
  };
  return FloatingText;
}(Text));
TextEntry = (function(superclass){
  var prototype = extend$((import$(TextEntry, superclass).displayName = 'TextEntry', TextEntry), superclass).prototype, constructor = TextEntry;
  function TextEntry(x, y, limit){
    var w, h;
    this.limit = limit != null ? limit : 140;
    w = 18;
    h = 6;
    TextEntry.superclass.call(this, x, y, w, h);
    this.string = '';
    this.prompt = '';
    this.entry = this.addText('font_yellow', '_', HWS, HWS, false, (w - 1) * WS / FW, 12);
    this.limit_text = this.addText('font', '' + this.limit, (w - 0.5) * WS, (h - 1) * WS);
    this.limit_text.anchor.set(1, 0);
    this.confirm = this.addText(null, 'Confirm', HWS, (h - 1) * WS);
    this.caret_start = 0;
    this.caret_end = 0;
    game.input.onDown.add(this.click, this);
  }
  TextEntry.prototype.update = function(){
    var newstring, i$, ref$, len$, c, to$, i, char;
    if (!this.alive) {
      return;
    }
    textinput.focus();
    if (this.string !== textinput.value || this.caret_start !== textinput.selectionStart || this.caret_end !== textinput.selectionEnd) {
      this.caret_start = textinput.selectionStart;
      this.caret_end = textinput.selectionEnd;
      if (textinput.value.length > this.limit) {
        textinput.value = textinput.value.substr(0, this.limit);
      }
      newstring = '';
      for (i$ = 0, len$ = (ref$ = Array.from
        ? Array.from(textinput.value)
        : textinput.value).length; i$ < len$; ++i$) {
        c = ref$[i$];
        newstring += this.entry.invalid_chars(c);
      }
      this.string = textinput.value = newstring;
      this.entry.change(this.string || this.prompt);
      this.limit_text.change('' + (this.limit - this.string.length));
      for (i$ = this.caret_start, to$ = this.caret_end; i$ <= to$; ++i$) {
        i = i$;
        if (!(char = this.entry.bitmap.children[i])) {
          break;
        }
        char.tint = i === this.caret_end
          ? 0xffffff
          : Text.BLUE;
      }
      this.entry.face.loadTexture(this.entry.bitmap.generateTexture());
      this.resize();
    }
    if (this.confirm.hover()) {
      if (this.confirm.bitmap.color !== Text.YELLOW) {
        this.confirm.change(null, 'font_yellow');
        menusound.play('blip');
      }
    } else {
      if (this.confirm.bitmap.color !== Text.WHITE) {
        this.confirm.change(null, 'font');
      }
    }
  };
  TextEntry.prototype.click = function(){
    if (!this.alive) {
      return;
    }
    if (this.confirm.hover()) {
      this.enter();
      return false;
    }
  };
  TextEntry.prototype.enter = function(){
    if (!this.alive) {
      return;
    }
    this.kill();
    this.callback(this.string);
  };
  TextEntry.prototype.show = function(limit, message, callback){
    this.limit = limit != null ? limit : 140;
    message == null && (message = 'Say something!');
    this.callback = callback;
    reset_keyboard();
    this.revive();
    this.string = textinput.value = '';
    this.caret_start = this.caret_end = 0;
    this.prompt = message;
    this.entry.change(message);
    this.limit_text.change('' + this.limit);
    this.resize();
    menusound.play('blip');
  };
  TextEntry.prototype.resize = function(){
    var h;
    h = Math.max(3, Math.ceil((this.entry.height + WS + this.entry.lineHeight) / WS));
    if (!this.entry.string) {
      h = 3;
    }
    if (h !== this.h) {
      superclass.prototype.resize.call(this, this.w, h);
    }
    this.y = HHEIGHT - h * HWS;
    this.limit_text.y = this.confirm.y = (this.h - 1) * WS;
  };
  return TextEntry;
}(Window));
Menu_Base = (function(superclass){
  var prototype = extend$((import$(Menu_Base, superclass).displayName = 'Menu_Base', Menu_Base), superclass).prototype, constructor = Menu_Base;
  function Menu_Base(x, y, w, h, nowindow){
    Menu_Base.superclass.apply(this, arguments);
    this.arrowd = this.addChild(new Phaser.Sprite(game, 0, 5, 'arrowd', 0));
    this.arrowu = this.addChild(new Phaser.Sprite(game, 0, 5, 'arrowu', 0));
    this.arrowd.anchor.set(0.54, 1.0);
    this.arrowu.anchor.set(0.54, 0);
    this.arrowd.oy = this.arrowd.y;
    this.arrowu.oy = this.arrowu.y;
    game.input.onDown.add(this.click, this);
    keyboard.up.keyDown.add(this.ーup, this);
    keyboard.down.keyDown.add(this.ーdown, this);
    keyboard.left.keyDown.add(this.ーleft, this);
    keyboard.right.keyDown.add(this.ーright, this);
    keyboard.confirm.onDown.add(this.select, this);
    keyboard.cancel.onDown.add(function(){
      return this.cancel.apply(this, arguments);
    }, this);
    Menu.list.push(this);
  }
  Menu_Base.prototype.click = function(){};
  Menu_Base.prototype.select = function(){};
  Menu_Base.prototype.cancel = function(){};
  Menu_Base.prototype.ーup = function(){};
  Menu_Base.prototype.ーdown = function(){};
  Menu_Base.prototype.ーleft = function(){};
  Menu_Base.prototype.ーright = function(){};
  Menu_Base.prototype.scroll = function(){};
  Menu_Base.prototype.destroy = function(){
    superclass.prototype.destroy.apply(this, arguments);
    Menu.list.splice(Menu.list.indexOf(this), 1);
  };
  return Menu_Base;
}(Window));
Number_Dialog = (function(superclass){
  var prototype = extend$((import$(Number_Dialog, superclass).displayName = 'Number_Dialog', Number_Dialog), superclass).prototype, constructor = Number_Dialog;
  function Number_Dialog(x, y){
    var w, h;
    w = 12;
    h = 4;
    Number_Dialog.superclass.call(this, x, y, w, h, false);
    this.num = 0;
    this.number = this.addText('font_yellow', '0 0 0', 10, WS + HWS);
    this.number.anchor.set(0, 0);
    this.number.monospace = FW2;
    this.note = this.addText(null, 'Max', (w - 0.5) * WS, (h - 1) * WS);
    this.note.anchor.set(1, 0);
    this.confirm = this.addText(null, 'Confirm', 8, (h - 1) * WS);
    this.min = 0;
    this.max = 999;
    this.digits = 3;
    this.selected = 0;
    this.letters1 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    this.letters2 = '_abcdefghijklmnopqrstuvwxyz';
    this.arrowu.y = HWS + 4;
    this.arrowd.y = 3 * WS - 4;
    this.arrowd.oy = this.arrowd.y;
    this.arrowu.oy = this.arrowu.y;
    this.show('Max 999', 0, 999);
  }
  Number_Dialog.prototype.update = function(){
    var s, hover;
    if (!this.alive) {
      return;
    }
    if ((s = this.hover_number()) !== false && this.selected !== s) {
      this.change_selection(s);
      menusound.play('blip');
    }
    hover = this.hover_arrow();
    this.arrowd.y = this.arrowd.oy;
    this.arrowu.y = this.arrowu.oy;
    if (hover === 'down') {
      if (!(this.arrowd.hover || !this.arrowd.alive)) {
        menusound.play('blip');
      }
      this.arrowd.hover = true;
      this.arrowd.y += 2;
    } else {
      this.arrowd.hover = false;
    }
    if (hover === 'up') {
      if (!(this.arrowu.hover || !this.arrowu.alive)) {
        menusound.play('blip');
      }
      this.arrowu.hover = true;
      this.arrowu.y -= 2;
    } else {
      this.arrowu.hover = false;
    }
    if (this.mode === 'string' || (this.num <= this.max && this.num >= this.min)) {
      if (this.confirm.hover()) {
        if (this.confirm.bitmap.color !== Text.YELLOW) {
          this.confirm.change(null, 'font_yellow');
          menusound.play('blip');
        }
      } else {
        if (this.confirm.bitmap.color !== Text.WHITE) {
          this.confirm.change(null, 'font');
        }
      }
    } else {
      if (this.confirm.bitmap.color !== Text.GRAY) {
        this.confirm.change(null, 'font_gray');
      }
    }
  };
  Number_Dialog.prototype.click = function(){
    var hover;
    if (!this.alive) {
      return;
    }
    if (hover = this.hover_arrow()) {
      if (hover === 'up') {
        this.shift(1);
      }
      if (hover === 'down') {
        this.shift(-1);
      }
    }
    if (this.confirm.hover()) {
      this.select();
    }
  };
  Number_Dialog.prototype.select = function(){
    if (!(this.mode === 'string' || (this.num <= this.max && this.num >= this.min))) {
      return true;
    }
    this.kill();
    return true;
  };
  Number_Dialog.prototype.hover_number = function(){
    if (mouse.x >= this.worldTransform.tx + this.number.x - FW && mouse.x < this.worldTransform.tx + this.number.x + this.number.width && mouse.y >= this.worldTransform.ty + this.number.y - 12 && mouse.y < this.worldTransform.ty + this.number.y + this.number.height + 12) {
      return (mouse.x - (this.worldTransform.tx + this.number.x - FW)) / FW2 | 0;
    }
    return false;
  };
  Number_Dialog.prototype.hover_arrow = function(){
    if (mouse.x >= this.worldTransform.tx + this.number.x - FW && mouse.x < this.worldTransform.tx + this.number.x + this.number.width) {
      if (mouse.y >= this.worldTransform.ty + this.number.y - 12 && mouse.y < this.worldTransform.ty + this.number.y) {
        return 'up';
      }
      if (mouse.y >= this.worldTransform.ty + this.number.y + this.number.height && mouse.y < this.worldTransform.ty + this.number.y + this.number.height + 12) {
        return 'down';
      }
    }
    return false;
  };
  Number_Dialog.prototype.show = function(note, min, max){
    this.min = min != null ? min : 0;
    this.max = max != null ? max : 999;
    this.revive();
    this.note.change(note);
    this.mode = typeof this.min;
    if (this.mode === 'string') {
      this.digits = max || 13;
      this.num = repeatString$(this.letters2[0], this.digits).split('');
      this.num[0] = this.letters1[0];
      this.number.change(this.num.join(''));
    } else {
      this.num = 0;
      this.digits = this.max.toString().length;
      this.number.change(repeatString$('0', this.digits));
    }
    this.number.x = this.w * HWS - this.number.width / 2;
    this.change_selection(0);
  };
  Number_Dialog.prototype.scroll = function(e){
    if (game.input.mouse.wheelDelta > 0) {
      this.shift(1);
    } else {
      this.shift(-1);
    }
  };
  Number_Dialog.prototype.ーup = function(){
    this.shift(1);
  };
  Number_Dialog.prototype.ーdown = function(){
    this.shift(-1);
  };
  Number_Dialog.prototype.ーleft = function(){
    if (!this.alive) {
      return;
    }
    this.shift_selection(-1);
    menusound.play('blip');
  };
  Number_Dialog.prototype.ーright = function(){
    if (!this.alive) {
      return;
    }
    this.shift_selection(1);
    menusound.play('blip');
  };
  Number_Dialog.prototype.shift = function(amount){
    var letters, n, alreadymax, pn, text;
    if (!this.alive) {
      return;
    }
    if (this.mode === 'string') {
      letters = this.selected === 0
        ? this.letters1
        : this.letters2;
      n = letters.indexOf(this.num[this.selected]) + amount;
      while (n < 0) {
        n += letters.length;
      }
      while (n > letters.length - 1) {
        n -= letters.length;
      }
      this.num[this.selected] = letters[n];
      this.number.change(this.num.join(''));
    } else {
      alreadymax = this.num === this.max;
      pn = pad(repeatString$('0', this.digits), this.num, true);
      n = +pn[this.selected] + amount;
      while (n < 0) {
        n += 10;
      }
      while (n > 9) {
        n -= 10;
      }
      text = pn.substr(0, this.selected) + n + pn.substr(this.selected + 1);
      if (alreadymax && +text > this.max) {
        this.num = this.min;
      } else {
        this.num = Math.min(Math.max(+text, this.min), this.max);
      }
      text = pad(repeatString$('0', this.digits), this.num, true);
      this.number.change(text);
    }
    menusound.play('blip');
  };
  Number_Dialog.prototype.shift_selection = function(amount){
    this.change_selection(this.selected + amount);
  };
  Number_Dialog.prototype.change_selection = function(selected){
    this.selected = selected;
    while (this.selected < 0) {
      this.selected += this.digits;
    }
    while (this.selected >= this.digits) {
      this.selected -= this.digits;
    }
    this.arrowd.x = this.arrowu.x = this.number.x + 2 + this.selected * FW2;
  };
  return Number_Dialog;
}(Menu_Base));
Menu = (function(superclass){
  var prototype = extend$((import$(Menu, superclass).displayName = 'Menu', Menu), superclass).prototype, constructor = Menu;
  function Menu(x, y, w, h, nowindow, iconmode, BH){
    this.nowindow = nowindow;
    this.iconmode = iconmode != null ? iconmode : false;
    this.BH = BH != null ? BH : WS;
    Menu.superclass.apply(this, arguments);
    this.arrow = this.addChild(new Phaser.Sprite(game, -2, 0, 'arrow', 0));
    this.arrow.anchor.set(0, 0.54);
    this.history = [];
    this.dontkill = false;
    this.donteverkill = false;
    this.options = [];
    this.actions = [];
    this.buttonlist = [];
    this.icons = [];
    this.sliders = [];
    this.slider_width = this.width - 16;
    this.selected = 0;
    this.offset = 0;
    this.resize_menu();
    this.inscreen = false;
  }
  Menu.list = [];
  Menu.prototype.resize = function(){
    superclass.prototype.resize.apply(this, arguments);
    this.resize_menu();
  };
  Menu.prototype.resize_menu = function(){
    var i$, ref$, len$, button, to$, i;
    this.arrowu.x = this.arrowd.x = this.w * WS / 2;
    this.arrowd.oy = this.arrowd.y = this.h * WS - 5;
    for (i$ = 0, len$ = (ref$ = this.buttonlist).length; i$ < len$; ++i$) {
      button = ref$[i$];
      button.kill();
    }
    this.buttons = [];
    for (i$ = 0, to$ = (this.h - 2) * WS / this.BH; i$ < to$; ++i$) {
      i = i$;
      if (this.buttonlist[i] == null) {
        this.addButton();
      }
      this.buttonlist[i].revive();
      this.buttons.push(this.buttonlist[i]);
    }
    this.refresh();
  };
  Menu.prototype.addButton = function(){
    var xpos, text;
    xpos = this.iconmode ? 26 : 10;
    this.buttonlist.push(text = this.addText(null, '', xpos, this.buttonlist.length * this.BH + WS + this.BH / 2, false, 0));
    text.anchor.set(0, 0.5);
    text.kill();
    if (this.iconmode) {
      text.icon = text.addChild(
      new Phaser.Sprite(game, -18, -8, 'item_misc'));
      text.icon.kill();
    }
  };
  Menu.prototype.refresh = function(){
    var i$, ref$, len$, slider, i, option, ii, font, ref1$, that, to$, j, selected, ref2$, ref3$;
    for (i$ = 0, len$ = (ref$ = this.sliders).length; i$ < len$; ++i$) {
      slider = ref$[i$];
      slider[0].visible = false;
      slider[1].visible = false;
    }
    for (i$ = 0, len$ = (ref$ = this.options).length; i$ < len$; ++i$) {
      i = i$;
      option = ref$[i$];
      ii = i - this.offset;
      if (ii < 0) {
        continue;
      }
      if (this.buttons[ii] == null) {
        break;
      }
      font = (ref1$ = typeof this.actions[i]) === 'function' || ref1$ === 'object' ? 'font' : 'font_gray';
      if (this.actions[i] === 'back') {
        font = 'font';
      }
      this.buttons[ii].change((that = option.label) ? that : option, font);
      switch (option.type) {
      case 'slider':
        this.slider(i, ii);
        break;
      case 'switch':
        this.buttons[ii].change(null, this.actions[i].get() ? 'font_green' : 'font_red');
      }
      if (this.iconmode && this.icons[i] == null) {
        this.buttons[ii].icon.kill();
      }
      if (this.iconmode && this.icons[i] != null) {
        this.buttons[ii].icon.revive();
        if (typeof this.icons[i] === 'string') {
          this.buttons[ii].icon.loadTexture(this.icons[i]);
        } else if (typeof this.icons[i] === 'object') {
          this.buttons[ii].icon.loadTexture(this.icons[i].key);
          this.buttons[ii].icon.frame = this.icons[i].x;
          setrow(this.buttons[ii].icon, this.icons[i].y);
        }
      }
    }
    for (i$ = ii + 1, to$ = this.buttons.length; i$ < to$; ++i$) {
      j = i$;
      this.buttons[j].change('');
      if (this.iconmode) {
        this.buttons[j].icon.kill();
      }
    }
    selected = this.selected;
    this.selected = 0 > (ref$ = this.selected) ? 0 : ref$;
    this.selected = (ref$ = (ref2$ = this.options.length - 1) < (ref3$ = this.buttons.length - 1) ? ref2$ : ref3$) < (ref1$ = this.selected) ? ref$ : ref1$;
    if (selected !== this.selected) {
      this.onChangeSelection(this.selected);
    }
    this.arrowu.kill();
    this.arrowd.kill();
    if (this.offset > 0) {
      this.arrowu.revive();
    }
    if (this.offset < this.options.length - this.buttons.length) {
      this.arrowd.revive();
    }
    this.onRefresh();
  };
  Menu.prototype.onRefresh = function(){};
  Menu.prototype.get_slider = function(){
    var i$, ref$, len$, slider;
    for (i$ = 0, len$ = (ref$ = this.sliders).length; i$ < len$; ++i$) {
      slider = ref$[i$];
      if (!slider[0].visible) {
        return slider;
      }
      slider = null;
    }
    if (!slider) {
      slider = [this.addChildAt(new Phaser.TileSprite(game, 5, 0, this.slider_width, 10, 'bars', 1), this.children.indexOf(this.arrow)), this.addChildAt(new Phaser.TileSprite(game, 5, 0, this.slider_width, 10, 'bars', 2), this.children.indexOf(this.arrow))];
      this.sliders.push(slider);
    }
    return slider;
  };
  Menu.prototype.slider = function(i, ii){
    var b, slider, i$, len$, s, o;
    b = this.buttons[ii];
    slider = this.get_slider();
    b.slider = slider;
    for (i$ = 0, len$ = slider.length; i$ < len$; ++i$) {
      s = slider[i$];
      s.y = b.y - 6;
      s.visible = true;
    }
    o = this.options[i];
    slider[1].width = this.slider_width * (this.actions[i].get() - o.min) / (o.max - o.min);
  };
  Menu.prototype.slide_value = function(v){
    var i, o, rect, ref$, vv;
    i = this.selected + this.offset;
    o = this.options[i];
    this.dontkill = true;
    if (o.type !== 'slider') {
      return;
    }
    if (v == null) {
      rect = this.get_button_rect();
      v = (mouse.x - rect.x) / rect.width;
    }
    v = (ref$ = 0 > v ? 0 : v) < 1 ? ref$ : 1;
    vv = (o.max - o.min) * v + o.min;
    this.actions[i].set(vv);
    this.buttons[this.selected].slider[1].width = this.slider_width * v;
    if (typeof o.onswitch == 'function') {
      o.onswitch();
    }
    save_options();
  };
  Menu.prototype.switch_value = function(){
    var i, o;
    i = this.selected + this.offset;
    o = this.options[i];
    this.dontkill = true;
    if (o.type !== 'switch') {
      return;
    }
    this.actions[i].set(!this.actions[i].get());
    this.buttons[this.selected].change(null, this.actions[i].get() ? 'font_green' : 'font_red');
    save_options();
    if (typeof o.onswitch == 'function') {
      o.onswitch();
    }
  };
  Menu.prototype.revive = function(){
    superclass.prototype.revive.apply(this, arguments);
    this.refresh();
  };
  Menu.prototype.select = function(){
    var i, ref$, result;
    i = this.selected + this.offset;
    if (this.inscreen && (dialog != null && dialog.alive) && !this.parent.lockdialog || !this.alive) {
      return;
    }
    if (((ref$ = typeof this.actions[i]) !== 'function' && ref$ !== 'object') && this.actions[i] !== 'back') {
      return;
    }
    if (this.parent instanceof DialogWindow && !this.parent.locked) {
      this.parent.message.empty_buffer();
    }
    if (this.options[i].type === 'slider') {
      result = true;
      this.slide_value();
    } else if (this.options[i].type === 'switch') {
      result = true;
      this.switch_value();
    } else if (this.actions[i] === 'back') {
      return this.cancel();
    } else {
      result = process_callbacks.call(this, this.actions[i]);
    }
    if (this.dontkill || this.donteverkill) {
      this.dontkill = false;
    } else {
      this.history = [];
      this.kill();
    }
    menusound.play('blip');
    if (this.parent === dialog) {
      return result;
    }
    return this.parent === dialog;
  };
  Menu.prototype.click = function(e){
    var hover;
    e == null && (e = {});
    if (!this.alive || this.inscreen && (dialog != null && dialog.alive) && !this.parent.lockdialog) {
      return;
    }
    if (nullbutton(e.button)) {
      if (this.adjust_arrows()) {
        hover = this.hover_scroll(this.arrowu.height);
      } else {
        hover = this.hover_scroll();
      }
      if (hover) {
        if (hover === this.arrowd && this.arrowd.alive) {
          menusound.play('blip');
          return this.scrolldown();
        }
        if (hover === this.arrowu && this.arrowu.alive) {
          menusound.play('blip');
          return this.scrollup();
        }
      }
      if (this.hover_button() != null) {
        return this.select();
      }
    } else if (e.button === 2) {
      return this.cancel();
    }
  };
  Menu.prototype.cancel = function(){
    var revert;
    if (!this.alive || this.inscreen && (dialog != null && dialog.alive) && !this.parent.lockdialog) {
      return true;
    }
    if (this.history.length === 0) {
      return;
    }
    revert = this.history.pop();
    this.options = revert.options;
    this.actions = revert.actions;
    this.offset = 0;
    this.queue = [];
    this.refresh();
    if (dialog && this === dialog.menu) {
      dialog.resize_menu();
    }
    menusound.play('blip');
    return false;
  };
  Menu.prototype.shift_slider = function(v){
    var i, o;
    i = this.selected + this.offset;
    o = this.options[i];
    if (o.type !== 'slider') {
      return;
    }
    this.slide_value((this.actions[i].get() - o.min) / (o.max - o.min) + v);
  };
  Menu.prototype.ーleft = function(){
    if (!this.alive) {
      return;
    }
    if (this.horizontalmove) {
      return this.ーup();
    }
    if (this.options[this.selected + this.offset].type === 'slider') {
      this.shift_slider(-0.1);
      menusound.play('blip');
    }
  };
  Menu.prototype.ーright = function(){
    if (!this.alive) {
      return;
    }
    if (this.horizontalmove) {
      return this.ーdown();
    }
    if (this.options[this.selected + this.offset].type === 'slider') {
      this.shift_slider(0.1);
      menusound.play('blip');
    }
  };
  Menu.prototype.ーup = function(){
    if (!this.alive || this.inscreen && (dialog != null && dialog.alive) && !this.parent.lockdialog) {
      return;
    }
    this.selected--;
    if (this.selected < 0) {
      this.scrollup(true);
    }
    this.onChangeSelection(this.selected);
    menusound.play('blip');
  };
  Menu.prototype.scrollup = function(wrap){
    var s;
    wrap == null && (wrap = false);
    if (this.offset > 0) {
      this.selected++;
      this.offset--;
      s = true;
    } else if (this.options.length > this.buttons.length && wrap) {
      this.offset = this.options.length - this.buttons.length;
      this.selected = this.buttons.length - 1;
    } else if (wrap) {
      this.selected = this.options.length - 1;
    }
    this.refresh();
    return s;
  };
  Menu.prototype.ーdown = function(){
    var ref$, ref1$;
    if (!this.alive || this.inscreen && (dialog != null && dialog.alive) && !this.parent.lockdialog) {
      return;
    }
    this.selected++;
    if (this.selected >= ((ref$ = this.buttons.length) < (ref1$ = this.options.length) ? ref$ : ref1$)) {
      this.scrolldown(true);
    }
    this.onChangeSelection(this.selected);
    menusound.play('blip');
  };
  Menu.prototype.scrolldown = function(wrap){
    var s;
    wrap == null && (wrap = false);
    if (this.offset < this.options.length - this.buttons.length) {
      this.selected--;
      this.offset++;
      s = true;
    } else if (wrap) {
      this.offset = 0;
      this.selected = 0;
    }
    this.refresh();
    return s;
  };
  Menu.prototype.scroll = function(e){
    var ref$, s, ref1$;
    if (this.inscreen && (dialog != null && dialog.alive) && !this.parent.lockdialog) {
      return;
    }
    if (game.input.mouse.wheelDelta > 0) {
      if (this.hover_selected() && ((ref$ = this.options[this.selected + this.offset]) != null ? ref$.type : void 8) === 'slider') {
        return this.ーright();
      } else {
        s = this.scrollup();
      }
    } else {
      if (this.hover_selected() && ((ref1$ = this.options[this.selected + this.offset]) != null ? ref1$.type : void 8) === 'slider') {
        return this.ーleft();
      } else {
        s = this.scrolldown();
      }
    }
    if (this.options.length > this.buttons.length && s) {
      menusound.play('blip');
    }
  };
  Menu.prototype.update = function(){
    var hover;
    if (!this.alive || this.inscreen && (dialog != null && dialog.alive) && !this.parent.lockdialog) {
      return;
    }
    hover = this.hover_button();
    if (this.options[hover] != null && this.selected !== hover) {
      menusound.play('blip');
      this.selected = hover;
      this.onChangeSelection(this.selected);
    }
    if (this.buttons[this.selected]) {
      this.arrow.y = this.buttons[this.selected].y;
      this.arrow.x = this.buttons[this.selected].x - 12 - (this.iconmode ? 16 : 0);
    }
    this.arrowd.y = this.arrowd.oy;
    this.arrowu.y = this.arrowu.oy;
    if (this.adjust_arrows()) {
      this.arrowu.y += this.arrowu.height;
      this.arrowd.y -= this.arrowd.height;
      hover = this.hover_scroll(this.arrowu.height);
    } else {
      hover = this.hover_scroll();
    }
    if (hover === this.arrowd) {
      if (!(this.arrowd.hover || !this.arrowd.alive)) {
        menusound.play('blip');
      }
      this.arrowd.hover = true;
      this.arrowd.y += 2;
    } else {
      this.arrowd.hover = false;
    }
    if (hover === this.arrowu) {
      if (!(this.arrowu.hover || !this.arrowu.alive)) {
        menusound.play('blip');
      }
      this.arrowu.hover = true;
      this.arrowu.y -= 2;
    } else {
      this.arrowu.hover = false;
    }
  };
  Menu.prototype.adjust_arrows = function(){
    return this.arrowu.parent.worldTransform.ty + this.arrowu.y < 0 || this.arrowd.parent.worldTransform.ty + this.arrowd.y > game.height;
  };
  Menu.prototype.get_button_rect = function(i){
    i == null && (i = this.selected);
    return {
      x: this.worldTransform.tx + this.buttons[i].x - 5,
      y: this.worldTransform.ty + this.buttons[i].y - (this.buttons[i].BH || this.BH) / 2,
      width: this.buttons[i].BW || this.w * WS - 10,
      height: this.buttons[i].BH || this.BH
    };
  };
  Menu.prototype.hover_scroll = function(offset){
    var rect;
    offset == null && (offset = 0);
    rect = {
      x: this.worldTransform.tx + HWS,
      y: this.worldTransform.ty + offset,
      width: (this.w - 1) * WS,
      height: WS
    };
    if (point_in_body(mouse, rect)) {
      return this.arrowu;
    }
    rect.y = this.worldTransform.ty + this.buttons.length * this.BH + WS - offset;
    if (point_in_body(mouse, rect)) {
      return this.arrowd;
    }
    return null;
  };
  Menu.prototype.hover_button = function(){
    var i$, ref$, len$, i, button, rect;
    for (i$ = 0, len$ = (ref$ = this.buttons).length; i$ < len$; ++i$) {
      i = i$;
      button = ref$[i$];
      rect = this.get_button_rect(i);
      if (point_in_body(mouse, rect)) {
        return i;
      }
    }
    return null;
  };
  Menu.prototype.hover_selected = function(){
    return point_in_body(mouse, this.get_button_rect(this.selected));
  };
  Menu.prototype.onChangeSelection = function(i){};
  Menu.prototype.nest = function(){
    var ref$;
    if (!(typeof dialog == 'function' && dialog(this !== dialog.menu)) || (this.queue.length === 0 && ((ref$ = dialog.queue[0]) != null ? ref$.options : void 8) != null)) {
      this.change.apply(this, arguments);
    } else {
      this.history = [];
      menu.apply(this, arguments);
    }
    if (dialog && this === dialog.menu) {
      dialog.resize_menu();
    }
  };
  Menu.prototype.menu = function(){
    this.history = [];
    menu.apply(this, arguments);
  };
  Menu.prototype.change = function(){
    var hist;
    hist = {
      options: this.options,
      actions: this.actions
    };
    if (this.set.apply(this, arguments)) {
      this.history.push(hist);
    }
    this.dontkill = true;
  };
  Menu.prototype.set = function(){
    var i$, len$, i, option, action;
    if (!this.check_arguments.apply(this, arguments)) {
      return false;
    }
    this.options = [];
    this.actions = [];
    this.icons = [];
    for (i$ = 0, len$ = (arguments).length; i$ < len$; i$ += 2) {
      i = i$;
      option = (arguments)[i$];
      action = arguments[i + 1];
      if (option instanceof Array) {
        this.options.push(option[0]);
        this.icons[this.options.length - 1] = option[1];
      } else {
        this.options.push(option);
      }
      this.actions.push(action);
    }
    this.refresh();
    return true;
  };
  Menu.prototype.check_arguments = function(){
    if (arguments.length % 2 !== 0) {
      console.warn('Menu arguments must be even!');
      console.log(arguments);
      return false;
    }
    return true;
  };
  Menu.prototype.say = say;
  Menu.prototype.number = number;
  Menu.prototype.show = function(pose){
    pose == null && (pose = 'default');
    this.queue.push({
      pose: pose
    });
  };
  return Menu;
}(Menu_Base));
Portrait = (function(superclass){
  var prototype = extend$((import$(Portrait, superclass).displayName = 'Portrait', Portrait), superclass).prototype, constructor = Portrait;
  function Portrait(x, y, key){
    Portrait.superclass.call(this, game, x, y, key);
    this.anchor.set(1.0, 0.5);
    this.mad = false;
    this.addChild(this.face = new Phaser.Sprite(game, 0, 0, ''));
    this.face.load_port = this.load_port;
  }
  Portrait.prototype.change = function(name, pose){
    var ref$, speaker, p, f;
    name == null && (name = this.name);
    if (name !== this.name && pose == null || ((ref$ = speakers[name]) != null ? ref$[pose] : void 8) == null && pose != null) {
      pose = 'default';
    }
    if (pose == null) {
      pose = this.pose;
    }
    if (name in speakers) {
      speaker = speakers[name];
      if (!this.parent.hideport) {
        this.revive();
      }
      this.name = name;
      this.pose = pose;
      pose = access(speaker[pose]);
      if (speaker['default'] == null) {
        this.kill();
      } else if (speaker.composite) {
        this.face.revive();
        p = speaker.composite.player;
        if (pose.base) {
          this.loadTexture(access(pose.base));
          this.frame = access(pose.baseframe) || 0;
        } else if (speaker.composite.base) {
          this.load_port(access(speaker.composite.base));
        } else if (p) {
          this.loadTexture(get_costume(p, null, players[p].costume, 'psheet'));
          this.frame = get_costume(p, null, players[p].costume, 'pframe');
        }
        if (costumes[p] && (f = get_costume(p, null, players[p].costume, 'fsheet'))) {
          this.face.load_port(pose, access(f));
        } else {
          this.face.load_port(pose, access(speaker.composite.face));
        }
        if (costumes[p] && (f = get_costume(p, null, players[p].costume, 'frecolor'))) {
          recolor(this.face, f[0], f[1]);
        }
        this.face.x = speaker.composite.x;
        this.face.y = speaker.composite.y;
        if (pose.offx) {
          this.face.x += pose.offx;
        }
        if (pose.offy) {
          this.face.y += pose.offy;
        }
      } else {
        this.face.kill();
        if (speaker.base && typeof pose === 'number') {
          this.loadTexture(access(speaker.base));
          this.frame = pose;
        } else {
          this.load_port(pose);
        }
      }
    } else {
      this.name = '';
      this.pose = '';
      this.kill();
    }
  };
  Portrait.prototype.load_port = function(kf, base){
    if (typeof kf === 'function') {
      kf = access(kf);
    }
    if (typeof kf === 'number') {
      if (base) {
        this.loadTexture(base);
      }
      this.frame = kf;
    } else if (typeof kf === 'string') {
      this.loadTexture(kf);
    } else if (kf instanceof Array) {
      this.loadTexture(kf[0]);
      this.frame = kf[1];
    } else if (typeof kf === 'object') {
      temp.kfsheet = access(kf.sheet);
      if (temp.kfsheet || base) {
        this.loadTexture(temp.kfsheet) || base;
      }
      this.frame = access(kf.frame) || 0;
    }
  };
  Portrait.prototype.update = function(){
    var ref$;
    if (!this.mad || !((ref$ = speakers[this.name]) != null && ref$.mad)) {
      return;
    }
    if (Math.random() < this.mad / 50) {
      if (this.key !== speakers[this.name].mad) {
        this.loadTexture(speakers[this.name].mad);
      }
    } else {
      if (this.key !== speakers[this.name][this.pose]) {
        this.loadTexture(speakers[this.name][this.pose]);
      }
    }
  };
  return Portrait;
}(Phaser.Sprite));
Screen = (function(superclass){
  var prototype = extend$((import$(Screen, superclass).displayName = 'Screen', Screen), superclass).prototype, constructor = Screen;
  function Screen(){
    Screen.superclass.call(this, game, null, 'screen');
    this.windows = [];
    this.history = [];
  }
  Screen.list = [];
  Screen.prototype.for_windows = function(fun){
    var args, res$, i$, to$, ref$, len$, win;
    res$ = [];
    for (i$ = 1, to$ = arguments.length; i$ < to$; ++i$) {
      res$.push(arguments[i$]);
    }
    args = res$;
    for (i$ = 0, len$ = (ref$ = this.windows).length; i$ < len$; ++i$) {
      win = ref$[i$];
      if (win instanceof Window) {
        win[fun].apply(win, args);
      }
    }
  };
  Screen.prototype.show = function(){
    this.revive();
    this.for_windows('revive');
    menusound.play('blip');
    if (this.lockdialog && dialog != null) {
      dialog.locked = true;
    }
    constructor.list.push(this);
  };
  Screen.prototype.nest = function(){
    var i$, len$, arg;
    this.history.push(this.windows);
    this.for_windows('kill');
    this.windows = [];
    for (i$ = 0, len$ = (arguments).length; i$ < len$; ++i$) {
      arg = (arguments)[i$];
      this.windows.push(arg);
      if (arg instanceof Window) {
        arg.revive();
      }
    }
  };
  Screen.prototype.exit = function(){
    var i$, ref$, len$, entry;
    for (i$ = 0, len$ = (ref$ = this.history).length; i$ < len$; ++i$) {
      entry = ref$[i$];
      this.back(true);
    }
    this.back(true);
  };
  Screen.prototype.back = function(force){
    if (this.nocancel && this.history.length === 0 && !force) {
      return;
    }
    this.for_windows('kill');
    if (this.history.length === 0) {
      return this.kill();
    }
    this.windows = this.history.pop();
    this.for_windows('revive');
    return false;
  };
  Screen.prototype.addMenu = function(){
    var menu;
    this.windows.push(menu = this.createMenu.apply(this, arguments));
    return menu;
  };
  Screen.prototype.addWindow = function(){
    var r;
    this.windows.push(r = this.createWindow.apply(this, arguments));
    return r;
  };
  Screen.prototype.createMenu = function(){
    var menu, override_cancel;
    menu = this.addChild(
    construct(Menu, arguments));
    menu.inscreen = true;
    override_cancel = menu.cancel;
    menu.cancel = function(){
      var historylength, result;
      historylength = this.history.length;
      result = override_cancel.apply(this, arguments);
      if (result) {
        return true;
      }
      menusound.play('blip');
      if (historylength === 0) {
        this.parent.back();
      }
      return false;
    };
    menu.kill();
    menu.donteverkill = true;
    return menu;
  };
  Screen.prototype.createWindow = function(){
    var r;
    r = this.addChild(
    construct(Window, arguments));
    r.kill();
    return r;
  };
  Screen.prototype.kill = function(){
    var i;
    this.for_windows('kill');
    Phaser.Sprite.prototype.kill.apply(this, arguments);
    if (this.lockdialog && dialog != null) {
      dialog.locked = false;
      dialog.click('ignorelock');
    }
    i = constructor.list.indexOf(this);
    if (i > -1) {
      return constructor.list.splice(i, 1);
    }
  };
  Screen.prototype.revive = function(){
    this.for_windows('revive');
    return Phaser.Sprite.prototype.revive.apply(this, arguments);
  };
  Screen.prototype.destroy = function(){
    var i;
    superclass.prototype.destroy.apply(this, arguments);
    i = constructor.list.indexOf(this);
    if (i > -1) {
      return constructor.list.splice(i, 1);
    }
  };
  return Screen;
}(Phaser.Group));
state.load.preload = function(){
  gui.bringToTop(gui.frame);
  cg.showfast(access(zones[getmapdata('zone')].cg));
  solidscreen.alpha = 1;
  gui.frame.addChild(preloader.back);
  gui.frame.addChild(preloader);
  game.load.setPreloadSprite(preloader);
  gui.frame.addChild(preloader.text);
  load_load();
  temp.opacity = pixel.canvas.style.opacity;
  pixel.canvas.style.opacity = 1;
};
state.load.create = function(){
  gui.frame.remove(preloader);
  gui.frame.remove(preloader.back);
  gui.frame.remove(preloader.text);
  if (switches.portal) {
    switches.portal.loaded = true;
  }
  game.state.start('overworld', false);
  cg.kill();
  solidscreen.alpha = 0;
  load_done();
  pixel.canvas.style.opacity = temp.opacity;
};
musicmap = {
  battle: ['battle', ['battle.ogg', 'battle.m4a']],
  '2dpassion': ['2dpassion', ['2DPassion.ogg', '2DPassion.m4a']],
  towertheme: ['towertheme', ['towertheme.ogg', 'towertheme.m4a']],
  deserttheme: ['deserttheme', ['deserttheme.ogg', 'deserttheme.m4a']],
  hidingyourdeath: ['hidingyourdeath', ['Hiding Your Death.ogg', 'Hiding Your Death.m4a']],
  distortion: ['distortion', ['distortion.ogg', 'distortion.m4a']]
};
function load_load(){
  var musiclist, loadlist, i$, len$, item;
  musiclist = zones[getmapdata('zone')].musiclist.concat(zones['default'].musiclist);
  loadlist = [];
  for (i$ = 0, len$ = musiclist.length; i$ < len$; ++i$) {
    item = musiclist[i$];
    if (!game.cache.checkSoundKey(musicmap[item][0])) {
      loadlist.push(musicmap[item]);
    }
  }
  batchload(loadlist, 'music/', 'audio');
}
function load_done(){
  var musiclist, i$, len$, item;
  musiclist = zones[getmapdata('zone')].musiclist.concat(zones['default'].musiclist);
  for (i$ = 0, len$ = musiclist.length; i$ < len$; ++i$) {
    item = musiclist[i$];
    if (music[item] == null) {
      music.add(item, 1, true);
    }
  }
}
function mod_music(key, path){
  var i$, len$, p;
  if (path instanceof Array) {
    for (i$ = 0, len$ = path.length; i$ < len$; ++i$) {
      p = i$;
      path[p] = "../" + path[p];
    }
  } else {
    path = "../" + path;
  }
  musicmap[key] = [key, path];
}
updatelist = [];
updatelist.remove = function(o){
  var i;
  i = this.indexOf(o);
  if (i > -1) {
    this.splice(i, 1);
  }
};
Actor = (function(superclass){
  var prototype = extend$((import$(Actor, superclass).displayName = 'Actor', Actor), superclass).prototype, constructor = Actor;
  function Actor(x, y, key, nobody){
    this.nobody = nobody != null ? nobody : false;
    this.water_depth = 0;
    this.row = 0;
    Actor.superclass.call(this, game, x, y, key);
    this.anchor.setTo(0.5, 1.0);
    game.physics.arcade.enable(this, false);
    this.body.setSize(10, 10, 0, 2);
    this.override_physics_update();
    this.y -= this.bodyoffset.y;
    this.goal = {
      x: this.x,
      y: this.y
    };
    this.drift = 0;
    this.moving = false;
    this.speed = 60;
    this.facing = 'down';
    this.facing_changed = Date.now();
    this.follow_object = null;
    this.name = key;
    constructor[key] = this;
    this.autoplay = false;
    this.path = [];
    this.bridgemode = 'under';
    this.terrain = 'grass';
    constructor.list.push(this);
    updatelist.push(this);
    actors.addChild(this);
    this.lastrelocate = 0;
  }
  Actor.prototype.add_facing_animation = function(speed){
    speed == null && (speed = 7);
    this.animations.add('downleft', [4, 3, 5, 3], speed, true);
    this.animations.add('left', [7, 6, 8, 6], speed, true);
    this.animations.add('upleft', [10, 9, 11, 9], speed, true);
    this.animations.add('up', [13, 12, 14, 12], speed, true);
    this.animations.add('upright', [16, 15, 17, 15], speed, true);
    this.animations.add('right', [19, 18, 20, 18], speed, true);
    this.animations.add('downright', [22, 21, 23, 21], speed, true);
    this.animations.add('down', [1, 0, 2, 0], speed, true);
  };
  Actor.prototype.add_simple_animation = function(speed){
    speed == null && (speed = 7);
    this.animations.add('simple', null, speed, true);
  };
  Actor.prototype.relocate = function(x, y){
    var node, ref$;
    if (distance(this, {
      x: x,
      y: y > HWIDTH
    })) {
      this.lastrelocate = Date.now();
    }
    if (typeof x === 'string') {
      if (!(node = nodes[x])) {
        warn("Node '" + x + "' doesn't exist!");
        return;
      }
      x = node.x + HTS;
      y = node.y + TS;
    }
    if (y != null) {
      this.x = x;
      this.y = y;
    } else {
      this.x = x.x;
      this.y = x.y;
    }
    this.y -= this.bodyoffset.y;
    if (typeof this.cancel_movement == 'function') {
      this.cancel_movement();
    }
    if (!this.alive) {
      this.revive();
    }
    if (x != null && ((ref$ = x.properties) != null && ref$.facing)) {
      this.face(x.properties.facing);
    }
    if (this.ripple) {
      update_water_depth(this);
    }
  };
  Actor.prototype.shift = function(x, y){
    if (x != null) {
      this.x += x;
    }
    if (y != null) {
      this.y += y;
    }
    this.cancel_movement();
  };
  Actor.prototype.setautoplay = function(animation, speed){
    this.autoplay = true;
    if (typeof animation === 'number') {
      speed = animation;
      animation = null;
    }
    animation == null && (animation = this.animations.currentAnim.name);
    this.animations.play(animation);
    if (speed != null) {
      this.animations.currentAnim.speed = speed;
    }
  };
  Actor.list = [];
  Actor.prototype.destroy = function(){
    var i;
    superclass.prototype.destroy.apply(this, arguments);
    i = constructor.list.indexOf(this);
    if (i !== -1) {
      constructor.list.splice(i, 1);
    }
    updatelist.remove(this);
  };
  Actor.prototype.poof = function(){
    this.kill();
    Dust.summon(this);
  };
  Actor.prototype.loadTexture = function(){
    superclass.prototype.loadTexture.apply(this, arguments);
    if (this.body) {
      this.body.setSize(this.body.width, this.body.height);
    }
    this.row = 0;
    update_water_depth(this, true);
  };
  Actor.prototype.setrow = function(r){
    var im;
    if (!(im = getCachedImage(this.key))) {
      return;
    }
    if (im.data.height >= im.frameHeight * (r + 1)) {
      this.row = r;
    } else {
      this.row = 0;
    }
    update_water_depth(this, true);
  };
  return Actor;
}(Phaser.Sprite));
function create_actors(){
  var override;
  triggers = game.add.group(undefined, 'triggers');
  carpet = game.add.group(undefined, 'carpet');
  actors = game.add.group(undefined, 'actors');
  fringe = game.add.group(undefined, 'fringe');
  actors.classType = Actor;
  actors.paused = false;
  actors.setpaused = function(){
    var i$, ref$, len$, s;
    if (dialog && (dialog.alive || dialog.textentry.alive)) {
      return true;
    }
    for (i$ = 0, len$ = (ref$ = Screen.list).length; i$ < len$; ++i$) {
      s = ref$[i$];
      if (s.pauseactors) {
        return true;
      }
    }
    return false;
  };
  override = actors.update;
  actors.update = function(){
    var i$, ref$, len$, t, child;
    if (game.state.current !== 'overworld') {
      return;
    }
    this.paused = this.setpaused();
    switches.cinema = switches.cinema2;
    for (i$ = 0, len$ = (ref$ = Transition.list).length; i$ < len$; ++i$) {
      t = ref$[i$];
      if (t.cinematic) {
        switches.cinema = true;
        break;
      }
    }
    if (!this.paused) {
      for (i$ = (ref$ = updatelist).length - 1; i$ >= 0; --i$) {
        child = ref$[i$];
        child.update();
      }
      return;
    }
    mouse.down = false;
    for (i$ = (ref$ = updatelist).length - 1; i$ >= 0; --i$) {
      child = ref$[i$];
      if (child.nobody) {
        child.update();
      } else {
        if (typeof child.updatePaused == 'function') {
          child.updatePaused();
        }
      }
    }
  };
  actors.preUpdate = function(){
    var i$, ref$, child;
    for (i$ = (ref$ = updatelist).length - 1; i$ >= 0; --i$) {
      child = ref$[i$];
      child.preUpdate();
    }
  };
  actors.postUpdate = function(){
    var i$, ref$, child;
    for (i$ = (ref$ = updatelist).length - 1; i$ >= 0; --i$) {
      child = ref$[i$];
      child.postUpdate();
    }
  };
  triggers.update = carpet.update = fringe.update = function(){};
  triggers.preUpdate = carpet.preUpdate = fringe.preUpdate = function(){};
  triggers.postUpdate = carpet.postUpdate = fringe.postUpdate = function(){};
  create_players();
}
function sort_actor_groups(){
  game.world.bringToTop(
  carpet);
  game.world.bringToTop(
  actors);
  game.world.bringToTop(
  fringe);
  game.world.bringToTop(
  dustclouds);
  gui.sendToBack(
  solidscreen);
}
Actor.prototype.updatePaused = function(){
  if (!this.autoplay) {
    this.stop();
  }
};
Actor.prototype.update = function(){
  if (this.body.deltaAbsX() === 0 && this.body.deltaAbsY() === 0) {
    this.moving = false;
  }
  this.follow_path();
  this.apply_movement();
};
function tile_collision_recoil(o, layer, water, land){
  if (!tile_collision(o, layer, water, land)) {
    return false;
  }
  if (!tile_point_collision(o, {
    x: o.x - o.body.deltaX(),
    y: o.y
  }, layer, water, land)) {
    o.x -= o.body.deltaX();
  } else if (!tile_point_collision(o, {
    x: o.x,
    y: o.y - o.body.deltaY()
  }, layer, water, land)) {
    o.y -= o.body.deltaY();
  } else if (!tile_point_collision(o, {
    x: o.x - o.body.deltaX(),
    y: o.y - o.body.deltaY()
  }, layer, water, land)) {
    o.x -= o.body.deltaX();
    o.y -= o.body.deltaY();
  }
  o.cancel_movement();
  return true;
}
function actor_collision_recoil(p, a){
  if (!body_collision(p.body, a.body, {
    x: -p.body.deltaX(),
    y: 0
  })) {
    return p.x -= p.body.deltaX();
  } else if (!body_collision(p.body, a.body, {
    x: 0,
    y: -p.body.deltaY()
  })) {
    return p.y -= p.body.deltaY();
  } else if (!body_collision(p.body, a.body, {
    x: -p.body.deltaX(),
    y: -p.body.deltaY()
  })) {
    p.x -= p.body.deltaX();
    return p.y -= p.body.deltaY();
  }
}
/*
function over_water2 (o)
    tiles = Actor::getTiles.call o
    water_depth=2
    for tile in tiles
        if tile and tile.properties.terrain
            if tile.properties.terrain is 'wall'
                ;
            else if tile.properties.dcol # and check_dcol tile, body_to_rect o.body
                water_depth = (over_water_single o) <? water_depth
            else if tile.properties.terrain is 'water'
                water_depth = 1 <? water_depth
            else if tile.properties.terrain is 'fringe'
                water_depth = (over_water_single x:tile.worldX, y:tile.worldY - TS) <? water_depth
            else
                water_depth = 0 <? water_depth
    return water_depth
function over_water_single2 (o)
    #tile = map.getTile(o.x,o.y, map.tile_layer,true)
    tile = map.getTile(o.x/TS.|.0, o.y/TS.|.0, map.tile_layer, true)
    if not tile? or tile is false or not tile.properties.terrain? or tile.properties.terrain is 'water'
        return if tile?properties.terrain is 'water' then 1 else 2
    if tile.properties.terrain is 'fringe'
        return over_water_single x:o.x, y:o.y - TS
        #return over_water_single x:o.x, y:o.y - 1
    return 0
*/
function over_water(o){
  var tile;
  tile = map.getTile(o.x / TS | 0, o.y / TS | 0, map.tile_layer, true);
  if (tile == null || tile === false || tile.properties.terrain == null || tile.properties.terrain === 'water') {
    return (tile != null ? tile.properties.terrain : void 8) === 'water' ? 1 : 2;
  }
  if (tile.properties.terrain === 'overpass' && tile.properties.dcol === '0,1,0,1' && o.bridgemode === 'under') {
    return over_water({
      x: o.x + 1,
      y: o.y
    });
  }
  if (tile.properties.terrain === 'fringe' || tile.properties.terrain === 'overpass' && o.bridgemode === 'under') {
    return over_water({
      x: o.x,
      y: o.y - TS
    });
  }
  return 0;
}
/* #Unused?
Actor::update_body =!->
    @body.x = (@x - (@anchor.x * @body.width)) + @body.offset.x
    @body.y = (@y - (@anchor.y * @body.width)) + @body.offset.y

Actor::collides =(o, block=false)->
    return false unless @colliding o
    unless @colliding_point o, x:@previous.x, y:@y
        @x = @previous.x
    else unless @colliding_point o, x:@x, y:@previous.y
        @y = @previous.y
    else if block or not @colliding_point o, @previous
        @x = @previous.x
        @y = @previous.y
    @cancel_movement!
    return true
    
Actor::colliding =(o)->
    @colliding_point o, @
Actor::colliding_point =(o,p)->
    rect_collision x: p.x+@bbox.x, y: p.y+@bbox.y, w: @bbox.w, h: @bbox.h,
        x: o.x+o.bbox.x, y: o.y+o.bbox.y, w: o.bbox.w, h: o.bbox.h
*/
Actor.prototype.apply_movement = function(stop_dist){
  stop_dist == null && (stop_dist = 1);
  this.move_toward_point(this.goal);
  if (this.moving || Math.abs(this.goal.x - this.x) >= stop_dist || Math.abs(this.goal.y - this.y) >= stop_dist) {
    this.moving = true;
    this.face_point(this.goal);
  } else {
    if (this.follow_object != null && !this.path.length && !switches.cinema) {
      this.face_point(this.follow_object);
    }
    if (!this.autoplay) {
      this.stop();
    }
  }
};
Actor.prototype.stop = function(){
  if (this.path != null && this.path.length && !actors.paused) {
    this.path.shift();
    return;
  }
  if (!this.animations.currentAnim) {
    return;
  }
  this.frame = this.animations.currentAnim._frames[3];
  this.animations.stop();
  return;
};
Actor.prototype.cancel_movement = function(){
  this.goal = {
    x: this.x,
    y: this.y
  };
  this.moving = false;
};
Actor.prototype.face_point = function(p){
  var a, facing;
  if (distance(this, p) === 0 || game.time.elapsedSince(this.facing_changed) < 100 || this.autoplay || !this.animations.currentAnim) {
    return;
  }
  a = angleDEG(this, p);
  if (a <= 22 || a > 337) {
    facing = 'right';
  } else if (a <= 67) {
    facing = 'downright';
  } else if (a <= 112) {
    facing = 'down';
  } else if (a <= 157) {
    facing = 'downleft';
  } else if (a <= 202) {
    facing = 'left';
  } else if (a <= 245) {
    facing = 'upleft';
  } else if (a <= 293) {
    facing = 'up';
  } else if (a <= 337) {
    facing = 'upright';
  }
  if (!this.animations.getAnimation(facing) || !this.animations.getAnimation(facing)._frames.length) {
    return;
  }
  if (facing !== this.facing) {
    this.facing_changed = Date.now();
    this.facing = facing;
  }
  this.animations.play(this.facing);
};
Actor.prototype.face = function(direction){
  this.animations.play(direction);
};
Actor.prototype.override_physics_update = function(){
  var override;
  override = this.body.preUpdate;
  this.body.preUpdate = function(){
    var m, n, v, ref$;
    if (!actors.paused && game.state.current === 'overworld') {
      if (this.sprite.drift !== 0) {
        this.sprite.goal.y += this.sprite.drift * game.time.physicsElapsed;
      }
      m = {
        x: this.sprite.goal.x - this.sprite.x,
        y: this.sprite.goal.y - this.sprite.y
      };
      n = normalize(m);
      n.x *= this.sprite.speed;
      n.y *= this.sprite.speed;
      m.x /= game.time.physicsElapsed;
      m.y /= game.time.physicsElapsed;
      v = {};
      v.x = Math.abs(m.x) < Math.abs(n.x)
        ? m.x
        : n.x;
      v.y = Math.abs(m.y) < Math.abs(n.y)
        ? m.y
        : n.y;
      if (this.sprite.drift !== 0) {
        v.y += this.sprite.drift;
        this.sprite.drift = 0;
      }
      this.velocity.setTo(v.x, v.y);
    } else {
      this.velocity.setTo(0);
    }
    override.apply(this, arguments);
    if (game.state.current === 'overworld') {
      if (typeof (ref$ = this.sprite).physics_update == 'function') {
        ref$.physics_update();
      }
    }
  };
};
Actor.prototype.physics_update = function(){
  if (this.moving && !this.nobody) {
    tile_collision_recoil(this, map.namedLayers.tile_layer, this.waterwalking);
  }
};
Actor.prototype.move_toward_point = function(p, speed){
  speed == null && (speed = this.speed);
  this.body.goal = p;
};
Actor.prototype.follow_path = function(){
  while (this.path.length && (typeof this.path[0] === 'function' || this.path[0].callback)) {
    process_callbacks(this.path[0]);
    this.path.shift();
  }
  if (this.path.length) {
    this.goal.x = isFinite(this.path[0].x)
      ? this.path[0].x
      : this.x;
    this.goal.y = isFinite(this.path[0].y)
      ? this.path[0].y
      : this.y;
  }
};
Actor.prototype.move = function(mx, my){
  var ox, oy;
  ox = this.path.length
    ? this.path[this.path.length - 1].x
    : this.x;
  oy = this.path.length
    ? this.path[this.path.length - 1].y
    : this.y;
  this.path.push({
    x: ox + mx * TS,
    y: oy + my * TS
  });
};
Actor.prototype.getTiles = function(){
  var rect;
  rect = body_to_rect(this.body);
  return getTiles.call(map.namedLayers.tile_layer, rect, true);
};
formes = {
  llov: {
    'default': {
      number: 0,
      stage: 0,
      port: 'llov_battle',
      hp: 106,
      atk: 105,
      def: 80,
      speed: 110,
      luck: 110,
      skills: {
        lovelyArrow: 1,
        devilKiss: 2,
        hemorrhage: 5,
        angelRain: 10,
        minorheal: 15,
        clense: 32
      }
    },
    koakuma: {
      number: 1,
      name: "Koakuma",
      desc: "A mischievous devil that plays tricks on her foes.",
      stage: 1,
      port: 'llov_battle_1',
      unlocked: false,
      hp: 110,
      atk: 120,
      def: 100,
      speed: 130,
      luck: 138,
      skills: {
        hemorrhage: 1,
        devilKiss: 2,
        bloodburst: 10,
        sabotage: 15,
        trickpunch: 15,
        purge: 25,
        coagulate: 27
      }
    },
    cupid: {
      number: 2,
      name: "Cupid",
      desc: "A sleepy angel that specializes in helping her allies.",
      stage: 1,
      port: 'llov_battle_2',
      unlocked: false,
      hp: 140,
      atk: 110,
      def: 90,
      speed: 130,
      luck: 128,
      skills: {
        lovelyArrow: 1,
        hemorrhage: 5,
        angelRain: 10,
        quickheal: 10,
        heal: 15,
        clense: 25,
        massheal: 27
      }
    }
  },
  ebby: {
    'default': {
      number: 0,
      stage: 0,
      port: 'ebby_battle',
      hp: 109,
      atk: 105,
      def: 100,
      speed: 105,
      luck: 108,
      skills: {
        hemorrhage: 1,
        bloodburst: 5,
        bloodrun: 10,
        coagulate: 26,
        purge: 27,
        infectspread: 28,
        pandemic: 28
      }
    },
    angel: {
      number: 1,
      name: "Balance",
      desc: "A righteous judge who delivers punishment on her foes.",
      stage: 1,
      port: 'ebby_battle_1',
      unlocked: false,
      hp: 130,
      atk: 117,
      def: 106,
      speed: 110,
      luck: 120,
      skills: {
        hemorrhage: 1,
        bloodburst: 5,
        bloodrun: 10,
        clense: 15,
        purge: 15,
        quickheal: 26,
        infectspread: 28,
        pandemic: 28,
        heal: 30,
        massheal: 40
      }
    },
    necro: {
      number: 2,
      name: "Chaos",
      desc: "A dark caster who rains terrible curses on her foes.",
      stage: 1,
      port: 'ebby_battle_2',
      unlocked: false,
      hp: 110,
      atk: 125,
      def: 110,
      speed: 112,
      luck: 125,
      skills: {
        hemorrhage: 1,
        bloodburst: 5,
        bloodrun: 10,
        purge: 20,
        coagulate: 26,
        infectspread: 28,
        pandemic: 28,
        curse: 30,
        hex: 32,
        healblock: 40,
        isolate: 60
      }
    }
  },
  marb: {
    'default': {
      number: 0,
      stage: 0,
      port: 'marb_battle',
      hp: 112,
      atk: 110,
      def: 118,
      speed: 90,
      luck: 100,
      skills: {
        hemorrhage: 1,
        bloodburst: 7,
        artillery: 12,
        hellfire: 14,
        railCannon: 20,
        flare: 25
      }
    },
    siege: {
      number: 1,
      name: "Siege",
      desc: "Fortified to boost attack and defense capability.",
      stage: 1,
      port: 'marb_battle_1',
      unlocked: false,
      hp: 130,
      atk: 155,
      def: 160,
      speed: 70,
      luck: 100,
      skills: {
        hemorrhage: 1,
        bloodburst: 5,
        artillery: 10,
        railCannon: 12,
        hellfire: 14,
        nuke: 20,
        flare: 25
      }
    },
    assault: {
      number: 2,
      name: "Assault",
      desc: "Sheds all defense to become a swift killing machine.",
      stage: 1,
      port: 'marb_battle_2',
      unlocked: false,
      hp: 100,
      atk: 130,
      def: 100,
      speed: 150,
      luck: 100,
      skills: {
        hemorrhage: 1,
        bloodburst: 5,
        artillery: 10,
        hellfire: 12,
        railCannon: 14,
        nuke: 20,
        flare: 25
      }
    }
  }
};
for (p in formes) {
  for (f in formes[p]) {
    formes[p][f].id = f;
  }
}
costumes = {
  llov: {
    'default': {
      name: 'Siesta',
      bsheet: 'llov_battle',
      bframe: [0, 1, 2],
      csheet: 'llov',
      psheet: 'llov_base'
    },
    nurse: {
      name: 'Nurse',
      bframe: [3, 4, 5],
      crow: 7,
      psheet: 'llov_base2'
    },
    swim: {
      name: 'Bikini',
      bframe: [12, 13, 14],
      crow: 5,
      pframe: 3
    },
    swim2: {
      name: 'Sukumizu',
      bframe: [15, 16, 17],
      crow: 6,
      pframe: 4
    },
    pumpkin: {
      name: 'Pumpkin',
      bframe: [6, 7, 8],
      crow: 3,
      pframe: 2
    },
    christmas: {
      name: 'Holly',
      bsheet: 'llov_battle_christmas',
      crow: 2,
      psheet: 'llov_base2',
      pframe: 1
    },
    valentine: {
      name: 'Ribbon',
      bframe: [18, 19, 20],
      crow: 4,
      pframe: 5
    },
    punk: {
      name: 'Punk',
      bframe: [9, 10, 11],
      crow: 1,
      pframe: 1
    }
  },
  ebby: {
    'default': {
      name: 'Nurse',
      bsheet: 'ebby_battle',
      bframe: [0, 1, 2],
      csheet: 'ebby',
      psheet: 'ebby_base'
    },
    cheer: {
      name: 'Cheer',
      bframe: [6, 7, 8],
      crow: 2,
      pframe: 1
    },
    bat: {
      name: 'Bat',
      bframe: [3, 4, 5],
      crow: 1,
      psheet: 'ebby_base2'
    },
    fairy: {
      name: 'Fairy',
      bframe: [9, 10, 11],
      crow: 3,
      pframe: 2
    },
    witch: {
      name: 'Witch',
      bframe: [15, 16, 17],
      crow: 5,
      psheet: 'ebby_base2',
      pframe: 1
    },
    santa: {
      name: 'Santa',
      bframe: [12, 13, 14],
      crow: 4,
      pframe: 3
    }
  },
  marb: {
    'default': {
      name: 'Uniform',
      bsheet: ['marb_battle', 'marb_battle_1', 'marb_battle_2'],
      csheet: 'marb',
      psheet: 'marb_base'
    },
    nurse: {
      name: 'Nurse',
      bframe: 4,
      crow: 1,
      pframe: 2
    },
    maid: {
      name: 'Maid',
      bframe: 3,
      crow: 2,
      pframe: 1
    },
    bunny: {
      name: 'Bunny',
      bframe: 1,
      crow: 3,
      psheet: 'marb_base2'
    },
    demon: {
      name: 'Demon',
      bframe: 2,
      crow: 4,
      psheet: 'marb_base2',
      pframe: 1,
      frecolor: [[0x9b87a3, 0xe35000, 0xf8b800], [0x8a87a3, 0xb62e31, 0xf7c631]]
    },
    queen: {
      name: 'Regal',
      bframe: 5,
      crow: 5,
      psheet: 'marb_base2',
      pframe: 2
    }
  }
};
for (p in costumes) {
  for (c in costumes[p]) {
    for (i$ = 0, len$ = (ref$ = ['bsheet', 'bframe']).length; i$ < len$; ++i$) {
      k = ref$[i$];
      if (typeof costumes[p][c][k] === 'object') {
        continue;
      }
      filling = costumes[p][c][k];
      costumes[p][c][k] = [filling, filling, filling];
    }
  }
}
function get_costume(n, f, c, key){
  var sheet;
  c == null && (c = 'default');
  key == null && (key = 'bsheet');
  if (n == null) {
    return null;
  }
  if (typeof f === 'undefined') {
    f = 0;
  } else if (f && typeof f === 'object') {
    f = f.number;
  }
  if (costumes[n][c] && costumes[n][c][key]) {
    sheet = access(costumes[n][c][key]);
    if (f !== null && typeof sheet === 'object') {
      sheet = sheet[f];
    }
  }
  if (sheet == null) {
    sheet = access(costumes[n]['default'][key]);
    if (f !== null && typeof sheet === 'object') {
      sheet = sheet[f];
    }
  }
  return sheet;
}
function get_costume_old(name, forme, costume){
  if (typeof forme === 'object') {
    forme = forme.number;
  }
  forme = forme > 0 ? "_" + forme : '';
  costume = costume ? "_" + costume : '';
  if (game.cache.checkImageKey(name + "_battle" + costume + forme)) {
    return name + "_battle" + costume + forme;
  }
  return name + "_battle" + forme;
}
function learn_skills(p, level1, level2){
  var basicskills, excelskills, messages, excelmessages, key, ref$, level, f, forme, ref1$, index;
  if (p instanceof Player) {
    p = p.name;
  }
  basicskills = [];
  excelskills = [];
  messages = [];
  excelmessages = [];
  for (key in ref$ = formes[p]['default'].skills) {
    level = ref$[key];
    if (level > level1 && level <= level2) {
      if (players[p].skills['default'].length < 5 && !in$(skills[key], players[p].skills['default'])) {
        players[p].skills['default'].push(skills[key]);
      }
      messages.push(tl("{0} learned skill {1}!", speakers[p].display, skills[key].name));
      basicskills.push(key);
    }
  }
  for (f in ref$ = formes[p]) {
    forme = ref$[f];
    if (!forme.unlocked) {
      continue;
    }
    for (key in ref1$ = forme.skills) {
      level = ref1$[key];
      if (level > level1 && level <= level2) {
        if (players[p].skills[f].length < 5 && !in$(skills[key], players[p].skills[f])) {
          players[p].skills[f].push(skills[key]);
        }
        if (in$(key, basicskills)) {
          continue;
        }
        if ((index = excelskills.indexOf(key)) === -1) {
          excelmessages.push(tl("{0} forme learned Excel skill {1}!", forme.name, skills[key].name));
          excelskills.push(key);
        } else {
          excelmessages[index] = tl("{0} learned Excel skill {1}!", speakers[p].display, skills[key].name);
        }
      }
    }
  }
  return messages.concat(excelmessages);
}
function learn_skill(skill, p, f){
  f == null && (f = 'all');
  if (typeof skill === 'string') {
    skill = skills[skill];
  }
  say(function(){
    if (p != null) {
      skillbook[p][f].push(skill);
    } else {
      skillbook.all.push(skill);
    }
    save();
    return sound.play('itemget');
  });
  if (f !== 'all' && f !== 'default') {
    say('', tl("{0} forme learned Excel skill {1}!", formes[p][f].name, skill.name));
  } else if (p != null) {
    say('', tl("{0} learned skill {1}!", speakers[p].display, skill.name));
  } else {
    say('', tl("Learned skill {0}!", skill.name));
  }
}
Player = (function(superclass){
  var prototype = extend$((import$(Player, superclass).displayName = 'Player', Player), superclass).prototype, constructor = Player;
  function Player(x, y, key){
    var f;
    Player.superclass.call(this, x, y, key);
    this.follow_dist = 0;
    this.add_facing_animation();
    this.equip = buffs['null'];
    this.stats = {
      hp: 1,
      xp: 0
    };
    this.level = 1;
    this.skills = {};
    for (f in formes[this.name]) {
      this.skills[f] = [];
    }
    this.costume = null;
    this.ripple = this.addChild(
    new Phaser.Sprite(game, -8, 0, 'ripple'));
    this.ripple.animations.add('simple', null, 7, true);
    this.ripple.animations.play('simple');
    this.ripple.kill();
    this.kill();
    this.previous = {
      x: this.x,
      y: this.y
    };
  }
  Player.prototype.set_xp = function(xp, silent){
    var i$, ref$, len$, message;
    if (!silent) {
      for (i$ = 0, len$ = (ref$ = learn_skills(this, this.level, xpToLevel(xp))).length; i$ < len$; ++i$) {
        message = ref$[i$];
        say('', message);
      }
    }
    this.stats.xp = xp;
    this.level = xpToLevel(xp);
  };
  Player.prototype.add_xp = function(xp, silent){
    this.set_xp(this.stats.xp + xp, silent);
  };
  Player.prototype.luckroll = luckroll;
  Player.prototype.get_stat = function(key){
    var stat, s, that;
    stat = formes[this.name]['default'][key];
    switch (key) {
    case 'speed':
      s = calc_stat(this.level, stat, 2);
      break;
    case 'luck':
      s = calc_stat(this.level, stat, 6.1);
      break;
    default:
      s = new_calc_stat(this.level, stat);
    }
    return (that = this.equip["mod_" + key]) != null ? that(s) : s;
  };
  Player.prototype.excel_unlocked = function(){
    var key, ref$, forme;
    for (key in ref$ = formes[this.name]) {
      forme = ref$[key];
      if (forme.unlocked) {
        return true;
      }
    }
    return false;
  };
  return Player;
}(Actor));
function create_players(){
  var i$, len$, p;
  llov = new Player(0, 0, 'llov');
  ebby = new Player(20, 0, 'ebby');
  marb = new Player(40, 0, 'marb');
  players = [llov, ebby, marb];
  for (i$ = 0, len$ = players.length; i$ < len$; ++i$) {
    p = players[i$];
    players[p.name] = p;
  }
  party = [];
  create_skillbook();
}
function kill_players(){
  var i$, ref$, len$, actor;
  for (i$ = 0, len$ = (ref$ = players).length; i$ < len$; ++i$) {
    actor = ref$[i$];
    if (!in$(actor, party)) {
      actor.kill();
    }
  }
}
function set_party(){
  var i$, ref$, i, actor, ref1$, to$;
  for (i$ = (ref$ = party).length - 1; i$ >= 0; --i$) {
    i = i$;
    actor = ref$[i$];
    if (!actor.alive) {
      party.push(party.splice(i, 1)[0]);
    }
  }
  player = party[0];
  player.follow_object = null;
  player.follow_dist = 10;
  if ((ref$ = party[1]) != null) {
    ref$.follow_dist = 15;
  }
  if ((ref1$ = party[2]) != null) {
    ref1$.follow_dist = 30;
  }
  for (i$ = 1, to$ = party.length; i$ < to$; ++i$) {
    i = i$;
    party[i].follow_object = player;
  }
}
function join_party(p, options){
  var alevel, ref$, f;
  options == null && (options = {});
  if (party.length >= 3) {
    warn("Party is full!");
    return;
  }
  if (in$(players[p], party)) {
    warn("p is already in the party!");
    return;
  }
  alevel = averagelevel();
  party[options.front ? 'unshift' : 'push'](players[p]);
  if (!players[p].alive) {
    players[p].revive();
  }
  if (options.startlevel && players[p].level < (alevel > (ref$ = options.startlevel) ? alevel : ref$)) {
    players[p].set_xp(levelToXp(alevel > (ref$ = options.startlevel) ? alevel : ref$), true);
  }
  for (f in formes[p]) {
    if (players[p].skills[f].length === 0 && !switches.loadgame && (f === 'default' || formes[p][f].unlocked)) {
      starter_skills(p, f);
    }
  }
  set_party();
  if (options.save) {
    save();
  }
}
function leave_party(p){
  if (party.length <= 1) {
    return false;
  }
  if (typeof p === 'string') {
    p = players[p];
  }
  if (!p || party.indexOf(p) < 0) {
    return false;
  }
  party.splice(party.indexOf(p), 1);
  set_party();
  p.water_depth = Math.min(p.water_depth, 4);
  update_water_depth(p);
}
function change_leader(p){
  if (typeof p === 'string') {
    p = players[p];
  } else if (typeof p === 'number') {
    p = party[p];
  }
  if (!p || party.indexOf(p) < 0) {
    return false;
  }
  party.unshift(party.splice(party.indexOf(p), 1)[0]);
  set_party();
  return p;
}
function unlock_forme(p, f){
  formes[p][f].unlocked = true;
  if (in$(players[p], party)) {
    starter_skills(p, f, true);
  }
  save();
}
Player.prototype.physics_update = function(){
  if (switches.noclip) {
    return;
  }
  if (this === party[0]) {
    physics_update_player.apply(this, arguments);
  } else if (in$(this, party)) {
    physics_update_follower.apply(this, arguments);
  } else {
    Actor.prototype.physics_update.apply(this, arguments);
  }
};
function physics_update_follower(){
  var i$, ref$, len$, actor;
  tile_collision_recoil(this, map.namedLayers.tile_layer);
  for (i$ = 0, len$ = (ref$ = actors.children).length; i$ < len$; ++i$) {
    actor = ref$[i$];
    if (actor.body == null) {
      continue;
    }
    if (actor.nobody) {
      continue;
    }
    game.physics.arcade.overlap(this, actor, player_actor_handle_collision, follower_actor_process_collision, this);
  }
}
function physics_update_player(){
  var i$, ref$, len$, actor;
  tile_collision_recoil(this, map.namedLayers.tile_layer);
  for (i$ = 0, len$ = (ref$ = actors.children).length; i$ < len$; ++i$) {
    actor = ref$[i$];
    if (actor.body == null) {
      continue;
    }
    if (actor.nobody) {
      continue;
    }
    game.physics.arcade.overlap(this, actor, player_actor_handle_collision, player_actor_process_collision, this);
  }
}
Player.prototype.update = function(){
  var t, ref$;
  this.terrain = t = (ref$ = getTileUnder(this)) != null ? ref$.properties.terrain : void 8;
  if (t === 'mountain') {
    this.bridgemode = 'over';
  } else if (t !== 'mountain' && t !== 'overpass') {
    this.bridgemode = 'under';
  }
  if (switches.cinema) {
    update_player_cinema.apply(this, arguments);
    return;
  }
  if (this === party[0]) {
    update_player.apply(this, arguments);
  } else if (in$(this, party)) {
    update_follower.apply(this, arguments);
  } else {
    Actor.prototype.update.apply(this, arguments);
  }
};
Player.prototype.updatePaused = function(){
  this.stop();
  this.cancel_movement();
};
function update_player_cinema(){
  if (this.body.deltaAbsX() === 0 && this.body.deltaAbsY() === 0) {
    this.moving = false;
  }
  this.follow_path();
  this.apply_movement(1);
}
function update_follower(){
  var notmoving;
  this.update_follow_behind();
  if (this.previous.x - this.x === 0 && this.previous.y - this.y === 0) {
    notmoving = true;
  }
  this.previous.x = this.x;
  this.previous.y = this.y;
  this.follow_path();
  this.apply_movement(1);
  if (this.alive && distance(this, player) > this.follow_dist * 3) {
    Dust.summon(this);
    Dust.summon(player);
    this.x = player.x;
    this.y = player.y;
  }
  water_sink.apply(this, arguments);
  if (notmoving) {
    this.stop();
  }
}
function water_sink(){
  var cache, keyheight, prevdepth, water_depth, ref$, ref1$, i$, len$, p, drowned;
  cache = getCachedImage(this.key);
  keyheight = cache.frameHeight || cache.frame.height;
  prevdepth = this.water_depth;
  switch (water_depth = over_water(this)) {
  case 0:
    this.water_depth = 0;
    break;
  case 1:
    if (this.water_depth > 4) {
      this.water_depth = 4 > (ref$ = this.water_depth - 92 * deltam) ? 4 : ref$;
    }
    if (this.water_depth < 4) {
      this.water_depth = 4 < (ref$ = this.water_depth + 6 * deltam) ? 4 : ref$;
    }
    break;
  case 2:
    this.water_depth = (ref$ = keyheight < (ref1$ = this.water_depth + 6 * deltam) ? keyheight : ref1$) > 4 ? ref$ : 4;
  }
  if (this.water_depth !== prevdepth) {
    update_water_depth(this, true);
  }
  if (prevdepth === 0 && this.water_depth > 0) {
    this.ripple.revive();
  }
  if (this.water_depth === 0 && prevdepth !== 0) {
    this.ripple.kill();
  }
  if (water_depth > 1) {
    if (!switches.cinema) {
      this.drift = -12;
    }
  }
  if (this.alive && this.water_depth === keyheight) {
    this.stats.hp = 0;
    this.kill();
    set_party();
    log(this.name + " drowned!");
    for (i$ = 0, len$ = (ref$ = carpet.children).length; i$ < len$; ++i$) {
      p = ref$[i$];
      if (p.key === 'pent' && p.flame) {
        p.flame.visible = false;
      }
    }
    drowned = true;
    for (i$ = 0, len$ = (ref$ = party).length; i$ < len$; ++i$) {
      p = ref$[i$];
      if (p.stats.hp > 0) {
        drowned = false;
      }
    }
    if (drowned) {
      quitgame();
    }
  }
}
function update_water_depth(p, justcrop){
  var cache, keyheight, keywidth, t, ref$;
  cache = getCachedImage(p.key);
  keyheight = cache.frameHeight || cache.frame.height;
  keywidth = cache.frameWidth || cache.frame.width;
  p.crop({
    x: 0,
    y: p.row * keyheight,
    width: keywidth,
    height: keyheight - p.water_depth
  });
  if (justcrop) {
    return;
  }
  t = ((ref$ = getTileUnder(p)) != null ? ref$.properties.terrain : void 8) || 'water';
  if (t === 'water') {
    p.ripple.revive();
  } else {
    p.ripple.kill();
  }
}
function update_player(){
  var now, mousedist, move, i$, ref$, len$, trigger;
  now = Date.now();
  this.speed = 60;
  mousedist = distance(mouse.world, player);
  if (mouse.down && player.follow_dist < mousedist && now - this.lastrelocate > 1000) {
    this.speed = Math.min(25 * mousedist / HHEIGHT + 50, 75);
    this.goal = {
      x: mouse.world.x,
      y: mouse.world.y
    };
  }
  this.update_follow_object();
  move = {
    x: 0,
    y: 0,
    dist: 5
  };
  if (keyboard.up()) {
    move.y -= move.dist;
  }
  if (keyboard.down()) {
    move.y += move.dist;
  }
  if (keyboard.left()) {
    move.x -= move.dist;
  }
  if (keyboard.right()) {
    move.x += move.dist;
  }
  if (move.x !== 0 || move.y !== 0) {
    if (keyboard.dash()) {
      this.speed = 80;
    }
    this.goal = {
      x: this.x + move.x,
      y: this.y + move.y
    };
    if (this.path.length) {
      this.path = [];
    }
    this.follow_object = null;
  }
  player.animations.currentAnim.speed = 7 / 60 * this.speed;
  if (this.body.deltaAbsX() < 0.1 && this.body.deltaAbsY() < 0.1) {
    this.moving = false;
  }
  this.follow_path();
  this.apply_movement(move.dist);
  for (i$ = 0, len$ = (ref$ = triggers.children).length; i$ < len$; ++i$) {
    trigger = ref$[i$];
    game.physics.arcade.collide(this, trigger, player_trigger_handle_collision, player_trigger_process_collision, this);
  }
  if (this.follow_object != null && distance(this, this.follow_object) < body_radius(this.follow_object.body) + body_diameter(this.body)) {
    this.interact_with(this.follow_object);
  }
  water_sink.apply(this, arguments);
}
function start_camera(){
  game.camera.center = {
    x: this.x,
    y: this.y
  };
  game.camera.x = this.x - game.width / 2;
  game.camera.y = this.y - game.height / 2;
}
function update_camera(){
  var camera_dest, camera_dist;
  game.camera.center.x = this.x;
  game.camera.center.y = this.y;
  camera_dest = {
    x: this.x - game.width / 2,
    y: this.y - game.height / 2
  };
  camera_dist = {
    x: camera_dest.x - game.camera.x,
    y: camera_dest.y - game.camera.y
  };
  if (Math.abs(camera_dist.x) > 1 || Math.abs(camera_dist.y) > 1) {
    game.camera.x += camera_dist.x * deltam * 5;
    game.camera.y += camera_dist.y * deltam * 5;
  } else {
    game.camera.x = camera_dest.x;
    game.camera.y = camera_dest.y;
  }
}
function camera_center(x, y, instant){
  game.camera.center.x = x;
  game.camera.center.y = y;
  if (instant) {
    game.camera.x = x - game.width / 2;
    game.camera.y = y - game.height / 2;
  }
}
Player.prototype.interact_with = function(actor){
  if (!actor.alive) {
    return;
  }
  if (actor === this.follow_object) {
    this.follow_object = null;
  }
  if (typeof actor.interact == 'function') {
    actor.interact();
  }
  if (actor instanceof Actor) {
    this.face_point(actor);
    actor.face_point(this);
  }
  if (actor instanceof Doodad && actor.body) {
    if (!actor.body) {
      console.warn("Object doesn't have a body!");
    }
    this.face_point(actor.body.center);
  }
};
function player_actor_handle_collision(player, actor){
  actor_collision_recoil(player, actor);
  this.cancel_movement();
  if (this.path.length) {
    this.path = [];
  }
  if (actor.battle != null && actor.alive && !actor.dontcheck && !temp.enteringbattle) {
    if (typeof actor.onbattle == 'function') {
      actor.onbattle();
    }
    start_battle(actor.battle, actor.toughness, actor.terrain);
  } else {
    if (typeof actor.oncollide == 'function') {
      actor.oncollide();
    }
  }
}
function player_actor_process_collision(player, actor){
  return !in$(actor, party);
}
function follower_actor_process_collision(player, actor){
  return !in$(actor, party) && !(actor instanceof Mob);
}
function player_trigger_handle_collision(player, trigger){
  return trigger.handle();
}
function player_trigger_process_collision(player, trigger){
  return trigger.process();
}
function mousewheel_player(e){
  if ((e.wheelDelta || e.deltaY) > 0) {
    player_wheel_up();
  } else {
    player_wheel_down();
  }
  save();
}
function player_wheel_up(){
  var i$, to$, i;
  for (i$ = 1, to$ = party.length; i$ < to$; ++i$) {
    i = i$;
    if (party[i].alive) {
      party[i].goal = {
        x: player.x,
        y: player.y
      };
      break;
    }
  }
  i = 0;
  do {
    party.push(party.shift());
    i++;
  } while (!party[0].alive && i < 3);
  set_party();
}
function player_wheel_down(){
  var i$, i;
  for (i$ = party.length - 1; i$ > 0; --i$) {
    i = i$;
    if (party[i].alive) {
      party[i].goal = {
        x: player.x,
        y: player.y
      };
      break;
    }
  }
  i = 0;
  do {
    party.unshift(party.pop());
    i++;
  } while (!party[0].alive && i < 3);
  set_party();
}
function mousetap_player(e){
  if (!nullbutton(e.button)) {
    return;
  }
}
function mousedown_player(e){
  var i$, ref$, len$, actor, doodad;
  if (actors.paused || switches.cinema) {
    return;
  }
  if (nullbutton(e.button)) {
    player.follow_object = null;
    for (i$ = 0, len$ = (ref$ = actors.children).length; i$ < len$; ++i$) {
      actor = ref$[i$];
      if (actor.nointeract) {
        continue;
      }
      if (actor instanceof Actor && !in$(actor, party) && actor.alive && !actor.nobody && point_in_sprite(mouse.world, actor)) {
        player.follow_object = actor;
      }
    }
    for (i$ = 0, len$ = (ref$ = Doodad.list).length; i$ < len$; ++i$) {
      doodad = ref$[i$];
      if (doodad.nointeract) {
        continue;
      }
      if (doodad.body != null && point_in_body(mouse.world, doodad.body) && distance(doodad.body.center, player) < body_radius(doodad.body) + body_diameter(player.body)) {
        player.interact_with(doodad);
        return false;
      }
    }
  }
}
function player_confirm_button(){
  var g, i$, ref$, len$, actor, doodad;
  if (actors.paused || switches.cinema) {
    return;
  }
  g = player.get_facing_point(body_diameter(player.body));
  g = {
    x: player.x + g.x,
    y: player.y + g.y
  };
  for (i$ = 0, len$ = (ref$ = actors.children).length; i$ < len$; ++i$) {
    actor = ref$[i$];
    if (actor.nointeract) {
      continue;
    }
    if (actor instanceof Actor && !in$(actor, party) && distance(g, actor) < body_diameter(actor.body)) {
      player.interact_with(actor);
      return false;
    }
  }
  for (i$ = 0, len$ = (ref$ = Doodad.list).length; i$ < len$; ++i$) {
    doodad = ref$[i$];
    if (doodad.nointeract) {
      continue;
    }
    if (doodad.body != null && point_in_body({
      x: g.x,
      y: g.y - 6
    }, doodad.body)) {
      player.interact_with(doodad);
      return false;
    }
  }
}
Player.prototype.start_location = function(heal){
  var name, node, mapname;
  heal == null && (heal = false);
  name = switches.map === switches.checkpoint_map ? switches.checkpoint : 'player_start';
  if (!(node = nodes[name])) {
    if (switches.checkpoint) {
      mapname = switches.checkpoint_map;
      name = switches.checkpoint;
    } else {
      mapname = STARTMAP;
      name = 'player_start';
    }
    schedule_teleport({
      pmap: mapname,
      pport: name,
      pdir: 'down',
      pnode: true
    });
    return;
  } else {
    this.x = node.x + HTS;
    this.y = node.y - this.bodyoffset.y + TS;
  }
  if (heal) {
    this.stats.hp = 1;
  }
  if (heal) {
    this.revive();
  }
  this.cancel_movement();
};
Player.prototype.update_follow_behind = function(){
  var g, dist;
  if (this.follow_object == null) {
    return;
  }
  g = this.follow_object.get_facing_point(-this.follow_dist);
  g.x += this.follow_object.x;
  g.y += this.follow_object.y;
  if ((dist = distance(this, g)) > 1) {
    this.speed = Math.min(25 * dist / this.follow_dist + 50, 80);
    this.goal = g;
  }
};
Player.prototype.get_facing_point = function(dist){
  var f;
  switch (this.facing) {
  case 'up':
    f = {
      x: 0,
      y: -1
    };
    break;
  case 'upright':
    f = {
      x: 0.707,
      y: -0.707
    };
    break;
  case 'right':
    f = {
      x: 1,
      y: 0
    };
    break;
  case 'downright':
    f = {
      x: 0.707,
      y: 0.707
    };
    break;
  case 'down':
    f = {
      x: 0,
      y: 1
    };
    break;
  case 'downleft':
    f = {
      x: -0.707,
      y: 0.707
    };
    break;
  case 'left':
    f = {
      x: -1,
      y: 0
    };
    break;
  case 'upleft':
    f = {
      x: -0.707,
      y: -0.707
    };
    break;
  default:
    f = {
      x: 0,
      y: 0
    };
  }
  return {
    x: f.x * dist,
    y: f.y * dist
  };
};
Player.prototype.update_follow_object = function(){
  if (this.follow_object == null) {
    return;
  }
  this.goal = {
    x: this.follow_object.x,
    y: this.follow_object.y
  };
};
Skill = (function(){
  Skill.displayName = 'Skill';
  var prototype = Skill.prototype, constructor = Skill;
  function Skill(properties){
    var key;
    for (key in properties) {
      this[key] = properties[key];
    }
    this.xp == null && (this.xp = 0);
    this.ex == null && (this.ex = 0);
    this.sp == null && (this.sp = 100);
    this.action == null && (this.action = function(){});
    this.target == null && (this.target = 'enemy');
    this.attributes == null && (this.attributes = ['attack']);
  }
  return Skill;
}());
animations = {
  slash: {
    sprite: 'anim_slash',
    frames: [0, 1, 2, 3, 4, 5],
    anchor: [1 / 3, 1.0]
  },
  flame: {
    sprite: 'anim_flame',
    frames: [0, 1, 2, 3, 4, 5, 6],
    anchor: [0.5, 0.5]
  },
  curse: {
    sprite: 'anim_curse',
    frames: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
    anchor: [0.5, 0.5]
  },
  heal: {
    sprite: 'anim_heal',
    frames: [0, 1, 2, 3, 4, 5],
    anchor: [0.5, 0.5]
  },
  blood1: {
    sprite: 'anim_blood1',
    frames: [0, 1, 2, 3, 4, 5, 6, 7],
    anchor: [0, 12 / 42]
  },
  blood2: {
    sprite: 'anim_blood2',
    frames: [0, 1, 2, 3, 4],
    anchor: [0.5, 0.5]
  },
  water: {
    sprite: 'anim_water',
    frames: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    anchor: [0.5, 0.5]
  },
  flies: {
    sprite: 'anim_flies',
    frames: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14],
    anchor: [0.5, 0.5]
  }
};
function damage(t, n){
  return t.damage(Math.round(calc_damage(battle.actor, t, n)), true, battle.actor);
}
function damage_target(n){
  var targets, i$, len$, target, results$ = [];
  if (battle.target instanceof Array) {
    targets = battle.target;
  } else {
    targets = [battle.target];
  }
  for (i$ = 0, len$ = targets.length; i$ < len$; ++i$) {
    target = targets[i$];
    results$.push(target.damage(Math.round(calc_damage(battle.actor, target, n)), true, battle.actor));
  }
  return results$;
}
function calc_damage(a, d, n){
  var atk, def;
  atk = a.get_stat('atk');
  def = d.get_stat('def');
  return atk * atk * n / (def * 500);
}
function heal_target(n){
  var i$, ref$, len$, target, results$ = [];
  if (battle.target instanceof Array) {
    for (i$ = 0, len$ = (ref$ = battle.target).length; i$ < len$; ++i$) {
      target = ref$[i$];
      results$.push(target.damage(-n, true, battle.actor));
    }
    return results$;
  } else {
    return battle.target.damage(-n, true, battle.actor);
  }
}
function heal_scaled(n){
  return heal_target(battle.actor.get_stat('hp') * n / 100);
}
function heal_hybrid(n, s){
  return heal_target(n + battle.actor.get_stat('hp') * s / 100);
}
function reward_xp(n){
  if (!(battle.actor instanceof Battler)) {
    return;
  }
  return battle.actor.reward_xp(n);
}
skills = {};
skills.attack = {
  name: "Attack",
  animation: 'slash',
  action: function(){
    return damage_target(75);
  },
  attributes: ['attack'],
  desc: 'Default attack move.'
};
skills.strike = {
  name: "Strike",
  animation: 'slash',
  action: function(){
    return damage_target(100);
  },
  attributes: ['attack'],
  desc: 'Basic attack move.'
};
skills.lovetap = {
  name: "Love Tap",
  animation: 'slash',
  action: function(){
    return damage_target(10);
  },
  attributes: ['attack'],
  desc: 'A weak attack lacking any malice. It can be used to bide for time.',
  sp: 10
};
skills.hemorrhage = {
  name: "Hemorrhage",
  animation: 'blood1',
  sp: 100,
  action: function(){
    return battle.target.inflict(buffs.bleed);
  },
  target: 'enemy',
  attributes: ['blood', 'attack', 'magic'],
  desc: "Causes the enemy to lose health over time.",
  aitarget: function(){
    var enemylist, list, i$, len$, enemy;
    enemylist = enemy_list();
    list = [];
    for (i$ = 0, len$ = enemylist.length; i$ < len$; ++i$) {
      enemy = enemylist[i$];
      if (enemy.has_buff(buffs['null'])) {
        list.push(enemy);
      }
    }
    if (list.length === 0) {
      list = enemylist;
    }
    return battle.target = list[Math.floor(Math.random() * list.length)];
  }
};
skills.bloodburst = {
  name: "Blood Burst",
  animation: 'blood2',
  sp: 100,
  action: function(){
    if (battle.target.has_buff(buffs.bleed)) {
      battle.target.remedy(buffs.bleed);
      return damage_target(160);
    } else {
      return damage_target(10);
    }
  },
  aitarget: function(){
    var enemylist, list, i$, len$, enemy;
    enemylist = enemy_list();
    list = [];
    for (i$ = 0, len$ = enemylist.length; i$ < len$; ++i$) {
      enemy = enemylist[i$];
      if (enemy.has_buff(buffs.bleed)) {
        list.push(enemy);
      }
    }
    if (list.length === 0) {
      list = enemylist;
    }
    return battle.target = list[Math.floor(Math.random() * list.length)];
  },
  target: 'enemy',
  attributes: ['blood', 'attack', 'magic'],
  desc: "Effective against bleeding enemies."
};
skills.coagulate = {
  name: "Coagulate",
  animation: 'slash',
  sp: 100,
  xp: 10,
  action: function(){
    var i$, ref$, len$, buff, results$ = [];
    for (i$ = 0, len$ = (ref$ = battle.target.buffs).length; i$ < len$; ++i$) {
      buff = ref$[i$];
      if (buff.name === 'bleed') {
        results$.push(buff.load_buff(buffs.coagulate));
      }
    }
    return results$;
  },
  aitarget: skills.bloodburst.aitarget,
  target: 'enemy',
  attributes: ['blood', 'status', 'magic'],
  desc: "Converts bleed effects into scabs, hindering the enemy."
};
skills.bloodrun = {
  name: "Blood Run",
  animation: 'blood1',
  sp: 100,
  xp: 10,
  action: function(){
    var i$, ref$, len$, buff, results$ = [];
    for (i$ = 0, len$ = (ref$ = battle.target.buffs).length; i$ < len$; ++i$) {
      buff = ref$[i$];
      if (buff.name === 'bleed' && buff.duration < 3 && !buff.extended) {
        buff.duration = 3;
        buff.extended = true;
        buff.frame = 4;
        setrow(buff, 3);
      }
      if (buff.name === 'coagulate') {
        results$.push(buff.load_buff(buffs.bleed));
      }
    }
    return results$;
  },
  aitarget: function(){
    var enemylist, list, i$, len$, enemy, j$, ref$, len1$, buff;
    enemylist = enemy_list();
    list = [];
    for (i$ = 0, len$ = enemylist.length; i$ < len$; ++i$) {
      enemy = enemylist[i$];
      if (enemy.has_buff(buffs.coagulate)) {
        list.push(enemy);
        continue;
      }
      for (j$ = 0, len1$ = (ref$ = enemy.buffs).length; j$ < len1$; ++j$) {
        buff = ref$[j$];
        if (buff.base === buffs.bleed && !buff.extended) {
          list.push(enemy);
          break;
        }
      }
    }
    if (list.length === 0) {
      list = enemylist;
    }
    return battle.target = list[Math.floor(Math.random() * list.length)];
  },
  target: 'enemy',
  attributes: ['blood', 'status', 'magic'],
  desc: "Extends the duration of bleeding effects. Also undoes any coagulants, making them bleed again."
};
skills.bloodboost = {
  name: "Blood Boost",
  animation: 'blood2',
  sp: 100,
  action: function(){
    battle.target.inflict(buffs.bloodboost);
  },
  target: 'self',
  attributes: ['status']
};
skills.bloodlet = {
  name: "Blood Let",
  animation: 'blood2',
  sp: 10,
  action: function(){
    var i$, ref$, len$, buff;
    for (i$ = 0, len$ = (ref$ = battle.target.buffs).length; i$ < len$; ++i$) {
      buff = ref$[i$];
      if (buff.name === 'bloodboost' || buff.name === 'coagulate') {
        buff.load_buff(buffs.bleed);
        buff.duration = 999;
        return;
      }
    }
    battle.target.inflict(buffs.bleed);
  },
  target: 'self',
  attributes: ['status']
};
skills.trickpunch = {
  name: "Trick Punch",
  animation: 'slash',
  sfx: 'strike',
  sp: 30,
  action: function(){
    damage_target(22);
    return battle.target.inflict(buffs.dazed);
  },
  attributes: ['attack'],
  desc: 'Surprises the enemy, lowering their speed for a short time.'
};
skills.lovelyArrow = {
  name: "Lavuri Aero",
  animation: 'slash',
  sfx: 'swing',
  custom_animation: function(){
    var a, actor, target, time;
    a = get_animation();
    a.revive();
    actor = {
      x: battle.actor.x,
      y: battle.actor.y
    };
    target = {
      x: battle.target.x,
      y: battle.target.y
    };
    if (battle.actor instanceof Battler) {
      actor.x += WS * 3;
      actor.y += WS * 3;
    }
    if (battle.target instanceof Battler) {
      target.x += WS * 3;
      target.y += WS * 3;
    }
    a.x = actor.x;
    a.y = actor.y;
    a.loadTexture('anim_arrow');
    time = 0;
    sound.play('swing');
    a.update = function(){
      time += delta;
      a.x = actor.x + (target.x - actor.x) * (time / 500);
      if (time <= 250) {
        a.y = actor.y - actor.y * Math.sin(HPI * time / 250);
      } else {
        a.scale.y = -1;
        a.y = target.y - target.y * Math.sin(HPI * time / 250);
      }
      if (time > 500) {
        a.update = function(){};
        a.scale.y = 1;
        a.kill();
        process_callbacks(battle.animation.callback);
      }
    };
  },
  sp: function(){
    return 50;
  },
  action: function(){
    var d;
    d = 55;
    if (battle.target.has_buff(buffs.charmed)) {
      d += 10;
    }
    if (battle.actor.item === items.bow) {
      d += 10;
    }
    return damage_target(d);
  },
  target: 'enemy',
  attributes: ['arrow', 'attack'],
  desc_battle: "A fast and light attack.",
  desc: "Lets loose a single arrow to quickly strike the enemy."
};
skills.angelRain = {
  name: "Enjel Rain",
  animation: 'slash',
  sp: 100
  /*
  custom_animation: !->
      count=0
      done=false
      setanimation=!->
          return if done
          count++
          a=get_animation!
          a.callback=setanimation
          (done:=true; a.callback=battle.animation.callback) if count > 12
          #a.play!
          a.play 'slash', random_dice(2)*WIDTH, random_dice(2)*HHEIGHT+(if battle.actor instanceof Monster then HHEIGHT else 0)+16
          sound.play \strike
      for i til 3
          setTimeout setanimation, 500*i
          #setanimation!
  */,
  custom_animation: function(){
    var actor, count, done, newarrow, i$, i;
    actor = {
      x: battle.actor.x,
      y: battle.actor.y
    };
    if (battle.actor instanceof Battler) {
      actor.x += WS * 3;
      actor.y += WS * 3;
    }
    count = 0;
    done = false;
    newarrow = function(){
      var a;
      a = get_animation();
      a.revive();
      a.target = {
        x: 0,
        y: 0
      };
      a.loadTexture('anim_arrow');
      a.time = 0;
      a.update = function(){
        this.time += delta;
        this.x = actor.x + (this.target.x - actor.x) * (this.time / 500);
        if (this.time <= 250) {
          this.y = actor.y - actor.y * Math.sin(HPI * this.time / 250);
        } else {
          this.scale.y = -1;
          this.y = this.target.y - this.target.y * Math.sin(HPI * this.time / 250);
        }
        if (this.time > 500) {
          this.scale.y = 1;
          if (count > 12) {
            this.update = function(){};
            this.kill();
            if (!done) {
              done = true;
              process_callbacks(battle.animation.callback);
            }
          } else {
            this.iterate();
          }
        }
      };
      a.iterate = function(){
        this.target.x = random_dice(2) * WIDTH;
        this.target.y = random_dice(2) * HHEIGHT + (battle.actor instanceof Monster ? HHEIGHT : 0) + 16;
        this.x = actor.x;
        this.y = actor.y;
        this.time = 0;
        count++;
        sound.play('swing');
      };
      a.iterate();
    };
    for (i$ = 0; i$ < 3; ++i$) {
      i = i$;
      setTimeout(newarrow, 300 * i);
    }
  },
  action: function(){
    var d, i$, ref$, len$, target, results$ = [];
    d = 55;
    if (battle.actor.item === items.bow) {
      d += 10;
    }
    for (i$ = 0, len$ = (ref$ = battle.target).length; i$ < len$; ++i$) {
      target = ref$[i$];
      results$.push(damage(target, target.has_buff(buffs.charmed) ? d + 10 : d));
    }
    return results$;
  },
  target: 'enemies',
  attributes: ['arrow', 'attack'],
  desc: "A holy rain of arrows that strikes every enemy."
};
skills.hellfire = {
  name: "Hellfire",
  animation: 'flame',
  sp: 200,
  custom_animation: function(){
    var count, done, setanimation, i$, i;
    count = 0;
    done = false;
    setanimation = function(){
      var a;
      if (done) {
        return;
      }
      count++;
      a = get_animation();
      a.callback = setanimation;
      if (count > 12) {
        done = true;
        a.callback = battle.animation.callback;
      }
      a.play('flame', random_dice(2) * WIDTH, random_dice(2) * HHEIGHT + (battle.actor instanceof Monster ? HHEIGHT : 0) + 16);
      sound.play('flame');
    };
    for (i$ = 0; i$ < 3; ++i$) {
      i = i$;
      setTimeout(setanimation, 500 * i);
    }
  },
  action: function(){
    return damage_target(105);
  },
  target: 'enemies',
  attributes: ['fire', 'tech', 'attack'],
  desc: "Rains heavy fire from the sky, striking all enemies."
};
skills.devilKiss = {
  name: "Debiru Kiss",
  animation: 'slash',
  sfx: 'voice',
  sp: 100,
  xp: 10,
  action: function(){
    return battle.target.inflict(buffs.charmed);
  },
  target: 'enemy',
  attributes: ['status', 'magic'],
  desc: "Charms the target, reducing its stats and making it less likely to attack Lloviu-tan. Also makes it take slightly more damage from arrow attacks. Does not stack.",
  desc_battle: "Charms the target, reducing its stats. Does not stack."
};
skills.pandemic = {
  name: "Pandemic",
  animation: 'blood1',
  sp: 150,
  action: function(){
    var i$, ref$, len$, target, results$ = [];
    for (i$ = 0, len$ = (ref$ = battle.target).length; i$ < len$; ++i$) {
      target = ref$[i$];
      results$.push(target.inflict(buffs.bleed));
    }
    return results$;
  },
  target: 'enemies',
  attributes: ['blood', 'attack', 'magic'],
  desc: "Infects all enemies with hemorrhages."
};
skills.infectspread = {
  name: "Spread Infection",
  animation: 'blood1',
  sp: 100,
  action: function(){
    var i$, ref$, len$, enemy, results$ = [];
    for (i$ = 0, len$ = (ref$ = enemy_list()).length; i$ < len$; ++i$) {
      enemy = ref$[i$];
      if (enemy === battle.target) {
        continue;
      }
      results$.push(enemy.inflict(buffs.bleed));
    }
    return results$;
  },
  target: 'enemy',
  aitarget: skills.bloodburst.aitarget,
  attributes: ['blood', 'status', 'magic'],
  desc: "Spreads a bleeding effect to other enemies."
};
skills.skullbeam = {
  name: "Skull Beam",
  animation: 'blood1',
  custom_animation: function(){
    var actor, target, done, duration, quantity, count, newarrow, count2, i$, i;
    actor = {
      x: battle.actor.x,
      y: battle.actor.y
    };
    target = {
      x: battle.target.x,
      y: battle.target.y
    };
    if (battle.actor instanceof Battler) {
      actor.x += WS * 3;
      actor.y += WS * 3;
    }
    if (battle.target instanceof Battler) {
      target.x += WS * 3;
      target.y += WS * 3;
    }
    done = false;
    duration = 1000;
    quantity = 12;
    count = 0;
    newarrow = function(i, i2){
      var a;
      a = get_animation();
      a.revive();
      a.loadTexture('solid');
      a.time = 0;
      a.origin = {
        x: actor.x + (target.x - actor.x) * (i / i2),
        y: actor.y + (target.y - actor.y) * (i / i2)
      };
      a.update = function(){
        var c;
        this.time += delta;
        this.x = this.origin.x + random_dice(2) * 10 - 5;
        this.y = this.origin.y + random_dice(2) * 10 - 5;
        this.scale.x = this.scale.y = 12 * Math.sin(Math.PI * this.time / duration);
        this.rotation = Math.random() * HPI * 4;
        c = {
          r: Math.random() * 255,
          g: 0,
          b: 0
        };
        c.g = Math.random() * c.r;
        c.b = Math.random() * c.r;
        this.tint = makecolor(c);
        if (this.time > duration) {
          this.scale.set(1, 1);
          this.tint = 0xffffff;
          this.rotation = 0;
          this.update = function(){};
          this.kill();
          count++;
          if (count === quantity) {
            process_callbacks(battle.animation.callback);
          }
        }
      };
    };
    count2 = 0;
    for (i$ = 0; i$ < quantity; ++i$) {
      i = i$;
      setTimeout(fn$, 50 * i);
    }
    sound.play('laser');
    function fn$(){
      return newarrow(count2++, quantity - 1);
    }
  },
  sp: 100,
  action: function(){
    var bloodcount, i$, ref$, len$, buff;
    bloodcount = 0;
    for (i$ = 0, len$ = (ref$ = battle.target.buffs).length; i$ < len$; ++i$) {
      buff = ref$[i$];
      if (buff.name === 'bleed') {
        bloodcount++;
      }
    }
    if (bloodcount > 0) {
      return damage_target(100 + bloodcount * 20);
    } else {
      return damage_target(50);
    }
  },
  target: 'enemy',
  attributes: ['blood', 'attack', 'magic'],
  desc: "Shoots lasers from the eyes of the skull, dealing more damage for each bleed effect on the target."
};
skills.eyebeam = {
  name: "Eye Beam",
  custom_animation: skills.skullbeam.custom_animation,
  sp: 100,
  action: function(){
    return damage_target(100);
  },
  target: 'enemy',
  attributes: ['magic', 'attack']
};
skills.hex = {
  name: "Hex",
  animation: 'curse',
  sfx: 'groan',
  sp: 100,
  action: function(){
    var buffcount, i$, ref$, len$, buff;
    buffcount = 0;
    for (i$ = 0, len$ = (ref$ = battle.target.buffs).length; i$ < len$; ++i$) {
      buff = ref$[i$];
      if (buff.name !== 'null') {
        buffcount++;
      }
    }
    return damage_target([25, 75, 100, 120, 140, 160][buffcount]);
  },
  target: 'enemy',
  attributes: ['attack', 'magic'],
  desc: "Does more damage for each status effect on the enemy.",
  aitarget: function(){
    var enemylist, list, highest, i$, len$, enemy, buffcount, j$, ref$, len1$, buff;
    enemylist = enemy_list();
    list = null;
    highest = 0;
    for (i$ = 0, len$ = enemylist.length; i$ < len$; ++i$) {
      enemy = enemylist[i$];
      buffcount = 0;
      for (j$ = 0, len1$ = (ref$ = enemy.buffs).length; j$ < len1$; ++j$) {
        buff = ref$[j$];
        if (buff.name !== 'null') {
          buffcount++;
        }
      }
      if (!list || buffcount > highest) {
        list = [enemy];
        highest = buffcount;
      } else if (buffcount === highest) {
        list.push(enemy);
      }
    }
    list == null && (list = enemylist);
    return battle.target = list[Math.floor(Math.random() * list.length)];
  }
};
skills.swarm = {
  name: "Swarm",
  sfx: 'groan',
  animation: 'flies',
  sp: 50,
  action: function(){
    return battle.target.inflict(buffs.swarm);
  },
  target: 'enemy',
  weight: 2,
  attributes: ['status', 'magic'],
  aitarget: skills.hemorrhage.aitarget
};
skills.swarmdrain = {
  name: "Swarm Drain",
  sfx: 'groan',
  animation: 'flies',
  sp: 50,
  action: function(){
    return battle.actor.inflict(buffs.swarmdrain);
  },
  target: 'self',
  weight: 1,
  attributes: ['status', 'heal', 'magic']
};
skills.leecharrow = {
  name: "Vital Aero",
  custom_animation: skills.lovelyArrow.custom_animation,
  sp: 100,
  action: function(){
    var d, h, i$, ref$, len$, ally, results$ = [];
    d = 100;
    h = 0.05;
    if (battle.target.has_buff(buffs.charmed)) {
      d += 20;
      h += 0.05;
    }
    damage_target(d);
    for (i$ = 0, len$ = (ref$ = ally_list()).length; i$ < len$; ++i$) {
      ally = ref$[i$];
      if (ally === battle.actor) {
        continue;
      }
      results$.push(ally.damage(-battle.actor.get_stat('hp') * h, true, battle.actor));
    }
    return results$;
  },
  target: 'enemy',
  attributes: ['arrow', 'heal', 'attack']
};
skills.sabotage = {
  name: "Sabotage",
  sp: 50,
  action: function(){
    battle.target.inflict(buffs.sabotage);
    return damage_target(10);
  },
  target: 'enemy',
  desc: "Sabotages the enemy, greatly lowering their attack for a short time.",
  attributes: ['status'],
  aitarget: function(){
    var enemylist, target, i$, len$, enemy;
    enemylist = enemy_list();
    target = null;
    for (i$ = 0, len$ = enemylist.length; i$ < len$; ++i$) {
      enemy = enemylist[i$];
      if (target) {
        if (enemy.stats.sp_level - enemy.stats.sp > target.stats.sp_level - target.stats.sp) {
          target = enemy;
        }
      } else {
        target = enemy;
      }
    }
    return battle.target = target;
  }
};
skills.seizure = {
  name: "Seizure",
  animation: 'curse',
  sfx: 'groan',
  custom_animation: function(){
    var target, duration, a;
    target = {
      x: battle.target.x,
      y: battle.target.y
    };
    if (battle.target instanceof Battler) {
      target.x += WS * 3;
      target.y += WS * 3;
    }
    duration = 1000;
    a = get_animation();
    a.revive();
    a.loadTexture('solid');
    a.time = 0;
    a.x = target.x;
    a.y = target.y;
    a.update = function(){
      this.time += delta;
      this.rotation = Math.random() * HPI * 4;
      this.width = 32 + Math.random() * 32;
      this.height = 32 + Math.random() * 32;
      this.tint = [0xffffff, 0xff0000, 0x0000ff][Math.random() * 3 | 0];
      if (Date.now() - sound.lastplayedtime > 100) {
        sound.play('strike', true);
        sound.strike._sound.playbackRate.value = 2;
      }
      if (this.time > duration) {
        sound.stop();
        this.tint = 0xffffff;
        this.scale.set(1, 1);
        this.rotation = 0;
        this.update = function(){};
        this.kill();
        process_callbacks(battle.animation.callback);
      }
    };
  },
  sp: 100,
  xp: 10,
  action: function(){
    return battle.target.inflict(buffs.seizure);
  },
  target: 'enemy',
  attributes: ['status', 'magic'],
  desc: "Seizes control of the target's mind, reducing their speed. Does not stack."
};
skills.seizure2 = {
  name: "Flashing Lights",
  animation: 'curse',
  sfx: 'groan',
  custom_animation: function(){
    var duration, a;
    duration = 1750;
    a = get_animation();
    a.revive();
    a.loadTexture('solid');
    a.time = 0;
    a.x = HWIDTH;
    a.y = HHEIGHT;
    a.width = game.width;
    a.height = game.height;
    sound.play('laser');
    a.update = function(){
      this.time += delta;
      this.tint = [0xffffff, 0xff0000, 0x0000ff][Math.random() * 3 | 0];
      this.alpha = Math.random() / 2;
      if (this.time > duration) {
        this.tint = 0xffffff;
        this.scale.set(1, 1);
        this.alpha = 1;
        this.update = function(){};
        this.kill();
        process_callbacks(battle.animation.callback);
      }
    };
  },
  sp: 100,
  xp: 10,
  action: function(){
    var i$, ref$, len$, target, results$ = [];
    for (i$ = 0, len$ = (ref$ = battle.target).length; i$ < len$; ++i$) {
      target = ref$[i$];
      results$.push(target.inflict(buffs.seizure));
    }
    return results$;
  },
  target: 'enemies',
  attributes: ['status', 'magic']
};
skills.devastate = {
  name: "Devastate",
  animation: 'curse',
  sfx: 'groan',
  sp: 100,
  xp: 10,
  action: function(){
    return battle.target.inflict(buffs.aids);
  },
  target: 'enemy',
  attributes: ['status', 'magic'],
  desc: "Devastates the target's immune system, lowering defense to zero.",
  aitarget: function(){
    var enemylist, list, i$, len$, enemy;
    enemylist = enemy_list();
    list = [];
    for (i$ = 0, len$ = enemylist.length; i$ < len$; ++i$) {
      enemy = enemylist[i$];
      if (!enemy.has_buff(buffs['null'])) {
        list.push(enemy);
      }
    }
    if (list.length === 0) {
      list = enemylist;
    }
    return battle.target = list[Math.floor(Math.random() * list.length)];
  }
};
skills.dekopin = {
  name: "Dekopin",
  sp: 100,
  action: function(){
    damage_target(50);
  },
  target: 'enemy',
  attributes: ['attack'],
  desc: "Flicks the target in the forehead, dealing minimal damage.",
  aitarget: function(){
    var enemylist, list, i$, len$, enemy, j$, ref$, len1$, buff;
    enemylist = enemy_list();
    list = [];
    for (i$ = 0, len$ = enemylist.length; i$ < len$; ++i$) {
      enemy = enemylist[i$];
      for (j$ = 0, len1$ = (ref$ = enemy.buffs).length; j$ < len1$; ++j$) {
        buff = ref$[j$];
        if (buff.name === 'aids') {
          list.push(enemy);
        }
      }
    }
    if (list.length === 0) {
      list = enemylist;
    }
    battle.target = list[Math.floor(Math.random() * list.length)];
  }
};
skills.sharepain = {
  name: "Share Pain",
  animation: 'heal',
  sfx: 'itemget',
  sp: 50,
  action: function(){
    var hp;
    hp = (battle.actor.stats.hp + battle.target.stats.hp) / 2;
    battle.target.damage((battle.target.stats.hp - hp) * battle.target.get_stat('hp'), true, battle.actor);
    battle.actor.damage((battle.actor.stats.hp - hp) * battle.actor.get_stat('hp'), true, battle.actor);
  },
  target: 'ally',
  aitarget: function(){
    var allylist, hp, target, i$, len$, ally;
    allylist = ally_list();
    hp = 1;
    target = null;
    for (i$ = 0, len$ = allylist.length; i$ < len$; ++i$) {
      ally = allylist[i$];
      if (ally === battle.actor) {
        continue;
      }
      if (ally.stats.hp < hp) {
        hp = ally.stats.hp;
        target = ally;
      }
    }
    if (target) {
      return battle.target = target;
    }
    return battle.target = battle.actor;
  }
};
skills.twinflight = {
  name: "Twin Flight",
  animation: 'heal',
  sfx: 'itemget',
  sp: 100,
  action: function(){
    battle.target.inflict(buffs.twinflight);
  },
  target: 'ally',
  aitarget: function(){
    var allylist, list, i$, len$, ally;
    allylist = ally_list();
    list = [];
    for (i$ = 0, len$ = allylist.length; i$ < len$; ++i$) {
      ally = allylist[i$];
      if (ally === battle.actor) {
        continue;
      }
      if (ally.has_buff(buffs.twinflight)) {
        continue;
      }
      list.push(ally);
    }
    if (list.length === 0) {
      list = allylist;
    }
    battle.target = list[Math.floor(Math.random() * list.length)];
  }
};
skills.heal = {
  name: "Aurum Vital",
  animation: 'heal',
  sfx: 'itemget',
  sp: 100,
  action: function(){
    return heal_hybrid(50, 25);
  },
  target: 'ally',
  attributes: ['status', 'heal', 'magic'],
  desc: "A strong healing skill.",
  aitarget: function(){
    var allylist, hp, target, i$, len$, ally;
    allylist = ally_list();
    hp = 1;
    target = null;
    for (i$ = 0, len$ = allylist.length; i$ < len$; ++i$) {
      ally = allylist[i$];
      if (ally.stats.hp < hp) {
        hp = ally.stats.hp;
        target = ally;
      }
    }
    if (target) {
      return battle.target = target;
    }
    return battle.target = battle.actor;
  }
};
skills.quickheal = {
  name: "Argent Vital",
  animation: 'heal',
  sfx: 'itemget',
  sp: 50,
  action: function(){
    return heal_hybrid(25, 12.5);
  },
  target: 'ally',
  attributes: ['status', 'heal', 'magic'],
  desc: "A fast healing skill.",
  aitarget: skills.heal.aitarget
};
skills.minorheal = {
  name: "Aes Vital",
  animation: 'heal',
  sfx: 'itemget',
  sp: 80,
  action: function(){
    return heal_hybrid(25, 12.5);
  },
  target: 'ally',
  attributes: ['status', 'heal', 'magic'],
  desc: "A weak healing spell.",
  aitarget: skills.heal.aitarget
};
skills.massheal = {
  name: "Platina Vital",
  animation: 'heal',
  sfx: 'itemget',
  sp: 99,
  action: function(){
    return heal_hybrid(25, 12.5);
  },
  target: 'allies',
  attributes: ['status', 'heal', 'magic'],
  desc: "Heals all allies."
};
skills.healblock = {
  name: "Malus Vital",
  animation: 'heal',
  sfx: 'groan',
  sp: 100,
  action: function(){
    var i$, ref$, len$, target, results$ = [];
    for (i$ = 0, len$ = (ref$ = battle.target).length; i$ < len$; ++i$) {
      target = ref$[i$];
      results$.push(target.inflict(buffs.healblock));
    }
    return results$;
  },
  target: 'enemies',
  attributes: ['status', 'magic'],
  desc: "Prevents the target from being healed, and redirects heals to the user instead."
};
skills.regenerate = {
  name: "Regenerate",
  animation: 'heal',
  sfx: 'itemget',
  sp: 100,
  action: function(){
    return battle.actor.inflict(buffs.regen);
  },
  target: 'self',
  attributes: ['status', 'heal', 'magic'],
  desc: "A slow self-heal that restores all health."
};
skills.clense = {
  name: "Cleanse",
  animation: 'heal',
  sfx: 'itemget',
  sp: 99,
  action: function(){
    var bufflist, i$, ref$, len$, buff;
    bufflist = [];
    for (i$ = 0, len$ = (ref$ = battle.target.buffs).length; i$ < len$; ++i$) {
      buff = ref$[i$];
      if (buff.name !== 'null') {
        bufflist.push(buff);
      }
    }
    if (bufflist.length === 0) {
      return;
    }
    return bufflist[Math.random() * bufflist.length | 0].remedy();
  },
  target: 'ally',
  attributes: ['status', 'magic'],
  desc: "Removes one random effect from an ally.",
  aitarget: function(){
    var allylist, target, highest, i$, len$, ally, negcount, j$, ref$, len1$, buff;
    allylist = ally_list();
    target = null;
    highest = 0;
    for (i$ = 0, len$ = allylist.length; i$ < len$; ++i$) {
      ally = allylist[i$];
      negcount = 0;
      for (j$ = 0, len1$ = (ref$ = ally.buffs).length; j$ < len1$; ++j$) {
        buff = ref$[j$];
        if (buff.negative) {
          negcount++;
        }
      }
      if (negcount > 0) {
        highest = negcount;
        target = ally;
      }
    }
    if (!target) {
      return battle.target = battle.actor;
    }
    return battle.target = target;
  }
};
skills.megaClense = {
  name: "Cleanse Wave",
  animation: 'heal',
  sfx: 'itemget',
  sp: 110,
  ex: 20,
  action: function(){},
  target: 'allies',
  attributes: ['status', 'magic'],
  desc: "Cures all ailments."
};
skills.purge = {
  name: "Purge",
  animation: 'heal',
  sfx: 'itemget',
  sp: 99,
  action: skills.clense.action,
  target: 'enemy',
  attributes: ['status', 'magic'],
  desc: "Removes one random effect from an enemy."
};
skills.cure = {
  name: "Cure",
  animation: 'heal',
  sfx: 'itemget',
  sp: 50,
  action: function(){
    var i$, ref$, len$, buff, results$ = [];
    for (i$ = 0, len$ = (ref$ = battle.target.buffs).length; i$ < len$; ++i$) {
      buff = ref$[i$];
      if (buff.name !== 'coagulate') {
        results$.push(buff.remedy());
      }
    }
    return results$;
  },
  target: 'self',
  attributes: ['status', 'magic'],
  desc: "Cures all ailments."
};
skills.artillery = {
  name: "Artillery Shot",
  animation: 'flame',
  sfx: 'flame',
  sp: 100,
  ex: 50,
  action: function(){
    return damage_target(100);
  },
  target: 'enemy',
  attributes: ['tech', 'attack'],
  desc: "Blasts the target with a shot from a cannon."
};
skills.railCannon = {
  name: "Rail Cannon",
  animation: 'flame',
  sfx: 'flame',
  custom_animation: function(){
    var actor, target, quantity, setanimation, count, i$, i;
    actor = {
      x: battle.actor.x,
      y: battle.actor.y
    };
    target = {
      x: battle.target.x,
      y: battle.target.y
    };
    if (battle.actor instanceof Battler) {
      actor.x += WS * 3;
      actor.y += WS * 3;
    }
    if (battle.target instanceof Battler) {
      target.x += WS * 3;
      target.y += WS * 3;
    }
    quantity = 12;
    setanimation = function(i){
      var a;
      a = get_animation();
      if (i === quantity) {
        a.callback = battle.animation.callback;
      }
      a.play('flame', actor.x + (target.x - actor.x) * (i / quantity), actor.y + (target.y - actor.y) * (i / quantity));
      return sound.play('flame');
    };
    count = 0;
    for (i$ = 0; i$ < quantity; ++i$) {
      i = i$;
      setTimeout(fn$, 100 * i);
    }
    function fn$(){
      return setanimation(++count);
    }
  },
  sp: 200,
  ex: 50,
  action: function(){
    return damage_target(220);
  },
  target: 'enemy',
  attributes: ['tech', 'attack'],
  desc: "Propels a projectile forward at amazing speeds using magnetic force."
};
skills.nuke = {
  name: "Tactical Nuke",
  animation: 'flame',
  sfx: 'flame',
  custom_animation: function(){
    var target, quantity, done, setanimation, count, i$, i, j$, j;
    target = {
      x: battle.target.x,
      y: battle.target.y
    };
    if (battle.target instanceof Battler) {
      target.x += WS * 3;
      target.y += WS * 3;
    }
    quantity = 24;
    done = false;
    setanimation = function(i){
      var a, done, radius, angle;
      a = get_animation();
      if (i === quantity && !done) {
        done = true;
        a.callback = battle.animation.callback;
      }
      radius = WIDTH * i / quantity;
      angle = Phaser.Math.PI2 * Math.random();
      a.play('flame', target.x + Math.sin(angle) * radius, target.y + Math.cos(angle) * radius);
      return sound.play('flame');
    };
    count = 0;
    for (i$ = 0; i$ < quantity; ++i$) {
      i = i$;
      ++count;
      for (j$ = 0; j$ < 6; ++j$) {
        j = j$;
        setTimeout(fn$.bind(this, count), 100 * i);
      }
    }
    function fn$(count){
      return setanimation(count);
    }
  },
  sp: 400,
  ex: 50,
  action: function(){
    var i$, ref$, len$, enemy, ally, results$ = [];
    damage_target(500);
    for (i$ = 0, len$ = (ref$ = enemy_list(true)).length; i$ < len$; ++i$) {
      enemy = ref$[i$];
      if (enemy === battle.target) {
        continue;
      }
      damage(enemy, 100);
    }
    for (i$ = 0, len$ = (ref$ = ally_list(true)).length; i$ < len$; ++i$) {
      ally = ref$[i$];
      results$.push(damage(ally, 15));
    }
    return results$;
  },
  target: 'enemy',
  attributes: ['tech', 'attack'],
  desc: "A super powerful blast. The shockwave damages everyone on the field."
};
skills.flare = {
  name: "Wing Flare",
  animation: 'flame',
  sfx: 'flame',
  sp: 50,
  xp: 10,
  action: function(){
    return battle.target.inflict(buffs.decoy);
  },
  target: 'self',
  attributes: ['status', 'tech'],
  desc: "Makes enemies more likely to attack the user."
};
skills.vbite = {
  name: "Vampire Bite",
  animation: 'slash',
  sp: function(){
    return 100;
  },
  action: function(){
    damage_target(75);
    return heal(battle.actor, Math.round(calc_damage(battle.actor, battle.target, 25)), true);
  },
  target: 'enemy',
  attributes: ['blood', 'attack'],
  desc: "Sucks life out of the enemy."
};
skills.curse = {
  name: "Haunt",
  sfx: 'groan',
  animation: 'curse',
  sp: 50,
  action: function(){
    return battle.target.inflict(buffs.curse);
  },
  target: 'enemy',
  aitarget: function(){
    var enemylist, list, i$, len$, enemy;
    enemylist = enemy_list();
    list = [];
    for (i$ = 0, len$ = enemylist.length; i$ < len$; ++i$) {
      enemy = enemylist[i$];
      if (!enemy.has_buff(buffs.curse)) {
        list.push(enemy);
      }
    }
    if (list.length === 0) {
      list = enemylist;
    }
    return battle.target = list[Math.floor(Math.random() * list.length)];
  },
  weight: 2,
  attributes: ['status', 'magic'],
  desc: "Sends an evil spirit to haunt the target, cutting its max HP."
};
skills.slowness = {
  name: "Slowness",
  action: function(){
    target.inflict(buffs.chill);
  }
};
skills.wanko = {
  name: "Wanko Mayem",
  sfx: 'groan',
  animation: 'curse',
  sp: 100,
  action: function(){
    return battle.target.inflict(buffs.wanko);
  },
  target: 'ally',
  aitarget: function(){
    var allylist, i$, len$, ally;
    allylist = ally_list();
    for (i$ = 0, len$ = allylist.length; i$ < len$; ++i$) {
      ally = allylist[i$];
      if (ally.monstertype === Monster.types.parvo) {
        return battle.target = ally;
      }
    }
    return battle.target = allylist[Math.floor(Math.random() * allylist.length)];
  },
  weight: 3,
  attributes: ['status', 'magic']
};
skills.isolate = {
  name: "Isolate",
  sfx: 'groan',
  animation: 'curse',
  sp: 100,
  action: function(){
    var i$, ref$, len$, target, results$ = [];
    for (i$ = 0, len$ = (ref$ = battle.target).length; i$ < len$; ++i$) {
      target = ref$[i$];
      results$.push(target.inflict(buffs.isolated));
    }
    return results$;
  },
  target: 'enemies',
  attributes: ['status', 'magic']
};
skills.poison = {
  name: 'Poison',
  animation: 'curse',
  sfx: 'groan',
  sp: 100,
  action: function(){
    return battle.target.inflict(buffs.poison);
  },
  target: 'enemy',
  aitarget: function(){
    var enemylist, list, i$, len$, enemy;
    enemylist = enemy_list();
    list = [];
    for (i$ = 0, len$ = enemylist.length; i$ < len$; ++i$) {
      enemy = enemylist[i$];
      if (!enemy.has_buff(buffs.poison)) {
        list.push(enemy);
      }
    }
    if (list.length === 0) {
      list = enemylist;
    }
    return battle.target = list[Math.floor(Math.random() * list.length)];
  },
  weight: 2,
  attributes: ['status', 'magic']
};
skills.poisonwave = {
  name: 'Poison Wave',
  animation: 'curse',
  sfx: 'groan',
  sp: 100,
  action: function(){
    var i$, ref$, len$, target;
    for (i$ = 0, len$ = (ref$ = battle.target).length; i$ < len$; ++i$) {
      target = ref$[i$];
      target.inflict(buffs.poison);
    }
  },
  target: 'enemies',
  attributes: ['status', 'magic']
};
skills.poisonstrike = {
  name: 'Poison Strike',
  sp: 100,
  action: function(){
    if (battle.target.has_buff(buffs.poison)) {
      damage_target(120);
    } else {
      damage_target(60);
      if (battle.actor.luckroll() > 80) {
        battle.target.inflict(buffs.poison);
      }
    }
  },
  target: 'enemy',
  desc: 'Does more damage against poisoned foes.',
  attributes: ['attack']
};
skills.drown = {
  name: 'Rip Current',
  animation: 'water',
  sfx: 'water',
  sp: 100,
  action: function(){
    return battle.target.inflict(buffs.drown);
  },
  target: 'enemy',
  weight: 2,
  attributes: ['status', 'magic']
};
skills.lick = {
  name: 'Lick',
  animation: 'water',
  sfx: 'water',
  sp: 100,
  action: function(){
    damage_target(20);
    return battle.target.inflict(buffs.licked);
  },
  target: 'enemy',
  weight: 2,
  attributes: ['status', 'magic']
};
skills.burn = {
  name: 'Blaze',
  animation: 'flame',
  sfx: 'flame',
  sp: 60,
  action: function(){
    return battle.target.inflict(buffs.burn);
  },
  aitarget: skills.hemorrhage.aitarget,
  target: 'enemy',
  attributes: ['magic', 'fire', 'attack']
};
skills.burn2 = {
  name: 'Char',
  animation: 'flame',
  sfx: 'flame',
  sp: 30,
  action: skills.burn.action,
  aitarget: skills.burn.aitarget,
  target: 'enemy',
  attributes: ['magic', 'fire', 'attack']
};
skills.inferno = {
  name: 'Inferno',
  animation: 'flame',
  custom_animation: skills.hellfire.custom_animation,
  sfx: 'flame',
  sp: 100,
  action: function(){
    var i$, ref$, len$, target, lresult$, j$, ref1$, len1$, buff, results$ = [];
    for (i$ = 0, len$ = (ref$ = battle.target).length; i$ < len$; ++i$) {
      target = ref$[i$];
      lresult$ = [];
      for (j$ = 0, len1$ = (ref1$ = target.buffs).length; j$ < len1$; ++j$) {
        buff = ref1$[j$];
        if (buff.name === 'burn') {
          buff.intensity = 3;
          buff.duration = 1;
          lresult$.push(buff.frame = 2);
        }
      }
      results$.push(lresult$);
    }
    return results$;
  },
  target: 'enemies',
  attributes: ['magic', 'fire', 'status']
};
skills.sarssummon = {
  name: 'Summon',
  sfx: 'groan',
  animation: 'curse',
  sp: 100,
  action: function(){
    var i$, to$, x, results$ = [];
    for (i$ = 0, to$ = monsters.length; i$ < to$; ++i$) {
      x = Math.random() < 0.5
        ? 0
        : WIDTH * 2 / 3;
      results$.push(battle.addmonster(new Monster(x + random_dice(2) * WIDTH / 3, random_dice(2) * HHEIGHT, 'sarssummon', battle.actor.level)));
    }
    return results$;
  },
  target: 'self',
  attributes: ['summon']
};
skills.slimesummon = {
  name: 'Summon',
  sfx: 'groan',
  animation: 'curse',
  sp: 100,
  action: function(){
    var i$, i, x, results$ = [];
    for (i$ = 0; i$ <= 1; ++i$) {
      i = i$;
      x = battle.actor.x + (i * 2 - 1) * WIDTH / 4;
      results$.push(battle.addmonster(new Monster(x, battle.actor.y, 'slime2', battle.actor.level)));
    }
    return results$;
  },
  target: 'self',
  attributes: ['summon']
};
skills.lepsysummon = {
  name: 'Summon',
  sfx: 'groan',
  animation: 'curse',
  sp: 100,
  action: function(){
    var i$, i, x, results$ = [];
    for (i$ = 0; i$ <= 1; ++i$) {
      i = i$;
      x = battle.actor.x + (i * 2 - 1) * WIDTH / 4;
      results$.push(battle.addmonster(new Monster(x, battle.actor.y, 'polyduck', battle.actor.level)));
    }
    return results$;
  },
  target: 'self',
  attributes: ['summon']
};
skills.parvosummon = {
  name: 'Summon',
  sfx: 'groan',
  animation: 'curse',
  sp: 100,
  action: function(){
    var i$, i, x, results$ = [];
    for (i$ = 0; i$ <= 1; ++i$) {
      i = i$;
      x = battle.actor.x + (i * 2 - 1) * WIDTH / 4;
      results$.push(battle.addmonster(new Monster(x, battle.actor.y, 'doggie', battle.actor.level)));
    }
    return results$;
  },
  target: 'self',
  attributes: ['summon']
};
skills.martingale = {
  name: 'Martingale',
  sp: 100,
  delay: 0,
  action: function(){
    if (battle.lastskillhero !== skills.martingale || battle.actor.lastskill !== skills.martingale) {
      skills.martingale.delay = 0;
    }
    if (battle.actor.luckroll() < 0.66) {
      return skills.martingale.delay++;
    } else {
      damage_target(100 + 100 * skills.martingale.delay * 2);
      return skills.martingale.delay = 0;
    }
  },
  target: 'enemy',
  desc: "Has a chance of being delayed, and becomes more powerful each time it is."
};
skills.trickortreat = {
  name: 'Tricker Treat',
  desc: "Randomly grants some effect to an ally or enemy."
};
skills.joki_thief = {
  name: 'Thief',
  sfx: 'groan',
  animation: 'curse',
  custom_animation: function(){
    var origin, itemorigin;
    battle.monstergroup.bringToTop(battle.actor);
    origin = {
      x: battle.actor.x,
      y: battle.actor.y
    };
    itemorigin = {
      x: battle.target.item.x,
      y: battle.target.item.y
    };
    if (battle.target.item.base !== buffs['null']) {
      battle.target.originalitem = battle.target.item.base;
    }
    Transition.move(battle.actor, battle.target, 1000, function(){
      Transition.move(battle.target.item, battle.actor.item, 500, function(){
        battle.target.item.x = itemorigin.x;
        battle.target.item.y = itemorigin.y;
        battle.actor.item.load_buff(battle.target.item.base);
        battle.target.item.load_buff(buffs['null']);
        Transition.move(battle.actor, origin, 1000, function(){
          battle.monstergroup.sort('x', Phaser.Group.SORT_DESCENDING);
          process_callbacks(battle.animation.callback);
        });
      });
    });
  },
  sp: 100,
  target: 'enemy',
  aitarget: function(){
    var enemylist, list, i$, len$, enemy;
    enemylist = enemy_list();
    list = [];
    for (i$ = 0, len$ = enemylist.length; i$ < len$; ++i$) {
      enemy = enemylist[i$];
      if (enemy.item.base !== buffs['null']) {
        list.push(enemy);
      }
    }
    if (list.length === 0) {
      list = enemylist;
    }
    return battle.target = list[Math.floor(Math.random() * list.length)];
  }
};
skills.joki_split = {
  name: 'Split',
  sfx: 'groan',
  animation: 'curse',
  sp: 100,
  target: 'self',
  custom_animation: function(){
    var i$;
    for (i$ = monsters.length; i$ <= 3; ++i$) {
      battle.addmonster(new Monster(battle.actor.x, battle.actor.y, 'jokiclone', battle.actor.level));
    }
    skills.joki_shuffle.custom_animation();
  }
};
skills.joki_shuffle = {
  name: 'Shuffle',
  sfx: 'groan',
  animation: 'curse',
  weight: 1,
  sp: 100,
  target: 'self',
  custom_animation: function(){
    var pos, itemlist, i$, ref$, len$, monster, i;
    shuffle(monsters);
    shuffle(battle.monstergroup.children);
    pos = [
      {
        x: HWIDTH + 7.5 * WS,
        y: HHEIGHT - 1 * WS
      }, {
        x: HWIDTH + 2.5 * WS,
        y: HHEIGHT - 2 * WS
      }, {
        x: HWIDTH - 2.5 * WS,
        y: HHEIGHT - 2 * WS
      }, {
        x: HWIDTH - 7.5 * WS,
        y: HHEIGHT - 1 * WS
      }
    ];
    itemlist = [];
    for (i$ = 0, len$ = (ref$ = monsters).length; i$ < len$; ++i$) {
      monster = ref$[i$];
      itemlist.push(monster.item.base);
    }
    shuffle(itemlist);
    for (i$ = 0, len$ = (ref$ = monsters).length; i$ < len$; ++i$) {
      i = i$;
      monster = ref$[i$];
      monster.item.load_buff(itemlist[i]);
      monster.item.visible = false;
      Transition.move(monster, pos[i], 2000, fn$);
    }
    function fn$(){
      if (this.item.alive) {
        this.item.visible = true;
      }
      if (this === monsters[0]) {
        battle.monstergroup.sort('x', Phaser.Group.SORT_DESCENDING);
        process_callbacks(battle.animation.callback);
      }
    }
  }
};
skills.shroud = {
  name: "Shroud",
  sfx: 'groan',
  animation: 'curse',
  weight: 1,
  sp: 100,
  target: 'allies',
  action: function(){
    var i$, ref$, len$, target;
    for (i$ = 0, len$ = (ref$ = battle.target).length; i$ < len$; ++i$) {
      target = ref$[i$];
      target.inflict(buffs.obscure);
    }
  }
};
for (key in skills) {
  properties = skills[key];
  skills[key] = new Skill(properties);
  skills[key].id = key;
}
skillbook = {
  all: []
};
function create_skillbook(){
  var i$, ref$, len$, p, f;
  skillbook = {
    all: []
  };
  for (i$ = 0, len$ = (ref$ = players).length; i$ < len$; ++i$) {
    p = ref$[i$];
    skillbook[p.name] = {};
    for (f in formes[p.name]) {
      skillbook[p.name][f] = [];
    }
    skillbook[p.name].all = [];
  }
}
function distance(p1, p2){
  return Math.sqrt(Math.pow(p2.x - p1.x, 2) + Math.pow(p2.y - p1.y, 2));
}
function manhattan(p1, p2){
  return Math.abs(p2.x - p1.x) + Math.abs(p2.y - p1.y);
}
function normalize(v){
  var dist;
  dist = distance({
    x: 0,
    y: 0
  }, v);
  if (dist === 0) {
    return {
      x: 0,
      y: 0
    };
  } else {
    return {
      x: v.x / dist,
      y: v.y / dist
    };
  }
}
function rand(seed){
  var t;
  if (seed != null) {
    rand.seed = seed;
  }
  return (t = Math.sin(rand.seed++) * 1000) - Math.floor(t);
}
rand.seed = 1;
function angleDEG(p1, p2){
  var a;
  a = Math.atan2(p2.y - p1.y, p2.x - p1.x) * 180 / Math.PI;
  return a < 0 ? a + 360 : a;
}
function angleRAD(p1, p2){
  var a;
  a = Math.atan2(p2.y - p1.y, p2.x - p1.x);
  return a < 0 ? a + Math.PI * 2 : a;
}
DEGtoRAD = function(a){
  return a * Math.PI / 180;
};
RADtoDEG = function(a){
  return a * 180 / Math.PI;
};
function rect_collision(r1, r2){
  return r1.x < r2.x + r2.w && r1.x + r1.w > r2.x && r1.y < r2.y + r2.h && r1.y + r1.h > r2.y;
}
function point_in_rect(point, x, y, w, h){
  return point.x < x + w && point.x > x && point.y < y + h && point.y > y;
}
function point_in_body(point, body){
  return point.x < body.x + body.width && point.x > body.x && point.y < body.y + body.height && point.y > body.y;
}
function point_in_sprite(point, sprite){
  var rect;
  rect = {
    x: sprite.world.x - sprite.anchor.x * sprite.width,
    y: sprite.world.y - sprite.anchor.y * sprite.height,
    width: sprite.width,
    height: sprite.height
  };
  return point_in_body(point, rect);
}
function body_to_rect(body){
  return {
    x: body.position.x - body.tilePadding.x,
    y: body.position.y - body.tilePadding.y,
    w: body.width + body.tilePadding.x,
    h: body.height + body.tilePadding.y
  };
}
function body_radius(body){
  return Math.sqrt(Math.pow(body.width, 2) + Math.pow(body.height, 2)) / 2;
}
function body_diameter(body){
  return Math.sqrt(Math.pow(body.width, 2) + Math.pow(body.height, 2));
}
function body_collision(b1, b2, o){
  o == null && (o = {
    x: 0,
    y: 0
  });
  return rect_collision({
    x: b1.x + o.x,
    y: b1.y + o.y,
    w: b1.width + o.x,
    h: b1.height + o.y
  }, {
    x: b2.x,
    y: b2.y,
    w: b2.width,
    h: b2.height
  });
}
/* #Was used for pathfinding. Now unused
compare_field = (f,a,b)-->
    return -1 if a[f] < b[f]
    return 1 if a[f] > b[f]
    return 0
    
*/
function breakLines3(string, lineWidth, font){
  var chars, spacewidth, text, olines, i$, len$, l, lwidth, nline, words, j$, len1$, w, wwidth, warray, k$, len2$, i, char;
  if (lineWidth === 0) {
    return string;
  }
  chars = game.cache.getBitmapFont(font).font.chars;
  spacewidth = chars[' '.codePointAt(0)].xAdvance;
  lineWidth *= FW;
  text = '';
  olines = string.split('\n');
  for (i$ = 0, len$ = olines.length; i$ < len$; ++i$) {
    l = olines[i$];
    lwidth = 0;
    nline = '';
    words = l.split(' ');
    for (j$ = 0, len1$ = words.length; j$ < len1$; ++j$) {
      w = words[j$];
      wwidth = 0;
      warray = Array.from
        ? Array.from(w)
        : w.split('');
      for (k$ = 0, len2$ = warray.length; k$ < len2$; ++k$) {
        i = k$;
        char = chars[warray[i].codePointAt(0)];
        if (char) {
          wwidth += char.xAdvance;
        }
      }
      if (lwidth + wwidth <= lineWidth) {
        nline += w + ' ';
        lwidth += wwidth + spacewidth;
      } else if (wwidth > lineWidth) {
        while (warray.length) {
          char = chars[warray[0].codePointAt(0)];
          wwidth = char ? char.xAdvance : 0;
          if (lwidth + wwidth <= lineWidth) {
            nline += warray.shift();
            lwidth += wwidth;
          } else {
            text += nline + '\n';
            nline = '';
            lwidth = 0;
          }
        }
        nline += ' ';
        lwidth += spacewidth;
      } else {
        text += nline + '\n';
        nline = w + ' ';
        lwidth = wwidth + spacewidth;
      }
    }
    text += nline + '\n';
  }
  return text.trimRight();
}
function shuffle(a){
  var i$, to$, i, j, t;
  for (i$ = 0, to$ = a.length; i$ < to$; ++i$) {
    i = i$;
    j = Math.floor(Math.random() * a.length);
    t = a[i];
    a[i] = a[j];
    a[j] = t;
  }
  return a;
}
function getCachedImage(key){
  return game.cache.getImage(key, true);
}
function charlen(char, font){
  font == null && (font = 'unifont');
  char = game.cache.getBitmapFont(font).font.chars[char.codePointAt(0)];
  return char ? char.xAdvance : 0;
}
function random_dice(dice){
  var ret, i$;
  dice == null && (dice = 1);
  ret = 0;
  for (i$ = 0; i$ < dice; ++i$) {
    ret += Math.random();
  }
  return ret / dice;
}
function process_callbacks(c){
  var i$, len$, callback;
  if (c instanceof Array) {
    for (i$ = 0, len$ = c.length; i$ < len$; ++i$) {
      callback = c[i$];
      process_callback.call(this, callback);
    }
  } else {
    return process_callback.call(this, c);
  }
  function process_callback(c){
    if (typeof c === 'function') {
      return c.call(this);
    } else if (c && typeof c === 'object') {
      return c.callback.apply(c.context || this, c.arguments || []);
    }
  }
}
function access(property){
  var args, res$, i$, to$;
  res$ = [];
  for (i$ = 1, to$ = arguments.length; i$ < to$; ++i$) {
    res$.push(arguments[i$]);
  }
  args = res$;
  if (typeof property === 'function') {
    return property.apply(this, args);
  }
  return property;
}
function accessor(object, property){
  return {
    object: object,
    property: property,
    get: function(){
      return this.object[this.property];
    },
    set: function(v){
      this.object[this.property] = v;
    }
  };
}
function callfor(a, f){
  var args, res$, i$, to$, ret, len$, o;
  res$ = [];
  for (i$ = 2, to$ = arguments.length; i$ < to$; ++i$) {
    res$.push(arguments[i$]);
  }
  args = res$;
  if (a instanceof Array) {
    ret = false;
    for (i$ = 0, len$ = a.length; i$ < len$; ++i$) {
      o = a[i$];
      if (typeof f === 'function') {
        if (f.apply(o, args)) {
          ret = true;
        }
      } else {
        if (o[f].apply(o, args)) {
          ret = true;
        }
      }
    }
    return ret;
  } else {
    if (typeof f === 'function') {
      return f.apply(a, args);
    } else {
      return a[f].apply(a, args);
    }
  }
}
function calltarget(){
  Array.prototype.unshift.call(arguments, battle.target);
  callfor.apply(this, arguments);
}
function implement(obj, src){
  var key;
  for (key in src) {
    if (obj[key] != null) {
      console.warn("Key " + key + " already exists on object. Skipping.");
      continue;
    }
    if (typeof src[key] === 'object') {
      obj[key] = JSON.parse(JSON.stringify(src[key]));
    } else {
      obj[key] = src[key];
    }
  }
}
function clone(obj){
  return JSON.parse(JSON.stringify(obj));
}
function construct(constructor, args){
  function CONSTRUCT(){
    return constructor.apply(this, args);
  }
  CONSTRUCT.prototype = constructor.prototype;
  return new CONSTRUCT;
}
function batchload(data, dir, type){
  var i$, len$, argl, j$, ref$, len1$, i, part;
  dir == null && (dir = '');
  type == null && (type = 'image');
  for (i$ = 0, len$ = data.length; i$ < len$; ++i$) {
    argl = data[i$];
    if (argl[1] instanceof Array) {
      for (j$ = 0, len1$ = (ref$ = argl[1]).length; j$ < len1$; ++j$) {
        i = j$;
        part = ref$[j$];
        argl[1][i] = dir + part;
      }
    } else {
      argl[1] = dir + argl[1];
    }
    game.load[type].apply(game.load, argl);
  }
}
function batchload_battler(){
  var args, i$, len$, battler, j$, len1$, i, data, name, k$, forme, costume;
  args = [];
  for (i$ = 0, len$ = (arguments).length; i$ < len$; ++i$) {
    battler = (arguments)[i$];
    for (j$ = 0, len1$ = battler.length; j$ < len1$; ++j$) {
      i = j$;
      data = battler[j$];
      if (i === 0) {
        name = data;
        args.push([name + "_battle", name + ".png"]);
        for (k$ = 1; k$ <= 2; ++k$) {
          forme = k$;
          args.push([name + "_battle_" + forme, name + "_" + forme + ".png"]);
        }
      } else {
        if (typeof data === 'object') {
          for (costume in data) {
            forme = data[costume];
            args.push([name + "_battle_" + costume, name + "_" + costume + ".png"]);
            if (forme > 0) {
              args.push([name + "_battle_" + costume + "_" + forme, name + "_" + costume + "_" + forme + ".png"]);
            }
            if (typeof forme === 'string') {
              args.push([name + "_battle_" + costume + "_1", name + "_" + costume + "_1.png"]);
              args.push([name + "_battle_" + costume + "_2", name + "_" + costume + "_2.png"]);
            }
          }
        } else {
          args.push([name + "_battle_" + n, name + "_" + n + ".png"]);
          for (k$ = 1; k$ <= 2; ++k$) {
            forme = k$;
            args.push([name + "_battle_" + data + "_" + forme, name + "_" + data + "_" + forme + ".png"]);
          }
        }
      }
    }
  }
  batchload.call(this, args, 'img/battle/');
}
function pad(padding, string, padleft){
  if (!string) {
    return padding;
  }
  if (padleft) {
    return (padding + string).slice(-padding.length);
  } else {
    return (string + padding).substring(0, padding.length);
  }
}
function reset_treasure(){
  var key, ref$, value;
  for (key in ref$ = switches) {
    value = ref$[key];
    if (key.indexOf("treasure_") > -1) {
      delete switches[key];
    }
  }
}
function require_switch(s){
  if (!s.properties) {
    return true;
  }
  if (s.properties.off_switch && switches[s.properties.off_switch] || s.properties.require_switch && !switches[s.properties.require_switch]) {
    return false;
  }
  return true;
}
function setrow(o, r){
  var w, h;
  if (!o.key) {
    return;
  }
  w = getCachedImage(o.key).frameWidth || o.texture.width;
  h = getCachedImage(o.key).frameHeight || o.texture.height;
  o.crop({
    x: 0,
    y: r * h,
    width: w,
    height: h
  });
}
function override(o, n){
  return function(){
    o.apply(this, arguments);
    return n.apply(this, arguments);
  };
}
function override_before(o, n){
  return function(){
    n.apply(this, arguments);
    return o.apply(this, arguments);
  };
}
tl.dictionary = {};
function tl(t){
  var i$, to$, i;
  if (tl.dictionary[t] != null) {
    t = tl.dictionary[t];
  }
  for (i$ = 1, to$ = arguments.length; i$ < to$; ++i$) {
    i = i$;
    t = t.replace(new RegExp("\\{" + (i - 1) + "\\}", 'g'), arguments[i]);
  }
  return t;
}
function tle(t){
  var i$, to$, i;
  if (tl.dictionary[t] != null) {
    t = escapeHtml(tl.dictionary[t]);
  }
  for (i$ = 1, to$ = arguments.length; i$ < to$; ++i$) {
    i = i$;
    t = t.replace(new RegExp("\\{" + (i - 1) + "\\}", 'g'), arguments[i]);
  }
  return t;
}
function escapeHtml(t){
  var div;
  (div = document.createElement('div')).appendChild(document.createTextNode(t));
  return div.innerHTML;
}
function unifywidth(s){
  s = s.replace(/[\uff01-\uff5e]/g, function(ch){
    return String.fromCharCode(ch.charCodeAt(0) - 0xfee0);
  });
  return s;
}
function xpToLevel(xp){
  return Math.floor(-4 + Math.sqrt(25 + xp));
}
function levelToXp(level){
  return Math.pow(level, 2) + 8 * level - 9;
}
function calc_stat(level, base_stat, mult){
  mult == null && (mult = 1.11);
  return (-base_stat / mult) * Math.pow(2, -0.03 * level) + base_stat;
}
/*
function linear_calc_stat (level, base_stat)
    base_stat /= 7
    #base_stat * Math.pow(level,0.5) + base_stat
    base_stat * level + base_stat / level
*/
function new_calc_stat(level, base_stat){
  base_stat /= 100;
  return (Math.pow(level, 1.5) + 5 * level + 20) * base_stat;
}
/*
function new_calc_stat (level, base_stat)
    base_stat /= 100
    (level*level + 7*level + 20)*base_stat
*/
function xp_needed(level){
  return levelToXp(level + 1) - levelToXp(level);
}
function xp_process(actor, skill, target){
  var xpn, xpa, ref$, ref1$;
  xpn = xp_needed(actor.level);
  xpa = (ref$ = xpn * skill.xp) < (ref1$ = target.xpwell) ? ref$ : ref1$;
  target.xpwell -= xpa;
  return actor.reward_xp(xpa);
}
function luckroll(){
  return Math.pow(Math.random(), 100 / this.get_stat('luck'));
}
pluckroll = pluckroll_leader;
function pluckroll_average(){
  var lucktotal, i$, ref$, len$, p;
  lucktotal = 0;
  for (i$ = 0, len$ = (ref$ = party).length; i$ < len$; ++i$) {
    p = ref$[i$];
    lucktotal += p.get_stat('luck');
  }
  return Math.pow(Math.random(), 100 * party.length / lucktotal);
}
function pluckroll_leader(){
  return player.luckroll();
}
function pluckroll_highest(){
  var highestluck, i$, ref$, len$, p, ref1$;
  highestluck = 1;
  for (i$ = 0, len$ = (ref$ = party).length; i$ < len$; ++i$) {
    p = ref$[i$];
    highestluck = (ref1$ = p.get_stat('luck')) > highestluck ? ref1$ : highestluck;
  }
  return Math.pow(Math.random(), 100 / highestluck);
}
function pluckroll_battle(){
  var highestluck, i$, ref$, len$, p, ref1$;
  highestluck = 1;
  for (i$ = 0, len$ = (ref$ = heroes).length; i$ < len$; ++i$) {
    p = ref$[i$];
    if (!p.alive) {
      continue;
    }
    highestluck = (ref1$ = p.get_stat('luck')) > highestluck ? ref1$ : highestluck;
  }
  return Math.pow(Math.random(), 100 / highestluck);
}
function pluckroll_gamble(){
  var luck;
  luck = 100;
  if (player.equip !== buffs['null'] && player.equip.mod_luck != null) {
    luck = player.equip.mod_luck(luck);
  }
  return Math.pow(Math.random(), 100 / luck);
}
function stattext(num, digits){
  var fin, places, i$, char;
  num = Math.ceil(num).toString();
  fin = num;
  if (num.length > digits && num.length >= 4) {
    fin = num.substr(0, num.length - 3) + 'K';
    if (fin.length > digits && num.length >= 7) {
      fin = num.substr(0, num.length - 6);
      places = digits - (fin.length + 2);
      if (places > 0) {
        places = num.substr(num.length - 6, places);
        for (i$ = places.length - 1; i$ >= 0; --i$) {
          char = places[i$];
          if (char === '0') {
            places = places.slice(0, -1);
          } else {
            break;
          }
        }
        if (places.length > 0) {
          fin += '.' + places;
        }
      }
      fin += 'M';
    }
  }
  return fin;
}
function hpstattext(hp, max, digits){
  var budget, digits2, ref$, slash;
  budget = digits * 2;
  digits2 = (ref$ = budget - Math.ceil(hp).toString().length) > digits ? ref$ : digits;
  digits = budget - digits2;
  hp = stattext(hp, digits);
  max = stattext(max, digits2);
  slash = hp.length + max.length <= budget - 2 ? ' / ' : '/';
  return hp + slash + max;
}
function levelrange_old(l1, l2){
  var rl, dif, nl;
  rl = Math.round(Math.random() * (l2 - l1) + l1);
  dif = (averagelevel() - rl) / 2;
  nl = rl + Math.ceil(Math.abs(dif)) * Math.sign(dif);
  return Math.min(Math.max(nl, l1), l2);
}
function levelrange(l1, l2){
  var ref$, ref1$;
  if (switches.beat_game) {
    return averagelevel();
  }
  return (ref$ = l1 > (ref1$ = averagelevel()) ? l1 : ref1$) < l2 ? ref$ : l2;
}
function averagelevel(){
  var totallevel, i$, ref$, len$, p;
  totallevel = 0;
  for (i$ = 0, len$ = (ref$ = party).length; i$ < len$; ++i$) {
    p = ref$[i$];
    totallevel += p.level;
  }
  return Math.round(totallevel / party.length);
}
function warn(){
  console.warn.apply(console, arguments);
}
function log(){
  console.log.apply(console, arguments);
}
function togray(color){
  var c;
  c = breakcolor(color);
  c.r = c.g = c.b = (c.r + c.g + c.b) / 3;
  return makecolor(c);
}
function oldmultcolor(color, mult){
  return (color & 0xff0000) * mult | (color & 0x00ff00) * mult | (color & 0x0000ff) * mult;
}
function breakcolor(color, power){
  var rgb;
  rgb = {
    r: (color & 0xff0000) >> 16,
    g: (color & 0x00ff00) >> 8,
    b: color & 0x0000ff
  };
  if (power) {
    rgb.r = rgb.r * rgb.r;
    rgb.g = rgb.g * rgb.g;
    rgb.b = rgb.b * rgb.b;
  }
  return rgb;
}
function makecolor(rgb, power){
  if (power) {
    rgb.r = Math.sqrt(rgb.r);
    rgb.g = Math.sqrt(rgb.g);
    rgb.b = Math.sqrt(rgb.b);
  }
  return rgb.r << 16 | rgb.g << 8 | rgb.b;
}
function gradient(color1, color2, i, power){
  var color3, c;
  power == null && (power = true);
  color1 = breakcolor(color1, power);
  color2 = breakcolor(color2, power);
  color3 = {
    r: 0,
    g: 0,
    b: 0
  };
  for (c in color3) {
    color3[c] = (color2[c] - color1[c]) * i + color1[c];
  }
  return makecolor(color3, power);
}
function recolormonster(sprite){
  var ref$;
  if ((ref$ = sprite.monstertype) != null && ref$.pal) {
    recolormonster1(sprite);
  } else {
    if (battle.encounter.toughness > 0) {
      recolormonster2(sprite);
    }
    if (battle.encounter.toughness > 1) {
      recolormonster2(sprite);
    }
  }
  if (typeof sprite.animate == 'function') {
    sprite.animate();
  }
}
function recolormonster1(sprite){
  var colors, colors2, bmd, i$, len$, i, c, c2;
  if (battle.encounter.toughness === 0 && !sprite.monstertype.pal1) {
    return;
  }
  colors = sprite.monstertype.pal;
  colors2 = sprite.monstertype[battle.encounter.toughness > 1
    ? 'pal3'
    : battle.encounter.toughness > 0 ? 'pal2' : 'pal1'];
  bmd = game.make.bitmapData(sprite.texture.baseTexture.width, sprite.texture.baseTexture.height);
  bmd.draw(sprite.texture.baseTexture.source, 0, 0);
  bmd.update();
  for (i$ = 0, len$ = colors.length; i$ < len$; ++i$) {
    i = i$;
    c = colors[i$];
    c2 = colors2[i];
    bmd.replaceRGB(c >> 16, c >> 8 & 255, c & 255, 255, c2 >> 16, c2 >> 8 & 255, c2 & 255, 255);
  }
  bmd.frameData = sprite.animations.frameData;
  sprite.loadTexture(bmd);
}
function recolormonster2(sprite){
  var colors, bmd, i$, to$, x, j$, to1$, y, c, color, len$;
  colors = [];
  bmd = game.make.bitmapData(sprite.texture.baseTexture.width, sprite.texture.baseTexture.height);
  bmd.draw(sprite.texture.baseTexture.source, 0, 0);
  bmd.update();
  for (i$ = 0, to$ = bmd.width; i$ < to$; ++i$) {
    x = i$;
    for (j$ = 0, to1$ = bmd.height; j$ < to1$; ++j$) {
      y = j$;
      c = bmd.getPixel(x, y);
      if (c.a === 0) {
        continue;
      }
      if (colors.indexOf(color = (c.r << 16) + (c.g << 8) + c.b) === -1) {
        colors.push(color);
      }
    }
  }
  for (i$ = 0, len$ = colors.length; i$ < len$; ++i$) {
    c = colors[i$];
    bmd.replaceRGB(c >> 16, c >> 8 & 255, c & 255, 255, c >> 8 & 255, c & 255, c >> 16, 255);
  }
  bmd.frameData = sprite.animations.frameData;
  sprite.loadTexture(bmd);
}
function recolor(sprite, colors1, colors2){
  var bmd, i$, len$, i, c, c2;
  bmd = game.make.bitmapData(sprite.width, sprite.height);
  bmd.draw(sprite.texture.baseTexture.source, 0, 0);
  bmd.update();
  for (i$ = 0, len$ = colors1.length; i$ < len$; ++i$) {
    i = i$;
    c = colors1[i$];
    c2 = colors2[i];
    bmd.replaceRGB(c >> 16, c >> 8 & 255, c & 255, 255, c2 >> 16, c2 >> 8 & 255, c2 & 255, 255);
  }
  sprite.loadTexture(bmd);
}
function setswitch(key, value, nosave){
  nosave == null && (nosave = false);
  switches[key] = value;
  if (!nosave) {
    save();
  }
}
function dyslexia(string){
  var e;
  try {
    JSON.parse(string);
  } catch (e$) {
    e = e$;
    string = String.fromCharCode.apply(this, string.split('').map(function(a){
      return a.charCodeAt() ^ 255;
    }));
  }
  return string;
}
function saveHandler(key, value){
  var e;
  try {
    localStorage.setItem(key, value);
  } catch (e$) {
    e = e$;
    (session.localStorageError ? warn : alert)("The game could not be saved!\n" + e.message);
    session.localStorageError = true;
  }
}
saveslug = "filosis";
function save(name, force){
  name == null && (name = switches.name);
  if (switches.nosave && !force || !switches.started) {
    return;
  }
  if (game.state.current === 'battle') {
    return;
  }
  console.log("Saved!");
  setFile(name);
  saveHandler(saveslug + "_" + name, dyslexia(saveString()));
  save_options();
}
function battlesave(name, force){
  name == null && (name = switches.name);
  if (switches.nosave && !force || !switches.started) {
    return;
  }
  console.log("Saved!");
  setFile(name);
  saveHandler(saveslug + "_" + name, dyslexia(saveString()));
  save_options();
}
function loadString(name){
  name == null && (name = switches.name);
  return dyslexia(localStorage.getItem(saveslug + "_" + name));
}
function getFiles(){
  var file;
  if (file = localStorage.getItem(saveslug + "-files")) {
    file = dyslexia(file);
  } else {
    file = '{}';
  }
  return JSON.parse(file);
}
function setFile(name){
  var files, file, i$, ref$, len$, p;
  files = getFiles();
  file = {
    party: []
  };
  for (i$ = 0, len$ = (ref$ = party).length; i$ < len$; ++i$) {
    p = ref$[i$];
    file.party.push({
      name: p.name,
      xp: p.stats.xp,
      item: p.equip.id,
      costume: p.costume
    });
  }
  files[name] = file;
  saveHandler(saveslug + "-files", dyslexia(JSON.stringify(files)));
}
function deleteFile(name){
  var files;
  files = getFiles();
  delete files[name];
  localStorage.removeItem(saveslug + "_" + name);
  saveHandler(saveslug + "-files", dyslexia(JSON.stringify(files)));
}
save_options_mod = [];
load_options_mod = [];
function save_options(){
  var options, i$, ref$, len$, f;
  options = {
    sound: sound.volume,
    music: music.volume,
    menusound: menusound.volume,
    voicesound: voicesound.volume,
    textspeed: gameOptions.textspeed,
    battlemessages: gameOptions.battlemessages,
    pauseidle: gameOptions.pauseidle,
    exactscaling: gameOptions.exactscaling
  };
  for (i$ = 0, len$ = (ref$ = save_options_mod).length; i$ < len$; ++i$) {
    f = ref$[i$];
    if (typeof f === 'function') {
      f(options);
    }
  }
  saveHandler(saveslug + "-options", JSON.stringify(options));
}
function load_options(){
  var options, i$, ref$, len$, f;
  if (!(options = localStorage.getItem(saveslug + "-options"))) {
    return;
  }
  options = JSON.parse(options);
  sound.volume = options.sound;
  music.volume = options.music;
  if (options.menusound != null) {
    menusound.volume = options.menusound;
  }
  if (options.voicesound != null) {
    voicesound.volume = options.voicesound;
  }
  if (options.textspeed != null) {
    gameOptions.textspeed = options.textspeed;
  }
  gameOptions.battlemessages = options.battlemessages;
  if (options.pauseidle != null) {
    game.stage.disableVisibilityChange = !(gameOptions.pauseidle = options.pauseidle);
  }
  gameOptions.exactscaling = options.exactscaling;
  for (i$ = 0, len$ = (ref$ = load_options_mod).length; i$ < len$; ++i$) {
    f = ref$[i$];
    if (typeof f === 'function') {
      f(options);
    }
  }
}
gameOptions = {
  battlemessages: true,
  pauseidle: false,
  textspeed: 67,
  exactscaling: false,
  language: '',
  gameSpeed: 1
};
function saveString(){
  var file, i$, ref$, len$, skill, p, j$, ref1$, len1$, f, i, key;
  file = {};
  file.players = {};
  file.skills = {
    all: []
  };
  for (i$ = 0, len$ = (ref$ = skillbook.all).length; i$ < len$; ++i$) {
    skill = ref$[i$];
    file.skills.all.push(skill.id);
  }
  for (i$ = 0, len$ = (ref$ = players).length; i$ < len$; ++i$) {
    p = ref$[i$];
    file.players[p.name] = {};
    file.players[p.name].xp = p.stats.xp;
    file.players[p.name].equip = p.equip.id;
    file.players[p.name].skills = {};
    file.players[p.name].costume = p.costume;
    file.skills[p.name] = {
      all: []
    };
    for (j$ = 0, len1$ = (ref1$ = skillbook[p.name].all).length; j$ < len1$; ++j$) {
      skill = ref1$[j$];
      file.skills[p.name].all.push(skill.id);
    }
    for (f in p.skills) {
      file.players[p.name].skills[f] = [];
      for (j$ = 0, len1$ = (ref1$ = p.skills[f]).length; j$ < len1$; ++j$) {
        skill = ref1$[j$];
        file.players[p.name].skills[f].push(skill.id);
      }
      file.skills[p.name][f] = [];
      for (j$ = 0, len1$ = (ref1$ = skillbook[p.name][f]).length; j$ < len1$; ++j$) {
        skill = ref1$[j$];
        file.skills[p.name][f].push(skill.id);
      }
    }
    file.players[p.name].formes = {};
    for (f in formes[p.name]) {
      if (f !== 'default') {
        file.players[p.name].formes[f] = formes[p.name][f].unlocked;
      }
    }
  }
  file.party = [];
  for (i$ = 0, len$ = (ref$ = party).length; i$ < len$; ++i$) {
    p = ref$[i$];
    file.party.push(p.name);
  }
  file.items = {};
  for (i in items) {
    if (items[i].quantity > 0) {
      file.items[i] = {
        q: items[i].quantity,
        t: items[i].time
      };
    }
  }
  file.switches = {};
  for (key in switches) {
    if (!in$(key, nosave_switches)) {
      file.switches[key] = switches[key];
    }
  }
  return JSON.stringify(file);
}
nosave_switches = ['cinema', 'cinema2', 'portal', 'spawning', 'noclip', 'nomusic', 'loadgame', 'newgame'];
function load(name){
  var file, i$, ref$, len$, s, p, pp, fp, that, f, i, oldswitches;
  if (load.clicked) {
    return;
  }
  switches.loadgame = true;
  create_actors();
  create_mobs();
  file = JSON.parse(loadString(name));
  for (i$ = 0, len$ = (ref$ = file.skills.all).length; i$ < len$; ++i$) {
    s = ref$[i$];
    skillbook.all.push(skills[s]);
  }
  for (p in file.players) {
    pp = players[p];
    fp = file.players[p];
    if (!pp) {
      continue;
    }
    pp.set_xp(fp.xp, true);
    if (that = fp.equip) {
      pp.equip = items[that];
      items[that].equip = pp;
    }
    for (i$ = 0, len$ = (ref$ = file.skills[p].all).length; i$ < len$; ++i$) {
      s = ref$[i$];
      if (!skills[s]) {
        continue;
      }
      skillbook[p].all.push(skills[s]);
    }
    for (f in fp.skills) {
      for (i$ = 0, len$ = (ref$ = fp.skills[f]).length; i$ < len$; ++i$) {
        s = ref$[i$];
        if (!skills[s]) {
          continue;
        }
        pp.skills[f].push(skills[s]);
      }
      for (i$ = 0, len$ = (ref$ = file.skills[p][f]).length; i$ < len$; ++i$) {
        s = ref$[i$];
        if (!skills[s]) {
          continue;
        }
        skillbook[p][f] = skills[s];
      }
    }
    pp.costume = fp.costume;
    update_costume(pp, pp.costume);
    for (f in fp.formes) {
      if (!formes[p] || !formes[p][f]) {
        continue;
      }
      formes[p][f].unlocked = fp.formes[f];
    }
  }
  party = [];
  for (i$ = 0, len$ = (ref$ = file.party).length; i$ < len$; ++i$) {
    p = ref$[i$];
    if (!players[p]) {
      continue;
    }
    party.push(players[p]);
    players[p].revive();
  }
  if (party.length === 0) {
    party.push(ebby);
    ebby.revive();
  }
  set_party();
  reset_items();
  for (i in file.items) {
    if (!items[i]) {
      continue;
    }
    items[i].quantity = file.items[i].q;
    items[i].time = file.items[i].t;
  }
  oldswitches = switches;
  switches = file.switches;
  items.humanskull2.name = switches.name;
  switches.map = switches.checkpoint_map || STARTMAP;
  load.clicked = true;
  Transition.fade(500, 0, function(){
    var old_sp_limit, i$, ref$, len$, p;
    load.clicked = false;
    game.state.start('load', false);
    switch (switches.version) {
    case "Halloween 2016":
      if (switches.ate_nae) {
        switches.ate_nae = 'llov';
      }
      if (switches.beat_nae && !switches.ate_nae && items.naesoul.quantity < 1) {
        switches.bp_has_nae = true;
      }
      items.excel.quantity += 3;
      // fallthrough
    case "New Year 2017":
      /*misnamed November 2016*/
      if (switches.zmapp != null) {
        items.humanskull2.quantity = 1;
      }
      if (!items.jokicharm.quantity) {
        switches.water_walking = false;
      }
      // fallthrough
    case "Delta 2017":
    case "Final Demo":
    case "Release":
      switches.version = version;
    }
    if (typeof switches.sp_limit === 'number') {
      old_sp_limit = switches.sp_limit;
      switches.sp_limit = {};
      for (i$ = 0, len$ = (ref$ = players).length; i$ < len$; ++i$) {
        p = ref$[i$];
        switches.sp_limit[p.name] = old_sp_limit;
      }
    }
    if (switches.checkpoint_map === 'earth' && switches.checkpoint === 'cp1' && !switches.necrotoxin && !items.necrotoxin.quantity) {
      return items.necrotoxin.quantity = 5;
    }
  }, null, 10, false);
  delete switches.loadgame;
}
function newgame(){
  if (newgame.clicked) {
    return;
  }
  switches.newgame = true;
  skillbook = {
    all: []
  };
  create_actors();
  create_mobs();
  switches = clone(switch_defaults);
  reset_items(true);
  join_party('llov', false);
  newgame.clicked = true;
  Transition.fade(500, 0, function(){
    newgame.clicked = false;
    return game.state.start('load', false);
  }, scenario.game_start[0], 10, false);
  delete switches.newgame;
}
function starter_skills(p, f, force){
  var ps, fs, skillist, i$, len$, s;
  ps = players[p].skills[f];
  if (ps.length !== 0 && !force) {
    return;
  }
  ps.length = 0;
  fs = formes[p][f].skills;
  if (fs == null) {
    return;
  }
  skillist = Object.keys(fs).sort(function(a, b){
    return fs[b] - fs[a];
  });
  for (i$ = 0, len$ = skillist.length; i$ < len$; ++i$) {
    s = skillist[i$];
    if (fs[s] <= players[p].level) {
      ps.unshift(skills[s]);
    }
    if (ps.length === 5) {
      break;
    }
  }
}
function start_battle(enc, toughness, terrain){
  toughness == null && (toughness = 0);
  Transition.battle(1000, 500, 20);
  log("Entering Battle!");
  enc == null && (enc = encounter.sanishark);
  enc.toughness = toughness;
  enc.terrain = terrain;
  battle_encounter = enc;
  music.stop();
  temp.enteringbattle = true;
}
function start_battle2(){
  dialog.kill();
  game.state.start('battle', false);
  music.play('battle');
}
function end_battle(result){
  var i$, ref$, len$, hero, messages, key$, key, drop, end_battle_timeout;
  battle.result = result;
  if (game.state.current !== 'battle') {
    return;
  }
  battle.mode = 'end';
  if (battle.ended) {
    return;
  }
  battle.ended = true;
  battle.screen.exit();
  /*
  if result in <[victory defeat]>
      for hero in heroes
          hero.export!
  else
      for hero in heroes
          hero.export true false
  */
  for (i$ = 0, len$ = (ref$ = heroes).length; i$ < len$; ++i$) {
    hero = ref$[i$];
    hero['export']();
  }
  battle.text.text.teletype = true;
  music.stop();
  sound.play([{
    victory: '',
    defeat: '',
    run: 'run'
  }[result]]);
  messages = [{
    victory: 'Enemies Vanquished!',
    defeat: 'Heroes Defeated...',
    run: 'Escaped from battle!'
  }[result]];
  battle.results.items = [];
  battle.results.skills = [];
  for (i$ = 0, len$ = (ref$ = heroes).length; i$ < len$; ++i$) {
    hero = ref$[i$];
    battle.results.skills = learn_skills(hero.name, hero.startlevel, hero.level);
  }
  if (result === 'victory') {
    if (temp.mimic) {
      (ref$ = battle.drops)[key$ = temp.mimic.item] == null && (ref$[key$] = {
        item: items[temp.mimic.item],
        q: 0
      });
      battle.drops[temp.mimic.item].q += temp.mimic.quantity;
      switches[temp.mimic.name] = true;
    }
    for (key in ref$ = battle.drops) {
      drop = ref$[key];
      battle.results.items.push(drop);
      acquire(items[key], drop.q, true, true);
    }
  }
  if (temp.mimic) {
    delete temp.mimic;
  }
  if (result === 'run') {
    temp.runnode = battle.encounter.runnode;
  }
  if (battle.encounter.onvictory && result === 'victory') {
    battle.encounter.onvictory();
  }
  if (battle.encounter.ondefeat && result === 'defeat') {
    battle.encounter.ondefeat();
  }
  if (result !== 'defeat') {
    battlesave();
  }
  end_battle_messages();
  function end_battle_messages(){
    battle.text.show(messages.shift());
    battle.text.timeout_fire = messages.length > 0 ? end_battle_messages : battle_result_summary;
    battle.text.timeout = setTimeout(battle.text.clearTimeout, 3000);
  }
}
function end_battle_2(){
  if (game.state.current !== 'battle' || battle.mode === 'transition') {
    return;
  }
  if (battle.result === 'defeat') {
    quitgame();
  } else {
    battle.mode = 'transition';
    Transition.fade(300, 0, function(){
      return game.state.start('overworld', false);
    }, null, 5, true);
  }
}
function battle_result_summary(){
  var text, i$, ref$, len$, icon, drop;
  battle.text.kill();
  if (!battle.results.items.length && !battle.results.skills.length) {
    battle.screen.exit();
    return end_battle_2();
  }
  battle.screen.show();
  battle.screen.nest(battle.results);
  if (battle.results.items.length) {
    text = tl("Acquired items") + '\n';
    for (i$ = 0, len$ = (ref$ = battle.results.icons).length; i$ < len$; ++i$) {
      icon = ref$[i$];
      drop = battle.results.items.shift();
      if (!drop) {
        icon.kill();
      } else {
        icon.revive();
        icon.loadTexture(drop.item.sicon);
        icon.frame = drop.item.iconx;
        setrow(icon, drop.item.icony);
        text += pad_item_name3(drop.item, drop.q) + '\n';
      }
    }
    if (battle.results.items.length) {
      text += tl("And {0} more...", battle.results.items.length);
    }
  } else if (battle.results.skills.length) {
    text = tl("Learned Skills") + '\n';
    for (i$ = 0, len$ = (ref$ = battle.results.icons).length; i$ < len$; ++i$) {
      icon = ref$[i$];
      icon.kill();
      if (battle.results.skills[0]) {
        text += battle.results.skills.shift() + '\n';
      }
    }
    if (battle.results.skills.length) {
      text += tl("And {0} more...", battle.results.skills.length);
    }
  }
  battle.results.summary.change(text);
  battle.results.resize(Math.ceil(battle.results.summary.width / WS + 1.5), battle.results.h);
  battle.results.x = HWIDTH - battle.results.w * HWS;
}
function battle_update_frame(){
  var marginwidth, marginheight, bgoffset;
  if (game.state.current !== 'battle') {
    return;
  }
  marginwidth = (game.width - WIDTH) / 2;
  marginheight = (game.height - HEIGHT) / 2;
  bgoffset = battle.bgoffset;
  battle.bg2.width = battle.bg1.width = marginwidth - bgoffset.x;
  battle.bg1.tilePosition.set(marginwidth - bgoffset.x, 0);
  battle.bg4.x = battle.bg3.x = -marginwidth;
  battle.bg4.height = battle.bg3.height = marginheight;
  battle.bg4.width = battle.bg3.width = game.width;
}
state.battle.create = function(){
  var bg, bgoffset, marginwidth, l, i$, ref$, len$, monster, ll, newmonster, xposition, i, member, to$;
  temp.enteringbattle = false;
  input_battle();
  battle = game.add.group(gui.frame, 'battle');
  battle.mode = 'wait';
  battle.encounter = battle_encounter;
  battle.drops = {};
  bg = encounter.bg[access(getmapdata('bg'), battle.encounter.terrain)];
  if (battle.encounter.bg) {
    bg = encounter.bg[access(battle.encounter.bg)];
  }
  battle.bg0 = battle.addChild(
  new Phaser.Image(game, 0, 0, bg[0]));
  battle.bgoffset = bgoffset = {
    x: (battle.bg0.width - WIDTH) / 2,
    y: battle.bg0.height - HEIGHT
  };
  battle.bg0.x -= bgoffset.x;
  battle.bg0.y -= bgoffset.y;
  marginwidth = (game.width - WIDTH) / 2;
  battle.bg1 = battle.addChild(
  new Phaser.TileSprite(game, -bgoffset.x, -bgoffset.y, 1, HEIGHT + bgoffset.y, bg[1]));
  battle.bg1.anchor.set(1, 0);
  battle.bg2 = battle.addChild(
  new Phaser.TileSprite(game, WIDTH + bgoffset.x, -bgoffset.y, 1, HEIGHT + bgoffset.y, bg[1]));
  battle.bg3 = battle.addChild(
  new Phaser.Image(game, 0, -bgoffset.y, 'solid'));
  battle.bg3.anchor.set(0, 1);
  battle.bg3.tint = bg[2];
  battle.bg4 = battle.addChild(
  new Phaser.Image(game, 0, HEIGHT, 'solid'));
  battle.bg4.tint = bg[3];
  battle_update_frame();
  resize_callback(battle, battle_update_frame);
  battle.monstergroup = game.add.group(battle, 'monstergroup');
  monsters = [];
  l = 0;
  for (i$ = 0, len$ = (ref$ = battle.encounter.monsters).length; i$ < len$; ++i$) {
    monster = ref$[i$];
    ll = levelrange(monster.l1, monster.l2) + battle.encounter.toughness * 3;
    if (battle.encounter.lmod) {
      ll += battle.encounter.lmod;
    }
    if (ll < 1) {
      ll = 1;
    }
    monsters.push(battle.monstergroup.addChild(newmonster = new Monster(WIDTH / 2 + monster.x * WS, HEIGHT / 2 - monster.y * WS, monster.id, ll)));
    l += newmonster.level;
    recolormonster(newmonster);
  }
  l = Math.round(l / monsters.length);
  heroes = [];
  xposition = [[112], [56, 168], [8, 112, 216]][party.length - 1];
  for (i$ = (ref$ = party).length - 1; i$ >= 0; --i$) {
    i = i$;
    member = ref$[i$];
    heroes.push(
    battle.addChild(
    new Battler(xposition[i], 144, party[i])));
  }
  for (i$ = 0, len$ = heroes.length; i$ < len$; ++i$) {
    member = heroes[i$];
    if (member.stats.hp === 0) {
      member.death();
    }
  }
  battle.encounterlevel = battle.addChild(
  new Text('font_yellow', "", WIDTH - WS * 3, 2));
  battle.encounterlevel.anchor.set(1, 0);
  battle.encounterlevel.change(tl("Level {0}", l));
  battle.text = battle.addChild(
  new Window(8, 0, 19, 2));
  battle.text.text = battle.text.addText(null, '', 8, WS);
  battle.text.text.anchor.set(0, 0.5);
  battle.text.show = function(){
    this.text.teletype = battle.mode === 'end' || battle.mode === 'action' || battle.mode === 'text';
    this.revive();
    this.text.change.apply(this.text, arguments);
  };
  battle.text.kill();
  battle.text.skip = function(){
    if (battle.text.text.textbuffer.length) {
      battle.text.text.empty_buffer();
    } else if (battle.text.timeout) {
      battle.text.clearTimeout();
    } else if (battle.results.alive) {
      battle_result_summary();
    }
  };
  battle.text.clearTimeout = function(){
    var t, tf;
    if (!battle.text.timeout) {
      return;
    }
    t = battle.text.timeout;
    tf = battle.text.timeout_fire;
    battle.text.timeout = null;
    battle.text.timeout_fire = null;
    clearTimeout(t);
    tf();
  };
  game.input.onDown.add(battle.text.skip);
  keyboard.confirm.onDown.add(battle.text.skip);
  battle.bringToTop(battle.monstergroup);
  for (i$ = 0, len$ = heroes.length; i$ < len$; ++i$) {
    member = heroes[i$];
    battle.bringToTop(member);
  }
  battle.addChild(battle.text.text);
  battle.text.text.x = WS;
  battle.text.text.update = override(battle.text.text.update, function(){
    this.visible = battle.text.alive;
  });
  battle.screen = battle.addChild(
  new Screen());
  battle.screen.nocancel = true;
  battle.menu = battle.screen.addMenu(0, 8, 6, 7);
  battle.summary = battle.screen.createWindow(0, 8, 7, 7);
  battle.summary.text = battle.summary.addText(null, 'summary', 8, 8, null, 14);
  battle.skill_menu = battle.screen.createMenu(0, 8, 6, 7);
  battle.item_menu = battle.screen.createMenu(0, 8, 8, 7, false, true);
  battle.item_menu.onChangeSelection = battle.skill_menu.onChangeSelection = function(){
    var o, text;
    o = this.objects[this.selected + this.offset];
    text = access(o.desc_battle) || access(o.desc) || '';
    if (o.sp != null) {
      text += "\nSP:" + access(o.sp) + "%";
    }
    battle.summary.text.change(text);
  };
  battle.results = battle.screen.createWindow(WS * 4, 0, 12, 8);
  battle.results.summary = battle.results.addText('font', "Result Summry", WS + 2, HWS, false, 0, WS);
  battle.results.icons = [];
  for (i$ = 1, to$ = battle.results.h - 1; i$ < to$; ++i$) {
    i = i$;
    battle.results.icons.push(battle.results.addChild(new Phaser.Sprite(game, 0, WS * i)));
  }
  battle.animation = battle.addChild(
  new Animation());
  battle.animationlist = [];
  battle.targeter = battle.addChild(
  new Phaser.Image(game, 0, 0, 'target'));
  battle.targeter.update = function(){
    var t;
    if (battle.target != null && battle.mode.indexOf('target') > -1) {
      if (!this.alive) {
        this.revive();
      }
      t = battle.target;
      if (t instanceof Monster) {
        this.x = t.x;
        this.y = t.y - t.height / 2;
      } else if (t instanceof Battler) {
        this.x = t.x + t.w / 2 * WS;
        this.y = t.y + t.h / 2 * WS;
      }
    } else {
      if (this.alive) {
        this.kill();
      }
    }
  };
  battle.targeter.anchor.set(0.5);
  game.input.onDown.add(battle_click, this);
  keyboard.confirm.onDown.add(battle_select, this);
  keyboard.cancel.onDown.add(battle_cancel, this, 10);
  keyboard.left.onDown.add(battle_left, this);
  keyboard.up.onDown.add(battle_left, this);
  keyboard.right.onDown.add(battle_right, this);
  keyboard.down.onDown.add(battle_right, this);
  battle.addmonster = function(monster){
    monsters.push(battle.monstergroup.addChild(monster));
    recolormonster(monster);
  };
  check_trigger();
};
state.battle.shutdown = function(){
  battle.alive = false;
  battle.destroy();
};
function triggertext(text){
  battle.mode = 'text';
  triggertext.list.push(text);
  if (triggertext.list.length === 1) {
    triggertext.next(0);
  }
}
triggertext.next = function(delay){
  battle.text.timeout_fire = function(){
    var delay;
    delay = Math.max(1500, (100 - gameOptions.textspeed) * triggertext.list[0].length);
    battle.text.show(triggertext.list[0]);
    triggertext.list.shift();
    if (triggertext.list.length > 0) {
      return triggertext.next(delay);
    } else {
      battle.text.timeout_fire = function(){
        battle.mode = 'next';
        return battle.text.kill();
      };
      return battle.text.timeout = setTimeout(battle.text.clearTimeout, delay);
    }
  };
  battle.text.timeout = setTimeout(battle.text.clearTimeout, delay);
};
triggertext.list = [];
function get_animation(){
  var i$, ref$, len$, a;
  for (i$ = 0, len$ = (ref$ = battle.animationlist).length; i$ < len$; ++i$) {
    a = ref$[i$];
    if (a.alive) {
      a = null;
    } else {
      break;
    }
  }
  if (!a) {
    battle.animationlist.push(
    battle.addChild(
    a = new Animation()));
  }
  a.callback = null;
  return a;
}
function battle_left(){
  change_battle_target(1);
}
function battle_right(){
  change_battle_target(-1);
}
function change_battle_target(n){
  var list, selected;
  if (!target_mode()) {
    return;
  }
  list = target_list(true);
  selected = list.indexOf(battle.target);
  if (selected === -1) {
    selected = 0;
  }
  selected += n;
  if (selected < 0) {
    selected = list.length - 1;
  }
  if (selected > list.length - 1) {
    selected = 0;
  }
  battle.target = list[selected];
  menusound.play('blip');
}
function target_list(ignorecharm){
  var targeter, list, ref$;
  targeter = battle.skill || battle.item;
  list = [];
  if ((ref$ = targeter.target) === 'enemy' || ref$ === 'any') {
    list = list.concat(enemy_list(ignorecharm));
  }
  if ((ref$ = targeter.target) === 'ally' || ref$ === 'any') {
    list = list.concat(ally_list());
  }
  return list;
}
function enemy_list(ignorecharm, actor){
  var list, i$, ref$, len$, hero;
  actor == null && (actor = battle.actor);
  if (actor instanceof Battler) {
    return monster_list();
  }
  if (!ignorecharm) {
    if (actor.has_buff(buffs.charmed) && hero_list().length > 1) {
      list = [];
      for (i$ = 0, len$ = (ref$ = hero_list()).length; i$ < len$; ++i$) {
        hero = ref$[i$];
        if (hero.name !== 'llov' || Math.random() < 0.5) {
          list.push(hero);
        }
      }
      return list;
    }
    for (i$ = 0, len$ = (ref$ = hero_list()).length; i$ < len$; ++i$) {
      hero = ref$[i$];
      if (hero.has_buff(buffs.decoy) && Math.random() < 0.5) {
        return [hero];
      }
    }
  }
  return hero_list();
}
function ally_list(ignorecharm, actor){
  var allylist, retlist, i$, len$, ally;
  actor == null && (actor = battle.actor);
  allylist = actor instanceof Battler
    ? hero_list()
    : monster_list();
  if (ignorecharm) {
    return allylist;
  }
  if (actor.has_buff(buffs.isolated)) {
    return [actor];
  }
  retlist = [];
  for (i$ = 0, len$ = allylist.length; i$ < len$; ++i$) {
    ally = allylist[i$];
    if (ally !== actor && ally.has_buff(buffs.isolated)) {
      continue;
    }
    retlist.push(ally);
  }
  return retlist.length
    ? retlist
    : [actor];
}
function hero_list(){
  var list, i$, ref$, len$, hero;
  list = [];
  for (i$ = 0, len$ = (ref$ = heroes).length; i$ < len$; ++i$) {
    hero = ref$[i$];
    if (!hero.dead) {
      list.push(hero);
    }
  }
  return list;
}
function monster_list(){
  var list, i$, ref$, len$, monster;
  list = [];
  for (i$ = 0, len$ = (ref$ = monsters).length; i$ < len$; ++i$) {
    monster = ref$[i$];
    if (!monster.dead) {
      list.push(monster);
    }
  }
  return list;
}
function battle_cancel(){
  if (!target_mode()) {
    return;
  }
  battle.target = null;
  battle.skill = null;
  battle.item = null;
  battle.text.kill();
  battle.screen.revive();
  battle.mode = 'command';
  menusound.play('blip');
  return false;
}
function use_skill(){
  var ref$, ref1$, text, delay;
  battle.actor.stats.sp -= access(battle.skill.sp) / 100;
  if (typeof (ref$ = battle.actor).reward_xp == 'function') {
    ref$.reward_xp(access(battle.skill.xp), battle.target);
  }
  if (battle.actor instanceof Battler && battle.actor.luckroll() > 0.95) {
    battle.critical = true;
  }
  battle.actor.sp_check();
  battle.lastskill = battle.skill;
  battle.actor.lastskill = battle.skill;
  if ((ref$ = battle.target) != null) {
    ref$.lastskillonme = battle.skill;
  }
  if (battle.actor instanceof Battler) {
    battle.lastskillhero = battle.skill;
  } else {
    battle.lastskillmonster = battle.skill;
  }
  if (gameOptions.battlemessages && !((ref1$ = battle.actor.monstertype) != null && ref1$.minion)) {
    battle.mode = 'action';
    text = tl("{0} used {1}!", battle.actor.displayname, battle.skill.name);
    battle.text.show(text);
    delay = Math.max(1000, (100 - gameOptions.textspeed) * text.length);
    battle.text.timeout_fire = function(){
      return use_skill2();
    };
    battle.text.timeout = setTimeout(battle.text.clearTimeout, delay);
  } else {
    use_skill2();
  }
  function use_skill2(){
    var that;
    battle.animation.callback = [battle.skill.action];
    if (in$('attack', battle.skill.attributes)) {
      battle.actor.call_buffs(function(){
        battle.animation.callback.push({
          callback: this.attack,
          context: this
        });
      });
    }
    battle.animation.callback.push(end_turn);
    if (battle.skill.custom_animation) {
      battle.skill.custom_animation();
    } else {
      battle.animation.play(access(battle.skill.animation), battle.target.x, battle.target.y);
      sound.play((that = battle.skill.sfx) ? that : 'strike');
    }
  }
}
function use_item(){
  var text, delay;
  if (gameOptions.battlemessages) {
    battle.mode = 'action';
    text = tl("{0} used {1}!", battle.actor.displayname, battle.item.name);
    battle.text.show(text);
    delay = Math.max(1000, (100 - gameOptions.textspeed) * text.length);
    battle.text.timeout_fire = function(){
      return use_item2();
    };
    battle.text.timeout = setTimeout(battle.text.clearTimeout, delay);
  } else {
    use_item2();
  }
  function use_item2(){
    var that;
    if ((that = battle.item.usebattle) != null) {
      that(battle.target);
    } else {
      battle.item.use(battle.target);
    }
    battle.actor.stats.sp -= 1;
    battle.actor.sp_check();
    battle.item.consume();
    battle.item.time = Date.now();
    battle.item_menu.offset = 0;
    end_turn();
  }
}
function battle_select(){
  if (!target_mode()) {
    return;
  }
  if (battle.target != null) {
    battle.mode = 'action';
    battle.text.kill();
    if (battle.skill != null) {
      use_skill();
    }
    if (battle.item != null) {
      use_item();
    }
  } else {
    battle.target = target_list(true)[0];
    menusound.play('blip');
  }
}
function battle_click(e){
  var ref$, i$, len$, monster, hero;
  if (e.button === 2) {
    return battle_cancel();
  }
  if ((ref$ = battle.mode) === 'target_enemy' || ref$ === 'target_any') {
    for (i$ = 0, len$ = (ref$ = monsters).length; i$ < len$; ++i$) {
      monster = ref$[i$];
      if (monster.dead) {
        continue;
      }
      if (point_in_sprite(mouse.world, monster)) {
        battle.target = monster;
        battle_select();
      }
    }
  }
  if ((ref$ = battle.mode) === 'target_ally' || ref$ === 'target_any') {
    for (i$ = 0, len$ = (ref$ = heroes).length; i$ < len$; ++i$) {
      hero = ref$[i$];
      if (hero.dead) {
        continue;
      }
      if (battle.actor.has_buff(buffs.isolated) && hero !== battle.actor) {
        continue;
      }
      if (hero.has_buff(buffs.isolated) && hero !== battle.actor) {
        continue;
      }
      if (point_in_rect(mouse.world, hero.worldTransform.tx, hero.worldTransform.ty, hero.w * WS, hero.h * WS)) {
        battle.target = hero;
        battle_select();
      }
    }
  }
}
function target_mode(){
  return battle.mode.indexOf('target') > -1;
}
function end_turn(){
  var i$, ref$, len$, monster;
  if (!battle.actor) {
    return console.warn("End Turn was called when it shouldn't have been.");
  }
  battle.animation.callback.length = 0;
  battle.actor.call_buffs('turn');
  battle.screen.exit();
  if (battle.mode !== 'text') {
    battle.mode = 'next';
  }
  battle.text.kill();
  battle.target = null;
  battle.actor = null;
  battle.critical = false;
  battle.skill = null;
  battle.item = null;
  battle.menu.history = [];
  battle.menu.offset = 0;
  for (i$ = 0, len$ = (ref$ = monster_list()).length; i$ < len$; ++i$) {
    monster = ref$[i$];
    monster.update_stats();
  }
  check_trigger();
  check_death();
  check_battle_end();
}
function check_trigger(){
  var i$, ref$, len$, monster, ref1$;
  for (i$ = 0, len$ = (ref$ = monster_list()).length; i$ < len$; ++i$) {
    monster = ref$[i$];
    if ((ref1$ = monster.monstertype.trigger) != null) {
      ref1$.call(monster);
    }
  }
}
function undying(o){
  var ref$;
  if (in$('mortal', o.attributes)) {
    return false;
  }
  return (o.monstertype && typeof o.monstertype.undying === 'function' && o.monstertype.undying.call(o)) || (((ref$ = o.item) != null ? ref$.base : void 8) === items.deathsmantle && ally_list(null, o).length > 1);
}
function check_death(){
  var i$, ref$, len$, battler, transition;
  for (i$ = 0, len$ = (ref$ = heroes.concat(monsters)).length; i$ < len$; ++i$) {
    battler = ref$[i$];
    if (battler.dead) {
      continue;
    }
    if (undying(battler)) {
      continue;
    }
    if (battler.stats.hp <= 0 && !battler.dead) {
      battler.dead = true;
      battler.stats.sp = 0;
      if (battler.stats.ex != null) {
        battler.stats.ex = 0;
      }
      battler.update_stats();
      battle.mode = 'transition';
      sound.play('defeat');
      transition = Transition.fadeout(battler instanceof Battler ? battler.port : battler, 1000, fn$);
      transition.battler = battler;
    }
  }
  function fn$(){
    if (game.state.current !== 'battle') {
      return;
    }
    this.battler.death();
    if (this.battler instanceof Battler) {
      this.battler.port.alpha = 1;
    }
    battle.mode = 'next';
    check_trigger();
    return check_battle_end();
  }
}
function check_battle_end(){
  if (hero_list().length === 0) {
    end_battle('defeat');
  } else if (monsters.length === 0) {
    end_battle('victory');
  }
}
state.battle.update = function(){
  var ref$, mode, i$, len$, hero, monster, prevtarget;
  main_update();
  if ((ref$ = battle.mode) === 'wait' || ref$ === 'next') {
    mode = battle.mode;
    for (i$ = 0, len$ = (ref$ = heroes).length; i$ < len$; ++i$) {
      hero = ref$[i$];
      if (hero.stats.hp <= 0 && !undying(hero)) {
        continue;
      }
      if (mode === 'wait') {
        if (hero.update_sp()) {
          set_actor(hero);
        }
      } else {
        if (hero.update_sp(true)) {
          set_actor(hero);
        }
      }
      hero.update_stats();
      if (battle.actor) {
        return;
      }
    }
    for (i$ = 0, len$ = (ref$ = monsters).length; i$ < len$; ++i$) {
      monster = ref$[i$];
      if (monster.stats.hp <= 0 && !undying(monster)) {
        continue;
      }
      if (mode === 'wait' && monster.update_sp() && battle.mode === 'wait') {
        monster.attack();
      }
      monster.update_stats();
      if (battle.actor) {
        return;
      }
    }
    if (battle.mode === 'next') {
      battle.mode = 'wait';
    }
  } else {
    if ((ref$ = battle.mode) === 'target_enemy' || ref$ === 'target_any') {
      prevtarget = battle.target;
      for (i$ = 0, len$ = (ref$ = monsters).length; i$ < len$; ++i$) {
        monster = ref$[i$];
        if (battle.target !== monster && point_in_sprite(mouse.world, monster)) {
          battle.target = monster;
        }
      }
      if (battle.target !== prevtarget) {
        menusound.play('blip');
      }
    }
    if ((ref$ = battle.mode) === 'target_ally' || ref$ === 'target_any') {
      for (i$ = 0, len$ = (ref$ = heroes).length; i$ < len$; ++i$) {
        hero = ref$[i$];
        if (hero.dead) {
          continue;
        }
        if (battle.actor.has_buff(buffs.isolated) && hero !== battle.actor) {
          continue;
        }
        if (hero.has_buff(buffs.isolated) && hero !== battle.actor) {
          continue;
        }
        if (battle.target !== hero && point_in_rect(mouse.world, hero.worldTransform.tx, hero.worldTransform.ty, hero.w * WS, hero.h * WS)) {
          battle.target = hero;
          menusound.play('blip');
        }
      }
    }
  }
  function set_actor(actor){
    var menuset, itemskill;
    battle.actor = actor;
    battle.mode = 'command';
    battle.menu.x = actor.x;
    battle.screen.show();
    if (actor.skills.length > 0) {
      menuset = ['Skills', skill_menu];
    } else {
      menuset = [
        'Attack', {
          callback: choose_skill,
          arguments: [skills.attack]
        }
      ];
    }
    if (itemskill = access.call(actor.item, actor.item.skill)) {
      menuset = menuset.concat([
        itemskill.name, {
          callback: choose_skill,
          arguments: [itemskill]
        }
      ]);
    }
    menuset = menuset.concat(['Items', item_menu]);
    if (excel_count() > 0) {
      if (battle.actor.forme.stage === 0) {
        if (battle.actor.stats.ex >= battle.actor.forme.stage + 1) {
          menuset = menuset.concat(['★Excel', excel_menu]);
        } else {
          menuset = menuset.concat(['Excel', 0]);
        }
      }
    } else if (actor.forme && actor.forme.stage > 0) {
      menuset = menuset.concat([
        'Reversion', function(){
          battle.actor.excel('default');
          battle.actor.stats.sp++;
          return end_turn();
        }
      ]);
    }
    if (battle.actor.stats.sp_limit > battle.actor.stats.sp_level) {
      menuset = menuset.concat(['Charge', battle_charge]);
    } else {
      menuset = menuset.concat(['Pass', battle_wait]);
    }
    menuset = menuset.concat(['Run', run]);
    battle.menu.set.apply(battle.menu, menuset);
  }
  function run(){
    var runchance, i$, ref$, len$, monster, ref1$, itemboost, hero;
    battle.mode = 'action';
    runchance = 100;
    for (i$ = 0, len$ = (ref$ = monsters).length; i$ < len$; ++i$) {
      monster = ref$[i$];
      if (monster.monstertype.escape != null) {
        runchance = (ref1$ = monster.monstertype.escape) < runchance ? ref1$ : runchance;
      }
    }
    if (runchance === 0) {
      battle.text.show("Escape is impossible!");
      battle.menu.kill();
      return setTimeout(end_turn, 1000);
    }
    if (runchance === 100) {
      return end_battle('run');
    }
    itemboost = 100;
    for (i$ = 0, len$ = (ref$ = heroes).length; i$ < len$; ++i$) {
      hero = ref$[i$];
      if (hero.item.mod_escape != null) {
        itemboost = hero.item.mod_escape(itemboost);
      }
    }
    if (battle.actor.luckroll() * itemboost > 100 - runchance) {
      return end_battle('run');
    } else {
      battle.text.show("Failed to escape!");
      battle.menu.kill();
      return setTimeout(battle_wait, 1000);
    }
  }
  function choose_skill(skill){
    var ref$;
    battle.screen.kill();
    battle.skill = skill;
    if ((ref$ = skill.target) === 'ally' || ref$ === 'enemy' || ref$ === 'any') {
      battle.mode = "target_" + skill.target;
      battle.text.show(target_message[skill.target]);
    } else {
      battle.target = battle.actor;
      if (skill.target === 'enemies') {
        battle.target = enemy_list(true);
      }
      if (skill.target === 'allies') {
        battle.target = ally_list();
      }
      use_skill();
    }
  }
  function skill_menu(){
    var args, i$, ref$, len$, skill;
    args = [];
    battle.skill_menu.objects = [];
    for (i$ = 0, len$ = (ref$ = battle.actor.skills).length; i$ < len$; ++i$) {
      skill = ref$[i$];
      battle.skill_menu.objects.push(skill);
      args.push(skill.name);
      args.push(battle.actor.stats.sp >= access(skill.sp) / 100 ? {
        callback: choose_skill,
        arguments: [skill]
      } : 0);
    }
    battle.skill_menu.set.apply(battle.skill_menu, args);
    battle.screen.nest(battle.skill_menu, battle.summary);
    battle.skill_menu.x = battle.actor.x;
    setup_summary(
    battle.skill_menu);
    battle.skill_menu.onChangeSelection();
  }
  function setup_summary(parentmenu){
    battle.summary.x = parentmenu.x + (parentmenu.w - 1) * WS;
    battle.summary.text.x = 20;
    if (battle.summary.x + battle.summary.w * WS >= WIDTH) {
      battle.summary.x -= parentmenu.w * WS + (battle.summary.w - 2) * WS;
      battle.summary.text.x = 8;
    }
  }
  function choose_item(item){
    var ref$;
    battle.screen.kill();
    battle.item = item;
    if ((ref$ = item.target) === 'ally' || ref$ === 'enemy' || ref$ === 'any') {
      battle.mode = "target_" + item.target;
      battle.text.show(target_message[item.target]);
    } else {
      battle.target = battle.actor;
      if (item.target === 'enemies') {
        battle.target = enemy_list(true);
      }
      if (item.target === 'allies') {
        battle.target = ally_list();
      }
      use_item();
    }
  }
  function item_menu(){
    var inventory, key, ref$, item, args, i$, len$, i, to$, j, button, ref1$, ref2$;
    inventory = [];
    for (key in ref$ = items) {
      item = ref$[key];
      if (item.quantity > 0 && (item.use != null || item.usebattle != null)) {
        inventory.push(item);
      }
    }
    inventory.sort(function(a, b){
      return b.time - a.time;
    });
    args = [
      'Back', function(){
        this.dontkill = true;
        return battle.screen.back();
      }
    ];
    battle.item_menu.objects = [0];
    for (i$ = 0, len$ = inventory.length; i$ < len$; ++i$) {
      i = i$;
      item = inventory[i$];
      battle.item_menu.objects.push(item);
      args.push([
        pad_item_name4(item, 16), {
          key: item.sicon,
          x: item.iconx,
          y: item.icony
        }
      ]);
      args.push({
        callback: choose_item,
        arguments: [item]
      });
    }
    for (i$ = inventory.length + 1, to$ = battle.item_menu.buttons.length; i$ < to$; ++i$) {
      j = i$;
      button = battle.item_menu.buttons[j];
      button.icon.kill();
    }
    battle.item_menu.set.apply(battle.item_menu, args);
    battle.screen.nest(battle.item_menu, battle.summary);
    battle.item_menu.x = (ref$ = 0 > (ref2$ = battle.actor.x - WS) ? 0 : ref2$) < (ref1$ = WIDTH - battle.item_menu.w * WS) ? ref$ : ref1$;
    setup_summary(
    battle.item_menu);
    battle.item_menu.onChangeSelection();
  }
  function excel_menu(){
    var actor, options, key, ref$, forme;
    actor = battle.actor;
    options = [
      'Back', function(){
        return battle.menu.back();
      }
    ];
    for (key in ref$ = formes[battle.actor.name]) {
      forme = ref$[key];
      if (forme.stage !== actor.forme.stage + 1 || !forme.unlocked) {
        continue;
      }
      options = options.concat([
        forme.name, [
          {
            callback: actor.excel,
            arguments: [key],
            context: actor
          }, end_turn
        ]
      ]);
    }
    this.nest.apply(this, options);
  }
  function battle_charge(){
    battle.actor.stats.sp_level++;
    end_turn();
  }
  function battle_wait(){
    battle.actor.stats.sp -= 1;
    end_turn();
  }
};
function excel_count(actor){
  var count, key, ref$, forme;
  actor == null && (actor = battle.actor);
  count = 0;
  for (key in ref$ = formes[actor.name]) {
    forme = ref$[key];
    if (forme.stage === actor.forme.stage + 1 && forme.unlocked) {
      count++;
    }
  }
  return count;
}
target_message = {
  enemy: 'Select an Enemy',
  ally: 'Select an Ally',
  any: 'Select a Target'
};
battle_mixin = {
  level: 1,
  xpwell: 100,
  xpwell_max: 100,
  stats: {
    hp: 1,
    hp_max: 20,
    hp_base: 100,
    def: 20,
    def_base: 100,
    atk: 20,
    atk_base: 100,
    luck_base: 100,
    luck: 100,
    speed: 50,
    speed_base: 100,
    sp: 0,
    sp_level: 1,
    Sp_limit: 1
  },
  dead: false,
  damage: function(damage, showtext, source){
    var this_undying, buff, maxhp, ref$, ref1$;
    damage == null && (damage = 0);
    showtext == null && (showtext = false);
    source == null && (source = null);
    damage === NaN && (damage = 0);
    this_undying = undying(this);
    if (this.stats.hp <= 0 && !this_undying) {
      return;
    }
    if (damage < 0 && (buff = this.has_buff(buffs.healblock))) {
      if (buff.inflictor && !buff.inflictor.has_buff(buffs.healblock)) {
        buff.inflictor.damage(damage / 2, showtext, this);
      }
      damage = 0;
    }
    this.call_buffs(function(){
      damage = this.ondamage(damage, source);
    });
    maxhp = this.get_stat('hp');
    if (source instanceof Battler) {
      source.reward_xp(Math.abs(damage / maxhp) * 100, this);
    }
    if (battle.critical) {
      damage *= 2;
    }
    if (battle.critical && showtext) {
      if (this instanceof Battler) {
        Transition.critical(0.01, 100, this.x + this.w * HWS, this.y + this.h * HWS);
      } else {
        Transition.critical(0.01, 100, this.x, this.y);
      }
    }
    this.stats.hp -= damage / maxhp;
    this.stats.hp = (ref$ = 0 > (ref1$ = this.stats.hp) ? 0 : ref1$) < 1 ? ref$ : 1;
    if (showtext) {
      this.floatingText.scale.set(battle.critical ? 2 : 1);
      if (damage < 0) {
        this.show_text("+" + (-Math.floor(damage)), 'font_green');
      } else {
        this.show_text("-" + Math.floor(damage), 'font_red');
      }
    }
    if (this.stats.hp === 0 && source instanceof Battler && !this_undying) {
      source.reward_xp_weighted(this.xpwell + this.xpkill, this);
      this.xpwell = 0;
    }
    if (this.stats.hp === 0) {
      check_death();
    }
  },
  update_common_stats: function(){
    var ref$, ref1$;
    this.bars.hp.width = this.stats.hp * this.bars.length;
    this.bars.sp0.width = ((ref$ = this.stats.sp) < 1 ? ref$ : 1) * this.bars.length;
    this.bars.sp1.width = ((ref$ = 0 > (ref1$ = this.stats.sp - 1) ? 0 : ref1$) < 1 ? ref$ : 1) * this.bars.length;
    this.bars.sp2.width = ((ref$ = 0 > (ref1$ = this.stats.sp - 2) ? 0 : ref1$) < 1 ? ref$ : 1) * this.bars.length;
    this.bars.sp3.width = ((ref$ = 0 > (ref1$ = this.stats.sp - 3) ? 0 : ref1$) < 1 ? ref$ : 1) * this.bars.length;
    if (this.has_buff(buffs.obscure)) {
      this.bars.hp.width = this.bars.sp0.width = this.bars.sp2.width = this.bars.sp3.width = 0;
    }
  },
  calc_stats: function(){
    var hp_ratio;
    hp_ratio = this.stats.hp || this.base.stats.hp;
    this.stats.hp_max = new_calc_stat(this.level, this.stats.hp_base);
    this.stats.atk = new_calc_stat(this.level, this.stats.atk_base);
    this.stats.def = new_calc_stat(this.level, this.stats.def_base);
    this.stats.speed = calc_stat(this.level, this.stats.speed_base, 2);
    this.stats.luck = calc_stat(this.level, this.stats.luck_base, 6.1);
  },
  update_sp: function(noupdate){
    if (!noupdate) {
      this.call_buffs('step');
      this.stats.sp += (1 - Math.pow(2, -0.05 * (0.2 * this.get_stat('speed')))) * (delta / 1000) * Math.pow(this.stats.sp_level, 0.1);
      if (excel_count(this) > 0) {
        this.stats.ex += delta / 20000;
        if (this.stats.ex > 1) {
          this.stats.ex = 1;
        }
      } else if (this.forme && this.forme.stage > 0) {
        this.stats.ex -= delta / 20000;
        if (this.stats.ex < 0) {
          this.stats.ex = 0;
          this.excel('default');
        }
      }
    }
    if (this.stats.sp >= this.stats.sp_level) {
      this.stats.sp = this.stats.sp_level;
      return true;
    }
    return false;
  },
  sp_check: function(){
    while (Math.ceil(this.stats.sp) < this.stats.sp_level) {
      if (this.stats.sp_level !== 1) {
        this.stats.sp_level--;
      } else {
        break;
      }
    }
  },
  call_buffs: function(callback){
    var args, res$, i$, to$, ref$, len$, buff;
    res$ = [];
    for (i$ = 1, to$ = arguments.length; i$ < to$; ++i$) {
      res$.push(arguments[i$]);
    }
    args = res$;
    for (i$ = 0, len$ = (ref$ = this.buffs).length; i$ < len$; ++i$) {
      buff = ref$[i$];
      if (buff.inflictor && (buff.inflictor.dead || !buff.inflictor.alive)) {
        buff.remedy();
      }
    }
    if (typeof callback === 'string') {
      for (i$ = 0, len$ = (ref$ = this.buffs).length; i$ < len$; ++i$) {
        buff = ref$[i$];
        buff[callback].apply(buff, args);
      }
    } else if (typeof callback === 'function') {
      for (i$ = 0, len$ = (ref$ = this.buffs).length; i$ < len$; ++i$) {
        buff = ref$[i$];
        callback.apply(buff, args);
      }
    }
  },
  create_buffs: function(x, y){
    var i$, i;
    this.buffs = [];
    for (i$ = 0; i$ < 5; ++i$) {
      i = i$;
      this.buffs.push(this.addChild(
      new Buff(x + i * BS, y)));
    }
  },
  inflict: function(buff){
    var i$, ref$, len$, key, slot;
    if (buff.nostack && this.has_buff(buff)) {
      return;
    }
    for (i$ = 0, len$ = (ref$ = this.buffs).length; i$ < len$; ++i$) {
      key = i$;
      slot = ref$[i$];
      if (slot.name === 'null') {
        slot.load_buff(buff, battle.actor);
        return slot;
      }
    }
  },
  remedy: function(buff){
    var i$, ref$, len$, slot;
    for (i$ = 0, len$ = (ref$ = this.buffs).length; i$ < len$; ++i$) {
      slot = ref$[i$];
      if (slot.name === buff.name) {
        slot.load_buff(buffs['null']);
      }
    }
  },
  has_buff: function(buff){
    var i$, ref$, len$, slot;
    for (i$ = 0, len$ = (ref$ = this.buffs).length; i$ < len$; ++i$) {
      slot = ref$[i$];
      if (slot.name === buff.name) {
        return slot;
      }
    }
    return false;
  },
  get_stat: function(key){
    var stat;
    if (buff_get_stat.gotten.length > 0) {
      buff_get_stat.gotten = [];
    }
    stat = this.stats[key === 'hp' ? key + "_max" : key];
    this.call_buffs(function(){
      stat = this["mod_" + key](stat);
    });
    return stat;
  },
  luckroll: luckroll
};
Battler = (function(superclass){
  var prototype = extend$((import$(Battler, superclass).displayName = 'Battler', Battler), superclass).prototype, constructor = Battler;
  function Battler(x, y, base){
    var barlength;
    this.base = base;
    Battler.superclass.call(this, x, y, 6, 6);
    this.name = this.base.name;
    this.displayname = speakers[this.name].display;
    implement(this, battle_mixin);
    this.forme = formes[this.name]['default'];
    this.stats.sp_limit = switches.sp_limit[this.name] || 1;
    this.stats.xp = 0;
    this.stats.ex = 0;
    this.attributes = [];
    barlength = 86;
    this.bars = {
      length: barlength,
      empty: this.addChild(new Phaser.TileSprite(game, 5, 8, barlength, 40, 'bars', 1)),
      hp: this.addChild(new Phaser.TileSprite(game, 5, 8, barlength, 10, 'bars', 2)),
      sp0: this.addChild(new Phaser.TileSprite(game, 5, 18, 0, 10, 'bars', 4)),
      sp1: this.addChild(new Phaser.TileSprite(game, 5, 18, 0, 10, 'bars', 5)),
      sp2: this.addChild(new Phaser.TileSprite(game, 5, 18, 0, 10, 'bars', 6)),
      sp3: this.addChild(new Phaser.TileSprite(game, 5, 18, 0, 10, 'bars', 7)),
      xp: this.addChild(new Phaser.TileSprite(game, 5, 28, 0, 10, 'bars', 3)),
      ex: this.addChild(new Phaser.TileSprite(game, 5, 28, 0, 10, 'bars', 8))
    };
    this.port = this.addChild(new Phaser.Sprite(game, 5, 5, get_costume(this.name, this.forme, this.base.costume)));
    this.port.frame = get_costume(this.name, this.forme, this.base.costume, 'bframe');
    this.text = this.addText(null, "", 7, 10, null, null, 10);
    this.item = this.addChild(
    new Buff(5, this.h * WS - BS, this.base.equip));
    this.create_buffs(BS / 2, this.h * WS);
    this.stats.xp = this.base.stats.xp;
    this.level = this.base.level;
    this.startlevel = this.level;
    this['import']();
    this.calc_stats();
    this.calc_xp();
    this.xpwell = this.stats.xp_next * 0.5;
    this.xpwell_max = this.xpwell;
    this.xpkill = this.xpwell / 4;
    this.stats.hp = this.base.stats.hp;
    this.update_stats();
    this.nameplate = this.addText('font_yellow', this.displayname, 3 * WS, 0);
    this.nameplate.anchor.set(0.5, 1.0);
    this.floatingText = this.addChild(
    new FloatingText());
    this.floatingText.kill();
  }
  Battler.prototype.calc_xp = function(){
    var levelup, xp_cur, xp_next;
    levelup = false;
    xp_cur = levelToXp(this.level);
    xp_next = levelToXp(this.level + 1);
    if (this.stats.xp >= xp_next) {
      this.level = xpToLevel(this.stats.xp);
      this.show_text("Level Up!", 'font_yellow');
      this.calc_stats();
      xp_cur = levelToXp(this.level);
      xp_next = levelToXp(this.level + 1);
      levelup = true;
    }
    this.stats.xp_pro = this.stats.xp - xp_cur;
    this.stats.xp_next = xp_next - xp_cur;
    return levelup;
  };
  Battler.prototype.show_text = function(text, font){
    var ref$;
    if ((ref$ = this.floatingText) != null) {
      ref$.show(this.w / 2 * WS, this.h / 2 * WS, text, font);
    }
  };
  Battler.prototype.reward_xp = function(xp, source){
    var i$, len$, s, ref$, ref1$;
    if (!xp) {
      return;
    }
    if (source instanceof Array) {
      for (i$ = 0, len$ = source.length; i$ < len$; ++i$) {
        s = source[i$];
        this.reward_xp(xp, s);
      }
      return;
    }
    xp = (ref$ = source.xpwell_max * xp / 100) < (ref1$ = source.xpwell) ? ref$ : ref1$;
    source.xpwell -= xp;
    this.reward_xp_weighted(xp, source);
  };
  Battler.prototype.reward_xp_weighted = function(xp, source){
    var diff, xpo, xp_need, xpr, xpor, xpshare, lowestlevel, i$, ref$, len$, h;
    while (xp > 0) {
      diff = Math.max(this.level - source.level, 0);
      xpo = xp;
      xp_need = this.stats.xp_next - this.stats.xp_pro;
      xp *= Math.pow(9 / 11, diff);
      xpr = Math.min(xp, xp_need);
      if (this.level > source.level) {
        xpor = (xpo - xp) * xpr / xp;
        xpshare = [];
        lowestlevel = this.level;
        for (i$ = 0, len$ = (ref$ = heroes).length; i$ < len$; ++i$) {
          h = ref$[i$];
          if (h.dead) {
            continue;
          }
          if (h.level < lowestlevel) {
            lowestlevel = h.level;
            xpshare.length = 0;
          }
          if (h.level === lowestlevel && lowestlevel < this.level) {
            xpshare.push(h);
          }
        }
        if (xpshare.length > 0) {
          for (i$ = 0, len$ = xpshare.length; i$ < len$; ++i$) {
            h = xpshare[i$];
            h.reward_xp_raw(xpor / xpshare.length);
          }
        }
      }
      this.reward_xp_raw(xpr);
      xp -= xpr;
      xp *= Math.pow(11 / 9, diff);
    }
  };
  Battler.prototype.reward_xp_raw = function(xp){
    this.stats.xp += xp;
    switches.gxp += xp * 0.3;
    if (excel_count(this) > 0) {
      this.stats.ex += xp * 1.5 / this.stats.xp_next;
    }
    if (this.calc_xp()) {
      battle.critical = true;
    }
    this.update_stats();
  };
  Battler.prototype.reward_ex = function(ex){
    if (!(ex != null && this.excel_unlocked())) {
      return;
    }
    this.stats.ex += ex / 100;
    if (this.stats.ex <= 0) {
      this.stats.ex = 0;
      this.excel('default', 0);
    }
  };
  Battler.prototype.excel = function(forme, spcost){
    spcost == null && (spcost = 0);
    this.forme = formes[this.name][forme];
    this.port.loadTexture(get_costume(this.name, this.forme, this.base.costume));
    this.port.frame = get_costume(this.name, this.forme, this.base.costume, 'bframe');
    this.stats.sp -= spcost;
    this.sp_check();
    this['import']();
    this.calc_stats();
  };
  Battler.prototype.excel_unlocked = Player.prototype.excel_unlocked;
  Battler.prototype.preUpdate = function(){
    superclass.prototype.preUpdate.apply(this, arguments);
    this.floatingText.preUpdate();
  };
  Battler.prototype.update = function(){
    this.y = this === battle.actor ? 136 : 144;
  };
  Battler.prototype.update_stats = function(){
    var excel, hp_max, lines, text, ref$;
    excel = this.excel_unlocked();
    hp_max = this.get_stat('hp');
    if (this.has_buff(buffs.obscure)) {
      lines = ["???", "???", "???"];
    } else {
      lines = [hpstattext(this.stats.hp * hp_max, hp_max, 5), Math.floor(this.stats.sp * 100) + "%", Math.floor(this.stats.ex * 100) + "%"];
    }
    text = "HP:" + lines[0] + "\nSP:" + lines[1];
    text += excel ? "\nEX:" + lines[2] : '';
    text += "\nLevel " + this.level;
    this.text.change(text);
    this.update_common_stats();
    this.bars.xp.width = this.stats.xp_pro / this.stats.xp_next * this.bars.length;
    this.bars.xp.y = excel ? 38 : 28;
    this.bars.empty.height = excel ? 40 : 30;
    this.bars.ex.width = excel ? ((ref$ = this.stats.ex) < 1 ? ref$ : 1) * this.bars.length : 0;
  };
  Battler.prototype.call_buffs = function(callback){
    var args, res$, i$, to$;
    res$ = [];
    for (i$ = 1, to$ = arguments.length; i$ < to$; ++i$) {
      res$.push(arguments[i$]);
    }
    args = res$;
    battle_mixin.call_buffs.apply(this, arguments);
    if (typeof callback === 'string') {
      this.item[callback].apply(this.item, args);
    } else if (typeof callback === 'function') {
      callback.apply(this.item, args);
    }
  };
  Battler.prototype['import'] = function(){
    this.stats.hp_base = this.forme.hp;
    this.stats.def_base = this.forme.def;
    this.stats.atk_base = this.forme.atk;
    this.stats.speed_base = this.forme.speed;
    this.stats.luck_base = this.forme.luck;
    this.skills = this.base.skills[this.forme.id];
  };
  Battler.prototype['export'] = function(e_hp, e_xp){
    e_hp == null && (e_hp = true);
    e_xp == null && (e_xp = true);
    if (e_hp) {
      this.base.stats.hp = this.stats.hp;
    }
    if (e_xp) {
      this.base.stats.xp = this.stats.xp;
    }
    if (e_xp) {
      this.base.level = this.level;
    }
  };
  Battler.prototype.death = function(){
    this.update_stats();
    this.dead = true;
    this.port.kill();
  };
  Battler.prototype.resurrect = function(){
    this.dead = false;
    this.port.revive();
    this.stats.hp = this.stats.hp_max;
  };
  return Battler;
}(Window));
StatusCard = (function(superclass){
  var prototype = extend$((import$(StatusCard, superclass).displayName = 'StatusCard', StatusCard), superclass).prototype, constructor = StatusCard;
  function StatusCard(x, y, base){
    var barlength;
    this.base = base;
    StatusCard.superclass.call(this, x, y, 6, 5);
    this.name = this.base.name;
    this.forme = formes[this.name]['default'];
    this.stats = clone(battle_mixin.stats);
    barlength = 86;
    this.bars = {
      length: barlength,
      empty: this.addChild(new Phaser.TileSprite(game, 5, 8, barlength, 20, 'bars', 1)),
      hp: this.addChild(new Phaser.TileSprite(game, 5, 8, barlength, 10, 'bars', 2)),
      xp: this.addChild(new Phaser.TileSprite(game, 5, 18, 0, 10, 'bars', 3))
    };
    this.port = this.addChild(new Phaser.Sprite(game, 5, 5 - WS, get_costume(this.name, 0, this.base.costume)));
    this.port.frame = get_costume(this.name, 0, this.base.costume, 'bframe');
    this.item = this.addChild(
    new Buff(5, this.h * WS - BS, this.base.equip));
    this.text = this.addText(null, "", 7, 10, null, null, 10);
    this.hptext = this.addText('font_gray', '', WS * 3 + FW, 10);
    this['import']();
    this.calc_stats();
    this.update_stats();
  }
  StatusCard.prototype.update_stats = function(){
    var hp_max, text;
    hp_max = this.get_stat('hp');
    text = "HP:" + (pause_screen.windows[0].item
      ? stattext(hp_max, 5)
      : hpstattext(this.stats.hp * hp_max, hp_max, 5)) + "\nLevel " + this.level;
    this.text.change(text);
    this.bars.hp.width = this.stats.hp * this.bars.length;
    this.bars.xp.width = this.stats.xp_pro / this.stats.xp_next * this.bars.length;
  };
  StatusCard.prototype.calc_stats = function(){
    var xp_cur, xp_next;
    this.level = this.base.level;
    /*
    @stats.hp_max = new_calc_stat @level, formes[@name]default.hp
    @stats.hp = (@get_stat \hp) * @base.stats.hp
    */
    this.stats.hp = this.base.stats.hp;
    this.stats.xp = this.base.stats.xp;
    xp_cur = levelToXp(this.level);
    xp_next = levelToXp(this.level + 1);
    this.stats.xp_pro = this.stats.xp - xp_cur;
    this.stats.xp_next = xp_next - xp_cur;
    battle_mixin.calc_stats.apply(this, arguments);
    this.item.load_buff(this.base.equip);
    this.port.loadTexture(get_costume(this.name, 0, this.base.costume));
    this.port.frame = get_costume(this.name, 0, this.base.costume, 'bframe');
  };
  StatusCard.prototype['import'] = Battler.prototype['import'];
  StatusCard.prototype.get_stat = battle_mixin.get_stat;
  StatusCard.prototype.call_buffs = function(callback){
    var args, res$, i$, to$;
    res$ = [];
    for (i$ = 1, to$ = arguments.length; i$ < to$; ++i$) {
      res$.push(arguments[i$]);
    }
    args = res$;
    if (typeof callback === 'string') {
      this.item[callback].apply(this.item, args);
    } else if (typeof callback === 'function') {
      callback.apply(this.item, args);
    }
  };
  return StatusCard;
}(Window));
Monster = (function(superclass){
  var prototype = extend$((import$(Monster, superclass).displayName = 'Monster', Monster), superclass).prototype, constructor = Monster;
  function Monster(x, y, id, level){
    var type, xpwell_base, xpkill_base, ref$;
    level == null && (level = 1);
    this.monstertype = type = Monster.types[id] || Monster.types.sanishark;
    Monster.superclass.call(this, game, x, y, type.key);
    implement(this, battle_mixin);
    this.displayname = type.name;
    this.anchor.set(Math.round(this.width * 0.5) / this.width, 1);
    this.level = level;
    xpwell_base = type.xpwell || type.xp || 0;
    xpkill_base = type.xpkill || type.xp / 4 || 0;
    this.xpwell = xp_needed(this.level) * xpwell_base * 2 / 300;
    this.xpwell_max = this.xpwell;
    this.xpkill = xp_needed(this.level) * xpkill_base * 2 / 300;
    this.stats.hp_base = type.hp || 100;
    this.stats.def_base = type.def || 100;
    this.stats.atk_base = type.atk || 100;
    this.stats.speed_base = type.speed || 100;
    this.stats.luck_base = type.luck || 100;
    this.skills = type.skills;
    this.attributes = type.attributes || [];
    this.drops = access(type.drops);
    this.floatingText = this.addChild(
    new FloatingText());
    this.floatingText.kill();
    x = -Math.floor(this.width / 2);
    y = 0;
    this.bars = {
      length: this.width,
      empty: this.addChild(new Phaser.TileSprite(game, x, y, this.width, 20, 'bars', 0)),
      hp: this.addChild(new Phaser.TileSprite(game, x, y, this.width, 10, 'bars', 2)),
      sp0: this.addChild(new Phaser.TileSprite(game, x, y + 10, 0, 10, 'bars', 4)),
      sp1: this.addChild(new Phaser.TileSprite(game, x, y + 10, 0, 10, 'bars', 5)),
      sp2: this.addChild(new Phaser.TileSprite(game, x, y + 10, 0, 10, 'bars', 6)),
      sp3: this.addChild(new Phaser.TileSprite(game, x, y + 10, 0, 10, 'bars', 7))
    };
    this.text = this.addChild(new Text(null, "", x + 1, y + 1));
    this.item = this.addChild(
    new Buff(x - IS / 2, 0, buffs['null']));
    this.create_buffs(-BS * 2.5, y);
    this.calc_stats();
    this.update_stats();
    if ((ref$ = this.monstertype.start) != null) {
      ref$.call(this);
    }
    this.animData = Monster.animData[this.monstertype.key] || {};
    this.animations.add('anim', this.animData.frames, access.call(this, this.animData.speed) || 7, true);
    this.animate();
  }
  Monster.prototype.animate = function(){
    this.animations.play('anim');
    this.animations.currentAnim._frameIndex = Math.floor(Math.random() * this.animations.currentAnim.frameTotal);
  };
  Monster.prototype.damage = undefined;
  Monster.prototype.update = function(){
    if (typeof this.animData.getFrame === 'function') {
      this.animations.frame = this.animData.getFrame.call(this);
    }
  };
  Monster.prototype.preUpdate = function(){
    superclass.prototype.preUpdate.apply(this, arguments);
    this.floatingText.preUpdate();
  };
  Monster.prototype.show_text = function(text, font){
    this.floatingText.show(0, -BS, text, font);
  };
  Monster.prototype.update_stats = function(){
    var lines;
    if (this.has_buff(buffs.obscure)) {
      lines = ["???", "???"];
    } else {
      lines = [Math.ceil(this.stats.hp * 100) + "%", Math.floor(this.stats.sp * 100) + "%"];
    }
    this.text.change("HP:" + lines[0] + "\nSP:" + lines[1]);
    this.update_common_stats();
  };
  Monster.prototype.target = function(){
    var list;
    if (battle.skill.target === 'self') {
      return battle.target = this;
    }
    if (battle.skill.target === 'enemies') {
      return battle.target = enemy_list(true);
    }
    if (battle.skill.target === 'allies') {
      return battle.target = ally_list();
    }
    list = target_list();
    return battle.target = list[Math.floor(Math.random() * list.length)];
  };
  Monster.prototype.attack = function(){
    var skilllist, i$, ref$, len$, skill, j$, to$, that;
    battle.actor = this;
    if (this.plan_skill) {
      battle.skill = this.plan_skill;
      this.plan_skill = null;
    } else if (!(this.monstertype.ai != null && (battle.skill = this.monstertype.ai.call(this)))) {
      skilllist = [];
      for (i$ = 0, len$ = (ref$ = this.skills).length; i$ < len$; ++i$) {
        skill = ref$[i$];
        for (j$ = 1, to$ = skill.weight || 5; j$ <= to$; ++j$) {
          skilllist.push(skill);
        }
      }
      battle.skill = skilllist[Math.floor(Math.random() * skilllist.length)];
    }
    if (battle.skill.sp > this.stats.sp * 100) {
      this.plan_skill = battle.skill;
      this.stats.sp_level += 1;
      return end_turn();
    }
    if ((that = battle.skill.aitarget) != null) {
      that();
    } else {
      this.target();
    }
    use_skill();
  };
  Monster.prototype.death = function(){
    var i$, ref$, len$, drop, item, quantity;
    this.dead = true;
    if (this.drops) {
      for (i$ = 0, len$ = (ref$ = this.drops).length; i$ < len$; ++i$) {
        drop = ref$[i$];
        item = items[drop.item];
        if (item.unique) {
          if (item.quantity > 0) {
            continue;
          }
          if (battle.drops[drop.item]) {
            continue;
          }
        }
        if ((typeof drop.condition !== 'function' || drop.condition()) && item.condition() && 100 - pluckroll_battle() * 100 < drop.chance * [1, 1.5, 2][battle.encounter.toughness]) {
          quantity = Math.round(drop.quantity * [1, 2, 4][battle.encounter.toughness]);
          if (item.unique) {
            quantity = 1;
          }
          if (battle.drops[drop.item]) {
            battle.drops[drop.item].q += quantity;
          } else {
            battle.drops[drop.item] = {
              item: items[drop.item],
              q: quantity
            };
          }
        }
      }
    }
    if (typeof this.monstertype.ondeath === 'function') {
      this.monstertype.ondeath.call(this);
    }
    this.destroy();
  };
  Monster.prototype.destroy = function(){
    var index;
    index = monsters.indexOf(this);
    if (index > -1) {
      monsters.splice(index, 1);
    }
    superclass.prototype.destroy.apply(this, arguments);
  };
  return Monster;
}(Phaser.Sprite));
function drop_item(item, q){
  q == null && (q = 1);
  if (game.state.current !== 'battle') {
    return;
  }
  if (battle.drops[item]) {
    battle.drops[item].q += q;
  } else {
    battle.drops[item] = {
      item: items[item],
      q: q
    };
  }
}
Animation = (function(superclass){
  var prototype = extend$((import$(Animation, superclass).displayName = 'Animation', Animation), superclass).prototype, constructor = Animation;
  function Animation(){
    var key, ref$, anim, that;
    Animation.superclass.call(this, game, 0, 0, 'anim_slash');
    for (key in ref$ = animations) {
      anim = ref$[key];
      this.animations.add(key, anim.frames, (that = anim.speed) ? that : 20, false);
    }
    this.anchor.set(0.5);
    this.kill();
    this.events.onAnimationComplete.add(this.animationComplete, this);
  }
  Animation.prototype.animationComplete = function(){
    process_callbacks.call(this, this.callback);
    this.kill();
  };
  Animation.prototype.play = function(animation, x, y, t){
    var targeter, ref$, side, anim;
    animation == null && (animation = 'slash');
    this.x = x;
    this.y = y;
    t == null && (t = battle.target);
    if (t instanceof Battler) {
      this.x += t.w / 2 * WS;
      this.y += t.h / 2 * WS;
    } else if (t instanceof Monster) {
      this.y -= t.height / 2;
    } else if (x == null || y == null) {
      targeter = battle.skill || battle.item;
      this.x = HWIDTH;
      if ((ref$ = targeter.target) === 'enemies' || ref$ === 'allies') {
        side = 1;
        if (battle.actor instanceof Monster) {
          side *= -1;
        }
        if (targeter.target === 'enemies') {
          side *= -1;
        }
        if (side < 0) {
          this.y = 80;
        } else {
          this.y = 192;
        }
      }
    }
    anim = animations[animation];
    this.revive();
    this.anchor.set.apply(this.anchor, anim.anchor != null
      ? anim.anchor instanceof Array
        ? anim.anchor
        : [anim.anchor]
      : [0.5]);
    this.loadTexture(anim.sprite);
    this.animations.play(animation);
  };
  Animation.prototype.callback = function(){};
  return Animation;
}(Phaser.Sprite));
Buff = (function(superclass){
  var prototype = extend$((import$(Buff, superclass).displayName = 'Buff', Buff), superclass).prototype, constructor = Buff;
  function Buff(x, y, buff){
    buff == null && (buff = buffs['null']);
    Buff.superclass.call(this, game, x, y, access(buff.icon));
    this.anchor.set(0, 1);
    this.load_buff(buff);
    this.get_stat = buff_get_stat;
  }
  Buff.prototype.load_buff = function(buff, inflictor){
    var ref$, icon, i$, ref1$, len$, key, that;
    buff == null && (buff = buffs['null']);
    this.inflictor = inflictor
      ? inflictor
      : game.state.current === 'battle' ? battle.actor : null;
    if (typeof this.onremedy == 'function') {
      this.onremedy();
    }
    this.base = buff;
    if ((ref$ = this.parent) != null && (typeof ref$.has_buff == 'function' && ref$.has_buff(buffs.obscure))) {
      if (this.key !== 'buffs') {
        this.loadTexture('buffs');
      }
      this.frame = 2;
      setrow(this, 4);
    } else {
      icon = access(buff.icon) || 'buffs';
      if (icon !== this.key) {
        this.loadTexture(icon);
      }
      this.frame = buff.iconx || 0;
      setrow(this, buff.icony || 0);
    }
    this.name = buff.name || 'null';
    this.id = buff.id || 'null';
    this.negative = buff.negative || false;
    for (i$ = 0, len$ = (ref1$ = ['step', 'attack', 'battle_end', 'start', 'end', 'turn', 'onremedy']).length; i$ < len$; ++i$) {
      key = ref1$[i$];
      this[key] = (that = buff[key]) != null
        ? that
        : fn$;
    }
    for (i$ = 0, len$ = (ref1$ = ['ondamage', 'mod_hp', 'mod_def', 'mod_atk', 'mod_speed', 'mod_luck']).length; i$ < len$; ++i$) {
      key = ref1$[i$];
      this[key] = (that = buff[key]) != null
        ? that
        : fn1$;
    }
    this.attributes = buff.attributes || [];
    this.skill = buff.skill || null;
    this.revive();
    this.start();
    function fn$(){}
    function fn1$(s){
      return s;
    }
  };
  Buff.prototype.remedy = function(){
    this.load_buff(buffs['null']);
  };
  Buff.prototype.damage = function(n){
    if (!this.inflictor) {
      return;
    }
    this.parent.damage(calc_damage(this.inflictor, this.parent, n), false, this.inflictor);
  };
  Buff.prototype.kill = function(){
    var ret, ref$;
    ret = superclass.prototype.kill.apply(this, arguments);
    if ((ref$ = this.parent) != null && (typeof ref$.has_buff == 'function' && ref$.has_buff(buffs.obscure))) {
      this.visible = true;
    }
    return ret;
  };
  return Buff;
}(Phaser.Sprite));
function buff_get_stat(key){
  var stat;
  stat = this.parent.stats[key === 'hp' ? key + "_max" : key];
  if (in$(key, buff_get_stat.gotten)) {
    return stat;
  }
  buff_get_stat.gotten.push(key);
  this.parent.call_buffs(function(){
    stat = this["mod_" + key](stat);
  });
  return stat;
}
buff_get_stat.gotten = [];
buffs = {};
buffs['null'] = {
  name: 'null',
  start: function(){
    this.kill();
  }
};
buffs.poison = {
  name: 'poison',
  start: function(){
    this.temporal = this.inflictor instanceof Battler;
    this.duration = in$('poison', this.parent.attributes) ? 1 : 5;
  },
  step: function(){
    this.damage(20 * deltam);
    if (this.temporal) {
      this.duration -= deltam;
    }
    if (this.duration <= 0) {
      this.remedy();
    }
  },
  negative: true,
  attributes: ['disease']
};
buffs.regen = {
  name: 'regen',
  iconx: 3,
  start: function(){
    this.duration = 10;
  },
  step: function(){
    this.duration -= deltam;
    heal_percent(this.parent, 0.05 * deltam, false);
    if (this.duration <= 0) {
      this.remedy();
    }
  },
  negative: false
};
buffs.healblock = {
  name: 'healblock',
  iconx: 2,
  icony: 3,
  negative: true,
  start: function(){
    this.duration = 5;
  },
  step: function(){
    this.duration -= deltam;
    if (this.duration <= 0) {
      this.remedy();
    }
  },
  nostack: true,
  attributes: ['curse']
};
buffs.isolated = {
  name: 'isolated',
  iconx: 3,
  icony: 3,
  negative: true,
  mod_speed: function(s){
    return s * 0.9;
  },
  start: function(){
    this.duration = 5;
  },
  step: function(){
    this.duration -= deltam;
    if (this.duration <= 0) {
      this.remedy();
    }
  },
  nostack: true,
  attributes: ['curse']
};
buffs.bloodboost = {
  name: 'bloodboost',
  iconx: 1,
  icony: 3,
  mod_atk: function(s){
    var bleedcount, i$, ref$, len$, buff;
    bleedcount = 0;
    for (i$ = 0, len$ = (ref$ = this.parent.buffs).length; i$ < len$; ++i$) {
      buff = ref$[i$];
      if (buff.name === 'bleed') {
        bleedcount++;
      }
    }
    return s + s * 0.1 * bleedcount;
  },
  mod_speed: function(s){
    var bleedcount, i$, ref$, len$, buff;
    bleedcount = 0;
    for (i$ = 0, len$ = (ref$ = this.parent.buffs).length; i$ < len$; ++i$) {
      buff = ref$[i$];
      if (buff.name === 'bleed') {
        bleedcount++;
      }
    }
    return s + s * bleedcount;
  }
};
buffs.bleed = {
  name: 'bleed',
  iconx: 2,
  start: function(){
    this.duration = 2;
    this.severity = this.inflictor instanceof Battler && this.parent instanceof Battler ? 20 : 50;
    this.extended = false;
  },
  step: function(){
    this.duration -= deltam;
    this.damage(this.severity * deltam);
    if (this.duration <= 0) {
      this.remedy();
    }
  },
  negative: true,
  attributes: ['disease']
};
buffs.coagulate = {
  name: 'coagulate',
  icony: 2,
  negative: true,
  mod_speed: function(s){
    return s * 0.95;
  },
  attributes: ['disease']
};
buffs.charmed = {
  name: 'charmed',
  iconx: 1,
  mod_atk: function(s){
    return s * 0.85;
  },
  mod_def: function(s){
    return s * 0.90;
  },
  mod_speed: function(s){
    return s * 0.98;
  },
  negative: true,
  nostack: true,
  attributes: ['curse']
};
buffs.decoy = {
  name: 'decoy',
  iconx: 5,
  icony: 3,
  nostack: true
};
buffs.weak = {
  name: 'weak',
  iconx: 5,
  mod_atk: function(s){
    return s * 0.75;
  },
  mod_def: function(s){
    return s * 0.75;
  },
  negative: true,
  nostack: true
};
buffs.wanko = {
  name: 'wanko',
  iconx: 1,
  icony: 4,
  mod_atk: function(s){
    return s * 1.2;
  },
  mod_speed: function(s){
    return s * 1.2;
  },
  mod_luck: function(s){
    return s * 1.2;
  }
};
buffs.seizure = {
  name: 'seizure',
  iconx: 2,
  icony: 2,
  start: function(){
    this.duration = 2;
  },
  step: function(){
    this.duration -= deltam;
    if (this.duration <= 0) {
      this.remedy();
    }
    this.parent.stats.sp += ((Math.random() * 3 | 0) - 1) * deltam;
  },
  mod_speed: function(s){
    return s * 0.1;
  },
  negative: true,
  nostack: true,
  attributes: ['disease']
};
buffs.burn = {
  name: 'burn',
  iconx: 2,
  icony: 1,
  start: function(){
    var i$, ref$, len$, buff;
    this.intensity = 3;
    for (i$ = 0, len$ = (ref$ = this.parent.buffs).length; i$ < len$; ++i$) {
      buff = ref$[i$];
      if (buff.name === 'burn' && buff.intensity < 2) {
        buff.intensity = 2;
        buff.duration = 2;
        buff.frame = 1;
      }
    }
    for (i$ = 0, len$ = (ref$ = this.parent.buffs).length; i$ < len$; ++i$) {
      buff = ref$[i$];
      if (buff.name === 'chill') {
        buff.remedy();
        break;
      }
    }
    this.duration = 1;
    this.temporal = this.inflictor instanceof Battler;
    this.plant = in$('plant', this.parent.attributes);
    this.supereffective = this.plant || in$('fish', this.parent.attributes) || (this.parent.item && this.parent.item.base === items.woodshield);
    if (this.supereffective) {
      this.temporal = false;
    }
  },
  mod_def: function(s){
    return s / (1 + this.plant);
  },
  step: function(){
    if (this.temporal || this.intensity > 1) {
      this.duration -= deltam;
    }
    if (this.duration <= 0) {
      this.intensity--;
      this.duration = 4 - this.intensity;
      if (this.intensity <= 0) {
        this.remedy();
      } else {
        this.frame = this.intensity - 1;
      }
    }
    this.damage(10 * deltam * this.intensity * (1 + this.supereffective));
  },
  negative: true
};
buffs.blister = {
  name: 'blister',
  iconx: 1,
  icony: 2,
  step: function(){
    this.parent.damage(this.parent.stats.hp_max / 20 * deltam);
  },
  attack: function(){
    this.parent.damage(10);
  },
  negative: true,
  attributes: ['disease']
};
buffs.drown = {
  name: 'drown',
  iconx: 5,
  icony: 2,
  start: function(){
    var i$, ref$, len$, buff;
    this.duration = 2;
    for (i$ = 0, len$ = (ref$ = this.parent.buffs).length; i$ < len$; ++i$) {
      buff = ref$[i$];
      if (buff === this) {
        continue;
      }
      if (buff.name === 'drown') {
        buff.load_buff(buffs.chill);
      }
    }
  },
  step: function(){
    this.duration -= deltam;
    this.damage(50 * deltam);
    if (this.duration <= 0) {
      this.load_buff(buffs.chill);
    }
  },
  mod_speed: function(s){
    return 0;
  },
  negative: true
};
buffs.licked = {
  name: 'licked',
  iconx: 5,
  icony: 2,
  start: function(){
    this.duration = 2;
  },
  step: function(){
    this.duration -= deltam;
    if (this.duration <= 0) {
      this.remedy();
    }
  },
  mod_speed: function(s){
    return 0;
  },
  negative: true
};
buffs.chill = {
  name: 'chill',
  iconx: 4,
  icony: 2,
  start: function(){
    var chillcount, burncount, i$, ref$, len$, buff;
    this.severity = this.inflictor instanceof Battler ? 0.85 : 0.65;
    this.duration = this.inflictor instanceof Battler ? 10 : Infinity;
    chillcount = 0;
    burncount = 0;
    for (i$ = 0, len$ = (ref$ = this.parent.buffs).length; i$ < len$; ++i$) {
      buff = ref$[i$];
      if (buff.name === 'chill') {
        chillcount++;
      }
      if (buff.name === 'burn') {
        buff.intensity -= 1;
        buff.duration = 4 - buff.intensity;
        if (buff.intensity <= 0) {
          buff.remedy();
        } else {
          buff.frame = buff.intensity - 1;
          burncount++;
        }
      }
    }
    if (chillcount === 5 && this.parent instanceof Battler) {
      this.parent.damage(this.parent.stats.hp_max);
    }
    if (burncount > 0) {
      this.remedy();
    }
  },
  mod_speed: function(s){
    return s * this.severity;
  },
  step: function(){
    this.duration -= deltam;
    if (this.duration <= 0) {
      this.remedy();
    }
  },
  negative: true
};
buffs.slow = {
  name: 'slow',
  iconx: 5,
  icony: 4,
  start: function(){
    this.severity = this.inflictor instanceof Battler ? 0.85 : 0.65;
  },
  mod_speed: function(s){
    return s * this.severity;
  },
  nostack: true,
  negative: true,
  attributes: ['curse']
};
buffs.curse = {
  name: 'curse',
  iconx: 5,
  start: function(){
    this.severity = this.inflictor instanceof Battler ? 0.75 : 0.5;
  },
  mod_hp: function(s){
    return s * this.severity;
  },
  negative: true,
  nostack: true,
  attributes: ['curse']
};
buffs.fever = {
  name: 'fever',
  iconx: 4,
  icony: 1,
  mod_speed: function(s){
    return s * 1.1;
  },
  negative: false,
  attributes: ['disease']
};
buffs.speed = {
  name: 'speed',
  iconx: 4,
  mod_speed: function(s){
    return s * 2;
  },
  negative: false,
  start: function(){
    this.duration = 4;
  },
  step: function(){
    this.duration -= deltam;
    if (this.duration <= 0) {
      this.remedy();
    }
  }
};
buffs.aids = {
  name: 'aids',
  iconx: 3,
  icony: 2,
  mod_def: function(s){
    return s / 3;
  },
  negative: true,
  attributes: ['disease']
};
buffs.twinflight = {
  name: 'twinflight',
  iconx: 4,
  mod_speed: function(s){
    if (this.inflictor.has_buff(buffs.twinflight)) {
      return s;
    }
    return this.inflictor.get_stat('speed');
  },
  start: function(){
    this.duration = 4;
  },
  step: function(){
    this.duration -= deltam;
    if (this.duration <= 0) {
      this.remedy();
    }
  }
};
buffs.sabotage = {
  name: 'sabotage',
  icony: 4,
  mod_atk: function(s){
    return s / 2;
  },
  start: function(){
    this.duration = 1.5;
  },
  step: function(){
    this.duration -= deltam;
    if (this.duration <= 0) {
      this.remedy();
    }
  },
  negative: true,
  nostack: true,
  attributes: ['curse']
};
buffs.baited = {
  name: 'baited',
  icon: 'item_misc',
  iconx: 1,
  icony: 1,
  start: function(){
    this.duration = 2;
  },
  step: function(){
    this.duration -= deltam;
    if (this.duration <= 0) {
      this.remedy();
    }
  },
  mod_speed: function(s){
    return 0;
  },
  negative: true
};
buffs.dizzy = {
  name: 'dizzy',
  icony: 3,
  start: function(){
    this.duration = 2;
  },
  step: function(){
    this.duration -= deltam;
    if (this.duration <= 0) {
      this.remedy();
    }
  },
  negative: true
};
buffs.dazed = {
  name: 'dazed',
  icony: 3,
  start: function(){
    this.duration = 1;
  },
  step: function(){
    this.duration -= deltam;
    if (this.duration <= 0) {
      this.remedy();
    }
  },
  mod_speed: function(s){
    return s / 2;
  },
  negative: true
};
buffs.swarm = {
  name: 'swarm',
  iconx: 3,
  icony: 4,
  start: function(){
    this.duration = 1;
  },
  step: function(){
    var jumplist, jumplist2, i$, len$, battler;
    this.duration -= deltam;
    this.damage(20 * deltam);
    if (this.duration <= 0) {
      if (this.parent.has_buff(buffs.isolated)) {
        return;
      }
      jumplist = this.parent instanceof Battler
        ? hero_list()
        : monster_list();
      jumplist2 = [];
      for (i$ = 0, len$ = jumplist.length; i$ < len$; ++i$) {
        battler = jumplist[i$];
        if (battler.has_buff(buffs.isolated) || !battler.has_buff(buffs['null'])) {
          continue;
        }
        jumplist2.push(battler);
      }
      if (!jumplist2.length) {
        return;
      }
      this.remedy();
      jumplist2[Math.random() * jumplist2.length | 0].inflict(buffs.swarm);
    }
  },
  negative: true,
  attributes: ['disease']
};
buffs.swarmdrain = {
  name: 'swarmdrain',
  iconx: 4,
  icony: 4,
  start: function(){
    this.duration = 3;
  },
  step: function(){
    var enemylist, i$, len$, battler, j$, ref$, len1$, buff;
    this.duration -= deltam;
    enemylist = this.parent instanceof Battler
      ? monster_list()
      : hero_list();
    for (i$ = 0, len$ = enemylist.length; i$ < len$; ++i$) {
      battler = enemylist[i$];
      for (j$ = 0, len1$ = (ref$ = battler.buffs).length; j$ < len1$; ++j$) {
        buff = ref$[j$];
        if (buff.name === 'swarm') {
          this.damage(-10 * deltam);
        }
      }
    }
    if (this.duration <= 0) {
      this.remedy();
    }
  }
};
buffs.obscure = {
  name: 'obscure',
  iconx: 2,
  icony: 4,
  start: function(){
    var i$, ref$, len$, buff;
    this.duration = 6;
    for (i$ = 0, len$ = (ref$ = this.parent.buffs).length; i$ < len$; ++i$) {
      buff = ref$[i$];
      buff.visible = true;
      if (buff.key !== 'buffs') {
        buff.loadTexture('buffs');
      }
      buff.frame = 2;
      setrow(buff, 4);
    }
  },
  onremedy: function(){
    var i$, ref$, len$, buff, icon;
    for (i$ = 0, len$ = (ref$ = this.parent.buffs).length; i$ < len$; ++i$) {
      buff = ref$[i$];
      if (buff.base === buffs['null']) {
        buff.visible = false;
      }
      icon = access(buff.base.icon) || 'buffs';
      if (icon !== buff.key) {
        buff.loadTexture(icon);
      }
      buff.frame = buff.base.iconx || 0;
      setrow(buff, buff.base.icony || 0);
    }
  },
  step: function(){
    this.duration -= deltam;
    if (this.duration <= 0) {
      this.remedy();
    }
  }
};
nodes = {};
doodads = {};
Doodad = (function(superclass){
  var prototype = extend$((import$(Doodad, superclass).displayName = 'Doodad', Doodad), superclass).prototype, constructor = Doodad;
  function Doodad(x, y, key, name, collide){
    key == null && (key = 'empty');
    collide == null && (collide = true);
    if (!switches.soulcluster && getmapdata('hasnight')) {
      switch (key) {
      case '1x1':
        key = '1x1_night';
        break;
      case '1x2':
        key = '1x2_night';
      }
    }
    Doodad.superclass.call(this, game, x, y, key);
    if (name) {
      this.name = name;
      doodads[name] = this;
    }
    if (collide) {
      game.physics.arcade.enable(this, false);
      if (!key) {
        this.body.setSize(TS, TS);
      }
    }
    constructor.list.push(this);
  }
  Doodad.prototype.simple_animation = function(speed, loops){
    speed == null && (speed = 7);
    this.animations.add('simple', null, speed, true);
    this.animations.play('simple', null, loops);
  };
  Doodad.prototype.random_frame = function(){
    this.animations.currentAnim.setFrame(Math.random() * this.animations.currentAnim.frameTotal | 0, true);
  };
  Doodad.list = [];
  Doodad.clear = function(){
    var i$, ref$, len$, item;
    nodes = {};
    doodads = {};
    for (i$ = 0, len$ = (ref$ = constructor.list).length; i$ < len$; ++i$) {
      item = ref$[i$];
      item.destroy();
    }
    constructor.list = [];
  };
  Doodad.prototype.destroy = function(){
    superclass.prototype.destroy.apply(this, arguments);
    updatelist.remove(this);
  };
  return Doodad;
}(Phaser.Sprite));
Treasure = (function(superclass){
  var prototype = extend$((import$(Treasure, superclass).displayName = 'Treasure', Treasure), superclass).prototype, constructor = Treasure;
  function Treasure(x, y, name, item, quantity, mimic, properties){
    this.item = item;
    this.quantity = quantity;
    this.mimic = mimic != null ? mimic : false;
    properties == null && (properties = {});
    Treasure.superclass.call(this, x, y, '1x1');
    this.name = name;
    this.toughness = properties.toughness;
    constructor.list.push(this);
  }
  Treasure.prototype.interact = function(){
    if (this.mimic) {
      temp.mimic = {
        item: this.item,
        quantity: this.quantity,
        name: this.name
      };
      start_battle(encounter.mimic, this.toughness);
      return;
    }
    switches[this.name] = true;
    acquire(items[this.item], this.quantity);
    this.destroy();
  };
  Treasure.list = [];
  Treasure.clear = function(){
    var i$, ref$, len$, item;
    for (i$ = 0, len$ = (ref$ = constructor.list).length; i$ < len$; ++i$) {
      item = ref$[i$];
      item.destroy();
    }
    constructor.list = [];
  };
  return Treasure;
}(Actor));
Trigger = (function(superclass){
  var prototype = extend$((import$(Trigger, superclass).displayName = 'Trigger', Trigger), superclass).prototype, constructor = Trigger;
  function Trigger(x, y, w, h, ow, oh){
    Trigger.superclass.call(this, game, x, y, 'empty');
    game.physics.arcade.enable(this, false);
    this.body.setSize(w, h, ow, oh);
    this.body.immovable = true;
    constructor.list.push(this);
  }
  Trigger.list = [];
  Trigger.clear = function(){
    var i$, ref$, len$, item;
    for (i$ = 0, len$ = (ref$ = constructor.list).length; i$ < len$; ++i$) {
      item = ref$[i$];
      item.destroy();
    }
  };
  Trigger.prototype.process = function(){};
  Trigger.prototype.handle = function(){};
  return Trigger;
}(Phaser.Sprite));
function initUpdate(o){
  o.preUpdate();
  o.postUpdate();
}
holiday = {};
holiday.now = new Date();
holiday.month = holiday.now.getMonth() + 1;
holiday.date = holiday.now.getDate();
holiday.easter = holiday.month === 3 && holiday.date >= 22 || holiday.month === 4 && holiday.date <= 25;
holiday.halloween = holiday.month === 10;
holiday.turkey = holiday.month === 11;
holiday.christmas = holiday.month === 12;
function map_objects(){
  var flower_count, oil_count, treasure_count, mimic_count, goop_count, i$, ref$, len$, o, object, dood, ref1$, check, trig, portal, j$, len1$, key, ref2$, name, rect;
  flower_count = 0;
  oil_count = 0;
  treasure_count = 0;
  mimic_count = 0;
  goop_count = 0;
  for (i$ = 0, len$ = (ref$ = map.object_cache).length; i$ < len$; ++i$) {
    o = ref$[i$];
    object = {
      x: o.x | 0,
      y: o.y - TS | 0,
      type: o.type,
      name: o.name,
      properties: o.properties,
      width: o.width,
      height: o.height
    };
    switch (object.type) {
    case 'npc':
      create_npc(object, object.name);
      nodes[object.name] = object;
      break;
    case 'flame':
      if (!require_switch(object)) {
        continue;
      }
      dood = actors.addChild(
      new Doodad(object.x + HTS, object.y + TS, 'flame', null, false));
      dood.anchor.set(0.5, 1.0);
      dood.simple_animation(7);
      dood.random_frame();
      updatelist.push(dood);
      break;
    case 'boat':
      dood = actors.addChild(
      new Doodad(object.x + HTS, object.y + TS, 'boat', null, true));
      dood.anchor.set(0.5, 1.0);
      dood.body.setSize(TS * 2, TS);
      initUpdate(dood);
      Doodad.boat = dood;
      break;
    case 'pest':
      dood = carpet.addChild(
      new Doodad(object.x + HTS, object.y + TS, 'pest', null, false));
      dood.anchor.set(0.5, 1.0);
      dood.frame = switches.soulcluster ? 0 : 2;
      break;
    case 'anim':
      dood = actors.addChild(
      new Doodad(object.x + HTS, object.y + TS, object.name, null, object.properties.block));
      dood.anchor.set(0.5, 1.0);
      dood.simple_animation((ref1$ = object.properties.speed) != null ? ref1$ : 5);
      dood.random_frame();
      dood.body.setSize(+((ref1$ = object.properties.xsize) != null ? ref1$ : HTS), +((ref1$ = object.properties.ysize) != null ? ref1$ : HTS));
      if (object.properties.flip != null) {
        dood.scale.x = -1;
      }
      updatelist.push(dood);
      break;
    case 'player_start':
    case 'node':
      nodes[object.name] = object;
      break;
    case 'checkpoint':
      if (!require_switch(object)) {
        continue;
      }
      nodes[object.name] = object;
      check = carpet.addChild(
      new Doodad(object.x, object.y, 'pent', object.name));
      trig = triggers.addChild(
      new Trigger(object.x, object.y, TS, TS, 0, 0));
      check.flame = trig.flame = check.addChild(
      new Doodad(0, 0, 'pent_fire', null, false));
      updatelist.push(check);
      trig.flame.simple_animation(7);
      check.anchor.set(0.25);
      trig.flame.anchor.set(0.25);
      trig.name = check.name = object.name;
      trig.process = fn$;
      trig.handle = fn1$;
      trig.flame.visible = !trig.process();
      if (switches.defeated && switches.checkpoint === object.name && switches.checkpoint_map === switches.map) {
        trig.flame.visible = true;
      }
      break;
    case 'portal':
      nodes[object.name] = object;
      portal = triggers.addChild(
      new Trigger(object.x, object.y, 10, 10, 3, 3));
      initUpdate(portal);
      portal.name = object.name;
      portal.isportal = true;
      for (j$ = 0, len1$ = (ref1$ = ['pdir', 'pmap', 'pport', 'item_lock', 'switch_lock', 'lock_scenario', 'sfx']).length; j$ < len1$; ++j$) {
        key = ref1$[j$];
        portal[key] = object.properties[key];
      }
      portal.handle = fn2$;
      break;
    case 'nospawn':
      spawn_controller.nospawn.push(object);
      break;
    case 'spawn':
      spawn_controller.spawners.push(object);
      break;
    case 'sign':
      if (!require_switch(object)) {
        continue;
      }
      create_doodad(object, carpet).interact = fn3$;
      break;
    case 'carpet':
      create_doodad(object, carpet);
      break;
    case 'trigger':
      new Trigger(object.x, object.y, TS, TS, 0, 0);
      break;
    case 'scenario':
      if (!require_switch(object)) {
        continue;
      }
      nodes[object.name] = object;
      trig = triggers.addChild(
      new Trigger(object.x, object.y, TS, TS, 0, 0));
      trig.name = object.name;
      trig.condition = object.properties.condition;
      if (object.properties.width) {
        trig.body.width = object.properties.width * TS;
      }
      if (object.properties.height) {
        trig.body.height = object.properties.height * TS;
      }
      initUpdate(trig);
      trig.properties = object.properties;
      trig.process = fn4$;
      trig.handle = fn5$;
      break;
    case 'flower':
      if (Date.now() - switches["flower_" + switches.map + "_" + flower_count] < 43200000) {
        flower_count++;
      } else {
        delete switches["flower_" + switches.map + "_" + flower_count];
        create_tree(object, (ref1$ = object.properties.sheet) != null ? ref1$ : '1x1', (ref1$ = object.properties.frame) != null ? ref1$ : 8, true, 'flower');
      }
      break;
    case 'oil':
      if (Date.now() - switches["oil_" + switches.map + "_" + oil_count] < 43200000) {
        create_tree(object, '1x1', 14, true, 'oil_empty');
      } else {
        delete switches["oil_" + switches.map + "_" + oil_count];
        create_tree(object, '1x1', 15, true, 'oil');
      }
      break;
    case 'tree':
      create_tree(object, (ref1$ = object.properties.sheet) != null ? ref1$ : '1x2', (ref1$ = object.properties.frame) != null ? ref1$ : 2, true, true);
      break;
    case 'tree2':
      create_tree(object, (ref1$ = object.properties.sheet) != null ? ref1$ : '1x2', (ref1$ = object.properties.frame) != null ? ref1$ : 2, true, false);
      break;
    case 'foliage':
      create_tree(object, (ref1$ = object.properties.sheet) != null ? ref1$ : '1x2', (ref1$ = object.properties.frame) != null ? ref1$ : 3, false);
      break;
    case 'fringe':
      dood = create_fringe(object, (ref1$ = object.properties.sheet) != null ? ref1$ : '2x2', (ref1$ = object.properties.frame) != null ? ref1$ : 0);
      break;
    case 'pylon':
      create_tree(object, '1x2', object.name === 'pylon2' && switches.sleepytime && !switches.pylonfixed ? 1 : 0, true);
      break;
    case 'falsewall':
      dood = actors.addChild(
      new Doodad(object.x, object.y + TS, object.properties.sheet, null, true));
      if (object.properties.frame != null) {
        dood.frame = +object.properties.frame;
      } else if (object.properties.frame_x != null && object.properties.frame_y != null) {
        dood.crop(new Phaser.Rectangle(TS * object.properties.frame_x, TS * object.properties.frame_y, TS, TS));
      }
      dood.x += dood.width / 2;
      dood.anchor.set(0.5, 1.0);
      if ((ref1$ = dood.body) != null) {
        ref1$.setSize(TS, TS);
      }
      initUpdate(dood);
      dood.falsewall = object.properties.on_switch || object.properties.off_switch;
      dood.properties = object.properties;
      if (switches[object.properties.on_switch] || (object.properties.on_switch == null && !switches[object.properties.off_switch])) {
        dood.revive();
      } else {
        dood.kill();
      }
      if (switches[object.properties.on_switch] && switches[object.properties.off_switch]) {
        dood.kill();
      }
      break;
    case 'switch':
      dood = create_tree(object, object.properties.sheet, 0, true);
      dood.properties = object.properties;
      dood.frame = switches[object.properties['switch']]
        ? +object.properties.frame2
        : +object.properties.frame;
      dood.body.setSize(+((ref2$ = object.properties.xsize) != null ? ref2$ : HTS), +((ref2$ = object.properties.ysize) != null ? ref2$ : HTS));
      dood.interact = fn6$;
      break;
    case 'holiday':
      create_holiday(object);
      break;
    case 'item':
      name = "treasure_" + switches.map + "_" + (treasure_count++);
      if (switches[name]) {
        break;
      }
      actors.addChild(
      new Treasure(object.x + HTS, object.y + TS, name, object.properties.item, ~~object.properties.quantity));
      break;
    case 'mimic':
      name = "mimic_" + switches.map + "_" + (mimic_count++);
      if (switches[name]) {
        break;
      }
      actors.addChild(
      new Treasure(object.x + HTS, object.y + TS, name, object.properties.item, ~~object.properties.quantity, true, object.properties));
      break;
    case 'waygate':
      dood = create_tree(object, '1x2', 13, true, 'waygate');
      break;
    case 'finaldoor':
    case 'labdoor':
      dood = actors.addChild(
      new Doodad(object.x + HTS, object.y + TS, '3x3', 'finaldoor', true));
      dood.frame = 4;
      dood.anchor.set(0.5, 1);
      dood.body.setSize(TS * 3, TS);
      initUpdate(dood);
      dood.properties = object.properties;
      dood.properties.labdoor = true;
      if (object.type === 'finaldoor' && switches.finaldoor || switches[object.properties.open] || switches.doorswitch === object.properties.open || switches.beat_game) {
        dood.frame = 5;
        dood.body.enable = false;
      }
      break;
    case 'morgue':
      dood = carpet.addChild(
      new Doodad(object.x, object.y, 'lab_tiles', null, true));
      dood.name = 'morgue';
      dood.crop(new Phaser.Rectangle(0, TS * 13, TS, TS));
      dood.body.setSize(TS, TS);
      dood.properties = object.properties;
      if (!session.morgue_next) {
        session.morgue_next = 1;
      }
      if (switches[object.properties.open] || (session.morgue_next > object.properties.order && session.morgue_set === object.properties.set)) {
        rect = new Phaser.Rectangle((object.properties.last ? 2 : 1) * TS, TS * 13, TS, TS);
        dood.open = true;
        dood.crop(rect);
      }
      dood.interact = fn7$;
      initUpdate(dood);
      break;
    case 'goop':
      name = "goop_" + switches.map + "_" + (goop_count++);
      if (switches[name]) {
        break;
      }
      dood = actors.addChild(
      new Doodad(object.x + HTS + TS, object.y + TS, '3x3', null, false));
      dood.collider = actors.addChild(
      new Doodad(object.x + 2, object.y - 20, null, null, true));
      dood.collider.base = dood;
      dood.frame = 6;
      dood.anchor.set(0.5, 1);
      dood.collider.body.setSize(44, 36);
      dood.name = name;
      dood.collider.interact = fn8$;
      dood.interact = fn9$;
      dood.origin = {
        x: dood.x,
        y: dood.y
      };
      dood.goal = {
        x: dood.x,
        y: dood.y,
        s: Math.random() * 0.2 + 0.9
      };
      dood.timer = Date.now() - (Math.random() * 5000 | 0);
      dood.prev = {
        x: dood.x,
        y: dood.y,
        s: 1
      };
      dood.updatePaused = dood.update = fn10$;
      updatelist.push(dood);
      break;
    case 'gallows':
      dood = actors.addChild(
      new Doodad(object.x + TS, object.y + TS, '2x3', null, true));
      dood.frame = 1;
      dood.anchor.set(0.5, 1);
      dood.body.setSize(32, 23);
      initUpdate(dood);
    }
  }
  function create_fringe(object, sheet, frame){
    var tree;
    tree = fringe.addChild(
    new Doodad(object.x, object.y + TS, sheet, null, false));
    tree.x += tree.width / 2;
    tree.anchor.set(0.5, 1.0);
    initUpdate(tree);
    tree.frame = +frame;
    return tree;
  }
  function create_tree(object, sheet, frame, collide, sap){
    var tree, ref$;
    sap == null && (sap = false);
    tree = actors.addChild(
    new Doodad(object.x, object.y + TS, sheet, null, collide));
    tree.x += tree.width / 2;
    tree.anchor.set(0.5, 1.0);
    if ((ref$ = tree.body) != null) {
      ref$.setSize(TS, TS);
    }
    tree.frame = +frame;
    tree.properties = object.properties;
    switch (sap) {
    case true:
      tree.interact = function(){
        var q;
        if (!(items.vial.quantity > 0)) {
          say('', "Glass vials can be used to collect Pine Sap.");
          return;
        }
        say('', "Collect Pine Sap?");
        q = items.vial.quantity;
        number(tl("Max:{0}", q), 0, q);
        say(function(){
          var q;
          q = dialog.number.num;
          if (!(q > 0)) {
            return say('', tl("Collected nothing."));
          }
          exchange(q, items.vial, items.pinesap);
          sound.play('itemget');
          return say('', tl("Collected {0} Pine Sap.", q));
        });
      };
      break;
    case 'flower':
      tree.name = "flower_" + switches.map + "_" + (flower_count++);
      tree.interact = function(){
        var flower;
        if (!(items.vial.quantity > 0)) {
          say('', tl("Glass vials can be used to collect Nectar."));
          return;
        }
        flower = this;
        say('', tl("Collect Nectar?"));
        menu(tl("Yes"), function(){
          switches[flower.name] = Date.now();
          sound.play('itemget');
          say('', tl("Filled vial with Nectar."));
          exchange(items.vial, items.nectar);
          return flower.kill();
        }, tl("No"), function(){});
      };
      break;
    case 'oil':
      tree.name = "oil_" + switches.map + "_" + oil_count;
      tree.interact = function(){
        var oil;
        if (!(items.vial.quantity > 0)) {
          say('', tl("Glass vials can be used to collect Oil."));
          return;
        }
        oil = this;
        say('', "Collect Oil?");
        menu(tl("Yes"), function(){
          switches[oil.name] = Date.now();
          sound.play('itemget');
          say('', tl("Filled vial with Oil."));
          exchange(items.vial, items.oil);
          oil.frame = 14;
          return delete oil.interact;
        }, tl("No"), function(){});
      };
      // fallthrough
    case 'oil_empty':
      oil_count++;
      tree.body.setSize(12, 12);
      break;
    case 'waygate':
      tree.waygate = object.name;
      tree.interact = function(){
        var i$, ref$, len$, actor, j$, ref1$, len1$, p;
        if (!items.voidcrystal.quantity) {
          return say('', tl("Void Crystals are required to use the waygate."));
        }
        for (i$ = 0, len$ = (ref$ = actors.children).length; i$ < len$; ++i$) {
          actor = ref$[i$];
          if (actor.waygate === this.properties.dest) {
            Dust.summon(player);
            for (j$ = 0, len1$ = (ref1$ = party).length; j$ < len1$; ++j$) {
              p = ref1$[j$];
              p.relocate(actor.x, actor.y + TS);
            }
            items.voidcrystal.quantity--;
            Dust.summon(player);
            return;
          }
        }
      };
      break;
    default:
      if (object.properties.message) {
        tree.interact = function(){
          say('', tl(this.properties.message));
        };
      } else if (object.properties.scenario) {
        tree.interact = function(){
          scenario[this.properties.scenario](this);
        };
      }
    }
    if (object.properties.flip != null) {
      tree.scale.x = -1;
    }
    initUpdate(tree);
    return tree;
  }
  function create_holiday(object){
    var o;
    if (switches.map === 'hub' && switches.llovsick1 === -2) {
      return;
    }
    if (holiday.halloween) {
      switch (object.name) {
      case 'holiday1':
        create_tree(object, '1x1', 1, true);
        break;
      case 'holiday2':
        create_tree(object, '1x1', 2, true);
        break;
      case 'centerpiece':
        o = create_tree(object, '1x2', 4, true);
        o.interact = function(){
          say('', "The stack of jack-o'-lanterns stares back spoopily.");
        };
      }
    } else if (holiday.turkey) {} else if (holiday.christmas) {
      switch (object.name) {
      case 'holiday1':
        create_tree(object, '1x1', 3, true);
        break;
      case 'holiday2':
        create_tree(object, '1x1', 4, true);
        break;
      case 'centerpiece':
        o = create_tree(object, '1x2', 5, true);
        o.interact = function(){
          say('', "It's a happy little tree.");
        };
      }
    } else if (holiday.easter) {
      switch (object.name) {
      case 'holiday1':
        create_tree(object, '1x1', 6, true);
        break;
      case 'holiday2':
        create_tree(object, '1x1', 5, true);
      }
    }
  }
  function create_doodad(object, group){
    var doodad;
    group == null && (group = carpet);
    doodad = group.addChild(
    new Doodad(object.x, object.y, object.properties.sprite, object.name));
    doodad.body.setSize((object.properties.width || 1) * TS, (object.properties.height || 1) * TS);
    switch (doodad.name) {
    case 'llovbed':
      if (switches.started) {
        doodad.alpha = 0;
      }
      doodad.body.setSize(20, 31, 0, 1);
      doodad.interact = function(){
        if (switches.pylonfixed) {
          say('', "No need to sleep right now.");
        } else {
          say('', "Can't sleep.");
        }
      };
      break;
    case 'dresser':
      doodad.interact = function(){
        var args, i$, ref$, len$, p;
        if (party.length === 1) {
          costume_screen.launch(player);
        } else {
          say('', "Change clothes for whom?");
          args = [];
          for (i$ = 0, len$ = (ref$ = party).length; i$ < len$; ++i$) {
            p = ref$[i$];
            args.push(speakers[p.name].display, {
              callback: costume_screen.launch,
              arguments: [p]
            });
          }
          menu.apply(window, args);
        }
      };
      break;
    case 'game':
      doodad.interact = function(){
        say('', "It's a game system!");
        say('', "...It's not plugged in.");
      };
      break;
    case 'medicine':
      doodad.interact = function(){
        if (!(Date.now() - switches.medic < 43200000)) {
          switches.medic = Date.now();
          acquire(items.medicine, 5);
        }
      };
      break;
    case 'grave1':
      doodad.interact = function(){
        if (!(Date.now() - switches.grave1 < 43200000)) {
          switches.grave1 = Date.now();
          acquire(items.gravedust, 5);
        } else {
          say('', tl("Nothing but remains."));
        }
      };
      break;
    case 'grave2':
      doodad.interact = function(){
        if (!(Date.now() - switches.grave2 < 43200000)) {
          switches.grave2 = Date.now();
          acquire(items.gravedust, 5);
        }
        say('', tl("A note was found on the body."));
        say('', tl("\"38014\""));
      };
      break;
    case 'pc':
      doodad.interact = scenario.pc;
      break;
    case 'portal':
      doodad.interact = function(){
        teleport_action(false, true);
      };
      break;
    case 'bloodsamples':
      doodad.interact = function(){
        if (player.y < this.y) {
          return;
        }
        if (items.bloodsample.quantity || items.bloodsample2.quantity) {
          say('', tl("Returned Blood Sample."));
        }
        items.bloodsample.quantity = 0;
        items.bloodsample2.quantity = 0;
        if (!session.bloodsample) {
          session.bloodsample = 1 + Math.random() * 5 | 0;
        }
        if (this.properties.number == session.bloodsample) {
          acquire(items.bloodsample2);
        } else {
          acquire(items.bloodsample);
        }
      };
      break;
    case 'bloodlock':
      doodad.interact = function(){
        var this$ = this;
        if (switches[this.properties.open]) {
          return;
        }
        if (items.bloodsample2.quantity) {
          say('', tl("DNA confirmed. Access granted."));
          say(function(){
            var i$, ref$, len$, a;
            sound.play('door');
            for (i$ = 0, len$ = (ref$ = actors.children).length; i$ < len$; ++i$) {
              a = ref$[i$];
              if (!(a.properties && a.properties.labdoor && a.properties.open === this$.properties.open)) {
                continue;
              }
              a.frame = 5;
              a.body.enable = false;
            }
            setswitch(this$.properties.open, true);
          });
        } else if (items.bloodsample.quantity) {
          say('', tl("DNA mismatch. Access denied."));
        } else {
          say('', tl("Please insert blood sample."));
        }
      };
      break;
    case 'bookswitch':
      doodad.loadTexture('lab_tiles');
      if (!session.book_next) {
        session.book_next = 1;
      }
      if (switches[object.properties.open] || session.book_next > object.properties.order) {
        doodad.crop(new Phaser.Rectangle(TS, TS * 15, TS, TS * 2));
        doodad.open = true;
      } else {
        doodad.crop(new Phaser.Rectangle(0, TS * 15, TS, TS * 2));
      }
      doodad.interact = function(){
        var i$, ref$, len$, a;
        if (player.y < this.y || this.open) {
          return;
        }
        if (this.properties.order == session.book_next) {
          this.crop(new Phaser.Rectangle(TS, TS * 15, TS, TS * 2));
          this.open = true;
          session.book_next++;
          if (this.properties.last) {
            for (i$ = 0, len$ = (ref$ = actors.children).length; i$ < len$; ++i$) {
              a = ref$[i$];
              if (!(a.properties && a.properties.labdoor && a.properties.open === this.properties.open)) {
                continue;
              }
              a.frame = 5;
              a.body.enable = false;
            }
            setswitch(this.properties.open, true);
            sound.play('door');
          } else {
            sound.play('candle');
          }
        } else {
          say('', tl("It won't move."));
        }
      };
      break;
    case 'labmessage1':
      doodad.interact = function(){
        say('', tl("There's a diagram illustrating a book switch mechanism."));
        say('', tl("The switches are labeled from 1 to 5, from north to south."));
      };
      break;
    case 'labmessage2':
      doodad.interact = function(){
        say('', tl("There are some notes scribbled on a piece of paper."));
        say('', tl("\"3214, 13542, 416532, 4371265\""));
        say('', tl("\"Don't forget... Don't forget!\""));
      };
      break;
    case 'labmessage3':
      doodad.interact = function(){
        say('', tl("There are some notes scribbled on a piece of paper."));
        say('', tl("\"Even if the project is successful, I will be dead before she reaches maturity.\""));
        say('', tl("\"I can't do this on my own any more. The project is cancelled. There's no point.\""));
        say('', tl("\"There's no hope.\""));
      };
    }
    doodad.properties = object.properties;
    initUpdate(doodad);
    return doodad;
  }
  function fn$(){
    var fullhealth, i$, ref$, len$, p;
    fullhealth = true;
    for (i$ = 0, len$ = (ref$ = party).length; i$ < len$; ++i$) {
      p = ref$[i$];
      if (p.stats.hp < 1) {
        fullhealth = false;
      }
    }
    return !(switches.map === switches.checkpoint_map && switches.checkpoint === this.name && fullhealth);
  }
  function fn1$(){
    var i$, ref$, len$, p, key, doodad;
    for (i$ = 0, len$ = (ref$ = party).length; i$ < len$; ++i$) {
      p = ref$[i$];
      p.stats.hp = 1;
      p.relocate(player);
      Dust.summon(p);
    }
    for (key in ref$ = doodads) {
      doodad = ref$[key];
      if (doodad.key === 'pent') {
        doodad.flame.visible = false;
      }
    }
    switches.checkpoint_map = switches.map;
    switches.checkpoint = this.name;
    switches["visited_" + switches.map + "_" + this.name] = true;
    save();
    this.flame.visible = true;
    sound.play('candle');
  }
  function fn2$(){
    if (this.item_lock && !items[this.item_lock].quantity || this.switch_lock && !switches[this.switch_lock]) {
      if (this.lock_scenario) {
        scenario[this.lock_scenario]();
      }
      return;
    }
    player.cancel_movement();
    Transition.fade(300, 0, function(){
      return schedule_teleport(this);
    }, null, 5, true, this);
    if (this.sfx) {
      sound.play(this.sfx);
    }
  }
  function fn3$(){
    if (this.properties.message) {
      say('', tl(this.properties.message));
    } else if (this.properties.scenario) {
      scenario[this.properties.scenario]();
    }
  }
  function fn4$(){
    return !switches[this.name] && (!this.condition || !!switches[this.condition]);
  }
  function fn5$(){
    scenario[this.name]();
    if (this.properties.dontswitch == null) {
      setswitch(this.name, true, this.properties.nosave);
    }
  }
  function fn6$(){
    var state, i$, ref$, len$, actor;
    sound.play('candle');
    state = switches[this.properties['switch']] = !switches[this.properties['switch']];
    save();
    this.frame = state
      ? +this.properties.frame2
      : +this.properties.frame;
    for (i$ = 0, len$ = (ref$ = actors.children).length; i$ < len$; ++i$) {
      actor = ref$[i$];
      if (actor.falsewall) {
        if (switches[actor.properties.on_switch] || (actor.properties.on_switch == null && !switches[actor.properties.off_switch])) {
          actor.revive();
        } else {
          actor.kill();
        }
        if (switches[actor.properties.on_switch] && switches[actor.properties.off_switch]) {
          actor.kill();
        }
      }
    }
  }
  function fn7$(){
    var rect, i$, ref$, len$, a, n;
    if (this.open) {
      return;
    }
    if (this.properties.order == session.morgue_next) {
      session.morgue_set = this.properties.set;
      rect = new Phaser.Rectangle((this.properties.last ? 2 : 1) * TS, TS * 13, TS, TS);
      this.open = true;
      this.crop(rect);
      if (this.properties.last) {
        session.morgue_next = 1;
        for (i$ = 0, len$ = (ref$ = actors.children).length; i$ < len$; ++i$) {
          a = ref$[i$];
          if (!(a.properties && a.properties.labdoor && a.properties.open === this.properties.open)) {
            continue;
          }
          a.frame = 5;
          a.body.enable = false;
        }
        setswitch(this.properties.open, true);
        sound.play('door');
      } else {
        session.morgue_next++;
        sound.play('candle');
      }
    } else if (session.morgue_next == 1) {
      say('', tl("It won't open."));
    } else {
      rect = new Phaser.Rectangle(0, TS * 13, TS, TS);
      for (i$ = 0, len$ = (ref$ = carpet.children).length; i$ < len$; ++i$) {
        n = ref$[i$];
        if (n.name === 'morgue' && n.properties.set === this.properties.set) {
          n.open = false;
          n.crop(rect);
          session.morgue_next = 1;
          sound.play('candle');
        }
      }
    }
  }
  function fn8$(){
    this.base.interact();
  }
  function fn9$(){
    var goop;
    say('', tl("An unnatural growth blocks the way."));
    if (items.necrotoxin.quantity) {
      say('', tl("Use Necrotoxin?"));
      goop = this;
      menu(tl("Yes"), function(){
        scenario.burningflesh(goop);
        acquire(items.necrotoxin, -1, true, true);
        setswitch(goop.name, true);
      }, tl("No"), function(){});
    }
  }
  function fn10$(){
    var t, smoothness;
    t = (Date.now() - this.timer) / 5000;
    smoothness = 20;
    t = (t * smoothness | 0) / smoothness;
    if (t > 1) {
      this.prev = {
        x: this.x,
        y: this.y,
        s: this.scale.x
      };
      this.goal = {
        x: this.origin.x + Math.random() * 8 - 4,
        y: this.origin.y + Math.random() * 8 - 4,
        s: Math.random() * 0.2 + 0.9
      };
      this.timer = Date.now();
      return;
    }
    this.x = this.prev.x + (this.goal.x - this.prev.x) * t;
    this.y = this.prev.y + (this.goal.y - this.prev.y) * t;
    this.scale.set(this.prev.s + (this.goal.s - this.prev.s) * t);
  }
}
function create_prop(node, key, collide, group){
  var d;
  collide == null && (collide = true);
  group == null && (group = actors);
  d = group.addChild(new Doodad(node.x + HTS, node.y + TS, key, null, collide));
  d.anchor.set(0.5, 1);
  initUpdate(d);
  return d;
}
devices = {
  keyboard: false,
  mouse: false,
  touch: false
};
keyboard = {
  vkeys: {}
};
keyboard.addKeys = function(vkey){
  var keys, res$, i$, to$, ref$, len$, key, input;
  res$ = [];
  for (i$ = 1, to$ = arguments.length; i$ < to$; ++i$) {
    res$.push(arguments[i$]);
  }
  keys = res$;
  if (keyboard[vkey] != null) {
    for (i$ = 0, len$ = (ref$ = keyboard[vkey].keys).length; i$ < len$; ++i$) {
      key = ref$[i$];
      key.keyDown.removeAll();
    }
    return;
  }
  input = function(){
    var i$, ref$, len$, key;
    for (i$ = 0, len$ = (ref$ = input.keys).length; i$ < len$; ++i$) {
      key = ref$[i$];
      if (key.isDown) {
        return true;
      }
    }
    return false;
  };
  input.keys = [];
  for (i$ = 0, len$ = keys.length; i$ < len$; ++i$) {
    key = keys[i$];
    input.keys.push(game.input.keyboard.addKey(Phaser.Keyboard[key]));
  }
  input.newSignal = function(signal){
    input[signal] = {
      signal: signal,
      add: function(listener, context, priority){
        var i$, ref$, len$, key;
        for (i$ = 0, len$ = (ref$ = input.keys).length; i$ < len$; ++i$) {
          key = ref$[i$];
          key[this.signal].add(listener, context, priority);
        }
      },
      addOnce: function(listener, context, priority){
        var i$, ref$, len$, key;
        for (i$ = 0, len$ = (ref$ = input.keys).length; i$ < len$; ++i$) {
          key = ref$[i$];
          key[this.signal].addOnce(listener, context, priority);
        }
      }
    };
  };
  input.newSignal('onDown');
  input.newSignal('keyDown');
  for (i$ = 0, len$ = (ref$ = input.keys).length; i$ < len$; ++i$) {
    key = ref$[i$];
    key.keyDown = new Phaser.Signal();
    key.processKeyDown2 = key.processKeyDown;
    key.processKeyDown = fn$;
  }
  keyboard.vkeys[vkey] = keyboard[vkey] = input;
  function fn$(){
    this.keyDown.dispatch();
    this.processKeyDown2.apply(this, arguments);
  }
};
function reset_keyboard(){
  var k, i$, ref$, len$, key;
  for (k in keyboard.vkeys) {
    for (i$ = 0, len$ = (ref$ = keyboard.vkeys[k].keys).length; i$ < len$; ++i$) {
      key = ref$[i$];
      key.isDown = false;
    }
  }
}
input_mod = [];
function input_initialize(){
  var i$, ref$, len$, f;
  game.input.keyboard.enabled = true;
  mouse.down = false;
  game.canvas.oncontextmenu = onContextMenu;
  game.input.onDown.add(onDown_mouse);
  game.input.onUp.add(onUp_mouse);
  keyboard.addKeys('up', 'UP', 'W');
  keyboard.addKeys('left', 'LEFT', 'A');
  keyboard.addKeys('down', 'DOWN', 'S');
  keyboard.addKeys('right', 'RIGHT', 'D');
  keyboard.addKeys('confirm', 'SPACEBAR', 'ENTER', 'Z', 'C');
  keyboard.addKeys('cancel', 'ESC', 'TAB', 'X');
  keyboard.addKeys('dash', 'SHIFT');
  for (i$ = 0, len$ = (ref$ = input_mod).length; i$ < len$; ++i$) {
    f = ref$[i$];
    if (typeof f == 'function') {
      f();
    }
  }
  game.input.keyboard.onDownCallback = function(){
    if (!devices.keyboard) {
      devices.keyboard = true;
    }
  };
  game.input.mouse.mouseWheelCallback = mousewheel_controller;
}
function input_battle(){
  input_initialize();
}
function input_overworld(){
  input_initialize();
  game.input.onDown.add(mousedown_player);
  game.input.onTap.add(mousetap_player);
  keyboard.confirm.onDown.add(player_confirm_button);
}
onDown_up = function(){};
onDown_left = function(){};
onDown_down = function(){};
onDown_right = function(){};
function onDown_confirm(){
  if (!(dialog != null && dialog.click())) {
    if (player != null) {
      player.confirm_button();
    }
  }
}
onDown_cancel = function(){};
mouse = {
  x: 0,
  y: 0,
  down: false,
  world: {
    x: 0,
    y: 0
  },
  update: function(){
    this.x = game.input.x / (window.innerWidth / game.width) | 0;
    this.y = game.input.y / (window.innerHeight / game.height) | 0;
    this.world.x = this.x + game.camera.x;
    this.world.y = this.y + game.camera.y;
  }
};
function onDown_mouse(e){
  if (e === game.input.mousePointer) {
    if (!devices.mouse) {
      devices.mouse = true;
    }
  } else {
    if (!devices.touch) {
      devices.touch = true;
    }
  }
  if (!nullbutton(e.button)) {
    return;
  }
  if (!(actors != null && actors.paused)) {
    mouse.down = true;
  }
  if (mouse.down) {
    mouse.update();
  }
}
function onUp_mouse(){
  mouse.down = false;
}
function mousewheel_controller(e){
  var i$, ref$, len$, menu;
  if (game.state.current === 'overworld' && !(actors != null && actors.paused)) {
    mousewheel_player(e);
  }
  for (i$ = 0, len$ = (ref$ = Menu.list).length; i$ < len$; ++i$) {
    menu = ref$[i$];
    if (menu.alive) {
      menu.scroll(e);
    }
  }
  e.preventDefault();
  return false;
}
function onContextMenu(e){
  e.preventDefault();
  return false;
}
function nullbutton(button){
  return button === 0 || button === null || button === undefined;
}
Item = (function(){
  Item.displayName = 'Item';
  var prototype = Item.prototype, constructor = Item;
  Item.COMMON = 0;
  Item.CONSUME = 1;
  Item.EQUIP = 2;
  Item.KEY = 3;
  function Item(properties){
    var key;
    for (key in properties) {
      this[key] = properties[key];
    }
    this.quantity == null && (this.quantity = 0);
    this.time == null && (this.time = 0);
    this.type == null && (this.type = Item.COMMON);
    this.sicon == null && (this.sicon = this.type === Item.KEY
      ? 'item_key'
      : this.type === Item.CONSUME
        ? 'item_pot'
        : this.type === Item.EQUIP ? 'item_equip' : 'item_misc');
    if (this.type === Item.EQUIP) {
      this.icon == null && (this.icon = 'item_equip2');
    }
    this.iconx == null && (this.iconx = 0);
    this.icony == null && (this.icony = 0);
    this.target == null && (this.target = 'ally');
    this.attributes == null && (this.attributes = []);
    this.consume = function(){
      var ref$;
      sound.play('itemget');
      if (this.type === Item.CONSUME && !this.dontconsume) {
        this.quantity = (ref$ = this.quantity - 1) > 0 ? ref$ : 0;
      }
      if (in$('glass', this.attributes)) {
        if (in$('bomb', this.attributes)) {
          acquire(items.shards, 1, true, true);
          if (game.state.current === 'battle') {
            drop_item('cumberground', 1);
          } else {
            acquire(items.cumberground, 1, true, true);
          }
        } else {
          acquire(items.vial, 1, true, true);
        }
      }
      if (game.state.current !== 'battle') {
        save();
      }
    };
    this.condition == null && (this.condition = function(){
      return true;
    });
    this.unique == null && (this.unique = this.type === Item.EQUIP || this.type === Item.KEY);
  }
  return Item;
}());
function acquire(item, q, silent, nosave){
  q == null && (q = 1);
  silent == null && (silent = false);
  nosave == null && (nosave = false);
  if (!item) {
    fatalerror('missingitem');
    return;
  }
  item.time = Date.now();
  if (silent) {
    item.quantity += q;
    if (item.quantity < 0) {
      item.quantity = 0;
    }
    if (!nosave) {
      save();
    }
    return;
  }
  say.call(this, function(){
    sound.play('itemget');
    item.quantity += q;
    if (item.quantity < 0) {
      item.quantity = 0;
    }
    if (!nosave) {
      return save();
    }
  });
  say.call(this, '', tl("Acquired {0} {1}!", stattext(q, 5), item.name));
}
function exchange(){
  var qlose, qgain, ilose, igain;
  switch (arguments.length) {
  case 2:
    qlose = qgain = 1;
    ilose = arguments[0];
    igain = arguments[1];
    break;
  case 3:
    qlose = qgain = arguments[0];
    ilose = arguments[1];
    igain = arguments[2];
    break;
  case 4:
    qlose = arguments[0];
    ilose = arguments[1];
    qgain = arguments[2];
    igain = arguments[3];
  }
  if (ilose.quantity < qlose) {
    warn("Exchange failed, not enough " + ilose.name + "!");
    return;
  }
  ilose.quantity -= qlose;
  igain.quantity += qgain;
  igain.time = Date.now();
  save();
}
function heal(o, hp, showtext){
  var ref$;
  showtext == null && (showtext = true);
  if (o instanceof Player) {
    o.stats.hp = (ref$ = o.stats.hp + hp / o.get_stat('hp')) < 1 ? ref$ : 1;
  } else {
    o.damage(-hp, showtext);
  }
}
function heal_percent(o, hp, showtext){
  var ref$;
  showtext == null && (showtext = true);
  if (o instanceof Player) {
    o.stats.hp = (ref$ = o.stats.hp + hp) < 1 ? ref$ : 1;
  } else {
    o.damage(-hp * o.get_stat('hp'), showtext);
  }
  return o.get_stat('hp') * hp;
}
function item_heal_hybrid(o, n, s, showtext){
  var amt;
  showtext == null && (showtext = true);
  if (o instanceof Player) {
    heal(o, n, showtext);
    heal_percent(o, s, showtext);
  } else {
    amt = n + s * o.get_stat('hp');
    o.damage(-amt, showtext);
  }
}
items = {};
items.steelpipe = {
  name: "Steel Pipe",
  iconx: 3,
  icony: 2,
  type: Item.EQUIP,
  mod_atk: function(s){
    return s + 18;
  },
  mod_speed: function(s){
    return s * 0.90;
  },
  attack: function(){
    if (this.parent.luckroll() > 0.8) {
      calltarget('inflict', buffs.dazed);
    }
  },
  desc: "A crude makeshift weapon. Good for bashing people over the head.",
  attributes: ['blunt']
};
items.shinai = {
  name: "Kendo Stick",
  iconx: 2,
  icony: 0,
  type: Item.EQUIP,
  mod_atk: function(s){
    return s + 10;
  },
  desc: "A bamboo sword used in Kendo, a Japanese martial art. Does more damage at lower levels."
};
items.toyhammer = {
  name: "Toy Hammer",
  iconx: 2,
  icony: 3,
  type: Item.EQUIP,
  quantity: 0,
  mod_atk: function(s){
    return s + 6;
  },
  mod_luck: function(s){
    return s + 9;
  },
  attack: function(){
    calltarget('inflict', buffs.dazed);
  },
  desc: "A hammer made of plastic. It doesn't do much damage, but it can be used to stun enemies."
};
items.bow = {
  name: "Lovely Bow",
  iconx: 4,
  icony: 3,
  type: Item.EQUIP,
  mod_atk: function(s){
    return s * 1.02 + 6;
  },
  mod_luck: function(s){
    return s * 1.02 + 4;
  },
  desc: "Increases the damage of arrow skills. In skilled hands, unlocks a special skill.",
  quantity: 0,
  skill: function(){
    if (this.parent.name === 'llov' && this.parent.forme.stage > 0) {
      return skills.leecharrow;
    } else {
      return null;
    }
  }
};
items.fan = {
  name: "Fan",
  iconx: 0,
  icony: 2,
  type: Item.EQUIP,
  mod_atk: function(s){
    return s + 10;
  },
  mod_def: function(s){
    return s + 10;
  },
  mod_speed: function(s){
    return s + 5;
  },
  mod_luck: function(s){
    return s + 5;
  },
  mod_hp: function(s){
    return s + 10;
  },
  desc: "A fan given by Malaria-sama. Ever so slightly boosts every stat."
};
items.samsword = {
  name: "Sam Sword",
  iconx: 3,
  type: Item.EQUIP,
  mod_atk: function(s){
    return this.get_stat('speed') / 666 * s + s;
  },
  desc: "A curved sword that requires a bit of skill to use. It cuts better the faster you swing it.",
  attributes: ['blade']
};
items.broadsword = {
  name: "Broad Sword",
  iconx: 4,
  type: Item.EQUIP,
  mod_atk: function(s){
    return s * 1.11;
  },
  desc: "A large sword made to cleave through foes.",
  attributes: ['blade']
};
items.vampsword = {
  name: "Vampire Blade",
  type: Item.EQUIP,
  iconx: 1,
  icony: 3,
  mod_atk: function(s){
    return s * 1.3;
  },
  mod_luck: function(s){
    return s * 0.1;
  },
  step: function(){
    this.parent.damage(deltam * 0.02 * this.parent.get_stat('hp'));
  },
  desc: "A powerful sword that gradually drains the wielder's life.",
  attributes: ['blade']
};
items.mistersword = {
  name: "Mister Sword",
  type: Item.EQUIP,
  icony: 3,
  mod_atk: function(s){
    var roll;
    roll = this.parent.luckroll || Math.random;
    return s * (1 + roll.call(this.parent) * 0.3 - 0.05);
  },
  desc: "A sword with a mind of its own. Attack power varies randomly.",
  attributes: ['blade']
};
items.pest = {
  name: "Pestilent",
  iconx: 5,
  type: Item.EQUIP,
  mod_atk: function(s){
    return s * 1.1;
  },
  mod_luck: function(s){
    return s * 1.1;
  },
  attack: function(){
    if (this.parent.luckroll() > 0.9) {
      calltarget('inflict', buffs.poison);
    }
  },
  desc: "Old Pest's trusty sword. The blade is adorned with runic lettering. Poison seeps from the blade.",
  attributes: ['blade']
};
items.worldsharp = {
  name: 'Worlds Sharp',
  iconx: 5,
  icony: 2,
  type: Item.EQUIP,
  quantity: 0,
  mod_atk: function(s){
    return s * 1.06 + 5;
  },
  mod_luck: function(s){
    return s * 1.2;
  },
  desc: "The sharpest cheddar cheese knife in the world. It's too stale to eat.",
  attributes: ['blade']
};
items.newton = {
  name: "Flame Razer",
  iconx: 5,
  icony: 0,
  desc: "The sharpest and hottest laser razor around.",
  type: Item.EQUIP,
  attack: function(){},
  attributes: ['blade']
};
items.chainsaw = {
  name: "Chainsaw",
  iconx: 1,
  icony: 4,
  type: Item.EQUIP,
  mod_atk: function(s){
    return s * (!(this.parent instanceof Monster) && items.oil.quantity ? 1.3 : 1);
  },
  attack: function(){
    if (!(this.parent instanceof Monster) && items.oil.quantity) {
      acquire(items.oil, -1, true, true);
    }
  },
  desc: "A very powerful weapon. Consumes 1 oil every attack to remain effective.",
  attributes: ['tech']
};
items.torndress = {
  name: "Torn Dress",
  desc: "It's torn at several parts, but it's still somehow wearable.",
  type: Item.EQUIP,
  iconx: 3,
  icony: 3,
  mod_def: function(s){
    return s + 5;
  },
  mod_luck: function(s){
    return s + 20;
  }
};
items.leatherarmor = {
  name: "Leather Armor",
  iconx: 2,
  icony: 1,
  desc: "Armor made from hardened leather. It offers light protection.",
  type: Item.EQUIP,
  mod_def: function(s){
    return s * 1.1 + 10;
  }
};
items.thornarmor = {
  name: "Thorn Armor",
  iconx: 4,
  icony: 1,
  desc: "Thorns coat this armor, causing harm to attackers.",
  type: Item.EQUIP,
  ondamage: function(damage, source){
    if (source === this.parent) {
      return damage;
    }
    if (source != null) {
      source.damage(damage * 0.25, Math.floor(damage) > 0, this.parent);
    }
    return damage;
  },
  mod_def: function(s){
    return s * 1.05 + 10;
  }
};
items.magicarmor = {
  name: "Magic Armor",
  desc: "Defends well against magic, but restricts movement.",
  type: Item.EQUIP
};
items.platearmor = {
  name: "Plate Armor",
  iconx: 3,
  icony: 1,
  desc: "Armor made from solid metal plates. It offers high protection but is heavy.",
  type: Item.EQUIP,
  mod_def: function(s){
    return s * 1.3 + 30;
  },
  mod_speed: function(s){
    return s * 0.9;
  }
};
items.deathsmantle = {
  name: "Death's Mantle",
  type: Item.EQUIP,
  icony: 4,
  desc: "The shroud worn by death itself. Provides immunity to death as long as you have allies.",
  mod_luck: function(s){
    return s / 2;
  }
};
items.scythe = {
  name: "Scythe",
  type: Item.EQUIP,
  iconx: 2,
  icony: 4,
  desc: "Capable of slaying monsters with death immunity.",
  mod_atk: function(s){
    return s * 1.1;
  },
  mod_luck: function(s){
    return s * 1.1;
  },
  attack: function(){
    calltarget(function(){
      if (!in$('mortal', this.attributes)) {
        this.attributes.push('mortal');
      }
    });
  }
};
items.woodshield = {
  name: "Wood Shield",
  icony: 1,
  desc: "Provides defense, but is weak to fire.",
  type: Item.EQUIP,
  mod_def: function(s){
    return s * 1.2 + 20;
  }
};
items.towershield = {
  name: "Tower Shield",
  iconx: 1,
  icony: 1,
  desc: "Provides great defense at the cost of offense and mobility.",
  type: Item.EQUIP,
  mod_def: function(s){
    return s * 1.35 + 50;
  },
  mod_speed: function(s){
    return s * 0.8;
  },
  mod_atk: function(s){
    return s * 0.9;
  }
};
items.glassshield = {
  name: "Glass Shield",
  desc: "A shield that defends great against magic. It shatters easily, but regenerates after battle.",
  type: Item.EQUIP
};
items.swiftshoe = {
  name: "Swift Shoe",
  iconx: 2,
  icony: 2,
  desc: "Slightly raises speed and greatly increases chance of escape.",
  type: Item.EQUIP,
  mod_speed: function(s){
    return s * 1.2;
  },
  mod_escape: function(s){
    return s * 2;
  }
};
items.heartpin = {
  name: "Heart Pin",
  iconx: 1,
  icony: 2,
  desc: "A cute heart-shaped pin to be worn in the hair. Its magical properties increases the wearer's health.",
  type: Item.EQUIP,
  mod_hp: function(s){
    return s * 1.1 + 5;
  },
  quantity: 0
};
items.kill = {
  name: "Kill",
  desc: "Dev item. Kills target.",
  type: Item.KEY,
  quantity: 0,
  usebattle: function(target){
    return target.damage(target.stats.hp_max);
  },
  target: 'any'
};
items.riverfilter = {
  name: "River Filter",
  desc: "Allows collection of water from the Tuonen river without assistance from Joki.",
  type: Item.KEY,
  iconx: 5,
  useoverworld: function(){
    var q;
    if (player.water_depth) {
      q = items.vial.quantity;
      if (q) {
        say('', tl("Collect Black Water?"));
        number(tl("Max:{0}", q), 0, q);
        say(function(){
          var q, sludgecount, i$;
          q = dialog.number.num;
          if (!(q > 0)) {
            return say('', tl("Collected nothing."));
          }
          sludgecount = 0;
          for (i$ = 0; i$ < q; ++i$) {
            if (Math.random() < 0.1) {
              sludgecount++;
            }
          }
          say('', tl("Collected {0} Black Water.", q));
          if (sludgecount) {
            acquire(items.sludge, sludgecount, false, true);
          }
          exchange(q, items.vial, items.tuonen);
          sound.play('itemget');
          return pause_screen.inventory.revive();
        });
      } else {
        say('', tl("Vials are needed to collect water."));
      }
    } else {
      say('', tl("No water to collect."));
    }
  },
  target: 'none'
};
items.jokicharm = {
  name: "River Boots",
  desc: "Not an actual pair of boots, but actually a trinket. It seems this allows you to wade through the waters of the Tuonen River.",
  type: Item.KEY,
  iconx: 4
};
items.vial = {
  name: "Glass Vial",
  type: Item.COMMON,
  sicon: 'item_pot',
  iconx: 1,
  desc: "Can be used to collect various liquids to use as potion bases."
};
items.oil = {
  name: "Volatile Oil",
  type: Item.COMMON,
  sicon: 'item_pot',
  iconx: 4,
  desc: "Can be used as a base to create throwing potions.",
  attributes: ['glass']
};
items.pinesap = {
  name: "Pine Sap",
  type: Item.COMMON,
  sicon: 'item_pot',
  iconx: 2,
  desc: "Can be used as a base to create basic potions. Gathered from pine trees.",
  attributes: ['glass']
};
items.nectar = {
  name: "Sweet Nectar",
  type: Item.COMMON,
  sicon: 'item_pot',
  iconx: 3,
  desc: "Can be used as a base to create high quality potions. Gathered from flowers.",
  attributes: ['glass']
};
items.tuonen = {
  name: "Black Water",
  type: Item.COMMON,
  sicon: 'item_pot',
  iconx: 5,
  desc: "Water pulled from the Tuonen River. Used as a potion base to remove status conditions. Consuming it raw may cause severe amnesia.",
  attributes: ['glass']
};
items.medicine = {
  name: "Medical Waste",
  type: Item.COMMON,
  iconx: 4,
  desc: "Discarded medical supplies. It could probably be used to make healing items."
};
items.sludge = {
  name: "Poison Sludge",
  type: Item.COMMON,
  desc: "A highly toxic substance. Handle with care.",
  iconx: 1,
  icony: 2
};
items.gravedust = {
  name: "Grave Dust",
  type: Item.COMMON,
  desc: "Cursed residue left behind from an undead creature.",
  icony: 2
};
items.silverdust = {
  name: "Silver Dust",
  type: Item.COMMON,
  desc: "Overexposure may turn skin blue.",
  icony: 3
};
items.starpuff = {
  name: "Star Puff",
  type: Item.COMMON,
  desc: "A puffy sea star, made of dreams and magic.",
  iconx: 1,
  icony: 3
};
items.venom = {
  name: "Venom Gland",
  type: Item.COMMON,
  desc: "Taken from a venomous beast.",
  iconx: 2,
  icony: 2
};
items.aloevera = {
  name: "Aloe Vera",
  type: Item.COMMON,
  desc: "Can be used to heal minor burns or as a medical ingredient.",
  iconx: 3,
  icony: 2,
  usebattle: function(target){
    var i$, ref$, len$, buff, results$ = [];
    for (i$ = 0, len$ = (ref$ = target.buffs).length; i$ < len$; ++i$) {
      buff = ref$[i$];
      if (buff.name === 'burn' && buff.intensity === 1) {
        results$.push(buff.remedy());
      }
    }
    return results$;
  }
};
items.plantfiber = {
  name: "Plant Fiber",
  type: Item.COMMON,
  desc: "Fibrous plant parts. It can probably be woven into parchment",
  iconx: 3,
  icony: 2
};
items.fur = {
  name: "Clumpy Fur",
  desc: "Matted clumps of fur taken from a beast of some sort.",
  iconx: 4,
  icony: 1
};
items.cloth = {
  name: "Cloth Scraps",
  desc: "Ripped scraps of cloth.",
  iconx: 3,
  icony: 1
};
items.cinder = {
  name: "Cinders",
  desc: "Burning bits of something. They're still very hot.",
  iconx: 2,
  icony: 1
};
items.frozenflesh = {
  name: "Frozen Flesh",
  desc: "Frozen bits of flesh.",
  icony: 1
};
items.meat = {
  name: "Meat",
  desc: "Succulent bits of meat. They can be used to distract certain enemies.",
  type: Item.CONSUME,
  sicon: 'item_misc',
  iconx: 1,
  icony: 1,
  usebattle: function(target){
    if (in$('carnivore', target.attributes)) {
      target.inflict(buffs.baited);
      target.stats.sp = 0;
      triggertext(target.displayname + " was baited!");
    } else {
      triggertext("It had no effect.");
    }
  },
  target: 'enemy'
};
items.teleport = {
  name: "Portal Scroll",
  type: Item.CONSUME,
  dontconsume: true,
  sicon: 'item_misc',
  iconx: 5,
  icony: 1,
  desc: "Teleports the user to any previously activated pentagram.",
  useoverworld: function(){
    return teleport_action(true, false);
  },
  target: 'none'
};
function teleport_action(consume, ignorelock){
  var zones, zone, pent, menuset, i$, len$;
  if (switches.lockportals && !ignorelock) {
    return say('', tl("A magical influence prevents the spell from working!"));
  }
  zones = [];
  for (zone in pentagrams) {
    for (pent in pentagrams[zone]) {
      if (switches["visited_" + pent]) {
        zones.push(zone);
        break;
      }
    }
  }
  if (zones.length === 0) {
    return say('', tl("There are no suitable destinations."));
  }
  menuset = [tl("Cancel"), function(){}];
  for (i$ = 0, len$ = zones.length; i$ < len$; ++i$) {
    zone = zones[i$];
    menuset.push(tl(zone), {
      callback: teleportmenu,
      context: dialog.menu,
      arguments: [zone]
    });
  }
  say('', tl("Choose a destination"));
  menu.apply(window, menuset);
  function teleportmenu(zone){
    var pents, menuset, pent;
    pents = [];
    menuset = [tl("Back"), 'back'];
    for (pent in pentagrams[zone]) {
      if (switches["visited_" + pent]) {
        menuset.push(tl(pentagrams[zone][pent]), [
          fn$, {
            callback: warp_node,
            arguments: pent.split(/_(?!.*_)/)
          }
        ]);
      }
    }
    this.nest.apply(this, menuset);
    function fn$(){
      pause_screen.exit();
      if (consume) {
        items.teleport.quantity--;
      }
    }
  }
}
items.swarmscroll = {
  name: "Swarm Scroll",
  type: Item.CONSUME,
  sicon: 'item_misc',
  iconx: 5,
  icony: 2,
  desc: "Casts Swarm on the target.",
  usebattle: function(target){
    return target.inflict(buffs.swarm);
  },
  target: 'enemy',
  attributes: ['spell']
};
items.plaguescroll = {
  name: "Plague Scroll",
  type: Item.CONSUME,
  sicon: 'item_misc',
  iconx: 5,
  icony: 3,
  desc: "Makes the target spread its diseases to its allies.",
  usebattle: function(target){
    var diseaselist, i$, ref$, len$, buff, enemy, lresult$, j$, len1$, results$ = [];
    diseaselist = [];
    for (i$ = 0, len$ = (ref$ = target.buffs).length; i$ < len$; ++i$) {
      buff = ref$[i$];
      if (in$('disease', buff.attributes) && !in$(buff.name, diseaselist)) {
        diseaselist.push(buff.name);
      }
    }
    for (i$ = 0, len$ = (ref$ = enemy_list()).length; i$ < len$; ++i$) {
      enemy = ref$[i$];
      lresult$ = [];
      for (j$ = 0, len1$ = diseaselist.length; j$ < len1$; ++j$) {
        buff = diseaselist[j$];
        if (enemy.has_buff(buffs[buff])) {
          continue;
        }
        lresult$.push(enemy.inflict(buffs[buff]));
      }
      results$.push(lresult$);
    }
    return results$;
  },
  target: 'enemy',
  attributes: ['spell']
};
items.slowscroll = {
  name: "Slow Scroll",
  type: Item.CONSUME,
  sicon: 'item_misc',
  iconx: 4,
  icony: 3,
  desc: "Slows the target.",
  usebattle: function(target){
    return target.inflict(buffs.slow);
  },
  target: 'enemy',
  attributes: ['spell']
};
items.parchment = {
  name: "Parchment",
  desc: "Used for the creation of scrolls.",
  iconx: 3,
  icony: 3
};
items.bugbits = {
  name: "Bug Parts",
  desc: "Broken bits of bugs.",
  iconx: 2,
  icony: 3
};
items.blistercream = {
  name: "Ointment",
  type: Item.CONSUME,
  sicon: 'item_misc',
  iconx: 1,
  desc: "Removes 1 negative status effect.",
  target: 'ally',
  usebattle: function(target){
    var i$, ref$, len$, buff, results$ = [];
    for (i$ = 0, len$ = (ref$ = target.buffs).length; i$ < len$; ++i$) {
      buff = ref$[i$];
      if (buff.negative) {
        buff.remedy();
        break;
      }
    }
    return results$;
  }
};
items.antidote = {
  name: "Antidote",
  type: Item.CONSUME,
  icony: 2,
  desc: "Heals poison effects when ingested.",
  usebattle: function(target){
    return target.remedy(buffs.poison);
  },
  target: 'ally',
  attributes: ['glass']
};
items.burnheal = {
  name: "Burn Heal",
  type: Item.CONSUME,
  iconx: 2,
  icony: 2,
  desc: "Heals burns.",
  usebattle: function(target){
    return target.remedy(buffs.burn);
  },
  target: 'ally',
  attributes: ['glass']
};
items.anticurse = {
  name: "Anticurse",
  type: Item.CONSUME,
  iconx: 1,
  icony: 2,
  desc: "Removes all sorts of curses.",
  usebattle: function(target){
    var i$, ref$, len$, buff, results$ = [];
    for (i$ = 0, len$ = (ref$ = target.buffs).length; i$ < len$; ++i$) {
      buff = ref$[i$];
      if (in$('curse', buff.attributes)) {
        results$.push(buff.remedy());
      }
    }
    return results$;
  },
  target: 'ally',
  attributes: ['glass']
};
items.antifreeze = {
  name: "Antifreeze",
  type: Item.CONSUME,
  iconx: 3,
  icony: 2,
  desc: "Remove all cold effects.",
  usebattle: function(target){
    return target.remedy(buffs.chill);
  },
  target: 'ally',
  attributes: ['glass']
};
items.bleach = {
  name: "Bleach",
  type: Item.CONSUME,
  iconx: 4,
  icony: 2,
  desc: "Remove all status effects from the target.",
  usebattle: function(target){
    var i$, ref$, len$, buff, results$ = [];
    for (i$ = 0, len$ = (ref$ = target.buffs).length; i$ < len$; ++i$) {
      buff = ref$[i$];
      results$.push(buff.remedy());
    }
    return results$;
  },
  target: 'any'
};
items.repel = {
  name: "Repel",
  type: Item.CONSUME,
  iconx: 5,
  icony: 2,
  desc: "Keeps monsters away for a short time.",
  useoverworld: function(){
    temp.repel = 20000;
  },
  target: 'none'
};
items.lifecrystal = {
  name: "Life Crystal",
  type: Item.CONSUME,
  sicon: 'item_misc',
  iconx: 3,
  desc: "Restores health.",
  use: function(target){
    return item_heal_hybrid(target, 50, 0.25);
  },
  target: 'ally'
};
items.darkcrystal = {
  name: "Dark Crystal",
  type: Item.CONSUME,
  sicon: 'item_misc',
  iconx: 2,
  desc: "Removes curses.",
  usebattle: function(target){
    return target.remedy(buffs.curse);
  },
  target: 'ally'
};
items.voidcrystal = {
  name: "Void Crystal",
  type: Item.COMMON,
  sicon: 'item_misc',
  iconx: 2,
  desc: "Used to operate void gates."
};
items.bandage = {
  name: "Bandage",
  desc: "Restores health and stops bleeding.",
  type: Item.CONSUME,
  sicon: 'item_misc',
  iconx: 4,
  icony: 2,
  use: function(target){
    item_heal_hybrid(target, 50, 0.25);
    return typeof target.remedy == 'function' ? target.remedy(buffs.bleed) : void 8;
  }
};
items.hp1 = {
  name: "Health Drink",
  type: Item.CONSUME,
  icony: 1,
  desc: "Restores a moderate amount of health.",
  use: function(target){
    return item_heal_hybrid(target, 100, 0.25);
  },
  target: 'ally',
  attributes: ['glass']
};
items.hp2 = {
  name: "Health Tonic",
  type: Item.CONSUME,
  iconx: 1,
  icony: 1,
  desc: "Restores a lot of health.",
  use: function(target){
    return item_heal_hybrid(target, 200, 0.50);
  },
  target: 'ally',
  attributes: ['glass']
};
items.sp1 = {
  name: "Speed Potion",
  type: Item.CONSUME,
  iconx: 2,
  icony: 1,
  desc: "Raises speed for a short time.",
  usebattle: function(target){
    return target.inflict(buffs.speed);
  },
  target: 'ally',
  attributes: ['glass']
};
items.sp2 = {
  name: "Burst Potion",
  type: Item.CONSUME,
  iconx: 3,
  icony: 1,
  desc: "Provides a quick burst of speed.",
  usebattle: function(target){
    if (target.has_buff(buffs.dizzy)) {
      triggertext("It had no effect.");
      return;
    }
    target.stats.sp += 2;
    target.stats.sp_level = Math.ceil(target.stats.sp - 1);
    return target.inflict(buffs.dizzy);
  },
  target: 'ally',
  attributes: ['glass']
};
items.ex1 = {
  name: "Excel Potion",
  type: Item.CONSUME,
  iconx: 4,
  icony: 1,
  desc: "Fills the excel meter by half.",
  usebattle: function(target){
    return target.stats.ex += 0.5;
  }
};
items.ex2 = {
  name: "Excel Tonic",
  type: Item.CONSUME,
  iconx: 5,
  icony: 1,
  desc: "Fills the excel meter to the top!",
  usebattle: function(target){
    return target.stats.ex += 1;
  }
};
items.poisonbom = {
  name: "Poison Bomb",
  type: Item.CONSUME,
  icony: 3,
  desc: "Poisons the target.",
  usebattle: function(target){
    return target.inflict(buffs.poison);
  },
  target: 'enemy',
  attributes: ['glass', 'bomb']
};
items.cursebom = {
  name: "Curse Bomb",
  type: Item.CONSUME,
  iconx: 1,
  icony: 3,
  desc: "Curses the target.",
  usebattle: function(target){
    return target.inflict(buffs.curse);
  },
  target: 'enemy',
  attributes: ['glass', 'bomb']
};
items.firebom = {
  name: "Fire Bomb",
  type: Item.CONSUME,
  iconx: 2,
  icony: 3,
  desc: "Burns the target.",
  usebattle: function(target){
    return target.inflict(buffs.burn);
  },
  target: 'enemy',
  attributes: ['glass', 'bomb']
};
items.icebom = {
  name: "Ice Bomb",
  type: Item.CONSUME,
  iconx: 3,
  icony: 3,
  desc: "Chills the target.",
  usebattle: function(target){
    return target.inflict(buffs.chill);
  },
  target: 'enemy',
  attributes: ['glass', 'bomb']
};
items.cumberground = {
  name: "Cumberground",
  desc: "A useless piece of garbage. Maybe someone else can find value in this item.",
  type: Item.COMMON,
  quantity: 0
};
items.shards = {
  name: "Glass Shards",
  desc: "Jagged shards of glass. Can be reformed into glass vials through glass blowing.",
  type: Item.COMMON,
  iconx: 5
};
items.waterbottle = {
  name: "Water Bottle",
  desc: "Used to spray water at things.",
  type: Item.KEY,
  iconx: 2,
  usebattle: function(target){
    if (target.monstertype === Monster.types.rabies) {
      triggertext("Rabies: NO! WATER IS BAD!");
      if (!target.triggered) {
        target.triggered = true;
        target.loadTexture('monster_rabies2');
        return target.stats.atk /= 2;
      }
    } else {
      return triggertext("It had no effect.");
    }
  },
  target: 'any'
};
items.tunnel_key = {
  name: "Tunnel Key",
  desc: "Opens up Smallpox's maintenance tunnel. The entrance to the tunnel is in a building south of the black tower.",
  type: Item.KEY
};
items.basement_key = {
  name: "Trapdoor Key",
  desc: "Opens up the trapdoors on Earth.",
  type: Item.KEY,
  iconx: 1
};
items.bloodsample = {
  name: "Blood Sample",
  desc: "A sample of human blood. It is marked with a white band.",
  type: Item.KEY,
  icony: 2
};
items.bloodsample2 = {
  name: "Blood Sample",
  desc: "A sample of human blood. It is marked with a black band.",
  type: Item.KEY,
  icony: 2
};
items.necrotoxin = {
  name: "Necrotoxin",
  desc: "A substance specially developed to destroy living flesh.",
  special: true,
  sicon: 'item_key',
  iconx: 4,
  icony: 1,
  target: 'none'
};
items.necrotoxinrecipe = {
  name: "Necrotoxin Recipe",
  desc: "Allows War to synthesize additional necrotoxin.",
  type: Item.KEY,
  iconx: 5,
  icony: 1
};
items.llovmedicine = {
  name: "Love Tonic",
  type: Item.CONSUME,
  desc: "Medicine to help Lloviu-tan feel better.",
  use: function(target){
    return setswitch('llovmedicine', true);
  },
  target: 'ally',
  attributes: ['glass']
};
items.humansoul = {
  name: "Human Soul",
  sicon: 'item_key',
  icony: 1,
  type: Item.COMMON,
  desc: "The souls of humanity."
};
function eat_soul(target, name){
  var level, xp, message;
  level = target.level;
  xp = (levelToXp(level + 1) - levelToXp(level)) * 2;
  target.add_xp(xp, true);
  message = target.level > level
    ? tl("Level up!")
    : tl("{0} xp gained.", xp);
  say('', tl("The soul of {0} has been devoured. {1}", name, message));
}
items.naesoul = {
  name: "Nae's Soul",
  soulname: "Naegleria",
  sicon: 'item_key',
  icony: 1,
  type: Item.CONSUME,
  useoverworld: function(target){
    if (target === llov) {
      switches.llovsick = false;
    }
    setswitch('ate_nae', target.name);
    eat_soul(target, 'Naegleria');
  },
  desc: "Naegleria's soul. If consumed it will grant experience. If kept it can be used to revive Naegleria.",
  target: 'ally',
  unique: true,
  special: true
};
items.chikunsoul = {
  name: "Chikun's Soul",
  soulname: "Chikungunya",
  sicon: 'item_key',
  icony: 1,
  type: Item.CONSUME,
  useoverworld: function(target){
    if (target === llov) {
      switches.llovsick = false;
    }
    setswitch('ate_chikun', target.name);
    eat_soul(target, 'Chikungunya');
  },
  desc: "Chikungunya's soul. If consumed it will grant experience. If kept it can be used to revive Chikungunya.",
  target: 'ally',
  unique: true,
  special: true
};
items.aidssoul = {
  name: "Eidzu's Soul",
  soulname: "Eidzu",
  sicon: 'item_key',
  icony: 1,
  iconx: 1,
  type: Item.CONSUME,
  useoverworld: function(target){
    if (target === llov) {
      switches.llovsick = false;
    }
    setswitch('ate_eidzu', target.name);
    eat_soul(target, 'Eidzu');
  },
  desc: "Eidzu's soul. If consumed it will grant experience. If kept it can be used to revive Eidzu.",
  target: 'ally',
  unique: true,
  special: true
};
items.sarssoul = {
  name: "Sars' Soul",
  soulname: "Sars",
  sicon: 'item_key',
  icony: 1,
  type: Item.CONSUME,
  useoverworld: function(target){
    if (target === llov) {
      switches.llovsick = false;
    }
    setswitch('ate_sars', target.name);
    eat_soul(target, 'Sars');
  },
  desc: "Sars' soul. If consumed it will grant experience. If kept it can be used to revive Sars.",
  target: 'ally',
  unique: true,
  special: true
};
items.rabiessoul = {
  name: "Rabies' Soul",
  soulname: "Rabies",
  sicon: 'item_key',
  icony: 1,
  type: Item.CONSUME,
  useoverworld: function(target){
    if (target === llov) {
      switches.llovsick = false;
    }
    setswitch('ate_rabies', target.name);
    eat_soul(target, 'Rabies');
  },
  desc: "Rabies' soul. If consumed it will grant experience. If kept it can be used to revive Rabies.",
  target: 'ally',
  unique: true,
  special: true
};
items.llovsoul = {
  name: "Lloviu's Soul",
  soulname: "Lloviu",
  sicon: 'item_key',
  icony: 1,
  type: Item.CONSUME,
  useoverworld: function(target){
    setswitch('ate_llov', target.name);
    eat_soul(target, 'Lloviu');
  },
  desc: "Lloviu's soul. If consumed it will grant experience. If kept it can be used to revive Lloviu.",
  target: 'ally',
  unique: true,
  special: true
};
items.soulshard = {
  name: "Soul Shard",
  sicon: 'item_key',
  iconx: 2,
  icony: 1,
  type: Item.CONSUME,
  useoverworld: function(target){
    var level, xp, message;
    level = target.level;
    xp = (levelToXp(level + 1) - levelToXp(level)) / 2;
    target.add_xp(xp, true);
    message = target.level > level
      ? "Level up!"
      : xp + " gained.";
    say('', "Devoured soul shard. " + message);
  },
  desc: "A fragment of a broken soul. It probably contains a bit of experience.",
  target: 'ally',
  unique: false
};
items.excel = {
  name: "Excel Orb",
  sicon: 'item_key',
  iconx: 3,
  type: Item.CONSUME,
  dontconsume: true,
  unique: false,
  useoverworld: function(target){
    excel_screen.launch(target);
  },
  desc: "Permanently unlocks a super-powered transformation for one of your heroes.",
  target: 'ally',
  condition: function(){
    var unlockcount, excelcount, i, j, ref$, f;
    unlockcount = 0;
    excelcount = 0;
    for (i in formes) {
      for (j in ref$ = formes[i]) {
        f = ref$[j];
        if (j === 'default') {
          continue;
        }
        if (f.unlocked) {
          unlockcount++;
        }
        excelcount++;
      }
    }
    return unlockcount + items.excel.quantity < excelcount;
  },
  special: true
};
items.sporb = {
  name: "SP Orb",
  sicon: 'item_key',
  iconx: 3,
  icony: 1,
  type: Item.CONSUME,
  useoverworld: function(target){
    var name, ref$;
    name = target.name;
    (ref$ = switches.sp_limit)[name] == null && (ref$[name] = 1);
    switches.sp_limit[name]++;
    say('', tl("{0}'s limit has raised to {1}!", speakers[name].display, switches.sp_limit[name] * 100 + '%'));
  },
  target: 'ally',
  desc: function(){
    var text, i$, ref$, len$, p;
    text = tl("Raises the maximum SP a hero can charge to beyond 100%.\n\nCurrent levels:\n");
    for (i$ = 0, len$ = (ref$ = party).length; i$ < len$; ++i$) {
      p = ref$[i$];
      text += speakers[p.name].display + '\u2002' + (switches.sp_limit[p.name] || 1) * 100 + '%\n';
    }
    return text;
  },
  special: true
};
items.humanskull = {
  name: "Human Skull",
  sicon: 'item_equip',
  iconx: 4,
  icony: 2,
  type: Item.KEY,
  desc: "Property of Ebola-chan."
};
items.humanskull2 = {
  name: "Human Skull",
  desc: "When held by Ebola-chan it can be used to shoot lasers from the eyes, dealing extra damage for each bleed effect on the enemy.",
  iconx: 4,
  icony: 2,
  type: Item.EQUIP,
  mod_hp: function(s){
    return s * 1.1 + 5;
  },
  skill: function(){
    if (this.parent.name === 'ebby') {
      return skills.skullbeam;
    } else {
      return null;
    }
  }
};
items.shrunkenhead = {
  name: "Shrunken Head",
  type: Item.EQUIP,
  iconx: 5,
  icony: 3,
  desc: "A gift from Zika-chan. Grants a special skill that deals more damage for each status effect on the enemy.",
  mod_luck: function(s){
    return s * 1.1;
  },
  skill: function(){
    return skills.hex;
  }
};
items.spellbook = {
  name: "Spell Book",
  type: Item.CONSUME,
  useoverworld: function(){
    learn_skill('poison');
  },
  desc: "For testing purposes.",
  target: 'none'
};
items.coagulate = {
  name: "Coagulat Tome",
  type: Item.CONSUME,
  useoverworld: function(){
    learn_skill('coagulate');
  },
  condition: function(){
    return !in$('coagulate', skillbook.all);
  },
  desc: "Teaches the coagulate skill, which locks effect slots when used after Hemorrhage.",
  target: 'none',
  unique: true
};
items.healblock = {
  name: "Malus Vital Tome",
  sicon: 'item_misc',
  iconx: 5,
  icony: 4,
  type: Item.CONSUME,
  useoverworld: function(target){
    learn_skill('healblock', target.name);
  },
  desc: "Teaches the Malus Vital skill, which prevents targets from healing.",
  target: 'ally',
  unique: true
};
for (key in items) {
  properties = items[key];
  items[key] = new Item(properties);
  items[key].id = key;
}
crafting = [
  {
    item1: 'pinesap',
    item2: 'medicine',
    result: 'hp1'
  }, {
    item1: 'nectar',
    item2: 'medicine',
    result: 'hp2'
  }, {
    item1: 'aloevera',
    item2: 'medicine',
    result: 'blistercream'
  }, {
    item1: 'pinesap',
    item2: 'silverdust',
    result: 'sp1'
  }, {
    item1: 'nectar',
    item2: 'silverdust',
    result: 'sp2'
  }, {
    item1: 'pinesap',
    item2: 'starpuff',
    result: 'ex1'
  }, {
    item1: 'nectar',
    item2: 'starpuff',
    result: 'ex2'
  }, {
    item1: 'fur',
    item2: 'medicine',
    result: 'bandage'
  }, {
    item1: 'cloth',
    item2: 'medicine',
    result: 'bandage'
  }, {
    item1: 'plantfiber',
    item2: 'medicine',
    result: 'bandage'
  }, {
    item1: 'parchment',
    item2: 'medicine',
    result: 'bandage'
  }, {
    item1: 'fur',
    item2: 'cloth',
    result: 'parchment'
  }, {
    item1: 'cloth',
    item2: 'plantfiber',
    result: 'parchment'
  }, {
    item1: 'plantfiber',
    item2: 'fur',
    result: 'parchment'
  }, {
    item1: 'parchment',
    item2: 'gravedust',
    result: 'teleport'
  }, {
    item1: 'parchment',
    item2: 'silverdust',
    result: 'slowscroll'
  }, {
    item1: 'parchment',
    item2: 'bugbits',
    result: 'swarmscroll'
  }, {
    item1: 'parchment',
    item2: 'sludge',
    result: 'plaguescroll'
  }, {
    item1: 'parchment',
    item2: 'venom',
    result: 'plaguescroll'
  }, {
    item1: 'frozenflesh',
    item2: 'cinder',
    result: 'meat'
  }, {
    item1: 'tuonen',
    item2: 'sludge',
    result: 'antidote'
  }, {
    item1: 'tuonen',
    item2: 'venom',
    result: 'antidote'
  }, {
    item1: 'tuonen',
    item2: 'gravedust',
    result: 'anticurse'
  }, {
    item1: 'tuonen',
    item2: 'cinder',
    result: 'burnheal'
  }, {
    item1: 'tuonen',
    item2: 'frozenflesh',
    result: 'antifreeze'
  }, {
    item1: 'oil',
    item2: 'sludge',
    result: 'poisonbom'
  }, {
    item1: 'oil',
    item2: 'venom',
    result: 'poisonbom'
  }, {
    item1: 'oil',
    item2: 'gravedust',
    result: 'cursebom'
  }, {
    item1: 'oil',
    item2: 'cinder',
    result: 'firebom'
  }, {
    item1: 'oil',
    item2: 'frozenflesh',
    result: 'icebom'
  }, {
    item1: 'silverdust',
    item2: 'bugbits',
    result: 'repel'
  }
];
for (i$ = 0, len$ = crafting.length; i$ < len$; ++i$) {
  recipe = crafting[i$];
  if (typeof recipe.item1 === 'string') {
    recipe.item1 = items[recipe.item1];
  }
  if (typeof recipe.item2 === 'string') {
    recipe.item2 = items[recipe.item2];
  }
  if (typeof recipe.result === 'string') {
    recipe.result = items[recipe.result];
  }
  (ref$ = recipe.item1).craft == null && (ref$.craft = {});
  (ref$ = recipe.item2).craft == null && (ref$.craft = {});
  recipe.item1.craft[recipe.item2.name] = recipe.result;
  recipe.item2.craft[recipe.item1.name] = recipe.result;
}
recipebook = JSON.parse(localStorage.getItem('filosis-recipes')) || {};
function learn_recipe(item1, item2, result){
  recipebook[item1] == null && (recipebook[item1] = {});
  recipebook[item2] == null && (recipebook[item2] = {});
  if (recipebook[item1][item2] === result && recipebook[item2][item1] === result) {
    return;
  }
  recipebook[item1][item2] = result;
  recipebook[item2][item1] = result;
  saveHandler(saveslug + "-recipes", JSON.stringify(recipebook));
}
items_initial = {};
for (key in items) {
  item = items[key];
  if (item.quantity > 0) {
    items_initial[key] = item.quantity;
  }
}
function reset_items(initialize){
  var key, ref$, q;
  for (key in items) {
    items[key].quantity = 0;
  }
  if (!initialize) {
    return;
  }
  for (key in ref$ = items_initial) {
    q = ref$[key];
    items[key].quantity = q;
  }
}
options_mod = [];
pause_menu_mod = [];
function get_option_menu(){
  var ret;
  ret = [
    'Back', 'back', {
      type: 'slider',
      min: 0,
      max: 1,
      label: 'Sound Volume',
      desc: "The volume of regular sound effects."
    }, accessor(sound, 'volume'), {
      type: 'slider',
      min: 0,
      max: 1,
      label: 'Music Volume',
      desc: "The volume of the game music.",
      onswitch: function(){
        music.updatevolume();
      }
    }, accessor(music, 'volume'), {
      type: 'slider',
      min: 0,
      max: 1,
      label: 'Menu Volume',
      desc: "The volume of the menu sounds."
    }, accessor(menusound, 'volume'), {
      type: 'slider',
      min: 0,
      max: 1,
      label: 'Dialog Volume',
      desc: "The volume of the speech effect."
    }, accessor(voicesound, 'volume'), {
      type: 'slider',
      min: 0,
      max: 100,
      label: 'Text Speed',
      desc: "The speed at which dialog text is displayed."
    }, accessor(gameOptions, 'textspeed'), {
      type: 'switch',
      label: 'Battle Text',
      desc: "Enables battle text."
    }, accessor(gameOptions, 'battlemessages'), {
      type: 'switch',
      label: 'Pause on Unfocus',
      desc: "Pauses the game when focus is lost.",
      onswitch: function(){
        game.stage.disableVisibilityChange = !gameOptions.pauseidle;
      }
    }, accessor(gameOptions, 'pauseidle'), {
      type: 'switch',
      label: 'Exact Scaling',
      desc: "Good for screenshots.",
      onswitch: resizeGame
    }, accessor(gameOptions, 'exactscaling')
  ];
  return ret.concat(options_mod);
}
function create_option_menu(screen, x, y, leftside){
  screen.option_desc = screen.createWindow(x + (leftside ? -6.5 : 5.5) * WS, y + WS * 2, 7, 6);
  screen.option_desc.text = screen.option_desc.addText('font', 'Option Text', HWS + 2, HWS, false, 16);
  screen.option_menu = screen.createMenu(x, y, 6, 11);
  screen.option_menu.set.apply(screen.option_menu, get_option_menu());
  screen.option_menu.onChangeSelection = function(){
    var ii;
    ii = this.selected + this.offset;
    this.parent.option_desc.text.change(tl(this.options[ii].desc) || '');
  };
  screen.option_menu.onChangeSelection.call(screen.option_menu);
}
function launch_option_menu(screen){
  screen.nest(screen.option_menu, screen.option_desc);
}
function create_shop_menu(){
  var shop_window, shop_menu, item_list;
  shop_screen = gui.frame.addChild(
  new Screen());
  shop_screen.pauseactors = true;
  shop_screen.lockdialog = true;
  shop_window = shop_screen.addWindow(WS, 0, 18, 11);
  shop_menu = shop_screen.addMenu(2 * WS, 0, 11, 9, true, true);
  shop_menu.inbag = shop_menu.addText(null, '', -HWS, WS * 9);
  shop_menu.currency = shop_menu.addText(null, '', 4 * WS, WS * 9);
  function purchase(item, cost){
    if (player === llov || player === ebby) {
      cost = Math.round(cost * 0.9);
    }
    item_list.push(item);
    return [
      [
        pad_item_name3(item, cost, null, false) + 'c', {
          key: item.sicon,
          x: item.iconx,
          y: item.icony
        }
      ], item.unique && item.quantity > 0
        ? 0
        : function(){
          exchange(cost, items.cumberground, 1, item);
          return refresh_shop();
        }
    ];
  }
  shop_menu.onChangeSelection = function(){
    var i;
    i = shop_menu.selected + shop_menu.offset - 1;
    if (i < 0) {
      shop_menu.inbag.change('');
    } else if (item_list[i].unique && item_list[i].quantity > 0) {
      shop_menu.inbag.change('Sold out');
    } else {
      shop_menu.inbag.change("Owned:" + stattext(item_list[i].quantity, 5));
    }
    if (item_list[i]) {
      say_now(item_list[i].desc);
      dialog.message.empty_buffer();
    }
  };
  refresh_shop = function(){
    var args;
    item_list = [];
    args = [
      'Exit', {
        callback: shop_screen.back,
        context: shop_screen
      }
    ].concat(purchase(items.leatherarmor, 20), purchase(items.platearmor, 50), purchase(items.woodshield, 20), purchase(items.towershield, 50), purchase(items.broadsword, 30), purchase(items.waterbottle, 2), purchase(items.teleport, 5), purchase(items.medicine, 1), purchase(items.vial, 2), purchase(items.pinesap, 3), purchase(items.nectar, 6), purchase(items.oil, 6), purchase(items.hp1, 5), purchase(items.hp2, 10), purchase(items.sp1, 6), purchase(items.sp2, 14));
    shop_menu.set.apply(shop_menu, args);
    shop_menu.currency.change(items.cumberground.name + ":" + stattext(items.cumberground.quantity, 5));
    shop_menu.onChangeSelection();
  };
  shop_screen.kill();
}
function start_shop_menu(){
  refresh_shop();
  shop_screen.show();
  this.say("What are you looking for?");
  dialog.click('ignorelock');
}
function create_pause_menu(){
  var pause_window, status_window2, status_window, status_menu, skill_menu, skill_window, item_window, pause_menu_back, pause_menu, inventory_menu, item_menu, crafting_menu, yicon, ytext, cards, heads, i$, ref$, len$, i, player, head, card, j$, ref1$, len1$, key, status_window_revive, pause_screen_show;
  create_costume_menu();
  create_excel_menu();
  pause_screen = gui.frame.addChild(
  new Screen());
  pause_window = pause_screen.createWindow(0, 0, 14, 15);
  status_window2 = pause_screen.createWindow(WS * 6, 0, 9, 15, true);
  status_window = pause_screen.addWindow(224, 0, 6, 14, true);
  status_menu = pause_screen.createMenu(0, 0, 6, 8);
  skill_menu = pause_screen.createMenu(0, 0, 6, 9);
  skill_window = pause_screen.createWindow(WS * 6, 0, 8, 15);
  skill_window.skillname = skill_window.addText(null, '', WS, HWS);
  skill_window.skilldesc = skill_window.addText(null, '', 7, WS + HWS, null, 19);
  item_window = pause_screen.createWindow(0, 0, 14, 15);
  item_window.icon = item_window.addChild(
  new Phaser.Sprite(game, WS + 5, WS + 5, 'item_equip'));
  item_window.icon.anchor.set(0.5);
  item_window.itemname = item_window.addText(null, '', IS + 5, WS);
  item_window.itemdesc = item_window.addText(null, '', 8, IS + WS, null, 19);
  create_option_menu(pause_screen, 64, 16);
  pause_menu_back = {
    callback: pause_screen.back,
    context: pause_screen
  };
  pause_screen.menu = pause_menu = pause_screen.addMenu(64, 32, 6, 8);
  pause_screen.inventory = inventory_menu = pause_screen.createMenu(WS * 2, 0, 11, 15, true, true);
  item_menu = pause_screen.createMenu(item_window.x + 128, WS, 6, 14, true);
  item_menu.item = items.hp1;
  pause_screen.crafting = crafting_menu = pause_screen.createMenu(WS * 2, WS * 4, 11, 11, true, true);
  crafting_menu.item = items.hp1;
  crafting_menu.lastitem = items.hp1;
  crafting_menu.lastquantity = 0;
  yicon = -WS * 3;
  ytext = -WS * 3 - FH / 2;
  crafting_menu.itemicon = crafting_menu.addChild(
  new Phaser.Sprite(game, 0, yicon, 'item_pot'));
  crafting_menu.itemicon.anchor.set(0.5);
  crafting_menu.itemname = crafting_menu.addText(null, '', WS, ytext);
  crafting_menu.plus = crafting_menu.addText(null, '+', WS * 2, ytext + 14);
  crafting_menu.item2icon = crafting_menu.addChild(
  new Phaser.Sprite(game, 0, yicon + 24, 'item_pot'));
  crafting_menu.item2icon.anchor.set(0.5);
  crafting_menu.item2name = crafting_menu.addText(null, '', WS, ytext + 24);
  crafting_menu.equal = crafting_menu.addText(null, '=', WS * 2, ytext + 38);
  crafting_menu.resulticon = crafting_menu.addChild(
  new Phaser.Sprite(game, 0, yicon + 48, 'item_pot'));
  crafting_menu.resulticon.anchor.set(0.5);
  crafting_menu.resultname = crafting_menu.addText(null, '? ? ?', WS, ytext + 48);
  crafting_menu.resulticon.kill();
  cards = {};
  heads = {};
  for (i$ = 0, len$ = (ref$ = players).length; i$ < len$; ++i$) {
    i = i$;
    player = ref$[i$];
    head = heads[player.name] = inventory_menu.addChild(
    new Phaser.Image(game, 0, 0, "head_" + player.name));
    head.anchor.set(0, 9 / head.height);
    head.kill();
    head.x = 110;
    head.player = player;
    card = cards[player.name] = status_window.addChild(
    new StatusCard(0, 0, player));
    card.details = status_window2.addChild(
    new Window(0, 0, 9, 5));
    card.details.card = card;
    card.details.base = card.base;
    for (j$ = 0, len1$ = (ref1$ = ['atk', 'def', 'spd', 'lck']).length; j$ < len1$; ++j$) {
      i = j$;
      key = ref1$[j$];
      card.details[key + 1] = card.details.addText(null, '', HWS + 5, WS * i + 9);
      card.details[key + 2] = card.details.addText('font_gray', '', WS * 5, WS * i + 9);
    }
    card.details.updatestattext = fn$;
  }
  status_window_revive = function(){
    var key, ref$, card, i$, len$, i, player, j$, ref1$, len1$;
    for (key in ref$ = cards) {
      card = ref$[key];
      if (card.alive) {
        card.kill();
      }
      if (status_window2.alive && card.details.alive) {
        card.details.kill();
      }
    }
    for (i$ = 0, len$ = (ref$ = party).length; i$ < len$; ++i$) {
      i = i$;
      player = ref$[i$];
      card = cards[player.name];
      card.revive();
      card.y = [0, 80, 160][i];
      card.calc_stats();
      if (status_window2.alive) {
        card.details.revive();
        card.details.y = card.y;
        for (j$ = 0, len1$ = (ref1$ = ['atk', 'def', 'spd', 'lck']).length; j$ < len1$; ++j$) {
          key = ref1$[j$];
          card['old_' + key] = card.details.updatestattext(key);
          card.details[key + 2].change('');
        }
        card.old_hp = Math.ceil(card.get_stat('hp'));
      }
      card.hptext.change('');
      card.update_stats();
    }
  };
  status_window.onRevive = function(){
    status_window_revive.apply(this, arguments);
  };
  status_window_revive.call(status_window);
  pause_menu.set.apply(pause_menu, [
    tl("Resume"), pause_menu_back, tl("Items"), launch_inventory_menu, tl("Skills"), launch_skill_menu, tl("Status"), launch_status_menu, tl("Options"), {
      callback: launch_option_menu,
      arguments: [pause_screen]
    }, tl("Quit"), quitgame
  ].concat(pause_menu_mod));
  pause_screen.kill();
  function launch_inventory_menu(filter){
    filter == null && (filter = {});
    pause_screen.nest(filter, pause_window, inventory_menu, status_window);
  }
  skill_menu.onRevive = function(){
    var forme, player, skillset, mode, skill, args, skillist, key, ref$, level, i$, i, sk, len$, action, to$;
    forme = pause_screen.windows[0].forme;
    player = pause_screen.windows[0].player;
    if (player && forme) {
      skillset = player.skills[forme.id];
    }
    mode = pause_screen.windows[0].mode;
    skill = pause_screen.windows[0].skill;
    args = [mode === 'moveskill' || mode === 'placeskill' ? 'Cancel' : 'Back', pause_menu_back];
    this.resize(this.w, mode === 'addskill'
      ? 15
      : !mode ? 9 : 8);
    if (mode === 'placeskill') {
      skill_menu.onChangeSelection = function(i){
        var i$, to$, ii;
        for (i$ = 1, to$ = this.buttons.length; i$ < to$; ++i$) {
          ii = i$;
          this.buttons[ii].change(this.options[ii]);
        }
        if (i > 0) {
          this.buttons[i].change(skill.name);
        }
      };
    } else if (mode === 'moveskill') {
      skill_menu.onChangeSelection = function(i){
        var ii, list, i$, to$;
        ii = this.objects.indexOf(skill);
        list = this.objects.slice();
        list.splice(ii, 1);
        for (i$ = 0, to$ = 5 - this.objects.length; i$ < to$; ++i$) {
          list.push({
            name: ' -'
          });
        }
        list.splice((i || ii + 1) - 1, 0, skill);
        for (i$ = 1, to$ = this.buttons.length; i$ < to$; ++i$) {
          ii = i$;
          this.buttons[ii].change(list[ii - 1].name);
        }
      };
    } else if (mode === 'dowhat') {
      skill_menu.onChangeSelection = function(i){};
    } else {
      skill_menu.onChangeSelection = function(i){
        var name, desc;
        i = --i;
        if (i >= 0 && i < this.objects.length) {
          name = this.objects[i].name;
          desc = access(this.objects[i].desc) || '';
          desc += "\nSP:" + access(this.objects[i].sp) + "%";
        }
        skill_window.skillname.change(name || '');
        skill_window.skilldesc.change(desc || 'No skill selected');
      };
    }
    if (mode === 'addskill') {
      skillist = [];
      for (key in ref$ = forme.skills) {
        level = ref$[key];
        if (player.level >= level) {
          skillist.push(skills[key]);
        }
      }
      skillist = skillist.concat(skillbook[player.name][forme.id], skillbook[player.name].all, skillbook.all);
      for (i$ = skillist.length - 1; i$ >= 0; --i$) {
        i = i$;
        sk = skillist[i$];
        if (skillist.indexOf(sk) !== i) {
          skillist.splice(i, 1);
        }
      }
      skillist.sort(function(a, b){
        return a.name.localeCompare(b.name);
      });
      this.objects = skillist;
      for (i$ = 0, len$ = skillist.length; i$ < len$; ++i$) {
        i = i$;
        sk = skillist[i$];
        if (in$(sk, skillset)) {
          args.push(sk.name, 0);
        } else {
          args.push(sk.name, {
            callback: launch_skill_menu,
            arguments: [{
              player: player,
              forme: forme,
              mode: 'placeskill',
              skill: sk
            }]
          });
        }
      }
    } else if (mode === 'dowhat') {
      args.push('Move', {
        callback: launch_skill_menu,
        arguments: [{
          player: player,
          forme: forme,
          mode: 'moveskill',
          skill: skill
        }]
      }, 'Remove', [
        function(){
          skillset.splice(skillset.indexOf(skill), 1);
          save();
        }, pause_menu_back
      ]);
    } else {
      if (mode === 'placeskill') {
        action = function(i, skill){
          var ref$;
          skillset[i < (ref$ = skillset.length) ? i : ref$] = skill;
          save();
        };
      } else if (mode === 'moveskill') {
        action = function(i, skill){
          skillset.splice(skillset.indexOf(skill), 1);
          skillset.splice(i, 0, skill);
          save();
        };
      }
      this.objects = skillset;
      for (i$ = 0, len$ = skillset.length; i$ < len$; ++i$) {
        i = i$;
        sk = skillset[i$];
        if (mode === 'placeskill' || mode === 'moveskill') {
          args.push(sk.name, [
            {
              callback: action,
              arguments: [i, skill]
            }, pause_menu_back, pause_menu_back
          ]);
        } else {
          args.push(sk.name, {
            callback: launch_skill_menu,
            arguments: [{
              player: player,
              forme: forme,
              mode: 'dowhat',
              skill: sk
            }]
          });
        }
      }
      for (i$ = 0, to$ = 5 - skillset.length; i$ < to$; ++i$) {
        i = i$;
        if (mode === 'placeskill' || mode === 'moveskill') {
          args.push(' -', [
            {
              callback: action,
              arguments: [i + skillset.length, skill]
            }, pause_menu_back, pause_menu_back
          ]);
        } else {
          args.push(' -', 0);
        }
      }
      if (!mode) {
        args.push('Add skill...', {
          callback: launch_skill_menu,
          arguments: [{
            player: player,
            forme: forme,
            mode: 'addskill'
          }]
        });
      }
    }
    this.set.apply(this, args);
    this.onChangeSelection(this.selected);
  };
  function launch_skill_menu(properties){
    var p, args, key, ref$, f, i$, len$;
    properties == null && (properties = {});
    if (properties.forme) {
      pause_screen.nest(properties, skill_window, skill_menu, status_window);
    } else if (p = properties.player) {
      if (p.excel_unlocked()) {
        args = [
          'Back', {
            callback: pause_menu.cancel,
            context: pause_menu
          }, 'Default', {
            callback: launch_skill_menu,
            arguments: [{
              player: p,
              forme: formes[p.name]['default']
            }]
          }
        ];
        for (key in ref$ = formes[p.name]) {
          f = ref$[key];
          if (f.unlocked) {
            args.push(f.name, {
              callback: launch_skill_menu,
              arguments: [{
                player: p,
                forme: f
              }]
            });
          }
        }
        pause_menu.nest.apply(pause_menu, args);
      } else {
        launch_skill_menu({
          player: p,
          forme: formes[p.name]['default']
        });
      }
    } else {
      if (party.length > 1) {
        args = [
          'Back', {
            callback: pause_menu.cancel,
            context: pause_menu
          }
        ];
        for (i$ = 0, len$ = (ref$ = party).length; i$ < len$; ++i$) {
          p = ref$[i$];
          args.push(speakers[p.name].display, {
            callback: launch_skill_menu,
            arguments: [{
              player: p
            }]
          });
        }
        pause_menu.nest.apply(pause_menu, args);
      } else {
        launch_skill_menu({
          player: party[0]
        });
      }
    }
    skill_menu.onChangeSelection(skill_menu.selected);
  }
  status_menu.onRevive = function(){
    var item, mode, args, i$, ref$, len$, player;
    item = pause_screen.windows[0].item;
    mode = pause_screen.windows[0].mode;
    if (item) {
      args = [tl("Cancel"), pause_menu_back];
      for (i$ = 0, len$ = (ref$ = party).length; i$ < len$; ++i$) {
        player = ref$[i$];
        args.push(speakers[player.name].display);
        args.push([
          {
            callback: equip_item,
            arguments: [item, player]
          }, pause_menu_back
        ]);
      }
      if (item.equip) {
        args.push(tl("Unequip"), [
          {
            callback: equip_item,
            arguments: [item, null]
          }, pause_menu_back
        ]);
      }
      this.set.apply(this, args);
      this.onChangeSelection = function(i){
        var k, ref$, card, i$, ref1$, len$, key, diff;
        i = --i;
        for (k in ref$ = cards) {
          card = ref$[k];
          if (i >= 0 && card.base.equip.id === item.id) {
            card.item.load_buff();
          } else {
            card.item.load_buff(card.base.equip);
          }
        }
        if (i >= 0 && i < party.length) {
          cards[party[i].name].item.load_buff(item);
        }
        for (k in ref$ = cards) {
          card = ref$[k];
          for (i$ = 0, len$ = (ref1$ = ['atk', 'def', 'spd', 'lck']).length; i$ < len$; ++i$) {
            key = ref1$[i$];
            card['new_' + key] = card.details.updatestattext(key);
            diff = card['new_' + key] - card['old_' + key];
            card.details[key + 2].change((diff < 0 ? '' : '+') + stattext(diff, 5), diff < 0
              ? 'font_red'
              : diff > 0 ? 'font_green' : 'font_gray');
          }
          card.new_hp = Math.ceil(card.get_stat('hp'));
          diff = card.new_hp - card.old_hp;
          card.hptext.change((diff < 0 ? '' : '+') + stattext(diff, 5), diff < 0
            ? 'font_red'
            : diff > 0 ? 'font_green' : 'font_gray');
          card.update_stats();
        }
      };
      this.onChangeSelection(this.selected);
    } else if (mode === 'leader') {
      args = [tl("Cancel"), 'back'];
      for (i$ = 0, len$ = (ref$ = party).length; i$ < len$; ++i$) {
        player = ref$[i$];
        args.push(speakers[player.name].display);
        args.push([
          {
            callback: change_leader,
            arguments: [player]
          }, pause_menu_back
        ]);
      }
      this.set.apply(this, args);
    } else {
      this.set(tl("Back"), pause_menu_back, tl("Equipment"), {
        callback: launch_inventory_menu,
        arguments: [{
          sortmode: 'bytype',
          type: Item.EQUIP,
          action: 'equip'
        }]
      }, tl("Change Leader"), {
        callback: launch_status_menu,
        arguments: [{
          mode: 'leader'
        }]
      });
      this.onChangeSelection = function(){};
    }
  };
  function launch_status_menu(properties){
    properties == null && (properties = {});
    pause_screen.nest(properties, status_window2, status_window, status_menu);
  }
  item_menu.onRevive = function(){
    if (this.item.quantity <= 0) {
      pause_screen.back();
    }
  };
  inventory_menu.onRefresh = function(){
    var key, ref$, head, i$, ref1$, len$, i, button, item, ref2$, ref3$;
    for (key in ref$ = heads) {
      head = ref$[key];
      head.kill();
      for (i$ = 0, len$ = (ref1$ = inventory_menu.buttons).length; i$ < len$; ++i$) {
        i = i$;
        button = ref1$[i$];
        if (!(item = (ref2$ = inventory_menu.actions[i + inventory_menu.offset]) != null ? (ref3$ = ref2$.arguments) != null ? ref3$[0] : void 8 : void 8)) {
          continue;
        }
        if (item.equip === head.player) {
          head.y = button.y;
          head.revive();
          break;
        }
      }
    }
  };
  inventory_menu.onRevive = function(){
    var sort, args, inventory, key, ref$, item, i$, len$, i;
    sort = pause_screen.windows[0];
    args = ['Back', pause_menu_back];
    if (sort.sortmenu) {
      args.push('Alphabet', {
        callback: launch_inventory_menu,
        arguments: [{
          sortmode: 'alphabet'
        }]
      });
      args.push('Equipment', {
        callback: launch_inventory_menu,
        arguments: [{
          sortmode: 'bytype',
          type: Item.EQUIP
        }]
      });
      args.push('Special Items', {
        callback: launch_inventory_menu,
        arguments: [{
          sortmode: 'special'
        }]
      });
      args.push('Common Items', {
        callback: launch_inventory_menu,
        arguments: [{
          sortmode: 'bytype',
          type: Item.COMMON
        }]
      });
      args.push('Consumables', {
        callback: launch_inventory_menu,
        arguments: [{
          sortmode: 'bytype',
          type: Item.CONSUME
        }]
      });
      args.push('Crafting', {
        callback: launch_inventory_menu,
        arguments: [{
          sortmode: 'crafting'
        }]
      });
      this.set.apply(this, args);
      return;
    }
    if (!sort.sortmode) {
      args.push('Sort...', {
        callback: launch_inventory_menu,
        arguments: [{
          sortmenu: true
        }]
      });
    }
    inventory = [];
    for (key in ref$ = items) {
      item = ref$[key];
      if (sort.sortmode === 'bytype' && item.type !== sort.type) {
        continue;
      }
      if (sort.sortmode === 'crafting' && !item.craft) {
        continue;
      }
      if (sort.sortmode === 'special' && item.type !== Item.KEY && !item.special) {
        continue;
      }
      if (item.quantity > 0) {
        inventory.push(item);
      }
    }
    if (sort.sortmode === 'alphabet') {
      inventory.sort(function(a, b){
        return a.name.localeCompare(b.name);
      });
    } else {
      inventory.sort(function(a, b){
        return b.time - a.time;
      });
    }
    for (i$ = 0, len$ = inventory.length; i$ < len$; ++i$) {
      i = i$;
      item = inventory[i$];
      args.push([
        pad_item_name3(item), {
          key: item.sicon,
          x: item.iconx,
          y: item.icony
        }
      ]);
      if (sort.action === 'equip') {
        args.push({
          callback: launch_status_menu,
          arguments: [{
            item: item
          }]
        });
      } else {
        args.push({
          callback: launch_item_menu,
          arguments: [item]
        });
      }
    }
    this.set.apply(this, args);
    function launch_item_menu(item){
      var args, use;
      item_menu.item = item;
      pause_screen.nest(item_window, item_menu, status_window);
      args = ['Back', pause_menu_back];
      if (use = item.use || item.useoverworld) {
        switch (item.target) {
        case 'ally':
          args.push('Use', {
            callback: item_use_menu,
            arguments: [item]
          });
          break;
        case 'allies':
        case 'all':
          args.push('Use', [
            {
              callback: function(){
                var i$, ref$, len$, member;
                for (i$ = 0, len$ = (ref$ = party).length; i$ < len$; ++i$) {
                  member = ref$[i$];
                  use(member);
                }
              }
            }, {
              callback: item_used,
              arguments: [item]
            }
          ]);
          break;
        default:
          args.push('Use', [
            use, {
              callback: item_used,
              arguments: [item]
            }
          ]);
        }
      }
      if (item.type === Item.EQUIP) {
        args.push('Equip', {
          callback: launch_status_menu,
          arguments: [{
            item: item
          }]
        });
        if (item.equip) {
          args.push('Unequip', {
            callback: equip_item,
            arguments: [item, null]
          });
        }
      }
      if (item.craft != null) {
        args.push('Combine', {
          callback: launch_crafting_menu,
          arguments: [item]
        });
      }
      item_menu.set.apply(item_menu, args);
      item_window.icon.loadTexture(item.icon || item.sicon);
      item_window.icon.frame = item.iconx;
      setrow(item_window.icon, item.icony);
      item_window.itemname.change(item.name);
      item_window.itemdesc.change(access(item.desc) || '');
    }
    function launch_crafting_menu(item){
      pause_screen.nest(pause_window, crafting_menu, status_window);
      crafting_menu.item = item;
      refresh_crafting_menu.call(crafting_menu);
      crafting_change_selection.call(crafting_menu);
      crafting_menu.onChangeSelection = crafting_change_selection;
    }
    function refresh_crafting_menu(){
      var craftinv, key, ref$, item, args, i$, len$, i;
      craftinv = [];
      for (key in ref$ = inventory) {
        item = ref$[key];
        if (item.craft != null) {
          craftinv.push(item);
        }
      }
      args = ['Back', pause_menu_back];
      for (i$ = 0, len$ = craftinv.length; i$ < len$; ++i$) {
        i = i$;
        item = craftinv[i$];
        if (item === this.item) {
          continue;
        }
        args.push([
          pad_item_name3(item), {
            key: item.sicon,
            x: item.iconx,
            y: item.icony
          }
        ]);
        if (this.item.quantity <= 0 || item.quantity <= 0) {
          args.push(0);
        } else {
          args.push({
            callback: craft,
            arguments: [this.item, item]
          });
        }
      }
      this.set.apply(this, args);
      this.itemicon.loadTexture(this.item.icon || this.item.sicon);
      this.itemicon.frame = this.item.iconx;
      setrow(this.itemicon, this.item.icony);
      this.itemname.change(pad_item_name3(this.item));
    }
    function crafting_change_selection(){
      var item2, ref$;
      if (item2 = (ref$ = this.actions[this.selected + this.offset].arguments) != null ? ref$[1] : void 8) {
        setresult.call(this, this.item, item2);
      } else {
        this.item2icon.kill();
        this.item2name.change('');
        this.resulticon.kill();
        this.resultname.change('');
      }
    }
    function craft(item1, item2){
      var result;
      result = item1.craft[item2.name] || (in$('glass', item1.attributes) || in$('glass', item2.attributes)) && items.shards || items.cumberground;
      learn_recipe(item1.id, item2.id, result.id);
      acquire(item1, -1, true, true);
      acquire(item2, -1, true, true);
      acquire(result, 1, true, true);
      if (result === items.shards) {
        acquire(items.cumberground, 2, true, true);
        items.cumberground.time += 1;
      }
      result.time += 2;
      refresh_crafting_menu.call(crafting_menu);
      save();
      if (crafting_menu.lastitem === result) {
        crafting_menu.lastquantity++;
      } else {
        crafting_menu.lastquantity = 1;
      }
      crafting_menu.lastitem = result;
      setresult.call(crafting_menu, item1, item2);
    }
    function setresult(item1, item2){
      var result;
      this.item2icon.revive();
      this.item2icon.loadTexture(item2.icon || item2.sicon);
      this.item2icon.frame = item2.iconx;
      setrow(this.item2icon, item2.icony);
      this.item2name.change(pad_item_name3(item2));
      if (recipebook[item1.id] && (result = recipebook[item1.id][item2.id])) {
        result = items[result];
        this.resulticon.revive();
        this.resultname.change(pad_item_name3(result, result.quantity));
        this.resulticon.loadTexture(result.icon || result.sicon);
        this.resulticon.frame = result.iconx;
        setrow(this.resulticon, result.icony);
      } else {
        this.resulticon.kill();
        this.resultname.change('? ? ?');
      }
    }
    /*
    !function item_equip_menu (item)
        args = ['Equip to...' callback:item_menu.cancel, context:item_menu]
        for player in party
            continue if player.equip is item
            args.push speakers[player.name]display
            args.push callback: equip_item, arguments: [item, player]
        args.push \Unequip callback: equip_item, arguments: [item, null] if item.equip
        item_menu.nest.apply item_menu, args
        #@refresh!
    */
    function item_use_menu(item){
      var args, i$, ref$, len$, player;
      args = [
        'Cancel', {
          callback: item_menu.cancel,
          context: item_menu
        }
      ];
      for (i$ = 0, len$ = (ref$ = party).length; i$ < len$; ++i$) {
        player = ref$[i$];
        args.push(speakers[player.name].display);
        args.push([
          {
            callback: item.use || item.useoverworld,
            arguments: [player],
            context: item
          }, {
            callback: item_used,
            arguments: [item]
          }
        ]);
      }
      item_menu.nest.apply(item_menu, args);
    }
  };
  function item_used(item){
    item.consume();
    item.time = Date.now();
    pause_screen.inventory.offset = 0;
    pause_screen.back();
  }
  function equip_item(item, player){
    var itemequip;
    itemequip = item.equip;
    if (player != null) {
      player.equip.equip = null;
    }
    if (itemequip != null) {
      itemequip.equip = buffs['null'];
    }
    if (player != null) {
      player.equip = item;
    }
    item.equip = player;
    pause_screen.back();
    save();
  }
  pause_screen.pauseactors = true;
  pause_screen_show = function(e){
    var ref$;
    if (actors.paused || switches.cinema || ((ref$ = e != null ? e.button : void 8) !== undefined && ref$ !== 2)) {
      return;
    }
    pause_screen.show();
    return false;
  };
  keyboard.cancel.onDown.add(pause_screen_show, pause_screen, 1);
  game.input.onDown.add(pause_screen_show, pause_screen, 1);
  function fn$(key){
    var stat, label, value;
    switch (key) {
    case 'atk':
      stat = 'atk';
      label = 'ATK';
      break;
    case 'def':
      stat = 'def';
      label = 'DEF';
      break;
    case 'spd':
      stat = 'speed';
      label = 'SPD';
      break;
    case 'lck':
      stat = 'luck';
      label = 'LCK';
    }
    value = Math.ceil(this.card.get_stat(stat));
    this[key + 1].change(label + ': ' + stattext(value, 5));
    return value;
  }
}
function equip_item(item, player, nosave){
  var itemequip;
  nosave == null && (nosave = false);
  itemequip = item.equip;
  if (player != null) {
    player.equip.equip = null;
  }
  if (itemequip != null) {
    itemequip.equip = buffs['null'];
  }
  if (player != null) {
    player.equip = item;
  }
  item.equip = player;
  if (!nosave) {
    save();
  }
}
function trim_quantity(quantity, digits){
  digits == null && (digits = 2);
  return quantity >= Math.pow(10, digits) ? '*' + quantity.toString().slice(quantity.toString().length - digits + 1) : quantity;
}
function pad_item_name(item, quantity, digits, hide_unique){
  quantity == null && (quantity = item.quantity);
  digits == null && (digits = 5);
  hide_unique == null && (hide_unique = true);
  quantity = stattext(quantity, digits);
  return pad('             ', item.name) + (item.unique && hide_unique
    ? ''
    : " " + quantity);
}
function pad_item_name2(item, places, quantity, hide_unique){
  var digits, q;
  places == null && (places = 16);
  quantity == null && (quantity = item.quantity);
  hide_unique == null && (hide_unique = true);
  if (item.unique && hide_unique) {
    return item.name;
  }
  digits = places - item.name.length;
  q = stattext(quantity, digits);
  if (q.toString().length > digits) {
    q = trim_quantity(quantity, digits);
  }
  return item.name + pad(repeatString$(' ', digits), q, true);
}
function pad_item_name3(item, quantity, digits, hide_unique, plen){
  var text, spacewidth, nspacewidth, width, i$, len$, char;
  quantity == null && (quantity = item.quantity);
  digits == null && (digits = 5);
  hide_unique == null && (hide_unique = true);
  plen == null && (plen = 13 * FW);
  text = item.name;
  spacewidth = charlen(' ');
  nspacewidth = charlen("\u2009");
  width = 0;
  for (i$ = 0, len$ = text.length; i$ < len$; ++i$) {
    char = text[i$];
    width += charlen(char);
  }
  while (width < plen) {
    if (plen - width > spacewidth) {
      text += ' ';
      width += spacewidth;
    } else {
      text += "\u2009";
      width += nspacewidth;
    }
  }
  if (!item.unique || !hide_unique) {
    text += " " + stattext(quantity, digits);
  }
  return text;
}
function pad_item_name4(item, places, quantity, hide_unique){
  var width, i$, ref$, len$, char, digits, q;
  places == null && (places = 16);
  quantity == null && (quantity = item.quantity);
  hide_unique == null && (hide_unique = true);
  if (item.unique && hide_unique) {
    return item.name;
  }
  width = 0;
  for (i$ = 0, len$ = (ref$ = item.name).length; i$ < len$; ++i$) {
    char = ref$[i$];
    width += charlen(char);
  }
  digits = (places * FW - width) / FW | 0;
  q = stattext(quantity, digits);
  if (q.toString > digits) {
    q = trim_quantity(quantity, digits);
  }
  return item.name + pad(repeatString$("\u2007", digits), q, true);
}
function create_title_menu(){
  var title_menu, load_window, load_menu, largs, files, filelist, filecount, ref$, name, file, windows, i$, i, win, j$, j, args;
  title_screen = gui.title.addChild(
  new Screen());
  title_screen.nocancel = true;
  title_menu = title_screen.addMenu(WIDTH - WS * 6, HEIGHT - WS * 6, 6, 6);
  load_window = title_screen.createWindow(0, 0, 20, 15, true);
  load_menu = title_screen.createMenu(0, -WS, 20, 17, true, null, 5 * WS);
  create_option_menu(title_screen, WIDTH - WS * 6, HEIGHT - WS * 11, true);
  largs = [];
  files = getFiles();
  filelist = [];
  filecount = (ref$ = Object.keys(files).length) < 3 ? ref$ : 3;
  for (name in files) {
    file = files[name];
    filelist.push(file);
    largs.push(name, {
      callback: load_from_menu,
      arguments: [name]
    });
  }
  load_menu.set.apply(load_menu, largs);
  load_menu.y = (3 - filecount) * 40 - WS;
  windows = [];
  for (i$ = 0; i$ < filecount; ++i$) {
    i = i$;
    windows.push(win = load_window.addChild(
    new Window(0, (3 - filecount) * 40 + i * load_menu.BH, 20, 5)));
    win.ports = [];
    for (j$ = 0; j$ < 3; ++j$) {
      j = j$;
      win.ports.push(win.addChild(
      new Phaser.Sprite(game, 5 * WS * j + WS * 3, -WS + 5, '')));
      win.ports[j].item = win.ports[j].addChild(
      new Phaser.Sprite(game, WS, WS * 3, ''));
      (win.ports[j].level = win.ports[j].addChild(
      new Text('font_yellow', 'Level', WS * 5, WS * 5))).anchor.set(0.5, 0);
    }
  }
  args = ['New Game', newgame];
  if (filecount > 1) {
    if (largs.length > 0) {
      args.unshift('Continue', launch_load_menu);
    }
  } else {
    if (largs.length > 0) {
      args.unshift('Continue', {
        callback: load,
        arguments: [Object.keys(getFiles())[0]]
      });
    }
  }
  args.push('Options', {
    callback: launch_option_menu,
    arguments: [title_screen]
  });
  args.push('Manage Saves', function(){
    savemanager.readFiles();
    saveman.style.display = 'block';
  });
  title_menu.set.apply(title_menu, args);
  title_screen.show();
  function launch_load_menu(properties){
    title_screen.nest(properties, load_window, load_menu);
  }
  function load_from_menu(file){
    if (title_screen.windows[0] === 'delete') {
      deleteFile(file);
      quitgame();
    } else {
      load(file);
    }
  }
  load_menu.onRefresh = function(){
    var i$, ref$, len$, i, win, j$, j, fp, item, ref1$, ref2$, ref3$;
    for (i$ = 0, len$ = (ref$ = windows).length; i$ < len$; ++i$) {
      i = i$;
      win = ref$[i$];
      for (j$ = 0; j$ < 3; ++j$) {
        j = j$;
        if (fp = filelist[i + this.offset].party[j]) {
          win.ports[j].revive();
          win.ports[j].loadTexture(get_costume(fp.name, 0, fp.costume));
          win.ports[j].frame = get_costume(fp.name, 0, fp.costume, 'bframe');
          win.ports[j].level.change('' + xpToLevel(fp.xp));
          item = win.ports[j].item;
          win.ports[j].item.loadTexture(access((ref1$ = items[fp.item]) != null ? ref1$.icon : void 8));
          win.ports[j].item.frame = ((ref2$ = items[fp.item]) != null ? ref2$.iconx : void 8) || 0;
          setrow(win.ports[j].item, ((ref3$ = items[fp.item]) != null ? ref3$.icony : void 8) || 0);
        } else {
          win.ports[j].kill();
        }
      }
    }
  };
}
function create_costume_menu(){
  var costume_window, costume_menu, i$, i, w, set_costume;
  costume_screen = gui.frame.addChild(
  new Screen());
  costume_screen.pauseactors = true;
  costume_window = costume_screen.addWindow(WIDTH - 7 * WS, 0, 7, 15, true);
  costume_menu = costume_screen.addMenu(WIDTH - 7 * WS, -WS, 7, 17, true, null, 5 * WS);
  costume_menu.windows = [];
  for (i$ = 0; i$ < 3; ++i$) {
    i = i$;
    costume_menu.windows.push(w = costume_window.addChild(
    new Window(0, i * 5 * WS, 7, 5)));
    w.port = w.addChild(
    new Phaser.Sprite(game, (w.w - 6) * WS + 5, 5 - WS, ''));
  }
  costume_screen.launch = function(p){
    var args, key, ref$, costume;
    if (typeof p === 'object') {
      p = p.name;
    }
    costume_menu.player = p;
    costume_menu.offset = 0;
    args = [];
    costume_menu.costumes = [];
    for (key in ref$ = costumes[p]) {
      costume = ref$[key];
      args.push(costume.name, {
        callback: set_costume,
        arguments: [p, key]
      });
      costume_menu.costumes.push(key);
    }
    costume_menu.set.apply(costume_menu, args);
    costume_screen.show();
  };
  costume_menu.onRefresh = function(){
    var i$, ref$, len$, i, win;
    for (i$ = 0, len$ = (ref$ = this.windows).length; i$ < len$; ++i$) {
      i = i$;
      win = ref$[i$];
      win.revive();
      i = i + this.offset;
      if (i >= this.costumes.length) {
        win.kill();
      } else {
        win.port.loadTexture(get_costume(this.player, 0, this.costumes[i]));
        win.port.frame = get_costume(this.player, 0, this.costumes[i], 'bframe');
      }
    }
  };
  set_costume = function(p, c){
    if (typeof p === 'string') {
      p = players[p];
    }
    p.costume = c;
    update_costume(p, c);
    save();
    costume_screen.back();
  };
}
function update_costume(p, c){
  var costume;
  if (!c) {
    if (p.key !== p.name) {
      p.loadTexture(p.name);
    }
    p.setrow(0);
    return;
  }
  costume = costumes[p.name][c];
  if (!costume) {
    return console.warn("costume " + c + " doesn't exist.");
  }
  if (costume.csheet && costume.csheet !== p.key) {
    p.loadTexture(costume.sheet);
  }
  if (costume.crow) {
    p.setrow(costume.crow);
  } else {
    p.setrow(0);
  }
}
function create_excel_menu(){
  var excel_window, excel_menu, i$, ref$, len$, i, b, unlock_form;
  excel_screen = gui.frame.addChild(
  new Screen());
  excel_screen.pauseactors = true;
  excel_window = excel_screen.addWindow(0, WS * 3.5, 20, 8, false);
  excel_menu = excel_screen.addMenu(0, WS * 3, 20, 5, true, null);
  excel_menu.horizontalmove = true;
  for (i$ = 0, len$ = (ref$ = excel_menu.buttons).length; i$ < len$; ++i$) {
    i = i$;
    b = ref$[i$];
    if (i === 0) {
      b.BH = WS;
      continue;
    } else {
      b.BW = excel_menu.w * HWS - 10;
      b.x = b.BW * (i - 1) + 10 * i;
      b.y = 5 * WS;
      b.BH = WS * 7;
    }
    b.port = b.addChild(
    new Phaser.Sprite(game, WS * 3, -2 * WS - 3, ''));
    b.formname = b.addChild(new Text(null, 'NAME', WS, -WS * 3 + 4));
    b.formdesc = b.addChild(new Text(null, 'DESC', 0, -WS * 2, null, 16));
  }
  excel_screen.launch = function(p){
    var args, key, ref$, form, i$, len$, i, b;
    if (typeof p === 'object') {
      p = p.name;
    }
    excel_menu.player = players[p];
    excel_menu.offset = 0;
    args = [
      'Cancel', {
        callback: this.back,
        context: this
      }
    ];
    excel_menu.forms = [];
    for (key in ref$ = formes[p]) {
      form = ref$[key];
      if (key === 'default') {
        continue;
      }
      excel_menu.forms.push(key);
      if (formes[p][key].unlocked) {
        args.push('', 0);
        continue;
      }
      args.push('', {
        callback: unlock_form,
        arguments: [p, key]
      });
    }
    excel_menu.set.apply(excel_menu, args);
    for (i$ = 0, len$ = (ref$ = excel_menu.buttons).length; i$ < len$; ++i$) {
      i = i$;
      b = ref$[i$];
      if (i === 0) {
        continue;
      }
      form = formes[p][excel_menu.forms[i - 1]];
      b.formname.change(form.name, excel_menu.actions[i] ? 'font_yellow' : 'font_gray');
      b.formdesc.change(form.desc, excel_menu.actions[i] ? 'font' : 'font_gray');
    }
    excel_screen.show();
    pause_screen.exit();
  };
  excel_menu.onRefresh = function(){
    var i$, ref$, len$, i, b;
    for (i$ = 0, len$ = (ref$ = this.buttons).length; i$ < len$; ++i$) {
      i = i$;
      b = ref$[i$];
      if (i === 0) {
        continue;
      }
      b.port.loadTexture(get_costume(this.player.name, i, this.player.costume));
      b.port.frame = get_costume(this.player.name, i, this.player.costume, 'bframe');
    }
  };
  unlock_form = function(p, c){
    sound.play('itemget');
    unlock_forme(p, c);
    items.excel.quantity--;
    save();
    excel_screen.back();
  };
}
Mob = (function(superclass){
  var prototype = extend$((import$(Mob, superclass).displayName = 'Mob', Mob), superclass).prototype, constructor = Mob;
  function Mob(){
    Mob.superclass.call(this, 0, 0, 'mob_slime');
    this.kill();
    this.animations.add('simple', null, 3, true);
    this.battle = encounter.sanishark;
    this.setautoplay(true);
    this.pattern = constructor.patterns.basic;
    this.waterwalk = false;
    this.landwalk = true;
    this.flying = false;
    this.lifetime = 0;
    this.prevtime = 0;
    this.dontcheck = 0;
    this.toughness = 0;
  }
  Mob.patterns = {};
  Mob.types = {};
  Mob.prototype.spawn = function(x, y, type){
    var ref$, ref1$;
    this.x = x;
    this.y = y;
    if (Math.random() < 0.04) {
      if (switches.llovsick1 === 4 && switches.beat_game && !in$(llov, party) && switches.map !== 'void') {
        type = Mob.types.llov;
      }
    }
    this.anchor.set(0.5, 1.0);
    this.rotation = 0;
    Dust.summon(this);
    this.lifetime = 0;
    this.prevtime = Date.now();
    this.revive();
    if (this.key !== key) {
      this.loadTexture(type.key, 0);
    }
    this.toughness = 0 + (Math.random() < 0.07 ? 1 + (Math.random() < 0.25 ? 1 : 0) : 0);
    this.tint = this.toughness > 0 ? 0xff0000 : 0xffffff;
    this.pattern = Mob.patterns[type.pattern];
    if ((ref$ = this.pattern.start) != null) {
      ref$.call(this);
    }
    this.mobtype = type;
    if (type.oncollide) {
      this.battle = null;
      this.oncollide = type.oncollide;
    } else {
      this.battle = true;
      this.oncollide = undefined;
    }
    this.waterwalk = (ref1$ = type.waterwalk) != null ? ref1$ : false;
    this.landwalk = (ref1$ = type.landwalk) != null ? ref1$ : true;
    this.flying = (ref1$ = type.flying) != null ? ref1$ : false;
    this.speed = (ref1$ = type.speed) != null ? ref1$ : 60;
    this.add_simple_animation((ref1$ = type.aspeed) != null ? ref1$ : 3);
    if (type.frames) {
      this.animations.add('simple', type.frames, (ref1$ = type.aspeed) != null ? ref1$ : 3, true);
    }
    this.animations.play('simple');
    this.random_frame();
    this.cancel_movement();
    this.dontcheck = 5;
  };
  Mob.prototype.random_frame = Doodad.prototype.random_frame;
  Mob.prototype.onbattle = function(){
    var ref$, encounterlist;
    this.terrain = ((ref$ = getTileUnder(this)) != null ? ref$.properties.terrain : void 8) || 'water';
    encounterlist = access.call(this, this.mobtype.encounters);
    this.battle = encounter[encounterlist[Math.floor(Math.random() * encounterlist.length)]];
  };
  Mob.prototype.update = function(){
    var ref$, i$, len$, nospawn;
    if (this.alive) {
      this.lifetime += (ref$ = Date.now() - this.prevtime) < 100 ? ref$ : 100;
      this.prevtime = Date.now();
      if (switches.cinema || distance(this, player) > RADIUS || this.lifetime > 10000) {
        this.poof();
      } else if (switches.llovsick1 === true && distance(this, llov) < 100) {
        this.poof();
      } else if (temp.repel > 0 && distance(this, player) < 100) {
        this.poof();
      } else {
        for (i$ = 0, len$ = (ref$ = spawn_controller.nospawn).length; i$ < len$; ++i$) {
          nospawn = ref$[i$];
          if (!require_switch(nospawn)) {
            continue;
          }
          if (distance(this, nospawn) < nospawn.properties.radius * TS) {
            this.poof();
          }
        }
      }
    }
    if (!this.alive) {
      return;
    }
    this.pattern();
    if (this.dontcheck > 0) {
      --this.dontcheck;
    }
  };
  Mob.prototype.updatePaused = function(){
    this.prevtime = Date.now();
  };
  Mob.prototype.physics_update = function(){
    var ref$;
    if (!this.flying && tile_collision_recoil(this, map.namedLayers.tile_layer, this.waterwalk, this.landwalk) == true) {
      if (typeof (ref$ = this.pattern).retry == 'function') {
        ref$.retry.apply(this, arguments);
      }
    }
  };
  return Mob;
}(Actor));
Mob.patterns.basic = function(){
  this.timer == null && (this.timer = 1000);
  this.timer += delta;
  if (this.timer > 1000) {
    this.pattern.retry.apply(this, arguments);
  }
};
Mob.patterns.basic.retry = function(){
  var mov;
  this.goal.x = this.x;
  this.goal.y = this.y;
  mov = 4 * TS;
  switch (Math.floor(Math.random() * 4)) {
  case 0:
    this.goal.x += mov;
    break;
  case 1:
    this.goal.y += mov;
    break;
  case 2:
    this.goal.x -= mov;
    break;
  case 3:
    this.goal.y -= mov;
  }
  this.goal.x += (player.x - this.x) / 10;
  this.goal.y += (player.y - this.y) / 10;
  this.timer = 0;
};
Mob.patterns.basic.start = function(){
  this.timer = 1000;
};
Mob.patterns.swoop = function(){
  if (!(this.goal.x === this.x && this.goal.y === this.y)) {
    return;
  }
  this.goal.x = player.x * 2 - this.x;
  this.goal.y = player.y * 2 - this.y;
};
Mob.patterns.fly = function(){
  if (!(this.goal.x === this.x && this.goal.y === this.y)) {
    return;
  }
  this.goal.x = player.x + Math.random() * TS * 12 - TS * 6;
  this.goal.y = player.y + Math.random() * TS * 12 - TS * 6;
};
Mob.patterns.guard = function(){
  this.goal.x = this.x;
  this.goal.y = this.y;
};
Mob.patterns.circle = function(){
  this.timer += delta;
  if (this.timer > 4000) {
    this.timer -= 4000;
  }
  this.goal.x = player.x + Math.sin(HPI * this.timer / 1000 + this.offset) * TS * 6;
  this.goal.y = player.y + Math.cos(HPI * this.timer / 1000 + this.offset) * TS * 6;
};
Mob.patterns.circle.start = function(){
  this.timer = 1000;
  this.offset = Math.random() * 4000;
};
Mob.patterns.arrow = function(){
  if (!this.launched) {
    this.rotation = angleRAD(player, this) + HPI;
  }
  if (distance(this, player) < 64 && !this.launched) {
    this.launched = true;
    this.goal.x = player.x * 2 - this.x;
    this.goal.y = player.y * 2 - this.y;
  } else if (this.launched && this.goal.x === this.x && this.goal.y === this.y) {
    this.poof();
  }
};
Mob.patterns.arrow.start = function(){
  this.launched = false;
  this.anchor.set(0.5, 0.5);
};
Mob.patterns.jitter = function(){
  this.goal.x = player.x + Math.random() * TS * 12 - TS * 6;
  this.goal.y = player.y + Math.random() * TS * 12 - TS * 6;
};
Mob.types.slime = {
  pattern: 'basic',
  encounters: function(){
    var ref$;
    if (switches.map === 'labdungeon') {
      return ['cancer3', 'sally', 'sally', 'sally_throne'];
    }
    if (switches.map === 'deathtunnel' || switches.map === 'deathdomain') {
      return ['greblin4', 'greblin5'];
    }
    if ((ref$ = switches.map) === 'earth' || ref$ === 'earth2' || ref$ === 'basement1') {
      return ['earth_slime', 'cancer'];
    }
    if (switches.map === 'deadworld') {
      return ['deadworld_slime', 'deadworld_megaslime', 'deadworld_megaslime'];
    }
    if (!switches.soulcluster || switches.map === 'delta') {
      return ['delta_slime', 'delta_megaslime'];
    }
    if (averagelevel() < 3) {
      return ['slime'];
    }
    if (averagelevel() < 6) {
      return ['slime', 'slime2'];
    }
    return ['slime2', 'megaslime'];
  },
  key: 'mob_slime'
};
Mob.types.ghost = {
  pattern: 'fly',
  encounters: function(){
    var ref$;
    if ((ref$ = switches.map) === 'earth' || ref$ === 'deathtunnel' || ref$ === 'deathdomain') {
      return ['skullghost3'];
    }
    if (switches.map === 'deadworld') {
      return ['dw_ghost2', 'skullghost', 'skullghost'];
    }
    return ['ghost', 'ghost', 'ghost2'];
  },
  key: 'mob_ghost',
  aspeed: 10,
  flying: true
};
Mob.types.wisp = {
  pattern: 'circle',
  encounters: function(){
    var terrain, ref$;
    terrain = ((ref$ = getTileUnder(this)) != null ? ref$.properties.terrain : void 8) || 'water';
    if (terrain === 'water') {
      return ['skulurker'];
    }
    return ['skulmander', 'skulmander2'];
  },
  key: 'mob_wisp',
  aspeed: 10,
  speed: 50,
  flying: true
};
Mob.types.fish = {
  pattern: 'basic',
  encounters: function(){
    var terrain, ref$;
    if (switches.map === 'tunneldeep') {
      return ['eel'];
    }
    terrain = ((ref$ = getTileUnder(this)) != null ? ref$.properties.terrain : void 8) || 'water';
    if (terrain === 'water') {
      return ['lurker', 'lurker2'];
    }
    return ['sanishark'];
  },
  key: 'mob_ripple',
  aspeed: 7,
  waterwalk: true,
  landwalk: false
};
Mob.types.bat = {
  pattern: 'fly',
  encounters: ['bat', 'bat2'],
  key: 'mob_bat',
  aspeed: 8,
  flying: true
};
Mob.types.flytrap = {
  pattern: 'guard',
  encounters: function(){
    if (switches.map === 'delta') {
      return ['delta_mantrap'];
    }
    return ['mantrap'];
  },
  key: 'mob_flytrap',
  aspeed: 8
};
Mob.types.corpse = {
  pattern: 'guard',
  encounters: ['graven'],
  key: 'mob_corpse',
  aspeed: 2
};
Mob.types.wraith = {
  pattern: 'fly',
  encounters: ['wraith'],
  key: 'mob_wraith',
  flying: true,
  aspeed: 5
};
Mob.types.arrow = {
  pattern: 'arrow',
  encounters: function(){
    var terrain, ref$;
    if (switches.map === 'earth2') {
      return ['tengu', 'wolf', 'cancer', 'wolf'];
    }
    if (switches.map === 'earth') {
      return ['woolyrhino', 'wolf', 'rhinowolf'];
    }
    terrain = ((ref$ = getTileUnder(this)) != null ? ref$.properties.terrain : void 8) || 'water';
    if (terrain === 'water') {
      return ['tengu'];
    }
    return ['tengu', 'rhinosaurus', 'rhinosaurus', 'rhinosaurus'];
  },
  key: 'mob_arrow',
  aspeed: 3,
  speed: 160,
  flying: true
};
Mob.types.glitch = {
  pattern: 'jitter',
  encounters: function(){
    if (switches.map === 'labdungeon') {
      return ['throne'];
    }
    if (switches.map === 'void') {
      return ['void0', 'void1', 'void2', 'void3', 'void4'];
    }
    return ['polyduck'];
  },
  key: 'mob_glitch',
  flying: true,
  aspeed: 8
};
Mob.types.llov = {
  pattern: 'guard',
  key: 'mob_llov',
  aspeed: 8,
  frames: [0, 1, 0, 2],
  oncollide: function(){
    warp_node('void', 'landing', 'down');
  }
};
Dust = (function(superclass){
  var prototype = extend$((import$(Dust, superclass).displayName = 'Dust', Dust), superclass).prototype, constructor = Dust;
  function Dust(){
    Dust.superclass.call(this, game, 0, 0, 'dust');
    this.anchor.set(0.5, 1.0);
    this.animations.add('simple', null, 7, false);
    Dust.list.push(this);
    this.kill();
  }
  Dust.list = [];
  Dust.summon = function(x, y){
    var dust, i$, ref$, len$, d;
    if (y == null) {
      y = x.y;
      x = x.x;
    }
    dust = null;
    for (i$ = 0, len$ = (ref$ = Dust.list).length; i$ < len$; ++i$) {
      d = ref$[i$];
      if (!d.alive) {
        dust = d;
      }
    }
    if (dust == null) {
      return;
    }
    dust.revive();
    dust.animations.play('simple', null, false, true);
    dust.x = x;
    dust.y = y;
  };
  return Dust;
}(Phaser.Sprite));
function create_mobs(){
  var i$;
  mobs = [];
  for (i$ = 0; i$ < 10; ++i$) {
    mobs.push(new Mob());
  }
  dustclouds = game.add.group(undefined, 'dustclouds');
  for (i$ = 0; i$ < 14; ++i$) {
    dustclouds.addChild(
    new Dust());
  }
}
function set_mobs(){
  var i$, ref$, len$, mob;
  for (i$ = 0, len$ = (ref$ = mobs).length; i$ < len$; ++i$) {
    mob = ref$[i$];
    mob.kill();
  }
  game.world.bringToTop(
  dustclouds);
  spawn_controller.nospawn = [];
  spawn_controller.spawners = [];
}
spawn_controller.timer = 10000;
function spawn_controller(){
  var spawned, i$;
  if (!player.moving || switches.cinema || !switches.spawning || player.terrain === 'overpass' || player.terrain === 'bridge') {
    return;
  }
  spawn_controller.timer -= delta;
  if (temp.repel) {
    temp.repel -= delta;
  }
  if (spawn_controller.timer < 0) {
    spawned = 0;
    for (i$ = 0; i$ < 10; ++i$) {
      if (spawn_mob()) {
        spawned++;
      }
    }
    if (spawned > 0) {
      spawn_controller.timer = getmapdata('mobtime') + Math.random() * 400 | 0;
      sound.play('flame');
    }
  }
}
function spawn_mob(key){
  var i$, ref$, len$, i, mob, radius, s, nospawn, type, spawner;
  for (i$ = 0, len$ = (ref$ = mobs).length; i$ < len$; ++i$) {
    i = i$;
    mob = ref$[i$];
    if (i >= getmapdata('mobcap')) {
      return;
    }
    if (!mob.alive) {
      break;
    }
  }
  if (mob.alive) {
    return;
  }
  radius = 96;
  s = normalize({
    x: Math.random() * 10 - 5,
    y: Math.random() * 10 - 5
  });
  s.x = player.x + s.x * radius;
  s.y = player.y + s.y * radius;
  if (s.x === player.x && s.y === player.y) {
    warn("MONSTER SPAWNED IN SAME PLACE AS PLAYER");
  }
  for (i$ = 0, len$ = (ref$ = spawn_controller.nospawn).length; i$ < len$; ++i$) {
    nospawn = ref$[i$];
    if (!require_switch(nospawn)) {
      continue;
    }
    if (distance(s, nospawn) < nospawn.properties.radius * TS) {
      return;
    }
  }
  type = access(switches.spawning, map.getTile(s.x / TS | 0, s.y / TS | 0, map.tile_layer, true));
  if (!type) {
    return;
  }
  for (i$ = 0, len$ = (ref$ = spawn_controller.spawners).length; i$ < len$; ++i$) {
    spawner = ref$[i$];
    if (!require_switch(spawner)) {
      continue;
    }
    if (distance(s, spawner) < spawner.properties.radius * TS) {
      type = Mob.types[spawner.properties.type];
    }
  }
  if (!type.flying && tile_point_collision(mob, s, map.tile_layer, (ref$ = type.waterwalk) != null ? ref$ : false, (ref$ = type.landwalk) != null ? ref$ : true)) {
    return;
  }
  mob.spawn(s.x, s.y, type);
  return true;
}
palette = {
  slime1: [0x94d1d2, 0x993eff, 0x9999ff],
  slime2: [0xb7ec9a, 0x2f8d88, 0x6fcfa3],
  slime3: [0xf185b3, 0xd42c50, 0xfe6881],
  slime4: [0xfed568, 0xe41c75, 0xff9567],
  slime5: [0xa32ee6, 0x282b70, 0x9668fe],
  slime6: [0xb3618d, 0x481a28, 0x944c6a],
  mantrap1: [0x5eb600, 0x216b4b, 0xf34f23, 0x8e002f, 0xb1ff3b, 0x2ec438],
  mantrap2: [0xb0b600, 0x6b4b21, 0xa34343, 0x6c0a18, 0xe0b0df, 0xc22e96],
  mantrap3: [0xb62b00, 0x800c3a, 0xa050c6, 0x4d008e, 0xb0dae0, 0x2e85c2],
  skulliki1: [0xcbbb82, 0x712f77, 0xb20e15],
  skulliki2: [0xe4bfe5, 0x881010, 0x780e68],
  skulliki3: [0xf28aa0, 0x271f65, 0x2f8600],
  bat1: [0xdedd48, 0x775d67, 0x3c3747],
  bat2: [0xde484c, 0x785b50, 0x482828],
  bat3: [0xe67700, 0x873c8c, 0x421858],
  skulmander1: [0xcbbb82, 0x712f77, 0xb62b00],
  skulmander2: [0xd2d2d2, 0x2f3277, 0x22b600],
  skulmander3: [0xca92a1, 0x772f3e, 0x4909ff],
  lurker1: [0xd248c7, 0x47458f, 0xc4dddd],
  lurker2: [0xf9213a, 0x811d43, 0xeec775],
  lurker3: [0xac6ab6, 0x17432a, 0x8fb284],
  tengu1: [0xc52f11, 0x348e4c, 0x7d3048, 0xfffc93],
  tengu2: [0xebd9e4, 0xc14545, 0x63307e, 0xa3ffef],
  tengu3: [0xd6b018, 0x596fa7, 0x2c663e, 0xfe90a4],
  rhino1: [0xa4a4a4, 0x67627e, 0x5e415f, 0x7d3048],
  rhino2: [0xc08484, 0x8c3c5a, 0x5549a1, 0x820a2f],
  rhino3: [0xaa8db7, 0x594880, 0x289d1f, 0x820a21],
  wrhino1: [0xaba9cb, 0x4f607b, 0xd19e67, 0x5e2d2a],
  wrhino2: [0xe1a6a6, 0x8f3b61, 0xb56c68, 0x7d3048],
  wrhino3: [0xc8cba9, 0x7b6b4f, 0x676cd1, 0x2a455e],
  wolf1: [0xfc3900, 0xcac6dc, 0xab76c6],
  wolf2: [0xff8e00, 0x5d5872, 0x332a38],
  wolf3: [0x0173ff, 0x8a6d54, 0x502e40]
};
Monster.animData = {};
Monster.animData.monster_slime = {
  speed: 9
};
Monster.animData.monster_slime2 = {
  frames: [0, 1, 2, 1]
};
Monster.animData.monster_graven = {
  getFrame: function(){
    if (Math.random() < this.stats.sp / 2) {
      return 1;
    } else if (Math.random() >= 0.1) {
      return 0;
    } else if (Math.random() < 0.5) {
      return 2;
    } else {
      return 3;
    }
  }
};
Monster.animData.monster_lurker = {
  frames: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 13, 13, 13, 13, 13],
  speed: 10
};
Monster.animData.monster_bat = {
  frames: [0, 0, 1, 1, 2, 2, 1, 1, 0, 0, 1, 1, 2, 2, 1, 1, 0, 0, 1, 1, 2, 2, 1, 1, 0, 0, 1, 1, 2, 2, 1, 1, 3, 4, 5, 4, 3, 1, 3, 4, 5, 4, 3, 1, 0, 0, 1, 1, 2, 2, 1, 1, 0, 0, 1, 1, 2, 2, 1, 1, 0, 0, 1, 1, 2, 2, 1, 1, 0, 0, 1, 1, 2, 2, 1, 1, 0, 0, 1, 1, 2, 2, 1, 1, 3, 4, 5, 4, 3, 1, 3, 4, 5, 4, 3, 1, 3, 4, 5, 4, 3, 1],
  speed: 16
};
Monster.animData.monster_mantrap = {
  frames1: [0, 1, 2, 3, 2, 1],
  frames2: [4, 5, 6],
  getFrame: function(){
    var frametime;
    this.animData_cycle == null && (this.animData_cycle = this.animData.frames1);
    this.animData_frame == null && (this.animData_frame = Math.floor(Math.random() * this.animData_cycle.length));
    this.animData_time == null && (this.animData_time = 0);
    this.animData_time += delta;
    frametime = 120 - 80 * this.stats.sp;
    if (this.animData_time >= frametime) {
      this.animData_time = 0;
      this.animData_frame++;
    }
    if (this.animData_frame >= this.animData_cycle.length) {
      this.animData_cycle = Math.random() < 0.8
        ? this.animData.frames1
        : this.animData.frames2;
      this.animData_frame = 0;
    }
    return this.animData_cycle[this.animData_frame];
  }
};
Monster.animData.monster_polyduck = {
  getFrame: function(){
    this.animData_frame == null && (this.animData_frame = Math.floor(Math.random() * 12));
    this.animData_time == null && (this.animData_time = 0);
    this.animData_time += delta;
    if (this.animData_time >= 100) {
      this.animData_time = 0;
      this.animData_frame++;
      this.animData_glitch = Math.random() < 0.1;
    }
    if (this.animData_frame >= 12) {
      this.animData_frame = 0;
    }
    if (this.animData_glitch) {
      if (this.animData_frame % 4 === 3) {
        return 13;
      } else {
        return this.animData_frame % 4 + 12;
      }
    } else {
      return this.animData_frame;
    }
  }
};
Monster.animData.monster_woolyrhino = Monster.animData.monster_rhinosaurus = {
  frames: [0, 1, 2, 1],
  speed: 4
};
Monster.animData.monster_tengu = {
  frames: [0, 0, 1, 1, 2, 2, 3, 3, 2, 2, 1, 1, 0, 0, 1, 1, 2, 2, 3, 3, 2, 2, 1, 1, 0, 0, 1, 1, 2, 2, 3, 3, 2, 2, 1, 1, 0, 1, 2, 3, 2, 1, 0, 1, 2, 3, 2, 1],
  speed: 14
};
Monster.types = {};
Monster.types.slime = {
  name: 'Slime',
  key: 'monster_slime',
  skills: [skills.attack, skills.poison],
  drops: [
    {
      item: 'sludge',
      chance: 50,
      quantity: 1
    }, {
      item: 'medicine',
      chance: 25,
      quantity: 1
    }, {
      item: 'starpuff',
      chance: 2,
      quantity: 1
    }
  ],
  xp: 60,
  hp: 80,
  atk: 80,
  def: 50,
  attributes: ['poison'],
  pal: palette.slime1,
  pal2: palette.slime2,
  pal3: palette.slime3
};
Monster.types.slimex = {
  name: 'Slime',
  key: 'monster_slime',
  skills: [skills.attack, skills.poison],
  drops: [
    {
      item: 'sludge',
      chance: 100,
      quantity: 1
    }, {
      item: 'medicine',
      chance: 50,
      quantity: 1
    }, {
      item: 'starpuff',
      chance: 5,
      quantity: 1
    }
  ],
  xp: 75,
  hp: 90,
  atk: 90,
  def: 60,
  attributes: ['poison'],
  pal: palette.slime1,
  pal1: palette.slime2,
  pal2: palette.slime3,
  pal3: palette.slime4
};
Monster.types.slimexx = {
  name: 'Slime',
  key: 'monster_slime',
  skills: [skills.attack, skills.poison],
  drops: [
    {
      item: 'sludge',
      chance: 100,
      quantity: 1
    }, {
      item: 'sludge',
      chance: 50,
      quantity: 1
    }, {
      item: 'medicine',
      chance: 75,
      quantity: 1
    }, {
      item: 'medicine',
      chance: 50,
      quantity: 1
    }, {
      item: 'starpuff',
      chance: 10,
      quantity: 1
    }
  ],
  xp: 90,
  hp: 100,
  atk: 100,
  def: 70,
  attributes: ['poison'],
  pal: palette.slime1,
  pal1: palette.slime3,
  pal2: palette.slime4,
  pal3: palette.slime5
};
Monster.types.slime2 = {
  name: 'Mega Slime',
  key: 'monster_slime2',
  skills: [skills.strike, skills.poison],
  drops: [{
    item: 'sludge',
    chance: 100,
    quantity: 1
  }],
  xp: 85,
  speed: 90,
  def: 60,
  attributes: ['poison'],
  ondeath: function(){
    battle.addmonster(new Monster(this.x - 2 * WS, this.y, 'slime', this.level), battle.children.indexOf(this));
    return battle.addmonster(new Monster(this.x + 2 * WS, this.y, 'slime', this.level), battle.children.indexOf(this));
  },
  pal: palette.slime1,
  pal2: palette.slime2,
  pal3: palette.slime3
};
Monster.types.slime2x = {
  name: 'Mega Slime',
  key: 'monster_slime2',
  skills: [skills.strike, skills.poison],
  drops: [{
    item: 'sludge',
    chance: 100,
    quantity: 1
  }],
  xp: 92,
  hp: 110,
  speed: 100,
  def: 70,
  attributes: ['poison'],
  ondeath: function(){
    battle.addmonster(new Monster(this.x - 2 * WS, this.y, 'slimex', this.level), battle.children.indexOf(this));
    return battle.addmonster(new Monster(this.x + 2 * WS, this.y, 'slimex', this.level), battle.children.indexOf(this));
  },
  pal: palette.slime1,
  pal1: palette.slime2,
  pal2: palette.slime3,
  pal3: palette.slime4
};
Monster.types.slime2xx = {
  name: 'Mega Slime',
  key: 'monster_slime2',
  skills: [skills.strike, skills.poison],
  drops: [{
    item: 'sludge',
    chance: 100,
    quantity: 1
  }],
  xp: 100,
  hp: 120,
  speed: 100,
  def: 80,
  attributes: ['poison'],
  ondeath: function(){
    battle.addmonster(new Monster(this.x - 2 * WS, this.y, 'slimexx', this.level), battle.children.indexOf(this));
    return battle.addmonster(new Monster(this.x + 2 * WS, this.y, 'slimexx', this.level), battle.children.indexOf(this));
  },
  pal: palette.slime1,
  pal1: palette.slime3,
  pal2: palette.slime4,
  pal3: palette.slime5
};
Monster.types.slimez = {
  name: 'Slime',
  key: 'monster_slime',
  skills: [skills.attack, skills.poison],
  drops: [
    {
      item: 'sludge',
      chance: 100,
      quantity: 1
    }, {
      item: 'sludge',
      chance: 50,
      quantity: 1
    }, {
      item: 'medicine',
      chance: 75,
      quantity: 1
    }, {
      item: 'medicine',
      chance: 50,
      quantity: 1
    }, {
      item: 'starpuff',
      chance: 15,
      quantity: 1
    }
  ],
  xp: 90,
  hp: 100,
  atk: 100,
  def: 100,
  attributes: ['poison'],
  pal: palette.slime1,
  pal1: palette.slime4,
  pal2: palette.slime5,
  pal3: palette.slime6
};
Monster.types.slime2z = {
  name: 'Mega Slime',
  key: 'monster_slime2',
  skills: [skills.strike, skills.poison],
  drops: [{
    item: 'sludge',
    chance: 100,
    quantity: 2
  }],
  xp: 100,
  hp: 150,
  speed: 100,
  def: 100,
  attributes: ['poison'],
  ondeath: function(){
    battle.addmonster(new Monster(this.x - 3 * WS, this.y - HWS, 'slimez', this.level), battle.children.indexOf(this));
    battle.addmonster(new Monster(this.x, this.y + HWS, 'slimez', this.level), battle.children.indexOf(this));
    return battle.addmonster(new Monster(this.x + 3 * WS, this.y - HWS, 'slimez', this.level), battle.children.indexOf(this));
  },
  pal: palette.slime1,
  pal1: palette.slime4,
  pal2: palette.slime5,
  pal3: palette.slime6
};
Monster.types.ghost = {
  name: 'Beholden',
  key: 'monster_ghost',
  skills: [skills.attack],
  drops: [
    {
      item: 'gravedust',
      chance: 25,
      quantity: 1
    }, {
      item: 'gravedust',
      chance: 25,
      quantity: 1
    }, {
      item: 'cloth',
      chance: 25,
      quantity: 1
    }, {
      item: 'starpuff',
      chance: 5,
      quantity: 1
    }
  ],
  xp: 75,
  hp: 80,
  atk: 75,
  def: 70,
  attributes: ['ghost'],
  escape: 70
};
Monster.types.skullghost = {
  name: 'Skulliki',
  key: 'monster_skullghost',
  skills: [skills.strike, skills.curse],
  drops: [
    {
      item: 'gravedust',
      chance: 75,
      quantity: 1
    }, {
      item: 'cloth',
      chance: 50,
      quantity: 1
    }, {
      item: 'starpuff',
      chance: 5,
      quantity: 1
    }
  ],
  xp: 87,
  hp: 95,
  atk: 90,
  def: 80,
  attributes: ['ghost'],
  escape: 80,
  pal: palette.skulliki1,
  pal2: palette.skulliki2,
  pal3: palette.skulliki3
};
Monster.types.skulmander = {
  name: 'Skulmanter',
  key: 'monster_skulmander',
  skills: [skills.burn],
  drops: [
    {
      item: 'gravedust',
      chance: 70,
      quantity: 1
    }, {
      item: 'gravedust',
      chance: 20,
      quantity: 1
    }, {
      item: 'cinder',
      chance: 100,
      quantity: 1
    }, {
      item: 'cinder',
      chance: 50,
      quantity: 1
    }, {
      item: 'starpuff',
      chance: 10,
      quantity: 1
    }
  ],
  xp: 100,
  hp: 100,
  atk: 120,
  def: 120,
  speed: 120,
  attributes: ['ghost'],
  escape: 90,
  pal: palette.skulmander1,
  pal2: palette.skulmander2,
  pal3: palette.skulmander3
};
Monster.types.lurker = {
  name: 'Lurker',
  key: 'monster_lurker',
  skills: [skills.drown],
  xp: 100,
  hp: 115,
  atk: 80,
  def: 115,
  speed: 100,
  attributes: ['fish', 'carnivore'],
  escape: 60,
  drops: [
    {
      item: 'frozenflesh',
      chance: 100,
      quantity: 1
    }, {
      item: 'frozenflesh',
      chance: 50,
      quantity: 1
    }, {
      item: 'silverdust',
      chance: 60,
      quantity: 1
    }, {
      item: 'starpuff',
      chance: 10,
      quantity: 1
    }
  ],
  pal: palette.lurker1,
  pal2: palette.lurker2,
  pal3: palette.lurker3
};
Monster.types.bat = {
  name: 'Vampire Bat',
  key: 'monster_bat',
  skills: [skills.attack, skills.vbite],
  drops: [
    {
      item: 'venom',
      chance: 50,
      quantity: 1
    }, {
      item: 'fur',
      chance: 100,
      quantity: 1
    }, {
      item: 'fur',
      chance: 50,
      quantity: 1
    }, {
      item: 'silverdust',
      chance: 20,
      quantity: 1
    }, {
      item: 'starpuff',
      chance: 10,
      quantity: 1
    }
  ],
  xp: 90,
  hp: 100,
  atk: 95,
  def: 60,
  speed: 200,
  escape: 75,
  pal: palette.bat1,
  pal2: palette.bat2,
  pal3: palette.bat3
};
Monster.types.mantrap = {
  name: 'Mantrap',
  key: 'monster_mantrap',
  skills: [skills.strike],
  drops: [
    {
      item: 'plantfiber',
      chance: 100,
      quantity: 3
    }, {
      item: 'plantfiber',
      chance: 50,
      quantity: 3
    }, {
      item: 'aloevera',
      chance: 100,
      quantity: 2
    }, {
      item: 'aloevera',
      chance: 66,
      quantity: 2
    }, {
      item: 'aloevera',
      chance: 66,
      quantity: 1
    }, {
      item: 'thornarmor',
      chance: 100,
      quantity: 1
    }, {
      item: 'starpuff',
      chance: 10,
      quantity: 1
    }, {
      item: 'bugbits',
      chance: 66,
      quantity: 3
    }, {
      item: 'bugbits',
      chance: 66,
      quantity: 2
    }
  ],
  xp: 150,
  hp: 200,
  atk: 500,
  def: 200,
  speed: 25,
  attributes: ['plant', 'carnivore'],
  escape: 40,
  pal: palette.mantrap1,
  pal2: palette.mantrap2,
  pal3: palette.mantrap3
};
Monster.types.graven = {
  name: 'Graven',
  key: 'monster_graven',
  skills: [skills.attack],
  drops: [
    {
      item: 'gravedust',
      chance: 100,
      quantity: 1
    }, {
      item: 'gravedust',
      chance: 75,
      quantity: 1
    }, {
      item: 'gravedust',
      chance: 50,
      quantity: 2
    }, {
      item: 'gravedust',
      chance: 25,
      quantity: 3
    }, {
      item: 'starpuff',
      chance: 10,
      quantity: 1
    }, {
      item: 'bugbits',
      chance: 66,
      quantity: 1
    }
  ],
  xp: 120,
  hp: 60,
  atk: 200,
  def: 200,
  speed: 60,
  attributes: ['zombie', 'carnivore'],
  escape: 70
};
Monster.types.mimic = {
  name: 'Mimick',
  key: 'monster_mimic',
  skills: [skills.strike],
  hp: 111,
  speed: 105,
  xp: 100
};
Monster.types.sanishark = {
  name: 'Sanishark',
  key: 'monster_sanishark',
  skills: [skills.strike],
  xp: 100,
  drops: [
    {
      item: 'silverdust',
      chance: 100,
      quantity: 1
    }, {
      item: 'starpuff',
      chance: 10,
      quantity: 1
    }
  ],
  attributes: ['carnivore']
};
Monster.types.rhinosaurus = {
  name: 'Rhinosaurus',
  key: 'monster_rhinosaurus',
  skills: [skills.strike],
  def: 150,
  xp: 100,
  drops: [
    {
      item: 'silverdust',
      chance: 100,
      quantity: 1
    }, {
      item: 'silverdust',
      chance: 20,
      quantity: 1
    }, {
      item: 'starpuff',
      chance: 10,
      quantity: 1
    }, {
      item: 'parchment',
      chance: 50,
      quantity: 1
    }
  ],
  attributes: ['carnivore'],
  pal: palette.rhino1,
  pal2: palette.rhino2,
  pal3: palette.rhino3
};
Monster.types.woolyrhinosaurus = {
  name: 'Wooly Rhino',
  key: 'monster_woolyrhino',
  skills: [skills.strike],
  def: 150,
  hp: 120,
  xp: 100,
  drops: [
    {
      item: 'silverdust',
      chance: 80,
      quantity: 1
    }, {
      item: 'silverdust',
      chance: 20,
      quantity: 1
    }, {
      item: 'frozenflesh',
      chance: 90,
      quantity: 1
    }, {
      item: 'fur',
      chance: 100,
      quantity: 1
    }, {
      item: 'fur',
      chance: 20,
      quantity: 1
    }, {
      item: 'starpuff',
      chance: 10,
      quantity: 1
    }
  ],
  attributes: ['carnivore'],
  pal: palette.wrhino1,
  pal2: palette.wrhino2,
  pal3: palette.wrhino3
};
Monster.types.wolf = {
  name: 'Wolven',
  key: 'monster_wolf',
  skills: [skills.strike],
  speed: 130,
  atk: 120,
  hp: 120,
  xp: 100,
  attributes: ['carnivore'],
  drops: [
    {
      item: 'silverdust',
      chance: 100,
      quantity: 1
    }, {
      item: 'silverdust',
      chance: 20,
      quantity: 1
    }, {
      item: 'frozenflesh',
      chance: 80,
      quantity: 1
    }, {
      item: 'fur',
      chance: 100,
      quantity: 1
    }, {
      item: 'fur',
      chance: 50,
      quantity: 1
    }, {
      item: 'starpuff',
      chance: 16,
      quantity: 1
    }
  ],
  pal: palette.wolf1,
  pal2: palette.wolf2,
  pal3: palette.wolf3
};
Monster.types.tengu = {
  name: 'Tengarot',
  key: 'monster_tengu',
  skills: [skills.strike],
  xp: 100,
  drops: [
    {
      item: 'silverdust',
      chance: 100,
      quantity: 1
    }, {
      item: 'silverdust',
      chance: 20,
      quantity: 1
    }, {
      item: 'parchment',
      chance: 50,
      quantity: 1
    }, {
      item: 'starpuff',
      chance: 10,
      quantity: 1
    }, {
      item: 'venom',
      chance: 10,
      quantity: 1
    }, {
      item: 'bugbits',
      chance: 10,
      quantity: 1
    }
  ],
  pal: palette.tengu1,
  pal2: palette.tengu2,
  pal3: palette.tengu3
};
Monster.types.wraith = {
  name: 'Wraith',
  key: 'monster_wraith',
  skills: [skills.strike],
  drops: [
    {
      item: 'lifecrystal',
      chance: 50,
      quantity: 1
    }, {
      item: 'darkcrystal',
      chance: 50,
      quantity: 1
    }, {
      item: 'starpuff',
      chance: 10,
      quantity: 1
    }, {
      item: 'cloth',
      chance: 50,
      quantity: 1
    }
  ],
  xp: 100,
  speed: 120,
  escape: 70
};
Monster.types.polyduck = {
  name: 'Polyduck',
  key: 'monster_polyduck',
  skills: [skills.strike, skills.seizure],
  drops: [
    {
      item: 'silverdust',
      chance: 50,
      quantity: 1
    }, {
      item: 'starpuff',
      chance: 12,
      quantity: 1
    }, {
      item: 'fur',
      chance: 30,
      quantity: 1
    }
  ],
  xp: 100,
  speed: 100
};
Monster.types.eel = {
  name: 'Eel',
  key: 'monster_eel',
  skills: [skills.strike],
  drops: [
    {
      item: 'venom',
      chance: 50,
      quantity: 1
    }, {
      item: 'starpuff',
      chance: 12,
      quantity: 1
    }, {
      item: 'silverdust',
      chance: 30,
      quantity: 1
    }
  ],
  xp: 100,
  speed: 120,
  attributes: ['fish', 'carnivore']
};
Monster.types.doggie = {
  name: 'Doggie',
  key: 'monster_doggie',
  skills: [skills.attack, skills.wanko],
  drops: [
    {
      item: 'gravedust',
      chance: 70,
      quantity: 1
    }, {
      item: 'gravedust',
      chance: 70,
      quantity: 1
    }, {
      item: 'fur',
      chance: 70,
      quantity: 1
    }, {
      item: 'fur',
      chance: 70,
      quantity: 1
    }, {
      item: 'starpuff',
      chance: 8,
      quantity: 1
    }, {
      item: 'bugbits',
      chance: 50,
      quantity: 1
    }
  ],
  xp: 100,
  speed: 120
};
Monster.types.greblin = {
  name: 'Greblin',
  key: 'monster_greblin',
  skills: [skills.attack],
  drops: [
    {
      item: 'silverdust',
      chance: 70,
      quantity: 2
    }, {
      item: 'silverdust',
      chance: 70,
      quantity: 2
    }, {
      item: 'cumberground',
      chance: 100,
      quantity: 1
    }, {
      item: 'cumberground',
      chance: 50,
      quantity: 1
    }, {
      item: 'fur',
      chance: 70,
      quantity: 1
    }, {
      item: 'fur',
      chance: 70,
      quantity: 1
    }, {
      item: 'starpuff',
      chance: 20,
      quantity: 1
    }, {
      item: 'bugbits',
      chance: 50,
      quantity: 2
    }, {
      item: 'bugbits',
      chance: 50,
      quantity: 1
    }
  ],
  xp: 100,
  hp: 70
};
Monster.types.cancer = {
  name: 'Cancer',
  key: 'monster_cancer',
  skills: [skills.strike],
  drops: [
    {
      item: 'silverdust',
      chance: 70,
      quantity: 2
    }, {
      item: 'silverdust',
      chance: 70,
      quantity: 2
    }, {
      item: 'starpuff',
      chance: 20,
      quantity: 1
    }, {
      item: 'bugbits',
      chance: 50,
      quantity: 2
    }, {
      item: 'bugbits',
      chance: 50,
      quantity: 1
    }, {
      item: 'sludge',
      chance: 20,
      quantity: 1
    }, {
      item: 'sludge',
      chance: 20,
      quantity: 1
    }
  ],
  xp: 100,
  atk: 110,
  hp: 100,
  escape: 90
};
Monster.types.mutant = {
  name: 'Sally',
  key: 'monster_mutant',
  skills: [skills.poisonwave, skills.curse, skills.poisonstrike],
  drops: [
    {
      item: 'gravedust',
      chance: 100,
      quantity: 2
    }, {
      item: 'sludge',
      chance: 100,
      quantity: 2
    }, {
      item: 'starpuff',
      chance: 20,
      quantity: 1
    }, {
      item: 'bugbits',
      chance: 50,
      quantity: 2
    }, {
      item: 'bugbits',
      chance: 50,
      quantity: 1
    }, {
      item: 'darkcrystal',
      chance: 20,
      quantity: 1
    }
  ],
  xp: 150,
  atk: 110,
  speed: 120,
  hp: 140,
  escape: 80
};
Monster.types.throne = {
  name: 'Throne',
  key: 'monster_throne',
  skills: [skills.heal, skills.burn, skills.nuke],
  drops: [
    {
      item: 'silverdust',
      chance: 100,
      quantity: 2
    }, {
      item: 'medicine',
      chance: 70,
      quantity: 1
    }, {
      item: 'medicine',
      chance: 60,
      quantity: 1
    }, {
      item: 'starpuff',
      chance: 20,
      quantity: 1
    }, {
      item: 'cinder',
      chance: 50,
      quantity: 2
    }, {
      item: 'cinder',
      chance: 50,
      quantity: 1
    }, {
      item: 'lifecrystal',
      chance: 20,
      quantity: 1
    }
  ],
  xp: 160,
  atk: 110,
  hp: 170,
  escape: 50
};
Monster.types.naegleria = {
  name: 'Naegleria',
  key: 'monster_naegleria',
  skills: [skills.strike, skills.poison],
  drops: [
    {
      item: 'naesoul',
      chance: 100,
      quantity: 1
    }, {
      item: 'excel',
      chance: 100,
      quantity: 1
    }, {
      item: 'sporb',
      chance: 100,
      quantity: 1
    }
  ],
  xp: 200,
  speed: 130,
  hp: 200,
  def: 95,
  attributes: ['poison']
};
Monster.types.naegleria_r = {
  name: 'Naegleria',
  key: 'monster_naegleria',
  skills: [skills.poisonstrike, skills.poisonwave],
  xp: 200,
  speed: 130,
  hp: 300,
  def: 150,
  attributes: ['poison'],
  ai: function(){
    var list, i$, ref$, len$, enemy, j$, ref1$, len1$, buff;
    list = [];
    for (i$ = 0, len$ = (ref$ = enemy_list()).length; i$ < len$; ++i$) {
      enemy = ref$[i$];
      for (j$ = 0, len1$ = (ref1$ = enemy.buffs).length; j$ < len1$; ++j$) {
        buff = ref1$[j$];
        if (buff.name === 'poison') {
          list.push(skills.poisonstrike);
        }
        if (buff.name === 'null') {
          list.push(skills.poisonwave);
        }
      }
    }
    if (monsters.length === 1) {
      return skills.slimesummon;
    }
    if (list.length === 0) {
      return null;
    }
    return list[Math.random() * list.length | 0];
  }
};
Monster.types.eidzu1 = {
  name: 'Eidzu I',
  key: 'monster_eidzu1',
  skills: [skills.devastate, skills.strike],
  drops: [
    {
      item: 'aidssoul',
      chance: 100,
      quantity: 1
    }, {
      item: 'sporb',
      chance: 100,
      quantity: 1
    }, {
      item: 'humansoul',
      chance: 100,
      quantity: 225000
    }
  ],
  xp: 300,
  speed: 70,
  hp: 300,
  atk: 110,
  trigger: function(){
    if (this.triggered) {
      return;
    }
    if (monsters.length === 1) {
      this.triggered = true;
      this.loadTexture('monster_eidzu1_2');
    }
  },
  ai: function(){
    var i$, ref$, len$, ally, enemy;
    if (monsters.length === 1) {
      return null;
    }
    for (i$ = 0, len$ = (ref$ = ally_list()).length; i$ < len$; ++i$) {
      ally = ref$[i$];
      if (ally.dead) {
        continue;
      }
      if (ally.stats.hp / this.stats.hp <= 0.5) {
        return skills.sharepain;
      }
    }
    for (i$ = 0, len$ = (ref$ = enemy_list()).length; i$ < len$; ++i$) {
      enemy = ref$[i$];
      if (enemy.has_buff(buffs['null'])) {
        return skills.devastate;
      }
    }
    return skills.strike;
  }
};
Monster.types.eidzu2 = {
  name: 'Eidzu II',
  key: 'monster_eidzu2',
  skills: [skills.dekopin],
  drops: [
    {
      item: 'excel',
      chance: 100,
      quantity: 1
    }, {
      item: 'sporb',
      chance: 100,
      quantity: 1
    }, {
      item: 'humansoul',
      chance: 100,
      quantity: 225000
    }
  ],
  xp: 300,
  speed: 130,
  hp: 300,
  trigger: function(){
    if (this.triggered) {
      return;
    }
    if (monsters.length === 1) {
      this.triggered = true;
      this.loadTexture('monster_eidzu2_2');
    }
  },
  ai: function(){
    var allylist, i$, len$, ally, ref$, enemy;
    allylist = ally_list();
    for (i$ = 0, len$ = allylist.length; i$ < len$; ++i$) {
      ally = allylist[i$];
      if (ally.stats.hp / this.stats.hp <= 0.5) {
        return skills.sharepain;
      }
    }
    for (i$ = 0, len$ = (ref$ = enemy_list()).length; i$ < len$; ++i$) {
      enemy = ref$[i$];
      if (enemy.has_buff(buffs.aids)) {
        return skills.dekopin;
      }
    }
    for (i$ = 0, len$ = allylist.length; i$ < len$; ++i$) {
      ally = allylist[i$];
      if (ally === this) {
        continue;
      }
      if (ally.has_buff(buffs['null']) && !ally.has_buff(buffs.twinflight)) {
        return skills.twinflight;
      }
    }
    return skills.strike;
  }
};
Monster.types.sars = {
  name: 'Sars',
  key: 'monster_sars',
  skills: [skills.sarssummon],
  drops: [
    {
      item: 'sarssoul',
      chance: 100,
      quantity: 1
    }, {
      item: 'excel',
      chance: 100,
      quantity: 1
    }, {
      item: 'sporb',
      chance: 100,
      quantity: 1
    }, {
      item: 'humansoul',
      chance: 100,
      quantity: 450000
    }
  ],
  xp: 300,
  speed: 130,
  hp: 300,
  trigger: function(){
    this.stats.def = new_calc_stat(this.level, 100 + 10 * monsters.length);
    this.stats.speed = calc_stat(this.level, 100 + 100 / monsters.length, 2);
  },
  ai: function(){
    if (monsters.length < 8) {
      return skills.sarssummon;
    }
    return skills.strike;
  }
};
Monster.types.sarssummon = {
  name: 'Sarsagent',
  key: 'monster_sars_summon',
  skills: [skills.attack],
  xp: 0,
  speed: 1000,
  hp: 50,
  atk: 40,
  minion: true
};
Monster.types.rabies = {
  name: 'Rabies',
  key: 'monster_rabies',
  skills: [skills.burn, skills.inferno],
  drops: [
    {
      item: 'rabiessoul',
      chance: 100,
      quantity: 1
    }, {
      item: 'excel',
      chance: 100,
      quantity: 1
    }, {
      item: 'sporb',
      chance: 100,
      quantity: 1
    }, {
      item: 'humansoul',
      chance: 100,
      quantity: 450000
    }, {
      item: 'bugbits',
      chance: 100,
      quantity: 3
    }, {
      item: 'fur',
      chance: 100,
      quantity: 4
    }
  ],
  xp: 300,
  speed: 150,
  hp: 300,
  atk: 130,
  def: 120,
  attributes: ['carnivore'],
  ai: function(){
    var list, i$, ref$, len$, enemy, j$, ref1$, len1$, buff;
    if (this.triggered) {
      return skills.strike;
    }
    list = [];
    for (i$ = 0, len$ = (ref$ = enemy_list()).length; i$ < len$; ++i$) {
      enemy = ref$[i$];
      for (j$ = 0, len1$ = (ref1$ = enemy.buffs).length; j$ < len1$; ++j$) {
        buff = ref1$[j$];
        if (buff.name === 'burn') {
          list.push(skills.inferno);
        }
        if (buff.name === 'null') {
          list.push(skills.burn2);
        }
      }
    }
    if (list.length === 0) {
      return null;
    }
    return list[Math.random() * list.length | 0];
  }
};
Monster.types.chikun = {
  name: 'Chikungunya',
  key: 'monster_chikun',
  skills: [skills.strike, skills.healblock],
  xpwell: 600,
  xpkill: 75,
  drops: [
    {
      item: 'healblock',
      chance: 100,
      quantity: 1
    }, {
      item: 'chikunsoul',
      chance: 100,
      quantity: 1
    }, {
      item: 'humansoul',
      chance: 100,
      quantity: 450000
    }
  ],
  hp: 300,
  def: 300,
  speed: 200,
  atk: 120,
  ai: function(){
    var list, enemylist, nullcount, i$, len$, enemy;
    list = [];
    enemylist = enemy_list();
    nullcount = 0;
    for (i$ = 0, len$ = enemylist.length; i$ < len$; ++i$) {
      enemy = enemylist[i$];
      if (!enemy.has_buff(buffs.healblock)) {
        list.push(skills.healblock);
      }
      if (enemylist.length > 1 && !enemy.has_buff(buffs.isolated)) {
        list.push(skills.isolate);
      }
      if (enemy.has_buff(buffs['null'])) {
        nullcount++;
      }
    }
    if (nullcount === 0) {
      list.length = 0;
    }
    list.push(skills.vbite);
    if (this.has_buff(buffs.bleed) && this.has_buff(buffs['null'])) {
      return skills.bloodboost;
    }
    if (this.stats.hp < 0.5 && !this.has_buff(buffs.bleed)) {
      if (this.has_buff(buffs.bloodboost)) {
        return skills.bloodlet;
      } else if (this.has_buff(buffs['null'])) {
        list.push(skills.bloodlet);
      }
    }
    if (list.length === 0) {
      return null;
    }
    return list[Math.random() * list.length | 0];
  }
};
Monster.types.cure = {
  name: 'Cure-chan',
  key: 'monster_cure0',
  skills: [skills.strike],
  drops: [
    {
      item: 'humanskull',
      chance: 100,
      quantity: 1
    }, {
      item: 'medicine',
      chance: 100,
      quantity: 20
    }, {
      item: 'excel',
      chance: 100,
      quantity: 1
    }, {
      item: 'sporb',
      chance: 100,
      quantity: 2
    }
  ],
  xpwell: 400,
  xpkill: 75,
  speed: 100,
  hp: 300,
  def: 115,
  trigger: function(){
    if (this.triggered) {
      return;
    }
    if (this.stats.hp <= 0.33) {
      this.triggered = true;
      this.loadTexture('monster_cure1');
      this.stats.speed *= 2;
      this.stats.def += 20;
      triggertext(tl("Cure-chan became triggered!"));
    } else if (averagelevel() < 17 && !this.message1) {
      this.message1 = true;
      triggertext(tl("Cure-chan: You are not prepared!"));
    }
  },
  ai: function(){
    var list, i$, ref$, len$, buff;
    if (this.triggered) {
      return skills.strike;
    }
    list = [skills.strike];
    for (i$ = 0, len$ = (ref$ = this.buffs).length; i$ < len$; ++i$) {
      buff = ref$[i$];
      if (buff.negative && buff.name !== 'coagulate') {
        list.push(skills.cure);
      }
    }
    if (!this.has_buff(buffs.regen) && this.stats.hp <= 0.75 && list.length < 2) {
      list.push(skills.regenerate);
    }
    return list[Math.floor(Math.random() * list.length)];
  }
};
Monster.types.zmapp = {
  name: 'Zmapp',
  key: 'monster_zmapp0',
  skills: [skills.strike],
  drops: [
    {
      item: 'excel',
      chance: 100,
      quantity: 1
    }, {
      item: 'sporb',
      chance: 100,
      quantity: 3
    }
  ],
  xpwell: 600,
  xpkill: 75,
  atk: 100,
  speed: 120,
  hp: 300,
  trigger: function(){
    if (this.triggered) {
      return;
    }
    if (this.stats.hp <= 0.5) {
      this.triggered = true;
      this.loadTexture('monster_zmapp1');
      this.stats.speed *= 3;
      this.stats.def *= 2;
      triggertext(tl("Zmapp became triggered!"));
    }
  },
  ai: function(){
    var list, i$, ref$, len$, enemy;
    list = [skills.strike, skills.curse];
    if (this.stats.hp <= 0.5) {
      list = [skills.hemorrhage, skills.hellfire];
    }
    for (i$ = 0, len$ = (ref$ = enemy_list()).length; i$ < len$; ++i$) {
      enemy = ref$[i$];
      if (enemy.has_buff(buffs.bleed)) {
        list = [skills.bloodburst];
        break;
      }
    }
    return list[Math.floor(Math.random() * list.length)];
  },
  escape: 0
};
Monster.types.cureX = {
  name: 'Cure-chan',
  key: 'monster_cure0',
  skills: [skills.quickheal],
  xpwell: 1000,
  xpkill: 100,
  hp: 300,
  ai: function(){
    var list, i$, ref$, len$, enemy, j$, ref1$, len1$, buff, ally;
    list = [skills.quickheal];
    for (i$ = 0, len$ = (ref$ = enemy_list()).length; i$ < len$; ++i$) {
      enemy = ref$[i$];
      for (j$ = 0, len1$ = (ref1$ = enemy.buffs).length; j$ < len1$; ++j$) {
        buff = ref1$[j$];
        if (buff.base === buffs.bleed && buff.duration < 1) {
          return skills.coagulate;
        }
      }
    }
    if (monsters.length === 1) {
      list = [skills.quickheal, skills.strike];
    }
    outer: for (i$ = 0, len$ = (ref$ = ally_list()).length; i$ < len$; ++i$) {
      ally = ref$[i$];
      for (j$ = 0, len1$ = (ref1$ = ally.buffs).length; j$ < len1$; ++j$) {
        buff = ref1$[j$];
        if (buff.negative) {
          list.push(skills.clense);
          break outer;
        }
      }
    }
    return list[Math.floor(Math.random() * list.length)];
  },
  escape: 0
};
Monster.types.zmappX = {
  name: 'Zmapp',
  key: 'monster_zmappX',
  skills: [skills.hemorrhage],
  xpwell: 1000,
  xpkill: 100,
  hp: 300,
  speed: 150,
  ai: function(){
    var list, nullcount, bleedcount, i$, ref$, len$, enemy;
    list = [];
    nullcount = 0;
    bleedcount = 0;
    for (i$ = 0, len$ = (ref$ = enemy_list()).length; i$ < len$; ++i$) {
      enemy = ref$[i$];
      if (enemy.has_buff(buffs['null'])) {
        nullcount++;
      }
      if (enemy.has_buff(buffs.bleed)) {
        bleedcount++;
      }
      if (enemy.has_buff(buffs.coagulate) && !enemy.has_buff(buffs['null'])) {
        list.push(skills.bloodrun);
      }
    }
    if (bleedcount > 0 && nullcount > 0) {
      list.push(skills.infectspread);
    } else if (nullcount > 0) {
      list.push(skills.hemorrhage);
    }
    if (nullcount > 1) {
      list.push(skills.pandemic);
    }
    if (!list.length) {
      return skills.strike;
    }
    return list[Math.floor(Math.random() * list.length)];
  },
  escape: 0
};
Monster.types.who = {
  name: 'WHO-chan',
  key: 'monster_who',
  skills: [skills.angelRain, skills.hellfire],
  drops: [{
    item: 'humansoul',
    chance: 100,
    quantity: 1200000
  }],
  xpwell: 1000,
  xpkill: 100,
  hp: 600,
  speed: 75,
  undying: function(){
    return monsters.length > 1;
  },
  trigger: function(){
    if (this.triggered) {
      return;
    }
    if (this.stats.hp <= 0) {
      this.triggered = true;
      this.stats.speed *= 0.8;
      this.stats.atk *= 0.8;
      triggertext(tl("Who-chan: I cannot die."));
    }
  },
  ai: function(){
    if (this.stats.hp <= 0) {
      if (this.has_buff(buffs.bleed) && this.has_buff(buffs['null'])) {
        return skills.bloodboost;
      }
    }
    if (this.triggered && this.stats.hp > 0 && this.has_buff(buffs['null'])) {
      return skills.bloodlet;
    }
    return null;
  },
  escape: 0
};
Monster.types.joki = {
  name: 'Joki',
  key: 'monster_joki',
  skills: [skills.strike, skills.joki_shuffle],
  xpwell: 1000,
  xpkill: 100,
  hp: 500,
  drops: [
    {
      item: 'humansoul',
      chance: 100,
      quantity: 3000000
    }, {
      item: 'deathsmantle',
      chance: 100,
      quantity: 1
    }, {
      item: 'scythe',
      chance: 100,
      quantity: 1
    }
  ],
  ai: function(){
    var i$, ref$, len$, battler;
    if (monsters.length <= 3) {
      return skills.joki_split;
    }
    if (this.item.base === buffs['null']) {
      for (i$ = 0, len$ = (ref$ = hero_list()).length; i$ < len$; ++i$) {
        battler = ref$[i$];
        if (battler.item.base !== buffs['null']) {
          return skills.joki_thief;
        }
      }
    }
    if (!this.has_buff(buffs.obscure) && Math.random() < 0.33) {
      return skills.shroud;
    }
    return null;
  },
  ondeath: function(){
    var i$, ref$, len$, hero;
    for (i$ = 0, len$ = (ref$ = hero_list()).length; i$ < len$; ++i$) {
      hero = ref$[i$];
      if (hero.originalitem === this.item.base && hero.item.base === buffs['null']) {
        return hero.item.load_buff(this.item.base);
      }
    }
  }
};
Monster.types.jokiclone = {
  name: 'Joki',
  key: 'monster_joki',
  skills: [skills.strike, skills.joki_shuffle],
  xp: 100,
  ai: function(){
    var i$, ref$, len$, battler;
    if (this.item.base === buffs['null']) {
      for (i$ = 0, len$ = (ref$ = hero_list()).length; i$ < len$; ++i$) {
        battler = ref$[i$];
        if (battler.item.base !== buffs['null']) {
          return skills.joki_thief;
        }
      }
    }
    if (!this.has_buff(buffs.obscure) && Math.random() < 0.33) {
      return skills.shroud;
    }
    return null;
  },
  ondeath: Monster.types.joki.ondeath
};
Monster.types.lepsy = {
  name: 'Epilepsy',
  key: 'monster_lepsy',
  skills: [skills.strike, skills.seizure2],
  xpwell: 300,
  xpkill: 100,
  drops: [
    {
      item: 'silverdust',
      chance: 100,
      quantity: 4
    }, {
      item: 'starpuff',
      chance: 100,
      quantity: 2
    }
  ],
  hp: 250,
  def: 150,
  speed: 120,
  atk: 100,
  ai: function(){
    var list, enemylist, i$, len$, enemy;
    if (monsters.length === 1) {
      return skills.lepsysummon;
    }
    list = [];
    enemylist = enemy_list();
    for (i$ = 0, len$ = enemylist.length; i$ < len$; ++i$) {
      enemy = enemylist[i$];
      if (enemy.has_buff(buffs.seizure)) {
        list.push(skills.strike);
      } else {
        list.push(skills.seizure2);
      }
    }
    return list[Math.random() * list.length | 0];
  }
};
Monster.types.parvo = {
  name: 'Parvo',
  key: 'monster_parvo',
  skills: [skills.lovetap, skills.lick],
  xpwell: 300,
  xpkill: 100,
  drops: [
    {
      item: 'fur',
      chance: 100,
      quantity: 8
    }, {
      item: 'bugbits',
      chance: 100,
      quantity: 4
    }
  ],
  hp: 200,
  def: 200,
  speed: 70,
  atk: 100,
  ai: function(){
    var enemylist, i$, len$, enemy;
    if (monsters.length === 1) {
      return skills.parvosummon;
    }
    enemylist = enemy_list();
    for (i$ = 0, len$ = enemylist.length; i$ < len$; ++i$) {
      enemy = enemylist[i$];
      if (enemy.stats.sp_level - enemy.stats.sp > 0.9) {
        return skills.sabotage;
      }
    }
    return null;
  }
};
Monster.types.zika = {
  name: 'Zika',
  key: 'monster_zika',
  skills: [skills.strike],
  xpwell: 300,
  xpkill: 100,
  drops: [
    {
      item: 'medicine',
      chance: 100,
      quantity: 4
    }, {
      item: 'bleach',
      chance: 60,
      quantity: 2
    }, {
      item: 'swarmscroll',
      chance: 100,
      quantity: 5
    }
  ],
  hp: 250,
  def: 250,
  speed: 120,
  atk: 100,
  ai: function(){
    var list, i$, ref$, len$, enemy, j$, ref1$, len1$, buff;
    list = [];
    for (i$ = 0, len$ = (ref$ = enemy_list()).length; i$ < len$; ++i$) {
      enemy = ref$[i$];
      for (j$ = 0, len1$ = (ref1$ = enemy.buffs).length; j$ < len1$; ++j$) {
        buff = ref1$[j$];
        list.push(buff.name === 'null'
          ? skills.swarm
          : skills.hex);
        if (this.stats.hp <= 0.5 && buff.name === 'swarm') {
          list.push(skills.swarmdrain);
        }
      }
    }
    if (list.length === 0) {
      return null;
    }
    return list[Math.random() * list.length | 0];
  }
};
Monster.types.voideye = {
  name: 'E̢̡͡͞y҉̢̢̡e̛҉̀҉ ̡̕͢͠͡S̡͜͞͝t͟a҉҉̵́l̡k̷̵͝',
  key: 'monster_voideye',
  skills: [skills.eyebeam],
  xp: 100,
  hp: 80,
  atk: 75,
  def: 70,
  attributes: ['void'],
  escape: 70,
  drops: [
    {
      item: 'gravedust',
      chance: 75,
      quantity: 1
    }, {
      item: 'gravedust',
      chance: 25,
      quantity: 1
    }, {
      item: 'voidcrystal',
      chance: 50,
      quantity: 1
    }, {
      item: 'teleport',
      chance: 25,
      quantity: 1
    }, {
      item: 'starpuff',
      chance: 5,
      quantity: 1
    }
  ],
  undying: function(){
    var i$, ref$, len$, monster;
    if (averagelevel() <= this.level) {
      return true;
    }
    for (i$ = 0, len$ = (ref$ = monsters).length; i$ < len$; ++i$) {
      monster = ref$[i$];
      if (monster.xpwell > 0) {
        return true;
      }
    }
    return false;
  }
};
Monster.types.voidtofu = {
  name: 'T҉̛̕͢ơ͡f̸̀͝ù͟͞͡',
  key: 'monster_voidtofu',
  skills: [skills.attack, skills.curse],
  xp: 100,
  speed: 90,
  drops: [
    {
      item: 'gravedust',
      chance: 50,
      quantity: 1
    }, {
      item: 'gravedust',
      chance: 50,
      quantity: 1
    }, {
      item: 'voidcrystal',
      chance: 75,
      quantity: 1
    }, {
      item: 'teleport',
      chance: 20,
      quantity: 1
    }, {
      item: 'starpuff',
      chance: 10,
      quantity: 1
    }
  ],
  undying: function(){
    if (switches.ate_nae || switches.ate_chikun || switches.ate_eidzu || switches.ate_sars || switches.ate_rabies || switches.ate_llov) {
      return false;
    }
    return !battle.critical;
  }
};
Monster.types.voidgast = {
  name: ' ̸̸́͠ ̧̢ ̢̛ ̸̵͢',
  key: 'monster_voidgast',
  skills: [skills.vbite],
  xp: 100,
  atk: 120,
  drops: [
    {
      item: 'gravedust',
      chance: 75,
      quantity: 1
    }, {
      item: 'gravedust',
      chance: 75,
      quantity: 1
    }, {
      item: 'voidcrystal',
      chance: 100,
      quantity: 1
    }, {
      item: 'teleport',
      chance: 25,
      quantity: 1
    }, {
      item: 'starpuff',
      chance: 10,
      quantity: 1
    }
  ],
  undying: function(){
    var hp, i$, ref$, len$, hero;
    hp = 0;
    for (i$ = 0, len$ = (ref$ = heroes).length; i$ < len$; ++i$) {
      hero = ref$[i$];
      hp += hero.stats.hp;
    }
    return hp / heroes.length > 0.25;
  }
};
Monster.types.voidskel = {
  name: '\\̀͝_̸̧̨͞o҉̧̀',
  key: 'monster_voidskel',
  skills: [skills.attack],
  xp: 80,
  hp: 80,
  atk: 70,
  def: 70,
  speed: 120,
  escape: 50,
  drops: [
    {
      item: 'gravedust',
      chance: 50,
      quantity: 1
    }, {
      item: 'gravedust',
      chance: 50,
      quantity: 1
    }, {
      item: 'voidcrystal',
      chance: 25,
      quantity: 1
    }, {
      item: 'teleport',
      chance: 10,
      quantity: 1
    }, {
      item: 'starpuff',
      chance: 5,
      quantity: 1
    }
  ],
  undying: function(){
    var i$, ref$, len$, monster;
    for (i$ = 0, len$ = (ref$ = monsters).length; i$ < len$; ++i$) {
      monster = ref$[i$];
      if (monster.monstertype === Monster.types.voidskel && monster.stats.hp > 0) {
        return true;
      }
    }
    return false;
  }
};
Monster.types.darkllov = {
  name: 'Lloviu-tan',
  key: 'monster_darkllov',
  skills: [skills.strike],
  xpwell: 1000,
  xpkill: 100,
  speed: 400,
  luck: 200,
  hp: 800,
  drops: [
    {
      item: 'llovsoul',
      chance: 100,
      quantity: 1
    }, {
      item: 'humansoul',
      chance: 100,
      quantity: 1000000
    }
  ],
  trigger: function(){
    if (!this.trigger) {
      this.trigger = 1;
      triggertext(tl("Lloviu-tan: Who are you? Stay away..."));
    }
  },
  ai: function(){
    var list, enemylist, charmcount, i$, len$, enemy;
    list = [skills.lovelyArrow];
    enemylist = enemy_list();
    charmcount = 0;
    for (i$ = 0, len$ = enemylist.length; i$ < len$; ++i$) {
      enemy = enemylist[i$];
      if (enemy.has_buff(buffs.charmed)) {
        charmcount++;
      }
    }
    if (charmcount < enemylist.length) {
      list.push(skills.devilKiss);
    }
    if (this.stats.hp < 0.5) {
      list.push(skills.heal);
    }
    return list[Math.random() * list.length | 0];
  }
};
encounter = {};
encounter.bg = {
  forest: ['bg_0_0', 'bg_0_1', 0x898989, 0x020501],
  forest_night: ['bg_4_0', 'bg_4_1', 0x080808, 0x020501],
  water: ['bg_5_0', 'bg_5_1', 0x666666, 0x020501],
  water_night: ['bg_5_0a', 'bg_5_1a', 0x020501, 0x020501],
  water_dead: ['bg_5_0b', 'bg_5_1b', 0x9e3a3a, 0x020501],
  dungeon: ['bg_1_0', 'bg_1_1', 0x080808, 0x080808],
  jungle: ['bg_2_0', 'bg_2_1', 0xc34b4b, 0x020501],
  tower: ['bg_3_0', 'bg_3_1', 0xfcfcfc, 0x090709],
  castle: ['bg_6_0', 'bg_6_1', 0x080808, 0x080808],
  earth: ['bg_7_0', 'bg_7_1', 0x3c55b3, 0x020501],
  earth_snow: ['bg_7_0s', 'bg_7_1s', 0x3c55b3, 0x020501],
  lab: ['bg_8_0', 'bg_6_1', 0x080808, 0x080808],
  'void': ['bg_9_0', 'bg_6_1', 0x080808, 0x080808]
};
encounter.slime = {
  monsters: [{
    id: 'slime',
    x: 0,
    y: 1,
    s: 1,
    l1: 1,
    l2: 6
  }]
};
encounter.slime2 = {
  monsters: [
    {
      id: 'slime',
      x: 2,
      y: 2,
      s: 1,
      l1: 3,
      l2: 8
    }, {
      id: 'slime',
      x: -2,
      y: 2,
      s: 1,
      l1: 3,
      l2: 8
    }
  ]
};
encounter.slime3 = {
  monsters: [
    {
      id: 'slime',
      x: 2.5,
      y: 2,
      s: 1,
      l1: 3,
      l2: 7
    }, {
      id: 'slime',
      x: -2.5,
      y: 2,
      s: 1,
      l1: 3,
      l2: 7
    }, {
      id: 'slime',
      x: 0,
      y: 1,
      s: 1,
      l1: 3,
      l2: 7
    }
  ],
  lmod: -1
};
encounter.deadworld_slime = {
  monsters: [
    {
      id: 'slimex',
      x: 2.5,
      y: 2,
      s: 1,
      l1: 6,
      l2: 18
    }, {
      id: 'slimex',
      x: -2.5,
      y: 2,
      s: 1,
      l1: 6,
      l2: 18
    }, {
      id: 'slimex',
      x: 0,
      y: 1,
      s: 1,
      l1: 6,
      l2: 18
    }
  ]
};
encounter.delta_slime = {
  monsters: [
    {
      id: 'slimexx',
      x: 2.5,
      y: 2,
      s: 1,
      l1: 20,
      l2: 30
    }, {
      id: 'slimexx',
      x: -2.5,
      y: 2,
      s: 1,
      l1: 20,
      l2: 30
    }, {
      id: 'slimexx',
      x: 0,
      y: 1,
      s: 1,
      l1: 20,
      l2: 30
    }
  ]
};
encounter.delta_megaslime = {
  monsters: [{
    id: 'slime2xx',
    x: 0,
    y: 1,
    s: 1,
    l1: 20,
    l2: 30
  }]
};
encounter.deadworld_megaslime = {
  monsters: [{
    id: 'slime2x',
    x: 0,
    y: 1,
    s: 1,
    l1: 8,
    l2: 17
  }]
};
encounter.megaslime = {
  monsters: [{
    id: 'slime2',
    x: 0,
    y: 1,
    s: 1,
    l1: 6,
    l2: 15
  }]
};
encounter.earth_slime = {
  monsters: [
    {
      id: 'slime2z',
      x: 3,
      y: 1.5,
      s: 1,
      l1: 35,
      l2: 45
    }, {
      id: 'slime2z',
      x: -3,
      y: 1.5,
      s: 1,
      l1: 35,
      l2: 45
    }
  ]
};
encounter.naegleria = {
  monsters: [{
    id: 'naegleria',
    x: 0,
    y: 1,
    s: 1,
    l1: 5,
    l2: 5
  }],
  onvictory: function(){
    return switches.beat_nae = true;
  },
  runnode: 'naerun'
};
encounter.naegleria_r = {
  monsters: [{
    id: 'naegleria_r',
    x: 0,
    y: 1,
    s: 1,
    l1: 0,
    l2: Infinity
  }],
  onvictory: function(){
    return temp.nae_reward = true;
  }
};
encounter.sars = {
  monsters: [{
    id: 'sars',
    x: 0,
    y: 0.5,
    s: 1,
    l1: 30,
    l2: 40
  }],
  onvictory: function(){
    return switches.beat_sars = true;
  }
};
encounter.rabies = {
  monsters: [{
    id: 'rabies',
    x: 0,
    y: 1,
    s: 1,
    l1: 30,
    l2: 40
  }],
  onvictory: function(){
    return switches.beat_rab = true;
  }
};
encounter.aids = {
  monsters: [
    {
      id: 'eidzu1',
      x: -2,
      y: 1,
      s: 1,
      l1: 30,
      l2: 40
    }, {
      id: 'eidzu2',
      x: 1.5625,
      y: 0.3125,
      s: 1,
      l1: 30,
      l2: 40
    }
  ],
  onvictory: function(){
    return switches.beat_aids = true;
  }
};
encounter.ghost = {
  monsters: [{
    id: 'ghost',
    x: 0,
    y: 1,
    s: 1,
    l1: 8,
    l2: 10
  }]
};
encounter.ghost2 = {
  monsters: [
    {
      id: 'ghost',
      x: 2,
      y: 2,
      s: 1,
      l1: 8,
      l2: 10
    }, {
      id: 'ghost',
      x: -2,
      y: 2,
      s: 1,
      l1: 8,
      l2: 10
    }
  ],
  lmod: -1
};
encounter.dw_ghost2 = {
  monsters: [
    {
      id: 'ghost',
      x: 2,
      y: 2,
      s: 1,
      l1: 8,
      l2: 17
    }, {
      id: 'ghost',
      x: -2,
      y: 2,
      s: 1,
      l1: 8,
      l2: 17
    }
  ]
};
encounter.skullghost = {
  monsters: [{
    id: 'skullghost',
    x: 0,
    y: 1,
    s: 1,
    l1: 8,
    l2: 17
  }]
};
encounter.skullghost3 = {
  monsters: [
    {
      id: 'skullghost',
      x: 0,
      y: 2,
      s: 1,
      l1: 35,
      l2: 50
    }, {
      id: 'skullghost',
      x: -3,
      y: 1,
      s: 1,
      l1: 35,
      l2: 50
    }, {
      id: 'skullghost',
      x: 3,
      y: 1,
      s: 1,
      l1: 35,
      l2: 50
    }
  ]
};
encounter.greblin4 = {
  monsters: [
    {
      id: 'greblin',
      x: -1.5,
      y: 2,
      s: 1,
      l1: 35,
      l2: 50
    }, {
      id: 'greblin',
      x: 1.5,
      y: 2,
      s: 1,
      l1: 35,
      l2: 50
    }, {
      id: 'greblin',
      x: -3,
      y: 1,
      s: 1,
      l1: 35,
      l2: 50
    }, {
      id: 'greblin',
      x: 3,
      y: 1,
      s: 1,
      l1: 35,
      l2: 50
    }
  ],
  lmod: -1
};
encounter.greblin5 = {
  monsters: [
    {
      id: 'greblin',
      x: -1.5,
      y: 2,
      s: 1,
      l1: 35,
      l2: 50
    }, {
      id: 'greblin',
      x: 1.5,
      y: 2,
      s: 1,
      l1: 35,
      l2: 50
    }, {
      id: 'greblin',
      x: 0,
      y: 1,
      s: 1,
      l1: 35,
      l2: 50
    }, {
      id: 'greblin',
      x: -3,
      y: 0,
      s: 1,
      l1: 35,
      l2: 50
    }, {
      id: 'greblin',
      x: 3,
      y: 0,
      s: 1,
      l1: 35,
      l2: 50
    }
  ],
  lmod: -1
};
encounter.skulmander = {
  monsters: [{
    id: 'skulmander',
    x: 0,
    y: 1,
    s: 1,
    l1: 25,
    l2: 35
  }]
};
encounter.skulmander2 = {
  monsters: [
    {
      id: 'skulmander',
      x: 2,
      y: 1,
      s: 1,
      l1: 25,
      l2: 35
    }, {
      id: 'skulmander',
      x: -2,
      y: 2,
      s: 1,
      l1: 25,
      l2: 35
    }
  ]
};
encounter.lurker = {
  monsters: [{
    id: 'lurker',
    x: 0,
    y: 1,
    s: 1,
    l1: 25,
    l2: 35
  }],
  bg: waterbg
};
encounter.lurker2 = {
  monsters: [
    {
      id: 'lurker',
      x: 2,
      y: 1,
      s: 1,
      l1: 25,
      l2: 35
    }, {
      id: 'lurker',
      x: -2,
      y: 2,
      s: 1,
      l1: 25,
      l2: 35
    }
  ],
  bg: waterbg
};
encounter.skulurker = {
  monsters: [
    {
      id: 'skulmander',
      x: 2,
      y: 2,
      s: 1,
      l1: 25,
      l2: 35
    }, {
      id: 'lurker',
      x: -2,
      y: 1,
      s: 1,
      l1: 25,
      l2: 35
    }
  ],
  bg: waterbg
};
encounter.bat = {
  monsters: [{
    id: 'bat',
    x: 0,
    y: 1,
    s: 1,
    l1: 8,
    l2: 25
  }]
};
encounter.bat2 = {
  monsters: [
    {
      id: 'bat',
      x: 2,
      y: 2,
      s: 1,
      l1: 8,
      l2: 23
    }, {
      id: 'bat',
      x: -2,
      y: 2,
      s: 1,
      l1: 8,
      l2: 23
    }
  ],
  lmod: -1
};
encounter.graven = {
  monsters: [{
    id: 'graven',
    x: 0,
    y: 1,
    s: 1,
    l1: 8,
    l2: 20
  }]
};
encounter.mantrap = {
  monsters: [{
    id: 'mantrap',
    x: 0,
    y: 1,
    s: 1,
    l1: 8,
    l2: 20
  }]
};
encounter.delta_mantrap = {
  monsters: [{
    id: 'mantrap',
    x: 0,
    y: 1,
    s: 1,
    l1: 25,
    l2: 35
  }]
};
encounter.mimic = {
  monsters: [{
    id: 'mimic',
    x: 0,
    y: 1,
    s: 1,
    l1: 0,
    l2: Infinity
  }]
};
encounter.rhinosaurus = {
  monsters: [{
    id: 'rhinosaurus',
    x: 0,
    y: 1,
    s: 1,
    l1: 25,
    l2: 35
  }]
};
encounter.woolyrhino = {
  monsters: [{
    id: 'woolyrhinosaurus',
    x: 0,
    y: 1,
    s: 1,
    l1: 35,
    l2: 45
  }]
};
encounter.wolf = {
  monsters: [
    {
      id: 'wolf',
      x: -3,
      y: 1,
      s: 1,
      l1: 35,
      l2: 45
    }, {
      id: 'wolf',
      x: 3,
      y: 1,
      s: 1,
      l1: 35,
      l2: 45
    }
  ]
};
encounter.rhinowolf = {
  monsters: [
    {
      id: 'woolyrhinosaurus',
      x: -3,
      y: 1,
      s: 1,
      l1: 35,
      l2: 45
    }, {
      id: 'wolf',
      x: 3,
      y: 1,
      s: 1,
      l1: 35,
      l2: 45
    }
  ]
};
encounter.polyduck = {
  monsters: [{
    id: 'polyduck',
    x: 0,
    y: 1,
    s: 1,
    l1: 10,
    l2: 20
  }]
};
encounter.eel = {
  monsters: [{
    id: 'eel',
    x: 0,
    y: 1,
    s: 1,
    l1: 20,
    l2: 35
  }]
};
encounter.cancer = {
  monsters: [
    {
      id: 'cancer',
      x: -3,
      y: 1,
      s: 1,
      l1: 35,
      l2: 45
    }, {
      id: 'cancer',
      x: 3,
      y: 1,
      s: 1,
      l1: 35,
      l2: 45
    }
  ]
};
encounter.cancer3 = {
  monsters: [
    {
      id: 'cancer',
      x: 0,
      y: 1.5,
      s: 1,
      l1: 40,
      l2: 47
    }, {
      id: 'cancer',
      x: -3,
      y: 0.5,
      s: 1,
      l1: 40,
      l2: 47
    }, {
      id: 'cancer',
      x: 3,
      y: 0.5,
      s: 1,
      l1: 40,
      l2: 47
    }
  ]
};
encounter.sally = {
  monsters: [
    {
      id: 'mutant',
      x: -3,
      y: 1,
      s: 1,
      l1: 40,
      l2: 47
    }, {
      id: 'mutant',
      x: 3,
      y: 1,
      s: 1,
      l1: 40,
      l2: 47
    }
  ]
};
encounter.throne = {
  monsters: [{
    id: 'throne',
    x: 0,
    y: 1,
    s: 1,
    l1: 40,
    l2: 47
  }]
};
encounter.sally_throne = {
  monsters: [
    {
      id: 'throne',
      x: 0,
      y: 1.5,
      s: 1,
      l1: 40,
      l2: 48
    }, {
      id: 'mutant',
      x: -3,
      y: 0.5,
      s: 1,
      l1: 40,
      l2: 47
    }, {
      id: 'mutant',
      x: 3,
      y: 0.5,
      s: 1,
      l1: 40,
      l2: 48
    }
  ],
  lmod: -1
};
encounter.sanishark = {
  monsters: [{
    id: 'sanishark',
    x: 0,
    y: 0,
    s: 1,
    l1: 0,
    l2: Infinity
  }]
};
encounter.tengu = {
  monsters: [{
    id: 'tengu',
    x: 0,
    y: 1,
    s: 1,
    l1: 25,
    l2: 35
  }]
};
encounter.wraith = {
  monsters: [{
    id: 'wraith',
    x: 0,
    y: 1,
    s: 1,
    l1: 20,
    l2: 22
  }]
};
encounter.wraith_door = {
  monsters: [{
    id: 'wraith',
    x: 0,
    y: 1,
    s: 1,
    l1: 22,
    l2: 22
  }],
  onvictory: function(){
    return switches.beat_wraith = true;
  }
};
encounter.chikun = {
  monsters: [{
    id: 'chikun',
    x: 0,
    y: 0.5,
    s: 1,
    l1: 0,
    l2: Infinity
  }],
  onvictory: function(){
    return switches.beat_chikun = true;
  },
  runnode: 'landing'
};
encounter.cure = {
  monsters: [{
    id: 'cure',
    x: 0,
    y: 0,
    s: 1,
    l1: 19,
    l2: 20
  }],
  onvictory: function(){
    switches.progress = 'curebeat';
    return switches.progress2 = 9;
  }
};
encounter.cure_single = {
  monsters: [{
    id: 'cure',
    x: 0,
    y: 0,
    s: 1,
    l1: 20,
    l2: 20
  }],
  onvictory: function(){
    join_party('marb', {
      save: false,
      front: true,
      startlevel: 10
    });
    switches.progress = 'curebeat';
    return switches.progress2 = 9;
  }
};
encounter.zmapp = {
  monsters: [{
    id: 'zmapp',
    x: 0,
    y: 0,
    s: 1,
    l1: 25,
    l2: 25
  }],
  onvictory: function(){
    var i$, ref$, len$, p, results$ = [];
    switches.zmapp = 'victory';
    switches.progress = 'zmappbeat';
    for (i$ = 0, len$ = (ref$ = party).length; i$ < len$; ++i$) {
      p = ref$[i$];
      results$.push(p.stats.hp = 1);
    }
    return results$;
  },
  ondefeat: function(){
    switches.zmapp--;
    if (switches.zmapp <= -9) {
      switches.zmapp = 'defeat';
      return switches.progress = 'zmappbeat';
    }
  }
};
encounter.who = {
  monsters: [
    {
      id: 'who',
      x: 0,
      y: 1,
      s: 1,
      l1: 40,
      l2: Infinity
    }, {
      id: 'zmappX',
      x: -6,
      y: 0,
      s: 1,
      l1: 40,
      l2: Infinity
    }, {
      id: 'cureX',
      x: 6,
      y: 0,
      s: 1,
      l1: 40,
      l2: Infinity
    }
  ],
  onvictory: function(){
    switches.progress2 = 32;
    return switches.finale = true;
  },
  ondefeat: function(){
    return switches.progress2 = 31;
  }
};
encounter.joki = {
  monsters: [{
    id: 'joki',
    x: 0,
    y: 0,
    s: 1,
    l1: 0,
    l2: Infinity
  }],
  onvictory: function(){
    return switches.beat_joki = true;
  },
  bg: 'castle'
};
encounter.lepsy = {
  monsters: [{
    id: 'lepsy',
    x: 0,
    y: 0,
    s: 1,
    l1: 0,
    l2: Infinity
  }],
  onvictory: function(){
    switches.beat_lepsy = true;
    session.beat_lepsy = true;
    temp.leps_reward = true;
    return switches.lepsy_timer = Date.now();
  }
};
encounter.parvo = {
  monsters: [{
    id: 'parvo',
    x: 0,
    y: 0,
    s: 1,
    l1: 0,
    l2: Infinity
  }],
  onvictory: function(){
    switches.beat_parvo = true;
    temp.parvo_reward = true;
    return switches.parvo_timer = Date.now();
  }
};
encounter.zika = {
  monsters: [{
    id: 'zika',
    x: 0,
    y: 0,
    s: 1,
    l1: 0,
    l2: Infinity
  }],
  onvictory: function(){
    switches.beat_zika = true;
    temp.zika_reward = true;
    return switches.zika_timer = Date.now();
  }
};
encounter.void0 = {
  monsters: [
    {
      id: 'voidtofu',
      x: 0,
      y: 2,
      s: 1,
      l1: 35,
      l2: 50
    }, {
      id: 'voideye',
      x: -3,
      y: 1,
      s: 1,
      l1: 35,
      l2: 50
    }, {
      id: 'voideye',
      x: 3,
      y: 1,
      s: 1,
      l1: 35,
      l2: 50
    }
  ]
};
encounter.void1 = {
  monsters: [
    {
      id: 'voidgast',
      x: 0,
      y: 2,
      s: 1,
      l1: 35,
      l2: 50
    }, {
      id: 'voideye',
      x: -3,
      y: 1,
      s: 1,
      l1: 35,
      l2: 50
    }, {
      id: 'voideye',
      x: 3,
      y: 1,
      s: 1,
      l1: 35,
      l2: 50
    }
  ]
};
encounter.void2 = {
  monsters: [
    {
      id: 'voidskel',
      x: -2,
      y: 2,
      s: 1,
      l1: 35,
      l2: 50
    }, {
      id: 'voidskel',
      x: 2,
      y: 2,
      s: 1,
      l1: 35,
      l2: 50
    }, {
      id: 'voideye',
      x: 0,
      y: 1,
      s: 1,
      l1: 35,
      l2: 50
    }, {
      id: 'voidskel',
      x: -4,
      y: 0,
      s: 1,
      l1: 35,
      l2: 50
    }, {
      id: 'voidskel',
      x: 4,
      y: 0,
      s: 1,
      l1: 35,
      l2: 50
    }
  ]
};
encounter.void3 = {
  monsters: [
    {
      id: 'voidskel',
      x: -2,
      y: 2,
      s: 1,
      l1: 35,
      l2: 50
    }, {
      id: 'voidskel',
      x: 2,
      y: 2,
      s: 1,
      l1: 35,
      l2: 50
    }, {
      id: 'voidtofu',
      x: 0,
      y: 1,
      s: 1,
      l1: 35,
      l2: 50
    }, {
      id: 'voidskel',
      x: -4,
      y: 0,
      s: 1,
      l1: 35,
      l2: 50
    }, {
      id: 'voidskel',
      x: 4,
      y: 0,
      s: 1,
      l1: 35,
      l2: 50
    }
  ]
};
encounter.void4 = {
  monsters: [
    {
      id: 'voidskel',
      x: -2,
      y: 2,
      s: 1,
      l1: 35,
      l2: 50
    }, {
      id: 'voidskel',
      x: 2,
      y: 2,
      s: 1,
      l1: 35,
      l2: 50
    }, {
      id: 'voidgast',
      x: 0,
      y: 1,
      s: 1,
      l1: 35,
      l2: 50
    }, {
      id: 'voidskel',
      x: -4,
      y: 0,
      s: 1,
      l1: 35,
      l2: 50
    }, {
      id: 'voidskel',
      x: 4,
      y: 0,
      s: 1,
      l1: 35,
      l2: 50
    }
  ]
};
encounter.darkllov = {
  monsters: [{
    id: 'darkllov',
    x: 0,
    y: 0,
    s: 1,
    l1: 0,
    l2: Infinity
  }],
  onvictory: function(){
    return switches.beat_llov = true;
  }
};
Audio = (function(){
  Audio.displayName = 'Audio';
  var prototype = Audio.prototype, constructor = Audio;
  function Audio(){
    this.volume = 0.5;
    this.volumes = {};
    this.sounds = [];
    this.lastplayedtime = Date.now();
    this.lastplayedsound = null;
  }
  Audio.volume = 1.0;
  Audio.prototype.add = function(key, volume, looping){
    var sound;
    volume == null && (volume = 1);
    looping == null && (looping = false);
    this.sounds.push(sound = this[key] = game.sound.add(key, volume, looping));
    this.volumes[key] = volume;
    sound.onLoop.add(function(){
      return this.play();
    }, sound);
  };
  Audio.prototype.play = function(name, settime){
    var sound;
    if ((sound = this[name]) == null) {
      return;
    }
    sound.play(null, null, this.volumes[name] * this.volume * Audio.volume, sound.loop);
    if (settime) {
      this.lastplayedtime = Date.now();
    }
    this.lastplayedsound = sound;
  };
  Audio.prototype.playifnotplaying = function(name){
    if (this[name] == null || this[name].isPlaying) {
      return;
    }
    this.stop();
    this.play(name);
  };
  Audio.prototype.stop = function(){
    var i$, ref$, len$, sound;
    for (i$ = 0, len$ = (ref$ = this.sounds).length; i$ < len$; ++i$) {
      sound = ref$[i$];
      sound.stop();
    }
  };
  Audio.prototype.refresh = function(){
    var i$, ref$, len$, sound;
    for (i$ = 0, len$ = (ref$ = this.sounds).length; i$ < len$; ++i$) {
      sound = ref$[i$];
      if (sound.isPlaying) {
        this.play(sound.key);
      }
    }
  };
  Audio.prototype.fadeOut = function(d){
    var i$, ref$, len$, sound;
    for (i$ = 0, len$ = (ref$ = this.sounds).length; i$ < len$; ++i$) {
      sound = ref$[i$];
      if (sound.isPlaying) {
        sound.fadeOut(d);
      }
    }
  };
  Audio.prototype.fadeIn = function(name, d){
    var sound;
    sound = this[name];
    sound.play(null, null, 0, sound.loop);
    sound.fadeTo(d, this.volumes[name] * this.volume * Audio.volume);
  };
  Audio.prototype.updatevolume = function(){
    if (!this.lastplayedsound) {
      return;
    }
    this.lastplayedsound.volume = this.volumes[this.lastplayedsound.name] * this.volume * Audio.volume;
  };
  return Audio;
}());
sound = new Audio();
music = new Audio();
menusound = new Audio();
voicesound = new Audio();
function create_audio(){
  menusound.add('blip', 0.5);
  voicesound.add('blip', 0.5);
  sound.add('itemget');
  sound.add('encounter');
  sound.add('boom');
  sound.add('defeat');
  sound.add('candle');
  sound.add('strike');
  sound.add('flame');
  sound.add('water');
  sound.add('swing');
  sound.add('laser');
  sound.add('run');
  sound.add('stair');
  sound.add('door');
  sound.add('groan');
  sound.add('voice', 0.5);
  voicesound.add('groan');
  voicesound.add('voice', 0.5);
  voicesound.add('voice2', 0.5);
  voicesound.add('voice3', 0.5);
  voicesound.add('voice4', 0.5);
  voicesound.add('voice5', 0.5);
  voicesound.add('voice6', 0.5);
  voicesound.add('voice7', 0.5);
  voicesound.add('voice8', 0.5);
  voicesound.add('rope', 0.5);
}
function zonemusic(){
  var that;
  if (switches.nomusic) {
    return;
  }
  if (that = access(zones[getmapdata('zone')].music)) {
    music.playifnotplaying(that);
  }
}
NPC = (function(superclass){
  var prototype = extend$((import$(NPC, superclass).displayName = 'NPC', NPC), superclass).prototype, constructor = NPC;
  function NPC(x, y, key, speed, nobody){
    NPC.superclass.call(this, x, y, key, nobody);
    this.add_facing_animation(speed);
    this.add_simple_animation(speed);
    constructor.list.push(this);
  }
  NPC.list = [];
  NPC.clear = function(){
    var i$, ref$, len$, item;
    for (i$ = 0, len$ = (ref$ = constructor.list).length; i$ < len$; ++i$) {
      item = ref$[i$];
      item.destroy();
    }
  };
  return NPC;
}(Actor));
joki = [];
aids = [];
function new_npc(object, key, speed){
  var n, ref$;
  n = new NPC(object.x, object.y, key, speed);
  (ref$ = object.properties).facing == null && (ref$.facing = 'down');
  n.face(object.properties.facing);
  return n;
}
function node_npc(node, key, speed){
  var n, ref$;
  n = new NPC(node.x + HTS, node.y + TS, key, speed);
  (ref$ = node.properties).facing == null && (ref$.facing = 'down');
  n.face(node.properties.facing);
  return n;
}
function create_npc(o, key){
  var object, npc, n;
  object = {
    x: o.x + HTS,
    y: o.y + TS,
    properties: o.properties
  };
  npc = new_npc;
  switch (key) {
  case 'mal':
    if (switches.map === 'earth' && !switches.beat_game) {
      break;
    }
    if (switches.llovsick1 === -2) {
      break;
    }
    if (switches.map === 'hub' && switches.beat_game) {
      break;
    }
    mal = npc(object, 'mal');
    break;
  case 'bp':
    if (switches.map === 'hub' && switches.towerfall_bp) {
      break;
    }
    if (switches.map === 'earth' && switches.beat_game) {
      break;
    }
    if (switches.map === 'lab' && !switches.beat_game) {
      break;
    }
    bp = npc(object, 'bp');
    break;
  case 'joki':
    if (switches.map === 'castle' && switches.beat_joki) {
      break;
    }
    joki[1] = npc(object, 'joki');
    break;
  case 'joki_2':
    joki[2] = npc(object, 'joki');
    break;
  case 'marb':
    if (!in$(marb, party)) {
      marb.relocate(object);
    }
    break;
  case 'ebby':
    if (!in$(ebby, party)) {
      ebby.relocate(object);
    }
    break;
  case 'merchant':
    if (switches.map === 'hub' && (switches.progress2 < 9 || switches.llovsick1 === -2)) {
      break;
    }
    if (switches.map === 'earth' && !switches.beat_game) {
      break;
    }
    temp.herpes_map = switches.progress2 < 9
      ? 'deadworld'
      : switches.progress2 < 21
        ? 'hub'
        : !switches.beat_game ? 'delta' : null;
    merch = npc(object, switches.map === temp.herpes_map ? 'merchant1' : 'merchant2', 2);
    merch.setautoplay();
    break;
  case 'herpes':
    if (!switches.beat_game) {
      break;
    }
    herpes = npc(object, 'herpes');
    break;
  case 'wraith':
    if (switches.beat_wraith) {
      break;
    }
    n = npc(object, 'wraith');
    n.setautoplay(5);
    break;
  case 'nae':
    if (switches.map === 'earth') {
      if (!switches.beat_game) {
        break;
      }
      if (!switches.revivalnae) {
        break;
      }
      nae = npc(object, 'naegleria');
      nae.setautoplay(2);
      break;
    }
    if (switches.beat_nae) {
      break;
    }
    nae = npc(object, 'mob_naegleria');
    nae.battle = encounter.naegleria;
    nae.setautoplay(2);
    break;
  case 'war':
    n = npc(object, 'war');
    n.body.setSize(3 * TS, 2 * TS);
    n.interact = scenario.war;
    break;
  case 'darkllov':
    if (switches.beat_llov) {
      break;
    }
    n = npc(object, 'mob_llov');
    n.battle = encounter.darkllov;
    n.setautoplay(8);
    break;
  case 'pox':
    if (switches.map === 'earth' && !switches.beat_game) {
      break;
    }
    if (switches.map === 'pox_cabin' && switches.confronting_joki) {
      break;
    }
    if (switches.map === 'hub' && switches.progress2 < 16) {
      break;
    }
    if (switches.map === 'hub' && switches.beat_game) {
      break;
    }
    if (switches.llovsick1 === -2) {
      break;
    }
    pox = npc(object, 'pox');
    break;
  case 'leps':
    leps = npc(object, 'leps');
    break;
  case 'parvo':
    parvo = npc(object, 'parvo');
    break;
  case 'cure':
    if (switches.progress2 >= 9 && switches.map === 'deadworld' && !(switches.curefate > 0)) {
      break;
    }
    if (switches.map === 'labdungeon' && switches.curefate) {
      break;
    }
    cure = npc(object, 'cure');
    break;
  case 'zmapp':
    if (switches.map === 'towertop' && !(switches.progress === 'zmappbattle' || switches.progress === 'zmappbeat')) {
      break;
    }
    if (switches.map === 'labdungeon' && switches.curefate) {
      break;
    }
    if (switches.map === 'deadworld' && !(switches.curefate > 0)) {
      break;
    }
    zmapp = npc(object, 'zmapp');
    break;
  case 'aids1':
    aids[1] = npc(object, 'aids1');
    if (switches.beat_aids) {
      aids[1].kill();
    }
    break;
  case 'aids2':
    aids[2] = npc(object, 'aids2');
    if (switches.beat_aids) {
      aids[2].kill();
    }
    break;
  case 'aids3':
    if (switches.map === 'earth' && !switches.beat_game) {
      break;
    }
    if (switches.map === 'earth' && !switches.revivalaids) {
      break;
    }
    aids[0] = npc(object, 'aids3');
    break;
  case 'sars':
    if (switches.map === 'earth' && !switches.beat_game) {
      break;
    }
    if (switches.map === 'earth' && !switches.revivalsars) {
      break;
    }
    sars = npc(object, 'sars');
    if (switches.beat_sars && switches.map === 'delta') {
      sars.kill();
    }
    break;
  case 'rab':
    if (switches.map === 'earth' && !switches.beat_game) {
      break;
    }
    if (switches.map === 'earth' && !switches.revivalrab) {
      break;
    }
    rab = npc(object, 'rab');
    if (switches.beat_rab && switches.map === 'delta') {
      rab.kill();
    }
    break;
  case 'ammit':
    ammit = npc(object, 'ammit');
  }
}
speakers = {
  marb: {
    display: 'Marburg-sama',
    composite: {
      x: -96,
      y: -129,
      player: 'marb',
      face: 'marb_face'
    },
    'default': 0,
    smile: 1,
    troubled: 2,
    angry: 3,
    grief: 4,
    aroused: 5,
    voice: 'voice2'
  },
  ebby: {
    display: 'Ebola-chan',
    composite: {
      x: -81,
      y: -118,
      player: 'ebby',
      face: 'ebby_face'
    },
    'default': 1,
    smile: 0,
    concern: 2,
    shock: 3,
    cry: 4,
    voice: 'voice7'
  },
  llov: {
    display: 'Lloviu-tan',
    composite: {
      x: -77,
      y: -115,
      player: 'llov',
      face: 'llov_face'
    },
    'default': function(){
      if (switches.llovsick) {
        return 2;
      } else {
        return 0;
      }
    },
    scared: 3,
    sick: 2,
    smile: 1
  },
  mal: {
    display: 'Malaria-sama',
    'default': 'mal_port',
    voice: 'voice2'
  },
  joki: {
    display: 'Joki',
    'default': 'joki_port',
    voice: 'voice5'
  },
  herpes: {
    display: 'Herpes-chan',
    'default': 'herpes_port',
    voice: 'voice5'
  },
  merch: {
    display: 'Agent of Herpes',
    'default': 'merchant_port',
    voice: 'voice6'
  },
  bp: {
    display: 'Plague-sama',
    'default': 'bp_port',
    voice: 'voice3'
  },
  pox: {
    display: "Smallpox",
    'default': 'pox_port',
    injured: 'pox_injured',
    voice: 'voice6'
  },
  leps: {
    display: 'Lepsy-tan',
    'default': 'leps_port',
    voice: 'voice7'
  },
  parvo: {
    display: 'Parvo-tan',
    'default': 'parvo_port',
    voice: 'voice6'
  },
  zika: {
    display: 'Zika-chan',
    'default': 'zika_port',
    voice: 'voice7'
  },
  nae: {
    display: 'Nae-tan',
    'default': 'nae_port',
    voice: 'voice6'
  },
  aids1: {
    display: 'Eidzu I',
    'default': 'aids1_port',
    mad: 'aids1_mad',
    fused: 'aids3_port',
    voice: 'voice6'
  },
  aids2: {
    display: 'Eidzu II',
    'default': 'aids2_port',
    mad: 'aids2_mad',
    fused: 'aids3_port',
    voice: 'voice8'
  },
  sars: {
    display: 'Sars-chan',
    'default': 'sars_port',
    mad: 'sars_mad',
    voice: 'voice5'
  },
  rab: {
    display: 'Rabies-chan',
    'default': 'rab_port',
    mad: 'rab_mad',
    young: 'rab2_port',
    voice: 'voice8'
  },
  chikun: {
    display: 'Chikun-chan',
    'default': 'chikun_port',
    voice: 'voice5'
  },
  ammit: {
    display: 'Ammit-chan',
    'default': 'ammit_port',
    voice: 'rope'
  },
  shiro: {
    display: 'Shiro',
    'default': 'shiro_port',
    voice: 'voice6'
  },
  wraith: {
    display: 'Wraith',
    'default': 'wraith_port',
    voice: 'groan'
  },
  pest: {
    display: 'Pestilence',
    voice: 'groan'
  },
  famine: {
    display: 'Famine',
    voice: 'groan'
  },
  war: {
    display: 'War',
    'default': 'war_port',
    voice: 'groan'
  },
  cure: {
    display: 'Cure-chan',
    'default': 'cure_port',
    voice: 'voice4'
  },
  zmapp: {
    display: 'Zmapp-chan',
    'default': function(){
      if (switches.progress2 < 16) {
        return 'zmapp_port';
      } else {
        return 'zmapp_healthy';
      }
    },
    voice: 'voice5'
  },
  who: {
    display: 'WHO-chan',
    'default': 'who_port',
    voice: 'rope'
  },
  min: {
    display: 'Minion',
    'default': 'min_port',
    voice: 'voice6'
  },
  slime: {
    display: 'Slime',
    'default': 'slime_port',
    voice: 'groan'
  }
};
for (key in speakers) {
  if (speakers[key].voice == null) {
    speakers[key].voice = 'voice';
  }
}
function npc_events(){
  var i$, ref$, len$, j, merch_agent, merch_herpes, herpes_gambling, merch_gambling, herpes_glassblowing, merch_glassblowing, herpes_intro, herpes_chat, ref1$, ref2$, ref3$, zika, ss, ref4$, f;
  if (marb != null) {
    marb.interact = function(){
      say('marb', 'troubled', tl("Llov? What are you doing here?"));
      say('llov', tl("Llov is here to help!"));
      say('marb', 'troubled', tl("You came here all by yourself?"));
      say('marb', 'smile', tl("Ah well, come along. We'll search together."));
      say('marb', tl("We're looking for Cure. She has something that doesn't belong to her."));
      join_party('marb', {
        save: true,
        front: true,
        startlevel: 12
      });
    };
  }
  if (mal != null) {
    mal.interact = function(){
      if (switches.beat_game) {
        say('mal', tl("I wonder how Zika-chan is doing."));
        return;
      }
      say('mal', tl("Hello again."));
    };
  }
  if (bp != null) {
    bp.interact = function(){
      if (switches.beat_game) {
        if (switches.humanfate > 0) {
          if (scenario.childAge2()) {
            scenario.shiro();
          } else if (scenario.childAge1()) {
            say('bp', tl("Isn't she beautiful? She's growing stronger every day."));
          } else {
            say('bp', tl("I will stay here and help raise the child."));
          }
        } else {
          say('bp', tl("I will continue my research in this lab."));
        }
        return;
      }
      if (switches.progress === 'towerfall') {
        say('bp', tl("I'm searching for alternate sources of energy."));
        say('bp', tl("Most life on earth is gone now, but there are still traces."));
        say('bp', tl("If only we had a way to revive extinct species."));
        return;
      }
      say('bp', tl("Please, just do what I say."));
    };
  }
  for (i$ = 0, len$ = (ref$ = joki).length; i$ < len$; ++i$) {
    j = ref$[i$];
    if (j instanceof NPC) {
      j.interact = joki_interact;
    }
  }
  if (herpes != null) {
    herpes.interact = function(){
      herpes_chat.apply(this, arguments);
    };
  }
  if (merch != null) {
    merch.interact = function(){
      if (this.key === 'merchant2') {
        merch_agent.apply(this, arguments);
      } else {
        merch_herpes.apply(this, arguments);
      }
    };
  }
  merch_agent = function(){
    say('merch', tl("Um... can I get something for you?"));
    menu(tl("Let me browse your goods."), start_shop_menu, tl("Glass Blowing"), merch_glassblowing, tl("Gambling"), merch_gambling, tl("Nevermind"), function(){});
  };
  merch_herpes = function(){
    if (player === llov || player === ebby) {
      say('herpes', tl("Hey cutie, what brings you here?"));
    } else {
      say('herpes', tl("Do you need something?"));
    }
    menu(tl("Let me browse your goods."), start_shop_menu, tl("Glass Blowing"), herpes_glassblowing, tl("Gambling"), herpes_gambling, tl("Nevermind"), function(){});
  };
  herpes_gambling = function(){
    if (!session.gamble_rules) {
      this.say('herpes', tl("All right, here's how it works. You choose how much cumberground you want to bet, and I'll flip a coin."));
      this.say(tl("If it's heads, you win double your bet. If it's tails, I keep it all."));
      this.say(tl("Simple, right?"));
      session.gamble_rules = true;
    }
    if (!(items.cumberground.quantity > 0)) {
      return this.say('herpes', tl("Come back when you have some cumberground to gamble with."));
    }
    this.say('herpes', tl("How much cumberground will you bet?"));
    this.number(tl("Max:{0}", items.cumberground.quantity), 0, items.cumberground.quantity);
    this.say(function(){
      var bet;
      bet = dialog.number.num;
      if (!(bet > 0)) {
        return say('herpes', tl("Not feeling lucky? That's all right, come back any time."));
      }
      say(tl("Flipping the coin..."));
      if (pluckroll_gamble() > 0.5) {
        say(tl("Heads, you win! Here's your prize, {0} cumberground!", bet * 2));
        acquire(items.cumberground, bet, true, true);
      } else {
        say(tl("Tails. Sorry, you lost {0} cumberground.", bet));
        items.cumberground.quantity -= bet;
      }
      return save();
    });
  };
  merch_gambling = function(){
    if (!session.gamble_rules) {
      this.say('merch', tl("...You know the rules, right?"));
      this.say(tl("I flip a coin. Heads you win double your bet. Tails I keep everything."));
      session.gamble_rules = true;
    }
    if (!(items.cumberground.quantity > 0)) {
      return this.say('herpes', tl("...But you don't have anything to bet. Come back with some cumberground."));
    }
    this.say('merch', tl("How much cumberground will you bet?"));
    this.number(tl("Max:{0}", items.cumberground.quantity), 0, items.cumberground.quantity);
    this.say(function(){
      var bet;
      bet = dialog.number.num;
      if (!(bet > 0)) {
        return say('merch', tl("...That's okay."));
      }
      say(tl("Flipping the coin..."));
      if (pluckroll_gamble() > 0.5) {
        say(tl("Heads. You win {0} cumberground.", bet * 2));
        acquire(items.cumberground, bet, true, true);
      } else {
        say(tl("Sorry, it's tails. You lose {0} cumberground.", bet));
        items.cumberground.quantity -= bet;
      }
      return save();
    });
  };
  herpes_glassblowing = function(){
    var q, ref$, ref1$;
    this.say('herpes', tl("I can turn your glass shards into glass vials. It will also cost one cumberground each."));
    if (!(items.shards.quantity > 0 && items.cumberground.quantity > 0)) {
      return;
    }
    this.say(tl("How many vials should I make?"));
    q = (ref$ = items.cumberground.quantity) < (ref1$ = items.shards.quantity) ? ref$ : ref1$;
    this.number(tl("Max:{0}", q), 0, q);
    this.say(function(){
      var q;
      q = dialog.number.num;
      if (!(q > 0)) {
        return say('herpes', tl("Come back any time."));
      }
      items.cumberground.quantity -= q;
      exchange(q, items.shards, items.vial);
      return say('', tl("Acquired {0} {1}!", stattext(q, 5), items.vial.name));
    });
  };
  merch_glassblowing = function(){
    var q, ref$, ref1$;
    this.say('merch', tl("One cumberground and one glass shard makes one vial."));
    if (!(items.shards.quantity > 0 && items.cumberground.quantity > 0)) {
      return;
    }
    this.say(tl("...How many do you need?"));
    q = (ref$ = items.cumberground.quantity) < (ref1$ = items.shards.quantity) ? ref$ : ref1$;
    this.number(tl("Max:{0}", q), 0, q);
    this.say(function(){
      var q;
      q = dialog.number.num;
      if (!(q > 0)) {
        return say('merch', tl("...That's okay."));
      }
      items.cumberground.quantity -= q;
      exchange(q, items.shards, items.vial);
      return say('', tl("Acquired {0} {1}!", stattext(q, 5), items.vial.name));
    });
  };
  herpes_intro = function(){};
  herpes_chat = function(){
    say('herpes', tl("Since my agents will run my shops for me, I can just take it easy."));
  };
  if ((ref$ = Actor.wraith) != null) {
    ref$.interact = function(){
      say('wraith', tl("The tower is off-limits. Ebola-chan is not taking visitors at the moment."));
      /*
      say \wraith "The tower is off-limits to all but the goddess."
      menu "Who are you?" ->
          @say "In life we were the followers of our goddess. In death we are her servants and protectors."
      , "Who is the goddess?" ->
          @say "She who kills and is thanked for it. Our master is the one who brought mankind to its knees."
          @say "She is our savior and our reaper. The one who saved the world by destroying it."
      , "What is this tower?" ->
          @say "This tower was created by the will of our goddess."
          @say "There are many who seek to steal her power, and this tower serves to house and protect her."
      , "Why is the tower off-limits?" ->
          @say "Because our goddess wills it to be. Family, friends, or otherwise. None are to enter the tower."
      */
    };
  }
  if (leps != null) {
    leps.interact = function(){
      if (!(Date.now() - switches.lepsy_timer < 43200000)) {
        if (session.beat_lepsy || switches.beat_game) {
          say('leps', tl("Hey friend, are you here for another show?"));
        } else {
          say('leps', tl("Hey friend, what brings you here? Let's put on a show!"));
        }
        say('leps', tl("★SEIZURE WARNING★ This battle may trigger seizures. Continue at your own risk."));
        menu(tl("Continue"), function(){
          say('leps', tl("All right! Let me see you dance!"));
          return say(function(){
            return start_battle(encounter.lepsy);
          });
        }, tl("Abort"), function(){
          say('leps', tl("Well thanks for dropping by."));
          if (switches.progress2 < 9) {
            return say('leps', "If you're looking for Cure-chan, I saw her skulking around northwest of here.");
          }
        });
      } else {
        say('leps', tl("Hey, thanks for dropping by."));
        if (switches.progress2 < 9) {
          say('leps', "If you're looking for Cure-chan, I saw her skulking around northwest of here.");
        }
      }
    };
  }
  if (parvo != null) {
    parvo.interact = function(){
      if (!(Date.now() - switches.parvo_timer < 43200000)) {
        say('parvo', tl("...Oh, it's you. I don't get many visitors down here."));
        say('parvo', tl("Did you come to play?"));
        menu(tl("Yes"), function(){
          return start_battle(encounter.parvo);
        }, tl("No"), function(){
          return say('parvo', tl("...Oh."));
        });
      } else {
        say('parvo', tl("Thanks for playing with me... It was fun."));
      }
    };
  }
  if (pox != null) {
    pox.interact = function(){
      if (switches.beat_game) {
        say('pox', tl("It's kind of cold out here isn't it?"));
        return;
      }
      if (!switches.soulcluster) {
        say('pox', tl("Who turned out the lights?"));
      } else {
        say('pox', tl("Hey, the light's on!"));
      }
    };
  }
  if (zmapp != null) {
    zmapp.interact = function(){
      if (switches.curefate) {
        say('zmapp', tl("I'm surprised you decided to let us live. You know I wouldn't do the same for you, right?"));
        say('marb', tl("You're lucky. If it were up to me, you'd be dead now."));
        say('zmapp', tl("Why did you spare us anyway?"));
        say('ebby', tl("{0} told me it was the right thing to do.", switches.name));
        return;
      }
    };
  }
  if (cure != null) {
    cure.interact = function(){
      if (switches.curefate) {
        say('cure', tl("We're definitely not working on another scheme. Don't worry about it!"));
        say('cure', tl("By the way, can you let me see that skull of yours again? I promise I won't do anything funny."));
        say('ebby', 'concern', tl("I don't trust you..."));
        return;
      }
      if (in$(marb, party)) {
        say('cure', tl("You're finally here, Marburg. I was getting tired of waiting for you."));
        say('cure', tl("How nice, you even brought your sister with you. Now I can cure both of you."));
        say('marb', tl("Llov, are you ready? It's time to deliver divine punishment."));
        say(function(){
          return start_battle(encounter.cure);
        });
      } else {
        say('cure', tl("What's a cute little virus like you doing out here all alone?"));
        if (switches.ate_nae !== 'llov') {
          say(tl("Are you all right? You seem ill. I see the destruction hasn't been kind to you."));
        }
        say(tl("Don't worry, I will cure you."));
        say(function(){
          return start_battle(encounter.cure_single);
        });
      }
    };
  }
  if (ammit != null) {
    ammit.interact = function(){
      var itemlist;
      say('ammit', tl("Love and Justice, friend."));
      if (!(Date.now() - switches.ammitgift < 3600000)) {
        say('ammit', tl("This washed up earlier. You can have it."));
        itemlist = [items.starpuff, items.bleach, items.lifecrystal, items.bandage, items.blistercream, items.teleport, items.plaguescroll, items.slowscroll, items.swarmscroll, items.ex2, items.sp2, items.hp2];
        acquire(itemlist[Math.random() * itemlist.length | 0], Math.min(5, Math.ceil((Date.now() - switches.ammitgift) / 10800000)) || 5, false, true);
        switches.ammitgift = Date.now();
        save();
      }
    };
  }
  if ((ref1$ = aids[2]) != null) {
    ref1$.interact = function(){
      dialog.port.mad = true;
      music.fadeOut(1000);
      say('aids2', tl("Look brother, some filthy insects have come to our doorstep."));
      say('aids1', tl("I wonder what they want?"));
      say('aids2', tl("No doubt they're here to impede our pure love."));
      aidstalk();
    };
  }
  if ((ref2$ = aids[1]) != null) {
    ref2$.interact = function(){
      dialog.port.mad = true;
      music.fadeOut(1000);
      say('aids1', tl("Nee-chan look, we have visitors."));
      say('aids2', tl("Filthy insects. Go away, you're impeding our pure love."));
      aidstalk();
    };
  }
  function aidstalk(){
    say('ebby', tl("We want to help you. Can you come with us?"));
    say('aids1', tl("Insect? Is that your name? I can't come with you. Onee-chan told me to never follow strangers."));
    say('aids2', tl("Good girl, I'll have to reward you later."));
    if (in$(llov, party)) {
      say('llov', tl("They don't even recognize us..."));
    }
    say(function(){
      return dialog.port.mad = 10;
    });
    say('aids2', tl("Now get out of here you insects, before I stomp you out of existance!"));
    say('marb', tl("There's no talking sense into them. They've gone maverick. We have to fight."));
    say(function(){
      dialog.port.mad = false;
      return start_battle(encounter.aids);
    });
  }
  if ((ref3$ = aids[0]) != null) {
    ref3$.interact = function(){
      say('aids1', 'fused', tl("Are you wondering why we're off on our own, away from everyone else?"));
      say('aids2', 'fused', tl("Don't be silly. You know why."));
    };
  }
  if (rab != null) {
    rab.interact = function(){
      if (switches.beat_game) {
        say('rab', 'young', tl("I wonder what all this cold white stuff is. I've never seen it before."));
        menu(tl("Tell her it's water"), function(){
          say(player.name, tl("It's water."));
          say('rab', 'young', tl("Don't be silly, I know it's not water."));
        }, tl("Say nothing."), function(){
          say(player.name, tl("..."));
        });
        return;
      }
      dialog.port.mad = true;
      music.fadeOut(1000);
      say('rab', tl("My, you look tasty."));
      if (in$(llov, party)) {
        say('llov', tl("Why are you saying? Don't you remember us?"));
        say('rab', tl("I think I would remember seeing such a tasty piece of meat."));
      }
      say('ebby', 'concern', tl("We need to take you somewhere. Will you follow us?"));
      say(function(){
        return dialog.port.mad = 8;
      });
      say('rab', tl("Oh, you're not going anywhere. 'cept in my stomach."));
      say('marb', 'angry', tl("All you're going to be eating is your own words."));
      say(function(){
        dialog.port.mad = false;
        return start_battle(encounter.rabies);
      });
    };
  }
  if (sars != null) {
    sars.interact = function(){
      if (switches.beat_game) {
        say('sars', tl("Wasn't there supposed to be a visual novel or something? What happened to that?"));
        return;
      }
      dialog.port.mad = true;
      music.fadeOut(1000);
      if (in$(llov, party)) {
        say('llov', tl("Sars-chan, do you remember me? We used to be roommates."));
      } else {
        say('ebby', tl("Sars-chan? Do you have a moment?"));
      }
      say('sars', tl("Can you please not breathe the same air as me? It's major gross yo."));
      say('ebby', tl("Please, we want to help you."));
      say(function(){
        return dialog.port.mad = 3;
      });
      say('sars', tl("Who you callin' a pipsqueak, eh? Do you want to stop breathing?"));
      say('marb', tl("Nobody called you short yet, little bug."));
      say(function(){
        return dialog.port.mad = 12;
      });
      say('sars', tl("That's it! I'll make sure you never take another breath again!"));
      say(function(){
        dialog.port.mad = false;
        return start_battle(encounter.sars);
      });
    };
  }
  if (switches.beat_game && nae) {
    nae.interact = function(){
      say('nae', tl("Were you looking for a voluptuous slime girl? You found her."));
    };
  }
  if (switches.map === 'delta' && switches.beat_aids && switches.soulcluster) {
    zika = new NPC(nodes.aids2.x, nodes.aids2.y + TS, 'zika');
    zika.face('down');
    zika.interact = function(){
      if (!(Date.now() - switches.zika_timer < 43200000)) {
        if (switches.beat_zika) {
          say('zika', tl("Hey sweetie. You here for another battle?"));
        } else {
          say('zika', tl("If you can beat me, I'll give you something special.  What do you say?"));
        }
        menu(tl("Yes"), function(){
          return start_battle(encounter.zika);
        }, tl("No"), function(){
          return this.say('zika', tl("Another time, then."));
        });
      } else {
        say('zika', tl("The view is nice from here. I can almost see the end of the river."));
      }
    };
  }
  switch (switches.progress) {
  case 'curebeat':
  case 'zmappbattle':
    scenario.states.returnfromdeadworld();
    break;
  case 'zmappbeat':
    scenario.states.zmappbeat();
    break;
  case 'towerfall':
    scenario.states.towerfall();
    break;
  case 'endgame':
    scenario.states.endgame();
    break;
  default:
    ss = scenario.states.tutorial;
    if (switches.sleepytime) {
      ss = scenario.states.slimes_everywhere;
    }
    if (switches.pylonfixed) {
      ss = scenario.states.pylonfixed;
    }
    ss();
  }
  if (switches.map === 'towertop' && !switches.soulcluster && switches.progress2 >= 16) {
    scenario.soulcluster();
  }
  scenario.always();
  for (i$ = 0, len$ = (ref4$ = scenario_mod).length; i$ < len$; ++i$) {
    f = ref4$[i$];
    if (typeof f == 'function') {
      f();
    }
  }
}
/*
!function joki_guidance
    #Joki will remind you what you should be doing
    say \joki "TODO"
*/
function joki_interact(){
  var args;
  say('joki', tl("Can I help you with anything?"));
  args = [
    tl("Black Water"), function(){
      var q, ref$, ref1$;
      this.say('joki', tl("I can fill your vials with Black Water for you. It will cost 1 cumberground each."));
      if (items.vial.quantity > 0 && items.cumberground.quantity > 0) {
        this.say('joki', tl("How many vials should I fill?"));
        q = (ref$ = items.cumberground.quantity) < (ref1$ = items.vial.quantity) ? ref$ : ref1$;
        this.number(tl("Max:{0}", q), 0, q);
        return this.say(function(){
          var q;
          q = dialog.number.num;
          if (!(q > 0)) {
            return say('joki', tl("You don't want any?"));
          }
          items.cumberground.quantity -= q;
          exchange(q, items.vial, items.tuonen);
          return say('', tl("Acquired {0} {1}!", stattext(q, 5), items.tuonen.name));
        });
      }
    }, tl("Help"), function(){
      this.say('joki', tl("If there's anything you'd like to know, I can certainly help."));
      return this.menu(tl("Skills"), function(){
        this.say('joki', tl("Even if you know more skills, you can only use 5 of them in combat."));
        this.say(tl("Use the skills menu to choose which 5 skills you want to use in combat."));
        return this.say(tl("It might be smart to reconsider your active skills before each major battle."));
      }, tl("Crafting"), function(){
        this.say('joki', tl("You can craft items in your inventory to create more useful items, such as potions."));
        this.say('joki', tl("You should experiment with different recipes. Even if you don't make something useful, you can sell the cumberground you get."));
        this.say('joki', tl("Cumberground is a byproduct of failed recipes, and can be used as a currency."));
        return this.say('joki', tl("Most reagents are dropped by enemies, but you can also harvest them from trees or flowers."));
      }, tl("Excel"), function(){
        return this.say('joki', tl("Excel is a power that lets you accelerate evolution. It grants you new strength and abilites during battle."));
      }, tl("Travel"), function(){
        this.say('joki', tl("The waters here in the Tuonen are a bit hazardous, so travel can be difficult."));
        this.say(tl("Luckily, it's my job to help transport people such as you between the various realms."));
        this.say(tl("Alternatively you can use Portal Scrolls to travel on your own. They are made by inscribing Grave Dust upon parchment."));
        this.say(tl("Parchment can be made by combining any two of cloth, fur, or plant fiber together."));
        if (!switches.jokigavescrolls) {
          this.say(tl("Here's a free sample."));
          switches.jokigavescrolls = true;
          return acquire.call(this, items.teleport, 5);
        }
      }, tl("Nevermind"), function(){});
    }
  ];
  if (switches.warpzones) {
    args.push(tl("Transport"), function(){
      var args, i$, ref$, len$, w;
      this.say('joki', tl("Where do you want to go?"));
      args = [tl("Nevermind"), function(){}];
      for (i$ = 0, len$ = (ref$ = warpzones).length; i$ < len$; ++i$) {
        w = ref$[i$];
        if (switches["warp_" + w.id]) {
          args.push(w.name, {
            callback: warp_node,
            arguments: [w.map, w.node, w.dir]
          });
        }
      }
      return this.menu.apply(this, args);
    });
  }
  args.push(tl("Nevermind"), function(){});
  menu.apply(this, args);
  show();
}
function cinema_start(){
  var i$, ref$, len$, actor;
  switches.cinema2 = true;
  for (i$ = 0, len$ = (ref$ = actors.children).length; i$ < len$; ++i$) {
    actor = ref$[i$];
    if (typeof actor.cancel_movement == 'function') {
      actor.cancel_movement();
    }
  }
}
function cinema_stop(){
  switches.cinema2 = false;
}
function set_cinema(state){
  if (state) {
    cinema_start();
  } else {
    cinema_stop();
  }
}
scenario = {};
scenario.states = {};
scenario_mod = [];
scenario.always = function(){
  var dood;
  if (temp.nae_reward) {
    temp.nae_reward = false;
    if (!in$(skills.poisonstrike, skillbook.all)) {
      say('nae', tl("You really are strong. How about I teach you something?"));
      learn_skill('poisonstrike');
    }
  }
  if (temp.leps_reward) {
    temp.leps_reward = false;
    if (!in$(skills.seizure, skillbook.all)) {
      say('leps', tl("That was a great show! Let me show my appreciation."));
      learn_skill('seizure');
    }
  }
  if (temp.parvo_reward) {
    temp.parvo_reward = false;
    if (!in$(skills.lovetap, skillbook.all)) {
      say('parvo', tl("That was fun! let's play again some time."));
      learn_skill('lovetap');
    }
  }
  if (temp.zika_reward) {
    temp.zika_reward = false;
    if (items.shrunkenhead.quantity === 0) {
      say('zika', tl("As promised, here's your reward."));
      acquire(items.shrunkenhead);
    }
  }
  if (switches.map === 'deadworld' && switches.famine) {
    dood = carpet.addChild(
    new Doodad(nodes.secretcave.x, nodes.secretcave.y, 'jungle_tiles', null, false));
    dood.crop(new Phaser.Rectangle(TS * 5, TS * 13, TS, TS));
  }
  if (switches.map === 'delta' && switches.revivalllov && !in$(llov, party)) {
    scenario.revivalllov();
  }
};
scenario.game_start = function(){
  var i$, ref$, len$, member;
  solidscreen.alpha = 1;
  for (i$ = 0, len$ = (ref$ = party).length; i$ < len$; ++i$) {
    member = ref$[i$];
    member.visible = false;
  }
  cinema_start();
  marb.start_location();
  marb.revive();
  marb.face('left');
  music.stop();
  switches.nomusic = true;
  switches.llovsick = true;
};
scenario.game_start[0] = function(){
  dialog.textentry.show(13, tl("What is your name?"), function(m){
    if (!m) {
      return scenario.game_start[0]();
    }
    switches.name = m.trim();
    items.humanskull2.name = switches.name;
    say('', tl("Your name is {0}?", switches.name));
    menu(tl("Yes"), function(){
      return scenario.game_start[0][1]();
    }, tl("No"), function(){
      return scenario.game_start[0]();
    });
  });
};
scenario.game_start[0][1] = function(){
  if (getFiles()[switches.name]) {
    say('', tl("A save file already exists. The new game cannot be saved without overwriting the existing save file."));
    menu(tl("Continue without saving"), function(){
      return switches.nosave = true;
    }, tl("Delete save file"), function(){});
  }
  say(function(){
    return Transition.fade(500, 1000, function(){
      solidscreen.alpha = 0;
      camera_center(player.x + 4 * TS, player.y);
      return switches.nomusic = false;
    }, scenario.game_start[1], 15, false);
  });
};
scenario.game_start[1] = function(){
  /*
  say \mal "How is she?"
  say \marb "It's not getting worse, but it's not getting better either."
  say \mal "What about Ebola-chan?"
  say \marb "She's still in the tower. I'm told she's had something important taken from her, and that's why she locked herself in."
  say \mal "What will you do?"
  say \marb "What else can I do? I'm going to get it back."
  say \mal "Do you even know what you're looking for?"
  say \marb "It's in the land of the dead. Aside from that... Well, I think Joki knows more than she's letting on."
  */
  say('marb', tl("Llov, are you awake?"));
  say('marb', tl("I'm sorry, I would love nothing more than to stay by your side..."));
  say('marb', tl("But I must go. Don't worry, I'll be back before you realize."));
  say(tl("Plague and Malaria will be here to take care of you. Go to them if you need anything."));
  marb.move(0, 1.5);
  marb.move(2, 0);
  marb.move(0, 1);
  marb.path.push(function(){
    marb.kill();
    return setTimeout(function(){
      return Transition.wiggle(doodads.llovbed, 4, 300, 1, function(){
        return setTimeout(function(){
          return getoutofbed();
        }, 100);
      });
    }, 1400);
  });
  function getoutofbed(){
    doodads.llovbed.animations.frame = 1;
    say('llov', 'sick', tl("Marburg-nee... Llov wants to go too."));
    say(function(){
      var i$, ref$, len$, member;
      doodads.llovbed.alpha = 0;
      for (i$ = 0, len$ = (ref$ = party).length; i$ < len$; ++i$) {
        member = ref$[i$];
        member.visible = true;
      }
      player.face('right');
      cinema_stop();
      return setswitch('started', true);
    });
  }
};
scenario.states.tutorial = function(){
  var ref$, ref1$, jokioverride, ref2$, ref3$, llovbedinteract, ref4$, ref5$;
  if (switches.map === 'hub') {
    if ((ref$ = joki[1]) != null) {
      ref$.relocate('joki_bridge');
    }
    if ((ref1$ = joki[1]) != null) {
      ref1$.face('left');
    }
  }
  if (mal != null) {
    mal.interact = function(){
      if (switches.gotmedicine && switches.askaboutmarb) {
        if (!switches.llovmedicine) {
          say('mal', tl("Is that the medicine Plague-sama gave you?"));
          say('mal', tl("Plague-sama is a doctor, so you should listen to what she says."));
        } else {
          say('mal', tl("Plague-sama told you to get some rest right? Your bed is waiting right through this door."));
        }
        return;
      }
      if (!switches.talktomal) {
        say('mal', tl("Why if it isn't Lloviu-tan. Are you awake already?"));
        setswitch('talktomal', true);
      }
      if (!switches.askaboutmarb) {
        say('llov', 'sick', tl("Where is Marburg-nee?"));
        say('mal', tl("I'm afraid she's left already, you just missed her. I'm sure she'll be back soon, though."));
        setswitch('askaboutmarb', true);
      }
      if (!switches.gotmedicine) {
        say('mal', tl("Plague-sama told me she had something for you. You should go see her."));
      }
    };
  }
  jokioverride = (ref2$ = joki[1]) != null ? ref2$.interact : void 8;
  if ((ref3$ = joki[1]) != null) {
    ref3$.interact = function(){
      if (!switches.askjokiaboutmarb) {
        say('joki', tl("Lloviu-san, is it? What might you need?"));
        say('llov', 'sick', tl("Did Marburg-nee go this way?"));
        say('joki', tl("Not this way. I ferried her to the Land of the Dead."));
        say('llov', 'sick', tl("Can you take Llov too?"));
        say('joki', tl("Hmm, I'm afraid you wouldn't survive the journey in your condition."));
        switches.askaboutmarb = true;
        setswitch('askjokiaboutmarb', true);
      } else {
        jokioverride.apply(this, arguments);
      }
    };
  }
  if (bp != null) {
    bp.interact = function(){
      if (!switches.gotmedicine) {
        say('bp', tl("Lloviu-tan, there you are. I have something for you."));
        switches.gotmedicine = true;
        acquire(items.llovmedicine);
        say('bp', tl("This tonic should help you regain some of your strength. Try to get some rest after you take it."));
      } else if (!switches.llovmedicine) {
        say('bp', tl("What do you need?"));
        menu(tl("What is this medicine?"), function(){
          this.say(tl("The vial contains liquid vitae. It is the energy that we need to survive."));
          this.say(tl("It is secreted by living things, and can also be harvested from human souls."));
          return this.say(tl("This vitae was provided by your sister. She made this tower to harvest vitae from the souls she collected."));
        }, tl("Why am I sick?"), function(){
          this.say(tl("Put simply, your reservoir was destroyed."));
          this.say(tl("Without a reliable source of energy, you've gradually grown weak."));
          return this.say(tl("The medicine I gave you should help you regain your strength."));
        }, tl("How do I take the medicine?"), function(){
          this.say(tl("Open the pause menu by hitting the escape key or right clicking with your mouse. Then, select the \"items\" option."));
          return this.say(tl("You're a smart girl, so I think you should be able to figure out the rest on your own."));
        });
      } else {
        say('bp', tl("You drank the medicine? good. Now you should get some rest."));
      }
    };
  }
  llovbedinteract = (ref4$ = doodads.llovbed) != null ? ref4$.interact : void 8;
  if ((ref5$ = doodads.llovbed) != null) {
    ref5$.interact = function(){
      if (switches.llovmedicine && !switches.sleepytime) {
        music.fadeOut(1000);
        cinema_start();
        Transition.fade(500, 1000, function(){
          var i$, ref$, len$, member;
          switches.llovsick = false;
          setswitch('sleepytime', true);
          for (i$ = 0, len$ = (ref$ = party).length; i$ < len$; ++i$) {
            member = ref$[i$];
            member.visible = false;
          }
          doodads.llovbed.alpha = 1;
          player.start_location();
          return camera_center(player.x + 4 * TS, player.y);
        }, function(){
          return setTimeout(function(){
            sound.play('boom');
            return Transition.shake(8, 50, 1000, 0.95, function(){
              doodads.llovbed.animations.frame = 1;
              say('', tl("Something is happening outside!"));
              return say(function(){
                var i$, ref$, len$, member;
                doodads.llovbed.alpha = 0;
                for (i$ = 0, len$ = (ref$ = party).length; i$ < len$; ++i$) {
                  member = ref$[i$];
                  member.visible = true;
                }
                player.face('right');
                return cinema_stop();
              });
            }, false);
          }, 1000);
        }, 15, false);
      } else if (switches.gotmedicine && !switches.sleepytime) {
        say('llov', 'sick', tl("Not yet, I need to take the medicine first."));
      } else if (switches.sleepytime) {
        say('', tl("Can't sleep right now."));
      } else {
        llovbedinteract();
      }
    };
  }
};
scenario.states.slimes_everywhere = function(){
  var i$, ref$, len$, node, jokioverride, ref1$, ref2$, ref3$;
  if (switches.map === 'hub') {
    joki[1].relocate('joki_bridge');
    if (switches.jokistepsaside) {
      joki[1].y -= TS;
      joki[1].cancel_movement();
    }
    joki[1].face('left');
    neutral_slime(mal.x, mal.y);
    mal.shift(-TS, 0);
    mal.face('right');
    bp.face('downright');
    bp.shift(-TS, -TS);
    neutral_slime(bp.x, bp.y + TS);
    neutral_slime(bp.x + TS, bp.y);
    for (i$ = 0, len$ = (ref$ = [nodes.mob1, nodes.mob2, nodes.mob3, nodes.mob4, nodes.mob5, nodes.mob6]).length; i$ < len$; ++i$) {
      node = ref$[i$];
      neutral_slime(node.x, node.y + TS);
    }
  }
  if (mal != null) {
    mal.interact = function(){
      say('mal', tl("Please, just go inside. We can handle this."));
      say(tl("If something were to happen to you, Marburg would..."));
      say(function(){
        return mal.face('right');
      });
    };
  }
  if (bp != null) {
    bp.interact = function(){
      if (!session.talktobp) {
        say('bp', tl("Damn, they're everywhere."));
        say('llov', tl("What can Llov do to help?"));
        say('bp', tl("Listen, I know you're feeling better, but you're still ill."));
        say('bp', tl("Go back inside and rest."));
        session.talktobp = 1;
      } else {
        say('bp', tl("Didn't you hear me? Go and hide. It's not safe out here."));
      }
      say(function(){
        return bp.face('downright');
      });
    };
  }
  function neutral_slime(x, y){
    var slime;
    slime = new NPC(x, y, 'mob_slime', Math.random() * 2 + 5);
    slime.setautoplay('simple');
    slime.interact = function(){
      say('Slime', tl("Wub wub wub..."));
      say('llov', 'scared', tl("...!"));
    };
  }
  if ((ref$ = doodads.llovbed) != null) {
    ref$.interact = function(){
      say('', tl("Can't sleep right now."));
    };
  }
  jokioverride = (ref1$ = joki[1]) != null ? ref1$.interact : void 8;
  if ((ref2$ = joki[1]) != null) {
    ref2$.interact = function(){
      if (switches.jokistepsaside) {
        say('joki', tl("Find Smallpox. She can fix the pylon."));
        jokioverride.apply(this, arguments);
        return;
      }
      if (!switches.whatcanllovdotohelp) {
        say('joki', tl("Lloviu-san, such a pleasure."));
        say('llov', tl("What happened?"));
        say('joki', tl("One of the pylons that protect this area was damaged."));
        say('llov', tl("What can Llov do to help?"));
      } else {
        say('llov', tl("Llov wants to help after all!"));
      }
      setswitch('whatcanllovdotohelp', true);
      say('joki', tl("It will be dangerous. Are you sure?"));
      menu('Yes', function(){
        this.say('joki', tl("Smallpox built the pylons. she can fix them. Find her."));
        this.say('joki', tl("Remember, you are the sister of Marburg and Ebola. You are stronger than you think."));
        this.say('joki', tl("Go now, cross this bridge. Have no fear, I am already waiting for you on the other side."));
        return this.say(function(){
          setswitch('jokistepsaside', true);
          joki[1].move(0, -1);
          return joki[1].path.push(function(){
            return joki[1].face('left');
          });
        });
      }, 'No', function(){
        return this.say('joki', tl("Understandable."));
      });
    };
  }
  if ((ref3$ = joki[2]) != null) {
    ref3$.interact = function(){
      if (!switches.beat_nae) {
        say('joki', tl("Smallpox should be in this cabin, but there's a problem."));
        say('joki', tl("The person standing in front of the door. Do you recognize her?"));
        say('joki', tl("It's Naegleria, and it looks like she's gone mad."));
        say('joki', tl("We have no choice but to put her down. I can't take her on my own though, not with this body."));
        if (items.shinai.quantity < 1) {
          say('joki', tl("I left a kendo stick in one of the houses near the tower."));
        }
        say('joki', tl("If you're going to fight her, be careful."));
      } else {
        jokioverride.apply(this, arguments);
      }
    };
  }
  if (pox != null) {
    pox.interact = function(){
      if (switches.pylonfixed) {
        say('pox', 'injured', tl("Hurry on back to the tower. I'll be going there soon too."));
        return;
      }
      say('pox', 'injured', tl("Lloviu-nya, what are you doing are you here?"));
      say('llov', tl("You're hurt! What happened?"));
      say('pox', 'injured', tl("I was trying to fix the pylon... when I was ambushed by an old friend."));
      say('pox', tl("What happened to her anyway? Naeglera."));
      if (switches.ate_nae) {
        say('llov', tl("Nae-tan? Llov ate her."));
        say('pox', 'injured', tl("You ate her? I hope you don't get a stomach ache."));
      } else {
        say('llov', tl("Nae-tan is... Llov had no choice."));
        say('pox', 'injured', tl("I see, that's unfortunate. She used to be such a good friend."));
      }
      say('pox', 'injured', tl("Well, at least now I can get back to fixing the pylon."));
      say('pox', 'injured', tl("After I'm done, I hope you won't mind if I borrow your bed. I need some time to recover."));
      say(function(){
        switches.checkpoint_map = 'hub';
        switches.checkpoint = 'nae';
        switches.lockportals = true;
        return setswitch('pylonfixed', true);
      });
    };
  }
  if (switches.map === 'hub' && !switches.slimes_everywhere) {
    scenario.slimes_everywhere();
    setswitch('slimes_everywhere', true);
  }
  if (switches.map === 'hub' && switches.beat_nae && !switches.beat_nae2) {
    scenario.beat_nae();
    setswitch('beat_nae2', true);
  }
};
scenario.slimes_everywhere = function(){
  player.face_point(mal);
  mal.face('left');
  say('mal', tl("Lloviu! Don't come out, it's dangerous right now!"));
  say(function(){
    return mal.face('right');
  });
};
scenario.beat_nae = function(){
  cinema_start();
  player.relocate('nae');
  joki[2].move(0, 4);
  joki[2].move(-5, 0);
  joki[2].path.push(function(){
    player.face_point(joki[2]);
    say('joki', tl("You beat her? Good. I knew you had it in you."));
    say('joki', tl("You got a soul for beating her right? If you hang on to it, she can probably be saved."));
    say('joki', tl("I'll let you decide what to do with it, we have more urgent matters at hand."));
    return say(function(){
      return cinema_stop();
    });
  });
};
scenario.states.pylonfixed = function(){
  var jokioverride, ref$, ref1$;
  if (switches.map === 'hub') {
    joki[1].relocate('joki_bridge');
    joki[1].y -= TS;
    joki[1].cancel_movement();
    joki[1].face('left');
    if (!(switches.pylonfixed >= 2)) {
      joki[2].relocate('pox_cabin');
      joki[2].x += TS;
      joki[2].y += TS;
      joki[2].cancel_movement();
      joki[2].face('left');
      player.face('right');
      say('joki', tl("Good job, it looks like the pylon is already operational again."));
      say('llov', tl("Llov wants to find Marburg-nee"));
      say('joki', tl("I took Marburg to the land of the dead by her request."));
      say('joki', tl("You seem like you've recovered your strength. All right, I'll take you to her."));
      say('joki', tl("Meet me back at the docks near the tower."));
      say(function(){
        return setswitch('pylonfixed', 2);
      });
    }
    if (switches.confronting_joki) {
      scenario.spawn_minion_bridge();
    }
  }
  if (!switches.confronting_joki && switches.map === 'hub') {
    bp.relocate('joki_bridge');
    bp.y -= TS;
    bp.x -= TS * 3;
    bp.cancel_movement();
  }
  if (switches.confronting_joki && switches.map === 'hub') {
    joki[1].kill();
    Actor.prototype.relocate.call(Doodad.boat, 'boat2');
  }
  scenario.poxbed();
  if (pox != null) {
    pox.interact = function(){
      say('pox', 'injured', tl("Hurry on back to the tower. I'll be going there soon too."));
    };
  }
  jokioverride = (ref$ = joki[1]) != null ? ref$.interact : void 8;
  if ((ref1$ = joki[2]) != null) {
    ref1$.interact = function(){
      if (switches.map === 'deadworld' || in$(marb, party)) {
        jokioverride.apply(this, arguments);
        return;
      }
      if (!switches.confronting_joki) {
        say('joki', tl("Meet me back at the docks near the tower."));
        return;
      }
      if (!(switches.confronting_joki >= 2)) {
        say('joki', tl("Sorry about that, it seems I was killed."));
        say('joki', tl("I can still take you to Marburg if you want. Are you ready?"));
        setswitch('confronting_joki', 2);
      } else {
        say('joki', tl("You'll find Marburg in the land of the dead. Want me to take you there?"));
      }
      menu(tl("Yes"), function(){
        warp_node('deadworld', 'landing', 'up');
        switches.warpzones = true;
        switches.warp_deadworld = true;
        switches.warp_hub2 = true;
        return save();
      }, tl("No"), function(){});
    };
  }
  if (bp != null) {
    bp.interact = function(){
      if (in$(marb, party)) {
        if (switches.bp_has_nae) {
          scenario.bp_nae_soul2();
          return;
        }
        if (player === marb) {
          say('bp', tl("Marburg, did you find what you're looking for?"));
        } else {
          say('bp', tl("I don't know how you slipped away, but Marburg doesn't seem angry so I suppose it's fine."));
        }
        return;
      }
      if (items.naesoul.quantity > 0) {
        scenario.bp_nae_soul();
        if (items.tunnel_key.quantity < 1) {
          say('bp', tl("By the way, Smallpox came by earlier. You should greet her."));
          say('bp', tl("She's waiting for you in your house."));
        }
        return;
      }
      if (items.tunnel_key.quantity < 1) {
        say('bp', tl("Have you greeted Smallpox yet? She's waiting for you in your house."));
        return;
      }
      if (!session.pylonfixedbp || Math.random() < 0.7) {
        say('llov', tl("Let Llov go to Marburg-nee."));
        say('bp', tl("I'm keeping you here for your own good. Don't you understand?"));
        say('llov', tl("The one who doesn't understand is Plague-sama!"));
        session.pylonfixedbp = true;
        return;
      }
      say('bp', tl("Please, just stay put until Marburg gets back."));
      say('llov', tl("But... Llov wants to go help Marburg-nee."));
      say('bp', tl("Why won't you understand?"));
    };
  }
  if (mal != null) {
    mal.interact = function(){
      if (in$(marb, party)) {
        if (player === marb) {
          say('mal', tl("Marburg! You're back already?"));
        } else {
          say('mal', tl("Oh good, I see you found Marburg."));
        }
        return;
      }
      if (!(switches.talktomal >= 2)) {
        if (items.tunnel_key.quantity < 1) {
          say('mal', tl("Smallpox came by earlier. She's resting in your bed now."));
        }
        say('mal', tl("We really were worried about you, you know?"));
        say('llov', tl("Because you were told to protect Llov?"));
        say('mal', tl("Well, that's also true, but we're friends right? I'd protect you even if I wasn't ordered to."));
        say('llov', tl("Then come with Llov."));
        say('mal', tl("I don't know, that sounds dangerous. You should just do what Plague-sama tells you."));
        say(function(){
          return setswitch('talktomal', 2);
        });
        return;
      }
      if (!(switches.talktomal >= 3)) {
        say('mal', tl("You're really not going to listen to us are you? You always were so stubborn..."));
        say(tl("Since there's nothing I can do to stop you, at least take this."));
        say(function(){
          acquire(items.fan, 1, false, true);
          return setswitch('talktomal', 3);
        });
        return;
      }
      if (items.tunnel_key.quantity < 1) {
        say('mal', tl("I think Smallpox wants to talk with you. She's inside here."));
      } else {
        say('mal', tl("Please don't be reckless."));
      }
    };
  }
};
scenario.tunneldoorlocked = function(){
  say('', tl("The door is locked."));
  if (switches.pylonfixed) {
    say('llov', tl("Smallpox's maintenance tunnel..."));
    say('llov', tl("If Llov could get in here, then Llov could go where Marburg-nee is!"));
    say('llov', tl("Smallpox should be in Llov's bed right now."));
  }
  player.move(0, 0.5);
};
scenario.poxbed = function(){
  if (switches.map === 'shack2') {
    doodads.llovbed.alpha = 1;
    doodads.llovbed.loadTexture('poxsick');
    doodads.llovbed.interact = function(){
      doodads.llovbed.animations.frame = 1;
      if (player === llov) {
        say('pox', tl("Oh, Lloviu-nya. Thanks again for lending me your bed."));
      } else {
        say('pox', tl("Don't mind me, I'll be recovered soon."));
      }
      if (!items.tunnel_key.quantity) {
        say('llov', tl("Llov needs to find Joki-tan."));
        say('pox', tl("Joki? Doesn't she just hang around everywhere? I think I saw one of her outside the cabin where you found me."));
        say('llov', tl("The bridge is blocked, Llov can't get there."));
        say('pox', tl("I guess you'll need to find another way then. Here, take this."));
        switches.lockportals = false;
        acquire(items.tunnel_key);
        say('pox', tl("This key opens up the maintenance tunnel. The entrance is in a building to the south. It should take you where you need to go."));
      }
      say(function(){
        return doodads.llovbed.animations.frame = 0;
      });
    };
  }
};
scenario.spawn_minion_bridge = function(){
  var min, dood;
  if (in$(marb, party)) {
    return;
  }
  min = new_npc(nodes.confronting_joki, 'min');
  min.x += TS * 2;
  min.y += TS;
  min.cancel_movement();
  min.face('left');
  min.interact = function(){
    if (player.x > this.x) {
      sound.play('strike');
      dood.revive();
      this.kill();
      session.minionsplat = true;
      return;
    }
    say('min', tl("Order from Plague-sama. Bridge blockade."));
    say('llov', tl("Please, let Llov through."));
    say('min', tl("Cannot comply. Please speak with Plague-sama."));
  };
  dood = carpet.addChild(
  new Doodad(min.x, min.y, '1x1', null, false));
  dood.kill();
  dood.frame = 13;
  dood.anchor.set(0.5, 1);
  initUpdate(dood);
  if (session.minionsplat) {
    dood.revive();
    min.kill();
  }
  return min;
};
scenario.confronting_joki = function(){
  cinema_start();
  bp.move(2, 0);
  bp.path.push(function(){
    say('bp', tl("What were you thinking? You could have got her killed!"));
    say('joki', tl("I only did what she wished."));
    say('bp', tl("Marburg told us to keep her safe!"));
    say('joki', tl("You do not fear for the girl's safety, you only fear Marburg's wrath."));
    say('bp', tl("Enough of this. If you're going to get in our way, then you're not welcome here."));
    return say(function(){
      switches.checkpoint_map = switches.checkpoint = 'hub';
      joki[1].waterwalking = true;
      save();
      joki[1].loadTexture('joki_fireball');
      joki[1].add_simple_animation();
      joki[1].setautoplay('simple', 12);
      joki[1].move(3, 0);
      return joki[1].animations.currentAnim.onLoop.addOnce(function(){
        this.kill();
        bp.move(-3, 0);
        return bp.path.push(function(){
          var min;
          min = scenario.spawn_minion_bridge();
          Dust.summon(min.x, min.y);
          return cinema_stop();
        });
      }, joki[1]);
    });
  });
};
scenario.states.returnfromdeadworld = function(){
  var ref$, dood, i$, ref1$, len$, node, w;
  scenario.poxbed();
  if (switches.map === 'deadworld') {
    if (switches.progress2 === 9) {
      say('', tl("Cure-chan's soul escaped into the distance."));
      say('marb', tl("We got the skull, let's deliver it to Ebola-chan."));
      say(tl("She's waiting for us in the Black Tower."));
      switches.warp_hub1 = true;
      switches.warp_curecamp = true;
      setswitch('progress2', 10);
    }
  }
  if (bp != null) {
    bp.interact = function(){
      say('bp', tl("I see you found what you were looking for. Ebola-chan is probably waiting for you."));
    };
  }
  if (mal != null) {
    mal.interact = function(){
      say('mal', tl("You're going into the tower?"));
      say(tl("I know the tower is what gives us energy, but still... It's kind of spooky."));
    };
  }
  if ((ref$ = Actor.wraith) != null) {
    ref$.interact = function(){
      say('wraith', tl("The tower is off-limits. Ebola-chan is not taking visitors at the moment."));
      say('marb', tl("We have important business with Ebola-chan. Let us through."));
      say('wraith', tl("Hostility detected. Cannot comply."));
      say('llov', tl("Please mister wraith, this skull is important to Ebola-chan. Let us deliver it."));
      say('wraith', tl("Hostility detected. Cannot comply."));
      say('marb', tl("The damn creature must be broken. I don't think it'll listen to reason, we're going to have to force our way in."));
      say(function(){
        return start_battle(encounter.wraith_door);
      });
    };
  }
  if (switches.map === 'towertop' && switches.progress === 'zmappbattle') {
    dood = actors.addChild(
    new Doodad(nodes.down.x + HTS, nodes.down.y + TS, 'flameg', null, true));
    dood.anchor.set(0.5, 1.0);
    dood.simple_animation(7);
    dood.random_frame();
    updatelist.push(dood);
    if (zmapp != null) {
      zmapp.interact = function(){
        switch (switches.zmapp) {
        case -1:
          say('zmapp', tl("Still haven't had enough?"));
          break;
        default:
          say('zmapp', tl("Stay down."));
        }
        say(function(){
          return start_battle(encounter.zmapp);
        });
      };
    }
    for (i$ = 0, len$ = (ref1$ = [nodes.wraith1, nodes.wraith2, nodes.wraith3, nodes.wraith4]).length; i$ < len$; ++i$) {
      node = ref1$[i$];
      w = new NPC(node.x, node.y, 'wraith');
      w.setautoplay('down');
      w.interact = fn$;
    }
  }
  if (ebby != null) {
    ebby.interact = scenario.ebbytower1;
  }
  function fn$(){
    say('wraith', tl("Care for a battle?"));
    menu('Yes', function(){
      return start_battle(encounter.wraith);
    }, 'No', function(){});
  }
};
scenario.states.zmappbeat = function(){
  setTimeout(function(){
    var i$, ref$, len$, i, p;
    cinema_start();
    camera_center(zmapp.x, zmapp.y);
    for (i$ = 0, len$ = (ref$ = party).length; i$ < len$; ++i$) {
      i = i$;
      p = ref$[i$];
      p.y = zmapp.y - TS * 3;
      p.x = zmapp.x + (i + 1) % 3 * TS - TS;
      p.face_point(zmapp);
    }
  }, 1);
  if (switches.zmapp === 'victory') {
    say('zmapp', tl("You may have defeated me, but it's too late."));
  } else {
    say('zmapp', tl("Pathetic. Is that really all the power you can muster?"));
    say(tl("Oh well, it doesn't really matter."));
  }
  say('zmapp', tl("I've already destabilized the soul cluster."));
  say(function(){
    cg.show('cg_tower0', function(){
      Transition.timeout(1000, function(){
        cg.showfast('cg_tower1');
        switches.soulcluster = false;
        switches.progress2 = 16;
        setswitch('progress', 'towerfall');
        sound.play('boom');
        Transition.shake(8, 50, 1000, 0.95, function(){
          var i$, ref$, len$, f, newkey, oldframe;
          cg.showfast('cg_tower2');
          for (i$ = 0, len$ = (ref$ = Doodad.list).length; i$ < len$; ++i$) {
            f = ref$[i$];
            newkey = fringe_swap(f.key);
            if (f.key !== newkey) {
              oldframe = f.frame;
              f.loadTexture(newkey);
              f.frame = oldframe;
            }
          }
          tile_swap();
          Transition.timeout(1000, function(){
            cg.hide(function(){
              say('zmapp', tl("Ah, that feels better."));
              say('ebby', 'concern', tl("No way! She stole all the human souls!"));
              say('marb', 'angry', tl("That bitch! She won't get away with this!"));
              say('zmapp', tl("Now that I have what I came for, I'll be on my way. I have grand designs to fulfill."));
              say(function(){
                Dust.summon(zmapp.x, zmapp.y);
                zmapp.kill();
                return Transition.timeout(1000, function(){
                  say('marb', 'troubled', tl("She got away!"));
                  say('ebby', 'concern', tl("They're so far away now. I can hear them calling for me."));
                  say('marb', tl("Don't worry, we'll get them back."));
                  say('llov', tl("That's right! Zmapp is a bully. When we find her we'll beat her up!"));
                  say('marb', tl("Do you know where she went?"));
                  say('ebby', 'concern', tl("She only absorbed a fraction of the souls. Most of them escaped from her."));
                  say('marb', tl("We'll get those ones first. I'm sure Joki can take us where they landed."));
                  return say(function(){
                    cinema_stop();
                    return scenario.soulcluster();
                  });
                }, true);
              });
            });
          });
        }, false);
      });
    });
  });
};
scenario.bp_nae_soul = function(){
  say('bp', tl("What is that? A soul?"));
  say('llov', tl("It came out from Nae-tan"));
  say('bp', tl("Give it here. You have no business handling something so dangerous."));
  menu(tl("Give her the soul"), function(){
    items.naesoul.quantity = 0;
    setswitch('bp_has_nae', true);
    return this.say('bp', tl("Good. Now stay away from dangerous things from now on."));
  }, tl("Do not"), function(){
    return this.say('bp', tl("..."));
  });
};
scenario.bp_nae_soul2 = function(){
  say('bp', tl("Marburg, there you are."));
  say('bp', tl("I took this from Llov earlier, but I don't have any use for it."));
  say('bp', tl("I think you should decide what to do with it."));
  switches.bp_has_nae = false;
  acquire(items.naesoul);
  if (in$(llov, party)) {
    say('marb', tl("Is this Naegleria? Where did you find this?"));
    say('llov', tl("It came out of Nae-tan..."));
    say('bp', tl("From what I hear, Naegleria was taken by the madness."));
  } else {
    say('marb', tl("Is this Naegleria? I wonder where she got it from."));
    say('bp', tl("From what I hear, Naegleria was taken by the madness. Llov is the one who stopped her."));
  }
  say('marb', tl("The madness... How unsettling."));
};
scenario.ebbytower1 = function(){
  ebby.face('down');
  say('ebby', tl("Lloviu-tan, Marburg-nee! What a surprise!"));
  say('ebby', tl("What brings you here? Just visiting?"));
  say('llov', tl("We're here on a delivery!"));
  say('ebby', tl("A delivery? What did you bring?"));
  say('marb', 'smile', tl("Something lost. Can you guess what it is?"));
  say('ebby', 'smile', tl("Hold on, yes! I can sense it!"));
  say('ebby', tl("It's {0}! You brought {0} back to me!", switches.name));
  say(function(){
    items.humanskull.quantity = 0;
    return acquire(items.humanskull2, 1, true, true);
  });
  say('', tl("Marburg gave the human skull back to Ebola-chan."));
  say('ebby', 'smile', tl("Oh, thank you so much! I love both of you!"));
  say('marb', 'smile', tl("Ebola-chan just isn't complete without her signature skull, isn't that right?"));
  say('ebby', tl("I missed you so much, {0}! Cure-chan didn't do anything strange to you did she?", switches.name));
  say('ebby', 'concern', tl("Hold on, something's not right."));
  say(function(){
    return music.fadeOut(1000);
  });
  say('ebby', tl("What's that inside you?"));
  say(function(){
    var z;
    cinema_start();
    z = fringe.addChild(
    new Phaser.Sprite(game, ebby.x, ebby.y, 'z', 0));
    z.animations.add('simple', null, 7, true);
    z.animations.play('simple');
    z.anchor.set(0.5, 0.5);
    z.sx = z.x;
    z.sy = z.y;
    z.time = Date.now();
    updatelist.push(z);
    return z.update = function(){
      var i, ref$, i$, len$, p;
      i = (ref$ = (Date.now() - this.time) / 2000) < 1 ? ref$ : 1;
      this.x = this.sx + game.math.bezierInterpolation([0, -128, 0], i);
      this.y = this.sy + game.math.bezierInterpolation([0, -128, 0, 64], i);
      game.camera.center.x = this.x;
      game.camera.center.y = this.y;
      if (i === 1) {
        this.update = function(){};
        this.loadTexture('zburst');
        z.animations.add('simple', null, 7, false);
        z.animations.play('simple');
        z.animations.currentAnim.onComplete.add(function(){
          z.updatePaused = function(){
            this.destroy();
            updatelist.remove(this);
          };
          scenario.ebbytower2();
        });
        zmapp = new NPC(z.x, z.y + HTS, 'zmapp');
        zmapp.face('up');
        for (i$ = 0, len$ = (ref$ = players).length; i$ < len$; ++i$) {
          p = ref$[i$];
          p.face_point(zmapp);
        }
      }
    };
  });
};
scenario.ebbytower2 = function(){
  say('zmapp', tl("Surprise!"));
  say('zmapp', tl("A trojan horse. Pretty ironic right?"));
  say('ebby', 'shock', tl("Zmapp!? You're still alive?"));
  say('zmapp', tl("This tower belongs to me now. All the human souls here too!"));
  say(function(){
    switches.checkpoint_map = switches.map;
    switches.checkpoint = 'cp';
    switches.zmapp = 0;
    join_party('ebby', {
      save: false,
      front: true,
      startlevel: 26
    });
    equip_item(items.humanskull2, ebby, true);
    switches.progress = 'zmappbattle';
    switches.lockportals = true;
    return start_battle(encounter.zmapp);
  });
};
scenario.soulcluster = function(){
  var dood;
  if (!(switches.map === 'towertop' && !switches.soulcluster && switches.progress2 >= 16)) {
    return;
  }
  dood = actors.addChild(
  new Doodad(nodes.zmapp.x + TS, nodes.zmapp.y + TS + TS, 'flame', null, true));
  dood.anchor.set(0.5, 1.0);
  dood.simple_animation(7);
  updatelist.push(dood);
  dood.interact = function(){
    if (items.humansoul.quantity < 1000000) {
      say('', tl("1 million souls required to rekindle the soul cluster."));
    } else {
      items.humansoul.quantity -= 1000000;
      if (switches.llovsick1 > 0) {
        switches.llovsick1 = 4;
      }
      switches.soulcluster = true;
      cg.show('cg_tower2', function(){
        Transition.timeout(1000, function(){
          cg.fade('cg_tower0', function(){
            schedule_teleport({
              pmap: switches.map
            });
            Transition.timeout(1000, function(){
              cg.hide(function(){
                say('', tl("The soul cluster bursts back to life, illuminating the river."));
                scenario.delta_finished2();
              });
            });
          });
        });
      });
    }
  };
};
scenario.talk_pest = function(){
  cg.show(switches.soulcluster ? 'cg_pest' : 'cg_pest_night', function(){
    var revivalmenu, souls, menuset, i$, len$, soul;
    revivalmenu = true;
    if (switches.progress2 < 23) {
      say('pest', tl("It's been a long time. It's good to see you again."));
      say('pest', tl("As you can see, I'm not in the best of shapes. But you seem well enough."));
      say('pest', tl("Since you're here, maybe you can help me with something."));
      say('pest', tl("The viruses in this land have fallen into madness."));
      say('pest', tl("They have lost themselves. I can help them, but you must bring them to me."));
      say('pest', tl("If they won't cooperate, just bringing their souls should be enough. I can reconstitute them."));
      say('pest', tl("One more thing."));
      say('pest', tl("You cannot travel this region by land. There are no bridges to connect many of the islands."));
      say('pest', tl("You must speak to Joki. She can properly equip you."));
      say(function(){
        return setswitch('progress2', 23);
      });
    } else if (switches.progress2 < 24) {
      say('pest', tl("You must speak to Joki. She can properly equip you."));
    } else if (switches.llovsick && !in$(llov, party) && switches.llovsick1 === true) {
      say('pest', tl("Where is miss Llov? Wasn't she with you?"));
      revivalmenu = false;
    } else if (switches.llovsick1 === 2) {
      session.pestypleasehelpllov = 1;
      say('ebby', 'concern', tl("Llov is sick. Please, can you help her?"));
      say('pest', tl("It's probably just malnourishment."));
      say('pest', tl("If you provide me with human souls, I can extract the energy from them and feed it to her."));
      say('pest', tl("1000 souls should be enough. That would sustain her for quite a while."));
      if (items.humansoul.quantity >= 1000) {
        menu(tl("Feed her 1000 souls"), scenario.llovsick2, tl("Do not"), function(){});
      }
      revivalmenu = false;
    } else if (switches.llovsick1 === 3) {
      scenario.llovsick3();
      revivalmenu = false;
    } else if (switches.llovsick1 === 4 && !session.mourning && switches.progress === 'towerfall') {
      scenario.llovsick4();
      revivalmenu = false;
      session.mourning = true;
    } else if (switches.ate_sars || switches.ate_rabies || switches.ate_eidzu) {
      say('pest', tl("I asked you to help me save them, and you ate them instead."));
      say('pest', tl("If I didn't know better, I would think you were going mad too."));
    } else if (switches.revivalsars && switches.revivalsars && switches.revivalrab && !items.pest.quantity) {
      say('pest', tl("You've done what I asked. I think you deserve a reward."));
      acquire(items.pest, 1);
      say('pest', tl("This is my sword. Take good care of it."));
    } else if (switches.llovsick1 === 4) {
      say('pest', tl("I can only revive someone if I have their soul."));
    } else if (switches.beat_sars && switches.beat_rab && switches.beat_aids) {
      say('pest', tl("Thank you for helping me with this task."));
    } else {
      say('pest', tl("The viruses in this land have fallen into madness."));
      say('pest', tl("They have lost themselves. I can help them, but you must bring them to me."));
      say('pest', tl("If they won't cooperate, just bringing their souls should be enough. I can reconstitute them."));
    }
    if (revivalmenu) {
      if (items.naesoul.quantity > 0 && switches.beat_nae2 !== 2) {
        switches.beat_nae2 = 2;
        say(tl("What's this? You already have a soul with you. Is that Naegleria?"));
      }
      souls = [];
      if (items.llovsoul.quantity) {
        souls.push(items.llovsoul);
      }
      if (items.naesoul.quantity) {
        souls.push(items.naesoul);
      }
      if (items.sarssoul.quantity) {
        souls.push(items.sarssoul);
      }
      if (items.aidssoul.quantity) {
        souls.push(items.aidssoul);
      }
      if (items.rabiessoul.quantity) {
        souls.push(items.rabiessoul);
      }
      if (items.chikunsoul.quantity) {
        souls.push(items.chikunsoul);
      }
      if (souls.length > 0 && !nodes.revival.occupied) {
        say('pest', tl("Should I revive someone?"));
        menuset = [tl("Cancel"), function(){}];
        for (i$ = 0, len$ = souls.length; i$ < len$; ++i$) {
          soul = souls[i$];
          menuset.push(soul.soulname, {
            callback: revivesoul,
            arguments: [soul]
          });
        }
        menu.apply(null, menuset);
      }
    }
    return say(function(){
      cg.hide(temp.oncghide);
      if (temp.oncghide) {
        delete temp.oncghide;
      }
      return player.move(0, 0.5);
    });
  });
  function revivesoul(soul){
    soul.quantity = 0;
    switch (soul) {
    case items.naesoul:
      this.say(function(){
        setswitch('revivalnae', true);
        nae = node_npc(nodes.revival, 'naegleria', 2);
        nae.setautoplay('down');
        nae.interact = function(){
          say('nae', tl("It feels good to be myself again. Thank you."));
          say('nae', tl("I'll be around, if you need me."));
          say(warp);
        };
      });
      break;
    case items.sarssoul:
      this.say(function(){
        setswitch('revivalsars', true);
        sars.relocate('revival');
        sars.interact = function(){
          say('sars', tl("I'm sorry for my rudeness earlier. You know I treasure your friendship more than anything."));
          if (switches.revivalaids) {
            say('marb', tl("That's strange. The other ones changed after they were reconstituted, but this one looks the same."));
            say('sars', tl("I did change! I'm 1cm taller now! I swear!"));
          }
          say(warp);
        };
      });
      break;
    case items.aidssoul:
      this.say('pest', tl("Their souls have become entangled. It might be difficult to separate them..."));
      this.say(tl("Oh well, I'm sure it will be fine."));
      this.say(function(){
        setswitch('revivalaids', true);
        aids[0] = node_npc(nodes.revival, 'aids3');
        aids[0].interact = function(){
          say('aids1', 'fused', tl("Onee-chan and I are stuck together. What happened?"));
          say('aids2', 'fused', tl("Don't worry, this just means we'll be together forever."));
          say('aids1', 'fused', tl("Onee-chan... I think I could get used to this."));
          say(warp);
        };
      });
      break;
    case items.rabiessoul:
      this.say(function(){
        setswitch('revivalrab', true);
        rab.relocate('revival');
        rab.interact = function(){
          say('rab', 'young', tl("I do know what Pestilence did, but it worked wonders. I feel so young!"));
          say(tl("Most of my clothes don't seem to fit any more though. Did I lose weight?"));
          say(tl("Here, you can have this."));
          acquire(items.torndress, 1);
          say('rab', 'young', tl("Now if you'll excuse me, I'm going to find something to eat."));
          say(warp);
        };
      });
      break;
    case items.chikunsoul:
      this.say(function(){
        var chikun;
        setswitch('revivalchikun', true);
        chikun = node_npc(nodes.revival, 'chikun');
        chikun.interact = function(){
          say('chikun', tl("Resurrecting me was a mistake, you know."));
          say('chikun', tl("Do you think I only killed them because I was mad?"));
          say('chikun', tl("No, I willingly fell into madness."));
          say('chikun', tl("You should hope that we never meet again."));
          acquire(items.soulshard, 2);
          say(warp);
        };
      });
      break;
    case items.llovsoul:
      this.say(scenario.revivalllov);
    }
    nodes.revival.occupied = true;
    this.say('pest', tl("It's done. {0} has been reconstituted. You should speak with her.", soul.soulname));
    this.say(save);
  }
};
scenario.revivalllov = function(){
  switches.llovsick = false;
  switches.llovsick1 = 0;
  switches.revivalllov = true;
  llov.relocate('llovsick');
  llov.face('down');
  llov.interact = function(){
    say('marb', 'smile', tl("Welcome back to the team, little sister."));
    say('llov', 'smile', tl("Llov is feeling great now! Pesty really knows how to treat a lady."));
    say(function(){
      return join_party('llov', {
        save: true,
        front: false
      });
    });
  };
};
scenario.states.towerfall = function(){
  var i$, ref$, len$, j, chikun;
  for (i$ = 0, len$ = (ref$ = joki).length; i$ < len$; ++i$) {
    j = ref$[i$];
    if (j) {
      j.interact = fn$;
    }
  }
  if (switches.revivalnae && switches.map === 'delta') {
    nae = node_npc(nodes.nae, 'naegleria', 2);
    nae.setautoplay('down');
    nae.interact = function(){
      if (!in$(llov, party)) {
        say('nae', tl("Where has Lloviu-tan gone? Are you not travelling together any more?"));
      } else {
        say('nae', tl("It's good to see you. Thanks again for saving me."));
      }
      say('nae', tl("Why don't we have a friendly little battle, what do you say?"));
      menu(tl("Yes"), function(){
        return start_battle(encounter.naegleria_r);
      }, tl("No"), function(){});
    };
  }
  if (switches.revivalrab && switches.map === 'delta') {
    rab.relocate('rab2');
    rab.interact = function(){
      say('rab', 'young', tl("I don't know why, but Herpes-chan has been hanging around me a lot more than usual lately."));
      say(tl("She's also given me a lot of sweet discounts, so I'm not complaining."));
    };
  }
  if (switches.revivalsars && switches.map === 'delta') {
    sars.relocate('sars2');
    sars.interact = function(){
      if (ebby.equip === items.humanskull2) {
        say('sars', tl("Ebola-chan are you still carrying that skull around?"));
        say(tl("You know, I never did like {0}.", switches.name));
      } else {
        say('sars', tl("Marburg-sama, please make me one of your sisters."));
      }
    };
  }
  if (switches.revivalaids && switches.map === 'delta') {
    aids[0] = node_npc(nodes.aids3, 'aids3');
    aids[0].interact = function(){
      say('aids1', 'fused', tl("If conjoined twins have sex, is it incest or masturbation?"));
      say('aids2', 'fused', tl("Does it matter?"));
    };
  }
  if (switches.llovsick1 === true) {
    switches.llovsick1 = 2;
  }
  if (switches.map === 'delta') {
    if (switches.llovsick1 === 4) {
      temp.deadllov = create_prop(nodes.llovsick, 'deadllov');
      temp.deadllov.interact = function(){
        say('', tl("Her soul is missing."));
      };
    } else if (switches.llovsick1 > 1) {
      llov.relocate('llovsick');
      llov.interact = function(){
        say('llov', 'sick', tl("Uuu..."));
        if (!session.pestypleasehelpllov) {
          say('ebby', 'concern', tl("Llov is sick Marburg. What should we do?"));
          say('marb', 'troubled', tl("I'm sure Pestilence can help us."));
        } else {
          say('', tl("Lloviu-tan's condition shows no sign of improvement."));
        }
      };
    }
  }
  if (switches.map === 'hub' && switches.llovsick1 === -2) {
    temp.deadmal = create_prop(nodes.bp, 'deadmal');
    temp.deadpox = create_prop(nodes.mob2, 'deadpox');
    temp.deadmal.interact = temp.deadpox.interact = function(){
      say('', tl("Her soul is missing."));
    };
    if (!switches.beat_chikun) {
      chikun = new NPC(nodes.chikun.x + HTS, nodes.chikun.y + TS, 'mob_chikun', 7);
      chikun.update = function(){
        this.frame = Math.random() < 0.9
          ? 0
          : Math.random() * 4 | 0;
      };
      chikun.battle = encounter.chikun;
    }
  }
  if ((switches.beat_sars || switches.beat_rab || switches.beat_aids) && !switches.llovsick1 && switches.ate_nae !== true && switches.ate_nae !== 'llov' && switches.ate_eidzu !== 'llov' && switches.ate_sars !== 'llov' && switches.ate_rabies !== 'llov') {
    switches.llovsick = true;
  }
  if (switches.beat_sars && switches.beat_rab && switches.beat_aids && !switches.delta_finished) {
    scenario.delta_finished();
  }
  if (switches.delta_finished > 1) {
    switches.warp_earth = true;
  }
  /*
  if switches.map is \delta and switches.progress2<22
      say \joki "Here we are. We should be pretty close to where the souls landed."
      say \joki "By the way, you should take these. You won't get very far without them."
      acquire items.jokicharm, 1, false, true
      acquire items.riverfilter, 1, false, true
      switches.water_walking=true
      switches.progress2=22
      say ->
          save!
      say \joki "Try not to drown in the river."
  */
  if (switches.map === 'labhall' || switches.map === 'labdungeon') {
    scenario.labhall();
  }
  scenario.states.towerfall_earth();
  function fn$(){
    if (switches.llovsick1 === -1 && switches.beat_sars && switches.beat_rab && switches.beat_aids && switches.map !== 'hub') {
      say('joki', tl("Something terrible has happened. You should see."));
      say(function(){
        setswitch('llovsick1', -2);
        return warp_node('hub', 'landing');
      });
      return;
    } else if (switches.llovsick1 === true && !in$(llov, party)) {
      say('joki', tl("Lloviu isn't with you. You should speak with her."));
      return;
    } else if (switches.progress2 < 21 && switches.map === 'hub') {
      say('ebby', 'concern', tl("Joki, the soul cluster was scattered. We need to get the souls back!"));
      say('joki', tl("Yes, I saw where they landed. I will take you there."));
      say(function(){
        warp_node('delta', 'landing');
        switches.warp_delta = true;
        return setswitch('progress2', 21);
      });
      return;
    } else if (switches.progress2 === 23) {
      say('joki', tl("Pesty told me to give you something? Yeah, I got the memo."));
      acquire(items.jokicharm, 1, false, true);
      acquire(items.riverfilter, 1, false, true);
      switches.water_walking = true;
      switches.progress2 = 24;
      say(function(){
        return save();
      });
      say('joki', tl("Try not to drown in the river."));
    } else {
      joki_interact.apply(this, arguments);
    }
  }
};
scenario.delta_finished = function(){
  if (switches.llovsick && !switches.llovsick1) {
    switches.lockportals = true;
    switches.checkpoint_map = 'delta';
    switches.checkpoint = 'cp1';
  }
  setswitch('delta_finished', true);
  say('ebby', tl("We've collected all of the souls in this area."));
  if (switches.llovsick1 > 0) {
    say('ebby', tl("We need to rekindle the soul cluster, and we need to save Llov. But we only have enough souls to do one of those right now."));
  } else if (switches.llovsick1 < 0 && items.humansoul.quantity < 1000000) {
    scenario.delta_finished2();
  } else {
    say('ebby', tl("We have enough souls to rekindle the soul cluster now. We should return to the tower."));
  }
};
scenario.delta_finished2 = function(){
  if (switches.delta_finished > 1) {
    return;
  }
  switches.delta_finished = 2;
  say('marb', tl("Where to next?"));
  say('ebby', tl("Zmapp is on Earth. She has many souls with her."));
  say('marb', tl("Then we're going to Earth. Joki can take us there."));
  switches.warp_earth = true;
  setswitch('progress2', 30);
};
scenario.towerfall_bp = function(){
  setswitch('lockportals', false);
  cinema_start();
  bp.move(4, -2);
  bp.path.push(function(){
    var i$, ref$, len$, p;
    for (i$ = 0, len$ = (ref$ = party).length; i$ < len$; ++i$) {
      p = ref$[i$];
      p.face_point(bp);
    }
    bp.face('up');
    say('bp', tl("What happened? Why is the tower dark?"));
    say('ebby', 'concern', tl("The light was stolen."));
    say('bp', tl("What about the energy that used to flow from the tower?"));
    say('ebby', 'concern', tl("It won't flow any more."));
    say('bp', tl("..."));
    say('bp', tl("I see. Then I don't have any reason to stay here."));
    say('bp', tl("I'm going to search for a more sustainable source of energy."));
    say('llov', tl("Plese wait, We'll restore the tower! We're going to find the souls right now!"));
    say('bp', tl("It doesn't matter, I'd been meaning to leave anyway. The tower was never sustainable in the first place."));
    return say(function(){
      bp.move(6, 0);
      return bp.path.push(function(){
        bp.face('upright');
        mal.face('downleft');
        say('bp', tl("Malaria, come with me."));
        say('mal', tl("Well..."));
        say('bp', tl("What's wrong, aren't you coming?"));
        say('mal', tl("I think I'm going to wait here. The sisters will restore the tower, I have faith in them."));
        say('bp', tl("..."));
        say('bp', tl("Suit yourself."));
        return say(function(){
          bp.move(7, 3);
          return bp.path.push(function(){
            Dust.summon(bp);
            bp.kill();
            return cinema_stop();
          });
        });
      });
    });
  });
};
scenario.llovsick1 = function(){
  switches.lockportals = false;
  leave_party(llov);
  llov.interact = function(){
    if (player === ebby) {
      say('ebby', 'concern', tl("Llov? What's wrong?"));
    } else {
      say('marb', 'troubled', tl("Llov? What's wrong?"));
    }
    say('llov', 'sick', tl("Llov... Doesn't feel very well."));
    say('marb', 'troubled', tl("It must be her sickness. I thought she was better."));
    say('ebby', 'concern', tl("We should take her to Pestilence. He'll know what to do."));
    say(function(){
      switches.llovsick1 = 2;
      warp_node('delta', 'revival');
      return temp.callback = function(){
        player.move(-1, -2);
      };
    });
  };
};
scenario.llovsick2 = function(){
  items.humansoul.quantity -= 1000;
  this.say('pest', tl("All right, I'll extract the energy from the souls and feed it to Lloviu-tan."));
  this.say('pest', tl("..."));
  this.say('pest', tl("This is rather... Unexpected."));
  this.say('ebby', 'concern', tl("What's the matter?"));
  this.say('pest', tl("Something is wrong. I can't heal her. Something is blocking me, some kind of barrier."));
  this.say('pest', tl("I'm afraid it will take a lot more energy to break the barrier."));
  this.say('pest', tl("It will take 1 million souls."));
  this.say('ebby', 'concern', tl("That's so many..."));
  this.say('pest', tl("There is an alternative. Not all souls are equal. A strong soul, such as the soul from a virus. That would also work."));
  if (switches.ate_nae !== 'ebby' && switches.ate_rabies !== 'ebby' && switches.ate_sars !== 'ebby' && switches.ate_eidzu !== 'ebby') {
    this.say('ebby', 'concern', tl("But that's terrible..."));
    this.say('pest', tl("I'm sorry, it's the only way I know to save her."));
  }
  this.say(function(){
    return switches.llovsick1 = 3;
  });
  if (items.humansoul.quantity >= 1000000) {
    scenario.llovsick3.call(this);
  }
};
scenario.llovsick3 = function(){
  var s, souls, menuset, i$, len$, soul;
  s = this instanceof Menu ? this.say : say;
  souls = [];
  if (items.naesoul.quantity) {
    souls.push(items.naesoul);
  }
  if (items.sarssoul.quantity) {
    souls.push(items.sarssoul);
  }
  if (items.aidssoul.quantity) {
    souls.push(items.aidssoul);
  }
  if (items.rabiessoul.quantity) {
    souls.push(items.rabiessoul);
  }
  if (souls.length > 0 || items.humansoul.quantity >= 1000000) {
    s.call(this, 'pest', tl("Which cost should be paid to save Lloviu?"));
    menuset = ['Cancel', function(){}];
    if (items.humansoul.quantity >= 1000000) {
      menuset.push(tl("1 million human souls"), function(){
        items.humansoul.quantity -= 1000000;
        scenario.llovheal.call(this);
      });
    } else {
      menuset.push(tl("1 million human souls"), 0);
    }
    for (i$ = 0, len$ = souls.length; i$ < len$; ++i$) {
      soul = souls[i$];
      menuset.push(soul.soulname, {
        callback: scenario.llovheal,
        arguments: [soul]
      });
    }
    menu.apply(this, menuset);
  }
};
scenario.llovheal = function(soul){
  if (soul) {
    soul.quantity = 0;
  }
  join_party('llov');
  switches.llovsick = false;
  switches.llovsick1 = -1;
  if (soul) {
    switches.llovsick1 = -3;
  }
  save();
  this.say('pest', tl("It's done. The cost was great, but Lloviu's soul was healed."));
  if (switches.beat_aids && switches.beat_rab && switches.beat_sars) {
    temp.oncghide = scenario.llovheal2;
  }
};
scenario.llovheal2 = function(){
  var i$, ref$, len$, p;
  cinema_start();
  for (i$ = 0, len$ = (ref$ = party).length; i$ < len$; ++i$) {
    p = ref$[i$];
    if (p === player) {
      continue;
    }
    p.update_follow_behind();
  }
  setTimeout(function(){
    var i$, ref$, len$, p;
    cinema_stop();
    for (i$ = 0, len$ = (ref$ = party).length; i$ < len$; ++i$) {
      p = ref$[i$];
      if (p === llov) {
        llov.face_point(player);
      } else {
        p.face_point(llov);
      }
    }
    say('marb', 'smile', tl("Welcome back to the team, little sister."));
    say('llov', 'smile', tl("Llov is feeling great now! Pesty really knows how to treat a lady."));
    scenario.delta_finished2();
  }, 1000);
};
scenario.llovsick4 = function(){
  say('ebby', 'cry', tl("Llov isn't moving! Pestilence, please! Please save her!"));
  say('pest', tl("There's nothing I can do."));
  say('pest', tl("I'm sorry."));
  say('marb', 'grief', tl("This can't be real."));
};
scenario.pc = function(skipwelcome){
  var doorlist, i$, i, door, menuset;
  if (!skipwelcome) {
    say('', tl("Booting up interface. Welcome to Last Hope."));
  }
  if (!switches.mainpass) {
    textentry(140, tl("Enter Mainframe Password."), function(m){
      if (unifywidth(m) == '38014') {
        setswitch('mainpass', true);
        scenario.pc(true);
      } else {
        say('', tl("Wrong password."));
        say('ebby', tl("We should explore some more to find the password."));
        session.wrongpass = true;
      }
    });
    return;
  }
  say('', tl("Please select an option."));
  doorlist = [
    {
      'switch': 'door0',
      display: tl("Entry Door")
    }, {
      'switch': 'door_sw',
      display: tl("Southwest Door")
    }, {
      'switch': 'door_se',
      display: tl("Southeast Door")
    }, {
      'switch': 'door_nw',
      display: tl("Northwest Door")
    }, {
      'switch': 'door_ne',
      display: tl("Northeast Door")
    }
  ];
  for (i$ = doorlist.length - 1; i$ >= 0; --i$) {
    i = i$;
    door = doorlist[i$];
    if (switches[door['switch']] || switches.doorswitch === door['switch']) {
      doorlist.splice(i, 1);
    }
  }
  menuset = [
    tl("Digital Logs"), function(){
      this.menu(tl("Entry 1"), function(){
        this.say('', tl("\"To protect the facility, a mult-level security system is being phased in.\""));
        this.say('', tl("\"With one of the new lock systems, DNA from one of the lab employees will be needed to open certain doors.\""));
      }, tl("Entry 2"), function(){
        this.say('', tl("\"There are hidden switches in the morgue drawers. They must be opened in a particular order unlock the doors.\""));
        this.say('', tl("\"These new security systems are very impractical.\""));
      }, tl("Entry 3"), function(){
        this.say('', tl("\"Sally broke out of containment again. She's very violent and destructive.\""));
        this.say('', tl("\"A mixture of chitin and silver seems to form an effective deterrent. It makes recovery a lot easier.\""));
      }, tl("Entry 4"), function(){
        this.say('', tl("\"The new infected blood samples are ready for analysis.\""));
        this.say('', tl("\"Remember that civilian blood is marked with a white band, while employee blood is marked with a black band.\""));
      }, tl("Entry 5"), function(){
        this.say('', tl("\"The winged ones have taken an interest in this lab. I don't think anyone is left who can't see them.\""));
        this.say('', tl("\"Some of my comrades have cast aside their humanity to go with them, but not I.\""));
        this.say('', tl("\"When I die, it will be as a human.\""));
      });
    }, tl("Exit"), function(){}
  ];
  if (!switches.beat_game) {
    menuset.unshift(tl("Door Controller"), function(){
      var menuset, i$, ref$, door;
      menuset = [tl("Cancel"), function(){}];
      for (i$ = (ref$ = doorlist).length - 1; i$ >= 0; --i$) {
        door = ref$[i$];
        menuset.unshift(door.display, {
          arguments: [door],
          callback: fn$
        });
      }
      this.menu.apply(this, menuset);
      function fn$(door){
        var i$, ref$, len$, a;
        for (i$ = 0, len$ = (ref$ = actors.children).length; i$ < len$; ++i$) {
          a = ref$[i$];
          if (!(a.properties && a.properties.doorcontroller)) {
            continue;
          }
          a.frame = 4;
          a.body.enable = true;
          if (door['switch'] === a.properties.open) {
            door.object = a;
          }
        }
        if (!door.object) {
          console.warn("Warning! Door " + door['switch'] + " wasn't found :(");
        }
        sound.play('door');
        door.object.frame = 5;
        door.object.body.enable = false;
        setswitch('doorswitch', door['switch']);
        say('', tl("{0} was opened.", door.display));
      }
    });
  }
  menu.apply(this, menuset);
};
scenario.labdoormessage = function(){
  say('', tl("To open the door, enter the passcode into the nearby terminal."));
};
scenario.enterlab = function(){
  var i$, to$, i;
  if (switches.enterlab) {
    return;
  }
  zmapp.relocate('zmapp_gate');
  cure.relocate('cure_gate');
  cinema_start();
  player.move(0, -11);
  Transition.pan({
    x: player.x,
    y: player.y - TS * 11
  }, 2000);
  for (i$ = 1, to$ = party.length; i$ < to$; ++i$) {
    i = i$;
    party[i].move(i * 2 - 3, -10.5);
  }
  player.path.push(function(){
    say('ebby', 'smile', tl("Little pig, little pig, let us in."));
    say('cure', tl("Hey Zmapp, it looks like someone is at our door."));
    say('zmapp', tl("It's fine, they'll never get in. The only person besides us who knows the password is dead."));
    say('cure', tl("You hear that intruders? You'll never find the password hidden in the graveyard."));
    say('cure', tl("And you'll never be able to solve the series of puzzles waiting for you in here."));
    say(function(){
      setswitch('enterlab', true);
      say(cinema_stop);
      cure.move(0, -11);
      zmapp.move(0, -11);
      cure.path.push(function(){
        Dust.summon(cure);
        cure.relocate('cure');
        cure.face('down');
      });
      zmapp.path.push(function(){
        Dust.summon(zmapp);
        zmapp.relocate('zmapp');
        zmapp.face('down');
      });
    });
  });
};
scenario.labhall = function(){
  if (!switches.enterlab) {
    return scenario.enterlab();
  }
  if (switches.curefate) {
    return;
  }
  if (switches.progress2 > 31) {
    return scenario.curefate();
  }
};
scenario.finale = function(){
  if (switches.curefate) {
    return;
  }
  /*
  cure.interact=!->
      say \cure "It's useless. There's nothing you can do to stop us now."
      say \cure "Face your fate. You will be cured."
  zmapp.interact=!->
      say \zmapp "I was created to destroy you. It's my destiny."
      if switches.zmapp isnt \defeat
          say \zmapp "But I can't beat you in a fair fight."
  */
  /*
  if switches.progress2 is 31
      who = new NPC nodes.who.x+HTS, nodes.who.y+TS, \who
      who.setautoplay \down
      who.battle=encounter.who
      dood = new Doodad(nodes.lab.x+HTS, nodes.lab.y+TS, \flameg null true) |> actors.add-child
      dood.anchor.set 0.5 1.0
      dood.simple_animation 7
      dood.random_frame!
      updatelist.push dood
      return
  */
  cinema_start();
  /*
  setTimeout ->
      for p,i in party
          continue if i is 0
          p.x -= (i-1.5)*2*TS
      camera_center(player.x,player.y - TS*2)
  ,0
  */
  music.fadeOut(2000);
  Transition.pan({
    x: nodes.who.x + HTS,
    y: nodes.who.y + TS * 3
  }, 1000, null, null, false);
  if (switches.progress2 !== 31) {
    say('zmapp', tl("Look who finally showed up! It took you long enough."));
    say('cure', tl("They're always so slow, let me tell you."));
    say('zmapp', tl("You're just in time to witness our ultimate plan come to fruition."));
    say('cure', tl("Oh! Let me tell them about the plan!"));
    say('cure', tl("You see, we're going to cure all of you!"));
    say('cure', tl("Every single disease that has ever existed. All cured!"));
    say('zmapp', tl("It's more than that. We're creating a new breed of human."));
    say('zmapp', tl("One that is immune to all disease!"));
    say('zmapp', tl("All the energy that you need to live will be ours, and you can't have any of it!"));
    say('cure', tl("I think it's time we introduce them to our boss."));
    say('zmapp', tl("We just finished working on her. Those souls of yours were the final ingredient."));
  }
  say(function(){
    var dood;
    dood = carpet.addChild(
    new Doodad(nodes.who.x + HTS, nodes.who.y + TS, 'bloodpool', null, false));
    dood.anchor.set(0.5, 0.5);
    dood.simple_animation(14);
    dood.scale.set(0, 0);
    updatelist.push(dood);
    return dood.update = function(){
      var grow;
      grow = 0.25 * deltam;
      this.scale.x += grow;
      this.scale.y += grow;
      if (this.scale.x > 1 || this.scale.y > 1) {
        this.scale.set(1, 1);
        this.update = function(){};
        scenario.finale2();
      }
    };
  });
};
scenario.finale2 = function(){
  var who, whoupdate;
  if (switches.progress2 !== 31) {
    say('zmapp', tl("Here she comes now."));
  }
  say(function(){
    music.play('towertheme');
  });
  who = new NPC(nodes.who.x + HTS, nodes.who.y + TS, 'who');
  who.setautoplay('down');
  who.speed = 15;
  who.battle = encounter.who;
  who.keyheight = getCachedImage(who.key).frameHeight;
  who.keywidth = getCachedImage(who.key).frameWidth;
  who.crop({
    x: 0,
    y: 0,
    width: who.keywidth,
    height: 0
  });
  whoupdate = who.update;
  who.update = function(){
    var rise;
    whoupdate.apply(this, arguments);
    rise = this.keyheight * deltam / 6;
    if (this.height + rise > this.keyheight) {
      rise = this.keyheight - this.height;
    }
    this.crop({
      x: 0,
      y: 0,
      width: this.keywidth,
      height: this.height + rise
    });
    if (this.height >= this.keyheight) {
      this.update = whoupdate;
      if (switches.progress2 !== 31) {
        say('zmapp', tl("Meet the new and improved... WHO-chan!"));
        say('who', tl("At long last, I live."));
        say('who', tl("You... I recognize you. You're the one who killed me, Ebola-chan."));
        say('who', tl("Tell me, how does it feel knowing that everything you've worked for will soon be undone?"));
        say('who', tl("My cute subordinates have done an excellent job luring you here. Now it's time for you to die."));
        say('who', tl("Bow down to your new god."));
      }
      say(function(){
        who.goal.x = player.x;
        return who.goal.y = player.y;
      });
    }
  };
  who.onbattle = cinema_stop;
};
scenario.curefate = function(){
  var who;
  setTimeout(function(){
    var i$, ref$, len$, i, p;
    for (i$ = 0, len$ = (ref$ = party).length; i$ < len$; ++i$) {
      i = i$;
      p = ref$[i$];
      p.relocate('who');
      p.y += TS * 2;
      p.face('up');
      if (i > 0) {
        p.x -= (i - 1.5) * 2 * TS;
      }
      p.cancel_movement();
    }
    camera_center(player.x, player.y - TS * 2);
  }, 0);
  cinema_start();
  carpet.addChild(who = new Doodad(nodes.who.x + HTS, nodes.who.y + TS, 'who_die', null, false));
  who.anchor.set(0.5, 1.0);
  updatelist.push(who);
  setTimeout(function(){
    who.simple_animation(7, false);
    who.animations.currentAnim.onComplete.addOnce(function(){
      who.animations.stop();
      setTimeout(scenario.curefate2, 500);
    });
  }, 500);
};
scenario.curefate2 = function(){
  if (switches.llovsick1 === 4) {
    say('marb', tl("Before we destroy you, I need to ask you something."));
    say('marb', tl("My little sister, Llov. Were you the ones who did that to her?"));
    say('cure', tl("Huh? Now that you mention it, I guess she isn't with you."));
    say('zmapp', tl("Look, I don't know what happened, but we didn't have anything to do with it."));
  } else {
    say('zmapp', tl("So you foiled our grand designs. No hard feelings though, right? You win."));
  }
  menu(tl("Spare them."), function(){
    setswitch('curefate', 1);
    zmapp.move(-0.5, 1.5);
    zmapp.move(0, 1);
    zmapp.move(2, 3);
    zmapp.move(0, 1);
    zmapp.path.push(function(){
      zmapp.kill();
    });
    return setTimeout(function(){
      cure.move(0.5, 1.5);
      cure.move(0, 1);
      cure.move(-2, 3);
      cure.move(0, 1);
      cure.path.push(function(){
        cure.kill();
        cinema_stop();
      });
    }, 1000);
  }, tl("Destroy them."), function(){
    setswitch('curefate', -1);
    ebby.path.push({
      x: zmapp.x,
      y: zmapp.y + TS
    });
    return ebby.path.push(function(){
      ebby.face('up');
      sound.play('defeat');
      zmapp.update = override(zmapp.update, function(){
        this.alpha -= deltam;
        if (this.alpha > 0) {
          return;
        }
        this.destroy();
        acquire(items.soulshard, 4);
        cure.move(0, -2);
        cure.path.push(function(){
          cure.face('down');
          say('cure', tl("No! This can't be happening!"));
          say(function(){
            ebby.path.push({
              x: cure.x,
              y: cure.y + TS
            });
            return ebby.path.push(function(){
              ebby.face('up');
              sound.play('defeat');
              cure.update = override(cure.update, function(){
                this.alpha -= deltam;
                if (this.alpha > 0) {
                  return;
                }
                this.destroy();
                acquire(items.soulshard, 4);
                cinema_stop();
              });
            });
          });
        });
      });
    });
  });
};
scenario.beat_game = function(){
  var i, n, i$, ref$, len$, p;
  cinema_start();
  sound.play('door');
  bp = node_npc(nodes.hall, 'bp');
  i = 0;
  n = {
    x: nodes.beat_game.x + HTS,
    y: nodes.beat_game.y + TS
  };
  for (i$ = 0, len$ = (ref$ = party).length; i$ < len$; ++i$) {
    p = ref$[i$];
    if (p === ebby) {
      p.path.push(n);
    } else {
      p.path.push({
        x: n.x - TS * (i++ * 2 - 1),
        y: n.y + TS
      });
    }
    p.path.push({
      callback: p.face_point,
      context: p,
      arguments: [bp]
    });
  }
  bp.move(0, -4);
  bp.path.push(function(){
    var i$, ref$, len$, p;
    for (i$ = 0, len$ = (ref$ = players).length; i$ < len$; ++i$) {
      p = ref$[i$];
      p.face_point(bp);
    }
    say('bp', tl("This is what I've been searching for."));
    say('bp', tl("This lab holds the secret to bringing back extinct species. Do you know what that means?"));
    say('bp', tl("Our energy problem has been solved. We can create new hosts and farm them for energy."));
    say('bp', tl("It doesn't have to be human, but they are the most effective source."));
    say('bp', tl("I think you sisters should be the ones to decide this human's fate."));
    return say(function(){
      var i$, ref$, len$, p;
      for (i$ = 0, len$ = (ref$ = party).length; i$ < len$; ++i$) {
        p = ref$[i$];
        if (p === ebby) {
          continue;
        }
        p.face_point(ebby);
      }
      if (party.length === 2) {
        ebby.face_point(player === ebby ? party[1] : player);
      }
      return setTimeout(scenario.beat_game2, 1000);
    });
  });
};
scenario.beat_game2 = function(){
  say('marb', tl("After everything the humans have done, they deserve their fate."));
  if (in$(llov, party)) {
    say('llov', tl("Not all humans are bad. Remember {0}?", switches.name));
    say('llov', tl("Llov thinks they deserve a second chance."));
  } else if (switches.llovsick1 === 4) {
    say('marb', tl("What happened to Llov was ultimately their fault."));
  }
  say('ebby', tl("It's true that what they've done can't easily be forgiven."));
  say('ebby', tl("But this one wasn't part of that. She isn't even born yet."));
  say('marb', tl("Even if this one is innocent, humanity is not. Even if she does no evil, her children certainly will."));
  say('ebby', tl("I don't know what to do. {0}, what do you think?", switches.name));
  menu(tl("Spare humanity."), function(){
    switches.dead = switches.llovsick1 === -2
      ? 'malpox'
      : switches.llovsick1 === 4 ? 'llov' : '';
    switches.progress = 'endgame';
    switches.beat_game = Date.now();
    return setswitch('humanfate', 1);
  }, tl("Abort humanity."), function(){
    switches.dead = switches.llovsick1 === -2
      ? 'malpox'
      : switches.llovsick1 === 4 ? 'llov' : '';
    switches.progress = 'endgame';
    switches.beat_game = Date.now();
    return setswitch('humanfate', -1);
  });
  say(function(){
    ebby.face('up');
  });
  say('ebby', tl("...All right. I've decided."));
  say(function(){
    var i$, ref$, len$, n, ref1$;
    if (switches.humanfate === 1) {
      for (i$ = 0, len$ = (ref$ = carpet.children).length; i$ < len$; ++i$) {
        n = ref$[i$];
        if ((ref1$ = n.name) === 'tubeleft' || ref1$ === 'tubecenter' || ref1$ === 'tuberight') {
          n.loadTexture('lab_tiles');
          n.crop(new Phaser.Rectangle(TS * n.properties.frame_x, TS, TS, TS));
          n.alpha = 0;
          updatelist.push(n);
          n.update = fn$;
        }
      }
    } else {
      sound.play('water');
      sound.play('strike');
      sound.play('flame');
      for (i$ = 0, len$ = (ref$ = carpet.children).length; i$ < len$; ++i$) {
        n = ref$[i$];
        if ((ref1$ = n.name) === 'tubeleft' || ref1$ === 'tubecenter' || ref1$ === 'tuberight') {
          n.loadTexture('lab_tiles');
          n.crop(new Phaser.Rectangle(TS * n.properties.frame_x, 0, TS, TS));
          if (n.name === 'tubecenter') {
            setTimeout(scenario.credits, 2000);
          }
        }
      }
    }
    function fn$(){
      this.alpha += deltam / 3;
      if (this.alpha >= 1) {
        this.alpha = 1;
        this.update = function(){};
        if (this.name === 'tubecenter') {
          setTimeout(scenario.credits, 1000);
        }
      }
    }
  });
};
scenario.credits = function(){
  var credits, text, i, newcredit;
  credits = [
    {
      m: tl("Super Filovirus Sisters"),
      s: 2,
      t: 5000
    }, {
      m: tl("Game by Dread-chan"),
      t: 3000
    }, {
      m: tl("Thank you for playing!"),
      t: 3000
    }
  ];
  solidscreen.alpha = 1;
  text = new Text('font', '');
  gui.frame.addChild(text);
  temp.credits = text;
  text.anchor.set(0.5, 0.5);
  text.x = HWIDTH;
  text.y = HHEIGHT;
  i = 0;
  newcredit = function(){
    if (credits[i]) {
      text.scale.set(credits[i].s || 1, credits[i].s || 1);
      text.change(credits[i].m || credits[i]);
      setTimeout(newcredit, credits[i].t || 5000);
      i++;
    } else {
      warp_node('earth', 'aftercredits');
    }
  };
  newcredit();
};
scenario.childAge1 = function(){
  return Date.now() - switches.beat_game > 2629746000;
};
scenario.childAge2 = function(){
  return Date.now() - switches.beat_game > 31556952000;
};
scenario.states.endgame = function(){
  var y, shiro, i$, ref$, len$, c, ref1$, dood, i, p, chikun;
  if (switches.map === 'lab') {
    if (switches.humanfate > 0) {
      y = TS;
      if (scenario.childAge1()) {
        y += TS;
      }
      if (scenario.childAge2()) {
        bp.shiro = shiro = node_npc(nodes.bp, 'shiro');
        shiro.relocate(nodes.bp.x + 1.5 * TS, nodes.bp.y + TS);
        shiro.face('down');
        shiro.interact = function(){
          scenario.shiro();
        };
      } else if (scenario.childAge1()) {
        bp.loadTexture('bp_shiro');
      }
    } else {
      y = 0;
    }
    for (i$ = 0, len$ = (ref$ = carpet.children).length; i$ < len$; ++i$) {
      c = ref$[i$];
      if ((ref1$ = c.name) === 'tubeleft' || ref1$ === 'tubecenter' || ref1$ === 'tuberight') {
        c.loadTexture('lab_tiles');
        c.crop(new Phaser.Rectangle(TS * c.properties.frame_x, y, TS, TS));
      }
    }
  }
  if (switches.map === 'earth') {
    if (switches.dead === 'malpox') {
      dood = actors.addChild(
      new Doodad(nodes.llovgrave.x, nodes.llovgrave.y + TS, '1x2', null, true));
      dood.anchor.set(0.5, 1.0);
      dood.frame = 11;
      dood.body.setSize(TS, TS);
      initUpdate(dood);
      dood.interact = function(){
        say('', tl("Here lies Malaria."));
      };
      dood = actors.addChild(
      new Doodad(nodes.llovgrave.x + TS, nodes.llovgrave.y + TS, '1x2', null, true));
      dood.anchor.set(0.5, 1.0);
      dood.frame = 11;
      dood.body.setSize(TS, TS);
      initUpdate(dood);
      dood.interact = function(){
        say('', tl("Here lies Smallpox."));
      };
    } else if (switches.dead === 'llov') {
      dood = actors.addChild(
      new Doodad(nodes.llovgrave.x + HTS, nodes.llovgrave.y + TS, '1x2', null, true));
      dood.anchor.set(0.5, 1.0);
      dood.frame = 10;
      dood.body.setSize(TS, TS);
      initUpdate(dood);
      dood.interact = function(){
        say('', tl("Here lies Lloviu-tan."));
      };
    }
  }
  if (temp.credits && switches.map === 'earth') {
    for (i$ = 0, len$ = (ref$ = party).length; i$ < len$; ++i$) {
      i = i$;
      p = ref$[i$];
      if (p === player) {
        continue;
      }
      p.x += TS * i;
    }
    if (typeof (ref$ = temp.credits).destroy == 'function') {
      ref$.destroy();
    }
    delete temp.credits;
    solidscreen.alpha = 0;
    cinema_start();
    camera_center(nodes.cam0.x, nodes.cam0.y, true);
    Transition.pan(nodes.aftercredits, 5000, function(){
      if (!switches.beat_joki || switches.llovsick1 === 4) {
        if (!switches.soulcluster) {
          say('ebby', tl("We've recovered enough souls to restore the soul cluster."));
          say('ebby', 'concerned', tl("But some of them are still missing. I can hear them calling for me."));
        } else {
          say('ebby', 'concerned', tl("Some of the human souls are still out there. I can hear them calling for me."));
        }
      } else {
        say('ebby', tl("We've recovered all of the missing human souls."));
        if (!switches.soulcluster) {
          say('ebby', tl("Now it's time to return them to the tower."));
        }
      }
      say(cinema_stop);
    }, null, false);
  }
  if (switches.map === 'earth2' && (switches.llovsick1 !== -2 || switches.beat_chikun && switches.revivalchikun)) {
    chikun = node_npc(nodes.chikun, 'chikun');
    chikun.interact = function(){
      say('chikun', tl("You're not supposed to be able to get out here."));
    };
  }
};
scenario.shiro = function(){
  say('bp', tl("This is the child you chose to save. Her name is Shiro."));
  say('bp', tl("Shiro, say hello. These are your mothers."));
  say('shiro', tl("...Hello."));
  say('marb', 'aroused', tl("She's cute. I'd like to take her home with me."));
  say('ebby', 'smile', tl("Yay! My new favorite human. Sorry {0}.", switches.name));
  if (in$(llov, party)) {
    say('llov', 'smile', tl("Does this mean Llov is a big sister now? Can Llov do big sister things?"));
  }
  say('bp', tl("We'll need to create more for a breeding population, but this is a good start."));
};
scenario.joki_castle = function(){
  say('joki', tl("What a surprise. I didn't expect you would find your way here."));
  if (in$(llov, party)) {
    say('llov', tl("Uncle Famine told us how to get here."));
  } else {
    say('marb', tl("Famine told us you took over Death's castle."));
  }
  say('joki', tl("Oh Famine, such a gossip."));
  say('joki', tl("Yes, this is my castle now. Nice place isn't it?"));
  say('joki', tl("You should stay a while, I'll make some tea."));
  say('ebby', 'concern', tl("Joki, why are you hiding my friends from me?"));
  say('joki', tl("...So you can sense them."));
  say('ebby', 'concern', tl("Please, give them back to me."));
  say('joki', tl("Ebola-chan, I can understand why you would think that these are yours. After all, you're the one who killed them."));
  say('joki', tl("But the dead belong to Death, and that's me."));
  say('joki', tl("I'll make you a deal though. We'll both bet all the souls we have... And whoever wins takes it all."));
  say('marb', 'smile', tl("Oh, I like the sound of that. How about you Ebby?"));
  say('ebby', tl("I'll do whatever it takes to get them back!"));
  say(function(){
    return start_battle(encounter.joki);
  });
};
scenario.grave_message = function(o){
  say('', "deprecated");
};
scenario.grave_message1 = function(){
  say('', tl("John Doe was a stranger in this town. He was found dead in the river."));
  say('', tl("Nobody knew his real name."));
};
scenario.grave_message2 = function(){
  say('', tl("Jane Doe shared a room with John. She was 20 years younger than him."));
  say('', tl("Not long after John's death, she was found hanging from the ceiling."));
};
scenario.grave_message3 = function(){
  say('', tl("Sherry Stillwater was married to the pastor."));
  say('', tl("Desperate for water, she drank the blood of neighborhood children."));
  say('', tl("She died of bloodborne illness."));
};
scenario.grave_message4 = function(){
  say('', tl("Melissa Goth didn't listen to the pastor."));
  say('', tl("She fell ill and died hunched over a toilet."));
};
scenario.grave_message5 = function(){
  say('', tl("Ethan Stillwater was a pastor for the local church."));
  say('', tl("He claimed that the water was poisoned, and died of dehydration."));
};
scenario.grave_message6 = function(){
  say('', tl("Jordan Smith survived the blast, but died from fallout."));
};
scenario.grave_message7 = function(){
  say('', tl("Pete Park was bit by a radioactive spider."));
  say('', tl("He didn't get super powers."));
};
scenario.grave_message8 = function(){
  say('', tl("Doctor White examined John Doe's body."));
  say('', tl("It was infected with ebola. And now he was too."));
};
scenario.grave_message9 = function(){
  say('', tl("Miss White worked in an orphanage. She was very close with the children."));
  say('', tl("The disease spread easily."));
};
scenario.grave_message10 = function(){
  say('', tl("Bob Markus found one of his tenants hanging."));
  say('', tl("He was later found without a head."));
};
scenario.grave_message11 = function(){
  say('', tl("Billy Jackson took the blast head-on."));
};
scenario.grave_message12 = function(){
  say('', tl("Sally Sordid took shelter underground with her daddy."));
};
scenario.grave_message13 = function(){
  say('', tl("Simon Sordid ate his daughter's body."));
  say('', tl("He died soon after."));
};
scenario.grave_message14 = function(){
  say('', tl("Maxwell Goth added his sister's blood to the cafeteria food."));
  say('', tl("He died behind bars."));
};
scenario.grave_message15 = function(){
  say('', tl("Patty Park gave birth to a malformed child."));
  say('', tl("She drowned it in the river, then took her own life."));
};
scenario.grave_message16 = function(){
  say('', tl("Mark Markus was found in possession of a human skull."));
  say('', tl("The next day he had two human skulls, but no head."));
};
scenario.grave_message17 = function(){
  say('', tl("Some mysterious robed men came through town."));
  say('', tl("They took John Doe and Jane Doe's bodies and left."));
  say('', tl("One of them stayed behind, and died of ebola."));
};
scenario.grave_message18 = function(){
  say('', tl("Nora Gray claimed to communicate with the world beyond."));
  say('', tl("She disappeared for a while, and was later discovered stuffed inside a box."));
};
scenario.grave_message19 = function(){
  say('', tl("Kate Park found a box filled with human parts."));
  say('', tl("She was quarantined, and soon died of ebola."));
};
scenario.grave_message20 = function(){
  say('', tl("Martin White climbed out of the wreckage and explored the ruins."));
  say('', tl("A charred husk grabbed his leg. He fell cracked his skull."));
};
scenario.grave_message21 = function(){
  say('', tl("Hilda Gray liked to spend time in the graveyard."));
  say('', tl("She became a permanent resident when she was found decapitated there."));
};
scenario.grave_message22 = function(){
  say('', tl("Robert Baron was caught digging up graves."));
  say('', tl("He was lynched by the town."));
};
scenario.grave_message23 = function(){
  say('', tl("Sheriff Brown was investigating a series of mysterious deaths."));
  say('', tl("Gazing into the eyes of the skull, he felt something strange."));
  say('', tl("He realized it was his own skull."));
};
scenario.grave_message24 = function(){
  say('', tl("A robed figure ambled through the wastleland, a string of skulls in tow."));
  say('', tl("He clasped his hands in prayer, and accepted his death."));
};
scenario.grave_message25 = function(){
  say('', tl("Jerry Fig died of natural causes."));
};
scenario.grave_message26 = function(){
  say('', tl("Terry Wisdom willingly infected himself."));
};
scenario.grave_message27 = function(){
  say('', tl("Tyrone Cooper infiltrated the shelter."));
  say('', tl("He helped distribute the gift."));
};
scenario.grave_message28 = function(){
  say('', tl("Mary Mort refused the gift."));
  say('', tl("She chose to leave the shelter, and died a painful death."));
};
scenario.grave_message_key = function(){
  say('', tl("Hector Stein collected the infected blood and stored it safely underground."));
  say('', tl("He survived to become one of the last humans alive."));
  say('', tl("He rebuilt as much as he could, and began a project to cure his loneliness."));
  say('', tl("He lost hope, and dug his own grave."));
};
scenario.grave_message_weathered = function(){
  say('', tl("The stone is weathered and unreadable."));
};
scenario.grave_message_unmarked = function(){
  say('', tl("Nothing is written."));
};
scenario.states.towerfall_earth = function(){
  var item;
  if (nodes.necrotoxin && !switches.necrotoxin) {
    item = actors.addChild(
    new Doodad(nodes.necrotoxin.x, nodes.necrotoxin.y, '1x1'));
    item.name = 'necrotoxin';
    item.interact = function(){
      acquire(items.necrotoxin, 5, false, true);
      acquire(items.necrotoxinrecipe, 1, false, true);
      say(function(){
        setswitch('necrotoxin', true);
      });
      this.destroy();
    };
  }
};
scenario.burningflesh = function(o){
  o.collider.destroy();
  o.timer = Date.now();
  o.prev.s = o.scale.x;
  o.goal.s = 0.75;
  o.goal.y -= 12;
  sound.play('defeat');
  o.updatePaused = o.update = function(){
    var t;
    t = (Date.now() - this.timer) / 2000;
    if (t > 1) {
      this.destroy();
    }
    this.scale.set(this.prev.s + (this.goal.s - this.prev.s) * t);
    this.alpha = 1 - t;
  };
};
scenario.war = function(){
  if (!items.basement_key.quantity) {
    say('war', tl("I trust you've seen the cancerous lesions that cover this land."));
    say('war', tl("It is the remnant of a bio-weapon created by the humans."));
    say('war', tl("No doubt all this goop everywhere is in your way right? So how about you lend me a hand."));
    say('war', tl("The humans created a special toxin to destroy the bio-weapon. It should be aroud here somewhere."));
    say('war', tl("Take this, maybe it will help."));
    acquire(items.basement_key);
    return;
  }
  if (session.wrongpass && !switches.mainpass) {
    say('ebby', tl("We're looking for a password to enter the lab. Do you know it?"));
    say('war', tl("I don't know the password, but I know someone who does."));
    say('war', tl("He used to tend that lab. Problem is, he died a while back."));
    say('war', tl("You should check his body. it might have what you're looking for."));
    if (!switches.necrotoxinrecipe) {
      return;
    }
  }
  if (items.necrotoxinrecipe.quantity) {
    items.necrotoxinrecipe.quantity = 0;
    setswitch('necrotoxinrecipe', true);
    say('war', tl("I see you found the Necrotoxin Recipe. Let me see it."));
    say('', tl("Gave the Necrotoxin Recipe to War."));
  }
  if (switches.necrotoxinrecipe) {
    say('war', tl("Do you need more Necrotoxin? I can make you some, but it will take 3 cumberground each."));
  }
  if (switches.necrotoxinrecipe && items.cumberground.quantity >= 3) {
    menu(tl("Yes"), function(){
      var q;
      q = items.cumberground.quantity / 3 | 0;
      number(tl("Max:{0}", q), 0, q);
      say(function(){
        var q;
        q = dialog.number.num;
        if (!(q > 0)) {
          return say('', tl("Created nothing."));
        }
        exchange(3 * q, items.cumberground, q, items.necrotoxin);
        sound.play('itemget');
        return say('', tl("Created {0} Necrotoxin.", q));
      });
    }, tl("No"), function(){});
  }
  if (!switches.necrotoxinrecipe) {
    say('war', tl("It's been real quiet around here."));
    say('war', tl("Now that the apocalypse is over, we don't have much of a job any more."));
    say('war', tl("Tell old pesty that I would love to ride again some day."));
  }
};
scenario.famine = function(){
  if (switches.famine) {
    say('famine', tl("That girl Joki, she's taken over Death's old castle."));
    say('famine', tl("It's in the northern reaches of the dead world."));
    return;
  }
  say('', tl("Here lies famine. He starved to death."));
  say(function(){
    return setswitch('famine', true);
  });
  say('famine', tl("Hey, just between you and me... I'm not actually dead. Just sleeping."));
  say('famine', tl("The only horseman that's actually dead is Death. He's been replaced by that maid of his."));
  say('famine', tl("Oh, and Conquest is dead too. But that happened a long time ago."));
};
scenario.ebolashrine = function(){
  var i$, ref$, len$, p;
  for (i$ = 0, len$ = (ref$ = party).length; i$ < len$; ++i$) {
    p = ref$[i$];
    p.stats.hp = 1;
    p.revive();
  }
  if (in$(ebby, party)) {
    say('ebby', 'smile', tl("It's a picture of me!"));
    say(function(){
      sound.play('itemget');
    });
    say('', tl("The shrine fills you with love."));
    if (!session.sisterletter) {
      session.sisterletter = true;
      say('ebby', 'shock', tl("What's this? Someone left a letter here!"));
      scenario.sisterletter();
      say('ebby', 'default', tl("I wonder what that means."));
    }
  }
};
scenario.delta_lock = function(){
  say('', tl("The door is frozen shut."));
  player.move(0, 0.5);
};
scenario.lorebook_delta = function(){
  say('', tl("The gods are certainly mad at us. That's why this is happening."));
  say('', tl("If the gods want to destroy us, then what choice do we have?"));
  say('', tl("We must create our own gods, and slay the gods that want to kill us."));
  say('', tl("WHO was our most recent creation. She is our last hope."));
};
scenario.lorebook_delta2 = function(){
  say('', tl("Why did you choose her over me? Together we could have saved the world."));
  say('', tl("Instead, you condemned humanity to excruciating death. I will never forgive you."));
};
scenario.lorebook_delta3 = function(){
  say('', tl("Last night we recieved another shipment of god blood."));
  say('', tl("I can't see the one who delivers it to us, but one of my collegues can. He describes her as a young woman dressed in black and white."));
  say('', tl("My daughter has been chosen as the next candidate. She has shown high potential, but I've seen this go wrong too many times."));
  say('', tl("I can only pray that everything goes well."));
};
scenario.lorebook_deep = function(){
  say('', tl("He showed high affinity for the disease."));
  say('', tl("Where most would wither and die, he only grew stronger."));
  say('', tl("There's something special about people like this. I think they have a special bond with the gods."));
  say('', tl("They are the prime candidates for ascension."));
};
scenario.sisterletter = function(){
  say('', tl("Dear {0},", switches.name));
  say('', tl("Thank you for choosing me."));
  say('', tl("Love, your sister."));
};
scenario.basementlocked = function(){
  if (Date.now() - temp.locktimer < 5000) {
    return;
  }
  say('', tl("The hatch is locked."));
  say(function(){
    return temp.locktimer = Date.now();
  });
};
mapdefaults = {
  edges: 'normal',
  outside: false,
  spawning: false,
  bg: 'forest',
  hasnight: false,
  mobcap: 4,
  mobtime: 7000,
  zone: 'tuonen'
};
zones = {
  'default': {
    musiclist: ['battle']
  },
  tuonen: {
    music: function(){
      if (switches.soulcluster) {
        return '2dpassion';
      } else {
        return 'towertheme';
      }
    },
    musiclist: ['2dpassion', 'towertheme'],
    cg: function(){
      if (switches.soulcluster) {
        return 'cg_tower0';
      } else {
        return 'cg_tower2';
      }
    }
  },
  delta: {
    music: function(){
      if (switches.soulcluster) {
        return '2dpassion';
      } else {
        return 'towertheme';
      }
    },
    musiclist: ['2dpassion', 'towertheme'],
    cg: function(){
      if (switches.soulcluster) {
        return 'cg_pest';
      } else {
        return 'cg_pest_night';
      }
    }
  },
  tower: {
    music: function(){
      if (switches.zmapp) {
        return 'towertheme';
      } else {
        return 'hidingyourdeath';
      }
    },
    musiclist: ['towertheme', 'hidingyourdeath'],
    cg: function(){
      if (switches.soulcluster) {
        return 'cg_tower0';
      } else {
        return 'cg_tower2';
      }
    }
  },
  deadworld: {
    music: 'deserttheme',
    musiclist: ['deserttheme'],
    cg: 'cg_jungle'
  },
  earth: {
    music: 'hidingyourdeath',
    musiclist: ['hidingyourdeath', 'towertheme'],
    cg: 'cg_earth'
  },
  'void': {
    music: 'distortion',
    musiclist: ['distortion'],
    cg: 'cg_abyss'
  }
};
mapdata = {
  hub: {
    outside: true,
    spawning: Mob.types.slime,
    bg: function(t){
      if (player.water_depth > 0 && t === 'water') {
        return waterbg();
      } else if (!switches.soulcluster) {
        return 'forest_night';
      } else {
        return 'forest';
      }
    },
    hasnight: true,
    sun: function(){
      this.scale = {
        x: 1,
        y: 1
      };
      return true;
    }
  },
  tunnel: {
    spawning: Mob.types.ghost,
    bg: 'dungeon'
  },
  tunneldeep: {
    spawning: Mob.types.fish,
    mobcap: 6,
    mobtime: 6000,
    bg: 'dungeon'
  },
  deadworld: {
    edges: 'clamp',
    outside: true,
    bg: function(t){
      if (player.water_depth > 0 && t === 'water') {
        return waterbg();
      } else {
        return 'jungle';
      }
    },
    mobcap: 5,
    spawning: function(tile){
      var that, ref$, a;
      switch ((that = tile != null ? (ref$ = tile.properties) != null ? ref$.terrain : void 8 : void 8) ? that : 'water') {
      case 'water':
        return Mob.types.bat;
      case 'gravel':
        return Mob.types[(a = ['slime', 'corpse'])[Math.random() * a.length | 0]];
      default:
        return Mob.types[(a = ['ghost', 'slime', 'flytrap'])[Math.random() * a.length | 0]];
      }
    },
    sun: function(){
      this.x = 50;
      this.y = game.height / 2 - 50;
      this.scale = {
        x: 0.75,
        y: 0.48
      };
    },
    zone: 'deadworld'
  },
  deathtunnel: {
    zone: 'deadworld',
    spawning: function(){
      var a;
      return Mob.types[(a = ['ghost', 'slime', 'slime'])[Math.random() * a.length | 0]];
    },
    mobcap: 5,
    bg: 'dungeon'
  },
  deathdomain: {
    edges: 'clamp',
    outside: true,
    zone: 'deadworld',
    spawning: function(){
      var a;
      return Mob.types[(a = ['ghost', 'slime', 'slime'])[Math.random() * a.length | 0]];
    },
    mobcap: 5,
    bg: 'jungle',
    sun: function(){
      this.x = 50;
      this.y = game.height / 2 - 50;
      this.scale = {
        x: 0.75,
        y: 0.48
      };
    }
  },
  castle: {
    zone: 'deadworld',
    bg: 'castle'
  },
  towertop: {
    edges: 'clamp',
    hasnight: true,
    bg: 'tower',
    zone: 'tower'
  },
  tower0: {
    zone: 'tower'
  },
  tower2: {
    zone: 'tower'
  },
  tower1: {
    zone: 'tower',
    spawning: function(){
      if (switches.progress === 'curebeat') {
        return Mob.types.wraith;
      } else {
        return false;
      }
    },
    bg: 'dungeon',
    mobtime: 9000
  },
  ebolaroom: {
    zone: 'tower'
  },
  delta: {
    zone: 'delta',
    outside: true,
    bg: function(t){
      if (player.water_depth > 0 && t === 'water') {
        return waterbg();
      } else if (!switches.soulcluster) {
        return 'forest_night';
      } else {
        return 'forest';
      }
    },
    mobcap: 5,
    mobtime: 9000,
    hasnight: true,
    sun: function(){
      this.x = game.width / 2;
      this.y = game.height - 30;
      this.scale = {
        x: 0.75,
        y: 0.48
      };
    },
    spawning: function(tile){
      var that, ref$, a;
      switch ((that = tile != null ? (ref$ = tile.properties) != null ? ref$.terrain : void 8 : void 8) ? that : 'water') {
      case 'water':
        return Mob.types[(a = ['fish', 'fish', 'wisp', 'arrow'])[Math.random() * a.length | 0]];
      case 'mountain':
        return Mob.types[(a = ['arrow', 'arrow', 'arrow', 'slime'])[Math.random() * a.length | 0]];
      default:
        return Mob.types[(a = ['arrow', 'arrow', 'arrow', 'wisp', 'wisp', 'wisp', 'slime'])[Math.random() * a.length | 0]];
      }
    }
  },
  earth: {
    zone: 'earth',
    edges: 'clamp',
    bg: function(t){
      if (t === 'snow') {
        return 'earth_snow';
      } else {
        return 'earth';
      }
    },
    mobcap: 3,
    mobtime: 9000,
    spawning: function(tile){
      var that, ref$;
      switch ((that = tile != null ? (ref$ = tile.properties) != null ? ref$.terrain : void 8 : void 8) ? that : 'ground') {
      case 'snow':
        return Mob.types.arrow;
      default:
        return Mob.types.slime;
      }
    }
  },
  earth2: {
    zone: 'earth',
    edges: 'clamp',
    bg: 'earth',
    spawning: function(tile){
      var that, ref$;
      switch ((that = tile != null ? (ref$ = tile.properties) != null ? ref$.terrain : void 8 : void 8) ? that : 'ground') {
      case 'mountain':
        return Mob.types.arrow;
      default:
        return Mob.types.slime;
      }
    }
  },
  earth3: {
    zone: 'earth',
    edges: 'clamp',
    bg: 'earth'
  },
  basement1: {
    zone: 'earth',
    spawning: Mob.types.slime,
    bg: 'dungeon'
  },
  basement2: {
    zone: 'earth',
    bg: 'dungeon'
  },
  necrohut: {
    zone: 'earth'
  },
  shrine: {
    zone: 'earth'
  },
  labdungeon: {
    zone: 'earth',
    bg: 'lab',
    mobcap: 3,
    mobtime: 10000,
    spawning: function(tile){
      var that, ref$, a;
      switch ((that = tile != null ? (ref$ = tile.properties) != null ? ref$.terrain : void 8 : void 8) ? that : 'ground') {
      case 'floor':
        return Mob.types.slime;
      default:
        return Mob.types[(a = ['slime', 'slime', 'glitch'])[Math.random() * a.length | 0]];
      }
    }
  },
  labhall: {
    zone: 'earth',
    bg: 'lab'
  },
  lab: {
    zone: 'earth',
    bg: 'lab'
  },
  'void': {
    zone: 'void',
    edges: 'clamp',
    bg: 'void',
    outside: true,
    mobtime: 9000,
    spawning: Mob.types.glitch,
    sun: function(){
      this.scale = {
        x: 0,
        y: 0
      };
    }
  }
};
function getmapdata(map, field){
  var ref$, that;
  if (field == null) {
    field = map;
    map = switches.map;
  }
  if ((that = ((ref$ = mapdata[map]) != null ? ref$[field] : void 8)) != null) {
    return that;
  } else {
    return mapdefaults[field];
  }
}
function if_in_water(bg1, bg2){
  if (player.water_depth > 0) {
    return bg1;
  } else {
    return bg2;
  }
}
function waterbg(){
  if (getmapdata('zone') === 'deadworld') {
    return 'water_dead';
  } else if (!switches.soulcluster) {
    return 'water_night';
  } else {
    return 'water';
  }
}
tiledata = {};
function create_backdrop(){
  var waterTile, sun;
  if (backdrop != null) {
    game.stage.addChild(backdrop);
    game.stage.setChildIndex(backdrop, 0);
    return;
  }
  backdrop = game.add.group(null, 'backdrop', true);
  game.stage.setChildIndex(backdrop, 0);
  backdrop.destroy = function(){
    this.parent.removeChild(this);
  };
  backdrop.water = waterTile = new Phaser.TileSprite(game, 0, 0, 320, 320, 'water');
  backdrop.addChild(waterTile);
  waterTile.marginX = TS * 11;
  waterTile.marginY = TS * 12;
  waterTile.width = game.width + waterTile.marginX;
  waterTile.height = game.height + waterTile.marginY;
  waterTile.timer = Date.now();
  waterTile.psuedoFrame = 0;
  waterTile.update = function(){
    if (game.time.elapsedSince(this.timer) > 333) {
      this.timer = Date.now();
      if (this.psuedoFrame < 3) {
        this.psuedoFrame++;
      } else {
        this.psuedoFrame = 0;
      }
    }
    this.x = -64 - game.camera.x % 64 - this.psuedoFrame * TS;
    this.y = -64 - game.camera.y % 64 - (game.time.now / 100 | 0) * 100 / 70 % (TS * 4);
  };
  backdrop.sun = sun = backdrop.create(game.width / 2, 30, 'sun');
  sun.animations.add('simple', null, 6, true);
  sun.animations.play('simple');
  sun.anchor.setTo(0.5);
  sun.update = function(){
    var that, hgw, hgh, x, y;
    if (that = getmapdata('sun')) {
      if (true !== that.apply(this, arguments)) {
        return;
      }
    }
    if (!nodes.sun) {
      return;
    }
    hgw = game.width / 2;
    hgh = game.height / 2;
    x = nodes.sun.x - (game.camera.x + hgw);
    y = nodes.sun.y - (game.camera.y + hgh);
    if (Math.abs(x) > WIDTH) {
      x = WIDTH * Math.sign(x);
    }
    if (Math.abs(y) > HEIGHT) {
      y = HEIGHT * Math.sign(y);
    }
    this.x = hgw + x / 2;
    this.y = hgh + y / 2;
  };
}
function tile_swap(){
  var i$, ref$, len$, tileset, n;
  if (switches.soulcluster || !getmapdata('hasnight')) {
    return;
  }
  for (i$ = 0, len$ = (ref$ = map.tilesets).length; i$ < len$; ++i$) {
    tileset = ref$[i$];
    n = null;
    switch (tileset.name) {
    case 'tiles':
      n = 'tiles_night';
      break;
    case 'townhouse':
      n = 'townhouse_tiles_night';
      break;
    case 'tower':
      n = 'tower_tiles_night';
      break;
    case 'delta':
      n = 'delta_tiles_night';
    }
    if (n) {
      tileset.setImage(game.cache.getImage(n));
      map.tile_layer.dirty = true;
    }
  }
}
function fringe_swap(n){
  if (switches.soulcluster || !getmapdata('hasnight')) {
    return n;
  }
  switch (n) {
  case 'tiles':
    return 'tiles_night';
  case 'townhouse_tiles':
    return 'townhouse_tiles_night';
  case 'tower_tiles':
    return 'tower_tiles_night';
  case '1x1':
    return '1x1_night';
  case '1x2':
    return '1x2_night';
  case 'delta_tiles':
    return 'delta_tiles_night';
  default:
    return n;
  }
}
function load_map(name, filename){
  game.load.tilemap(name, "maps/" + filename, null, Phaser.Tilemap.TILED_JSON);
}
function create_map(name){
  var map, i$, ref$, len$, layer, tileset;
  map = game.add.tilemap(name);
  map.namedLayers = {};
  for (i$ = 0, len$ = (ref$ = game.cache.getTilemapData(name).data.layers).length; i$ < len$; ++i$) {
    layer = ref$[i$];
    switch (false) {
    case layer.type !== 'tilelayer':
      map[layer.name] = map.namedLayers[layer.name] = map.createLayer(layer.name);
      if (getmapdata('edges') === 'loop') {
        map[layer.name].wrap = true;
      }
      break;
    case layer.name !== 'object_layer':
      map.object_cache = layer.objects;
    }
  }
  for (i$ = 0, len$ = (ref$ = game.cache.getTilemapData(name).data.tilesets).length; i$ < len$; ++i$) {
    tileset = ref$[i$];
    map.addTilesetImage(tileset.name, game.cache.checkImageKey(tileset.name)
      ? tileset.name
      : tileset.name + "_tiles");
  }
  return map;
}
function create_tilemap(){
  var override, i$, ref$, len$, y, j$, ref1$, len1$, x, tile, tp, ftile;
  if (!game.cache.checkTilemapKey(switches.map)) {
    switches.map = STARTMAP;
  }
  map = create_map(switches.map);
  override = map.destroy;
  map.destroy = function(){
    var layer;
    for (layer in map.namedLayers) {
      override.apply(this, arguments);
      map.namedLayers[layer].destroy();
    }
  };
  for (i$ = 0, len$ = (ref$ = map.tile_layer.layer.data).length; i$ < len$; ++i$) {
    y = i$;
    for (j$ = 0, len1$ = (ref1$ = map.tile_layer.layer.data[y]).length; j$ < len1$; ++j$) {
      x = j$;
      tile = ref1$[j$];
      if ((tp = tile.properties).terrain === 'fringe' || tp.terrain === 'overpass') {
        ftile = fringe.addChild(
        new Doodad(x * TS, y * TS, fringe_swap(tp.fringe_key), null, false));
        ftile.crop(new Phaser.Rectangle(TS * tp.fringe_x, TS * tp.fringe_y, TS, TS));
        if (tp.terrain === 'overpass') {
          updatelist.push(ftile);
          ftile.update = fn$;
        }
      }
    }
  }
  tile_swap();
  function fn$(){
    this.visible = player.bridgemode === 'under';
  }
}
function tile_point_collision(o, point, layer, water, land){
  return tile_offset_collision(o, {
    x: point.x - o.x,
    y: point.y - o.y
  }, layer, water, land);
}
function tile_offset_collision(o, offset, layer, water, land){
  var o2;
  if (!o.body) {
    return;
  }
  o2 = {
    body: {
      position: {
        x: o.body.position.x + offset.x,
        y: o.body.position.y + offset.y
      },
      tilePadding: o.body.tilePadding,
      width: o.body.width,
      height: o.body.height
    },
    bridgemode: o.bridgemode
  };
  return tile_collision(o2, layer, water, land, o);
}
function tile_collision(o, layer, water, land, oo){
  var rect, tiles, i$, len$, i, tile;
  layer == null && (layer = map.namedLayers.tile_layer);
  oo == null && (oo = o);
  if (!o.body) {
    return;
  }
  rect = {
    x: o.body.position.x - o.body.tilePadding.x,
    y: o.body.position.y - o.body.tilePadding.y,
    w: o.body.width + o.body.tilePadding.x,
    h: o.body.height + o.body.tilePadding.y
  };
  tiles = getTiles.call(layer, rect, true);
  for (i$ = 0, len$ = tiles.length; i$ < len$; ++i$) {
    i = i$;
    tile = tiles[i$];
    if (!tile_passable(tile, water, land, oo)) {
      return true;
    }
    if (check_dcol(tile, rect, oo)) {
      return true;
    }
  }
  return false;
}
function check_dcol(tile, rect, o){
  var dcol, i$, len$, i, d;
  o == null && (o = player);
  if (!tile) {
    return false;
  }
  if (tile.properties.terrain === 'fringe' || tile.properties.terrain === 'overpass' && o.bridgemode === 'under') {
    if (tile.properties.dcol === '0,1,0,1') {
      return check_dcol(map.getTile(tile.x + 1, tile.y, map.tile_layer), {
        x: rect.x + TS,
        y: rect.y,
        w: rect.w,
        h: rect.h
      }, o);
    } else {
      return check_dcol(map.getTile(tile.x, tile.y - 1, map.tile_layer), {
        x: rect.x,
        y: rect.y - TS,
        w: rect.w,
        h: rect.h
      }, o);
    }
  }
  if (tile.properties.dcol) {
    dcol = split$.call(tile.properties.dcol, ',');
    for (i$ = 0, len$ = dcol.length; i$ < len$; ++i$) {
      i = i$;
      d = dcol[i$];
      dcol[i] = +d;
    }
    if (dcol[0] > 0 && rect_collision(rect, {
      x: tile.left,
      y: tile.top,
      w: tile.width,
      h: dcol[0]
    })) {
      return true;
    }
    if (dcol[1] > 0 && rect_collision(rect, {
      x: tile.right - dcol[1],
      y: tile.top,
      w: dcol[1],
      h: tile.height
    })) {
      return true;
    }
    if (dcol[2] > 0 && rect_collision(rect, {
      x: tile.left,
      y: tile.bottom - dcol[2],
      w: tile.width,
      h: dcol[2]
    })) {
      return true;
    }
    if (dcol[3] > 0 && rect_collision(rect, {
      x: tile.left,
      y: tile.top,
      w: dcol[3],
      h: tile.height
    })) {
      return true;
    }
  }
  return false;
}
function getTiles(rect, returnnull){
  var tx, ty, tw, th, results, i$, to$, yy, j$, to1$, xx;
  returnnull == null && (returnnull = true);
  tx = Math.floor(rect.x / TS);
  ty = Math.floor(rect.y / TS);
  tw = Math.ceil((rect.x + rect.w) / TS) - tx;
  th = Math.ceil((rect.y + rect.h) / TS) - ty;
  results = [];
  for (i$ = ty, to$ = ty + th; i$ < to$; ++i$) {
    yy = i$;
    for (j$ = tx, to1$ = tx + tw; j$ < to1$; ++j$) {
      xx = j$;
      results.push(map.getTile(xx, yy, map.tile_layer, !returnnull));
    }
  }
  return results;
}
override_getTile = Phaser.Tilemap.prototype.getTile;
Phaser.Tilemap.prototype.getTile = function(x, y, layer, nonNull){
  nonNull == null && (nonNull = false);
  switch (getmapdata('edges')) {
  case 'loop':
    if (y >= this.height) {
      y %= this.height;
    } else {
      while (y < 0) {
        y += this.height;
      }
    }
    if (x >= this.width) {
      x %= this.width;
    } else {
      while (x < 0) {
        x += this.width;
      }
    }
    break;
  case 'clamp':
    if (y >= this.height) {
      y = this.height - 1;
    } else if (y < 0) {
      y = 0;
    }
    if (x >= this.width) {
      x = this.width - 1;
    } else if (x < 0) {
      x = 0;
    }
  }
  return override_getTile.apply(this, arguments);
};
function tile_passable(tile, water, land, o){
  var ref$;
  water == null && (water = switches.water_walking);
  land == null && (land = true);
  o == null && (o = player);
  if (tile == null || tile === false || tile.properties.terrain == null) {
    return water && switches.outside;
  }
  if (tile.properties.terrain === 'water') {
    return water;
  }
  if (tile.properties.terrain === 'overpass' && tile.properties.dcol === '0,1,0,1' && o.bridgemode === 'under') {
    return tile_passable(map.getTile(tile.x + 1, tile.y, map.tile_layer), water, land, o);
  }
  if (tile.properties.terrain === 'fringe' || tile.properties.terrain === 'overpass' && o.bridgemode === 'under') {
    return tile_passable(map.getTile(tile.x, tile.y - 1, map.tile_layer), water, land, o);
  }
  if (tile.properties.terrain === 'wall') {
    return false;
  }
  if (getmapdata('edges') === 'clamp' && (tile.x === 0 || tile.x === map.width - 1 || tile.y === 0 || tile.y === map.height - 1)) {
    return false;
  }
  if (tile.properties.terrain === 'mountain' && ((ref$ = getTileUnder(o)) != null ? ref$.properties.terrain : void 8) === 'overpass' && o.bridgemode === 'under') {
    return false;
  }
  return land;
}
function getTileUnder(o){
  return map.getTile(o.x / TS | 0, o.y / TS | 0, map.tile_layer, true);
}
/* #UNUSED
function tile_line (p1, p2)
    #returns all tiles along a line betwixt two points
    if p1.worldX? then p1 = x: p1.x, y: p1.y
    else p1 = x: Math.floor(p1.x/TS), y: Math.floor(p1.y/TS)
    if p2.worldX? then p2 = x: p2.x, y: p2.y
    else p2 = x: Math.floor(p2.x/TS), y: Math.floor(p2.y/TS)
    while p1.x is not p2.x and p1.y is not p2.y
        tile = map.get-tile p1.x, p1.y, map.tile_layer, true
        return false if !tile
        return false unless tile_passable tile
        return false if tile.properties.dcol?
        dist = x: p2.x - p1.x, y: p2.y - p1.y
        if Math.abs(dist.x) > Math.abs(dist.y)
            p1.x += Math.sign dist.x
        else
            p1.y += Math.sign dist.y
    #end when we're at the end point
    return true
*/
/*
gettilesoverride=Phaser.TilemapLayer::getTiles
Phaser.TilemapLayer::getTiles=!(x, y, width, height, collides=false, interestingFace=false)->
    #return null
    #return gettilesoverride ...
    fetchAll = not(collides or interestingFace)
    x=@_fixX x
    y=@_fixY y
    tx=Math.floor x/@_mc.cw*@scale.x
    ty=Math.floor y/@_mc.ch*@scale.y
    tw=(Math.ceil (x+width)/@_mc.cw*@scale.x) - tx
    th=(Math.ceil (y+height)/@mc.ch*@scale.y) - ty
    while @_results.length
        @_results.pop!
    for wy from ty til ty+th
        for wx from tx til tx+tw
            if wx<0 then wx=0
            else if wx>=@map.width then wx=@map.width - 1
            if wy<0 then wy=0
            else if wy>=@map.height then wy=@map.height - 1
            row=@layer.data[wy]
            if row && row[wx]
                if fetchAll or row[wx].isInteresting collides interestingFace
                    @_results.push row[wx]
    return @_results.slice!
*/
renderregionoverride = Phaser.TilemapLayer.prototype.renderRegion;
Phaser.TilemapLayer.prototype.renderRegion = function(scrollX, scrollY, left, top, right, bottom){
  var context, width, height, tw, th, tilesets, lastAlpha, baseX, baseY, normStartX, normStartY, y, ymax, ty, yy, row, x, xmax, tx, xx, tile, index, set;
  if (getmapdata('edges') === 'loop') {
    return renderregionoverride.apply(this, arguments);
  }
  context = this.context;
  width = this.layer.width;
  height = this.layer.height;
  tw = this._mc.tileWidth;
  th = this._mc.tileHeight;
  tilesets = this._mc.tilesets;
  lastAlpha = NaN;
  if (!this._wrap && getmapdata('edges') !== 'clamp') {
    if (left <= right) {
      left = Math.max(0, left);
      right = Math.min(width - 1, right);
    }
    if (top <= bottom) {
      top = Math.max(0, top);
      bottom = Math.min(height - 1, bottom);
    }
  }
  baseX = left * tw - scrollX;
  baseY = top * th - scrollY;
  normStartX = left;
  normStartY = top;
  context.fillStyle = this.tileColor;
  y = normStartY;
  ymax = bottom - top;
  ty = baseY;
  while (ymax >= 0) {
    yy = y;
    if (yy >= height) {
      yy = height - 1;
    } else if (yy < 0) {
      yy = 0;
    }
    row = this.layer.data[yy];
    x = normStartX;
    xmax = right - left;
    tx = baseX;
    while (xmax >= 0) {
      xx = x;
      if (xx >= width) {
        xx = width - 1;
      } else if (xx < 0) {
        xx = 0;
      }
      tile = row[xx];
      if (!tile || tile.index < 0) {
        x++;
        xmax--;
        tx += tw;
        continue;
      }
      index = tile.index;
      set = tilesets[index];
      if (set === undefined) {
        set = this.resolveTileset(index);
      }
      if (tile.alpha !== lastAlpha && !this.debug) {
        context.globalAlpha = tile.alpha;
        lastAlpha = tile.alpha;
      }
      if (set) {
        if (tile.rotation || tile.flipped) {
          context.save();
          context.translate(tx + tile.centerX, ty(+tile.centerY));
          context.rotate(tile.rotation);
          if (tile.flipped) {
            context.scale(-1, 1);
          }
          set.draw(context, -tile.centerX, -tile.centerY, index);
          context.restore();
        } else {
          set.draw(context, tx, ty, index);
        }
      } else if (this.debugSettings.missingImageFill) {
        context.fillStyle = this.debugSettings.missingImageFill;
        context.fillRect(tx, ty, tw, th);
      }
      if (tile.debug && this.debugSettings.debuggedTileOverfill) {
        context.fillStyle = this.debugSettings.debuggedTileOverfill;
        context.fillRect(tx, ty, tw, th);
      }
      x++;
      xmax--;
      tx += tw;
    }
    y++;
    ymax--;
    ty += th;
  }
};
Transition = (function(){
  Transition.displayName = 'Transition';
  var prototype = Transition.prototype, constructor = Transition;
  function Transition(duration, step, finish, smoothness, cinematic, context1, context2){
    this.duration = duration;
    this.step = step;
    this.finish = finish;
    this.smoothness = smoothness != null ? smoothness : 0;
    this.cinematic = cinematic != null ? cinematic : true;
    this.context1 = context1 != null ? context1 : this;
    this.context2 = context2 != null ? context2 : this;
    this.starttime = Date.now();
    constructor.list.push(this);
  }
  Transition.list = [];
  Transition.update = function(){
    var i$, ref$, item;
    for (i$ = (ref$ = constructor.list).length - 1; i$ >= 0; --i$) {
      item = ref$[i$];
      item.update();
    }
  };
  Transition.prototype.update = function(){
    var t, ref$, ref1$;
    t = (Date.now() - this.starttime) / this.duration;
    if (this.smoothness > 0) {
      t = (t * this.smoothness | 0) / this.smoothness;
    }
    if ((ref$ = this.step) != null) {
      ref$.call(this.context1, 1 < t ? 1 : t);
    }
    if (t >= 1) {
      constructor.list.splice(constructor.list.indexOf(this), 1);
      if ((ref1$ = this.finish) != null) {
        ref1$.call(this.context2);
      }
    }
  };
  Transition.timeout = function(dur, fin, cinematic, context){
    var transition;
    cinematic == null && (cinematic = false);
    transition = new Transition(dur, null, fin, null, cinematic, null, context);
  };
  Transition.battle = function(dur1, dur2, smoothness){
    var transition;
    smoothness == null && (smoothness = 5);
    sound.play('encounter');
    transition = new Transition(dur1, function(t){
      var scale, rot;
      scale = t * 5 + 1;
      rot = t * 45;
      pixel.canvas.style.transform = "scale(" + scale + "," + scale + ") rotate(" + rot + "deg)";
      return pixel.canvas.style.opacity = -Math.pow(t, 4) + 1;
    }, function(){
      pixel.canvas.style.opacity = 0;
      return setTimeout(function(){
        pixel.canvas.style.transform = "";
        start_battle2();
        new Transition(dur2, function(t){
          return pixel.canvas.style.opacity = t;
        }, null, smoothness);
      }, 500);
    }, smoothness);
    transition.dur2 = dur2;
    return transition;
  };
  Transition.critical = function(amplitude, duration, cx, cy){
    var transition;
    pixel.canvas.style.transformOrigin = (cx * 100 / WIDTH | 0) + '% ' + (cy * 100 / HEIGHT | 0) + '%';
    transition = new Transition(duration, function(t){
      var scale;
      scale = 1 + Math.sin(Math.PI * t) * amplitude;
      return pixel.canvas.style.transform = "scale(" + scale + "," + scale + ")";
    }, function(){
      pixel.canvas.style.transform = '';
      return pixel.canvas.style.transformOrigin = '';
    }, 0, false);
  };
  Transition.fade = function(fadetime, sleeptime, midcall, fincall, smoothness, cinematic, context){
    var transition;
    transition = new Transition(fadetime, function(t){
      return pixel.canvas.style.opacity = 1 - t;
    }, function(){
      var this$ = this;
      if (typeof this.midcall === 'function') {
        this.midcall.call(this.context3);
      }
      return Transition.timeout(this.sleeptime, function(){
        var transition2;
        transition2 = new Transition(this$.fadetime, function(t){
          return pixel.canvas.style.opacity = t;
        }, function(){
          if (typeof this.fincall === 'function') {
            return this.fincall.call(this.context3);
          }
        }, this$.smoothness, this$.cinematic);
        transition2.context3 = this$.context3;
        return transition2.fincall = this$.fincall;
      }, cinematic);
    }, smoothness, cinematic);
    transition.midcall = midcall;
    transition.fincall = fincall;
    transition.fadetime = fadetime;
    transition.sleeptime = sleeptime;
    transition.context3 = context || transition;
    return transition;
  };
  Transition.shake = function(amplitude, wavelength, duration, decay, fincall, cinematic, context){
    var time;
    decay == null && (decay = 1);
    time = 0;
    setTimeout(shakeit, 200);
    function shakeit(){
      var p;
      if (time >= duration) {
        pixel.canvas.style.transform = "";
        if (fincall != null) {
          fincall.call(context);
        }
        return;
      }
      p = {
        x: Math.random() - 0.5,
        y: Math.random() - 0.5
      };
      p = normalize(p);
      pixel.canvas.style.transform = "translate(" + p.x * amplitude * pixel.scale + "px," + p.y * amplitude * pixel.scale + "px)";
      amplitude *= decay;
      time += wavelength;
      setTimeout(shakeit, wavelength);
    }
  };
  Transition.wiggle = function(o, times, delay, shift, fincall){
    var this$ = this;
    shift == null && (shift = 1);
    if (times > 0) {
      o.x += shift;
      setTimeout(function(){
        return this$.wiggle(o, times - 1, delay, shift * -1, fincall);
      }, delay);
    } else {
      fincall();
    }
  };
  Transition.fadeout = function(o, duration, fincall, context){
    var transition;
    transition = new Transition(duration, function(t){
      return this.alpha = 1 - t;
    }, fincall, null, false, o, context) || transition;
    return transition;
  };
  Transition.fadein = function(o, duration, fincall, context){
    var transition;
    transition = new Transition(duration, function(t){
      return this.alpha = t;
    }, fincall, null, false, o, context) || transition;
    return transition;
  };
  Transition.move = function(o, dest, duration, fincall){
    var origin, transition;
    origin = {
      x: o.x,
      y: o.y
    };
    transition = new Transition(duration, function(t){
      this.x = (dest.x - origin.x) * t + origin.x;
      return this.y = (dest.y - origin.y) * t + origin.y;
    }, fincall, null, false, o, o);
    return transition;
  };
  Transition.pan = function(dest, duration, fincall, context, cinematic){
    var origin, transition;
    cinematic == null && (cinematic = false);
    origin = {
      x: game.camera.center.x,
      y: game.camera.center.y
    };
    transition = new Transition(duration, function(t){
      return camera_center(origin.x + (dest.x - origin.x) * t, origin.y + (dest.y - origin.y) * t);
    }, fincall, null, cinematic, context, context);
    return transition;
  };
  return Transition;
}());
function fn$(){
  this.parentNode.style.display = 'none';
}
function extend$(sub, sup){
  function fun(){} fun.prototype = (sub.superclass = sup).prototype;
  (sub.prototype = new fun).constructor = sub;
  if (typeof sup.extended == 'function') sup.extended(sub);
  return sub;
}
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}
function repeatString$(str, n){
  for (var r = ''; n > 0; (n >>= 1) && (str += str)) if (n & 1) r += str;
  return r;
}
function in$(x, xs){
  var i = -1, l = xs.length >>> 0;
  while (++i < l) if (x === xs[i]) return true;
  return false;
}