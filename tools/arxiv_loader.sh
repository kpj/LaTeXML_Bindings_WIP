set -e
set -u


function parse_id {
    echo -n "$(sed 's/[^0-9]*//' <<< "$1")"
}

function load_paper {
    wget -O "$1" -U 'Mozilla/5.0 (Windows NT 5.1; rv:10.0.2) Gecko/20100101 Firefox/10.0.2' "http://arxiv.org/e-print/$1" &> /dev/null
}

function get_tex_from_tar {
    local fn=''
    tar xf "$1" &> /dev/null || ( mv "$1" "$1.gz" && gunzip "$1.gz" &> /dev/null && exit 1 || ( mv "$1.gz" "$1" && exit 1 ) ) || fn="$1"
    
    if [[ -f "$fn" ]] ; then
        if [[ ${fn##*.} != "tex" ]] ; then
            mv "$1" "$1.tex"
            fn="$1.tex"
        fi
    fi

    if [[ -f "$fn" && ( \
        "$(file "$fn")" =~ "PDF document" || \
        "$(file "$fn")" =~ "HTML document text" \
       ) ]] ; then
        echo -n "undef"
    else
        find . ! -name "*.tex" -delete
        local tex_name=$(ls)
        mv ./*.tex "$2"
        echo -n "$tex_name"
    fi
}


cwd="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$cwd"

[[ "$#" -ne 1 ]] && echo "Usage: $0 <id>" && exit 1
id=$(parse_id "$1")
[[ -z "$id" ]] && echo "Invalid id, aborting..." && exit 1

dw_dir="my_dir"

mkdir -p "$dw_dir"
cd "$dw_dir"

load_paper "$id"
tex_name=$(get_tex_from_tar "$id" "$cwd" )

cd "$cwd"
rm -r "$dw_dir"

if [[ "$tex_name" != "undef" ]] ; then
    echo "Gathered '$(echo -n $tex_name | tr '\n' ' ')'"
else
    echo "No tex file found"
fi
