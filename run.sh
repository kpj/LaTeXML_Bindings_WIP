set -e
set -u

[ ! -d "$1" ] && echo "Usage: $0 <directory>" && exit 1

cwd="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

dir="$1"
tex_file="${dir%/}.tex"
xml_file="${tex_file/%tex/xml}"
pdf_file="${dir%/}.pdf"

rm -f "$xml_file" "$pdf_file"

cd "$dir" && \
pdflatex -file-line-error -halt-on-error "$tex_file" && \
latexml --path="$cwd/bindings" --dest="$xml_file" "$tex_file"
