---
title: "Esercitazione 2"
subtitle: "Calcolo numerico per la generazione di immagini fotorealistiche"
author: "Maurizio Tomasi <maurizio.tomasi@unimi.it>"
...

# Gestione dei colori

# Codificare un colore

-   Abbiamo visto che i colori percepiti dall'occhio umano possono essere codificati tramite tre valori scalari $X$, $Y$, $Z$.
-   Il sistema più usato per codificare colori è però RGB (Red, Green, Blue), che si può convertire in XYZ tramite una trasformazione matriciale.
-   Il compito di oggi è implementare un tipo di dato `Color` che codifichi un colore secondo i livelli di rosso, verde e blu.

# Colori in Python

-   Definiamo una classe `Color` usando `@dataclass` (come `struct` in C++):

    ```python
    # Supported since Python 3.7
    from dataclasses import dataclass

    @dataclass
    class Color:
        red: float
        green: float
        blue: float
    ```

-   È possibile creare un colore con questa sintassi:

    ```python
    color1 = Color(red=3.4, green=0.4, blue=1.7)
    color2 = Color(3.4, 0.4, 1.7)  # Shorter version
    ```

# Verifica del codice

# Scrittura di test automatici

# Continuous Integration

# Implementazione

# Dettagli di `Color`

-   Definite un tipo `Color` e le seguenti operazioni su esso:

    -   Somma/sottrazione di due colori, componente per componente (la sottrazione sarà utile in seguito);
    -   Prodotto per uno scalare.

-   Se il vostro linguaggio lo consente, definite il tipo `Color`
    come un *value type*:

    -   In C++, usate `struct` oppure `class`;
    -   In C\#, usate `struct`, ma non usate `class`;
    -   In Pascal, usate `object` o `record`, ma non usate `class`;
    -   In Nim, usate `object`, ma non usate `ref object`.

# Guida per l'esercitazione

# Guida per l'esercitazione

1.   Creare un nuovo repository GitHub: questo sarà il repository che userete per il resto del corso!

2.   Implementare il tipo `Color` con le seguenti caratteristiche:

     -   Campi `red`, `green`, `blue`;
     -   Funzione `is_close` per verificare se due colori sono simili;
     -   Somma e differenza tra colori, prodotto colore-scalare;
     -   Costante `BLACK_COLOR = Color(0.0, 0.0, 0.0)`.

3.   Implementare una suite completa di test;

4.   Attivare un sistema di Continuous Integration con GitHub Actions.


# Test (1)

-   Creazione di colori e funzione `is_close`:

    ```python
    col1 = Color(0.7, 0.4, 0.3)

    assert col1.is_close(Color(0.7, 0.4, 0.3))
    ```

-   Verifica che `is_close` fallisca quando è necessario:

    ```python
    try:
        assert col2.is_close(Color(0.1, 0.2, 0.3))
        assert False  # You shouldn't reach this line!
    except AssertionError:
        pass  # Ok!
    ```

# Test (2)

-   Somma/differenza di colori:

    ```python
    col2 = Color(0.1, 0.2, 0.9)

    sum_col = col1 + col2
    assert sum_col.is_close(Color(0.8, 0.6, 1.2))

    sub_col = col1 - col2
    assert sub_col.is_close(Color(0.6, 0.2, -0.6))
    ```

-   Prodotto scalare-colore (potete implementare anche colore-scalare,
    se volete):

    ```python
    prod_col = 2.0 * col1

    assert prod_col.is_close(Color(1.4, 0.8, 0.6))
    ```
