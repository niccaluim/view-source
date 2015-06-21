function highlightTags(name) {
  $(".tag").removeClass("highlighted");
  $(".tag-" + name).addClass("highlighted");
}

function showSource(which) {
  $(".source").hide();
  $("#" + which).show();
  $(".display-mode").removeClass("highlighted");
  $("#button-" + which).addClass("highlighted");
}

$(document).ready(function (){
  $("#prettified").hide();
  // A Heisenbug sets the margin here to 640px sometimes. Running it in
  // a timeout seems to fix that.
  window.setTimeout(function (){
    $('#summary').next().css('margin-top', $('#summary').height())
  }, 1);
});
