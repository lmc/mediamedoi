$.jQTouch({
  cacheGetRequests: false,
  debug: true
});

var file_browser_template;
$(window).ready(function(){
  file_browser_preload = $('#file_browser_loader').clone().html();
});
  
$('.media_library_list li.directory a').live('jqt:before_goto',function(event){
  //if(!file_browser_template)
  //  file_browser_template = $('#file_browser').clone().html();
    
  var target = $(event.target);
  var path   = target.data('path');
  
  var new_id = 'file_browser_'+path_to_id(path);
  
  var template = $('<div></div>').html(file_browser_preload);
  
  template.attr('id',new_id);
  $('#jqt').append(template);
  
  target.data('jqt-hash','#'+new_id);

  var url = root_path+'/media_libraries';
  console.log(url);
  $.get(url,{path: path,from_browser: true},function(html){
    $('#'+new_id).html(html);
  });
});

$(window).ready(function(){
  $('#queue').bind('pageAnimationStart',function(event,args){
    if(args.direction != "in") return;
    $('#queue .ajax_target').load(root_path+'/conversion_queue_items ul');
  });
});

function path_to_id(path){
  return hex_sha1(path);
}
