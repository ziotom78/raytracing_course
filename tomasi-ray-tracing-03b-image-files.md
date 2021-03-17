---
title: "Esercitazione 3"
subtitle: "Calcolo numerico per la generazione di immagini fotorealistiche"
author: "Maurizio Tomasi <maurizio.tomasi@unimi.it>"
...

# Il tipo `HdrImage`

-   Oggi implementeremo un tipo `HdrImage`, che useremo per rappresentare una immagine HDR tramite una matrice di colori (del tipo `Color`).
-   Il tipo `HdrImage` dovrà implementare queste funzionalità:
    -   Creazione di un'immagine vuota;
    -   Lettura/scrittura di pixel;
    -   Caricamento di immagini in formato PFM.

# Implementazione di `HdrImage`

-   Deve avere tre campi:
    -   `width` ed `height` (numero di colonne e di righe della matrice);
    -   Array di valori `Color`.
-   Servono due costruttori/funzioni:
    -   Creare un'immagine vuota partendo da una risoluzione;
    -   Scrivere un'immagine in un file PFM.
-   Ovviamente vogliamo anche una serie completa di test!

# Matrice dei colori

-   Il tipo più naturale per una matrice di colori è un array bidimensionale di dimensione `(ncols, nrows)`…

-   …ma per certi versi è più comodo usare un array **monodimensionale** di dimensione `ncols × nrows`.

-   In Python possiamo implementare `HdrImage` così:

    ```python
    class HdrImage:
        def __init__(self, width=0, height=0):
            (self.width, self.height) = (width, height)
            self.pixels = [Color() for i in range(self.width * self.height)]
    ```

# Accesso ai pixel

Data la posizione `(x, y)` di un pixel (con `x` colonna e `y` riga), l'indice nell'array `self.pixels` si trova così:

<center>
![](./media/bitmap-linear-access.svg)
</center>

# `get_pixel` e `set_pixel`

-   Usando la formula della slide precedente possiamo implementare i metodi `get_pixel` e `set_pixel`:

    ```python
    def get_pixel(self, x, y):
        assert (x >= 0) and (x < self.width)
        assert (y >= 0) and (y < self.height)
        return self.pixels[y * self.height + x]

    def set_pixel(self, x, y, new_color):
        assert (x >= 0) and (x < self.width)
        assert (y >= 0) and (y < self.height)
        self.pixels[y * self.height + x] = new_color
    ```

-   Ma questa implementazione è la migliore?

# Test e granularità

-   L'implementazione di funzioni e tipi dovrebbe essere legata alla scrittura di test.

-   **Non** è semplice implementare test per le due funzioni:

    -   Ciascuna fa troppe cose insieme, che vanno testate tutte!
    -   Ci sono test che vanno ripetuti per `get_pixel` e `set_pixel`, ossia la validità delle coordinate e la correttezza nel calcolo dell'indice.

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
def valid_coordinates(self, x, y):
    return ((x >= 0) and (x < self.width) and
            (y >= 0) and (y < self.height))

def pixel_offset(self, x, y):
    return y * self.width + x

def get_pixel(self, x, y):
    assert self.valid_coordinates(x, y)
    return self.pixels[self.pixel_offset(x, y)]

