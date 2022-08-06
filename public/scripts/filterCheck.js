var doc = document.getElementById('filterChoice');
doc.onchange = (event) => {
    var inputText = event.target.value;
    window.location.href = "/workouts?filter="+inputText;
}