%%% INFO-501, TP3
%%% Enzo Goldstein
%%%
%%% Lancez la "requête"
%%% jouer.
%%% pour commencer une partie !
%

% il faut déclarer les prédicats "dynamiques" qui vont être modifiés par le programme.
:- dynamic position/2, position_courante/1.

% on remet à jours les positions des objets et du joueur
:- retractall(position(_, _)), retractall(position_courante(_)).

% on déclare des opérateurs, pour autoriser `prendre torche` au lieu de `prendre(torche)`
:- op(1000, fx, prendre).
:- op(1000, fx, lacher).
:- op(1000, fx, aller).



% position du joueur. Ce prédicat sera modifié au fur et à mesure de la partie (avec `retract` et `assert`)
position_courante(feu_de_camp).

% passages entre les différent endroits du jeu
passage(quelque_part, nord, quelque_part).

% position des objets
position(truc, quelque_part).


% ramasser un objet
prendre(X) :-
        position(X, en_main),
        write("Vous l'avez déjà !"), nl,
        !.

prendre(X) :-
        position_courante(P),
        position(X, P),
        retract(position(X, P)),
        assert(position(X, en_main)),
        write("OK."), nl,
        !.

prendre(X) :-
        write("??? Je ne vois pas de "),
        write(X),
        write(" ici."), nl,
        fail.


% laisser un objet
lacher(X) :-
        position(X, en_main),
        position_courante(P),
        retract(position(X, en_main)),
        assert(position(X, P)),
        write("OK."), nl,
        !.

lacher(_) :-
        write("Vous n'avez pas ça en votre possession !"), nl,
        fail.


% quelques raccourcis
n :- aller(nord).
s :- aller(sud).
e :- aller(est).
o :- aller(ouest).


% déplacements
aller(musee) :-
        position_courante(reveil),
        retract(position_courante(reveil)),
        assert(position_courante(musee)),
        regarder, !.

aller(_) :-
        write("Vous ne pouvez pas aller par là."),
        fail.

% discussions personnages
parler :-
        position_courante(reveil),
        parler(ardoise_initial).


% regarder autour de soi
regarder :-
        position_courante(Place),
        decrire(Place), nl,
        lister_objets(Place), nl.


% afficher la liste des objets à l emplacement donné
lister_objets(Place) :-
        position(X, Place),
        write("Il y a "), write(X), write(" ici."), nl,
        fail.

lister_objets(_).


% fin de partie
fin :-
        nl, write("La partie est finie."), nl,
        halt.


% affiche les instructions du jeu
instructions :-
        nl,
        write("Les commandes doivent être données avec la syntaxe Prolog habituelle."), nl,
        write("Les commandes existantes sont :"), nl,
        write("jouer.                   -- pour commencer une partie."), nl,
        write("n.  s.  e.  o.           -- pour aller dans cette direction (nord / sud / est / ouest)."), nl,
        write("aller(direction)         -- pour aller dans cette direction."), nl,
        write("prendre(objet).          -- pour prendre un objet."), nl,
        write("lacher(objet).           -- pour lacher un objet en votre possession."), nl,
        write("regarder.                -- pour regarder autour de vous."), nl,
        write("instructions.            -- pour revoir ce message !."), nl,
        write("fin.                     -- pour terminer la partie et quitter."), nl,
        nl.



% lancer une nouvelle partie
jouer :-
        instructions,
        decrire(reveil),
        regarder.

% dialogue personnages



