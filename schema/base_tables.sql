--
-- broadcom_support_matrix
--
CREATE TABLE IF NOT EXISTS broadcom_support_matrix (
    spring_boot               VARCHAR(32) PRIMARY KEY,
    initial_release           DATE NOT NULL,
    end_of_oss_support        DATE,
    end_of_commercial_support DATE
);
COMMENT ON TABLE broadcom_support_matrix IS 'Official timeline from Broadcom for Spring Boot support, sourced from <a href="https://spring.io/projects/spring-boot#support">https://spring.io/projects/spring-boot</a>';

--
-- spring_boot_java_matrix
--
CREATE TABLE IF NOT EXISTS spring_boot_java_matrix (
    spring_boot               VARCHAR(32) PRIMARY KEY,
    minimum_java_version      USMALLINT NOT NULL
);
COMMENT ON TABLE spring_boot_java_matrix IS 'Minimum required Java version for various Spring Boot releases, sourced by going through the corresponding <a href="https://docs.spring.io/spring-boot/system-requirements.html">manuals</a>';

--
-- driver_java_matrix
--
CREATE TABLE IF NOT EXISTS driver_java_matrix (
    neo4j_java_driver         VARCHAR(32) PRIMARY KEY,
    minimum_java_version      USMALLINT NOT NULL
);
COMMENT ON TABLE driver_java_matrix IS 'Minimum required Java version for releases of the Neo4j Java Driver, sourced by going through the corresponding <a href="https://github.com/neo4j/neo4j-java-driver/tags">tags of the readme</a>';

--
-- driver_versions
--
CREATE TABLE IF NOT EXISTS driver_versions (
    neo4j_java_driver  VARCHAR(32) PRIMARY KEY,
    release_date       DATE
);
COMMENT ON TABLE driver_versions IS 'Known Neo4j Driver versions';

--
-- spring_boot_versions
--
CREATE TABLE IF NOT EXISTS spring_boot_versions (
    spring_boot        VARCHAR(32) PRIMARY KEY,
    release_date       DATE,
    spring_data_neo4j  VARCHAR(32),
    neo4j_ogm          VARCHAR(32),
    neo4j_java_driver  VARCHAR(32),
);
COMMENT ON TABLE spring_boot_versions IS 'Known Spring Boot versions. This contains also the SDN version that shipped with the specific Spring Boot release. We might miss one or two, but that doesn''t matter, as there was hardly every a patch release of SDN without a corresponding Spring Boot release';

--
-- ogm_versions
--
CREATE TABLE IF NOT EXISTS ogm_versions (
    neo4j_ogm          VARCHAR(32) PRIMARY KEY,
    release_date       DATE,
    neo4j_java_driver  VARCHAR(32)
);
COMMENT ON TABLE ogm_versions IS 'Known OGM versions';

--
-- driver_support_matrix
--
CREATE TABLE IF NOT EXISTS driver_support_matrix (
    neo4j_java_driver  VARCHAR(32) PRIMARY KEY,
    supported          BOOLEAN NOT NULL
);
COMMENT ON TABLE driver_support_matrix IS 'List of supported driver versions, conversations and common sense';

--
-- driver_server_matrix
--
CREATE TABLE IF NOT EXISTS driver_server_matrix (
    neo4j_java_driver  VARCHAR(32) PRIMARY KEY,
    neo4j_versions     VARCHAR(32)[] NOT NULL
);
COMMENT ON TABLE driver_server_matrix IS 'List of drivers and the server versions that they support, sourced from <a href="https://github.com/neo4j/neo4j-java-driver/wiki">https://github.com/neo4j/neo4j-java-driver/wiki</a>';

--
-- neo4j_versions
--
CREATE TABLE IF NOT EXISTS neo4j_versions (
    neo4j             VARCHAR(32) PRIMARY KEY,
    release_date      DATE NOT NULL,
    end_of_support    DATE
);
COMMENT ON TABLE neo4j_versions IS 'All Neo4j versions and their support dates. End of support for the 5.x series is always <code>null</code>, as the release of the next version ends support of the previous. From <a href="https://neo4j.com/developer/kb/neo4j-supported-versions">https://neo4j.com/developer/kb/neo4j-supported-versions/</a>';

--
-- ogm_support_matrix
--
CREATE TABLE IF NOT EXISTS ogm_support_matrix (
    neo4j_ogm VARCHAR(32) PRIMARY KEY,
    bolt_only BOOLEAN NOT NULL,
    status    VARCHAR(32) NOT NULL CHECK (status IN ('unsupported', 'bugfix', 'supported')),
    supported_driver_lines VARCHAR(32)[]
);
COMMENT ON TABLE ogm_support_matrix IS 'The status of OGM support';


