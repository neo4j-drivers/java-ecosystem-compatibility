--
-- broadcom_support_matrix
--
CREATE TABLE IF NOT EXISTS broadcom_support_matrix (
    spring_boot               VARCHAR(32) PRIMARY KEY,
    initial_release           DATE NOT NULL,
    end_of_oss_support        DATE,
    end_of_commercial_support DATE
);
COMMENT ON TABLE broadcom_support_matrix IS 'State of support for Spring Boot from Broadcom';

--
-- spring_boot_java_matrix
--
CREATE TABLE IF NOT EXISTS spring_boot_java_matrix (
    spring_boot               VARCHAR(32) PRIMARY KEY,
    minimum_java_version      USMALLINT NOT NULL
);
COMMENT ON TABLE spring_boot_java_matrix IS 'State of Java versions for Spring Boot';

--
-- driver_java_matrix
--
CREATE TABLE IF NOT EXISTS driver_java_matrix (
    neo4j_java_driver         VARCHAR(32) PRIMARY KEY,
    minimum_java_version      USMALLINT NOT NULL
);
COMMENT ON TABLE driver_java_matrix IS 'State of Java versions for the Neo4j Driver';

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
COMMENT ON TABLE driver_support_matrix IS 'Support status for Neo4j Java driver';

--
-- driver_server_matrix
--
CREATE TABLE IF NOT EXISTS driver_server_matrix (
    neo4j_java_driver  VARCHAR(32) PRIMARY KEY,
    neo4j_versions     VARCHAR(32)[] NOT NULL
);
COMMENT ON TABLE driver_server_matrix IS 'Which server versions are supported by the specific driver';

--
-- neo4j_versions
--
CREATE TABLE IF NOT EXISTS neo4j_versions (
    neo4j             VARCHAR(32) PRIMARY KEY,
    release_date      DATE NOT NULL,
    end_of_support    DATE
);
COMMENT ON TABLE neo4j_versions IS 'Neo4j versions, their release dates and potentially, end of support date';

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


