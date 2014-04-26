Alois Paulus

Projet Unix 2013-2014
_____________________

1) Analyse des packets R 
------------------------
------------------------

1.1) Lancer le script
---------------------

./rextrat.sh -d pathToFolder

ou bien pour obtenir de l'aide

./rextrat.sh -h

1.2) Les arguments
---------------------

- L: Ignore les liens symboliques 
- p: Affiche le contenu du fichier package.csv
- c: Supprimer tous les fichiers généré par le script
- r: Active la recherche de packet R dans un packet R
- d path: Donne le chemin du dossier à examiner

1.3) Structure du script
---------------------

Mon script est composé de plusieurs fonctions dans le but d'avoir des fonctions courtes et compréhensibles.

Chaque fonction est documentée dans le script.

La structuture général correspond à :

- Récupérer tous les dossiers contenu dans un dossier donner en paramètre
- Pour chaque dossier :
    - vérifier si c'est un R packet
    - Si oui traiter ce dossier et écrire les fichiers
    - Rechercher les packets R parmis ses dossiers (dependant du paramètre -r)

2) Suite de Syracuse
---------------------
---------------------

1.1) Lancer le script
---------------------

./syracuseGen.sh n

1.2) SyracuseGen.sh
---------------------

Ce script fait appel au script syracuse.sh pour obtenir la suite de syracuse pour chaque nombre contenu entre 1 et n

et génère les graphiques grâce à la commande dot pour chaqu'une de ces suites.

La commande dot est un utilitaire contenu dans la librarie GraphViz qui permet de générer les graphiques en fichier PNG.

1.3) Syracuse.sh
---------------------

Il prend en paramètre un entier strictement positif et génère en language dot le graphe d'écrivant les vols de Syracuse pour les suites partant des entiers de 1 à n (n étant le paramètre).

Pour cela j'ai employé un tableau de tableau. Pour chaque nombre je stocke un tableau de nombres représentant sa suite de Syracuse.

Ensuite je parcoure ces tableaux de nombre pour générer le fichier dot.

3) Outils  
-----------
-----------

- getopts : j'ai employé cet outil pour géré les arguments du script d'analyse des packet R. Il m'a été très utile pour gérer les arguments multiples, non ordonné et avec option.

