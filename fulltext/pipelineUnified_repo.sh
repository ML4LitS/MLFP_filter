#!/bin/sh
# a script to fetch, annotate, transform, and summarize, for xml, ocr, and pdf
# input: stdin
# output: stdout
source /hps/software/users/literature/commons/scripts/SetJava11ClassPath.sh
module purge
module load perl-5.34.0-gcc-9.3.0-vj4zrze
#ML Environment for Python
source /homes/lit_otar/otar_env/bin/activate
# paths
UKPMC=/hps/software/users/literature/textmining
UKPMCXX=$UKPMC/lib
DICXX=$UKPMC/automata
OJDBC_DRIVER=/hps/software/users/literature/commons/jars/jar_db/ojdbc8.jar

#pipeline03122020.jar
OTHERS=$OJDBC_DRIVER:$UKPMCXX/ebitmjimenotools.jar:$UKPMCXX/monq.jar:$UKPMCXX/mallet.jar:$UKPMCXX/mallet-deps.jar:$UKPMCXX/marie.jar:$UKPMCXX/pipeline.jar:$UKPMCXX/commons-lang-2.4.jar:$UKPMCXX/ie.jar:$UKPMCXX/commons-io-2.0.1.jar:$UKPMCXX/jopt-simple-3.2.jar:$UKPMCXX/jackson-core-2.11.0.rc1.jar:$UKPMCXX/jackson-databind-2.11.0.rc1.jar:$UKPMCXX/jackson-annotations-2.11.0.rc1.jar
STDERR=$1

ADDTEXT="java -XX:+UseSerialGC -cp $OTHERS:$UKPMCXX/pmcxslpipe_repo.jar ebi.ukpmc.xslpipe.Pipeline -stdpipe -stageSpotText"
OUTTEXT="java -XX:+UseSerialGC -cp $OTHERS:$UKPMCXX/pmcxslpipe_repo.jar ebi.ukpmc.xslpipe.Pipeline -stdpipe -outerText"
REMBACK="java -XX:+UseSerialGC -cp $OTHERS:$UKPMCXX/pmcxslpipe_repo.jar ebi.ukpmc.xslpipe.Pipeline -stdpipe -removeBackPlain -fixEBIns"


SENTENCISER="java -XX:+UseSerialGC -cp $OTHERS:$UKPMCXX/Sentenciser160415.jar ebi.ukpmc.sentenciser.Sentencise -rs '<article[^>]+>' -ok -ie UTF-8 -oe UTF-8"
SENTCLEANER="java -XX:+UseSerialGC -cp $OTHERS:$UKPMCXX/Sentenciser160415.jar ebi.ukpmc.sentenciser.SentCleaner -stdpipe"
SEC_TAG="perl $UKPMC/bin/SectionTagger_XML_inline_repo.perl"
RDF_GEN="perl $UKPMC/bin/gen_ttl170731.perl"
JSON_DOC_GEN="perl $UKPMC/bin/gen_json_doc170731.perl"
JSON_API_GEN="perl $UKPMC/bin/gen_json_api_unified_repo_Acs.perl"


SP_DICTIONARY="$DICXX/swissprot_Sept2014.2.3.mwt"
ABB_FILTER="perl $UKPMC/bin/ProteinAbbreviationFilterUnified.perl $SP_DICTIONARY"

