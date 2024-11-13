# java-ecosystem-compatibility

This repository contains some scripting and base data to build a database that can answer questions like

* Which version of Neo4j Database is still in support and which Driver version is recommended for this database or compatible with it?
* A complete list of available releases of the Neo4j Java Driver and what servers they support
* A complete list of combinations of Spring Boot, Spring Data Neo4j (SDN, Neo4j-OGM (if applicable) and the Neo4j Java Driver they shipped with
* Support status for Spring Boot and SDN versions as communicated by Broadcom.

## Required tooling

* [DuckDB](https://duckdb.org) >= 1.1
* [Java](https://adoptium.net/de/temurin/releases/?version=17) >= 17
* [Apache Maven](https://maven.apache.org) >= 3.9
* [xidel](https://www.videlibri.de/xidel.html)
* A shell that supports `sed` and `compgen`

## Create and populate a database

All scripts are idempotent and can be safely run multiple times.
First create an empty database:

```bash
./bin/create_or_update_database.sh test.duckdb
```

Then populate it. The first run will take some time, as we grab data from Maven central and actually create some Java projects to have the actual shipped dependencies with Spring Boot and Neo4j-OGM projects:

```bash
./bin/import_and_update.sh test.duckdb
```
