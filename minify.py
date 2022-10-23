import sys

def cleanSpacesOutside(text):
    ''' Receives a text and removes all spaces, tabs and line
    escapes outside of simple or double brackets ('', ""), so as to
    minify without altering string contents. Example:
    " [ { 'text': 'any text' } ] " -> "[{'text':'any text'}]"
    '''
    assert type(text) == str
    cleanText, endStringChar = "", ""
    for i in range(0, len(text)):
        if endStringChar and text[i] == endStringChar:
            cleanText += endStringChar
            endStringChar = ""
        elif text[i] in ['"', "'"]:
            if not endStringChar:
                endStringChar = text[i]
                cleanText += endStringChar
            else:
                cleanText += text[i]
        elif text[i] == " " and not endStringChar or\
            text[i] in ["\n", "\t"]:
                pass
        else:
            cleanText += text[i]
    return cleanText

def minify(file):
    with open(file, "r") as fh:
        fileContent = fh.read()
        print(cleanSpacesOutside(fileContent))

if __name__ == "__main__":
    minify(sys.argv[1])
