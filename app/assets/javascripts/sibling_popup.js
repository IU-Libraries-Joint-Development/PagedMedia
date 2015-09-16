// Copyright (c) 2015 Indiana University
// All rights reserved.

// Run this in the parent window to create the dialog popup.
function show_sibling_popup(parent, prev_sib, next_sib, old_sib) {
    window.open("/sibling_popup/show?parent=" + parent + "&prev_sib=" + prev_sib + "&next_sib=" + next_sib + "&old_sib=" + old_sib,
                "_blank",
                "location=no,menubar=no,status=no,toolbar=no,height=300,width=400");
}

// Run this in the dialog popup to redirect the parent window to a new-object page.
function redirect_parent(type, parent, prev_sib, next_sib) {
    opener.location.pathname = type + "s/new"
        + "?parent=" + parent
        + "&prev_sib=" + prev_sib
        + "&next_sib=" + next_sib;
}

// Extract value of a Select element.
function get_select_value(id) {
	selector = document.getElementById(id);
	// TODO check null selector
	index = selector.selectedIndex;
	// TODO check no selection
	return selector.options[index].value;
}
