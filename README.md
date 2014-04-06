Alois Paulus

Projet Unix 2013-2014
----------------------
----------------------

1) Analyse des packets R 
------------------------

1.1) Lancer le script

./rextrat.sh pathtofolder 

ou bien

./rextrat.sh --help

1.2) Structure du script

Mon script est composé de plusieurs fonctions dans le but d'avoir des fonctions courtes et compréhensibles.

Chaque fonction est documentée dans le script.

La strcuture général ressemble à :

- Récupérer tous les dossiers présent dans le dossier donner en paramètre
- Pour chaque folder :
    - vérifier si c'est un R packet
    - Si oui traiter ce dossier et écrire les fichiers

2) Suite de Syracuse
---------------------

1.1) Lancer le script 

./syracuseGen.sh n

1.2) Structure du script

Ce script fait appel au script syracuse.sh pour obtenir la suite de syracuse pour chaque nombre contenu en 1 et n.

et génère les graphiques grâce à la commande dot pour chaqu'une de ces suites.

La commande dot est un utilitaire contenu dans la librarie GraphViz qui permet générer les graphiques en fichier PNG.

1.3) Syracuse.sh

Il prend en paramètre un entier strictement positif et génère en language dot le graphe d'écrivant les vols de Syracuse pour les suites partant des entiers de 1 à n (n étant le paramètre).

Pour cela j'ai employé un tableau de tableau. Pour chaque nombre je stocke un tableau de nombres représentant sa suite de Syracuse.

Ensuite je parcour ces tableaux de nombre pour générer le fichier dot.

