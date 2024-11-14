# java-ecosystem-compatibility

This repository contains some scripting and base data to build a database that can answer questions like

* Which version of Neo4j Database is still in support and which Driver version is recommended for this database or
  compatible with it?
* A complete list of available releases of the Neo4j Java Driver and what servers they support
* A complete list of combinations of Spring Boot, Spring Data Neo4j (SDN, Neo4j-OGM (if applicable) and the Neo4j Java
  Driver they shipped with
* Support status for Spring Boot and SDN versions as communicated by Broadcom.

## Static data

The `static` folder contains a bunch of artisanal maintained CSV files containing the following data:

<dl>
  <dt><code>broadcom_support_matrix.csv</code></dt>
  <dd>
      Official timeline from Broadcom for Spring Boot support, sourced from <a
          href="https://spring.io/projects/spring-boot#support">https://spring.io/projects/spring-boot</a>
  </dd>
  
  <dt><code>spring_boot_java_matrix.csv</code></dt>
  <dd>Minimum required Java version for various Spring Boot releases, sourced by going through the corresponding <a
          href="https://docs.spring.io/spring-boot/system-requirements.html">manuals</a></dd>
  
  <dt><code>driver_java_matrix.csv</code></dt>
  <dd>Minimum required Java version for releases of the Neo4j Java Driver, sourced by going through the corresponding
      <a
              href="https://github.com/neo4j/neo4j-java-driver/tags">tags of the readme</a></dd>
  
  <dt><code>driver_support_matrix.csv</code></dt>
  <dd>List of supported driver versions, conversations and common sense</dd>
  
  <dt><code>driver_server_matrix.csv</code></dt>
  <dd>List of drivers and the server versions that they support, sourced from <a
          href="https://github.com/neo4j/neo4j-java-driver/wiki">https://github.com/neo4j/neo4j-java-driver/wiki</a>
  </dd>
  
  <dt><code>neo4j_versions.csv</code></dt>
  <dd>All Neo4j versions and their support dates. End of support for the 5.x series is always <code>null</code>, as
      the release of the next version ends support of the previous. From <a
              href="https://neo4j.com/developer/kb/neo4j-supported-versions">https://neo4j.com/developer/kb/neo4j-supported-versions/</a>
  </dd>
</dl>

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

Then populate it. The first run will take some time, as we grab data from Maven central and actually create some Java
projects to have the actual shipped dependencies with Spring Boot and Neo4j-OGM projects:

```bash
./bin/import_and_update.sh test.duckdb
```
