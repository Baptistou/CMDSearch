Program SEARCH version 6.0 by Baptiste Thémine

Windows command line utility that performs file search, text search and file/folder comparison.
Compatible with Windows XP, Vista, 7, 8, 8.1, 10 english and french.
The file search.bat can be placed into folder "C:\Windows" and be executed on CMD or PowerShell.

The syntax of this command is :

SEARCH HELP					Display help
SEARCH FILE [files...] [options]		File search
SEARCH TEXT "string" [files...] [options]	Text search
SEARCH COMP file1 file2 [options]		File comparison
SEARCH ... [/CMD[ONLY] "cmdline"]		Command line option

Note : The utility executes commands DIR, FIND, FINDSTR and FC on the computer file tree
in read only by default, i.e. without any alteration or deletion of personal data.
Therefore, changing command line option must be treated with caution.
Only a temporary file created in the folder specified by %TEMP% variable is used during
directory comparison.

Please find below English detailed help and examples of use :

SEARCH FILE [directory | files...] [options]

 Options : [/DIR directory] [/NAME files...] [/DATE [date]] [/TIME [time]]
           [/A[:attribute]] [/O[:ord]] [/S] [/T[:tf]]

 File search filters and displays a list of files in a directory according to :
 - a search mask i.e. one or multiple file titles and/or file extensions
   (wildcards "*" and "?" can be used). For example,
   /NAME a title		search files matching "*a*title*"
   /NAME "title1" "title2"	search files matching "*title1*" or "*title2*"
   /NAME .txt .bat		search text files and batch files
 - an attribute	D  Directories		R  Read-only files
		H  Hidden files		A  Files ready for archiving
		S  System files		I  Not content indexed files
		L  Reparse Points	-  Prefix meaning not
 - a date [dd/mm/yyyy] or a date range [dd/mm/yyyy - dd/mm/yyyy].
 - a time [hh:mm] or a time range [hh:mm - hh:mm].
 Note : /DATE and /TIME specified alone match for current date and time.

 /O:ord	List by files in sorted order.
	N  By name (alphabetic)		S  By size (smallest first)
	E  By extension (alphabetic)	D  By date/time (oldest first)
	G  Group directories first	-  Prefix to reverse order
 /S	Searches for matching files in the current directory and all
	subdirectories.
 /T:tf	Controls which time field displayed or used for sorting
	C  Creation		A  Last Access		W  Last Written

 Examples :

 SEARCH FILE /S
 Displays all files inside the current directory and all subdirectories.

 SEARCH FILE %TEMP%
 Displays all elements inside the Window temporary folder.

 SEARCH FILE "test" "a file name" .txt
 Searches for text files and files with a name containing the strings "test" or
 "a file name".

 SEARCH FILE /A:HS
 Displays the hidden system files inside the current directory.

 SEARCH FILE /DIR C:\Windows\system32 /NAME .exe /O:S
 Displays the list of CMD.exe commands in sorted order by size.

 SEARCH FILE /DATE /TIME 8:00-18:00
 Searches for all elements modified today between 8:00 am and 6:00 pm.

 SEARCH FILE /DATE 12/12/2012-%DATE% /T:C
 Searches for all elements created between the 12th of december 2012 and today.


SEARCH TEXT "string" [directory | files...] [options]

 Options : [/DIR directory] [/NAME files...] [/FIND[STR]] [/B] [/C] [/E] [/I]
           [/L | /R] [/M] [/N[:nnn]] [/P] [/Q] [/S] [/X]

 Text search searches for a text string in a list of files in a directory and
 displays matching lines in the report.

 /FIND	Specifies that text search will execute FIND command. It can't be used
	with B, E, L, Q, R or X specifiers.
 /FINDSTR	Specifies that text search will execute FINDSTR command.
 	The behavior of this command is different : if multiple space-separated
	words are specified, the search is performed word by word.
 /B	Matches pattern if at the beginning of a line.
 /C	Displays the count of lines containing the string.
 /E	Matches pattern if at the end of a line.
 /I	Specifies that the search is not to be case-sensitive.
 /L	Uses search string literally (by default).
 /M	Don't display matching lines.
 /N:nnn	Specifies the maximum number of characters to display for each
	matching lines. Without specification, N = 160 characters.
 /P	Skip files with non-printable characters.
 /Q	Skip lines containing non-printable characters.
 /R	Uses search string as regular expressions. For more details, please
	read the regular expression reference of FINDSTR command.
 /S	Searches for matching files in the current directory and all
	subdirectories.
 /X	Searches lines that match exactly.

 Examples :

 SEARCH TEXT "Hello world"
 Searches for all files containing the string "Hello world" and displays the
 matching lines.

 SEARCH TEXT "Hello world" /DIR "test" /NAME .txt /M /X
 Searches for text files inside the folder "test" which contains a whole line
 "Hello world" but doesn't display them.

 SEARCH TEXT "Hello world" .txt .bat /FINDSTR /B /I /L
 Searches for text and batch files containing the strings "Hello" or "world" at
 the beginning of a line and specifies that the search is not case-sensitive.

 SEARCH TEXT "^[0-9][0-9]*$" /C /P /R
 Searches for files with printable characters the lines which contains only
 digits and displays the result with the count of matching lines.

 SEARCH TEXT .* /C /M /R
 Displays the count of all lines inside each file.

 SEARCH TEXT . /C /M /R
 Displays the count of non empty lines inside each file.


