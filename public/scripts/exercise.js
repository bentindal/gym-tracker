var theTime = ""

function time() {
    var d = new Date();
    var s = d.getSeconds();
    var m = d.getMinutes();
    var h = d.getHours(); 
    theTime = ("0" + h).substr(-2) + ":" + ("0" + m).substr(-2) + ":" + ("0" + s).substr(-2);
    clock.innerText = theTime
}

function getCurrentTime(){
    var d = new Date();
    var s = d.getSeconds();
    var m = d.getMinutes();
    var h = d.getHours(); 
    theTime = ("0" + h).substr(-2) + ":" + ("0" + m).substr(-2) + ":" + ("0" + s).substr(-2);
    return theTime;
}

function getSecondsSince(time) {
    var time1 = time.split(":")
    var time2 = getCurrentTime().split(":")
    console.log(time1, time2)
    var total1 = parseInt(time1[1])*60 + parseInt(parseInt(time1[2]))
    var total2 = parseInt(time2[1])*60 + parseInt(parseInt(time2[2]))
    console.log(total1, total2)
    var difference = total2 - total1
    var result = 0
    if (difference >= 60) {
        result = "last set was " + Math.floor(difference / 60) + " minutes " + difference % 60 + " seconds ago"
    }
    else {
        result = "last set was " + difference % 60 + " seconds ago"
    }
    return result
}

function updateRestTimer() {
    var restTimer = document.getElementById("restTime")
    var total = getSecondsSince(lastTime)
    document.getElementById("restTime").innerText = total
}


var clock = document.getElementById('clock2');
setInterval(time, 100);
setInterval(updateRestTimer, 1000)

document.getElementById("reps").setAttribute("value", lastRepCount)
document.getElementById("weight").setAttribute("value", lastWeightCount)