/*
LG 2023-08-28 update by cleaning route before generating drug key 

LG 2023-08-25 check and update Ying's program for clean freetext fields 

this program for clean other RA drug free text field which include pre-TM and TM other biologic, other DMARDs, other biosimilar text fields
also for TAE drugs 

2-27-2023: final updated based on Rich reviewd file

*/
// clean free text fields route is not needed, use route_code with value labels 
//  drug_name_code 

foreach x in drug_name route_code {
	clonevar `x'_raw=`x'
}

// create lower case of drug_name_txt
gen drugtxt=lower(drug_name_txt) 


///////////////////////////////////////////////////////////////////////////
////////////////////	Extract Drug names from drug_name_txt
///////////////////////////////////////////////////////////////////////////

// general drugkey from drug_name

foreach x in actemra orencia cimzia enbrel humira kineret simponi simponi_aria remicade rituxan amjevita olumiant erelzi renflexis inflectra kevzara sirukumab xeljanz xeljanz_xr mtx arava azulfidine imuran plaquenil minocin cyclosporine pred invest rinvoq ridaura cuprimine  kenalog {
	replace drugkey="`x'" if strpos(lower(drug_name), "`x'") & strpos(lower(drug_name), "other")==0
} 

replace drugkey="xeljanz_xr" if strpos(lower(drug_name), "xeljanz") & strpos(drug_name, "extended") 
replace drugkey="arava" if drug_name=="leflunomide" & drugkey=="" 
replace drugkey="azulfidine" if drug_name=="sulfasalazine" & drugkey==""
replace drugkey="meth_pred" if strpos(lower(drug_name), "methylpred") 

//source_acronym study_acronym dw_event_type_acronym 
groups drug_name drug_name_code if drugkey=="",missing ab(16)  

// all names are with other freetext fields 
/*
  +-------------------------------------------------------------------------------+
  |                                  drug_name   drug_name_code   Freq.   Percent |
  |-------------------------------------------------------------------------------|
  |                                                               54129     74.27 |
  |              RA medication other (specify)              990    1997      2.74 |
  |                           adalimumab other              118      32      0.04 |
  | biologic or small molecule other (specify)              920   16266     22.32 |
  |                           etanercept other              148      34      0.05 |
  |-------------------------------------------------------------------------------|
  |                           infliximab other              168     210      0.29 |TM // 168 and 169 should be coded the same 
  |                 infliximab other (specify)              169      21      0.03 |RCC
  |                  rituximab other (specify)              179       4      0.01 |RCC 
  |                  treatment other (specify)            99020     191      0.26 |
  +-------------------------------------------------------------------------------+

/*
Some drug_name/codes can be combined into one

  |                               cyclosporine              510       16      0.00 |same drugkey
  |                      cyclosporine (Neoral)              511      516      0.05 |
 

  |                           infliximab other              168      210      0.02 |exract freetext first 
  |                 infliximab other (specify)              169       21      0.00 |


  |                              sulfasalazine              550       34      0.00 |same drugkey
  |                 sulfasalazine (Azulfidine)              551    32547      3.07 |
*/

*/

groups drugkey drug_name drug_name_code , missing ab(16) sepby(drugkey)

*groups hdr_study_source_acronym hdr_dw_event_type_acronym if drug_name=="adalimumab (Humira Citrate-free)" , ab(16) sepby(hdr_study_source_acronym)
// RCC only 

///////////////////////////////////
////////	No drugs
/////////////////////////////////// 

for any unknown mystery laughter lots more hugs "fresh air" "future tech" xcvxzcv ffff ff e error fake faux na "n/a" none no "not needed" "no biologic started": replace drugtxt="" if drugtxt=="X" 

for any "time" "supr healthy" "no other drug" "not needed" ofofof "why is this required": replace drugtxt="" if strpos(drugtxt, "X") // & drugkey==""


//////////////////////////////////////////////////////////////////////////////
*********		Biologic, JAKs, Biosimilar 	**********************************
//////////////////////////////////////////////////////////////////////////////

///////////////////////////////	TNFs
// Enbrel
for any enbrl enbrel etanc entaner etane embrel embril benel enbe enbre enrel  entaracept embel ebrel enbrle enbrol enbrel enrbel enteracept eubrel endrel enre;: replace drugkey="enbrel" if strpos(drugtxt, "X")   
// Enbrel bs
for any erelzi: replace drugkey="erelzi" if strpos(drugtxt, "X")  

