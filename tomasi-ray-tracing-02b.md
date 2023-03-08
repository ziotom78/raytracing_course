---
title: "Esercitazione 2"
subtitle: "Calcolo numerico per la generazione di immagini fotorealistiche"
author: "Maurizio Tomasi <maurizio.tomasi@unimi.it>"
...

# Gestione dei colori

# Codificare un colore

-   Abbiamo visto che i colori percepiti dall'occhio umano possono essere codificati tramite tre valori scalari R, G, B.
-   Il compito di oggi è implementare un tipo di dato `Color` che codifichi un colore usando tre numeri *floating-point* (a 32 bit) per i livelli di rosso, verde e blu.
-   La conversione da RGB a sRGB sarà oggetto dell'esercitazione di settimana prossima, quando introdurremmo i formati grafici (PNG, Jpeg, etc.)
-   Come per la scorsa lezione, anche oggi mostrerò esempi di codice in Python

# Colori in Python

-   Definiamo una classe `Color` usando `@dataclass` (come `struct` in C++):

    ```python
    # Supported since Python 3.7
    from dataclasses import dataclass

    @dataclass
    class Color:
        r: float = 0.0
        g: float = 0.0
        b: float = 0.0
    ```

-   È possibile creare un colore con questa sintassi:

    ```python
    color1 = Color(r=3.4, g=0.4, b=1.7)
    color2 = Color(3.4, 0.4, 1.7)  # Shorter version
    ```

# Operazioni su `Color`

