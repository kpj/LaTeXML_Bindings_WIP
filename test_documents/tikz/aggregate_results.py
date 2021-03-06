import datetime, math, os, os.path, re, sys


if len(sys.argv) != 2:
    print('Usage: %s <dir>' % sys.argv[0])
    sys.exit(1)

data_dir = sys.argv[1]
time_type = 'user' # CPU time in user-mode (of current process)
skipped = False
result_dir = 'results'

file_contents = []
times = []
deltas = []
res = (0, 0, 0, 0) # min/avg/max/mdev (absolute)
resp = (0, 0, 0, 0) # min/avg/max/mdev (relative)

# fubar functions
final_output = ''
def oprint(string):
    global final_output

    print(string)
    final_output += '%s\n' % string

def now():
    return datetime.datetime.now().strftime('%Y.%m.%d_%H:%M:%S')

def get_pgf_bindings():
    res = []
    cwd = os.path.dirname(os.path.realpath(__file__))
    for f in os.listdir(os.path.join(cwd, '../../bindings/')):
        if f.startswith('pgfmathfunctions.') and f.endswith('.code.tex.ltxml'):
            res.append(f)
    return res

# read files
for root, sub, files in os.walk(data_dir):
    for f in files:
        if f.endswith('.tlog'):
            with open(os.path.join(root, f), 'r') as fd:
                file_contents.append((f[:-5], fd.read()))

if len(file_contents) == 0:
    oprint('No tlog-files found, aborting...')
    sys.exit()

# extract times
def get_time(content):
    """Returns tuple containing time with and without bindings
    (without, with)
    """
    pat = re.compile(r'.* bindings:.*' + time_type + r' ([^\s]+)\s.*')
    def parse_line(line):
        res = re.match(pat, line)
        if res:
            return re.match(pat, line).group(1)
        else:
            return None

    foo = content.split('\n')
    if len(foo) > 2:
        return (parse_line(foo[1]), parse_line(foo[2]))
    else:
        return (None, None)

for f, fc in file_contents:
    res = get_time(fc)
    if res[0] and res[1]:
        times.append((f, get_time(fc)))
    else:
        oprint(' - Skipping %s...' % f)
        skipped = True

if len(times) == 0:
    oprint('All tlog-files skipped, aborting...')
    sys.exit()

# parse times
def readable(t):
    return '%.2f' % t

def str2time(string):
    def m2hm(mins):
        mins = int(mins)
        return '%i:%i' % (int(mins / 60), mins % 60)
    foo = string.split('m')
    res = m2hm(foo[0])
    tstr = '%sm%s' % (res, foo[1])

    frmt = '%H:%Mm%S.%fs'
    return datetime.datetime.strptime(tstr, frmt)

def total_seconds(td):
    # because python >=2.7 is not available
    if isinstance(td, datetime.timedelta):
        return readable((td.microseconds + (td.seconds + td.days * 24 * 3600) * 10**6) / float(10**6))
    elif isinstance(td, datetime.datetime):
        return 3600 * float(td.strftime('%H')) + 60 * float(td.strftime('%M')) + float(td.strftime('%S.%f'))
    else:
        return td

for f, t in times:
    diff = total_seconds(str2time(t[0]) - str2time(t[1]))
    perc = '%.2f%%' % (100.0 / total_seconds(str2time(t[0])) * float(diff))
    deltas.append((f, diff, perc)) # (filename, absolute difference in seconds, relative difference in percent)

# analyse results
avg = lambda arr: sum(arr) / len(arr)
mdev = lambda arr: math.sqrt(avg(map(lambda x: (x - avg(arr))**2, arr)))

nums = [float(t) for f, t, p in deltas]
res = (min(deltas, key=lambda x: float(x[1]))[1], readable(avg(nums)), max(deltas, key=lambda x: float(x[1]))[1], readable(mdev(nums)))

numsp = [float(p[:-1]) for f, t, p in deltas]
resp = (min(deltas, key=lambda x: float(x[2][:-1]))[2][:-1], readable(avg(numsp)), max(deltas, key=lambda x: float(x[2][:-1]))[2][:-1], readable(mdev(numsp)))

# output results
oprint(('\n' if skipped else '') + 'Time improvements using bindings:')
for e in deltas:
    oprint(' > %s: %ss (%s)' % e)
    
oprint('--- overall statistics ---')
oprint('min/avg/max/mdev = ' + '/'.join(res) + ' s')
oprint('min/avg/max/mdev = ' + '/'.join(resp) + ' %')

# save to file (say hello to awful filenames [-:)
if not os.path.isdir(result_dir):
    os.mkdir(result_dir)

with open(os.path.join(result_dir, '%s|%s|results.txt' % (now(), data_dir[:-1])), 'w') as fd:
    fd.write('Loaded pgf-bindings:\n')
    for b in sorted(get_pgf_bindings()):
        fd.write(' > %s\n' % b)
    fd.write('\n')

    fd.write(final_output)
