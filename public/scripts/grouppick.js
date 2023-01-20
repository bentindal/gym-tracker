var doc = document.getElementsByClassName('groupCheckbox');

selected = [];

function updateSelected() {
    selected = [];
    for (var i = 0; i < doc.length; i++) {
        if (doc[i].checked) {
            selected.push(doc[i].value);
        }
    }
    console.log(selected);

    link = "?filter="+selected[0];
    for (var i=1; i < selected.length; i++) {
        link = link + "," + selected[i];
    }
    window.location.href = "/profile2"+link;
}