
> **Question**: If the right way of executing jobs on remote sites in the cloud is all about containment and security, then what is the wrong way?
>
> **Answer**: Remotebashing

Overview
--------
Remotebashing is a simple 2 scripts approach to executing remote jobs using `ssh`, `rsync` and `screen`.

`sync.sh` will:
- upload job assets to the remote
- upload `run.sh` scripts
- download job results
- execute `runNext.sh` over there in `screen`.

`runNext.sh` will run every job it finds and when all are done, exit.

Installation
------------
- You need `rsync`, `ssh`, `screen` and `bash`. `screen` is only used on the remote.
- Edit `sync.sh` and put the remote host in there.

Usage
-----
- Create a job by creating a directory containing a `run.sh` file, for example `example/run.sh`. Don't worry about making it executable, before upload a `chmod a+x` will be done.
- Run `sync.sh` when the job is ready to be run on the remote machine
- When you are tired of waiting or want the partial results, run `sync.sh` again.

Cleaning up
-----------
As soon as a job has had a first try, it will never run again until the `job/run.log` file is removed on the remote host. This means that sometimes you will have to manually log in and remove jobs, assets etc.
