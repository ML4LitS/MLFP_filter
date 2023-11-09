createDirectory(){
    if [ -d "$1" ]
    then
      rm -R "$1"
      echo "Removing dir $1"
    fi

    if [ ! -d "$1" ]
    then
      mkdir -p "$1"
      echo "Created dir $1"
    fi
}

initiateVariables(){
        echo "Initializing variables"
	MAIL_RECIPIENTS="<your_email>"
       
}


getRootDirectory(){
	 if [ "$1" = "fulltext" ]
         then
                SCILITE_PIPELINE_ROOT_DIRECTORY="/hps/nobackup/literature/text-mining/mlfp_prod/daily_pipeline_api/$2/fulltext"
         else
                SCILITE_PIPELINE_ROOT_DIRECTORY="/hps/nobackup/literature/text-mining/mlfp_prod/daily_pipeline_api/$2/abstract"
         fi
}


getScilitePipelineValue(){
        #echo "first parameter $1 $2 $3"
        getRootDirectory "$2" "$3"
	if [ "$1" = "root_dir" ]
     	then
      		SCILITE_PIPELINE_VALUE=$SCILITE_PIPELINE_ROOT_DIRECTORY
        elif [ "$1" = "json_api_dir" ]
        then
                SCILITE_PIPELINE_VALUE="$SCILITE_PIPELINE_ROOT_DIRECTORY/json_api"
        elif [ "$1" = "json_highlight_dir" ]
        then    
                SCILITE_PIPELINE_VALUE="$SCILITE_PIPELINE_ROOT_DIRECTORY/json_highlight"
        elif [ "$1" = "4summary_dir" ]
        then
                SCILITE_PIPELINE_VALUE="$SCILITE_PIPELINE_ROOT_DIRECTORY/tm_summary/xml/4summary"
         elif [ "$1" = "4summary_dir_root" ]
        then
                SCILITE_PIPELINE_VALUE="$SCILITE_PIPELINE_ROOT_DIRECTORY/tm_summary/"
        elif [ "$1" = "tar_dir" ]
        then
                SCILITE_PIPELINE_VALUE="$SCILITE_PIPELINE_ROOT_DIRECTORY/tar"
        elif [ "$1" = "rdf_dir" ]
        then
               	SCILITE_PIPELINE_VALUE="$SCILITE_PIPELINE_ROOT_DIRECTORY/rdf"
        elif [ "$1" = "log_dir" ]
        then
               	SCILITE_PIPELINE_VALUE="$SCILITE_PIPELINE_ROOT_DIRECTORY/log"
        elif [ "$1" = "summary_dir" ]
        then
               	SCILITE_PIPELINE_VALUE="$SCILITE_PIPELINE_ROOT_DIRECTORY/summary"
        elif [ "$1" = "source_dir" ]
        then
               	SCILITE_PIPELINE_VALUE="$SCILITE_PIPELINE_ROOT_DIRECTORY/source"
        elif [ "$1" = "source_dir_job" ]
        then
               	SCILITE_PIPELINE_VALUE="$SCILITE_PIPELINE_ROOT_DIRECTORY/job_$4/source"
        elif [ "$1" = "annotation_dir_job" ]
        then
               	SCILITE_PIPELINE_VALUE="$SCILITE_PIPELINE_ROOT_DIRECTORY/job_$4/annotation"
        elif [ "$1" = "json_dir_job" ]
        then
                SCILITE_PIPELINE_VALUE="$SCILITE_PIPELINE_ROOT_DIRECTORY/json_api_$4"
        elif [ "$1" = "log_file" ]
        then
               	SCILITE_PIPELINE_VALUE="$SCILITE_PIPELINE_ROOT_DIRECTORY/log/log.txt"
        elif [ "$1" = "error_file" ]
        then
               	SCILITE_PIPELINE_VALUE="$SCILITE_PIPELINE_ROOT_DIRECTORY/log/error.txt"
        elif [ "$1" = "mongo_file" ]
        then
                SCILITE_PIPELINE_VALUE="$SCILITE_PIPELINE_ROOT_DIRECTORY/log/mongo.txt"
        elif [ "$1" = "mongo_file_job" ]
        then
                SCILITE_PIPELINE_VALUE="$SCILITE_PIPELINE_ROOT_DIRECTORY/log/mongo_$4.txt"
        elif [ "$1" = "summary_mongo_loaded" ]
        then
                SCILITE_PIPELINE_VALUE="$SCILITE_PIPELINE_ROOT_DIRECTORY/summary/mongo_loaded.csv"
	elif [ "$1" = "summary_file_api" ]
 	then
               	if [ "$2" = "fulltext" ]
               	then
               		SCILITE_PIPELINE_VALUE="$SCILITE_PIPELINE_ROOT_DIRECTORY/summary/list_pmcids_api_json.csv"
                else
			SCILITE_PIPELINE_VALUE="$SCILITE_PIPELINE_ROOT_DIRECTORY/summary/list_abstracts_api_json.csv"
                fi
        elif [ "$1" = "summary_file_highlight" ]
        then
                if [ "$2" = "fulltext" ]
                then
                        SCILITE_PIPELINE_VALUE="$SCILITE_PIPELINE_ROOT_DIRECTORY/summary/list_pmcids_highlight_json.csv"
                else
                        SCILITE_PIPELINE_VALUE="$SCILITE_PIPELINE_ROOT_DIRECTORY/summary/list_abstracts_highlight_json.csv"
                fi
        elif [ "$1" = "summary_file_rdf" ]
        then
                if [ "$2" = "fulltext" ]
                then
                        SCILITE_PIPELINE_VALUE="$SCILITE_PIPELINE_ROOT_DIRECTORY/summary/list_pmcids_rdf.csv"
                else
                        SCILITE_PIPELINE_VALUE="$SCILITE_PIPELINE_ROOT_DIRECTORY/summary/list_abstracts_rdf.csv"
                fi
        elif [ "$1" = "rdf_flag_generated" ]
        then
                SCILITE_PIPELINE_VALUE="$SCILITE_PIPELINE_ROOT_DIRECTORY/rdf_generated.txt"
        elif [ "$1" = "flag_job_finished" ]
        then
                SCILITE_PIPELINE_VALUE="$SCILITE_PIPELINE_ROOT_DIRECTORY/finished_job_$4"
        elif [ "$1" = "flag_mongo_job_finished" ]
        then
                SCILITE_PIPELINE_VALUE="$SCILITE_PIPELINE_ROOT_DIRECTORY/finished_job_mongo_loading_$4"
	elif [ "$1" = "java_classpath" ]
        then
                folder_java="/hps/software/users/literature/textmining/scilite_loader"
		lib_java="$folder_java/lib"
		main_jar=$folder_java/scilite_loader.jar
		OJDBC_DRIVER=/hps/software/users/literature/commons/jars/jar_db/ojdbc8.jar
		CP_JAVA=".:$main_jar:$OJDBC_DRIVER:$lib_java/*"
                SCILITE_PIPELINE_VALUE=$CP_JAVA
	fi
}
