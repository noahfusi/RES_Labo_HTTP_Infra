# RES_Labo_HTTP_Infra
RES 2021 HTTP Infrastructure lab

## Step 2: Dynamic HTTP server with express.js
express_identities

### Installé Express.js
- Aller dans le dossier node.js
- npm install --save express

### Utilisation Express.js

Une foit Express.js installé on peut l'utliser dans dans notre index.js, on vas utiliser .listen pour écoute surt le port 3000. On vas douc rechercher des connexions avec comme port celui demandé
```
app.listen(3000, () => {
  console.log(`Accepting HTTP request on port 3000!`)
})
```
On va également utiliser .get pour répondre aux demandes adressées l'url "/"
```
app.get('/', (req, res) => {
  res.send('(generateWebIdentity()')
})
```

Pour la réponse on veut retourner du json contenant des identités web. Cette fonction génère des identités grace à chancejs installer plus tôt. Notre identité est composé d'un lien vers un avatar, une couleur pour le nom, un email et un pseudo twitter.
``` 
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
```
## Step 3: Reverse proxy with apache (static configuration)

/api/identities