SP_DICT2="java -XX:+UseSerialGC -Xmx3000m -XX:MinHeapFreeRatio=10 -XX:MaxHeapFreeRatio=10 -cp $OTHERS monq.programs.DictFilter -t elem -e plain -ie UTF-8 -oe UTF-8 $SP_DICTIONARY"
OR_DICT="java -XX:+UseSerialGC -Xmx13000m -XX:MinHeapFreeRatio=10 -XX:MaxHeapFreeRatio=10 -cp $OTHERS monq.programs.DictFilter -t elem -e plain -ie UTF-8 -oe UTF-8 $DICXX/Organisms150507.2.mwt"
GO_DICT="java -XX:+UseSerialGC -Xmx3000m -XX:MinHeapFreeRatio=10 -XX:MaxHeapFreeRatio=10 -cp $OTHERS monq.programs.DictFilter -t elem -e plain -ie UTF-8 -oe UTF-8 $DICXX/go150429.2.mwt"
DI_DICT="java -XX:+UseSerialGC -Xms5G -Xmx5G -XX:MinHeapFreeRatio=10 -XX:MaxHeapFreeRatio=10 -cp $OTHERS monq.programs.DictFilter -t elem -e plain -ie UTF-8 -oe UTF-8 $DICXX/DiseaseDictionary.mwt"
CH_DICT="java -XX:+UseSerialGC -Xms5000m -Xmx6G -XX:MinHeapFreeRatio=10 -XX:MaxHeapFreeRatio=10 -cp $OTHERS monq.programs.DictFilter -t elem -e plain -ie UTF-8 -oe UTF-8 $DICXX/chebi150615_wo_role.2.mwt"
EFO_DICT="java -XX:+UseSerialGC -Xmx1000m -XX:MinHeapFreeRatio=10 -XX:MaxHeapFreeRatio=10 -cp $OTHERS monq.programs.DictFilter -t elem -e plain -ie UTF-8 -oe UTF-8 $DICXX/efo150428.mwt"
AC_DICT="java -XX:+UseSerialGC -Xms1000m -Xmx1G -XX:MinHeapFreeRatio=10 -XX:MaxHeapFreeRatio=10 -cp $OTHERS monq.programs.DictFilter -t elem -e plain -ie UTF-8 -oe UTF-8 $DICXX/acc200116.mwt"
AC2_DICT="java -XX:+UseSerialGC -Xms1000m -Xmx1G -XX:MinHeapFreeRatio=10 -XX:MaxHeapFreeRatio=10 -cp $OTHERS monq.programs.DictFilter -t elem -e plain -ie UTF-8 -oe UTF-8 $DICXX/acc_230726_II.mwt"
RE_DICT="java -XX:+UseSerialGC -Xms1000m -Xmx1G -XX:MinHeapFreeRatio=10 -XX:MaxHeapFreeRatio=10 -cp $OTHERS monq.programs.DictFilter -t elem -e plain -ie UTF-8 -oe UTF-8 $DICXX/resources200116.mwt" 
MET_DICT="java -XX:+UseSerialGC -Xms1000m -Xmx1G -XX:MinHeapFreeRatio=10 -XX:MaxHeapFreeRatio=10 -cp $OTHERS monq.programs.DictFilter -t elem -e plain -ie UTF-8 -oe UTF-8 $DICXX/experimentalMethods_Dict.mwt"


BNCFILTER="java -XX:+UseSerialGC -cp $OTHERS -Xmx400m -XX:MinHeapFreeRatio=15 -XX:MaxHeapFreeRatio=15 marie.bnc.BncFilter 160"
CHEBIBNCFILTER="java -XX:+UseSerialGC -cp $OTHERS -Xmx400m -XX:MinHeapFreeRatio=15 -XX:MaxHeapFreeRatio=15 ebi.ukpmc.pipeline.filter.ChEBIBncFilter 250"

GN_FILTER="java -XX:+UseSerialGC -cp $UKPMCXX/genefilter160511.jar:$OTHERS ebi.ukpmc.gene.GeneFilter"
CH_FILTER="java -XX:+UseSerialGC -cp $UKPMCXX/chebifilter160428.jar:$OTHERS ebi.ukpmc.chebi.ChEBIFilter"
OR_FILTER="java -XX:+UseSerialGC -cp $UKPMCXX/organismsfilter.jar:$OTHERS -Xmx1024m -Xms1024m ebi.ukpmc.organisms.OrganismsFilter"

ACC_VAL="java -XX:+UseSerialGC -cp $UKPMCXX/commons-cli-1.2.jar:$UKPMCXX/AnnotationFilter-assembly-v5.0.jar:$OTHERS ukpmc.AnnotationFilter -stdpipe -secTag"

ACC_VAL_SEN="java -XX:+UseSerialGC -cp $UKPMCXX/commons-cli-1.2.jar:$UKPMCXX/AnnotationFilter-assembly-v5.0.jar:$OTHERS ukpmc.AnnotationFilter -stdpipe"

WHATIZIT2IEXML="java -XX:+UseSerialGC -Xmx512M -Xms512M -cp $OTHERS ebi.ukpmc.pipeline.normalize.whatizit2iexml"
NORMALIZEIDS="java -XX:+UseSerialGC -cp $OTHERS ebi.ukpmc.pipeline.normalize.NormalizeIds"