def set_pixel(self, x, y, new_color):
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

    # Check that indices in the array are calculated correctly:
    # this kind of test would have been harder to write
    # in the old implementation
    assert img.pixel_offset(3, 2) == 17    # See the plot a few slides before
    assert img.pixel_offset(6, 3) == 7 * 4 - 1
    ```

-   Questi sono detti *unit test*, perché vanno a verificare le singole «unità» di codice.

# Scrittura/lettura di file

# File PFM

-   La classe `HdrImage` deve essere in grado di caricare e salvare immagini PFM.

-   Abbiamo visto che i file PFM sono scritti in forma *binaria*, anche se includono parti di testo.

-   In che modo i linguaggi di programmazione che usiamo supportano l'accesso ai file?

-   Come distinguere tra file binari e testuali?

# Accesso ai file in Python

<asciinema-player src="./cast/binary-text-files-75x25.cast" cols="75" rows="25" font-size="medium"></asciinema-player>

# File di testo/binari

-   Non è possibile in generale dire se un file è codificato in forma testuale o binaria.
-   Le estensioni dei file possono essere usate per capire il formato (ma si possono sempre prendere svarioni!).
-   Python mostra che file binari usano tipi di dati (`b"Hello, world!\n"`) diversi da quelli dei file di testo (`"Hello, world!\n"`).
-   Tutti i linguaggi (Python 3, Julia, C\#, Kotlin, etc.) supportano nativamente Unicode e gestiscono correttamente questa differenza…
-   …con l'eccezione del C++ ([è](https://stackoverflow.com/questions/31302506/stdu32string-conversion-to-from-stdstring-and-stdu16string) [una](https://stackoverflow.com/questions/17103925/how-well-is-unicode-supported-in-c11) [triste](https://stackoverflow.com/questions/2259544/is-wchar-t-needed-for-unicode-support) [storia](https://stackoverflow.com/questions/48816848/what-is-the-efficient-standards-compliant-mechanism-for-processing-unicode-usin)).

# Immagini PFM

-   Scrivere file PFM è relativamente banale, perché hanno un [formato](http://www.pauldebevec.com/Research/HDR/PFM/) molto semplice (decisamente più semplice dei file PPM visti a lezione!)

-   Un file PFM deve iniziare con questi caratteri (tutti ASCII, quindi non dobbiamo preoccuparci di Unicode):

    ```text
    PF
    width height
    ±1.0
    ```

    dove `width` ed `height` sono la larghezza (numero di colonne) e l'altezza (numero di righe) dell'immagine; seguono poi i valori RGB in binario.

-   I ritorni a capo vanno codificati come `\n` (non c'è ambiguità Windows/DOS/Linux/etc. come per i file di testo).

# Il numero `±1.0`

-   La terza riga dell'header del file deve contenere `1.0` oppure `-1.0`.

-   Questo numero serve per segnalare il modo in cui ciascuna delle componenti RGB di un colore (floating-point a 32 bit) viene codificata:

    1.  Il valore `1.0` indica che si usa la codifica *big endian*;
    2.  Il valore `-1.0` indica che si usa la codifica *little endian*.

# Numeri in binario

-   Per scrivere numeri in binario, ogni linguaggio offre una serie di opzioni.

-   In Python basta usare `import struct`:

    ```python
    def _write_float(stream, value):
        # Meaning of "<f":
        # "<": little endian
        # "f": single-precision floating point value (32 bit)
        stream.write(struct.pack("<f", value))
    ```

# API di `HdrImage`

-   Il modo in cui un tipo di dato o una funzione deve essere usato dal programmatore si chiama *Application Program Interface* (API).

-   Nel nostro caso, la API per scrivere un file PFM consiste nel modo in cui invocheremmo una funzione `write_pfm`:

    ```python
    # Our API requires the name of the file
    img.write_pfm("output_file.pfm")
    ```

-   Il tipo di API dovrebbe essere modellato anche in funzione dei test che si devono scrivere su di essa.

# Test ed API

-   Consideriamo il caso di `write_pfm`. Come dovremmo scrivere un test su questa funzione?

    ```python
    img = HdrImage(7, 4)
    img.write_pfm("output_file.pfm")
    assert ...  # Now what?
    ```

-   Se la funzione scrive su file, vuol dire che dovremmo poi *caricare* il file e verificare che sia stato scritto correttamente.

-   Ciò significa che finché non abbiamo una routine parallela `read_pfm` non possiamo testare `write_pfm`?


# Gestione dei file

-   Dobbiamo investigare meglio il modo in cui i file possono essere manipolati nei programmi.

-   Potete pensare a un file binario come a un vettore (array monodimensionale) di byte, in sequenza uno dopo l'altro. (Un file testuale è lo stesso, ma nella codifica UTF è una sequenza di *code point* anziché byte, e la cosa è un po' più complicata).

-   I linguaggi moderni introducono una astrazione: lo *stream*.

-   Questa astrazione è molto utile nei test.


# File e stream

-   Semplificando, uno *stream* è un oggetto in grado di compiere queste operazioni:

    1.  Restituire un byte alla volta leggendolo da una sequenza;
    2.  Scrivere un byte alla volta, aggiungendolo in coda a quelli già scritti.

-   Queste due operazioni sono quelle che tipicamente si fanno sui file, ma uno *stream* è applicabile anche ad altri contesti:

    1.  Una connessione di rete a un server remoto funziona come uno stream;
    2.  La stessa memoria RAM può essere considerata come uno stream; di conseguenza, una sequenza di byte in memoria può essere vista come uno stream, se il linguaggio lo supporta.


# Esempio in Python

<asciinema-player src="./cast/files-streams-75x25.cast" cols="75" rows="25" font-size="medium"></asciinema-player>


# Stream, API e test

-   Potremmo pensare di modificare la nostra API in modo che scriva in un generico stream, come l'esempio `write_hello` nel video:

    ```python
    stream = CreateSomeStream(...)
    img.write_pfm(stream)
    ```

-   Quando il programma è in esecuzione, faremo in modo che `stream` sia un file vero.

-   Quando dobbiamo eseguire un test, possiamo invece fare in modo che `stream` sia una variabile in memoria. I byte non verranno quindi scritti su file, ma mantenuti in un vettore di byte, su cui eseguiremo degli `assert`.

# Il metodo `write_pfm`

```python
def write_pfm(self, stream):
    # The PFM header, as a Python string (UTF-8)
    header = f"PF\n{self.width} {self.height}\n-1.0\n"

    # Convert the header into a sequence of bytes
    stream.write(header.encode("utf-8"))

    # Write the image (bottom-to-up, left-to-right)
    for y in reversed(range(self.height)):
        for x in range(self.width):
            color = self.get_pixel(x, y)
            _write_float(stream, color.r)
            _write_float(stream, color.g)
            _write_float(stream, color.b)
