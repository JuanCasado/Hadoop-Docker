
# HBASE

## Setup

```bash
virtualenv env
source ./env/bin/activate
pip install -r requirements.txt
```

## Create hbase tables

Hadoop containers must be up!

```bash
python ./src/createTables.py
```
