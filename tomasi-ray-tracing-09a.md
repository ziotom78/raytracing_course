# *Axis-aligned boxes*

# *Axis-aligned boxes*

-   La forma cubica non è molto interessante di per sè, ma si presta ad alcune ottimizzazioni molto semplici.

-   A causa del suo scopo particolare, tratteremo il caso dei cubi usando convenzioni diverse da quelle fatte per le sfere ed i piani:

    #.   Non ci limiteremo al cubo di lato unitario con vertice nell'origine…
    #.   …ma assumeremo che le facce siano parallele ai piani coordinati.

-   Queste assunzioni sono indicate in letteratura col termine *axis-aligned box* (AAB).

# Rappresentazione in memoria

-   Un parallelepipedo con gli spigoli allineati lungo gli assi $xyz$ può essere definito dalle seguenti quantità:

    #. Il valore minimo e massimo delle $x$;
    #. Il valore minimo e massimo delle $y$;
    #. Il valore minimo e massimo delle $z$.

-   Equivalentemente, si possono memorizzare due vertici opposti del parallelepipedo, $P_m$ (valori minimi di $x$, $y$ e $z$) e $P_M$ (valori massimi).

# Intersezione raggio-AAB

-   Scriviamo il raggio come $r: O + t \vec d$.

-   Il calcolo è molto simile a quello fatto per il piano, se si considera una dimensione alla volta:

    <center>![](./media/aab-ray-intersection.svg)</center>

# Intersezione raggio-AAB

-   Scriviamo con $F_i$ il generico punto del piano perpendicolare alla direzione $i$-esima (sei piani in tutto), che avrà coordinate

    $$
    F_0 = (f_0^{\text{min}/\text{max}}, \cdot, \cdot), \quad F_1 = (\cdot, f_1^{\text{min}/\text{max}}, \cdot), \quad F_2 = (\cdot, \cdot, f_2^{\text{min}/\text{max}}).
    $$

-   Lungo la coordinata $i$-esima si intersecano *due* piani:

    $$
    O + t_i \vec d = F^{\text{min}/\text{max}}_i\quad\Rightarrow\quad t_i^{\text{min}/\text{max}} = \frac{f_i^{\text{min}/\text{max}} - O_i}{d_i}.
    $$

# Intersezione raggio-AAB

-   Ogni direzione produce due intersezioni, quindi in totale si hanno sei potenziali intersezioni (una per ogni faccia del cubo).

-   Ma non tutte le intersezioni sono corrette: esse sono calcolate per l'intero piano infinito su cui giace la faccia del cubo.

-   Occorre quindi verificare per ciascun valore di $t$ se il punto $P$ corrispondente stia effettivamente su una delle facce del cubo.

# Intersezione raggio-AAB

-   Nel caso dell'immagine precedente, in cui il raggio interseca il parallelepipedo, gli intervalli $[t^{(1)}_i, t^{(2)}_i]$ posseggono un tratto in comune tra loro:

<center>![](./media/aab-ray-good-intersection.svg)</center>

-   L'intersezione tra gli intervalli è un intervallo i cui estremi corrispondono ai punti di intersezione del raggio con l'AAB.


# Intersezione raggio-AAB

-   Nel caso in cui il raggio manchi il parallelepipedo, gli intervalli $[t^{(1)}_i, t^{(2)}_i]$ sono disgiunti tra loro:

<center>![](./media/aab-ray-missed-intersection.svg)</center>

-   Se quindi l'intersezione degli intervalli per i tre assi dà l'insieme vuoto, il raggio non colpisce l'AAB.

# Bounding boxes

# Complessità del rendering

-   Settimana scorsa abbiamo implementato il tipo `World`, che contiene una lista di oggetti

-   Quando si calcola una intersezione con un oggetto, `World.ray_intersection` deve iterare su tutte le `Shape` di `World`

-   Se si decuplica il numero di `Shape`, decuplica anche il tempo necessario a produrre un'immagine…