SEARCH COMP file1 file2 [options]
            directory1 directory2 [options]

 Options : files     [/A] [/B | /R] [/I]
           directories  [/NAME files...] [/DATE [date]] [/TIME [time]]
                        [/A[:attribute]] [/S] [/T[:tf]] [/V]

 File comparison searches differences between two specified files and displays
 the result in the report. Comparison can also be used for two directories,
 in this case the command compares the content of each directory and displays
 differences according to name, size, and last modified date/time of each file
 (criteria can be modified with /CMD specifier).

 /A	Displays only first and last lines for each set of differences.
 /B	Performs a binary comparison.
 /I	Specifies that the search is not to be case-sensitive.
 /R	Displays only the range of each set of differences.

 /A:att	Compares files with specified attributes.
 /S	Compares the content of the two specified directories and all
	subdirectories.
 /T:tf	Controls which time field displayed or used for comparison
	C  Creation		A  Last Access		W  Last Written
 /V	Searches similarities instead of differences for comparing two
	directories.

 Examples :

 SEARCH COMP test1.txt test2.txt /I
 Does a non case-sensitive ASCII comparison between the contents of files
 "test1.txt" and "test2.txt".

 SEARCH COMP *.bat test.bat /A
 Compares the file test.bat with all batch files in current directory and
 displays the result in abbreviated format.

 SEARCH COMP test1\*.txt test2\*txt
 Does an ASCII comparison between text files two by two inside the two folders
 "test1" and "test2". The compared files must have the same name inside the two
 folders.

 SEARCH COMP test1 test2 /A:-D /S
 Searches for all file differencies between the two folders "test1" and "test2"
 and all subdirectories.

 SEARCH COMP test1 test2 /V /CMD "echo @fname"
 Searches for all file names which are both inside the folder "test1" and the
 folder "test2".

 SEARCH COMP test1 test2 /NAME .bat /T:C /CMD "echo @fdate @ftime @frelp"
 Searches for batch files which have different creation date/time inside the
 two folders "test1" and "test2".


Command line option reference :

 Syntax : SEARCH [FILE | TEXT | COMP] [/CMD[ONLY] "cmdline"]

 /CMD allows to redirect search result to a specified command line. "cmdline"
 is the command line to execute for each found files by file search or text
 search and defines also criteria for comparing two directories. If /CMDONLY is
 specified, only the specified commmand line output will be displayed.
 The default command line is "echo @fattr @fdate @ftime @fsize@tab@fpath".

 The following variables can be used in the command string :
 @fpath   - full path of the file
 @fshort  - full path of the file with short name 8.3
 @frelp   - relative path of the file
 @fname   - name of the file
 @fext    - extension of the file
 @fattr   - attributes of the file
 @fdate   - last modified date of the file
 @ftime   - last modified time of the file
 @fsize   - size of the file
 @fbyte   - size of the file in bytes
 @count   - file counter
 @tab     - tab
 @qot     - quote

 Examples :

 SEARCH FILE /CMD "echo @fdate @ftime @fsize@tab@fname@fext"
 Displays file list similarly to DIR command.

 SEARCH FILE /S /CMDONLY "echo @fpath"
 Equivalent to DIR /A /B /S.

 SEARCH FILE /CMDONLY "echo @fattr;@fdate;@ftime;@fsize;@fpath" > test.csv
 Exports the directory content into CSV document readable by Excel.

 SEARCH FILE /CMD "echo @fpath & ren @qot@fpath@qot test@count@fext"
 Renames all elements in current directory with the name "testN".

 SEARCH FILE /DATE 12/12/2012 /CMD "echo @fpath & copy @qot@fpath@qot test"
 Copies elements modified the 12th of december 2012 into folder "test".

 SEARCH TEXT "Hello world" /M /CMD "echo @fpath & del @qot@fpath@qot"
 Deletes all files which contain the string "Hello world".

 SEARCH COMP test1 test2 /V /CMD "echo @fname"
 Searches for all file names which are both inside the folder "test1" and the
 folder "test2".

 SEARCH COMP test1 test2 /NAME .bat /T:C /CMD "echo @fdate @ftime @frelp"
 Searches for batch files which have different creation date/time inside the
 two folders "test1" and "test2".


