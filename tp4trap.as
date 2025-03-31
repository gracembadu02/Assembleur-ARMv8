/********************************************************************************
*																				*
*	Programme qui lit, affiche et vérifie un sudoku.                          	*
*	Version sans les fonctions exit, printf et scanf							*
*															                    *
*	Auteurs: 																	*
*																				*
********************************************************************************/

.include "/root/SOURCES/ift209/tools/ift209.as"
.global Main


.section ".text"

/* Début du programme */

Main:	adr		x20,Sudoku        //x20 contient l'adresse de base du sudoku

        mov		x0,x20              //Paramètre: adresse du sudoku
       	bl		LireSudoku			//Appelle le sous-programme de lecture

		mov		x0,x20				//Paramètre: adresse du sudoku
		bl		AfficherSudoku		//Appelle le sous-programme d'affichage

		mov		x0,x20				//Paramètre: adresse du sudoku
		bl		VerifierSudoku		//Appelle le sous-programme de vérification

		mov		x0,0				//0: tous les tampons
		mov		x8,57				// //Vidange des tampons
		svc		0

		mov		x0,0				//0: aucune erreur
		mov		x8,93
		svc		0


/*******************************************************************************
	Lecture du sudoku.

	Traite le sudoku comme un tableau de 81 nombres.

	Paramètres
		x0: Adresse de base du sudoku


*******************************************************************************/

LireSudoku:
		SAVE					//Sauvegarde l'environnement de l'appelant

		mov		x20,x0			//Conserve l'adresse du sudoku dans x20
		add		x21,x20,81		//Calcule l'adresse de fin de parcours dans x21

lireSudoku10:

		mov		x0,0
		adr		x1,tampon		//Param2: adresse du tampon de lecture
		mov		x2,1
		mov		x8,63
		svc		0

		ldr		x22,tampon		//Récupère la valeur lue
		sub		x22,x22,'0'
		strb	w22,[x20],1		//Écrit la valeur lue dans le sudoku et avance

		mov		x0,0
		adr		x1,tampon		//Param2: adresse du tampon de lecture
		mov		x2,1
		mov		x8,63
		svc		0

		cmp		x20,x21			//Vérifie si le parcours est terminé
		b.lt	lireSudoku10	//Sinon, passe au nombre suivant



		RESTORE					//Ramène l'environnement de l'appelant
		br		x30				//Retour à l'appelant



/*******************************************************************************
	Affiche le sudoku.
	Coquille pour démarrer AfficherStructure.

	Démarre AfficherStructure avec l'adresse de départ du sudoku, en spécifiant
	que la sous-structure à afficher sera une ligne (et donc aussi composée
	récursivement de cellules)

	Paramètres
		x0: Adresse de base du sudoku


*******************************************************************************/
AfficherSudoku:

		SAVE						//Sauvegarde l'environnement de l'appelant

		adr		x1,vtable			//Param1: Table des sous-programmes
		adr		x2,ptable			//Param2: Table des séparateurs
		mov		x3,9				//Param3: Taille de la structure de 1er niveau
		bl		AfficherStructure	//Appelle la fonction qui affiche la structure multi-niveaux

		RESTORE						//Ramène l'environnement de l'appelant
		br		x30					//Retour à l'appelant


/*******************************************************************************
	Affiche récursivement le sudoku.
	Les séparateurs apparaîssent à des intervalles fixes de 3 éléments, peu
	importe si ce sont des lignes ou des cellules uniques.

	Ce qui diffère entre afficher tout le sudoku et une ligne seulement est
	quel séparateur utiliser, puis la taille de la sous-structure (ligne ou cellule)
	qu'on affiche à chaque fois.

	Paramètres
		x0: Adresse de la structure à afficher dans le sudoku (sudoku au complet ou ligne)
		x1: Adresse de l'adresse de la fonction qui affiche les sous-structures de la structure courante
		x2: Adresse de l'adresse du séparateur utilisé dans la structure actuelle
		x3: Taille en mémoire de chaque sous-structure affichée, pour se déplacer dans le sudoku correctement

*******************************************************************************/

AfficherStructure:
		SAVE						//Sauvegarde l'environnement de l'appelant
		mov		x20,x0				//Conserve l'adresse du sudoku
		mov		x19,x1				//Conserve la table des sous-fonctions
		mov		x26,x2				//Conserve la table des séparateurs

		mov		x27,3				//Constante 3 pour calculs
		mov		x25,9				//Constante 9 pour calculs
		mov		x28,x3				//Garde la taille de la structure
		mov		x21,0				//Compteur de structure


