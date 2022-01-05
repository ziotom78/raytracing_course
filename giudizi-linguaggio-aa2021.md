---
title: "Valutazioni degli studenti sui linguaggi usati"
author: "Maurizio Tomasi <[maurizio.tomasi@unimi.it](mailto:maurizio.tomasi@unimi.it)>"
css: ./css/github-pandoc.css
toc: true
fontsize: 12
geometry: "margin=1.5in"
mainfont: "EB Garamond"
sansfont: "Noto Sans"
monofont: "Noto Mono"
colorlinks: true
...

# A.A. 2020–2021

## Tommaso Armadillo (2021-06-23)

All’inizio del corso mi sono trovato a dover scegliere un linguaggio
di programmazione. Personalmente volevo imparare un nuovo linguaggio,
per questo motivo ho escluso fin da subito il C++. Per prima cosa ho
letto il pdf scritto dal professor Tomasi in cui fa una panoramica su
diversi linguaggi consigliati, tra questi mi hanno colpito il C# e
Julia. Il primo per la sua sintassi molto simile al C++, ma al tempo
stesso molto più leggera e il secondo perchè mi ha dato l’impressione
di essere un linguaggio molto versatile e innovativo. Alla fine ho
scelto il C# sia perchè rispetto a Julia si trova più materiale
online, sia perchè il C# è molto utilizzato nell’industria videoludica
(grazie al motore grafico Unity) che è un qualcosa che mi ha sempre
interessato e che ho sempre voluto approfondire un po’.

