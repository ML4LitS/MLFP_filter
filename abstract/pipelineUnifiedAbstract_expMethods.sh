#!/bin/sh
# a script to fetch, annotate, transform, and summarize, for xml, ocr, and pdf
# input: stdin
# output: stdout
source /hps/software/users/literature/commons/scripts/SetJava8ClassPath.sh
# paths
module purge
module load perl-5.34.0-gcc-9.3.0-vj4zrze
UKPMC=/hps/software/users/literature/textmining
UKPMCXX=$UKPMC/lib
DICXX=$UKPMC/automata
OJDBC_DRIVER=/hps/software/users/literature/commons/jars/jar_db/ojdbc8.jar


OTHERS=$OJDBC_DRIVER:$UKPMCXX/ebitmjimenotools.jar:$UKPMCXX/monq.jar:$UKPMCXX/mallet.jar:$UKPMCXX/mallet-deps.jar:$UKPMCXX/marie.jar:$UKPMCXX/pipeline180822_notOA.jar:$UKPMCXX/commons-lang-2.4.jar:$UKPMCXX/ie.jar:$UKPMCXX/commons-io-2.0.1.jar:$UKPMCXX/jopt-simple-3.2.jar

# commands
# works as stdin and stdout
STDERR=$1

ADDTEXT="java -XX:+UseSerialGC -cp $OTHERS:$UKPMCXX/pmcxslpipe20200107.jar ebi.ukpmc.xslpipe.Pipeline -stdpipe -stageSpotText"
OUTTEXT="java -XX:+UseSerialGC -cp $OTHERS:$UKPMCXX/pmcxslpipe20200107.jar ebi.ukpmc.xslpipe.Pipeline -stdpipe -outerText"
REMBACK="java -XX:+UseSerialGC -cp $OTHERS:$UKPMCXX/pmcxslpipe20200107.jar ebi.ukpmc.xslpipe.Pipeline -stdpipe -removeBackPlain -fixEBIns"

SENTENCISER="java -XX:+UseSerialGC -cp $OTHERS:$UKPMCXX/Sentenciser160415.jar ebi.ukpmc.sentenciser.Sentencise -rs '<article[^>]+>' -ok -ie UTF-8 -oe UTF-8"
SENTCLEANER="java -XX:+UseSerialGC -cp $OTHERS:$UKPMCXX/Sentenciser160415.jar ebi.ukpmc.sentenciser.SentCleaner -stdpipe"
SEC_TAG="perl $UKPMC/bin/SectionTagger_XML_inline_DA.perl" 
JSON_DOC_GEN="perl $UKPMC/bin/gen_json_doc170731abs.perl"
JSON_API_GEN="perl $UKPMC/bin/gen_json_api20181031abs_unified_Acs.perl"

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
MET_DICT="$JAVA_HOME/bin/java -XX:+UseSerialGC -Xms1000m -Xmx1G -XX:MinHeapFreeRatio=10 -XX:MaxHeapFreeRatio=10 -cp $OTHERS monq.programs.DictFilter -t elem -e plain -ie UTF-8 -oe UTF-8 $DICXX/experimentalMethods_Dict.mwt"


SP_FILTER="$JAVA_HOME/bin/java -XX:+UseSerialGC -cp $UKPMCXX/spfilter.jar:$OTHERS ebi.ukpmc.sp.SPFilter"
BNCFILTER="$JAVA_HOME/bin/java -XX:+UseSerialGC -cp $OTHERS -Xmx400m -XX:MinHeapFreeRatio=15 -XX:MaxHeapFreeRatio=15 marie.bnc.BncFilter 160"
CHEBIBNCFILTER="$JAVA_HOME/bin/java -XX:+UseSerialGC -cp $OTHERS -Xmx400m -XX:MinHeapFreeRatio=15 -XX:MaxHeapFreeRatio=15 ebi.ukpmc.pipeline.filter.ChEBIBncFilter 250"

GN_FILTER="$JAVA_HOME/bin/java -XX:+UseSerialGC -cp $UKPMCXX/genefilter160511.jar:$OTHERS ebi.ukpmc.gene.GeneFilter"
CH_FILTER="$JAVA_HOME/bin/java -XX:+UseSerialGC -cp $UKPMCXX/chebifilter160428.jar:$OTHERS ebi.ukpmc.chebi.ChEBIFilter"
OR_FILTER="$JAVA_HOME/bin/java -XX:+UseSerialGC -cp $UKPMCXX/organismsfilter.jar:$OTHERS -Xmx1024m -Xms1024m ebi.ukpmc.organisms.OrganismsFilter"

