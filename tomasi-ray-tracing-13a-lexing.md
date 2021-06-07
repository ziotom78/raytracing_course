---
title: "Lezione 13"
subtitle: "Analisi lessicale"
author: "Maurizio Tomasi <maurizio.tomasi@unimi.it>"
...

# Interpretare file di testo

# Contesto del problema

-   Finora abbiamo creato immagini fotorealistiche modificando il comando `demo` del nostro raytracer.

-   Dovreste aver ormai riscontrato tutti una certa farraginosità nella procedura! Tutte le volte che abbiamo voluto modificare l'immagine, occorreva compiere queste azioni:

    #.  Modificare il codice nel `main`;
    #.  Ricompilare;
    #.  Eseguire il codice e controllare il risultato.
    
-   Questo approccio potrebbe non essere sostenibile: di fatto obblighiamo gli utenti a scrivere codice nel linguaggio di programmazione che abbiamo usato!

# Obbiettivo

-   Il nostro obbiettivo è di definire un *formato* per la descrizione delle scene, e di scrivere del codice per interpretarlo.

-   Una volta implementato, l'utente userà un comune editor come Emacs o Visual Studio Code per creare un file, chiamato ad es. `scene.txt`, ed eseguirà il programma così:

    ```
    ./myprogram render scene.txt
    ```
    
    e gli oggetti `Shape` e `Material` saranno creati in memoria basandosi su quanto specificato in `scene.txt`. A differenza del comando `demo` però, è facile modificare `scene.txt`.
    
-   Quello che ci aspetta è di fatto l'implementazione di un *compilatore*!

# Categorie di utenti

-   Nel caso in cui il linguaggio usato sia Julia o Python, che ammette un uso interattivo, la soluzione migliore sarebbe quella di definire le scene direttamente sulla REPL (o in un notebook Jupyter/Pluto)!

-   Ma nel caso di programmi scritti in C++, C\# o Kotlin, una soluzione del genere non è ovviamente percorribile.

-   L'implementazione di un mini-linguaggio **non è la soluzione migliore** per linguaggi che offrono una REPL come Julia; chiedo comunque a tutti di implementare quanto richiesto, perché l'esercizio offre tanti spunti didattici.

# Valore didattico dell'esercizio

#.  Per implementare questa *feature* dovremo apprendere i rudimenti della teoria dei compilatori, che non viene affrontata in altri corsi (che io sappia), ma che insegna a scrivere codice molto elegante.

#.  Avete usato in questo corso linguaggi diversi: ora capirete meglio perché i linguaggi richiedono di definire le cose in un modo anziché in un altro, e certi errori dei compilatori saranno più comprensibili.

#.  Dovremo scrivere codice che gestisca le (tante) possibili condizioni di errore in modo robusto ed elegante, più di quanto abbiamo fatto sinora (un *path-tracer* non è il contesto migliore per imparare ciò): ciò è molto educativo!

#.  Creare nuovi linguaggi può essere molto divertente!

# Tipi di linguaggi

*General-purpose languages*
: Questi sono i «linguaggi di programmazione» che conoscete bene (C++, Python, etc.).  Sono chiamati *general-purpose* perché non sono pensati per un dominio specifico, potendo essere usati per creare videogiochi, sistemi operativi, librerie numeriche, applicazioni grafiche, etc.

*Domain-specific languages* (DSL)
: Si tratta di linguaggi che risolvono un problema molto specifico, e la cui sintassi è pensata per esprimere il problema nel modo più naturale possibile.

Nel nostro caso dovremo definire un DSL e implementare un compilatore per esso. Il nostro sarà un approccio con *molta* pratica e quel tanto che basta di teoria.

# Esempi di DSL

# SQL

-   SQL (*Structured Query Language*) è un linguaggio usato per creare/modificare/consultare tabelle di dati salvate in database:

    ```sql
    CREATE TABLE measurement (time text, sensor text, value real, flags number);
    INSERT INTO measurement VALUES ('2021-06-06', 'LKS-0001', 1.73, 0);
    INSERT INTO measurement VALUES ('2021-06-07', 'LKS-0001', 1.46, 1);
    SELECT time, value FROM measurement WHERE sensor = 'LKS-0001' AND value > 1.50;
    ```