-   …ma già per risolvere l'equazione del rendering in casi semplici possono volerci anche ore!


---

<center>![](./media/pathtracer100.webp)</center>

Questa immagine contiene tre forme geometriche (due piani e una sfera), ed è stata calcolata in ~156 secondi.

---

<iframe src="https://player.vimeo.com/video/517979969?badge=0&amp;autopause=0&amp;player_id=0&amp;app_id=58479" width="1934" height="810" frameborder="0" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen title="Moana (Clements, Musker, Hall, Williams) Beach scene (no sound)"></iframe>

# [*Moana island scene*](https://www.disneyanimation.com/resources/moana-island-scene/)

<center>
![](./media/moana-island-scene.webp)
</center>


# Ottimizzazioni

-   Con la nostra implementazione di `World`, il tempo necessario per il calcolo di un'immagine è all'incirca proporzionale al numero di intersezioni tra raggi e forme.

-   Ma scene realistiche contengono moltissime forme!

-   *Moana island scene* è una scena composta da ~15 miliardi di forme base. Il tempo del rendering sarebbe dell'ordine di 25 000 anni!

-   Esistono però tecniche di ottimizzazione che consentono di ridurre molto il numero di intersezioni da calcolare. Una di queste si basa sugli *axis-aligned bounding boxes*


# *Axis-aligned bounding box*

-   Gli *axis-aligned bounding box* (AABB) sono degli AAB che delimitano il volume occupato da oggetti.

-   Sono molto usati nella *computer graphics* come meccanismo di ottimizzazione.

-   Il principio è il seguente:

    #.  Per ogni forma nello spazio si calcola il suo AABB;
    #.  Quando si deve determinare l'intersezione tra un raggio e una forma, si verifica prima se il raggio interseca l'AABB;
    #.  Se non lo interseca, si passa alla forma successiva, altrimenti si procede al calcolo dell'intersezione.

---

<center>![](./media/bounding-volume.webp){height=540px}</center>

# Utilità degli AABB

-   Gli AABB sono utili solo per scene complesse, formate da molti oggetti non banali. Per scene semplici possono al contrario **rallentare** il rendering.

-   Sono però molto utili con le *mesh* di triangoli e con oggetti CSG complessi.

-   Se voleste supportare gli AABB nel vostro ray-tracer, dovreste aggiungere al tipo `Shape` un membro `aabb` da usare all'interno di `Shape.rayIntersection`:

    ```python
    class MyComplexShape:
        # ...
        def rayIntersection(self, ray: Ray) -> Union[HitRecord, None]:
            inv_ray = ray.transform(self.transformation.inverse())
            if not self.aabb.quickRayIntersection(inv_ray):
                return None

            # etc.
    ```


# Triangoli, quadilateri e *mesh*

# Modellizzazione 3D

<center>![](./media/blender-mesh-modeling.webp)</center>

# Scanner 3D

<center>![](./media/3d-scanners.webp)</center>

# Stanford bunny (1994)

<center>![](./media/stanford-bunny-triangles.png)</center>

(Modello ottenuto dalla scansione di una statuetta di ceramica)

# Triangoli

I triangoli sono una forma geometrica molto usata nei programmi di modellizzazione e rendering 3D, per le molte loro proprietà:

#. Sono la superficie piana con il minor numero di vertici (→ efficienti da memorizzare).
#. La loro rappresentazione nello spazio è univoca (per tre punti passa uno e un solo triangolo planare).
#. La loro superficie è parametrizzabile in coordinate $(u, v)$ in forma molto semplice.
#. Superfici complesse possono essere rappresentate come unione di più triangoli.


# Coordinate baricentriche

-   Le coordinate baricentriche sono state proposte da Möbius nel 1827, ed esprimono i punti di un piano passante per i punti $A, B, C$ mediante l'espressione

    $$
    P(\alpha, \beta, \gamma) = \alpha A + \beta B + \gamma C,
    $$

    dove $\alpha, \beta, \gamma \in \mathbb{R}$ sono le *coordinate baricentriche*.

