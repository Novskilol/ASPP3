function highlight(name){
	var list = document.getElementsByClassName(name);
	for (var i = 0; i < list.length; i++) {
		list[i].style.background = "#fff";
	}
}

function removeHighlight() {
	$(".code identifier, declaration").each(function removeHighlight() {
		$(this).css("background", "none");
	});
}

function expandCollapse(){
	$('.code').find('braces').click(function toggleBlock(){
		$(this).parent().children('item').toggle();
	});
}

function highlightIdentifiers(){
	$("identifier, declaration").hover(
		function (){
			highlight($(this).attr('class'));
		},
		function (){ 
			removeHighlight();
		});
}

// $(".declaration").each(function addIdToDeclaration(i, v) {
// 	$(this).parent('declaration').data('identifier', $(this).text());
// });

function simpleTooltip(name){
	$("identifier, declaration").each(function(i){
		$("body").append("<div class='"+name+"' id='"+name+i+"'><p>"+$(this).attr('title')+"</p></div>");
		var my_tooltip = $("#"+name+i);

		$(this).removeAttr("title").mouseover(function(){
			my_tooltip.css({opacity:0.8, display:"none"}).fadeIn(0);
		}).mousemove(function(kmouse){
			my_tooltip.css({left:kmouse.pageX+15, top:kmouse.pageY+15});
		}).mouseout(function(){
			my_tooltip.fadeOut(0);
		});
	});
}

// doesn't check indent lvl
function gotoDeclaration(){
	$(".code identifier").click(function goto() {
		var identifier = $(this).text();

		$(".code declaration").each(function search() {
			if ($(this).text() === identifier) {
				$('html, body').animate(
					{scrollTop: $(this).offset().top}, 'fast');
				return false;
			}
		});
	});
}



$(document).ready(function(){
	gotoDeclaration();
	simpleTooltip("tooltip");
	highlightIdentifiers();
	expandCollapse();
});


