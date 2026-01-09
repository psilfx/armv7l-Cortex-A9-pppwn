#!/bin/bash

WEB_BASE_DIR=$(pwd)
WEB_CONFIG_FILE="pppwn.config.json"
WEB_OPKG_INSTALL="php8 php8-cgi php8-cli jq"
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
opkg_php8=$(opkg list-installed | grep php8)
opkg_php8_cgi=$(opkg list-installed | php8-cgi)
opkg_php8_cli=$(opkg list-installed | php8-cli)
#Если какой то пакет не установился выдаём ошибку
if [ -z "$opkg_php8" -o -z "$opkg_php8_cgi" -o -z "$opkg_php8_cli" ]; then
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
if [ -f "$WEB_CONFIG_FILE" ]; then
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
if [ ! -f "$WEB_CONFIG_FILE" ]; then
	echo "Ошибка...$WEB_BASE_DIR/$WEB_CONFIG_FILE"
fi
echo "Запись в $WEB_BASE_DIR/$WEB_CONFIG_FILE успешно..."
#Копируем нужные файлы в систему
echo ""
echo "Работаем с файлами..."
mkdir -p /opt/bin /opt/etc
#Копируем главный бинарь
if [ ! -f "/opt/bin/$PPPWN_BINARY_FILE" ]; then
	echo "Копируем бинарник в /opt/bin/$PPPWN_BINARY_FILE..."
	cp "$WEB_BASE_DIR/install/$PPPWN_BINARY_FILE" "/opt/bin/"
	chmod +x "/opt/bin/$PPPWN_BINARY_FILE"
else
	echo "Pppwn бинарник уже существует /opt/bin/$PPPWN_BINARY_FILE..."
fi
#Копируем конфиг
if [ -f "/opt/etc/$WEB_CONFIG_FILE" ]; then
	echo "Конфиг уже существует в /opt/etc/$WEB_CONFIG_FILE...перезапишем..."
	rm "/opt/etc/$WEB_CONFIG_FILE"
fi
mv "$WEB_BASE_DIR/$WEB_CONFIG_FILE" "/opt/etc/"
echo "Копируем новый файл в /opt/etc/$WEB_CONFIG_FILE..."
#Копируем службу
service_exists=$(test -f "/opt/etc/pppwn_ctl" && echo 1)
if [ "$service_exists" != "1" ]; then
	echo "Служба усрешно установлена..."
	cp "$WEB_BASE_DIR/install/pppwn_ctl" "/opt/etc/"
	chmod +x "/opt/etc/pppwn_ctl"
else
	echo "Служба уже установлена..."
fi
echo ""
echo "========================================"
echo "Установка завершена успешно!"
echo "Сетевой интерфейс: $selected_interface"
echo "Версия прошивки: $FW_VERSION"
echo "========================================"
echo ""
echo -e "Для запуска веб морды: \033[1;33msh /opt/etc/pppwn_ctl web_start\033[1;37m"
exit 0