-   Le coordinate baricentriche risultano molto utili per caratterizzare il triangolo di vertici $A, B, C$: il punto $P$ è interno al triangolo se e solo se

    $$
    0 \le \alpha \le 1,\quad 0 \le \beta \le 1,\quad 0 \le \gamma \le 1, \quad \alpha + \beta + \gamma = 1.
    $$

# Coordinate nei triangoli

-   La condizione $\alpha + \beta + \gamma = 1$ fa sì che i punti di un triangolo siano caratterizzati da due gradi di libertà, come dev'essere per una superficie bidimensionale.

-   L'uguaglianza nelle prime tre disequazioni vale per i punti lungo il bordo del triangolo.

-   Usando l'ultima uguaglianza, si ottiene una forma più significativa:

    $$
    P(\beta, \gamma) = A + \beta(B - A) + \gamma(C - A) = A + \beta \vec v_{AB} + \gamma \vec v_{AC},
    $$

    che esprime $P$ come $A$ più uno spostamento verso $B$ e uno verso $C$.

---

<center>![](./media/triangle-coordinates.svg){height=640px}</center>

# Coordinate nei triangoli

-   Si può dimostrare che le coordinate baricentriche di un punto $P$ sono legate all'area $\sigma$ del triangolo e alle aree dei tre sotto-triangoli aventi come vertice il punto $P$ e due dei vertici:

    $$
    \alpha = \frac{\sigma_1}\sigma = 1 - \frac{\sigma_2 + \sigma_3}\sigma, \quad \beta = \frac{\sigma_2}\sigma, \quad \gamma = \frac{\sigma_3}\sigma.
    $$

-   Se si assegna segno negativo alle aree che sono fuori dal triangolo, queste equazioni valgono per qualsiasi punto sul piano in cui giace il triangolo.

# Esempio interattivo { data-state="barycentric-coordinates-demo" }

<center>
    <canvas
        id="barycentric-coordinates-canvas"
        width="620px"
        height="480px"
        style="left:0px;top:0px;cursor:crosshair;border:1px solid black;"/>
</center>

<script type="text/javascript" src="./js/barycentric-coordinates.js"></script>

# Quadrilateri

-   Noi oggi ci concentreremo sui triangoli, ma i programmi di rendering offrono anche la possibilità di definire *quadrilateri*.

-   Se ci si limita ai parallelogrammi, si possono rappresentare come l'unione di un vertice $P$ e due vettori $\vec v$ e $\vec w$; in questo modo, i risultati che mostreremo oggi sono facilmente estendibili anche ad essi:

    <center>
    ![](media/parallelogram.svg)
    </center>

# Intersezione con raggi

-   Vediamo ora come usare le coordinate baricentriche per calcolare efficientemente l'intersezione tra un triangolo e un raggio.

-   A differenza di quanto fatto con le sfere e i piani, in questo caso non adotteremo un sistema di riferimento semplificato. Il motivo sarà chiaro quando spiegheremo le *mesh* di triangoli.

-   Identificheremo quindi un triangolo tramite le coordinate dei tre punti $A, B, C$ (nove valori floating-point).

# Il problema analitico

-   Consideriamo il raggio $r(t): O + t \vec d$ e il punto generico $P(\beta, \gamma)$ del triangolo. L'intersezione è data da

    $$
    A + \beta (B - A) + \gamma (C - A) = O + t \vec d,
    $$

    con il vincolo $0 \leq (\beta, \gamma) \leq 1$.

-   Riordiniamo l'equazione in modo da spostare le tre incognite $\beta$, $\gamma$ e $t$ sulla sinistra:

    $$
    \beta (B - A) + \gamma (C - A) - t \vec d = O - A.
    $$


# Forma matriciale

-   L'equazione che abbiamo ottenuto è

    $$
    \beta (B - A) + \gamma (C - A) - t \vec d = O - A,
    $$

    che è un'equazione vettoriale nelle tre componenti $x, y, z$.

