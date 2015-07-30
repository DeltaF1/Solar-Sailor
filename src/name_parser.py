import re

f = open("common_names.txt", "r")

p = re.compile("([A-Z]*) *[0-9]")

out = open("common_namesparsed.txt","w")

for line in f.readlines():
    s = p.match(line).group(1).lower().title()
    #print s
    out.write(s+" ")

f.close()
out.close()