-   Somma tra due colori (analogo di $L_\lambda^{(1)} + L_\lambda^{(2)}$)
-   Prodotto per uno scalare ($\alpha L_\lambda$)
-   Prodotto tra due colori ($f_{r,\lambda} \otimes L_\lambda$ nell'equazione del rendering)
-   Livello di somiglianza tra due colori (da usare nei test)

# Esempio in Python

```python
class Color:
    # ...

    def __add__(self, other):
        return Color(
            self.r + other.r,
            self.g + other.g,
            self.b + other.b,
        )

    def __mul__(self, scalar):
        return Color(
            self.r * scalar,
            self.g * scalar,
            self.b * scalar,
        )

    # Etc.
```

# Il tipo `HdrImage`

-   Oltre al tipo `Color`, oggi implementeremo un tipo `HdrImage`, che useremo per rappresentare una immagine HDR tramite una matrice di elementi `Color`.
-   Per oggi, il tipo `HdrImage` dovrà implementare solo queste funzionalità:
    -   Creazione di un'immagine vuota, specificando il numero di colonne (`width`) e il numero di righe (`height`);
    -   Lettura/modifica di pixel.

# Matrice dei colori

-   Il tipo più naturale per una matrice di colori è un array bidimensionale di dimensione `(ncols, nrows)`…

-   …ma è più comodo ed efficiente usare un array **monodimensionale** di dimensione `ncols × nrows`.

-   Gli array bidimensionali non sono supportati in tutti i linguaggi (Kotlin ad esempio non li supporta), e se usati male possono essere molto inefficienti:

    ```java
    // This is valid Java, but it's sub-optimal!
    int[][] myNumbers = { {1, 2, 3, 4}, {5, 6, 7} };
    ```

# Struttura di `HdrImage`

-   In Python possiamo implementare `HdrImage` così:

    ```python
    class HdrImage:
        def __init__(self, width=0, height=0):
            # Initialize the fields `width` and `height`
            (self.width, self.height) = (width, height)
            # Create an empty image (Color() returns black, remember?)
            self.pixels = [Color() for i in range(self.width * self.height)]
    ```

-   L'array di valori ha un numero di elementi pari a $\mathtt{width} \times \mathtt{height}$

-   A noi però interessa identificare un elemento della matrice tramite una coppia `(colonna, riga)`, ossia `(x, y)`.

# Accesso ai pixel

Data la posizione `(x, y)` di un pixel (con `x` colonna e `y` riga), l'indice nell'array `self.pixels` si trova così:

<center>
![](./media/bitmap-linear-access.svg)
</center>

# `get_pixel` e `set_pixel`

-   Usando la formula della slide precedente possiamo implementare i metodi `get_pixel` e `set_pixel`:

    ```python
    def get_pixel(self, x: int, y: int) -> Color:
        assert (x >= 0) and (x < self.width)
        assert (y >= 0) and (y < self.height)
        return self.pixels[y * self.width + x]

    def set_pixel(self, x: int, y: int, new_color: Color):
        assert (x >= 0) and (x < self.width)
        assert (y >= 0) and (y < self.height)
        self.pixels[y * self.width + x] = new_color
    ```

    Ma questa implementazione è la migliore?

-   No! Ma per capirlo dobbiamo parlare di come si verifica il codice


# Verifica del codice

# Perché verificare il codice?

-   Gli errori sono dietro l'angolo!

-   Esempio (in un tema d'esame del corso di TNDS!):

    ```c++
    CampoVettoriale operator+(const CampoVettoriale &v) const {
      CampoVettoriale sum(v); // invoco costruttore di copia di v
      sum.Addcomponent(getFx(), getFx(), getFz());

      return sum;
    }
    ```

-   Per verificare la correttezza di una funzione, occorrerebbe invocarla con dati *non banali* e controllarne il risultato.

# Come verificare il codice?

-   Una volta scritto, il codice va *verificato* su casi il cui risultato è già noto

-   Il modo più semplice è testare il codice stampando a video i valori:

    ```python
    color1 = Color(1.0, 2.0, 3.0)  # Avoid trivial cases like Color(3.0, 3.0, 3.0)
    color2 = Color(5.0, 6.0, 7.0)  # in your tests!
    print(color1 + color2)
    print (color1 * 2)
    ```

    che produce l'output

    ```text
    Color(r=6.0, g=8.0, b=10.0)
    Color(r=2.0, g=4.0, b=6.0)
    ```

-   Possiamo fare di meglio?

# Scrittura di test automatici

-   Il compito di verificare la correttezza dei calcoli è noioso e facile da sbagliare.

-   Dovremmo far svolgere compiti tediosi ai computer!

-   Tutti i linguaggi moderni offrono sistemi per l'esecuzione automatica di test. (Il C++ no, ed ecco perché queste cose non sono state spiegate nel corso di TNDS)

# Test automatici

-   In Python, il nostro codice di partenza è questo:

```python
color1 = Color(1.0, 2.0, 3.0)
color2 = Color(5.0, 6.0, 7.0)
print(color1 + color2)
print(color1 * 2)
```

-   Possiamo migliorarlo facilmente usando `assert`:

```python
color1 = Color(1.0, 2.0, 3.0)
color2 = Color(5.0, 6.0, 7.0)
assert (color1 + color2) == Color(6.0, 8.0, 10.0)
assert (2 * color1) == Color(2.0, 4.0, 6.0)
```

-   Se eseguiamo il codice, non produrrà alcun output: tutto bene!

# Come testare i test?

-   Il fatto che il nostro programma non produca output è atteso (non ha bug), ma non tranquillizzante: siamo *sicuri* che abbia davvero eseguito il test?

-   Una pratica molto diffusa è quella di iniziare scrivendo test *sbagliati*, e verificando che si generi effettivamente un errore:

    ```python
    color1 = Color(1.0, 2.0, 3.0)
    color2 = Color(5.0, 6.0, 7.0)
    assert (color1 + color2) == Color(6.0, 8.0, 11.0) # 10 -> 11
    assert (2 * color1) == Color(3.0, 4.0, 6.0) # 2 -> 3
    ```

    Solo quando l'errore viene emesso si corregge il test.

---

<asciinema-player src="cast/color-test-python.cast" rows="27" cols="94" font-size="medium"></asciinema-player>

# Verifiche su floating point

-   Nei test che scriveremo dovremo usare operazioni logiche e di confronto (in Python: `==`, `<`, `>`, `<=`, `>=`, etc.)

-   Occorre prestare molta attenzione ai numeri floating point!

    <asciinema-player src="cast/floating-point-python.cast" rows="15" cols="80"
        font-size="medium"></asciinema-player>

# Accorgimenti per floating point

-   Evitate dei test che coinvolgano numeri con parti decimali (es., `2.1`, `5.09`)
-   Numeri interi piccoli (es., `16.0`) sono codificati senza arrotondamenti…
-   …quindi nei test, se possibile, usate numeri floating point interi (come abbiamo fatto per la classe `Color` in Python)
-   Per i casi in cui non è possibile, definite una funzione `are_close`:

    ```python
    def are_close(x, y, epsilon = 1e-5):
        return abs(x - y) < epsilon

    x = sum([0.1] * 10)       # Sum of the values in [0.1, 0.1, ..., 0.1]
    print(x)                  # Output: 0.9999999999999999
    assert are_close(1.0, x)  # This test passes successfully
    ```


# Test e granularità

-   L'implementazione di funzioni e tipi dovrebbe essere legata alla scrittura di test.

-   Implementare test per le due funzioni `get_pixel` e `set_pixel` è ripetitivo:

    ```python
    def get_pixel(self, x: int, y: int) -> Color:
        assert (x >= 0) and (x < self.width)
        assert (y >= 0) and (y < self.height)
        return self.pixels[y * self.width + x]

    def set_pixel(self, x: int, y: int, new_color: Color):
        assert (x >= 0) and (x < self.width)
        assert (y >= 0) and (y < self.height)
        self.pixels[y * self.width + x] = new_color
    ```

    La verifica delle coordinate va testata due volte: in `get_pixel` e in `set_pixel`.

---

# Test ripetuti

-   Dobbiamo verificare che coordinate sbagliate vengano rigettate sia in `set_pixel` che in `get_pixel`:

    ```python
    img = HdrImage(7, 4)

    # Test that wrong positions be signaled
    with pytest.raises(AssertionError):
        img.get_pixel(-1, 0)

    # We must redo the same for "set_pixel"
    with pytest.raises(AssertionError):
        img.set_pixel(-1, 0, Color())
    ```

-   Possiamo fare di meglio *modularizzando* il codice, ossia decomponendolo in parti più semplici (che è un vantaggio già di per sè).

# Nuova implementazione

```python
def valid_coordinates(self, x: int, y: int) -> bool:
    return ((x >= 0) and (x < self.width) and
            (y >= 0) and (y < self.height))

def pixel_offset(self, x: int, y: int) -> int:
    return y * self.width + x

def get_pixel(self, x: int, y: int) -> Color:
    assert self.valid_coordinates(x, y)
    return self.pixels[self.pixel_offset(x, y)]

def set_pixel(self, x: int, y: int, new_color: Color):
    assert self.valid_coordinates(x, y)
    self.pixels[self.pixel_offset(x, y)] = new_color
```

# Test

-   Questi sono i test scritti per la nuova implementazione:

    ```python
    img = HdrImage(7, 4)

    # Check that valid/invalid coordinates are properly flagged
    assert img.valid_coordinates(0, 0)
    assert img.valid_coordinates(6, 3)
    assert not img.valid_coordinates(-1, 0)
    assert not img.valid_coordinates(0, -1)
    assert not img.valid_coordinates(7, 0)
    assert not img.valid_coordinates(0, 4)

    # Check that indices in the array are calculated correctly:
    # this kind of test would have been harder to write
    # in the old implementation
    assert img.pixel_offset(3, 2) == 17    # See the plot a few slides before
    assert img.pixel_offset(6, 3) == 7 * 4 - 1
    ```

-   Questi sono detti *unit test*, perché vanno a verificare le singole «unità» di codice.


# Funzioni di supporto ai test

-   Nel nostro codice Python, per verificare la corrispondenza tra due colori abbiamo usato `==`, che funziona perché abbiamo specificato numeri interi:

    ```c++
    assert (color1 + color2) == Color(6.0, 8.0, 10.0)
    assert (2 * color1) == Color(2.0, 4.0, 6.0)
    ```

-   Però $\pi$ compare spesso nei calcoli radiometrici!

-   Definite una funzione che confronti due `Color` come i floating-point:

    ```python
    def are_colors_close(a, b):
        return are_close(a.r, b.r) and are_close(a.g, b.g) and are_close(a.b, b.b)

    assert are_colors_close(color1, color2)
    ```

# Lavoro in gruppo

-   Da oggi lavorerete in gruppo: ciascuno di voi dovrà scegliere quale parte di codice implementare.

-   Inizieremo ad usare le caratteristiche più avanzate di Git per gestire i **conflitti**, ossia le situazioni in cui una parte di codice viene modificata contemporaneamente da più persone.

-   Vediamo un esempio pratico di conflitto per un semplice codice Python.

---

<asciinema-player src="cast/git-conflicts-96x27.cast" cols="96" rows="27"  font-size="medium"></asciinema-player>

# *Merge commit*

<center>
![](./media/merge-commit.svg)
</center>

# Tipi di conflitti

1.  Due sviluppatori stanno implementando la stessa funzionalità:
    -   Si sceglie una delle due implementazioni
    -   Si fondono insieme
2.  Due sviluppatori implementano funzionalità separate nello stesso punto del codice:
    -   Se possono coesistere, si mantengono insieme (è il caso del video precedente)
    -   Se non possono, si separano in due file diversi
3.  Due sviluppatori implementano due funzionalità incompatibili:
    -   Decidono quale delle due funzionalità vada mantenuta e quale no…
    -   …oppure uno dei due si licenzia!


# Guida per l'esercitazione

# Guida per l'esercitazione

1.  Scegliete un nome per il vostro progetto (qui useremo `myraytracer`).

2.  Strutturare il progetto nel modo seguente:

    -   Una libreria che implementi `Color` e `HdrImage`, più le operazioni su di essi;
    -   Un programma da linea di comando che importi la libreria, ma che per il momento stampi solo `Hello, world!`;
    -   Una serie di test automatici sui tipi `Color` e `HdrImage`.

3.  Registrare il progetto su GitHub e aggiungere i propri compagni.

5.  Non abbiate paura di creare conflitti e fare *merge commit*: più vi esercitate con essi, più semplice vi sarà la vita in futuro.


# Lavoro in gruppo

-   In ogni gruppo, solo **uno** di voi dovrebbe creare lo scheletro del progetto, creare la pagina GitHub e salvarlo.

-   Gli altri membri diventeranno collaboratori del progetto (v. slide seguente).

-   Pensate a un modo per suddividere il lavoro tra membri del vostro gruppo; ad esempio, per `Color`:

    1.  Somma di due colori;
    2.  Prodotto tra due colori, e prodotto colore-scalare;
    3.  Funzione `are_colors_close`;
    4.  Test.

---

<center>
![](./media/github-add-collaborators.png)
</center>

# Lavoro in gruppo

-   Per lavorare in gruppo sul repository GitHub, ciascuno di voi dovrà eseguire `git push` per inviare le proprie modifiche («commit») al server GitHub
-   A quel punto i compagni potranno scaricare le modifiche usando `git pull`.

-   Un modo per dividersi il lavoro è che uno di voi implementi un metodo (ad esempio `valid_coordinates`) e l'altro scriva **contemporaneamente** il test:

    - `valid_coordinates` + test;
    - `pixel_offset` + test;
    - `get_pixel`/`set_pixel` + test.

# Caratteristiche di `Color`

-   Tre campi `r`, `g`, `b` di tipo floating-point a **32 bit**: non servono 64 bit, e anzi ci farebbero sprecare memoria e tempo
-   Se usate linguaggi OOP, non perdete tempo a definire `GetR`/`SetR` e simili: sono lunghe da scrivere, facili da sbagliare, rendono il codice difficile da leggere e più lento da compilare
-   Metodo `Color.is_close` o funzione `are_close`/`are_colors_close` per verificare se due colori sono simili (utile nei test);
-   Somma tra colori;
-   Prodotti colore-colore e colore-scalare
-   Se è il caso, implementate anche una funzione che converta un numero in una stringa (es., `<r:1.0, g:3.0, b:4.0>`): sarà comodo per fare debug

# Uso della memoria

-   Nella maggior parte dei linguaggi c'è differenza tra *value* e *reference types*.

-   I *value types* sono valori a cui si può accedere direttamente, e sono sempre allocati sullo *stack*: sono molto veloci da usare, ma non possono occupare troppa memoria (alcuni kB al massimo).

-   I *reference types* sono dei puntatori al dato attuale, e possono essere sia sullo *stack* che nello *heap*; in quest'ultimo caso possono occupare tutta la memoria che vogliono, ma sono più lenti da leggere e scrivere.

-   Fanno eccezione i linguaggi basati su JVM (Java, Kotlin, Scala, etc.), per cui esistono solo *reference types* (ma la JVM può autonomamente convertire variabili in *value types* se capisce che è conveniente).

---

<center>
![](./media/stack-vs-heap-memory.svg)
</center>

---

# Esempio in C++

```c++
#include <iostream>
#include <vector>

int main() {
    int a{};                     // Allocated on the stack
    int * b{new int};            // Allocated in the heap
    int c[] = {1, 2, 3};         // Allocated on the stack
    std::vector<int> v{1, 2, 3}; // "v" on the stack, but the three numbers in the heap

    a = 15;   // This is fast
    *b = 16;  // This is slower
    
    std::cout << a << ", " << *b << "\n";
    // Output:
    // 15, 16
}
```

In Python, qualsiasi variabile (anche le variabili intere come `x = 1`) è allocata nello heap (uno dei motivi per cui è molto più lento del C++)

# Dimensione dello stack

-   Per programmi C/C++/Fortran/Julia, la dimensione è fissata dal sistema operativo. Sotto sistemi Posix (Linux/Mac OS X), potete conoscerne il valore in KB col comando `ulimit -s`:

    ```text
    $ ulimit -s
    8192
    ```

    Il valore di 8 MB è caratteristico di Linux; per i Mac è 0,5 MB.

-   La piattaforma .NET (Visual Basic, C\#) usa uno stack di 1 MB.

-   La piattaforma JVM (Java, Kotlin) usa uno stack di 1 MB, che è però usato solo per i tipi primitivi (interi, booleani, numeri floating-point).

# Value types

-   La classe `Color` è molto piccola: richiede memoria per 3 numeri floating-point, ed è quindi logico definirla come un *value type* (questo non è vero per `HdrImage`)

-   A seconda del linguaggio, l'uso di un *value type* richiede accorgimenti diversi:

    -   In C++, si usa `struct` oppure `class` (è uguale), ma quando la userete nei codici/test evitate `new`/`delete`;
    -   In C\# e in D, si usa `struct` (value type), ma non `class` (reference type);
    -   In Pascal, si usa `object` o `record`, ma non si usa `class`;
    -   In Nim, si usa `object`, ma non si usa `ref object`;
    -   In Julia, si usa il package [`StaticArrays`](https://juliaarrays.github.io/StaticArrays.jl/stable/).

# Test (1)

-   Creazione di colori e funzione `is_close`:

    ```python
    col = Color(1.0, 2.0, 3.0)
    assert col.is_close(Color(1.0, 2.0, 3.0))
    ```

-   Verificate anche che `is_close` fallisca (ossia ritorni `False`) quando è necessario:

    ```python
    assert not col.is_close(Color(3.0, 4.0, 5.0))  # First method
    ```
    
    Questo tipo di test «negativi» è molto importante!

# Test (2)

-   Somma/prodotto di colori:

    ```python
    col1 = Color(1.0, 2.0, 3.0)  # Do not use the previous definition,
    col2 = Color(5.0, 7.0, 9.0)  # it's better to define it again here

    assert (col1 + col2).is_close(Color(6.0, 9.0, 12.0))
    assert (col1 * col2).is_close(Color(5.0, 14.0, 27.0))
    ```

-   Prodotto colore-scalare (implementate anche scalare-colore,
    se volete):

    ```python
    prod_col = Color(1.0, 2.0, 3.0) * 2.0

    assert prod_col.is_close(Color(2.0, 4.0, 6.0))
    ```

# Test (3)

```python
def test_image_creation():
    img = HdrImage(7, 4)
    assert img.width == 7
    assert img.height == 4

def test_coordinates():
    img = HdrImage(7, 4)

    assert img.valid_coordinates(0, 0)
    assert img.valid_coordinates(6, 3)
    assert not img.valid_coordinates(-1, 0)
    assert not img.valid_coordinates(0, -1)
    assert not img.valid_coordinates(7, 0)
    assert not img.valid_coordinates(0, 4)

def test_pixel_offset():
    img = HdrImage(7, 4)

    assert img.pixel_offset(0, 0) == 0
    assert img.pixel_offset(3, 2) == 17
    assert img.pixel_offset(6, 3) == 7 * 4 - 1

def test_get_set_pixel():
    img = HdrImage(7, 4)

    reference_color = Color(1.0, 2.0, 3.0)
    img.set_pixel(3, 2, reference_color)
    assert are_colors_close(reference_color, img.get_pixel(3, 2))
```

# Suggerimenti per C\#

# Soluzioni e progetti

```{.graphviz im_fmt="svg" im_out="img" im_fname="project-structure-csharp"}
graph "" {
    lib [label="library (project)" shape=ellipse];
    exec [label="executable (project)" shape=box];
    test [label="tests (project)" shape=box];
    lib -- exec;
    lib -- test;
}
```

-   Il comando `dotnet` supporta la creazione di *soluzioni* e *progetti*.

-   Per *progetto* si intende qualsiasi cosa che possa essere prodotta a partire da file contenenti codice C\# (eseguibile, libreria…)

-   Una *soluzione* è un insieme di progetti. Nel grafico sopra, ogni elemento del grafico è un *progetto*, e il grafico nel suo complesso è una *soluzione*.

# Creare soluzioni/progetti

-   Per creare una soluzione, basta scrivere `dotnet new sln`
-   I progetti in `dotnet` si dividono in più tipi:
    -   Eseguibili (`dotnet new console`)
    -   Librerie (`dotnet new classlib`)
    -   Test automatici (`dotnet new xunit`)
-   Per specificare che il progetto `A` dipende da `B`, si usa `dotnet add A reference B`
-   Per aggiungere progetti a una soluzione, si usa `dotnet sln add`

# La nostra soluzione

Questi sono i comandi da terminale per produrre la soluzione che vogliamo:

```sh
# Create a new solution that will include:
# 1. The library
# 2. The executable (currently printing «Hello, world!»)
# 3. The tests
dotnet new sln -o "Myraytracer"

cd Myraytracer

# 1. Create the library, named "Trace", and add it to the solution
dotnet new classlib -o "Trace"
dotnet sln add Trace/Trace.csproj

# 2. Create the executable, named "Myraytracer", and add it to the solution
dotnet new console -o "Myraytracer"
dotnet sln add Myraytracer/Myraytracer.csproj

# 3. Create the tests, named "Trace.Tests", and add them to the solution
dotnet new xunit -o "Trace.Tests"
dotnet sln add Trace.Tests/Trace.Tests.csproj

# Both the executable and the tests depend on the «Trace» library
dotnet add Myraytracer/Myraytracer.csproj reference Trace/Trace.csproj
dotnet add Trace.Tests/Trace.Tests.csproj reference Trace/Trace.csproj

# Create a .gitignore file
dotnet new gitignore
```

Fate tutto da linea di comando e poi aprite il progetto in Rider: è più istruttivo!

# Albero delle directory

-   La soluzione così com'è creata ha nomi generici per i file, ed è meglio cambiarli in qualcosa di più facile da riconoscere;
-   Rinominate i file in modo da avere una struttura con questa forma:

    ```text
    Myraytracer
    ├── Myraytracer.sln
    ├── Myraytracer
    │   ├── Myraytracer.cs      <-- This was Program.cs
    │   └── Myraytracer.csproj
    ├── Trace
    │   ├── Color.cs            <-- This was Class1.cs
    │   ├── HdrImage.cs         <-- New file
    │   └── Trace.csproj
    └── Trace.Tests
        ├── ColorTests.cs       <-- This was UnitTest1.cs
        ├── HdrImageTests.cs    <-- New file
        └── Trace.Tests.csproj
    ```

# Scrittura di test

```csharp
// This should be put in Trace.Tests/ColorTests.cs
using System;
using Xunit;
using Trace;

namespace Trace.Tests
{
    public class ColorTests
    {
        [Fact]
        public void TestAdd()
        {
            Color a = new Color(1.0f, 2.0f, 3.0f);
            Color b = new Color(5.0f, 6.0f, 7.0f);
            // C# convention: *first* the expected value, *then* the test value
            Assert.True(Color.are_close(new Color(6.0f, 8.0f, 10.0f), a + b));
            // ...
        }
    }
}
```

Potete eseguire i test col comando `dotnet test`, oppure in Rider (comodissimo, fate riferimento alle slide relative a Kotlin)

# Suggerimenti per D

# Definizione dei tipi

-   Definite `Color` come una `struct` e `HdrImage` come una `class`; per `Color` prevedete dei default:

    ```d
    struct Color {
      float r = 0, g = 0, b = 0;
    };
    ```

-   Definite il campo `pixels` del tipo `HdrImage` come un [array dinamico](https://dlang.org/spec/arrays.html#dynamic-arrays)

-   Definite un costruttore per `HdrImage` che accetti `width` ed `height`, ed inizializzi `pixels` [allocando la lunghezza appropriata](https://dlang.org/spec/arrays.html#length-initialization) e poi impostando il colore di tutti i pixel al nero

# Test in D

-   Il linguaggio D offre un ottimo supporto ai test tramite la keyword `unittest` (da sogno!)

-   Non è quindi necessario definire i test in file separati, com'è invece il caso ad esempio del C\# e di Nim

-   Per eseguire i test, basta avviare il comando

    ```
    $ dub test
    ```
    
-   La documentazione corrispondente è qui: [Unit tests](https://dlang.org/spec/unittest.html)

# Suggerimenti per Nim

# Definizione dei tipi

-   Implementare i tipi `Color` e `HdrImage` dovrebbe essere elementare

-   Assicuratevi di usare `object` e non `ref object` per Color, mentre per `HdrImage` è indifferente

-   Ricordatevi che in Nim bisogna esportare sia i tipi che i loro membri, usando `*`:

    ```nim
    type
        Color* = object
            r*, g*, b*: float32
            
        HdrImage* = object
            width*, height*: int
            pixels*: Seq[Color]
    ```

# Creazione di `HdrImage`

-   In Nim non servono costruttori come in C++

-   La prassi è quella di definire una funzione `newMyType` che crei il tipo `MyType`

-   Aggiungete quindi una procedura `newHdrImage` che accetti due parametri `width` ed `height`; inizializzate il campo `pixels` usando [`newSeq`](https://nim-lang.org/docs/system.html#newSeq), poi impostate tutti i colori a zero (nero)

# Scrittura di test

-   In Nim è possibile usare il comando `assert` per eseguire dei test

-   La prassi è quella di creare dei file Nim all'interno della directory `tests`; se questi file iniziano con `t`, vengono [eseguiti automaticamente](https://github.com/nim-lang/nimble#tests) dal comando

    ```
    $ nimble test
    ```
    
-   Per scrivere i test dei tipi `Color` e `HdrImage`, create quindi un file `tests/test_basictypes.nim` fatto così:

    ```nim
    import ../src/basictypes
    
    when isMainModule:
        assert Color(1.0, 2.0, 3.0) + Color(3.0, 4.0, 5.0) == Color(4.0, 6.0, 8.0)
        # …
    ```

# Suggerimenti per Rust

# Struttura del codice

-   Per oggi non è necessario che strutturiate il codice in moduli complessi.

-   Create un file `basictypes.rs` in cui definirete sia il tipo `Color` che il tipo `HdrImage`, insieme a tutti i test associati ad essi

-   Potete per il momento lasciare il file `main.rs` intatto (con il messaggio `Hello, world!`)

-   Per formattare automaticamente il codice, usate il comando `cargo fmt`

# Definizione dei tipi

-   Per `Color`, derivate i *trait* `Copy`, `Clone` e `Debug` per semplificarvi la vita:

    ```rust
    #[derive(Copy, Clone, Debug)]
    pub struct Color {
        pub r: f32,
        pub g: f32,
        pub b: f32,
    }
    ```

-   Per `HdrImage`, definite il membro `pixels` di tipo `Vec<Color>`

-   Definite anche una funzione `create_hdr_image(width: i32, height: i32) -> HdrImage`, che inizializzi `pixels` correttamente

# Test in Rust

-   Rust supporta test nativamente usando le annotazioni `#[cfg(test)]` e `#[test]`

-   I test possono essere eseguiti automaticamente con il comando

    ```
    $ cargo test
    ```

-   Consultate la [guida di Rust](https://doc.rust-lang.org/rust-by-example/testing/unit_testing.html); una trattazione più approfondita si trova nel [capitolo 11](https://doc.rust-lang.org/book/ch11-00-testing.html) di *The Rust Programming Language* (Klabnik & Nichols)


# Suggerimenti per Java/Kotlin

# Gestione di progetti

-   IntelliJ IDEA si basa su Gradle, che è l'equivalente di CMake in C++.

-   Gradle può essere programmato in Groovy (un linguaggio basato su Java) o in Kotlin.

-   Siccome Java e Kotlin permettono un'ottima modularità, per questo corso non è necessario differenziare tra libreria ed eseguibile.

-   Create quindi un nuovo progetto esattamente come avete fatto la volta scorsa.

# Creazione di classi

In IntelliJ IDEA le classi si creano dalla finestra del progetto (a sinistra):

<center>
![](./media/kotlin-new-class.png){height=480}
</center>

# Creazione di `Color`

-   In Kotlin, usate le *data classes* per definire la classe `Color`: sono molto veloci da usare!

    ```kotlin
    /** A RGB color
     *
     * @param r The level of red
     * @param g The level of green
     * @param b The level of blue
     */
    public data class Color(val r: Double, val g: Double, val b: Double) {
        // ...
    }
    ```

-   Definite `is_close` e gli operatori `plus` (somma di due colori) e `times` (prodotto tra colore e scalare).

# Definizione di `HdrImage`

-   Kotlin permette la definizione di classi in forma estremamente compatta. Ecco un esempio di implementazione di `HdrImage`:

    ```kotlin
    class HdrImage(
        val width: Int,  // Using 'val' ensures that we cannot change the width
        val height: Int, // or the height of the image once it's been created
        var pixels: Array<Color> = Array(width * height) { Color(0.0F, 0.0F, 0.0F) }
    ) {
        // Here are the methods for the class…
    }
    ```

-   Abituatevi alla differenza tra `val` e `var`!

# Scrittura di test

-   IntelliJ IDEA genera e gestisce il codice di test.

-   Usa la libreria [JUnit](https://junit.org/); se vi chiede che versione usare, potete optare per la 4 oppure la 5.

-   Controllate la versione usata nel vostro progetto aprendo il menu «File | Project structure».

---

<center>
![](./media/kotlin-project-structure.png){height=560}
</center>

Qui la versione usata è la 4.

# Creazione di test vuoti

-   Fate click col tasto destro sul nome di una classe e scegliete *Generate*.

-   Nella finestra che compare, scegliete la versione giusta per JUnit e poi fate un segno di spunta accanto ai metodi per cui volete scrivere test. (Nel nostro caso saranno `is_close`, `plus` e `times`).

-   Una volta implementati i test (usando `assertTrue` e `assertFalse`), eseguiteli usando le icone a sinistra dell'editor.

---

# Generare test

<center>
![](./media/kotlin-generate-test.png)
</center>

---

# Eseguire test
<center>
![](./media/kotlin-run-test.png)
</center>
