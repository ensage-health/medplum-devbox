\c medplum;

DO
$do$
BEGIN

IF NOT EXISTS (SELECT FROM public."ClientApplication") THEN
	WITH ref_values as (
		SELECT uuid('f54370de-eaf3-4d81-a17e-24860f667912') AS client_id,
		'75d8e7d06bf9283926c51d5f461295ccf0b69128e983b6ecdd5a9c07506895de' AS client_secret,
		'Default Application' AS app_name,
		now()::timestamp at time zone 'UTC' AS last_updated,
		(SELECT P.id FROM public."Project" P LIMIT 1) AS project_id,
		(SELECT P.id FROM public."Practitioner" P ORDER BY "lastUpdated" LIMIT 1) AS practitioner_id
	) 
	INSERT INTO public."ClientApplication"(
		id, content, "lastUpdated", compartments, name)
		VALUES ((SELECT client_id FROM ref_values),
				'{"meta":{"project":"' || (SELECT project_id FROM ref_values) || '","versionId":"' || (SELECT uuid_generate_v4()) || '","lastUpdated":"' || (SELECT to_char(last_updated, 'YYYY-MM-DD"T"HH24:MI:SS"Z"') FROM ref_values) || '","author":{"reference":"Practitioner/' || (SELECT practitioner_id FROM ref_values) || '","display":"Medplum Admin"},"compartment":[{"reference":"Project/' || (SELECT project_id FROM ref_values) || '"}]},"resourceType":"ClientApplication","name":"' || (SELECT app_name FROM ref_values) || '","secret":"' || (SELECT client_secret FROM ref_values) || '","id":"' || (SELECT client_id FROM ref_values) || '"}',
				(SELECT last_updated FROM ref_values),
				array[(SELECT project_id FROM ref_values)]::uuid[],
				(SELECT app_name FROM ref_values));

	WITH ref_values as (
		SELECT uuid('f54370de-eaf3-4d81-a17e-24860f667912') AS client_id,
		now()::timestamp at time zone 'UTC' AS last_updated,
		uuid_generate_v4() AS membership_id,
		(SELECT P.id FROM public."Project" P LIMIT 1) AS project_id
	) 
	INSERT INTO public."ProjectMembership"(
		id, content, "lastUpdated", compartments, project, "user", deleted, profile)
		VALUES ((SELECT membership_id FROM ref_values),
				'{"meta":{"project":"' || (SELECT project_id FROM ref_values) || '","versionId":"' || (SELECT uuid_generate_v4()) || '","lastUpdated":"' || (SELECT to_char(last_updated, 'YYYY-MM-DD"T"HH24:MI:SS"Z"') FROM ref_values) || '","author":{"reference":"system"},"compartment":[{"reference":"Project/' || (SELECT project_id FROM ref_values) || '"}]},"resourceType":"ProjectMembership","project":{"reference":"Project/' || (SELECT project_id FROM ref_values) || '","display":"Super Admin"},"user":{"reference":"ClientApplication/' || (SELECT client_id FROM ref_values) || '","display":"Test app"},"profile":{"reference":"ClientApplication/' || (SELECT client_id FROM ref_values) || '","display":"Test app"},"id":"' || (SELECT membership_id FROM ref_values) || '"}',
				(SELECT last_updated FROM ref_values),
				array[(SELECT project_id FROM ref_values)]::uuid[],
				'Project/' || (SELECT project_id FROM ref_values),
				'ClientApplication/' || (SELECT client_id FROM ref_values),
				false,
				'ClientApplication/' || (SELECT client_id FROM ref_values));
	END IF;
END
$do$