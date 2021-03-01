---
title: "Esercitazione 1"
subtitle: "Calcolo numerico per la generazione di immagini fotorealistiche"
author: "Maurizio Tomasi <maurizio.tomasi@unimi.it>"
...

# Gestione di progetti

# Panoramica

-   In questo corso svilupperemo un programma complesso per generare
    immagini fotorealistiche;
-   La gestione di programmi complessi richiede una serie di accorgimenti:
    -   Controlli automatici della qualità del codice
    -   Monitoraggio delle modifiche
    -   Visibilità del codice ad altri utenti
    -   Accesso alla documentazione

# Sistemi di controllo delle versioni

-   Un sistema di controllo di versione (*version control system*,
    VCS) registra le modifiche fatte al codice;
-   Possibilità di annullare modifiche;
-   Rilascio di «release» (es., 1.0, 1.1, 1.2) con possibilità di
    recuperare quelle più vecchie;
-   Garantisce a più programmatori di modificare il codice
    *contemporaneamente* (con alcune avvertenze).

# Modo d'uso di un VCS

-   Un VCS gestisce una *directory*, con tutte le sue sottodirectory;
-   Quando si crea/modifica un file dentro la directory, si chiede al
    VCS di *registrare* la modifica;
-   Il VCS scatta «istantanee» della directory, che salva in un
    proprio database.

# Esempio d'uso

-   Creo una directory `raytracer` e un file `raytracer/hello.py`:

    ```python
    print("Hello, wold!")
    ```

-   Invoco il VCS per «salvare» un'istantanea della directory
    `raytracer`

-   Modifico il file `raytracer/hello.py` per correggere il messaggio:

    ```python
    print("Hello, world!")
    ```

-   Invoco di nuovo il VCS per «salvare» una nuova istantanea della
    directory

# Esempio d'uso

Alla fine dell'esempio, il database del VCS contiene due istantanee:

1.  File `raytracer/hello.py` con questo contenuto:

    ```python
    print("Hello, wold!")
    ```

2.  File `raytracer/hello.py` con questo contenuto:

    ```python
    print("Hello, world!")
    ```

# Commit

-   A ogni «istantanea» sono sempre associate dai VCS alcune informazioni aggiuntive:

    -   Utente che ha eseguito l'istantanea
    -   Data e ora dell'istantanea

-   Nel gergo dei VCS, una istantanea si dice **commit**.

# Un semplice VCS (1/2)

-   In Linux/Mac OS X, è possibile realizzare un semplice VCS con il
    comando seguente (da shell Bash/Zsh):

    ```sh
    tar -c -f "/vcsdatabase/raytracer-$(date +%Y%m%d%H%M%S)-$(whoami).tar" *
    ```

-   Il comando crea in un folder `/vcsdatabase` un file `.tar` contenente
    tutti i file della directory corrente

-   Il nome del file contiene il nome dell'utente e la data;
    quest'ultima è codificata come un lungo numero (es.,
    `20200926155130` per la data 2020-09-26, 15:51:30)

# Un semplice VCS (2/2)

È sempre utile associare un breve commento a un commit. Estendiamo
la nostra idea in uno shell script, che possiamo chiamare `my_vcs.sh`:

```sh
#!/bin/bash

readonly destpath="$1"
readonly tag="$2"

if [ "$tag" == "" ]; then
    echo "Usage: $0 PATH TAG"
    exit 1
fi

readonly filename="${destpath}/$(date +%Y%m%d%H%M%S)-$(whoami)-${tag}.tar"
tar -c -f "$filename" *
echo "File \"$filename\" created successfully"
```

Rendete lo script eseguibile con `chmod +x my_vcs.sh`.

# Esempio d'uso

<asciinema-player src="cast/hello_world.cast" rows="20" cols="94" font-size="medium"></asciinema-player>

# Vantaggi di un VCS

-   Abbiamo un backup del codice: se cancelliamo per sbaglio un file sorgente dalla directory di lavoro, possiamo recuperarlo da `/vcsdatabase`

-   Se ci accorgiamo che una modifica non funziona, possiamo ripristinare la versione precedente