affStruct10:
		udiv	x22,x21,x27			//Calcule compteur % 3...
		mul		x23,x22,x27			//À chaque multiple de 3, un séparateur...
		subs	xzr,x21,x23			//doit être affiché.
		b.ne	affStruct20			//Si le compteur n'est pas multiple de 3, n'affiche pas

	//appel systeme du printf pour afficher le séparateur
		ldr		x0,[x26]			//Param1:Adresse du séparateur courant
		bl		CalculLongChaine	//appel de la fonction
		mov		x24,x0				//stocke le resultat de la fonction dans x24
		mov		x0,1				//stdout
		ldr		x1,[x26]
		mov		x2,x24
		mov		x8,64
		svc		0                   //(stdout, taille ,chaine)


affStruct20:
		mul		x22,x21,x28			//Calcule la position de la structure suivante dans le sudoku
		add		x0,x20,x22			//Param1:  adresse des cellules de la structure dans le sudoku

		ldr		x30,[x19]			//Récupère l'adresse du sous-programme
		add		x1,x19,8			//Param2: table des sous-programmes (+déplacement)
		add		x2,x26,8			//Param3: table des séparateurs (+déplacement)
		udiv	x3,x28,x25			//Param4: taille de la structure / 9
		blr		x30					//Appelle le sous-programme approprié

		add		x21,x21,1			//Incrémente le compteur de structure
		cmp		x21,9				//Vérifie si on a affiché les 9 structures
		b.lt	affStruct10			//Sinon, recommence

		//appel systeme du printf pour afficher le dernier séparateur
		ldr		x0,[x26]			//Param1: adresse du séparateur
		bl		CalculLongChaine	//appel de la fonction
		mov		x24,x0				//stocke le resultat de la fonction dans x24
		mov		x0,1				//stdout
		ldr		x1,[x26]
		mov		x2,x24
		mov		x8,64
		svc		0                   //(stdout, taille ,chaine)

		//appel systeme du printf pour afficher le dernier saut de ligne
		adr		x0,sautLigne		//Param1: adresse du saut de ligne
		bl		CalculLongChaine	//appel de la fonction
		mov		x24,x0				//stocke le resultat de la fonction dans x24
		mov		x0,1				//stdout
		adr		x1,sautLigne
		mov		x2,x24
		mov		x8,64
		svc		0                   //(stdout, taille ,chaine)

		RESTORE						//Ramène l'environnement de l'appelant
		br		x30					//Retour à l'appelant


/*******************************************************************************
	Affiche une seule cellule du sudoku.


	Paramètres
		x0: Adresse de la cellule
		x1,x2 et x3 ont contiennent des valeurs préparées par AfficherStructure,
		mais celles-ci sont ignorées.

*******************************************************************************/
AfficherCellule:
		SAVE						//Sauvegarde l'environnement de l'appelant

		// appel systeme du printf pour Afficher le contenu de la cellule
		ldrb	w19,[x0]					// addresse de lentier a convertir
		mov		x2,3						// x2 = longueur de la chaine
		mov		x0,1						// stdout
		adr 	x1,fmtCaractere				// x1 = adresse de fmtCaractere

		// conversion de l'entier en caractere
		add		x19,x19,'0'                 // Caractere en ASCII = Entier + 48
		strb 	w19,[x1,1]                  // ecrit par dessus le caractere X l'entier en ASCII
		mov		x8,64						//
		svc		0							//write(chaine , taille ,stdout)


		RESTORE								//Ramène l'environnement de l'appelant
		ret
		//br		x30					//Retour à l'appelant



/*******************************************************************************
	Vérifie l'intégrité du sudoku.
	Utilise le sous-programme VerifieStructure, en paramétrisant le parcours
	pour que ce soit à tour de rôle des lignes, des colonnes et des blocs.

	Pour chaque type de structure, il faut avancer l'adresse de départ de la
	structure dans le sudoku différement. Les distances sont dans le tableau
	typeTable. Les distances entre les lignes (+9) sont en premier, celles entre
	les colonnes (+1) ensuite, et finalement, celles entre les blocs (+3,+3,+27).

	Les trois types de parcours sont fait un à la suite de l'autre, d'abord
	les lignes, ensuite les colonnes, finalement les blocs.
	Le tableau des distances entre les éléments (distable) contient les distances
	qui seront utilisées par VerifierStructure.

	Paramètres
		x0: adresse de base du sudoku

*******************************************************************************/

