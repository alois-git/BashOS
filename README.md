Paulus Alois

-----------------------
Projet Unix 2013-2014 |
-----------------------

1) Analyse des packets R 
_________________________

1.1) Utilisation du script
---------------------

./rextrat.sh -d pathToFolder

ou bien pour obtenir de l'aide

./rextrat.sh -h

1.2) Les arguments
---------------------

- L: Ignore les liens symboliques 
- p: Affiche le contenu du fichier package.csv
- c: Supprime tous les fichiers généré par le script
- r: Active la recherche de packet R dans un packet R
- d path: Donne le chemin du dossier à examiner

1.3) Structure du script
---------------------

Mon script est composé de plusieurs fonctions génériques pour éviter de devoir maintenir trop de ligne de code. De plus débugger en bash n'est pas des plus facile donc il fallait absolument avoir de petite fonction plus ou moins facile à vérifier.

Chaque fonction est documentée dans le script, je ne les ai donc pas reprises dans le rapport.

Pour ce script comme pour le suivant, j'ai beaucoup employé les tableaux. Car ils m'ont permis de stocker facilement des données et aussi de créer des fonctions génériques, par exemple : la liste des dossiers et des fichiers obligatoires.

La structuture générale du script correspond à :

Récupérer tous les dossiers contenus dans le dossier donné en paramètre
Pour chaque dossier :
    1) vérifier si c'est un packet R
    2) si oui, traiter ce dossier
    3) si non/oui (dependant du paramètre -r) rechercher si il contient des packets R
Fin


2) Suite de Syracuse
_____________________


1.1) Utilisation du script
--------------------------

./syracuseGen.sh n


1.2) SyracuseGen.sh
---------------------

Ce script appelle le script syracuse.sh pour obtenir la suite de syracuse pour chaque nombre contenu entre 1 et n. 
Ensuite il génère les graphiques grâce l'outil DOT pour chacune de ces suites.


1.3) Syracuse.sh
---------------------

Il prend en paramètre un entier strictement positif et génère en language DOT le graphe d'écrivant les vols de Syracuse pour les suites partant des entiers de 1 à n (n'étant le paramètre).

Pour cela j'ai employé un tableau de tableau. Pour chaque nombre je stocke un tableau de nombre contenant sa suite de Syracuse.
Ensuite je parcours ce tableau de tableau pour générer le fichier DOT. 

Le graphique DOT est généré avec le l'option "strict" qui permet d'afficher plusieurs arrêtes en une seule.

3) Outils
___________

- getopts : j'ai employé cet outil pour gérer les options du script d'analyse des packets R. Il m'a été très utile pour gérer les options multiples, non ordonnées et avec arguments.

getops prend en paramètre les options attendues ainsi que si l'on désire, leurs arguments.

Example : getopts "a" attends l'option -a
          getopts "a:" attends l'option -a avec un argument
          getopts "abc" attends l'option -a ou -b ou -c ou bien une combinaison de ces options.

