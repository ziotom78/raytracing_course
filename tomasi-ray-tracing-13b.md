---
title: "Esercitazione 14"
subtitle: "Analisi sintattica e semantica"
author: "Maurizio Tomasi <maurizio.tomasi@unimi.it>"
...

# Analisi sintattica e lessicale

# Esempio di formato

```python
# Declare a floating-point variable named "clock"
float clock(150)

# Declare a few new materials. Each of them includes a BRDF and a pigment

# We can split a definition over multiple lines and indent them as we like
material sky_material(
    diffuse(image("sky-dome.pfm")),
    uniform(<0.7, 0.5, 1>)
)

material ground_material(
    diffuse(checkered(<0.3, 0.5, 0.1>,
                      <0.1, 0.2, 0.5>, 4)),
    uniform(<0, 0, 0>)
)

material sphere_material(
    specular(uniform(<0.5, 0.5, 0.5>)),
    uniform(<0, 0, 0>)
)

# Define a few shapes
sphere(sphere_material, translation([0, 0, 1]))

# The language is flexible enough to permit spaces before "("
plane (ground_material, identity)

# Here we use the "clock" variable! Note that vectors are notated using
# square brackets ([]) instead of angular brackets (<>) like colors, and
# that we can compose transformations through the "*" operator
plane(sky_material, translation([0, 0, 100]) * rotation_y(clock))

# Define a camera
camera(perspective, rotation_z(30) * translation([-4, 0, 1]), 1.0, 1.0)
```

Questo è il tipo di file per cui oggi implementeremo il nostro *parser*, che effettuerà l'analisi semantica e lessicale del contenuto.

# Struttura del *parser*

-   Il nostro *parser* dovrà leggere in input la descrizione di una scena usando un `InputStream` e produrre una serie di oggetti in memoria:

    -   Una variabile di tipo `World`;
    -   La definizione dell'osservatore;
    -   Una tabella contenente tutti i `Material` definiti nella scena e associati al loro nome (es., `sky_material` nel nostro esempio);
    -   Una tabella contenente tutte le variabili `float`.
    
-   La tabella dei materiali e delle variabili non servirà per fare il *rendering* della scena, ma può essere utile per stampare a video una tabella riassuntiva, oppure per fare *debugging*.

# Il tipo `Scene`

-   Codificheremo quindi il risultato del *parsing* in un nuovo tipo, `Scene`

