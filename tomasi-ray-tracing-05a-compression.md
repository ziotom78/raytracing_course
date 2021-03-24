---
title: "Lezione 5"
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
-   Noi useremo il *tone mapping* descritto da Shirley (2003): è fisicamente meno preciso di altri metodi (es., la normalizzazione dello standard CIE usando D65), ma più intuitivo e più semplice da implementare.

# Algoritmo di tone mapping

1.  Stabilire un valore «medio» per l'irradianza misurata in corrispondenza di ogni pixel dell'immagine;
2.  Normalizzare il colore di ogni pixel a questo valore medio;
3.  Applicare una correzione ai punti di maggiore luminosità.

# Valore medio

-   Il valore «neutro» per la radianza è definito dalla media logaritmica della luminosità $l_i$ dei pixel (con $i = 1\ldots N$):
    $$
    \left<l\right> = \exp\left(\frac{\sum_i \log(\delta + l_i)}N\right),
    $$
    dove $\delta \ll 1$ evita la singolarità di $\log x$ in $x = 0$.

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

Shirley usa l'ultima definizione perché sostiene che, nonostante non sia fisicamente significativa, produca risultati visivamente migliori.

# Perché la media logaritmica?

-   Non abbiamo ancora giustificato la formula
    $$
    \left<l\right> = \exp\left(\frac{\sum_i \log(\delta + l_i)}N\right),
    $$

-   Essa è plausibile perché la risposta dell'occhio a uno stimolo $S$ è logaritmica (*leggi di Weber-Fechner*):
    $$
    p = k \log \frac{S}{S_0}
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

Una volta stimato il valore medio, i valori R, G, B dell'immagine sono aggiornati tramite la trasformazione
$$
R_i \rightarrow a \times \frac{R_i}{\left<l\right>},
$$
dove $a$ è un valore impostabile dall'utente (Shirley suggerisce $a = 0.18$, ma in realtà si dovrebbe ottimizzare a seconda dell'immagine).


# Punti luminosi

![](./media/bright-light-in-room.jpg){height=520}

Sono notoriamente difficili da trattare!

# Punti luminosi

Shirley suggerisce di applicare ai valori R, G, B di ogni punto dell'immagine la trasformazione
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

---

<center>
![](./media/kitchen-gamma-settings.png)
</center>

# Uso del tone mapping

```{.graphviz}
digraph "" {
    read [label="read input file" shape=box];
    solve [label="solve the rendering equation" shape=box];
    savepfm [label="save a PFM file" shape=box];
    tonemapping [label="apply tone mapping" shape=box];
    savepng [label="save a PNG file" shape=box];
    read -> solve;
    solve -> savepfm;
    savepfm -> tonemapping;
    tonemapping -> savepng;
    savepng -> tonemapping;
}
```


# Formati grafici e compressione

# Formati LDR

-   Non ci sarà un formato obbligatorio da implementare nel codice (PNG, JPEG, BMP, GIF, etc.): scegliete quello che vi intriga di più, o il più semplice da implementare.
-   È però importante evidenziare le differenze tra i vari formati, perché ciascun formato ha vantaggi e svantaggi.

# Differenze tra formati

Versatilità
: Alcuni formati supportano solo colori codificati come terne (R, G, B) di 8×3 bytes, altri ammettono più possibilità
Metadati
: Alcuni formati consentono di associare più metadati all'immagine, altri sono più rigidi.
Facilità di lettura/scrittura
: Ci sono formati molto semplici da scrivere (come PNM), altri notevolmente più complessi (JPEG).
Compressione
: Formati diversi implementano metodi per comprimere i dati e ridurre lo spazio su disco.

# Compressione dati

-   Uno schermo di computer ha solitamente una risoluzione di 1920×1080 pixel.

-   Se vengono usati 8+8+8=24 bit per il colore sRGB di ogni pixel (3 byte per pixel), il numero totale di byte necessari è
    $$
    3 \times 1920 \times 1080 = 6\,220\,800
    $$
    che equivale a circa 6 MB.

-   Nelle immagini c'è solitamente molta informazione ridondante che può essere eliminata.

# Compressione dati

-   La compressione dei dati è un argomento molto importante in fisica computazionale.

-   Le simulazioni e gli esperimenti del XXI secolo richiedono di registrare quantità di dati sempre più grandi. Nell'ambito della cosmologia della CMB, bastano questi dati:

    -   Nel periodo 1989–1993, l'esperimento spaziale COBE/DMR ha registrato  meno di 8 GB di dati;
    -   Nel periodo 2001–2010, l'esperimento WMAP ha registrato 200 GB di dati;
    -   Nel periodo 2009–2013, l'esperimento Planck ha registrato 30 TB (30,000 GB) di dati.
    
    Grandi moli di dati sono comuni anche in altri domini della fisica (particelle, climatologia, etc.): apprendere i principi della compressione dati è estremamente utile!
    
-   Vediamo quindi nel dettaglio alcuni algoritmi di compressione usati nei file grafici.

---

<center>
![](./media/astro_maurizio_1_PkZIP-13.png)
</center>

---

<center>
![](./media/astro_maurizio_1_PkZIP-14.png)
</center>

---

<center>
![](./media/astro_maurizio_1_PkZIP-15.png)
</center>

---

<center>
![](./media/astro_maurizio_1_PkZIP-16.png)
</center>

---

<center>
![](./media/astro_maurizio_1_PkZIP-17.png)
</center>

---

<center>
![](./media/astro_maurizio_1_PkZIP-18.png)
</center>

---

<center>
![](./media/astro_maurizio_1_PkZIP-19.png)
</center>

---

<center>
![](./media/astro_maurizio_1_PkZIP-20.png)
</center>

---

<center>
![](./media/astro_maurizio_1_PkZIP-21.png)
</center>

---

<center>
![](./media/astro_maurizio_1_PkZIP-22.png)
</center>

---

<center>
![](./media/astro_maurizio_1_PkZIP-23.png)
</center>

---

<center>
![](./media/astro_maurizio_1_PkZIP-24.png)
</center>

---

<center>
![](./media/astro_maurizio_1_PkZIP-25.png)
</center>

---

<center>
![](./media/astro_maurizio_1_PkZIP-26.png)
</center>

---

<center>
![](./media/astro_maurizio_1_PkZIP-27.png)
</center>

---

<center>
![](./media/astro_maurizio_1_PkZIP-28.png)
</center>

---

<center>
![](./media/astro_maurizio_1_PkZIP-29.png)
</center>
