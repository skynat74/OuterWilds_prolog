%%% INFO-501, TP3
%%% Enzo Goldstein
%%% Natal Fevre-Burdy
%%%
%%% Lancez la "requete"
%%% jouer.
%%% pour commencer une partie !


% il faut declarer les predicats "dynamiques" qui vont etre modifies par le programme.
:- dynamic position/2, position_courante/1, statue/1, planete/1, nombre_de_morts/1, compteur_temps/1, sabliere_noire/1.
:- discontiguous position/2.

% on remet a jours les positions des objets et du joueur
:- retractall(position(_, _)), retractall(position_courante(_)).

% on declare des operateurs, pour autoriser `aller camp` au lieu de `aller(camp)`
:- op(1000, fx, aller).
:- op(1000, fx, lacher).
:- op(1000, fx, dire).
:- op(1000, fx, voir).
:- op(1000, fx, prendre).
:- op(1000, fx, reposer).
:- op(1000, fx, attendre).

% Tests pour debogage
voir_position :-
        position_courante(X),
        write(X).

voir_planete :-
        planete(X),
        write(X).

voir_temps :-
        compteur_temps(X),
        write(X).

voir_nb_mort :-
        nombre_de_morts(X),
        write(X).

voir_projet :-
        sabliere_noire(X),
        write(X).

test :-
        write("position : "), voir_position, nl,
        write("planete : "), voir_planete, nl,
        write("temps : "), voir_temps, nl,
        write("morts : "), voir_nb_mort, nl,
        write("projet : "), voir_projet, nl.

% ----------------
% Initialisations
% ----------------

% position du joueur. Ce predicat sera modifie au fur et a mesure de la partie (avec `retract` et `assert`)
position_courante(camp).
planete(atrebois).

% la statue n est pas activee au debut
statue(activee).   

% Sabliere noire est en cours de fonctionnement au debut
sabliere_noire(activee).

% le joueur n est pas encore mort au debut
nombre_de_morts(0).

% la boucle commence a 0 minutes, pour aller jusqu a 17 minutes
compteur_temps(0).


% AAAAAAAAAAA     UUUU       UUUU     TTTTTTTTTTTT     RRRRRRRRRRRR     EEEEEEEEEEEE     SSSSSSSSSSSS
% AAAAA    AAAAA  UUUU       UUUU         TTTT         RRRR      RRRR   EEEE            SSSS
% AAAAAAAAAAAAAA  UUUU       UUUU         TTTT         RRRRRRRRRRRRR    EEEEEEEEEEEE      SSSSSSSSSSSS
% AAAAA    AAAAA  UUUU       UUUU         TTTT         RRRR   RRRR      EEEE                     SSSS
% AAAAA    AAAAA    UUUUUUUUUUUU          TTTT         RRRR     RRRR    EEEEEEEEEEEE     SSSSSSSSSSSS


% regarder autour de soi
regarder :-
        position_courante(Place),
        decrire(Place), nl.

% pour prendre le generateur
prendre(generateur) :-
        position_courante(salle),
        planete(sabliere),
        decrire(prise_generateur),
        retract(sabliere_noire(_)),
        assert(sabliere_noire(desactivee)),
        assert(position(generateur, en_main)), !.

prendre(_) :-
        write("Vous ne pouvez pas faire ceci."), nl.

% pour reposer le generateur
reposer(generateur) :-
        position_courante(salle),
        planete(sabliere),
        retract(sabliere_noire(_)),
        assert(sabliere_noire(activee)),
        retract(position(generateur, en_main)), !.

reposer(_) :-
        write("Vous ne pouvez pas faire ceci."), nl.

% gestion de la mort
mort :-
        statue(activee),
        sabliere_noire(activee),
        decrire(mort), nl,
        reinit.

mort :-
        statue(desactivee),
        write("Le noir de la mort ne se dissipa jamais... Les autres Atriens ne vous reverrons plus jamais."),
        fin;
        sabliere_noire(desactivee),
        write("Le noir de la mort ne se dissipa jamais... Les autres Atriens ne vous reverrons plus jamais."),
        fin.

reinit :-
        retract(position_courante(_)),
        assert(position_courante(camp)),
        retract(planete(_)),
        assert(planete(atrebois)),
        incrementer_morts,
        retract(compteur_temps(_)),
        assert(compteur_temps(0)),
        decrire(reveil),
        regarder, nl.

incrementer_morts :-
        nombre_de_morts(N),
        NouveauNombre is N + 1,
        retract(nombre_de_morts(N)),
        assert(nombre_de_morts(NouveauNombre)).


% Fin de partie
fin :-
        nl, write("La partie est finie."), nl,
        halt.


% Gestion de la boucle temporelle
incrementer_temps :-
    compteur_temps(T),
    NouveauTemps is T + 1,
    retract(compteur_temps(T)),
    assert(compteur_temps(NouveauTemps)), !.

verifier_boucle :-
    compteur_temps(X),
    X >= 17,
    decrire(mort_supernova), nl,
    mort, !.

verifier_boucle :-
    compteur_temps(T),
    T = 16,
    decrire(explosion_etoile), nl,
    incrementer_temps, !.

verifier_boucle :-
    compteur_temps(T),
    T < 16,
    incrementer_temps, !.

% verifie si le joueur est dans un lieu en exterieur, permettant de voir l'etoile s'effondrer
en_exterieur :-
        position_courante(dehors),
        \+ planete(leviathe);
        position_courante(baie);
        position_courante(espace);
        position_courante(camp);
        position_courante(etage);
        position_courante(tarmac).

% Permet d attendre une minute
attendre(NbMinute) :-
        compteur_temps(Tc),
        Min is Tc + 1,
        Max is Tc + NbMinute,
        Max > 17,
        forall(between(Min, 18, _), 
                verifier_boucle
        ), !.

attendre(NbMinute) :-
        compteur_temps(Tc),
        Min is Tc + 1,
        Max is Tc + NbMinute,
        Max =< 17,
        forall(between(Min, Max, _), 
                verifier_boucle
        ), !.

attendre_boucle :-
        attendre(18).


% affiche les instructions du jeu
instructions :-
        nl,
        write("Les commandes doivent etre donnees avec la syntaxe Prolog habituelle."), nl,
        write("Les commandes avec des parentheses peuvent etre ecrites sans parentheses."), nl,
        write("Les commandes existantes sont :"), nl,
        write("jouer.                   -- pour commencer une partie."), nl,
        write("dire(mot).               -- pour dire quelque chose aux pnj."), nl,
        write("aller(direction).        -- pour aller dans cette direction."), nl,
        write("prendre(objet).          -- pour prendre un objet."), nl,
        write("reposer(objet).          -- pour remettre un objet a l'endroit ou vous l'avez trouvez."), nl,
        write("regarder.                -- pour regarder autour de vous."), nl,
        write("attendre(n).             -- pour attendre n minutes."), nl,
        write("instructions.            -- pour revoir ce message !."), nl,
        write("fin.                     -- pour terminer la partie et quitter."), nl,
        nl.



% lancer une nouvelle partie
jouer :-
        instructions,
        decrire(reveil),
        regarder.


% DDDDDDDDDDDD     EEEEEEEEEEEE     PPPPPPPPPPP       LLLLL             AAAAAAAAA     CCCCCCCCCCCCC   EEEEEEEEEEEE     MMMMM      MMMMM     EEEEEEEEEEEE     NNNN        NNNN    TTTTTTTTTTTT     SSSSSSSSSSSS
% DDDD       DDDD  EEEE             PPPP      PPPP    LLLLL             AAAA   AAAA  CCCC             EEEE             MMMMMMM  MMMMMMM     EEEE             NNNNNN      NNNN        TTTT      SSSS          
% DDDD        DDD  EEEEEEEEEEEE     PPPPPPPPPPPP      LLLLL             AAAAAAAAAAA CCCC              EEEEEEEEEEEE     MMMMMMMMMMMMMMMM     EEEEEEEEEEEE     NNNN NNN    NNNN        TTTT       SSSSSSSSSSSS
% DDDD        DDD  EEEE             PPPP              LLLLL             AAAA   AAAA CCCC              EEEE             MMMMMMMMMMMMMMMM     EEEE             NNNN   NNN  NNNN        TTTT                 SSSS
% DDDDDDDDDDDD     EEEEEEEEEEEE     PPPP              LLLLLLLLLLLLLLL   AAAA   AAAA    CCCCCCCCCCCCC  EEEEEEEEEEEE     MMMMM       MMMM     EEEEEEEEEEEE     NNNN      NNNNN        TTTT       SSSSSSSSSSSS

% A chaque fois que le joueur se deplace, le temps avance
aller(_) :-
        verifier_boucle,
        fail.


% Atrebois
aller(musee) :-
        position_courante(camp),
        retract(position_courante(camp)),
        assert(position_courante(musee)),
        regarder, !.

aller(musee) :-
        position(codes, en_main),
        statue(desactivee),
        position_courante(etage),
        retract(position_courante(etage)),
        assert(position_courante(musee)),
        retract(statue(desactivee)),
        assert(statue(activee)),
        decrire(evenement_statue), !.

aller(musee) :-
        position_courante(etage),
        retract(position_courante(etage)),
        assert(position_courante(musee)),
        regarder, !.

aller(etage) :-
        position_courante(musee),
        retract(position_courante(musee)),
        assert(position_courante(etage)),
        regarder, !.

aller(camp) :-
        position_courante(musee),
        retract(position_courante(musee)),
        assert(position_courante(camp)),
        regarder, !.

aller(camp) :-
        position_courante(fusee),
        retract(position_courante(fusee)),
        assert(position_courante(camp)),
        regarder, !.

aller(fusee) :-
        position(codes, en_main),
        position_courante(camp),
        retract(position_courante(camp)),
        assert(position_courante(fusee)),
        regarder, !.

