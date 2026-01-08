#!/bin/bash

WEB_BASE_DIR=$(pwd)
WEB_CONFIG_FILE="pppwn.config.json"
WEB_OPKG_INSTALL="git git-http python3 jq"
PPPWN_BINARY_FILE="pppwn"
FW_VERSION=1100

echo ""
echo "*****************************************"
echo "=== Установит PPPWN сетевой интерфейс ==="
echo "=== Установит нужные пакеты           ==="
echo "=== Скопирует необходимые файлы       ==="
echo "*****************************************"
echo ""
echo ""
echo ""
read -p "Хотите продолжить?(y/n): " continue
#Проверяем ввод пользователя
install=0
if [ "$continue" = "y" -o "$continue" = "Y" -o "$continue" = "Д" -o "$continue" = "д" ]; then
	install=1
fi
if [ $install -eq 0 ]; then
	echo ""
	echo "Отменено пользователем...выходим..."
	exit 0
fi
#Если пользователь дал согласие
echo ""
echo "Хорошо, теперь сделаем это..."
echo ""
echo ""
echo "Устанавливаем пакеты..."
echo ""
opkg update
opkg install "$WEB_OPKG_INSTALL"
#Проверяме установку
installed=0
opkg_git=$(opkg list-installed | grep git)
opkg_git_http=$(opkg list-installed | grep git-http)
opkg_git_python=$(opkg list-installed | grep python)
#Если какой то пакет не установился выдаём ошибку
if [ -z opkg_git -o -z opkg_git_http -o -z opkg_git_python ]; then
	echo ""
	echo "Некоторые пакеты не установились, ошибка...попробуйте снова..."
	exit 0
fi
echo ""
echo "$WEB_OPKG_INSTALL успешно установлены."
echo ""
echo ""
echo "Выбери интерфейс сетевого моста. Что то типа br-lan, br0 и так далее..."
echo ""
#Создаём список интерфейсов
interfaces=$(ls /sys/class/net/)
icount=0
for iface in $interfaces; do
    icount=$((icount + 1))
    echo "$icount. $iface"
done
#Выбор пользовательского интерфейса
echo ""
read -p "Выбор интерфейса: " lan_interface
selected_interface="none"
icount=0
for iface in $interfaces; do
    icount=$((icount + 1))
    if [ "$icount" = "$lan_interface" ]; then
		selected_interface="$iface"
		break
	fi
done
if [ "$selected_interface" = "none" ]; then
	echo ""
	echo "Ничего не выбрано...повторите попытку..."
	exit 0
fi
echo ""
echo "Сетевой интерфейс: $selected_interface"
echo ""
echo "Создаём файл конфига..."
file_created=$(test -f "$WEB_CONFIG_FILE" && echo 1)
if [ "$file_created" = "1" ]; then
	rm "$WEB_BASE_DIR/$WEB_CONFIG_FILE"
	echo "Старый конфиг был удалён..."
fi
cat > "$WEB_CONFIG_FILE" << EOF
{
    "interface": "$selected_interface",
    "basedir": "$WEB_BASE_DIR",
    "fwversion": "$FW_VERSION"
}
EOF
file_created=$(test -f "$WEB_CONFIG_FILE" && echo 1)
if [ "$file_created" != "1" ]; then
	echo "Ошибка...$WEB_BASE_DIR/$WEB_CONFIG_FILE"
fi
echo "Запись в $WEB_BASE_DIR/$WEB_CONFIG_FILE успешно..."
#Копируем нужные файлы в систему
echo ""
echo "Работаем с файлами..."
#Копируем главный бинарь
pppwn_bin_exists=$(test -f "/opt/bin/$PPPWN_BINARY_FILE" && echo 1)
if [ "$pppwn_bin_exists" != "1" ]; then
	echo "Копируем бинарник в /opt/bin/$PPPWN_BINARY_FILE..."
	mv "$WEB_BASE_DIR/install/$PPPWN_BINARY_FILE" "/opt/bin/"
	chmod +x "/opt/bin/$PPPWN_BINARY_FILE"
else
	echo "Pppwn бинарник уже существует /opt/bin/$PPPWN_BINARY_FILE..."
fi
#Копируем конфиг
config_exists=$(test -f "/opt/etc/$WEB_CONFIG_FILE" && echo 1)
if [ "$config_exists" = "1" ]; then
	echo "Конфиг уже существует в /opt/etc/$WEB_CONFIG_FILE...перезапишем..."
	rm "/opt/etc/$WEB_CONFIG_FILE"
fi
mv "$WEB_BASE_DIR/$WEB_CONFIG_FILE" "/opt/etc/"
echo "Копируем новый файл в /opt/etc/$WEB_CONFIG_FILE..."
#Копируем службу
service_exists=$(test -f "/opt/etc/pppwn_ctl" && echo 1)
if [ "$service_exists" != "1" ]; then
	echo "Служба усрешно установлена..."
	mv "$WEB_BASE_DIR/install/pppwn_ctl" "/opt/etc/"
	chmod +x "/opt/etc/pppwn_ctl"
else
	echo "Служба уже установлена..."
fi
echo ""
echo "Всё отлично...Выход"
exit 0