VerifierSudoku:
		SAVE						//Sauvegarde l'environnement de l'appelant

		mov		x20,x0				//Conserve l'adresse de base du sudoku
		mov		x28,0				//Compteur de structure
		mov		x27,0				//Compteur de type de parcours
		adr		x26,typeTable		//Tableau des distances entre structures
		adr		x21,distable		//Tableau des distances entre éléments


		/*
			Boucle des types: 1 tour de boucle par type de structure.
			0=lignes, 1=colonnes,2=blocs. Le compteur de type sert à
			retrouver déterminer quelle sous-chaîne afficher dans le
			message d'erreur, ainsi que quel groupe de valeurs de
			distances utiliser dans distable.
		*/
verifSudoku10:

		mov		x22,0				//Initialise la position de la structure
		mov		x28,0				//Initialise le compteur de structures


		/*
			Boucle des structures: 1 tour de boucle par structure (donc 9 pour
			chaque type). Le tableau des distances entre les structures (typeTable)
			est utilisé pour calculer la position de la prochaine structure dans
			le sudoku.
		*/
verifSudoku20:

		add		x0,x20,x22			//Param1: adresse de la structure
		lsl		x1,x27,3			//Param2: Type de parcours * 8...
		add		x1,x21,x1			//début de distable + type*8
		bl		VerifierStructure	//Vérifie la structure courante

		cmp		x0,0				//Vérifie le résultat
		b.eq	verifSudoku30		//Si aucune erreur, passe à la suite

		adr		x0,fmtErreur		//Param1: format d'impression
		adr		x25,fmtTable		//Adresse de la table des formats...
		ldr		x1,[x25,x27,lsl 3]	//Param2: adresse de chaîne: fmtTable + 8*type
		add		x2,x28,1			//Param3: numéro de structure (compteur +1)



		// Cette partie gére l'affichage de fmterreur1
		adr		x0,fmtErreur1
		bl		CalculLongChaine	// calcul la longeur de fmtErreur
		mov		x2,x0				// stocke le resultat dans x2
		mov		x0,1
		adr		x1,fmtErreur1
		mov		x8,64
		svc		0



		// Cette partie gére l'affichage du format
		adr		x25,fmtTable		//Adresse de la table des formats...
		ldr		x1,[x25,x27,lsl 3]	//Param2: adresse de chaîne: fmtTable + 8*type
		mov		x0,x1
		bl		CalculLongChaine	// calcule de la longeur de la chaine du format
		mov		x2,x0				// met le resultat dans x2
		mov		x0,1
		mov		x8,64
		svc		0



		// Cette partie gére l'affichage de l'index
		add		x2,x28,1			//Param3: numéro de structure (compteur +1)
		add		x2,x2,'0'			// conversion en char
		adr		x1,printable
		strb	w2,[x1]				// stockage de la variable en memoire pour l'affichage
		adr		x0,printable
		bl		CalculLongChaine	// calcule de la taille de la chaine de l'index a afficher
		mov		x2,x0				// stockage du resultat dans x2
		mov		x0,1
		mov		x8,64
		svc		0


		// Cette partie gére l'affichage du saut de ligne
		adr		x0,sautLigne
		bl		CalculLongChaine		// calcul de la taille de lal chaine du saut de ligne
		mov		x2,x0					// stockage du résultat dans x2 pour l'affichage
		mov		x0,1
		adr		x1,sautLigne
		mov		x8,64
		svc		0



verifSudoku30:

		ldrb	w25,[x26],1			//Obtient la distance avec la prochaine struct
		add		x22,x22,x25			//Incrémente la position de la structure


		add		x28,x28,1			//Incrémente le compteur de structures
		cmp		x28,9				//S'il reste des structures à parcourir...
		b.lt	verifSudoku20		//Continue la boucle des structures
		//Fin de la boucle des structures

		add		x27,x27,1			//Incrémente le compteur des types
		cmp		x27,3				//S'il reste des types à vérifier
		b.lt	verifSudoku10		//Continue la boucle des types
		//Fin de la boucle des types

verif10:
		RESTORE						//Ramène l'environnement de l'appelant
		br		x30					//Retour à l'appelant

