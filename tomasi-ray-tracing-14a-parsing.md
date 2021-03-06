---
title: "Lezione 14"
subtitle: "Analisi sintattica e semantica – Conclusioni"
author: "Maurizio Tomasi <maurizio.tomasi@unimi.it>"
...

# Analisi sintattica e semantica

# Analisi sintattica e semantica

-   Nella scorsa lezione abbiamo visto come è possibile implementare un'analisi lessicale di un file sorgente che definisce la scena 3D.

-   Il *lexer* che abbiamo implementato legge una sequenza di caratteri da uno *stream* (un file) e produce come output una sequenza di *token*.

-   Il compito di oggi è interpretare la sequenza di *token* (analisi sintattica) e da questa costruire in memoria una serie di oggetti di tipo `Shape`, `Material`, etc. (analisi semantica).

# Analisi sintattica

-   La sintassi di un linguaggio è divisibile in categorie a seconda delle peculiarità nella sua sintassi e nel modo in cui sono quindi concatenati i token: LL(n), LR(n), GLR(n), LALR(n), etc.

-   Ciascuna di queste famiglie richiede algoritmi specifici per l'analisi sintattica, e purtroppo algoritmi che vanno bene per una famiglia non vanno bene per altre!

-   Il nostro linguaggio è di tipo LL(1), e l'algoritmo corrispondente per analizzare la grammatica è tra i più semplici.

# Come affrontare il problema

-   Consideriamo questa definizione:

    ```bash
    material sky_material(
        diffuse(image("sky-dome.pfm")),
        uniform(<0.7, 0.5, 1>)
    )
    ```
    
-   È una definizione che include elementi più complessi di un *token*:

    #.  Un materiale;
    #.  Una BRDF (`diffuse`);
    #.  Due pigmenti (`image` e `uniform`);
    #.  Un colore, indicato con `<0.7, 0.5, 1>`.
    
# Approccio *top-down*

-   La definizione di `sky_material` è però semplice da analizzare se suddividiamo il problema in tante funzioni, ciascuna delle quali analizza *un elemento soltanto*.

-   Definiamo quindi una funzione `parse_color` che si occupa di interpretare un colore e di restituire l'oggetto `Color` corrispondente, una funzione `parse_pigment`, una funzione `parse_brdf`, etc.

-   Queste funzioni avranno il compito di chiamarsi a vicenda, una dentro l'altra, in modo che quelle più ad alto livello come `parse_material` possano contare su quelle via via più semplici come `parse_color`.

# `parse_color`

```python
def expect_symbol(stream: InputStream, symbol: str):
    """Read a token from `stream` and check that it matches `symbol`."""
    token = stream.read_token()
    if not isinstance(token, SymbolToken) or token.symbol != symbol:
        raise parser_error(token, f"got '{token}' instead of '{symbol}'")
        
    # Don't bother returning the character: we were already expecting it


def expect_number(stream: InputStream) -> float:
    """Read a token from `stream` and check that it is a literal number.

    Return the number as a ``float``."""
    token = stream.read_token()
    if not isinstance(token, LiteralNumberToken):
        raise parser_error(token, f"got '{token}' instead of a number")
        
    return token.value


# This parses a list of tokens like "<0.7, 0.5, 1>". Note that functions
# with name "expect_*" only read *one* token, while functions named
# "parse_*" read more than one token.
def parse_color(stream: InputStream) -> Color:
    expect_symbol(stream, "<")
    red = expect_number(stream)
    expect_symbol(stream, ",")
    green = expect_number(stream)
    expect_symbol(stream, ",")
    blue = expect_number(stream)
    expect_symbol(stream, ">")

    # Create the "Color" object *immediately* (not something a real-world
    # compiler will do, but our case is simpler than a real compiler)
    return Color(red, green, blue)
```

# `parse_pigment`

```python
def parse_pigment(stream: InputStream) -> Pigment:
    keyword = expect_keywords(stream, [
        KeywordEnum.UNIFORM, 
        KeywordEnum.CHECKERED, 
        KeywordEnum.IMAGE,
    ])

    expect_symbol(stream, "(")
    if keyword == KeywordEnum.UNIFORM:
        # Example: "uniform(<0.7, 0.5, 1>)"
        color = parse_color(stream)
        
        result = UniformPigment(color=color)
    elif keyword == KeywordEnum.CHECKERED:
        # Example: "checkered(<0.3, 0.5, 0.1>, <0.1, 0.2, 0.5>, 4)"
        color1 = parse_color(stream)
        
        expect_symbol(stream, ",")
        
        color2 = parse_color(stream)
        
        expect_symbol(stream, ",")
        
        num_of_steps = int(expect_number(stream))
        
        result = CheckeredPigment(color1=color1, color2=color2, num_of_steps=num_of_steps)
    elif …: # Other pigments
        …
        
    expect_symbol(stream, ")")
    return result
```

# Analisi semantica e oltre

-   Il nostro «compilatore» è molto semplice, e non appena l'analisi sintattica capisce che si sta definendo una variabile/materiale/forma/osservatore crea immediatamente in memoria un oggetto corrispondente (es., `Color`).

-   Compilatori più complessi creano in memoria una AST (Abstract Syntax Tree), che  è una rappresentazione del contenuto del file sorgente molto comoda per fare un'analisi *semantica*. (Nel nostro caso, analisi sintattica e semantica sono fuse insieme).

