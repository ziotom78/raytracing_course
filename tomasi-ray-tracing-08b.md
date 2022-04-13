---
title: "Esercitazione 8"
subtitle: "Calcolo numerico per la generazione di immagini fotorealistiche"
author: "Maurizio Tomasi <maurizio.tomasi@unimi.it>"
...

# Issues

# Un bug nel codice!

-   Il codice Python di settimana scorsa conteneva volutamente un errore nell'implementazione del metodo `ImageTracer.fire_ray`:

    ```python
    u = (col + u_pixel) / (self.image.width - 1)
    v = (row + v_pixel) / (self.image.height - 1)
    ```

-   L'errore sta nel fatto che le righe in `HdrImage` sono numerate dall'*alto*, non dal *basso*. Nella seconda riga invece, `v` cresce quando cresce `row`.

# Cosa fare con i bug

-   L'esistenza di questo bug provoca un ribaltamento verticale delle immagini: l'alto e il basso sono scambiati!

-   Eppure abbiamo implementato dei test!

-   Perché non ce ne siamo accorti?


# Test della scorsa lezione

```python
# These were the tests we implemented last week
image = HdrImage(width=4, height=2)
camera = PerspectiveCamera(aspect_ratio=2)
tracer = ImageTracer(image=image, camera=camera)

# Here we check that "u_pixel" and "v_pixel" do what they're supposed to do
ray1 = tracer.fire_ray(0, 0, u_pixel=2.5, v_pixel=1.5)
ray2 = tracer.fire_ray(2, 1, u_pixel=0.5, v_pixel=0.5)
assert ray1.is_close(ray2)

# Here we check that all pixels have been visited
tracer.fire_all_rays(lambda ray: Color(1.0, 2.0, 3.0))
for row in range(image.height):
    for col in range(image.width):
        assert image.get_pixel(col, row) == Color(1.0, 2.0, 3.0)
```


# Test incompleti

-   Ci rendiamo conto che i nostri test non verificavano il corretto orientamento dell'immagine!

-   Questo genere di problemi è **molto** comune, anche in progetti professionali: c'è una potenziale condizione di errore che i test non coprono, e che non viene quindi scoperta durante l'implementazione.

-   Vediamo ora qual è il modo giusto di correggere l'errore.


# Correggere un bug

Correzioni in un repository pubblico come GitHub richiedono questi passaggi:

#.   Segnalare il problema su GitHub, aprendo una *issue* (sinonimi: *bug report* o *ticket*). Alla issue sarà assegnato un numero unico, ad es. #156.

#.   Creare una branch nel repository, chiamandola `fix156`.

#.   Modificare i test in modo che evidenzino l'errore: una volta implementati, questi nuovi test devono ovviamente fallire.

#.   Solo una volta che i nuovi test sono implementati si può correggere il bug.

#.   Quando i nuovi test passano, aprire una PR legata al branch, e se tutto funziona (inclusi i *CI builds*) si fa il *merge* e si chiude la *issue*.


# Aprire una *issue*

<iframe src="https://player.vimeo.com/video/544935196?badge=0&amp;autopause=0&amp;player_id=0&amp;app_id=58479" width="672" height="640" frameborder="0" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen title="How to open a new issue in GitHub"></iframe>

# Creare un nuovo test

-   Il test che avevamo scritto per `ImageTracer` non era esaustivo…

-   …ma era comunque già abbastanza complesso, perché verificava due cose distinte:

    #.   La correttezza della gestione di `u_pixel` e `v_pixel`

    #.   Il fatto che `ImageTracer.fire_all_rays` fosse in grado di «visitare» tutti i pixel dell'immagine.

-   Non conviene che aggiungiamo materiale a questo test, altrimenti in caso in futuro fallisse sarebbe meno immediato capire *dove* si trovi il problema.

# Lavoro da fare

-   Quello che faremo ora è dividere il test in tre sotto-test:

    #.  Le due verifiche già esistenti, che vanno però divise in due test distinti;
    #.  Un nuovo test che fallisca a causa del bug che abbiamo evidenziato.

-   Nell'implementare questo test in Python, ho usato una caratteristica del framework di test (`unittest`) che probabilmente esiste anche nei vostri framework.


# Ripetizioni ineleganti

