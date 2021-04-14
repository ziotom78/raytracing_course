---
title: "Esercitazione 6"
subtitle: "Calcolo numerico per la generazione di immagini fotorealistiche"
author: "Maurizio Tomasi <maurizio.tomasi@unimi.it>"
...

# Numeri di versione

# Scopo dei numeri di versione

-   Ogni programma dovrebbe avere un **numero di versione** associato, che dice quanto sia aggiornato un programma.
-   Un utente può confrontare un numero di versione sul sito ufficiale del programma con quello del programma installato sul proprio computer.
-   Molti diversi approcci ai numeri di versione.

# Esempio I: data di rilascio

-   Ubuntu Linux: distribuzione Linux.
-   Il numero di versione è la data di rilascio nella forma `anno.mese`, a cui si associa un soprannome come «Focal fossa» (20.04).
-   Associato a un rigido calendario di rilascio (ogni 6 mesi).
-   Gli standard ISO del C++ seguono uno schema simile, usando solo l'anno: C++11, C++14, C++17, C++20, …
-   Utile soprattutto se si segue un calendario rigido e regolare.

# Esempio II: numero irrazionale

-   TeX: programma di tipografia digitale creato da Donald Knuth (per digitare *The art of computer programming*, 1962–2019).
-   La versione è l'arrotondamento del valore di $\pi$, dove ogni versione successiva aggiunge una cifra:

    -   3
    -   3.1
    -   3.14
    -   3.141…

-   METAFONT, il programma che gestisce i font di TeX, usa $e = 2.71828\ldots$
-   Matematicamente affascinante, ma poco pratico!

# Esempio III: versioni pari/dispari

