---
title: "Esercitazione 1: Git e GitHub"
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

-   Creo una directory `hello_world` e un file `hello_world/hello.py`:

    ```python
    print("Hello, wold!")
    ```

-   Invoco il VCS per «salvare» un'istantanea della directory
    `hello_world`

-   Modifico il file `hello_world/hello.py` per correggere il messaggio:

    ```python
    print("Hello, world!")
    ```

-   Invoco di nuovo il VCS per «salvare» una nuova istantanea della
    directory

# Esempio d'uso

Alla fine dell'esempio, il database del VCS contiene due istantanee:

1.  File `hello_world/hello.py` con questo contenuto:

    ```python
    print("Hello, wold!")
    ```

2.  File `hello_world/hello.py` con questo contenuto:

    ```python
    print("Hello, world!")
    ```

# Commit

-   A ogni «istantanea» sono sempre associate dai VCS alcune informazioni aggiuntive:

    -   Utente che ha eseguito l'istantanea
    -   Data e ora dell'istantanea

-   Nel gergo dei VCS, una istantanea si dice **commit**.

# Un semplice VCS (1/3)

-   Possiamo realizzare un semplice VCS in Linux/Mac OS X (da shell Bash/Zsh) usando due programmi da linea di comando: `date` (stampa data e ora) e `whoami` (stampa il nome dell'utente).

    ```sh
    $ date +%Y-%m-%d  # Data nel formato ANNO-MESE-GIORNO
    2021-03-03
    $ whoami
    tomasi
    ```
        
-   Usiamo la possibilità delle shell Unix di sostituire comandi usando `$()`:

    ```sh
    $ echo "Ciao, io sono $(whoami) e oggi è $(date +%Y-%m-%d)"
    Ciao, io sono tomasi e oggi è 2021-03-03
    ```

# Un semplice VCS (2/3)

-   Questo comando realizza una copia di backup dei file nella directory corrente:

    ```sh
    tar -c -f "/vcsdatabase/hello_world-$(date +%Y%m%d%H%M%S)-$(whoami).tar" *
    ```

-   Il comando crea in un folder `/vcsdatabase` un file `.tar` contenente
    tutti i file della directory corrente

-   Il nome del file contiene il nome dell'utente e la data;
    quest'ultima è codificata come un lungo numero (es.,
    `20200926155130` per la data 2020-09-26, 15:51:30)

# Un semplice VCS (3/3)

È sempre utile associare un breve commento a un commit. Estendiamo la nostra idea in uno shell script chiamato `my_vcs.sh`:

```sh
#!/bin/bash

readonly destpath="$1"
readonly tag="$2"

if [ "$tag" == "" ]; then
    echo "Usage: $0 PATH TAG"
    exit 1
fi

# Create the folder, if it does not exist
mkdir -p "${destpath}"

readonly filename="${destpath}/$(date +%Y%m%d%H%M%S)-$(whoami)-${tag}.tar"
tar -c -f "$filename" *
echo "File \"$filename\" created successfully"
```

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
    L'[amalgamation](https://www.sqlite.org/amalgamation.html) di
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

# Esempio {data-transition="none"}

<!-- Immagini create con git-sim https://github.com/initialcommit-com/git-sim -->
![](./media/git-process-01.jpg){height=600px}

# Esempio {data-transition="none"}

![](./media/git-process-02.jpg){height=600px}

# Esempio {data-transition="none"}

![](./media/git-process-03.jpg){height=600px}

# Esempio {data-transition="none"}

