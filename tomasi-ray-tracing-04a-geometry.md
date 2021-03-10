---
title: "Lezione 4"
subtitle: "Calcolo numerico per la generazione di immagini fotorealistiche"
author: "Maurizio Tomasi <maurizio.tomasi@unimi.it>"
...

# Equazione del rendering

# Formulazione dell'equazione

L'equazione che studieremo durante il corso è la seguente:
$$
\begin{aligned}
L(x \rightarrow \Theta) = &L_e(x \rightarrow \Theta) +\\
&\int_{\Omega_x} f_r(x, \Psi \rightarrow \Theta)\,L(x \leftarrow \Psi)\,\cos(N_x, \Psi)\,\mathrm{d}\omega_\Psi,
\end{aligned}
$$
dove $L_e$ è la radianza emessa dalla superficie nel punto $x$ lungo la direzione $\Theta$.

# Esempi banali

-   Assenza di radiazione: in questo caso $L_e = 0$ e $\forall\Psi: L(x \leftarrow \Psi) = 0$, quindi

    $$
    L = 0.
    $$
    
    È una scena perfettamente buia: molto poco interessante!

-   Se un punto emette radiazione isotropa con radianza $L_e$ in $x_0$, allora in ogni altro punto $x$ dello spazio vale che

    $$
    L(x_0 \rightarrow \Theta) = L_e
    $$
    
    Tutto lo spazio è riempito dalla medesima radianza: poco interessante!

# Esempio più complesso

Piano infinito diffusivo ideale e non emettente ($L_e = 0$) e una sferetta di raggio $r$ a una distanza $d \gg r$ dal piano che emette isotropicamente con radianza $L_d$. 

![](./media/plane.png){height=360}

# Esempio più complesso

Dato un punto $x$ sul piano, vale che:

$$
L(x \rightarrow \Theta) = \int_{2\pi} \frac{\rho_d}\pi\,L(x \leftarrow \Psi)\,\cos(N_x, \Psi)\,\mathrm{d}\omega_\Psi.
$$
Già qui le cose si complicano! Qual è il valore di $L(x \leftarrow \Psi)$? (No, *non* è $L_d$!)

# Radianza entrante

Il valore di $L(x \leftarrow \Psi)$ è **nullo**, tranne quando $\Psi$ punta verso la sorgente luminosa. Dividiamo il dominio dell'integrale:
$$
\int_{2\pi} = \int_{\Omega(d)} + \int_{2\pi - \Omega{d}},
$$
dove $\Omega(d)$ è l'angolo solido della sfera alla distanza $d$. Il secondo integrale è nullo, perché su quell'angolo solido $L(x \leftarrow \Psi) = 0$.

# Radianza entrante

L'integrale sull'angolo solido $\Omega(d)$ è semplice se supponiamo che nel dominio sia $d$ che l'angolo $\theta$ tra $N_x$ e $\Psi$ siano costanti (la sfera è piccola):
$$
L(x \rightarrow \Theta) = \int_{\Omega(d)} \frac{\rho_d}\pi\,L_d\,\cos(N_x, \Psi)\,\mathrm{d}\omega_\Psi \approx \frac{\rho_d}\pi\,L_d\,\cos\theta \times \pi\left(\frac{r}d\right)^2,
$$
dove $\theta$ è l'angolo tra la normale e la direzione della sferetta.

# Proprietà della soluzione

-   $L(x \rightarrow \Theta) \approx \rho_d\,L_d\,\cos\theta\,\left(\frac{r}d\right)^2.$
-   Anche se il punto emette isotropicamente e la superficie è diffusiva ideale, c'è comunque una dipendenza dal coseno di $\theta$.
-   La radianza riflessa è proporzionale alla superficie della sfera ($\propto r^2$).
-   All'aumentare di $d$, la radiazione emessa dal piano diminuisce come $d^{-2}$.

# Doppio piano

Supponiamo ora di avere *due* piani diffusivi ideali:

![](./media/double-plane.png){height=360}

Come si tratta questo caso?

# Doppio piano

Consideriamo ancora il piano sottostante. Vale che:

$$
L_\text{down}(x \rightarrow \Theta) = \int_{\Omega_x} \frac{\rho_d}\pi\,L(x \leftarrow \Psi)\,\cos(N_x, \Psi)\,\mathrm{d}\omega_\Psi.
$$
Ma ora l'integrale non è più una semplice delta di Dirac: oltre alla sferetta c'è il piano superiore. Qual è il valore di $L_\text{up}(x \leftarrow \Psi)$ prodotto dal piano superiore?

# Doppio piano

Il valore di $L(x \leftarrow \Psi)$ causato da una direzioneper il piano superiore si calcola con la stessa formula della slide precedente:

$$
L_\text{up}(x \rightarrow \Theta) = \int_{\Omega_x} \frac{\rho_d}\pi\,L(x \leftarrow \Psi)\,\cos(N_x, \Psi)\,\mathrm{d}\omega_\Psi.
$$

Ma così ci invischiamo in un problema ricorsivo!

# Il problema generale

Nel caso generale avviene che l'integrale da calcolare è *multiplo*:

$$
L(x \rightarrow \Theta) = \int_{\Omega^{(1)}_x} \int_{\Omega^{(2)}_x} \int_{\Omega^{(3)}_x} \ldots
$$

È un integrale a molte dimensioni (i termini successivi al primo sono sempre meno importanti e tendono a zero, quindi le dimensioni non sono *infinite*).

# Il problema generale

-  L'equazione del rendering è impossibile da risolvere analiticamente
   nel caso generale.
-  Ecco quindi la necessità di usare il calcolo numerico
-  Il nostro codice dovrà implementare una serie di tipi geometrici

# Modellizzazione di oggetti

---

<center>
![](./media/night-stand-photo.jpg)
</center>

---

<center>
![](./media/night-stand-sketch.png)
</center>

---

<center>
![](./media/night-stand-lines.png)
</center>

---

<center>
![](./media/night-stand-vertexes.png)
</center>

# Lezioni imparate oggi

---

-   Sempre definire in modo accurato le quantità misurabili (energia, flusso, radianza, etc.).
-   Assicurarsi di studiare un modello fisico in casi semplici (spazio vuoto, sferetta e piano, sferetta e due piani, etc.), per *capire* il modello prima di usarlo.
-   Il mondo è *complicato*!
night-stand-lines.png
night-stand-photo.jpg
night-stand-sketch.png
night-stand-vertexes.png
