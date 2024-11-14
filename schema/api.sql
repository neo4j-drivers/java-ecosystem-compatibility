--
-- v_sdn_versions
--
CREATE OR REPLACE VIEW v_sdn_versions AS (
  WITH hlp AS (
    SELECT *, f_make_version(v.spring_boot) AS orderable_version,
    FROM spring_boot_versions v WHERE spring_data_neo4j IS NOT NULL
  )
  SELECT v.* EXCLUDE(release_date, orderable_version),
         sj.minimum_java_version,
         release_date,
         least(end_of_oss_support, lead(release_date) OVER release_order) AS end_of_oss_support,
         least(end_of_commercial_support, lead(release_date) OVER release_order) AS end_of_commercial_support
  FROM hlp v
  ASOF LEFT JOIN broadcom_support_matrix sm ON v.orderable_version >= f_make_version(sm.spring_boot)
  ASOF LEFT JOIN spring_boot_java_matrix sj ON v.orderable_version >= f_make_version(sj.spring_boot)
  WINDOW release_order AS (PARTITION BY f_make_version(v.spring_boot)[1:2] ORDER BY orderable_version ASC)
  ORDER BY orderable_version DESC
);
COMMENT ON VIEW v_sdn_versions IS
    'The list of all combinations of Spring Boot and SDN versions and whether they are supported in either an OSS or commercially way.';


--
-- v_oss_supported_sdn_versions
--
CREATE OR REPLACE VIEW v_oss_supported_sdn_versions AS (
  SELECT * EXCLUDE(neo4j_ogm)
  FROM v_sdn_versions v
  WHERE end_of_oss_support >= today()
);
COMMENT ON VIEW v_oss_supported_sdn_versions IS
    'The list of all combinations of Spring Boot and SDN versions that are still OSS supported.';


--
-- v_commercially_supported_sdn_versions
--
CREATE OR REPLACE VIEW v_commercially_supported_sdn_versions AS (
   SELECT * EXCLUDE(neo4j_ogm)
   FROM v_sdn_versions v
   WHERE end_of_commercial_support >= today()
 );
COMMENT ON VIEW v_commercially_supported_sdn_versions IS
    'The list of all combinations of Spring Boot and SDN versions that are still supported under a commercial Broadcom license.';


--
-- v_java_driver_versions
--
CREATE OR REPLACE VIEW v_java_driver_versions AS (
    WITH hlp AS (
        SELECT *, f_make_version(v.neo4j_java_driver) AS orderable_version,
        FROM driver_versions v
    ),
    dsm AS (
       SELECT *, f_make_version(neo4j_java_driver) AS orderable_version
       FROM driver_server_matrix
    )
    SELECT f_make_line(v.orderable_version) AS line,
           v.* EXCLUDE(orderable_version),
           CASE WHEN lead(v.neo4j_java_driver) OVER release_order IS NULL THEN sm.supported ELSE false END AS supported,
           dsm.neo4j_versions,
           dj.minimum_java_version
    FROM hlp v
    ASOF LEFT JOIN driver_support_matrix sm ON v.orderable_version >= f_make_version(sm.neo4j_java_driver)
    ASOF LEFT JOIN dsm ON v.orderable_version >= dsm.orderable_version
    ASOF LEFT JOIN driver_java_matrix dj ON v.orderable_version >= f_make_version(dj.neo4j_java_driver)
    WINDOW release_order AS (
       PARTITION BY IF(v.orderable_version[1] >= 5, v.orderable_version[1:1], v.orderable_version[1:2]) ORDER BY v.orderable_version ASC
    )
    ORDER BY v.orderable_version DESC
);
COMMENT ON VIEW v_java_driver_versions IS
    'The full list of all released versions of the Java driver, server_versions is a nested attribute, containing a list of supported servers.';


--
-- v_supported_java_driver_versions
--
CREATE OR REPLACE VIEW v_supported_java_driver_versions AS (
  SELECT * EXCLUDE (supported, neo4j_versions), unnest(neo4j_versions) AS neo4j
  FROM v_java_driver_versions
  WHERE supported = true
);
COMMENT ON VIEW v_supported_java_driver_versions IS 'All supported driver versions';


