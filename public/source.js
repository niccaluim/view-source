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
  $('#summary').next().css('margin-top', $('#summary').height())
  $("#prettified").hide();
});