/*******************************************************************************
	Vérifie l'intégrité d'une structure (ligne, colonne ou bloc)

	Paramètres
		x0: adresse de base de la structure dans le sudoku
		x1: adresse du tableau des distances entre les cellules.

	Résultat
		x0: 0 si une erreur a été rencontrée, 1 sinon.


	Pour les lignes, la distance entre tous les éléments dans le sudoku est 1.
	Pour les colonnes, la distance entre tous les éléments dans le sudoku est 9.
	Pour les blocs, les éléments non-muliples de 3 sont à une distance de 1,
	tandis que les éléments multiples de 3 sont à une distance de 7.
	La séquence d'incrémentation est donc +1,+1,+7,+1,+1,+7...
	Pour savoir comment avancer dans le sudoku, il suffit de récupérer le pas
	d'incrémentation correspondant dans le tableau des distances.

	Pour vérifier l'intégrité, on peut représenter dans un registre (x28 ici) 1
	bit pour chaque numéro, qui est allumé si on l'a vu et éteint sinon (ou vu
	plus qu'une fois). Lorsqu'on a terminé le parcours, les 9 bits correspondant
	à chacun des numéros devraient être allumés. Le bit 0 demeurera toujours
	éteint. La seule valeur acceptable dans	ce registre à la fin du parcours
	est donc la constante 0b1111111110 = 0x3FE.


*******************************************************************************/

VerifierStructure:
		SAVE						//Sauvegarde l'environnement de l'appelant

		mov		x20,x0				//Conserve l'adresse de base de la structure
		mov		x28,x1				//Conserve l'adresse des distances dans x28
		mov		x24,0				//Initialise les bits de vérification
		add		x27,x28,9			//Adresse de fin du tableau de distances
		mov		x25,1				//Bit à injecter dans les bits de vérification

verifStruct10:

		ldrb	w22,[x20]			//Récupère le contenu de la cellule courante
		lsl		x26,x25,x22			//Positionne le bit correctement
		eor		x24,x26,x24			//Allume le bit si éteint, éteint si allumé.

		ldrb	w23,[x28],1			//Récupère la distance suivante et avance l'adresse
		add		x20,x20,x23			//Incrémente l'adresse de cellule de la distance

		cmp		x28,x27				//Vérifie s'il reste des cellules à parcourir
		b.lt	verifStruct10		//Si oui, boucle

		cmp		x24,0x3FE			//Compare la liste de bits avec le résultat attendu
		csel	x0,xzr,x25, eq		//Choisit 0 si non-égal, 1 égal.


		RESTORE						//Ramène l'environnement de l'appelant
		br		x30					//Retour à l'appelant


CalculLongChaine:
		SAVE						//Sauvegarde l'environnement de l'appelant
		mov	    x19,x0				// x19 = adresse de la chaine de caractere
		mov		x20,0				//initialiser le compteur a 0
		b		add10				// 	branche a add10
add10 :
		ldrb    w21,[x19],1			// se depacer en memoire de 1
		cmp	    w21,0				//	compare si le caractere est egal au caractere null
		b.eq	add20				// si oui brsnche a add20

		add		x20,x20,1			// sinon incremente le compteur
		b		add10				// refait la boucle add10

add20:
		mov		x0,x20				//stocke dans x0 = longueur de la chaine = x20
		RESTORE
		br		x30					//Retour à l'appelant

.section ".rodata"

scfmt1:     	.asciz  "%d"
barreHoriz:     .asciz	"|---------|---------|---------|\n"
barreVert:		.asciz	"|"
sautLigne:		.asciz	"\n"
fmtCellule:		.asciz	" %1u "
fmtErreur:		.asciz	"Le sudoku contient une erreur dans %s %d\n"
fmtErreur1:		.asciz	"Le sudoku contient une erreur dans  "
fmtLigne:		.asciz	"la ligne "
fmtColonne:		.asciz	"la colonne "
fmtBloc:		.asciz	"le bloc "

SudokuFixe:		.byte	5,3,8,6,4,7,2,1,9,6,1,2,5,9,3,8,7,4,7,9,4,2,1,8,6,5,3,8,5,9,7,6,2,1,4,3,4,2,6,1,3,9,7,8,5,1,7,3,8,5,4,9,2,6,9,6,5,3,7,1,4,8,2,2,8,7,4,9,6,5,3,1,3,4,1,9,2,8,7,6,5


.align 8
vtable:			.dword AfficherStructure,AfficherCellule
ptable:			.dword barreHoriz, barreVert
fmtTable:		.dword fmtLigne,fmtColonne,fmtBloc
distable:		.byte 1,1,1,1,1,1,1,1,9,9,9,9,9,9,9,9,1,1,7,1,1,7,1,1
typeTable:		.byte 9,9,9,9,9,9,9,9,9,1,1,1,1,1,1,1,1,1,3,3,21,3,3,21,3,3,21



.section ".bss"
.align	4
tampon:			.skip 4
Sudoku: 		.skip 81
printable:		.skip 1

.section ".data"
fmtCaractere:	.asciz	" X "