--------------------------------------------------------------------------------

Programme SEARCH version 6.0 par Baptiste Thémine

Utilitaire pour ligne de commande Windows qui effectue des recherches de fichiers,
recherches de textes et comparaison de fichiers/répertoires.
Compatible avec Windows XP, Vista, 7, 8, 8.1, 10 anglais et français.
Le fichier search.bat peut être placé dans le répertoire "C:\Windows" et exécuté
sur CMD ou PowerShell.

La syntaxe de cette commande est :

SEARCH HELP					Afficher l'aide
SEARCH FILE [fichiers...] [options]		Recherche de fichier
SEARCH TEXT "chaîne" [fichiers...] [options]	Recherche de texte
SEARCH COMP fichier1 fichier2 [options]		Comparaison de fichiers
SEARCH ... [/CMD[ONLY] "cmdline"]		Option ligne de commande

Note : L'utilitaire exécute des commandes DIR, FIND, FINDSTR et FC sur l'arborescence
de l'ordinateur en lecture seule par défaut, c'est-à-dire sans qu'aucune altération ou
suppression de vos données personnelles soit possible.
La modification de l'option ligne de commande est donc à utiliser avec précaution.
Seule l'écriture dans un fichier temporaire dans le répertoire indiqué par la variable
d'environnement %TEMP% est utilisé pour la comparaison de répertoires.

Veuillez trouver ci-dessous l'aide détaillée en français et les exemples d'utilisation :

SEARCH FILE [répertoire | fichiers...] [options]

 Options : [/DIR répertoire] [/NAME fichiers...] [/DATE [date]] [/TIME [heure]]
           [/A[:attribut]] [/O[:tri]] [/S] [/T[:tf]]

 La recherche de fichier permet de filtrer les fichiers d'un répertoire selon :
 - un masque de recherche càd un ou plusieurs titres et/ou extensions de
   fichier (caractères génériques "*" et "?" autorisés). Par exemple,
   /NAME un titre		recherche les fichiers contenant "*un*titre*"
   /NAME "titre1" "titre2"	recherche les fichiers "*titre1*" ou "*titre2*"
   /NAME .txt .bat		recherche les fichiers textes et batch
 - un attribut	D  Répertoire		R  Lecture seule
		H  Caché		A  Archive
		S  Système		I  Fichiers indexés sans contenu
		L  Points d'analyse	-  Préfixe de négation
 - une date [jj/mm/aaaa] ou une plage de dates [jj/mm/aaaa - jj/mm/aaaa].
 - une heure [hh:mm] ou une plage horaire [hh:mm - hh:mm].
 Remarque : /DATE et /TIME spécifiés seuls valent la date et l'heure actuelle.

 /O:tri	Affiche les fichiers selon un tri spécifié.
	N  Nom (alphabétique)		S  Taille (ordre croissant)
	E  Extension (alphabétique)	D  Date et heure (chronologique)
	G  Répertoires en tête		-  Préfixe en ordre indirect
 /S	Recherche les fichiers correspondants dans le répertoire et dans tous
	ses sous-répertoires.
 /T:tf	Contrôle le champ d'heure affiché et utilisé dans le tri.
	C  Création		A  Dernier accès	W  Dernière écriture

 Exemples :

 SEARCH FILE /S
 Affiche tous les fichiers présents dans le répertoire en cours et tous ses
 sous-répertoires.

 SEARCH FILE %TEMP%
 Affiche tous les éléments présents dans le dossier temporaire de Windows.

 SEARCH FILE "test" "un fichier" .txt
 Recherche les fichiers textes et les fichers dont le titre contient les
 chaînes "test" ou "un fichier".

 SEARCH FILE /A:HS
 Affiche tous les fichiers cachés systèmes du répertoire en cours.

 SEARCH FILE /DIR C:\Windows\system32 /NAME %PATHEXT% /O:-N
 Affiche toutes les commandes de CMD.exe dans l'ordre alphabétique décroissant.

 SEARCH FILE /DATE /TIME 8:00-18:00
 Recherche tous les éléments modifiés aujourd'hui entre 8 et 18 heures.

 SEARCH FILE /DATE 12/12/2012-%DATE% /T:C
 Recherche tous les éléments créés depuis le 12 décembre 2012 à aujourd'hui.


