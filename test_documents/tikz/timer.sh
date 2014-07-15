set -e
set -u


cwd="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$cwd"

tDir="./tex_to_time"
bDir="/home/knj1/Desktop/git_repo/bindings"

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
    outp=$((time $cmd) 2>&1)
    echo "$outp" > "$olog" # save output to log
    echo "$outp" | grep -e 'real\s' -e 'user\s' -e 'sys\s' | tr '\t\n' ' \t' # print time
    echo
}

function testFile {
    tex_file="$1"
    lml="latexml --path=$bDir --dest=${tex_file/%tex/xml} $tex_file"

    exec > >(tee ${tex_file/%tex/tlog}) # print to stdout and log


    echo "$tex_file"

    disableBindings
    echo -ne "Without bindings: "
    execute "$lml" "${tex_file/%tex/olog}"

    enableBindings
    echo -ne "With bindings:\t  "
    execute "$lml" "${tex_file/%tex/olog}"

    echo
}

# clean before use
#find "$tDir" -type f ! -name "*.tex" -delete

# time it
if [[ ( "$#" -eq 0 ) ]] ; then
    find "$tDir" -name "*.tex" | while read line ; do
        testFile "$line"
    done
else
    for arg in "$@" ; do
        testFile "$arg"
    done
fi
