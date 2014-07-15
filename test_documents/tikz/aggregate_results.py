import datetime, os, os.path, re


data_dir = 'tex_to_time'
time_type = 'user'

file_contents = []
times = []
deltas = []

# read files
for f in os.listdir(data_dir):
    if f.endswith('.tlog'):
        with open(os.path.join(data_dir, f), 'r') as fd:
            file_contents.append(fd.read())

# extract times
def get_time(content):
    """Returns tuple containing time with and without bindings
    (without, with)
    """
    pat = re.compile(r'.* bindings:.*' + time_type + r' ([^\s]+)\s.*')
    def parse_line(line):
        return re.match(pat, line).group(1)

    foo = content.split('\n')
    return (parse_line(foo[1]), parse_line(foo[2]))

for fc in file_contents:
    times.append(get_time(fc))

# parse times
def str2time(string):
    frmt = '%Mm%S.%fs'
    return datetime.datetime.strptime(string, frmt)

for t in times:
    deltas.append(str2time(t[0]) - str2time(t[1]))
    print(deltas[-1])
