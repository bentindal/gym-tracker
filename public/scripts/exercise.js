var theTime = ""

function time() {
    var d = new Date();
    var s = d.getSeconds();
    var m = d.getMinutes();
    var h = d.getHours();
    theTime = ("0" + h).substr(-2) + ":" + ("0" + m).substr(-2) + ":" + ("0" + s).substr(-2);
    clock.innerText = theTime
}

function getCurrentDate(){
    let d = new Date();
    const day = d.getDate();
    const month = d.getMonth() + 1;
    const year = d.getFullYear(); 
    return ("0" + day).substr(-2) + "/" + ("0" + month).substr(-2) + "/" + year;
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
    var total1 = parseInt(time1[0])*60*60 + parseInt(time1[1])*60 + parseInt(parseInt(time1[2]))
    var total2 = parseInt(time2[0])*60*60 + parseInt(time2[1])*60 + parseInt(parseInt(time2[2]))
    var difference = total2 - total1
    var result = 0
    console.log(lastDate)
    console.log(getCurrentDate())
    if (lastDate != getCurrentDate()){
        result = ""
    }
    else if (difference > (60*60*24)){
        result = ""
    }
    else if (difference >= 3600) {
        result = "last set " + Math.floor(difference / 3600)+ " hours " + (Math.floor(difference / 60) - Math.floor(difference / 3600)*60) + " minutes " + difference % 60 + " seconds ago"
    }
    else if (difference >= 60) {
        result = "last set " + Math.floor(difference / 60) + " minutes " + difference % 60 + " seconds ago"
    }
    else if (difference < 60) {
        result = "last set " + difference + " seconds ago"
    }
    else {
        result = "error"
    }
    return result
}

function updateRestTimer() {
    var restTimer = document.getElementById("restTime")
    var total = getSecondsSince(lastTime)
    document.getElementById("restTime").innerText = total
}

function showTable(){
    document.getElementById("noWorkoutText").setAttribute("hidden", true)
}
console.log(lastRepCount)
if (lastRepCount != "") {
    showTable()
}

var clock = document.getElementById('clock2');
setInterval(time, 100);
setInterval(updateRestTimer, 100)

document.getElementById("reps").setAttribute("value", lastRepCount)
document.getElementById("weight").setAttribute("value", lastWeightCount)