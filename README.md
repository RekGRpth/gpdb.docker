# gpdb.docker

- Build docker image. For example, for working with GPDB7 use:

```sh
./build7.sh
```

- Set permissions for docker folders:

```sh
sudo chmod 750 /var/lib/docker/containers
sudo chmod 751 /var/lib/docker
sudo chmod 755 /var/lib/docker/volumes
```

Note: To make this persist after a restart, you need to add this in the autoload, e.g. to the `/etc/rc.local` file.

- Create docker volume

```sh
docker volume create gpdb
```

- Set permissions for volume

```sh
sudo chown -R <your_username>:<your_group> /var/lib/docker/volumes/gpdb
```

- Create symbolic link for ease of access to data

```sh
ln -fs /var/lib/docker/volumes/gpdb/_data ~/gpdb
```

- Create src code dir and download src code

```sh
mkdir ~/gpdb/src
git clone https://github.com/RekGRpth/arenadata.sh.git ~/gpdb/src
git clone --branch 7.x --recurse-submodules https://github.com/GreengageDB/greengage.git ~/gpdb/src/gpdb7
```

- If you want work with cluster in **RAM** (e.g. in `/tmpfs/data/7`), create dir:

```sh
sudo mkdir -p /tmpfs/data/7
sudo chmod 755 /tmpfs/data/7
sudo chown -R <your_username>:<your_group> /tmpfs/data/7
```

Note: To make this persist after a restart, you need to add this in the autoload, e.g. to the `/etc/rc.local` file.

Also create next `.bashrc`:

```sh
cat <<'EOF' > ~/gpdb/.bashrc
export DATADIRS="$HOME/.data"
export COORDINATOR_DATA_DIRECTORY="$DATADIRS/qddir/demoDataDir-1"
export MASTER_DATA_DIRECTORY="$DATADIRS/qddir/demoDataDir-1"
test -f "$GPHOME/greenplum_path.sh" && source "$GPHOME/greenplum_path.sh"
test -f "$GPHOME/greengage_path.sh" && source "$GPHOME/greengage_path.sh"
EOF
```

- Or if you want to use **disk** just remove this bind from `run7.sh`:

```diff
-    --mount type=bind,source="/tmpfs/data/$GP_MAJOR",destination=/home/gpadmin/.data \
```

And create the same `.bashrc` but without first export:

```sh
cat <<'EOF' > ~/gpdb/.bashrc
export COORDINATOR_DATA_DIRECTORY="$DATADIRS/qddir/demoDataDir-1"
export MASTER_DATA_DIRECTORY="$DATADIRS/qddir/demoDataDir-1"
test -f "$GPHOME/greenplum_path.sh" && source "$GPHOME/greenplum_path.sh"
test -f "$GPHOME/greengage_path.sh" && source "$GPHOME/greengage_path.sh"
EOF
```

- Run script

```sh
./run7.sh
```

It sets other settings and runs docker image `gpdb7`.

Attention! This clears all unmounted data from image, run it only if you need
to reset state or after rebuild of docker image.
No need to run it after restart of host system because the container runs automatically.

- Connect to container

```sh
docker exec -it gpdb7 bash
```

- Enjoy, for example, to make demo cluster, run inside container:

```sh
~/src/config.sh
~/src/clean.sh
~/src/build.sh
~/src/demo.sh
```

## Work with GPDB in VS Code

- To debug GPDB use VS Code [Remote Explorer extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.remote-explorer).

- Open `$HOME/gpdb_src` folder inside docker image `gpdb7`.

- Install [ms-vscode.cpptools-extension-pack](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools-extension-pack) inside container.

- `launch.json` can be:

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
                    "description": "Follow the child process after fork",
                    "text": "set follow-fork-mode child",
                    "ignoreFailures": true
                },
                {
                    "description": "Keep both parent and child processes attached after fork",
                    "text": "set detach-on-fork off",
                    "ignoreFailures": true
                }
            ]
        }
    ]
}
```

- `c_cpp_properties.json` file can have:

```json
{
    "configurations": [
        {
            "name": "Linux",
            "includePath": [
                "${workspaceFolder}/**",
                "${env:HOME}/gpdb_src/src/**",
                "/usr/include/**"
            ],
            "defines": [],
            "compilerPath": "/usr/bin/gcc",
            "cStandard": "c11",
            "cppStandard": "c++14",
            "intelliSenseMode": "linux-gcc-x64"
        }
    ],
    "version": 4
}
```

- Or you can use `*.code-workspace` file on host, e.g.

```json
{
  "folders": [
    { "uri": "vscode-remote://attached-container+<container_id>/home/gpadmin/gpdb_src" }
  ],
  "remoteAuthority": "attached-container+<container_id>",
  "settings": {
    "C_Cpp.default.includePath": [
      "${workspaceFolder}/**",
      "${env:HOME}/gpdb_src/src/**",
      "/usr/include/**"
    ],
    "C_Cpp.default.defines": [],
    "C_Cpp.default.compilerPath": "/usr/bin/gcc",
    "C_Cpp.default.cStandard": "c11",
    "C_Cpp.default.cppStandard": "gnu++14",
    "C_Cpp.default.intelliSenseMode": "linux-gcc-x64"
  },
  "extensions": {
    "recommendations": [
      "ms-vscode.cpptools-extension-pack",
      "eamodio.gitlens"
    ]
  },
  "launch": {
    // Paste launch.json settings here
  }
}
```

where the `container_id` can be viewed as

```sh
echo -n '{"containerName":"/gpdb7"}' | xxd -p
```
