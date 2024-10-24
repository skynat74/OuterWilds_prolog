%%% INFO-501, TP3
%%% Enzo Goldstein
%%%
%%% Lancez la "requete"
%%% jouer.
%%% pour commencer une partie !
%

% il faut declarer les predicats "dynamiques" qui vont etre modifies par le programme.
:- dynamic position/2, position_courante/1, statue/1.

% on remet a jours les positions des objets et du joueur
:- retractall(position(_, _)), retractall(position_courante(_)).

% on declare des operateurs, pour autoriser `prendre torche` au lieu de `prendre(torche)`
:- op(1000, fx, prendre).
:- op(1000, fx, lacher).
:- op(1000, fx, aller).
:- op(1000, fx, dire).
:- op(1000, fx, voir).



% position du joueur. Ce predicat sera modifie au fur et a mesure de la partie (avec `retract` et `assert`)
position_courante(camp).

% la statue n est pas activee au debut
statue(desactivee).

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


% deplacements
aller(musee) :-
        position_courante(camp),
        retract(position_courante(camp)),
        assert(position_courante(musee)),
        regarder, !.

aller(etage) :-
        position_courante(musee),
        retract(position_courante(musee)),
        assert(position_courante(etage)),
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
        n'avez pas les codes de lancement necessaire. Vous faites demi-tour."), nl,
        fail.


aller(espace) :-
        position_courante(fusee),
        retract(position_courante(fusee)),
        assert(position_courante(espace)),
        regarder, !.

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
        'On pense que les Nomai l'ont sculptee pour honorer un evenement important de leur histoire.'"), nl.

voir(statue) :-
        write("Vous voyez une statue mysterieuse des Nomai, une civilisation ancienne et disparue. Vous lisez :
        'Cette statue est une des rares que nous ayons decouvertes.'
        'On pense que les Nomai l'ont sculptee pour honorer un evenement important de leur histoire.'"), nl.

voir(maquettes) :-
        write("Vous voyez un modele reduit du systeme solaire montrant les orbites des differentes planetes.. 
        Vous lisez les informations suivantes :
        'Voici notre systeme solaire, compose de Atrebois et de ses voisines. 
        Chacune des planetes a ses propres mysteres, qui continuent d'intriguer les chercheurs.'"), nl.

voir(journal) :-
        position_courante(fusee),
        write("C'est mon premier jour dans le programme spatial !
        J'ai vraiment hate de partir explorer toutes les planetes de notre systeme solaire.
        Je pars avec le traducteur et grace a lui je suis sur que je pourrai en apprendre davantage sur les numai...
        Je reussirai a comprendre pourquoi ils on disparu, tout le monde sera fier de moi sur Atrebois !"), nl.

voir(sigles) :-
        position_courante(musee),
        position(traducteur, en_main),
        affiche_sigle,
        write("Votre traducteur vous affiche :
        'Cassava : Nous sommes bientôt prets ! Filix et moi avons acheve la construction et d'apres elle,
        le calibrage de l'appareil ne devrait pas prendre longtemps.'
        'Filix : Fort heureusement, l'absence d'atmosphere sur la Rocaille facilitera le calibrage.
        Apres tout ce temps, je suis impatiente qu'on reprenne enfin nos recherches !'"), nl.

voir(sigles) :-
        write("Vous vous approchez et observez les ruines nomai. Vous pouvez y apercevoir d'etranges sigles nomai incomprehensibles : "),
        affiche_sigle.



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


% dialogue personnages
parler :-
    position_courante(camp),
    write("Si c'est pas notre pilote ! Je vois que tu es de retour de ta derniere nuit a la belle etoile avant ton decollage.
        Alors ca y est, c'est le grand jour ? J'ai l'impression que tu as rejoint le programme spatial pas plus tard qu'hier, 
        et voila soudain que tu t'appretes a partir pour ton premier voyage en solitaire.
        Qu'est-ce que t'en dis - t'as pas hate de t'envoler a bord de ce petit bijou ? Le plein est fait, y'a plus qu'a decoller !
        -> (Options : dire allons-y, dire ok). "), nl.

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



% descriptions des emplacements
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
        write("Vous arrivez a l'ascenseur, entrez les codes de lancement et arrivez a la plateforme de lancement ou vous attend votre fusee.
        Vous entrez par l'ecoutille, vous voici dans votre vaisseau spatial.
        Vous pouvez y voir votre combinaison spatial, le journal de bord ainsi que les commandes du vaisseau.
        -> (Options : prendre combinaison, voir journal, aller espace, aller camp)"), nl.

decrire(espace) :-
    write("Vous prenez les commandes de votre vaisseau, allumez les moteur et vous envolez.
    Vous depassez la ligne d'horizon a vive allure et ne voyez plus que les etoiles dans le noir...
    Vous etes desormais dans l'espace, vous pouvez aller ou vous voulez !
    -> (Options : aller cravite, aller leviathe, aller station, aller comete, aller atrebois)"), nl.

decrire(evenement_statue) :-
    write("Vous descendez les escaliers et vous retrouvez devant la statue nomai du musee.
    Soudainement, la statue ouvre les yeux et vous regarde brusquement.
    Vous n'entendez qu'un bruit sourd et voyez ses grands yeux violets, 
    tandis que vos souvenirs depuis votre reveil defilent devant vos yeux.
    Tout d'un coup, ses yeux s'eteignent et le bruit sourd cesse...
    Vous restez au beau milieu du musee, perplexe. Vous regardez autours de vous... 
    Personne d'autre que la ruine nomai contenant des sigles n'a vu ce que vous venez de voir."), nl.