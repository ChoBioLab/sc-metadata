import gspread
import requests
import os
import re
import requests
import pandas as pd
import numpy as np


def get_google_sheet(sheet_url, path_secret, range_name=0, sheet_num=0,
                     convert_missing=True):
    """Retrieve sheet data using OAuth credentials and Google Python API."""
    scope = ["https://spreadsheets.google.com/feeds", 
             "https://www.googleapis.com/auth/drive"]
    store = file.Storage(os.path.join(os.path.expanduser("~"), 
                                      ".ssh/credentials.json"))
    creds = store.get()
    if not creds or creds.invalid:
        flow = client.flow_from_clientsecrets(path_secret, scope)
        creds = tools.run_flow(flow, store)
    gcred = gspread.authorize(creds)  # authenticate with Google API
    if "http" not in sheet_url:  # if given as ID rather than full URL
        sheet_url = "https://docs.google.com/spreadsheets/d/" + sheet_url
    sheet = gcred.open_by_url(sheet_url)
    worksheet = sheet.get_worksheet(sheet_num)
    dff = worksheet.get_all_values()
    data = pd.DataFrame(dff[1:], columns=dff[0])
    if isinstance(data, list):
        data = pd.DataFrame(data[1:], columns=data[0])
    if convert_missing is True:
        data = data.replace({"NA": np.nan, "": np.nan})
    return data


def try_float(x):
    """Try to convert to float."""
    try:
        return float(x)
    except Exception as err:
        print(err)
        return np.nan
    
    
def get_redcap_metadata(project, config):
    """Get field names, record IDs, & full data dictionary of a REDCap project."""
    info = {}  # empty dictionary to hold different types of project metadata
    for x in ["metadata", "record"]:
        req = requests.post(config[project]["url"], data={"content": x, "format": "json",
                                                          "token": config[project]["token"]})
        metadata = req.json()  # request metadata
        print("HTTP Status: " + str(req.status_code))
        info.update({x: metadata})  # store in dictionary
    info = {"field_names": [x["field_name"] for x in info["metadata"]],
            "record_ids": [x["record_id"] for x in info["record"]],
            "data_dictionary": info["metadata"]}
    return info


def search_fields(pattern, data, header=True, print_output=True):
    """Search for a partial match in the REDCap field names."""
    fields = data.field_name.apply(lambda x: np.nan if re.search(
        pattern.lower(), x.lower()) is None else x).dropna(
            )  # search for pattern in each value
    hhh = f"\n\n{'*' * 80}\n\n" if header is True else ""
    if print_output is True: 
        print(f"{hhh}\n\n{list(fields)}{hhh}")  # print partial matches
    return fields


def investigate_fields(column, data_rc, data_meta=None, pattern=True, pattern_start_only=False):
    """Print information about REDCap fields corresponding to column names in metadatabase."""
    pattern_original = pattern
    print(isinstance(column, (list, np.ndarray, set, tuple)))
    if isinstance(column, (list, np.ndarray, set, tuple)):  # if list-like (multiple fields/"column")
        for x in list(column):
            investigate_fields(x, data_rc, data_meta=data_meta, pattern=pattern_original, 
                               pattern_start_only=pattern_start_only)
    else:  # if 1 column name given
        print(column)
        print(f"\n\n\n{'=' * 80}\n\n{column}\n\n{'=' * 80}\n\n")
        if column not in list(data_rc.field_name) or pattern is True:  # if exact column name not in fields...
            if pattern is None or pattern is True:  # if no pattern specified...
                if "_" in column:  # if specified column has "_" (e.g., for repeated measures)...
                    # (ensures will print other variables, even if specify X_1, will also tell you X_2, X_3...)
                    pattern = re.sub("_[0-9]+$", "", column)  # look for base variable name (repeated measures)
                else:  # if not a repeated variable but 
                    pattern = column[:4] if len(column) > 4 else column[:3]
            else:
                pattern = column
            fields = search_fields("^" + pattern if pattern_start_only is True else pattern, 
                                data_rc, header=False, print_output=False)  # search fields for partial match
            if len(fields) > 0 and column not in list(data_rc.field_name):  # if column is not in field names...
                # if len > 0, then detected field(s) that are partial match, so return first
                col_rc = fields[0]
                print(f"Changing column {column} to partial match: {col_rc}")
            else:
                col_rc = column
        else:
            col_rc = column
        if data_rc is not None:  # REDCap data info
            # print(data_rc.loc[x])
            if col_rc not in data_rc.index.values:
                print(f"{data_rc} not in REDCap field names")
            else:
                print(data_rc.loc[col_rc].head())
                print(f"\n{'*' * 80}\nBranching Logic:\n\n", data_rc.loc[col_rc].loc["branching_logic"])
                print(f"\n{'*' * 80}\nCategories:\n\n", data_rc.loc[col_rc].loc["select_choices_or_calculations"])
        if data_meta is not None:  # metadatabase info
            if column not in data_meta.columns:
                print(f"{column} not in metadatabase column names")
            else:
                print(f"\n{'*' * 80}\nUnique Metadatabase Values:\n\n", data_meta[column].unique())
            
            
