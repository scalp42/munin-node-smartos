
from fabric.api import run, env, put, open_shell, prompt

env.hosts = ['s-app1', 's-app2', 's-app3', 's-app4', 's-app5', 's-app6', 's-app7']

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
    run('bash munin-node-install.sh')

def clean_munin():
	run('rm -fr ~/munin-2.0.0*')

def restart_munin():
	run('svcadm disable munin-node')
	run('svcadm enable munin-node')

def perms_munin():
	run('chown -R munin:munin /usr/local/munin')

def get_hosts():
	run('cat /tmp/*.txt')

def allow_host():
#	run('cp /usr/local/munin/etc/munin-node.conf /usr/local/munin/etc/munin-node.conf.backup')
	run('rm -f ~/sed.txt')
	run('wget --no-check-certificate https://raw.github.com/gist/f57cf673f4dd2bf49579/b15ca6a967c58b51262ebd1f5b340f25bb44cdae/sed.txt')
	run('chmod +x sed.txt')
	run('bash sed.txt')

def update_muninconf():
	run('rm -f ~/munin-node.conf.example')
	run('wget --no-check-certificate https://raw.github.com/scalp42/munin-node-smartos/master/munin-node.conf.example')
	run('mv ~/munin-node.conf.example /usr/local/munin/etc/munin-node.conf')