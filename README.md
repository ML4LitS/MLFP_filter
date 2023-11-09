# MLFP_filter
## Europe PMC Machine Learning Filter for Removing False Positives from Dictionary Annotations

This repository contains the Europe PMC Machine Learning Filter (MLFP_filter) designed to reduce false positives in dictionary annotations. The system is structured into two main pipelines: the Abstract pipeline and the Fulltext pipeline.

### Initial Setup
Before initiating the pipelines, ensure that the following environment variables are set to store daily articles and text-mined results:

- `<your_path_where_you_like_to_store_data>/$TODAY_DATE/fulltext`
- `<your_path_where_you_like_to_store_data>/$TODAY_DATE/abstract`

The script `bsub_scilite_pipeline.sh` is used to create these directories.

### Full Text Pipeline
The Full Text Pipeline is initiated using the script `scilite_pipeline.sh`, which also triggers the Abstract pipeline.

#### Running the Fulltext Pipeline
To run the Fulltext pipeline, use the following parameters:

- `PIPELINE_PATH_FULLTEXT="/fulltext/pipelineUnified_repo.sh"`
- `NUM_FILE_X_JOB_FULLTEXT=2`

The script `pipelineUnified_repo.sh` is responsible for executing all processes within the Fulltext pipeline. For instance, the command:

```
sh scilite_fulltext_pipeline.sh $TIMESTAMP $TODAY_DATE $PIPELINE_PATH_FULLTEXT $NUM_FILE_X_JOB_FULLTEXT
```

calls the `scilite_fulltext_pipeline.sh` script, which fetches data based on the `$TODAY_DATE` parameter.

#### Running the Abstract Pipeline
The Abstract pipeline is similarly initiated with the following parameters:

- `PIPELINE_PATH_ABSTRACT="abstract/pipelineUnifiedAbstract_expMethods.sh"`
- `NUM_FILE_X_JOB_ABSTRACT=2`

The command:

```
sh /hps/software/users/literature/textmining/abstract/scilite_abstract_pipeline.sh $TIMESTAMP $TODAY_DATE $PIPELINE_PATH_ABSTRACT $NUM_FILE_X_JOB_ABSTRACT
```

triggers the main script for the Abstract pipeline, which fetches data based on the `$TODAY_DATE`.

### Common Pipeline Overview
Both pipelines operate similarly, with the primary difference being the source of articles fetched. The general workflow is as follows:

#### Fetch Process
- For the Full Text pipeline, the `ebi.ukpmc.pipeline.fetch.FulltextFetcherOA.java` class is invoked. The code is available on Git: `https://USERNAME@scm.ebi.ac.uk/git/lit-textmining-annotationPipeline.git`. It takes multiple arguments, including database configurations, and uses the `--timestamp` option to fetch data from the `PMC_INFO` table where `timestamp > $DATE_PROVIDED`.
- For the Abstract pipeline, the `ebi.ukpmc.pipeline.fetch.abstracts.AbstractFetcher.java` class is used to fetch data from the `CITATIONS` table where `c.date_update > $DATE_PROVIDED`.

#### Annotation Process
After fetching, the pipeline creates separate jobs for processing the source files. The annotation process involves several steps, including sentence segmentation, cleaning, and applying ML filters and dictionaries. These processes are executed using scripts and binaries located at:

- `/hps/software/users/literature/textmining/bin`
- `/hps/software/users/literature/textmining/lib`

Each step's output serves as the input for the subsequent step, culminating in the annotated data being written to the `job_x/annotation` folder.

#### JSON Generation Process
Annotated files are compiled, and additional Perl scripts generate JSON from the annotated XML files. These JSON files are then placed in the `json_api` folder within the daily pipeline directory.

#### Submitting JSON Files to the Annotation Submission System
The final step involves submitting the JSON files for both Full Text and Abstract annotations to the Annotation Submission System (ASS), which integrates the annotated data into MongoDB.

#### Log Files
Two types of log files are generated:

1. Script logs, which record the pipeline's progress from start to finish, are located at:
   `/logs/rdf_[today's date].txt`

2. Process logs, which detail the status and errors of each process, can be found at:
   - `/$TODAY_DATE/fulltext/logs`
   - `/$TODAY_DATE/abstract/logs`

### Prerequisites
Before running any scripts, obtain the necessary credentials:

- `USERNAME_DB_CDB`
- `PASSWORD_DB_CDB`
- `URL_DB_CDB`
- `SCHEMA_DB_CDB`
- `DOMAIN_API`

Before running any scripts, replace your email credentials:

- `LSF_EMAIL` in bsub_scilite_pipeline.sh, bsub_single_fulltext_job, bsub_single_abstract_job
- `MAIL_RECIPIENTS` in common_functions.sh

The machine-learning model used here is available at https://github.com/ML4LitS/annotation_models. Place the model in `quantised` folder.

Ensure you replace placeholders with actual paths and credentials where necessary.

## Cite 
1. APA 

Tirunagari, S., Shafique, Z., Venkatesan, A., & Harisson, M. (2023). Europe PMC Machine Learning False Positive Filter for Dictionary Annotations (Version 0.0.1) [Computer software]. Retrieved from [https://github.com/ML4LitS/MLFP_filter](https://github.com/ML4LitS/MLFP_filter)

2. Bibtex

@software{tirunagari2023accelerating,
  author = {Tirunagari, Santosh; Shafique, Zunaira; Venkatesan, Aravind; and Harisson, Melissa},
  doi = {},
  month = {06},
  title = {Europe PMC Machine Learning False Positive Filter for Dictionary Annotations},
  url = {https://github.com/ML4LitS/MLFP_filter},
  version = {0.0.1},
  year = {2023}
}

## Licence
MIT
