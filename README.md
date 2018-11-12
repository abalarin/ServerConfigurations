# Welcome to Automated Server Configuration Scripts!
This is a way to automate your server configuration

## Getting Started - ServerSetupAutomater`

Install expect mac: `brew install expect`

To start the automater run `ServerSetupAutomater.exp`

```
Usage: `./ServerSetupAutomater.exp` <host> <ssh_user> <ssh_password> <config_script>

Example1: `./ServerSetupAutomater.exp 11.111.11.11`

Example2: `./ServerSetupAutomater.exp 11.111.11.11 root password UbuntuConfig.sh`
```

### `ServerSetupAutomater.exp` is just a script loader

ServerSetupAutomater is not actually modifying any your server configurations!

Its basically just allowing you to to start configuration from your local machine

* It requests login credentials (if not already provided on command line)
* Test connectivity to host
* * If connection can't be established - exit script
* Prompt for a `Server Config Script` (if not already provided on command line). You could user `UbuntuConfig.sh`
* SCP `Server Config Script` to hostname
* Prompt and SCP aliases if desired
* SSH into host and run the `Server Config Script`
