set -e
set -u

[[ ( "$#" -ne 1 ) || ( ! -d "$1" ) ]] && echo "Usage: $0 <directory>" && exit 1

cwd="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$cwd"

dir="$1"
tex_file="${dir%/}.tex"
xml_file="${tex_file/%tex/xml}"
pdf_file="${dir%/}.pdf"


cd "$dir" && \
rm -f "$xml_file" "$pdf_file" && \
pdflatex -file-line-error -halt-on-error "$tex_file" && \
latexml --path="$cwd/bindings" --dest="$xml_file" "$tex_file"