// Humira 
for any umira humin humir humira ada humri humra humnira humiro humia hurmi adalumumab humas humera  hunira huira hunmira  : replace drugkey="humira" if strpos(drugtxt, "X")  

// humira biosimilar 
for any amgevita amjevita atto : replace drugkey="amjevita" if strpos(drugtxt, "X") 

// hadlima added on 2024-05-02
for any hadlima bwwd: replace drugkey="amjevita" if strpos(drugtxt, "X") 

// humira other biosimilar 
replace drugkey="humira_bs" if drugkey=="humira" & strpos(drugtxt, "other")  
for any "ada biosim" : replace drugkey="humira_bs" if strpos(drugtxt, "X") 

// simponi
for any simponi simpni simpon " aria" golimu glimum symponi simoponi simiponi sinponi: replace drugkey="simponi" if strpos(drugtxt, "X") & drugtxt!="solgarial" 
// LG added 
for any aia ara arai arir aroa arira aria iv arua: replace drugkey="simponi_aria" if drugkey=="simponi" & strpos(drugtxt, "X") 
replace drugkey="simponi_aria" if drugtxt=="aria" | drugtxt=="simoni/aria"

// cimzia 
for any cimia cimzia certoliz cizmia cimzz cimizia cinzia cimza : replace drugkey="cimzia" if strpos(drugtxt, "X") 

// remicade 
for any remicade remicad remicaid remicd remciade remincade remcade reicade renicade emicade remicaee remicae remicase remimcade : replace drugkey="remicade" if strpos(drugtxt, "X") & drugkey=="" 
	// LG added 2023-08-31
for any apremicase: replace drugkey="" if strpos(drugtxt, "X") & drugkey=="remicade"
// LG added dyyb 
for any dyyb inflectra inflecta infectra inlfectra infelctra: replace drugkey="inflectra" if strpos(drugtxt, "X") 

// LG added abda
for any abda reflexus reflexis renbflexis renflex renfe renflex reneflex : replace drugkey="renflexis" if strpos(drugtxt, "X") 

// LG added axxq
for any ausola avsol avsola avosla avosla axxq: replace drugkey="avsola" if strpos(drugtxt, "X") 

// Remicade other biosimilar 
for any infliximab inf: replace drugkey="remicade_bs" if strpos(drugtxt, "X") & drugkey=="" & strpos(drugtxt, "mab") // check 

for any inflixmal infliximeb: replace drugkey="remicade_bs" if strpos(drugtxt, "X") & drugkey==""

replace drugkey="remicade_bs" if strpos(drugtxt, "rem") & strpos(drugtxt, "biosim")  

replace drugkey="remicade_bs" if drugtxt=="infliximab other" 

/////////////////////	Non-TNFis

// orencia
for any atabacept orenia orlencia ornecia orencia orecia orencn orenca orenc abat 0rencia orncia orenica orecnia orenicia orensia oencia orcenia orienc : replace drugkey="orencia" if strpos(drugtxt, "X")

// actemra 
for any actdemra "acte,ra" actrema actemra acterma tocili tocizumab actem acemra acetemra acetmra actmera actrmra actermra actenra aetemra tcz  :  replace drugkey="actemra" if strpos(drugtxt, "X")  // tocilizumab (Actemra) SC IV 

//	kevzara
for any kevzara sarilum kesvara kezvara kevarza keuza keusara: replace drugkey="kevzara" if strpos(drugtxt, "X") 

// kineret
for any kineret anakinra anaki kincret: replace drugkey="kineret" if strpos(drugtxt, "X")  

// rituxan and biosimilar
for any ritoxan ritiuxan rituxan rituan rituxin ritxan riutxan rixtan rtuxan rtx "rit uxan" ritaxon retuxan rituxen rituzan retuxin: replace drugkey="rituxan" if strpos(drugtxt, "X") 
// drug: Rituximab-pvvr(Ruxience) - Rituxan biosimilar -Pfizer LG added pvvr 
for any pvvr rexience ruxience: replace drugkey="ruxience" if strpos(drugtxt, "X")   
// rituxan bs other 
for any rotuximab rituximab ritumimab rituxiumab rhuximab ritaxim rituximob rituxamib: replace drugkey="rituxan_bs" if strpos(drugtxt, "X") & drugkey=="" 

