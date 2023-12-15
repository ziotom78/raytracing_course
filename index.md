---
title: "Numerical tecniques for photorealistic image generation"
author: "Maurizio Tomasi <maurizio.tomasi@unimi.it>"
...


# Scelta del linguaggio

-   [A comparison between a few programming languages](language-comparison.html)
-   [Giudizi degli studenti sui linguaggi usati negli anni passati](giudizi-linguaggio.html)

<!--
# Lezioni

| Settimana | Slides teoria                                   | Slides esercitazioni                            |
|----------:|:-----------------------------------------------:|:-----------------------------------------------:|
|         1 | [27 Febbraio 2023](tomasi-ray-tracing-01a.html) | [29 Febbraio 2023](tomasi-ray-tracing-01b.html) |
|         2 | [6 Marzo 2023](tomasi-ray-tracing-02a.html)     | [8 Marzo 2023](tomasi-ray-tracing-02b.html)     |
|         3 | [13 Marzo 2023](tomasi-ray-tracing-03a.html)    | [15 Marzo 2023](tomasi-ray-tracing-03b.html)    |
|         4 | [20 Marzo 2023](tomasi-ray-tracing-04a.html)    | [22 Marzo 2023](tomasi-ray-tracing-04b.html)    |
|         5 | [27 Marzo 2023](tomasi-ray-tracing-05a.html) | [29 Marzo 2023](tomasi-ray-tracing-05b.html) |
|         6 | [3 Aprile 2023](tomasi-ray-tracing-06a.html) | [5 Aprile 2023](tomasi-ray-tracing-06b.html) |
|         7 | [17 Aprile 2023](tomasi-ray-tracing-07a.html) | [19 Aprile 2023](tomasi-ray-tracing-07b.html) |
|         8 | [26 Aprile 2023](tomasi-ray-tracing-08a.html) | [3 Maggio 2023](tomasi-ray-tracing-08b.html) |
|         9 | [8 Maggio 2023](tomasi-ray-tracing-09a.html) | — |
|        10 | [15 Maggio 2023](tomasi-ray-tracing-10a.html) | [17 Maggio 2023](tomasi-ray-tracing-10b.html) |
|        11 | [22 Maggio 2023](tomasi-ray-tracing-11a.html) | [24 Maggio 2023](tomasi-ray-tracing-11b.html) |
|        12 | [29 Maggio 2023](tomasi-ray-tracing-12a.html) | [31 Maggio 2023](tomasi-ray-tracing-12b.html) |
|        13 | [5 Giugno 2023](tomasi-ray-tracing-13a.html) | [7 Giugno 2023](tomasi-ray-tracing-13b.html) |
-->

# Argomenti per l'esame (A.A. 2023/2024)

## Parti richieste per l'esame