XML_SUMMARY="java -XX:+UseSerialGC -cp $OTHERS:$UKPMCXX/pmcxslpipe_repo.jar ebi.ukpmc.xslpipe.Pipeline -stdpipe -xml2summary"
XML_OA="java -XX:+UseSerialGC -cp $OTHERS:$UKPMCXX/pmcxslpipe_repo.jar ebi.ukpmc.xslpipe.Pipeline -stdpipe -xml2oa"

OCR_SUMMARY="java -XX:+UseSerialGC -cp $OTHERS ebi.ukpmc.pipeline.xslt.Pipeline -ocr2summary"
FETCH="java -XX:+UseSerialGC -cp $OTHERS -Doracle.net.tns_admin=/hps/software/dbtools/oracle/client/tnsnames ebi.ukpmc.pipeline.fetch.FulltextFetcherOA "


# ML Injection here
PYTHON_ENV="python"
ML_FILTER="/hps/software/users/literature/textmining/mlfp_prod_pipeline/ML_FP_Filter_Production_V08.py -z GP,DS,OG "

# pipelines, this is based on the pipeline diagram
if [ "$1" = "help" ]; then
  echo "usage: program error_log mode file_format"

# fetch
elif [ "$2" = "fetch" ] && [ "$3" = "xml" ]; then
  $FETCH --dataDir $4 --timestamp $5 --maxDocs $6 --summaryDir $7 --dbUserCDB $9 --dbPwdCDB ${10} --dbUrlCDB ${11} --dbSchemaCDB ${12} --domainAPI ${13} 1>> $8 2>> $STDERR 
elif [ "$2" = "fetchPmcids" ] && [ "$3" = "xml" ]; then
  $FETCH --dataDir $4 --pmcids $5  --maxDocs $6 --summaryDir $7 --dbUserCDB $9 --dbPwdCDB ${10} --dbUrlCDB ${11} --dbSchemaCDB ${12} --domainAPI ${13} 1>> $8 2>> $STDERR
elif [ "$2" = "fetchRang" ] && [ "$3" = "xml" ]; then
  $FETCH --dataDir $4 --timestamp $5 --timestampEnd ${14}  --maxDocs $6 --summaryDir $7 --dbUserCDB $9 --dbPwdCDB ${10} --dbUrlCDB ${11} --dbSchemaCDB ${12} --domainAPI ${13} 1>> $8 2>> $STDERR

# annotate
elif [ "$2" = "annotation" ] && [ "$3" = "xml" ]; then
 sed 's/"article-type=/" article-type=/' 2>> $STDERR | $SEC_TAG 2>> $STDERR | $ADDTEXT 2>> $STDERR | $OUTTEXT 2>> $STDERR | $SENTENCISER 2>> $STDERR | $AC_DICT 2>> $STDERR | $RE_DICT 2>> $STDERR | $ACC_VAL 2>> $STDERR | $ACC_VAL_SEN 2>> $STDERR | $SENTCLEANER 2>> $STDERR | $REMBACK 2>> $STDERR | $SP_DICT2 2>> $STDERR | $BNCFILTER 2>> $STDERR | $GN_FILTER 2>> $STDERR | $ABB_FILTER 2>> $STDERR | $OR_DICT 2>> $STDERR | $OR_FILTER 2>> $STDERR | $MET_DICT 2>> $STDERR | $GO_DICT 2>> $STDERR | $DI_DICT 2>> $STDERR | $CH_DICT 2>> $STDERR | $CHEBIBNCFILTER 2>> $STDERR | $CH_FILTER 2>> $STDERR | $PYTHON_ENV $ML_FILTER 2>> $STDERR | $SENTCLEANER 2>> $STDERR
elif [ "$2" = "annotation_short" ] && [ "$3" = "xml" ]; then
   sed 's/"article-type=/" article-type=/' 2>> $STDERR | $SEC_TAG 2>> $STDERR | $ADDTEXT 2>> $STDERR | $OUTTEXT 2>> $STDERR | $SENTENCISER 2>> $STDERR | $AC_DICT 2>> $STDERR | $AC2_DICT 2>> $STDERR | $RE_DICT 2>> $STDERR | $ACC_VAL 2>> $STDERR | $ACC_VAL_SEN 2>> $STDERR | $SENTCLEANER 2>> $STDERR | $REMBACK 2>> $STDERR | $SP_DICT2 2>> $STDERR | $BNCFILTER 2>> $STDERR | $GN_FILTER 2>> $STDERR | $ABB_FILTER 2>> $STDERR | $SENTCLEANER 2>> $STDERR



