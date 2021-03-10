---
title: "Esercitazione 4"
subtitle: "Calcolo numerico per la generazione di immagini fotorealistiche"
author: "Maurizio Tomasi <maurizio.tomasi@unimi.it>"
...

# Implementazione di `Vec2` e `Vec3`


# Continuous Integration (CI)

# Cosa significa CI?

-   *Continuous Integration* (CI) è la pratica di fare spesso commit sul server Git (nel nostro caso, il sito GitHub).

-   Fare spesso commit è il modo migliore per obbligarsi a stare sincronizzati col lavoro di altri.

-   Questo però crea potenziali problemi: cosa succede se le mie modifiche interferiscono con quelle di un altro?

-   I test automatici possono venirci in soccorso, ma **occorre ricordarsi di eseguirli sempre**!

# Build automatici

-   Per mettere in pratica la CI è necessario che il computer sappia eseguire i test automatici da solo.

-   La pratica della *continuous integration* richiede quindi che il computer sia istruito perché compili il codice ed esegua i test automatici ogni volta che fa un commit.

# Potenziali problemi

-   È sufficiente che un test fatto girare sul **mio** computer abbia successo?

-   **No**! Il mio computer potrebbe avere delle librerie installate che il codice usa, ma che su altri computer non sono (ancora) state installate

-   Perché un test sia rappresentativo, deve essere eseguito su una macchina «vergine» (ossia, su cui sia installato solo il sistema operativo di base).

# CI builds

-   Un *CI build* è un processo che esegue i test su una macchina virtuale creata appositamente, che viene cancellata subito dopo.

-   L'esito del test può essere segnalato tramite email, oppure tramite un'icona sulla pagina del repository in GitHub

-   GitHub implementa le «Actions», che altro non sono che *CI builds*

# Workflow

1.  Crea una nuova macchina virtuale (solitamente nel Cloud) e installa una versione di Linux/Mac OS X/Windows;
2.  Scarica le librerie e i programmi necessari alla compilazione (es., Julia);
3.  Scarica da un repository Git (es., una pagina GitHub) il codice che deve essere verificato;
4.  Compila il codice;
5.  Esegue i test automatici;
6.  Se necessario, avvisa l'utente di malfunzionamenti.

# GitHub Actions

-   Il sito GitHub non offre solo l'*hosting* di repository Git, ma anche l'esecuzione di *CI builds*.
-   Questi builds sono chiamate «Actions».
-   Il punto di forza di GitHub è che esistono librerie di «actions», ossia template che permettono velocemente di configurare *CI builds*.
-   Vedremo un esempio pratico più tardi, nel caso del C++.

# Guida per l'esercitazione

# Guida per l'esercitazione

1.  Implementare i tipi `Vec2` e `Vec3`, con i consueti test

2.  Configurare una «action» che esegua i test automatici

3.  Verificare che i test vengano eseguiti facendo un commit, e che i test falliscano modificando un test apposta.

# Test (1)

-   Somma/differenza di vettori 3D:

# Test (2)

# Test (3)

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

-   Provate a modificare uno dei test sul tipo `Vec3`, in modo che fallisca:

    -   Cambiate il file `test/vec3.cpp`
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
