---
title: "Esercitazione 4"
subtitle: "Calcolo numerico per la generazione di immagini fotorealistiche"
author: "Maurizio Tomasi <maurizio.tomasi@unimi.it>"
...

# Repository GitHub

# Il progetto `pytracer`

-   Ho creato un repository GitHub con l'implementazione di riferimento in Python: [github.com/ziotom78/pytracer](https://github.com/ziotom78/pytracer)
-   D'ora in poi aggiornerò il codice sul sito ogni settimana, in occasione delle esercitazioni.
-   È un buon esempio per chi è interessato a capire come strutturare un progetto in Python.

# Leggere file PFM

# Lettura di file

-   Settimana scorsa avete implementato un codice per salvare i file
    PFM; oggi implementiamo funzioni che li leggano.
-   A differenza della *scrittura* di un file, la lettura presenta più difficoltà:
    -   Il file potrebbe essere in un formato errato (problemi nella copia, estensione sbagliata, etc.);
    -   Dobbiamo essere in grado di leggere sia *little endian* che *big endian*.

# Costruttore o funzione?

-   Si può implementare la lettura di un file PFM in un costruttore (esempio in C++):

    ```c++
    struct HdrImage {
        HdrImage image(std::istream & stream);
        // ...
    };
    
    std::ifstream myfile{"input.pfm"};
    HdrImage img{myfile};
    ```

-   Ma si può anche pensare di implementare una funzione `read_pfm_file`:

    ```c++
    HdrImage read_pfm_file(std::istream & stream);
    
    std::ifstream myfile{"input.pfm"};
    HdrImage img{read_pfm_file(myfile)};
    ```

# Scelta della API

