// Keep everything in anonymous function, called on window load.
if(window.addEventListener) {
window.addEventListener('load', function () {
  var canvas, context;

  // Initialization sequence.
  function init () {
    
    var myWebSocket = new WebSocket("ws://localhost:50000/websession");
    
    myWebSocket.onopen = function(evt) { alert("Connection open ..."); };
    // myWebSocket.onmessage = function(evt) { alert( "Received Message:  "  +  evt.data); };
    myWebSocket.onmessage = function (evt)
      {
	 var x, y;

    // Get the mouse position relative to the canvas element.
    /*if (ev.layerX || ev.layerX == 0) { // Firefox
      x = ev.layerX;
      y = ev.layerY;
    } else if (ev.offsetX || ev.offsetX == 0) { // Opera
      x = ev.offsetX;
      y = ev.offsetY;
    }*/

    // The event handler works like a drawing pencil which tracks the mouse 
    // movements. We start drawing a path made up of lines.
	 // alert(evt.data)
	 d = evt.data.split(" ");
	 id = parseInt(d[0]);
	 x= parseInt(d[1]);
	 y=parseInt(d[2]);
    if (!started) {
      context.beginPath();
      context.moveTo(x, y);
      started = true;
    } else {
      context.lineTo(x, y);
      context.stroke();
    }
  
      };
    myWebSocket.onclose = function(evt) { alert("Connection closed."); };

    // Find the canvas element.
    canvas = document.getElementById('imageView');
    if (!canvas) {
      alert('Error: I cannot find the canvas element!');
      return;
    }

    if (!canvas.getContext) {
      alert('Error: no canvas.getContext!');
      return;
    }

    // Get the 2D canvas context.
    context = canvas.getContext('2d');
    if (!context) {
      alert('Error: failed to getContext!');
      return;
    }

    // Attach the mousemove event handler.
    //canvas.addEventListener('mousemove', ev_mousemove, false);
  }

  // The mousemove event handler.
  var started = false;
  function ev_mousemove (ev) {
    var x, y;

    // Get the mouse position relative to the canvas element.
    /*if (ev.layerX || ev.layerX == 0) { // Firefox
      x = ev.layerX;
      y = ev.layerY;
    } else if (ev.offsetX || ev.offsetX == 0) { // Opera
      x = ev.offsetX;
      y = ev.offsetY;
    }*/

    // The event handler works like a drawing pencil which tracks the mouse 
    // movements. We start drawing a path made up of lines.
    
    if (!started) {
      context.beginPath();
      context.moveTo(x, y);
      started = true;
    } else {
      context.lineTo(x, y);
      context.stroke();
    }
  }

  init();
}, false); }
