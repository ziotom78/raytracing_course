---
title: "Lezione 3"
subtitle: "Calcolo numerico per la generazione di immagini fotorealistiche"
author: "Maurizio Tomasi <maurizio.tomasi@unimi.it>"
...

# Codifica binaria e testuale

# Codifica binaria

-   I file binari sono il tipo più semplice: consistono di una sequenza di byte (ossia, 8 bit scritti in sequenza).

-   Ogni byte può contenere un valore intero nell'intervallo 0–255

-   Per stampare il contenuto di un file binario potete usare il comando `xxd` (sotto Ubuntu, installatelo con `sudo apt install xxd`):

    ```text
    $ xxd file.bin
    ```
    
    (Su altri sistemi operativi potreste avere `hexdump` anziché `xxd`).
    
-   Salvare dati in un file binario vuol dire scrivere una sequenza di numeri binari sul disco fisso, memorizzati come byte.


# Da binario a decimale

-   Per ragionare sui valori dei byte si usa la numerazione binaria, che ovviamente usa come base il numero 2:

    ```
    0  → 0
    1  → 1
    2  → 10
    3  → 11
    4  → 100
    …
    ```
    
-   Per un numero `dcba` espresso in una base $B$, il suo valore è

    $$
    \text{value} = a \times B^0 + b \times B^1 + c \times B^2 + d \times B^3.
    $$
    
    Quindi il valore binario `100` corrisponde a $0 \times 2^0 + 0 \times 2^1 + 1\times 2^2 = 4.$

# Notazione esadecimale

-   La notazione binaria è però scomoda, perché i numeri richiedono rapidamente molte cifre; inoltre i computer lavorano a multipli di 8 bit (i byte).

-   In alternativa alla notazione binaria si usa molto la notazione esadecimale (16), che usa le cifre

    ```
    0 1 2 3 4 5 6 7 8 9 A B C D E F
    ```
    
-   La notazione esadecimale richiede 4 bit per cifra, perché $2^4 = 16$. Siccome un byte è composto da 8 bit, il valore di un byte è sempre codificabile usando solo due cifre esadecimali (`0xFF = 255`).

-   In C/C++/D/Nim/Rust/Julia/C\#/Kotlin, i numeri esadecimali si scrivono con `0x`, ad es. `0x1F67 = 8039` (in alcuni linguaggi `0b` introduce un numero binario).

---

<asciinema-player src="./cast/binary-files-73x19.cast" cols="73" rows="19" font-size="medium"></asciinema-player>


# Ordine dei bit in un byte

-   C'è sempre un'ambiguità di fondo nel raggruppamento dei bit in byte, e sta nel loro ordine.

-   Se un byte è formato dalla sequenza di bit `0011 0101`, esistono due modi per interpretarlo:

    $$
    \begin{aligned}
    2^2 + 2^3 + 2^5 + 2^7 &= 172,\\
    2^5 + 2^4 + 2^2 + 2^0 &= 53.
    \end{aligned}
    $$

# «Endianness» dei bit

-   L'ordine dei bit in un byte è detto in gergo *bit-endianness*, termine tratto dai *Viaggi di Gulliver* (1726), di J. Swift:

    1.  La codifica *big-endian* parte dalla potenza *maggiore* («big»);
    2.  La codifica *little-endian* parte dalla potenza *minore* («little»).

-   Le CPU Intel e AMD oggi usate nei personal computer usano tutte la codifica *little-endian*. La codifica *big-endian* è stata molto usata in passato, ma oggi è ancora impiegata in alcune CPU ARM.

# Usare più di 8 bit

-   Un numero a 8 bit può assumere valori da 0 a 255

-   È un intervallo molto ridotto! Ma si possono combinare insieme più bytes

-   In C++ esistono i tipi `int16_t` (16 bit → 2 byte), `int32_t` (32 bit → 4 byte), `int64_t` (64 bit → 8 byte)

-   Ma se si combinano insieme più byte, c'è di nuovo il problema della *endianness*! Il numero esadecimale 1F3D si codifica con la coppia di byte `1F 3D` (*big endian*) oppure `3D 1F` (*little endian*)?

-   Oltre alla *bit endianness*, c'è il problema del *byte endianness*!

# Salvare dati in binario

-   Oltre al problema della *endianness*, bisogna anche capire come il proprio linguaggio gestisce i file binari. Guardate questo esempio in C++:

    ```c++
    #include <fstream>
    
    int main() {
      int x{138};  // 138 < 256, so the value fits in *one* byte
      std::ofstream outf{"file.bin"};
      outf << x; // Ouch! It writes *three* bytes: '1', '3', '8'
    }
    ```
    
