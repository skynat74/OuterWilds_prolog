%%% INFO-501, TP3
%%% Enzo Goldstein
%%%
%%% Lancez la "requete"
%%% jouer.
%%% pour commencer une partie !
%

% il faut declarer les predicats "dynamiques" qui vont etre modifies par le programme.
:- dynamic position/2, position_courante/1, statue/1, planete/1, au_moins_une_mort/1.
:- discontiguous position/2.

% on remet a jours les positions des objets et du joueur
:- retractall(position(_, _)), retractall(position_courante(_)).

% on declare des operateurs, pour autoriser `prendre torche` au lieu de `prendre(torche)`
:- op(1000, fx, prendre).
:- op(1000, fx, lacher).
:- op(1000, fx, aller).
:- op(1000, fx, dire).
:- op(1000, fx, voir).

% cheats
position(traducteur, en_main).
position(codes, en_main).
statue(activee).

test(X) :-
        write(X).


% position du joueur. Ce predicat sera modifie au fur et a mesure de la partie (avec `retract` et `assert`)
position_courante(camp).
planete(atrebois).

% la statue n est pas activee au debut
% statue(desactivee).

% le joueur n est pas encore mort au debut
au_moins_une_mort(faux).

% position des objets
position(combinaison, vaisseau).

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


% DDDDDDDDDDDD     EEEEEEEEEEEE     PPPPPPPPPPP       LLLLL             AAAAAAAAA     CCCCCCCCCCCCC   EEEEEEEEEEEE     MMMMM      MMMMM     EEEEEEEEEEEE     NNNN        NNNN    TTTTTTTTTTTT     SSSSSSSSSSSS
% DDDD       DDDD  EEEE             PPPP      PPPP    LLLLL             AAAA   AAAA  CCCC             EEEE             MMMMMMM  MMMMMMM     EEEE             NNNNNN      NNNN        TTTT      SSSS          
% DDDD        DDD  EEEEEEEEEEEE     PPPPPPPPPPPP      LLLLL             AAAAAAAAAAA CCCC              EEEEEEEEEEEE     MMMMMMMMMMMMMMMM     EEEEEEEEEEEE     NNNN NNN    NNNN        TTTT       SSSSSSSSSSSS
% DDDD        DDD  EEEE             PPPP              LLLLL             AAAA   AAAA CCCC              EEEE             MMMMMMMMMMMMMMMM     EEEE             NNNN   NNN  NNNN        TTTT                 SSSS
% DDDDDDDDDDDD     EEEEEEEEEEEE     PPPP              LLLLLLLLLLLLLLL   AAAA   AAAA    CCCCCCCCCCCCC  EEEEEEEEEEEE     MMMMM       MMMM     EEEEEEEEEEEE     NNNN      NNNNN        TTTT       SSSSSSSSSSSS

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
        n'avez pas les codes de lancement necessaire. Vous faites demi-tour."), nl.

% Cravite
aller(ruines) :-
        position_courante(dehors),
        retract(position_courante(dehors)),
        assert(position_courante(ruines)),
        regarder, !.

aller(dehors) :-
        position_courante(ruines),
        retract(position_courante(ruines)),
        assert(position_courante(dehors)),
        regarder, !.
        
aller(fusee) :-
        position_courante(dehors),
        retract(position_courante(dehors)),
        assert(position_courante(fusee)),
        regarder, !.

aller(trou) :-
        position_courante(dehors),
        retract(position_courante(dehors)),
        assert(position_courante(trou)),
        regarder,
        mort, !.

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

aller(_) :-
        write("Vous ne pouvez pas aller par la."),
        fail.


% AAAAAAAAAAA     UUUU       UUUU     TTTTTTTTTTTT     RRRRRRRRRRRR     EEEEEEEEEEEE     SSSSSSSSSSSS
% AAAAA    AAAAA  UUUU       UUUU         TTTT         RRRR      RRRR   EEEE            SSSS
% AAAAAAAAAAAAAA  UUUU       UUUU         TTTT         RRRRRRRRRRRRR    EEEEEEEEEEEE      SSSSSSSSSSSS
% AAAAA    AAAAA  UUUU       UUUU         TTTT         RRRR   RRRR      EEEE                     SSSS
% AAAAA    AAAAA    UUUUUUUUUUUU          TTTT         RRRR     RRRR    EEEEEEEEEEEE     SSSSSSSSSSSS


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

% morts
mort :-
        statue(activee),
        decrire(mort), nl,
        reveil.

mort :-
        statue(desactivee),
        write("Le noir de la mort ne se dissipa jamais... Les autres Atriens ne vous reverrons plus jamais."),
        fin.

