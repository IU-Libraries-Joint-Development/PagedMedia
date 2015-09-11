function show_form(type) {
    divs = document.getElementsByClassName('popup_alternate_div');
    for (i = 0; i < divs.length; i++) {
      divs[i].style.display = 'none';
    }

    document.getElementById('form_for_' + type).style.display = 'inherit';
};

function show_sibling_popup() {
    window.open("/sibling_popup/show", "_blank",
                "location=no,menubar=no,status=no,toolbar=no,height=300,width=400");
}
