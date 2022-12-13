---
title: "Esercitazione 12"
subtitle: "Analisi lessicale"
author: "Maurizio Tomasi <maurizio.tomasi@unimi.it>"
...

# Implementazione di un *lexer*

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

Questo è il tipo di file per cui il nostro *lexer* dovrà produrre una lista di *token*.


# Gestione di errori

# Condizioni di errore

-   Già nella scrittura del *lexer*, prima di occuparsi dell'aspetto sintattico e semantico, è possibile imbattersi in errori nel codice.

-   Ad esempio, la presenza di un carattere come `@` non è ammessa nel nostro linguaggio, e già il *lexer* può individuare questo tipo di errore.

-   Un altro esempio è la dimenticanza di chiudere il doppio apice `"` alla fine di una stringa.


# Come segnalare errori

-   Nei compilatori moderni, il tipo `Token` contiene al suo interno informazioni sulla posizione del token nel file sorgente (vedi ad esempio il tipo [`Token`](https://github.com/llvm/llvm-project/blob/llvmorg-10.0.0/clang/include/clang/Lex/Token.h) nella versione 10.0.0 del compilatore Clang: non è un'implementazione molto elegante, ma è ottimizzata per essere efficiente!).

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
    
-   Il tipo `Token` dovrebbe quindi contenere questi tre campi. Nel caso di pytracer, ha un membro di tipo [`SourceLocation`](https://github.com/ziotom78/pytracer/blob/c1f0ed490f322bb9db9db185127aac69ac790fba/scene_file.py#L20-L32).

    ```python
    @dataclass
    class SourceLocation:
        file_name: str = ""
        line_num: int = 0
        col_num: int = 0
    ```

# Posizioni e token

-   Se usate una gerarchia di classi, mettete un campo di tipo `SourceLocation` nella classe base `Token`:

    ```python
    @dataclass
    class Token:
        """A lexical token, used when parsing a scene file"""
        location: SourceLocation
    ```

-   Se usate i *sum types*, ricordatevi di usare i *tag* se il vostro linguaggio lo richiede (es., [Nim](https://nim-lang.org/docs/manual.html#types-object-variants)).

# Segnalare errori

-   Il modo più pratico per segnalare errori è quello di sollevare una eccezione: pytracer definisce [`GrammarError`](https://github.com/ziotom78/pytracer/blob/c1f0ed490f322bb9db9db185127aac69ac790fba/scene_file.py#L149-L161).

-   All'eccezione si associa il messaggio di errore e un `SourceLocation`: così si può indicare all'utente la posizione in cui è stato riscontrato l'errore.

-   Usare le eccezioni implica che non appena si trova un errore la compilazione si ferma. Questo non è molto *user-frendly*: se la compilazione è un processo lento (es., C++, Rust), sarebbe meglio produrre una *lista* di errori.

-   Noi non lo faremo: il nostro compilatore sarà molto veloce, e non è facile implementare un metodo per produrre una lista di errori, per il modo in cui si effettua l'analisi sintattica (v. la prossima lezione).


# Definizione di `InputStream`

# Uso di *stream* nel *lexing*

-   Abbiamo visto nella lezione di teoria che è necessario leggere un carattere alla volta dal file sorgente.

-   È quindi l'ideale usare uno *stream* per leggere da file, con l'accortezza di aprire il file in modalità testo (non è un file binario come nel formato PFM!):

    ```python
    with open(file_name, "rt") as f:  # "rt" stands for "*R*ead *T*ext"
        …
    ```
    
-   A noi serve anche la possibilità di *look ahead*, ossia di leggere un carattere e rimetterlo a posto, nonché la capacità di tenere traccia della posizione nello *stream* in cui siamo arrivati (per produrre messaggi d'errore).

# Definizione di `InputStream`

-   Il tipo `InputStream` deve contenere questi campi:

    #.  Un campo `stream`, il cui tipo dipende dal linguaggio che usate: ad esempio `std::istream` in C++;
    #.  Un campo `location` di tipo `SourceLocation`.
    
-   Oltre a questi campi ne servono altri per implementare il *look-ahead*.


# *Look ahead* di caratteri

-   Ricordiamoci che `InputStream` deve offrire la possibilità di «rimettere a posto» un carattere tramite la funzione `unread_char`.

-   Quando si rimette a posto un carattere, bisogna rimettere a posto anche la posizione nel file, ossia il campo `location`.

-   Questo significa che `InputStream` deve contenere anche i seguenti membri:

    #.  `saved_char` (che conterrà il carattere «dis-letto», oppure zero se non è stata chiamata `unread_char`);
    #.  `saved_location`, che contiene il valore di `SourceLocation` associato a `saved_char`.

# Costruttore di `InputStream`

```python
class InputStream:
    def __init__(self, stream, file_name="", tabulations=8):
        self.stream = stream

        # Note that we start counting lines/columns from 1, not from 0
        self.location = SourceLocation(file_name=file_name, line_num=1, col_num=1)

        self.saved_char = ""
        self.saved_location = self.location
        self.tabulations = tabulations
```

# Tracciamento della posizione

-   È molto importante tracciare correttamente la posizione nel file, ossia aggiornare in modo appropriato il campo `location`.

-   Queste le regole da seguire:

    #.  In presenza di un ritorno a capo come `\n`, si incrementa `line_num` e si resetta `col_num` a 1;
    #.  In presenza di `\t` (tabulazione) si incrementa `col_num` di un valore convenzionale (solitamente 4 oppure 8);
    #.  In tutti gli altri casi si incrementa `col_num` e si lascia intatto `line_num`.
    
-   Questo approccio richiederebbe accorgimenti aggiuntivi per i [caratteri Unicode](./tomasi-ray-tracing-03a.html#lo-standard-unicode), ma il nostro formato ammette solo caratteri ASCII (per fortuna!).

---

```python
class InputStream:
    …
    
    def _update_pos(self, ch):
        """Update `location` after having read `ch` from the stream"""
        if ch == "":
            # Nothing to do!
            return
        elif ch == "\n":
            self.location.line_num += 1
            self.location.col_num = 1
        elif ch == "\t":
            self.location.col_num += self.tabulations
        else:
            self.location.col_num += 1

    def read_char(self) -> str:
        """Read a new character from the stream"""
        if self.saved_char != "":
            # Recover the «unread» character and return it
            ch = self.saved_char
            self.saved_char = ""
        else:
            # Read a new character from the stream
            ch = self.stream.read(1)

        self.saved_location = copy(self.location)
        self._update_pos(ch)

        return ch

    def unread_char(self, ch):
        """Push a character back to the stream"""
        assert self.saved_char == ""
        self.saved_char = ch
        self.location = copy(self.saved_location)
```

# Definizione di `Token`

# Definizione di `Token`

-   Decidete se volete usare una gerarchia di classi o una *tagged union* (*sum type*); siccome Python non ammette queste ultime, in [pytracer](https://github.com/ziotom78/pytracer/blob/c1f0ed490f322bb9db9db185127aac69ac790fba/scene_file.py#L35-L146) ho usato una gerarchia di classi.

-   I tipi di token da definire sono i seguenti:

    #.  *Keyword*: usate un tipo enumerativo (`enum` in [Nim](https://nim-lang.org/docs/manual.html#types-enumeration-types), [D](https://dlang.org/spec/enum.html), [C\#](https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/builtin-types/enum) e [Rust](https://doc.rust-lang.org/book/ch06-01-defining-an-enum.html), `enum class` in [Kotlin](https://kotlinlang.org/docs/enum-classes.html)), perché renderà il *parser* più efficiente;
    #.  *Identificatore*: è una stringa;
    #.  *Literal string*: è nuovamente una stringa;
    #.  *Literal number*: un valore floating-point;
    #.  *Symbol*: un carattere;
    #.  *Stop token* (vedi slide seguente).

# Fine del file

-   È necessario che il *lexer* sappia segnalare quando un file è finito.

-   Nel codice di pytracer ho implementato un nuovo *token* «speciale»: [`StopToken`](https://github.com/ziotom78/pytracer/blob/c1f0ed490f322bb9db9db185127aac69ac790fba/scene_file.py#L41-L45). Esso viene emesso quando si è raggiunta la fine del file.

-   Il trucco di `StopToken` non è indispensabile: si potrebbe semplicemente verificare quando lo stream è arrivato alla fine…

-   …ma mostra quanto possa essere duttile il concetto di *token*. Trucchi del genere sono molto diffusi nei compilatori (v. ad esempio come Python gestisce i cambi di indentazione [a livello di *lexer*](https://riptutorial.com/python/example/8674/how-indentation-is-parsed)).

# Spazi bianchi e ritorni a capo

-   Il nostro formato ignora, spazi, ritorni a capo tra *token* e commenti.

-   Per implementare la funzione `read_token` ci serve una funzione che salti questi caratteri:

    ```python
    WHITESPACE = " \t\n\r"

    def skip_whitespaces_and_comments(self):
        """Keep reading characters until a non-whitespace/non-comment character is found"""
        ch = self.read_char()
        while ch in WHITESPACE or ch == "#":
            if ch == "#":
                # It's a comment! Keep reading until the end of the line (include the case "", the end-of-file)
                while self.read_char() not in ["\r", "\n", ""]:
                    pass

            ch = self.read_char()
            if ch == "":
                return

        # Put the non-whitespace character back
        self.unread_char(ch)
    ```

# Leggere un *token*

-   Dividete il metodo `read_token` in funzioni semplici [come ho fatto in pytracer](https://github.com/ziotom78/pytracer/blob/c1f0ed490f322bb9db9db185127aac69ac790fba/scene_file.py#L231-L284), in modo che sia più chiaro da leggere.

-   Dopo aver saltato ogni spazio bianco e commento, `read_token` deve leggere il primo carattere `c` e decidere che token vada creato:

    #.  Se è un simbolo (virgola, parentesi, etc.), restituisce un `SymbolToken`;
    #.  Se è una cifra, restituisce un `LiteralNumberToken`;
    #.  Se è `"`, restituisce un `LiteralStringToken`;
    #.  Se è una sequenza di caratteri `a`…`z`, restituisce un `KeywordToken` se la sequenza è una parola chiave, `IdentifierToken` altrimenti;
    #.  Se il file è finito, restituisce `StopToken`.
    
---

```python
SYMBOLS = "()<>[],*"

def read_token(self) -> Token:
    self.skip_whitespaces_and_comments()

    # At this point we're sure that ch does *not* contain a whitespace character
    ch = self.read_char()
    if ch == "":
        # No more characters in the file, so return a StopToken
        return StopToken(location=self.location)

    # At this point we must check what kind of token begins with the "ch" character 
    # (which has been put back in the stream with self.unread_char). First,
    # we save the position in the stream
    token_location = copy(self.location)

    if ch in SYMBOLS:
        # One-character symbol, like '(' or ','
        return SymbolToken(token_location, ch)
    elif ch == '"':
        # A literal string (used for file names)
        return self._parse_string_token(token_location=token_location)
    elif ch.isdecimal() or ch in ["+", "-", "."]:
        # A floating-point number
        return self._parse_float_token(first_char=ch, token_location=token_location)
    elif ch.isalpha() or ch == "_":
        # Since it begins with an alphabetic character, it must either be a keyword
        # or a identifier
        return self._parse_keyword_or_identifier_token(
            first_char=ch, 
            token_location=token_location,
        )
    else:
        # We got some weird character, like '@` or `&`
        raise GrammarError(self.location, f"Invalid character {ch}")
```

# Test

-   Implementate due famiglie di test:

    #.  Un [test per `InputStream`](https://github.com/ziotom78/pytracer/blob/c1f0ed490f322bb9db9db185127aac69ac790fba/test_all.py#L1037-L1081), che verifichi che la posizione in un file sia tracciata correttamente anche in caso ci siano ritorni a capo o si invochi `unread_char`;
    #.  Un [test per `read_token`](https://github.com/ziotom78/pytracer/blob/c1f0ed490f322bb9db9db185127aac69ac790fba/test_all.py#L1083-L1104), che verifichi che spazi e commenti vengano saltati e che la sequenza di token sia prodotta correttamente.
    
-   La scrittura di questi test vi permetterà di familiarizzare con i tipi che avete definito (soprattutto se usate *sum types*!), in previsione della prossima lezione.


# Guida per l'esercitazione

# Guida per l'esercitazione

#.  Create un nuovo *branch* chiamato `scenefiles`;
#.  Implementate `SourceLocation`;
#.  Implementate `GrammarError`;
#.  Implementate `InputStream` e le funzioni/metodi associati (soprattutto `unread_char`!);
#.  Implementate il tipo `Token`, facendo attenzione che tutti i tipi di *token* presenti in pytracer (sono sei in tutto);
#.  Implementate la funzione/metodo `read_token`.