reveil :-
        retract(position_courante(_)),
        assert(position_courante(camp)),
        retract(planete(_)),
        assert(planete(atrebois)),
        retract(au_moins_une_mort(_)),
        assert(au_moins_une_mort(vrai)),
        decrire(reveil),
        regarder, nl.


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


% VVVV         VVVV      OOOOOOOOOOOO      IIIIIIIIIIIIII     RRRRRRRRRRRR
%   VVVV     VVVV      OOOO        OOOO         IIII          RRRR      RRRR
%     VVVV VVVV        OOOO        OOOO         IIII          RRRRRRRRRRRRR
%       VVVVV          OOOO        OOOO         IIII          RRRR   RRRR
%         VV             OOOOOOOOOOOO      IIIIIIIIIIIIII     RRRR     RRRR


% Atrebois
voir(statue) :-
        statue(activee),
        write("Vous voyez une statue mysterieuse des Nomai, une civilisation ancienne et disparue. Vous lisez :
        'Cette statue est une des rares que nous ayons decouvertes.'
        'On pense que les Nomai l'ont sculptee pour honorer un evenement important de leur histoire.'
        La statue a les yeux ouverts."), nl, !.

voir(statue) :-
        write("Vous voyez une statue mysterieuse des Nomai, une civilisation ancienne et disparue. Vous lisez :
        'Cette statue est une des rares que nous ayons decouvertes.'
        'On pense que les Nomai l'ont sculptee pour honorer un evenement important de leur histoire.'"), nl, !.

voir(maquettes) :-
        write("Vous voyez un modele reduit du systeme solaire montrant les orbites des differentes planetes.. 
        Vous lisez les informations suivantes :
        'Voici notre systeme solaire, compose de Atrebois et de ses voisines. 
        Chacune des planetes a ses propres mysteres, qui continuent d'intriguer les chercheurs.'"), nl, !.

voir(journal) :-
        position_courante(fusee),
        write("C'est mon premier jour dans le programme spatial !
        J'ai vraiment hate de partir explorer toutes les planetes de notre systeme solaire.
        Je pars avec le traducteur et grace a lui je suis sur que je pourrai en apprendre davantage sur les numai...
        Je reussirai a comprendre pourquoi ils on disparu, tout le monde sera fier de moi sur Atrebois !"), nl, !.

voir(sigles) :-
        position_courante(musee),
        position(traducteur, en_main),
        affiche_sigle,
        write("Votre traducteur vous affiche :
        'Cassava : Nous sommes bientôt prets ! Filix et moi avons acheve la construction et d'apres elle,
        le calibrage de l'appareil ne devrait pas prendre longtemps.'
        'Filix : Fort heureusement, l'absence d'atmosphere sur Cravite facilitera le calibrage.
        Apres tout ce temps, je suis impatiente qu'on reprenne enfin nos recherches !'"), nl, !.

voir(sigles) :-
        write("Vous vous approchez et observez les ruines nomai. Vous pouvez y apercevoir d'etranges sigles nomai incomprehensibles : "),
        affiche_sigle, nl.


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


% DDDDDDDDDDDD      IIIIIIIIIIIII     AAAAAAAAA     LLLLL             OOOOOOOOOOO     GGGGGGGGGGG    UUUU       UUUU     EEEEEEEEEEEE     SSSSSSSSSSSS
% DDDD      DDDD         IIII         AAAA   AAAA   LLLLL          OOOO       OOOO  GGGG             UUUU       UUUU     EEEE            SSSS
% DDDD        DDD        IIII         AAAAAAAAAAA   LLLLL          OOOO       OOOO  GGGG   GGGGGGG   UUUU       UUUU     EEEE              SSSSSSSSSSSS
% DDDD      DDDD         IIII         AAAA   AAAA   LLLLL          OOOO       OOOO  GGGG       GGG   UUUU       UUUU     EEEE                     SSSS
% DDDDDDDDDDDD      IIIIIIIIIIIII     AAAA   AAAA   LLLLLLLLLLLLL    OOOOOOOOOOO     GGGGGGGGGGGG     UUUUUUUUUUUUUU     EEEEEEEEEEEE     SSSSSSSSSSSS

parler :-
        position_courante(camp),
        au_moins_une_mort(faux),
        write("Si c'est pas notre pilote ! Je vois que tu es de retour de ta derniere nuit a la belle etoile avant ton decollage.
        Alors ca y est, c'est le grand jour ? J'ai l'impression que tu as rejoint le programme spatial pas plus tard qu'hier, 
        et voila soudain que tu t'appretes a partir pour ton premier voyage en solitaire.
        Qu'est-ce que t'en dis - t'as pas hate de t'envoler a bord de ce petit bijou ? Le plein est fait, y'a plus qu'a decoller !
        -> (Options : dire allons-y, dire ok). "), nl, !.

parler :-
        position_courante(camp),
        au_moins_une_mort(vrai),
        write("Alors, t'as pas hâte de t'envoler à bord de cette fusée ? Le plein est fait, y'a plus qu'à décoller !
        -> (Options : dire allons-y, dire ok, dire je_viens_de_mourir). "), nl, !.
        
        

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
        assert(position(codes, en_main)), nl.

% interaction personnages
dire(allons-y) :-
        position_courante(camp),
        write("Ta motivation fait plaisir a voir, mais souviens-toi, si tu bousilles la fusee, viens pas m'en demander un autre. 
        Je ne suis pas en alliage d'aluminium leger resistant a la rentree atmospherique, tu sais.
        Quoi qu'il en soit, tu vas devoir parler a Cornee a l'observatoire pour obtenir les codes de lancement si tu veux pouvoir decoller."), nl.

dire(ok) :-
        position_courante(camp),
        write("Ha ha ! Tout est pret de mon côte - on va enfin pouvoir tester le nouveau systeme d'atterrissage 
        hydraulique avec un pilote plutôt que le systeme automatique ! ... En parlant de pilote, 
        evite de t'ecraser a ton premier atterrissage, compris ? Quoi qu'il en soit, tu vas devoir parler a 
        Cornee a l'observatoire pour obtenir les codes de lancement si tu veux pouvoir decoller."), nl.

dire(je_viens_de_mourir) :-
        position_courante(camp),
        au_moins_une_mort(vrai),
        write("Hola ! On a fait un cauchemar ? Tu dors encore a moitie, mais tu m'as l'air bel et bien en vie.
        Je sais que c'est la tradition de dormir a la belle etoile la veille d'un depart, mais si tu veux mon avis, ça vous rend un peu nerveux."), nl.


% DDDDDDDDDDDD     EEEEEEEEEEEE     SSSSSSSSSSSS     CCCCCCCCCCCCC  RRRRRRRRRRRR     IIIIIIIIIIIII    PPPPPPPPPPP       TTTTTTTTTTTT     IIIIIIIIIIIII    OOOOOOOOOOO     NNNN        NNNN     SSSSSSSSSSSS
% DDDD      DDDD   EEEE            SSSS            CCCC             RRRR      RRRR       IIII         PPPP      PPPP        TTTT             IIII       OOOO       OOOO   NNNNNN      NNNN    SSSS
% DDDD        DDD  EEEEEEEEEEEE       SSSSSSSSSSS CCCC              RRRRRRRRRRRRR        IIII         PPPPPPPPPPPP          TTTT             IIII       OOOO       OOOO   NNNN NNN    NNNN      SSSSSSSSSSSS
% DDDD      DDDD   EEEE                       SSSS CCCC             RRRR   RRRR          IIII         PPPP                  TTTT             IIII       OOOO       OOOO   NNNN   NNN  NNNN             SSSS
% DDDDDDDDDDDD     EEEEEEEEEEEE     SSSSSSSSSSSS     CCCCCCCCCCCCC  RRRR     RRRR    IIIIIIIIIIIII    PPPP                  TTTT         IIIIIIIIIIIII    OOOOOOOOOOO     NNNN     NNNNN      SSSSSSSSSSSS

% Atrebois
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

decrire(fusee) :-
        planete(atrebois),
        write("Vous arrivez a l'ascenseur, entrez les codes de lancement et arrivez a la plateforme de lancement ou vous attend votre fusee.
        Vous entrez par l'ecoutille, vous voici dans votre vaisseau spatial.
        Vous pouvez y voir votre combinaison spatial, le journal de bord ainsi que les commandes du vaisseau.
        -> (Options : prendre combinaison, voir journal, aller espace, aller camp)"), nl.

decrire(fusee) :-
        planete(cravite),
        write("Vous vous dirigez vers votre fusee et entrez par l'ecoutille.
        Vous pouvez y voir votre combinaison spatial, le journal de bord ainsi que les commandes du vaisseau.
        -> (Options : prendre combinaison, voir journal, aller espace, aller dehors)"), nl.

decrire(evenement_statue) :-
        write("Vous descendez les escaliers et vous retrouvez devant la statue nomai du musee.
        Soudainement, la statue ouvre les yeux et vous regarde brusquement.
        Vous n'entendez qu'un bruit sourd et voyez ses grands yeux violets, 
        tandis que vos souvenirs depuis votre reveil defilent devant vos yeux avec des rayons violets les encerclant.
        Tout d'un coup, ses yeux s'eteignent et le bruit sourd cesse...
        Vous restez au beau milieu du musee, perplexe. Vous regardez autours de vous... 
        Personne d'autre que la ruine nomai contenant des sigles n'a vu ce que vous venez de voir."), nl.

% Cravite
decrire(dehors) :-
        planete(cravite),
        write("Autour de vous vous voyez le trou cree par la meteorite, votre vaisseau vous attendant sagement
        ainsi que, plus interressant, d'anciennes ruines nomai.
        -> (Options : aller fusee, aller ruines, aller trou)"), nl.

decrire(ruines) :-
        write("Vous arrivez dans ce qui s'apparente a un hall d'entree assez grand ou vous pouvez y apercevoir des endroits intriguants.
        Tout d'abord, vous voyez une grande structure au milieu de la salle ainsi que des sigles similaires a ceux du musee sur le mur.
        Ensuite, il y a des portes menant a d'autres endroits. Une porte mene a l'exterieur, une autre vers ce qui semble etre un dortoir
        et la derniere vers ce qui pourrait correspondre a une salle a manger.
        -> (Options : voir structure, voir sigles, aller dortoir, aller salle_a_manger, aller cravite)"), nl.

decrire(trou) :-
        write("Vous sautez dans le vide en direction le centre de la planete, c'est-a-dire le trou noir.
        Vous rentrez dedans et... Le vide de l'espace vous entoure.
        Vous apercevez toujours une multitudes d'etoiles ainsi que le soleil au loin,
        mais bizarrement il n'emet pas la meme lumiere que d'habitude... Ce n'est pas le soleil, c'est une autre etoile.
        Vous etes en fait a l'autre bout de la galaxie.
        Vous vous retournez et voyez, de la d'ou vous etes arrivez, une lumiere blanche eblouissante.
        Vous essayez alors de revenir a l'interieur mais la lumiere vous repousse... C'est un trou blanc !
        Vous etes condamne a errer dans l'espace. Petit a petit votre reserve d'oxygene se vide.
        Vous vous asfixiez et soudain, plus rien..."), nl.

% Espace
decrire(espace) :-
        write("Vous prenez les commandes de votre vaisseau, allumez les moteur et vous envolez.
        Vous depassez la ligne d'horizon a vive allure et ne voyez plus que les etoiles dans le noir...
        Vous etes desormais dans l'espace, vous pouvez aller ou vous voulez !
        -> (Options : aller soleil, aller cravite)"), nl.

decrire(soleil) :-
        write("Vous accelerez en direction du soleil, vous prenez de plus en plus de vitesse.
        Plus vous vous rapprochez, plus il fait chaud dans le cockpit et moins vous voyez devant vous.
        Soudainement, vous vous dites qu'aller dans le soleil ne sers a rien et est sacrement dangereux.
        Il est vrai qu'une telle decision est diffcilement comprehensible.
        Vous commencez donc a faire demi-tour, reacteurs pleine puissance.
        Malheureusement, vous etes deja trop pres et la gravite du soleil est trop puissante.
        Vous vous retrouvez bruler par le soleil, puis vous vous retrouvez dans le noir...").


% Atterrissages
decrire(atterrissage_cravite) :-
        planete(cravite),
        write("Vous volez jusqu'a la planete, esquivez une des nombreuses meteorites s'ecrasant sur cravite et vous posez.
        Vous sortez alors de votre vaisseau, la planete parait assez hostile.
        Soudainement, vous voyez tout un pan de la planete s'ecrouler pas loin.
        A travers ce trou vous voyez le centre de la planete... C'est un trou noir.
        Mieux vaut ne pas tomber en bas, qui sait ce qu'il y a dans un trou noir..."), nl.

decrire(atterrissage_atrebois) :-
        write("Vous atterrissez tranquillement sur la plateforme de lancement du village...
        Vous vous empressez de sortir de votre vaisseau pour eteindre le feu que vous venez de lancer.
        Le feu s'eteint, pas facile d'atterrir sur une plateforme en bois.
        Vous prenez alors l'ascenseur pour descendre et arrivez au camp."), nl.


decrire(mort) :-
        write("Vous restez un peu dans le noir jusqu'a ce que vous voyiez une sorte de masque nomai arriver au loin.
        Il est accompagne de rayons violets et vous voyez vos souvenirs depuis votre reveil defiler.
        Vous rentrer alors dans l'oeil du masque."), nl.