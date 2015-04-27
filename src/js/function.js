function highlight(name){
	var list = document.getElementsByClassName(name);
	for (var i = 0; i < list.length; i++) {
		list[i].style.background = "#fff";
	}
}

function removeHighlight() {
	$(".code identifier").each(function removeHighlight() {
		$(this).css("background", "none");
	});
}

$(function expandCollapse(){
	$('.code').find('braces').click(function toggleBlock(){
		$(this).parent().children('item').toggle();
	});
});

// highlight identifier with the same class where the class of an identifier can be his name + an Id
$(document).ready(function highlightIdentifiers(){
	$("identifier").hover(
		function (){
			highlight($(this).attr('class'));
		},
		function (){ 
			removeHighlight();
		});
});


	
		// $(".declaration").each(function addIdToDeclaration(i, v) {
		// 	$(this).parent('declaration').data('identifier', $(this).text());
		// });

		// function simple_tooltip(target_items, name){
		// 	$(target_items).each(function(i){
		// 		$("body").append("<div class='"+name+"' id='"+name+i+"'><p>"+$(this).attr('title')+"</p></div>");
		// 		var my_tooltip = $("#"+name+i);

		// 		$(this).removeAttr("title").mouseover(function(){
		// 			my_tooltip.css({opacity:0.8, display:"none"}).fadeIn(0);
		// 		}).mousemove(function(kmouse){
		// 			my_tooltip.css({left:kmouse.pageX+15, top:kmouse.pageY+15});
		// 		}).mouseout(function(){
		// 			my_tooltip.fadeOut(0);
		// 		});
		// 	});
		// }
		// $(document).ready(function(){
		// 	simple_tooltip("identifier","tooltip");
		// });