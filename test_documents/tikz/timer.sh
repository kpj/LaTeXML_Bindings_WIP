#set -e
set -u

##
# this script does not accept any errors produced by LaTeXML
##

[[ "$#" -eq 0 ]] && echo "Usage: $0 <dir/file> [<dir/file>]" && exit

cwd="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$cwd"

bDir="../../bindings/"

function enableBindings {
    find "$bDir" -name "pgfmathfunctions*.not" | while read line ; do
        mv "$line" "${line%.not}"
    done
}
trap enableBindings 2

function disableBindings {
    find "$bDir" -name "pgfmathfunctions*.ltxml" | while read line ; do
        mv "$line" "$line.not"
    done
}

function execute {
    local cmd="$1"
    local olog="$2"

    #echo -e "\n> $cmd"
    local outp=$((time $cmd) 2>&1 | tee -a "$olog")

    if [[ $(echo "$outp" | grep '^Error:') ]] ; then
        echo 'error' # some error occured in LaTeXML
    else
        echo "$outp" | grep -e 'real\s' -e 'user\s' -e 'sys\s' | tr '\t\n' ' \t' # print time
    fi

    echo
}

function testFile {
    local tex_file="$1"
    local time_log="${tex_file/%tex/tlog}"
    local output_log="${tex_file/%tex/olog}"
    local lml="latexml --path=$bDir --dest=${tex_file/%tex/xml} $tex_file"

    exec > >(tee "$time_log") # print to stdout and log

    rm -f "$output_log"
    echo "$tex_file"

    disableBindings
    echo -ne "Without bindings: "
    echo -ne "####################\n# Without bindings #\n####################\n" > "$output_log"
    execute "$lml" "$output_log"

    enableBindings
    echo -ne "With bindings:\t  "
    echo -ne "\n\n#################\n# With bindings #\n#################\n" >> "$output_log"
    execute "$lml" "$output_log"

    echo
}

# time it
for arg in "$@" ; do
    if [[ -d "$arg" ]] ; then
        tDir="$arg"
        find "$tDir" -name "*.tex" | while read line ; do
            testFile "$line"
        done
    elif [[ -f "$arg" ]] ; then
        testFile "$arg"
    else
        echo "$0: cannot access $arg: No such file or directory"
    fi
done
