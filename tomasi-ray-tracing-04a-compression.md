---
title: "Lezione 4"
subtitle: "Calcolo numerico per la generazione di immagini fotorealistiche"
author: "Maurizio Tomasi <maurizio.tomasi@unimi.it>"
...

# Compressione

# Compressione dei dati

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
