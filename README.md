# RES_Labo_HTTP_Infra
RES 2021 HTTP Infrastructure lab

## Step 1: Static HTTP server with apache httpd

Pour cette première étape nous voulons configuré un server apache http que nous allons "dockerisé" pour pouvoir servir du contenu static. Pour ce faire, nous allons utiliser cette image [php](https://hub.docker.com/_/php) disponible sur le site dockerhub qui regroupe les images dockers de la communauté. Cette image contient initaialement un serveur apache déja configuré ce qui est parfait dans notre cas.

Pour pouvoir utiliser cette image docker, il nous faut d'abors écrire un fichier [dockerfile](https://github.com/noahfusi/RES_Labo_HTTP_Infra/blob/main/docker-image/apache-php/Dockerfile) qui nous permettra de pouvoir construire notre image. Dans ce fichier nous dans un premier temps nous allons spécifier quel version d'ache nous voulons utilisé ```FROM php:7.2-apache```, ensuite nous allons copié les fichiers de configurations dans le docker avec la commande ``` COPY content/ /var/www/html/ ```. Cette commande va copier le contenu de [content](https://github.com/noahfusi/RES_Labo_HTTP_Infra/tree/main/docker-image/apache-php/content), ce dossier contient le site (fichiers html, javascript, css, ...) dans /var/html/html/ qui est le chemin que le serveur va utilisé pour afficher le site. Dans notre cas le contenu de [content](https://github.com/noahfusi/RES_Labo_HTTP_Infra/tree/main/docker-image/apache-php/content) est un template bootstrat téléchargé sur ce [site](https://startbootstrap.com/themes/landing-pages), cela nous permet d'avoir une page complète rapidement.

Maintenant que nous avons tout préparé, il reste à construire notre image. Il suffit de se trouver dans le dossier courant de lancer la commande ``` docker build -t res/apache_php .```. Miantenant que nous avons notre image nous pouvons la lancer ``` docker run -p 9000:80 res/apache_php```, dans cette commande nous faison du port mapping pour ne pas avoir de conflit avec d'autrer programme.

## Step 2: Dynamic HTTP server with express.js

Dans cette partie nous voulons écrire une application web dynamic qui a retourner des donnés json dans notre cas. Pour notre cas nous allons utiliser node.js avec une [image](https://hub.docker.com/_/node) disponible sur dockerhub. Nous allons utliser la LTS qui est la dernière version stable de node.js.

Comme pour l'étape précédente nous allons écrire un fichier [dockerfile](https://github.com/noahfusi/RES_Labo_HTTP_Infra/blob/fb-express-dynamic/docker-image/express-image/Dockerfile). Dans ce fichier nous allons commencer par précisier quelle version de node nous voulons utiliser. ```FROM node:lts```, ensuite nous allons copier le contenant dans le docker avec la commande ```COPY content/ /opt/app``` et pour finir nous allons lancer une commande a chaque démarage de notre conteneur ```CMD ["node", "/opt/app/index.js"]```. Cette commande vas effectuer le script index.js.

Pour pouvoir avoir du contenu à copier il faut d'abors ce rendre dans le dossier content[content](https://github.com/noahfusi/RES_Labo_HTTP_Infra/tree/fb-express-dynamic/docker-image/express-image/content), nous allons donc initialisé node.js avec la commande ```npm init```. Cette commande nous demande des informations, dans notre 
cas nous allons uniquement renseigné name, version, description, entry point (le fichier d'entré est déja pré écrit) et author.

Dans notre example nous voulons utiliser chance.js pour générer les informations à transmettre, pour ce faire nous allons lancer la commande ```npm install --save chance```. Nous avons également besoin d'Expresse.js pour la communication, nous alons alors utilisé cette commande ```npm install --save express```.

Nous allons donc créer un fichier index.js qui est le point d'entrée de notre node. Dans ce fichier nous allons donc pouvoir utiliser expresse.js et chance.js. On vas utiliser .listen pour écoute surt le port 3000. On vas donc rechercher des connexions avec comme port celui demandé.
```
app.listen(3000, () => {
  console.log(`Accepting HTTP request on port 3000!`)
})
```
On va également utiliser .get pour répondre aux demandes adressées l'url "/".
```
app.get('/', (req, res) => {
  res.send('(generateWebIdentity()')
})
```

Pour la réponse on veut retourner du json contenant des identités web. Cette fonction génère des identités grace à chance.js installer plus tôt. Notre identité est composé d'un lien vers un avatar, une couleur pour le nom, un email et un pseudo twitter.
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

Une fois notre fichier compléter nous allons pouvoir build l'image. Nous nous déplacons dans le fichier courant et lancons la commande ```docker build -t res/express_identities .```, nous pouvons eusuite lancer l'image avec ```docker run res/express_identities```.

## Step 3: Reverse proxy with apache (static configuration)

/api/identities