ACC_VAL="$JAVA_HOME/bin/java -XX:+UseSerialGC -cp $UKPMCXX/commons-cli-1.2.jar:$UKPMCXX/AnnotationFilter-assembly-v5.0.jar:$OTHERS ukpmc.AnnotationFilter -stdpipe -secTag"

ACC_VAL_SEN="$JAVA_HOME/bin/java -XX:+UseSerialGC -cp $UKPMCXX/commons-cli-1.2.jar:$UKPMCXX/AnnotationFilter-assembly-v5.0.jar:$OTHERS ukpmc.AnnotationFilter -stdpipe"

WHATIZIT2IEXML="$JAVA_HOME/bin/java -XX:+UseSerialGC -Xmx512M -Xms512M -cp $OTHERS ebi.ukpmc.pipeline.normalize.whatizit2iexml"
NORMALIZEIDS="$JAVA_HOME/bin/java -XX:+UseSerialGC -cp $OTHERS ebi.ukpmc.pipeline.normalize.NormalizeIds"

XML_SUMMARY="$JAVA_HOME/bin/java -XX:+UseSerialGC -cp $OTHERS:$UKPMCXX/pmcxslpipe20200107.jar ebi.ukpmc.xslpipe.Pipeline -stdpipe -xml2summary"
XML_OA="$JAVA_HOME/bin/java -XX:+UseSerialGC -cp $OTHERS:$UKPMCXX/pmcxslpipe20200107.jar ebi.ukpmc.xslpipe.Pipeline -stdpipe -xml2oa4abs"
OCR_SUMMARY="$JAVA_HOME/bin/java -XX:+UseSerialGC -cp $OTHERS ebi.ukpmc.pipeline.xslt.Pipeline -ocr2summary"
FETCH="$JAVA_HOME/bin/java -XX:+UseSerialGC -cp $OTHERS -Doracle.net.tns_admin=/hps/software/dbtools/oracle/client/tnsnames ebi.ukpmc.pipeline.fetch.abstracts.AbstractFetcher"


# pipelines, this is based on the pipeline diagram
if [ "$1" = "help" ]; then
  echo "usage: program error_log mode file_format"
# fetch
elif [ "$2" = "fetch_abstract" ]; then
  $FETCH --dataDir $3 --timestampStart $4 --maxDocs $5 --summaryDir $6  --dbUserCDB $8 --dbPwdCDB $9 --dbUrlCDB ${10} --dbSchemaCDB ${11}  1>> ${7} 2>> $STDERR 
elif [ "$2" = "fetch_abstract_range" ]; then
  $FETCH --dataDir $3 --timestampStart $4 --timestampEnd ${12} --maxDocs $5 --summaryDir $6  --dbUserCDB $8 --dbPwdCDB $9 --dbUrlCDB ${10} --dbSchemaCDB ${11}  1>> ${7} 2>> $STDERR 
elif [ "$2" = "fetch_abstract_pmid" ]; then
  $FETCH --dataDir $3 --pmids $4 --maxDocs $5 --summaryDir $6  --dbUserCDB $8 --dbPwdCDB $9 --dbUrlCDB ${10} --dbSchemaCDB ${11}  1>> ${7} 2>> $STDERR
elif [ "$2" = "fetch" ] && [ "$3" = "ocr" ]; then
  $FETCH --ext $3 --dataDir $4 --timestamp $5 --dbUser $6 --dbPwd $7 --dbUrl $8  --dbSchema $9  --maxDocs ${10} --summaryDir ${11} --dbUserCDB ${13} --dbPwdCDB ${14} --dbUrlCDB ${15} --dbSchemaCDB ${16} 1>> ${12} 2>> $STDERR
elif [ "$2" = "fetch" ] && [ "$3" = "pdf" ]; then
  $FETCH --ext $3 --dataDir $4 --timestamp $5 --dbUser $6 --dbPwd $7 --dbUrl $8  --dbSchema $9  --maxDocs ${10} --summaryDir ${11} --dbUserCDB ${13} --dbPwdCDB ${14} --dbUrlCDB ${15} --dbSchemaCDB ${16} 1>> ${12} 2>> $STDERR