// truxima LG added abbs and limited to drugkey==""
// 2024-05-02 added trixima
for any abbs truxema truima truxina truxima truyima truzima tsuxima rituxima trruxima tsuxina trixima: replace drugkey="truxima" if strpos(drugtxt, "X")  & drugkey==""

// sirukumab 
for any siruku sirikumab : replace drugkey="sirukumab" if strpos(drugtxt, "X") 

////////////////////	JAKi
// xeljanz LG added tocacitinib
for any toficitinib toficitinib xel tofa xeijan xejan senj xejan xenj xaljanz zeljanz xenljan xljanz zelijan tfacitinib tocacitinib: replace drugkey="xeljanz" if strpos(drugtxt, "X") 

// LG added more xeljanz_xr
for any " xr" " er" " sr" " xe" " xl": replace drugkey="xeljanz_xr" if drugkey=="xeljanz" & strpos(drugtxt, "X") & strpos(drugtxt, "on xeljanz as")==0
// LG replace a few 
for any "not xeljanz":replace drugkey="" if strpos(drugtxt, "X") 

// olumiant 
for any oliumant oluimant baracitinib olumi bari olumant barcitinib : replace drugkey="olumiant" if strpos(drugtxt, "X") 

// rinvoq 
for any rinnvoq rinoq updacitinib rinvpq rinvq invoq rinvo rinov rivoq rnvoq ronvoq  "rin voq" rincoq rimvoq rinqo upa rinvvoq pinvoq rivnoq rivnoq rinuoq:  replace drugkey="rinvoq" if strpos(drugtxt, "X") 

///////////////////////////////////////////////////////////////////////////////
***********************csDMARD/prednisone  ************************************
///////////////////////////////////////////////////////////////////////////////

// MTX with route, LG modified using route_code 
// LG added myx rasuro otrexp
for any myx methrotexate mtx metho mtx mehtotrexate trexall rasuro rsauva resuvo rsauvo rasuv otrexup otrexp mxtx methrexate methrothrexate metotrexate trexate ntx : replace drugkey="mtx" if strpos(drugtxt, "X") & drugkey=="" & strpos(drugtxt, "fluo")==0 

for any rasuro rasuvo rsauva resuvo rsauvo rasuve otrexup otrexp: replace route_code=200 if strpos(drugtxt, "X")  // MTX injection 


// leflunomide (Arava) oral ​/inject 
for any lefluomide lrflunomid lrflunomide avara arava leflun arave areva arrava lefnomideu lefunomide lefluemonide leuflodimide: replace drugkey="arava" if strpos(drugtxt, "X") 

// azathioprine (Imuran) 
replace drugkey="imuran" if substr(drugtxt,1,3)=="aza" & drugtxt!="azathume" 

for any imunan imuran imaran immura immure imran imruan imulon imrnran imura imuam imuran imuran imuran imurn imuron lmuran imunran inuran iruran omuran arathioprine azothiapine azothiopain azothiopine azothioprone azothripine azothropin azhiatopirine: replace drugkey="imuran" if strpos(drugtxt, "X") 
replace drugkey="imuran" if substr(drugtxt, 1,2)=="az" & strpos(drugtxt, "prine") 

// cyclosporine (Neoral/Gengraf) 
for any cyclsporine neoral cyclosp cya gengraf : replace drugkey="cyclosporine" if strpos(drugtxt, "X") 
// correction for drug with cya==>hyoscyameic
replace drugkey="" if drugtxt=="hyoscyameic" & drugkey=="cyclosporine"

// minocycline hydrochloride(Minocin) 2024-05-02 added micycline
for any micycline minicycline minocin minocyc minoclyc minoayc minocc mihocyc minicin mimocydine minoci mihocycline minici minoayc monocyc monocin:  replace drugkey="minocin" if strpos(drugtxt, "X") 

////////////// hydroxychloroquine (Plaquenil) LG added hydoxych
for any hyroxychloroquine hydoxych hydroxych quinacrine plq hq plaqu plauq paquenil plauenil hyydroxycholoquine: replace drugkey="plaquenil" if strpos(drugtxt, "X") 

////////////// sulfasalazine (Azulfidine)
// LG excludes hydoxychloroquine sulfate
for any azulfid sulfasa azulf sulfsal sulsalazine "sulfa sala" ssz salfasalizine sulfa salazine : replace drugkey="azulfidine" if strpos(drugtxt, "X") & drugkey==""