-   Possiamo ricostruire la storia dello sviluppo del codice, semplicemente guardando l'elenco dei file in `/vcsdatabase`:

    ```
    20200926153856-tomasi-first-release.tar
    20200926155130-tomasi-fix-bug.tar
    ```

-   Se ci accorgiamo dell'esistenza di un bug, possiamo controllare a ritroso in quale momento il bug è stato introdotto

# Problemi del nostro VCS (1/4)

-   Se si usa un VCS, è probabilmente perché il progetto è complesso e ha molti file

-   Di solito le modifiche influenzano uno o comunque pochi file
    alla volta

-   Ma la nostra implementazione con `tar` salva ogni volta **tutti i
    file**: questo rischia di occupare molto spazio, e non è
    necessario!

-   C'è anche un altro problema: se nel database ci fossero i file

    ```
    20200926153856-tomasi-first-release.tar
    20200926155130-tomasi-fix-bug.tar
    ```

    e volessimo capire cos'era il «bug» e com'è stato corretto, dovremmo confrontare uno a uno i file nell'ultimo `.tar` con i loro analoghi nel `.tar` precedente per capire cosa sia cambiato.

# Problemi del nostro VCS (2/4)

-   Potremmo scrivere uno shell script che invoca `tar` salvando solo
    i file effettivamente modificati (controllando ad esempio la data
    di modifica di ciascun file con `ls -l`).
-   Ma neppure questo è ottimale: può darsi che un file molto lungo
    sia stato cambiato in **una sola riga**, e noi lo salveremmo per
    intero!
-   (Ci sono in giro file «molto lunghi», di decine di migliaia di
    linee di codice.
    L'[amalgamatron](https://www.sqlite.org/amalgamation.html) di
    SQLite3 è un file in linguaggio C di 220.000 righe.)

# Problemi del nostro VCS (3/4)

-   Modifiche complesse sono solitamente implementate in modo graduale; ad esempio:

    1.  Modifica che aggiunge la possibilità di salvare il lavoro in un file;

    2.  Modifica che aggiunge la possibilità di caricare un file;

    Se ciascuna delle due attività richiedesse una settimana di lavoro, il programmatore potrebbe voler eseguire un backup terminato il primo punto, e poi passare al secondo.

-   Il nostro sistema non consente di raggruppare modifiche logicamente legate tra loro: ogni file `tar` è indipendente dagli altri!

# Problemi del nostro VCS (4/4)

-   Il nostro sistema non offre alcun controllo nel caso in cui più di una persona lavori al progetto.

-   Considerate questa situazione:

    -   A parte dal `.tar` con l'ultima versione del codice per correggere un bug;

    -   B parte dallo stesso `.tar` per aggiungere una funzionalità al programma;

    -   A usa `my_vcs.sh` per salvare la sua versione col bug corretto;

    -   B usa `my_vcs.sh` per salvare la sua versione con la nuova
        funzionalità.

    Al termine ci sarà un file `.tar` col bug corretto ma senza la funzionalità, e un file `.tar` con la nuova funzionalità ma in cui il bug è ancora presente.

# VCS professionali

-   Esistono soluzioni per ciascuno dei problemi che abbiamo individuato nel nostro VCS.

-   I VCS moderni hanno tutti queste caratteristiche:

    -   Salvano solo le parti di file che sono cambiate (usando
        strumenti simili al comando `diff` che c'è in Linux e Mac OS
        X);

    -   Consentono di raggruppare commit che sono logicamente legati
        (es., salvataggio/caricamento file)

    -   Nel caso in cui più programmatori lavorino allo stesso file,
        controllano la consistenza delle modifiche

# Tipi di VCS

Centralizzati
 : Il database (la nostra directory `/vcsdatabase`) risiede su un computer remoto, a cui tutti i programmatori accedono.

Distribuiti
 : Il database risiede sul computer locale; più programmatori che lavorano allo stesso codice hanno un proprio database, che sincronizzano tra loro periodicamente (di solito con un comando esplicito).

# Alcuni VCS importanti