-   La AST viene poi passata come input alle fasi successive del compilatore (ottimizzatore, generatore di codice, etc.); sono loro a preoccuparsi di creare oggetti in memoria o salvare istruzioni in linguaggio macchina su file.

# Perché una AST?

-   Consideriamo questo codice C++:

    ```c++
    #include <iostream>
    #include <cstdlib>

    int main(int argc, const char *argv[]) {
        float a = 15.0;
        float b = std::atof(argv[1]);

        std::cout << a << "\n" << b << "\n";
    }
    ```

-   A differenza del nostro parser, il compilatore C++ **non può** creare in memoria le variabili `a` e `b` mentre fa il *parsing*, perché quelle variabili «vivono» solo in fase di esecuzione.

# Ruolo della AST

-   Un programma come quello dell'esempio precedente «vive» nella memoria del computer due volte:

    1.  Quando viene compilato (`g++ -o myprog main.cpp`);
    2.  Quando viene eseguito (`./myprog 150.0`)
    
-   La AST viene prodotta durante la compilazione (punto 1), mentre l'allocazione della memoria necessaria per le variabili `a` e `b` avviene durante l'esecuzione (punto 2).

-   Il nostro interprete di scene 3D non opera questa distinzione tra due fasi, perché descrive una scena ma non la «esegue»: ecco perché non serve una AST.
    


# Esempio di AST

```{.graphviz im_fmt="svg" im_out="img" im_fname="ast-example"}
graph "" {
    scene [label="scene" shape=ellipse];
    
    float_def [label="float" shape=ellipse];
    float_id [label="shade" shape=box];
    float_val [label="0.4" shape=box];
    
    material_def [label="material" shape=ellipse];
    material_id [label="'sky_material'" shape=box];
    brdf_def [label="diffuse" shape=ellipse];
    brdf_color [label="color" shape=ellipse];
    brdf_red [label="shade" shape=box];
    brdf_green [label="0" shape=box];
    brdf_blue [label="0" shape=box];
    
    emission_def [label="uniform" shape=ellipse];
    emission_red [label="0.7" shape=box];
    emission_green [label="0.5" shape=box];
    emission_blue [label="1" shape=box];

    scene -- float_def;
    float_def -- float_id;
    float_def -- float_val;
    
    scene -- material_def;
    material_def -- material_id;
    material_def -- brdf_def;
    brdf_def -- brdf_color;
    brdf_color -- brdf_red;
    brdf_color -- brdf_green;
    brdf_color -- brdf_blue;
    
    material_def -- emission_def;
    emission_def -- emission_red;
    emission_def -- emission_green;
    emission_def -- emission_blue;
}
```

Le AST sono studiate come degli alberi, ma la loro struttura in memoria non deve necessariamente essere implementata esattamente così.

# La nostra AST

-   In Python, la AST precedente potrebbe essere definita così:

    ```python
    scene = [
        FloatAst(
            identifier="shade", 
            value=NumberLiteral(0.4),
        ),
        MaterialAst(
            identifier="sky_material",
            brdf=UniformAst(
                color=ColorAst(
                    red=Identifier("shade"),
                    green=NumberLiteral(0.0),
                    blue=NumberLiteral(0.0),
                ),
            ),
            emission=ColorAst(
                red=NumberLiteral(0.7),
                green=NumberLiteral(0.5),
                blue=NumberLiteral(1),
            ),
        ),
    ]
    ```

-   In realtà `scene` va costruita man mano che procede l'analisi sintattica!


# Manipolazione di AST

