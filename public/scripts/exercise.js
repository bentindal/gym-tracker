var theTime = ""

function time() {
    var d = new Date();
    var s = d.getSeconds();
    var m = d.getMinutes();
    var h = d.getHours(); 
    theTime = ("0" + h).substr(-2) + ":" + ("0" + m).substr(-2) + ":" + ("0" + s).substr(-2);
    clock.innerText = theTime
}

var clock = document.getElementById('clock2');
setInterval(time, 100);

document.getElementById("reps").setAttribute("value", lastRepCount)
document.getElementById("weight").setAttribute("value", lastWeightCount)