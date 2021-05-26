---
title: "Esercitazione 12"
subtitle: "Path tracing (continua)"
author: "Maurizio Tomasi <maurizio.tomasi@unimi.it>"
...

# Basi ortonormali (ONB)

# Creazioni di ONB

-   È conveniente usare l'algoritmo di [Duff et al. 2017](https://graphics.pixar.com/library/OrthonormalB/paper.pdf):

    ```python
    def create_onb_from_z(normal: Union[Vec, Normal]) -> Tuple[Vec, Vec, Vec]:
        sign = 1.0 if (normal.z > 0.0) else -1.0
        a = -1.0 / (sign + normal.z)
        b = normal.x * normal.y * a

        e1 = Vec(1.0 + sign * normal.x * normal.x * a, sign * b, -sign * normal.x)
        e2 = Vec(b, sign + normal.y * normal.y * a, -normal.y)

        return e1, e2, Vec(normal.x, normal.y, normal.z)
    
    ```
    
-   Quando invocate questa funzione, fate molta attenzione al fatto che il parametro `normal` deve essere già normalizzato!

# Test

-   Per verificare il funzionamento di `create_onb_from_z`, possiamo usare il *random testing* (un'idea apparentemente nata nel mondo del linguaggio [Haskell](https://www.haskell.org/), vedi [quickcheck](https://hackage.haskell.org/package/QuickCheck)).

-   L'idea è quella di generare un gran numero di vettori casuali, passarli come parametri a `create_onb_from_z`, e verificare che il tipo di ritorno sia effettivamente una ONB. (Pare che Duff et al. abbiano scoperto così il bug nell'algoritmo di [Frisvad, 2012](http://orbit.dtu.dk/files/
126824972/onb_frisvad_jgt2012_v2.pdf)).

-   L'approccio generale del *random testing* è quello di generare input casuali, e verificare che gli output soddisfino certe proprietà. È conveniente soprattutto per funzioni matematiche, ma non è sempre la soluzione migliore.

---

# *Random testing* in [pytracer](https://github.com/ziotom78/pytracer/blob/01a672c782515030dd5abc9a33d1e0c843bbd394/test_all.py#L914-L934)

```python
pcg = PCG()

expected_zero = pytest.approx(0.0)
expected_one = pytest.approx(1.0)

# As Python is slow, we just test 100 times the function. You can use
# larger numbers, as far as the time required to run the test is kept short
for i in range(100):
    normal = Vec(pcg.random_float(), pcg.random_float(), pcg.random_float())
    normal.normalize()
    e1, e2, e3 = create_onb_from_z(normal)

    # Verify that the z axis is aligned with the normal
    assert e3.is_close(normal)

    # Verify that the base is orthogonal
    assert expected_zero == e1.dot(e2)
    assert expected_zero == e2.dot(e3)
    assert expected_zero == e3.dot(e1)

    # Verify that each component is normalized
    assert expected_one == e1.squared_norm()
    assert expected_one == e2.squared_norm()
    assert expected_one == e3.squared_norm()
```

# *Importance sampling*

# Implementazione

-   Nella lezione di teoria abbiamo anticipato che il nostro *path tracer* userà il metodo Monte Carlo per stimare l'integrale dell'equazione del rendering:

    $$
    \int_{2\pi} f_r(x, \Psi \rightarrow \Theta)\,L(x \leftarrow \Psi)\,\cos\theta\,\mathrm{d}\omega_\Psi.
    $$
    
-   Per migliorare la varianza useremo l'*importance sampling*, impiegando la PDF

    $$
    p(\omega) \propto f_r \times \cos\theta.
    $$
    
# Il tipo `BRDF`