SEARCH TEXT "chaîne" [répertoire | fichiers...] [options]

 Options : [/DIR répertoire] [/NAME fichiers...] [/FIND[STR]] [/B] [/C] [/E]
           [/I] [/L | /R] [/M] [/N[:nnn]] [/P] [/Q] [/S] [/X]

 La recherche de texte permet de rechercher une chaîne dans les fichiers d'un
 répertoire et d'afficher les lignes correspondantes dans le rapport.

 /FIND	Spécifie que la recherche s'effectue avec la commande FIND. Ne peut pas
	être utilisée avec les commutateurs B, E, L, Q, R ou X.
 /FINDSTR	Spécifie que la recherche s'effectue avec la commande FINDSTR.
 	Cette dernière a un comportement différent : si plusieurs mots séparés
	par un espace sont spécifiés, la recherche s'effectue mot par mot.
 /B	Recherche l'élément s'il est en début de ligne.
 /C	Compte le nombre de lignes contenant la chaîne.
 /E	Recherche l'élément s'il est en fin de ligne.
 /I	Spécifie que la recherche ne doit pas tenir compte de la casse.
 /L	Recherche la chaîne spécifiée littéralement (par défaut).
 /M	Ne pas afficher les lignes correspondantes.
 /N:nnn	Spécifie le nombre maximal de caractères à afficher pour chaque ligne
	correspondante. Sans nombre spécifié, N = 160 caractères.
 /P	Ignore les fichiers contenant des caractères non affichables.
 /Q	Ignore les lignes correspondantes avec caractères non affichables.
 /R	Recherche la chaîne spécifiée en tant qu'expression régulière. Pour
	plus de détails, consultez l'aide de la commande FINDSTR.
 /S	Recherche les fichiers correspondants dans le répertoire et dans tous
	ses sous-répertoires.
 /X	Recherche les lignes correspondant parfaitement.

 Exemples :

 SEARCH TEXT "Hello world"
 Recherche tous les fichiers contenant la chaîne "Hello world" et affiche les
 lignes correspondantes.

 SEARCH TEXT "Hello world" /DIR "test" /NAME .txt /M /X
 Recherche les fichiers textes dans le répertoire "test" qui contiennent au
 moins une ligne "Hello world" mais ne les affiche pas.

 SEARCH TEXT "Hello world" .txt .bat /FINDSTR /B /I /L
 Recherche les fichiers textes et batch contenant les chaînes "Hello" ou
 "world" en début de ligne et sans tenir compte de la casse.

 SEARCH TEXT "^[0-9][0-9]*$" /C /P /R
 Recherche dans les fichiers lisibles les lignes qui ne contiennent que des
 chiffres et affiche le résultat avec le nombre de lignes correspondantes.

 SEARCH TEXT .* /C /M /R
 Affiche le nombre total de lignes contenus dans chaque fichier.

 SEARCH TEXT . /C /M /R
 Affiche le nombre total de lignes non vides contenus dans chaque fichier.


