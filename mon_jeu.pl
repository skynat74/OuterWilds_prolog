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
        position_courante(ruines),
        retract(position_courante(ruines)),
        assert(position_courante(caverne)),
        regarder, !. 

aller(caverne) :-
        position_courante(dehors),
        retract(position_courante(dehors)),
        assert(position_courante(caverne)),
        regarder, !.    

aller(plafond) :-
        position_courante(caverne),
        retract(position_courante(caverne)),
        assert(position_courante(ruines)),
        regarder, !.

aller(dortoir) :-
        position_courante(ruines),
        retract(position_courante(ruines)),
        assert(position_courante(dortoir)),
        regarder, !.

aller(ruines) :-
        position_courante(dortoir),
        retract(position_courante(dortoir)),
        assert(position_courante(ruines)),
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
        position_courante(gallerie),
        retract(position_courante(gallerie)),
        assert(position_courante(crevasse)),
        regarder, !.

aller(gallerie) :-
        position_courante(crevasse),
        retract(position_courante(crevasse)),
        assert(position_courante(gallerie)),
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
        decrire(Place), nl.

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
        Je pars avec le traducteur et grace a lui je suis sur que je pourrai en apprendre davantage sur les numai...
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
        position_courante(ruines),
        write("Vous regardez de plus pres la structure, il y a un ecriteau a cote. Vous traduisez :
        Soyez bienvenue en ces lieux, cet autel est un espace dedie a la contemplation de ce qui nous a conduits 
        jusqu'a ce systeme stellaire : le signal de l'œil.
        Nous avons repere le signal de l'œil au cours de nos peregrinations et l'avons suivi jusqu'ici pour en decouvrir la source.
        voici ce que nous savons : la source du signal (ce que nous avons decidez d'appeler l'œil de l'univers) 
        est plus ancienne que l'univers lui-meme, c'est tout ce que nous savons pour l'instant.
        L'œil est plus ancien que l'univers, imaginez ce que nous pourrions apprendre grace a lui !"), nl, !.

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
        Eni : 'Je suis tout a fait d'accord mais… regardez la surface de cette planete.
                Elle se deforme, elle craque… Elle semble prete a s'effondrer d'un instant a l'autre.'
                J'ai repere une zone un peu plus loin qui paraît plus stable ; on pourrait y trouver refuge temporairement.'
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
        Eni : 'Ou detruites. Et si notre vaisseau principal a lui aussi ete touche… il n'a sans doute pas survecu a l'impact.
                Nous sommes... seuls.'
        Vesh : 'Que faisons nous alors ? Nous pourions reconstruire un vaisseau ?'
        Eni : 'Refaire un vaisseau nous prendrai un temps monstrueux !
                Et nous ne savons pas comment le signal de l'oeil se comporte, il pourrait disparaitre entre temps.
                Il est trop important, nous devons continuer les recherches dessus.'
        Vesh : 'Oui mais si on refaisait un vaisseau nous pourrions contacter des vaisseaux nomai qui pourraient nous aider.'
        Lann : 'Eni a raison, tu as vus les releves dans le vaisseau toi aussi, l'oeil est trop important.'
        Vesh : 'Tres bien, le source du signal prime.'
        Lann : 'Sinon j'ai eu le temps de faire de nouvelles analyses sur la planete et j'ai trouve une zone beaucoup plus stable.
                Ce serait un abri parfait. Par contre pour l'atteindre nous aurons besoin d'accrocher des cristaux antigravitationnels au plafond
                pour passer sous la planete. En effet, passer par l'exterieur serait trop risque.'
        Eni : 'Une route de cristaux suspendus ? Ce sera complexe… mais faisable. 
                Nous avons de quoi fabriquer des cristaux ici.'
        Vesh : 'Parfait, alors faisons-le !'
        Lann : 'Je vais partir en premier installer la route lorsque j'aurais les cristaux.
                Vous n'aurez plus qu'a 'aller' au 'plafond'.'"), nl, !.


voir(sigles) :-
        position_courante(dortoir),
        affiche_sigle,
        write("Votre traducteur vous affiche :
        'Filix : Ca va Pye ? Tu n'as pas l'air bien.'
        'Pye : J'avoue que ca fait beaucoup de pression... 
                   Ils me demandent quand meme de recreer un generateur similaire a celui du vaisseau mere.'
        'Filix : Ne t'inquiete pas je suis sur que tu vas y arriver ! "), nl, !.

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
        'Clary : J'ai bien compris, mais… soyez prudentes, toutes les deux.'"), nl, !.

voir(appareil) :-
        position_courante(gallerie),
        write("Votre traducteur vous affiche :
        'Poke : Cette enveloppe de pierre spherique semble etre la source  de l'energie que nous avons releve… Non ?
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
                Et la pression 	ne cesse de croître a mesure que la comete s'en approche…
        'Pye : Retourne immediatement a la navette ! Il faut prevenir nos camarades du terrible danger qui les menace.
                Pose ton materiel et cours !
        'Poke : Que fais tu Pye ?
        'Pye : Plus on en saura sur cette xenomatiere, meilleure seront nos chances de survie. 
                Je vais essayer d'en apprendre le plus possible. Va prevenir les autres. 
                Ils pourront peut-etre construire un abri… Aller, Poke ! Maintenant !
        
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



% DDDDDDDDDDDD      IIIIIIIIIIIII     AAAAAAAAA     LLLLL             OOOOOOOOOOO     GGGGGGGGGGG    UUUU       UUUU     EEEEEEEEEEEE     SSSSSSSSSSSS
% DDDD      DDDD         IIII         AAAA   AAAA   LLLLL          OOOO       OOOO  GGGG             UUUU       UUUU     EEEE            SSSS
% DDDD        DDD        IIII         AAAAAAAAAAA   LLLLL          OOOO       OOOO  GGGG   GGGGGGG   UUUU       UUUU     EEEEEE            SSSSSSSSSSSS
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
        write("Alors, t'as pas hate de t'envoler a bord de cette fusee ? Le plein est fait, y'a plus qu'a decoller !
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
        write("Ha ha ! Tout est pret de mon cote - on va enfin pouvoir tester le nouveau systeme d'atterrissage 
        hydraulique avec un pilote plutot que le systeme automatique ! ... En parlant de pilote, 
        evite de t'ecraser a ton premier atterrissage, compris ? Quoi qu'il en soit, tu vas devoir parler a 
        Cornee a l'observatoire pour obtenir les codes de lancement si tu veux pouvoir decoller."), nl.

dire(je_viens_de_mourir) :-
        position_courante(camp),
        au_moins_une_mort(vrai),
        write("Hola ! On a fait un cauchemar ? Tu dors encore a moitie, mais tu m'as l'air bel et bien en vie.
        Je sais que c'est la tradition de dormir a la belle etoile la veille d'un depart, mais si tu veux mon avis, ca vous rend un peu nerveux."), nl.


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
        write("Vous sautez dans le vide en direction le centre de la planete, c'est-a-dire le trou noir.
        Vous rentrez dedans et... Le vide de l'espace vous entoure.
        Vous apercevez toujours une multitudes d'etoiles ainsi que le soleil au loin,
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

decrire(ruines) :-
        write("Vous arrivez dans ce qui s'apparente a un hall d'entree assez grand ou vous pouvez y apercevoir des endroits intriguants.
        Tout d'abord, vous voyez une grande structure au milieu de la salle ainsi que des sigles similaires a ceux du musee sur le mur.
        Ensuite, il y a des portes menant a d'autres endroits. Une porte mene a l'exterieur, une autre vers ce qui semble etre un dortoir
        et la derniere vers ce qui pourrait correspondre a une salle a manger.
        -> (Options : voir structure, voir sigles, aller dortoir, aller salle_a_manger, aller caverne)"), nl.

decrire(dortoir) :-
        write("Vous arrivez dans la salle ou se situe plusieurs lits.
        Sur deux d'entre eux se trouve des squelettes nomai, ils semblaient dormir paisiblement avant de mourir.
        Derriere vous se trouve la porte pour revenir dans le hall.
        Au fond de la piece, vous voyez des sigles nomai.
        -> (Options : voir sigles, aller ruines)"), nl.


% Intrus
decrire(fusee) :-
        planete(intrus),
        write("Vous partez en direction de votre fusee en vous concentrant pour ne pas glisser sur la glace.
        Vous arrivez a l'atteindre, vous vous accrochez a elle pour ne pas partir plus loin et rvous entrez par l'ecoutille.
        Vous pouvez y voir votre journal de bord ainsi que les commandes du vaisseau.
        -> (Options : voir journal, aller espace, aller dehors)"), nl.

decrire(dehors) :-
        planete(intrus),decrire(soleil) :-
        write("Vous accelerez en direction du soleil, vous prenez de plus en plus de vitesse.
        Plus vous vous rapprochez, plus il fait chaud dans le cockpit et moins vous voyez devant vous.
        Soudainement, vous vous dites qu'aller dans le soleil ne sers a rien et est sacrement dangereux.
        Il est vrai qu'une telle decision est diffcilement comprehensible.
        Vous commencez donc a faire demi-tour, reacteurs pleine puissance.
        Malheureusement, vous etes deja trop pres et la gravite du soleil est trop puissante.
        Vous vous retrouvez bruler par le soleil, puis vous vous retrouvez dans le noir...").
        write("Vous regardez autours de vous.
        Vous pouvez voir une navette nomai coincee dans la glace de la comete avec un appareil de communication nomai a ses pieds.
        Vous pouvez aussi apercevoir une crevasse dans la glace s'enfoncant dans l'intrus.
        Enfin, vous voyez votre fusee qui ne bouge pas trop de la ou vous l'avez laissee.
        -> (Options : voir appareil, aller crevasse, aller fusee)"), nl.

decrire(crevasse) :-
        write("Vous arrivez a quelques metres sous la glace dans une caverne de glace.
        Vous voyez un appareil au sol avec un squellete de nomai, toujours vetu d'une combinaison, a cote.
        Vous voyez une gallerie dans la glace permettant de descendre plus profond.
        Vous voyez aussi la crevasse permettant de remonter a la surface.
        -> (Options : voir appareil, aller gallerie, aller dehors)"), nl.

decrire(gallerie) :-
        write("Vous prenez la gallerie et arrivez au centre de la comete.
        Vous voyez un rocher de taille consequente qui semble avoir explose de l'interieur.
        Dans la piece, un autre cadavre de nomai, aussi vetu d'une combinaison, flottant dans les airs.
        A cote du cadavre vous voyez un autre appareil.
        Vous voyez aussi la gallerie permettant de remonter a la crevasse.
        -> (Options : voir appareil, aller crevasse)"), nl.

% Espace
decrire(espace) :-
        write("Vous prenez les commandes de votre vaisseau, allumez les moteur et vous envolez.
        Vous depassez la ligne d'horizon a vive allure et ne voyez plus que les etoiles dans le noir...
        Vous etes desormais dans l'espace, vous pouvez aller ou vous voulez !
        -> (Options : aller soleil, aller atrebois, aller cravite, aller intrus)"), nl.

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

decrire(atterrissage_intrus) :-
        write("Vous atterrissez difficilement sur la surface glacee de la comete.
        Une fois votre vaisseau stabilise entre trois morceaux de glace, vous sortez de votre vaisseau"), nl.

% Autre
decrire(mort) :-
        write("Vous restez un peu dans le noir jusqu'a ce que vous voyiez une sorte de masque nomai arriver au loin.
        Il est accompagne de rayons violets et vous voyez vos souvenirs depuis votre reveil defiler.
        Vous rentrer alors dans l'oeil du masque."), nl.