```

# Immagine per i test

-   Ho creato due file PFM con queste caratteristiche:

    -   Dimensioni: 3 pixel × 2 pixel;
    -   Uno è codificato come *little endian*, l'altro come *big endian*;
    -   Matrice dei colori (RGB):

        |    | #1              | #2              | #3              |
        |----|-----------------|-----------------|-----------------|
        | #A | (10, 20, 30)    | (40, 50, 60)    | (70, 80, 90)    |
        | #B | (100, 200, 300) | (400, 500, 600) | (700, 800, 900) |

-   È utile che abbiate i file sul vostro disco. Scaricateli con nome [`reference_le.pfm`](./media/reference_le.pfm) e [`reference_be.pfm`](./media/reference_be.pfm) e salvateli nel vostro repository, possibilmente nella stessa directory dei test.

# Scrittura del test (1/3)

Il primo approccio è quello di leggere il file `reference_le.pfm` e confrontarlo col file che *sarebbe* stato scritto da `write_pfm`:

```python
img = HdrImage(3, 2)

img.set_pixel(0, 0, Color(1.0e1, 2.0e1, 3.0e1)) # Each component is
img.set_pixel(1, 0, Color(4.0e1, 5.0e1, 6.0e1)) # different from any
img.set_pixel(2, 0, Color(7.0e1, 8.0e1, 9.0e1)) # other: important in
img.set_pixel(0, 1, Color(1.0e2, 2.0e2, 3.0e2)) # tests!
img.set_pixel(1, 1, Color(4.0e2, 5.0e2, 6.0e2))
img.set_pixel(2, 1, Color(7.0e2, 8.0e2, 9.0e2))

with open("reference_le.pfm", "wb") as inpf:
    reference_bytes = inpf.readall()

buf = BytesIO()
img.write_pfm(buf)

