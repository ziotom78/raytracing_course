---
title: "Esercitazione 10"
subtitle: "Numeri casuali e BRDF"
author: "Maurizio Tomasi <maurizio.tomasi@unimi.it>"
...

# Generazione di numeri pseudocasuali

# Numeri pseudo-casuali

-   Avete sicuramente già avuto a che fare con numeri casuali, probabilmente per eseguire simulazioni Monte Carlo (vedi ad es. il corso di TNDS).

-   In questo corso non affronteremo in dettaglio il problema della generazione dei numeri casuali, ma useremo una serie di risultati senza dimostrarli.

-   Il contesto delle immagini fotorealistiche è interessante per verificare il funzionamento di un generatore di numeri casuali: se la qualità del generatore non è ottima, si vede subito!

---

<center>![](./media/bad-random-generator.webp)</center>

# Come funziona un generatore

-   Un generatore di numeri pseudo-casuali è solitamente implementato come una *state machine*, ossia un algoritmo che mantiene in memoria una informazione sul proprio stato, che viene aggiornata ogni volta che produce un nuovo numero.

-   I generatori usati oggi di solito producono numeri *interi* in un dato intervallo.

-   Essendo soltanto pseudo-casuali, se si conosce l'ultimo numero estratto e lo stato di un generatore, si può predire quale sarà il numero successivo (*determinismo*). Questo può essere un vantaggio!

# Qualità di un generatore

#.  I numeri che produce dovrebbero essere «casuali»…

#.  …ma anche predicibili!

#.  I numeri presi a coppie/terne/quaterne/etc. dovrebbero continuare ad essere «casuali».

#.  Dovrebbe essere veloce da eseguire.

#.  Dovrebbe essere possibile far avanzare velocemente il suo stato interno: questa proprietà viene detta «ricercabilità» (*seekability*).

# 1. «Casualità»

-   Un generatore di numeri *pseudo*-casuali deterministico deve avere un certo periodo $N$: una volta estratti $N$ valori, è condannato a ripetere nuovamente la sequenza (oppure, in rari casi, a fermarsi).
-   È importante che i primi $N$ valori siano distribuiti il più uniformemente possibile.
-   È anche importante che il periodo sia sufficientemente lungo! Nello studio del satellite PICO avevamo riscontrato strani risultati, dovuti al fatto che il periodo del generatore era «solo» $2^{32}$ e quindi dopo un certo tempo il codice rivedeva da capo gli stessi numeri.

# 2. Predicibilità

-   Siccome i numeri pseudo-casuali vengono impiegati per simulazioni al calcolatore, è importante poter fare il debugging del codice.

-   Se i numeri del generatore fossero *veramente* casuali e riscontrassimo un problema che emerge solo di tanto in tanto, il debugging sarebbe molto difficile!

-   Di solito i generatori richiedono di essere inizializzati con un «seme» (*seed*): se si fornisce due volte lo stesso seme, la sequenza di numeri è la stessa. Questo è *estremamente* utile!

# 3. Dimensionalità

-   I numeri casuali vengono spesso usati per produrre vettori casuali, ossia campioni $x \in \mathbb{R}^n$, per qualche valore di $n$ (ad esempio, punti sul piano con $n = 2$, punti nello spazio con $n = 3$, etc.).

-   Un cattivo generatore di numeri casuali può funzionare perfettamente nel generare sequenze 1D, ma mostrare strane correlazioni quando usato per generare punti 2D.

-   Un generatore che mantiene le proprietà di «casualità» in $k$ dimensioni si dice che soddisfa l'*equidistribuzione $k$-dimensionale*.

---

# Esempio

-   Supponiamo che un generatore produca numeri a 32 bit in cui i primi 31 bit sono “casuali”, ma l'ultimo bit alterni regolarmente tra 0 ed 1:

    #.  1110111101100010110101110111001<font color=#f00>0</font> (numero pari)
    #.  1010001010100100001000010111010<font color=#f00>1</font> (numero dispari)
    #.  0100001101100101100111111000111<font color=#f00>0</font> (numero pari)
    #.  0101011011001110101000110101011<font color=#f00>1</font> (numero dispari)
    #.  Etc., in modo che **tutti** i valori tra 0 e 2³²−1 siano estratti una volta