def extract_categories(field, data_rc):
    """Extract levels of categorical variables by REDCap field name."""
    cats = data_rc.loc[field].loc["select_choices_or_calculations"].split("|")
    cats = dict(zip(*[[x.strip().split(", ")[i] for x in cats] for i in [1, 0]]))
    return cats


def get_redcap_metadata(project, api_url, token):
    """Get field names, record IDs, & full data dictionary of a REDCap project."""
    info = {}  # empty dictionary to hold different types of project metadata
    for x in ["metadata", "record"]:
        req = requests.post(api_url, data={"content": x, "format": "json",
                                                              "token": token})
        metadata = req.json()  # request metadata
        print("HTTP Status: " + str(req.status_code))
        info.update({x: metadata})  # store in dictionary
    info = {"field_names": [x["field_name"] for x in info["metadata"]],
            "record_ids": [x["record_id"] for x in info["record"]],
            "data_dictionary": info["metadata"]}
    return info


def export_redcap_data(api_url, token, file=None, data=None,
                       project="Cho Lab Single Cell Sample Metadatabase", 
                       record_id=1, event_id=None, field=None, repeat_instance=None):
    """
    Export REDCap data using API.

    Parameters
    ----------
    file : str
        Output file path or value to import as the data for the field.
    project : str
        Project name in order to retrieve proper API token. See config_redcap.py to see options, e.g., GHR.
    record_id : str or int
        REDCap ID for participant.
    event_id : str or None, optional
        REDCap ID for event (e.g., 'baseline', 'event_1_arm_1') for longitudinal projects only.
        The default is None.
    field : str, optional
        Field (variable name) to which to upload data. The default is None.
    repeat_instance: int, optional
        Only for projects with repeating instruments/events)
        The repeat instance number of the repeating event (if longitudinal) or the repeating instrument
        (if classic or longitudinal).
        The default value is None.

    Returns
    -------
    None. Data are uploaded to REDCap.

    Example
    -------

    Using GUI:

    >>> from Tasks.redcap_api import export_redcap_data
    >>> data = export_redcap_data()

    Using Function Arguments (See example above; these functions are basically mirrors of each other.)

    """
    if event_id in [False, "", "None", "no", "none", "n"]:
        event_id = None
    if repeat_instance in [False, "", "None", "no", "none", "n"]:
        repeat_instance = None
    if os.path.exists(file):  # if uploading file to field
        fields = {"token": token, 
                  "content": "file", "action": "import",
                  "record": record_id, "field": field, 
                  "returnFormat": "xml"}
    else:  # if uploading value to field
        fields = {"field": field, 
                  "token": token,
                  "content": "record", "action": "import",
                  "format": "json", "type": "flat", 
                  "overwriteBehavior": "normal", 
                  "forceAutoNumber": "false",
                  "data": file, "returnContent": "nothing",
                  "returnFormat": "json"}
    if event_id is not None:
        fields.update({"event": event_id})
    if repeat_instance is not None:
        fields.update({"repeat_instance": repeat_instance})
    print(fields)
    if os.path.exists(file):  # if file
        file_obj = open(file, "rb")
        req = requests.post(api_url, data=fields, 
                            files={"file": file_obj})
        file_obj.close()
        print(f"\n\nHTTP Status: {str(req.status_code)}\nReason: {req.reason}")
        print("\n\n", req.text)
    else:
        req = requests.post(api_url, data=fields)
        print("HTTP Status: " + str(req.status_code))
        print(req.json())