# This script will process XML texts to remove false positives from GP DS and OG z_tags
# (c) EMBL-EBI, Jan 2021
#
# Started: 04 Jan 2021
# Updated: 08 July  2021;
# Updated 13 Jan 2022
# Updated: 28 Feb 2023
# Updated: 13 Apr 2023
_author_ = 'Santosh Tirunagari'


import sys
from bs4 import BeautifulSoup
from collections import defaultdict
import argparse
from fuzzywuzzy import fuzz
import re
from tqdm import tqdm

from optimum.pipelines import pipeline
from functools import partial
from transformers import AutoTokenizer
from optimum.onnxruntime import ORTQuantizer, ORTModelForTokenClassification
from optimum.onnxruntime.configuration import AutoQuantizationConfig, AutoCalibrationConfig


import logging

# logging.basicConfig(level=logging.INFO, format='%(asctime)s :: %(levelname)s :: %(message)s')
logging.info("Imported Libraries!")


# This function will compare ml tags and ztags. The agreed tags are then returned back
def compare_ml_annotations_with_dictionary_tagged(ml_tags_, z_tags_):
    # logging.info("Compare ml tags and ztags and return the agreed tags!")
    agreed_z_tags = set()
#     print(z_tags_, ml_tags_)
    for each_z_tag in z_tags_:
        for each_ml_annotation in ml_tags_:
            score = fuzz.partial_ratio(each_ml_annotation, each_z_tag) #token_set_ratio
            if score > 80:
                agreed_z_tags.add(each_z_tag)
    return agreed_z_tags