--
-- v_neo4j_versions
--
CREATE OR REPLACE VIEW v_neo4j_versions AS (
  SELECT f_make_line(f_make_version(neo4j)) AS line,
         neo4j,
         release_date,
         CASE WHEN end_of_support IS NULL THEN
            lag(release_date) OVER (PARTITION BY substr(neo4j, 1, instr(neo4j, '.') -1) ORDER BY f_make_version(neo4j) DESC)
         ELSE
            end_of_support
         END AS end_of_support
  FROM neo4j_versions
  ORDER BY f_make_version(neo4j) DESC
);
COMMENT ON VIEW v_neo4j_versions IS 'All known Neo4j versions';


--
-- v_neo4j_driver_support_matrix
--
CREATE OR REPLACE VIEW v_neo4j_driver_support_matrix AS (
    SELECT n.neo4j AS neo4j_version,
           n.release_date,
           n.end_of_support,
           first(d.neo4j_java_driver ORDER BY f_make_version(d.neo4j_java_driver) DESC) AS recommended_driver,
           list(DISTINCT d.line ORDER BY f_make_version(d.line) DESC) AS compatible_driver_lines,
           (end_of_support IS NULL OR end_of_support >= today() AND first(d.supported ORDER BY f_make_version(d.neo4j_java_driver) DESC)) AS supported
    FROM v_neo4j_versions n, v_java_driver_versions d
    WHERE list_contains(d.neo4j_versions, n.line)
    GROUP BY neo4j_version, n.release_date, end_of_support
    ORDER BY f_make_version(neo4j_version) DESC
);
COMMENT ON VIEW v_neo4j_driver_support_matrix IS 'Neo4j and driver support matrix';

--
-- v_neo4j_ogm_support_matrix
--
CREATE OR REPLACE VIEW v_neo4j_ogm_support_matrix AS (
    WITH dsm AS (
        SELECT *, f_make_version(neo4j_java_driver) AS orderable_version
        FROM driver_server_matrix
    ),
    drivers AS (
       SELECT *, f_make_version(neo4j_java_driver) orderable_version FROM driver_versions
    ),
    ogm_server AS (
       SELECT g.* EXCLUDE(supported_driver_lines),
              supported_driver_line,
              unnest(neo4j_versions) neo4j_version
       FROM ogm_support_matrix g, unnest(g.supported_driver_lines) AS sl(supported_driver_line)
       ASOF LEFT JOIN dsm ON f_make_version(supported_driver_line) >= dsm.orderable_version
    ),
    server_by_ogm AS (
        SELECT neo4j_ogm, status,
               -- I'd rather use min_by and max_by here, but they don't support a list argument as order criterion
               list(supported_driver_line ORDER BY f_make_version(supported_driver_line))[1] AS first_supported_driver,
               list(supported_driver_line ORDER BY f_make_version(supported_driver_line))[-1] AS last_supported_driver,
               list(neo4j_version ORDER BY f_make_version(neo4j_version)) AS Neo4j
        FROM ogm_server
        GROUP BY ALL
    )
    SELECT neo4j_ogm AS "Neo4j-OGM", status AS Status,
           list(neo4j_java_driver ORDER BY orderable_version)[1] AS "Minimum required Java driver",
           list(neo4j_java_driver ORDER BY orderable_version)[-1] AS "Maximum required Java driver",
           Neo4j,
    FROM server_by_ogm, drivers
    WHERE f_make_line(drivers.orderable_version) = f_make_line(f_make_version(first_supported_driver))
       OR f_make_line(drivers.orderable_version) = f_make_line(f_make_version(last_supported_driver))
    GROUP BY neo4j_ogm, status, Neo4j,
    ORDER BY f_make_version(neo4j_ogm) DESC
);
COMMENT ON VIEW v_neo4j_ogm_support_matrix IS 'The list of Neo4j-OGM releases, their minimum required and maximum supported Java driver and the server version they can connect to';
