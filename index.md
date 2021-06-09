---
title: "Numerical tecniques for photorealistic image generation"
author: "Maurizio Tomasi <maurizio.tomasi@unimi.it>"
...

# AA 2020/2021

-   Lezione 1 (2021-03-01): [l'equazione del rendering](./tomasi-ray-tracing-01a-rendering-equation.html). Argomenti:
-   Esercitazione 1 (2021-03-03): [introduzione a Git e GitHub](./tomasi-ray-tracing-01b-github.html)
-   Lezione 2 (2021-03-08): [gestione dei colori](./tomasi-ray-tracing-02a-colors.html)
-   Esercitazione 2 (2021-03-10): [test automatici](./tomasi-ray-tracing-02b-tests.html)
-   Lezione 3 (2021-03-14): [immagini](./tomasi-ray-tracing-03a-images.html)
-   Esercitazione 3 (2021-03-17): [file PFM](./tomasi-ray-tracing-03b-image-files.html)
-   Lezione 4 (2021-03-22): [documentazione](./tomasi-ray-tracing-04a-documentation.html)
-   Esercitazione 4 (2021-03-24): [lettura file PFM](./tomasi-ray-tracing-04b-reading-images.html)
-   Lezione 5 (2021-03-29): [compressione dati](./tomasi-ray-tracing-05a-compression.html)
-   Esercitazione 5 (2021-03-31): [librerie esterne](./tomasi-ray-tracing-05b-external-libraries.html)
-   Lezione 6 (2021-04-12): [geometria Euclidea](./tomasi-ray-tracing-06a-geometry.html)
-   Esercitazione 6 (2021-04-14): [pull requests](./tomasi-ray-tracing-06b-pull-requests.html)
-   Lezione 7 (2021-04-19): [quaternioni e algebre di Clifford](./tomasi-ray-tracing-07a-clifford-algebras.html) (opzionale)
-   Esercitazione 7 (2021-04-21): [CI build](./tomasi-ray-tracing-07b-ci-builds.html)
-   Lezione 8 (2021-04-26): [proiezioni](./tomasi-ray-tracing-08a-projections.html)
-   Esercitazione 8 (2021-04-28): [docstrings](./tomasi-ray-tracing-08b-docstrings.html)
-   Lezione 9 (2021-05-03): [forme geometriche](./tomasi-ray-tracing-09a-shapes.html)
-   Esercitazione 9 (2021-05-05): [issues](./tomasi-ray-tracing-09b-issues.html)
-   Lezione 10 (2021-05-10): [ottimizzazione di forme geometriche](./tomasi-ray-tracing-10a-other-shapes.html)
-   Esercitazione 10 (2021-05-06): vedi l'[esercitazione 9](./tomasi-ray-tracing-09b-issues.html)
-   Lezione 11 (2021-05-17): [rendering](tomasi-ray-tracing-11a-path-tracing.html)
-   Esercitazione 11 (2021-05-19): [BRDFs e numeri casuali](tomasi-ray-tracing-11b-random-numbers-and-pigments.html)
-   Lezione 12 (2021-05-24): [rendering (parte 2)](tomasi-ray-tracing-12a-path-tracing2.html)
-   Esercitazione 12 (2021-05-26): [rendering (parte 2)](tomasi-ray-tracing-12b-path-tracing2.html)
-   Lezione 13 (2021-06-07): [analisi lessicale](tomasi-ray-tracing-13a-lexing.html)
-   Esercitazione 13 (2021-06-09): [implementazione di un analizzatore lessicale](tomasi-ray-tracing-13b-lexing.html)


# Indice dei contenuti

## Parti richieste per l'esame

-   [Elementi di radiometria](tomasi-ray-tracing-01a-rendering-equation.html#/radiometria): energia emessa, flusso, irradianza/emettenza
-   [Angoli solidi](tomasi-ray-tracing-01a-rendering-equation.html#/cos%C3%A8-un-angolo-solido-12)
-   [Radianza e sue proprietà](tomasi-ray-tracing-01a-rendering-equation.html#/radianza)
-   [Emettitori diffusi ideali](tomasi-ray-tracing-01a-rendering-equation.html#/esempio)
-   [BRDF](tomasi-ray-tracing-01a-rendering-equation.html#/la-brdf)
-   [Equazione del rendering](tomasi-ray-tracing-01a-rendering-equation.html#/lequazione-del-rendering)
-   [Sistemi di controllo delle versioni](tomasi-ray-tracing-01b-github.html#/sistemi-di-controllo-delle-versioni)
-   [Git](tomasi-ray-tracing-01b-github.html#git)
-   [GitHub](tomasi-ray-tracing-01b-github.html#github)
-   [Codifica del colore](tomasi-ray-tracing-02a-colors.html#/codifica-del-colore)
-   [Sistemi XYZ e RGB](tomasi-ray-tracing-02a-colors.html#/sistema-xyz)
-   [Relazione tra radianza spettrale e colori RGB](tomasi-ray-tracing-02a-colors.html#/da-l_lambda-a-rgb)
-   [Visualizzazione su dispositivi](tomasi-ray-tracing-02a-colors.html#/visualizzazione-su-dispositivi)
-   [Comportamento dei monitor](tomasi-ray-tracing-02a-colors.html#/comportamento-dei-monitor)
-   [Definizione di colori](tomasi-ray-tracing-02b-tests.html#/gestione-dei-colori)
-   [Test automatici](tomasi-ray-tracing-02b-tests.html#/verifica-del-codice)
-   [Conflitti e *merging*](tomasi-ray-tracing-02b-tests.html#/lavoro-in-gruppo)
-   [Tipi di immagini: HDR/LDR, raster/vettoriali](tomasi-ray-tracing-03a-images.html#/immagini-hdr-e-ldr)
-   [Licenze d'uso](tomasi-ray-tracing-04a-documentation.html#/licenze-duso)
-   [Gestione degli errori](tomasi-ray-tracing-04a-documentation.html#/gestione-degli-errori)
-   [Tone mapping](tomasi-ray-tracing-05a-compression.html#/tone-mapping)
-   [Compressione dei dati](tomasi-ray-tracing-05a-compression.html#/compressione-dati)
-   [*Run-length encoding*](tomasi-ray-tracing-05a-compression.html#/run-length-encoding)
-   [Ottimizzazione dei bit, compressione Huffmann](tomasi-ray-tracing-05a-compression.html#/ottimizzazione-dei-bit)
-   [Entropia e teorema di Shannon](tomasi-ray-tracing-05a-compression.html#/entropia-di-shannon)
-   [Modellizzazione di oggetti](tomasi-ray-tracing-06a-geometry.html#/modellizzazione-di-oggetti)
-   [Trasformazioni](tomasi-ray-tracing-06a-geometry.html#/trasformazioni): [di scala](tomasi-ray-tracing-06a-geometry.html#/trasformazioni-di-scala), [applicate a normali](tomasi-ray-tracing-06a-geometry.html#/trasformazioni-e-normali), [rotazioni](tomasi-ray-tracing-06a-geometry.html#/rotazioni), [traslazioni](tomasi-ray-tracing-06a-geometry.html#/traslazioni)
-   [Numeri di versione, *semantic versioning*](tomasi-ray-tracing-06b-pull-requests.html#/numeri-di-versione)
-   [*Branch* e *pull requests*](tomasi-ray-tracing-06b-pull-requests.html#/pull-requests)
-   [*CI builds*](tomasi-ray-tracing-07b-ci-builds.html#/ci-builds)
-   [Soluzioni analitiche dell'equazione del rendering](tomasi-ray-tracing-08a-projections.html#/soluzione-dellequazione)
-   [Algoritmi *image order*](tomasi-ray-tracing-08a-projections.html#/algoritmi-image-order)
-   [Schermi virtuali e osservatori](tomasi-ray-tracing-08a-projections.html#/schermo-e-osservatore)
-   [Proiezioni prospettiche ed ortogonali](tomasi-ray-tracing-08a-projections.html#/tipi-di-proiezione)
-   [*Pixel aspect ratio* e *screen aspect ratio*](tomasi-ray-tracing-08a-projections.html#/aspect-ratio)
-   [Forma alternativa dell'equazione del rendering e funzione di visibilità](tomasi-ray-tracing-09a-shapes.html#/equazione-del-rendering)
-   [Intersezioni tra raggi e forme geometriche](tomasi-ray-tracing-09a-shapes.html#/intersezioni-tra-raggi-e-forme-geometriche): [sfere](tomasi-ray-tracing-09a-shapes.html#/sfere), [piani](tomasi-ray-tracing-09a-shapes.html#/piani)
-   [Algoritmo di path tracing](tomasi-ray-tracing-11a-path-tracing.html#/path-tracing)
-   [Probabilità e Monte Carlo](tomasi-ray-tracing-11a-path-tracing.html#/probabilit%C3%A0-e-monte-carlo): CDF, PDF, valore di aspettazione, varianza, deviazione standard, metodo della media, *importance sampling*, densità marginale e condizionale
-   [Estrazione di direzioni casuali](tomasi-ray-tracing-11a-path-tracing.html#/direzioni-casuali): distribuzione uniforme e distribuzione di Phong
-   [BRDF e pigmenti](tomasi-ray-tracing-11a-path-tracing.html#/brdf)
-   [Caratteristiche dei numeri pseudo-casuali](tomasi-ray-tracing-11b-random-numbers-and-pigments.html#/generazione-di-numeri-pseudocasuali)
-   [*Importance sampling* nell'equazione del rendering](tomasi-ray-tracing-12a-path-tracing2.html#/integrale-mc)
-   [Roulette russa](tomasi-ray-tracing-12a-path-tracing2.html#/roulette-russa)
-   [*Antialiasing*](tomasi-ray-tracing-12a-path-tracing2.html#/aliasing-e-antialiasing)
-   [Test della fornace](tomasi-ray-tracing-12b-path-tracing2.html#/test-1)
-   [Terminologia](tomasi-ray-tracing-13a-lexing.html#/terminologia): lessico, sintassi, semantica, *token*, [*look-ahead*](tomasi-ray-tracing-13a-lexing.html#/tornare-indietro)


## Parti non richieste per l'esame

-   [Il formato PFM](tomasi-ray-tracing-03a-images.html#/file-pfm)
-   [File di testo e file binari](tomasi-ray-tracing-03a-images.html#/codifica-testuale-e-binaria)
-   [Lo standard Unicode](tomasi-ray-tracing-03a-images.html#/lo-standard-unicode)
-   [File e stream](tomasi-ray-tracing-03b-image-files.html#/file-e-stream)
-   [File README](tomasi-ray-tracing-04a-documentation.html#/il-readme)
-   [Il formato Markdown](tomasi-ray-tracing-04a-documentation.html#/markdown)
-   [Formati grafici](tomasi-ray-tracing-05a-compression.html#/formati-grafici-e-compressione)
-   [Codifica aritmetica](tomasi-ray-tracing-05a-compression.html#/codifica-aritmetica)
-   [*Dictionary compressors* (LZ77, LZ78)](tomasi-ray-tracing-05a-compression.html#/dictionary-compressors)
-   [I formati grafici più diffusi](tomasi-ray-tracing-05a-compression.html#/i-formati-grafici-pi%C3%B9-diffusi)
-   [Manipolazione di bit](tomasi-ray-tracing-05a-compression.html#/approfondimento-manipolare-i-bit)
-   [Quaternioni](tomasi-ray-tracing-07a-clifford-algebras.html#/quaternioni-argomento-opzionale)
-   [Algebre di Clifford](tomasi-ray-tracing-07a-clifford-algebras.html#/algebre-di-clifford-argomento-opzionale)
-   [Constructive Solid Geometry](tomasi-ray-tracing-09a-shapes.html#/constructive-solid-geometry)
-   [*Issues*](tomasi-ray-tracing-09b-issues.html#/issues)
-   [*Change log*](tomasi-ray-tracing-09b-issues.html#/changelog)
-   [*Axis-aligned boxes*](tomasi-ray-tracing-10a-other-shapes.html#/axis-aligned-boxes)
-   [Triangoli e *mesh* di triangoli](tomasi-ray-tracing-10a-other-shapes.html#/triangoli-e-mesh-di-triangoli)
-   [Generatore PCG](tomasi-ray-tracing-11b-random-numbers-and-pigments.html#/lalgoritmo-pcg)
-   [Basi ortonormali arbitrarie](tomasi-ray-tracing-12a-path-tracing2.html#/basi-ortonormali-onb-arbitrarie)
-   [BRDF riflettente](tomasi-ray-tracing-12a-path-tracing2.html#/brdf-riflettente)
-   [Algoritmi di illuminazione diretta](tomasi-ray-tracing-12a-path-tracing2.html#/illuminazione-diretta)
-   [*Photon mapping*](tomasi-ray-tracing-12a-path-tracing2.html#/photon-mapping)
-   [*Stratified sampling*](tomasi-ray-tracing-12a-path-tracing2.html#/stratified-sampling)
-   [*Point-light tracing*](tomasi-ray-tracing-12a-path-tracing2.html#/point-light-tracing)
-   Esempi di DSL: [SQL](tomasi-ray-tracing-13a-lexing.html#/sql), Julia, Nim…
-   [Panoramica sulla definizione di scene](tomasi-ray-tracing-13a-lexing.html#/linguaggi-per-la-definizione-di-scene-3d): DKBTrace, POV-Ray, PolyRay, YafaRay
-   [Gerarchie di classi e *sum types*](tomasi-ray-tracing-13a-lexing.html#/tokens-e-gerarchie-di-classi)
