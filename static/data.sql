--
-- Data sourced from https://spring.io/projects/spring-boot#support
--
INSERT INTO broadcom_support_matrix (spring_boot, initial_release, end_of_oss_support, end_of_commercial_support) VALUES
    ('3.4', '2024-11-21'::date,	'2025-11-21'::date, '2027-02-21'::date),
    ('3.3', '2024-05-23'::date,	'2025-05-23'::date, '2026-08-23'::date),
    ('3.2', '2023-11-23'::date,	'2024-11-23'::date, '2026-02-23'::date),
    ('3.1', '2023-05-18'::date,	'2024-05-18'::date, '2025-08-18'::date),
    ('3.0', '2022-11-24'::date,	'2023-11-24'::date, '2025-02-24'::date),
    ('2.7', '2022-05-19'::date,	'2023-11-24'::date, '2026-12-31'::date),
    ('2.6', '2021-11-17'::date,	'2022-11-24'::date, '2024-02-24'::date),
    ('2.5', '2021-05-20'::date,	'2022-05-19'::date, '2023-08-24'::date),
    ('2.4', '2020-11-12'::date,	'2021-11-18'::date, '2023-02-23'::date),
    ('2.3', '2020-05-15'::date,	'2021-05-20'::date, '2022-08-20'::date),
    ('2.2', '2019-10-16'::date,	'2020-10-16'::date, '2022-01-16'::date),
    ('2.1', '2018-10-30'::date,	'2019-10-30'::date, '2021-01-30'::date),
    ('2.0', '2018-03-01'::date,	'2019-03-01'::date, '2020-06-01'::date),
    ('1.5', '2017-01-30'::date,	'2019-08-06'::date, '2020-11-06'::date)
ON CONFLICT DO NOTHING;

--
-- Data sourced by going through the Spring Boot documentation
-- https://docs.spring.io/spring-boot/system-requirements.html
--
INSERT INTO spring_boot_java_matrix (spring_boot, minimum_java_version) VALUES
    ('1.0', 6),
    ('1.3', 7),
    ('2.0', 8),
    ('3.0', 17)
ON CONFLICT DO NOTHING;

--
-- Going through the Java driver GitHub repo tag by tag
-- https://github.com/neo4j/neo4j-java-driver/tags
--
INSERT INTO driver_java_matrix (neo4j_java_driver, minimum_java_version) VALUES
    ('1.0', 7),
    ('1.5', 8),
    ('2.0', 8),
    ('5.x', 17)
ON CONFLICT DO NOTHING;

--
-- Conversations and common sense
--
INSERT INTO driver_support_matrix (neo4j_java_driver, supported) VALUES
    ('1.0', false),
    ('4.4', true),
    ('5.x', true)
ON CONFLICT DO NOTHING;

--
-- https://github.com/neo4j/neo4j-java-driver/wiki
--
INSERT INTO  driver_server_matrix (neo4j_java_driver, neo4j_versions) VALUES
    ('1.0', ['3.0']),
    ('1.1', ['3.0', '3.1']),
    ('1.2', ['3.0', '3.1']),
    ('1.3', ['3.0', '3.1', '3.2']),
    ('1.4', ['3.0', '3.1', '3.2', '3.3']),
    ('1.5', ['3.0', '3.1', '3.2', '3.3']),
    ('1.6', ['3.2', '3.3', '3.4']),
    ('1.7', ['3.3', '3.4', '3.5']),
    ('4.0', ['3.5', '4.0']),
    ('4.1', ['3.5', '4.0', '4.1']),
    ('4.2', ['3.5', '4.0', '4.1', '4.2']),
    ('4.3', ['3.5', '4.0', '4.1', '4.2', '4.3']),
    ('4.4', ['3.5', '4.0', '4.1', '4.2', '4.3', '4.4', '5.x']),
    ('5.x', ['4.3', '4.4', '5.x'])
ON CONFLICT DO NOTHING;

--
-- https://github.com/neo4j-documentation/knowledge-base/blob/master/articles/modules/ROOT/pages/neo4j-supported-versions.adoc
--
WITH hlp AS (
    SELECT * FROM VALUES
        ('5.24', 'September 27, 2024', null), ('5.23', 'August 22, 2024', null),
        ('5.22', 'July 24, 2024', null),
        ('5.21', 'June 28, 2024', null),
        ('5.20', 'May 23, 2024', null),
        ('5.19', 'April 12, 2024', null),
        ('5.18', 'March 13, 2024', null),
        ('5.17', 'February 23, 2024', null),
        ('5.16', 'January 22, 2024', null),
        ('5.15', 'December 15, 2023', null),
        ('5.14', 'November 24, 2023', null),
        ('5.13', 'October 23, 2023', null),
        ('5.12', 'September 15, 2023', null),
        ('5.11', 'August 14, 2023', null),
        ('5.10', 'July 19, 2023', null),
        ('5.9', 'June 15, 2023', null),
        ('5.8', 'May 16, 2023', null),
        ('5.7', 'April 20, 2023', null),
        ('5.6', 'March 24, 2023', null),
        ('5.5', 'February 16, 2023', null),
        ('5.4', 'January 26, 2023', null),
        ('5.3', 'December 15, 2022', null),
        ('5.2', 'November 21, 2022', null),
        ('5.1', 'October 24, 2022', null),
        ('5.0', 'October 06, 2022', null),
        ('4.4', 'December 2, 2021', 'November 30, 2025'),
        ('4.3', 'June 17, 2021', 'December 16, 2022'),
        ('4.2', 'November 17, 2020', 'May 16, 2022'),
        ('4.1', 'June 23, 2020', 'December 22, 2021'),
        ('4.0', 'January 15, 2020', 'July 14, 2021'),
        ('3.5', 'November 29, 2018', 'May 27, 2022'),
        ('3.4', 'May 17, 2018', 'March 31, 2020'),
        ('3.3', 'October 24, 2017', 'April 28, 2019'),
        ('3.2', 'May 11, 2017', 'November 30, 2018'),
        ('3.1', 'December 13, 2016', 'June 13, 2018'),
        ('3.0', 'April 16, 2016', 'October 31, 2017'),
        ('2.3', 'October 21, 2015', 'April 21, 2017'),
        ('2.2', 'March 25, 2015', 'September 25, 2016'),
        ('2.1', 'May 29, 2014', 'November 29, 2015'),
        ('2.0', 'December 11, 2013', 'June 11, 2015'),
        ('1.9', 'May 21, 2013', 'November 21, 2014'),
        ('1.8', 'September 28, 2012', 'March 28, 2014'),
        ('1.7', 'April 18, 2012', 'October 18, 2013'),
        ('1.6', 'January 22, 2012', 'July 22, 2013'),
        ('1.5', 'November 9, 2011', 'March 9, 2013'),
        ('1.4', 'July 8, 2011', 'January 8, 2013'),
        ('1.3', 'April 12, 2011', 'September 12, 2012'),
        ('1.2', 'December 29, 2010', 'June 29, 2012'),
        ('1.1', 'July 30, 2010', 'January 30, 2012'),
        ('1.0', 'February 23, 2010', 'August 23, 2011') src(neo4j, release_date, end_of_support)
), formatted AS (
    SELECT neo4j,
           strptime(release_date, '%B %-d, %Y')   AS release_date,
           strptime(end_of_support, '%B %-d, %Y') AS end_of_support
    FROM hlp
)
INSERT INTO neo4j_versions BY NAME SELECT * FROM formatted ON CONFLICT DO NOTHING;