-   Versioni indicate con `X.Y`, dove `X` è la «major version» e `Y` la «minor version».
-   Se `Y` è pari, la versione è **stabile** (es., `2.0`, `2.2`, `2.4`, …); altrimenti è una versione di **sviluppo** (es., `2.1`, `2.3`, `2.5` …), non pronta per essere usata dal pubblico generico ma solo dagli utenti più smaliziati.
-   [Nim](https://nim-lang.org/), [Gtk+](https://www.gtk.org/), [GNOME](https://www.gnome.org/), [Lilypond](http://lilypond.org/) seguono questo approccio.
-   Molto usato in passato, ora tende ad essere abbandonato.

# Esempio IV: *semantic versioning*

-   Lo schema che useremo nel corso è il cosiddetto [*semantic versioning*](https://semver.org/), usato ad esempio da Julia e Python, che usa lo schema `X.Y.Z`:
    -   `X` è la «major version»
    -   `Y` è la «minor version»
    -   `Z` è la «patch version»
-   Le regole per assegnare valori a `X`, `Y` e `Z` sono rigide, e consentono agli utenti di decidere se valga la pena aggiornare un software o no.

# Semantic versioning (1/2)

-   Si parte dalla versione `0.1.0`.
-   Ad ogni rilascio di una nuova versione, si segue una di queste regole:
    -   Si incrementa `Z` («patch number») se si sono solo corretti dei bug;
    -   Si incrementa `Y` («minor number») e si resetta `Z` se si sono aggiunte funzionalità nuove;
    -   Si incrementa `X` («major number») e si resettano `Y` e `Z` se si sono aggiunte funzionalità che rendono il programma **incompatibile** con l'ultima versione rilasciata.

# Semantic versioning (2/2)

-   Nelle prime fasi di vita di un progetto, si rilasciano rapidamente nuove versioni che sono usate da «beta testers»; non è importante indicare quando si introducono incompatibilità, perché queste sono frequenti ma gli utenti sono ancora pochi.
-   La versione `1.0.0` va rilasciata quando il programma è pronto per essere usato da utenti generici.
-   Di conseguenza, le versioni precedenti alla `1.0.0` seguono regole diverse:
    -   Si incrementa `Z` se si correggono bug;
    -   Si incrementa `Y` e si resetta `Z` in tutti gli altri casi.

# Esempio (1/2)

-   Abbiamo scritto un programma che stampa `Hello, world!`:

    ```
    $ ./hello
    Hello, wold!
    ```

-   La prima versione che rilasciamo è la `0.1.0`
-   Ci accorgiamo che il programma stampa `Hello, wold!`, così correggiamo il problema e rilasciamo la versione `0.1.1` (correzione di un bug).

# Esempio (2/2)

-   Aggiungiamo una nuova funzionalità: se si passa un nome come
    `Paperino` da riga di comando, il programma stampa
    `Hello, Paperino!`. Senza argomenti, il programma scrive ancora
    `Hello, world!`:

    ```
    $ ./hello Paperino
    Hello, Paperino!

    $ ./hello
    Hello, world!
    ```

-   Abbiamo aggiunto una funzionalità ma abbiamo preservato la
    compatibilità (senza argomenti, il programma funziona ugualmente
    come la versione `0.1.1`), quindi la nuova versione sarà la
    `0.2.0`.

# Punto di vista di un utente

1.  Se viene rilasciata una nuova «patch release» della versione che
    si sta usando (es., `1.3.4` → `1.3.5`), l'utente dovrebbe **sempre**
    aggiornare.
2.  Se viene rilasciata una nuova «minor release» della versione che
    si sta usando (es., `1.3.4` → `1.4.0`), l'utente dovrebbe aggiornare
    solo se ritiene utili le nuove caratteristiche.
3.  Una nuova «major release» (es., `1.3.4` → `2.0.0`) dovrebbe essere
    installata solo da nuovi utenti, o da chi è intenzionato ad
    aggiornare il modo in cui si usa il programma.

# Il nostro programma

-   Con l'aggiunta delle funzionalità di settimana scorsa, siamo pronti per rilasciare la prima versione del nostro programma!

-   Al momento il programma converte un file PFM in un file LDR (PNG, JPEG, etc.)

-   Rilasceremo quindi la versione 0.1.0.

-   GitHub permette di rilasciare versioni tramite una specifica funzionalità.

---

<center>
![](./media/github-release-1.png){height=720px}
</center>

---

<center>
![](./media/github-release-2.png){height=720px}
</center>

---

<center>
![](./media/github-release-3.png){height=720px}
</center>

# Pull requests

# Come funziona Git

-   Stiamo usando Git da alcune settimane, e dovremmo aver imparato come funziona.

-   Abbiamo visto in particolare che Git salva ogni modifica del codice (il *commit*) legandola alla modifica precedente:

    <center>
    ![](./media/git-commit.svg)
    </center>
    
-   Oggi vedremo che questa struttura lineare può in realtà essere più complicata.

# Modifiche complesse

-   Nelle scorse lezioni abbiamo implementato il codice per leggere e scrivere file PFM.

-   Ciascuno dei gruppi ha implementato questa funzionalità tramite una serie di commit.

-   Questi commit erano *logicamente* legati tra loro, ma ciò non appare quando si apre la pagina dei commit di uno qualsiasi dei vostri repository (v. slide seguente).

---

<center>
![](./media/pfm-commits.png)
</center>

# Branch

-   Git implementa il concetto di *branch* («ramo»), che è un modo di separare una sequenza di commit dal «tronco» principale del *master*:

    <center>
    ![](./media/git-branch.svg)
    </center>
    
-   Tramite il comando `git branch NOME` si cambia il branch attivo; `git commit` aggiunge sempre in coda a questo branch.

-   `HEAD` punta sempre all'ultimo commit del branch attivo.

# Esempio di branch

<asciinema-player src="cast/git-branch-84x25.cast" cols="84" rows="25" font-size="medium"></asciinema-player>

# Comandi per branch

-   `git branch` elenca i branch (di default, all'inizio c'è solo `master`).

-   `git checkout -b NOME` crea un nuovo branch e lo rende attivo.

-   `git checkout -b NOME` rende attivo un branch già esistente.

-   `git merge NOME1 NOME2` incorpora le modifiche al branch `NOME1` dentro il branch `NOME2`; di solito `NOME2` è `master`.

-   `git branch -d NOME` cancella un branch.

-   Quando eseguite `git fetch` o `git pull` per scaricare nuovi commit da GitHub, vengono importati tutti i branch.

# Branch in GitHub

-   GitHub permette di navigare all'interno dei branch tramite un bottone dedicato:

    <center>
    ![](./media/github-branches-list.png){height=440px}
    </center>
    
-   La vera potenza dei branch sta però nei *pull request*.

# Pull request in GitHub

-   Un *pull request* è una richiesta di eseguire un comando `git merge` all'interno di `master`.

-   GitHub attiva un forum per ogni pull request, in modo che gli sviluppatori possano commentare l'opportunità o meno di eseguire `git merge`.

-   Nel momento in cui si fa il *merging*, è possibile (e consigliato) applicare lo *squashing*, che consiste nel fondere insieme tutti i commit in uno solo.

-   Lo *squashing* è utilissimo per levare di mezzo i tanti commit con messaggi «*Small fixes*», «*Oops I forgot to add this*», etc.

# Esempio di Pull request

<iframe src="https://player.vimeo.com/video/535144283?badge=0&amp;autopause=0&amp;player_id=0&amp;app_id=58479" width="1440" height="622" frameborder="0" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen title="How to create pull requests in GitHub"></iframe>

# Altro esempio

<center>
![](./media/github-pull-request-healpix.png)
</center>

# Come usarli in pratica

-   Se uno di voi crea un pull request su GitHub, gli altri possono aggiungere commit a quel pull request con i comandi

    ```text
    git fetch
    git checkout NOME_PULL_REQUEST
    ```
    
    come se fosse un branch creato da loro stessi (`git fetch` scarica da GitHub tutti i nuovi branch, inclusi i pull request).

-   I pull request sono una delle caratteristiche fondamentali di GitHub!

-   Abituatevi ad usarli per ogni modifica «seria» del vostro codice (no, correggere un errore grammaticale nel `README.md` non rientra nella casistica).

# Link a Gather

Useremo il solito link: [gather.town/app/CgOtJvyNfVKMIQ9e/LaboratorioRayTracing](https://gather.town/app/CgOtJvyNfVKMIQ9e/LaboratorioRayTracing)

# Guida per l'esercitazione

# Guida per l'esercitazione

-   Iniziate col «rilasciare» la *release* 0.1.0 di quanto avete scritto sinora.

-   Uno di voi crei un nuovo pull request chiamato `geometry`, e gli altri invochino `git fetch` seguito da `git checkout geometry`.

-   Fate tutto il lavoro previsto per oggi e per la settimana prossima nel branch `geometry`.

-   Implementate questi tipi:

    #.  `Vec` (un vettore tridimensionale), che rappresenterà anche le normali.
    #.  `Point` (un punto tridimensionale).
    
# Metodi per `Vec`

#. Conversione a stringa, es., `Vec(x=0.4, y=1.3, z=0.7)`;
#. Confronto tra vettori (per i test), usando funzioni come `are_close`;
#. Somma tra vettori;
#. Differenza di vettori;
#. Prodotto per uno scalare;
#. Prodotto scalare tra due vettori;
#. Prodotto vettoriale;
#. Calcolo di $\left\|v\right\|^2$ (`squared_norm`) e di $\left\|v\right\|$ (`norm`);
#. Funzione che normalizza il vettore: $v \rightarrow v / \left\|v\right\|$.

# Metodi per `Point`

#. Conversione a stringa, es., `Point(x=0.4, y=1.3, z=0.7)`;
#. Confronto tra punti (per i test);
#. Somma tra `Point` e `Vec`, restituendo un `Point`;
#. Differenza tra due `Point`, restituendo un `Vec`;
#. Differenza tra `Point` e `Vec`, restituendo un `Point`;

# Implementazione Python

-   L'implementazione Python nel repository [pytracer](https://github.com/ziotom78/pytracer) mostra come implementare `Point` e `Vec`.

-   Attenzione però: Python è un linguaggio *dinamico*, e permette di fare cose che non sono direttamente traducibili in altri linguaggi.

-   Questo è evidente nell'implementazione di metodi che sono molto simili tra `Point` e `Vec`, come la somma di due elementi:

    #. `Point` + `Vec` → `Point`;
    #. `Vec` + `Vec` → `Vec`.

# Implementazione Python

```python
def _are_xyz_close(a, b):
    # This works thanks to Python's duck typing. In C++ and other languages
    # you should probably rely on function templates or something like
    return are_close(a.x, b.x) and are_close(a.y, b.y) and are_close(a.z, b.z)

def _add_xyz(a, b, return_type):
    # Ditto
    return return_type(a.x + b.x, a.y + b.y, a.z + b.z)

def _sub_xyz(a, b, return_type):
    # Ditto
    return return_type(a.x - b.x, a.y - b.y, a.z - b.z)
```

# Implementazione Python

```python
@dataclass
class Vec:
    x: float = 0.0
    y: float = 0.0
    z: float = 0.0

    def is_close(self, other):
        assert isinstance(other, Vec)
        return _are_xyz_close(self, other)

    def __add__(self, other):
        return _add_xyz(self, other, Vec)

    def __sub__(self, other):
        return _sub_xyz(self, other, Vec)
```

# Altre operazioni su `Vec`

```python
def dot(self, other):
    return self.x * other.x + self.y * other.y + self.z * other.z

def squared_norm(self):
    return self.x ** 2 + self.y ** 2 + self.z ** 2

def norm(self):
    return math.sqrt(self.squared_norm())

def cross(self, other):
    return Vec(x=self.y * other.z - self.z * other.y,
               y=self.z * other.x - self.x * other.z,
               z=self.x * other.y - self.y * other.x)

def normalize(self):
    norm = self.norm()
    x /= norm
    y /= norm
    z /= norm
```

# Test

-   Il set completo di test si trova nel repository [pytracer](https://github.com/ziotom78/pytracer), nel file [test_all.py](https://github.com/ziotom78/pytracer/blob/41878248890338e62aa38c928c17561490c901b6/test_all.py#L202-L232).

-   Implementate gli stessi test presenti in quel file.

# Lavoro di gruppo

#. Uno di voi crea la *release* 0.1.0;
#. Uno di voi crea un branch `geometry` e fa un *pull request*, che gli altri scaricano;
#. Uno di voi implementa il tipo `Vec` (senza metodi o operatori!);
#. Uno di voi implementa il tipo `Point` (idem);
#. Sincronizzatevi tra voi facendo un *merge*;
#. Dividetevi l'implementazione dei vari metodi ed operatori.

# Indicazioni per C++

# Definizione dei tipi

-   È importante che `Vec` e `Point` siano efficientissimi!
-   Non preoccupatevi di definire classi con metodi `GetX`/`SetX` e compagnia: definite i tipi `Vec` e `Point` come delle semplici `struct`, oppure `class` con membri `x`, `y`, `z` pubblici.
-   Preoccupatevi di implementare sia costruttori di copia che *move constructor*.
-   Definite la maggior parte delle funzioni come `inline` (ossia, dichiarandole all'interno della classe nel file `.h`).

# Modo sconsigliato

```c++
class Vec {
    // These are "private" members (the default visibility in "class")
    float x, y, z;  // You can use "double", if you wish
    
public:
    Vec(float _x = 0, float _y = 0, float _z = 0) : x{_x}, y{_y}, z{_z} {}
    Vec(const Vec &); // Copy constructor
    Vec(const Vec &&); // Move constructor
    
    float getx() const { return x; }
    void setx(float _x) { x = _x; }
    // Etc.
};
```

# Modo consigliato

```c++
struct Vec {  // With "struct", everything is "public" by default
    float x, y, z;  // You can use "double", if you wish
    
    Vec(float _x = 0, float _y = 0, float _z = 0) : x{_x}, y{_y}, z{_z} {}
    Vec(const Vec &); // Copy constructor
    Vec(const Vec &&); // Move constructor

    // No need to define "getx", "setx", etc.
};
```

# Evitare ripetizioni

-   Potete usare i template C++ per evitare di ridefinire più volte alcune funzionalità comuni tra `Point` e `Vec`.

-   Questo è l'esempio della somma tra due elementi:

    ```c++
    template <typename In1, typename In2, typename Out>
    Out _sum(const In1 &a, const In2 &b) {
      return Out{a.x + b.x, a.y + b.y, a.z + b.z};
    }

    Point operator+(const Point &a, const Vec &b) {
      return _sum<Point, Vec, Point>(a, b);
    }

    Vec operator+(const Vec &a, const Vec &b) {
      return _sum<Vec, Vec, Vec>(a, b);
    }
    ```

# Indicazioni per C\#

# Definizione dei tipi

-   Siccome `Vec` e `Point` saranno molto utilizzati nei calcoli, è importante che siano classi estremamente efficienti.
-   Questo è quindi un caso in cui è meglio definire i tipi come *value types* usando `struct` anziché `class`.
-   Purtroppo C\# non implementa un meccanismo simile a quello dei `template` del C++, quindi dovrete definire due volte le operazioni comuni tra `Point` e `Vec`, come la somma.

# Indicazioni per Julia

# Definizione dei tipi

-   Per definire i tipi `Vec` e `Point` potreste usare la libreria [StaticArrays.jl](https://github.com/JuliaArrays/StaticArrays.jl), che implementa array di dimensione fissata molto efficienti. È una libreria molto efficiente, ma **non vi consiglio di usarla in questo caso**.
-   Il problema di StaticArrays.jl è che non permette di implementare il multiple dispatch: `Vec` e `Point` sarebbero visti da Julia come lo stesso tipo `SVector{3, Float32}`.
-   Meglio definire due nuovi tipi con `struct`
-   Vi consiglio di omettere `mutable`: incoraggerete Julia a usarli come *value types* anziché *reference types*.

# Indicazioni per Kotlin

-   Nessuna indicazione in particolare: l'implementazione di `Point` e `Vec` dovrebbe essere abbastanza semplice.
-   Come il C\#, neppure Kotlin supporta la metaprogrammazione (il caso di `template` in C++), quindi dovrete duplicare un po' di funzioni, come quelle che calcolano `Point + Vec` e `Vec + Vec`.