# annotate
elif [ "$2" = "annotation" ]; then

   sed 's/^<articles>//' 2>> $STDERR | sed 's/^<\/articles>//' 2>> $STDERR | sed 's/^<article>/<!DOCTYPE "JATS-archivearticle1.dtd">\n<article>/' 2>> $STDERR | $ADDTEXT 2>> $STDERR | $OUTTEXT 2>> $STDERR | $SENTENCISER 2>> $STDERR | $AC_DICT 2>> $STDERR | $RE_DICT 2>> $STDERR | $ACC_VAL 2>> $STDERR | $ACC_VAL_SEN 2>> $STDERR | $SENTCLEANER 2>> $STDERR | $REMBACK 2>> $STDERR | $SP_DICT2 2>> $STDERR | $BNCFILTER 2>> $STDERR | $GN_FILTER 2>> $STDERR | $ABB_FILTER 2>> $STDERR | $OR_DICT 2>> $STDERR | $OR_FILTER 2>> $STDERR | $MET_DICT 2>> $STDERR | $GO_DICT 2>> $STDERR | $DI_DICT 2>> $STDERR | $CH_DICT 2>> $STDERR | $CHEBIBNCFILTER 2>> $STDERR | $CH_FILTER 2>> $STDERR | $SENTCLEANER 2>> $STDERR


elif [ "$2" = "annotation" ] && [ "$3" = "ocr" ]; then
  $SENTENCISER 2>> $STDERR | $AC_DICT 2>> $STDERR | $AC2_DICT 2>> $STDERR | $ACC_VAL 2>> $STDERR | $SP_DICT2 2>> $STDERR | $BNCFILTER 2>> $STDERR | $OR_DICT 2>> $STDERR | $OR_FILTER 2>> $STDERR | $GO_DICT 2>> $STDERR | $DI_DICT 2>> $STDERR | $CH_DICT 2>> $STDERR | $CHEBIBNCFILTER 2>> $STDERR | $CH_FILTER 2>> $STDERR | $EFO_DICT 2>> $STDERR
elif [ "$2" = "annotation" ] && [ "$3" = "pdf" ]; then
  $SENTENCISER 2>> $STDERR | $AC_DICT 2>> $STDERR | $AC2_DICT 2>> $STDERR | $ACC_VAL 2>> $STDERR | $SP_DICT2 2>> $STDERR | $BNCFILTER 2>> $STDERR | $OR_DICT 2>> $STDERR | $OR_FILTER 2>> $STDERR | $GO_DICT 2>> $STDERR | $DI_DICT 2>> $STDERR | $CH_DICT 2>> $STDERR | $CHEBIBNCFILTER 2>> $STDERR | $CH_FILTER 2>> $STDERR | $EFO_DICT 2>> $STDERR

# 4summary
elif [ "$2" = "4summary" ] && [ "$3" = "xml" ]; then
  $WHATIZIT2IEXML 2>> $STDERR | $NORMALIZEIDS 2>> $STDERR | $XML_SUMMARY 2>> $STDERR | grep -v '^<!DOCTYPE' 2>> $STDERR
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
elif [ "$2" = "4jsondoc" ]; then
  OUTPUTSTREAM_PMCID_LIST=$3
  $WHATIZIT2IEXML 2>> $STDERR | $NORMALIZEIDS 2>> $STDERR | $XML_OA 2>> $STDERR | grep -v '^<!DOCTYPE' 2>> $STDERR | $JSON_DOC_GEN 2>> $OUTPUTSTREAM_PMCID_LIST
elif [ "$2" = "4jsonapi" ]; then
  OUTPUTSTREAM_PMCID_LIST=$3
  $WHATIZIT2IEXML 2>> $STDERR | $NORMALIZEIDS 2>> $STDERR | $XML_OA 2>> $STDERR | grep -v '^<!DOCTYPE' 2>> $STDERR | $JSON_API_GEN 2>> $OUTPUTSTREAM_PMCID_LIST
elif [ "$2" = "4jsonapi_test" ]; then
  OUTPUTSTREAM_PMCID_LIST=$3
  $WHATIZIT2IEXML 2>> $STDERR | $NORMALIZEIDS 2>> $STDERR | $XML_OA 2>> $STDERR | grep -v '^<!DOCTYPE' 2>> $STDERR | $JSON_API_GEN 2>> $STDERR
elif [ "$2" = "4jsonann" ] && [ "$3" = "xml" ]; then
  OUTPUTSTREAM_PMCID_LIST=$4
  $WHATIZIT2IEXML 2>> $STDERR | $NORMALIZEIDS 2>> $STDERR | $XML_OA 2>> $STDERR | grep -v '^<!DOCTYPE' 2>> $STDERR | $JSON_ANN_GEN 2>> $OUTPUTSTREAM_PMCID_LIST

fi

# end