-   In forma matriciale, il sistema si riscrive così:

    $$
    \begin{pmatrix}
    b_x - a_x& c_x - a_x& d_x\\
    b_y - a_y& c_y - a_y& d_y\\
    b_z - a_z& c_z - a_z& d_z\\
    \end{pmatrix}
    \begin{pmatrix}
    \beta\\\gamma\\t
    \end{pmatrix}
    =
    \begin{pmatrix}
    o_x - a_x\\o_y - a_y\\o_z - a_z
    \end{pmatrix}.
    $$

# Soluzione analitica

-   La soluzione dipende dal determinante della matrice M:

    $$
    \det M = \det
    \begin{pmatrix}
    b_x - a_x& c_x - a_x& d_x\\
    b_y - a_y& c_y - a_y& d_y\\
    b_z - a_z& c_z - a_z& d_z\\
    \end{pmatrix},
    $$

    che deve essere diverso da zero, altrimenti il raggio è parallelo al piano del triangolo.

-   La soluzione si ottiene facilmente con la [regola di Cramer](https://en.wikipedia.org/wiki/Cramer%27s_rule), che è inefficiente nel caso generale ma adeguata per matrici 3×3 come è il caso qui.

# Soluzione analitica

-   Ovviamente, una volta ottenuta la soluzione è necessario verificare che

    $$
    t_\text{min} < t < t_\text{max}, \quad 0 \leq \beta \leq 1, \quad 0 \leq \gamma \leq 1.
    $$

-   La normale del triangolo si può ottenere facilmente dal prodotto vettoriale tra i due vettori allineati con i lati:

    $$
    \hat n = \pm (B - A) \times (C - A),
    $$

    dove il segno è determinato dalla direzione del raggio.

-   Le coordinate $(u, v)$ possono essere poste uguali a $(\beta, \gamma)$.


# *Mesh*

# [*Moana island scene*](https://www.disneyanimation.com/resources/moana-island-scene/)

<center>
![](./media/moana-island-scene.webp)
</center>

# [*Moana island scene*](https://www.disneyanimation.com/resources/moana-island-scene/)

<center>
![](./media/moana-island-scene-website.png)
</center>

---

<center>
![](./media/moana-ironwood-tree.png){height=640px}
</center>

<small>
[The challenges of Releasing the *Moana* Island Scene (Tamstorf & Pritchett, EGSR 2019)](https://disneyanimation.com/publications/the-challenges-of-releasing-the-moana-island-scene/)
</small>

# *Mesh*

-   Le scene viste nelle slide precedenti sono formate dalla combinazione di molte forme semplici.

-   Mantenere in memoria una lista di forme semplici richiede una serie di accorgimenti non banali.

-   Oggi discuteremo delle *mesh*, in cui la forma elementare è appunto un triangolo planare. (Identico discorso si può fare per le *mesh* di quadrilateri, ma noi ci concentreremo per semplicità sui triangoli).

# Memorizzare triangoli

-   Abbiamo visto come implementare il codice per calcolare l'intersezione tra raggio e triangolo nel caso generale in cui il triangolo sia codificato tramite i suoi tre vertici $A$, $B$ e $C$.

-   Non abbiamo seguito l'approccio usato per sfere e piani di scegliere una forma «standard» (es., un triangolo sul piano $xy$), perché questo avrebbe richiesto di memorizzare una trasformazione 4×4 e la sua inversa, per un totale di 32 numeri floating-point (128 bytes a precisione singola).

-   Memorizzare le tre coordinate di un triangolo richiede solo 3×3×4 = 36 byte…

-   …ma si può fare di meglio!

---

<center>![](./media/stanford-bunny-triangles.png)</center>

# Memorizzazione di *mesh*

-   In una *mesh* di triangoli si memorizzano i vertici in una lista ordinata $P_k$, con $k = 1\ldots N$.

-   I triangoli sono rappresentati da una terna di indici interi $i_1, i_2, i_3$ che rappresenta la posizione dei vertici $P_{i_1}, P_{i_2}, P_{i_3}$ nella lista ordinata.

-   Se si usano numeri interi a 32 bit per memorizzare gli indici, ogni triangolo richiede 3×4 = 12 bytes.

-   Questo è vantaggioso se un vertice è condiviso da più triangoli, che è il caso generale.

---

<iframe src="https://player.vimeo.com/video/546494716?badge=0&amp;autopause=0&amp;player_id=0&amp;app_id=58479" width="1102" height="620" frameborder="0" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen title="Wireframe models in Blender"></iframe>

Modello: 44.000 vertici, 80.000 triangoli.

# Normali

<p style="text-align:center">![](media/triangle-normals.png){height=240px}</p>

-   Un triangolo è una superficie piana, ed ogni punto della sua superficie possiede quindi la medesima normale $\hat n$.

-   Nel caso di *mesh* di triangoli, si possono usare le coordinate baricentriche del triangolo per simulare una superficie liscia: ciò è utile soprattutto quando la *mesh* è ottenuta dalla discretizzazione di una superficie liscia.

# Smooth shading

<p style="text-align:center">![](media/triangle-normals.png){height=240px}</p>

-   Nel momento in cui si approssima una superficie liscia occorre calcolare sia i vertici dei triangoli che le normali sui vertici.

-   In corrispondenza del punto $P$ definito da $\alpha, \beta, \gamma$ si assegna la normale

    $$
    \hat n_P = \alpha \hat n_1 + \beta \hat n_2 + \gamma \hat n_3.
    $$

---

<iframe src="https://player.vimeo.com/video/546515481?badge=0&amp;autopause=0&amp;player_id=0&amp;app_id=58479" width="1138" height="640" frameborder="0" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen title="Flat and smooth shading in Blender"></iframe>

# Coordinate $(u, v)$

-   Nel caso di una *mesh* ci sono infiniti modi possibili per creare una mappatura $(u, v)$ sulla superficie.

-   Nelle *mesh* si fa in modo che ogni elemento della *mesh* copra una porzione specifica dell'intero spazio $[0, 1] \times [0, 1]$.

-   Programmi di modellizzazione 3D come Blender permettono di modificare la mappatura $(u, v)$ di ogni elemento.

---

<center>![](./media/blender-uv-mapping.webp)</center>

# [Wavefront OBJ](https://en.wikipedia.org/wiki/Wavefront_.obj_file)

-   È un formato molto semplice da caricare e utilizzato per memorizzare mesh (non solo di triangoli).

-   Esempio (inizio del modello `minicooper.obj`):

    ```text
    # Vertexes
    v  20.851225 -39.649834 32.571609
    v  20.720263 -39.659435 32.675613
    v  20.589304 -39.649834 32.571609
    …
    # Normals
    vn  -0.000006 38.811405 3.583478
    vn  -0.000006 38.811405 3.583478
    vn  -0.000006 38.811405 3.583478
    …
    # Triangles («faces»)
    f 3//3 2//2 1//1
    f 4//4 3//3 1//1
    f 5//5 4//4 1//1
    ```

# File OBJ

-   Il modo più comodo di visualizzarli è usare [Blender](https://www.blender.org/), ovviamente! Sotto Linux potete anche impiegare `openctm-tools`, che è più agile (il comando `ctmviewer NOMEFILE` visualizza un file OBJ in una finestra interattiva).

-   Il sito di [J. Burkardt](https://people.sc.fsu.edu/~jburkardt/data/obj/obj.html) contiene molti file OBJ scaricabili liberamente (ho preso da lì il modello della Mini Cooper).

# Intersezione con raggi

-   Il calcolo dell'intersezione tra una *mesh* e un raggio non è semplice da implementare.

-   Il problema è che gran parte del tempo richiesto per calcolare la soluzione dell'equazione del rendering viene speso per l'intersezione tra raggi e forme.

-   All'aumentare delle forme aumenta necessariamente anche il tempo di calcolo.

# AABB e *mesh*

-   Gli AABB sono perfetti per essere applicati a *mesh*. (In questo caso non si applicano ovviamente ai **singoli** elementi, ma alla *mesh* nel suo complesso).

-   Al momento del caricamento di una *mesh*, si può calcolare il suo AABB calcolando il valore minimo e il valore massimo delle coordinate di tutti i vertici.

-   Nel caso dell'albero di *Oceania*, l'intersezione tra un raggio e i 18 milioni di elementi avverebbe solo per quei raggi effettivamente orientati verso quell'albero.

---

<center>![](./media/bounding-volume.webp){height=540px}</center>

# Oltre le AABB

-   Non è però sempre sufficiente usare gli AABB per le *mesh* perché queste siano efficienti.

-   Sovente le scene sono occupate quasi completamente da un oggetto complesso, e in questo caso gli AABB non portano alcun vantaggio (è il caso dell'immagine precedente).

-   È però possibile basarsi sull'idea degli AABB per implementare ottimizzazioni più sofisticate: quelle più usate impiegano i [KD-tree](https://en.wikipedia.org/wiki/K-d_tree) e i [BVH](https://en.wikipedia.org/wiki/Bounding_volume_hierarchy). Vedere il [libro di Pharr, Jakob & Humphreys](https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration).


# Debugging

---

<iframe width="1008" height="566" src="https://www.youtube.com/embed/4gNYTqn3qRc" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

# Introduzione al debugging

-   Settimana scorsa avete corretto il vostro primo bug, che riguardava l'errato orientamento delle immagini salvate dal vostro codice.

-   In generale un *bug* è un problema nel programma che lo fa funzionare in modo diverso da quello che ci si aspetta.

-   È molto importante avere un approccio scientifico alla gestione dei bug! Nelle prossime slide vi darò alcune indicazioni generali.


# Difetto, infezione e fallimento

-   Il bellissimo libro di Zeller [*Why programs fail: a guide to systematic debugging*](https://www.whyprogramsfail.com/) spiega la scoperta di un *bug* come la combinazione di tre fattori:

    1. **Difetto**: un errore nel modo in cui è scritto il codice;
    2. **Infezione**: un certo input “attiva” il difetto ed altera il valore di alcune variabili rispetto al caso atteso;
    3. **Fallimento**: l'esito del programma è sbagliato, o perché i risultati sono errati, o perché il programma va in crash.

-   Il *bug* sta nel difetto iniziale, ma se non c'è infezione o non c'è fallimento è difficile accorgersene!


# Un esempio da TNDS

-   Nel corso di TNDS si deve implementare un codice che calcoli il valore di

    \[
    \int_0^\pi \sin x\,\mathrm{d}x
    \]

    usando la formula di Simpson:

    \[
    \int_a^b f(x)\,\mathrm{d}x \approx \frac{h}3 \left[f(a) + 4\sum_{i=1}^{n/2} f\bigl(x_{2i-1}\bigr) + 2\sum_{i=1}^{n/2 - 1} f\bigl(x_{2i}\bigr) + f(b)\right].
    \]

-   Spesso l'implementazione è errata nonostante il risultato sia corretto ($\int = 2$)!


---

\[
\int_a^b f(x)\,\mathrm{d}x \approx \frac{h}3 \left[f(a)+ {\color{red}{4}}\sum_{i=1}^{n/2} f\bigl(x_{2i-1}\bigr) + {\color{red}{2}}\sum_{i=1}^{n/2 - 1} f\bigl(x_{2i}\bigr) + f(b)\right].
\]

-   Spesso gli studenti scambiano il 4 con il 2.

-   Questo porta a una *infezione*: il valore dell'espressione tra parentesi quadre è sbagliato.

-   Ciò porta a un *fallimento*: il risultato dell'integrale è sbagliato.

-   Di tutti i casi, questo è il più semplice: è immediato accorgersi del problema!

---

\[
\int_a^b f(x)\,\mathrm{d}x \approx \frac{h}3 \left[f(a)+ 4\sum_{i=1}^{\color{red}{n/2}} f\bigl(x_{2i-1}\bigr) + 2\sum_{i=1}^{\color{red}{n/2 - 1}} f\bigl(x_{2i}\bigr) + f(b)\right].
\]

-   A volte gli studenti terminano una delle due sommatorie troppo presto (dimenticano l'ultimo termine) oppure troppo tardi (aggiungono un termine in più).

-   Nel caso di $\int_0^\pi \sin x\,\mathrm{d}x$, l'ultimo termine della sommatoria è per $x \approx \pi$, quindi è molto piccolo: c'è una *infezione*, ma se si stampano poche cifre significative a video può essere che il risultato sia arrotondato al valore giusto, e non ci sia quindi un *fallimento*.

---


\[
\int_a^b f(x)\,\mathrm{d}x \approx \frac{h}3 \left[{\color{red}{f(a)}}+ 4\sum_{i=1}^{n/2} f\bigl(x_{2i-1}\bigr) + 2\sum_{i=1}^{n/2 - 1} f\bigl(x_{2i}\bigr) + {\color{red}{f(b)}}\right].
\]

-   A volte gli studenti dimenticano di sommare $f(a)$ e/o $f(b)$, o li moltiplicano per 2 o per 4.

-   Nel caso però di $\int_0^\pi \sin x\,\mathrm{d}x$, il valore dell'espressione tra parentesi quadre è comunque giusto perché $f(0) = f(\pi) = 0$.

-   In questo caso c'è un *difetto* ma non c'è una *infezione* né un *fallimento*: è il caso più difficile da individuare!


# *Issue* duplicate

-   È molto comune che un medesimo *difetto* porti a *fallimenti* diversi: ciò dipende infatti dai dati di input, dal tipo di azione che si esegue col programma, etc.

-   È quindi molto comune che gli utenti aprano *issue* diverse che però sono causate dal medesimo *difetto*.

-   Esempio: [un crash in Julia](https://github.com/JuliaLang/julia/issues/48332) è causato dalla combinazione di due issue già segnalate in precedenza, che però a prima vista non sembravano correlate.

-   GitHub consente di assegnare l'etichetta *Duplicated* alle *issue*: <img style="vertical-align:middle" src="media/github-duplicate.png"/>


# Come segnalare *issue*

-   Quando si osserva un *fallimento* e si vuole aprire una *issue*, bisogna indicare:

    1.   Lista di azioni che hanno portato al fallimento (inclusi tutti gli input!)
    2.   Output del programma
    3.   Descrizione del comportamento atteso e di quello invece osservato

    Questo perché lo sviluppatore deve poter **riprodurre** il *fallimento* per individuare poi il *difetto* che l'ha causato.

-   Se un utente vi segnala una issue senza che alcune di queste cose siano chiare, non fatevi scrupoli a chiedere maggiori dettagli.

-   GitHub consente di configurare un [modello per le *issue*](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/configuring-issue-templates-for-your-repository).

# Individuare *difetti* scientificamente (Zeller)

1.   Osservare/riprodurre un *fallimento*
2.   Formulare un'ipotesi sul *difetto* che ha causato il *fallimento*
3.   Usare l'ipotesi per fare una predizione
4.   Verificare l'ipotesi con esperimenti e ulteriori osservazioni:
     -   Se l'ipotesi è confermata, raffinare la predizione
     -   Se l'ipotesi è invalidata, cercarne una alternativa
5.   Ripetere i passi 3 e 4 finché l'ipotesi non può più essere migliorata

---
title: "Lezione 9"
subtitle: "Forme avanzate, debugging"
author: "Maurizio Tomasi <maurizio.tomasi@unimi.it>"
...
