---
title: "Lezione 6"
subtitle: "Calcolo numerico per la generazione di immagini fotorealistiche"
author: "Maurizio Tomasi <maurizio.tomasi@unimi.it>"
...

# Modellizzazione di oggetti

# «Cornell box»

![](./media/cornell_box_physical_model_image11.jpg){height=560}

# «Cornell box»

![](./media/cornell-box-schema.svg){height=560}

---

<center>
![](./media/night-stand-photo.jpg){height=620}
</center>

---

<center>
![](./media/night-stand-sketch.png){height=620}
</center>

---

<center>
![](./media/night-stand-lines.png){height=620}
</center>

---

<center>
![](./media/night-stand-vertexes.png){height=620}
</center>

# Posizioni e trasformazioni

-   La descrizione geometrica di un oggetto nello spazio fa solitamente uso di trasformazioni;

-   Queste trasformazioni sono necessarie per collocare gli oggetti che compongono la scena in modo che la loro posizione, il loro orientamento e le loro dimensioni siano quelle desiderate.

-   Anche la posizione della telecamera viene specificata tramite trasformazioni che ne identificano la posizione (dove sta l'osservatore?) e l'orientamento (in che direzione sta guardando?).

# Interazione con superfici

<center>
![](./media/surface-normals-wikipedia.svg)
</center>

Il modo in cui un raggio di luce interagisce con una superficie dipende dalla BRDF, che [è espressa in termini dell'angolo](tomasi-ray-tracing-01a-rendering-equation.html#/la-brdf) $\theta = N_x \cdot \Psi$ tra la direzione di incidenza $\Psi$ e la normale $N_x$ alla superficie nel punto $x$.

# Codifica della geometria

Per risolvere l'equazione del rendering numericamente, il nostro codice deve trattare correttamente una serie di quantità:

-   Punti nello spazio tridimensionale (posizioni dei vertici del comodino);
-   Vettori 3D (direzioni di propagazione della luce);
-   Normali (che rappresentano l'inclinazione della superficie in un punto);
-   Matrici (per rappresentare le trasformazioni).

Ripassiamo quindi le proprietà di questi oggetti geometrici.

# Ripasso di algebra lineare

# Spazi vettoriali

Uno spazio vettoriale $V$ su un campo $F$ è un insieme non vuoto $V$ di elementi, detti *vettori*, associato a due operatori $+: V \times V \rightarrow V$ e $\cdot: F \times V \rightarrow V$ che soddisfano queste proprietà $\forall u, v, w \in V, \forall \alpha, \beta \in F$:

#.  $+$ è commutativo e associativo;
#.  Esiste un vettore $0$ che è elemento neutro per $+$;
#.  $\forall u \in V,\ \exist -u \in V: u + (-u) = 0$;
#.  $\alpha(\beta v) = (\alpha\beta) v,\quad (\alpha + \beta) v = \alpha v + \beta v,\quad \alpha(v + u) = \alpha v + \alpha u$;
#.  Se $1 \in F$ è l'elemento neutro del prodotto su $F$, allora $1u = u$.

# Prodotto interno

Dato uno spazio vettoriale $V$ su $F$, il prodotto interno è un'operazione $\left<\cdot, \cdot\right>: V \times V \rightarrow F$ che gode delle seguenti proprietà $\forall u, v, w \in V, \forall \alpha \in F$:

#.  $\left<\alpha u, v\right> = \alpha \left<u, v\right>$;
#.  $\left<u + v, w\right> = \left<u, w\right> + \left<v, w\right>$;
#.  $\left<u, v\right> = \overline{\left<v, u\right>}$;
#.  $\left<u, u\right> > 0$ se $u \not= 0$.

Un esempio è il classico prodotto scalare $\vec u \cdot \vec v = \left\|\vec u\right\|\,\left\|v\right\|\,\cos\theta$ su $\mathbb{R}^n$.

# Norma e ortogonalità

-   Dato un prodotto interno, si può definire la *norma* $\left\|\cdot\right\|: V \rightarrow F$ in questo modo:

    $$
    \left\|u\right\| = \sqrt{\left<u, u\right>},
    $$
    
    che è positiva definita, e si annulla solo se $u = 0$.
    
-   Si definiscono *ortogonali* due vettori $u$ e $v$ se vale che $\left<u, v\right> = 0$.

-   Un vettore $u$ tale che $\left\|u\right\| = 1$ si dice *normalizzato*.

# Generatori

-   Lo spazio generato da un insieme di vettori $\{v_i\}_{i=1}^N$ è l'insieme

    $$
    \mathrm{Span}\left(\{v_i\}_{i=1}^N\right) = \left\{\sum_{i=1}^N \alpha_i v_i \forall \alpha_i \in F\right\}.
    $$

-   Nel caso di $\mathbb{R}^3$:
    #.  Lo spazio generato da $\vec v$ è la retta passante per 0 e allineata con $\vec v$.
    #.  Lo spazio generato da due vettori $\vec v$ e $\vec w$ non paralleli è il piano passante per l'origine su cui giacciono $\vec v$ e $\vec w$.
    
# Basi (1/2)

-   I vettori $\{v_i\}_{i=1}^N$ si dicono *linearmente indipendenti* se l'uguaglianza

    $$
    \sum_{i=1}^N \alpha_i v_i = 0
    $$
    
    vale solo se $\alpha_i = 0\ \forall i=1\ldots N$.

-   Un insieme di vettori $\left\{v_i\right\}_{i=1}^N$ è detto *base* di $B$ se sono linearmente indipendenti e generano $V$, ossia

    $$
    \mathrm{Span}\left(\{v_i\}_{i=1}^N\right) = V.
    $$
    
# Basi (2/2)

-   Se $V$ ammette due basi $\left\{e_i\right\}_{i=1}^N$ ed $\left\{f_i\right\}_{i=1}^M$, il numero di elementi in entrambe è identico ($N = M$) ed è detto *dimensione* di $V$. (Ignoriamo in questo corso gli spazi infinito-dimensionali.)

-   Si definisce *base ortonormale* di uno spazio vettoriale $V$ dotato di prodotto interno l'insieme di vettori $\left\{e_i\right\}_{i=1}^N$ tali che

    $$
    \left<e_i, e_j\right> = \delta_{ij}\quad\forall i, j = 1 \ldots N.
    $$
    
# Rappresentazione di vettori

-   Data una base $\{e_i\}_{i=1}^N$, è sempre possibile scrivere $v \in V$ come

    $$
    v = \sum_{i=1}^N \alpha_i e_i,
    $$
    
    dove $\alpha_i \in F$. (Conseguenza del fatto che la base genera lo spazio $V$).
    
-   Tale rappresentazione è sempre unica; se la base è ortonormale, allora vale anche che

    $$\alpha_i = \left<v, e_i\right>.$$

# Rappresentazione di vettori

-   Il fatto che $\alpha_i = \left<v, e_i\right>$ vale **solo** se la base è ortonormale!

-   Ad esempio, consideriamo sul piano $\mathbb{R}^2$ la base $e_1 = (1, 0), e_2 = (1, 1)$. Il vettore $v = (4, 3)$ si scompone come

    $$
    v = e_1 + 3 e_2 = \begin{pmatrix}1\\0\end{pmatrix} + 3 \begin{pmatrix}1\\1\end{pmatrix} = \begin{pmatrix}4\\3\end{pmatrix},
    $$
    
    ma $\left<v, e_1\right> = 4$ e $\left<v, e_2\right> = 7$.

-   Il nostro codice userà sempre basi ortonormali.

# Trasformazioni lineari

-   Una trasformazione lineare da uno spazio vettoriale $V$ a uno spazio $W$ è una funzione lineare $f: V \rightarrow W$:

    $$
    f(\alpha u + \beta v) = \alpha f(u) + \beta f(v).
    $$
    
-   Dalla linearità ne segue che $f(0) = 0$, perché

    $$
    f(0) = f(v - v) = f(v) - f(v) = 0\quad\forall v \in V.
    $$

# Matrici (1/2)

-   Una matrice $M$ è un insieme di valori scalari $\left\{m_{ij}\right\} \in F$ che rappresenta una trasformazione lineare $f: V \rightarrow W$ secondo una coppia di basi per $V$ e per $W$.

-   La matrice $M$ che rappresenta $f: V \rightarrow W$ deve avere $n = N$ colonne e $m = M$ righe, dove $N$ è la dimensione di $V$ e $M$ è la dimensione di $W$.

# Matrici (2/2)

-   Se si conosce il valore di $f(e_i)\ \forall e_i$, si può calcolare $f$ su qualsiasi vettore:

    $$
    f(v) = f\left(\sum_{i=1}^N \alpha_i e_i\right) =
    \sum_{i=1}^N \alpha_i f(e_i).
    $$

-   Il punto precedente si lega al fatto che la colonna $i$-esima della matrice $M$ contiene la rappresentazione di $f(e_i)$ (con $e_i$ elemento $i$-esimo della base di $V$) nella base di $W$.

# Primo esempio

-   Consideriamo la matrice in $\mathbb{R}^2$

    $$
    M = \begin{pmatrix}3&4\\2&-1\end{pmatrix}
    $$
    
    e la base $e_1 = (1, 0), e_2 = (0, 1)$.
    
-   È facile vedere che la prima colonna di $M$ è uguale a $M e_1$ e la seconda a $M e_2$:

    $$
    M e_1 = \begin{pmatrix}3&4\\2&-1\end{pmatrix} \begin{pmatrix}1\\0\end{pmatrix} = \begin{pmatrix}3\\2\end{pmatrix},\quad
    M e_2 = \begin{pmatrix}3&4\\2&-1\end{pmatrix} \begin{pmatrix}0\\1\end{pmatrix} = \begin{pmatrix}4\\-1\end{pmatrix}.
    $$

# Secondo esempio

-   Scriviamo la matrice $R(\theta)$ che rappresenta una rotazione di $\theta$ intorno all'origine del piano cartesiano $xy$.

-   Per quanto detto, è sufficiente calcolare $R(\theta) e_1$ e $R(\theta) e_2$:

    $$
    R(\theta) e_1 = \begin{pmatrix}\cos\theta\\\sin\theta\end{pmatrix}, \quad
    R(\theta) e_2 = \begin{pmatrix}\cos(\theta + 90^\circ)\\\sin(\theta + 90^\circ)\end{pmatrix} = \begin{pmatrix}-\sin\theta\\\cos\theta\end{pmatrix},
    $$
    
    perché essi sono le colonne della matrice $R(\theta)$:
    
    $$
    R(\theta) = \begin{pmatrix}\cos\theta&-\sin\theta\\\sin\theta&\cos\theta\end{pmatrix}.
    $$

# Riflessioni

-   Consideriamo ora un tipo particolare di trasformazione, detta *riflessione*.

-   Punti, vettori ed angoli si trasformano in maniera intuitiva rispetto alle riflessioni:

    <center>
    ![](./media/mirror.svg){height=380px}
    </center>

# Pseudovettori

-   Consideriamo ora un'automobile che si allontana da noi, e la sua copia riflessa.

-   Il momento angolare delle ruote $\vec\omega$ **non** si trasforma come un normale vettore nella riflessione: è uno *pseudovettore*.

    <center>
    ![](./media/auto-angular-momentum.svg){height=380px}
    </center>
    
# Pseudovettori

-   Il problema di $\vec\omega$ è che è definito tramite il prodotto vettoriale: $\vec \omega = \vec r \times \vec p$, e il risultato di un prodotto vettoriale è *sempre* uno pseudovettore.

-   Questo si vede anche nel caso della legge di Ampère:

    <center>
    ![](./media/B-pseudovector.svg){height=380px}
    </center>

# Trasformazioni

---

<center>
![](./media/raytracing-example.webp)
</center>

# Tipi di trasformazioni

-   Ci interesseremo solo di trasformazioni **invertibili**.

-   Le trasformazioni che implementeremo saranno le seguenti:
    #.  Trasformazione di scala (ingrandimento/rimpicciolimento);
    #.  Rotazione attorno ad un asse;
    #.  Traslazione (spostamento).
    
    <center>
    ![](./media/transformations.svg)
    </center>

# Trasformazioni di scala

# Proprietà generali

-   Una trasformazione di scala è rappresentata da una matrice diagonale $M = \mathrm{diag}(s_1, s_2, \ldots)$ con $s_i \not= 0\ \forall i$:

    $$
    M = \begin{pmatrix}s_1& 0& \vdots\\0& s_2& \vdots\\\ldots& \ldots&\end{pmatrix}.
    $$
    
-   Trasformazioni di scala in cui $s_i < 0$ sono anche dette *speculari* rispetto all'asse $i$-esimo (riflessione rispetto a uno specchio).

# Esempio

-   Un cerchio sul piano può essere trasformato in un ellisse tramite una trasformazione di scala; nell'esempio qui sotto, $M = \mathrm{diag}(1/2, 1)$:

    <center>
    ```{.gle im_fmt="svg" im_opt="-cairo -device svg" im_out="img"}
    size 10 4

    amove 2 2
    circle 2 fill grey50

    amove 7.5 2
    begin scale 0.5 1.0
        circle 2 fill grey20
    end scale
    ```
    </center>
    
-   Una riflessione rispetto all'asse $y$ è rappresentata da $M = \mathrm{diag}(1, -1)$.

    <center>
    ```{.gle im_fmt="svg" im_opt="-cairo -device svg" im_out="img"}
    size 10 4

    begin path fill grey50 stroke
        amove 7 0
        rline 3 0
        rline 0 4
        closepath
    end path

    begin path fill grey20 stroke
        amove 3 0
        rline -3 0
        rline 0 4
        closepath
    end path
    ```
    </center>

# Rotazioni

---

# Formalismo

-   Per definire una rotazione sul piano attorno all'origine è sufficiente **un** grado di libertà.

-   Però per definire una rotazione in tre dimensioni intorno all'origine sono necessari **tre** gradi di libertà: l'asse di rotazione e l'angolo. (L'asse di rotazione è un vettore di lunghezza unitaria, quindi ha due gradi di libertà).

-   Ci sono vari modi per rappresentare una rotazione, alcuni più efficaci di altri a seconda del contesto. Noi considereremo il formalismo matriciale, ma daremo anche una panoramica sui **quaternioni**.

# Traslazioni

# Il problema delle traslazioni

-   Il vettore $\vec \omega$ 

```{.asy im_fmt="html" im_opt="-f html" im_out="img"}
size(0,100);
import solids;
currentlight=Viewport;

draw(O--2X, blue); //x-axis
draw(O--2Y, green); //y-axis
draw(O--2Z, red); //z-axis
```