-   La libreria [sqlite3](https://www.sqlite.org/index.html) implementa un interprete SQL e un formato di dati, consentendo di salvare/leggere questi database da file. È una delle librerie più usate al mondo, ed è usata in Linux, Mac OS X, Android e iOS.

-   È una libreria invocabile da [C/C++](https://www.sqlite.org/cintro.html), [Python](https://docs.python.org/3/library/sqlite3.html), [C\#](https://zetcode.com/csharp/sqlite/), etc., ma il comando consente di operare direttamente dalla linea di comando!

---

<asciinema-player src="cast/sqlite3-example-89x25.cast" cols="89" rows="25" font-size="medium"></asciinema-player>

Immaginate come implementare questi comandi in linguaggi come C++ o Python. Ovviamente SQL è molto più immediato!


# DSL in linguaggi *general-purpose*

-   Non dovreste stupirvi del fatto che oggi inventeremo un nuovo «linguaggio» per il nostro programma: è un'attività più comune di quanto si pensi (anche se i fisici non lo fanno quasi mai ☹).

-   È talmente comune che alcuni linguaggi *general-purpose* prevedono la possibilità di definire DSL **al proprio interno**: sono i linguaggi cosiddetti «metaprogrammabili» (es., [Common LISP](https://gigamonkeys.com/book/practical-a-simple-database.html), [Julia](https://docs.julialang.org/en/v1/manual/metaprogramming/), [Kotlin](https://www.raywenderlich.com/2780058-domain-specific-languages-in-kotlin-getting-started), [Nim](https://forum.nim-lang.org/t/2380)…).

-   Vediamo un paio di esempi.

# [ACME.jl](https://github.com/HSU-ANT/ACME.jl)

```julia
using ACME

circ = @circuit begin
    j_in = voltagesource()
    r1 = resistor(1e3)
    c1 = capacitor(47e-9)
    d1 = diode(is=1e-15)
    d2 = diode(is=1.8e-15)
    j_out = voltageprobe()
    j_in[+] ⟷ r1[1]
    j_in[-] ⟷ gnd
    r1[2] ⟷ c1[1] ⟷ d1[+] ⟷ d2[-] ⟷ j_out[+]
    gnd ⟷ c1[2] ⟷ d1[-] ⟷ d2[+] ⟷ j_out[-]
end
```

La libreria ACME (Julia) definisce una serie di operatori come `⟷` e `[±]` per descrivere un circuito elettrico con una sintassi semplice da leggere.

# [Karax](https://github.com/karaxnim/karax) (Nim)

```nim
import karax / [karaxdsl, vdom]

const places = @["boston", "cleveland", "los angeles", "new orleans"]

proc render*(): string =
  let vnode = buildHtml(tdiv(class = "mt-3")):
    h1: text "My Web Page"
    p: text "Hello world"
    ul:
      for place in places:
        li: text place
    dl:
      dt: text "Can I use Karax for client side single page apps?"
      dd: text "Yes"

      dt: text "Can I use Karax for server side HTML rendering?"
      dd: text "Yes"
  result = $vnode

echo render()
```

La libreria [karax/karaxdsl](https://github.com/karaxnim/karax) estende il linguaggio [Nim](https://nim-lang.org/) con comandi come `h1` e `p`, in modo che si possano definire gli elementi che definiscono una pagina HTML.

# Linguaggi per la definizione di scene 3D

# Panoramica

-   A noi non interessano database né circuiti elettrici né pagine HTML: siamo interessati alla definizione di scene 3D.

-   Per definire il nostro linguaggio dovremmo innanzitutto farci un'idea di cosa faccia la «concorrenza».

-   Vediamo quindi come quattro *renderer* permettono di specificare le scene che sono fornite come input: DBKTrace, POV-Ray, PolyRay e YafaRay. Ovviamente tutti questi programmi funzionano da linea di comando come farà il nostro:

    ```
    $ program input_file
    ```

# DKBTrace

-   Nel 1986 David K. Buck rilasciò DKBTrace, un ray-tracer che usava l'algoritmo di *point-light tracing*.
-   Scritto in C.
-   Il programma funzionava solo sul [Commodore Amiga](https://en.wikipedia.org/wiki/Amiga), un vecchio microcomputer molto usato all'epoca per la grafica.
-   Lo sviluppatore abbandonò ben presto DKBTrace per lavorare a POV-Ray (che vedremo tra poco).

# File di input

```text
{ DKBTrace example file }
INCLUDE "colors.dat"
INCLUDE "shapes.dat"
INCLUDE "textures.dat"

VIEW_POINT
    LOCATION  <0 0 0>
    DIRECTION <0 0 1>
    UP        <0 1 0>
    RIGHT     <1.33333 0 0>
END_VIEW_POINT

OBJECT
    SPHERE
        <0 0 3> 1
    END_SPHERE
    TEXTURE
        COLOUR Red
    END_TEXTURE
END_OBJECT

OBJECT
    SPHERE
        <0 0 0> 1
    END_SPHERE
    TEXTURE
        COLOUR White
    END_TEXTURE
    TRANSLATE <2 4 -3>
    LIGHT_SOURCE
    COLOUR White
END_OBJECT
```

# [POV-Ray](http://povray.org/)

-   POV-Ray risolve l'equazione del rendering usando il *point-light tracing* (ma che nel manuale di POV-Ray viene chiamato semplicemente *raytracing*), esattamente come DKBTrace.

-   La prima versione è stata rilasciata nel 1991; al momento la versione più recente è la 3.7.0 (rilasciata nel 2013). La versione 3.8 è in fase di preparazione.

-   In origine era stato scritto in C, e poi [riscritto in C++](https://github.com/POV-Ray/povray/tree/3.7-stable).

-   A partire dalla versione 3.0 implementa l'algoritmo [*radiosity*](https://en.wikipedia.org/wiki/Radiosity_(computer_graphics)) per simulare sorgenti diffuse in maniera simile al path-tracing.

# File di input

```povray
// POV-Ray example file
#include "colors.inc"
background { color Cyan }

#declare tex = texture {
    pigment { color Yellow }
}

camera {
  location <0, 2, -3>
  look_at  <0, 1,  2>
}

sphere {
  <0, 1, 2>, 2
  texture { tex }
}

light_source { <2, 4, -3> color White }
```

---

<center>![](media/mtpiano.webp){height=640px}</center>

# PolyRay

-   Creato da Alexander Enzmann nel 1991 (lo stesso anno di POV-Ray!).
-   Scritto interamente in C.
-   Ultima versione (1.8) rilasciata nel 1995.
-   Non più sviluppato, ma usato come ispirazione nello sviluppo delle versioni di POV-Ray successive alla 1.0.

# File di input

```text
// PolyRay example file
viewpoint {
    from <0,0,-8>        // The location of the eye
    at <0,0,0>           // The point that we are looking at
    up <0,1,0>           // The direction that will be up
    angle 45             // The vertical field of view
    resolution 160, 160  // The image will be 160x160 pixels
}

background skyblue

light <-10,3, -20>

define shiny_red
texture {
   surface {
      color red
      ambient 0.2
      diffuse 0.6
      specular white, 0.5
      microfacet Cook 5
   }
}

object {
   sphere <0, 0, 0>, 2
   shiny_red
}
```

# [YafaRay](http://www.yafaray.org/)

-   Scritto in C++ (repository su [GitHub](https://github.com/YafaRay)).

-   Risolve l'equazione del rendering usando un algoritmo di *path-tracing*.

-   Può essere usato in Blender come «motore» per il rendering.

-   Il formato delle scene è XML.

# File di input

```xml
<scene>

<shader type="generic" name="Default">
    <attributes>
        <color r="0.750000" g="0.750000" b="0.800000" />
        <specular r="0.000000" g="0.000000" b="0.000000" />
        <reflected r="0.000000" g="0.000000" b="0.000000" />
        <transmitted r="0.000000" g="0.000000" b="0.000000" />
    </attributes>
</shader>

<transform
    m00="8.532125" m01="0.000000" m02="0.000000" m03="0.000000"
    m10="0.000000" m11="8.532125" m12="0.000000" m13="0.000000"
    m20="0.000000" m21="0.000000" m22="8.532125" m23="0.000000"
    m30="0.000000" m31="0.000000" m32="0.000000" m33="1.000000"
>
<object name="Plane" shader_name="Default" >
    <attributes>
    </attributes>
    <mesh>
        <include file=".\Meshes\Plane.xml" />
    </mesh>
</object>
</transform>

<light type="pathlight" name="path" power= "1.000000" depth="2" samples="16" 
       use_QMC="on" cache="on"  cache_size="0.008000"
       angle_threshold="0.200000"  shadow_threshold="0.200000" >
</light>

<camera name="Camera" resx="1024" resy="576" focal="1.015937" >
    <from x="0.323759" y="-7.701275" z="2.818493" />
    <to x="0.318982" y="-6.717273" z="2.640400" />
    <up x="0.323330" y="-7.523182" z="3.802506" />
</camera>

<filter type="dof" name="dof" focus="7.97854234329" near_blur="10.000000"
        far_blur="10.000000" scale="2.000000">
</filter>

<filter type="antinoise" name="Anti Noise" radius="1.000000"
        max_delta="0.100000">
</filter>

<background type="HDRI" name="envhdri" exposure_adjust="1">
    <filename value="Filename.HDR" />
</background>

<render camera_name="Camera" AA_passes="2" AA_minsamples="2"
        AA_pixelwidth="1.500000" AA_threshold="0.040000"
        raydepth="5" bias="0.300000" indirect_samples="1"
        gamma="1.000000" exposure="0.000000" background_name="envhdri">
    <outfile value="butterfly2.tga"/>
    <save_alpha value="on"/>
</render>

</scene>
```

---

<center>![](media/yafray-example.webp)</center>

# Il «nostro» formato

# Definire il formato

-   Ci aspetta ora un compito molto eccitante: definire il nostro formato!

-   Potremmo ispirarci a formati molto semplici, come ad esempio il Wavefront OBJ che avevamo descritto [tempo fa](./tomasi-ray-tracing-10a-other-shapes.html#wavefront-obj): ogni riga contiene una lettera (`v`, `f`, `n`, etc.) seguita da una sequenza di numeri.

-   Ad esempio, potremmo definire una BRDF diffusiva (`d`) con colore $(0.3, 0.7, 0.5)$ associata a una sfera (`s`) centrata in $(1, 3, 6)$ di raggio $r = 2$ con un codice del genere:

    ```text
    d 0.3 0.7 0.5
    s 1 3 6 2
    ```
    
    Ma non sarebbe affatto leggibile! Proviamo a pensare a qualcosa di più elegante.

# Come implementare il formato

-   Un buon formato non deve essere ambiguo, e deve anche essere facile da imparare.

-   Anziché usare lettere come `s` o `d` per indicare diverse entità (sfera o BRDF diffusiva), useremo stringhe di caratteri (`sphere` e `diffuse`)

-   La scrittura `s 1 3 6 2` non è chiara, perché non si distingue il raggio dalle coordinate. Ispirandoci alla sintassi di Python e Julia, indicheremo punti e vettori con le parentesi angolari, ad es. `[1, 3, 6]`.

-   Implementeremo anche la possibilità di associare un nome agli oggetti: in questo modo potremo fare riferimento a BRDF create in precedenza (es., `green_matte`) quando definiamo nuove `Shape`.

# Cosa includere

Pensiamo a cosa deve essere specificabile nel nostro formato. Dobbiamo sicuramente prevedere una sintassi per ciascuno di questi oggetti:

- Osservatori;
- Forme (sfere, piani, e qualsiasi altro oggetto voi abbiate implementato);
- Trasformazioni;
- Vettori;
- Materiali;
- BRDF;
- Pigmenti;
- Colori;
- Numeri.

# Scelte da compiere

-   Dobbiamo definire una sintassi per creare oggetti, e ovviamente ci sono varie possibilità. Ad esempio, per definire una sfera potremmo usare una qualsiasi di queste quattro sintassi:

    ```text
    sphere: [1, 3, 6], 2
    sphere([1, 3, 6], 2)
    sphere with center=[1, 3, 6], radius=2
    [1, 3, 6] 2 sphere
    ```
    
    (L'ultima sintassi è comune in linguaggi *stack-based* come il Postscript).
    
-   La scelta dell'una o dell'altra sintassi è in linea di principio completamente nelle nostre mani!
    
-   Senza ulteriori indugi, vi mostro la sintassi che ho scelto per il corso tramite un esempio concreto.


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

# Come interpretare il formato?

-   Da un punto di vista puramente concettuale, il compito che ci aspetta non è poi così diverso da quello di leggere un file PFM…

-   …con la differenza però che il file di input che consideriamo ora è molto più complesso e «duttile» del formato PFM!

-   Questa maggiore versatilità comporta molti più rischi di errore: è facile per l'utente che crea una scena dimenticarsi una virgola, o confondere la notazione `<>` (colori) con `[]` (vettori). Dobbiamo quindi prestare grande cura alla segnalazione degli errori all'utente!

-   Per interpretare questo tipo di file occorre procedere per gradi.

# Paragone coi compilatori

-   Il lavoro che ci aspetta è simile alla scrittura di un compilatore vero e proprio. Ad esempio, il comando `g++` legge in input file di testo fatti come il seguente:

    ```c++
    #include <iostream>
    
    int main(int argc, const char *argv[]) {
      std::cout << "The name of the program is " << argv[0] << "\n";
    }
    ```
    
    e produce in output un file eseguibile che contiene la sequenza di istruzioni macchina corrispondenti a questo codice C++.
    
-   Nel nostro caso il codice deve costruire in memoria una serie di variabili che contengono le `Shape`, la `Camera` e i `Material` di cui è composta la scena.

# Terminologia

Per chi lavora con interpreti/compilatori è prassi usare alcuni termini della linguistica:

-   L'analisi del **lessico** studia la tipologia delle singole parole, e stabilisce ad esempio che la parola «invece» è corretta, mentre «invecie» è sbagliata.
-   L'analisi della **sintassi** studia i rapporti tra gli elementi di una espressione, e stabilisce ad esempio che un verbo non può mai seguire un articolo («un mangeremmo»).
-   L'analisi della **semantica** studia il rapporto tra una espressione come «la casa in fondo alla strada» e l'oggetto extra-linguistico a cui si fa riferimento (appunto, quella particolare casa in fondo alla strada).

# Linguaggi informatici

Nel caso di un «linguaggio» informatico come il nostro, la sua analisi viene solitamente fatta seguendo lo stesso ordine della slide precedente:

1.  Un'analisi **lessicale**, in cui si verifica che le singole «parole» siano scritte correttamente;
2.  Un'analisi **sintattica**, in cui si considera come le singole «parole» sono concatenate;
3.  Un'analisi **semantica**, il cui risultato è l'insieme di variabili in memoria del tipo corrispondente (nel nostro caso, `Sphere`, `Plane`, `SpecularBRDF`, etc.), come se fossero state dichiarate ed inizializzate direttamente nel nostro codice sorgente.

# Workflow di un compilatore

```{.graphviz im_fmt="svg" im_out="img" im_fname="compiler-architecture"}
graph "" {
    rankdir="LR";
    source [label="source code" shape=ellipse];
    lexer [label="lexer" shape=box];
    parser [label="parser" shape=box];
    AST [label="AST builder" shape=box];
    optimizer [label="optimizer" shape=box];
    executable [label="executable" shape=ellipse];
    
    source -- lexer;
    lexer -- parser;
    parser -- AST;
    AST -- optimizer;
    optimizer -- executable;
}
```

-   Il *lexer* scompone il codice sorgente in elementi semplici, chiamati *token*;
-   Il *parser* analizza la sequenza dei *token* per legarli tra loro e comprenderne la sintassi e la semantica;
-   L'*AST builder* crea il cosiddetto *Abstract Syntax Tree* (non usato nel nostro caso);
-   L'*optimizer* applica ottimizzazioni all'AST (non usato nel nostro caso);
-   Dall'AST ottimizzato viene generato l'eseguibile (non usato nel nostro caso).

# Esempio: analisi lessicale

-   Consideriamo le prime righe dell'esempio mostrato poco fa:

    ```text
    # Declare a variable named "clock"
    float clock(150)
    ```

-   Il risultato dell'analisi lessicale delle linee sopra è la produzione della sequenza di token seguente (da cui sono già rimossi spazi bianchi e commenti):

    ```python
    [
        KeywordToken(TOKEN_FLOAT), # A "keyword", because "float" is a reserved word
        IdentifierToken("clock"),  # An "identifier" is a variable name
        SymbolToken("("),
        LiteralNumberToken(150.0),
        SymbolToken(")"),
    ]
    ```

# Esempio: analisi sintattica

```text
# Declare a variable named "clock"
float clock(150)
```

-   L'analisi sintattica parte dalla sequenza di token prodotta dall'analisi lessicale:

    ```python
    [
        KeywordToken(TOKEN_FLOAT), IdentifierToken("clock"), SymbolToken("("),
        LiteralNumberToken(150.0), SymbolToken(")"),
    ]
    ```

-   L'analisi sintattica deve verificare che la sequenza di token sia corretta: se il primo token è la parola chiave `float`, allora significa che stiamo definendo una variabile floating-point. È quindi necessario che il token successivo contenga il nome della variabile (deve essere un *identificatore*), seguito dal valore numerico racchiuso tra le parentesi.


# Errori di sintassi

-   Prendendo spunto da questo esempio, considerate il seguente codice C++:

    ```c++
    int if;
    std::cout << "Enter a number: ";
    std::cin >> if;
    
    if (if % 2 == 0)
        std::cout << "The number is even\n";
    ```

-   Questo codice sopra è perfettamente comprensibile da un essere umano, ma il C++ lo vieta! (L'equivalente in Scheme sarebbe invece ok).

-   L'errore è causato dal fatto che la sintassi del C++ richiede che il tipo della variabile (`int`) sia seguito da un *identificatore*, e non da una *keyword* (`if`).


# Esempio: analisi semantica

```text
# Declare a variable named "clock"
float clock(150)
```

-   Il risultato dell'analisi sintattica dice che l'istruzione richiede di creare una variabile `clock` e di assegnarle il valore `150.0`.

-   L'analisi semantica deve verificare che la definizione di questa variabile non crei inconsistenze. Ad esempio, potrebbe verificare che `clock` non fosse già stata definita in precedenza, e nel caso scegliere una di queste possibilità:

    1.  Produrre un errore (è il caso del C++);
    2.  Aggiornare il valore della variabile `clock` anziché definirne una nuova con lo stesso nome (è il caso del Python e di Scheme).

# Implementazione

# Funzionamento del *lexer*

-   Il *lexer* è la parte di codice che si occupa dell'analisi lessicale.

-   Il suo compito è di leggere da uno *stream* (tipicamente un file) e produrre in output una lista di *token*, classificati secondo il loro tipo.

-   Per motivi di efficienza, i lexer *non* restituiscono una lista di token, ma leggono i *token* uno alla volta, restituendoli man mano che li interpretano, e si usano quindi così:

    ```python
    while True:
        token = read_token()
        if token.eof():
            break
            
        …
    ```

# Output di un *lexer*

-   Un *lexer* deve saper classificare i *token* a seconda del loro tipo.

-   A seconda del linguaggio esistono vari tipi di token; nel nostro caso abbiamo:

    #.  *Keyword*: una parola chiave del linguaggio, come `sphere` e `diffuse`;
    #.  *Identifier*: il nome di una variabile/tipo/funzione come `clock`;
    #.  *Numeric literal*: un numero come `150`, possibilmente distinto tra *integer literal* e *floating-point literal* (noi non faremo distinzione);
    #.  *String literal*: una stringa di caratteri, solitamente racchiusa tra `"` (doppi apici) o `'` (singoli apici);
    #.  *Symbol*: un carattere non alfanumerico, come `(`, `+`, `,`, etc.) Non considereremo simboli composti da più caratteri (es., `>=` in C++).

# Tipi di *token*

-   L'implementazione del tipo `Token` ci consente di approfondire il sistema dei tipi dei linguaggi che abbiamo usato nel corso.

-   Concettualmente, i diversi tipi di *token* sono derivati da un tipo base, `Token` appunto. È quindi naturale pensare a una gerarchia di classi, che ha `Token` come tipo base.

-   Questa soluzione funziona, ed è ciò che ho usato in pytracer. Non è però la soluzione più comoda!

---

```python
@dataclass
class Token:
    """A lexical token, used when parsing a scene file"""
    pass


class LiteralNumberToken(Token):
    """A token containing a literal number"""
    def __init__(self, value: float):
        super().__init__()
        self.value = value

    def __str__(self) -> str:
        return str(self.value)


class SymbolToken(Token):
    """A token containing a symbol (e.g., a comma or a parenthesis)"""
    def __init__(self, symbol: str):
        super().__init__()
        self.symbol = symbol

    def __str__(self) -> str:
        return self.symbol


# Etc.
```


# *Tokens* e gerarchie di classi

-   Ci sono alcuni svantaggi nell'usare una gerarchia di classi:

    #.  Il codice diventa molto verboso: si devono implementare tante classi, tutte molto simili tra loro.
    #.  Le gerarchie di classi sono pensate per essere *estendibili*: posso sempre definire una nuova classe derivata da `Token`. Ma nel caso di un linguaggio, l'elenco dei tipi di token è fissato ed è molto difficile che cambi.
    
-   Il tipo più indicato per un *token* è un *sum type*, chiamato anche *tagged union*, che si contrappone ai *product type* che tutti voi conoscete (probabilmente senza saperlo). Vediamo in cosa consistono.


# *Product types*

-   Le `struct`/`class` di linguaggi come C++, Python e Julia sono *product types*, perché dal punto di vista formale sono un **prodotto cartesiano** tra insiemi.

-   Consideriamo questa definizione in C++:

    ```c++
    struct MyStruct {
        int32_t a; // Can be any value in the set I of all 32-bit signed integers
        uint8_t c; // Can be any value in the set B of all 8-bit unsigned bytes
    };
    ```
    
    Se l'insieme di tutti i valori assumibili da un `int32_t` e da un `uint8_t` è denominato rispettivamente con $I$ e $B$, allora una variabile `MyStruct var` è tale per cui $\mathtt{var} \in I \times B$.


# *Sum types*

-   Un *sum type* combina tra loro più tipi usando la *somma insiemistica* (ossia l'unione $\cup$) anziché il prodotto cartesiano.

-   Nel nostro esempio C++, i *sum types* si definiscono tramite la parola chiave `union` (molto appropriata!):

    ```c++
    union MyUnion {
        int32_t a;
        uint8_t c;
    };
    ```
    
-   In questo caso, la variabile `MyUnion var` è tale per cui $\mathtt{var} \in I \cup B$: puo essere un `int32_t` **oppure** un `uint8_t`, ma non entrambi.

# Uso di `union`

```c++
union MyUnion {
    int32_t a;   // This takes 4 bytes
    uint8_t c;   // This takes 1 byte
};

/* The size in memory of MyUnion is *not* 4+1 == 5, but it is max(4, 1) == 4
 *
 * <-------a------->
 * +---+---+---+---+
 * | 1 | 2 | 3 | 4 |
 * +---+---+---+---+
 * <-c->
 */

int main() {
    MyUnion s;
    
    s.a = 10;   // Integer
    std::cout << s.a << "\n";
    
    s.c = 24U;  // This replaces the value 10 (signed) with the value (24) unsigned
    std::cout << s.c << "\n";
}
```

# *Sum types* e *token*

-   Un *token* è idealmente rappresentato da un *sum type*. Supponiamo di avere per semplicità due soli tipi di token, definiti in un codice C++:

    #.  *Literal number* (es., `150`), rappresentato in memoria come un `float`;
    #.  *Literal string* (es., `"filename.pfm"`), rappresentato da `std::string`;

-   Consideriamo ora una funzione `read_token(stream)` che restituisce il token successivo letto da `stream`: può restituire un *literal number* oppure un *literal string*.

-   Se i numeri appartengono all'insieme $N$ e le stringhe a $S$, allora è chiaro che il token `t` è tale per cui $\mathtt{t} \in N \cup S$: può essere uno dei due tipi, ma non più tipi contemporaneamente. È quindi logicamente un *sum type*!

# *Sum types* vs gerarchie

-   Una `union` racchiude all'interno di un'unica definizione tutti i tipi: 

    ```c++
    union MyUnion {
        int32_t a;   // This takes 4 bytes
        uint8_t c;   // This takes 1 byte
    };
    ```

-   È più semplice da leggere e da capire di una gerarchia di classi:

    ```c++
    struct Value {};
    
    struct Int32Value : Value { int32_t a; };
    
    struct UInt8Value : Value { uint8_t c; };
    ```


# *Sum types* e *token*

-   Potremmo allora definire il tipo `Token` in C++ nel modo seguente:

    ```c++
    union Token {
       float number;
       std::string string;
    };
    ```

-   Una volta assegnato un valore però non c'è modo di capire a quale dei due insiemi $N$ o $S$ appartenga l'elemento (le `union` non sono *tagged*):

    ```c++
    Token my_token;
    my_token = read_token(stream);  // Read the next token from the stream
    
    if (my_token.???)   // How can I check if it is a "literal number" or a "string"?
    ```

# *Tagged unions* in C/C++

```c++
// Kinds of tokens. Here we just consider two types
enum class TokenType {
  LITERAL_NUMBER,
  LITERAL_STRING,
};

// The sum type.
union TokenValue {
  float number;
  std::string string;

  // The default constructor and destructor are *mandatory* for unions to
  // be used in structs/classes
  TokenValue() : number(0.0) {}
  ~TokenValue() {}
};

// Here is the "Token" type! We just combine `TokenType` and `TokenValue`
// in a product type, which implements a proper "tagged union".
struct Token {
  TokenType type;    // The "tag"
  TokenValue value;  // The "union"

  Token() : type(TokenType::LITERAL_NUMBER) {}

  void assign_number(float val) {
      type = TokenType::LITERAL_NUMBER;
      value.number = val;
  }

  void assign_string(const std::string & s) {
      type = TokenType::LITERAL_STRING;
      value.string = s;
  }
};

int main() {
  Token my_token;
  token.assign_number(150.0);
}
```

# *Tagged unions* in C/C++

-   L'esempio mostra che per implementare una *tagged union* occorrono *tre* tipi:

    #.  Il tipo `Token` è una `struct` che contiene al suo interno il cosiddetto *tag* (che indica se il token appartiene a $N$ o a $S$);
    #.  Il tipo `TokenType` è il *tag*, ed un `enum` (C) o `enum class` (C++);
    #.  Il tipo `TokenValue` è la `union` vera e propria, che in C++ va corredata di un costruttore e un distruttore di default per poter essere usata in `Token`.

-   Questo modo di fare è complicato, ma è necessario in quei linguaggi come il C++ che non supportano le *tagged union* (vedi [questo post](https://www.schoolofhaskell.com/school/to-infinity-and-beyond/pick-of-the-week/sum-types) per una panoramica dei linguaggi che hanno questa lacuna). (Julia supporta le *tagged unions* tramite il tipo `Union` e la funzione `isa`, C\# e Kotlin non supportano i *sum types*).


# Esaustività dei controlli

```c++
// Let's assume we have four token types
enum class TokenType {
  LITERAL_NUMBER,
  LITERAL_STRING,
  SYMBOL,
  KEYWORD,
};

void print_token(const Token & t) {
    switch(t.type) {
    case TokenType::LITERAL_NUMBER: std::cout << t.value.number; break;
    case TokenType::LITERAL_STRING: std::cout << t.value.string; break;
    case TokenType::LITERAL_SYMBOL: std::cout << t.value.symbol; break;
    // Oops! I forgot TokenType::KEYWORD, but not every compiler will produce a warning!
    }
}
```


# *Sum types* fatti bene

-   Linguaggi come [Haskell](https://wiki.haskell.org/Algebraic_data_type), i derivati di ML (es., [OCaml](https://ocaml.org/), F\#), [Pascal](https://www.freepascal.org/docs-html/ref/refsu15.html), [Nim](https://nim-lang.org/docs/tut2.html#object-oriented-programming-object-variants), etc., consentono di definire *sum types* in maniera molto più naturale.

-   Ad esempio, ecco come definire il tipo `Token` in OCaml:

    ```ocaml
    type token = 
        | LiteralNumber of float
        | LiteralString of string
        | Symbol of char
        | Keyword of string;
    ```
 
    Non c'è bisogno di definire una lunga gerarchia di classi!
    
# Esaustività in OCaml
 
-   In linguaggi come [OCaml](https://ocaml.org/) e [F\#](https://fsharpforfunandprofit.com/posts/discriminated-unions/), i controlli sui *sum types* sono esaustivi:

    ```ocaml
    let tok = LiteralNumber 0.5;
    match tok with
       | LiteralNumber a -> print_float a
       | LiteralString s -> print_string s
       | Symbol c -> print_char c;
   
    (* Warning: this pattern-matching is not exhaustive.
     * Here is an example of a case that is not matched:
     * Keyword _                                         *)
    ```
    
-   I *sum types* rappresentano gerarchie di classi «rigide», dove c'è un solo antenato (`token`) e le classi figlie sono note a priori: proprio il caso dei token! Linguaggi come [OCaml](https://ocaml.org/) sono infatti spesso usati per scrivere compilatori (es., [FFTW](http://www.fftw.org/fftw-paper-ieee.pdf),  [Rust](https://www.reddit.com/r/rust/comments/18b808/is_the_original_ocaml_compiler_still_available/)).


# *Sum types* vs gerarchie

-   Un *sum type* come `union` in C/C++ è utile quando il numero di tipi (`LiteralToken`, `SymbolToken`, …) è limitato e non cambierà facilmente, mentre il numero di *metodi* da applicare a quel tipo (es., `print_token`) può crescere indefinitamente.

-   Una gerarchia di classi è utile nel caso contrario: il numero di tipi può crescere in numero potenzialmente illimitato, ma il numero di metodi è in linea di principio limitato. Un buon esempio è `Shape`: si possono definire infinite forme (`Sphere`, `Plane`, `Cone`, `Cylinder`, `Parabola`, etc.), ma il numero di operazioni da fare è limitato (`ray_intersection`, `is_point_inside`, etc.).


# Funzionamento di un *lexer*

# Funzionamento di un *lexer*

-   Il *lexer* legge i caratteri da uno stream, uno alla volta, e decide quali *token* creare a seconda dei caratteri in cui si imbatte.

-   Ad esempio, la lettura del carattere `"` (doppio apice) in un codice C++ indica che si sta definendo una stringa di caratteri:

    ```c++
    const char * message = "error, you must specify an input file";
    ```
    
    Quando i lexer usati nei compilatori C++ trovano un carattere `"`, essi  continuano a leggere caratteri fino al successivo `"`, che segnala la fine della stringa, e restituiscono un token *string literal*.

# Ambiguità nei *lexer*

-   Il caso di uno *string literal* è semplice da affrontare: tutte le volte che ci si imbatte in un carattere `"`, si ha a che fare con questo tipo di *token*.

-   Ma nella maggior parte dei casi un *lexer* deve affrontare ambiguità. Ad esempio, un carattere `a`…`z` indica che sta iniziando una *keyword*  come `int`, oppure un *identifier* come `iterations_per_minute`?

    In questo caso si leggono caratteri finché appartengono alla lista dei caratteri validi in un identificatore (solitamente lettere maiuscole/minuscole, cifre e il carattere `_`), poi si confronta la stringa letta con la lista di possibili *keyword* ammesse dal linguaggio.
    
# Tornare indietro

-   In un *lexer* (e vedremo che è così anche nei *parser*) è comoda la possibilità di far sì che un carattere appena letto dal file sia «dis-letto», ossia venga rimesso a posto:

    ```python
    c = read_char(file)   # Suppose that this returns the character "X"
    unread_char(file, c)  # Puts the "X" back into the file
    c = read_char(file)   # Read the "X" again
    ```
    
    Questo permette di scrivere il *lexer* in maniera più elegante.
    
-   L'operazione `unread_char` non fa nulla sul file (che è aperto in sola lettura!): semplicemente memorizza il carattere `X` in una variabile all'interno di `file`, e la restituisce alla successiva chiamata a `read_char`.

# Uso di `unread_char`

-   Perché `unread_char` è utile in un *lexer*? Vediamo per esempio questa espressione Python:

    ```python
    15+4
    ```
    
    che è composta dei *token* `15` (*numeric literal*), `+` (*symbol*), `4` (*numeric literal*).
    
-   Quando il *lexer* inizia il suo lavoro individua il carattere `1`, e capisce che deve creare un token *numeric literal*. A questo punto deve leggere i caratteri finché trova la prima non-cifra, che è `+`. La lettura di `+` segnala che l'intero è finito e va emesso un *literal number token*; ma `+` va rimesso a posto, perché farà parte del token successivo.


# Lettura di un *numeric literal*

```python
ch = read_char()

# Very basic and ugly code! It does not interpret negative numbers!
if ch.isdigit():
    # We have a numeric literal here!
    literal = ch

    while True:
        ch = read_char()  # Read the next character

        if ch.isdigit():
            # We have got the next digit for the current numeric literal
            literal += ch
        else:
            # The number has ended, so put the last character back in place
            self.unread_char(ch)
            break

    try:
        value = int(literal)
    except ValueError:
        print(f"invalid numeric literal {literal}")
```

# Condizioni di errore

-   Già nella scrittura del *lexer*, prima di occuparsi dell'aspetto sintattico e semantico, è possibile imbattersi in errori nel codice.

-   Ad esempio, la presenza di un carattere come `@` non è ammessa nel nostro linguaggio, e già il *lexer* può individuare questo tipo di errore.

-   Un altro esempio è la dimenticanza di chiudere il doppio apice `"` alla fine di una stringa.

# Come segnalare errori

-   Nei compilatori moderni, il tipo `Token` contiene al suo interno anche informazioni sulla posizione del token nel file sorgente (vedi ad esempio il tipo [`Token`](https://github.com/llvm/llvm-project/blob/llvmorg-10.0.0/clang/include/clang/Lex/Token.h) nella versione 10.0.0 del compilatore Clang: non è un'implementazione molto elegante, ma è ottimizzata per essere efficiente!).

-   Questa informazione serve al *lexer* e al *parser* per stampare messaggi d'errore come il seguente (prodotto da Clang 10):

    ```text
    test.cpp:31:15: error: no viable conversion from 'int' to 'std::string'
          (aka 'basic_string<char>')
      std::string message = 127;
                  ^         ~~~
    ```
    
    dove viene indicato il nome del file (`test.cpp`), il numero della riga (`31`) e il numero della colonna (`15`) in cui è stato trovato l'errore.

# Tracciare posizioni

-   La posizione di un token in un file è identificata da tre informazioni:

    #.  Il nome del file sorgente (una stringa);
    #.  Il numero della riga (un intero, numerato partendo da 1);
    #.  Il numero della colonna (idem).
    
-   Il tipo `Token` dovrebbe quindi contenere anche questi tre campi. Nel caso di pytracer ho definito un tipo `SourceLocation` che ho usato nella definizione.

-   Ad esempio, in Julia potete definire un token in questo modo:

    ```julia
    struct Token  # Use "isa(token.value, …) to determine the token type
        loc::SourceLocation
        value::Union{LiteralNumber, LiteralString, Keyword, Identifier, Symbol}
    end
    ```

# Segnalare errori

-   Il modo più pratico per segnalare errori è quello di sollevare una eccezione.

-   Questa eccezione deve avere associato un tipo `SourceLocation`, in modo che il codice possa scrivere un messaggio all'utente che riporti anche la posizione in cui è stato riscontrato l'errore.

-   Usare le eccezioni implica che non appena si trova un errore la compilazione si ferma. Questo non è molto *user-frendly*: se la compilazione è un processo lento (es., C++, Rust), sarebbe meglio produrre una *lista* di errori.

-   Noi non lo faremo: il nostro compilatore sarà molto veloce, e non è facile implementare un metodo per produrre una lista di errori, per il modo in cui si effettua l'analisi sintattica (v. la prossima lezione).
