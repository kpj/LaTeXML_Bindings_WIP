cd "$( dirname "${BASH_SOURCE[0]}" )"

PERL5LIB="$PERL5LIB:$PWD/../../plugins/" latexmlc --profile profile.opt main.tex
#--path="../../plugins/simple_binding"
