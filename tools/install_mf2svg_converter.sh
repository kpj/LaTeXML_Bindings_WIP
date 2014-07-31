path=''

function do_stuff {
    name="$1"
    link="$2"
    dir="$1"

    wget -O "$name.tar.gz" "$link"
    mkdir -p "$dir"
    tar xvf "$name.tar.gz" -C "$dir"
    rm -f "$name.tar.gz"
    cd "$dir" && cd *

    if [[ -f 'configure' ]] ; then
        install_dir=$(pwd)/_install
        ./configure --prefix="$install_dir"
        make
        make install

        path="$install_dir/bin:$path"
    else
        path="$(pwd):$path"
    fi

    cd ../..
}


do_stuff 'mftrace' 'http://lilypond.org/download/sources/mftrace/mftrace-1.2.18.tar.gz'
do_stuff 'potrace' 'http://potrace.sourceforge.net/download/potrace-1.11.linux-x86_64.tar.gz'
do_stuff 't1utils' 'http://mirrors.ctan.org/fonts/utilities/t1utils/t1utils-1.38.tar.gz'
do_stuff 'fontforge' 'http://downloads.sourceforge.net/project/fontforge/fontforge-source/fontforge_full-20120731-b.tar.bz2?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Ffontforge%2Ffiles%2Ffontforge-source%2F&ts=1406835705&use_mirror=colocrossing'


echo -e "\n\n\n##################################"
echo "Adding $path to " '$PATH'
export PATH="$path$PATH"
echo "You can now execute 'mftrace -f SVG <file>'"
