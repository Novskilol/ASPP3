/* change background color of elements with class name 'name' */
function highlight(name){
	var list = document.getElementsByClassName(name);
	for (var i = 0; i < list.length; i++) {
		list[i].style.background = "#383838";
	}
}

/* remove background from all elements */
function removeHighlight() {
	$(".code identifier, declaration").each(function removeHighlight() {
		$(this).css("background", "none");
	});
}

/* highlight elements with the same class */
function highlightIdentifiers(){
	$("identifier, declaration").hover(
		function (){
			highlight($(this).attr('class'));
		},
		function (){
			removeHighlight();
		});
}

/* collapse or expand code on clic (on curly braces) */
function expandCollapse(){
	$('.code').find('braces').click(function toggleBlock(){
		$(this).parent().children('item').toggle();
	});
}

/* show tooltip on hover containing prototype or doxygen documentation */
/* work for identifiers and declarations */
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

/* scroll screen to the declaration of an identifier  */
function gotoDeclaration(){
    $(".code identifier").click(function goto() {
        var list = $('declaration.'+$(this).attr('class'));
        $('html, body').animate(
             {scrollTop: list.offset().top},
             'fast');
    });
}

$(document).ready(function(){
	gotoDeclaration();
	simpleTooltip("tooltip");
	highlightIdentifiers();
	expandCollapse();
});
