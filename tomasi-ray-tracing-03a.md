---
title: "Lezione 3"
subtitle: "Calcolo numerico per la generazione di immagini fotorealistiche"
author: "Maurizio Tomasi <maurizio.tomasi@unimi.it>"
...

# Immagini

# Salvataggio di immagini

-   Due tipi di file grafici:

    -   Vettoriali: SVG, PDF, EPS, AI…
    -   Raster (matriciali): JPEG, PNG, GIF, RAW…
    
-   I file **vettoriali** contengono istruzioni per disegnare un'immagine:

    ```
    - cerchio centrato in (3.5, 2.6) con raggio 1.5 di colore nero
    - linea da (1.1, 1.7) a (3.7, 7.4) di colore nero con spessore 2
    - etc.
    ```
    
-   I file **raster** salvano una matrice di colori, e sono quelli che ci
    interessano per questo corso.
    
---

<center>
![](./media/difference-between-raster-and-vector-image.png)
</center>

# Grafica vettoriale

<center>
![](./media/Carnot-cycle-p-V-diagram.svg)
</center>

# Grafica raster

<center>
![](./media/gilles_tran.jpg)
</center>

# Codifica di immagini raster

-   Un'immagine è una matrice di colori, dove ogni colore è solitamente una tripletta RGB;
-   L'ordine con cui viene salvata la matrice (destra-sinistra, alto-basso, per righe o per colonne) è determinato dal formato;
-   Formati diversi implementano compressioni diverse.

# Compressione di immagini

# Tone Mapping

# Tone mapping

-   Per *tone mapping* si intende una conversione da RGB a sRGB che preservi la «tinta» complessiva di un'immagine.
-   Noi useremo il *tone mapping* descritto da Shirley (2003) anziché la normalizzazione su D65 per stabilire la conversione da RGB a sRGB: è fisicamente meno preciso, ma più semplice da implementare e fornisce risultati visivamente gradevoli.

# Algoritmo di tone mapping

1.  Stabilire un valore «neutro» per la radianza;
2.  Normalizzare il colore di ogni punto sul valore neutro;
3.  Aggiustare i punti di maggiore luminosità.

# Valore neutro

-   Il valore «neutro» per la radianza è definito dalla media logaritmica della luminosità $l$ dei pixel:

    $$
    \left<l\right> = \exp\left(\frac{\sum_i \log(\delta + l_i)}N\right),
    $$
    dove $i$ itera su $N$ pixel, e $\delta \ll 1$ evita la singolarità di $\log x$ in $x = 0$.

-   Quale valore usare per $S$ nel *tone mapping*?

# Valore neutro


-   $S = (R + G + B) / 3$;

-   $S = (R + G + B) / 3$;

-   $S = \frac{\max(R, G, B) + \min(R, G, B)}2$ (*luminosità*).
        
    Noi useremo quest'ultima definizione: la luminosità non è una quantità fisicamente significativa, ma è quella che porta a risultati visivamente migliori.

# Perché la media logaritmica?

-   La risposta dell'occhio a uno stimolo $S$ è logaritmica (*leggi di Weber-Fechner*):

    $$
    p = k \log \frac{S}{S_0}
    $$
    dove $p$ è il valore percepito, e $S$ è l'intensità dello stimolo.
    
-   La media logaritmica è una media sugli *esponenti*:
    $$
    10^{\frac{\log_{10} 10^2 + \log_{10} 10^4 + \log_{10} 10^6}3} = 10^4,
    $$
    mentre la media aritmetica è $(10^2 + 10^4 + 10^6)/3 \approx 10^6/3$.


# Normalizzazione

Una volta stimato il valore neutro, i valori R, G, B dell'immagine sono aggiornati tramite la trasformazione
$$
R_i \rightarrow a \times \frac{R_i}{\left<l\right>},
$$
dove $a$ è un valore impostabile dall'utente (Shirley suggerisce $a = 0.18$).


# Punti luminosi

![](./media/bright-light-in-room.jpg){height=520}

Sono notoriamente difficili da trattare!

# Punti luminosi

Shirley suggerisce di applicare ai valori R, G, B di ogni pixel la trasformazione
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
