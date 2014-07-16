#set -e
set -u

##
# this script does not accept any errors produced by LaTeXML
##

[[ "$#" -eq 0 ]] && echo "Usage: $0 <dir/file> [<dir/file>]" && exit

cwd="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$cwd"

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

    if [[ $(echo "$outp" | grep 'Error') ]] ; then
        echo 'error' # some fatal error occured in LaTeXML
    else
        echo "$outp" | grep -e 'real\s' -e 'user\s' -e 'sys\s' | tr '\t\n' ' \t' # print time
    fi

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
