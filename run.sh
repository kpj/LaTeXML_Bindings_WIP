set -e
set -u

[[ ( "$#" -ne 1 ) || ( ! -d "$1" ) ]] && echo "Usage: $0 <directory>" && exit 1

cwd="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$cwd"

dir="$1"
fname="main"
tex_file="$fname.tex"
xml_file="${tex_file/%tex/xml}"
pdf_file="${tex_file/%tex/pdf}"
html_file="${tex_file/%tex/html}"


cd "$dir" && \
rm -f "$xml_file" "$pdf_file" "$html_file" && \
pdflatex -file-line-error -halt-on-error "$tex_file" && \
latexml --path="$cwd/bindings" --dest="$xml_file" "$tex_file" && \
latexmlpost --format=html --destination="$html_file" "$xml_file"