-   Il valore `138` è stato salvato in *forma testuale*.

-   Se invece includete `<cstdint>` e cambiate il tipo di `x` da `int` a `uint8_t`, il valore viene salvato come binario!


# Codifica testuale

# Codifica testuale

-   I caratteri del computer vengono codificati tramite numeri; la più usata è la codifica ASCII:

    -  La lettera `A` è codificata dal numero 65, `B` da 66, `C` da 67, etc.;
    -  La lettera `a` è codificata dal numero 97, `b` da 98, etc.;
    -  La cifra `0` è codificata dal numero 48, `1` da 49, etc.
    
-   Codificare una parola come `Casa` vuol dire rappresentare la parola con la sequenza di valori `67 97 115 97 = 0x43 0x61 0x73 0x61`.

-   Questi codici numerici fanno parte dello standard ASCII, che specifica 128 caratteri. ([Qui c'è la tabella completa](https://garbagecollected.org/2017/01/31/four-column-ascii/), spiegata bene).

# Codifica di testi

-   Lo standard ASCII è semplicissimo, eppure sufficiente per codificare testi:

    ```text
    Beauty - be not caused - It Is -
    Chase it, and it ceases -
    Chase it not, and it abides -
    
    Overtake the Creases
    
    In the Meadow - when the Wind
    Runs his fingers thro' it -
    Deity will see to it
    That You never do it -
    
    (Emily Dickinson, 1863)
    ```

-   Ma come si codifica la fine della riga in ogni verso della poesia?

-   In 128 valori è possibile codificare *tutti* i caratteri?


# Ritorno a capo

-   Il modo per indicare un ritorno a capo dipende dal sistema operativo!

-   Nelle macchine da scrivere c'erano due operazioni da fare per iniziare una nuova riga (vedi [questo video YouTube](https://www.youtube.com/watch?v=r97JHr13T98)):

    1.   Spostarsi verso il bordo sinistro/destro del foglio (*carriage return*);
    2.   Muoversi alla riga successiva (*line feed*).
    
-   Anche i computer hanno adottato questi due comandi, che corrispondono a due valori ASCII: `13` (*carriage return*, indicato anche come `\r`) e `10` (*line feed*, indicato con `\n`).

# Tipi di ritorno a capo

-   Il tipo di ritorno a capo dipende dal sistema operativo utilizzato:

    | Sistema operativo  | Codifica         |
    |--------------------|------------------|
    | Windows, DOS       | `13 10` (`\r\n`) |
    | RISC OS            | `10 13` (`\n\r`) |
    | C64, macOS classic | `13` (`\r`)      |
    | Linux, Mac OS X    | `10` (`\n`)      |
    
-   Si può convertire un file con i comandi `dos2unix` e `unix2dos`.

-   Git si aspetta il formato Linux (`\n`), ed emette un warning se i file aggiunti con `git add` ne usano un altro.

# Da ASCII a Unicode

-   ASCII è stato usato per la prima volta su un terminale che usava 7 bit per byte: ecco perché l'ultimo carattere ha valore `127 = 0x7F` ($127 = 2^7 - 1$).

-   Nei 128 caratteri sono inclusi anche caratteri «speciali», come il ritorno a capo (`10`), la tabulazione (`8`), etc., che «consumano» posizioni nella tabella.

-   ASCII è un sistema centrato sul sistema di scrittura usato negli USA, e non include caratteri accentati come «è», «é», «ü», «â», etc.

-   Oltre agli accenti sulle lettere latine, sono esistenti nel mondo molti altri alfabeti e simboli (greco, cirillico, cinese, i simboli matematici, etc.).

-   Lo standard Unicode ha esteso ASCII per includere *tutte* i possibili simboli testuali (contiene anche i geroglifici egizi e il sumerico!).

# Lo standard Unicode

-   Standard internazionale nato nel 1991, che copre praticamente tutti i sistemi di scrittura oggi esistenti al mondo.

-   Oggi è supportato quasi universalmente.

-   Viene aggiornato periodicamente, circa una volta all'anno.

<center>
![](./media/unicode-example.png)
</center>


# Versioni Unicode

| Versione | Data         | Scritture | Caratteri |
|----------|--------------|-----------|-----------|
| 1.0      | Ottobre 1991 | 24        | 7,129     |
| …        |              |           |           |
| 11.0     | Giugno 2018  | 146       | 137,374   |
| 12.0     | Marzo 2019   | 150       | 137,928   |
| 13.0     | Marzo 2020   | 154       | 143,859   |

# Esempi di caratteri Unicode

-   Lettera A maiuscola: `A` (65, uguale all'ASCII!);
-   Lettera A minuscola con accento acuto: `à` (224);
-   Lettera E maiuscola con accento grave: `É` (201);
-   Puntini di sospensione: `…` (8230);
-   Bemolle: `♭` (9837);
-   Faccina che ride: `😀` (128.512).

# Codifica Unicode

-   Ogni carattere Unicode è associato a un valore numerico, chiamato *code point*.

-   Si possono [combinare insieme caratteri](https://en.wikipedia.org/wiki/Combining_character): unendo `a` e `^` per formare `â`.

-   Le lettere accentate più comuni hanno però una [codifica dedicata](https://en.wikipedia.org/wiki/Precomposed_character). Queste lettere sono quindi codificabili in **più modi** secondo lo standard Unicode. (Questo rende complicato confrontare due stringhe!)

-   Un *grafema* è il risultato di una combinazione di uno o più code point. Quindi la parola `così` è composta da quattro grafemi: `c`, `o`, `s` ed `ì` (che può essere il *code point* 236, oppure la combinazione dei code point `i` e `).

-   La combinazione di caratteri diversi è molto importante in certe scritture come il cinese.

# Codificare i *code point*

-   Lo standard Unicode possiede molti *code point*, e a ogni versione se ne aggiungono di nuovi.

-   Questo pone un problema nella codifica dei *code point* su file: ASCII usava un byte per carattere perché il set era limitato. Ma per Unicode quanti byte per *code point* usare? 1? 2? 100?

    -   Se si scegliesse un valore basso, si limiterebbe l'estendibilità di Unicode.
    -   Se si scegliesse un valore molto alto, i file di testo aumenterebbero di dimensione inutilmente: la poesia di E. Dickinson richiede 232 byte in codifica ASCII (un byte per carattere). Usare 4 byte per carattere quadruplicherebbe lo spazio.

# Codifiche oggi usate

-   Storicamente sono state proposte varie codifiche per Unicode.

-   Le più usate oggi sono le codifiche UTF (Unicode Transformation Format), che esistono in tre versioni:

    -   UTF8 (usata nei sistemi Linux e Mac OS X);
    -   UTF16 (usata in Windows);
    -   UTF32 (molto comoda dal punto di vista del software).

# UTF-8

-   È oggi la codifica più usata in assoluto (tranne che sotto Windows 😢).

-   Il numero di byte usati per un *code point* è variabile da 1 a 4.

-   È compatibile con la codifica ASCII: un file ASCII è automaticamente anche un file UTF-8 valido, perché sfrutta il fatto che la codifica ASCII usa solo 7 degli 8 bit in un byte, e che i primi 127 *code point* Unicode sono uguali ai valori ASCII.


# Codifica UTF-8

| Code point           | Byte 1     | Byte 2     | Byte 3     | Byte 4     |
|----------------------|------------|------------|------------|------------|
| `0x0000`–`0x007F`    | `0xxxxxxx` | —          | —          | —          |
| `0x0080`–`0x07FF`    | `110xxxxx` | `10xxxxxx` | —          | —          |
| `0x0800`–`0xFFFF`    | `1110xxxx` | `10xxxxxx` | `10xxxxxx` | —          |
| `0x10000`–`0x10FFFF` | `11110xxx` | `10xxxxxx` | `10xxxxxx` | `10xxxxxx` |

# Codifica UTF-16

-   Funziona come la codifica UTF-8, ma si usano coppie di byte ($8 + 8 = 16$). 

-   Un *code point* può essere codificato da due oppure quattro byte.

-   C'è anche qui un problema di *endianness*: il valore `0x2A6C` si scrive come la coppia di byte `0x2A 0x6C` (*big endian*) oppure `0x6C 0x2A` (*little endian*)?

-   Nei file di testo codificati con UTF-16 si inserisce all'inizio del file il cosiddetto BOM (*byte-order marker*) che corrisponde al *code point* `0xFEFF`. Se i primi due byte di un file sono `0xFE 0xFF`, allora è chiaro che il file usa *big endian*, se sono `0xFF 0xFE` usa *little endian*. (Anche UTF-8 ha un BOM, `0xEF 0xBB 0xBF`, che però non è così utile).

-   UTF-16 è usato da Windows e nei linguaggi basati su Java (Kotlin, Scala, etc.).

# Codifica UTF-32

-   Ovviamente, usa 32 bit per *code point*.

-   In questo caso non c'è ambiguità: ogni code point usa esattamente quattro byte.

-   È ovviamente la codifica più inefficiente dal punto di vista dello spazio occupato: la poesia di Emily Dickinson occuperebbe 928 byte in UTF-32, e solo 232 byte in ASCII/UTF-8 (quattro volte tanto!)

-   È però la codifica più semplice: ogni code point occupa sempre lo spazio di un tipo `uint32_t` in C/C++.

# File binari e testuali

-   Quanto detto oggi spiega perché è spesso più vantaggioso usare *file binari* anziché testuali: è molto più facile per un programma leggerli e scriverli!

-   Quasi tutti i formati grafici oggi usati (PNG, JPEG, GIF, etc.) si basano su codifiche binarie.

-   I file testuali hanno però alcuni vantaggi significativi:

    -   Sono più facili da leggere e da scrivere per un essere umano;
    
    -   Non hanno problemi di *endianness*.
    
-   Questa settimana e la prossima lavoreremo su file binari; tra alcune settimane passeremo ai file testuali per leggere i file di input del nostro programma.


# Gestione degli errori

# Errori

-   Nella scorsa esercitazione abbiamo implementato il tipo `HdrImage`.
-   Questa settimana implementeremo le funzioni per scrivere e leggere file PFM.
-   Legge e scrivere file è un'attività che è facilmente soggetta ad errori:
    -   La directory in cui salvare il file non esiste, oppure è protetta da scrittura
    -   Il file specificato dall'utente non esiste
    -   Il file è danneggiato
    -   Il file è in un formato valido ma che il nostro codice non è in grado di caricare (es., un file è codificato in *big endian*, ma noi abbiamo previsto solo *little endian*)

# Tipi di errore

-   Gli errori possono essere suddivisi in due classi:

    -   Errori di pertinenza del programmatore
    -   Errori di pertinenza dell'utente
    
-   A seconda del tipo di errore in cui vi imbattete, la sua gestione è diversa.

# Errori del programmatore

-   Si tratta di un errore logico del programma.
-   Un programma «perfetto» non dovrebbe mai avere errori logici.
-   Se si ha l'evidenza che è avvenuto un errore logico, sarebbe meglio segnalarlo **nel modo più rumoroso possibile**.

# Esempio

```python
my_list = [5, 3, 8, 4, 1, 9]
sorted = my_sort_function(my_list)

if not (len(my_list) == len(sorted)):
    print("Error, mismatch in the length of the sorted list")
    
if not (sorted[0] <= sorted[1]):
    print("Error, the array is not sorted")

# The program continues
...
```

# Esempio migliorato

```python
my_list = [5, 3, 8, 4, 1, 9]
sorted = my_sort_function(my_list)

# If any "assert", the program will crash and will print details
# about what the code was doing. If PDB support is turned on,
# a debugger will be fired automatically.
assert len(my_list) == len(sorted)
assert sorted[0] <= sorted[1]

# The program continues
...
```

# Gestione errori del programmatore

-   Tutti i linguaggi implementano funzioni che consentono di mandare in crash un programma (es., `assert` e `abort` in C/C++).
-   Queste istruzioni solitamente stampano a video una serie di dettagli sulla causa dell'errore, e sono pensate per essere usate insieme a un debugger.
-   Eseguire un debugger è sensato: se l'errore è logico, è il programmatore che deve mettere mano al codice, non l'utente!
-   Attenzione al fatto che alcune di queste funzioni potrebbero non essere compilate in modalità *release* (es., [`assert`](https://nim-lang.org/docs/assertions.html#assert.t,untyped,string) vs [`doAssert`](https://nim-lang.org/docs/assertions.html#doAssert.t%2Cuntyped%2Cstring) in Nim).

# Errori dell'utente

-   Sono errori causati da un input o un contesto sbagliato, e non per colpa di un errore nel programma:
    -   L'utente chiede di leggere un file che non esiste;
    -   L'utente chiede di scrivere un file su un supporto che non ha più spazio libero;
    -   L'utente specifica un input scorretto;
    -   L'utente chiede di usare una periferica (stampante?) non connessa al computer oppure spenta.
-   Vanno gestiti solitamente in modo molto diverso dagli errori del programmatore!

# Esempio

<asciinema-player src="./cast/user-error-74x25.cast" cols="74" rows="25" font-size="medium"></asciinema-player>

# Gestire errori dell'utente

-   Gli errori dell'utente sono **inevitabili**.
-   Se si ha evidenza che l'utente ha commesso un errore, ci sono diversi modi di reagire:
    1.  Stampare un messaggio di errore, il più chiaro possibile;
    2.  Chiedere all'utente di inserire di nuovo il dato scorretto;
    3.  In certi contesti il codice può decidere autonomamente come correggere l'errore.
    
        Ad esempio, se si chiede un valore numerico entro un certo intervallo $[a, b]$ e il valore fornito è $x > b$, si può porre $x = b$ e continuare.

# Correzione errori (1/2)

```python
x = float(input("Insert a number: "))
y = float(input("Insert another number: "))
if y != 0.0:
    print(f"The ratio {x} / {y} is {x / y}")
else:
    print("Error, the second number cannot be zero!")
```

# Correzione errori (2/2)

```python
x = float(input("Insert a number: "))

while True:
    y = float(input("Insert another number: "))
    if y == 0.0:
        print("Error, the second number cannot be zero!")
    else:
        break
        
print(f"The ratio {x} / {y} is {x / y}")
```

# Programma corretto

<asciinema-player src="./cast/user-error-corrected-74x25.cast" cols="74" rows="25" font-size="medium"></asciinema-player>

# Messaggi d'errore

-   Gli studenti hanno spesso la tendenza a stampare messaggi di errore.

-   Esempio (sbagliato) preso da un tema d'esame TNDS:

    ```c++
    double Bisezione::CercaZeri(double a, double b) {
        if(f->Eval(a) * f->Eval(b) >= 0) {
            cout << "Errore, teorema degli zeri non soddisfatto\n";
        } else {
            // Etc.
        }
    }
    ```

    Non c'è un `return` in corrispondenza dell'`if`, e l'esercizio chiedeva di calcolare lo zero di una funzione in un intervallo in cui lo zero **doveva esserci**. Se il teorema degli zeri non è soddisfatto, vuol dire che c'è un errore in `a` oppure `b`.

# Visibilità dei messaggi di errore

-   Se una funzione stampa un messaggio quando capita un errore, è molto probabile che quel messaggio si perda all'interno dell'output:

    ```text
    $ python3 my-beautiful-program.py
    Initializing the program...
    Now I am reading data from the device
    The device has sent 163421 samples
    Computing statistics on the samples
    Error, some samples are negative
    Sorting the samples
    Running a Monte Carlo simulations, please wait...
    Done, time elapsed: 164.96 seconds
    Producing the plots...
    Done, the results are saved in "output.pdf"
    $
    ```
    
-   Meglio rendere l'errore più visibile, ad esempio con i colori, oppure (meglio!) fermare del tutto l'esecuzione del programma appena l'errore si verifica.

# Errori dell'utente nelle funzioni

-   È solitamente molto semplice come gestire gli errori dell'utente nel `main` di un programma.
-   È invece meno chiaro come gestire gli errori nell'input passato a una funzione o un metodo, come ad esempio `Bisezione::CercaZeri` (gli estremi erano un input dell'utente, o erano stati calcolati automaticamente dal programma?).
-   Nessuna funzione o metodo dovrebbe **mai** fare qualcosa di catastrofico (mandare in crash il programma) o **visibile** (stampare un messaggio d'errore a video).
-   La **regola aurea** è che la funzione restituisca un valore di ritorno che segnali l'errore, oppure che sollevi un'eccezione.

# Restituire un errore

-   Se un linguaggio permette di restituire valori multipli, potete usare questa sintassi (molto usata in [Go](https://blog.golang.org/error-handling-and-go)):

    ```python
    (result, error_condition) = my_function(...)
    
    if error_condition:
        # Handle the error: print a message, crash the program, etc.
        ...
    ```

-   Linguaggi come Nim e Rust implementano tipi dedicati: [`Result`](https://doc.rust-lang.org/book/ch09-02-recoverable-errors-with-result.html) in Rust, 

-   Potete impiegare le eccezioni, se il vostro linguaggio le supporta:

    ```python
    def my_function(...):
        if something_wrong:
            raise Exception("Error!")
    ```

# Parametri d'errore

In linguaggi come il C/C++, un approccio molto usato è quello di accettare un parametro addizionale che segnali l'errore:

```c++
double my_function(..., bool & error) {
    if (something_wrong) {
        error = true;
        return 0.0;
    }

    // ...

    error = false;
    return result;
}
```

Al posto di un `bool` potete usare una `enum class` per registrare il tipo di errore, o addirittura una `struct` per racchiudere informazioni complesse.

# Tipi *nullable*

Linguaggi come C\# e Kotlin definiscono il tipo *nullable*, che può essere usato con qualsiasi tipo, e ne indica l'*assenza*:

```csharp
// C# example

// Note the "?" after "double": this is the same syntax as in Kotlin
double? result = my_function(...);

if (! result.HasValue)
{
    // Something wrong happened, my_function didn't compute the result
}
```