-   Se voglio produrre punti 2D $(x, y)$ casuali distribuiti uniformemente, le ascisse avranno sempre valore pari e le ordinate dispari ⇒ metà dei punti teoricamente possibili in realtà non verranno mai scelti!

---

<center>![](./media/2d-randomness.png)</center>

Un *randogramma* (v. O'Neill 2014).

# 4. Velocità

-   Le applicazioni alla fisica dei metodi Monte Carlo richiedono di eseguire molte volte delle simulazioni, in modo da ridurre gli effetti del campionamento.

-   Un modo per avere grande velocità è usare operazioni logiche a livello di bit, che sono le più veloci realizzabili con le comuni CPU.

-   Un generatore dovrebbe mantenere il proprio stato in una struttura di memoria il più piccola possibile: in questo modo è più facile per la CPU ottimizzarne l'esecuzione.


# 5. Ricercabilità

-   In un generatore ogni numero casuale viene ricavato dallo stato del generatore, e lo stato cambia per ogni nuovo numero generato. Di conseguenza, il valore casuale $x_{k + 1}$ dipende dalla conoscenza del valore $x_k$.

-   Se io volessi produrre $2\times 10^9$ numeri casuali avendo a disposizione due computer, potrei voler generare 10⁹ campioni sulla prima macchina e 10⁹ sulla seconda.

-   Se però non si imposta correttamente il problema, c'è il rischio che le due sequenze di campioni siano correlate.

# Esempio

-   Se assegno lo stesso *seed* ai due computer, ottengo la stessa sequenza: argh!

-   Potrei allora assegnare il *seed* 5 al primo computer, e il *seed* 36 al secondo.

-   Se però il generatore è tale per cui dopo il numero 5 estrae il numero 36, la sequenza di numeri generati è allora la seguente:

    ```text
    computer #1:  5  36  17  29  45  …
    computer #2: 36  17  29  45   3  …
    ```

-   Ovviamente, questo sarebbe un problema anche se anziché 36 assegnassi 17, 29 o 45 al secondo computer.

-   Non basta dare un *seed* diverso ai due computer per ottenere sequenze indipendenti!


# Soluzioni al problema

-   Una possibile soluzione è quella di avere un criterio per cui due stati del generatore siano *ortogonali*: ossia, non possono generare la stessa sequenza di campioni, neppure sfasata. Questi generatore tipicamente richiedono di essere inizializzati con *due* numeri iniziali: un identificativo della sequenza e il *seed*. Se si usano due identificativi diversi, le sequenze generate sono scorrelate.

-   Un'altra soluzione è quella di poter avanzare lo stato del generatore di $k$ passaggi in maniera rapida, *senza* effettivamente generare $k - 1$ numeri casuali e richiedendo un numero di operazioni ben minore di $\propto k$ (tipicamente vale che $\propto \log k$).

# Generazione parallela

Per generare una lunga sequenza di $N$ numeri casuali distribuendola su $k$ computer si può usare questa procedura:

#.  Parto da un *seed* fissato, oppure casuale (ricavato dalla data e ora in cui è stato eseguito il programma), e creo lo stato iniziale del generatore;
#.  Assegno a ognuno dei $k$ computer il compito di generare solo $N/k$ campioni, e copio lo *stesso* stato iniziale del generatore su ciascuno di essi;
#.  Sul computer $i$-esimo avanzo lo stato del generatore di $i \times N / k$, usando l'algoritmo «veloce»;
#.  Ogni generatore procede a generare i $N/k$ campioni.


# Algoritmi

-   Le librerie standard dei compilatori offrono funzionalità per la generazione dei numeri casuali, ma la qualità di questi generatori è molto diseguale!

-   Nel 2014 Melissa O'Neill ha pubblicato [uno splendido articolo](https://www.pcg-random.org/paper.html) su una nuova famiglia di generatori di numeri casuali che soddisfa *tutte* le caratteristiche elencate prima, ed è rilasciato come libreria open-source sul sito [www.pcg-random.org](https://www.pcg-random.org/).

-   In questo corso useremo quindi l'algoritmo PCG, che ha tutte le belle proprietà elencate prima.


# L'algoritmo PCG

-   L'algoritmo che implementeremo per generare numeri pseudo-casuali è descritto nello stesso articolo [O'Neill (2014)](https://www.pcg-random.org/paper.html).

-   Anche se potrebbero esistere implementazioni del PCG nel vostro linguaggio, è richiesto che lo implementiate da soli.

-   Ci sono infatti numerose varianti dell'algoritmo, che si distinguono per le dimensioni in bit delle quantità usate durante la generazione.

-   Faciliterà il lavoro dei vari gruppi se ciascuno userà il medesimo generatore col medesimo seed.


# Numeri *unsigned*

-   PCG, come molti algoritmi simili, richiede di fare calcoli con maschere di bit.

-   Le maschere di bit si codificano solitamente con interi senza segno.

<center>
![](media/julia-signed-unsigned-int.png){width=480px}
</center>

-   Un numero negativo come `-12` (`0b1100`) è codificato con il complemento a due: si invertono tutti i bit di `12` e si somma 1, a dare `0b11110100` (8 bit).

# Operazioni sui bit

<small>

| Nome             | Esempio (Julia)             |
|------------------|-----------------------------|
| And              | `0b1001 & 0b0011 == 0b0001` |
| Or               | `0b1001 | 0b0011 == 0b1011` |
| Xor              | `0b1001 ^ 0b0011 == 0b1010` |
| Arithmetic shift | `0b1001 >> 1 == 0b100`      |
|                  | `Int8(-12) >> 1 == -6`      |
|                  | `Int16(-12) >> 1 == -6`     |
| Logical shift    | `0b1001 >>> 1 == 0b100`     |
|                  | `Int8(-12) >>> 1 == 122`    |
|                  | `Int16(-12) >>> 1 == 32762` |

- Nell'*arithmetic shift* a destra, il nuovo bit più significativo è la copia del vecchio, in modo da preservare il segno.

- Nel *logical shift* il nuovo bit più significativo è sempre zero, ed è sempre questo da usare nel PCG.

</small>

# Implementazione in Python

-   L'implementazione Python dell'algoritmo richiede delle operazioni che permettano di controllare il modo in cui Python esegue operazioni su interi.

-   A differenza dei linguaggi usati da voi, in Python esiste solo un tipo `int`, le cui dimensioni si adattano a seconda del numero che va memorizzato.

-   In Python non è possibile avere un overflow, perché l'interprete Python alloca sempre più spazio per non perdere cifre.

-   I linguaggi che usate ottimizzano invece le prestazioni, e possono subire overflow. Questi overflow sono non solo accettati, ma addirittura *richiesti* nell'algoritmo PCG.

----

<asciinema-player src="cast/overflow-python-julia-74x26.cast" cols="74" rows="26" font-size="medium"></asciinema-player>

# Gestione degli interi

-   Per rendere Python più simile a Julia, si può implementare una funzione che mascheri i bit meno significativi, simulando i numeri a 64 e a 32 bit.

-   Un esempio di implementazione è il seguente:

    ```python
    def to_uint64(x: int) -> int:
        # Mask "x" with 2^64 - 1
        return x & 0xffffffffffffffff
    ```

-   Ovviamente questo non è necessario se si usa un linguaggio che implementa tipi interi di dimensione fissata. Questo è il caso di tutti i linguaggi che state usando 😀.


# Interi usati dal PCG

-   L'algoritmo PCG che implementeremo è quello che genera numeri a 32 bit nell'intervallo $[0, 2^{32} - 1]$ (`uint32_t` in C++).

-   La struttura dati usati dall'algoritmo PCG ha bisogno di memorizzare al suo interno due numeri interi `unsigned` a 64 bit.

-   Familiarizzatevi con i tipi di interi senza segno forniti dal vostro linguaggio. (Linguaggi come Java non hanno interi senza segno, quindi bisogna cavarsela con quelli con segno 🙁; però Kotlin [li implementa](https://kotlinlang.org/docs/unsigned-integer-types.html) 🥳)


# PCG in Python

-   Ecco l'implementazione del tipo `PCG` e del costruttore:

    ```python
    @dataclass
    class PCG:
        state: int = 0   # 64-bit unsigned integer
        inc: int = 0     # 64-bit unsigned integer

        def __init__(self, init_state=42, init_seq=54):
            self.state = 0
            self.inc = (init_seq << 1) | 1
            self.random()   # Throw a random number and discard it
            self.state += init_state
            self.random()   # Throw a random number and discard it
    ```

-   In Python non possiamo specificare i bit che ci occorrono, ma nelle vostre implementazioni dovrete dichiarare `state` e `inc` come `unsigned` a 64 bit.

# Il metodo `PCG.random`


```python
def random(self) -> int:  # 32-bit unsigned number (in Java, return a 64-bit number)
    oldstate = self.state    # 64-bit unsigned integer

    self.state = to_uint64((oldstate * 6364136223846793005 + self.inc))

    # "^" is the xor operation
    xorshifted = to_uint32((((oldstate >> 18) ^ oldstate) >> 27))

    # 32-bit variable
    rot = oldstate >> 59

    # Rotation with a wrap; in Java/Kotlin, use Integer.rotateRight(xorshifted, rot)
    # In Java, apply a two's complement (& 0xffffffffL) to return a long
    return to_uint32((xorshifted >> rot) | (xorshifted << ((-rot) & 31)))
```

# Test per `PCG`

```python
def test_random():
    pcg = PCG()

    # You can check these members in a test only if you
    # did not declare "state" and "inc" as private members
    # of the PCG type
    assert pcg.state == 1753877967969059832
    assert pcg.inc == 109

    for expected in [2707161783, 2068313097,
                     3122475824, 2211639955,
                     3215226955, 3421331566]:
        assert expected == pcg.random()
```

# Numeri floating-point

-   Ovviamente il metodo `PCG.random` restituisce un numero *intero*.

-   Nella lezione di teoria però abbiamo sempre usato numeri pseudo-casuali $X_i$ distribuiti uniformemente su $[0, 1]$.

-   Dal momento che l'implementazione PCG che stiamo usando è a 32 bit e ha periodo $2^{32} -1$, è sufficiente normalizzare i numeri interi restituiti dall'algoritmo per avere la distribuzione uniforme:

    ```python
    def random_float(self) -> float:
        return self.random() / 0xffffffff
    ```

# *Seed*

-   Fate in modo che il costruttore del tipo `PCG` accetti come parametri di default i seguenti:

    ```text
    init_state = 42
    init_seq = 54
    ```

-   In questo modo nei test basterà creare una variabile `PCG` col costruttore di default e il test sarà ripetibile (e confrontabile tra gruppi diversi!).


# BRDFs

# Tipi di dati

-   Oggi inizieremo ad implementare il nostro path-tracer, e inizieremo da materiali, BRDFs e pigmenti. Ci serviranno questi tipi di dati primitivi:

    #.  Il tipo `Pigment` è **astratto**, e rappresenta il colore associato ad un punto particolare di una superficie $(u, v)$;
    #.  Il tipo `BRDF` è **astratto**, e rappresenta la BRDF di un materiale, che deve contenere al suo interno un membro `Pigment`;
    #.  Il tipo `Material` è **concreto**, e rappresenta l'unione della parte emissiva di un materiale (il termine $L_e$, che rappresentiamo ancora come un `Pigment`) e della sua BRDF.

-   Dai tipi astratti `Pigment` e `BRDF` derivereremo poi una serie di tipi concreti.

# `Pigment`

-   Il tipo base `Pigment` serve per calcolare un colore (tipo `Color`) associato con una coordinata $(u, v)$, tramite un metodo/funzione `get_color`, che associa un `Vec2D` a un `Color`.

-   Dovreste quanto meno definire questi due tipi:

    -   `UniformPigment` (colore uniforme, il pigmento più semplice!);
    -   `CheckeredPigment` (scacchiera, utile per il debugging).

-   Potreste definire anche un `ImagePigment` che si costruisca a partire da una `HdrImage`: questo consente di creare effetti molto interessanti se applicate a sfere delle immagini contenenti [proiezioni equirettangolari](https://en.wikipedia.org/wiki/Equirectangular_projection). Usate come riferimento l'implementazione in [pytracer](https://github.com/ziotom78/pytracer/blob/f994f863bf2c37b3f3f73f681435895f8117c8fb/materials.py#L53-L73).

# Pigmento a scacchiera

<center>![](media/checkered-pigment.svg){height=420px}</center>

Il colore 1 viene usato nelle caselle in cui i numeri di riga e colonna sono entrambi pari o dispari, il colore 2 negli altri casi. Il numero di divisioni dovrebbe essere impostabile nel costruttore.

# `BRDF`

-   Il tipo `BRDF` deve codificare la BRDF dell'equazione del rendering, ossia

    $$
    f_r = f_r(x, \Psi \rightarrow \Theta).
    $$

-   La BRDF è per definizione uno scalare, ma per rappresentare la dipendenza dalla lunghezza d'onda $\lambda$, il codice Python restituisce un `Color` anziché un `float`: ogni componente (R/G/B) è la BRDF integrata su quella banda.

-   Questo è il prototipo di `BRDF.Eval` com'è implementato in [pytracer](https://github.com/ziotom78/pytracer/blob/f6431700cab1205632d32a0021b0cd4aace5cd4c/materials.py#L92-L98):

    ```python
    class BRDF:
        def eval(self, normal: Normal, in_dir: Vec, out_dir: Vec, uv: Vec2d) -> Color:
            # …
    ```

# BRDF e `Pigment`

-   Il tipo `BRDF` dovrebbe contenere un tipo `Pigment` o un suo derivato (in C++ ad esempio si userebbe un puntatore, oppure `std::shared_ptr<Pigment>`).

-   Usate le componenti R/G/B restituite dal pigmento per un dato punto $(u, v)$ della superficie per «pesare» il contributo di $f_r$ alle varie frequenze (se una delle componenti RGB è nulla, tutti i fotoni in quella banda vengono assorbiti).

-   Questa è ad esempio l'implementazione della BRDF diffusa ($f_r = \rho_d / \pi$) in [pytracer](https://github.com/ziotom78/pytracer/blob/f6431700cab1205632d32a0021b0cd4aace5cd4c/materials.py#L101-L108), che di fatto assume $\rho_d = \rho_d(\lambda)$:

    ```python
    class DiffuseBRDF(BRDF):
        def eval(self, normal: Normal, in_dir: Vec, out_dir: Vec, uv: Vec2d) -> Color:
            return self.pigment.get_color(uv) * (self.reflectance / pi)
    ```

# `Material`

-   Il tipo `Material` deve racchiudere le informazioni sull'interazione tra punti della superficie e fotoni:

    #.  La BRDF $f_r = f_r(x, \Psi \rightarrow \Theta)$;
    #.  La radianza emessa in funzione del punto sulla superficie: $L_e = L_e(u, v)$.

-   In [pytracer](https://github.com/ziotom78/pytracer/blob/f6431700cab1205632d32a0021b0cd4aace5cd4c/materials.py#L111-L115) è definito così:

    ```python
    @dataclass
    class Material:
        """A material"""
        brdf: BRDF = DiffuseBRDF()
        emitted_radiance: Pigment = UniformPigment(BLACK)  # A *pigment*!
    ```

# Versatilità

-   Il tipo `Pigment` non deve fare altro che restituire un colore data una coordinata $(u, v)$, quindi richiede solo un metodo `get_color`. (Potrebbe quindi essere ripensato come un [*oggetto funzione*](https://en.wikipedia.org/wiki/Function_object), volendo…)

-   Il tipo `BRDF` dovrà diventare più complesso di come l'abbiamo implementato oggi (in un path tracer **non serve valutare** $f_r$, e quindi useremo `BRDF.eval` per altri scopi!), quindi è meglio non usare scorciatoie.

-   Il tipo `Material` è semplicemente l'unione di una BRDF e di un pigmento (il termine $L_e$), e non andrà esteso.

# Modifiche a `Shape`

-   Dovete anche modificare la definizione di `Shape` in modo che contenga al suo interno una istanza del tipo `Material`:

    ```python
    class Shape:
        def __init__(self, transformation: Transformation = Transformation(),
                     material: Material = Material()):
            self.transformation = transformation
            self.material = material
    ```

-   Il tipo `HitRecord` dovrebbe essere modificato in modo da contenere anche un puntatore all'oggetto `Shape` che è stato «colpito» dal raggio: in questo modo si potrà risalire al `Material` da usare durante la risoluzione dell'equazione del rendering (un'alternativa è salvare `Material` anziché `Shape`).


# Flat-renderer

-   Ora che abbiamo attribuito un `Material` a ogni `Shape`, è possibile creare un renderer un po' più interessante del tipo on/off usato nel nostro demo.

-   Nello specifico, potremmo implementare un semplice renderer che, invece di usare i colori bianco e nero, assegna a un pixel il colore del `Pigment` calcolato nel punto dove il raggio colpisce l'oggetto.

-   Il codice di pytracer implementa una classe base, [`Renderer`](https://github.com/ziotom78/pytracer/blob/f6431700cab1205632d32a0021b0cd4aace5cd4c/render.py#L24-L35), da cui derivano due classi [`OnOffRenderer`](https://github.com/ziotom78/pytracer/blob/f6431700cab1205632d32a0021b0cd4aace5cd4c/render.py#L38-L49) e [`FlatRenderer`](https://github.com/ziotom78/pytracer/blob/f6431700cab1205632d32a0021b0cd4aace5cd4c/render.py#L52-L69): quando si esegue il comando `demo` si può scegliere quale usare mediante il flag `--algorithm`.

---

<center>
    <video src="media/flat-renderer.mp4" width="640" height="480" controls loop autoplay/>
</center>

(A causa del fatto che l'immagine è quasi completamente nera, il *tone mapping* fa saturare i colori se si usa il valore standard di luminosità; convertite l'immagine fissando una luminosità media di ~0.5).

# Generare animazioni

-   Generare un'animazione lunga può essere molto tedioso.

-   Se la CPU del vostro computer supporta più *core* (molto probabile), potete usare [GNU Parallel](https://www.gnu.org/software/parallel/) (`sudo apt install parallel` sotto Debian/Ubuntu/Mint) per usare tutti i core e produrre tanti frame contemporaneamente: il vantaggio in termini di tempo è impressionante!

-   Scrivete uno script `generate-image.sh` che produca una immagine dato un parametro numerico e rendetelo eseguibile con `chmod +x NOMEFILE`, poi eseguite il comando `parallel` in un modo simile a questo:

    ```text
    parallel -j NUM_OF_CORES ./generate-image.sh '{}' ::: $(seq 0 359)
    ```

# `generate-image.sh`

```sh
#!/bin/bash

if [ "$1" == "" ]; then
    echo "Usage: $(basename $0) ANGLE"
    exit 1
fi

readonly angle="$1"
readonly angleNNN=$(printf "%03d" $angle)
readonly pfmfile=image$angleNNN.pfm
readonly pngfile=image$angleNNN.png

time ./main.py demo --algorithm flat --angle-deg $angle \
    --width 640 --height 480 --pfm-output $pfmfile \
    && ./main.py pfm2png --luminosity 0.5 $pfmfile $pngfile
```


# Guida per l'esercitazione


# Cose da fare

#.  Implementate il generatore PCG.
#.  Create un nuovo branch di nome `pathtracing`;
#.  Create i tipi `Pigment`, `UniformPigment`, `CheckeredPigment` (se vi va, implementate anche `ImagePigment`);
#.  Create i tipi `BRDF` e `DiffuseBRDF`;
#.  Creare il tipo `Material`;
#.  Modificate `Shape` perché contenga una istanza di `Material`;
#.  Modificate `HitRecord` perché contenga un puntatore alla `Shape` colpita da un raggio;
#.  Se vi va, implementate un flat-renderer (ma modificate anche il demo).
#.  Implementate gli stessi test di [pytracer](https://github.com/ziotom78/pytracer/blob/f6431700cab1205632d32a0021b0cd4aace5cd4c/test_all.py#L729-L841).
