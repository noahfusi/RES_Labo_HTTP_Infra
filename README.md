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

Nous allons donc créer un fichier [index.js](https://github.com/noahfusi/RES_Labo_HTTP_Infra/blob/fb-express-dynamic/docker-image/express-image/content/index.js) qui est le point d'entrée de notre node. Dans ce fichier nous allons donc pouvoir utiliser expresse.js et chance.js. On vas utiliser .listen pour écoute surt le port 3000. On vas donc rechercher des connexions avec comme port celui demandé.
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

Dans cette partie nous voulons construire un reverse proxy pour accèder a notre server apache et à notre application web dynamic. Pour notre proxy nous allons utiliser des ip static pour faire la connexion, ce n'est pas tres robuste mais suffisant pour une demonstration. Dans létape 5 nous ferons un reverse proxy dynamic qui est beaucoup plus robuste.

Pour commencer nous avons avons besoin comme toujours d'un [dockerfile](https://github.com/noahfusi/RES_Labo_HTTP_Infra/blob/fb-apache-reverse-proxy/docker-image/apache-reverse-proxy/Dockerfile), pour ce proxis nous nous basons sur un serveur php pour le proxis et nous avons donce besoin d'une image ```FROM php:7.2-apache```. Ensuite nous copions le contenu de conf dans le docker ```COPY conf/ /etc/apache2```. Pour pouvoir utiliser le serveur apache comme proxy nous devons activer 2 modules avec la commande ```RUN a2enmod proxy proxy_http``` et pour finir nous devons activer le virtual host par défault et celui qu'on a créer avec la commande ```RUN a2ensite 000-* 001-*```.

Dans [conf](https://github.com/noahfusi/RES_Labo_HTTP_Infra/tree/fb-apache-reverse-proxy/docker-image/apache-reverse-proxy/conf) nous devons créer un dossier "sites-available", ce dossier qui sera copier dans le docker contient le virtual host par [default](https://github.com/noahfusi/RES_Labo_HTTP_Infra/blob/fb-apache-reverse-proxy/docker-image/apache-reverse-proxy/conf/sites-available/000-default.conf) et [celui](https://github.com/noahfusi/RES_Labo_HTTP_Infra/blob/fb-apache-reverse-proxy/docker-image/apache-reverse-proxy/conf/sites-available/001-reverse-proxy.conf) qui nous permet d'accèder aux autre conteneurs.Le contenu du fichier créer est le suivant :

```
<VirtualHost *:80>
	ServerName demo.res.ch
	
	#ErrorLog ${APACHE_LOG_DIR}/error.log
	#CustomLog ${APACHE_LOG_DIR}access.log combined
	
	ProxyPass "/api/identities" "http://172.17.0.2:3000/"
	ProxyPassReverse "/api/identities" "http://172.17.0.2:3000/"
	
	ProxyPass "/" "http://172.17.0.3:80/"
	ProxyPassReverse "/" "http://172.17.0.3:80/"
</VirtualHost>
```

On peut voir que l'on a défini le nom du serveur, en ce qui concerne les lignes en commentaires, l'image apache que l'on utilise ne pas à disposition la variable d'environnement "APACHE_LOG_DIR" donc voila pourqu'on on ne les utilises pas. Pour le mapping ce sont les commandes "ProxyPass" et "ProxyPassReverse" qui s'en occupe. On precise d'abors le préfix, il ne faut pas oublier les "/" sinon cela ne marche pas, vint ensuit la direction vers la machine dockers cible avec la même attention pour les "/". Nous avons 2 mapping, il faut impérativement que la plus spécifique s'execute en premier dans notre cas si la requete précise "/api/identities" le proxy va redirigé vers le docker de l'application web dynamique. Si la requête ne précise rien le proxy redirige vers le server apache.
Comme pour toute les étape précédente il faut build le docker avec la commande ```docker build -t res/apache_rp .``` et on peut le lancer avec la commande ```docker run -p 9000:80 res/apache_rp```.

## Step 4: AJAX requests with JQuery

Dans cette etape nous voulons utiliser la librairie JQuery pour envoyer des requêtes AJAX vers le [serveur dynamic](https://github.com/noahfusi/RES_Labo_HTTP_Infra/tree/ajax_jquery/docker-image/express-image) (celui s'occupe de générer des identitiés en JSON) pour mettre à jour le [server apache static](https://github.com/noahfusi/RES_Labo_HTTP_Infra/tree/ajax_jquery/docker-image/apache-php)

Pour commencer nous allons modifier le fichier [index.html](https://github.com/noahfusi/RES_Labo_HTTP_Infra/blob/ajax_jquery/docker-image/apache-php/content/index.html) qui se trouve dans le serveur apache static. Tout en bas de se fichier se trouve l'inlusion des ficheier javascript nous alors ajouter la ligne suivante.
```
<!-- Identities script-->
<script src="js/identities.js"></script> 
```
Nous devons également definir qu'est ce qui vas être mis ajour grâce a AJAX. Dans notre cas nous avons rajouter cette dans [index.html](https://github.com/noahfusi/RES_Labo_HTTP_Infra/blob/ajax_jquery/docker-image/apache-php/content/index.html) ```<h2 class="identities">ERROR !!!</h2>```, notre script modifie cette ligne et si il n'arrive pas le texte de base reste affiché.
Maintenant que nous avons fait le lien avec le script il faut aller le créer, nous allons donc nous rendre dans le dossier js et créer le fichier [identities.js](https://github.com/noahfusi/RES_Labo_HTTP_Infra/blob/ajax_jquery/docker-image/apache-php/content/js/identities.js) que nous allons ensuite editer avec le code suivant.

```
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
```
Dans ce fichier nous avons mis a disposition une fonction qui permet de récupérer le json envoyer suite à une requete aux server dynamic. Il vas egalement modifier les élément de la classe "identities" pour afficher l'email et le pseudo. La seul occurence de cette classe est celle qu'on a défini plus tôt dans l'explication. Il ne faut egalement pas oublier de lancer la fonction. Nous avons pour finir fait en sorte que cette fonction soit executé toute les 2 secondes.
