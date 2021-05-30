# RES_Labo_HTTP_Infra
RES 2021 HTTP Infrastructure lab

## Préambule

Les liens présents dans cette documentation réfèrent aux images dans les différentes branches du projet.
Pour faciliter la navigation, nous avons créé des dossiers correspondant à chaque étape, contenant également les fichiers nécessaires pour créer un conteneur Docker.

## Step 1: Static HTTP server with apache httpd

Pour cette première étape nous voulons configuré un server apache http que nous allons "dockerisé" pour pouvoir servir du contenu static. Pour ce faire, nous allons utiliser cette image [php](https://hub.docker.com/_/php) disponible sur le site dockerhub qui regroupe les images dockers de la communauté. Cette image contient initaialement un serveur apache déja configuré ce qui est parfait dans notre cas.

Pour pouvoir utiliser cette image docker, il nous faut d'abors écrire un fichier [dockerfile](https://github.com/noahfusi/RES_Labo_HTTP_Infra/blob/main/docker-image/apache-php/Dockerfile) qui nous permettra de pouvoir construire notre image. Dans ce fichier nous dans un premier temps nous allons spécifier quel version d'ache nous voulons utilisé ```FROM php:7.2-apache```, ensuite nous allons copié les fichiers de configurations dans le docker avec la commande ``` COPY content/ /var/www/html/ ```. Cette commande va copier le contenu de [content](https://github.com/noahfusi/RES_Labo_HTTP_Infra/tree/main/docker-image/apache-php/content), ce dossier contient le site (fichiers html, javascript, css, ...) dans /var/html/html/ qui est le chemin que le serveur va utilisé pour afficher le site. Dans notre cas le contenu de [content](https://github.com/noahfusi/RES_Labo_HTTP_Infra/tree/main/docker-image/apache-php/content) est un template bootstrat téléchargé sur ce [site](https://startbootstrap.com/themes/landing-pages), cela nous permet d'avoir une page complète rapidement.

Maintenant que nous avons tout préparé, il reste à construire notre image. Il suffit de se trouver dans le dossier courant de lancer la commande ``` docker build -t res/apache_php .```. Miantenant que nous avons notre image nous pouvons la lancer ``` docker run -p 9000:80 res/apache_php```, dans cette commande nous faison du port mapping pour ne pas avoir de conflit avec d'autrer programme.

Pour verifier que cela marche correctement, il suffit d'ouvrir un navigateur et d'écrire "localhost:9000" dans la barre de recherche.

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

Pour vérifier cette étape, on peut utiliser Postman qui nous permet d'envoyer des requests https. Il faut utiliser postman desktop car nous sommes en local sur notre machine. Dans cette requete GET, l'url ser ```localhost:3000/api/identities/``` et il ne faut pas oublier d'ajouter un headers Host avec comme valuer ```demo.res.ch```. Cette requete va nous retourner un json d'identités.

## Step 3: Reverse proxy with apache (static configuration)

Dans cette partie nous voulons construire un reverse proxy pour accèder a notre server apache et à notre application web dynamic. Pour notre proxy nous allons utiliser des ip static pour faire la connexion, ce n'est pas tres robuste mais suffisant pour une demonstration. Dans létape 5 nous ferons un reverse proxy dynamic qui est beaucoup plus robuste.

Pour commencer nous avons avons besoin comme toujours d'un [dockerfile](https://github.com/noahfusi/RES_Labo_HTTP_Infra/blob/fb-apache-reverse-proxy/docker-image/apache-reverse-proxy/Dockerfile), pour ce proxis nous nous basons sur un serveur php pour le proxis et nous avons donce besoin d'une image ```FROM php:7.2-apache```. Ensuite nous copions le contenu de conf dans le docker ```COPY conf/ /etc/apache2```. Pour pouvoir utiliser le serveur apache comme proxy nous devons activer 2 modules avec la commande ```RUN a2enmod proxy proxy_http``` et pour finir nous devons activer le virtual host par défault et celui qu'on a créer avec la commande ```RUN a2ensite 000-* 001-*```.

Dans [conf](https://github.com/noahfusi/RES_Labo_HTTP_Infra/tree/fb-apache-reverse-proxy/docker-image/apache-reverse-proxy/conf) nous devons créer un dossier "sites-available", ce dossier qui sera copié dans le docker contient le virtual host par [default](https://github.com/noahfusi/RES_Labo_HTTP_Infra/blob/fb-apache-reverse-proxy/docker-image/apache-reverse-proxy/conf/sites-available/000-default.conf) et [celui](https://github.com/noahfusi/RES_Labo_HTTP_Infra/blob/fb-apache-reverse-proxy/docker-image/apache-reverse-proxy/conf/sites-available/001-reverse-proxy.conf) qui nous permet d'accèder aux autre conteneurs. Le contenu du fichier créé est le suivant :

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

Pour vérifier que notre revers proxy fonctionne bien nous pouvons utiliser curl qui est un autre outil pour envoyer des requêtes http. Une fois que tout nos dockers sont lancer et que l'ip de express et de apache correspond bien dans reverse proxy, nous pouvons utiliser la commande suivante ```curl -H "Host: demo.res.ch" http://localhost:9000/api/identities```.

![image](https://user-images.githubusercontent.com/48253621/120103835-d1b8e800-c151-11eb-9a39-b69be7e5c2f5.png)
On remarque que la requete retourne effectivement des objet json de nos identités. Nous pouvons aussi lancer la commande pour le serveur apache ```curl -H "Host: demo.res.ch" http://localhost:9000```

![image](https://user-images.githubusercontent.com/48253621/120103889-1b093780-c152-11eb-9d4b-2e87828610ab.png)
Cette commande nous retourne bien une page html. 

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

## Step 5:

Dans cette partie nous voulons pouvoir spécifier dynamiquement les addresses ip des différents serveurs (c'est à dire sans devoir rebuild l'image Docker à chaque fois)
Afin de réaliser cette étape, nous avons décidé d'utiliser nginx afin d'explorer un autre reverse proxy.

Nginx offre les mêmes fonctionnalités que apache pour la fonction de reverse proxy. Il suffit simplement de spécifier la configuration dans les dossiers 
```/etc/nginx```
et 
```/etc/nginx/conf.d ``` 



Nous avons décidé de créer les fichiers ```static.conf``` et ```dynamic.conf``` dans ```etc/nginx/conf.d``` qui vont respectivement stocker les adresses ip des serveurs statiques et dynamiques.

Pour pouvoir changer les ips, il faut donc modifier ces fichiers. Pour le réaliser nous profitons du fait que l'image Docker de nginx utilise un script ```docker-entrypoint.sh``` pour démarrer le service et
l'avons modifié pour écrire les ips passées en variable d'environnement par Docker dans les fichiers ```static.conf``` et ```dynamic.conf```. 

La configuration se fait très facilement :

```
user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log notice;
pid        /var/run/nginx.pid;

events {
	worker_connections 4096;
}

http {

	upstream static {
		include conf.d/static.conf;
	}

	upstream dynamic {
		include conf.d/dynamic.conf;
	}

	server {
		listen 80;

		location "/api/identities/" {

			proxy_pass "http://dynamic/";

		}

		location / {

			proxy_pass "http://static";

		}

	}	

}
```

On déclare dans la partie http deux upstream qui représentent nos deux différents services. Chaque upstream inclus le fichier de configuration contenant ses serveurs.

On déclare ensuite un serveur qui va écouter sur le port 80 et rediriger les requêtes ```api/identities``` vers le serveur http dynamique et le reste vers le serveur http statique

On va donc créer un script nommé ```docker-entrypoint.sh``` contenant le script de base de l'image avec en plus le code permettant d'écrire dans les fichiers de configuration

Les fichiers de configuration des différents services sont très simples, ils doivent simplement contenir :
```
server ip_du_serveur;
```

Ces fichiers seront générés par le script ```docker-entrypoint.sh```.

Afin d'écrire les ips des serveurs passés en variable d'environnemnet, nous avons ajouté les lignes suivantes au début du script :

```
rm -f /etc/nginx/conf.d/static.conf
rm -f /etc/nginx/conf.d/dynamic.conf
touch /etc/nginx/conf.d/static.conf
touch /etc/nginx/conf.d/dynamic.conf
printf "server ${STATIC_IP};" >> /etc/nginx/conf.d/static.conf
printf "server ${DYNAMIC_IP};" >> /etc/nginx/conf.d/dynamic.conf
```

Ces lignes vont supprimer les fichiers s'ils existent déjà et en créer de nouveaux avec les adresses ip passée en variable d'environnement STATIC_IP et DYNAMIC_IP.

Pour pouvoir lancer le reverse proxy, il faut donc spécifier les ips dans la commande Docker, par exemple :

```
docker run -d -p 9000:80 -e STATIC_IP=172.17.0.2 -e DYNAMIC_IP=172.17.0.3:3000 nginx
```
Dans notre exemple, nous utilisons le serveur http statique de l'étape 4 et le serveur express.js de l'étape 3.

On peut ensuite voir facilement si le reverse fonctionne correctement en se connectant à localhost depuis un navigateur ou en effectuant des requêtes vers ```localhost``` et ```localhost/api/identities/``` via curl`.

## Additional steps:

Pour cette partie, nous avons utilisé [traefik](https://doc.traefik.io/traefik/) pour sa simplicité de configuration et d'utilisation avec Docker. Nous utilisons l'image officielle [traefik:v2.4](https://hub.docker.com/_/traefik).
Pour pouvoir lancer facilement plusieurs conteneurs (traefik, static http, express js ...) nous utilisons [docker-compose](https://docs.docker.com/compose/).
La totalité de la configuration se déroulera dans ce fichier docker-compose.yml à l'aide des labels.

Les serveurs http statiques et dynmiques sont ceux de l'étape 4 et de l'étape 3

Il n'y aura pas de dossiers différents pour chaque étape, les modifications étant en général très mineures.

### Load balancing: multiple server nodes

Afin de pouvoir utiliser traefik comme un reverse proxy supportant le load balancing, il faut lancer traefik avec quelques options minimales :

* Les commandes permettant de configurer traefik pour utiliser le provider pour Docker, d'activer la dashboard de traefik, ainsi que de déclarer un point d'entrée pour les requêtes
    ```
    - "--api.insecure=true"
    - "--providers.docker=true"
    - "--entrypoints.entryPoint_name.address=:80"
    ```

* Le mapping des différents ports (80, 443 et 8080) :
    ```     
  ports:
  - "443:443"
  - "80:80"
  - "8080:8080"
  ```

* Mapper également le socket utilisé par l'API Docker afin de permettre à Traefik de communiquer avec Docker :
  ```
  volumes:
  - /var/run/docker.sock:/var/run/docker.sock
  ```
  
* Le fichier docker-compose.yml utilisé est situé dans le dossier [extra_steps](https://github.com/noahfusi/RES_Labo_HTTP_Infra/tree/main/extra_steps/traefik/)
 
  
Il faudra ensuite spécifier certains labels pour les serveur http statiques et dynamiques :
 ```
- traefik.enable = true
- traefik.http.routers.router_name.rule=Rule(`/`)
- traefik.http.routers.router_name.entryPoints=entryPoint_name
- traefik.http.routers.router_name.service=service_name
- traefik.http.services.service_name.loadbalancer.server.port=num_port
```

La premiére ligne permet à traefik de détecter ce conteneur et ses options.

Les 3 suivantes spécifient la régle de routage (host, path, pathprefix), le point d'entrée (port) ainsi que le service "backend"

les 2 dernières déclarent le service "backend", ainsi que le numéro de port pour communiquer

Il faut faire attention à la manière dont le router "passe" les requêtes au backend, par exemple :

Si on essaye d'accéder à localhost/abc/xyz/, le router va simplement passer la requête au service conceré, mais le chemin de la requête restera /abc/xyz/. Dans le cas où le service backend concerné attend une requête au root (/),
il faut alors dire au router d'ajouter un traitement intermédiaire (middleware) à la requête qui va enlever le /abc/xyz/

Voici un exemple pour une requête localhost/api/identities/ où l'on enlève le /api/identities/ dans la requête :

```
dynamic_http:
    restart: unless-stopped
    image: express_identities
    labels:
    - traefik.enable=true
    - traefik.http.routers.dynamic_http.rule=Path(`/api/identities/`)
    - traefik.http.middlewares.dynamic2.stripprefix.prefixes= /api/identities/
    - traefik.http.routers.dynamic_http.entryPoints=web
    - traefik.http.routers.dynamic_http.service=dynamic
    - traefik.http.routers.dynamic_http.priority=100
    - traefik.http.routers.dynamic_http.middlewares=dynamic2
    - traefik.http.services.dynamic.loadbalancer.server.port=3000
```

#### Démonstration :
En utilisant la commande : 
```
docker-compose up -d --scale static_http=3 --scale dynamic_http=3
```

On lance les différents conteneurs en précisant que l'on désire 3 serveurs http statiques et 3 serveurs http dynamiques

On peut ensuite voir dans l'interface web de traefik (localhost:8080) qu'il a bien créé deux services composés de 3 serveurs chacuns :

![http statique](images/load_balancing_demo.png?raw=true "Demo loadbalancer")

Si on lance sans le -d, c'est à dire avec affichage, on peut observer les différents serveurs des load balancer en mode round-robin (mode par défaut):

![http dynamique](images/load_balancing_demo_dockerconsole_dynamic.png?raw=true "Demo loadbalancer")

![http statique](images/load_balancing_demo_dockerconsole_static.png?raw=true "Demo loadbalancer")

On peut voir dans la première image que les serveur dynamiques se relaient pour répondre aux requêtes.

On peut voir la même chose dans la deuxième image où l'on voit que les 3 serveurs ont répondu aux différentes requêtes (css, scripts etc ...)


### Load balancing: round-robin vs sticky sessions

Comme vu dans la partie précédente, les loadbalancers de traefik fonctionnent par défaut en mode round-robin

Pour mettre en place la partie sticky session en utilisant des cookies pour la partie http statique, il suffit de rajouter un label :
```
- traefik.http.services.static.loadBalancer.sticky.cookie
```

#### Démonstration :
Pour cette démonstration, nous allons simplement effectuer des refresh sur la page (localhost:80).

![http statique sticky](images/load_balancing_sticky_demo_dockerconsole.png?raw=true "Demo loadbalancer")
 
On peut voir dans l'image ci-dessus que lors du refresh, c'est le même serveur http statique qui nous a servi grâce au cookie stocké dans le navigateur.

Pour pouvoir vérifier que c'est bien le cookie qui fonctionne et pas une mauvaise configuration, on peut lancer des requêtes via curl :

```
curl localhost
```

![http statique sticky](images/load_balancing_sticky_demo_dockerconsole_curl.png?raw=true "Demo loadbalancer")

On peut voir ci-dessus que les différents serveurs statiques nous on servi à tour de rôle.


### Dynamic cluster management :

Pour cette partie, on utilise les capacités de traefik qui propose cette fonctionnalité.
Pour l'implémenter, il n'y a rien à modifier.

#### Demonstration :
Pour démontrer la capactié de gérer dynamiquement l'arrivée et le départ de serveurs, on lance 3 serveurs statiques et 3 servers dynamiques avec 
```
docker-compose up -d --scale static_http=3 --scale dynamic_http=3
```

![http statique](images/load_balancing_demo.png?raw=true "Demo loadbalancer")

On va ensuite rajouter un serveur statique avec (sans -d pour pouvoir observer l'activité du serveur) :
```
docker-compose run static_http
```
![dynamic cluster add](images/dynamic_cluster_add_server.png?raw=true "Demo loadbalancer")

On peut voir dans l'interface web de traefik que le nombre de serveur statiques est passé de 3 à 4.

![dynamic cluster add](images/dynamic_cluster_add_server_log.png?raw=true "Demo loadbalancer")

En lançant plusieurs requêtes via curl, on peut voir dans l'affichage du serveur que l'on a lancé qu'il répond bien aux requêtes

Pour tester la suppression de serveurs, on va simplement kill 2 serveurs statiques avec :
```
docker kill nom_du_conteneur
```
![dynamic cluster add](images/dynamic_cluster_remove_server.png?raw=true "Demo loadbalancer")

On voit que le nombre de serveurs est bien passé à 2. Si on lance des requêtes via curl (pour éviter le sticky cookie) :

![dynamic cluster add](images/dynamic_cluster_remove_server_log.png?raw=true "Demo loadbalancer")

On voit que le serveur static_http_1 a été kill et que les 2 autres se chargent des requêtes.




 

