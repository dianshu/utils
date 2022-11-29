apt update && apt-get install -y g++ gcc distcc ccache
apt autoremove -y

username=distcc
if id -u $username >/dev/null 2>&1; then
    echo "$username exists, skip creation"
else
    echo "create user: $username"
    useradd -s /bin/bash -m distcc
fi

homedir="/home/$username"

echo /usr/lib/ccache/g++ > $homedir/distcc_cmdlist.cfg
echo /usr/lib/ccache/gcc >> $homedir/distcc_cmdlist.cfg

cat > $username/run.sh << EOF
#!/bin/bash
export DISTCC_CMDLIST="$homedir/distcc_cmdlist.cfg"
export CCACHE_DIR=$homedir/.ccache

distccd \\
    --daemon \\
    --no-detach \\
    --user "$username" \\
    --port 3632 \\
    --stats \\
    --stats-port 3633 \\
    --log-stderr \\
    --listen "0.0.0.0" \\
    --allow "0.0.0.0/0" \\
    --nice 5 \\
    --jobs 4
EOF

chmod 777 $username/run.sh