import json
import re
import sys

def isExtensionJson(file):
    if not file:
        return False
    REJsonExtension = r"(?i)\.json$"
    return bool(re.search(REJsonExtension, file))

def verify(file):
    if not isExtensionJson(file):
        # Error #1: not a JSON file
        return 1
    jsonFile = file
    try:
        with open(jsonFile, "r") as fh:
            json_str = fh.read()
    except:
        # Error #3: file not found
        return 3
    try:
        json_data = json.loads(json_str)
        # No error: valid JSON
        return 0
    except:
        # Error #2: invalid JSON data
        return 2

if __name__ == "__main__":
    print(verify(sys.argv[1]))
