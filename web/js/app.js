const runBtn    = document.getElementById('runBtn');
const stopBtn   = document.getElementById('stopBtn');
const statusBtn = document.getElementById('statusBtn');
const clearBtn  = document.getElementById('clearBtn');
const output    = document.getElementById('output');
const status    = document.getElementById('status');

function PPPWN_command_status( message , type = 'success' ) {
	status.textContent = message;
	status.className   = `status ${type}`;
	setTimeout( () => {
		status.style.opacity = '0';
		setTimeout( () => {
			status.className = 'status';
			status.style.opacity = '1';
		} , 300 );
	} , 3000 );
}

async function PPPWN_run_command( command , btn ) {
	try {
		PPPWN_command_status( 'Запускаем процесс...' , 'success' );
		btn.disabled   = true;
		const response = await fetch( '/pppwn_ctl.php' , {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json',
			},
			body: JSON.stringify({
				command: command,
				timeout: 300 // 5 минут
			})
		});
		const result        = await response.json();
		output.textContent += `=== Команда ${command} ===\n`;
		output.textContent += result.output || '(нет вывода)';
		output.textContent += `\n\nКод возврата: ${result.code}\n`;
		output.textContent += '='.repeat(50) + '\n\n';
		output.scrollTop    = output.scrollHeight;
		PPPWN_command_status( `Процесс завершен с кодом ${result.code}` , result.code == 0 ? 'success' : 'error' );
	} catch ( error ) {
		output.textContent += `ОШИБКА: ${error.message}\n`;
		output.textContent += '='.repeat(50) + '\n\n';
		PPPWN_command_status( `Ошибка: ${error.message}` , 'error' );
		console.error( 'Error:' , error );
	} finally {
		btn.disabled  = false;
	}
}

async function PPPWN_start() {
	PPPWN_run_command( "start" , runBtn );
}
async function PPPWN_stop() {
	PPPWN_run_command( "stop" , stopBtn );
}
async function PPPWN_status() {
	PPPWN_run_command( "status" , statusBtn );
}

function ClearOutput() {
	output.textContent = '';
	PPPWN_command_status( 'Вывод очищен' , 'success' );
}

runBtn.addEventListener( 'click'   , PPPWN_start );
stopBtn.addEventListener( 'click'  , PPPWN_stop );
statusBtn.addEventListener( 'click'  , PPPWN_status );
clearBtn.addEventListener( 'click' , ClearOutput );

window.addEventListener( 'load' , () => {
	output.textContent  = 'Готов к работе...\n';
	output.textContent += 'Введите аргументы и нажмите "Запустить"\n';
	output.textContent += '='.repeat(50) + '\n\n';
});