-   Dobbiamo quindi aggiungere un metodo che si applichi ai tipi derivati da `BRDF` e che abbia [questa segnatura](https://github.com/ziotom78/pytracer/blob/01a672c782515030dd5abc9a33d1e0c843bbd394/materials.py#L103):

    ```python
    def scatter_ray(self, 
        pcg: PCG,                    # Used to generate random numbers
        incoming_dir: Vec,           # Direction of the incoming ray
        interaction_point: Point,    # Where the ray hit the surface
        normal: Normal,              # Normal on interaction_point
        depth: int,                  # Depth value for the new ray
    ) -> Ray
    ```

-   Ogni tipo derivato da `BRDF` (es., `DiffuseBRDF`, `SpecularBRDF`, etc.) dovrà ridefinire `scatter_ray`.

# `DiffuseBRDF`

-   Per la BRDF diffusa, abbiamo dimostrato che $p(\omega) \propto \cos\theta$.

-   L'implementazione di [`DiffuseBRDF.scatter_ray`](https://github.com/ziotom78/pytracer/blob/01a672c782515030dd5abc9a33d1e0c843bbd394/materials.py#L117-L130) deve quindi usare l'[algoritmo che abbiamo ricavato](tomasi-ray-tracing-11a-path-tracing.html#risultato-di-phong) per la distribuzione di Phong con $n = 1$:

    ```python
    def scatter_ray(self, pcg: PCG, incoming_dir: Vec,
                    interaction_point: Point, normal: Normal, depth: int) -> Ray:
        e1, e2, e3 = create_onb_from_z(normal)
        cos_theta_sq = pcg.random_float()
        cos_theta, sin_theta = sqrt(cos_theta_sq), sqrt(1.0 - cos_theta_sq)
        phi = 2.0 * pi * pcg.random_float()

        return Ray(origin=interaction_point,
                   dir=e1 * cos(phi) * cos_theta + e2 * sin(phi) * cos_theta + e3 * sin_theta,
                   tmin=1.0e-3,   # Be generous here
                   tmax=inf,
                   depth=depth)
    ```

# `SpecularBRDF`

-   La generazione di raggi per la BRDF speculare è perfettamente deterministica, e non c'è un termine $\cos\theta$ con cui pesare il contributo del raggio.

-   L'implementazione di [`SpecularBRDF.scatter_ray`](https://github.com/ziotom78/pytracer/blob/01a672c782515030dd5abc9a33d1e0c843bbd394/materials.py#L151-L164) è quindi particolarmente semplice:

    ```python
    def scatter_ray(self, pcg: PCG, incoming_dir: Vec,
                    interaction_point: Point, normal: Normal, depth: int) -> Ray:
        ray_dir = Vec(incoming_dir.x, incoming_dir.y, incoming_dir.z).normalize()
        normal = normal.to_vec().normalize()

        return Ray(origin=interaction_point,
                   dir=ray_dir - normal * 2 * normal.dot(ray_dir),
                   tmin=1e-3,
                   tmax=inf,
                   depth=depth)
    ```

# *Path tracing*

# Il tipo `PathTracer`

-   Abbiamo finora definito due renderer: `OnOffRenderer` e `FlatRenderer`. Oggi implementiamo `PathTracer`.

-   I parametri del costruttore sono i seguenti:

    #.  L'oggetto `World` per cui fare il render;
    #.  Il colore di background, usato per quelle direzioni lungo cui non ci sono intersezioni;
    #.  Il generatore di numeri casuali da usare (tipo `PCG`);
    #.  Numero di raggi da generare per il calcolo dell'integrale;
    #.  Profondità massima dei raggi;
    #.  Limite per la profondità oltre il quale usare la Roulette russa.

# [Implementazione](https://github.com/ziotom78/pytracer/blob/01a672c782515030dd5abc9a33d1e0c843bbd394/render.py#L73-L126)

```python
def __call__(self, ray: Ray) -> Color:
    if ray.depth > self.max_depth:
        return Color(0.0, 0.0, 0.0)

    hit_record = self.world.ray_intersection(ray)
    if not hit_record:
        return self.background_color

    hit_material = hit_record.material
    hit_color = hit_material.brdf.pigment.get_color(hit_record.surface_point)
    emitted_radiance = hit_material.emitted_radiance.get_color(hit_record.surface_point)

    hit_color_lum = max(hit_color.r, hit_color.g, hit_color.b)

    # Russian roulette
    if ray.depth >= self.russian_roulette_limit:
        if self.pcg.random_float() > hit_color_lum:
            # Keep the recursion going, but compensate for other potentially discarded rays
            hit_color *= 1.0 / (1.0 - hit_color_lum)
        else:
            # Terminate prematurely
            return emitted_radiance

    # Monte Carlo integration
    
    cum_radiance = Color(0.0, 0.0, 0.0)
    
    # Only do costly recursions if it's worth it
    if hit_color_lum > 0.0:
        for ray_index in range(self.num_of_rays):
            new_ray = hit_material.brdf.scatter_ray(
                pcg=self.pcg,
                incoming_dir=hit_record.ray.dir,
                interaction_point=hit_record.world_point,
                normal=hit_record.normal,
                depth=ray.depth + 1,
            )
            # Recursive call
            new_radiance = self(new_ray)
            cum_radiance += hit_color * new_radiance

    return emitted_radiance + cum_radiance * (1.0 / self.num_of_rays)
```

# Test

-   Un metodo molto semplice per verificare il funzionamento di un *path tracer* è il cosiddetto *test della fornace*.

-   Si tratta di lanciare un raggio all'interno di un oggetto di forma arbitraria e BRDF diffusa con luminosità $L_e$ e riflettanza $\rho_d$ costanti.

-   Il generico raggio percorrerà un cammino intrappolato nell'oggetto, e la radianza totale sarà uguale a

    $$
    L = L_e + \rho_d \Bigl(L_e + \rho_d \bigl(L_e + \rho_d(L_e + \dots)\bigr)\Bigr).
    $$
    
---

<center>![](media/furnace-test.svg)</center>

---


$$
\begin{aligned}
L &= L_e + \rho_d \Bigl(L_e + \rho_d \bigl(L_e + \rho_d(L_e + \dots)\bigr)\Bigr) =\\
  &= L_e + \rho_d L_e + \rho_d^2 L_e + \rho_d^3 L_e + \ldots =\\
  &= L_e \bigl(1 + \rho_d + \rho_d^2 + \rho_d^3 + \ldots \bigr) =\\
  &= L_e \sum_{n=0}^\infty \rho_d^n =\\
  &= \frac{L_e}{1 - \rho_d}.
\end{aligned}
$$

# Test in pytracer

-   Il codice di pytracer implementa il test [`testFurnace`](https://github.com/ziotom78/pytracer/blob/01a672c782515030dd5abc9a33d1e0c843bbd394/test_all.py#L938-L962) che usa queste assunzioni:

    #.  Crea una sfera centrata nell'origine;
    #.  Lancia un raggio che parta dal centro della sfera;
    #.  Invoca `PathTracer` fissando `max_depth=100` e assicurandosi che *non* venga usato l'algoritmo della roulette russa;
    #.  Verifica che la radianza restituita corrisponda a $L_e / (1 - \rho_d)$.
    
-   Il test viene ripetuto un certo numero di volte usando valori casuali di $L_e$ e di $\rho_d$. (Rischioso se si esegue molte volte, perché $\rho_d$ potrebbe diventare arbitrariamente vicino a 1, e `max_depth=100` potrebbe non bastare più!).

---

```python
pcg = PCG()

# Run the furnace test several times using random values for
# the emitted radiance and reflectance
for i in range(5):
    emitted_radiance = pcg.random_float()
    reflectance = pcg.random_float()

    world = World()

    enclosure_material = Material(
        brdf=DiffuseBRDF(pigment=UniformPigment(Color(1.0, 1.0, 1.0) * reflectance)),
        emitted_radiance=UniformPigment(Color(1.0, 1.0, 1.0) * emitted_radiance),
    )

    world.add(Sphere(material=enclosure_material))

    path_tracer = PathTracer(
        pcg=pcg, 
        num_of_rays=1, 
        world=world, 
        max_depth=100, 
        russian_roulette_limit=101,
    )

    ray = Ray(origin=Point(0, 0, 0), dir=Vec(1, 0, 0))
    color = path_tracer(ray)

    expected = emitted_radiance / (1.0 - reflectance)
    assert pytest.approx(expected, 1e-3) == color.r
    assert pytest.approx(expected, 1e-3) == color.g
    assert pytest.approx(expected, 1e-3) == color.b
```

# Il metodo `main`

-   Ora che abbiamo un *path tracer*, è bene modificare il nostro comando `demo` in modo che crei un'immagine che metta meglio in luce il funzionamento dell'algoritmo.

-   Potete sbizzarrirvi a definire la scena che preferite, usando le forme che avete implementato nel vostro codice (sfere, piani, triangoli, CSG, etc.).

-   La cosa importante è che definiate una grande superficie diffusiva (un piano o una sfera di raggio grande), che funga da sorgente luminosa e che abbia quindi una componente $L_e$ non trascurabile.

-   In [pytracer](https://github.com/ziotom78/pytracer/blob/01a672c782515030dd5abc9a33d1e0c843bbd394/main.py#L116-L150) ho definito un piano per il suolo, una sfera per il cielo, e due sfere in primo piano: la prima ha una BRDF diffusiva, la seconda una BRDF riflessiva.

---

<center>![](media/pytracer-demo-pathtracing.webp)</center>


# Numeri casuali

-   Fate in modo che si possano passare i due numeri che inizializzano il generatore `PCG` da linea di comando.

-   Il numero che interessa di più è `init_seq`, perché identifica univocamente la sequenza di numeri generati dal `PCG`, e consente quindi di produrre immagini completamente decorrelate (che possono quindi essere mediate tra loro senza produrre *bias*).

-   Mediare immagini diverse (prodotte contemporaneamente mediante [GNU Parallel](https://www.gnu.org/software/parallel/)) è un buon modo per ridurre la varianza senza aumentare il tempo di calcolo effettivo (*wall-clock time*).


# Link a Gather

Useremo il solito link: [gather.town/app/CgOtJvyNfVKMIQ9e/LaboratorioRayTracing](https://gather.town/app/CgOtJvyNfVKMIQ9e/LaboratorioRayTracing)


# Guida per l'esercitazione


# Cose da fare

#.  Continuate il lavoro nel branch `pathtracing`;
#.  Implementate una funzione per creare una base ortonormale partendo da un vettore normale (se nel vostro linguaggio non è semplice restituire tre valori di ritorno, implementate un nuovo tipo `ONB`);
#.  Implementate il metodo `scatter_ray` che funzioni sui tipi BRDF, e implementate la BRDF speculare;
#.  Implementate l'algoritmo di path tracing;
#.  Modificate il demo in modo che abbia un cielo diffusivo in grado di illuminare la scena.
#.  Fatto il *merging*, incrementate il numero di versione a `0.3.0` e aggiornate il file `CHANGELOG.md`.

# Aggiunte opzionali

-   [Antialiasing](tomasi-ray-tracing-12a-path-tracing2.html#aliasing) (vedi la [PR#13 di pytracer](https://github.com/ziotom78/pytracer/pull/13));
-   [Point-light tracing](tomasi-ray-tracing-12a-path-tracing2.html#point-light-tracing-1) (vedi la [PR#14 di pytracer](https://github.com/ziotom78/pytracer/pull/14)).
