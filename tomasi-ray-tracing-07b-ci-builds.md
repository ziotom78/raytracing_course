---
title: "Esercitazione 7"
subtitle: "Calcolo numerico per la generazione di immagini fotorealistiche"
author: "Maurizio Tomasi <maurizio.tomasi@unimi.it>"
...

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

-   Per attivare un CI build è sufficiente create una directory nascosta `.github/workflows` nel proprio repository, che contenga un file di testo in formato [YAML](https://en.wikipedia.org/wiki/YAML), che contenga .

-   GitHub Actions ha un «marketplace» che consente di configurare automaticamente con pochi click del mouse un CI build in funzione del linguaggio che usate.

---

<center>
![](./media/github-action-run-tests.png){height=720px}
</center>

---

<center>
![](./media/github-action-run-tests-detail.png){height=720px}
</center>

# Matrici



# Workflow in GitHub

-   Aggiungete un *workflow* al vostro repository GitHub

-   Ci sono molti template disponibili in GitHub: scegliete il più appropriato

-   Il workflow deve eseguire le seguenti azioni:

    1.  Scaricare il codice dal repository GitHub (verifica che non manchino file)
    2.  Compilare il codice (verifica che non ci siano errori di sintassi)
    3.  Eseguire i test (verifica che il codice funzioni a dovere)

-   Modificate un test in modo che fallisca e verificate che quando fate il commit ciò vi venga segnalato. (Poi rimettete a posto il test).

# Indicazioni per il C++

# GitHub Actions

-   Una volta salvato il codice in un repository su GitHub, configurate una nuova «Action» (v. video seguente).

-   Il modello è «CMake based projects» (ignorate il fatto che sembri supportare solo il linguaggio C):

    <center>
    ![](./media/cmake-github-action.png)
    </center>
    
---

<iframe src="https://player.vimeo.com/video/520878087?badge=0&amp;autopause=0&amp;player_id=0&amp;app_id=58479" width="1280" height="720" frameborder="0" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen title="Setting up GitHub Actions for CMake-based projects"></iframe>

# Esecuzione dei test

-   Provate a modificare uno dei test sul tipo `HdrImage`, in modo che fallisca:

    -   Cambiate il file `test/hdrimage.cpp`
    -   Andate nella directory `build` ed eseguite `ctest`
    -   Fate il commit delle modifiche
    -   Inviate le modifiche a GitHub col comando `git push`

 -  Cosa succede al *CI build*? Fallisce come vi aspettavate?

# Suggerimenti

-   Se il build **non** fallisce, è probabilmente perché viene usato come tipo di build il `Release` anziché il `Debug`, e avete usato `assert` nel vostro codice
-   Soluzioni:
    -   Cambiate il file `.yml` in modo da usare `Debug` anziché `Release`
    -   Usate `#undef NDEBUG` prima di `#include <cassert>` (meglio!)
    -   Definite una vostra funzione `my_assert` (ancora meglio!)
    -   Usate una libreria di testing C++, come [Catch2](https://github.com/catchorg/Catch2/tree/v2.x) (ottimo!)
-   Insegnamento: provare **sempre** a far fallire uno o più test quando si configura un *CI build*!

# Indicazioni per C\#

# GitHub Actions

-   Aggiungete una Action al repository GitHub, una volta che avete fatto il commit ed eseguito `git push`.

-   Il modello è «.NET» (evitate il modello «.NET desktop», a noi serve quello per i programmi che funzionano da linea di comando):

    <center>
    ![](./media/dotnet-github-action.png)
    </center>

# Indicazioni per Julia

# GitHub Actions

-   A differenza del C++ e del C\#, Julia non ha una action preconfigurata nel sito.
-   Ma GitHub gestisce un «marketplace», e il team Julia l'ha usato per fornire alla comunità una [serie di actions](https://github.com/julia-actions).
-   Le azioni che servono sono le seguenti:
    - `julia-actions/setup-julia@v1` (installa Julia);
    - `actions/cache@v1` (evita di reinstallare pacchetti Julia ogni volta)
    - `julia-actions/julia-buildpkg@latest` (compila il package)
    - `julia-actions/julia-runtest@latest` (esegue i test)


# File `UnitTests.yml`

```yaml
name: Unit tests

on:
  push:
    branches:
      - master

jobs:
  test:
    name: Julia ${{ matrix.julia-version }} - ${{ matrix.os }} - ${{ matrix.arch }}
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        julia-version:
          - '1.5'
        os:
          - ubuntu-latest
        arch:
          - x64

    steps:
      - uses: actions/checkout@v2

      - name: "Set up Julia"
        uses: julia-actions/setup-julia@v1
        with:
          version: ${{ matrix.julia-version }}
          arch: ${{ matrix.arch }}

      - name: "Cache artifacts"
        uses: actions/cache@v1
        env:
          cache-name: cache-artifacts
        with:
          path: ~/.julia/artifacts
          key: ${{ runner.os }}-test-${{ env.cache-name }}-${{ hashFiles('**/Project.toml') }}
          restore-keys: |
            ${{ runner.os }}-test-${{ env.cache-name }}-
            ${{ runner.os }}-test-
            ${{ runner.os }}-

      - name: "Build package"
        uses: julia-actions/julia-buildpkg@latest

      - name: "Run unit tests"
        uses: julia-actions/julia-runtest@latest
```

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
