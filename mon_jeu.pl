%%% INFO-501, TP3
%%% Enzo Goldstein
%%%
%%% Lancez la "requete"
%%% jouer.
%%% pour commencer une partie !
%

% il faut declarer les predicats "dynamiques" qui vont etre modifies par le programme.
:- dynamic position/2, position_courante/1.

% on remet a jours les positions des objets et du joueur
:- retractall(position(_, _)), retractall(position_courante(_)).

% on declare des operateurs, pour autoriser `prendre torche` au lieu de `prendre(torche)`
:- op(1000, fx, prendre).
:- op(1000, fx, lacher).
:- op(1000, fx, aller).



% position du joueur. Ce predicat sera modifie au fur et a mesure de la partie (avec `retract` et `assert`)
position_courante(feu_de_camp).

% passages entre les different endroits du jeu
passage(quelque_part, nord, quelque_part).

% position des objets
position(truc, quelque_part).


% ramasser un objet
prendre(X) :-
        position(X, en_main),
        write("Vous l'avez deja !"), nl,
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
        write("Vous n'avez pas ca en votre possession !"), nl,
        fail.


% quelques raccourcis
n :- aller(nord).
s :- aller(sud).
e :- aller(est).
o :- aller(ouest).


% deplacements
aller(musee) :-
        position_courante(feu_de_camp),
        retract(position_courante(feu_de_camp)),
        assert(position_courante(musee)),
        regarder, !.

aller(fusee) :-
        position(codes, en_main),
        position_courante(feu_de_camp),
        retract(position_courante(feu_de_camp)),
        assert(position_courante(fusee)),
        regarder, !.

aller(fusee) :-
        write("Vous vous dirigez vers la fusee... Vous voyez un ascenseur vous indiquant que vous 
        n'avez pas les codes de lancement necessaire. Vous faites demi-tour."), nl,
        fail.

aller(_) :-
        write("Vous ne pouvez pas aller par la."),
        fail.


% regarder autour de soi
regarder :-
        position_courante(Place),
        decrire(Place), nl,
        lister_objets(Place), nl.


% afficher la liste des objets a l emplacement donne
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
        write("Les commandes doivent etre donnees avec la syntaxe Prolog habituelle."), nl,
        write("Les commandes existantes sont :"), nl,
        write("jouer.                   -- pour commencer une partie."), nl,
        write("dire(mot).               -- pour dire quelque chose aux pnj."), nl,
        write("aller(direction).        -- pour aller dans cette direction."), nl,
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


% voir objets
voir(statue) :-
        position(codes, en_main),
        write("Vous voyez une statue mysterieuse des Nomai, une civilisation ancienne et disparue. Vous lisez :
        'Cette statue est une des rares que nous ayons decouvertes.'
        'On pense que les Nomai l'ont sculptee pour honorer un evenement important de leur histoire.'
        Soudainement, la statue ouvre les yeux et vous regarde brusquement.
        Vous n'entendez qu'un bruit sourd et voyez ses grands yeux violets, 
        tandis que vos souvenirs depuis votre reveil defilent devant vos yeux.
        Tout d'un coup, ses yeux s'eteignent et le bruit sourd cesse...
        "), nl.

voir(statue) :-
        write("Vous voyez une statue mysterieuse des Nomai, une civilisation ancienne et disparue. Vous lisez :
        'Cette statue est une des rares que nous ayons decouvertes.'
        'On pense que les Nomai l'ont sculptee pour honorer un evenement important de leur histoire.'
        "), nl.

voir(maquettes) :-
        write("Vous voyez un modele reduit du systeme solaire montrant les orbites des differentes planetes.. 
        Vous lisez les informations suivantes :
        'Voici notre systeme solaire, compose de Timber Hearth et de ses voisines. 
        Chacune des planetes a ses propres mysteres, qui continuent d'intriguer les chercheurs.'
        "), nl.


% dialogue personnages
parler :-
    position_courante(feu_de_camp),
    write("Si c'est pas notre pilote ! Je vois que tu es de retour de ta derniere nuit a la belle etoile avant ton decollage.
        Alors ca y est, c'est le grand jour ? J'ai l'impression que tu as rejoint le programme spatial pas plus tard qu'hier, 
        et voila soudain que tu t'appretes a partir pour ton premier voyage en solitaire.
        Qu'est-ce que t'en dis - t'as pas hate de t'envoler a bord de ce petit bijou ? Le plein est fait, y'a plus qu'a decoller !
        -> (Options : dire allons-y, dire ok). "), nl.

parler :-
    position_courante(musee),
    write("Te voila ! Je viens de terminer les observations prealables. Les conditions meteorologiques locales sont bonnes. 
        C'est l'heure pour notre plus jeune astronaute de prendre son envol !
        Et tu seras notre toute premiere recrue a partir avec un traducteur de nomai portable !
        Je t'avoue que rien que d'y penser, j'en ai la tete qui tourne.
        On est mieux equipes que jamais pour lever le voile sur les mysteres des Nomaï. 
        Vous avez fait un travail remarquable, toi et Hal ! Voici les codes de lancement pour utiliser l'ascenseur.
        -> (Obtenu : traducteur, codes)"),
        assert(position(traducteur, en_main)),
        assert(position(codes, en_main)), nl.

% interaction personnages
dire(allons-y) :-
    position_courante(feu_de_camp),
    write("Ta motivation fait plaisir a voir, mais souviens-toi, si tu bousilles la fusee, viens pas m'en demander un autre. 
        Je ne suis pas en alliage d'aluminium leger resistant a la rentree atmospherique, tu sais.
        Quoi qu'il en soit, tu vas devoir parler a Cornee a l'observatoire pour obtenir les codes de lancement si tu veux pouvoir decoller. 
        Amene-les-moi une fois que tu auras fait tes adieux ou je ne sais quoi."), nl.

dire(ok) :-
    position_courante(feu_de_camp),
    write("Ha ha ! Tout est pret de mon côte - on va enfin pouvoir tester le nouveau systeme d'atterrissage 
        hydraulique avec un pilote plutôt que le systeme automatique ! ... En parlant de pilote, 
        evite de t'ecraser a ton premier atterrissage, compris ? Quoi qu'il en soit, tu vas devoir parler a 
        Cornee a l'observatoire pour obtenir les codes de lancement si tu veux pouvoir decoller. 
        Amene-les-moi une fois que tu auras fait tes adieux ou je ne sais quoi."), nl.



% descriptions des emplacements
decrire(reveil) :-
    write("Vous vous reveillez dans la nature, observant le ciel. 
    Vous voyez les etoiles et distinguer une forme exploser au loin... 
    Une planete de tres grande taille parcourt tranquillement ton champ de vision.
    "), nl.

decrire(feu_de_camp) :-
    write("Le feu crepite et eclaire la nuit, un villageois se tient pres du bois crepitant.
    Une fusee se tient en hauteur, cela vous donne le tournis. Un ascenseur pres de vous permet d'y acceder.
    Au dela du feu, se tient un chemin menant vers un batiment eclairee...
    -> (Options : parler, aller fusee, aller musee)"), nl.


decrire(musee) :-
    write("Vous rentrez, ebloui, dans un grand batiment avec une multitude de statues, maquettes et d'etranges cailloux.
    Chaque objet semble plus interessant l'un que l'autre.
    -> (Options : voir statue, parler, voir maquettes)"), nl.

decrire(musee_etage) :-
    write(""), nl.