```python
def test_uv_sub_mapping():
    # Create the objects to test
    image = HdrImage(width=4, height=2)
    camera = PerspectiveCamera(aspect_ratio=2)
    tracer = ImageTracer(image=image, camera=camera)

    ray1 = tracer.fire_ray(0, 0, u_pixel=2.5, v_pixel=1.5)
    ray2 = tracer.fire_ray(2, 1, u_pixel=0.5, v_pixel=0.5)
    assert ray1.is_close(ray2)

def test_image_coverage():
    # Create the objects to test (same as above)
    image = HdrImage(width=4, height=2)
    camera = PerspectiveCamera(aspect_ratio=2)
    tracer = ImageTracer(image=image, camera=camera)

    tracer.fire_all_rays(lambda ray: Color(1.0, 2.0, 3.0))
    for row in range(image.height):
        for col in range(image.width):
            assert image.get_pixel(col, row) == Color(1.0, 2.0, 3.0)
```

# *Set-up* e *tear-down*

-   L'ineleganza sta nel fatto che dobbiamo creare in ogni test gli oggetti `image`, `camera` e `tracer`.

-   I framework di test (non tutti) forniscono di solito la possibilità di invocare procedure di *set-up* per creare gli oggetti su cui si eseguono poi i test.

-   (Analogamente, questi framework implementano anche la possibilità di invocare procedure di *tear-down* alla fine dei test, con lo scopo ad esempio di cancellare file temporanei creati durante i test stessi).

---


```python
class TestImageTracer(unittest.TestCase):
    # This is invoked automatically whenever you run `pytest`
    def setUp(self):
        self.image = HdrImage(width=4, height=2)
        self.camera = PerspectiveCamera(aspect_ratio=2)
        self.tracer = ImageTracer(image=self.image, camera=self.camera)

    def test_orientation(self):
        # Fire a ray against top-left corner of the screen
        top_left_ray = self.tracer.fire_ray(0, 0, u_pixel=0.0, v_pixel=0.0)
        assert Point(0.0, 2.0, 1.0).is_close(top_left_ray.at(1.0))

        # Fire a ray against bottom-right corner of the screen
        bottom_right_ray = self.tracer.fire_ray(3, 1, u_pixel=1.0, v_pixel=1.0)
        assert Point(0.0, -2.0, -1.0).is_close(bottom_right_ray.at(1.0))

    def test_uv_sub_mapping(self):
        ray1 = self.tracer.fire_ray(0, 0, u_pixel=2.5, v_pixel=1.5)
        ray2 = self.tracer.fire_ray(2, 1, u_pixel=0.5, v_pixel=0.5)
        assert ray1.is_close(ray2)

    def test_image_coverage(self):
        self.tracer.fire_all_rays(lambda ray: Color(1.0, 2.0, 3.0))
        for row in range(self.image.height):
            for col in range(self.image.width):
                assert self.image.get_pixel(col, row) == Color(1.0, 2.0, 3.0)
```

# Fallimento dei test

<asciinema-player src="cast/github-issue-failed-tests-86x22.cast" cols="86" rows="22" font-size="medium"></asciinema-player>

# Creazione di un PR

<center>![](./media/github-fix-issue.png){height=560px}</center>

# Correzione del bug

-   Questa è la correzione per il metodo `ImageTracer.fire_ray`:

    ```python
    u = (col + u_pixel) / self.image.width
    v = 1.0 - (row + v_pixel) / self.image.height
    ```

-   Facendo il commit, si vede che ora il test passa:

    <center>![](./media/github-issue-bugfix.png){height=280px}</center>

# Chiusura del bug

-   A questo punto il bug è sistemato, e possiamo procedere a chiudere la *issue*

-   È molto importante però prima dare un'occhiata complessiva alla PR, per verificare che sia chiaramente leggibile. In particolare, selezionate il tab *Files changed* e leggetelo con occhio critico:

    1.  I file che vengono modificati sono quelli che mi aspetto, o è presente qualche altra modifica a cui stavo lavorando quando il bug è stato scoperto?
    
    2.  Chi vedrà queste modifiche, sarà in grado di capirle senza leggere l'intero codice?
    
-   Evitate di includere modifiche «gratuite» (correzioni di errori grammaticali in docstring, linee vuote aggiunte a caso…)

---

<center>![](media/github-pr-last-check-before-merging.png){height=680px}</center>

