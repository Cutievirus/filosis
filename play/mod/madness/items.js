items.madness_bloodscroll = {
  name: "Blood Scroll",
  type: Item.CONSUME,
  sicon: 'item_key',
  iconx: 5,
  icony: 1,
  desc: "Perform a sacrifice to enhance attack and speed.",
  usebattle: function(target){
    var i$, ref$, len$, buff, results$ = [];
    target.inflict(buffs.bloodboost);
    target.inflict(buffs.bleed);
    for (i$ = 0, len$ = (ref$ = target.buffs).length; i$ < len$; ++i$) {
      buff = ref$[i$];
      if (buff.name === 'bleed') {
        results$.push(buff.duration = 999);
      }
    }
    return results$;
  },
  target: 'ally',
  attributes: ['spell']
};