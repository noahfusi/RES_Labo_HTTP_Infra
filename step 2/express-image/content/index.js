var Chance = require('chance');
var chance = new Chance();

var express = require('express');
var app = express();

app.get('/', (req, res) => {
  res.send(generateWebIdentity())
})

app.listen(3000, () => {
  console.log(`Accepting HTTP request on port 3000!`)
})

function generateWebIdentity() {
	var numberOfIdentity = chance.integer({
		min: 1,
		max: 10
	});
	console.log(numberOfIdentity)
	var identities = [];
	for (var i = 0; i < numberOfIdentity; i++){
		var avatar = chance.avatar();
		var nameColor = chance.color();
		var email = chance.email();
		var pseudo = chance.twitter();
		identities.push({
			avatar : avatar,
			nameColor : nameColor,
			email : email,
			pseudo : pseudo
		});
	}
	console.log(identities);
	return identities;
}