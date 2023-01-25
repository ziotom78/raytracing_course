---
title: "Esercitazione 4"
subtitle: "Calcolo numerico per la generazione di immagini fotorealistiche"
author: "Maurizio Tomasi <maurizio.tomasi@unimi.it>"
...

# Scrittura di immagini LDR

# Interfaccia del programma

-   Oggi implementeremo il codice del nostro programma (`main.py` nella versione Python).

-   Il funzionamento del programma in questa versione sarà il seguente:

    ```text
    $ ./main.py input_file.pfm 0.3 1.0 output_file.png
    File 'input_file.pfm' has been read from disk
    File 'output_file.png' has been written to disk
    $
    ```

-   Lo scopo è quello di convertire un file PFM in un file PNG (o nel formato LDR che preferite). I valori `0.3` e `1.0` fanno riferimento al [fattore di scala](./tomasi-ray-tracing-05b-external-libraries.html#/normalizzazione) $a$ e a $\gamma$, rispettivamente.

# Implementazione

Le attività da compiere sul codice sono le seguenti:

#.   Definire una funzione che calcoli la luminosità di un oggetto `Color`;
#.   Definire una funzione che calcoli la luminosità media di un `HdrImage`;
#.   Definire una funzione che normalizzi i valori di un `HdrImage` usando una certa luminosità media, opzionalmente passata come argomento;
#.   Definire una funzione che applichi la correzione per le sorgenti luminose;
#.   Implementare il `main` nel codice dell'applicazione.

# Luminosità (1/2)

-   Aggiungiamo un semplice metodo `luminosity` alla classe `Color`, che restituisce il valore della luminosità suggerito da Shirley & Morley:

    ```python
    class Color:
        # ...

        def luminosity(self):
            return (max(self.r, self.g, self.b) + min(self.r, self.g, self.b)) / 2
    ```

-   Se nel vostro linguaggio l'equivalente di `max` e `min` accetta solo due parametri (es., `minOf` e `maxOf` in Kotlin), potete usare l'equivalenza

    $$
    \max\left\{a, b, c\right\} \equiv \max\bigl\{\max\left\{a, b\right\}, c\bigr\}.
    $$

# Luminosità (2/2)

-   Occorrono anche alcuni test per `Color.luminosity`:

    ```python
    def test_luminosity():
        col1 = Color(1.0, 2.0, 3.0)
        col2 = Color(9.0, 5.0, 7.0)

        assert pytest.approx(2.0) == col1.luminosity()
        assert pytest.approx(7.0) == col2.luminosity()
    ```

-   Il metodo `pytest.approx()` fa parte della libreria `pytest`, e corrisponde alla funzione `is_close` che avete implementato tempo fa.

# Luminosità media (1/2)

```python
class HdrImage:
    # ...

    def average_luminosity(self, delta=1e-10):
        cumsum = 0.0
        for pix in self.pixels:
            cumsum += math.log10(delta + pix.luminosity())

        return math.pow(10, cumsum / len(self.pixels))
```

# Luminosità media (2/2)

```python
def test_average_luminosity():
    img = HdrImage(2, 1)

    img.set_pixel(0, 0, Color(  5.0,   10.0,   15.0))  # Luminosity: 10.0
    img.set_pixel(1, 0, Color(500.0, 1000.0, 1500.0))  # Luminosity: 1000.0

    print(img.average_luminosity(delta=0.0))
    assert pytest.approx(100.0) == img.average_luminosity(delta=0.0)
```

# Normalizzazione (1/3)

-   La funzione `normalize_image` calcola la luminosità media di un'immagine secondo l'[equazione corrispondente](tomasi-ray-tracing-05b-external-libraries.html#/normalizzazione).

-   La funzione dovrebbe accettare il valore di $a$ come parametro di input:

    ```python
    def normalize_image(self, factor, luminosity=None):
        if not luminosity:
            luminosity = self.average_luminosity()

        for i in range(len(self.pixels)):
            self.pixels[i] = self.pixels[i] * (factor / luminosity)
    ```

# Normalizzazione (2/3)

-   È bene accettare la luminosità come parametro anziché calcolarla:

    -   Nei test, ci può fare comodo passare diversi valori per la luminosità;
    -   L'utente potrebbe voler specificare questo valore.

-   Se il vostro linguaggio supporta i tipi opzionali, potete chiamare la funzione `average_luminosity` se il parametro luminosità è nullo:

    ```csharp
    // This is C#; in Kotlin it's almost the same.
    public void NormalizeImage(float factor, float? luminosity = null)
    {
        // In Kotlin use "?:" instead of "??"
        var lum = luminosity ?? AverageLuminosity();
        for (int i = 0; i < pixels.Length; ++i) { /* ... */ }
    }
    ```

# Normalizzazione (3/3)

```python
def test_normalize_image():
    img = HdrImage(2, 1)

    img.set_pixel(0, 0, Color(  5.0,   10.0,   15.0))
    img.set_pixel(1, 0, Color(500.0, 1000.0, 1500.0))

    img.normalize_image(factor=1000.0, luminosity=100.0)
    assert img.get_pixel(0, 0).is_close(Color(0.5e2, 1.0e2, 1.5e2))
    assert img.get_pixel(1, 0).is_close(Color(0.5e4, 1.0e4, 1.5e4))
```

# Punti luminosi (1/2)

```python
def _clamp(x: float) -> float:
    return x / (1 + x)

class HdrImage:
    # ...

    def clamp_image(self):
        for i in range(len(self.pixels)):
            self.pixels[i].r = _clamp(self.pixels[i].r)
            self.pixels[i].g = _clamp(self.pixels[i].g)
            self.pixels[i].b = _clamp(self.pixels[i].b)
```

# Punti luminosi (2/2)

```python
def test_clamp_image():
    img = HdrImage(2, 1)

    img.set_pixel(0, 0, Color(0.5e1, 1.0e1, 1.5e1))
    img.set_pixel(1, 0, Color(0.5e3, 1.0e3, 1.5e3))

    img.clamp_image()

    # Just check that the R/G/B values are within the expected boundaries
    for cur_pixel in img.pixels:
        assert (cur_pixel.r >= 0) and (cur_pixel.r <= 1)
        assert (cur_pixel.g >= 0) and (cur_pixel.g <= 1)
        assert (cur_pixel.b >= 0) and (cur_pixel.b <= 1)
```


# Gestione di dipendenze

# Gestione di dipendenze

-   Implementare il codice per salvare un'immagine in uno dei formati LDR più diffusi (PNG, JPEG, TIFF, WebP) sarebbe interessantissimo, ma molto complesso!
-   Implementeremo questa funzionalità appoggiandoci a una libreria esterna
-   In questo modo impareremo come il linguaggio che stiamo usando consente di gestire le dipendenze

# Librerie di sistema

<center>![](media/dependencies-simple.svg)</center>

-   Questo genere di librerie di solito si installano usando in qualche modo `sudo`, come ad esempio `./configure && make && sudo make install`

-   Esempio: installare ROOT sul proprio sistema per lavorare alle esercitazioni di TNDS!

# Librerie di sistema

Capita però spesso che si debbano usare librerie *incompatibili* nei propri codici! Supponiamo di avere numerosi oscilloscopi in un laboratorio di elettronica, e che usiamo la libreria `oscilloscope` per analizzarne le misure:

-   Sinora abbiamo utilizzato la versione 2.4 per scrivere molti codici di analisi usati regolarmente

-   È però uscita ormai da un po' la versione 3.0 di `oscilloscope`, che ha nuove funzionalità interessanti, ma non ho ancora fatto l'aggiornamento perché è incompatibile con la versione 2.4!
    
-   Sta per uscire la versione 4.0, ancora più potente, ma non supporterà più uno dei miei vecchi oscilloscopi, che mi è ancora indispensabile.

# Possibili soluzioni

-   Il modo più primitivo di risolvere il problema è di tenere svariati computer in laboratorio, ciascuno con la propria versione di `oscilloscope`

-   Un modo un po' più comodo consiste nel creare varie *virtual machine*

-   Ormai da una decina d'anni hanno preso piede i *container* (es. [Docker](https://www.docker.com/), [Podman](https://podman.io/), [Singularity](https://sylabs.io/singularity)), che sono macchine virtuali «leggere»: sono meno versatili, ma il tempo di avvio è praticamente zero

-   Ciascuna di queste soluzioni rende però complicato scambiare dati tra programmi che usano librerie diverse (ad esempio, per sovrapporre il plot di una curva di un oscilloscopio con quella di un altro) ed installare nuove versioni

# Esempio

```
# Install GCC 10 and the C++ library Healpix version 3.70
Bootstrap: docker
From: ubuntu:20.04

%runscript
        exec /usr/bin/g++-10 "$@"

%post

        apt-get update
        DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata
        apt-get install -y build-essential gcc-10 g++-10 cmake curl libcfitsio-dev

        echo "export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH" >> $SINGULARITY_ENVIRONMENT

        curl -L "https://downloads.sourceforge.net/project/healpix/Healpix_3.70/Healpix_3.70_2020Jul23.tar.gz" > healpix.tar.gz
        tar xvf healpix.tar.gz
        (cd Healpix_3.70 && ./configure --auto=cxx && make -j 4)
```

Questo file viene «compilato» dall'eseguibile `singularity`, che produce un file eseguibile di ~200 MB contenente il comando `g++-10` insieme al sistema operativo Ubuntu Linux 20.04.

---

<asciinema-player src="cast/singularity-90x19.cast" cols="90" rows="19" font-size="medium"></asciinema-player>


# Librerie locali

Le librerie locali risolvono questi problemi perché non vengono installate a livello di sistema, ma sono legate a un singolo *repository*:

<center>![](media/dependencies-complex.svg)</center>

-   Esempio: copia di una libreria *header-only* nel proprio progetto C++

-   Esempio: [*virtual environment*](https://docs.python.org/3/tutorial/venv.html) in Python

# Gestione di dipendenze

-   Tutti i linguaggi moderni supportano una gestione di librerie «locali»

-   Queste funzionalità sono solitamente implementate nei programmi che avete usato sinora per creare progetti (`dotnet`, `dub`, `nimble`, `cargo`…)

-   Scegliete quindi una libreria che supporti la *scrittura* di immagini LDR e importatela nel vostro progetto come una dipendenza **locale** (niente `sudo`!)

-   L'uso di librerie locali ci aiuterà molto quando affronteremo la *continuous integration*.

# Produzione di immagini LDR

# Conversione a LDR (1/3)

-   Una volta applicata `normalize_image` e `clamp_image`, tutte le componenti RGB dei colori nella matrice saranno nell'intervallo [0, 1].
-   A questo punto la conversione nello spazio sRGB avviene tramite la [solita formula con γ](tomasi-ray-tracing-05b-ci-builds.html#/correzione-%CE%B3).
-   Il risultato della conversione è una matrice che va salvata in un formato grafico LDR: PNG, JPEG, WebP…
-   Per il salvataggio dovete scegliere una libreria appropriata.

# Conversione a LDR (2/3)

| Linguaggio | Librerie                                                                                               |
|------------|--------------------------------------------------------------------------------------------------------|
| C\#        | [ImageSharp](https://docs.sixlabors.com/articles/imagesharp/?tabs=tabid-1)                             |
| D          | [imageformats](https://code.dlang.org/packages/imageformats)                                           |
| Kotlin     | [javax.imageio](https://docs.oracle.com/javase/8/docs/api/javax/imageio/ImageIO.html) (già installato) |
| Nim        | [simplepng](https://github.com/jrenner/nim-simplepng)                                                  |
| Python     | [Pillow](https://pillow.readthedocs.io/en/stable/)                                                     |
| Rust       | [image](https://crates.io/crates/image)                                                                |

Potete scegliere altre librerie, ma attenzione a scegliere quelle pixel-based!

# Cosa ci serve

Scegliete una libreria LDR che abbia queste caratteristiche:

-   Creazione di una immagine specificando numero di colonne (`width`) e numero di righe (`height`)
-   Impostazione del valore sRGB di un pixel date le sue coordinate `x` e `y`
-   Salvataggio dell'immagine in un formato grafico diffuso
-   Fate molta attenzione al sistema di coordinate: il pixel a `(0, 0)` è in alto a sinistra? in basso a sinistra? oppure…?

# Conversione a LDR (3/3)

```python
class HdrImage:
    # ...

    def write_ldr_image(self, stream, format, gamma=1.0):
        from PIL import Image
        img = Image.new("RGB", (self.width, self.height))

        for y in range(self.height):
            for x in range(self.width):
                cur_color = self.get_pixel(x, y)
                img.putpixel(xy=(x, y), value=(
                        int(255 * math.pow(cur_color.r, 1 / gamma)),
                        int(255 * math.pow(cur_color.g, 1 / gamma)),
                        int(255 * math.pow(cur_color.b, 1 / gamma)),
                ))

        img.save(stream, format=format)
```

# Funzione `main` (1/2)

```python
from dataclasses import dataclass

@dataclass
class Parameters:
    input_pfm_file_name: str = ""
    factor:float = 0.2
    gamma:float = 1.0
    output_png_file_name: str = ""

    def parse_command_line(self, argv):
        if len(sys.argv) != 5:
            raise RuntimeError("Usage: main.py INPUT_PFM_FILE FACTOR GAMMA OUTPUT_PNG_FILE")

        self.input_pfm_file_name = sys.argv[1]

        try:
            self.factor = float(sys.argv[2])
        except ValueError:
            raise RuntimeError(f"Invalid factor ('{sys.argv[2]}'), it must be a floating-point number.")

        try:
            self.gamma = float(sys.argv[3])
        except ValueError:
            raise RuntimeError(f"Invalid gamma ('{sys.argv[3]}'), it must be a floating-point number.")

        self.output_png_file_name = sys.argv[4]
```

(Anziché usare variabili globali per i parametri letti da `argv`, uso una `struct` che poi passo alle varie funzioni: è più facile scrivere test!)

# Funzione `main` (2/2)

```python
def main(argv):
    parameters = Parameters()
    try:
        parameters.parse_command_line(argv)
    except RuntimeError as err:
        print("Error: ", err)
        return

    with open(parameters.input_pfm_file_name, "rb") as inpf:
        img = hdrimages.read_pfm_image(inpf)

    print(f"File {parameters.input_pfm_file_name} has been read from disk.")

    img.normalize_image(factor=parameters.factor)
    img.clamp_image()

    with open(parameters.output_png_file_name, "wb") as outf:
        img.write_ldr_image(stream=outf, format="PNG", gamma=parameters.gamma)

    print(f"File {parameters.output_png_file_name} has been written to disk.")
```

# Guida per l'esercitazione

# Guida per l'esercitazione

#.  Definire una funzione che calcoli la luminosità di un oggetto `Color` e la luminosità media di un `HdrImage`;
#.  Definire una funzione che normalizzi i valori di un `HdrImage` usando una certa luminosità media, opzionalmente passata come argomento;
#.  Definire una funzione che applichi la correzione per le sorgenti luminose;
#.  Implementare il `main` nel codice dell'applicazione, in modo che accetti 4 argomenti: il file PFM da leggere, il valore di $a$, il valore di γ, e il nome del file PNG/JPEG/etc. da creare.
#.  Aggiungete *docstrings* a quelle classi, metodi, funzioni, tipi, etc. che vi sembrano bisognose di ciò, ma preoccupatevi che ciascun commento **non sia pedante**.
#.  Scegliete insieme una licenza, provando a leggerla insieme per capire cosa essa conceda e cosa vieti.

# Immagini di riferimento

-   Se vi serve un'immagine PFM realistica, potete usare  [memorial.pfm](http://www.pauldebevec.com/Research/HDR/memorial.pfm).

-   C'è anche il sito [Scenes for pbrt-v3](https://www.pbrt.org/scenes-v3.html).

# Indicazioni per C\#

# Importare librerie

-   La libreria ImageSharp supporta molti formati: JPEG, PNG, BMP, GIF, e TGA (un vecchio formato che non abbiamo trattato nella lezione di teoria).

-   In C\# si possono scaricare e installare automaticamente librerie, e specificare che vanno impiegate nei propri progetti senza bisogno di modificare Makefile e di usare `root-config`, `pkg-config` e cose simili.

-   Aggiungete il package [SixLabors.ImageSharp](https://docs.sixlabors.com/index.html) alla libreria di classi (che forse avete chiamato `Tracer`):

    ```text
    $ dotnet add package SixLabors.ImageSharp
    ```

# Salvare file PNG

```csharp
// Create a sRGB bitmap
var bitmap = new Image<Rgb24>(Configuration.Default, width, height);

// The bitmap can be used as a matrix. To draw the pixels in the bitmap
// just use the syntax "bitmap[x, y]" like the following:
bitmap[SOMEX, SOMEY] = new Rgb24(255, 255, 128); // Three "Byte" values!

// Save the bitmap as a PNG file
using (Stream fileStream = File.OpenWrite("output.png")) {
    bitmap.Save(fileStream, new PngEncoder());
}
```

# Indicazioni per D/Nim/Rust

# Indicazioni per D/Nim/Rust

-   Similmente al C\#, potete installare librerie nel vostro progetto con il vostro package manager:

    -   In D, usate `dub add NAME`;
    -   In Nim, usate `nimble install NAME`;
    -   In Cargo, usate `cargo` seguendo [la guida](https://doc.rust-lang.org/cargo/guide/dependencies.html).
    
-   Queste librerie saranno installate come dipendenze del vostro programma, e non a livello di sistema.

# Indicazioni per Kotlin

# Indicazioni per Kotlin

-   A differenza di Python, C++, C\# e Julia, il linguaggio Kotlin fornisce supporto per immagini PNG, JPEG, BMP e GIF tramite le librerie standard Java.

-   A voi servono le classi `java.awt.image.BufferedImage` (immagine LDR) e `javax.imageio.ImageIO` (la classe che implementa i metodi per leggere/scrivere immagini LDR su file).

# Codificare il colore

-   La classe `BufferedImage` permette di codificare il colore in tanti modi diversi. Se usate `TYPE_INT_RGB`, il colore è un numero intero a 32 bit anziché una terna RGB.

-   I 32 bit del numero che codifica un colore seguono questo formato:

    ```
    00000000 rrrrrrrr gggggggg bbbbbbbb
    ```

    dove `r` sono i bit del rosso, `g` quelli del verde e `b` quelli del blu. Di solito i colori si indicano usando la notazione esadecimale, perché in questo modo sono sempre a sei cifre, ad es. `0x12FA51`.

-   Se `r`, `g` e `b` sono byte nell'intervallo [0, 255], potete usare la formula `r * 65536 + g * 256 + b` oppure `(r shl 16) + (g shl 8) + b`.

# Esempio di codice Kotlin

```kotlin
fun main(args: Array<String>) {
    val width = 800
    val height = 600
    val ldrImage = BufferedImage(width, height, BufferedImage.TYPE_INT_RGB)
    for (y in 0 until height) {
        for (x in 0 until width) {
            // 0xFF0000 corresponds to sRGB(255, 0, 0): the image will be
            // painted uniformly with a bright red shade
            ldrImage.setRGB(x, y, 0xFF0000)
        }
    }
    // Save the image to the file specified on the command line
    ImageIO.write(args[0], "PNG", stream)
}
```

# Linea di comando

-   Kotlin deriva da Java, ed ha ereditato il suo modo un po' «barocco» di gestire i parametri da linea di comando.

-   Il vostro eseguibile Kotlin **non può** essere eseguito come un normale eseguibile Python/C++/C\#:

    ```text
    $ ./main.py input_file.pfm 0.3 1.0 output_file.png
    ```

    perché bisogna passare da `gradlew`, che richiede che i parametri siano passati attraverso `--args`:

    ```text
    ./gradlew run --args="input_file.pfm 0.3 1.0 output_file.png"
    ```