parler :-
    position_courante(feu_de_camp),
    write("Si c'est pas notre pilote ! Je vois que tu es de retour de ta dernière nuit à la belle étoile avant ton décollage.
        Alors ça y est, c'est le grand jour ? J'ai l'impression que tu as rejoint le programme spatial pas plus tard qu'hier, 
        et voilà soudain que tu t'apprêtes à partir pour ton premier voyage en solitaire.
        Qu'est-ce que t'en dis - t'as pas hâte de t'envoler à bord de ce petit bijou ? Le plein est fait, y'a plus qu'à décoller !
        → (Options : Allons y, OK). "), nl.

parler :-
    position_courante(feu_de_camp),
    dialogue(ardoise_allons_y),
    write("Ta motivation fait plaisir à voir, mais souviens-toi, si tu bousilles la fusée, viens pas m'en demander un autre. 
        Je ne suis pas en alliage d'aluminium léger résistant à la rentrée atmosphérique, tu sais.
        Quoi qu'il en soit, tu vas devoir parler à Cornée à l'observatoire pour obtenir les codes de lancement si tu veux pouvoir décoller. 
        Amène-les-moi une fois que tu auras fait tes adieux ou je ne sais quoi."),
        retract(dialogue(ardoise_allons_y)), nl.

parler :-
    position_courante(feu_de_camp),
    dialogue(ardoise_ok),
    write("Ha ha ! Tout est prêt de mon côté - on va enfin pouvoir tester le nouveau système d'atterrissage 
        hydraulique avec un pilote plutôt que le système automatique ! ... En parlant de pilote, 
        évite de t'écraser à ton premier atterrissage, compris ? Quoi qu'il en soit, tu vas devoir parler à 
        Cornée à l'observatoire pour obtenir les codes de lancement si tu veux pouvoir décoller. 
        Amène-les-moi une fois que tu auras fait tes adieux ou je ne sais quoi."),
        retract(dialogue(ardoise_ok)), nl.

parler(cornee) :-
    write("Te voilà ! Je viens de terminer les observations préalables. Les conditions météorologiques locales sont bonnes. 
        C'est l'heure pour notre plus jeune astronaute de prendre son envol !
        Et tu seras notre toute première recrue à partir avec un traducteur de nomaï portable !
        Je t'avoue que rien que d'y penser, j'en ai la tête qui tourne.
        On est mieux équipés que jamais pour lever le voile sur les mystères des Nomaï. 
        Vous avez fait un travail remarquable, toi et Hal ! Voici les codes de lancement pour utiliser l'ascenseur.
        → (Obtenu : traducteur, codes)"),
        assert(position(traducteur, en_main)),
        assert(position(codes, en_main)), nl.



% descriptions des emplacements
decrire(reveil) :-
    write("Vous vous réveillez dans la nature, observant le ciel. 
    Vous voyez les étoiles et distinguer une forme exploser au loin... 
    Une planète de très grande taille parcourt tranquillement ton champ de vision.
    "), nl.

decrire(feu_de_camp) :-
    write("Le feu crépite et éclaire la nuit, un villageois se tient près du bois crépitant.
    Une fusée se tient en hauteur, cela vous donne le tournis. Un ascenseur près de vous permet d'y accéder.
    Au delà du feu, se tient un chemin menant vers un batiment éclairée...
    → (Options : parler villageois, aller fusee, aller musee)"), nl.


decrire(musee) :-
    write("Vous rentrez, ébloui, dans un grand batiment avec une multitude de statues, maquettes et d'étranges cailloux.
    Chaque objet semble plus intéressant l'un que l'autre.
    → (Options : voir statue, parler villageois, voir maquettes)"), nl.

decrire(maquettes) :-
    write("Vous voyez un modèle réduit du système solaire montrant les orbites des différentes planètes.. Vous lisez les informations suivantes :
    'Voici notre système solaire, composé de Timber Hearth et de ses voisines. Chacune des planètes a ses propres mystères, qui continuent d'intriguer les chercheurs.'
    "), nl.


decrire(statue) :-
        position(codes, en_main),
        write("Vous voyez une statue mystérieuse des Nomai, une civilisation ancienne et disparue. Vous lisez :
        'Cette statue est une des rares que nous ayons découvertes.'
        'On pense que les Nomai l'ont sculptée pour honorer un événement important de leur histoire.'
        Soudainement, la statue ouvre les yeux et vous regarde brusquement.
        Vous n'entendez qu'un bruit sourd et voyez ses grands yeux violets, 
        tandis que vos souvenirs depuis votre réveil défilent devant vos yeux.
        Tout d'un coup, ses yeux s'éteignent et le bruit sourd cesse...
        "), nl.

decrire(statue) :-
        write("Vous voyez une statue mystérieuse des Nomai, une civilisation ancienne et disparue. Vous lisez :
        'Cette statue est une des rares que nous ayons découvertes.'
        'On pense que les Nomai l'ont sculptée pour honorer un événement important de leur histoire.'
        "), nl.
