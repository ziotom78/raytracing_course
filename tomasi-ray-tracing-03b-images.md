---
title: "Esercitazione 3"
subtitle: "Calcolo numerico per la generazione di immagini fotorealistiche"
author: "Maurizio Tomasi <maurizio.tomasi@unimi.it>"
...


# Formati grafici

# Formati HDR e LDR

-   I formati HDR (High Dynamical Range) usano numeri floating-point per coprire ordini di grandezza diversi nelle componenti R, G, B:

    -   1.3
    -   6.4e-5
    -   8.3e+4

-   I formati LDR (Low Dynamical Range) usano numeri interi per le componenti R, G, B, di solito nell'intervallo 0–255:

    -   0, 1, 2…
    -   …253, 254, 255

# Differenza tra HDR e LDR

| HDR                       | LDR                       |
| ---                       | ---                       |
| OpenEXR, PFM              | JPEG, PNG, BMP, GIF, etc. |
| Grandi file               | Piccoli file              |
| Difficili da visualizzare | Facili da visualizzare    |
| Facili da creare          | Difficili da creare       |

# Formati richiesti nel corso

-   Non è richiesto usare librerie esterne

-   Implementeremo codice per scrivere le immagini nei formati PFM
    (HDR) e PNM (LDR)…

-   …ma darò indicazioni su come usare librerie esterne, per chi può/vuole

# I formati Netpbm

-   Netpbm è un pacchetto di svariati programmi per gestire file
    contenenti immagini

-   Definisce anche una serie di formati, molto semplici da leggere e
    da scrivere

    -   **PPM** (Portable PixMap): usa numeri interi per le componenti
        R, G, B

    -   **PFM** (Portable FloatMap): usa numeri floating-point per le
        componenti R, G, B (non ufficiale)

-   Svantaggio: pochi programmi sono in grado di leggere PPM sotto
    Windows (Adobe Photoshop, Gimp), pochissimi leggono PFM

# Il formato PFM

