function show_add_page_form(){
    if($('#add_page_form').css('display') == 'none'){
      $('#add_page_form').slideDown("slow",function(){
        $('#add_page').toggle();
        $('#cancel_add_page').toggle();
      });
    }else{
      $('#add_page_form').slideUp("slow",function(){
        $('#add_page').toggle();
        $('#cancel_add_page').toggle();  
      });
    }
}