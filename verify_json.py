import json

def isExtensionJson(file):
    if len(file) < 6:
        return False
    fileExtension = ""
    for i in range(-5, 0):
        fileExtension += file[i]
    if fileExtension != ".json":
        return False
    return True

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
    import sys
    print(verify(str(sys.argv[1])))
