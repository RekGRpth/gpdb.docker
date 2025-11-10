# gpdb.docker

- Build docker image. For example. for work with GPDB7 use:
```sh
./build7.sh
```

- Set permissions for docker folders:
```sh
sudo chmod 755 /var/lib/docker/volumes
sudo chown -R <your_group>:<your_username>  /var/lib/docker/volumes/gpdb
sudo chmod 751 /var/lib/docker
# Check access
ls -l /var/lib/docker/volumes/gpdb/
```

- Create symbolic link for easy of access
```sh
mkdir /var/lib/docker/volumes/gpdb/_data
ln -fs /var/lib/docker/volumes/gpdb/_data ~/gpdb
```

- Create src code dir
```sh
mkdir ~/gpdb/src
```

- Download src code
```sh
git clone https://github.com/RekGRpth/arenadata.sh.git ~/gpdb/src/arenadata.sh
git clone --branch 7.x --recurse-submodules https://github.com/GreengageDB/greengage.git ~/gpdb/src/gpdb7
```

- Create .bashrc
```sh
cat <<'EOF' > ~/gpdb/.bashrc
export COORDINATOR_DATA_DIRECTORY="$DATADIRS/qddir/demoDataDir-1"
export MASTER_DATA_DIRECTORY="$DATADIRS/qddir/demoDataDir-1"
test -f "$GPHOME/greenplum_path.sh" && source "$GPHOME/greenplum_path.sh"
test -f "$GPHOME/greengage_path.sh" && source "$GPHOME/greengage_path.sh"
EOF
```

- Correct path to cluster data in run7.sh, if needed
For example, use the following diff to make cluster in RAM for Ubuntu 22.04 :
```diff
--- a/run7.sh
+++ b/run7.sh
@@ -10,0 +11 @@ mkdir -p "$GPDB/gpAdminLogs/$GP_MAJOR"
+mkdir -p /tmp/data/$GP_MAJOR
@@ -23 +24 @@ docker run \
-    --mount type=bind,source="/tmpfs/data/$GP_MAJOR",destination=/home/gpadmin/.data \
+    --mount type=bind,source="/tmp/data/$GP_MAJOR",destination=/home/gpadmin/.data \
```

In this case `.bashrc` should contain `export DATADIRS="$HOME/.data"`.

- Run the image
```sh
./run7.sh
```

- Connect to docker image
```sh
docker exec -it --user gpadmin gpdb7 bash -c "cd ~/src && exec bash"
```

- For example, to make demo cluster, use
```sh
./arenadata.sh/config.sh
./arenadata.sh/clean.sh
./arenadata.sh/build.sh
./arenadata.sh/demo.sh
```

- To debug GPDB use VS Code Dev Container extension. Open $HOME/src/gpdb7 folder inside docker. `launch.json` can be:
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "(gdb) Attach",
            "type": "cppdbg",
            "request": "attach",
            "program": "/usr/local/greengage-db-devel/bin/postgres",
            "MIMode": "gdb",
            "miDebuggerPath": "/usr/bin/gdb",
            "targetArchitecture": "x86_64",
            "setupCommands": [
                {
                    "description": "Enable automatic pretty-printing in gdb",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                },
                {
                    "description": "Set disassembly flavor to Intel syntax",
                    "text": "-gdb-set disassembly-flavor intel",
                    "ignoreFailures": true
                },
                {
                    // https://sourceware.org/gdb/onlinedocs/gdb/Forks.html
                    "description": "Follow the child process after fork",
                    "text": "set follow-fork-mode child",
                    "ignoreFailures": true
                },
                {
                    // https://sourceware.org/gdb/onlinedocs/gdb/Forks.html
                    "description": "Keep both parent and child processes attached after fork",
                    "text": "set detach-on-fork off",
                    "ignoreFailures": true
                }
            ]
        }
    ]
}
```