| Nome                 | Tipo           | Esempio                        |
|----------------------+----------------|--------------------------------|
| [Subversion](https://subversion.apache.org/) | Centralizzato | FreePascal, GCC (fino al 2019) |
| [GNU Bazaar](https://bazaar.canonical.com/en/) | Distribuito | Ubuntu Linux |
| [Mercurial](https://www.mercurial-scm.org/) | Distribuito | Facebook, Mozilla, GNU Octave |
| [Fossil](https://www.fossil-scm.org/home/doc/trunk/www/index.wiki) | Distribuito | SQLite |
| [BitKeeper](https://www.bitkeeper.org/) | Distribuito | Linux Kernel (fino al 2005) |
| [Git](https://git-scm.com/) | Distribuito | Troppi esempi! |

# Git

-   Creato da Linus Torvalds, creatore di Linux
-   VCS distribuito
-   Estremamente versatile…
-   …ma molto complesso da usare!
-   Oggi è lo standard tra i VCS (purtroppo)

# Usare Git (1/3)

-   Sotto sistemi Ubuntu/Mint Linux, installate Git con `sudo apt install git`

-   Appena installato, dovete configurare Git con la vostra identità. Avviate questi comandi:

    ```
    git config --global user.email "VOSTRAMAIL@BLABLA"
    git config --global user.name "Nome Cognome"
    ```

    Questo permetterà a git di associare il vostro nome alle azioni che effettuerete sul repository. (È ovviamente superfluo se sapete che al repository lavorerete sempre e solo voi, ma Git è pensato per essere uno strumento *collaborativo*).

#   Usare Git (2/3)

-   Per creare un database in una directory, eseguite

    ```
    git init
    ```

    Questo creerà una directory nascosta `.git` (equivalente alla nostra `/vcsdatabase`).

-   La prima volta che eseguite `git init` potrebbe richiedere di specificare il vostro nome e indirizzo email.

# Usare Git (3/3)

-   Quando volete fare un *commit*, dovete eseguire due operazioni:

    ```
    git add NOMEFILE1 NOMEFILE2…
    git commit
    ```

    Il primo comando prepara i file per «scattare l'istantanea»,
    copiandoli nella *staging area*, la seconda effettua l'istantanea
    vera e propria.

-   Il comando `git commit` apre un editor per inserire una descrizione.

# Come funziona Git (1/2)

-   Ogni commit/istantanea è identificata da un lungo numero
    esadecimale chiamato *hash* (es.,
    `2f2f2cb36bbf02eaf5629b6295e9a47684c16905`).
-   A ogni commit sono associati *due* hash:

    -   Il proprio hash (ovvio!)
    -   L'hash del commit precedente

-   L'hash dell'ultimo commit si chiama `HEAD`, ed è possibile
    visualizzarla tramite il comando

    ```
    git rev-parse HEAD
    ```

# Come funziona Git (2/2)

Quando si esegue `git commit`, avvengono queste cose:

1.   `git` analizza quali file sono stati modificati rispetto
     all'ultimo commit (indicato da `HEAD`);
2.   Crea un nuovo commit, salvando solo le modifiche rispetto al
     commit `HEAD`;
3.   Salva nel commit il valore `HEAD` come «hash precedente»
3.   Crea una nuova hash per il commit;
4.   Modifica `HEAD` in modo da puntare alla nuova hash.

# Come funziona git

![](./media/git-commit-anim.svg)

# Il nostro esempio con git

<asciinema-player src="cast/hello_world_git.cast" rows="20" cols="94" font-size="medium"></asciinema-player>

# Alcuni comandi utili

-    `git status` mostra lo stato del repository (**molto utile!**)
-    `git log` stampa la lista di commit partendo dall'ultimo (`HEAD`)
     e andando a ritroso
-    `git diff` mostra quali file sono stati cambiati dopo l'ultimo commit
-    `git mv` rinomina un file
-    `git rm` cancella un file

# File da escludere

-   I file generati automaticamente non dovrebbero essere inclusi in un repository (es., i file `*.o`, i backup, gli eseguibili, etc.)
-   Se si crea un file di testo di nome `.gitignore`, si possono elencare al suo interno i file da *escludere*. Ad esempio:

    ```
    *~
    *.o
    build/
    ```
-   Il file `.gitignore` va aggiunto al repository (`git add .gitignore`, seguito da `git commit`).


# GitHub

# Sistemi distribuiti

![](./media/distributed vcs.svg)

# Introduzione a GitHub

<iframe src="https://player.vimeo.com/video/513803423?badge=0&amp;autopause=0&amp;player_id=0&amp;app_id=58479" width="960" height="540" frameborder="0" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen title="anGitHub hello_world demo"></iframe>

# Come funziona GitHub

![](./media/distributed vcs.svg)

# Come funziona GitHub

![](./media/github-sketch.svg)

# Software hosting basato su Git

-   GitHub (Microsoft): il più diffuso
-   GitLab (GitLab Inc.)
-   BitBucket (Atlassian)
-   SourceForge (Slashdot Media): il primo ad aver avuto grande diffusione, ora è poco usato
-   Esistono anche soluzioni self-hosted ([Gitea](https://github.com/go-gitea/gitea), [GitBucket](https://github.com/gitbucket/gitbucket), etc.)

# BitBucket

<iframe src="https://player.vimeo.com/video/513805000" width="960" height="540" frameborder="0" allow="autoplay; fullscreen" allowfullscreen></iframe>

# Sincronizzare Git

Siccome Git è un sistema distribuito, occorre sincronizzare
manualmente il proprio database. Questi sono i comandi più importanti:

- `git clone` crea una nuova directory basandosi su un database remoto;
- `git pull` sincronizza il proprio database richiedendo le modifiche
  da uno remoto;
- `git push` invia le proprie modifiche locali a un database remoto.

# Git

![](./media/xkcd-git.png)

# Git

![](./media/git-coffee-mug.jpg){height=560}



# Guida per l'esercitazione


# Guida per l'esercitazione

1.  Creare un proprio account su GitHub (se non lo si ha già)
2.  Creare un progetto vuoto e aggiungere `README.md`, `CHANGELOG.md`, `LICENSE.md` e `.gitignore`
4.  Scrivere un programma (nel linguaggio di programmazione scelto) che stampi `Hello, wold!` [senza `r`] e pubblicarlo su GitHub
5.  Aprire una issue, sistemare il messaggio e chiudere la issue
6.  Aggiungere la possibilità di specificare un nome da linea di comando (come accedere alla linea di comando dipende dal linguaggio: provate a scoprirlo voi!)

# Indicazioni per C++

-   Installare CMake; sotto Linux Debian/Ubuntu/Mint basta eseguire

    ```
    sudo apt install cmake
    ```

-   Creare un'applicazione che produca un eseguibile. Strutturare il codice in questo modo:

    -   Un file `CMakeLists.txt` nella directory principale
    -   Una directory `src` che contiene il file `main.cpp`

-   In `.gitignore` elencate `*.o`, il nome dell'eseguibile (es. `hello_world`) ed eventuali file di backup (`*.bak`, `*~` a seconda dell'editor che usate)

# Esempio di CMake per C++

```cmake
cmake_minimum_required(VERSION 3.12)

# Define a "project", providing a description and a programming language
project(hello_world
    VERSION 1.0
    DESCRIPTION "Hello world in C++"
    LANGUAGES CXX
)

# Our "project" will be able to build an executable out of a C++ source file
add_executable(hello_world
    main.cpp
)

# Force the compiler to use the C++17 standard
target_compile_features(hello_world PUBLIC cxx_std_17)
```

Riferimenti per CMake: [Documentazione ufficiale](https://cmake.org/documentation/), [*Professional CMake*](https://crascit.com/professional-cmake/) (C. Scott).

# Indicazioni per C\#

-   Creare un'applicazione vuota con `dotnet new console`

# Indicazioni per Julia

-   Creare un package usando la guida in [julialang.github.io/Pkg.jl/v1/creating-packages/](https://julialang.github.io/Pkg.jl/v1/creating-packages/)

-   Creare un'applicazione che implementi la funzione `main`:

    ```julia
    #!/usr/bin/env julia

    function main()
        # …
    end
    ```


# Indicazioni per Kotlin

-   Creare un'applicazione console in IntelliJ IDEA

-   La directory che contiene il progetto ha un eseguibile, `gradlew`, che può essere usato per produrre una *distribution* nella directory `./build/distributions`:

    ```
    gradlew assembleDist
    ```

    Create una distribuzione del vostro programma e cercate di capire come installarla e usarla.