![](./media/git-process-04.jpg){height=600px}

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
-   Potete generare questo file usando il sito [gitignore.io](https://gitignore.io/), oppure la vostra IDE.

# GitHub

# Sistemi distribuiti

![](./media/distributed vcs.svg)

# Introduzione a GitHub

<iframe src="https://player.vimeo.com/video/513803423?badge=0&amp;autopause=0&amp;player_id=0&amp;app_id=58479" width="960" height="540" frameborder="0" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen title="anGitHub hello_world demo"></iframe>

# Sincronizzare Git

Siccome Git è un sistema distribuito, quando ci si connette a un server remoto occorre *sincronizzare* il proprio database. Questi sono i comandi più importanti:

- `git clone` crea una nuova directory basandosi su un database remoto, e scarica l'intero database in `.git`;
- `git pull` sincronizza il proprio database in `.git` richiedendo le modifiche
  da uno remoto;
- `git push` invia le proprie modifiche locali in `.git` a un database remoto.

# Come funziona GitHub

![](./media/distributed vcs.svg)

# Come funziona GitHub

![](./media/github-sketch.svg)

# Software hosting basato su Git

-   [GitHub](https://github.com) (Microsoft): il più diffuso
-   [GitLab](https://about.gitlab.com/) (GitLab Inc.)
-   [BitBucket](https://bitbucket.org/product) (Atlassian)
-   [SourceForge](https://sourceforge.net/) (Slashdot Media): il primo ad aver avuto grande diffusione, ora è poco usato
-   Esistono anche soluzioni self-hosted ([Gitea](https://github.com/go-gitea/gitea), [GitBucket](https://github.com/gitbucket/gitbucket), etc.)

# BitBucket

<iframe src="https://player.vimeo.com/video/513805000" width="960" height="540" frameborder="0" allow="autoplay; fullscreen" allowfullscreen></iframe>

# Git

[![](./media/git-coffee-mug.jpg){height=560}](https://remembertheapi.com/products/git-cheat-sheet-black-mugs)



# Guida per l'esercitazione


# Guida per l'esercitazione

1.  Creare un proprio account su GitHub (se non lo si ha già)
2.  Creare un progetto vuoto e aggiungere `.gitignore`
4.  Scrivere un programma (nel linguaggio di programmazione scelto) che stampi `Hello, wold!` [senza `r`], fare un commit (1) e pubblicarlo su GitHub
5.  Sistemare l'errore nella scritta e fare un commit (2)
6.  Aggiungere la possibilità di specificare un nome e fare un commit (3):

    ```sh
    $ hello_world
    Hello, world!
    $ hello_world Maurizio
    Hello, Maurizio!
    ```

# Uso di IDE

-   Se possibile, iniziate già oggi ad impratichirvi con un ambiente di sviluppo integrato (IDE) appropriato per il vostro linguaggio
-   Personalmente sono un ammiratore delle IDE sviluppate da [JetBrains](https://www.jetbrains.com/); sono a pagamento, ma esistono [licenze gratuite per studenti](https://www.jetbrains.com/community/education/#students).
-   Ho realizzato un video che mostra come usare [Rider](https://www.jetbrains.com/rider/); è utile che lo guardino anche coloro che usano altri linguaggi, in modo da sapere quali caratteristiche cercare nelle IDE

---

<iframe src="https://player.vimeo.com/video/683431827?h=9e4de4dba1&amp;badge=0&amp;autopause=0&amp;player_id=0&amp;app_id=58479" width="1280" height="720" frameborder="0" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen title="Come usare una IDE (JetBrains Rider)"></iframe>

# Suggerimenti per C\#

# Suggerimenti

-   Creare un'applicazione vuota e il file `.gitignore`; se usate `dotnet` da linea di comando, eseguite

    ```sh
    $ dotnet new console
    $ dotnet new gitignore
    ```
    
    Se usate Rider, assicuratevi di attivare Git quando create il progetto.
    
-   L'applicazione stampa già `Hello World!`: cambiate il messaggio in `Hello, wold!` (altrimenti l'esercitazione di oggi non ha senso!)
    
-   Compilate ed eseguite; da linea di comando, eseguite

    ```
    dotnet run
    ```
    
    mentre sotto Rider premete Shift+F10.

# Esempio

<asciinema-player src="cast/dotnet-example.cast" rows="20" cols="94" font-size="medium"></asciinema-player>

# Formattazione

-   Per formattare automaticamente il codice in Rider, eseguite *Code*/*Reformat code* (Shift+Alt+L)

-   Sotto Visual Studio Code, installate il package [C\#](https://code.visualstudio.com/docs/languages/csharp).

-   Per formattare il codice da linea di comando, installate `dotnet-format`:

    ```sh
    $ dotnet tool install -g dotnet-format
    ```


# Indicazioni per C++

# Istruzioni

-   Installare CMake; sotto Linux Debian/Ubuntu/Mint basta eseguire

    ```
    sudo apt install cmake
    ```

-   Creare un'applicazione che produca un eseguibile. Strutturare il codice in questo modo:

    -   Un file `CMakeLists.txt` nella directory principale
    -   Una directory `src` che contiene il file `main.cpp`

-   In `.gitignore` elencate `*.o`, il nome dell'eseguibile (es. `hello_world`), eventuali file di backup (`*.bak`, `*~` a seconda dell'editor che usate) e la directory `build` (oppure usate [gitignore.io](https://gitignore.io/) indicando `c++` e `cmake`).

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
    src/main.cpp
)

# Force the compiler to use the C++17 standard
target_compile_features(hello_world PUBLIC cxx_std_17)
```

# Esempio d'uso di CMake

<asciinema-player src="cast/cmake-example.cast" rows="20" cols="94" font-size="medium"></asciinema-player>

# Riferimenti per CMake

- [Documentazione ufficiale](https://cmake.org/documentation/) (abbastanza illeggibile, ma è la più aggiornata per definizione)
- [*Professional CMake*](https://crascit.com/professional-cmake/) (C. Scott)
- [*An Introduction to Modern CMake*](https://cliutils.gitlab.io/modern-cmake/)

# Formattazione

-   Se usate [CLion](https://www.jetbrains.com/clion/) (consigliatissimo!), potete formattare il codice usando il comando *Code*/*Reformat code* (Shift+Alt+L)

-   Altrimenti, esiste il programma da linea di comando `clang-format`; installatelo con

    ```sh
    sudo apt install clang-format
    ```
    
-   Se scrivete questo:

    ```c++
    int sum  ( int a,int b    )    {    return a+ b;}
    ```
    
    la formattazione automatica lo trasforma in
    ```c++
    int sum(int a, int b) { return a + b; }
    ```

# Formattazione

-   Il programma `clang-format` si usa da linea di comando:

    ```sh
    clang-format -i main.cpp
    ```
    
-   Se **non** usate CLion, dovrebbe essere possibile configurare il vostro editor perché invochi automaticamente `clang-format` ad ogni salvataggio (ad esempio, per VSCode esiste il package [clang-format](https://github.com/xaverh/vscode-clang-format-provider))

-   Questi strumenti sono utilissimi per mantenere il codice pulito e chiaro da leggere: cercate di configurarli al meglio e di imparare ad usarli sin da subito.


# Indicazioni per Nim/D/Rust

# Suggerimenti (1/2)

-   Creare un'applicazione vuota usando il package manager del vostro linguaggio. Nim usa `nimble`:

    ```
    $ nimble init helloworld
    ```
    
-   D usa `dub`:

    ```
    $ dub init helloworld
    ```
    
-   Rust usa `cargo`:

    ```
    $ cargo init helloworld
    ```
    
-   Sia con Nim che con D dovrete rispondere ad alcune domande. Se possibile, scegliete il default (ma per Nim assicuratevi di specificare che volete un `binary`).

# Suggerimenti (2/2)

-   L'applicazione stampa già `Hello World!`: cambiate il messaggio in `Hello, wold!` (altrimenti l'esercitazione di oggi non ha senso!)
    
-   Per compilare ed eseguire, basta usare il comando `run` (identico in `nimble`, `dub` e `cargo`):

    ```
    $ cd helloworld
    $ nimble run     # Oppure: dub run, oppure: cargo run
    ```

-   Sia per [D](https://intellij-dlanguage.github.io/) che per [Nim](https://plugins.jetbrains.com/plugin/15128-nim) esistono dei plugin per IntelliJ IDEA, l'IDE Java di JetBrains. Per Rust, potete usare CLion con il plugin [Rust](https://plugins.jetbrains.com/plugin/8182-rust/docs).

# Suggerimenti per Java/Kotlin

# Suggerimenti

-   Creare un'applicazione Java oppure Kotlin in [IntelliJ IDEA](https://www.jetbrains.com/idea/):

    -   Se usate Kotlin, come *Build system* scegliete «Gradle Kotlin»
    
    -   Come JDK, se non ne avete di installati scegliete il numero (versione) 17
    
    -   Usate «Console application» come template
    
-   L'applicazione vuota stampa `Hello World!`: come prima cosa, cambiate il messaggio in `Hello, wold!`.

-   Per usare Git, meglio fare affidamento al menu «VCS» di IntelliJ (gestisce automaticamente i `.gitignore`).

---

<center>
![](./media/intellij_new_kotlin_project.png)
</center>

# Compilare ed eseguire

-   La directory che contiene il progetto ha un eseguibile, `gradlew`, che può essere usato per produrre una *distribution* nella directory `./build/distributions`:

    ```
    gradlew assembleDist
    ```

-   Siccome è una funzione molto utile, esploratela! Create una distribuzione del vostro programma e cercate di capire come installarla e usarla.

# Suggerimenti

-   In Java e in Kotlin si fa grande affidamento sull'ambiente di sviluppo (IDE). Imparate a conoscere bene IntelliJ IDEA!

-   Abituatevi a invocare regolarmente il comando «Code | Reformat code» (Ctrl+Alt+L).
