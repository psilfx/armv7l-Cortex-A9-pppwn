<h1>PPPwn под armv7l.</h1>

<p>file: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), statically linked, with debug_info, not stripped</p>

<h2>Проверен и работает на Netgear r7000 Nighthawk.</h2>

<p>Собрано из исходников от <a href="https://github.com/xfangfang/PPPwn_cpp">xfangfang</a> .</p>
<p>Бинарники stage взяты от <a href="https://github.com/MODDEDWARFARE/PPPwn_WRT">MODDEDWARFARE</a> .</p>

<h3>Запуск:</h3>
<ul>
<li>1. Скопировать на роутер или ещё куда, стартануть например через ssh
<kbd>./pppwn --interface br-lan --fw 1100 --stage1 "stage1_1100.bin" --stage2 "stage2_1100.bin" --timeout 10 --auto-retry</kbd></li>
<li>2. Взять флэшку записать в корень goldhen.bin от <a href="https://github.com/SiSTR0">SISTR0</a> и вставить в PS4</li>
<li>3. На приставке запустить <i>Сеть -> Установить соединение с интернетом -> Использовать Lan кабель -> Специальный -> PPPoE -> Login: PPP , Password: PPP -> Тестовое соединение</i></li>
<li>4. Дождаться успешной прошивки, если что то пойдёт не так приставка отрубится, а может и нет.</li>
<li>5. Флэшку можно вытаскивать и убирать, больше не понадобится. При последующем запуске будет грузится с жёсткого диска приставки.</li>
</ul>
<p>В целом гайдов полно, у парней, которых я указал выше поподробнее всё расписано. Ещё крутой репозиторий по теме <a href="https://github.com/FalsePhilosopher/PPPwnWRT">FalsePhilosopher</a>. Его тестил на mipsel, отлично.</p>
<h3>Запуск с установкой</h3>
<ul>
<li>1. Скопировать на роутер, запустить install.sh из директории</li>
<li>2. Ответить на вопросы, нужно для конфига</li>
<li>3. Запустить <kbd>sh /opt/etc/pppwn_ctl web_start</kbd>, будет доступен локально например 192.168.1.1:9590</li>
<li>4. Начать с пункта 2 обычного запуска.</li>
</ul>
<p>Список команд <kbd>sh /opt/etc/pppwn_ctl help</kbd></p>
