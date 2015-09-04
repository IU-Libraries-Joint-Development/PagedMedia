function show_form(type) {
    divs = document.getElementsByClassName('popup_alternate_div');
    for (i = 0; i < divs.length; i++) {
      divs[i].style.display = 'none';
    }

    document.getElementById('form_for_' + type).style.display = 'inherit';
};