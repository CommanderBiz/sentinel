# Termux-Sentinel

`Termux-Sentinel` is a Python-based probe for monitoring system health and the status of Monero miners on your network.

## Features

- **System Monitoring:** Checks local CPU and RAM usage.
- **Miner Probing:** Queries the API of XMRig miners (or any compatible API) to retrieve the current hashrate.
- **Single Host Check:** Gathers stats from a specific host on your network.
- **Network Scanning:** Scans an entire network range to discover and report on all active miners.

## Installation

You can download the script to any machine using `wget`:

```bash
wget https://raw.githubusercontent.com/CommanderBiz/termux-sentinel/main/probe.py
```

## Usage

The script requires Python 3 and the `requests` and `psutil` libraries.

### Check a Single Miner

Use the `--host` and `--port` arguments to check a specific miner.

```bash
python3 probe.py --host mini0 --port 8000
```

### Scan the Network for Miners

Use the `--scan` argument with a network range in CIDR notation to find all active miners.

```bash
python3 probe.py --scan 192.168.1.0/24 --port 8000
```