// LG correct dissimilar
for any  ss ss2: replace drugkey="azulfidine" if drugtxt=="X"
 
// LG correct ferrous sulfate
for any "ferrous sulfate": replace drugkey="" if strpos(drugtxt, "X") // iron added as nonRA 

for any "albuterol sulfate": replace drugkey="" if strpos(drugtxt, "X") // albuterol nonRA 

// ridaura 
for any ridu aurano rida ridoura auranofin auronofin ridaura : replace drugkey= "ridaura" if strpos(drugtxt, "X") 

// cuprimine 
for any cuprimine caprimine penicillamine pencillame penicillamene: replace drugkey="cuprimine" if strpos(drugtxt, "X") 

// prednisone 
replace drugkey="meth_pred" if strpos(drugtxt, "methyl") & strpos(drugtxt, "pred") 

for any mythl meth: replace drugkey="meth_pred" if strpos(drugtxt, "X") & strpos(drugtxt, "pred") 

for any mederol medrol mednol medrel methylsolone methylprenidolone: replace drugkey="meth_pred" if strpos(drugtxt, "X") 
 
for any pred rayos presnisone pdn: replace drugkey= "pred" if strpos(drugtxt, "X") & drugkey=="" 

// kenalog 
for any kenalog triamcin kenelog:  replace drugkey="kenalog" if strpos(drugtxt, "X")

// invest LG added "not aria" / "not xeljanz"
for any  study invest research placebo "open label" trial test experiment "lilly h9b" develop: replace drugkey="invest" if strpos(drugtxt, "X") & drugkey=="" 

for any "not aria" : replace drugkey="invest" if strpos(drugtxt, "X") & drugkey=="simponi_aria"

for any "not xeljanz": replace drugkey="invest" if strpos(drugtxt, "X") & drugkey=="xeljanz"

// added by LG 2023-08-31
for any "open label fostamatinib": replace drugkey="" if strpos(drugtxt, "X") & drugkey=="invest"  // coded fostamatinib as nonra 
for any secukinumab ocrelizumab: replace drugkey="" if strpos(drugtxt, "X") & drugkey=="invest"  // coded as othra 

////////////////////////////////////////////////////////////////////////////
// other RA drugs(other biologic, JAKs, csdmards, and cortisone 
////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////
////////	Other RA drugs as Drugkey
//////////////////////////////////////////////

// LG added other non-bio
for any "other non-bio" "other bio" "other dmard": replace drugkey="other_ra" if drugkey=="" & strpos(drugtxt, "X")
 
for any jak tnf jki: replace drugkey="other_ra" if strpos(drugtxt, "X")  & drugkey=="" 

///////////////////////////////////////////////////////////////////////////
/////////////////////	othra with details as a separate column
///////////////////////////////////////////////////////////////////////////
gen othra="" 

for any acthar actar achtar acth steroid : replace othra="acthar" if strpos(drugtxt, "X") // steroid 
// LG exclude corticosteroid from acthar 
replace othra="" if drugtxt=="corticosteroid"

// added v20231020
for any cellcept mucophenolate mycophenolate "cell cept" celstone celcept celicept cellest cellcet cevcept "cell cept" mmf: replace othra="cellcept" if strpos(drugtxt, "X") 

for any otzela otezla ortezia ortezla otelza oterzla apremilast apremicase : replace othra="otezla" if strpos(drugtxt, "X") 

for any costntyx cosenty cosenry secukinumab cosetex consentyx cosyntex: replace othra="consentyx" if strpos(drugtxt, "X") 

for any cytoxan cytox cyclophosphamide: replace othra="cytoxan" if strpos(drugtxt, "X")  

for any belimumab benlys: replace othra="benlysa" if strpos(drugtxt, "X") 

for any gold myochrysine myoch myocrism chrysotherapy myocrisin : replace othra="gold" if strpos(drugtxt, "X") 

for any solg solongal: replace othra="solganal"  if strpos(drugtxt, "X") 

for any taltz ixekizumab: replace othra="taltz" if strpos(drugtxt, "X") 

for any tremfya temfya guselkumab: replace othra="tremfya" if strpos(drugtxt, "X")  

for any stelara ustekinumab stelera stelora stelura: replace othra="stelara" if strpos(drugtxt, "X") 

for any tacrolimus  prograf tarto tacrolinus : replace othra="prograf" if strpos(drugtxt, "X")  // atopic dermatitis, immuno suppression

