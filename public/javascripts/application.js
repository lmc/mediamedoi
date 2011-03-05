$.jQTouch({
  cacheGetRequests: false,
  debug: true
});

var file_browser_template;
$.ready(function(){
  file_browser_template = $('#file_browser').clone().html();
});
  
$('.media_library_list li.directory a').live('jqt:before_goto',function(event){
  if(!file_browser_template)
    file_browser_template = $('#file_browser').clone().html();
    
  console.log('live click handler');
  var target = $(event.target);
  var path   = target.data('path');
  
  var new_id = 'file_browser_'+path_to_id(path);
  
  var template = $('<div></div>').html(file_browser_template);
  template.attr('id',new_id);
  $('#jqt').append(template)
  
  target.data('jqt-hash','#'+new_id);
});

function path_to_id(path){
  return path.replace(/ /,'_').replace(/\//,'__');
}