def get_unique_ml_tags(all_sentences):
    
    gp_set = set()
    ds_set = set()
    og_set = set()
    no_sentences = 8
    
    for i in range((len(all_sentences) + no_sentences - 1) // no_sentences ):
        batch_sentences = all_sentences[i * no_sentences:(i + 1) * no_sentences]
        try:
            pred = ner_quantized(batch_sentences)

            for each_sentence, predictions in dict(zip(batch_sentences, pred)).items():
                for ent in predictions:
                    if ent:
                        if ent['entity_group'] == 'GP':
                            gp_set.add(each_sentence[ent['start']:ent['end']])
                        elif ent['entity_group'] == 'DS':
                            ds_set.add(each_sentence[ent['start']:ent['end']])
                        if ent['entity_group'] == 'OG':
                            og_set.add(each_sentence[ent['start']:ent['end']])
        except:
            pass
                    
    return gp_set, ds_set, og_set



def GP_soup(file_soup):
    # logging.info("GP Tags")
    gene_dict_sentences = defaultdict(list)
    for each_ztag in file_soup.find_all('z:uniprot'):
        try:
            gene_sentence = each_ztag.findParents('plain')[0].text
            gene_dict_sentences[gene_sentence].append(each_ztag)
        except:
            pass
    return gene_dict_sentences

def DS_soup(file_soup):
    # logging.info("DS Tags")
    disease_dict_sentences = defaultdict(list)
    for each_ztag in file_soup.find_all('z:disease'):
        try:
            disease_sentence = each_ztag.findParents('plain')[0].text
            disease_dict_sentences[disease_sentence].append(each_ztag)
        except:
            pass
    return disease_dict_sentences


def OG_soup(file_soup):
    # logging.info("OG Tags")
    species_dict_sentences = defaultdict(list)
    for each_ztag in file_soup.find_all('z:species'):
        try:
            species_sentence = each_ztag.findParents('plain')[0].text
            species_dict_sentences[species_sentence].append(each_ztag)
        except:
            pass
    return species_dict_sentences

def getfileblocks(xml_stream):
    # logging.info("Divide the large xml files into individual files as a list")
    delimiter_string = '<!DOCTYPE article PUBLIC'
    subFileBlocks = [delimiter_string + remainder_string for remainder_string in xml_stream.split(delimiter_string) if remainder_string]
    if subFileBlocks:
        return subFileBlocks
    else:
        print('No input xml stream found')



def process_xml_text_to_remove_FPs(xml_stream_, interested_tags_):
    # logging.info("Process each XML file for ML FP removal")
    interested_tags = interested_tags_[0].split(',')

    xml_stream_list = getfileblocks(xml_stream_)

    for xml_text in tqdm(xml_stream_list): #tqdm(xml_stream_list): #
        # print(xml_text)
        # logging.info("Processing.....")

        soup = BeautifulSoup(xml_text, 'xml')
        dict_sentences = defaultdict(list)
        plain_sentences = set()

        dict_gp_set = set()
        dict_ds_set = set()
        dict_og_set = set()

        for each_interested_tag in interested_tags:
            # print(each_interested_tag)
            if each_interested_tag == 'GP':
                for each_ztag in soup.find_all('z:uniprot'):
                    try:
                        sentence_ = each_ztag.findParents('plain')[0].text
                        # print(sentence_)
                        dict_sentences[sentence_].append(each_ztag)
                        plain_sentences.add(sentence_)
                        dict_gp_set.add(each_ztag.text)
                    except:
                        pass
            elif each_interested_tag == 'DS':
                for each_ztag in soup.find_all('z:disease'):
                    try:
                        sentence_ = each_ztag.findParents('plain')[0].text
                        dict_sentences[sentence_].append(each_ztag)
                        plain_sentences.add(sentence_)
                        dict_ds_set.add(each_ztag.text)
                    except:
                        pass
            elif each_interested_tag == 'OG':
                for each_ztag in soup.find_all('z:species'):
                    try:
                        sentence_ = each_ztag.findParents('plain')[0].text
                        dict_sentences[sentence_].append(each_ztag)
                        plain_sentences.add(sentence_)
                        dict_og_set.add(each_ztag.text)
                    except:
                        pass
        # print(list(plain_sentences))
        if list(plain_sentences):
            ml_gp_set, ml_ds_set, ml_og_set = get_unique_ml_tags(list(plain_sentences))
            if 'GP' in interested_tags and list(dict_gp_set):
                GP_nofp_set = compare_ml_annotations_with_dictionary_tagged(ml_gp_set, dict_gp_set)
                GP_FP_set = dict_gp_set - GP_nofp_set
                for each_FP in GP_FP_set:
                    for tag in soup.findAll('z:uniprot', string=each_FP):
                        tag.unwrap()
            
            if 'DS' in interested_tags and list(dict_ds_set):
                DS_nofp_set = compare_ml_annotations_with_dictionary_tagged(ml_ds_set, dict_ds_set)
                DS_FP_set = dict_ds_set - DS_nofp_set
                for each_FP in DS_FP_set:
                    for tag in soup.findAll('z:disease', string=each_FP):
                        tag.unwrap()
            if 'OG' in interested_tags and list(dict_og_set):
                OG_nofp_set = compare_ml_annotations_with_dictionary_tagged(ml_og_set, dict_og_set)
                OG_FP_set = dict_og_set - OG_nofp_set
                for each_FP in OG_FP_set:
                    for tag in soup.findAll('z:species', string=each_FP):
                        tag.unwrap()

            new_file_content = str(soup).replace('<?xml version="1.0" encoding="utf-8"?>\n', '').replace('</ebiroot>', '</ebiroot>\n')
            print(new_file_content, end='')

        else:
            print(xml_text, end='')

    # logging.info("Processed ML FP removal and saved to output console")



if __name__ == "__main__":
    """
    NOTE: When use on cluster, make sure you use the correct file/directory path on nfs 
    instead of path on your local machine.
    """
    model_path_quantised = '/hps/software/users/literature/textmining/test_pipeline/ml_filter_pipeline/ml_fp_filter/quantised'
    model_quantized = ORTModelForTokenClassification.from_pretrained(model_path_quantised, file_name="model_quantized.onnx")
    tokenizer_quantized = AutoTokenizer.from_pretrained(model_path_quantised, model_max_length=512, batch_size=4, truncation=True)
    ner_quantized = pipeline("token-classification", model=model_quantized, tokenizer=tokenizer_quantized, aggregation_strategy="first")


    parser = argparse.ArgumentParser(description='This script will process xml to remove false positives')
    # parser.add_argument('files', metavar='FILE', nargs='*', help='files to read, if empty, stdin is used')
    # parser.add_argument("-t", "--text", nargs=1, required=True, help="Input xml text", metavar="TEXT", default=sys.stdin)
    parser.add_argument("-z", "--ztags", nargs=1, required=True, help="GP,DS,OG", metavar="TEXT")
    parser.add_argument('text', nargs='?',type=argparse.FileType(), default=sys.stdin)
    args = parser.parse_args()

    # If you would call fileinput.input() without files it would try to process all arguments.
    # We pass '-' as only file when argparse got no files which will cause fileinput to read from stdin
    # text = sys.stdin.read()

    logging.info("Call the process_xml_text_to_remove_FPs() to kick start the process of ML FP removal ")
    process_xml_text_to_remove_FPs(args.text.read(), args.ztags)

# / nfs / gns / literature / Santosh_Tirunagari / miniconda3 / envs / pytorch / bin / python / nfs / gns / literature / machine - learning / Santosh / Gitlab / biobertepmc / ML_FP_Filter_Production_V01.py - t
# "$(cat /nfs/misc/literature/machine-learning/Santosh/Gitlab/biobertepmc/test_xml_fp.txt)" - z
# GP, DS, OG