for any skyrizi risankizu: replace othra="skyrizi" if strpos(drugtxt, "X") 

for any leucovorin: replace othra="leucovorin" if strpos(drugtxt, "X")  

for any oskira: replace othra="oskira" if strpos(drugtxt, "X") 

for any ocrelizumab ocrevus ocruvus: replace othra="ocruvas" if strpos(drugtxt, "X")  // MS

// LG exclude quinacrine 
for any chloraqu chloreq chloroq chlorq choroq atabrine: replace othra="quinacrine" if strpos(drugtxt, "X") & drugkey!="plaquenil" // quinacrine
// LG add quinacrine quinacrine 
for any quinacrine quinacrine: replace othra="quinacrine" if strpos(drugtxt, "X") & drugkey=="plaquenil"
replace drugkey="" if othra=="quinacrine" & drugkey=="plaquenil"

for any salsalate: replace othra="salsalate" if strpos(drugtxt, "X") 

replace othra="IL-1ra" if drugtxt=="il 1ra" // IL-1RA 

for any ilaris kinizimumab: replace othra="ilaris" if strpos(drugtxt, "X") 	// canakinumab (Ilaris)

for any rheumate: replace othra="rheumate" if  strpos(drugtxt, "X")

for any celestone :  replace othra="celestone"  if strpos(drugtxt, "X") // steroid 

for any myfortic myfurtic mycoph mefetil mycophpayate: replace othra="myfortic" if strpos(drugtxt, "X") 
// glucocorticoid/cortisol LG added glucocorticoid 
for any glucocorticoid cortef dexamethasone "solu medral" decadron sexamethasone deflazacont: replace othra="glucocorticoid"   if strpos(drugtxt, "X")  & drugkey==""

for any entyvio: replace othra="entyvio" if strpos(drugtxt, "X") 

for any synkinase: replace othra="synkinase" if strpos(drugtxt, "X") 

replace othra="filgotinib" if drugtxt=="filgotinib" //filgotinib (Jyseleca)

replace othra="mmp3" if drugtxt=="mmp" //metalloprotease inhibitor


/////////////////////////////////////////////////////////////////////////////
// other non RA drug as a separate column, need to remove from other RA drug  
/////////////////////////////////////////////////////////////////////////////

gen nonra=""  

for any colbest clobeta: replace nonra="clobetasol" if strpos(drugtxt, "X")  // dermatatis, glucocorticoid
// LG added ferrous sulfate 
for any "ferrous sulfate": replace nonra="ferrous sulfate" if strpos(drugtxt, "X") // iron 

// LG added corticosteroid 
for any corticosteroid hydrochorti hydrocortisone hyoscyam hyoscyam cortizone clobestasol: replace nonra="corticosteroid" if strpos(drugtxt, "X") // for skin 

for any fluorometholone: replace nonra="fluorometholone" if strpos(drugtxt, "X") // glucocorticoid 

for any colchi: replace nonra="colchicine" if strpos(drugtxt, "X")  // acute gout attack 

for any cipro: replace nonra="ciprofloxacin" if strpos(drugtxt, "X") 

for any aimovig : replace nonra="aimovig" if strpos(drugtxt, "X") 

for any albuterol: replace nonra="albuterol" if strpos(drugtxt, "X") 

for any alelvia: replace nonra="alelvia" if strpos(drugtxt, "X") // opdrug 

for any folic: replace nonra="folic acid" if strpos(drugtxt, "X") // otc 

for any "fish oil": replace nonra="fish oil" if strpos(drugtxt, "X") // otc 

for any aspirin bayer: replace nonra="aspirin" if strpos(drugtxt, "X")  // nsaids 

for any celebrex cellebrex:  replace nonra="celebrex" if strpos(drugtxt, "X")  // nsaids 

for any diclofenac: replace nonra="diclofenac" if strpos(drugtxt, "X") // nsaids topic 

for any rofecoxib vioxx : replace nonra="vioxx" if strpos(drugtxt, "X") // nsaids 
// LG added nsaids indomethacin
for any indomethacin nsaids voltaren diclofenac motrin meloxica  etodolac sulindac sulindac oxaprozin napro advil bentyl lyrica mobic indocin nabumetone relafen daypro: replace nonra="nsaids" if strpos(drugtxt, "X")  

for any tramadol: replace nonra="tramadol" if strpos(drugtxt, "X") // pain
 
