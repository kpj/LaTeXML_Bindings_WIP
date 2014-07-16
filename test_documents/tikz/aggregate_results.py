import datetime, math, os, os.path, re


data_dir = 'complex_examples'
time_type = 'user'

file_contents = []
times = []
deltas = []
res = (0, 0, 0, 0) # min/avg/max/mdev

# read files
for f in os.listdir(data_dir):
    if f.endswith('.tlog'):
        with open(os.path.join(data_dir, f), 'r') as fd:
            file_contents.append((f[:-5], fd.read()))

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

for f, fc in file_contents:
    times.append((f, get_time(fc)))

# parse times
def readable(t):
    return '%.2f' % t

def str2time(string):
    frmt = '%Mm%S.%fs'
    return datetime.datetime.strptime(string, frmt)

def total_seconds(td):
    # because python >=2.7 is not available
    return readable((td.microseconds + (td.seconds + td.days * 24 * 3600) * 10**6) / float(10**6))

for f, t in times:
    deltas.append((f, total_seconds(str2time(t[0]) - str2time(t[1]))))

# analyse results
avg = lambda arr: sum(arr) / len(arr)
mdev = lambda arr: math.sqrt(avg(map(lambda x: (x - avg(arr))**2, arr)))

nums = [float(t) for f, t in deltas]
res = (min(deltas, key=lambda x: x[1])[1], readable(avg(nums)), max(deltas, key=lambda x: x[1])[1], readable(mdev(nums)))

# output results
print('Time improvements using bindings')
for f, r in deltas:
    print('%s: %ss' % (f, r))
    
print '--- overall statistics ---'
print('min/avg/max/mdev = ' + '/'.join(res) + ' s')
