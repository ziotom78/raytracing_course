---
title: "Esercitazione 6"
subtitle: "Calcolo numerico per la generazione di immagini fotorealistiche"
author: "Maurizio Tomasi <maurizio.tomasi@unimi.it>"
...

# Conferenze LCM

-   Quest'anno il Laboratorio Calcolo e Multimedia ripropone le conferenze OpenLab su temi informatici, in presenza ed online ([aula X](https://zoom.us/my/aula.x))

-   L'elenco degli incontri è disponibile al sito [https://lcm.mi.infn.it/](https://lcm.mi.infn.it/)

-   Oggi pomeriggio (ore 16) è prevista la conferenza *Strumenti avanzati per progetti in Python* (Gabriele Bozzola)

# CI builds

# CI builds

-   Nel momento in cui si gestiscono *pull request*, è necessario essere sicuri che la modifica non peggiori il codice.

-   Un requisito basilare è che tutti i test continuino a passare una volta che viene incorporato il *pull request*.

-   GitHub consente di verificare automaticamente questo requisito, tramite i *Continuous Integration builds*.

# Continuous Integration (CI)

-   È un termine che indica un metodo di lavoro in cui miglioramenti e modifiche al codice vengono incorporate il prima possibile nel branch `master`.

-   Perché possano essere incorporati, occorre essere certi della loro qualità!

-   Un CI build consiste nel creare una macchina virtuale su cui si installa un sistema operativo «pulito» e su cui si installa il codice, lo si compila e si eseguono i test.

-   Al termine dell'esecuzione dei test, la macchina virtuale viene cancellata; se si esegue di nuovo il CI build, si ricomincia da capo.

# Vantaggi dei CI build

-   Installano il codice su una macchina virtuale: più difficile combinare guai.

-   La macchina virtuale viene creata sempre da zero: più facile scoprire quali sono le dipendenze del codice. (Esempio: è stata installato il compilatore C++? È stata installata la libreria `libgd`?)

-   Si possono creare macchine virtuali che installano diversi sistemi operativi (Linux, Windows, Mac OS X, FreeBSD, etc.): il codice viene verificato su ciascuna di esse.

-   I CI builds possono venire eseguiti automaticamente da GitHub ogni volta che si apre un pull request, ogni volta che si fa un commit, etc.

# CI builds in GitHub

-   Un CI build può essere creato ed eseguito in GitHub tramite [GitHub Actions](https://docs.github.com/en/actions), un servizio che include una serie di possibilità che vanno oltre i semplici CI build.

-   Per attivare un CI build è sufficiente create una directory nascosta `.github/workflows` nel proprio repository, che contenga un file di testo in formato [YAML](https://en.wikipedia.org/wiki/YAML), che contenga queste informazioni:

    #.   Quando eseguire l'azione (a ogni pull request? a ogni commit?)
    #.   Quale sistema operativo usare (Linux? Windows? quale versione?)
    #.   Quali pacchetti aggiuntivi installare (compilatore C++? Python?)
    #.   Come compilare il codice ed eseguire i test?

# Il «Marketplace»

-   GitHub Actions ha un «marketplace» che consente di configurare automaticamente con pochi click del mouse un CI build in funzione del linguaggio che usate.

-   Sono disponibili azioni pre-configurate per molti linguaggi ed ambienti di sviluppo.

-   Non è drammatico se non trovate un'azione che fa al caso vostro: è abbastanza semplice creare nuove azioni su misura, una volta che capite come fare a descriverle.

---

<center>
![](./media/github-action-run-tests.png){height=720px}
</center>

---

<center>
![](./media/github-action-run-tests-detail.png){height=720px}
</center>


# Guida per l'esercitazione


# Workflow in GitHub

-   Aggiungete un *workflow* al vostro repository GitHub.

-   Ci sono molti template disponibili in GitHub: scegliete il più appropriato.

-   Il workflow deve eseguire le seguenti azioni:

    1.  Scaricare il codice dal repository GitHub (verifica che non manchino file);
    2.  Compilare il codice (verifica che non ci siano errori di sintassi);
    3.  Eseguire i test (verifica che il codice funzioni a dovere).

-   Modificate un test in modo che fallisca e verificate che quando fate il commit ciò vi venga segnalato. (Poi rimettete a posto il test).

# Indicazioni per C\#

# GitHub Actions

-   Aggiungete una Action al repository GitHub, una volta che avete fatto il commit ed eseguito `git push`.

-   Il modello è «.NET» (evitate il modello «.NET desktop», a noi serve quello per i programmi che funzionano da linea di comando):

    <center>
    ![](./media/dotnet-github-action.png)
    </center>

# Indicazioni per D/Nim/Rust

# GitHub Actions

-   Per D, potete usare [setup-dlang](https://github.com/dlang-community/setup-dlang)

-   Per Nim, esiste [Setup Nim Environment](https://github.com/marketplace/actions/setup-nim-environment)

-   Chi usa Rust ha già configurato una action, quindi tutto ok!

# Indicazioni per Kotlin

# GitHub Actions

-   Selezionate «Java with Gradle»:

    <center>
    ![](./media/gradle-github-action.png)
    </center>
    
    Gradle scaricherà automaticamente il supporto Kotlin.

-   Il processo proverà a compilare il codice e a eseguire *tutti* i test nel repository

# Risoluzione dei problemi

-   Ricordatevi di aggiungere al commit i file in `gradle/wrapper/`

-   Se avete problemi a causa della versione di Gradle, rigenerate `gradlew` da linea di comando così:

    ```sh
    gradle wrapper --gradle-version 5.3
    ```
    
    (Gradle supporta Kotlin a partire dalla versione 5.3).
