document.onkeydown = function(event) {
  var link, key;
  event = event || window.event;
  key = event.which || event.charCode;

  if(key == 38) {
    console.log("frwd");
    document.getElementById('move-forward').click();
  } else if(key == 40) {
    console.log("bkwd");
    document.getElementById('move-backward').click();
  } else if(key == 37) {
    console.log("left");
    document.getElementById('turn-left').click();
  } else if(key == 39) {
    console.log("rght");
    document.getElementById('turn-right').click();
  }

  console.log(key);
};