# 4summary
elif [ "$2" = "4summary" ] && [ "$3" = "xml" ]; then
  $WHATIZIT2IEXML 2>> $STDERR | $NORMALIZEIDS 2>> $STDERR | $XML_SUMMARY 2>> $STDERR | grep -v '^<!DOCTYPE' 2>> $STDERR | grep -v '^$' 2>> $STDERR
elif [ "$2" = "4summary" ] && [ "$3" = "ocr" ]; then
  $WHATIZIT2IEXML 2>> $STDERR | $NORMALIZEIDS 2>> $STDERR | $OCR_SUMMARY 2>> $STDERR | grep -v '^<!DOCTYPE' 2>> $STDERR
elif [ "$2" = "4summary" ] && [ "$3" = "pdf" ]; then
  $WHATIZIT2IEXML 2>> $STDERR | $NORMALIZEIDS 2>> $STDERR | $OCR_SUMMARY 2>> $STDERR | grep -v '^<!DOCTYPE' 2>> $STDERR

# 4oa
elif [ "$2" = "4oa" ] && [ "$3" = "xml" ]; then
  $WHATIZIT2IEXML 2>> $STDERR | $NORMALIZEIDS 2>> $STDERR | $XML_OA 2>> $STDERR | grep -v '^<!DOCTYPE' 2>> $STDERR

# 4rdf
elif [ "$2" = "4rdf" ] && [ "$3" = "xml" ]; then
  OUTPUTSTREAM_PMCID_LIST=$4
  $WHATIZIT2IEXML 2>> $STDERR | $NORMALIZEIDS 2>> $STDERR | $XML_OA 2>> $STDERR | grep -v '^<!DOCTYPE' 2>> $STDERR | $RDF_GEN 2>> $OUTPUTSTREAM_PMCID_LIST
elif [ "$2" = "4jsondoc" ] && [ "$3" = "xml" ]; then
  OUTPUTSTREAM_PMCID_LIST=$4
  $WHATIZIT2IEXML 2>> $STDERR | $NORMALIZEIDS 2>> $STDERR | $XML_OA 2>> $STDERR | grep -v '^<!DOCTYPE' 2>> $STDERR | $JSON_DOC_GEN 2>> $OUTPUTSTREAM_PMCID_LIST
elif [ "$2" = "4jsonapi" ] && [ "$3" = "xml" ]; then
  OUTPUTSTREAM_PMCID_LIST=$4
  $WHATIZIT2IEXML 2>> $STDERR | $NORMALIZEIDS 2>> $STDERR | $XML_OA 2>> $STDERR | grep -v '^<!DOCTYPE' 2>> $STDERR | $JSON_API_GEN 2>> $OUTPUTSTREAM_PMCID_LIST
elif [ "$2" = "pre_4jsonapi1" ] && [ "$3" = "xml" ]; then
  OUTPUTSTREAM_PMCID_LIST=$4
  $WHATIZIT2IEXML 2>> $STDERR 
elif [ "$2" = "pre_4jsonapi2" ] && [ "$3" = "xml" ]; then
OUTPUTSTREAM_PMCID_LIST=$4
$WHATIZIT2IEXML 2>> $STDERR | $NORMALIZEIDS 2>> $STDERR
elif [ "$2" = "pre_4jsonapi3" ] && [ "$3" = "xml" ]; then
OUTPUTSTREAM_PMCID_LIST=$4
$WHATIZIT2IEXML 2>> $STDERR | $NORMALIZEIDS 2>> $STDERR | $XML_OA 2>> $STDERR | grep -v '^<!DOCTYPE' 2>> $STDERR
elif [ "$2" = "4jsonapi_test" ] && [ "$3" = "xml" ]; then
   OUTPUTSTREAM_PMCID_LIST=$4
   $WHATIZIT2IEXML 2>> $STDERR | $NORMALIZEIDS 2>> $STDERR | $XML_OA 2>> $STDERR | grep -v '^<!DOCTYPE' 2>> $STDERR | $JSON_API_GEN 2>> $STDERR
elif [ "$2" = "sentencize" ] && [ "$3" = "xml" ]; then
 sed 's/"article-type=/" article-type=/' 2>> $STDERR | $SEC_TAG 2>> $STDERR | $ADDTEXT 2>> $STDERR | $OUTTEXT 2>> $STDERR | $SENTENCISER 2>> $STDERR
fi

# end
#Deactivate ML enironment
deactivate
