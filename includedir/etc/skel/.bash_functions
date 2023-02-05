sv-add(){
service=$(ls /etc/sv/ | rofi -dmenu -l 20 -i | awk '{print $2}')
if [ ! -z "$service" ]
then
    sudo ln -s /etc/sv/$service /var/service/
fi
};

sv-rm(){
service=$(ls /var/service/ | rofi -dmenu -l 20 -i | awk '{print $2}')
if [ ! -z "$service" ]
then
    sudo rm /var/service/$service
fi
};