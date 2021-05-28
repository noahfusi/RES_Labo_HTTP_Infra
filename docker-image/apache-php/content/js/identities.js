$(function() {
	
	function loadIdentities() {
		$.getJSON( "/api/identities/", function ( identities ) {
			var message = "Nobody is here";
			if ( identities.length > 0) {
				message = identities[0].email + " " + identities[0].pseudo;
			}
			$(".identities").text(message);
		});
	};
	
loadIdentities();
setInterval( loadIdentities, 2000);
});