-   Linguaggi come [Julia](https://docs.julialang.org/en/v1/manual/metaprogramming/), [Nim](https://livebook.manning.com/book/nim-in-action/chapter-9/7),  [Rust](https://doc.rust-lang.org/book/ch19-06-macros.html) consentono di scrivere programmi che manipolano la propria AST. (Sembra incredibile, ma il primo linguaggio a permetterlo, il [LISP](https://en.wikipedia.org/wiki/Lisp_(programming_language)), fu proposto da McCarty nel 1958!)

-   Le operazioni di modifica della AST sono compiute al momento della *compilazione* del programma (fase 1), non durante la sua esecuzione (fase 2).

-   Questa possibilità, denominata *metaprogrammazione*, è fondamentale per definire DSL all'interno del linguaggio: lo sviluppatore può istruire il compilatore perché una sequenza di token altrimenti invalida produca una AST corretta (LISP), oppure la AST prodotta dal compilatore venga modificata (Rust, Nim, Julia, D).

# Tipi di grammatiche

# Grammatiche LL(n)

-   In una grammatica LL(n), si analizzano i token «da sinistra a destra», ossia nell'ordine in cui sono prodotti dal *lexer*.

-   Il numero $n$ nella scrittura LL(n) indica che per interpretare correttamente la sintassi servono $n$ token di *look-ahead*: ossia, si dà un'occhiata agli $n$ token successivi per interpretare il token corrente (simile a come funziona `unread_char` nel nostro *lexer*).

-   Di conseguenza, il nostro formato per descrivere le scene è di tipo LL(1) perché:

    #.  Si analizza la sintassi leggendo un token alla volta e procedendo in ordine;
    #.  Può essere necessario controllare il tipo del token successivo a quello corrente, ma non di più.

# Perché LL(1)?

-   Spieghiamo ora in quali contesti è necessario usare il *look-ahead*.

-   Consideriamo questa definizione:

    ```
    float clock(150)
    ```
    
    In questo caso **non** è necessario un *look-ahead*:
    
    #.  Il primo token è la *keyword* `float`, che indica che si sta definendo una variabile;
    #.  So quindi che per forza i token successivi saranno l'*identificatore*, il simbolo `(`, un *numeric literal* e il simbolo `)`.

# Dichiarazione di un `float`

```python
# Read the first token of the next statement. Only a handful of
# keywords are allowed at the beginning of a statement.
what = expect_keywords(stream, [KeywordEnum.FLOAT, …])

if what == KeywordEnum.FLOAT:
    # We are going to declare a new "float" variable
    
    # Read the name of the variable
    variable_name = expect_identifier(stream)
    
    # Now we must get a "("
    expect_symbol(stream, "(")
    
    # Read the literal number to associate with the variable
    variable_value = expect_number(stream, scene)
    
    # Check that the statement ends with ")"
    expect_symbol(stream, ")")

    # Done! Add the variable to the list
    variable_table[variable_name] = variable_value
elif …:  # Statements other than "float …" can be interpreted here
    …
```

# Perché LL(1)?

-   Consideriamo invece questa definizione:

    ```text
    plane(sky_material, translation([0, 0, 100]) * rotation_y(clock))
    ```
    
-   Il modo più naturale di interpretare questa riga è tramite una funzione `parse_plane`, che al suo interno invochi una funzione `parse_transformation`.
    
-   Però la trasformazione presenta un problema: dopo i caratteri `…100])` non si può sapere se la trasformazione è terminata (e occorre ritornare a `parse_plane`), oppure se segua il simbolo `*` che rappresenta l'operatore di composizione: in quest'ultimo caso, `parse_transformation` non avrebbe ancora finito il suo lavoro!

---

```python
while True:
    # For simplicity, let's consider just two kinds of transformations
    transformation_kw = expect_keywords(stream, [
        KeywordEnum.TRANSLATION,
        KeywordEnum.ROTATION_Y,
    ])

    if transformation_kw == KeywordEnum.TRANSLATION:
        expect_symbol(stream, "(")
        result *= translation(parse_vector(stream, scene))
        expect_symbol(stream, ")")
    elif transformation_kw == KeywordEnum.ROTATION_Y:
        expect_symbol(stream, "(")
        result *= rotation_y(expect_number(stream, scene))
        expect_symbol(stream, ")")

    # Peek the next token
    next_kw = stream.read_token()
    if (not isinstance(next_kw, SymbolToken)) or (next_kw.symbol != "*"):
        # Pretend you never read this token and put it back!
        # This requires to alter the definition of `InputStream`
        # so that it holds the unread tokens as well as unread characters
        stream.unread_token(next_kw)
        break
```

# Grammatiche EBNF

# Descrivere una grammatica

-   Per «grammatica» si intende l'insieme delle regole lessicali, sintattiche e semantiche di un linguaggio.

-   Dal punto di vista dell'analisi sintattica, dovrebbe essere evidente che un parser ha bisogno in ogni istante di sapere qual è la lista di *token* ammissibili nel punto in cui è arrivato ad interpretare il codice sorgente.

-   Nella teoria dei compilatori sono state inventate alcune notazioni per descrivere la grammatica di linguaggi, che sono utilissime nel momento in cui si implementa un *lexer* o un *parser*.

-   In effetti, prima di implementare il parser di pytracer ho dovuto io stesso scrivere la nostra grammatica in un formato che consentisse di derivare la lista esaustiva di tutte le possibilità.

# Grammatica EBNF

-   La notazione che vedremo è detta *Extended Backus-Naur Form* (EBNF), ed è il risultato del lavoro di molte persone, tra cui Niklaus Wirth (il creatore del linguaggio Pascal).

-   Non descriveremo EBNF in modo completo, ma la presenteremo solo nella misura in cui serve ai nostri scopi.

-   Nella slide successiva è mostrata l'intera struttura sintattica della nostra grammatica in formato EBNF.

# EBNF del nostro formato

```python
scene ::= declaration*

declaration ::= float_decl | plane_decl | sphere_decl | material_decl | camera_decl

float_decl ::= "float" IDENTIFIER "(" number ")"

plane_decl ::= "plane" "(" IDENTIFIER "," transformation ")"

sphere_decl ::= "sphere" "(" IDENTIFIER "," transformation ")"

material_decl ::= "material" IDENTIFIER "(" brdf "," pigment ")"

camera_decl ::= "camera" "(" camera_type "," transformation "," number "," number ")"

camera_type ::= "perspective" | "orthogonal"

brdf ::= diffuse_brdf | specular_brdf

diffuse_brdf ::= "diffuse" "(" pigment ")"

specular_brdf ::= "specular" "(" pigment ")"

pigment ::= uniform_pigment | checkered_pigment | image_pigment

uniform_pigment ::= "uniform" "(" color ")"

checkered_pigment ::= "checkered" "(" color "," color "," number ")"

image_pigment ::= "image" "(" LITERAL_STRING ")"

color ::= "<" number "," number "," number ">"

transformation ::= basic_transformation | basic_transformation "*" transformation

basic_transformation ::= "identity" 
    | "translation" "(" vector ")"
    | "rotation_x" "(" number ")"
    | "rotation_y" "(" number ")"
    | "rotation_z" "(" number ")"
    | "scaling" "(" vector ")"
    
number ::= LITERAL_NUMBER | IDENTIFIER

vector ::= "[" number "," number "," number "]"
```

# Spiegazione di EBNF

-   Il simbolo `::=` definisce un elemento della grammatica, ad esempio:

    ```
    number ::= LITERAL_NUMBER | IDENTIFIER
    ```

-   Il simbolo `|` rappresenta una serie di alternative (*or* logico).

-   Il simbolo `*` denota zero o più ripetizioni:

    ```
    scene ::= declaration*
    ```

-   Gli identificatori `MAIUSCOLI` identificano *token*, quelli `minuscoli` altri elementi definiti nella grammatica EBNF.

-   Sono possibili definizioni ricorsive:

    ```
    transformation ::= basic_transformation | basic_transformation "*" transformation
    ```

# Gestione degli errori

# Gestione degli errori

-   Il nostro codice solleva una eccezione tutte le volte che viene individuato un errore nel codice sorgente.

-   È in grado di segnalare la riga e la colonna del *token* in corrispondenza del quale è stato trovato l'errore, e ciò è molto utile!

-   Ma questo modello di esecuzione impone che al primo errore la compilazione termini! I compilatori moderni come `g++` e `clang++` invece proseguono la compilazione andando in cerca anche degli errori successivi.

-   Per non fermarsi al primo errore occorre cercare un *termination token*, ossia un *token* che sia usato per terminare un comando: una volta trovato, si prosegue dal *token* successivo.

# *Termination tokens*

-   Nel linguaggio C++, due *termination tokens* molto usati sono il `;` (usato per terminare uno *statement*) e `}` (usato per terminare un blocco di codice. Ad esempio:

    ```c++
    if (x < 0) {
        x *= -1.0  // Error: missing ';'
    }
    x /= 1O;       // Uh-oh, I wrote a capital "o" instead of "0"
    ```
    
-   In un linguaggio come il nostro non è semplice individuare un *termination token*; la cosa migliore sarebbe richiedere la presenza di `;` alla fine di ogni *statement*, come nel C++, oppure obbligare a concludere le definizioni con un ritorno a capo (che sia codificato come un token `TOKEN_NEWLINE`).

# Velocità di un compilatore

-   La produzione di *liste* di errori anziché di un solo errore alla volta è importante soprattutto in quei casi in cui il compilatore è molto lento da eseguire. Questo è il caso del C++ e di Rust.

-   Il nostro linguaggio sarà molto semplice da interpretare (non ha una semantica complessa, e non richiede la creazione di una AST né l'applicazione di un ottimizzatore): non vale quindi la pena preoccuparsi di implementare questa funzionalità.

-   Però cogliamo l'occasione per capire perché possano esserci grandi differenze nella velocità di compilazione di linguaggi!

# Complessità del C++

-   La grande complessità del C++ è legata soprattutto ai `template` e all'uso degli *header file*; rendiamoci conto di questa difficoltà già guardando alcuni semplici esempi.

-   Considerate questa definizione, che mostra la difficoltà di interpretare `>>`:

    ```c++
    std::vector<std::vector<int>> matrix = identity(3); // >> are *two* tokens
    std::cin >> matrix[0][0]; // Here >> is *one* token
    ```
    
-   È impossibile creare la sequenza di token corretta con l'approccio che abbiamo seguito, che divide rigidamente il *lexing* dal *parsing* (e infatti la prima riga non era ammessa dallo standard C++ fino a pochi anni fa).

# Altre difficoltà dei `template`

-   I template C++ rendono complessa anche l'analisi sintattica:

    ```c++
    template<bool amd64> struct MyStruct;
    template<> struct MyStruct<false> { /* Valid on 32-bit machines */ };
    template<> struct MyStruct<true> { /* Valid on 64-bit machines */ };
    ```
    
-   Si tratta in pratica di *due* strutture con lo stesso nome (`MyStruct`). Questo può essere usato ad esempio nel codice seguente:

    ```c++
    MyStruct<sizeof(size_t) > 4> A;  // On 64-bit machines use the extended definition
    ```
    
    Ma a livello di sintassi, il termine `>` rende tutto complicato!
    
# Natura del problema

-   Il problema del C++ è che quando sono stati introdotti i template (che non esistevano nelle primissime versioni del linguaggio) sono stati usati come simboli `<` e `>`.

-   Questi simboli erano però già usati come operatori di confronto, e (ancora peggio!) esistevano già gli operatori `<<` e `>>`, derivati dal C.

-   Linguaggi come Pascal e Kotlin definiscono questi operatori `shl` e `shr`: questo rimuove l'ambiguità e semplifica l'analisi lessicale. Il linguaggio D invece usa una [sintassi diversa](https://dlang.org/spec/template.html) per i *template*, e nell'esempio precedente scriverebbe

    ```d
    MyStruct!(sizeof(size_t) > 4) A;
    ```

# Dichiarazioni in C++

-   Oltre ad essere semplice da interpretare dal compilatore, un linguaggio dovrebbe essere semplice anche per l'utente. Consideriamo questa dichiarazione C/C++:

    ```c
    int myvar[100];  /* More complicated: static const int * myvar[100] */
    ```
    
    che dichiara un array di 100 variabili di tipo `int`.
    
-   I token che definiscono il tipo sono `int`, `[`, `100` e `]`, e si trovano sia a *sinistra* che a *destra* del nome della variabile: questo per il programmatore è complicato! (Provate a interpretare il caso *more complicated* da soli!)

# Il caso di Go

-   Il linguaggio [Go](https://golang.org/), che è fortemente ispirato al C, rende più semplici le dichiarazioni usando una notazione diversa:

    ```go
    var myvar [100]int
    ```
    
-   La keyword `var` segnala al *parser* che si sta dichiarando una variabile.

-   I token che definiscono il tipo sono riportati tutti insieme, *dopo* l'identificatore che rappresenta il nome della variabile.
    
-   La scrittura `[100]int` segue l'ordine naturale delle parole: «un array di 100 valori `int`», ed è più facile da leggere per il programmatore (in C bisogna leggere a ritroso, da destra a sinistra).

# Altri esempi

-   Nel linguaggio Pascal le variabili si elencano dentro una clausola `var`, e come in Go il nome viene per primo ed è chiaramente separato dal tipo:

    ```pascal
    var
        myvar : Array [1..100] of Integer;
        other : String;
        x     : Real;
    ```
    
-   Anche questa sintassi è molto semplice da interpretare; il Pascal è infatti progettato per essere veloce da compilare.

-   Idee simili sono usate nei linguaggi Modula-2 e Modula-3, Oberon, Ada, Nim, Kotlin e Rust (è vero che quest'ultimo è lentissimo da compilare, ma ciò è a causa della complessità della sua semantica).

# Testing di compilatori

# Testing

-   La scrittura di test per un compilatore è una faccenda molto complessa, perché il numero di possibili errori è praticamente infinito!

-   Non è possibile avere test completamente esaustivi; bisogna avere fantasia e prepararsi ad aggiungere molti nuovi test una volta che gli utenti inizieranno ad usare il proprio programma. (In pytracer ho implementato giusto il minimo sindacale, siete incoraggiati a scrivere più test!)

-   Se siete curiosi, nella directory [`clang/test/Lexer`](https://github.com/llvm/llvm-project/tree/main/clang/test/Lexer) ci sono i file sorgente usati per i test del solo *lexer* di Clang!

# Estensioni

# Estensioni alla grammatica

Il nostro linguaggio è abbastanza completo, ma potrebbe essere più versatile:

-   Se avete implementato un *point-light tracer*, potreste estendere il linguaggio per specificare le sorgenti puntiformi, ad esempio con questa sintassi:

    ```text
    # Specify the position and the color of the point light
    point_light([3.0, 2.0, 5.0], <1.0, 1.0, 1.0>)
    ```
    
-   Può accadere che i nomi di file contengano il carattere `"` (ad es., `Incisione di Doré per la "Divina Commedia".jpg`), nel qual caso il nostro lexer fa cilecca. Potreste estendere il lexer in modo che accetti `\"` come un carattere `"` da includere nella stringa, in maniera analoga al C++ e al Python.

-   Potreste implementare il supporto per espressioni matematiche!

# Espressioni matematiche

-   Il nostro linguaggio permette variabili, ma non prevede calcoli aritmetici. Questo è molto limitante! Potrei voler muovere un oggetto lungo una retta e farne ruotare un altro:

    ```bash
    float speed_m_s(1.0);
    float freq_hz(0.5);
    
    # First sphere
    sphere(sphere_material, translation([0, 0, clock_s * speed_m_s]))
    
    # Second sphere (faster)
    sphere(sphere_material, rotation_x(360 * freq_hz * clock_s) * translation([1, 0, 0]))
    ```
    
-   Implementare il calcolo di espressioni matematiche non è difficilissimo: basta riusare i concetti che abbiamo presentato oggi.

# Grammatica per espressioni

-   Questa è una grammatica che implementa le quattro operazioni aritmetiche:

    ```python
    expression ::= term "+" expression | term "-" expression | term | "-" term

    term ::= factor "*" term | factor "/" term | factor

    factor ::= "(" expression ")" | LITERAL_NUMBER | IDENTIFIER
    ```
    
-   La grammatica implementa le usuali regole di precedenza degli operatori: nell'espressione `a + b * c`, il termine `b * c` è valutato prima della somma.

-   Notate che la regola per `expression` richiede un token di *look-ahead*.

-   Non è troppo difficile aggiungere il supporto per chiamate a funzioni come `sin`, `cos`, etc. (Ben più difficile è permettere all'utente di definire nuove funzioni!)


# Generazione automatica

-   Esistono strumenti per generare automaticamente *lexer* e *parser*. Questi richiedono come file di input una grammatica (solitamente nella forma EBNF), e producono in output codice sorgente che interpreta la grammatica.

-   Due strumenti storicamente importanti sono `lex` e `yacc`, che oggi sono disponibili nelle versioni open source [Flex](https://en.wikipedia.org/wiki/Flex_(lexical_analyser_generator)) e [Bison](https://en.wikipedia.org/wiki/GNU_Bison) (generano codice C/C++).

-   [Lemon](https://sqlite.org/src/doc/trunk/doc/lemon.html) genera codice C, ed è stato usato per scrivere il parser SQL usato in SQLite.

-   [ANTLR](https://en.wikipedia.org/wiki/ANTLR) (C++, C\#, Java, Python) è la soluzione più completa e moderna.

-   Tenete però presente che la maggior parte della gente preferisce scrivere *lexer* e *parser* a mano…


# Approfondimenti

-   Il libro di Wirth [*Compiler Construction*](https://people.inf.ethz.ch/wirth/CompilerConstruction/) (Addison-Wesley, 1996) è di una chiarezza esemplare: in poche pagine come implementa un compilatore per il linguaggio [Oberon](https://en.wikipedia.org/wiki/Oberon_(programming_language)) (un linguaggio creato da Wirth come successore del Pascal).

-   Il testo «sacro» che illustra la teoria dei compilatori è il cosiddetto *dragon book* di Aho, Sethi, Lam & Ullman: *Compilers – Principles, Techniques and Tools* (Pearson Publishing, 2006).

-   Oggi i compilatori sono notevolmente più complessi a causa della necessaria integrazione con gli ambienti di sviluppo (PyCharm, CLion, IntelliJ IDEA, etc.). Guardate il video [*Anders Hejlsberg on Modern Compiler Construction*](https://www.youtube.com/watch?v=wSdV1M7n4gQ): apprezzerete molto di più quello che fanno le vostre IDE!

# Conclusioni del corso

# Conclusioni del corso

-   Siamo arrivati alla fine del corso!

-   Una volta implementato il *parser*, potrete rilasciare la versione `1.0` del vostro programma, venderla alla Disney Studios, fare un sacco di soldi e vivere da nababbi per il resto della vostra vita!

-   Se invece avete intenzione di continuare a fare il mestiere del «fisico», prima di concludere è bene rivedere cosa abbiamo imparato in questo corso e come ciò vi possa essere utile in futuro, anche se questo non prevederà il *rendering* di scene 3D…


# Le abilità più importanti

-   Scrivere test, test, test e ancora test: ogni funzionalità deve avere un test automatico che ne verifichi la consistenza!

-   Progettate funzioni e classi in modo che siano facili da testare (es., passare in input *stream* anziché nomi di file).

-   Decidere sin da subito quale licenza usare per rilasciare il proprio codice.

-   Usare sistemi di controllo versione per monitorare i cambiamenti.

-   Essere ordinati nell'uso di *issues* e *pull requests*, mantenendo aggiornato il *CHANGELOG*.

-   Fornire documentazione del proprio lavoro sotto forma di `README`, un manuale, e/o docstrings.


# Codici di simulazione

-   Nel caso specifico di codici di simulazione, scegliete bene il vostro [generatore di numeri casuali](tomasi-ray-tracing-11b-random-numbers-and-pigments.html#algoritmi)!

-   È importante che l'utente del vostro codice possa specificare il *seed* e, se il generatore lo prevede, l'identificatore della sequenza: questo permette la ripetibilità delle simulazioni, e ciò aiuta molto in fase di *debugging*.

-   Se si devono fare tante simulazioni, usate la possibilità dei computer moderni di fare calcoli in parallelo. Nei casi più semplici è sufficiente usare [GNU Parallel](tomasi-ray-tracing-11b-random-numbers-and-pigments.html#generare-animazioni).


# Estendibilità

-   È molto probabile che gli utenti dei programmi che svilupperete provino ad usarli in contesti che voi non avevate previsto.

-   È importante quindi che il proprio programma abbia un certo grado di *versatilità*.

-   (Non bisogna però esagerare: più un programma è versatile, più e complesso da scrivere, e rischiate quindi di non arrivare mai a rilasciare la versione 1.0!)

# Estendibilità del path-tracer

-   Nel nostro progetto abbiamo implementato la possibilità di leggere la scena da un file. Questo è molto più versatile del semplice comando `demo`!

-   In maniera analoga, alcuni di voi hanno fatto in modo che il proprio programma salvasse immagini in più formati: non solo PFM, ma anche PNG, JPEG, etc.

-   In un caso più generale, che esula dall'esempio specifico del nostro ray-tracer, come garantire questa versatilità in termini di lettura/scrittura dati da file?

-   Siccome i fisici devono spesso leggere e scrivere grandi quantità di dati, è bene spendere qualche parola su questo.


# Possibili approcci

-   La versatilità negli input/output di un programma si ottiene in vari modi:

    #.  Usare un formato di dati generico già disponibile;
    #.  Inventare un formato di dati *ad hoc* per il programma;
    #.  Incorporare il compilatore/interprete di un linguaggio nel proprio programma;
    #.  Creare *bindings* al nostro codice in un linguaggio interpretato (es. Python).

-   Vediamo una ad una queste possibilità.

# 1. Usare un formato esistente

# Usare un formato esistente

-   Se dovete solo salvare tabelle di numeri, le soluzioni migliori sono probabilmente file CSV (di testo) o file Excel (binari). La libreria Python [Pandas](https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.read_excel.html) li supporta entrambi.

-   Formati più compatti che vanno bene per dati tabulari e matriciali sono [FITS](https://en.wikipedia.org/wiki/FITS) (vecchio ma molto ben supportato) e [HDF5](https://en.wikipedia.org/wiki/Hierarchical_Data_Format) (più nuovo ed efficiente, meno supportato).

-   Il vantaggio di formati esistenti è che sono leggibili anche da programmi diversi dal vostro: ad esempio, un file CSV è leggibile da Microsoft Excel, LibreOffice, Gnumeric, etc. Ciò è molto comodo soprattutto quando dovete condividere questi dati con altre persone.

# Formati più complessi

-   I formati CSV ed Excel vanno bene per *memorizzare* numeri organizzati in tabelle, ma spesso si devono applicare filtri complessi e calcoli a questi dati.

-   Un ottimo formato per questo scopo è [sqlite3](https://www.sqlite.org/index.html): a differenza di CSV ed Excel, offre eccellenti funzioni per fare ricerche e calcoli sui dati, ed è ottimizzato per grandi volumi di dati (fino a terabytes).

-   Se non è sufficiente un tipo tabellare, potete usare il formato [JSON](https://en.wikipedia.org/wiki/JSON), [YAML](https://en.wikipedia.org/wiki/YAML) (che avete già usato per le GitHub Actions) o [XML](https://en.wikipedia.org/wiki/XML): sono in grado di salvare tipi di dati molto diversi tra loro (persino liste e dizionari!).

-   XML è il più complesso, ma implementa un sistema di controllo della «sintassi» nel file (detto [XML schema](https://en.wikipedia.org/wiki/XML_schema)) che lo rende molto più robusto (anche se più difficile da scrivere).

---

<asciinema-player src="cast/json-example-python-julia-78x20.cast" cols="78" rows="20" font-size="medium"></asciinema-player>

Il vantaggio di usare un formato diffuso come JSON è che sono a disposizioni molti strumenti per visualizzarlo e modificarlo: vedete ad esempio [jq](https://stedolan.github.io/jq/).

# Il caso del nostro ray-tracer

-   Nel caso del nostro programma avremmo potuto usare il formato JSON:

    ```json
    { "camera": {
            "projection": "perspective",
            "transformations": [
                { "type": "rotation_z", "angle_deg": 30.0 },
                { "type:" "translation", "vector": [-4, 0, 1] }
            ],
            "distance": 1.0,
            "aspect_ratio": 1.0
        },
        ...
    }
    ```

-   Non serve un *lexer* e un *parser*, ma bisogna comunque validare il contenuto (es., `camera` deve contenere `projection`).

# 2. Inventare un formato

# Inventare un formato

-   È la soluzione che abbiamo adottato per descrivere le scene tridimensionali nel nostro programma.

-   Attività molto creativa, ma ha alcuni potenziali problemi:

    -   Rischia di richiedere molto tempo allo sviluppatore…
    
    -   …e richiede che l'utente impari la sintassi e la semantica del vostro linguaggio
    
-   Non è solitamente una buona scelta: noi l'abbiamo adottata a lezione per la sua valenza didattica (comprensione del funzionamento dei compilatori, gestione degli errori, …).


# 3. Incorporare un linguaggio

# Incorporare un linguaggio

-   Una soluzione usata soprattutto per programmi vasti e complessi è quella di incorporare un interprete di un linguaggio «semplice» all'interno del proprio programma (questo tipo di interpreti è detto *embedded*).

-   Esempi notevoli:

    -   Microsoft [Visual Basic for Applications](https://en.wikipedia.org/wiki/Visual_Basic_for_Applications) (linguaggio BASIC incluso in Word, Excel e molte altre);
    -   [AutoLISP](https://en.wikipedia.org/wiki/AutoLISP) (interprete LISP usato in AutoCAD);
    -   [GNU Guile](https://www.gnu.org/software/guile/) (interprete Scheme usato in [The Gimp](https://docs.gimp.org/en/gimp-concepts-script-fu.html), [Lilypond](https://lilypond.org/doc/v2.18/Documentation/extending/scheme-tutorial), etc.)
    -   Python (usato in [Blender](https://docs.blender.org/manual/en/latest/advanced/scripting/introduction.html), [Inkscape](https://wiki.inkscape.org/wiki/index.php/Python_modules_for_extensions), [The Gimp](https://www.gimp.org/docs/python/index.html), [Minecraft](https://projects.raspberrypi.org/en/projects/getting-started-with-minecraft-pi/4)).

-   Vedi [*Programmable Applications: Interpreter Meets Interface*](https://dspace.mit.edu/handle/1721.1/5980) (Eisenberg, 1995).

---

<center>![](media/blender-python.webp){height=620px}</center>

In Blender è possibile aprire un terminale Python in cui lanciare comandi per creare oggetti, modificarli, etc.

# Logica di funzionamento

-   Il linguaggio incorporato nella applicazione è «esteso» con funzioni specifiche per manipolare gli oggetti gestiti dall'applicazione. Ad esempio, questo codice VBA può essere usato per modificare la cella `A1` di un foglio Excel:

    ```monobasic
    Sub Macro1()
        Worksheets(1).Range("A1").Value = "Wow!"
        Worksheets(1).Range("A1").Borders.LineStyle = xlDouble
    End Sub
    ```

-   Comodo per automatizzare task ripetitivi (es. creare oggetti ripetuti in programmi grafici come Blender).

-   Alcuni linguaggi ([GNU Guile](https://www.gnu.org/software/guile/), [Lua](https://www.lua.org/)…) sono pensati principalmente per usi *embedded*.

# Esempio Python

Questo programma C inizializza l'interprete Python ed esegue un semplice script. Nella realtà, questo script potrebbe essere stato digitato dall'utente in una finestra di dialogo del programma:

```c
#define PY_SSIZE_T_CLEAN
#include <Python.h>

int
main(int argc, char *argv[])
{
    wchar_t *program = Py_DecodeLocale(argv[0], NULL);
    if (program == NULL) {
        fprintf(stderr, "Fatal error: cannot decode argv[0]\n");
        exit(1);
    }
    Py_SetProgramName(program);  /* optional but recommended */
    Py_Initialize();
    /* Run a simple Python program that prints the current date */
    PyRun_SimpleString("from time import time,ctime\n"
                       "print('Today is', ctime(time()))\n");
    if (Py_FinalizeEx() < 0) {
        exit(120);
    }
    PyMem_RawFree(program);
    return 0;
}
```

# Registrare funzioni

Si può estendere l'interprete Python perché riconosca nuove funzioni: è in questo modo che si rendono disponibili le funzionalità del proprio programma attraverso Python. Ecco un [esempio](https://docs.python.org/3/extending/embedding.html):

```c
static int numargs=0;

/* Return the number of arguments of the application command line */
static PyObject*
emb_numargs(PyObject *self, PyObject *args)
{
    if(!PyArg_ParseTuple(args, ":numargs"))
        return NULL;
    return PyLong_FromLong(numargs);
}

/* This will enable the interpreter to understand the following script:
 *
 *     import emb
 *     print(emb.numargs())
 *
 */
static PyMethodDef EmbMethods[] = {
    {"numargs", emb_numargs, METH_VARARGS,
     "Return the number of arguments received by the process."},
    {NULL, NULL, 0, NULL}
};

static PyModuleDef EmbModule = {
    PyModuleDef_HEAD_INIT, "emb", NULL, -1, EmbMethods,
    NULL, NULL, NULL, NULL
};

static PyObject*
PyInit_emb(void)
{
    return PyModule_Create(&EmbModule);
}
```

# Il caso del nostro ray-tracer

-   In questo caso, avremmo potuto esportare nell'interprete Python funzioni come `create_sphere`, `create_brdf`, etc. che invocano le funzionalità del nostro codice C++/C\#/…

-   I file di input sarebbero stati normali script Python, che potevano impiegare tutte le potenzialità del linguaggio (variabili, funzioni, cicli `for`, etc.):

    ```python
    black = color(0.0, 0.0, 0.0)  # We can define variables of any type, not only floats!
    
    sphere_material = create_material(
        brdf=diffuse_brdf(uniform_pigment(color(0.7, 0.5, 1.0))),
        emitted_radiance=uniform_pigment(black),
    )
    
    # Create many objects using a `for` loop
    for angle in [0, 90, 180, 270]:
        create_sphere(sphere_material, rotation_x(angle) * translation(vec(10, 0, 0)))
    ```

# 4. Creare *bindings*

# Creare *bindings*

-   Un approccio simile a quello degli interpreti *embedded* è quello di rendere il proprio codice invocabile da un linguaggio esterno (solitamente Python).

-   La differenza con la soluzione precedente è che in questo caso si usa l'interprete Python installato nel sistema, e non un interprete dedicato.

-   Il vantaggio è ovviamente che si possono combinare librerie già installate con la nostra: la soluzione è molto più versatile, ed è generalmente quella da preferire.

-   Questa soluzione è facilmente praticabile con linguaggi come C++, Nim, Rust…; è decisamente più complessa per Julia, C\# o Kotlin.

# Il caso di Python e Julia

-   I gruppi che hanno impiegato Julia possono sin da subito creare semplici script e usare il proprio *package* come una libreria:

    ```julia
    using MyRaytracer
    
    mycam = OrthogonalCamera(16//9, rotation_z(180.0))
    world = World()
    addshape(world, Sphere(translation(Vec(10, 0, 0))))
    …
    ```
    
-   Ovviamente si hanno a disposizione tutte le potenzialità di Julia: cicli `for`, definizione di funzioni di supporto, etc.

-   Questo codice può essere inserito anche direttamente nella REPL o in un notebook, ed è quindi particolarmente comodo!

# Altre estensioni

# Metadati di output

-   L'output del nostro programma è un file PFM, che contiene l'immagine fotorealistica calcolata dal codice.

-   Questo è sufficiente per un programma di *rendering*, ma in ambito scientifico non è sufficiente produrre un file che contiene solo il *risultato* di un calcolo: il risultato dipende infatti dagli input forniti, e più è complesso il calcolo, maggiore è il numero di input.

# Parametri del ray-tracer

-   Nel nostro caso gli input sono:

    #.   Scena usata (dove erano collocate le forme? che BRDF avevano?)
    #.   Osservatore (posizione, direzione, tipo di proiezione…)
    #.   Tipo di algoritmo (*flat*, *path tracing*, *point-light tracing*);
    #.   Numero massimo di raggi prodotti ad ogni iterazione (per il *path tracing*);
    #.   Parametri usati per la roulette russa;
    #.   Presenza o meno di *anti-aliasing*;
    #.   Etc.
    
-   Sarebbe molto utile che il codice salvasse queste informazioni all'interno di un'immagine PFM! In questo modo potete capire anche a distanza di molto tempo come è stata generata una immagine.

# Possibile soluzione

-   Se si usasse un formato più versatile di PFM per le immagini, si potrebbero salvare queste informazioni nel file immagine stesso.

-   Altrimenti, si può salvare un file JSON/YAML/XML associato al file PFM (es., `output.pfm.json`) che contenga queste informazioni:

    ```json
    {
        "scene-file": "/home/tomasi/Documents/raytracing/myworld.txt",
        "rendering-algorithm": "pathtracing",
        "projection": "orthogonal",
        "russian-roulette-limit": 5,
        "max_depth": 5,
        "rendering_time_s": 1676.7,
        ...
    }
    ```
