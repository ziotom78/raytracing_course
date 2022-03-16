---
title: "Esercitazione 3"
subtitle: "Calcolo numerico per la generazione di immagini fotorealistiche"
author: "Maurizio Tomasi <maurizio.tomasi@unimi.it>"
...

# Immagini PFM

# Immagini PFM

-   La classe `HdrImage` deve essere in grado di caricare e salvare immagini su disco.

-   Siccome `HdrImage` usa floating-point per le tre componenti di colore (rosso, verde, blu), occore un formato HDR, quindi PNG, JPEG e simili non vanno bene.

-   Noi useremo il formato PFM.

# Il formato PFM

-   Scrivere file PFM è relativamente banale, perché hanno un [formato](http://www.pauldebevec.com/Research/HDR/PFM/) molto semplice

-   Un file PFM è un file **binario**, ma inizia come se fosse un file di testo (con caratteri ASCII, quindi non dobbiamo preoccuparci di Unicode):

    ```text
    PF
    width height
    ±1.0
    ```

    dove `width` ed `height` sono la larghezza (numero di colonne) e l'altezza (numero di righe) dell'immagine; seguono poi i valori RGB in binario.

-   I ritorni a capo nelle prime tre righe vanno codificati sempre e solo come `\n`.


# Il numero `±1.0`

-   La terza riga dell'header del file deve contenere un numero positivo (es., `1.0`) oppure negativo.

-   Questo numero serve per segnalare il modo in cui ciascuna delle componenti RGB di un colore (floating-point a 32 bit) viene codificata:

    1.  Un valore positivo indica che si usa la codifica *big endian*;
    2.  Un valore negativo indica che si usa la codifica *little endian*.

-   In fase di scrittura potremmo scegliere uno dei due formati e non preoccuparci troppo, ma in fase di lettura dobbiamo gestirli entrambi!

# Floating-point in binario

-   Dobbiamo però capire come salvare un floating-point in binario. In C++

    ```c++
    std::ofstream of{"file.pfm"};
    of << 1.3;
    ```
    
    stampa i caratteri «`1`», «`.`» e «`3`» (codifica testuale!).

-   Ogni linguaggio ha un approccio diverso; in Python ad esempio si usa [`struct`](https://docs.python.org/3/library/struct.html):

    ```python
    def _write_float(stream, value):
        # Meaning of "<f":
        # "<": little endian
        # "f": single-precision floating point value (32 bit)
        stream.write(struct.pack("<f", value))
    ```

# Accesso ai file in Python

<asciinema-player src="./cast/binary-text-files-75x25.cast" cols="75" rows="25" font-size="medium"></asciinema-player>


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

-   Potete pensare a un file binario come a un vettore (array monodimensionale) di byte, in sequenza uno dopo l'altro. (Un file testuale è lo stesso, ma nella codifica UTF è una sequenza di *code point* anziché byte, e la cosa è un po' più complicata).

-   I linguaggi moderni introducono una astrazione: lo *stream*. (Ahimé, non D, almeno nelle sue librerie standard!)

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
def write_pfm(self, stream, endianness=Endianness.LITTLE_ENDIAN):
    # The PFM header, as a Python string (UTF-8)
    header = f"PF\n{self.width} {self.height}\n-1.0\n"

    # Convert the header into a sequence of bytes
    stream.write(header.encode("ascii"))

    # Write the image (bottom-to-up, left-to-right)
    for y in reversed(range(self.height)):
        for x in range(self.width):
            color = self.get_pixel(x, y)
            _write_float(stream, color.r, endianness)
            _write_float(stream, color.g, endianness)
            _write_float(stream, color.b, endianness)
```

# Immagine per i test

-   Ho creato due file PFM con queste caratteristiche:

    -   Uno è codificato come *little endian* (`-1.0`), l'altro come *big endian* (`1.0`);
    -   Matrice dei colori (RGB) di dimensione 3×2 pixel:

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

buf = BytesIO()
img.write_pfm(buf, endianness=Endianness.LITTLE_ENDIAN)

with open("reference_le.pfm", "wb") as inpf:
    reference_bytes = inpf.readall()

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

# Leggere file PFM

# Lettura di file

-   Veniamo ora al problema ben più difficile della *lettura* di file

-   A differenza della scrittura, la lettura presenta più difficoltà:
    -   Il file potrebbe essere in un formato errato (problemi nella copia, estensione sbagliata, etc.);
    -   Dobbiamo essere in grado di leggere sia *little endian* che *big endian*, mentre in fase di scrittura avevamo libertà di scelta.

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
    1.  In linguaggi OOP può essere più naturale fornire un costruttore;
    2.  In linguaggi più funzionali, come Nim e Rust, basta implementare una funzione;
    3.  Se nel proprio linguaggio i costruttori esistono ma hanno limitazioni (es., in Python non si può fare overloading), implementate una funzione.

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
    
-   Questo problema si ripropone anche in Kotlin e C\#, ed è dovuto alle limitazioni del cosiddetto *constructor chaining* nei linguaggi OOP

-   In questi casi io preferisco sempre implementare un metodo separato, oppure addirittura una funzione esterna

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
-   Possiamo gestire le condizioni di errore usando le eccezioni, se il linguaggio le supporta (non è il caso di Rust).
-   Se usate le eccezioni, definite una nuova classe che sia usata per le eccezioni generate nella lettura di un file PFM.

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
    2.  Una funzione che legga una sequenza di bytes fino a `\n` (se il linguaggio non l'ha già);
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

1.  Implementate le seguenti funzioni:

    -   lettura di una sequenza di 4 byte in un floating-point a 32 bit, tenendo conto della *endianness* (`_read_float` nell'esempio Python);
    -   lettura di una sequenza di byte fino a `\n` o alla fine dello stream (`_read_line`);
    -   lettura delle dimensioni dell'immagini da una stringa (`_parse_img_size`);
    -   decodifica del tipo di *endianness* da una stringa (`_parse_endianness`).

2.  Implementate una funzione/metodo che legga un file PFM da uno *stream*.
    
3.  Implementate gli stessi test dell'esempio Python. Verificate anche che i vostri metodi segnalino correttamente gli errori.


# Suggerimenti per C\#

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


# Suggerimenti per Nim

# Librerie da usare

-   Il codice di oggi dovrebbe essere molto semplice da implementare in Nim

-   La libreria [endians](https://nim-lang.org/docs/endians.html) fornisce funzioni per convertire dati in formato *little*/*big endian*

-   La libreria [streams](https://nim-lang.org/docs/streams.html) implementa il concetto di *stream* sia associato ad un file che ad una stringa in memoria


# Suggerimenti per Rust

# Uso di `enum` e `match`

-   Per specificare la *endianness* c'è il tipo [`ByteOrder`](https://docs.rs/endianness/latest/endianness/enum.ByteOrder.html) nella crate [endianness](https://docs.rs/endianness/latest/endianness/)
    
-   Con gli `enum` abituatevi ad usare `match` anziché `if`:

    ```rust
    fn endianness_number(endianness: &ByteOrder) -> f32 {
        match endianness {
            ByteOrder::LittleEndian => -1.0,
            ByteOrder::BigEndian => 1.0,
        }
    }
    ```

# Stream

-   Usate i *traits* `Write` e `Read` per definire le funzioni che leggono e scrivono su uno stream. Ad esempio:

    ```rust
    fn write_float<T: Write>(
        dest: &mut T, 
        value: f32, 
        endianness: &Endianness,
    ) -> std::io::Result<usize> {
        match endianness {
            Endianness::LittleEndian => dest.write(&value.to_le_bytes()),
            Endianness::BigEndian => dest.write(&value.to_be_bytes()),
        }
    }
    ```

-   Potete rendere il codice più veloce usando [`BufWriter` e `BufReader`](https://doc.rust-lang.org/nightly/std/io/index.html#bufreader-and-bufwriter), ma non è necessario (non sarà certo questo il collo di bottiglia!).

# Suggerimenti per D

# Stream

-   Purtroppo la versione più recente del linguaggio D [non supporta gli stream](https://forum.dlang.org/post/mailman.797.1513034483.9493.digitalmars-d-learn@puremagic.com) in maniera nativa

-   Ma non è un grosso danno, perché potete usare sequenze di byte dinamiche come `ubyte[]`; per la scrittura è ancora meglio un [`Appender`](https://dlang.org/library/std/array/appender.html) (più efficiente), oppure [`outbuffer`](https://dlang.org/phobos/std_outbuffer.html)

-   Il linguaggio fornisce il tipo [Endian](https://dlang.org/library/std/system/endian.html) e la libreria [std.bitmanip](https://dlang.org/phobos/std_bitmanip.html) che fornisce la funzione template `append`:

    ```d
    auto stream = appender!(ubyte[])();
    float value = 123.456;
    // uint is a 4-byte integer
    append!(uint, Endian.bigEndian)(stream, *cast(uint*)(&value));
    ```


# Suggerimenti per Kotlin

   
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

-   La *endianness* è identificata dal tipo [`ByteOrder`](https://docs.oracle.com/javase/7/docs/api/java/nio/ByteOrder.html) in `java.nio` (una classe Java: in Kotlin si possono usare nativamente librerie Java)

-   Per scrivere/leggere valori in formato binario c'è la classe [`ByteBuffer`](https://docs.oracle.com/javase/7/docs/api/java/nio/ByteBuffer.html), sempre in `java.nio`:

    ```kotlin
    fun writeFloatToStream(stream: OutputStream, value: Float, order: ByteOrder) {
        val bytes = ByteBuffer.allocate(4).putFloat(value).array() // Big endian
        
        if (order == ByteOrder.LITTLE_ENDIAN) {
            bytes.reverse()
        }
        
        stream.write(bytes)
    }
    ```

# Inizializzare `ByteBuffer`

-   I byte in Kotlin sono con segno (molto strano!)

-   Per inizializzare un array da valori esadecimali come quelli stampati da `xxd -i reference_be.pfm`, occorre una piccola funzione di aiuto:

    ```kotlin
    fun byteArrayOfInts(vararg ints: Int) = 
        ByteArray(ints.size) { pos -> ints[pos].toByte() }
    ```

# Contenuto di `reference_be.pfm`

```kotlin
val reference_be = byteArrayOfInts(
    0x50, 0x46, 0x0a, 0x33, 0x20, 0x32, 0x0a, 0x31, 0x2e, 0x30, 0x0a, 0x42,
    0xc8, 0x00, 0x00, 0x43, 0x48, 0x00, 0x00, 0x43, 0x96, 0x00, 0x00, 0x43,
    0xc8, 0x00, 0x00, 0x43, 0xfa, 0x00, 0x00, 0x44, 0x16, 0x00, 0x00, 0x44,
    0x2f, 0x00, 0x00, 0x44, 0x48, 0x00, 0x00, 0x44, 0x61, 0x00, 0x00, 0x41,
    0x20, 0x00, 0x00, 0x41, 0xa0, 0x00, 0x00, 0x41, 0xf0, 0x00, 0x00, 0x42,
    0x20, 0x00, 0x00, 0x42, 0x48, 0x00, 0x00, 0x42, 0x70, 0x00, 0x00, 0x42,
    0x8c, 0x00, 0x00, 0x42, 0xa0, 0x00, 0x00, 0x42, 0xb4, 0x00, 0x00
)
```

Fate lo stesso con `reference_le.pfm`.

# Scrittura di testo

-   Kotlin rappresenta internamente le stringhe di caratteri usando la codifica UTF-16 (come Java).

-   Per trasformare la codifica in ASCII e poterla salvare in un file binario, si può invocare il metodo `toByteArray()`:

    ```kotlin
    val header = "PF\n$width $height\n$endianness\n"
    stream.write(header.toByteArray())
    ```
