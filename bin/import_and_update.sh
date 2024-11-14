#!/usr/bin/env bash

#
# Loads all static data and any information we can get from "the internet" into the database
#

set -euo pipefail
export LC_ALL=en_US.UTF-8

DIR="$(dirname "$(realpath "$0")")"
DB="$(pwd)/$1"

#
# Load the static data that we created in a good, old artisanal fashion
#

for csv in "$DIR"/../data/t_*.csv; do
  csv=$(realpath "$csv")
  table=$(basename "$csv" '.csv')
  table="${table#t_}"
  duckdb "$DB" \
    -s "DELETE FROM $table" \
    -s "INSERT INTO $table SELECT * FROM read_csv('$csv')"
done;

mkdir -p .tmp

#
# Getting Driver versions
#

curl -s https://repo.maven.apache.org/maven2/org/neo4j/driver/neo4j-java-driver/ | sed -nE 's/.*title="([0-9\.]*)\/".*([0-9]{4}-[0-9]{2}-[0-9]{2}).*/\1,\2/p' |
   duckdb "$DB" -s "INSERT INTO driver_versions SELECT * FROM read_csv('/dev/stdin', header=false) ON CONFLICT DO NOTHING"

#
# Getting OGM versions that include the Java (Bolt) driver
#

# shellcheck disable=SC2016
echo '<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
     xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>org.neo4j</groupId>
  <artifactId>ogm-version-checker</artifactId>
  <version>0.0.1-SNAPSHOT</version>
  <properties>
    <java.version>17</java.version>
  </properties>
  <dependencies>
    <dependency>
      <groupId>org.neo4j</groupId>
      <artifactId>neo4j-ogm-bolt-driver</artifactId>
      <version>${ogmVersion}</version>
    </dependency>
  </dependencies>
  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-dependency-plugin</artifactId>
        <version>3.8.1</version>
      </plugin>
    </plugins>
  </build>
</project>' > .tmp/pom.xml

# Get all the dependencies, the regex for set will exclude OGM versions that require any RC, Milestone or beta releases of the driver
echo "neo4j_ogm,neo4j_java_driver" > .tmp/ogm_driver.csv
for ogm in $(\
  xidel -se '/metadata/versioning/versions/version' https://repo.maven.apache.org/maven2/org/neo4j/neo4j-ogm-bolt-driver/maven-metadata.xml | \
  duckdb "$DB" -noheader -csv -s "SELECT * from read_csv('/dev/stdin', header=false, columns={'neo4j_ogm': 'VARCHAR'}) ANTI JOIN ogm_versions USING (neo4j_ogm) WHERE NOT regexp_matches(neo4j_ogm, '[A-Za-z]')"\
); do
  set +e
  mvn -B -f .tmp/pom.xml -DogmVersion="$ogm" dependency:tree -Dincludes=org.neo4j.driver:neo4j-java-driver | sed -nE "s/.*org\.neo4j\.driver:neo4j-java-driver:jar:([0-9\.]*):compile/$ogm,\1/p" >> .tmp/ogm_driver.csv
  set -e
done

echo "neo4j_ogm,release_date" > .tmp/release_dates.csv
curl -s https://repo.maven.apache.org/maven2/org/neo4j/neo4j-ogm-bolt-driver/ | sed -nE 's/.*title="([0-9\.]*)\/".*([0-9]{4}-[0-9]{2}-[0-9]{2}).*/\1,\2/p' >> .tmp/release_dates.csv

duckdb "$DB" -s "INSERT INTO ogm_versions BY NAME SELECT * FROM read_csv('.tmp/ogm_driver.csv') od JOIN read_csv('.tmp/release_dates.csv') ord USING (neo4j_ogm) ON CONFLICT DO NOTHING";

#
# Getting Spring Boot versions, and SDN versions from Boots dependency management
#