for any vicodin lortab: replace nonra="lortab" if strpos(drugtxt, "X") // pain 

for any hydrocodone: replace nonra="hydrocodone" if strpos(drugtxt, "X") // pain 

// LG exclude hydoxychloroquine sulfate 
for any doxyc tetracycline doxicycline "mino cycline" docycyline: replace nonra="doxycycline" if  strpos(drugtxt, "X") & drugkey!="plaquenil" // tetracycline classantibiotic
// LG added more antibiotics
for any nitrofurantoin: replace nonra="nitrofurantoin" if strpos(drugtxt, "X") // antibiotics 
 
for any azithromicyn azithromycin: replace nonra="azithromycin" if strpos(drugtxt, "X") // antibiotics 
 
for any krystexxa: replace nonra="krystexxa" if strpos(drugtxt, "X") // gout   

for any prolia denosumab : replace nonra="prolia" if strpos(drugtxt, "X") // opdrug 

// LG added evenity 
for any evenity romosozumab : replace nonra="evenity" if strpos(drugtxt, "X") // opdrug 
// LG added zoledronic acid
for any "zoledronic acid" reclast: replace nonra="reclast" if strpos(drugtxt, "X") // opdrug 

for any ivig ivg immunoglobulin: replace nonra="ivig" if strpos(drugtxt, "X") // IV immunoglobulin 

for any gamunex gammagard hyqvia:  replace nonra="IgG"  if strpos(drugtxt, "X") // gamma globulin (IgG) 

for any statin pravac pravaststin zocor zetia zeta zocoor zocar niacin niaspan pravaststin lopid lipitor lopid crestor creastor crostor simvastin simastatim provastin : replace nonra="statins" if strpos(drugtxt, "X") // antihyperlipidemia 

for any tricor antara gemfibroz vytorin vitorin provastin  questran: replace nonra="lopid" if strpos(drugtxt, "X") // antihyperlipidemia 

// LG added hyoscyameic
for any hyoscyameic zantac zofran omperazole omepraz omeper  nexium prevacid prilosec protonix pepcid ddr: replace nonra="GIdrug" if strpos(drugtxt, "X")

for any lisinopril: replace nonra="ace inhibitor" if strpos(drugtxt, "X") 

for any coumadin : replace nonra="coumadin" if strpos(drugtxt, "X") // anticoagulants DVT drug

for any plavix : replace nonra="plavix" if strpos(drugtxt, "X") // platetet aggregation inhibitors CVD drug 

for any "6 mp" 6-mp 6mp purine mercapturine: replace nonra="mercaptopurine" if strpos(drugtxt, "X") // Mercaptopurine for acute lymphocytic leukemia  

for any colchicine: replace nonra="colchicine" if strpos(drugtxt, "X")

for any "d-pen" depen dpen "d-den" : replace nonra="d-penamine" if strpos(drugtxt, "X") 

for any fostamatinib: replace nonra="fostamatinib" if strpos(drugtxt, "X") 

// LG added hydrochlorthiazide
for any hctz hydrochlorthiazide hydrochlorothiazide: replace nonra="hydrochlorthiazide" if strpos(drugtxt, "X") 

for any lodine: replace nonra="lodine" if strpos(drugtxt, "X") 

for any penicillin: replace nonra="penicillin" if strpos(drugtxt, "X") 

for any prosorba: replace nonra="prosorba" if strpos(drugtxt, "X") 

for any revlimid lenalidomide: replace nonra="lenalidomide"  if strpos(drugtxt, "X") 

for any tysabri:  replace nonra="tysabri"  if strpos(drugtxt, "X") // multiple sclerosis 

for any thalidomide:  replace nonra="thalidomide"  if strpos(drugtxt, "X") // multiple sclerosis 

for any gilenya:  replace nonra="gilenya"  if strpos(drugtxt, "X") // multiple sclerosis 

for any neupogen: replace nonra="neupogen"  if strpos(drugtxt, "X")

for any atenolo:  replace nonra="atenolol"  if strpos(drugtxt, "X") // MI drug

for any amlodipine: replace nonra="amlodipine" if strpos(drugtxt, "X") // MI drug

for any diovan: replace nonra="diovan" if strpos(drugtxt, "X") // CV drug

for any spironolactone spironactone: replace nonra="spironolactone" if strpos(drugtxt, "X") // CV drug 

for any leukeran: replace nonra="leukeran" if strpos(drugtxt, "X") 

