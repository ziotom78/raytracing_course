---
title: "Esercitazione 5"
subtitle: "Calcolo numerico per la generazione di immagini fotorealistiche"
author: "Maurizio Tomasi <maurizio.tomasi@unimi.it>"
...


# Tone mapping

---

<center>
![](./media/tone-mapping-problem.png)
</center>

# Tone mapping

-   Una conversione da RGB a sRGB dovrebbe preservare la «tinta» complessiva di un'immagine.
-   Ecco perché non si parla di *tone mapping* per un singolo colore RGB, ma per una matrice di colori (ossia un'immagine).
-   Noi useremo il *tone mapping* descritto da [Shirley & Morley (2003)](https://books.google.it/books/about/Realistic_Ray_Tracing_Second_Edition.html?id=ywOtPMpCcY8C&redir_esc=y): è fisicamente meno preciso di altri metodi (es., la normalizzazione dello standard CIE usando D65), ma più intuitivo e più semplice da implementare.

# Algoritmo di tone mapping

1.  Stabilire un valore «medio» per l'irradianza misurata in corrispondenza di ogni pixel dell'immagine;
2.  Normalizzare il colore di ogni pixel a questo valore medio;
3.  Applicare una correzione ai punti di maggiore luminosità.

# Valore medio

-   Il valore «neutro» per la radianza è definito dalla media logaritmica della luminosità $l_i$ dei pixel (con $i = 1\ldots N$):
    $$
    \left<l\right> = 10^{\frac{\sum_i \log_{10}(\delta + l_i)}N},
    $$
    dove $\delta \ll 1$ evita la singolarità di $\log_{10} x$ in $x = 0$.

-   A ciascun pixel sono però associati tre valori scalari (R, G, B). Quale valore usare per la luminosità $l_i$?

# Luminosità

Media aritmetica
: $l_i = \frac{R_i + G_i + B_i}3$;

Media pesata
: $l_i = \frac{w_R R_i + w_G G_i + w_B B_i}{w_R + w_G + w_B}$, data una terna di valori positivi $(w_R, w_G, w_B)$;

Distanza dall'origine
: $l_i = \sqrt{R_i^2 + G_i^2 + B_i^2}$;

Funzione di luminosità
: $l_i = \frac{\max(R_i, G_i, B_i) + \min(R_i, G_i, B_i)}2$

Shirley & Morley usano l'ultima definizione perché sostengono che, nonostante non sia fisicamente significativa, produca risultati visivamente migliori.

# Perché la media logaritmica?

-   Non abbiamo ancora giustificato la formula
    $$
    \left<l\right> = 10^{\frac{\sum_i \log_{10}(\delta + l_i)}N},
    $$

-   Essa è plausibile perché la risposta dell'occhio a uno stimolo $S$ è logaritmica (*leggi di Weber-Fechner*):
    $$
    p = k \log_{10} \frac{S}{S_0}
    $$
    dove $p$ è il valore percepito, e $S$ è l'intensità dello stimolo.

# Proprietà della media logaritmica

-   La media logaritmica è una media sugli *esponenti*, mentre la media aritmetica è una media sui valori;

-   Nel caso i valori siano $10^2$, $10^4$ e $10^6$, la media logaritmica è
    $$
    10^{\frac{\log_{10} 10^2 + \log_{10} 10^4 + \log_{10} 10^6}3} = 10^4,
    $$
    mentre la media aritmetica è $(10^2 + 10^4 + 10^6)/3 \approx 10^6/3$.


# Normalizzazione

-   Una volta stimato il valore medio, i valori R, G, B dell'immagine sono aggiornati tramite la trasformazione

    $$
    R_i \rightarrow a \times \frac{R_i}{\left<l\right>},
    $$

    dove $a$ è un valore impostabile dall'utente.

-   Curiosamente, nel loro libro Shirley & Morley suggeriscono $a = 0.18$; in realtà non esiste un valore «giusto», e $a$ si deve scegliere a seconda dell'immagine.


# Punti luminosi

![](./media/bright-light-in-room.jpg){height=520}

Sono notoriamente difficili da trattare!

# Punti luminosi

Shirley & Morley suggeriscono di applicare ai valori R, G, B di ogni punto dell'immagine la trasformazione
$$
R_i \rightarrow \frac{R_i}{1 + R_i},
$$
che ha le seguenti caratteristiche:
$$
\begin{aligned}
R_i \ll 1 &\Rightarrow R_i \rightarrow R_i,\\
R_i \gg 1 &\Rightarrow R_i \rightarrow 1.
\end{aligned}
$$

# Punti luminosi

```{.gnuplot format=svg dpi=600}
set xlabel "Input"
set ylabel "Output"
plot [0:10] [] x/(1 + x)
```

# Correzione γ

-   Potremmo voler applicare una correzione γ ai valori dell'immagine.

-   Se in corrispondenza di un segnale $x$ il monitor emette un flusso

    $$
    \Phi \propto x^\gamma,
    $$

    allora i valori RGB da salvare nell'immagine LDR devono essere

    $$
    r = \left[2^8\times R^{1/\gamma}\right],\quad
    g = \left[2^8\times G^{1/\gamma}\right],\quad
    b = \left[2^8\times B^{1/\gamma}\right],
    $$

    assumendo che il formato codifichi i colori usando 8×3 = 24 bit.


---

<center>
![](./media/kitchen-gamma-settings.png)
</center>

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

-   Le attività da compiere sul codice sono le seguenti:

    #.   Definire una funzione che calcoli la luminosità di un oggetto `Color`;
    #.   Definire una funzione che calcoli la luminosità media di un `HdrImage`;
    #.   Definire una funzione che normalizzi i valori di un `HdrImage` usando una certa luminosità media, opzionalmente passata come argomento;
    #.   Definire una funzione che applichi la correzione per le sorgenti luminose;
    #.   Implementare il `main` nel codice dell'applicazione.

-   Come al solito, fornisco un'implementazione di riferimento in Python nel repository [pytracer](https://github.com/ziotom78/pytracer).

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
    -   L'utente potrebbe avere già calcolato il valore medio della luminosità.

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

# Conversione a LDR (1/3)

-   Una volta applicata `normalize_image` e `clamp_image`, tutte le componenti RGB dei colori nella matrice saranno nell'intervallo [0, 1].
-   A questo punto la conversione nello spazio sRGB avviene tramite la [solita formula con γ](tomasi-ray-tracing-05b-ci-builds.html#/correzione-%CE%B3).
-   Il risultato della conversione è una matrice che va salvata in uno dei formati grafici visti a lezione.
-   Per il salvataggio dovete scegliere una libreria appropriata.

# Conversione a LDR (2/3)

| Linguaggio | Librerie                                                                                                                                                               |
|------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| C++        | [libpng](http://www.libpng.org/pub/png/libpng.html), [libjpeg](http://libjpeg.sourceforge.net/), [libjpeg-turbo](https://github.com/libjpeg-turbo/libjpeg-turbo) [libtiff](http://www.libtiff.org/),  [webp](https://developers.google.com/speed/webp/docs/api), [libgd](https://libgd.github.io/) |
| Kotlin     | [javax.imageio](https://docs.oracle.com/javase/8/docs/api/javax/imageio/ImageIO.html) (già installato)                                                                 |
| Julia      | [Images.jl](https://github.com/JuliaImages/Images.jl) + [ImageIO.jl](https://github.com/JuliaIO/ImageIO.jl)                                                            |
| C\#        | [ImageSharp](https://docs.sixlabors.com/articles/imagesharp/?tabs=tabid-1)                                                                                             |
| Python     | [Pillow](https://pillow.readthedocs.io/en/stable/)                                                                                                                     |

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

# Link a Gather

Useremo il solito link: [gather.town/app/CgOtJvyNfVKMIQ9e/LaboratorioRayTracing](https://gather.town/app/CgOtJvyNfVKMIQ9e/LaboratorioRayTracing)

# Guida per l'esercitazione

# Guida per l'esercitazione

#.   Definire una funzione che calcoli la luminosità di un oggetto `Color`;
#.   Definire una funzione che calcoli la luminosità media di un `HdrImage`;
#.   Definire una funzione che normalizzi i valori di un `HdrImage` usando una certa luminosità media, opzionalmente passata come argomento;
#.   Definire una funzione che applichi la correzione per le sorgenti luminose;
#.   Implementare il `main` nel codice dell'applicazione, in modo che accetti 4 argomenti: il file PFM da leggere, il valore di $a$, il valore di γ, e il nome del file PNG/JPEG/etc. da creare.

Se vi serve un'immagine PFM realistica, potete usare  [memorial.pfm](http://www.pauldebevec.com/Research/HDR/memorial.pfm). C'è anche il sito [Scenes for pbrt-v3](https://www.pbrt.org/scenes-v3.html).

# Indicazioni per il C++

# `libgd`

-   Tra tutte le librerie C/C++ consigliate ([libpng](http://www.libpng.org/pub/png/libpng.html), [libjpeg](http://libjpeg.sourceforge.net/), [libjpeg-turbo](https://github.com/libjpeg-turbo/libjpeg-turbo), [libtiff](http://www.libtiff.org/), [webp](https://developers.google.com/speed/webp/docs/api), [libgd](https://libgd.github.io/)), libgd è la più semplice e versatile.

-   Su sistemi Ubuntu si può installare con

    ```
    sudo apt install libgd-dev
    ```

    Potrebbe non essere semplice installarla sotto Windows…

-   Supporta il salvataggio di immagini sia in formato PNG che JPEG.

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

  // "True color" is the old name for 24-bit RGB images
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

# Altre librerie

-   Se non riuscite ad usare `libgd`, potete tentare con qualcuna delle altre librerie.

-   Il sito [Awesome C++](https://github.com/fffaraz/awesome-cpp#image-processing) ha una sezione dedicata alle librerie grafiche per C++ che elenca molte possibilità.

# Librerie e CMake

-   Se la libreria supporta `pkg-config`, dovreste poter usarla nel vostro progetto usando `pkg_check_modules` (vedi [Use pkg_search_module and pkg_check_modules](https://riptutorial.com/cmake/example/22951/use-pkg-search-module-and-pkg-check-modules), [Converting from GCC to CMake](https://stackoverflow.com/questions/57961687/converting-from-gcc-to-cmake) e [What is the proper way to use pkg-config from cmake?](https://stackoverflow.com/questions/29191855/what-is-the-proper-way-to-use-pkg-config-from-cmake).

-   Se usate Windows, potreste aver più successo usando `find_package`.
    
-   Purtroppo non esiste una ricetta unica, ancora nel 2021 la gestione di dipendenze in C++ è un disastro!

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

# Indicazioni per Julia

# Il pacchetto [Images.jl](https://github.com/JuliaImages/Images.jl)

-   La community di Julia ha sviluppato una soluzione completa per la gestione delle immagini.
-   Il pacchetto principale è Images.jl, che definisce il tipo `Image`.
-   A Images.jl fanno riferimento molti altri sotto-pacchetti specialistici. A noi interessa installare [ImageIO.jl](https://github.com/JuliaIO/ImageIO.jl), che consente di leggere/scrivere formati grafici.

# Salvare file PNG

-   Usando `Pkg.add`, installate nel vostro package sia `Images` che `ImageIO`.

-   A questo punto basta creare matrici di valori `RGB` e salvarle col comando `save`; l'estensione del file ne determina il formato:

    ```julia
    using Images

    # Values must be expressed in the range [0, 1]
    image = [RGB(0.0, 0.0, 1.0) RGB(1.0, 0.0, 0.0);
             RGB(0.0, 1.0, 0.0) RGB(1.0, 1.0, 1.0)]

    # It's all too easy!
    save("test.png", image)
    ```

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
