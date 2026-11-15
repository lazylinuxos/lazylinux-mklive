sv-add(){
service=$(ls /etc/sv/ | rofi -dmenu -l 20 -i | awk '{print $1}')
if [ ! -z "$service" ]
then
    sudo ln -s /etc/sv/$service /var/service/
fi
};

sv-rm(){
service=$(ls /var/service/ | rofi -dmenu -l 20 -i | awk '{print $1}')
if [ ! -z "$service" ]
then
    sudo rm /var/service/$service
fi
};

export VPKG_ROOT=$HOME/lazy-pkgs # or void-packages

vpkg-build(){
package=$(ls $VPKG_ROOT/srcpkgs/ | rofi -dmenu -l 20 -i | awk '{print $1}')
if [ ! -z "$package" ]
then
    mkdir -p ${VPKG_ROOT}/builtpkgs
    touch ${VPKG_ROOT}/builtpkgs/${package}
    ${VPKG_ROOT}/xbps-src pkg ${package}
fi
};

vpkg-install(){
package=$(ls $VPKG_ROOT/builtpkgs/ | rofi -dmenu -l 20 -i | awk '{print $1}')
current_dir=$(pwd)
if [ ! -z "$package" ]
then
    cd $VPKG_ROOT
    xi ${package}
    cd $current_dir
fi
};