set -e
set -u


function parse_id {
    echo -n "$(sed 's/[^0-9]*//' <<< "$1")"
}

function load_paper {
    wget -O "$2" -U 'Mozilla/5.0 (Windows NT 5.1; rv:10.0.2) Gecko/20100101 Firefox/10.0.2' "http://arxiv.org/e-print/$1" &> /dev/null
}

function get_tex_from_tar {
    tar xf "$1"
    find . ! -name "*.tex" -delete
    local tex_name=$(ls)
    mv ./*.tex "$2"
    echo -n "$tex_name"
}


cwd="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$cwd"

[[ "$#" -ne 1 ]] && echo "Usage: $0 <id>" && exit 1
id=$(parse_id "$1")
[[ -z "$id" ]] && echo "Invalid id, aborting..." && exit 1

dw_dir="my_dir"
dw_file="foobarbazqux"

mkdir -p "$dw_dir"
cd "$dw_dir"

load_paper "$id" "$dw_file"
tex_name=$(get_tex_from_tar "$dw_file" "$cwd")

cd "$cwd"
rm -r "$dw_dir"

echo "Gathered '$tex_name'"