-   Il problema di scegliere tra le due possibilità riguarda la scelta della [API](./tomasi-ray-tracing-03b-image-files.html#/api-di-hdrimage).

-   La scelta dipende dal gusto personale e da altri possibili fattori:
    1.  In linguaggi OOP come il C\#, è più naturale fornire un costruttore;
    2.  In linguaggi come il Python non è possibile fare l'overloading di costruttori, quindi è meglio implementare una funzione (come faccio nel mio codice);
    3.  Se pensassimo in futuro di voler implementare la lettura di più file immagine, una funzione permette di differenziare i formati (ma non è molto utile):
    
        ```c++
        HdrImage read_pfm_file(std::istream & stream);
        HdrImage read_openexr_file(std::istream & stream);
        ```

# Stream e file

-   Nelle slide precedenti l'interfaccia in C++ per leggere un file è attraverso uno *stream* `std::istream`;
-   Come abbiamo visto, l'uso di stream semplifica la scrittura dei test (che non sono obbligati ad accedere al disco);
-   Garantisce anche maggiore versatilità: invece di leggere l'immagine da un file, potremmo leggerla da una connessione internet, o da un file compresso con GZip:

    ```python
    import gzip
    
    with gzip.open("image_file.pfm.gz", "rb") as inpf:
        read_pfm_file(inpf)
    ```
    
# Lettura diretta di file
    
-   È però innegabile che sarebbe comodo poter aprire un file anche così:

    ```python
    # How handy!
    image = read_pfm_file("image_file.pfm")
    ```
    
-   In C++ si potrebbe usare l'overloading per definire un nuovo costruttore:

    ```c++
    struct HdrImage {
        // Read a PFM file from a stream
        HdrImage(std::istream & stream);
        
        // Open a PFM file and read the stream of bytes from it
        HdrImage(const std::string & file_name)
        : this(std::ifstream{file_name}) { }
    };
    ```

# Stream e nomi di file

-   Purtroppo il codice C++ però è **errato** e non compila!

-   L'oggetto `std::ifstream` creato nel secondo costruttore è temporaneo e non può essere passato al primo costruttore:

    ```text
    $ g++ -c hdrimages.cpp
    hdrimages.cpp: In constructor ‘HdrImage::HdrImage(const string&)’:
    hdrimages.cpp:33:58: error: cannot bind non-const lvalue reference of type ‘std::istream&’ {aka ‘std::basic_istream<char>&’} to an rvalue of type ‘std::basic_istream<char>’
    ```
    
-   Questo problema si ripropone anche in Kotlin e C\#, ed è dovuto alle limitazioni del cosiddetto *constructor chaining* nei linguaggi OOP (Julia viene risparmiato  semplicemente perché non è un linguaggio object-oriented, e i costruttori sono implementati come semplici funzioni).

# Risolvere il dilemma

```c++
struct HdrImage {
private:
    // Put the code that reads the PFM file in a separate method
    void read_pfm_file(std::istream & stream);

public:
    // First constructor: invoke `read_pfm_file`
    HdrImage(std::istream & stream) { read_pfm_file(stream); }

    // Second constructor: again, invoke `read_pfm_file`
    HdrImage(const std::string & file_name) {
        std::ifstream stream{file_name};
        read_pfm_file(stream);
    }
};
```

# Regola d'oro della OOP

-   (I programmatori Julia si tappino le orecchie).

-   Mai, **mai** mettere codice complicato in un costruttore.

-   Molto meglio spostare inizializzazioni complesse in metodi privati, che vengono poi invocati corrispondentemente nel costruttore.

# Il formato PFM

-   Ricordiamo com'è fatto il formato PFM:

    ```text
    PF
    width height
    ±1.0
    <binary data>
    ```
    
-   Il codice di lettura deve verificare le seguenti cose:

    1.  Il file deve iniziare con `PF\n`, altrimenti non è in formato PFM;
    2.  La seconda riga deve contenere due numeri interi positivi;
    3.  La terza riga deve contenere `1.0` o `-1.0`;
    4.  I dati binari devono essere in numero sufficiente; nello specifico, ci aspettiamo $\text{width} \times \text{height}$ pixel, ciascuno composto da tre componenti (R, G, B) da 4 byte ciascuno, per un totale di $12 \times \text{width} \times \text{height}$ byte.
  
# Gestione degli errori

-   La funzione che legge un file deve essere in grado di gestire condizioni di errore.
-   Abbiamo visto nella lezione di teoria che gli errori in una funzione di libreria non deve fare nulla di **distruttivo** né di **visibile**, perché non si può sapere a priori se l'errore è stato causato dal programmatore stesso o dall'utente.
-   Possiamo gestire le condizioni di errore usando le eccezioni, se il linguaggio le supporta (è il caso di C++, C\#, Julia e Kotlin).
-   La cosa migliore da fare è definire una nuova classe che sia usata per le eccezioni generate nella lettura di un file PFM.

# `InvalidPfmFileFormat`

-   In Python basta creare una classe derivata da `Exception`:

    ```python
    class InvalidPfmFileFormat(Exception):
        def __init__(self, error_message: str):
            super().__init__(error_message)
    ```
    
    Notate che accettiamo un messaggio d'errore, in modo da identificare meglio quale problema sia sorto nella lettura del file PFM.
    
-   Se possibile, seguite la stessa strategia per il vostro linguaggio, avendo magari l'accortezza di derivare la classe da un'eccezione preesistente adatta al contesto (es., `System.FormatException` in C\#, `RuntimeException` in Kotlin).

# Condizioni di errore

-   Se gestiamo le condizioni di errore usando le eccezioni, possiamo decidere come gestire gli errori in funzione del contesto.

-   Ad esempio, in un `main` che vuole aprire un file PFM passato dall'utente:

    ```python
    filename = sys.argv[1]
    try:
        with open(filename, "rb") as inpf:
            image = read_pfm_file(inpf)
    except InvalidPfmFileFormat as err:
        printf(f"impossible to open file {filename}, reason: {err}")
    ```
    
-   In uno *unit test* che deve aprire un file contenente dati di riferimento, **non** cattureremmo l'eccezione in un `try … except`.

# Altre eccezioni

-   Per interpretare un file PFM dovremo invocare funzioni della libreria standard del nostro linguaggio:

    -   Leggere da uno *stream*;
    -   Interpretare una stringa di byte come un numero (es., `320`);

-   In caso di errori, le stesse funzioni di base del linguaggio possono emettere delle eccezioni (es., `ValueError` se in Python si cerca di convertire in intero una stringa come `hello, world!`).

-   Dobbiamo assicurarci di «catturare» queste eccezioni e convertirle in `InvalidPfmFileFprmat`, altrimenti il codice nella slide precedente non funzionerebbe più.

# Esempio

<asciinema-player src="./cast/catching-exceptions-78x25.cast" cols="78" rows="25" font-size="medium"></asciinema-player>

# Scrittura di test

-   Abbiamo visto nella scorsa lezione che è più facile scrivere test per funzioni di dimensioni ridotte.

-   Nel nostro caso, la lettura di un file PFM potrebbe appoggiarsi alle seguenti funzioni:

    1.  Una funzione che legga un floating-point a 32 bit;
    2.  Una funzione che legga una sequenza di bytes fino a `\n`;
    3.  Una funzione che interpreti la riga con la dimensione dell'immagine;
    4.  Una funzione che determini la *endianness* del file.
    
    Ognuna di queste funzioni può essere testata in uno [*unit test*](./tomasi-ray-tracing-03b-image-files.html#/test) dedicato.


# Funzioni di supporto (1/4)

```python
def _read_line(stream):
    result = b""
    while True:
        cur_byte = stream.read(1)
        if cur_byte in [b"", b"\n"]:
            return result.decode("ascii")

        result += cur_byte
```

# Test (1/4)

```python
def test_pfm_read_line():
    line = BytesIO(b"hello\nworld")
    assert _read_line(line) == "hello"
    assert _read_line(line) == "world"
    assert _read_line(line) == ""
```

# Funzioni di supporto (2/4)

```python
_FLOAT_STRUCT_FORMAT = {
    Endianness.LITTLE_ENDIAN: "<f",
    Endianness.BIG_ENDIAN: ">f",
}

# This function is meant to be used with PFM files only! It raises a
# InvalidPfmFileFormat exception if not enough bytes are available.
def _read_float(stream, endianness=Endianness.LITTLE_ENDIAN):
    format_str = _FLOAT_STRUCT_FORMAT[endianness]

    try:
        return struct.unpack(format_str, stream.read(4))[0]
        
    except struct.error:
        # Capture the exception and convert it in a more appropriate type
        raise InvalidPfmFileFormat("impossible to read binary data from the file")
```

# Test (2/4)

-   Per `_read_float` possiamo evitare di implementare dei test: è una funzione che agisce semplicemente da *wrapper* a una funzione standard della libreria Python.

-   Verificheremo comunque il suo comportamento quando testeremo la lettura di un file PFM dall'inizio alla fine.

# Funzioni di supporto (3/4)

```python
def _parse_endianness(line: str):
    try:
        value = float(line)
    except ValueError:
        raise InvalidPfmFileFormat("missing endianness specification")

    if value == 1.0:
        return Endianness.BIG_ENDIAN
    elif value == -1.0:
        return Endianness.LITTLE_ENDIAN
    else:
        raise InvalidPfmFileFormat("invalid endianness specification")
```

# Test (3/4)

```python
def test_pfm_parse_endianness():
    assert _parse_endianness("1.0") == Endianness.BIG_ENDIAN
    assert _parse_endianness("-1.0") == Endianness.LITTLE_ENDIAN

    # We must test that the function properly raises an exception when
    # wrong input is passed. Here we use the "pytest" framework to do this.
    with pytest.raises(InvalidPfmFileFormat):
        _ = _parse_endianness("2.0")

    with pytest.raises(InvalidPfmFileFormat):
        _ = _parse_endianness("abc")
```

# Funzioni di supporto (4/4)

```python
def _parse_img_size(line: str):
    elements = line.split(" ")
    if len(elements) != 2:
        raise InvalidPfmFileFormat("invalid image size specification")

    try:
        width, height = (int(elements[0]), int(elements[1]))
        if (width < 0) or (height < 0):
            raise ValueError()
    except ValueError:
        raise InvalidPfmFileFormat("invalid width/height")

    return width, height
```

# Test (4/4)

```python
def test_pfm_parse_img_size():
    assert _parse_img_size("3 2") == (3, 2)

    with pytest.raises(InvalidPfmFileFormat):
        _ = _parse_img_size("-1 3")

    with pytest.raises(InvalidPfmFileFormat):
        _ = _parse_img_size("3 2 1")
```

# `read_pfm_image`

```python
def read_pfm_image(stream):
    # The first bytes in a binary file are usually called «magic bytes»
    magic = _read_line(stream)
    if magic != "PF":
        raise InvalidPfmFileFormat("invalid magic in PFM file")

    img_size = _read_line(stream)
    (width, height) = _parse_img_size(img_size)

    endianness_line = _read_line(stream)
    endianness = _parse_endianness(endianness_line)

    result = HdrImage(width=width, height=height)
    for y in range(height - 1, -1, -1):
        for x in range(width):
            (r, g, b) = [_read_float(stream, endianness) for i in range(3)]
            result.set_pixel(x, y, Color(r, g, b))

    return result
```

# Integration test

-   Abbiamo implementato test per tutte le funzioni su cui è costruita `read_pfm_image`: `_read_line`, `_parse_endianness`, etc.

-   Ma chi ci dice che abbiamo combinato bene le funzioni tra loro?

-   È necessario andare oltre gli *unit test*, ed eseguire un test che metta in moto tutto il macchinario dall'inizio alla fine.

-   Un test su una funzione complessa, che invoca funzioni semplici già testate, si dice *integration test*.

-   Nello specifico, il nostro test deve verificare il funzionamento su file *little endian* ([`reference_le.pfm`](./media/reference_le.pfm)), su file *big endian* ([`reference_be.pfm`](./media/reference_be.pfm)), e anche su file errati.

# Test per `read_pfm_file`

```python
# This is the content of "reference_le.pfm" (little-endian file)
LE_REFERENCE_BYTES = bytes([
    0x50, 0x46, 0x0a, 0x33, 0x20, 0x32, 0x0a, 0x2d, 0x31, 0x2e, 0x30, 0x0a,
    0x00, 0x00, 0xc8, 0x42, 0x00, 0x00, 0x48, 0x43, 0x00, 0x00, 0x96, 0x43,
    0x00, 0x00, 0xc8, 0x43, 0x00, 0x00, 0xfa, 0x43, 0x00, 0x00, 0x16, 0x44,
    0x00, 0x00, 0x2f, 0x44, 0x00, 0x00, 0x48, 0x44, 0x00, 0x00, 0x61, 0x44,
    0x00, 0x00, 0x20, 0x41, 0x00, 0x00, 0xa0, 0x41, 0x00, 0x00, 0xf0, 0x41,
    0x00, 0x00, 0x20, 0x42, 0x00, 0x00, 0x48, 0x42, 0x00, 0x00, 0x70, 0x42,
    0x00, 0x00, 0x8c, 0x42, 0x00, 0x00, 0xa0, 0x42, 0x00, 0x00, 0xb4, 0x42
])

# This is the content of "reference_be.pfm" (big-endian file)
BE_REFERENCE_BYTES = bytes([
    0x50, 0x46, 0x0a, 0x33, 0x20, 0x32, 0x0a, 0x31, 0x2e, 0x30, 0x0a, 0x42,
    0xc8, 0x00, 0x00, 0x43, 0x48, 0x00, 0x00, 0x43, 0x96, 0x00, 0x00, 0x43,
    0xc8, 0x00, 0x00, 0x43, 0xfa, 0x00, 0x00, 0x44, 0x16, 0x00, 0x00, 0x44,
    0x2f, 0x00, 0x00, 0x44, 0x48, 0x00, 0x00, 0x44, 0x61, 0x00, 0x00, 0x41,
    0x20, 0x00, 0x00, 0x41, 0xa0, 0x00, 0x00, 0x41, 0xf0, 0x00, 0x00, 0x42,
    0x20, 0x00, 0x00, 0x42, 0x48, 0x00, 0x00, 0x42, 0x70, 0x00, 0x00, 0x42,
    0x8c, 0x00, 0x00, 0x42, 0xa0, 0x00, 0x00, 0x42, 0xb4, 0x00, 0x00
])

def test_pfm_read(self):
    for reference_bytes in [LE_REFERENCE_BYTES, BE_REFERENCE_BYTES]:
        img = read_pfm_image(BytesIO(reference_bytes))
        assert img.width == 3
        assert img.height == 2

        assert img.get_pixel(0, 0).is_close(Color(1.0e1, 2.0e1, 3.0e1))
        assert img.get_pixel(1, 0).is_close(Color(4.0e1, 5.0e1, 6.0e1))
        assert img.get_pixel(2, 0).is_close(Color(7.0e1, 8.0e1, 9.0e1))
        assert img.get_pixel(0, 1).is_close(Color(1.0e2, 2.0e2, 3.0e2))
        assert img.get_pixel(0, 0).is_close(Color(1.0e1, 2.0e1, 3.0e1))
        assert img.get_pixel(1, 1).is_close(Color(4.0e2, 5.0e2, 6.0e2))
        assert img.get_pixel(2, 1).is_close(Color(7.0e2, 8.0e2, 9.0e2))

def test_pfm_read_wrong(self):
    buf = BytesIO(b"PF\n3 2\n-1.0\nstop")
    with pytest.raises(InvalidPfmFileFormat):
        _ = read_pfm_image(buf)
```

# Guida per l'esercitazione

# Guida per l'esercitazione

1.  Implementate un costruttore `HdrImage::HdrImage` o una funzione `read_pfm_file` che legga un file PFM da uno *stream*.

2.  Per implementare la lettura di file PFM, implementate le seguenti funzioni:

    -   lettura di una sequenza di 4 byte in un floating-point a 32 bit, tenendo conto della *endianness* (`_read_float` nell'esempio Python);
    -   lettura di una sequenza di byte fino a `\n` o alla fine dello stream (`_read_line`);
    -   lettura delle dimensioni dell'immagini da una stringa (`_parse_img_size`);
    -   decodifica del tipo di *endianness* da una stringa (`_parse_endianness`).
    
3.  Implementate gli stessi test dell'esempio Python. Verificate anche che i vostri metodi segnalino correttamente gli errori.

# Lavoro in gruppo

-   Potete dividere facilmente il lavoro tra di voi se distribuite tra voi le funzioni di base elencate nella slide precedente.

-   A differenza delle lezioni passate, oggi è però importante che chi implementa una funzione scriva anche i test corrispondenti di quella funzione.

-   Uno di voi si preoccupi anche di scrivere un `README`, e di fornire il repository di una licenza, il cui tipo (MIT, BSD, GPL, etc.) dovrete decidere insieme.

# Link a Gather

Useremo il solito link: [gather.town/app/CgOtJvyNfVKMIQ9e/LaboratorioRayTracing](https://gather.town/app/CgOtJvyNfVKMIQ9e/LaboratorioRayTracing)