Personalmente sono molto contento della scelta che ho fatto. Il C# è
un linguaggio estremamente versatile e facile da imparare se si
conosce già il C++. La sintassi è identica per tutti i costrutti
principali, tuttavia elimina tutte le difficoltà e le complicazioni
del C++. Ad esempio non c’è bisogno né di creare file `.h` né di dover
scrivere esplicitamente un `makefile` per compilare il codice, ma è
possibile compilare ed eseguire semplicemente con il comando `dotnet
run` (dotnet è il compilatore C# fornito liberamente da Microsoft). C#
è supportato egregiamente da Visual Studio che permette con estrema
facilità di avviare il debugger per risolvere bug all’interno del
codice. Il linguaggio inoltre non prevede poi l’utilizzo di puntatori
e reference come il C++, rendendolo molto più facile e leggibile.
Esistono poi molte librerie fornite direttamente da Microsoft che
permettono di ottenere risultati interessanti in pochissimo tempo. Ad
esempio è possibile parallelizzare l’esecuzione di un ciclo `for`
semplicemente facendo un include di una libreria di sistema e
sostituendo il `for` con `Parallel.For`. Fare un’operazione del genere
in C++ richiede invece l’installazione di librerie esterne, che in
generale è un’operazione più lunga e che può portare a problemi nel
caso in cui altre persone vogliano utilizzare il nostro codice. Infine
un’ultima cosa da non sottovalutare, è il fatto che esiste una
documentazione, molto ben fatta, fornita direttamente da Microsoft ed
essendo poi un linguaggio molto diffuso su StackOverFlow si trovano
parecchie risorse utili.

## Matteo Foglieni (2021-06-30)

Per quanto riguarda il mio messaggio per gli studenti del futuro, è
molto semplice: scegliete Julia; sarà molto faticoso all’inizio, ma ne
varrà la pena.

La scelta di Julia per me si è basata su due soli elementi: il pdf
reso disponibile dal professore su alcuni dei vari linguaggi che
consigliava e una lezione facoltativa di Astronomia 1 nella quale lui
stesso presentava un piccolo lavoretto computazionale fatto proprio
con Julia; un po' poco forse con il senno di poi, diciamo che avevo
posto molta fiducia sull’opinione che il professore stesso ha su
questo linguaggio.

Le mie alternative erano C++ (per andare sul sicuro, anche se mi
immaginavo avrei dovuto tribolare parecchio, e un mio compagno che lo
ha scelto me lo ha infatti confermato) o C# (per "uscire dal seminato
ma senza esagerare"); ho scelto Julia per un elemento in particolare:
questo corso è una occasione più unica che rara a fisica di imparare
un linguaggio di programmazione nuovo (= diverso da C++ e Python).

A posteriori, risceglierei questo linguaggio con molta più
consapevolezza e sicurezza:

1.  La sintassi di Julia è relativamente facile da imparare
    (soprattutto se si ha una infarinatura di Python da lab astronomia
    o dalla tesi triennale) ed intuitiva una volta che si entra
    nell’ottica giusta;
2.  Il linguaggio è concepito per il calcolo scientifico, quindi anche
    la scrittura "a mano" di una qualsiasi funzione ha una ottima
    performance: le ottimizzazioni "serie" ovviamente vi sono da fare
    se uno ha tempo ed è interessato, ma anche senza di esse il
    programma ha tempi di esecuzione accettabilissimi; inoltre, avendo
    noi una formazione da fisici, la mentalità di usare e implementare
    funzioni penso venga proprio naturale;
3.  Julia è un linguaggio modernissimo, quindi varie funzionalità che,
    soprattutto verso la fine del corso, vanno rese nel programma
    (come i *sum types* per i tokens, o la possibilità di scrivere
    codice anche molto complesso per i costruttori) vengono supportate
    senza problemi;
4.  Il *multiple dispatch* è comodissimo, si adatta perfettamente per
    le varie shapes da implementare;

La scelta di Julia ha due principali problemi, che è bene sempre
tenere a mente:

1.  Per quanto simile a Python, resta un linguaggio nuovo da imparare
    da zero: soprattutto nelle fasi iniziali, ciò può essere molto
    frustrante, dato che ci si imbatte spesso nel voler fare una cosa
    ma non sapere come farla; se si vuole vedere il lato positivo,
    sicuramente si allenano capacità di improvvisazione e
    perseveranza;
2.  Come già detto nei pregi, Julia è un linguaggio molto moderno. Di
    conseguenza, non di rado si presentano problemi nel codice che non
    si riescono a capire e/o risolvere a causa di scarsa
    documentazione (soprattutto nella prima parte del corso, vedi
    problema 1), o a causa di veri e propri bug (mi sono capitati dei
    problemi con la funzione `string` che ancora non ho capito).
    Inoltre, essendo ancora relativamente poco diffuso (proprio perché
    neo-entrato nel panorama dei linguaggi), cercare su internet il
    messaggio di errore ottenuto e/o parole chiave sul problema
    riscontrato non assicura affatto che si ottenga una soluzione (per
    C++ è invece praticamente impossible che qualcun altro non abbia
    fatto la stessa domanda in precedenza)

NB: terrei comunque a sottolineare che Julia è sotto pesante sviluppo
e improvements; potrebbe quindi anche essere che tra un anno questi
problemi di documentazione e bugs risultino risolti o comunque molto
mitigati.

In conclusione, se avete voglia di impegnarvi e investirci molto
tempo, Julia non vi deluderà di certo!

Ultimissima cosa: a prescindere dal linguaggio scelto, il corso
richiede notevole impegno: non rinunciate a Julia per vertere su C++
solo per evitare di faticare, potreste avere brutte sorprese.


## Simone Pirota (2021-07-01)

1.  Perché avete scelto questo linguaggio? Quali altre alternative
    avevate valutato, e perché le avete scartate?

    Io ho scelto il C++, principalmente perchè già lo conoscevo, e un
    po' perchè la mia prima scelta (il linguaggio Rust) non era
    condivisa da nessun altro studente.

2.  Indipendentemente dal linguaggio scelto, quali sono stati i
    criteri che vi hanno aiutato a decidere? Come li giudicate col
    senno di poi?

    Principalmente la scelta del linguaggio è stata basata sulla
    curiosità e voglia di imparare un nuovo linguaggio di
    programmazione. Questo potrebbe risultare un criterio che esclude
    il C++, in quanto è già affrontato dai corsi di informatica della
    triennale, ma la grande differenza rispetto a quei corsi è che in
    questo lo si vede non in maniera didattica, ma dal punto di vista
    produttivo, come nella vita vera.
    
    Quindi, se avete voglia di imparare un nuovo linguaggio di
    programmazione (magari anche il più esotico tra quelli proposti) e
    se c'è un altro collega che vi segue non esitate; se invece come
    nel mio caso siete l'unico pazzo del gruppo e siete "obbligati" a
    "ripiegare" sul C++, non scoraggiatevi, perchè lo vedrete sotto
    tutta un'altra luce.
    
    Riassumendo, secondo me i criteri sono:
    
	-   voglia e curiosità di imparare un nuovo linguaggio
    
	-   voglia di approfondire un linguaggio che già si conosce
	
3.  Alla luce del lavoro di questo semestre, pensate sia stata una
    buona scelta?

    È stata una buonissima scelta, perchè come accennato prima, ho
    approfondito e imparato cose che in C++ manco sapevo si potessero
    fare, e soprattutto sono molto più sicuro quando vado a spulciare
    la STL in cerca di risposta, oppure se sto scrivendo una
    funzione/classe/etc etc o la sto copiando da una risposta di
    stackoverflow, ho abbastanza senso critico da capire se lo sto
    facendo nel migliore dei modi o meno.

4.  Se tornaste indietro, rifareste questa scelta? Perché?

    Rifarei la stessa scelta, o meglio, invece di tuffarmi sul Rust,
    sceglierei direttamente il C++, perchè credo sia indispensabile
    conoscerlo e sbatterci la testa il più possibile finché siamo
    studenti (se fosse per me riseguirei questo corso diverse volte,
    ogni volta con un linguaggio diverso, sì, se te lo stai chiedendo,
    questo è davvero un bel corso).


## Giacomo Rivolta (2021-07-01)

1.  Perché avete scelto questo linguaggio? Quali altre alternative
    avevate valutato, e perché le avete scartate?

    Noi abbiamo scelto il linguaggio Julia. Le possibilità che avevamo
    erano:
    
    -   rispolverare il molto impolverato C++;
    
    -   riprendere il Python (meno impolverato ma vietato!);
    
    -   imparare un nuovo linguaggio, moderno e semplice da usare.
    
    Visto che per riprendere in mano il C++ in maniera decente avrebbe
    impiegato lo stesso tempo di imparare un nuovo linguaggio, abbiamo
    deciso di impararne uno nuovo. Abbiamo scelto proprio Julia
    (suggeritoci dal prof. Tomasi) perché ci è sembrato moderno,
    semplice, versatile e veloce.
    
2.  Indipendentemente dal linguaggio scelto, quali sono stati i
    criteri che vi hanno aiutato a decidere? Come li giudicate col
    senno di poi?

    Come detto sopra, cercavamo un linguaggio moderno (consapevoli dei
    rischi che comporta, cioè poca documentazione e molti problemi non
    ancora risolti), semplice da imparare (cioè con una sintassi
    facile da apprendere e non pesante), versatile e veloce.
    
    Con il senno di poi direi che questi criteri e la scelta
    conseguente sono stati azzeccati.
    
3.  Alla luce del lavoro di questo semestre, pensate sia stata una
    buona scelta?

    Sì, penso che scegliere Julia sia stata una buona scelta, al di là
    di un po' di problemi "di gioventù" incontrati. Sicuramente la
    versatilità di Julia (cito solo il *multiple dispatch*), la sua
    semplice sintassi, la sua velocità e modernità lo hanno reso
    un'ottima scelta. Sicuramente alcuni problemi riguardo a
    funzionalità non ancora implementate e mancanza di documentazione
    (anche banalmente la risoluzione di qualche problema su
    StackOverflow) verranno aggiustati con il tempo.
    
4.  Se tornaste indietro, rifareste questa scelta? Perché?

    Sì, rifarei sia la scelta di scegliere Julia, sia quella di
    imparare un nuovo linguaggio perché è sempre utile e interessante.


## Federico Pellegatta (2021-07-05)

### Scelta del linguaggio

All'inizio del corso la mia intenzione era di imparare a programmare
in JavaScript, che già conoscevo in parte. Purtroppo però non ho
trovato un compagno che avesse lo stesso interesse e quindi ho dovuto
ripiegare sul sempiterno C++.

Con il senno di poi, avrei comunque preferito fare un piccolo sforzo
iniziale in più per imparare un linguaggio nuovo. Infatti, la scelta
del C++, se all'inizio mi sembrava la più comoda, in certi casi si è
rivelata piuttosto faticosa rispetto ad altri compagni che hanno
deciso di imparare un nuovo linguaggio. Probabilmente però non mi
sarei comunque buttato completamente in un nuovissimo linguaggio senza
aver dedicato qualche momento a "giocarci" prima di incominciare il
corso.

In ogni caso mi è stato utile la panoramica *A comparison between a
few programming languages* messa a disposizione dal Prof. Tomasi sul
sito Ariel del corso (nella sezione "Informazioni sul corso").

### Pareri generali sul corso

Il corso è molto divertente e stimolante: anche per chi sceglierà il
C++ scoprirà un sacco di cose nuove (che probabilmente ve lo faranno
odiare!). Le lezioni sono interessanti e il materiale didattico
preparato dal Prof è eccellente. È molto soddisfacente avere un
risultato visivo dopo mesi di lavoro: l'appagamento e il risultato
sono direttamente proporzionali all'impegno durante i mesi di corso.

Nonostante nelle presentazioni del corso il Prof. Tomasi abbia
sottolineato che si hanno delle scadenze ogni settimana, il carico di
lavoro mi è sembrato in linea con quello richiesto da altri corsi di
laboratorio. Chiaramente è fondamentale che il lavoro sia finito di
settimana in settimana, ma se anche si arrivi all'esercitazione
successiva con qualche dettaglio non ancora implementato, o qualche
cosa ancora da sistemare, si può velocemente recuperare chiedendo
aiuto al Prof. Inoltre può capitare che alcune settimane ci sia un po'
più di lavoro rispetto ad altre: l'importante è organizzarsi con il
proprio compagno di laboratorio.

In conclusione, ritengo che frequentare questo corso sia stata
un'ottima scelta che rifarei in futuro. Oltre a imparare ad utilizzare
strumenti come Git e GitHub per la programmazione in team, si
implementa un codice numerico complesso che approssimi un modello di
un fenomeno fisico non banale (cose non mostrate in altri corsi).

Puoi avere una panoramica del lavoro svolto e del risultato che io e
il mio compagno di laboratorio abbiamo ottenuto andando a sbirciare
[la nostra repo](https://github.com/federicopellegatta/raytracing).


## Daniele Zambetti (2021-07-07)

Ho scelto di utilizzare Julia come linguaggio di programmazione perché
mi era stato presentato velocemente durante una lezione di Astronomia
1 sempre dal professor Tomasi e fin da subito mi era parso molto
comprensibile da leggere come linguaggio. La chiarezza con cui è
possibile esprimere formule matematiche complesse (praticamente con lo
stesso formalismo con cui si scriverebbero su un foglio di carta) è
sorprendente, inoltre la grande flessibilità con cui vengono gestiti i
tipi delle variabili è comodissima. Leggendo il materiale messo a
disposizione del professore mi ha convinto vedere che nonostante sia
un linguaggio formalmente così alto, abbia tempi di compilazione
veramente rapidi.

Un criterio forse banale con cui ho deciso di imparare da capo un
nuovo linguaggio è anche che l’unico linguaggio che conoscevo utile
per fare questo corso, il C++, non lo usavo da moltissimo tempo quindi
la fatica di riprendere la sintassi (rigidissima del C++) sarebbe
stata di poco inferiore alla fatica di iniziare da capo con un nuovo
linguaggio.

Sono molto soddisfatto della scelta fatta, sia perché Julia si è
rilevato un linguaggio flessibile e davvero innovativo, sia perché ho
imparato ad essere molto autonomo nella ricerca di documentazione e di
esempi (la community di Julia è abbastanza attiva) su come si utilizza
questo linguaggio.

In laboratorio il lavoro non è stato particolarmente rallentato dal
dover imparare qiuesto nuovo linguaggio soprattutto perché, come
suggerito dal professore, per prendere dimestichezza con la sintassi
ho svolto prima dell’inizio del corso una decina di esercizi proposti
dal sito [Project Euler](https://projecteuler.net/).


## Matteo Zeccoli Marazzini (2021-07-09)

Ho scelto il linguaggio C++ perché tra quelli suggeriti era l'unico
che avevo già utilizzato, e ne ho approfittato per studiarlo meglio
usandolo in un progetto complesso. Avevo valutato anche il linguaggio
C, che conosco meglio, ma ho dovuto scartarlo perché nessun altro
l'aveva considerato e non avrei potuto lavorare in gruppo.

Il criterio più importante è stata la familiarità con il linguaggio:
per affrontare un lavoro così complicato, ho pensato che fosse troppo
difficile utilizzare uno strumento mai visto in precedenza. Con il
senno di poi, credo che sia stato un criterio utile: utilizzare ad
esempio Julia sarebbe stato sicuramente stimolante, ma non credo che
sarei riuscito a lavorare in modo altrettanto proficuo. Sono
soddisfatto della scelta: l'alternativa che avevo considerato (il C)
sarebbe stata interessante da usare, ma avrebbe reso alcune cose molto
più complicate da gestire. Ad esempio, funzioni che prendono argomenti
generici sono più rigide e difficili da implementare, e nel corso ne
abbiamo fatto largo uso. Inoltre, sono contento perché ho avuto
l'opportunità di imparare ad utilizzare il C++ in un modo diverso
rispetto a quello a cui ero abituato: ho potuto usare strumenti più
moderni come gli `shared_ptr`, le *lambda functions*, le *initializer
list*. Alla luce di queste riflessioni, credo che sceglierei
nuovamente il C++, soprattutto perché ho potuto imparare ad usarlo
molto meglio rispetto a prima del corso.


## Andrea Sala (2021-07-14)

Ho seguito il corso *Calcolo Numerico per la Generazione di Immagini
Fotorealistiche* nell'anno accademico 2020-2021 e ho scelto di
sviluppare il mio progetto in C#.

Quando ho letto la guida ai linguaggi di programmazioni redatta dal
Prof. Tomasi, sono subito rimasto incuriosito dal fatto che esistesse
un linguaggio simile al C++ ma che risolvesse alcune sue criticità.
Così e stato; i vantaggi del C# che ho sperimentato in prima persona
sono:

-   Uso più assennato dei punti e virgola
-   Linguaggio totalmente *object-oriented*: non c'è più quello strano
    mix di funzioni definite al di fuori del main e classi contenenti
    i loro methodi (in questo è molto utile la keyword `static`)
-   Molto ben integrato con l'IDE Visual Studio Code
-   Non c'è bisogno di puntatori
-   È molto comodo usare alcune classi predefinite del linguaggio
    (`List`, `Matrix4x4`, `Dictionary`, …)
-   Non c'è bisogno di scrivere il `Makefile`, ma compilazione ed
    esecuzione sono racchiuse nello stesso comando `dotnet run`
-   Gli errori sono documentati molto bene (codice `CS####`) sul sito
    di Microsoft
-   Ereditarietà concepita in modo più lineare rispetto al C++
-   Parallelizzare il codice è molto molto semplice

Ci sono anche (pochi) svantaggi nell'uso del C#. Ecco quelli che ho
riscontrato:

-   Command Line Interface non facilissima da implementare; abbiamo
    dovuto cercare un po' di librerie diverse prima di trovarne una
    soddisfacente
-   Quando si fa il parsing di un oggetto che può essere una delle
    tante classi figlie di una certa classe madre, è scomodo chiamare
    un datamembro presente in una sola delle classi figlie. Faccio un
    esempio:

    ```csharp
	Token tok = readToken();
	if (tok == SymbolToken)
	{
		string s = tok.symbol; 
	}
    ```

    Questo codice non è ammesso dal C#! Anche se io sono sicuro che
    quel token è un SymbolToken grazie al controllo, non posso
    accedere direttamente al data membro `symbol`, ma devo fare un
    casting un po' scomodo:

    ```csharp
	Token tok = readToken();
	if (tok == SymbolToken)
	{
		string s = ((SymbolToken)tok).symbol;
	}
    ```

- Leggermente meno performante del C++, ma per quello che ho fatto
  durante il corso non ho avuto problemi di lentezza.


## Anna Pivetta (2021-07-26)

Kotlin. La scelta di questo linguaggio da parte mia sinceramente non è
stata molto ragionata: ero curiosa di imparare un linguaggio nuovo e
ho scelto questo anche insieme al mio compagno di gruppo.

Il primo criterio per me è stato semplicemente che fosse un linguaggio
nuovo, inoltre sapevo che utilizzando Kotlin avrei avuto a che fare
con una bella IDE e mi sembra che anche imparare a interfacciarsi con
uno strumento del genere sia importante per qualcuno a cui piace
programmare.

Kotlin ha alcuni aspetti molto belli: per esempio la possibilità di
usare funzioni implicite rende il codice molto elegante. Inoltre,
esistono molte librerie che rendono alcuni passaggi molto semplici,
per esempio scrivere un’immagine ldr (png, jpeg…) è facilissimo in
Kotlin.

Ovviamente ci sono anche alcuni aspetti negativi, ne segnalo uno in
particolare. Se sceglierete Kotlin userete sicuramente la IDE
IntellijIDEA e il gestore di pacchetti gradle: sono entrambi strumenti
potenti e per certi versi molto comodi ma vanno usati con cautela e
più coscienza di quanto abbiamo fatto noi. IntellijIDEA vi offre
un’interfaccia grafica attraverso la quale potete dialogare con github
senza passare dalla linea di comando: questo è comodo ma bisogna fare
attenzione a cosa committate su github e cosa no. Ci sono alcuni file
che descrivono come è fatto il workspace o come sono le impostazioni
di gradle che se modificati possono crearvi alcuni impicci. Noi
abbiamo usato questi strumenti in modo un po’ sportivo, senza grande
consapevolezza di cosa stavamo facendo; sicuramente se farete qualche
ricerca iniziale su come funzionano gradle e intellijIDEA (non è
necessario un approfondimento esagerato, ma solo avere un minimo di
coscienza su questi strumenti) vi potrete risparmiare qualche
problema.

Complessivamente io sono contenta di aver scelto kotlin e rifarei
questa scelta: è un linguaggio molto elegante e gli strumenti che
mette a disposizione sono veramente tanti. Inoltre, la IDE
intellijIDEA aiuta veramente molto nella scrittura del codice.

In generale penso sia utile cimentarsi nell’imparare un linguaggio
nuovo e impratichirsi un po’ nella lettura della documentazione in
vista del futuro, anche per esempio del lavoro di tesi, dove spesso
bisogna utilizzare un linguaggio che non si conosce. Forse iniziare il
corso non conoscendo il linguaggio che si userà può sembrare una
complicazione in più, ma le esercitazioni delle prime settimane sono
molto semplici e avrete sicuramente il tempo di iniziare a
familiarizzare con il vostro linguaggio.


## Elisa Legnani (2022-01-04)

Ho scelto il C++ perché era un linguaggio che conoscevo già e volevo
rispolverare. Non mi sembrava di aver imparato ad usarlo con
scioltezza nei corsi precedenti, tanto che parte della sintassi di
esempio mi era nuova e mi aveva incuriosito. Non l’ho scelto tanto per
comodità, quanto per poterlo approfondire: nella descrizione dei
linguaggi fornita dal professore a inizio corso era chiaramente
indicato quanto potesse risultare complicato usarlo per questo
progetto e quanto invece altri linguaggi più recenti come Julia e
Kotlin fossero più maneggevoli. E questo è stato evidente fin dalle
prime lezioni, durante le quali, mentre altri imparavano un nuovo
linguaggio, noi abbiamo faticato a risolvere vari problemi, molti dei
quali aventi a che fare con l’utilizzo di librerie esterne e sistemi
operativi diversi (io ho lavorato con Linux e la mia compagna con
MacOS), oppure ad implementare test automatici da zero o ad imparare
nuovi strumenti per la compilazione. L’esperienza del professore e la
vastità di risorse ed esempi online ci hanno però aiutato molto in
questo senso.

A posteriori posso dire che è grazie a questo corso che ho ottenuto
una buona familiarità con il C++ e con i suoi standard più recenti. Mi
sento solo ora in grado di scrivere autonomamente un programma
complesso usando questo linguaggio, ed è per questo che sono
soddisfatta della scelta che ho fatto. Avevo valutato come alternativa
anche Julia, la cui semplicità e possibile utilizzo nel campo
dell’astrofisica (il professore aveva presentato il linguaggio anche
in una lezione di Astronomia 1) mi avevano interessato. Tornando
indietro rifarei la stessa celta, sono dell’idea che scontrarsi contro
i problemi ed imparare un metodo per risolverli sia importante
nell’apprendimento di qualsiasi materia.
 
A prescindere dal linguaggio scelto, il corso in generale è molto utile: 

-   si impara a scrivere del codice per descrivere un fenomeno fisico
    non banale in un unico grande progetto;
-   è fondamentale usare sistemi di controllo delle versioni quando si
    scrive codice complesso, e prima di questo corso non avevo avuto
    modo di approfondire l’argomento e di apprezzarne l’utilità;
-   non avevo mai scritto codice collaborando veramente con qualcun
    altro;
-   è importante scrivere codice fruibile da altri - ora che sto
lavorando alla tesi mi accorgo che spesso il codice in ambito di
ricerca è poco documentato e/o testato e per questo difficile da
utilizzare.

Esprimo anche un giudizio del tutto personale, ma credo anche
condiviso dagli altri studenti che hanno frequentato il corso. Si
tratta di un corso divertente. Oltre ad essere un utile strumento di
debugging, poter ottenere risultati visivi dopo vari mesi di duro
lavoro di programmazione dà una grande soddisfazione. Tanto che viene
voglia di implementare anche le parti facoltative, con il rischio di
non finire mai di continuare ad aggiustare e migliorare il programma.
