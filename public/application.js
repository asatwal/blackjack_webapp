$(document).ready(function(){
	player_hit();
  player_stay();
  dealer_hit();
});

function player_hit() {
  $(document).on("click", "form#player_hit_form input", function() {
    $.ajax({
      type: 'POST',
      url: '/player/game/hit'
    }).done(function(msg){
      $("div#play_game").replaceWith(msg);
    });
    return false;
  });
}

function player_stay() {
  $(document).on("click", "form#player_stay_form input", function() {
    $.ajax({
      type: 'POST',
      url: '/player/game/stay'
    }).done(function(msg){
      $("div#play_game").replaceWith(msg);
    });
    return false;
  });
}

function dealer_hit() {
  $(document).on("click", "form#dealer_hit_form input", function() {
    $.ajax({
      type: 'POST',
      url: '/dealer/game/hit'
    }).done(function(msg){
      $("div#play_game").replaceWith(msg);
    });
    return false;
  });
}
