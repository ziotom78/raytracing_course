---
title: "Lezione 3"
subtitle: "Calcolo numerico per la generazione di immagini fotorealistiche"
author: "Maurizio Tomasi <maurizio.tomasi@unimi.it>"
...

# Tone Mapping

# Da RGB a sRGB

-   Nella scorsa lezione abbiamo visto che l'equazione del rendering si riscrive naturalmente nelle componenti di colore R, G e B.

-   I dispositivi di visualizzazione (monitor, schermi di tablet, televisori) richiedono però l'uso di sRGB, che ha i seguenti limiti:

    -   Le componenti R, G e B sono numeri interi in un intervallo limitato
    -   La risposta dei dispositivi non è lineare
    
-   Il *tone mapping* è il processo attraverso cui si converte un'immagine RGB in un'immagine sRGB, dove per *immagine* si intende una matrice di colori RGB.

# Tone mapping

-   Una conversione da RGB a sRGB dovrebbe preservare la «tinta» complessiva di un'immagine.
-   Ecco perché non si parla di *tone mapping* per un singolo colore RGB, ma per una matrice di colori (ossia un'immagine).
-   Noi useremo il *tone mapping* descritto da Shirley (2003): è fisicamente meno preciso di altri metodi (es., la normalizzazione dello standard CIE usando D65), ma più semplice da implementare e fornisce comunque risultati visivamente gradevoli.

# Algoritmo di tone mapping

1.  Stabilire un valore «medio» per la radianza;
2.  Normalizzare il colore di ogni punto sul valore medio;
3.  Aggiustare i punti di maggiore luminosità.

# Valore medio

-   Il valore «neutro» per la radianza è definito dalla media logaritmica della luminosità $l$ dei pixel:
    $$
    \left<l\right> = \exp\left(\frac{\sum_i \log(\delta + l_i)}N\right),
    $$
    dove $i$ itera su $N$ pixel, e $\delta \ll 1$ evita la singolarità di $\log x$ in $x = 0$.

-   Quale valore usare per la luminosità $l_i$?

# Valore medio

-   $l = (R + G + B) / 3$;

-   $l = (R + G + B) / 3$;

-   $l = \frac{\max(R, G, B) + \min(R, G, B)}2$ («*luminosità*»).
        
    Noi useremo quest'ultima definizione: nonostante non sia fisicamente significativa, è quella che porta a risultati visivamente migliori.

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

Una volta stimato il valore medio, i valori R, G, B dell'immagine sono aggiornati tramite la trasformazione
$$
R_i \rightarrow a \times \frac{R_i}{\left<l\right>},
$$
dove $a$ è un valore impostabile dall'utente (Shirley suggerisce $a = 0.18$).


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

# Immagini

# Formati grafici

-   L'obbiettivo del corso è di creare immagini fotorealistiche integrando l'equazione del rendering.

-   Un'immagine fotorealistica dovrebbe essere indistinguibile da quella prodotta da una fotocamera.

-   In che modo una fotocamera registra in un file un'immagine?

# Salvataggio di immagini

-   Esistono due famiglie di file grafici:

    -   Grafica vettoriale: SVG, PDF, EPS, AI…
    -   Grafica raster (matriciale): JPEG, PNG, GIF, RAW…
    
-   I file **vettoriali** contengono istruzioni per disegnare un'immagine:

    ```text
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
-   Formati diversi implementano compressioni diverse;
-   Non sarà obbligatorio implementare la compressione delle immagini nei nostri codici, ma è comunque indispensabile conoscerne i fondamenti.

# Compressione dati

-   La compressione dei dati è un argomento molto importante in fisica computazionale.

-   Le simulazioni e gli esperimenti del XXI secolo richiedono di registrare quantità di dati sempre più grandi. Nell'ambito della cosmologia della CMB, bastano questi dati:

    -   Nel periodo 1989–1993, l'esperimento spaziale COBE/DMR ha registrato  meno di 8 GB di dati;
    -   Nel periodo 2001–2010, l'esperimento WMAP ha registrato 200 GB di dati;
    -   Nel periodo 2009–2013, l'esperimento Planck ha registrato 30 TB (30,000 GB) di dati.
    
    Grandi moli di dati sono comuni anche in altri domini della fisica (particelle, climatologia, etc.).

-   Apprendere i principi della compressione dati è estremamente utile!

# Compressione di immagini

-   Uno schermo di computer ha solitamente una risoluzione di 1920×1080 pixel.

-   Se vengono usati 8+8+8=24 bit per il colore sRGB di ogni pixel (3 byte per pixel), il numero totale di byte necessari è
    $$
    3 \times 1920 \times 1080 = 6\,220\,800
    $$
    che equivale a circa 6 MB.

-   Nelle immagini c'è solitamente molta informazione ridondante che può essere eliminata.

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