# shellcheck disable=SC2016
echo '<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		 xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>
	<groupId>org.neo4j</groupId>
	<artifactId>sdn-version-checker</artifactId>
	<version>0.0.1-SNAPSHOT</version>
	<properties>
		<java.version>17</java.version>
	</properties>
	<dependencyManagement>
		<dependencies>
			<dependency>
				<groupId>org.springframework.boot</groupId>
				<artifactId>spring-boot-dependencies</artifactId>
				<version>${bootVersion}</version>
				<type>pom</type>
				<scope>import</scope>
			</dependency>
		</dependencies>
	</dependencyManagement>
	<dependencies>
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-data-neo4j</artifactId>
		</dependency>
	</dependencies>
	<build>
		<plugins>
			<plugin>
				<groupId>org.apache.maven.plugins</groupId>
				<artifactId>maven-dependency-plugin</artifactId>
				<version>3.8.1</version>
			</plugin>
		</plugins>
	</build>
</project>
' > .tmp/pom.xml

# Get all the dependencies
for sb in $(\
  xidel -se '/metadata/versioning/versions/version' https://repo.maven.apache.org/maven2/org/springframework/boot/spring-boot/maven-metadata.xml | \
  duckdb "$DB" -noheader -csv -s "SELECT * from read_csv('/dev/stdin', header=false, columns={'spring_boot': 'VARCHAR'}) ANTI JOIN spring_boot_versions USING (spring_boot) WHERE f_make_version(spring_boot) >= [1,4,0] "\
); do
  set +e
  mvn -B -q -f .tmp/pom.xml -DoutputFile="$sb".json -DoutputType=json -DbootVersion="$sb" dependency:tree >/dev/null 2>/dev/null
  set -e
done

# Get release dates from the maven index, might not be 100% accurate, but good enough
curl -s https://repo.maven.apache.org/maven2/org/springframework/boot/spring-boot/ | sed -nE 's/.*title="(.*)\/".*([0-9]{4}-[0-9]{2}-[0-9]{2}).*/\1,\2/p' > .tmp/release_dates.csv

# Extract dependency information
if compgen -G ".tmp/*.json" > /dev/null;
then
duckdb "$DB" \
-s "
  WITH parent AS (
    SELECT unnest(children, recursive:=true) from read_json('.tmp/*.json')
  ), starter AS (
    SELECT version AS spring_boot, unnest(children, recursive:=true) FROM parent
  ), ogm AS (
    SELECT spring_boot, artifactId AS parent, version AS parentVersion, unnest(children, recursive:=true) FROM starter
  ), driver_via_ogm AS (
    SELECT spring_boot, artifactId AS parent, version AS parentVersion, unnest(children, recursive:=true) FROM ogm
  ), driver_via_sdn AS (
     SELECT spring_boot, artifactId AS parent, version AS parentVersion, unnest(children, recursive:=true) FROM starter
     WHERE starter.artifactId = 'spring-data-neo4j'
  )
  INSERT INTO spring_boot_versions BY NAME
  SELECT starter.spring_boot,
         r.release_date,
         starter.version AS spring_data_neo4j,
         ogm.version     AS neo4j_ogm,
         coalesce(driver_via_ogm.version, driver_via_sdn.version) AS neo4j_java_driver
  FROM starter
  NATURAL JOIN read_csv('.tmp/release_dates.csv', header=false, columns={'spring_boot': 'VARCHAR', 'release_date': 'DATE'}) r
  LEFT OUTER JOIN ogm ON
     ogm.parent = starter.artifactId AND
     ogm.parentVersion = starter.version AND
     ogm.spring_boot = starter.spring_boot AND
     ogm.artifactId = 'neo4j-ogm-core'
   LEFT OUTER JOIN driver_via_ogm ON
      driver_via_ogm.parent ='neo4j-ogm-bolt-driver' AND
      driver_via_ogm.parentVersion = ogm.version AND
      driver_via_ogm.spring_boot = starter.spring_boot AND
      driver_via_ogm.artifactId = 'neo4j-java-driver'
   LEFT OUTER JOIN driver_via_sdn ON
     driver_via_sdn.parent = starter.artifactId AND
     driver_via_sdn.parentVersion = starter.version AND
     driver_via_sdn.spring_boot = starter.spring_boot AND
     driver_via_sdn.artifactId = 'neo4j-java-driver'
  WHERE starter.artifactId = 'spring-data-neo4j'
  ON CONFLICT DO NOTHING
"
fi

rm -rf .tmp