<!--
-   [Elementi di radiometria](tomasi-ray-tracing-01a.html#/radiometria): energia emessa, flusso, irradianza/emettenza
-   [Radianza e sue proprietà](tomasi-ray-tracing-01a.html#/radianza)
-   [Emettitori diffusi ideali](tomasi-ray-tracing-01a.html#/esempio)
-   [BRDF](tomasi-ray-tracing-01a.html#/la-brdf)
-   [Equazione del rendering](tomasi-ray-tracing-01a.html#/lequazione-del-rendering)
-   [Sistemi di controllo delle versioni](tomasi-ray-tracing-01b.html#/sistemi-di-controllo-delle-versioni)
-   [Git](tomasi-ray-tracing-01b.html#git)
-   [GitHub](tomasi-ray-tracing-01b.html#github)
-   [Codifica del colore](tomasi-ray-tracing-02a.html#/codifica-del-colore)
-   [Relazione tra radianza spettrale e colori RGB](tomasi-ray-tracing-02a.html#/da-l_lambda-a-rgb)
-   [Visualizzazione su dispositivi](tomasi-ray-tracing-02a.html#/visualizzazione-su-dispositivi)
-   [Comportamento dei monitor](tomasi-ray-tracing-02a.html#/comportamento-dei-monitor)
-   [Gestione dei colori](tomasi-ray-tracing-02b.html#/gestione-dei-colori)
-   [Test automatici](tomasi-ray-tracing-02b.html#/verifica-del-codice)
-   [Conflitti e *merging*](tomasi-ray-tracing-02b.html#/lavoro-in-gruppo)
-   [Gestione degli errori](tomasi-ray-tracing-03a.html#/gestione-degli-errori)
-   [Licenze d'uso](tomasi-ray-tracing-04a.html#/licenze-duso)
-   [Tone mapping](tomasi-ray-tracing-04a.html#/tone-mapping)
-   [Modellizzazione di oggetti](tomasi-ray-tracing-05a.html#/modellizzazione-di-oggetti)
-   [Trasformazioni](tomasi-ray-tracing-05a.html#/trasformazioni): [di scala](tomasi-ray-tracing-05a.html#/trasformazioni-di-scala), [applicate a normali](tomasi-ray-tracing-05a.html#/trasformazioni-e-normali), [rotazioni](tomasi-ray-tracing-05a.html#/rotazioni), [traslazioni](tomasi-ray-tracing-05a.html#/traslazioni)
-   [Numeri di versione, *semantic versioning*](tomasi-ray-tracing-05a.html#/numeri-di-versione)
-   [*Branch* e *pull requests*](tomasi-ray-tracing-05b.html#/pull-requests)
-   [*CI builds*](tomasi-ray-tracing-06b.html#/ci-builds)
-   [Soluzioni analitiche dell'equazione del rendering](tomasi-ray-tracing-07a.html#/soluzione-dellequazione)
-   [Algoritmi *image order*](tomasi-ray-tracing-07a.html#/algoritmi-image-order)
-   [Schermi virtuali e osservatori](tomasi-ray-tracing-07a.html#/schermo-e-osservatore)
-   [Proiezioni prospettiche ed ortogonali](tomasi-ray-tracing-07a.html#/tipi-di-proiezione)
-   [*Aspect ratio*](tomasi-ray-tracing-07a.html#/aspect-ratio)
-   [Forma alternativa dell'equazione del rendering e funzione di visibilità](tomasi-ray-tracing-08a.html#/equazione-del-rendering)
-   [Intersezioni tra raggi e forme geometriche](tomasi-ray-tracing-08a.html#/intersezioni-tra-raggi-e-forme-geometriche): [sfere](tomasi-ray-tracing-08a.html#/sfere), [piani](tomasi-ray-tracing-08a.html#/piani)
-   [Debugging: difetto, infezione, fallimento](tomasi-ray-tracing-09a.html#/debugging)
-   [Algoritmo di path tracing](tomasi-ray-tracing-10a.html#/path-tracing)
-   [Probabilità e Monte Carlo](tomasi-ray-tracing-10a.html#/probabilit%C3%A0-e-monte-carlo): CDF, PDF, valore di aspettazione, varianza, deviazione standard, metodo della media, *importance sampling*, densità marginale e condizionale
-   [Direzioni casuali](tomasi-ray-tracing-10a.html#/direzioni-casuali): distribuzione uniforme e distribuzione di Phong
-   [BRDF e pigmenti](tomasi-ray-tracing-10a.html#/brdf)
-   [Generazione di numeri pseudo-casuali](tomasi-ray-tracing-10b.html#/generazione-di-numeri-pseudocasuali)
-   [*Importance sampling* nell'equazione del rendering](tomasi-ray-tracing-11a.html#/integrale-mc)
-   [Roulette russa](tomasi-ray-tracing-11a.html#/roulette-russa)
-   [*Antialiasing*](tomasi-ray-tracing-11a.html#/aliasing-e-antialiasing)
-   [Test della fornace](tomasi-ray-tracing-11b.html#/test-1)
-   [Terminologia nella teoria dei compilatori](tomasi-ray-tracing-12a.html#/terminologia): lessico, sintassi, semantica, *token*, [*look-ahead*](tomasi-ray-tracing-12a.html#/tornare-indietro)

-->

## Parti non richieste per l'esame

<!--

-   [Il formato PFM](tomasi-ray-tracing-02a.html#/file-pfm)
-   [File di testo e file binari](tomasi-ray-tracing-03a.html#/file-binari-e-di-testo)
-   [Lo standard Unicode](tomasi-ray-tracing-03a.html#/lo-standard-unicode)
-   [File e stream](tomasi-ray-tracing-03b.html#/file-e-stream)
-   [Il formato Markdown](tomasi-ray-tracing-04a.html#/markdown)
-   [Numeri complessi e quaternioni](tomasi-ray-tracing-06a.html#/numeri-complessi-e-quaternioni)
-   [Algebre di Clifford](tomasi-ray-tracing-06a.html#/algebre-di-clifford)
-   [Constructive Solid Geometry](tomasi-ray-tracing-08a.html#/constructive-solid-geometry)
-   [*Issues*](tomasi-ray-tracing-08b.html#/issues)
-   [*Change log*](tomasi-ray-tracing-08b.html#/changelog)
-   [*Axis-aligned boxes*](tomasi-ray-tracing-09a.html#/axis-aligned-boxes)
-   [Triangoli e *mesh* di triangoli](tomasi-ray-tracing-09a.html#/triangoli-e-mesh-di-triangoli)
-   [Generatore PCG](tomasi-ray-tracing-10b.html#/lalgoritmo-pcg)
-   [Basi ortonormali arbitrarie](tomasi-ray-tracing-11a.html#/basi-ortonormali-onb-arbitrarie)
-   [BRDF riflettente](tomasi-ray-tracing-11a.html#/brdf-riflettente)
-   [Algoritmi di illuminazione diretta](tomasi-ray-tracing-11a.html#/illuminazione-diretta)
-   [*Photon mapping*](tomasi-ray-tracing-11a.html#/photon-mapping)
-   [*Stratified sampling*](tomasi-ray-tracing-11a.html#/stratified-sampling)
-   [*Point-light tracing*](tomasi-ray-tracing-11a.html#/point-light-tracing)
-   Esempi di DSL: [SQL](tomasi-ray-tracing-12a.html#/sql), Julia, Nim…
-   [Panoramica sulla definizione di scene](tomasi-ray-tracing-12a.html#/linguaggi-per-la-definizione-di-scene-3d): DKBTrace, POV-Ray, YafaRay
-   [Gerarchie di classi e *sum types*](tomasi-ray-tracing-12a.html#/tokens-e-gerarchie-di-classi)
-   [Gestione degli errori di un compilatore](tomasi-ray-tracing-13a.html#/gestione-degli-errori-di-un-compilatore)
-   [Linguaggi a confronto](tomasi-ray-tracing-13a.html#/linguaggi-a-confronto)
-   [Testing di compilatori](tomasi-ray-tracing-13a.html#/testing-di-compilatori)
-   [Generazione automatica di compilatori](tomasi-ray-tracing-13a.html#/generazione-automatica-di-compilatori)

-->

