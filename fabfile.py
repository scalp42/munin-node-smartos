
from fabric.api import run, env, put, open_shell, prompt

env.hosts = ['munin']

env.use_ssh_config = True

env.warn_only = 1

env.output_prefix = 1

def shell():
	open_shell()

def upload():
	remote_dir = prompt('Remote path ?')
	file = prompt('File ?')
	put(file, remote_dir, mode=0750)

def prepare_munin():
    run('rm -f munin-node*')
    run('wget --no-check-certificate https://raw.github.com/scalp42/munin-node-smartos/master/munin-node-install.sh')
    run('chmod +x munin-node-install.sh')

def install_munin():
    run('bash nrpe_install.sh')

def clean_munin():
	run('rm -fr ~/munin-2.0.0*')

def restart_munin():
	run('svcadm disable munin-node')
	run('svcadm enable munin-node')

def perms_nrpe():
	run('chown -R munin:munin /usr/local/munin')