-   In [pytracer](https://github.com/ziotom78/pytracer/blob/03225baa510d97c004f8165609e590b4f5849de2/scene_file.py#L329L336), il tipo è definito così:

    ```python
    class Scene:
        """A scene read from a scene file"""
        materials: Dict[str, Material] = field(default_factory=dict)
        world: World = World()
        camera: Union[Camera, None] = None
        float_variables: Dict[str, float] = field(default_factory=dict)
        overridden_variables: Set[str] = field(default_factory=set)
    ```

# Funzioni `expect_*`

-   Nella nostra grammatica, capita spesso che in certi punti la presenza di un simbolo, un identificatore, o una particolare *keyword* sia **obbligatoria**.

-   È molto comodo implementare quindi funzioni come `expect_symbol`, `expect_number`, etc., che gestiscano eventuali condizioni in cui il *token* letto non è del tipo atteso, ad esempio:

    ```python
    def expect_symbol(s: InputStream, symbol: str):
        """Read a token from `input_file` and check that it matches `symbol`."""
        token = input_file.read_token()
        if not isinstance(token, SymbolToken) or token.symbol != symbol:
            raise GrammarError(token.location, f"got '{token}' instead of '{symbol}'")
    ```

# Funzione `expect_keyword`

-   Se nel caso di simboli solitamente è richiesto l'uso di **un particolare simbolo** (es., la parentesi tonda aperta), nel caso delle keyword il nostro linguaggio ammette spesso diverse possibilità.

-   Ad esempio, nell'interpretare una BRDF, ci si può aspettare sia `diffuse` che `specular`.

-   La funzione [`expect_keywords`](https://github.com/ziotom78/pytracer/blob/03225baa510d97c004f8165609e590b4f5849de2/scene_file.py#L346-L358) dovrebbe quindi accettare come parametro una **lista** di keyword ammesse, anziché una sola. (Di solito questo è utile anche per i simboli, ma nel nostro caso specifico è inutile: laddove la nostra grammatica richiede un simbolo, questo è sempre univocamente determinato).

# Lista di funzioni `expect_*`

-   Il codice di [pytracer](https://github.com/ziotom78/pytracer/blob/03225baa510d97c004f8165609e590b4f5849de2/scene_file.py#L339-L396) implementa queste funzioni:

    #.   `expect_symbol(s: InputStream, symbol: str)`
    #.   `expect_keywords(s: InputStream, keywords: List[KeywordEnum]) -> KeywordEnum`
    #.   `expect_number(s: InputStream, scene: Scene) -> float`
    #.   `expect_string(s: InputStream) -> str`
    #.   `expect_identifier(s: InputStream) -> str`

-   Ovviamente avete la libertà di variare questo approccio come pensate sia meglio per il vostro linguaggio (esempio: potete rendere tutte queste funzioni dei metodi di `InputStream`).

# `expect_number`

-   La funzione [`expect_number`](https://github.com/ziotom78/pytracer/blob/03225baa510d97c004f8165609e590b4f5849de2/scene_file.py#L361-L374) è un po' più sofisticata delle altre, perché ammette sia *literal* che identificatori a variabili già definite:

    ```python
    def expect_number(s: InputStream, scene: Scene) -> float:
        token = input_file.read_token()
        if isinstance(token, LiteralNumberToken):
            return token.value
        elif isinstance(token, IdentifierToken):
            variable_name = token.identifier
            if variable_name not in scene.float_variables:
                raise GrammarError(token.location, f"unknown variable '{token}'")
            return scene.float_variables[variable_name]

        raise GrammarError(token.location, f"got '{token}' instead of a number")
    ```
    
-   È questo il motivo per cui richiede un parametro `Scene`.

# Funzioni `parse_*`

-   Le funzioni [`parse_*`](https://github.com/ziotom78/pytracer/blob/03225baa510d97c004f8165609e590b4f5849de2/scene_file.py#L399-L616) si occupano invece di interpretare *liste* di token, ed impiegano al loro interno le funzioni `expect_*`.

-   Ad esempio, l'implementazione di [`parse_color`](https://github.com/ziotom78/pytracer/blob/03225baa510d97c004f8165609e590b4f5849de2/scene_file.py#L411-L420) in pytracer è fatta così:

    ```python
    def parse_color(s: InputStream, scene: Scene) -> Color:
        expect_symbol(input_file, "<")
        red = expect_number(input_file, scene)
        expect_symbol(input_file, ",")
        green = expect_number(input_file, scene)
        expect_symbol(input_file, ",")
        blue = expect_number(input_file, scene)
        expect_symbol(input_file, ">")
        return Color(red, green, blue)
    ```
    
-   L'uso di [`expect_number`](https://github.com/ziotom78/pytracer/blob/03225baa510d97c004f8165609e590b4f5849de2/scene_file.py#L361-L374) abilita la possibilità di usare variabili `float`.

# Lista di funzioni `parse_*`

#.  ```parse_vector(s: InputStream, scene: Scene) -> Vec```
#.  ```parse_color(s: InputStream, scene: Scene) -> Color```
#.  ```parse_pigment(s: InputStream, scene: Scene) -> Pigment```
#.  ```parse_brdf(s: InputStream, scene: Scene) -> BRDF```
#.  ```parse_material(s: InputStream, scene: Scene) -> Tuple[str, Material]```
#.  ```parse_transformation(input_file, scene: Scene)```
#.  ```parse_sphere(s: InputStream, scene: Scene) -> Sphere```
#.  ```parse_plane(s: InputStream, scene: Scene) -> Plane```
#.  ```parse_camera(s: InputStream, scene) -> Camera```

# La funzione `parse_scene`

-   La funzione [`parse_scene`](https://github.com/ziotom78/pytracer/blob/03225baa510d97c004f8165609e590b4f5849de2/scene_file.py#L571-L616) è quella più ad alto livello di tutte: deve interpretare la scena e produrre in output un oggetto `Scene`:

    ```python
    parse_scene(s: InputStream) -> Scene
    ```
    
-   Nella grammatica EBNF che abbiamo visto a lezione, una scene è una lista di zero o più definizioni di `float`/materiale/sfera/piano/osservatore (`scene ::= declaration*`). Dal punto di vista del codice, questo va scandito in un ciclo `while`.

-   La stessa cosa vale per le definizioni EBNF ricorsive, come `transformation`, che in aggiunta deve usare il *look-ahead*.


# *Look-ahead* di *token*

# Grammatica LL(1)

-   Nella lezione di teoria abbiamo visto che la nostra è una grammatica di tipo LL(1): per interpretare correttamente le trasformazioni occorre a volte leggere in anticipo il *token* successivo.

-   Questa funzionalità va implementata in `InputStream`, tramite una funzione [`unread_token`](https://github.com/ziotom78/pytracer/blob/03225baa510d97c004f8165609e590b4f5849de2/scene_file.py#L323-L326) che si appoggia a un nuovo membro [`saved_token`](https://github.com/ziotom78/pytracer/blob/03225baa510d97c004f8165609e590b4f5849de2/scene_file.py#L181) da aggiungere a `InputStream`.

---

```python
class InputStream:
    def __init__(self, stream, file_name="", tabulations=8):
        # …

        self.saved_token: Union[Token, None] = None

    def read_token(self) -> Token:
        if self.saved_token:
            result = self.saved_token
            self.saved_token = None
            return result
            
        # Continue as usual
        # …

    def unread_token(self, token: Token):
        """Pretend that `token` was never read from `input_file`"""
        assert not self.saved_token
        self.saved_token = token
```

# Implementazione di `main`

# Da `demo` a `render`

-   Il `main` del vostro programma ha finora accettato due comandi:

    #.  `pfm2png`, per applicare il *tone mapping* a immagini HDR;
    #.  `demo`, per generare l'immagine dimostrativa.
    
-   Oggi dovete rinominare il comando `demo` in `render`, e fare in modo che accetti un file da linea di comando.

-   È ovviamente un'ottima idea aggiungere una cartella `examples` nel vostro repository, in cui aggiungere una immagine dimostrativa (o più di una!).

# Animazioni

-   Il [`main` di pytracer](https://github.com/ziotom78/pytracer/blob/03225baa510d97c004f8165609e590b4f5849de2/main.py#L72-L192) ammette una funzionalità aggiuntiva che è comoda per le animazioni: si possono specificare i valori di variabili da linea di comando. Ad esempio:

    ```
    ./main --declare-float=clock:150.0 examples/demo.txt
    ```
    
    L'effetto di [`--declare-float`](https://github.com/ziotom78/pytracer/blob/03225baa510d97c004f8165609e590b4f5849de2/main.py#L118-L124) è quello di dichiarare una variabile `clock` e assegnarle il valore 150.0.
    
-   Questo di per sè non genera animazioni, ma è molto comodo per realizzarle:

    ```
    for angle in $(seq 0 359); do
        ./main --declare-float=clock:$angle --pfm-output=image$angle.pfm examples/demo.txt
    done
    ```
    
# Sovrascrivere variabili
    
-   Per semplificare l'esecuzione all'utente, questo tipo di definizioni può **sovrascrivere** definizioni già esistenti nel file di input (`examples/demo.txt` in quest'esempio).

-   In altre parole, il file con la scena può contenere al suo interno la definizione della variabile `clock`:

    ```python
    float clock(150.0)
    ```
    
    In presenza di `--declare-float=clock:0.0`, il valore 150 viene ignorato e il valore 0 viene usato al suo posto. Ma se non si passa questo argomento da linea di comando, la scena resta comunque leggibile.

# Sovrascrivere variabili

-   Abbiamo però il problema dell'uovo e della gallina: i parametri da linea di comando sono interpretati *prima* di leggere il file della scena, ma le variabili sono create *durante* la lettura della scena. Se definiamo `clock` sia da linea di comando che nel file, avremo un errore (doppia definizione).

-   Vi sono molte soluzioni per implementare la funzionalità descritta:

    #.   Marcare le variabili definite da linea di comando con un flag Booleano; quando nel file della scena si ridefiniscono queste variabile, non viene prodotto un errore se questo flag è `True`.
    #.   In fase di definizione di una variabile, si controlla se il valore è già stato letto da linea di comando: se sì, si ignora il valore letto nel file e si usa quello fornito dall'utente. ([Questo è quanto fa pytracer](https://github.com/ziotom78/pytracer/blob/03225baa510d97c004f8165609e590b4f5849de2/scene_file.py#L595-L601)).

# Una richiesta

# Una richiesta

-   È utile per gli studenti futuri conoscere le vostre impressioni sul linguaggio che avete scelto:

    #.  Perché avete scelto questo linguaggio? Quali altre alternative avevate valutato, e perché le avete scartate?
    #.  Indipendentemente dal linguaggio scelto, quali sono stati i criteri che vi hanno aiutato a decidere? Come li giudicate col senno di poi?
    #.  Alla luce del lavoro di questo semestre, pensate sia stata una buona scelta?
    #.  Se tornaste indietro, rifareste questa scelta? Perché?
    
-   Vi chiedo un breve testo che risponda a queste domande, che renderò disponibile (anonimamente, se preferite) ai futuri studenti; quindi scrivete immaginando che siano *loro*, non io, il vostro uditorio.

# Guida per l'esercitazione

# Guida per l'esercitazione

#.  Continuate a lavorare nel *branch* `scenefiles`;
#.  Modificate `InputStream` in modo che consenta il *look-ahead* di token oltre che di caratteri;
#.  Create le funzioni `expect_*` e `parse_*`;
#.  Cambiate il comando `demo` nel `main` con `render`, e permettete di leggere la scena da file;
#.  Aggiornate la documentazione e il `CHANGELOG`
#.  Rilasciate la versione `1.0`: congratulazioni!