SEARCH COMP fichier1 fichier2 [options]
            répertoire1 répertoire2 [options]

 Options : fichiers     [/A] [/B | /R] [/I]
           répertoires  [/NAME fichiers...] [/DATE [date]] [/TIME [heure]]
                        [/A[:attribut]] [/S] [/T[:tf]] [/V]

 La comparaison de fichiers permet de rechercher les différences entre deux
 fichiers spécifiés et de les afficher dans le rapport. La comparaison peut
 également s'effectuer sur deux répertoires auquel cas la commande va comparer
 le contenu des répertoires et afficher les différences selon le nom, la taille
 et la date/heure de dernière modification de chaque fichier (ces critères
 peuvent être modifiés avec /CMD).

 /A	Affiche la 1ère et dernière ligne de chaque ensemble de différences.
 /B	Effectue une comparaison binaire.
 /I	Spécifie que la recherche ne doit pas tenir compte de la casse.
 /R	Affiche uniquement l'intervalle de chaque ensemble de différences.

 /A:att	Compare les fichiers dotés des attributs spécifiés.
 /S	Compare le contenu des deux répertoires spécifiés et de tous leurs
	sous-répertoires.
 /T:tf	Contrôle le champ d'heure affiché et utilisé dans la comparaison.
	C  Création		A  Dernier accès	W  Dernière écriture
 /V	Recherche les ressemblances au lieu des différences pour la comparaison
	de deux répertoires.

 Exemples :

 SEARCH COMP test1.txt test2.txt /I
 Compare le contenu ASCII des fichiers "test1.txt" et "test2.txt" sans tenir
 compte de la casse.

 SEARCH COMP *.bat test.bat /A
 Compare le fichier test.bat avec tous les fichiers batch du répertoire courant
 en affichant le résultat abrégé.

 SEARCH COMP test1\*.txt test2\*txt
 Compare le contenu ASCII des fichiers textes deux à deux dans les répertoires
 "test1" et "test2". Les fichiers comparés doivent porter le même nom dans les
 deux répertoires.

 SEARCH COMP test1 test2 /A:-D /S
 Recherche toutes les différences de fichiers entre les répertoires "test1" et
 "test2" et tous leurs sous-répertoires.

 SEARCH COMP test1 test2 /V /CMD "echo @fname"
 Recherche tous les noms de fichier présents à la fois dans le répertoire
 "test1" et le répertoire "test2".

 SEARCH COMP test1 test2 /NAME .bat /T:C /CMD "echo @fdate @ftime @frelp"
 Recherche les fichiers batch présents dans les répertoires "test1" et "test2"
 dont les dates/heures de création sont différentes.


Guide de l'option ligne de commande

 Utilisation : SEARCH [FILE | TEXT | COMP] [/CMD[ONLY] "cmdline"]

 /CMD permet de rediriger le résultat de la recherche vers une commande
 spécifiée. "cmdline" indique la ligne de commande à exécuter pour chaque
 fichier trouvé par la recherche de fichier ou de texte et permet également de
 définir les critères de comparaison de deux répertoires. Si /CMDONLY est
 spécifié, alors seule la sortie de la ligne de commande est affichée. La ligne
 de commande par défaut est "echo @fattr @fdate @ftime @fsize@tab@fpath".

 Les variables suivantes peuvent être utilisées dans la chaîne de commandes :
 @fpath   - chemin d'accès complet du fichier
 @fshort  - chemin d'accès complet du fichier avec nom court 8.3
 @frelp   - chemin d'accès relatif du fichier
 @fname   - nom du fichier
 @fext    - extension du fichier
 @fattr   - attributs du fichier
 @fdate   - date de dernière modification du fichier
 @ftime   - dernière heure de modification du fichier
 @fsize   - taille du fichier
 @fbyte   - taille du fichier en octets
 @count   - compteur de fichier
 @tab     - tabulation
 @qot     - guillemet

 Exemples :

 SEARCH FILE /CMD "echo @fdate @ftime @fsize@tab@fname@fext"
 Affiche la liste de fichiers de manière semblable à la commande DIR.

 SEARCH FILE /S /CMDONLY "echo @fpath"
 Equivalent à DIR /A /B /S.

 SEARCH FILE /CMDONLY "echo @fattr;@fdate;@ftime;@fsize;@fpath" > test.csv
 Exporte le contenu du répertoire dans un document CSV lisible par Excel.

 SEARCH FILE /CMD "echo @fpath & ren @qot@fpath@qot test@count@fext"
 Renomme tous les éléments du répertoire courant avec le nom "testN".

 SEARCH FILE /DATE 12/12/2012 /CMD "echo @fpath & copy @qot@fpath@qot test"
 Copie les éléments modifiés le 12 décembre 2012 vers le répertoire "test".

 SEARCH TEXT "Hello world" /M /CMD "echo @fpath & del @qot@fpath@qot"
 Efface tous les fichiers contenant la chaîne "Hello world".

 SEARCH COMP test1 test2 /V /CMD "echo @fname"
 Recherche tous les noms de fichier présents à la fois dans le répertoire
 "test1" et le répertoire "test2".

 SEARCH COMP test1 test2 /NAME .bat /T:C /CMD "echo @fdate @ftime @frelp"
 Recherche les fichiers batch présents dans les répertoires "test1" et "test2"
 dont les dates/heures de création sont différentes.