# This assumes that write_pfm uses little endian
assert buf.getvalue() == reference_bytes
```

# Scrittura dei test (2/3)

Ma se eseguiamo `xxd` sul file `reference_le.pfm`, possiamo ottenere la sequenza di valori dei byte nel formato C/C++:

```text
$ xxd -i reference_le.pfm
unsigned char reference_le_pfm[] = {
  0x50, 0x46, 0x0a, 0x33, 0x20, 0x32, 0x0a, 0x2d, 0x31, 0x2e, 0x30, 0x0a,
  0x00, 0x00, 0xc8, 0x42, 0x00, 0x00, 0x48, 0x43, 0x00, 0x00, 0x96, 0x43,
  0x00, 0x00, 0xc8, 0x43, 0x00, 0x00, 0xfa, 0x43, 0x00, 0x00, 0x16, 0x44,
  0x00, 0x00, 0x2f, 0x44, 0x00, 0x00, 0x48, 0x44, 0x00, 0x00, 0x61, 0x44,
  0x00, 0x00, 0x20, 0x41, 0x00, 0x00, 0xa0, 0x41, 0x00, 0x00, 0xf0, 0x41,
  0x00, 0x00, 0x20, 0x42, 0x00, 0x00, 0x48, 0x42, 0x00, 0x00, 0x70, 0x42,
  0x00, 0x00, 0x8c, 0x42, 0x00, 0x00, 0xa0, 0x42, 0x00, 0x00, 0xb4, 0x42
};
unsigned int reference_le_pfm_len = 84;
```

# Scrittura dei test (3/3)

Se inseriamo questa sequenza di byte nel nostro programma, possiamo fare un confronto diretto in memoria:

```python
# Create "img" as in the previous case, then…

# Little-endian format
reference_bytes = bytes([
    0x50, 0x46, 0x0a, 0x33, 0x20, 0x32, 0x0a, 0x2d, 0x31, 0x2e, 0x30, 0x0a,
    0x00, 0x00, 0xc8, 0x42, 0x00, 0x00, 0x48, 0x43, 0x00, 0x00, 0x96, 0x43,
    0x00, 0x00, 0xc8, 0x43, 0x00, 0x00, 0xfa, 0x43, 0x00, 0x00, 0x16, 0x44,
    0x00, 0x00, 0x2f, 0x44, 0x00, 0x00, 0x48, 0x44, 0x00, 0x00, 0x61, 0x44,
    0x00, 0x00, 0x20, 0x41, 0x00, 0x00, 0xa0, 0x41, 0x00, 0x00, 0xf0, 0x41,
    0x00, 0x00, 0x20, 0x42, 0x00, 0x00, 0x48, 0x42, 0x00, 0x00, 0x70, 0x42,
    0x00, 0x00, 0x8c, 0x42, 0x00, 0x00, 0xa0, 0x42, 0x00, 0x00, 0xb4, 0x42
])

# No file is being read/written here!
buf = BytesIO()
img.write_pfm(buf)
assert buf.getvalue() == reference_bytes
```

# Guida per l'esercitazione

# Guida per l'esercitazione

1.  Implementate il tipo `HdrImage` con le seguenti caratteristiche:

    -   Campi `width` ed `height`, array di valori `Color`;
    -   Salvataggio in formato PFM; scegliete voi se scrivere il file usando *big endian* (`1.0` nel file) o *little endian* (`-1.0`).

    La dichiarazione e l'implementazione di `HdrImage` andrebbe salvata in un file a parte, nella stessa directory dove settimana scorsa avete salvato il file che implementa il tipo `Color`.

2.  Implementate una serie di test per le funzioni del punto precedente.

# Test (1)

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

def test_pixel_offset():
    img = HdrImage(7, 4)

    assert img.pixel_offset(0, 0) == 0
    assert img.pixel_offset(3, 2) == 17
    assert img.pixel_offset(6, 3) == 7 * 4 - 1
```

# Test (2)

