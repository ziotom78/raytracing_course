import math
import sets
import sequtils

const quantizationExampleData {.exportc.} = [
    -1.536055724495413832e+00,
    9.044733097635367924e-01,
    5.409657097963156414e-01,
    -1.750119343532895444e+00,
    1.548059070547038507e+00,
    -8.098518101645422185e-01,
    -3.731477230587659788e-01,
    1.064878658492932173e+00,
    -2.254272280983633525e-01,
    -1.940090071016739026e-01,
    -1.186545100015305776e+00,
    1.605573878321478354e+00,
    1.261361585184195944e+00,
    6.869415935765830206e-01,
    -9.925133095260693095e-01,
    5.531323568211743424e-01,
    1.737583307824631218e+00,
    -6.946403389584387966e-01,
    1.051009354080099378e-01,
    -1.569643900417903470e+00,
    1.991367602334929154e+00,
    5.889670297365239282e-01,
    -7.685425716683014219e-01,
    1.802453737213902452e+00,
    -1.588361921455569425e-01,
    7.764497352347723425e-01,
    3.140498114349546954e-01,
    1.713079872446938712e-01,
    -9.978628939336036119e-01,
    7.203802635075482463e-01,
    1.178728037239282322e+00,
    -1.095952102447454113e+00,
    5.011037998858830500e-01,
    9.547833725817600481e-02,
    -5.594633580251440197e-02,
    1.078657391170039892e+00,
    8.572187544677765114e-01,
    9.263153321408312824e-02,
    -5.231853485528968895e-01,
    -4.671351611714826269e-01,
    2.211285398744367581e-01,
    8.839879442216095340e-01,
    1.760816048436621983e-01,
    9.068497792452818729e-01,
    7.753538287779366822e-01,
    1.362347641927826203e+00,
    8.311448061778679008e-01,
    -1.134173292739656169e+00,
    5.357325865840159018e-01,
    1.217660976467234590e+00,
    1.967279553537953252e+00,
    4.401606739796565249e-01,
    1.525827929924904458e+00,
    1.626934315465861536e+00,
    1.024998047292848158e+00,
    1.272844247821826480e+00,
    8.979707998555378490e-01,
    2.790584997450591409e+00,
    5.991724832506705178e-01,
    -1.064747885184501586e-01,
    1.019360286053139220e+00,
    1.921649193087138663e+00,
    6.493393300162849657e-01,
    2.761341133472118514e+00,
    5.285973715049790966e-01,
    1.836072013224667732e-01,
    1.401996682185970400e+00,
    -4.856166725305385290e-01,
    4.770098495469518585e-01,
    -9.844173311977935104e-01,
    2.258444546475676606e+00,
    1.373693180101526412e+00,
    -3.020415032052947701e-02,
    -4.746812155861327431e-01,
    2.800304239276788509e-01,
    1.731286713233803010e+00,
    5.600333349630421953e-01,
    2.166408935172652317e+00,
    6.543474348266433704e-01,
    4.983150129165990205e-01,
    1.014028327357935577e+00,
    1.275565829221067204e+00,
    1.719807589379138246e+00,
    1.168586256847830240e+00,
    -6.307346156739728205e-01,
    -4.584506158637389195e-01,
    -6.866320862360308919e-01,
    -1.187864132097085079e+00,
    -1.160130384588700547e+00,
    2.347853773755088191e+00,
    5.078440230721757986e-01,
    1.158882036115096437e+00,
    1.991689603073023340e+00,
    3.059093500500916551e+00,
    1.104845298247525864e+00,
    1.871815748254935352e+00,
    1.517580403737667893e+00,
    3.836033725097010016e+00,
    1.684663269506514460e-02,
    1.602308073028093638e+00,
    1.849377174275397273e+00,
    3.073467579455823051e-01,
    3.520544248612784699e+00,
    1.623912274018274537e+00,
    1.574042139764805226e+00,
    1.807847487769256078e+00,
    1.414762793039949340e+00,
    1.449820379400540649e+00,
    -3.396577108712681703e-01,
    1.099121680487719965e+00,
    6.756931057296212684e-01,
    6.477724612629865986e-01,
    2.197832061607959186e+00,
    1.187930929775111721e-01,
    9.996014681323810436e-01,
    1.689274693186431309e+00,
    1.533757614247615919e+00,
    1.957910237145444876e+00,
    1.607126429454129202e+00,
    2.110755158607435344e+00,
    2.318016906116673770e+00,
    9.266797834477826790e-01,
    9.328750877582752121e-01,
    2.413104079264305923e+00,
    1.580777798570994763e+00,
    1.051204668818773724e+00,
    2.108282981058113847e+00,
    4.160938254577428275e+00,
    1.341012511048094824e+00,
    2.214232632659141053e+00,
    1.643601049929231728e+00,
    2.977007607838810799e-01,
    5.157596633824272914e-01,
    2.638785517568623895e+00,
    9.754397510471450872e-01,
    3.470919240430848873e+00,
    -1.154941292276163711e-01,
    1.023846825287141993e+00,
    2.359676067289792734e+00,
    2.970944683678681475e+00,
    1.014516773453427056e+00,
    3.258891846289341032e+00,
    3.694463262812788251e+00,
    3.969775902155099345e-01,
    2.293251458322873582e+00,
    2.767951445970163071e+00,
    3.196045189383525109e-01,
    1.750568066786879484e+00,
    1.884797950251288601e+00,
    2.110618772363453299e+00,
    1.863823643194928881e+00,
    2.166966363827237618e+00,
    6.734751981115694175e-01,
    -2.164192895886192236e-01,
    9.098959091364834384e-01,
    1.455469069294032414e+00,
    1.241631871317699698e+00,
    3.102788403248017524e+00,
    2.069030095069610997e+00,
    2.746282984848955611e+00,
    2.198038711349412200e+00,
    2.375383688654234327e+00,
    -1.375734677106312809e-01,
    1.748372664904616292e+00,
    1.296255368717060596e+00,
    1.623892437318590565e+00,
    3.199478605083067251e+00,
    2.485030292104446481e+00,
    3.263452537443444434e+00,
    2.851752072942447924e+00,
    5.006742151032563815e-01,
    3.133280117297259970e+00,
    1.305660776471526230e+00,
    1.210401380693820972e+00,
    1.521276812730174566e+00,
    2.291359172425392110e+00,
    3.276916657646991915e+00,
    1.116580482665672225e+00,
    1.322899175858205378e+00,
    2.916921187659712977e+00,
    3.860384044383172064e+00,
    3.284231645270206279e+00,
    3.175604275821537481e+00,
    1.780097560922020650e+00,
    2.477360889872957994e+00,
    2.375879733214057765e+00,
    3.043873492685626569e+00,
    1.153295557844037145e+00,
    2.577158689612547793e+00,
    1.728319690210287973e+00,
    3.438463971973004796e+00,
    3.322291113420346775e+00,
    2.420384564083901235e+00,
    2.526386426986354738e+00,
    2.825380108090199016e+00,
    1.441331987893375910e+00,
    2.611193231255199532e+00,
    1.088159019877160905e+00,
    2.196595399374530189e+00,
    2.879921523612987144e+00,
    2.368234100666739561e+00,
    1.525436487572123578e+00,
    7.399812806986463265e-01,
    1.767685732761913098e+00,
    1.755274612142052160e+00,
    3.846252180643257468e+00,
    3.931282496941465698e+00,
    1.582568104083752480e+00,
    3.195666501754037103e+00,
    1.187197515924020452e+00,
    3.757368249954892825e+00,
    2.708839870366618552e+00,
    1.488086195795771616e+00,
    1.319998232228332569e+00,
    1.637194484476982126e+00,
    2.862486043903298860e+00,
    1.895262632019424798e+00,
    2.431260670007923341e+00,
    2.738702064357113830e+00,
    3.920545821703694145e+00,
    2.949754928710633717e+00,
    1.637158834452874689e+00,
    1.326265499240848245e+00,
    2.384835978732614326e+00,
    2.641210432069256431e+00,
    3.585426443776340566e+00,
    3.219531280322699640e+00,
    1.446414800102312714e+00,
    3.010956163203811986e+00,
    3.391140451100985054e+00,
    2.969812308687589830e+00,
    4.609421197544214088e+00,
    2.184296675960619272e+00,
    2.949866508717692515e+00,
    2.264388803590873689e+00,
    4.064308419984740794e+00,
    1.140338549657635259e+00,
    3.160614829772144141e+00,
    2.489221868167533991e+00,
    2.024746873918530810e+00,
    1.736178549966665319e+00,
    2.830771490143501712e+00,
    3.284104179680507052e+00,
    3.395447852694263968e+00,
    3.262424371650701982e+00,
    2.831546178399457769e+00,
    3.255387104904922779e+00,
    3.646769279918108175e+00,
    2.359591801779781228e+00,
    3.885466451141950550e+00,
    4.773500196309313992e+00,
    2.336470758626727484e+00,
    2.401840513483716855e+00,
    3.063145541231679481e+00,
    4.017700643286094220e+00,
    2.998666463432845486e+00,
]

func shannon*(sequence: seq[int]) : float {.exportc.} =
    let symbols = toHashSet(sequence)

    result = 0.0
    for s in symbols:
        let prob = count(sequence, s) / sequence.len
        if prob > 0:
            result += -prob * log2(prob)

func quantize*(sequence: seq[float], fact: float) : seq[int] {.exportc.} =
    result.newSeq(sequence.len)
    
    for i in 0..<sequence.len:
        result[i] = int(round(sequence[i] / fact) * fact)

func getQuantizationExampleData() : seq[float] {.exportc.} =
    result.newSeq(quantizationExampleData.len)
    for i in 0..<result.len:
        result[i] = quantizationExampleData[i] * 10

# let sequence = @[1.0, 2.0, 3.0, 4.0]
# echo sequence
# echo shannon(quantize(sequence, 1.0))
# echo quantize(sequence, 2.0)
# echo shannon(quantize(sequence, 2.0))