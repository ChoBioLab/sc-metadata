import requests
import json
import os
import re
import pandas as pd
import numpy as np
from functions import (get_google_sheet, get_redcap_metadata, 
                       export_redcap_data)

# Options
unique_id = "lib_id"
path_file = "data_new.csv"
path_config = os.path.join(os.path.expanduser("~"), 
                           ".ssh/config_redcap.json")
cols_should_be_unique = ["standard_sample_id"]
project = "Cho Lab Single Cell Sample Metadatabase"
remove_leading_zeros_lib_id = True
overwriteBehavior = "normal"  # so blank doesn't overwrite filled

# Load Google Sheets Database
dff = pd.read_csv(path_file)
if remove_leading_zeros_lib_id:
    for i in range(1, 9):
        if f"lib_id_{i}" in dff.columns:
            dff[f"lib_id_{i}"] = dff[f"lib_id_{i}"].apply(
                lambda x: x if pd.isnull(x) else x.lstrip(
                    "00"))  # remove leading zeros from unique ID

# Load Data Dictionary
with open(path_config, "r") as json_file:
    config = json.load(json_file)
api_url, token = config[project]["url"], config[project]["token"]
drc = get_redcap_metadata(project, api_url, token)
data_dict = pd.concat([pd.Series(x, name=x["field_name"]) 
                       for x in drc["data_dictionary"]], axis=1).T

# Convert Categorical Values to REDCap Codes
for f in dff.columns:
    if f in data_dict.index.values and data_dict.loc[f].field_type in [
        "radio", "dropdown"]:
            cats = data_dict.loc[f].loc[
                "select_choices_or_calculations"].split(" | ")
            dff = dff.drop(f, axis=1).join(
                dff[f].apply(lambda x: x if pd.isnull(x) else dict(
                    pd.DataFrame([v.split(", ") for v in cats]).set_index(1)[0])[x]))
                            
#  Upload
errors = {}
for f in pd.unique(dff.columns):  # iterate fields
    errors.update({f: {}})
    if f in data_dict.index.values:  # if field is in data dictionary
        for i in pd.unique(dff.record_id):  # iterate record IDs
            dati = dff[dff.record_id == i]
            # if len(pd.unique(dati[f])) > 1:  # if repeated measures (RMs)
            #     errors[f].update({i: {}})
            #     for t, x in enumerate(list(dati[f])):  # iterate RMs
            #         field = f"{f}_{t}"
            #         errors[f][i].update({field: None})
            #         val = x
            #         if data_dict.loc[f].field_type in ["radio", "dropdown"]:
            #             val = dict(pd.DataFrame([
            #                 v.split(", ") for v in data_dict.loc[f].loc[
            #                     "select_choices_or_calculations"].split(
            #                     " | ")]).set_index(1)[0])[
            #                         val]  # convert categorical to code
            #         try:
            #             if not pd.isnull(x):
            #                 export_redcap_data(api_url, token, project=project,
            #                                    file=val, record_id=i, 
            #                                    event_id=data_dict.loc[
            #                                        f].form_name,
            #                                    field=field,
            #                                    repeat_instance=None)  # export
            #         except Exception as err:
            #             errors[f][i][field] = err
            # else:  # between-person measures
            errors[f].update({i: None})
            try:
                val = pd.unique(dati[f])[0]
                if data_dict.loc[f].field_type in ["radio", "dropdown"]:
                    val = dict(pd.DataFrame([v.split(", ") for v in data_dict.loc[
                        f].loc["select_choices_or_calculations"].split(
                            " | ")]).set_index(1)[0])[
                                val]  # convert categorical to code
                # export_redcap_data(api_url, token, project=project,
                #                    file=val, field=f, record_id=i,
                #                    event_id=data_dict.loc[f].form_name,
                #                    repeat_instance=None)  # export
                fields = {"field": f, "token": token, 
                          "content": "record", "action": "import", 
                          "format": "json", "type": "flat", 
                          "overwriteBehavior": overwriteBehavior,
                          "forceAutoNumber": "false",
                          "data": val, "returnContent": "nothing",
                          "returnFormat": "json"}
            except Exception as err:
                errors[f][i] = err

# forms_arm_1




# def export_redcap_data(api_url, token, file=None, data=None,
#                        project=project, 
#                        record_id=i, event_id=None, field=None, repeat_instance=None)

import requests

f = "disease"
i = "TEST"
val = 1
fields = {"field": f, "token": token, 
          "content": "record", "action": "import", 
          "format": "json", "type": "flat", 
          "overwriteBehavior": overwriteBehavior,
          "forceAutoNumber": "false",
          "data": val, "returnContent": "nothing",
          "returnFormat": "json"}
req = requests.post(api_url, data=fields)
print("HTTP Status: " + str(req.status_code))
print(req.json())