```python
def test_get_set_pixel():
    img = HdrImage(7, 4)

    reference_color = Color(1.0, 2.0, 3.0)
    img.set_pixel(3, 2, reference_color)
    assert are_colors_close(reference_color, img.get_pixel(3, 2))

def test_pfm_save():
    img = HdrImage(3, 2)

    img.set_pixel(0, 0, Color(1.0e1, 2.0e1, 3.0e1)) # Each component is
    img.set_pixel(1, 0, Color(4.0e1, 5.0e1, 6.0e1)) # different from any
    img.set_pixel(2, 0, Color(7.0e1, 8.0e1, 9.0e1)) # other: important in
    img.set_pixel(0, 1, Color(1.0e2, 2.0e2, 3.0e2)) # tests!
    img.set_pixel(1, 1, Color(4.0e2, 5.0e2, 6.0e2))
    img.set_pixel(2, 1, Color(7.0e2, 8.0e2, 9.0e2))

    # This is the content of "reference_le.pfm" (little-endian file)
    reference_bytes = bytes([
        0x50, 0x46, 0x0a, 0x33, 0x20, 0x32, 0x0a, 0x2d, 0x31, 0x2e, 0x30, 0x0a,
        0x00, 0x00, 0xc8, 0x42, 0x00, 0x00, 0x48, 0x43, 0x00, 0x00, 0x96, 0x43,
        0x00, 0x00, 0xc8, 0x43, 0x00, 0x00, 0xfa, 0x43, 0x00, 0x00, 0x16, 0x44,
        0x00, 0x00, 0x2f, 0x44, 0x00, 0x00, 0x48, 0x44, 0x00, 0x00, 0x61, 0x44,
        0x00, 0x00, 0x20, 0x41, 0x00, 0x00, 0xa0, 0x41, 0x00, 0x00, 0xf0, 0x41,
        0x00, 0x00, 0x20, 0x42, 0x00, 0x00, 0x48, 0x42, 0x00, 0x00, 0x70, 0x42,
        0x00, 0x00, 0xc8, 0x42, 0x00, 0x00, 0x48, 0x43, 0x00, 0x00, 0x96, 0x43
    ])

    buf = BytesIO()
    img.write_pfm(buf)
    assert buf.getvalue() == reference_bytes
```

# Lavoro in gruppo

-   Per iniziare il lavoro, occorre che **uno solo** di voi implementi lo scheletro del tipo `HdrImage`; basta la sua dichiarazione, ad esempio il file `.h` in C++.

-   Una volta fatto `git push`, prelevate in locale con `git pull`, e fate che uno di voi implementi il metodo e l'altro scriva **contemporaneamente** il test:

    - `valid_coordinates` + test;
    - `pixel_offset` + test;
    - `get_pixel`/`set_pixel` + test;
    - `save_pfm` + test.

-   Non abbiate paura di fare *merge commit*: più vi esercitate con essi, più semplice vi sarà la vita in futuro.

# Linguaggi

-   Come le scorse volte, vi do una serie di indicazioni per l'implementazione nei vari linguaggi.

-   Sono presenti in ogni slide una serie di link alla documentazione del linguaggio: imparate a consultarla e a prendere familiarità col modo in cui è organizzata!

-   Via via che procederemo dovrete essere sempre più autonomi nel trovare soluzioni per il vostro linguaggio, e a diventare confidenti con la sua sintassi.

# Link a Gather