-   Nei file PFM si scrivono queste informazioni:

    -   `PF` seguito da un ritorno a capo `\n`

    -   `width height -1.0`, dove `width` è il numero di colonne e
        `height` il numero di righe dell'immagine (numeri interi),
        separati da uno spazio e seguiti da un ritorno a capo `\n` (il
        numero `-1.0` serve per indicare l'ordine dei byte nel resto
        del file);

    -   Una sequenza di numeri `float` a **32 bit** (sic!), contenenti
        i valori R, G, B (in quest'ordine) di tutti i pixel
        dell'immagine

# File PFM in Python

-   Useremo come riferimento un'immagine contenente un gradiente di
    colore:

-   Si può generare l'immagine in Python in questo modo:

    ```python
    width, height = 256, 256

    image = [[Color(i / width, 1.0 - j / height, 0.5) for i in range(width)]
             for j in range(height)]
    ```

# File PFM in Python

-   Dobbiamo convertire un numero floating-point (es., `1.3`) nella
    sua rappresentazione in byte (es., `66 66 3f a6`);

-   Python non supporta `float` a 32 bit, così dobbiamo usare la
    libreria NumPy:

    ```python
    import numpy as np

    def float32_bytes(x):
        "Encode a number into bytes representing a 32-bit floating point"

        return np.float32(x).tobytes()
    ```

# File PFM in Python

```python
def write_pfm(outf, width, height, image):
    "Save an image using PFM format into 'outf'"

    # Write the header
    outf.write(bytes(f"PF\n{width} {height} -1.0\n", encoding="utf-8"))

    # Note that rows are transversed in reverse order!
    for row in reversed(range(height)):
        for col in range(width):
            curpixel = image[row][col]

            outf.write(float32_bytes(curpixel.red))
            outf.write(float32_bytes(curpixel.green))
            outf.write(float32_bytes(curpixel.blue))
```

# Risultato

-   Se avete installato
    [ImageMagick](https://imagemagick.org/index.php) (consigliato!),
    potete visualizzare l'immagine col comando `display image.pfm`:

    <center>
    ![](./media/imagemagick-pfm-display.png)
    </center>

-   In Ubuntu, installate ImageMagick con
    `apt install imagemagick`.

# Il formato PNM

# `libgd`

-   Libreria C molto diffusa: su sistemi Ubuntu si può installare con

    ```
    sudo apt install libgd-dev
    ```

-   Supporta il salvataggio di immagini in formato PNG e Jpeg

-   Supporta `pkg-config`:

    ```
    gcc -o main main.c $(pkg-config --cflags --libs gdlib)
    ```

# Creare immagini con `libgd`

```c
#include "gd.h"     /* The library's header file */
#include <stdio.h>

int main() {
  const int width = 256, height = 256;
  gdImagePtr im;
  FILE *f;
  int row, col;

  im = gdImageCreateTrueColor(width, height);

  for(row = 0; row < height; ++row) {
    for(col = 0; col < width; ++col) {
      int red, green, blue = 128;

      red = (int) (col * 255.0 / width);
      green = (int) ((1.0 - row * 1.0 / height) * 255.0);
      gdImageSetPixel(im, col, row, gdImageColorExact(im, red, green, blue));
    }
  }

  f = fopen("image.png", "wb");

  /* Output the image to the disk file in PNG format. */
  gdImagePng(im, f);  /* gdImageJpeg(im, jpegout, -1); */

  fclose(f);
  gdImageDestroy(im);
}
```

# Confronto tra PNG e PFM

-   Il formato PFM contiene molta più informazione del formato PNG
    (numeri floating-point anziché interi per le componenti R, G, B)

-   Il formato PNG implementa un compressore molto efficiente!
    Contiamo il numero di byte scritti nelle immagini del nostro
    gradiente:

    ```
    $ wc -c image.pfm image.png
    786448 image.pfm
       780 image.png
    787228 total
    $
    ```

    Il file PNG è 1000 volte più piccolo!

# Uso di `libgd` da altri linguaggi

-   È probabile che `libgd` sia già disponibile anche per il vostro
    linguaggio

-   Le uniche funzioni che vi servono sono le seguenti:

    -   `gdImageCreateTrueColor`
    -   `gdImageColorExact`
    -   `gdImageSetPixel`
    -   `gdImageGetPixel`
    -   `gdImagePng` e/o `gdImageJpeg`


# Numeri di versione

# Scopo dei numeri di versione

-   Ogni programma dovrebbe avere un **numero di versione** associato
-   Esso dice quanto sia aggiornato un programma
-   Un utente può confrontare un numero di versione sul sito ufficiale
    del programma con quello del programma installato sul proprio
    computer
-   Molti diversi approcci ai numeri di versione

# Esempio I: data di rilascio

-   Ubuntu Linux: distribuzione Linux
-   Il numero di versione è la data di rilascio nella forma `anno.mese`, a
    cui si associa un soprannome come «Focal fossa» (20.04)
-   Associato a un rigido calendario di rilascio (ogni 6 mesi)
-   Gli standard ISO del C++ seguono uno schema simile, usando solo
    l'anno: C++11, C++14, C++17, C++20, …
-   Utile soprattutto se si segue un calendario rigido e regolare

# Esempio II: numero irrazionale

-   TeX: programma di tipografia digitale creato da Donald Knuth (per
    digitare *The art of computer programming*, 1962-2019)
-   La versione è l'arrotondamento del valore di $\pi$, dove ogni
    versione successiva aggiunge una cifra:

    -   3
    -   3.1
    -   3.14
    -   3.141…

-   METAFONT, il programma che gestisce i font di TeX, usa $e = 2.71828\ldots$
-   Matematicamente affascinante, ma poco pratico

# Esempio III: versioni pari/dispari

-   Versioni indicate con `X.Y`, dove `X` è la «major version» e `Y`
    la «minor version»
-   Se `Y` è pari, la versione è **stabile**; altrimenti è una
    versione di **sviluppo**, non pronta per essere usata dal
    pubblico
-   [Nim](https://nim-lang.org/), [Gtk+](https://www.gtk.org/),
    [GNOME](https://www.gnome.org/), [Lilypond](http://lilypond.org/)
    seguono questo approccio
-   Molto usato in passato, ora tende ad essere abbandonato

# Esempio IV: *semantic versioning*

-   Lo schema che useremo nel corso è il cosiddetto [*semantic
    versioning*](https://semver.org/), usato ad esempio da Julia e
    Python, che usa lo schema `X.Y.Z`:
    -   `X` è la «major version»
    -   `Y` è la «minor version»
    -   `Z` è la «patch version»
-   Le regole per assegnare valori a `X`, `Y` e `Z` sono rigide, e
    consentono agli utenti di decidere se valga la pena aggiornare un
    software o no.

# Semantic versioning (1/2)

-   Si parte dalla versione `0.1.0`
-   Ad ogni rilascio di una nuova versione, si segue una di queste
    regole:
    -   Si incrementa `Z` («patch
        number») se si sono solo corretti dei bug
    -   Si incrementa `Y` («minor number») e si resetta `Z` se si sono
        aggiunte funzionalità nuove
    -   Si incrementa `X` («major number») e si resettano `Y` e `Z` se
        si sono aggiunte funzionalità che rendono il programma
        **incompatibile** con l'ultima versione rilasciata

# Semantic versioning (2/2)

-   Nelle prime fasi di vita di un progetto, si rilasciano rapidamente
    nuove versioni che sono usate da «beta testers»; non è importante
    indicare quando si introducono incompatibilità, perché gli utenti
    sono ancora pochi e selezionati
-   La versione `1.0.0` va rilasciata quando il programma è pronto per
    essere usato da utenti generici
-   Di conseguenza, le versioni precedenti alla `1.0.0` seguono regole
    diverse:
    -   Si incrementa `Z` se si correggono bug
    -   Si incrementa `Y` e si resetta `Z` in tutti gli altri casi

# Esempio (1/2)

-   Abbiamo scritto un programma che stampa `Hello, world!`:

    ```
    $ ./hello
    Hello, wold!
    ```

-   La prima versione che rilasciamo è la `0.1.0`
-   Ci accorgiamo che il programma stampa `Hello, wold!`, così
    seguiamo queste azioni:

    1.  Apriamo una *issue* su GitHub;
    2.  Correggiamo il problema e chiudiamo la issue;
    3.  Rilasciamo la versione `0.1.1` (correzione di un bug)

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
    aggiornare
2.  Se viene rilasciata una nuova «minor release» della versione che
    si sta usando (es., `1.3.4` → `1.4.0`), l'utente dovrebbe aggiornare
    solo se ritiene utili le nuove caratteristiche
3.  Una nuova «major release» (es., `1.3.4` → `2.0.0`) dovrebbe essere
    installata solo da nuovi utenti, o da chi è intenzionato ad
    aggiornare il modo in cui si usa il programma

# Esempio: Julia 1.0

-   È nato un caso interessante dopo il rilascio di Julia 1.0
-   Nelle versioni di sviluppo (0.1, 0.2, …, 0.7) era possibile
    scrivere questo codice al prompt di Julia:

    ```julia
    x = Int[1, 3, 2, 9]
    cumsum = 0
    for elem in x
        cumsum += elem    # Incrementa "cumsum"
    end
    ```

-   Nella versione 1.0 si è cambiata la regola di visibilità delle
    variabili: il codice sopra dà errore dentro il ciclo `for`, perché
    dalla versione 1.0 la variabile globale `cumsum` non è modificabile
    dentro un ciclo `for` eseguito nella REPL

# Esempio: Julia 1.0

-   La motivazione per la modifica è che Julia non richiede di
    dichiarare in anticipo le variabili, e modificare una variabile
    globale può essere molto inefficiente in Julia.

-   In Julia 0.7/1.0 è necessario scrivere questo:

    ```julia
    x = Int[1, 3, 2, 9]
    cumsum = 0
    for elem in x
        global cumsum     # Obbliga Julia a usare "cumsum" globale nel "for"
        cumsum += elem    # Incrementa "cumsum" correttamente in Julia 1.0
    end
    ```

-   Questo **non vale** all'interno delle funzioni, solo nella REPL!

# Esempio: Julia 1.0

-   Sebbene la modifica fosse stata annunciata in previsione del
    rilascio della versione 0.7/1.0, molti utenti sono rimasti stupiti
    da essa!
-   C'è stato un lungo dibattito nel forum di Julia:
    [qui](https://discourse.julialang.org/t/confused-about-global-vs-local-scoping-in-for-loops-in-1-0/16318/1),
    [qui](https://discourse.julialang.org/t/local-vs-global-scope-again/44227/1),
    [qui](https://discourse.julialang.org/t/documentation-on-for-loops-and-scoping-in-and-out-of-repl/21922),
    [qui](https://discourse.julialang.org/t/scope-and-global-in-repl-julia-0-7/10233),
    [qui](https://discourse.julialang.org/t/scope-of-variables-inside-functions-for-loops-and-if-statments/38981),
    [qui](https://discourse.julialang.org/t/another-possible-solution-to-the-global-scope-debacle/15894),
    [qui](https://discourse.julialang.org/t/global-scope-confusion-again/20044),
    [qui](https://discourse.julialang.org/t/remove-the-soft-scope-altogether-and-make-it-global/33333/1),
    [qui](https://discourse.julialang.org/t/repl-and-for-loops-scope-behavior-change/13514),
    [qui](https://discourse.julialang.org/t/explain-scoping-confusion-to-a-programming-beginner/43206),
    [qui](https://discourse.julialang.org/t/tips-to-cope-with-scoping-rules-of-top-level-for-loops-etc/24902),
    [qui](https://discourse.julialang.org/t/new-scope-solution/16707),
    [qui](https://discourse.julialang.org/t/why-not-an-even-harder-scope/50087),
    e dimentico sicuramente qualcosa!
-   In ognuna di queste discussioni, gli sviluppatori facevano notare
    che tanti dei cambiamenti suggeriti dagli utenti avrebbero
    obbligato a rilasciare Julia 2.0.0!

# Dopo Julia 1.0

-   Il funzionamento delle variabili globali in Julia non è stato cambiato, e la compatibilità è sempre stata preservata nelle versioni successive di Julia (1.1, 1.2, 1.3, 1.4, 1.5)
-   Questo vuol dire che **qualsiasi** programma scritto in Julia 1.0 può funzionare con le versioni successive del compilatore (nel senso che se non lo fa c'è un bug in Julia che va corretto)

# Documentazione


# Documentazione

# Importanza della documentazione

-   «Se una cosa non è documentata, non esiste!»
-   «Meglio avere un brutto programma documentato bene, che un buon programma documentato male!»

# Tipi di documentazione

-   Esistono vari tipi di documentazione:

    1.  README
    2.  CHANGELOG
    3.  LICENSE
    4.  Tutorial
    5.  Manuale d'uso
    6.  Documentazione delle funzioni fornite da una libreria

-   Oggi ci occuperemo solo dei primi tre

# Scopo del README

-   Primo documento in cui si imbatte un potenziale utente
-   Deve comunicare in maniera concisa questi concetti:
    1.  A cosa serve il programma
    2.  Cosa richiede per funzionare (Windows? Linux? una GPU? una
        stampante?)
    3.  Come si installa
    4.  Esempi pratici che mostrino cos'è in grado di fare il
        programma (possibilmente esempi ricchi e complessi!)
    5.  Licenza d'uso
-   Non deve addentrarsi troppo nei dettagli: più è conciso, meglio è

---

-   Cercate di essere *chiari* ma anche *sintetici*!
-   Esempio negativo (`boost.array`). L'introduzione inizia così:

    > The C++ Standard Template Library STL as part of the C++
    > Standard Library provides a framework for processing algorithms
    > on different kind of containers. However, ordinary arrays don't
    > provide the interface of STL containers (although, they provide
    > the iterator interface of STL containers).

    Un intero paragrafo, e ancora non si dice cosa faccia la libreria!
    (Non viene detto neppure nel paragrafo successivo…)

# Scopo di CHANGELOG

-   Elenca tutte le caratteristiche delle versioni di un codice

-   Ordine cronologico **inverso** (più recente in cima)

-   Esempio: file `CHANGELOG.md`

    ```markdown
    # Version 0.1.1
    
    -   Fix bug
    
    # Version 0.1.0
    
    -   First release
    ```

# Scopo di LICENSE

-   Riporta la licenza d'uso del software

-   Sembra burocratese, ma è **molto** importante!

-   Nessuna licenza: divieto d'uso del software

-   Molto usate licenze open-source:
    [MIT](https://opensource.org/licenses/MIT),
    [BSD](https://opensource.org/licenses/BSD-3-Clause),
    [GPL](https://opensource.org/licenses/gpl-license), etc.
    
-   Vedi il sito [Open Source Initiative](https://opensource.org/) per
    ulteriori dettagli

-   Per questo corso è importante che scegliate una licenza tra le tre
    elencate sopra (MIT/BSD/GPL). Se non avete idea di cosa scegliere,
    usate MIT.

# Markdown

-   Di solito i documenti README/CHANGELOG/LICENSE/… vengono scritti
    in Markdown (estensione `.md`)

-   Usando [pandoc](https://pandoc.org/), un file `.md` può essere
    convertito in:

    -   Pagine HTML (queste slide ne sono un esempio!)
    -   LaTeX (le dispense di questo corso, quando saranno disponibili)
    -   Presentazioni LaTeX Beamer
        ([ctan.org/pkg/beamer](https://ctan.org/pkg/beamer))
    -   File Microsoft Word
    -   Slide Microsoft PowerPoint
    -   Ebook in formato `.epub`
    -   Etc.


# Installazione di Pandoc

-   Pandoc (su sistemi Debian/Ubuntu/Mint):

    ```
    sudo apt install pandoc
    ```
    
-   TeX/LaTeX (idem):

    ```
    sudo apt install texlive-full
    ```

# Esempio di markdown

-   Testo in Markdown (`README.md`):

    ```markdown
    # Titolo

    Testo in *italico*, **grassetto**, `monospaced`. Lista:

    -   Primo

    -   Secondo
    ```

-   Convertibile in HTML con `pandoc -t html5 --standalone README.md`

# Titolo

Testo in *italico*, **grassetto**, `monospaced`. Lista:

-   Primo

-   Secondo

# Markdown → LaTeX:

-   Convertito con `pandoc -t latex README.md`

    ```latex
    \section{Titolo}

    Testo in \textit{italico}, \textbf{grassetto},
    \texttt{monospaced}. Lista:
    \begin{itemize}
    \item Primo
    \item Secondo
    \end{itemize}
    ```
    
-   Usando `--standalone` viene generato un documento LaTeX completo

-   Se si specifica come output un file con estensione `.pdf`, il file viene compilato automaticamente usando pdfLaTeX:

    ```
    pandoc -t latex -o README.pdf README.md
    ```

# Markdown → Word

-   Convertito con `pandoc -t docx -o README.docx README.md`

    ![](./media/pandoc-to-word.png){height=480}

# Markdown in GitHub

-   In GitHub non è necessario convertire il Markdown

-   Se si carica in un repository un file con nome `README.md`, GitHub
    lo mostrerà automaticamente convertito in una pagina HTML:
    
    ![](./media/harlequin-readme.png){height=400}

# Scopo del manuale d'uso

-   Un manuale d'uso deve illustrare in maniera analitica come usare
    ciascuna delle funzionalità del programma
-   Il manuale dovrebbe essere consultabile senza richiedere una
    lettura lineare: ogni capitolo dovrebbe essere il più possibile
    autonomo
-   Si può supporre che chi sta leggendo il manuale abbia già
    un'infarinatura del programma (magari perché ha fatto il tutorial
    tempo prima)
-   Analogia con la matematica: si definisce il campo reale e un
    polinomio generico $p(x) = \sum_{i=0}^n a_i x^i$, illustrandone le
    proprietà partendo dalla definizione generale

# Scopo del tutorial

-   Deve essere il primo documento che venga studiato seriamente da un
    utente interessato al programma
-   Si può iniziare descrivendo come si installa il programma, se
    questo non è già fatto nel README
-   Si deve partire da esempi semplici, e complicarli progressivamente
-   Analogia con la matematica: spiegazione dei polinomi iniziando dai
    più semplici di 1^ grado e, definendo somma e prodotto,
    introduzione di quelli di grado superiore

# Documentazione di funzioni

-   Valido per librerie di funzioni (es., ROOT,
    [fmt](https://github.com/fmtlib/fmt))
-   Documentazione di ciascuna funzione
-   Linguaggi con REPL (Julia, Python, …) implementano le *docstring*,
    accessibili dalla REPL:

    ```
    julia> ?sin
    sin(x)

    Compute sine of x, where x is in radians.
    ```
-   Non ha senso per programmi eseguibili

# Strumenti per documentazione

Python
: Sphinx

Julia
: Documenter

C, C++, C\#, D
: Doxygen (esempio: [Eigen](http://eigen.tuxfamily.org/dox/GettingStarted.html))

Free Pascal
: fpdoc

Rust
: mdbook

# Linguaggi di markup

-   Ogni strumento di documentazione usa convenzioni diverse
-   La maggior parte usa varianti di qualche linguaggio di markup:
    -   Markdown (Doxygen, Documenter, …)
    -   Restructured text (RST, usato nel mondo Python e in Nim)
-   Se potete, scegliete Markdown: è il linguaggio di markup più
    diffuso e anche il più semplice. RST è inutilmente complicato.


# Modalità di lavoro

1.   Estrazione di documentazione da file sorgente
2.   Costruzione di documentazione da file di testo

# Esempio: C++ e Doxygen

```c++
/** \brief Calculate the square root of a number
 *
 * Calculate the square root of number x. It uses a bisection formula
 * until the value \f$\left|result - x * x\right|\f$ is less than epsilon.
 *
 * \param x The number to use as input for the calculation
 * \param epsilon The required precision of the result
 * \return The square root, or -1.0 if x was negative
 */

double square_root(double x, double epsilon = 1e-9) {
  // ...
}
```

# Ottimi esempi

- [Dask](https://docs.dask.org/en/latest/)
- [xarray](https://xarray.pydata.org/en/stable/)
- [spaCy](https://spacy.io/usage/spacy-101#what-spacy-isnt)
- [Sentry](https://docs.sentry.io/)
- [Objax](https://objax.readthedocs.io/en/latest/)
- [Pyramid](https://docs.pylonsproject.org/projects/pyramid/en/1.10-branch/narr/testing.html?highlight=testing)
- [Balena](https://www.balena.io/docs/learn/welcome/introduction/)


# Guida per l'esercitazione

# Guida per l'esercitazione

1.   Implementare il tipo `Image` con le seguenti caratteristiche:

     -   Campi `width` ed `height`, array di valori `Color`;
     -   Caricamento/salvataggio in formato PFM;
     -   Caricamento/salvataggio in formato PNM (con aggiustamento
         tramite $\gamma$).
         
2.   Implementare una serie di test per le funzioni implementate.

# Test (1)

-   Creazione di un'immagine (che all'inizio deve essere tutta nera):

    ```python
    img = Image(width=320, height=240)

    assert img.width == 320
    assert img.height == 240

    for col in range(img.height):
        for row in range(img.width):
            img.get_pixel(col, row).is_close(BLACK_COLOR)
    ```

-   Scrittura/lettura di pixel:

    ```python
    # Change the value of one pixel
    img.set_pixel(100, 200, Color(0.1, 0.2, 0.3))
    assert img.get_pixel(100, 200).is_close(Color(0.1, 0.2, 0.3))
    ```

# Test (2)

-   Salvataggio/caricamento di un'immagine PFM; per rendere il test
    rappresentativo, assegnamo a ogni pixel un colore diverso dagli
    altri:

    ```python
    # Fill the image so that every pixel has a different color
    for col in range(img.height):
        for row in range(img.width):
            img.set_pixel(col, row, Color(col, row, col - row))

    # Save the image in a file
    with open("test.pfm", "wb") as outf:
        img.save_pfm(outf)

    # Load the file in a new variable
    with open("test.pfm", "rb") as inpf:
        newimg = Image.from_pfm(inpf)

    # Check that the two images match
    assert newimg.width == img.width
    assert newimg.height == img.height
    for col in range(newimg.height):
        for row in range(newimg.width):
            orig_col = img.get_pixel(col, row)
            new_col = newimg.get_pixel(col, row)
            assert new_col.is_close(orig_col)
    ```

# Test (3)

-   Salvataggio/caricamento di un'immagine PNM:

    ```python
    with open("test.pnm", "wb") as outf:
        img.save_pnm(outf)
    ```
