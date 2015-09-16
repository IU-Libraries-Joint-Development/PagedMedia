// Run this in the dialog popup to make a specific object type's form visible.
// FIXME defunct
function show_form(type) {
    divs = document.getElementsByClassName('popup_alternate_div');
    for (i = 0; i < divs.length; i++) {
      divs[i].style.display = 'none';
    }

    document.getElementById('form_for_' + type).style.display = 'inherit';
};

// Run this in the parent window to create the dialog popup.
function show_sibling_popup(parent, prev_sib, next_sib) {
    window.open("/sibling_popup/show?parent=" + parent + "&prev_sib=" + prev_sib + "next_sib=" + next_sib,
                "_blank",
                "location=no,menubar=no,status=no,toolbar=no,height=300,width=400");
}

// Run this in the dialog popup to redirect the parent window to a new-object page.
function redirect_parent(type, parent, prev_sib, next_sib) {
    opener.location=(type + "s/new"
        + "?parent=" + parent
        + "&prev_sib=" + prev_sib
        + "&next_sib=" + next_sib);
}

// Extract value of a Select element.
function get_select_value(id) {
	selector = Document.getElementById(id);
	// TODO check null selector
	index = selector.selectedIndex;
	// TODO check no selection
	return selector.options[index].value;
}