// LG: already coded as gold 
* for any myocrism: replace nonra="myocrism" if strpos(drugtxt, "X")  

// LG changed to ==
for any cycline: replace nonra="cycline" if drugtxt=="X"  

for any zyprexa: replace nonra="zyprexa"  if strpos(drugtxt, "X")

for any adeliminol: replace nonra="adeliminal"  if strpos(drugtxt, "X") 

for any advair: replace nonra="advair"  if strpos(drugtxt, "X") // COPD/Asthma therapy 

for any budesonide: replace nonra="budesonide"  if strpos(drugtxt, "X") // COPD/Asthma therapy 

for any "broncho-dilatars": replace nonra="bronchodilators"  if strpos(drugtxt, "X") // COPD/Asthma therapy 

for any provigil: replace nonra="provigil"  if strpos(drugtxt, "X")  // sleepiness

for any fluonazole: replace nonra="fluconazole"  if strpos(drugtxt, "X") // antifungal 

for any allopurinol: replace nonra="allopurinol"  if strpos(drugtxt, "X") // gult 

for any dapsone dasone: replace nonra="dapsone"  if strpos(drugtxt, "X") // anit-infective topical 

for any gabapentin:  replace nonra="gabapentin"  if strpos(drugtxt, "X") 

for any rifaximab: replace nonra="rifaximab"  if strpos(drugtxt, "X")  // antibiotics

for any vedolizumab : replace nonra="vedolizumab"  if strpos(drugtxt, "X") 

for any ozempic : replace nonra="ozempic" if strpos(drugtxt, "X") // type 2 diabetes mellitus

for any sinemet : replace nonra="sinemet" if strpos(drugtxt, "X") // Antiparkinson

for any doxipent: replace nonra="doxipent" if strpos(drugtxt, "X") //Antidepressant

for any ergocalciferol: replace nonra="vitamin D2" if strpos(drugtxt, "X")

replace nonra="avibactam" if drugtxt=="cza" // ceftazidime/avibactam


///////////////////////////////////////////////////////////////////////////////
//////////////////////////	Extract Route info from drug key and drug_name_txt
///////////////////////////////////////////////////////////////////////////////

// clean route_code 100=oral 200=SC 201=SC injection 210=IV 220=injection 

// LG 2023-08-01 if both sc and inj, then code as sc
*for any "sub cutaneous" sc sq subq "suq q" subc :  replace route_code=201 if (strpos(drugtxt, "X")  | strpos(drugtxt, " X") ) & strpos(drugtxt,"inj") & route_code==. 

for any "sub cutaneous" sc sq subq "suq q" subc "pre-filled syringe":  replace route_code=200 if (strpos(drugtxt, "X")  | strpos(drugtxt, " X") ) & route_code==. 

// if actemra, orencia or simponi  inj, should be SC injection 201 
for any inj:  replace route_code=201 if strpos(drugtxt, "X") & (drugkey=="orencia"|drugkey=="actemra"|drugkey=="simponi") & route_code==. 

// differenciate IV inj 
replace route_code=212 if (strpos(drugtxt, "(iv)")  | strpos(drugtxt, " iv") | strpos(drugtxt,  "aria"))  & strpos(drugtxt,"inj") & route_code==. 
replace route_code=210 if (strpos(drugtxt, "(iv)")  | strpos(drugtxt, " iv") | strpos(drugtxt,  "aria")) & route_code==. 

// SC and IV coded first, the rest is muscular
for any inj: replace route_code=220 if strpos(drugtxt,"X" ) & route_code==. 

// op gets a lot non-related coding 
for any op oral: replace route_code=100 if strpos(drugtxt, "X") & route_code==.  

// clean after testing 
for any "dropdown list" azothropin oprire oprione opurinol oprene iopan oprin oprim ophine oprone opine opain propionate cyclopho azathiop "in development" "open label" mercap methyloprednisone mucoph mycoph neoral "not aria" rinvop schmemicade solgarial hyoscyameic: replace route_code=. if strpos(drugtxt, "X") & route==""

// encode route_code to update route 

#delimit;
label define route_code 
100 "oral (PO)" 
200 "subcutaneous (SC)"
201 "subcutaneous (SC) injection"
210 "intravenous (IV)"
211 "intravenous (IV) infusion"
212 "intravenous (IV) injection"
220 "intramuscular (IM) injection"
, modify
;
#delimit cr;	

lab val route_code route_code
