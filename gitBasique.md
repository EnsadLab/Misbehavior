Git Basique
===========

Un tuto pas à pas pas trop mal : http://gitimmersion.com/ .

Il y a en dessous les bases pour utiliser le git.

## Récupérer le répertoire git

Dans github, dans le repertoire Misbehavior : à droite au dessus de "clone to desktop" cliquer sur "Https" ("you can clone with HTTPS") et copier l'adresse au dessus : https://github.com/EnsadLab/Misbehavior.git .

Dans l'ordinateur : crée un espace de travail (ex: /Alex/git/). Puis : 

```shell
cd /Alex/git/
git clone https://github.com/EnsadLab/Misbehavior.git
```

Si tout se passe bien le répertoire se clone et un dossier apparait du type : /Alex/git/Misbehavior .

## Pusher le répertoire vers github

Une fois toutes les modifications faites (ajouts de fichiers, modifications...) il faut les ajouter au git.
D'abord aller à la racine du dossier : 

```shell
cd /Alex/git/Misbehavior/
```

Puis ajouter les modifications : 

```shell
git add .
```

Il faut ensuite faire un commit de ces modifications : 

```shell
git commit -a -m "bla bla bla"
```

L'option -m permet d'ajouter un message relatif à ce commit et lisible par tout le monde.

Enfin il faut pusher le tout vers github : 

```shell
git push
```

Le terminal vous demande alors votre login et mot de passe github pour valider le push.

Comme le répertoire a originellement été cloné depuis github le push devrait par défaut se faire vers la même adresse.

## Obtenir des informations sur le repository

```shell
git status
```

permet d'obtenir des informations sur l'état actuel du repository : branche sur laquelle on travaille, dossiers modifiés et n'ayant pas encore subit de commit, fichiers non trackés car non ajoutés...

## Récupérer les dernières mises à jour de github vers son ordinateur

```shell
cd /Alex/git/Misbehavior
git pull origin
```

## Aller plus loin, merging etc etc

Mes connaissances s'arrêtent ici. Pour la suite il vaut mieux voir sur les tutos en ligne et avec Cécile a l'habitude des workflow via git.