Esempio preso da un PR di [pytracer](https://github.com/ziotom78/pytracer/pull/10/files)

# Chiusura del bug

<iframe src="https://player.vimeo.com/video/544950712?badge=0&amp;autopause=0&amp;player_id=0&amp;app_id=58479" width="672" height="640" frameborder="0" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen title="How to close an issue in GitHub"></iframe>

# Traccia dei bug

-   GitHub tiene traccia dei bug di un repository nella pagina dedicata: è possibile consultare quindi quali bug siano aperti e quali siano stati già chiusi.

-   Ma, come nel caso dei *commit*, una lista di bug è ben povera, e non racconta una «storia».

-   Vediamo ora lo scopo del file CHANGELOG.md, che è una forma di documentazione.

# CHANGELOG

-   Tutti i repository pubblici dovrebbero avere un file `CHANGELOG`/`NEWS`/`HISTORY`/…, che elenca i bug corretti e le nuove caratteristiche del codice elencati in funzione del numero di versione.

-   Questo è il file `HISTORY.md` di Julia:

    <center>![](./media/julia-release-notes.png){height=320px}</center>

# CHANGELOG

-   In un file `CHANGELOG` occorre indicare tutte le correzioni e modifiche fatte al codice.

-   Non serve essere verbosi: basta una o due righe per modifica, se si inserisce il link alla *issue*/*pull request*

-   Va scritto in ordine **cronologico inverso**: le modifiche più recenti stanno in cima. In questo modo è più semplice per chi legge vedere quali sono le novità dell'ultima versione (che verosimilmente è quella che si vuole scaricare).

-   Di solito si divide in sezioni, una per ogni versione del codice. La prima sezione si chiama di solito `HEAD`, e contiene le correzioni e le modifiche che finiranno nella prossima futura versione del codice.


# CHANGELOG di [Healpix.jl](https://github.com/ziotom78/Healpix.jl)

<center>![](./media/healpixjl-changelog.png)</center>


# CHANGELOG di [pytracer](https://github.com/ziotom78/pytracer)

-   Nel repository di [pytracer](https://github.com/ziotom78/pytracer) c'è un file `CHANGELOG.md`, scritto in Markdown, che potete usare come ispirazione. In particolare, il «nostro» bug figura così:

    ```markdown
    …

    -   Fix an issue with the vertical order of the images [#4](https://github.com/ziotom78/pytracer/pull/4)

    # Version 0.1.0

    -   First release of the code
    ```

-   Ricordatevi d'ora in poi che **l'ultimo commit in un PR** dovrà sempre essere l'aggiornamento di `CHANGELOG.md`!

# Cose da fare oggi

# La prima immagine!

<center>![](./media/pytracer-first-image.png)</center>

# Geometria

```{.asy im_fmt="html" im_opt="-f html" im_out="img,stdout,stderr" im_fname="first-image-geometry"}
size(0,100);
import three;
currentlight=Viewport;

// Spheres on the vertexes of the cube
draw(shift( 0.5,  0.5,  0.5) * scale3(0.1) * unitsphere, white);
draw(shift(-0.5,  0.5,  0.5) * scale3(0.1) * unitsphere, white);
draw(shift( 0.5, -0.5,  0.5) * scale3(0.1) * unitsphere, white);
draw(shift(-0.5, -0.5,  0.5) * scale3(0.1) * unitsphere, white);
draw(shift( 0.5,  0.5, -0.5) * scale3(0.1) * unitsphere, white);
draw(shift(-0.5,  0.5, -0.5) * scale3(0.1) * unitsphere, white);
draw(shift( 0.5, -0.5, -0.5) * scale3(0.1) * unitsphere, white);
draw(shift(-0.5, -0.5, -0.5) * scale3(0.1) * unitsphere, white);

// Two additional spheres
draw(shift( 0.0,  0.0, -0.5) * scale3(0.1) * unitsphere, white);
draw(shift( 0.0,  0.5,  0.0) * scale3(0.1) * unitsphere, white);

// A wireframe to suggest the structure of the cube
path3 square = (
    ( 0.5,  0.5,  0.0) --
    (-0.5,  0.5,  0.0) --
    (-0.5, -0.5,  0.0) --
    ( 0.5, -0.5,  0.0) -- cycle);

draw(shift(0.0, 0.0,  0.5) * square, black);
draw(shift(0.0, 0.0, -0.5) * square, black);
draw(rotate(90, X) * shift(0.0, 0.0,  0.5) * square, black);
draw(rotate(90, X) * shift(0.0, 0.0, -0.5) * square, black);
draw(rotate(90, Y) * shift(0.0, 0.0,  0.5) * square, black);
draw(rotate(90, Y) * shift(0.0, 0.0, -0.5) * square, black);

// The screen
path3 screen = ((-1, -1, -0.5) -- (-1, -1, 0.5) -- (-1, 1, 0.5) -- (-1, 1, -0.5) -- cycle);

draw(surface(screen), gray + opacity(0.7));

// The observer
triple observer_pos = (-2.0, 0.0, 0.0);
draw(shift(observer_pos) * scale3(0.05) * unitsphere, white);

draw(observer_pos -- (-1, -1, -0.5), gray);
draw(observer_pos -- (-1, -1,  0.5), gray);
draw(observer_pos -- (-1,  1,  0.5), gray);
draw(observer_pos -- (-1,  1, -0.5), gray);

// Axes
draw(O--1.5X, gray); //x-axis
draw(O--1.5Y, gray); //y-axis
draw(O--1.5Z, gray); //z-axis

label("$x$", 1.5X + 0.2Z);
label("$y$", 1.5Y + 0.2Z);
label("$z$", 1.5Z + 0.2X);
```

# Forme

-   Dobbiamo implementare delle forme nel nostro codice.

-   Per oggi basta implementare un tipo `Sphere`; se volete, aggiungete anche un `Plane` (è molto veloce da aggiungere).

-   Create un tipo astratto `Shape`, che implementi il metodo (astratto) `ray_intersection`. Questo accetta come parametro un parametro `Ray` e restituisce un tipo `HitRecord`. Se il vostro linguaggio lo supporta, il tipo di ritorno dovrebbe essere *nullable*.

# `Shape` in Python

```python
class Shape:
    def __init__(self, transformation=Transformation()):
        self.transformation = transformation

    def ray_intersection(self, ray: Ray) -> Optional[HitRecord]:
        return NotImplementedError(
            "Shape.ray_intersection is an abstract method and cannot be called directly"
        )
```

# `HitRecord`

-   Per restituire le informazioni su una intersezione, è buona norma usare un tipo dedicato: `HitRecord`.

-   Il tipo deve contenere queste informazioni:

    #.   `world_point`: punto 3D in cui è avvenuta l'intersezione (`Point`);
    #.   `normal`: normale della superficie all'intersezione (`Normal`);
    #.   `surface_point`: coordinate $(u, v)$ dell'intersezione (nuovo tipo `Vec2d`);
    #.   `t`: parametro del raggio associato all'intersezione;
    #.   `ray`: raggio di luce che ha causato l'intersezione.

-   Per i test è utile che implementi un metodo `is_close`/`are_close`.

# `Sphere` in Python

-   Il numero di intersezioni tra il raggio $O + t \vec d$ e la sfera dipende dal segno di

    $$
    \frac\Delta4 = \left(\vec O \cdot \vec d\right)^2 - \left\|\vec d\right\|^2\cdot \left(\left\|\vec O\right\|^2 - 1\right).
    $$

-   Nel caso in cui $\Delta > 0$, le due intersezioni sono

    $$
    t = \begin{cases}
    t_1 &= \frac{-\vec O \cdot d - \sqrt{\Delta / 4}}{\left\|\vec d\right\|^2},\\
    t_2 &= \frac{-\vec O \cdot d + \sqrt{\Delta / 4}}{\left\|\vec d\right\|^2}.
    \end{cases}
    $$

# `Sphere` in Python

-   Dovete **antitrasformare** il raggio prima di calcolare l'intersezione:

    ```python
    def ray_intersection(self, ray: Ray) -> Optional[HitRecord]:
        inv_ray = ray.transform(self.transformation.inverse())
        # ...
    ```

-   Quando avete calcolato `t1` e `t2`, dovete determinare quale delle due intersezioni è la più vicina all'origine del raggio:

    ```python
    if (tmin > inv_ray.tmin) and (tmin < inv_ray.tmax):
        first_hit_t = tmin
    elif (tmax > inv_ray.tmin) and (tmax < inv_ray.tmax):
        first_hit_t = tmax
    else:
        return None   # The ray missed the sphere
    ```

#   Normali e coordinate UV

-   Dovete implementare il calcolo della normale al punto di intersezione; nel codice di [pytracer](https://github.com/ziotom78/pytracer/blob/d12284d0c60965e48b004a305d6ba8e28c13f757/shapes.py#L42-L51) ciò è fatto all'interno di `_sphere_normal`:

    ```python
    def _sphere_normal(point: Point, ray_dir: Vec) -> Normal:
        result = Normal(point.x, point.y, point.z)
        return result if (point.to_vec().dot(ray_dir) < 0.0) else -result
    ```

-   Serve anche il codice che calcola il punto di intersezione sulla superficie della sfera, in coordinate $(u, v)$, per cui è utile un nuovo tipo `Vec2d`:

    ```python
    def _sphere_point_to_uv(point: Point) -> Vec2d:
        u = atan2(point.y, point.x) / (2.0 * pi)
        return Vec2d(u=u if u >= 0.0 else u + 1.0, v=acos(point.z) / pi)
    ```

# Creazione di `HitRecord`

```python
hit_point = inv_ray.at(first_hit_t)
return HitRecord(
    world_point=self.transformation * hit_point,
    normal=self.transformation * _sphere_normal(hit_point, ray.dir),
    surface_point=_sphere_point_to_uv(hit_point),
    t=first_hit_t,
    ray=ray,
)
```

# Test per `Sphere` (1/2)

-   Il raggio con $O = (0, 0, 2)$ e $\vec d = -\hat e_z$ deve intersecare la sfera unitaria nel punto $P = (0, 0, 1)$ con normale $\hat n = \hat e_z$.
-   Il raggio con $O = (3, 0, 0)$ e $\vec d = -\hat e_x$ deve intersecare la sfera unitaria nel punto $P = (1, 0, 0)$ con normale $\hat n = \hat e_x$.
-   Il raggio con $O = (0, 0, 0)$ e $\vec d = \hat e_x$ deve intersecare la sfera unitaria in $P = (1, 0, 0)$ con normale $\hat n = -\hat e_x$ (il raggio è *interno* alla sfera).

In tutti questi casi verificate anche le coordinate $(u, v)$ e il valore di $t$.

# Test per `Sphere` (2/2)

-   Applicate una traslazione $\vec t = (10, 0, 0)$ alla sfera e intersecatela con il raggio con $O = (10, 0, 2)$ e $\vec d = -\hat e_z$.
-   Intersecate la stessa sfera traslata con il raggio con $O = (13, 0, 2)$ e $\vec d = -\hat e_x$. L'intersezione dovrebbe essere $P = (11, 0, 0)$ con normale $\hat n = \hat e_x$.
-   Verificate che non vi siano potenziali intersezioni con la sfera **non** traslata, usando questi raggi:
    #.  Raggio con $O = (0, 0, 2)$ e $\vec d = -\hat e_z$;
    #.  Raggio con $O = (-10, 0, 0)$ e $\vec d = -\hat e_z$;

In tutti questi casi verificate anche le coordinate $(u, v)$ e il valore di $t$.

# Il tipo `World`

-   Una scena è composta da tante forme.
-   Ci occorre un tipo che contenga questa lista di forme: il tipo `World`.
-   Esso deve mantenere al suo interno una lista di oggetti `Shape`: abbiate cura a dichiarare correttamente questa lista, perché alcuni linguaggi potrebbero richiedere cautele particolari per liste di oggetti astratti.
-   Deve implementare un metodo `ray_intersection` che iteri sulle forme, cerchi le intersezioni, e restituisca quella più vicina all'origine del raggio.

# `World` in Python

```python
class World:
    def __init__(self):
        self.shapes = []

    def add(self, shape: Shape):
        self.shapes.append(shape)

    def ray_intersection(self, ray: Ray) -> Optional[HitRecord]:
        closest = None  # "closest" should be a nullable type!
        for shape in self.shapes:
            intersection = shape.ray_intersection(ray)

            if not intersection:
                continue

            if (not closest) or (intersection.t < closest.t):
                closest = intersection

        return closest
```

# Il nostro demo

<center>![](./media/pytracer-first-image.png)</center>

L'asimmetria nella disposizione delle sfere consente di individuare errori nell'ordinamento delle righe/colonne dell'immagine.

# La scena

-   Posizionate le sfere ai vertici del cubo con spigoli $(\pm 0.5, \pm 0.5, \pm 0.5)$.
-   Ciascuna sfera deve avere raggio 1/10.
-   L'osservatore deve essere spostato di $-\hat e_x$, ossia la sua posizione deve essere $(-2, 0, 0)$ e il centro dello schermo $(-1, 0, 0)$.
-   Scegliete voi se usare `OrthogonalCamera` o `PerspectiveCamera`.

# Il `main`

-   Il nostro `main` è stato sinora in grado di convertire un'immagine PFM in un altro formato (PNG, JPEG, WebP, etc.)
-   Dobbiamo ora cambiare l'interfaccia del programma in modo che permetta di usare due modalità:
    #.  Conversione da PFM ad altri formati (la vecchia modalità);
    #.  Una nuova modalità `demo`, dove genera l'immagine descritta poco fa.

# Esempio in Python

-   In Python ho usato la libreria Click, che permette di costruire interfacce utente da linea di comando che supportano le cosiddette *actions* (altre librerie li chiamano *verbs*).

-   Dopo il nome dell'eseguibile va riportato un comando, seguito opzionalmente da parametri:

    ```text
    ./main.py pfm2png input.pfm output.png
    ./main.py demo --width=480 --height=480
    ./main.py --help
    ...
    ```

---

<asciinema-player src="cast/python-click-cli-example-88x27.cast" cols="88" rows="27" font-size="medium"></asciinema-player>

# Possibili interfacce

-   *Actions* esattamente come Click (se la vostra libreria li supporta);
-   Due eseguibili separati: `demo` e `pfm2png`
-   Richiesta di input da terminale:

    ```python
    print("What do you want to do? (demo/pfm2png)")
    choice = input(choice)
    if choice == "demo":
        # …
    ```
-   Eccetera…

# Comando `demo`

#.  Inizializzare un oggetto `World` con le 10 sfere nelle posizioni indicate;
#.  Creare un oggetto `OrthogonalCamera` o `PerspectiveCamera` ([pytracer](https://github.com/ziotom78/pytracer/blob/d12284d0c60965e48b004a305d6ba8e28c13f757/main.py#L125-L130) consente all'utente di scegliere);
#.  (Opzionale) Potete provare a ruotare l'osservatore per ottenere angolazioni più interessanti (v. seguito);
#.  Create un oggetto `ImageTracer`;
#.  Fare un tracing dell'immagine, usando un criterio «on/off» (v. slide seguente);
#.  Salvare l'immagine PFM;
#.  (Opzionale) Convertite immediatamente l'immagine in PNG usando valori di default per il tone-mapping.

# On-off tracing

-   Un ray-tracer on/off controlla se il raggio ha colpito una superficie, e in caso positivo colora il pixel con un colore arbitrario (bianco), altrimenti lo colora col colore di sfondo (nero).

-   Nel nostro caso è sufficiente invocare `fire_all_rays` passando come argomento una funzione di una riga:

    ```python
    tracer.fire_all_rays(lambda ray: WHITE if world.ray_intersection(ray) else BLACK)
    ```

# Animazioni

-   Nella modalità `demo`, il codice Python permette di modificare l'orientazione dell'osservatore rispetto agli assi tramite il flag `--angle-deg`.

-   Questo può essere usato per generare delle animazioni tramite semplici script Bash:

    ```sh
    for angle in $(seq 0 359); do
        # Angle with three digits, e.g. angle="1" → angleNNN="001"
        angleNNN=$(printf "%03d" $angle)
        ./main.py demo --width=640 --height=480 --angle-deg $angle --output=img$angleNNN.png
    done

    # -r 25: Number of frames per second
    ffmpeg -r 25 -f image2 -s 640x480 -i img%03d.png \
        -vcodec libx264 -pix_fmt yuv420p \
        spheres-perspective.mp4
    ```

# Proiezione prospettica

<video src="./media/spheres-perspective.mp4" width="640px" height="480px" controls loop autoplay/>

# Proiezione ortogonale

<video src="./media/spheres-orthogonal.mp4" width="640px" height="480px" controls loop autoplay/>

# Guida per l'esercitazione


# Cose da fare

#.  Correggere il bug della scorsa volta aprendo una *issue*;
#.  Creare un file `CHANGELOG.md`;
#.  Lavorare su un nuovo branch `demo`;
#.  Creare i tipi `Shape`, `Sphere`, `World`, `Vec2d`;
#.  Implementare il comando `demo`, nel modo in cui preferite (potete cercare una libreria per interpretare la linea di comando);
#.  Aprire una PR e aggiornare il file `CHANGELOG.md`.