aller(fusee) :-
        position_courante(camp),
        write("Vous vous dirigez vers la fusee... Vous voyez un ascenseur vous indiquant que vous 
        n'avez pas les codes de lancement necessaire. Vous faites demi-tour."), nl, !.

% Cravite
aller(fusee) :-
        position_courante(dehors),
        retract(position_courante(dehors)),
        assert(position_courante(fusee)),
        regarder, !.

aller(dehors) :-
        position_courante(fusee),
        retract(position_courante(fusee)),
        assert(position_courante(dehors)),
        regarder, !.

aller(dehors) :-
        position_courante(caverne),
        planete(cravite),
        retract(position_courante(caverne)),
        assert(position_courante(dehors)),
        regarder, !.

aller(dehors) :-
        position_courante(capsule),
        planete(cravite),
        retract(position_courante(capsule)),
        assert(position_courante(dehors)),
        regarder, !.

aller(trou) :-
        position_courante(dehors),
        retract(position_courante(dehors)),
        assert(position_courante(trou)),
        regarder,
        mort, !.

aller(capsule) :-
        position_courante(dehors),
        retract(position_courante(dehors)),
        assert(position_courante(capsule)),
        regarder, !. 

aller(caverne) :-
        position_courante(hall),
        retract(position_courante(hall)),
        assert(position_courante(caverne)),
        decrire(passage_antigrav),
        regarder, !. 

aller(caverne) :-
        position_courante(dehors),
        retract(position_courante(dehors)),
        assert(position_courante(caverne)),
        regarder, !.    

aller(plafond) :-
        position_courante(caverne),
        retract(position_courante(caverne)),
        assert(position_courante(hall)),
        decrire(passage_antigrav),
        regarder, !.

aller(dortoir) :-
        position_courante(hall),
        retract(position_courante(hall)),
        assert(position_courante(dortoir)),
        regarder, !.

aller(laboratoire) :-
        position_courante(hall),
        retract(position_courante(hall)),
        assert(position_courante(laboratoire)),
        regarder, !.

aller(hall) :-
        position_courante(dortoir),
        retract(position_courante(dortoir)),
        assert(position_courante(hall)),
        regarder, !.

aller(hall) :-
        position_courante(laboratoire),
        retract(position_courante(laboratoire)),
        assert(position_courante(hall)),
        regarder, !.

% Leviathe
aller(fusee) :-
        position_courante(dehors),
        retract(position_courante(dehors)),
        assert(position_courante(fusee)),
        regarder, !.

aller(dehors) :-
        position_courante(fusee),
        retract(position_courante(fusee)),
        assert(position_courante(dehors)),
        regarder, !.

aller(dehors) :-
        position_courante(grotte),
        retract(position_courante(grotte)),
        assert(position_courante(dehors)),
        regarder, !.

aller(dehors) :-
        position_courante(module_controle),
        retract(position_courante(module_controle)),
        assert(position_courante(dehors)),
        regarder, !.

aller(grotte) :-
        position_courante(dehors),
        retract(position_courante(dehors)),
        assert(position_courante(grotte)),
        regarder, !.

aller(grotte) :-
        position_courante(plateforme),
        retract(position_courante(plateforme)),
        assert(position_courante(grotte)),
        regarder, !.

aller(plateforme) :-
        position_courante(grotte),
        retract(position_courante(grotte)),
        assert(position_courante(plateforme)),
        regarder, !.

aller(plafond) :-
        position_courante(dehors),
        retract(position_courante(dehors)),
        assert(position_courante(module_controle)),
        regarder, !.

aller(module_controle) :-
        position_courante(module_lancement),
        retract(position_courante(module_lancement)),
        assert(position_courante(module_controle)),
        regarder, !.

aller(module_controle) :-
        position_courante(module_pistage),
        retract(position_courante(module_pistage)),
        assert(position_courante(module_controle)),
        regarder, !.

aller(module_lancement) :-
        position_courante(module_controle),
        retract(position_courante(module_controle)),
        assert(position_courante(module_lancement)),
        regarder, !.

aller(module_lancement) :-
        position_courante(module_pistage),
        retract(position_courante(module_pistage)),
        assert(position_courante(module_lancement)),
        regarder, !.

aller(module_pistage) :-
        position_courante(module_controle),
        position(code_porte, en_main),
        retract(position_courante(module_controle)),
        assert(position_courante(module_pistage)),
        regarder, !.

aller(module_pistage) :-
        position_courante(module_lancement),
        position(code_porte, en_main),
        retract(position_courante(module_lancement)),
        assert(position_courante(module_pistage)),
        regarder, !.

aller(module_pistage) :-
        position_courante(module_controle),
        decrire(echec_porte), !;
        position_courante(module_lancement),
        decrire(echec_porte), !.

% Station solaire
aller(fusee) :-
        position_courante(tarmac),
        retract(position_courante(tarmac)),
        assert(position_courante(fusee)),
        regarder, !.

aller(tarmac) :-
        position_courante(fusee),
        retract(position_courante(fusee)),
        assert(position_courante(tarmac)),
        regarder, !.

aller(tarmac) :-
        position_courante(entree),
        retract(position_courante(entree)),
        assert(position_courante(tarmac)),
        regarder, !.

aller(entree) :-
        position_courante(tarmac),
        retract(position_courante(tarmac)),
        assert(position_courante(entree)),
        regarder, !.

aller(entree) :-
        position_courante(baie),
        retract(position_courante(baie)),
        assert(position_courante(entree)),
        regarder, !.

aller(baie) :-
        position_courante(entree),
        retract(position_courante(entree)),
        assert(position_courante(baie)),
        regarder, !.


% Sabliere
aller(fusee) :-
        position_courante(dehors),
        retract(position_courante(dehors)),
        assert(position_courante(fusee)),
        regarder, !.

aller(dehors) :-
        position_courante(fusee),
        retract(position_courante(fusee)),
        assert(position_courante(dehors)),
        regarder, !.

aller(dehors) :-
        position_courante(ascenseur_haut),
        retract(position_courante(ascenseur_haut)),
        assert(position_courante(dehors)),
        regarder, !.

aller(trappe) :-
        position_courante(dehors),
        \+ position(code_trappe, en_main),
        write("Vous vous rapprochez de la trappe et essayez un code au hasard.
        Le digicode vous fait savoir que c'est le mauvais code.
        Vous abandonnez et vous relevez."), !.

aller(trappe) :-
        position_courante(dehors),
        position(code_trappe, en_main),
        decrire(ouerture_trappe),
        retract(position_courante(dehors)),
        assert(position_courante(ascenseur_haut)),
        regarder, !.

aller(projet) :-
        position_courante(ascenseur_haut),
        retract(position_courante(ascenseur_haut)),
        assert(position_courante(ascenseur_bas)),
        regarder, !.

aller(surface) :-
        position_courante(ascenseur_bas),
        retract(position_courante(ascenseur_bas)),
        assert(position_courante(ascenseur_haut)),
        regarder, !.

aller(salle) :-
        position_courante(ascenseur_bas),
        retract(position_courante(ascenseur_bas)),
        assert(position_courante(salle)),
        regarder, !.

aller(ascenseur) :-
        position_courante(salle),
        retract(position_courante(salle)),
        assert(position_courante(ascenseur_bas)),
        regarder, !.

% Intrus
aller(fusee) :-
        position_courante(dehors),
        retract(position_courante(dehors)),
        assert(position_courante(fusee)),
        regarder, !.

aller(dehors) :-
        position_courante(fusee),
        retract(position_courante(fusee)),
        assert(position_courante(dehors)),
        regarder, !.

aller(dehors) :-
        position_courante(crevasse),
        retract(position_courante(crevasse)),
        assert(position_courante(dehors)),
        regarder, !.

aller(crevasse) :-
        position_courante(dehors),
        retract(position_courante(dehors)),
        assert(position_courante(crevasse)),
        regarder, !.

aller(crevasse) :-
        position_courante(galerie),
        retract(position_courante(galerie)),
        assert(position_courante(crevasse)),
        regarder, !.

aller(galerie) :-
        position_courante(crevasse),
        retract(position_courante(crevasse)),
        assert(position_courante(galerie)),
        regarder, !.

% deplacements spaciaux
aller(espace) :-
        position_courante(fusee),
        planete(X),
        retract(position_courante(fusee)),
        assert(position_courante(espace)),
        retract(planete(X)),
        assert(planete(espace)),
        regarder, !.

aller(soleil) :-
        position_courante(espace),
        retract(position_courante(espace)),
        assert(position_courante(soleil)),
        regarder, 
        mort, !.

aller(cravite) :-
        position_courante(espace),
        planete(X),
        retract(position_courante(espace)),
        assert(position_courante(dehors)),
        retract(planete(X)),
        assert(planete(cravite)),
        decrire(atterrissage_cravite),
        regarder, !.

aller(atrebois) :-
        position_courante(espace),
        planete(X),
        retract(position_courante(espace)),
        assert(position_courante(camp)),
        retract(planete(X)),
        assert(planete(atrebois)),
        decrire(atterrissage_atrebois),
        regarder, !.

aller(intrus) :-
        position_courante(espace),
        planete(X),
        retract(position_courante(espace)),
        assert(position_courante(dehors)),
        retract(planete(X)),
        assert(planete(intrus)),
        decrire(atterrissage_intrus),
        regarder, !.

aller(leviathe) :-
        position_courante(espace),
        planete(X),
        retract(position_courante(espace)),
        assert(position_courante(dehors)),
        retract(planete(X)),
        assert(planete(leviathe)),
        decrire(atterrissage_leviathe),
        regarder, !.

aller(station_solaire) :-
        position_courante(espace),
        nombre_de_morts(X),
        X < 2,
        decrire(mort_station),
        mort, !.

aller(station_solaire) :-
        position_courante(espace),
        nombre_de_morts(N),
        N >= 2,
        planete(X),
        retract(position_courante(espace)),
        assert(position_courante(tarmac)),
        retract(planete(X)),
        assert(planete(station_solaire)),
        decrire(atterrissage_station),
        regarder, !.

aller(sabliere) :-
        position_courante(espace),
        planete(X),
        retract(position_courante(espace)),
        assert(position_courante(dehors)),
        retract(planete(X)),
        assert(planete(sabliere)),
        decrire(atterrissage_sabliere),
        regarder, !.

aller(oeil_univers) :-
        position_courante(espace),
        position(generateur, en_main),
        position(coordonnees_oeil, en_main),
        planete(X),
        retract(position_courante(espace)),
        assert(position_courante(oeil_univers)),
        retract(planete(X)),
        assert(planete(oeil_univers)),
        decrire(atterrissage_oeil),
        regarder,
        fin, !.

aller(_) :-
        write("Vous ne pouvez pas aller par la."),
        fail.


% VVVV         VVVV      OOOOOOOOOOOO      IIIIIIIIIIIIII     RRRRRRRRRRRR
%   VVVV     VVVV      OOOO        OOOO         IIII          RRRR      RRRR
%     VVVV VVVV        OOOO        OOOO         IIII          RRRRRRRRRRRRR
%       VVVVV          OOOO        OOOO         IIII          RRRR   RRRR
%         VV             OOOOOOOOOOOO      IIIIIIIIIIIIII     RRRR     RRRR


% Atrebois
voir(statue) :-
        position_courante(musee),
        statue(activee),
        write("Vous voyez une statue mysterieuse des Nomai, une civilisation ancienne et disparue. Vous lisez :
        'Cette statue est une des rares que nous ayons decouvertes.'
        'On pense que les Nomai l'ont sculptee pour honorer un evenement important de leur histoire.'
        La statue a les yeux ouverts."), nl, !.

voir(statue) :-
        position_courante(musee),
        write("Vous voyez une statue mysterieuse des Nomai, une civilisation ancienne et disparue. Vous lisez :
        'Cette statue est une des rares que nous ayons decouvertes.'
        'On pense que les Nomai l'ont sculptee pour honorer un evenement important de leur histoire.'"), nl, !.

voir(maquettes) :-
        position_courante(musee),
        write("Vous voyez un modele reduit du systeme solaire montrant les orbites des differentes planetes.. 
        Vous lisez les informations suivantes :
        'Voici notre systeme solaire, compose de Atrebois et de ses voisines. 
        Chacune des planetes a ses propres mysteres, qui continuent d'intriguer les chercheurs.'"), nl, !.

voir(journal) :-
        position_courante(fusee),
        write("C'est mon premier jour dans le programme spatial !
        J'ai vraiment hate de partir explorer toutes les planetes de notre systeme solaire.
        Je pars avec le traducteur et grace a lui je suis sur que je pourrai en apprendre davantage sur les nomai...
        Je reussirai a comprendre pourquoi ils on disparu, tout le monde sera fier de moi sur Atrebois !"), nl, !.

voir(sigles) :-
        position_courante(musee),
        position(traducteur, en_main),
        affiche_sigle,
        write("Votre traducteur vous affiche :
        'Cassava : Nous sommes bientot prets ! Filix et moi avons acheve la construction et d'apres elle,
        le calibrage de l'appareil ne devrait pas prendre longtemps.'
        'Filix : Fort heureusement, l'absence d'atmosphere sur Cravite facilitera le calibrage.
        Apres tout ce temps, je suis impatiente qu'on reprenne enfin nos recherches !'"), nl, !.

voir(sigles) :-
        position_courante(musee),
        write("Vous vous approchez et observez les ruines nomai. Vous pouvez y apercevoir d'etranges sigles nomai incomprehensibles : "),
        affiche_sigle, nl.

% Cravite
voir(structure) :-
        position_courante(hall),
        affiche_oeil,
        write("Vous regardez de plus pres la structure, il y a un ecriteau a cote. Vous traduisez :
        Soyez bienvenue en ces lieux, cet autel est un espace dedie a la contemplation de ce qui nous a conduit 
        jusqu'a ce systeme stellaire : le signal de l'oeil.
        Nous avons repere le signal de l'oeil au cours de nos peregrinations et l'avons suivi jusqu'ici pour en decouvrir la source.
        Voici ce que nous savons : la source du signal (ce que nous avons decidez d'appeler l'oeil de l'univers) 
        est plus ancienne que l'univers lui-meme, c'est tout ce que nous savons pour l'instant.
        L'oeil est plus ancien que l'univers, imaginez ce que nous pourrions apprendre grace a lui !"), nl, !.

voir(sigles) :-
        position_courante(dehors),
        planete(cravite),
        affiche_sigle,
        write("Votre traducteur vous affiche :
        Eni : 'Tout le monde va bien ? Nos coordonnees sont stabilisees.
                Par contre que s'est-il passe ? J'ai l'impression que c'est toute la planete Sombronce qui a attaque le vaisseau.'
        Lann : 'Effectivement, la planete semble etre totalement corrompu par une espece de plante invasive et aggressive.
                Nous avons pu nous en sortir, par contre je ne sais pas ce qu'il est advenue des autres capsules
                et j'ai vu le vaisseau se faire engloutir pas la planete...'
        Vesh : 'Oui et pour l'instant nous n'avons aucun moyen de communiquer avec les capusles ou le vaisseau.
                Les autres capsules ont pu s'ecraser sur n'importe quelle planete dans ce systeme...
                Nous devrions essayer de les contacter des que nous le pourrons.'
        Eni : 'Je suis tout a fait d'accord mais... regardez la surface de cette planete.
                Elle se deforme, elle craque... Elle semble prete a s'effondrer d'un instant a l'autre.'
                J'ai repere une zone un peu plus loin qui parait plus stable ; on pourrait y trouver refuge temporairement.'
        Vesh : 'Tu as vus juste, la zone est particulieremet instable, allons-y !'"), nl, !.

voir(terminal) :-
        position_courante(capsule),
        write("Votre traducteur affiche :
        Debut du journal de bord : Capsule de sauvetage 1. Vaisseau endommage. Sequence d'urgence activee. En attente du depart du vaisseau.
        Lancement de la capsule de sauvetage 3... Lancement de la capsule de sauvetage 2... Lancement de la capsule de sauvetage 1.
        ALERTE. Collision imminente. Preparation a l'impact.
        Analyse de l'environnement externe... Analyse terminee. Instabilites structurelles majeures detectees. 
        Poches d'air respirables detectees. Energie solaire adequate detectee."), nl, !.


voir(boule) :-
        position_courante(capsule),
        write("Vous vous approchez de la boule et remarquez que votre scanner fait de plus en plus de bruit.
        C'est en fait une balise envoyant des signaux de secours.
        Elle est activee depuis que les nomai se sont crashes ici."), nl, !.

voir(sigles) :-
        position_courante(caverne),
        affiche_sigle,
        write("Votre traducteur vous affiche :
        Eni : 'Voila... le systeme de communication est en place, on ne pourra pas contacter d'autres vaisseaux nomai avec ca 
                mais au moins on devrait pouvoir communiquer avec les autres capsules qui se sont ecrasees dans le systeme.'
        Vesh : 'Ici la capsule de sauvetage 1. Y a-t-il quelqu'un ? Repondez... .
                Allez... Foli...Keek...que quelqu'un reponde.'
        Lann : 'Ils n'entendent peut-etre pas. Les autres capsules pourraient etre hors de portee, ou...'
        Eni : 'Ou detruites. Et si notre vaisseau principal a lui aussi ete touche... il n'a sans doute pas survecu a l'impact.
                Nous sommes... seuls.'
        Vesh : 'Que faisons nous alors ? Nous pourions reconstruire un vaisseau ?'
        Eni : 'Refaire un vaisseau nous prendrai un temps monstrueux !
                Et nous ne savons pas comment le signal de l'oeil se comporte, il pourrait disparaitre entre temps.
                Il est trop important, nous devons continuer les recherches dessus.'
        Vesh : 'Oui mais si on refaisait un vaisseau nous pourrions contacter des vaisseaux nomai qui pourraient nous aider.'
        Lann : 'Eni a raison, tu as vu les releves dans le vaisseau toi aussi, l'oeil est trop important.'
        Vesh : 'Tres bien, le source du signal prime.'
        Lann : 'Sinon j'ai eu le temps de faire de nouvelles analyses sur la planete et j'ai trouve une zone beaucoup plus stable.
                Ce serait un abri parfait. Par contre pour l'atteindre nous aurons besoin d'accrocher des cristaux antigravitationnels au plafond
                pour passer sous la planete. En effet, passer par l'exterieur serait trop risque.'
        Eni : 'Une route de cristaux suspendus ? Ce sera complexe... mais faisable. 
                Nous avons de quoi fabriquer des cristaux ici.'
        Vesh : 'Parfait, alors faisons-le !'
        Lann : 'Je vais partir en premier installer la route lorsque j'aurai les cristaux.
                Vous n'aurez plus qu'a 'aller' au 'plafond'.'"), nl, !.

voir(sigles) :-
        position_courante(hall),
        affiche_sigle,
        write("Votre traducteur vous affiche :
        Vesh : 'Ah Eni tu es revenu, alors tu as trouve l'oeil ?'
        Eni : 'Bah... les calculs etaient justes, et pourtant... rien. Pas la moindre variation dans le signal.
                C'est comme si l'Oeil ne diffusait plus rien du tout.'
        Vesh : 'On a verifie et recalibre chaque parametre. Le detecteur fonctionne.
                Mais... l'Oeil doit emettre un signal bien trop faible pour notre equipement actuel. 
                Nous ne capterons jamais quoi que ce soit a cette echelle.'
        Lann : 'Alors, soit l'Oeil s'est affaibli, soit il est bien plus lointain que nous le pensions.
                Peut-etre meme hors de portee de ce type de capteur. Si nous voulons le trouver, il va falloir penser... en plus grand.
                Nous allons devoir construire un detecteur bien plus avance et complexe ! Un gigantesque observatoire.'"), nl, !.


voir(sigles) :-
        position_courante(dortoir),
        affiche_sigle,
        write("Votre traducteur vous affiche :
        'Filix : Ca va Pye ? Tu n'as pas l'air bien.'
        'Pye : J'avoue que ca fait beaucoup de pression... 
                Ils me demandent quand meme de recreer un generateur similaire a celui du vaisseau mere.'
        'Filix : Ne t'inquiete pas je suis sur que tu vas y arriver !'"), nl, !.

voir(sigles) :-
        position_courante(laboratoire),
        affiche_sigle,
        write("Votre traducteur vous affiche :
        Eni : 'C'est officiel... l'observatoire a ete un echec. Rien. Meme avec sa taille, pas le moindre signal de l'Oeil. 
                C'est comme si l'Univers refusait de nous guider vers lui.'
        Vesh : 'On a concu le plus grand detecteur jamais construit... Et malgre cela, il reste muet. 
                Peut-etre avons-nous mal compris l'Oeil. 
                Peut-etre que son signal n'est pas capte par nos instruments, meme a cette echelle.'
        Lann : 'Je refuse de croire que tous nos efforts soient vains. Mais peut-etre devons-nous envisager d'autres methodes. 
                Nous pourrions... le trouver par l'observation directe.'
        Eni : 'Attends, tu veux dire... envoyer une sonde pour reperer l'Oeil ? Dans le vide immense de l'espace ? 
                Lann, envoyer une sonde au hasard dans l'univers n'a aucune chance de reussir. Meme si l'Oeil est quelque part, 
                il est minuscule a cette echelle. La sonde pourrait le manquer des milliards de fois.'
        Lann : 'Justement, Vesh. Je ne parle pas d'un envoi unique. Imagine une sonde lancee encore et encore, 
                un nombre infini de fois, jusqu'a ce qu'elle atteigne l'Oeil. Il y a... un moyen de le faire.'
        Vesh : 'Un nombre infini de fois ? Lann, que veux-tu dire ?'
        Lann : 'Les recherches que nous avons faites sur le trou noir de Cravite ont revele un phenomene inattendu. 
                Les objets qui tombent dans ce trou noir reapparaissent dans un trou blanc de l'autre cote... 
                quelques millisecondes avant d'etre entres dans le trou noir. Ce retour temporel pourrait theoriquement etre amplifie.'
        Eni : 'Amplifie... en injectant de l'energie dans la distorsion ? 
                Si nous recreons une version miniature de Cravite, un generateur de distorsions, et canalisons de l'energie a l'interieur, 
                nous pourrions manipuler cette distorsion temporelle pour ramener la sonde en arriere... disons, 
                toutes les 17 minutes : le temps qu'il faudrait a la sonde pour parcourir le systeme.'
        Vesh : 'D'accord, je crois que j'ai une idee de systeme pour faire tout fonctionner.
                Mais nous devons aller sur Leviathe, nous aurons besoin des cyclones qui se trouvent dessus.
                En effet, nous devrons construire un lance sonde geant et les cyclone nous aiderons
                a mettre tout ca en orbite.'
        Lann : 'Parfait! Partons sur Leviathe alors. Pye, etant l'apprentie d'Annona pourrais-tu rester ici
                pour nous construire le generateur de distorsion s'il te plait ?'
        Pye : 'Pas de soucis, je m'y mets tout de suite ! Par contre, il va nous falloir une sacree quantite d'energie.'
        Vesh : 'J'ai ma petite idee pour ca aussi.'"), nl, !.

% Leviathe
voir(sigles) :-
        position_courante(dehors),
        planete(leviathe),
        write("Le sol du tunnel pour aller au module de pistage de la sonde s'est effondre.
        Je me suis permis de ramener des pierres antigravites pour passer quand meme.
        Faites comme sur Cravite."), nl, !.

voir(dessin) :-
        position_courante(grotte),
        write("Vous vous approchez de la fresque et voyez quelque chose ressemblant a ceci :"), nl,
        affiche_dessin, nl, !.

voir(appareil) :-
        position_courante(grotte),
        write("Votre traducteur vous affiche :
        Phlox : Yarrow, accepterais-tu de reculer un peu pour que Daz soit plus proche de la statue ? 
                Lorsqu'elle se lie a quelqu'un, la statue choisit la personne qui se trouve le plus pres d'elle.
        Phlox : ...Tu vois, elle a ouvert les yeux. Cela veut dire que la statue s'est liee a Daz. 
                A present, ou qu'il soit dans le systeme stellaire, 
                la statue de Daz enregistrera ses souvenirs et les enverra au projet sabliere noire.
        Daz : Et maintenant que nous disposons de notre premier lien, 
                nous pouvons tester notre prototype de stockage de mnemonique.
        Daz : Chaque statue transmettra les souvenirs d'un nomai a son unite de stockage, 
                qui se trouve sur la Sabliere noire.
        Phlox : Chaque unite de stockage sera pourvue d'un masque qui n'est autre que le pendant de la statue. 
                Celui-ci pourra renvoyer les souvenirs ainsi stockes au nomai auquel elles appartiennent."), nl, !.

voir(sigles) :-
        position_courante(plateforme),
        write("Votre traducteur vous affiche :
        Ramie : J'ai installe les masques a l'interieur du projet sabliere noire Phlox. 
                C'est rassurant de savoir que les statues ne se lieront pas avant la reussite du projet. 
                J'imagine que l'experience serait difficile a supporter dans le cas contraire.
        Phlox : En principe, les statues ne se lieront qu'a la reussite du projet, 
                mais elles s'activeront egalement par mesure de securite dans le cas d'une defaillance technique.
        Ramie : Ah oui ? Pourquoi ca ?
        Phlox : Si quelque chose ne se passe pas comme prevu avec le projet sabliere noire, 
                les statues (et leurs masques) nous avertiront et nous permettrons d'y remedier. 
                Autrement, nous pourrions ne jamais nous apercevoir du probleme.
        Ramie : Je n'avais pas pense a ca ! Ce serait la un sort absolument affreux."), nl, !.

voir(terminal) :-
        position_courante(module_controle),
        write("Votre traducteur vous affiche :
        Requete de lancement de sonde recue du projet sabliere noire.
        Canon aligne sur une trajectoire de sonde choisie aleatoirement. Champ gravitationnel active.
        Debut de journal de bord : Lance-sondes orbital. Requete de lancement recue . Lancement de la sonde reussi.
        Le module de pistage recoit des donnees de la sonde.
        ATTENTION : Structure du lance-sondes orbital compromise lors du lancement. Degats detectes sur de multiples modules."), nl, !.

voir(sigles) :-
        position_courante(module_controle),
        write("Votre traducteur vous affiche :
        Mallow : Tu imagines Privett ? Le module de pistage sera le premier a connaitre les coordonnees de l'Oeil de l'univers ! 
                Et tu seras la premiere a les voir !
        Privett : Cela m'honore et me terrifie !
                Tu ne vas pas pousser la puissance du lance-sondes orbital a un niveau qui l'endommagerait n'est ce pas ?
        Mallow : Ne t'en fais pas mon amie ! De toute facon, nous n'allons tirer qu'une seule fois, 
                alors qui se soucierait de quelques petits dommages structurels sur le lance-sondes orbital ?
        Privett : Moi, Mallow ! Je m'en soucie, car nous ne pourrons pas recevoir les donnees de notre sonde 
                si l'antenne qui relie le lance-sondes et le module de pistage est detruit !"), nl, !.

voir(sigles) :-
        position_courante(module_lancement),
        write("Votre traducteur vous affiche :
        Cassava : J'ai de mauvaises nouvelles Avens. Yarrow a dit qu'il y avait un probleme avec la source d'alimentation envisagee, 
                donc le lance sonde orbital n'aura pas ordre de tirer. 
        Avens : J'espere que tu ne me menes pas en vaisseau Cassava.
        Cassava : J'aurais bien aime, mon ami, mais non. Ils ne sont pas certains de pouvoir regler le probleme, 
                donc les activites du lance-sondes orbital sont suspendues jusqu'a nouvel ordre.
                Rejoins moi sur la station solaire, c'est la que l'on a un probleme..."), nl, !.

voir(sigles_mur) :-
        position_courante(module_lancement),
        write("Votre traducteur vous affiche :
        Lami : Papa pourquoi je ne peux pas rentrer dans le module de pistage ?
        Avens : Le module de pistage est la piece maitresse pour trouver l'Oeil de l'univers,
                il contient de trop precieux terminaux pour etre abime par le temps ou des filoux comme toi.
                Nous l'avons donc connstruit dans un materiaux tres solide et verrouille par un digicode.
        Lami : Et je peux avoir le code ?
        Avens : Si tu veux avoir le code il faudra aller sur la station solaire mon grand et fouiller les notes de Pye."), nl, !.

voir(terminal) :-
        position_courante(module_pistage),
        nombre_de_morts(X),
        NbSondes is 9318054 + X,
        write("Votre traducteur vous affiche :
        Reception des donnees de la sonde "), write(NbSondes), write(".
        Recuperation des precedentes donnees de lancement de la Sabliere noire.
        Nombre total de sondes lancees : "), write(NbSondes), write(".
        Une anomalie spatiale remplissant tous les criteres connus relatifs a l'Oeil de l'univers a ete detectee par la sonde 9 318 054.
        Recuperation des coordonnees enregistrees de la Sabliere noire. Affichage des coordonnees de l'Oeil de l'univers.
        -> (Obtenu : coordonnees_oeil)"),
        assert(position(coordonnees_oeil, en_main)), nl, !.

voir(sigles) :-
        position_courante(module_pistage),
        write("Votre traducteur vous affiche :
        Yarrow : J'ai des nouvelles interessantes Privett : le projet sabliere noire est presque pret a recevoir 
                les donnees de la sonde envoyee par le lance-sondes orbital. Ramie effectue quelques ultimes reglages mais 
                elle n'en a plus pour tres longtemps. Le lance-sondes orbital et son equipage se portent bien ?
        Privett : Nous allons bien ! Le module de pistage est pret a enregistrer la trajectoire de vol de chaque tir et 
                vous transmettra automatiquement toutes les donnees pertinentes.
                Quand la sonde aura trouve la position de l'Oeil de l'univers, je vous enverrai directement une alerte a toi et Ramie.
                D'une autre facette, je commence a m'inquieter pour l'integrite structurelle de ce canon et l'integrite morale de son equipage."), nl, !.

% Station solaire
voir(terminal) :-
        position_courante(tarmac),
        compteur_temps(T),
        write("Votre traducteur vous affiche :
        IL Y A 281 042 ANS : Aucune commande d'utilisateur recue depuis 10 minutes. Mise en vieille de l'ensemble des systeme.
        IL Y A "), write(T), write(" MINUTES : Augmentation de l'activite solaire detectee. 
                L'integrite de la coque de la station solaire approche du seuil critique. Fermeture des issues de secours."), nl, !.

voir(bureau) :-
        position_courante(entree),
        write("Vous vous approchez du bureau et voyez pleins de schema de machines en tout genre.
        Vous comprenez rien mais vous fouillez un peu dans les documents.
        Vous trouvez une tablette sur laquelle vous pouvez traduire : 
                'code porte leviathe'
        Vous recuperez le document, il pourrait servir.
        Vous en voyez une autre sur laquelle vous pouvez traduire :
                'code Sabliere noire'
        Evidemment, vous prenez aussi !
        -> (Obtenu : code_porte, code_trappe)"),
        assert(position(code_porte, en_main)),
        assert(position(code_trappe, en_main)), nl, !.

voir(sigles) :-
        position_courante(entree),
        write("Votre traducteur vous affiche :
        Pye : Mission : la science nous contraint a faire exploser l'etoile !
        Idaea : Pourrions nous changer ca ? Travailler avec un ordre de mission aussi morbide sous les yeux ne me rejouit guere.
        Pye : Il est tout a fait correcte pourtant. Nous allons creer une supernova au nom du progres scientifique. Voila notre mission.
        Idaea : Notre mission est de decider si cet exploit, aussi irresponsable soit-il, est de l'ordre du possible.
                En voila une meilleure. Mission : determiner s'il est possible d'amener l'etoile a exploser.
        Pye : Tu n'as aucun sens de l'humour.
        Idaea : Mais moi au moins j'ai un sens de l'ethique !
        Pye : Je te saurais gre de ne pas partir en supernova avec moi avant que l'etoile ne l'ait fait Idaea."), nl, !.

voir(terminal) :-
        position_courante(baie),
        compteur_temps(T),
        Temps_restant is 17 - T,
        write("L'etoile entre dans la derniere phase de son cycle de vie. Elle approche de geante rouge. 
        DANGER : Evacuez la station solaire.
        Temps restant avant la mort de l'etoile : environ "), write(Temps_restant), write(" MINUTES."), nl, !.

voir(sigles) :-
        position_courante(baie),
        write("Votre traducteur vous afffiche :
        Yarrow : Que s'est-il passe ? La station solaire n'a pas tire ? 
        Pye : Elle a tire Yarrow. Mais ca a echoue. L'etoile a a peine reagit. 
                Il y a bien eu des changements infinitesimaux en surface mais ils etaient a peine visibles, meme au troisieme oeil.
                La station solaire ne servira a rien. Elle ne pourra jamais faire exploser l'etoile. 
                Je ne sais que faire maintenant, mes amis. 
                Je suppose que nous devrions tout reprendre depuis le debut, mais je ne sais comment nous y prendre. 
        Yarrow : Commencez par rentrer tous les deux sur la Sabliere noire, mon amie. 
                Peut-etre qu'une nouvelle tache vous aidera : 
                Spire a remarque une comete, que nous avons appelle l'intrus,
                qui approche de ce systeme stellaire et que nous souhaiterions voir de plus pres...
                Pye... Je souffre pour vous deux. Nous savons tous a quel point vous avez travaille dur. 
                Je ne peux que vous offrir ma compassion. Comment vas-tu ? Qu'en est-il d'Idaea ?
        Idaea : Nous allons bien Yarrow (du moins, autant que faire se peut, compte tenu des circonstances), meme si nous sommes decus. 
                Je n'approuvais peut-etre pas l'explosion de l'etoile mais je n'ai jamais souhaite que notre appareil echoue. 
                J'esperais en avoir fini avec ce funeste projet.
        Pye : Je vais aller sur l'intrus ca me fera du bien vous avez raison...
        Idaea : Je vais personnellement rester ici si ca ne te derange pas.
                
        Si le projet n'a pas pu etre alimente... Comment est-il possible que vous soyiez dans la boucle temporelle ?"), nl, !.

voir(sigles_sol) :-
        position_courante(baie),
        write("Votre traducteur vous affiche :
        Idaea : Quel dommage que le projet n'ait pas fonctionne... 
                Et dire qu'il suffisait simplement de prendre le generateur de distorsion du projet Sabliere noire 
                dans un vaisseau pour que celui ci distorde le vaisseau jusqu'au coordonnees que l'on aurait trouve...
                Il suffisait juste de 'aller' a 'oeil_univers' avec les coordonnées du module de pistage...
                Tout etait la..."), nl.

% Intrus
voir(appareil) :-
        position_courante(dehors),
        planete(intrus),
        write("Votre traducteur vous affiche :
        'Poke : Voila qui est problematique. Il semblerait que la comete veuille engloutir notre navette sous la glace. 
                Si nous restons trop longtemps a la surface, la navette pourrait completement geler.'
        'Clary : Et si l'une d'entre nous restait a bord de la navette, continuer de faire chauffer les moteurs et surveiller la surface ?'
        'Pye : Je pense que c'est une bonne idee, Clary. Si tu ne vois pas d'inconvenient a rester ici, Poke et moi allons explorer la surface.'"), nl, !.

voir(appareil) :-
        position_courante(crevasse),
        write("Votre traducteur vous affiche :
        'Pye : Mes releves d'energie ont gagne en intensite maintenant que nous sommes sous la surface.
                Je commence a me demander si ce ne serait pas plus dangereux que nous le pensions.'
        'Pye :  Clary, tu nous recois ?'
        'Clary : Oui mais plus faiblement. Je crains que nous ne perdions entierement le contact si vous vous aventurez plus profondement.'
        'Poke : Garde les moteurs de la navette allumes Clary. Nous rentrons des que nous avons identifie l'origine de ces releves d'energie.'
        'Clary : J'ai bien compris, mais... soyez prudentes, toutes les deux.'"), nl, !.

voir(appareil) :-
        position_courante(galerie),
        write("Votre traducteur vous affiche :
        'Poke : Cette enveloppe de pierre spherique semble etre la source de l'energie que nous avons releve... Non ?
                Je dirais plutot que la source se trouve a l'interieur de cette pierre. Je detecte une sorte de matiere exotique.
        'Pye : Cette pierre attenue fortement les releves que nous recevons.
                Ils devraient etre au moins deux fois superieurs a ce qu'on voit actuellement.
        'Poke : Pye, je pense qu'il vaut mieux eviter d'interagir avec cette matiere.
                Pour autant que je sache, un contact direct serait probablement fatal.
        'Pye : Je n'ai jamais rencontre une coque de ce genre, mais c'est notre seul rempart face a ce qu'elle renferme.
                Et le pire, c'est que cette matiere est incroyablement volatile.
        'Poke : ...Pye, Je ne sais pas ce qu'il y a dans cette enveloppe de pierre, mais ca n'est pas seulement instable.
                Cette matiere est soumise a une pression de plusieurs tonnes. Regarde les releves de densite.
                Je n'ai jamais rien vu d'aussi compact ! Mais qu'est ce que c'est que ca ?
        'Pye : Sa magnitude est bien superieur a ce que j'envisageais. Si la pierre venait a ceder,
                la matiere mortelle qu'elle renferme se repandrait a une telle vitesse qu'elle engloutirait tout ce systeme stellaire en un instant.
                Et la pression 	ne cesse de croitre a mesure que la comete s'en approche...
        'Pye : Retourne immediatement a la navette ! Il faut prevenir nos camarades du terrible danger qui les menace.
                Pose ton materiel et cours !
        'Poke : Que fais tu Pye ?
        'Pye : Plus on en saura sur cette xenomatiere, meilleure seront nos chances de survie. 
                Je vais essayer d'en apprendre le plus possible. Va prevenir les autres. 
                Ils pourront peut-etre construire un abri... Aller, Poke ! Maintenant !
        
        Vous abaissez votre traducteur... Vous regardez le squelette pres de vous... Ca doit etre Pye."), nl, !.

% General
affiche_sigle :-
        write("
                           @@@@@@@@
                        @@@        @@@
                     @@@              @@@
                   @@                    @@                    @@@@@@@@@
                 @@                        @@               @@@         @@@
                @                            @@          @@@               @@@
               @                               @       @@                     @@
@             @                                 @    @@                         @@
 @            @                                  @  @                             @
  @           @                                  @ @                               @
   @           @                                 @@                                @
    @           @@                               @                                 @
     @                                          @                                 @
      @                                        @                                @@
       @                                      @           @                   @@
        @@                                  @@             @@              @@@
          @@                              @@                 @@@        @@@
            @@                          @@                      @@@@@@@@
              @@@                    @@@
                 @@@              @@@
                    @@@        @@@
                       @@@@@@@@
        
        "), nl.

affiche_oeil :-
        write("      
                                         |                  
                                         |   |             /:#
                                         {  -|          [ }-
                                         ] -}         | ] # /
                                         [-/         @# _( : 
                                         #          / ] # }
                         )               #        ( - @- ]
                          - #            ####    } |] ^ |
                            [ |]_    ## @@ @@ @##-/@ : ]
                             } ^#### @ @ @@ @@ @#### [
                               @@@ @@@@/---]@@@@ @@@@
                              @@ @@@@/       ]@@ @ @@@
                 [] } @ # ^ ]@ @@@@|           |@@@ @@@^_ 
           - [] } @ {] } @ - @@ @|               |@@ @@@/ ]#@
                [# } @ - : ] @@@ @@|           |@@@ @@@  : ( ]
                              @@@ @@@/       ]@@@ @@@@       !
                               @ @@@@@ /---]@@@ @ @@@    
                              _ ####@@@ @ @ @  @####_  
                             @|     ##@@ @@@ @##-/-] [@ #
                            (]/        ####            }(#
                           (#                            ] _x
                          {x                                                 
                            
        "), nl.

affiche_dessin :-
        write("
                  Masque
                        
              ]]]       ]]]
                                
        Statue     [[[    Nomai 
        "), nl.



% DDDDDDDDDDDD      IIIIIIIIIIIII     AAAAAAAAA     LLLLL             OOOOOOOOOOO     GGGGGGGGGGG    UUUU       UUUU     EEEEEEEEEEEE     SSSSSSSSSSSS
% DDDD      DDDD         IIII         AAAA   AAAA   LLLLL          OOOO       OOOO  GGGG             UUUU       UUUU     EEEE            SSSS
% DDDD        DDD        IIII         AAAAAAAAAAA   LLLLL          OOOO       OOOO  GGGG   GGGGGGG   UUUU       UUUU     EEEEEE            SSSSSSSSSSSS
% DDDD      DDDD         IIII         AAAA   AAAA   LLLLL          OOOO       OOOO  GGGG       GGG   UUUU       UUUU     EEEE                     SSSS
% DDDDDDDDDDDD      IIIIIIIIIIIII     AAAA   AAAA   LLLLLLLLLLLLL    OOOOOOOOOOO     GGGGGGGGGGGG     UUUUUUUUUUUUUU     EEEEEEEEEEEE     SSSSSSSSSSSS

parler :-
        position_courante(camp),
        nombre_de_morts(X),
        X =< 0,
        write("Si c'est pas notre pilote ! Je vois que tu es de retour de ta derniere nuit a la belle etoile avant ton decollage.
        Alors ca y est, c'est le grand jour ? J'ai l'impression que tu as rejoint le programme spatial pas plus tard qu'hier, 
        et voila soudain que tu t'appretes a partir pour ton premier voyage en solitaire.
        Qu'est-ce que t'en dis - t'as pas hate de t'envoler a bord de ce petit bijou ? Le plein est fait, y'a plus qu'a decoller !
        -> (Options : dire allons-y, dire ok). "), nl, !.

parler :-
        position_courante(camp),
        nombre_de_morts(X),
        X > 0,
        write("Alors, t'as pas hate de t'envoler a bord de cette fusee ? Le plein est fait, y'a plus qu'a decoller !
        -> (Options : dire allons-y, dire ok, dire je_viens_de_mourir). "), nl, !.

parler:-
        position_courante(etage),
        nombre_de_morts(X),
        X > 0,
        write("He ! Regarde, la statue a ouvert les yeux ! Tu aurais bien aime voir ca, pas vrai ? (Soupir...) Moi aussi.
        Je suis encore bien loin d'avoir perce le secret de cette statue."), nl, !.
        
parler :-
        position_courante(etage),
        position(codes, en_main),
        write("Aller c'est l'heure, part explorer l'espace jeune atrien !"), nl, !.

parler :-
        position_courante(etage),
        write("Te voila ! Je viens de terminer les observations prealables. Les conditions meteorologiques locales sont bonnes. 
        C'est l'heure pour notre plus jeune astronaute de prendre son envol !
        Et tu seras notre toute premiere recrue a partir avec un traducteur de nomai portable !
        Je t'avoue que rien que d'y penser, j'en ai la tete qui tourne.
        On est mieux equipes que jamais pour lever le voile sur les mysteres des Nomai. 
        Vous avez fait un travail remarquable, toi et Hal ! Voici les codes de lancement pour utiliser l'ascenseur.
        -> (Obtenu : traducteur, codes)"),
        assert(position(traducteur, en_main)),
        assert(position(codes, en_main)), nl, !.

parler :-
        position_courante(dehors),
        planete(intrus),
        compteur_temps(X),
        X =< 10,
        write("Ben ca alors ! Salut toi ! J'imagine que ton premier decollage s'est bien passe, alors? 
        Bienvenue sur l'intrus. J'espere que tu n'as rien contre la glace.
        -> (Options : dire que_fais_tu_ici)"), nl, !.

parler :-
        position_courante(dehors),
        planete(intrus),
        compteur_temps(X),
        X > 10,
        write("Les etoiles ! Elles sont toutes en train de mourir ! Avec autant de supernovas, ca ne peut-etre que ca ! 
        On est les prochains tu comprends ? Notre soleil ! Nom d'un Atrien, on est les prochains !
        -> (Options : dire comment_ca)"), nl, !.


% interaction personnages
dire(allons-y) :-
        position_courante(camp),
        write("Ta motivation fait plaisir a voir, mais souviens-toi, si tu bousilles la fusee, viens pas m'en demander un autre. 
        Je ne suis pas en alliage d'aluminium leger resistant a la rentree atmospherique, tu sais.
        Quoi qu'il en soit, tu vas devoir parler a Cornee a l'observatoire pour obtenir les codes de lancement si tu veux pouvoir decoller."), nl.

dire(ok) :-
        position_courante(camp),
        write("Ha ha ! Tout est pret de mon cote - on va enfin pouvoir tester le nouveau systeme d'atterrissage 
        hydraulique avec un pilote plutot que le systeme automatique !... En parlant de pilote, 
        evite de t'ecraser a ton premier atterrissage, compris ? Quoi qu'il en soit, tu vas devoir parler a 
        Cornee a l'observatoire pour obtenir les codes de lancement si tu veux pouvoir decoller."), nl.

dire(je_viens_de_mourir) :-
        position_courante(camp),
        write("Hola ! On a fait un cauchemar ? Tu dors encore a moitie, mais tu m'as l'air bel et bien en vie.
        Je sais que c'est la tradition de dormir a la belle etoile la veille d'un depart, mais si tu veux mon avis, ca vous rend un peu nerveux."), nl.

dire(que_fais_tu_ici) :-
        position_courante(dehors),
        planete(intrus),
        write("Cornee m'a fait remarquer que nos cartes etaient obsoletes, donc je suis la pour les mettre a jour. 
        Mais il y a quelque chose de... comment dire... bizarre. J'ai vu... Allez, bien dix supernovas ? Meme douze peut-etre ? 
        On depasse la dizaine maintenant, et ca, ce n'est pas normal, tu sais. Pas normal du tout...
        Reviens me voir plus tard, je vais essayer de voir ce que je peux trouver a ce sujet..."), nl.

dire(comment_ca) :-
        position_courante(dehors),
        planete(intrus),
        write("C'est les etoiles. Toutes les autres etoiles sont en train de mourir, tu vois. 
        Oh, pourquoi il fallait qu'on naisse pendant l'extinction de l'univers ? Et notre soleil, il va… Les cartes des etoiles ! 
        Pourquoi ? Il fallait vraiment que je les mette a jour, hein ? J'aurais prefere ne rien savoir, mais non, non ! 
        Il a fallu que je mette les cartes etoiles a jour ! Il fallait que j'aille fureter ou je n'aurais pas du ! 
        Et maintenant, notre soleil est sur le point de.. sur le point de… Oh… Je ne me sens pas tres bien… 
        J'aimerais que tu t'en ailles s'il te plait."), nl.


% DDDDDDDDDDDD     EEEEEEEEEEEE     SSSSSSSSSSSS      CCCCCCCCCCCCC  RRRRRRRRRRRR     IIIIIIIIIIIII    PPPPPPPPPPP       TTTTTTTTTTTT     IIIIIIIIIIIII    OOOOOOOOOOO     NNNN        NNNN     SSSSSSSSSSSS
% DDDD      DDDD   EEEE            SSSS             CCCC             RRRR      RRRR       IIII         PPPP      PPPP        TTTT             IIII       OOOO       OOOO   NNNNNN      NNNN    SSSS
% DDDD        DDD  EEEEEEEEEEEE       SSSSSSSSSSS  CCCC              RRRRRRRRRRRRR        IIII         PPPPPPPPPPPP          TTTT             IIII       OOOO       OOOO   NNNN NNN    NNNN      SSSSSSSSSSSS
% DDDD      DDDD   EEEE                       SSSS  CCCC             RRRR   RRRR          IIII         PPPP                  TTTT             IIII       OOOO       OOOO   NNNN   NNN  NNNN             SSSS
% DDDDDDDDDDDD     EEEEEEEEEEEE     SSSSSSSSSSSS      CCCCCCCCCCCCC  RRRR     RRRR    IIIIIIIIIIIII    PPPP                  TTTT         IIIIIIIIIIIII    OOOOOOOOOOO     NNNN     NNNNN      SSSSSSSSSSSS

% Atrebois
decrire(fusee) :-
        planete(atrebois),
        write("Vous arrivez a l'ascenseur, entrez les codes de lancement et arrivez a la plateforme de lancement ou vous attend votre fusee.
        Vous entrez par l'ecoutille, vous voici dans votre vaisseau spatial.
        Vous pouvez y voir votre journal de bord ainsi que les commandes du vaisseau.
        -> (Options : voir journal, aller espace, aller camp)"), nl.
        
decrire(reveil) :-
    write("Vous vous reveillez dans la nature, observant le ciel. 
    Vous voyez les etoiles et distinguer une forme exploser au loin... 
    Une planete de tres grande taille parcourt tranquillement ton champ de vision."), nl.

decrire(camp) :-
    write("Le feu crepite et eclaire la nuit, un villageois se tient pres du bois crepitant.
    Une fusee se tient en hauteur, cela vous donne le tournis. Un ascenseur pres de vous permet d'y acceder.
    Au dela du feu, se tient un chemin menant vers un batiment eclairee...
    -> (Options : parler, aller fusee, aller musee)"), nl.


decrire(musee) :-
    write("Vous rentrez, ebloui, dans un grand batiment avec une multitude de statues, maquettes et d'etranges sigles sur le mur.
    Chaque objet semble plus interessant l'un que l'autre.
    -> (Options : voir statue, voir maquettes, voir sigles, aller etage, aller camp)"), nl.

decrire(etage) :-
    write("Vous arrivez a l'etage du musee, une grande bais vitree au plafond permet de voir les etoiles.
    Cornee, le gerant du musee, se tient pres de son bureau.
    -> (Options : parler, aller musee)"), nl.

decrire(evenement_statue) :-
        write("Vous descendez les escaliers et vous retrouvez devant la statue nomai du musee.
        Soudainement, la statue ouvre les yeux et vous regarde brusquement.
        Vous n'entendez qu'un bruit sourd et voyez ses grands yeux violets, 
        tandis que vos souvenirs depuis votre reveil defilent devant vos yeux avec des rayons violets les encerclant.
        Tout d'un coup, ses yeux s'eteignent et le bruit sourd cesse...
        Vous restez au beau milieu du musee, perplexe. Vous regardez autours de vous... 
        Personne d'autre que la ruine nomai contenant des sigles n'a vu ce que vous venez de voir."), nl.


% Cravite
decrire(fusee) :-
        planete(cravite),
        write("Vous vous dirigez vers votre fusee et entrez par l'ecoutille.
        Vous pouvez y voir votre journal de bord ainsi que les commandes du vaisseau.
        -> (Options : voir journal, aller espace, aller dehors)"), nl.

decrire(dehors) :-
        planete(cravite),
        write("Vous regardez autours de vous.
        Il y a votre fusee vous attendant sagement ainsi que le trou cree par la meteorite.
        Vous voyez aussi une capsule de sauvetage nomai avec des sigles ecrient par terre a cote.
        Enfin, vous voyez un chemin permettant d'acceder a une petite caverne.
        -> (Options : voir sigles, aller fusee, aller trou, aller capsule, aller caverne)"), nl.

decrire(trou) :-
        write("Vous sautez dans le vide en direction du centre de la planete, c'est-a-dire le trou noir.
        Vous rentrez dedans et... Le vide de l'espace vous entoure.
        Vous apercevez toujours une multitude d'etoiles ainsi que le soleil au loin,
        mais bizarrement il n'emet pas la meme lumiere que d'habitude... Ce n'est pas le soleil, c'est une autre etoile.
        Vous etes en fait a l'autre bout de la galaxie.
        Vous vous retournez et voyez, de la d'ou vous etes arrivez, une lumiere blanche eblouissante.
        Vous essayez alors de revenir a l'interieur mais la lumiere vous repousse... C'est un trou blanc !
        Vous etes condamne a errer dans l'espace. Petit a petit votre reserve d'oxygene se vide.
        Vous vous asfixiez et soudain, plus rien..."), nl.

decrire(capsule) :-
        write("Vous rentrez dans la capsule, elle n'est plus en tres bon etat.
        Tout ce que vous pouvez y voir c'est un terminal au fond ainsi qu'une boule excitant vos appareils.
        Il y a derriere vous la porte pour revenir dehors.
        -> (Options : voir terminal, voir boule, aller dehors)"), nl.

decrire(caverne) :-
        write("Vous arrivez dans la caverne et voyez un petit camp nomai laisse a l'abandon.
        Vous pouvez voir des sigles nomai au sol.
        Vous apercevez de droles de cailloux accroches au plafond et a un mur.
        Et il y a l'entree de la caverne permettant de revenir dehors.
        -> (Options : voir sigles, aller dehors)"), nl.

decrire(hall) :-
        write("Vous arrivez dans ce qui s'apparente a un hall assez grand ou vous pouvez y apercevoir des endroits intriguants.
        Tout d'abord, vous voyez une grande structure au milieu de la salle ainsi que des sigles similaires a ceux du musee sur le mur.
        Ensuite, il y a des portes menant a d'autres endroits. Un mur mene au chemin antigravite pour retourner a la caverne, 
        une autre vers ce qui semble etre un dortoir et la derniere vers ce qui pourrait correspondre a un laboratoire.
        -> (Options : voir structure, voir sigles, aller dortoir, aller laboratoire, aller caverne)"), nl.

decrire(dortoir) :-
        write("Vous arrivez dans la salle ou se situe plusieurs lits.
        Sur deux d'entre eux se trouve des squelettes nomai, ils semblaient dormir paisiblement avant de mourir.
        Derriere vous se trouve la porte pour revenir dans le hall.
        Au fond de la piece, vous voyez des sigles nomai.
        -> (Options : voir sigles, aller hall)"), nl.

decrire(laboratoire) :-
        write("Vous arrivez dans une piece avec des plans de travail et une multitude d'outils.
        Vous pouvez voir des sigles sur ce qui semble etre un tableau.
        Derriere vous se trouve la porte pour revenir dans le hall.
        -> (Options : voir sigles, aller hall)"), nl.

decrire(passage_antigrav) :-
        write("Vous vous approchez du mur et appuyez vos pieds au mur.
        Ils restent colles au mur et vous commencez a marcher.
        Vous etes dans le vide et voyez au dessus de votre tete le trou noir de la planete."), nl.


% Leviathe
decrire(fusee) :-
        planete(leviathe),
        write("Vous vous dirigez vers votre fusee, vos pieds s'enfoncent dans le sable.
        Vous arrivez a votre fusee et entrez par l'ecoutille.
        Vous pouvez y voir votre journal de bord ainsi que les commandes du vaisseau.
        -> (Options : voir journal, aller espace, aller dehors)"), nl.

decrire(dehors) :-
        planete(leviathe),
        write("Vous arrivez sur la plage de l'ile.
        Vous voyez une porte permettant de rentrer dans une grotte.
        De meme qu'un grand batiment atteignable par un tunnel. Le sol du tunnel semble s'etre effondre.
        A cote du tunnel vous voyez ce qui ressemble a un panneau avec des sigles nomai.
        Il y a aussi votre fusee calee dans le sable.
        -> (Options : voir sigles, aller grotte, aller fusee)"), nl.

decrire(grotte) :-
        write("Vous rentrez dans le grotte et voyez des statues comme celles du musee un peu partout.
        Seule une statue a l'air terminee, elle a les yeux ouvert.
        Vous pouvez voir en face de cette statue un appareil contenant des sigles nomai.
        Vous pouvez aussi voir un dessin affiche au mur.
        Ensuite, vous voyez une plateforme au dessus accessible via des escaliers.
        Enfin, il y a la porte pour repartir dehors.
        -> (Options : voir appareil, voir dessin, aller plateforme, aller dehors.)"), nl.

decrire(plateforme) :-
        write("Vous montez les escaliers et arrivez en haut.
        Ici, se trouve seulement un tableau avec des sigles nomai.
        Derriere vous, se trouve l'escalier pour redescendre en bas.
        -> (Options : voir sigles, aller grotte)"), nl.

decrire(module_controle) :-
        write("Vous arrivez dans une salle avec des appareils et des terminaux nomai.
        Vous voyez un terminal encore allume avec, de l'autre cote, un tableau contenant des sigles nomai.
        Ainsi qu'une porte avec ecrit au dessus 'module de pistage' mais l'entree a l'air verrouille par un digicode.
        Vous voyez une autre porte avec ecrit au dessus 'module de lancement'.
        Enfin, il y a le tunnel pour repartir dehors.
        -> (Options : voir sigles, voir terminal, aller module_lancement, aller module_pistage, aller dehors)"), nl.

decrire(module_lancement) :-
        write("Vous arrivez dans une autre piece remplie de terminaux mais cette fois aucun n'est allume.
        Par contre vous voyez un autre tableau avec des sigles nomai.
        Vous voyez une porte avec marque au dessus 'module de pistage' mais elle a l'air verrouille par un digicode.
        A cote de cette porte, vous voyez d'autres sigles nomai au mur.
        Ainsi qu'une autre porte avec marque au dessus 'module de controle'.
        -> (Options : voir sigles, aller module_pistage, aller module_controle)"), nl.

decrire(module_pistage) :-
        write("Vous arrivez dans une salle avec une sorte d'ecran geant affichant le lance-sondes orbital en orbite.
        Vous pouvez voir un tableau avec des sigles nomai.
        Vous voyez egalement un terminal nomai.
        Vous voyez une porte avec ecrit dessus 'module de lancement'.
        Enfin, vous voyez une porte avec ecrit au dessus 'module de controle'.
        -> (Options : vois sigles, voir terminal, aller module_lancement, aller module_controle)"), nl.

decrire(echec_porte) :-
        write("Vous vous approchez de la porte et essayer un code au hasard.
        Le digicode emet un petit sond grave signifiant que le code n'est pas le bon.
        Vous abandonnez et retournez dans la salle derriere vous."), nl.


% Station solaire
decrire(fusee) :-
        planete(station_solaire),
        write("Vous marchez sur le tarmac a gravite artificielle jusqu'a votre fusee et entrez par l'ecoutille.
        Vous pouvez y voir votre journal de bord ainsi que les commandes du vaisseau.
        -> (Options : voir journal, aller espace, aller tarmac)"), nl.

decrire(tarmac) :-
        write("Vous arrivez sur larmac a gravite artificielle et regardez autous de vous.
        Vous pouvez voir un terminal nomai allume.
        Vous voyez une porte permettant de d'arriver a l'entree de la station.
        Vous voyez aussi votre fusee bien retenue a la station grace au champ gravitationnel nomai.
        -> (Options : voir terminal, aller entree, aller fusee)"), nl.

decrire(entree) :-
        write("Vous arrivez dans un salle contenant plusieurs choses interressantes.
        D'abord, vous voyez un tableau avec des sigles nomai.
        Ensuite, vous voyez une sorte de bureau avec pleins d'objets inconnus dessus.
        Vous voyez aussi un couloir permettant d'aller dans une autre salle avec une grande baie vitree.
        Enfin, il y a la porte permettant de revenir sur la tarmac.
        -> (Options : voir sigles, voir bureau, aller baie, aller tarmac)"), nl.

decrire(baie) :-
        write("Vous arrivez dans une salle avec une enorme baie vitree donnant directement sur le soleil, terriblement pres.
        Vous voyez un cadavre nomai sur un banc qui semblaient regarder le soleil avant de mourir, 
        vous pouvez voir qu'il y a des sigles a cote de celui-ci.
        Vous apercevez un terminal dans un coin de la piece.
        Vous pouvez voir un autre tableau avec des sigles nomai.
        Et vous avez derriere vous, le couloir permettant de revenir a l'entree de la station.
        -> (Options : voir terminal, voir sigles, voir sigles_sol, aller entree)"), nl.


% Intrus
decrire(fusee) :-
        planete(intrus),
        write("Vous partez en direction de votre fusee en vous concentrant pour ne pas glisser sur la glace.
        Vous arrivez a l'atteindre, vous vous accrochez a elle pour ne pas partir plus loin et vous entrez par l'ecoutille.
        Vous pouvez y voir votre journal de bord ainsi que les commandes du vaisseau.
        -> (Options : voir journal, aller espace, aller dehors)"), nl.

decrire(dehors) :-
        planete(intrus),
        write("Vous regardez autours de vous.
        Vous voyez Chail, une astronaute qui est partie dans l'espace avant vous, avec une carte.
        Vous pouvez voir une navette nomai coincee dans la glace de la comete avec un appareil de communication nomai a ses pieds.
        Vous pouvez aussi apercevoir une crevasse dans la glace s'enfoncant dans l'intrus.
        Enfin, vous voyez votre fusee qui ne bouge pas trop de la ou vous l'avez laissee.
        -> (Options : parler, voir appareil, aller crevasse, aller fusee)"), nl.

decrire(crevasse) :-
        write("Vous arrivez a quelques metres sous la glace dans une caverne de glace.
        Vous voyez un appareil au sol avec un squelette de nomai, toujours vetu d'une combinaison, a cote.
        Vous voyez une galerie dans la glace permettant de descendre plus profond.
        Vous voyez aussi la crevasse permettant de remonter a la surface.
        -> (Options : voir appareil, aller galerie, aller dehors)"), nl.

decrire(galerie) :-
        write("Vous prenez la galerie et arrivez au centre de la comete.
        Vous voyez un rocher de taille consequente qui semble avoir explose de l'interieur.
        Dans la piece, un autre cadavre de nomai, aussi vetu d'une combinaison, flottant dans les airs.
        A cote du cadavre vous voyez un autre appareil.
        Vous voyez aussi la galerie permettant de remonter a la crevasse.
        -> (Options : voir appareil, aller crevasse)"), nl.


% Sabliere
decrire(fusee) :-
        planete(sabliere),
        write("Vous repartez vers votre fusee en ayant vos pieds qui s'enfoncent dans le sable.
        Vous l'atteignez et rentrez par l'ecoutille.
        Vous pouvez y voir votre journal de bord ainsi que les commandes du vaisseau.
        -> (Options : voir journal, aller espace, aller dehors)"), nl.

decrire(dehors) :-
        planete(sabliere),
        write("Vous regardez autours de vous.
        Il n'y rien... Vous, du sable et votre fusee...
        Ah si ! Il y a une trappe dans le sable mais elle est verrouille par un digicode nomai.
        -> (Options : aller trappe, aller fusee)"), nl.

decrire(ouerture_trappe) :-
        write("Vous vous rapprochez de la trappe et de son digicode.
        Vous vous rappellez du code sur la bureau de la nomai, vous le tapper sur le digicode.
        La trappe s'ouvre et laisse place a un ascenseur, vous rentrez dedans.").

decrire(ascenseur_haut) :-
        write("Dans l'ascenseur, vous voyez deux boutons.
        Un vous permet d'aller au 'projet sabliere noire',
        l'autre vous permet d'aller a la 'surface'
        -> (Options : aller projet, aller dehors)"), nl.

decrire(ascenseur_bas) :-
        write("Dans l'ascenseur, vous voyez deux boutons.
        Un vous permet d'aller au 'projet sabliere noire',
        l'autre vous permet d'aller a la 'surface'
        -> (Options : aller salle, aller surface)"), nl.

decrire(salle) :-
        \+ position(generateur, en_main),
        write("Vous regardez autour de vous, vous etes dans la salle du projet sabliere noire !
        Il n'y a pas de gravite ici, vous etes surement au centre de la planete.
        Le sol tournois sur l'axe de la planete permettant de creer une gravite artificielle.
        Vous voyez des masques comme ceux que vous voyez lors de vos morts. Trois sont allumes, les autres sont eteints.
        Vous voyez ce qui s'apparente au generateur de distorsions au centre, vous pouvez le prendre si vous voulez.
        Derriere vous, se trouve l'ascenseur pour remonter a la surface.
        -> (Options : prendre generateur, aller ascenseur)"), nl.

decrire(salle) :-
        position(generateur, en_main),
        write("Vous regardez autour de vous, vous etes dans la salle du projet sabliere noire !
        Il n'y a pas de gravite ici, vous etes surement au centre de la planete.
        Vous voyez des masques comme ceux que vous voyez lors de vos morts. Trois sont allumes, les autres sont eteints.
        Vous voyez le socle pour le distordeur au centre de la salle.
        Derriere vous, se trouve l'ascenseur pour remonter a la surface.
        -> (Options : reposer generateur, aller ascenseur)"), nl.

decrire(prise_generateur) :-
        write("Vous retirez le generateur de distorsions de son socle.
        Soudainement, les lumieres de la salle s'eteignent et le sol arrete de tourner.
        Maintenant la mort est definitive..."), nl.


% Espace
decrire(espace) :-
        write("Vous prenez les commandes de votre vaisseau, allumez les moteur et vous envolez.
        Vous depassez la ligne d'horizon a vive allure et ne voyez plus que les etoiles dans le noir...
        Vous etes desormais dans l'espace, vous pouvez aller ou vous voulez !
        -> (Options : aller soleil, aller atrebois, aller cravite, aller leviathe, 
                aller station_solaire, aller intrus, aller sabliere)"), nl.

decrire(soleil) :-
        write("Vous accelerez en direction du soleil, vous prenez de plus en plus de vitesse.
        Plus vous vous rapprochez, plus il fait chaud dans le cockpit et moins vous voyez devant vous.
        Soudainement, vous vous dites qu'aller dans le soleil ne sert a rien et est sacrement dangereux.
        Il est vrai qu'une telle decision est difficilement comprehensible.
        Vous commencez donc a faire demi-tour, reacteurs pleine puissance.
        Malheureusement, vous etes deja trop pres et la gravite du soleil est trop puissante.
        Vous vous retrouvez brule par le soleil, puis vous vous retrouvez dans le noir..."), nl.


% Atterrissages
decrire(atterrissage_cravite) :-
        planete(cravite),
        write("Vous volez jusqu'a la planete, esquivez une des nombreuses meteorites s'ecrasant sur Cravite et vous posez.
        Vous sortez alors de votre vaisseau, la planete parait assez hostile.
        Soudainement, vous voyez tout un pan de la planete s'ecrouler non loin de vous.
        A travers ce trou vous voyez le centre de la planete... C'est un trou noir.
        Mieux vaut ne pas tomber en bas, qui sait ce qu'il y a dans un trou noir..."), nl.

decrire(atterrissage_atrebois) :-
        write("Vous atterrissez tranquillement sur la plateforme de lancement du village...
        Vous vous empressez de sortir de votre vaisseau pour eteindre le feu que vous venez de lancer.
        Le feu s'eteint, pas facile d'atterrir sur une plateforme en bois.
        Vous prenez alors l'ascenseur pour descendre et arrivez au camp."), nl.

decrire(atterrissage_intrus) :-
        write("Vous atterrissez difficilement sur la surface glacee de la comete.
        Une fois votre vaisseau stabilise entre trois morceaux de glace, vous sortez de votre vaisseau."), nl.

decrire(atterrissage_leviathe) :-
        write("Vous mettez plein gaz en direction de la plus grosse planete du systeme.
        Vous vous rapprochez en passant a cote d'une grande structure detruite en orbite.
        Ensuite, vous passez a travers l'epaisse couche de nuages qui recouvre la planete.
        Vous voyez sa seule ile et vous dirigez dans sa direction en evitant les cyclones...
        En vous posant sur la plage, vous parvenez a stabiliser la fusee dans le sable et sortez de celle-ci."), nl.

decrire(atterrissage_station) :-
        write("Vous vous rapprochez de la station solaire et vous concentrez, l'atterrissage va etre complique.
        En effet, la station solaire est tres proche du soleil donc tres dangereuse.
        Vous epousez l'orbite du soleil et attendez que la station passe a cote de vous.
        Au moment ou elle passe, vous foncez dessus et vous vous posez un peu brutalement sur la plateforme d'atterrissage.
        Vous vous assurez que la fusee soit bien tenue par la gravite artificielle nomai et sortez de la fusee."), nl.

decrire(atterrissage_sabliere) :-
        write("Vous mettez pleine puissance en direction de Sabliere.
        Vous arrivez sur une planete avec du sable a perte de vue.
        Vous sortez par l'ecoutille de votre vaisseau."), nl.

decrire(atterrissage_oeil) :-
        write("Vous rentrez les coordonnees de l'oeil dans votre navigateur.
        Vous activez le distordeur...
        D'un coup, le vaisseau est pris dans une sorte de trou noir.
        Tout aussi soudainement, la couleur du trou noir devient blanc.
        Vous vous retrouvez sur une planete tres sombre et vos yeux peinent a s'adapter a la luminosite.
        Vous sortez de votre fusee et commencez a faire quelques pas un peu effraye.
        Vous vous retournez... Votre fusee a disparue..."), nl.


% Autre
decrire(mort) :-
        write("Vous restez un peu dans le noir jusqu'a ce que vous voyiez une sorte de masque nomai arriver au loin.
        Il est accompagne de rayons violets et vous voyez vos souvenirs depuis votre reveil defiler...
        Vous rentrer alors dans l'oeil du masque."), nl.

decrire(mort_station) :-
        write("Vous vous rapprochez de la station solaire et vous concentrez, l'atterrissage va etre complique.
        En effet, la station solaire est tres proche du soleil donc tres dangereuse.
        A l'approche, vous faites une erreur dans votre maneuvre et vous retrouvez brule dans le soleil.
        Il faudra reessayer jusqu'a avoir assez d'experience ou alors y acceder d'une autre maniere peut-etre.
        Apres que votre corps ait ete completement carbonise, vous vous retrouvez dans le noir."), nl.

decrire(mort_supernova) :-
        write("Petit a petit la lumiere bleue s'intensifie, se rapprochant de vous.
        Elle arrive jusqu'a vous et vous brule intensement.
        La lumiere disparait d'un coup pour laisser la place au noir total..."), nl.

decrire(explosion_etoile) :-
        en_exterieur,
        write("Vous entendez d'etranges bruits dans le ciel.
        Vous vous retourner et voyez le soleil, etonnament rouge et gros, se tordre.
        Vous voyez l'etoile s'effondrer sous son propre poid, la lumiere disparait pendant une petite seconde.
        Soudainement, la lumiere reapparait sous la forme d'une giganteque explosion bleue.
        Il ne vous reste plus beaucoup de temps avant que l'explosion arrive jusqu'a vous."), nl.

decrire(explosion_etoile) :-
        \+ en_exterieur,
        write("Vous entendez au loin d'etranges bruits.
        Vous voyez petit a petit une lumiere bleue s'intensifier."), nl.


% Oeil de l univers
decrire(oeil_univers) :-
        write("
        Soudain, vous voyez des eclairs bleu zebrant les environs. 
        En vous avancant, vous discernez le sol sombre de cet etrange endroit.
        Des structures bleues ne semblant respecter aucune physique connue s'elevent dans le ciel aux alentours.
        Au loin, vous discernez un trou s'enfoncant tres profondement, il vous est impossible de discerner
        ce qu'il se trouve au fond : le trou est noir et sans fin... Mais il est au plafond.

        Vous decidez tout de meme de vous elevez pour acceder au trou, grace au structure environnantes.
        La gravite change sous vos pieds et vous parvenez a monter... meme si de votre point de vue vous ne faites qu'avancer.
        Au bord de la structure, vous voyez le trou s'enfoncer sous vos pieds.
        D'un elan, vous vous y jetez contre toute pensee rationnelle...

        Rien d'autre que des lumieres bleues ne vous entourent tandis que vous continuez de vous enfoncer dans un trou sans fin.
        Soudain, les lumieres s'elargissent devant une galerie gigantesque avec ce qui s'apparente a de grands pilliers bleus.
        Tandis que vous continuez de tomber vous observer ces alentours a la fois terrifie et sans voix.
        Vous ne sauriez dire si ce que vous voyez autour de vous existe reellement...

        Tout d'un coup, vous vous retrouvez dans le musee d'Atrebois sombre et sans lumiere.
        Explorant doucement, vous vous retrouvez face a l'etrange statue auquel vous avez fait face au debut de votre aventure.
        Cependant, l'ecriteau a ete modifie depuis, il est indique :
        'Les Nomai ne sont jamais parvenus a le voir de leur propre yeux, mais grace a leurs efforts et leur technologie,
        un atrien a reussi a atteindre l'Oeil de l'univers.'

        Vous continuez tranquillement d'explorer en sachant que cet endroit n'est pas le meme que celui de votre planete natale.
        Puis en montant a l'etage, vous vous retrouvez face a un petit univers constitue d'enormement de minuscule soleils...
        En le regardant de plus pres, vous vous retrouvez projeter en arriere.
        Tandis que vous prenez de plus en plus de hauteur, vous voyez le musee de haut, 
        lui-meme pose sur une enorme boule noire avec d'enormes eclairs bleus tout autour...
        Sans vous arretez de vous elever, vous voyez de plus en plus de choses autour de vous dont des soleils...
        Cependant, au bout de quelques secondes, tous ces soleils viennent a exploser.

        En vous retournant, il vous semble tout de meme observer une zone avec de multiples points lumineux...
        Vous vous retrouvez alors projete en avant vers cette zone.
        Cependant, en vous approchant, vous comprenez qu'il s'agit d'une planete d'ou
        depassent de nombreux arbres eclaires par les mutiples lumieres volant a mi-hauteur.

        Vous vous retrouvez emerveille par ces petites lumieres flottant dans le vide.
        En vous mettant tranquillement a marcher, vous deambulez entre toutes ces petites lumieres.
        En vous approchant de plus pres de chacune d'elles vous voyez qu'il s'agit de petits systemes solaires.

        Cependant, plus le temps passe et moins de lumieres sont presentes autour de vous...
        Il semblerait qu'elles viennent a s'eteindre. Et plus vous avancez, plus vous entrez dans l'obscurite.
        Deambulant dans le noir, muni de votre lampe torche, vous contournez les arbres sans reel objectif...
        Vous butez alors soudainement sur un feu de camp, eteint, avec une chaise vide autour.
        Aussi curieux soit-il, vous vous demandez si des personnes etaient la avant...
        Vous songez alors a explorer pour chercher un signe de vie...

        Mais c'est alors que vous entendez le feu de camp s'embraser derriere vous.
        En vous retournant, vous voyez Esker, Feldspar, Chert, Gabbro, Riebeck et Solanum 
        n'attendant que vous au coin du feu. 
        En discutant avec chacun d'eux, ils vous proposent de jouer un morceau de musique, 
        chacun avec son instrument.
        Enfin, en parlant avec Solanum, elle vous dit :
        'Un observateur conscient est entre dans l'Oeil. Je me demande ce qu'il va arriver desormais.'
        Puis, vous demande :
        'Est-il temps de le savoir ?'
        Vous lui repondez que oui... puis vous observez chacun jouer de son intrument autour du feu.

        En observant la fumee se degageant du feu, vous voyez qu'elle prend soudainement une forme arrondie.
        Puis la forme se colore progressivement, devenant bleue par endroit. Puis entierement bleue.
        Soudainement, la musique s'arrete et la planete se met a clignoter.
        Vous entendez alors Esker :
        'Cela fait longtemps que l'on ne s'est pas retrouve autour d'un feu de camps...
        Je suis content que l'on ait pu se reunir avant la fin.'
        
        Soudainement, tout autour de vous s'etire a l'infini et vous vous retrouvez de nouveau dans le noir.
        Vous ne voyez rien et ne sentez rien... Cela pendant une duree qui vous semble etre a la fois courte et interminable...

        ...

        ...

        Tout d'un coup, vous voyez une matiere se propager face a vous, puis une tres grande explosion incandescente.
        Il vous semble voir la naissance d'une etoile, grandissant et s'illuminant toujours plus.
        Jusqu'a vous atteindre et vous submerger de lumiere...


                                                        FIN

        "), nl.
