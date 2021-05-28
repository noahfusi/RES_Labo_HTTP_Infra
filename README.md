# RES_Labo_HTTP_Infra
RES 2021 HTTP Infrastructure lab

## Step 1: Static HTTP server with apache httpd

Pour cette première étape nous voulons configuré un server apache http que nous allons "dockerisé" pour pouvoir servir du contenu static. Pour ce faire, nous allons utiliser cette image [php](https://hub.docker.com/_/php) disponible sur le site dockerhub qui regroupe les images dockers de la communauté. Cette image contient initaialement un serveur apache déja configuré ce qui est parfait dans notre cas.

Pour pouvoir utiliser cette image docker, il nous faut d'abors écrire un fichier [dockerfile](https://github.com/noahfusi/RES_Labo_HTTP_Infra/blob/main/docker-image/apache-php/Dockerfile) qui nous permettra de pouvoir construire notre image. Dans ce fichier nous dans un premier temps nous allons spécifier quel version d'ache nous voulons utilisé ```FROM php:7.2-apache```, ensuite nous allons copié les fichiers de configurations dans le docker avec la commande ``` COPY content/ /var/www/html/ ```. Cette commande va copier le contenu de [content](https://github.com/noahfusi/RES_Labo_HTTP_Infra/tree/main/docker-image/apache-php/content), ce dossier contient le site (fichiers html, javascript, css, ...) dans /var/html/html/ qui est le chemin que le serveur va utilisé pour afficher le site. Dans notre cas le contenu de [content](https://github.com/noahfusi/RES_Labo_HTTP_Infra/tree/main/docker-image/apache-php/content) est un template bootstrat téléchargé sur ce [site](https://startbootstrap.com/themes/landing-pages), cela nous permet d'avoir une page complète rapidement.

Maintenant que nous avons tout préparé, il reste à construire notre image. Il suffit de se trouver dans le dossier courant de lancer la commande ``` docker build -t res/apache_php .```. Miantenant que nous avons notre image nous pouvons la lancer ``` docker run -p 9000:80 res/apache_php```, dans cette commande nous faison du port mapping pour ne pas avoir de conflit avec d'autrer programme.

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