Useremo il solito link: [gather.town/app/CgOtJvyNfVKMIQ9e/LaboratorioRayTracing](https://gather.town/app/CgOtJvyNfVKMIQ9e/LaboratorioRayTracing)

# Indicazioni per C++

# Il tipo `HdrImage`

-   Usate `std::vector<Color>` per l'array di colori in `HdrImage`;

-   Non c'è bisogno di implementare funzioni `getWidth`, `setWidth`, eccetera. Basta che `width`, `height` e `pixels` siano membri pubblici:

    ```c++
    struct HdrImage {
        int width, height;
        std::vector<Color> pixels;
        
        // ...
    };
    ```
    
-   Sarebbe meglio dichiarare i metodi `valid_coordinates`, `pixel_index`, `get_pixel` e `set_pixel` nel file `.h` anziché nel `.cpp`.


# File e stream

-   Per accedere ai file, il C++ non è molto sofisticato: aprite il file in scrittura usando `std::ofstream`.

-   Gli stream in memoria (come `ByteIO` in Python) sono implementati da [`std::stringstream`](https://www.cplusplus.com/reference/sstream/stringstream/stringstream/) (in `<sstream>`):

    ```c++
    std::stringstream sstr;
    
    sstr << "PF\n" << width << " " << height << "\n" << endianness;
    std::string result{sstr.str()};  // "result" is an ASCII string that can
    ```

# Scrittura di dati binari

-   Il C++ non offre molti strumenti per scomporre una variabile `float` nei suoi quattro byte; usate questa implementazione e studiatela bene:

    ```c++
    #include <cstdint>  // It contains uint8_t

    enum class Endianness { little_endian, big_endian };

    void write_float(std::ofstream &stream, float value, Endianness endianness) {
      // Convert "value" in a sequence of 32 bit
      uint32_t double_word{*((uint32_t *)&value)};

      // Extract the four bytes in "double_word" using bit-level operators
      uint8_t bytes[] = {
          static_cast<uint8_t>(double_word & 0xFF),         // Least significant byte
          static_cast<uint8_t>((double_word >> 8) & 0xFF),
          static_cast<uint8_t>((double_word >> 16) & 0xFF),
          static_cast<uint8_t>((double_word >> 24) & 0xFF), // Most significant byte
      };

      switch (endianness) {
      case Endianness::little_endian:
        for (int i{}; i < 4; ++i)    // Forward loop
          stream << bytes[i];
        break;

      case Endianness::big_endian:
        for (int i{3}; i >= 0; --i)  // Backward loop
          stream << bytes[i];
        break;
      }
    }
    
    // You can use "write_float" to write little/big endian-encoded floats:
    // write_float(stream, 10.0, Endianness::little_endian);
    // write_float(stream, 10.0, Endianness::big_endian);
    ```
    
# Big/little endian?

-   Nella terza riga del file PFM bisogna scrivere `1.0` o `-1.0` a seconda della *endianness*.

-   La funzione `write_float` della slide precedente funziona sia in un caso che nell'altro, quindi potete scegliere una possibilità e usare quella.

-   Se siete curiosi, la seguente funzione restituisce `true` quando viene eseguita su un sistema *little endian*, e `false` altrimenti:

    ```c++
    bool is_little_endian() {
      uint16_t word{0x1234};
      uint8_t *ptr{(uint8_t *)&word};
    
      return ptr[0] == 0x34;
    }
    ```
    
# Indicazioni per C\#

# File e stream

-   In C\#, uno stream è di tipo `Stream`, che è una classe base da cui deriva [`FileStream`](https://docs.microsoft.com/en-us/dotnet/api/system.io.filestream?view=net-5.0) e [`MemoryStream`](https://docs.microsoft.com/en-us/dotnet/api/system.io.memorystream?view=net-5.0);

-   Per aprire un file in scrittura, usate la keyword [`using`](https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/keywords/using-statement):

    ```csharp
    var img = new HdrImage(7, 4);
    
    using (Stream fileStream = File.OpenWrite("file.pfm"))
    {
        img.SavePfm(fileStream);
    }
    ```

# Scrittura di dati binari

-   La classe [`BitConverter`](https://docs.microsoft.com/en-us/dotnet/api/system.bitconverter?view=net-5.0) implementa metodi per leggere e scrivere dati binari da stream.

-   Il seguente metodo scrive un numero floating-point a 32 bit in binario:

    ```csharp
    private static void writeFloat(Stream outputStream, float value)
    {
        var seq = BitConverter.GetBytes(value);
        outputStream.Write(seq, 0, seq.Length);
    }
    ```

-   Esiste la variabile `BitConverter.IsLittleEndian` per decidere se scrivere `1.0` o `-1.0` nel file PFM.

# Scrittura di testo

-   Il C\#, a differenza del C++, distingue tra stringhe (codificate in Unicode con UTF-16) e sequenze di byte.

-   Per scrivere correttamente l'header, la cosa più semplice è creare una stringa Unicode e poi convertirla in ASCII:

    ```csharp
    var header = Encoding.ASCII.GetBytes($"PF\n{width} {height}\n{endianness_value}\n");
    ```
    
    dove `endianness_value` è un `double` che vale `1.0` oppure `-1.0`.

# Indicazioni per Julia

# Tipo `HdrImage`

-   Potete usare una `struct` o una `mutable struct`, come preferite: gli elementi di un array `pixel` in una `struct` **possono** essere modificati.

-   Ovviamente dovrete definire *funzioni* anziché *metodi*, visto che Julia non supporta le classi OOP.

# File e stream

-   In Julia, gli stream sono rappresentati come sottotipi di `IO`.

-   Invece di definire una funzione `savepfm`, fornite una nuova definizione di [`write`](https://docs.julialang.org/en/v1/base/io-network/#Base.write) usando il *multiple dispatch*:

    ```julia
    function write(io::IO, image::HdrImage)
        # ...
    end
    ```
    
    In questo modo estenderete la funzione `write` (implementata da Julia per i tipi di base) anche al vostro tipo `HdrImage`.

# Scrittura di file binari

-   Per stabilire se la macchina è *little endian* o *big endian* c'è la costante [`ENDIAN_BOM`](https://docs.julialang.org/en/v1/base/io-network/#Base.ENDIAN_BOM):

    ```julia
    const little_endian = ENDIAN_BOM == 0x04030201
    ```
    
-   Per convertire un numero floating-point in un intero e viceversa, c'è [`reinterpret`](https://docs.julialang.org/en/v1/base/arrays/#Base.reinterpret):

    ```julia
    # On little-endian machines
    assert reinterpret(UInt32, 1.0f0) == 0x3f800000
    # On big-endian machines
    assert reinterpret(UInt32, 1.0f0) == 0x0000803f
    ```

# Conversioni

-   Si può convertire un valore intero da *big endian* o *little endian* al formato locale della macchina con le funzioni `ntoh`, `hton`, `ltoh` e `htol`.

-   La lettera `h` sta per «host», e indica la macchina su cui il programma sta girando.

-   Ovviamente su macchine *little endian* le funzioni `ltoh` e `htol` corrispondono all'identità; su macchine *big endian* ciò vale per `ntoh` e `hton`.

# Scrittura di testo

-   Le stringhe in Julia sono di tipo `String`, e sono codificate come UTF-8

-   I caratteri sono di tipo `Char`, ma a differenza del C++ sono valori a 32 bit: in altre parole, sono *code point* Unicode salvati usando UTF-32.

-   Per convertire una stringa in una sequenza di byte, usare [`transcode`](https://docs.julialang.org/en/v1/base/strings/#Base.transcode):

    ```julia
    bytebuf = transcode(UInt8, "PF\n$width $height\n$endianness\n")
    open("out.pfm", "wb") do io
        write(io, bytebuf)
        # ...
    end
    ```

# Indicazioni per Kotlin

# Tipo `HdrImage`

-   Potete crearlo con una *data class*:

    ```kotlin
    class HdrImage(val width: int, val height: int, var pixels: Array<Color>)
    ```
    
-   Per l'array di colori usate un tipo [`Array<Color>`](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin/-array/), che è funzionalmente simile a `std::vector<Color>` in C++. Attenzione alla sintassi per inizializzarlo:

    ```c++
    // Array of 5 elements, each being black
    val arr1 = Array<Color>(5) { Color(0.0f, 0.0f, 0.0f) }

    // Array of 5 elements, with shares of red of increasing brightness
    val arr2 = Array<Color>(5) { index -> Color(index, 0.0f, 0.0f) }
    ```
    
# File e stream

-   Kotlin (e Java) hanno le classi [`InputStream`](https://docs.oracle.com/javase/7/docs/api/java/io/InputStream.html) e [`OutputStream`](https://docs.oracle.com/javase/7/docs/api/java/io/OutputStream.html) (in `java.io`) per rappresentare uno stream. Queste vanno bene per i prototipi di `writeFloat` e `writePfm`.

-   Per aprire un file in scrittura c'è [`FileOutputStream`](https://docs.oracle.com/javase/7/docs/api/java/io/FileOutputStream.html), che restituisce direttamente uno stream.

-   Stream in memoria si creano con [`ByteArrayOutputStream`](https://docs.oracle.com/javase/7/docs/api/java/io/ByteArrayOutputStream.html).

-   Per aprire un file, operare su esso e chiuderlo c'è [`use`](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.io/use.html), simile a `using` in C\#:

    ```kotlin
    FileOutputStream("out.pfm").use {
        outStream -> outStream.write(...)
    }
    ```

# Scrittura di file binari

-   Per scrivere/leggere valori in formato binario c'è la classe [`ByteBuffer`](https://docs.oracle.com/javase/7/docs/api/java/nio/ByteBuffer.html) in `java.nio`:

    ```kotlin
    fun writeFloatToStream(stream: OutputStream, value: Float) {
        stream.write(ByteBuffer.allocate(4).putFloat(value).array())
    }
    ```

-   La classe `ByteBuffer` usa sempre la codifica *big endian*: questo è una fonte in meno di ambiguità. La cosa più comoda è quindi che nel vostro codice salviate sempre `1.0` nel file PFM (anziché `-1.0`).

-   Usate quindi come riferimento [`reference_be.pfm`](./media/reference_be.pfm), ed evitate `reference_fe.pfm`.

# Inizializzare `ByteBuffer`

-   I byte in Kotlin sono con segno (molto strano!)

-   Per inizializzare un array da valori esadecimali come quelli stampati da `xxd -i reference_be.pfm`, occorre una piccola funzione di aiuto:

    ```kotlin
    fun byteArrayOfInts(vararg ints: Int) = 
        ByteArray(ints.size) { pos -> ints[pos].toByte() }
    ```

# Contenuto di `reference_be.pfm`

```kotlin
val reference = byteArrayOfInts(
    0x50, 0x46, 0x0a, 0x33, 0x20, 0x32, 0x0a, 0x31, 0x2e, 0x30, 0x0a, 0x42,
    0xc8, 0x00, 0x00, 0x43, 0x48, 0x00, 0x00, 0x43, 0x96, 0x00, 0x00, 0x43,
    0xc8, 0x00, 0x00, 0x43, 0xfa, 0x00, 0x00, 0x44, 0x16, 0x00, 0x00, 0x44,
    0x2f, 0x00, 0x00, 0x44, 0x48, 0x00, 0x00, 0x44, 0x61, 0x00, 0x00, 0x41,
    0x20, 0x00, 0x00, 0x41, 0xa0, 0x00, 0x00, 0x41, 0xf0, 0x00, 0x00, 0x42,
    0x20, 0x00, 0x00, 0x42, 0x48, 0x00, 0x00, 0x42, 0x70, 0x00, 0x00, 0x42,
    0x8c, 0x00, 0x00, 0x42, 0xa0, 0x00, 0x00, 0x42, 0xb4, 0x00, 0x00
)
```

# Scrittura di testo

-   Kotlin rappresenta internamente le stringhe di caratteri usando la codifica UTF-16 (come Java).

-   Per trasformare la codifica in ASCII e poterla salvare in un file binario, si può invocare il metodo `toByteArray()`:

    ```kotlin
    val header = "PF\n$width $height\n$endianness\n"
    stream.write(header.toByteArray())
    ```
