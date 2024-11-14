# java-ecosystem-compatibility

This repository contains some scripting and base data to build a database that can answer questions like

* Which version of Neo4j Database is still in support and which Driver version is recommended for this database or
  compatible with it?
* A complete list of available releases of the Neo4j Java Driver and what servers they support
* A complete list of combinations of Spring Boot, Spring Data Neo4j (SDN, Neo4j-OGM (if applicable) and the Neo4j Java
  Driver they shipped with
* Support status for Spring Boot and SDN versions as communicated by Broadcom.

## The data

All data files reside in `data`.

<!-- Generated -->
### Static / artisanal maintained data

Those files are manually maintained and contain static information:

<dl>
<dt><code><a href="data/t_driver_java_matrix.csv">t_driver_java_matrix.csv</a></code></dt>
<dd>Minimum required Java version for releases of the Neo4j Java Driver, sourced by going through the corresponding <a href="https://github.com/neo4j/neo4j-java-driver/tags">tags of the readme</a></dd>
<dt><code><a href="data/t_driver_server_matrix.csv">t_driver_server_matrix.csv</a></code></dt>
<dd>List of drivers and the server versions that they support, sourced from <a href="https://github.com/neo4j/neo4j-java-driver/wiki">https://github.com/neo4j/neo4j-java-driver/wiki</a></dd>
<dt><code><a href="data/t_driver_support_matrix.csv">t_driver_support_matrix.csv</a></code></dt>
<dd>List of supported driver versions, conversations and common sense</dd>
<dt><code><a href="data/t_neo4j_versions.csv">t_neo4j_versions.csv</a></code></dt>
<dd>All Neo4j versions and their support dates. End of support for the 5.x series is always <code>null</code>, as the release of the next version ends support of the previous. From <a href="https://neo4j.com/developer/kb/neo4j-supported-versions">https://neo4j.com/developer/kb/neo4j-supported-versions/</a></dd>
<dt><code><a href="data/t_ogm_support_matrix.csv">t_ogm_support_matrix.csv</a></code></dt>
<dd>The status of OGM support</dd>
<dt><code><a href="data/t_spring_boot_java_matrix.csv">t_spring_boot_java_matrix.csv</a></code></dt>
<dd>Minimum required Java version for various Spring Boot releases, sourced by going through the corresponding <a href="https://docs.spring.io/spring-boot/system-requirements.html">manuals</a></dd>
</dl>

### Version and support matrices

Those files are generated via `export_database.sh` and contain the following information:

<dl>
<dt><code><a href="data/v_java_driver_versions.csv">v_java_driver_versions.csv</a></code></dt>
<dd>The full list of all released versions of the Java driver, server_versions is a nested attribute, containing a list of supported servers.</dd>
<dt><code><a href="data/v_neo4j_driver_support_matrix.csv">v_neo4j_driver_support_matrix.csv</a></code></dt>
<dd>Neo4j and driver support matrix</dd>
<dt><code><a href="data/v_neo4j_ogm_support_matrix.csv">v_neo4j_ogm_support_matrix.csv</a></code></dt>
<dd>The list of Neo4j-OGM releases, their minimum required and maximum supported Java driver and the server version they can connect to</dd>
<dt><code><a href="data/v_neo4j_versions.csv">v_neo4j_versions.csv</a></code></dt>
<dd>All known Neo4j versions</dd>
<dt><code><a href="data/v_sdn_versions.csv">v_sdn_versions.csv</a></code></dt>
<dd>The list of all combinations of Spring Boot and SDN versions and whether they are supported in either an OSS or commercially way.</dd>
<dt><code><a href="data/v_sdn_versions_with_commercial_support.csv">v_sdn_versions_with_commercial_support.csv</a></code></dt>
<dd>The list of all combinations of Spring Boot and SDN versions that are still supported under a commercial Broadcom license.</dd>
<dt><code><a href="data/v_sdn_versions_with_oss_support.csv">v_sdn_versions_with_oss_support.csv</a></code></dt>
<dd>The list of all combinations of Spring Boot and SDN versions that are still OSS supported.</dd>
<dt><code><a href="data/v_supported_java_driver_versions.csv">v_supported_java_driver_versions.csv</a></code></dt>
<dd>All supported driver versions</dd>
</dl>
<!-- /Generated -->

## Create and populate a database yourself

### Required tooling

* [DuckDB](https://duckdb.org) >= 1.1
* [Java](https://adoptium.net/de/temurin/releases/?version=17) >= 17
* [Apache Maven](https://maven.apache.org) >= 3.9
* [xidel](https://www.videlibri.de/xidel.html)
* A shell that supports `sed` and `compgen`

### Step by step

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
