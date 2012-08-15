CREATE OR REPLACE FUNCTION create_config_tbl (integer) RETURNS boolean AS '
BEGIN
	if not exists(select * from information_schema.tables where table_name = ''config'') then
		CREATE TABLE config (
			config_name varchar(255) NOT NULL,
			config_value varchar(255) NOT NULL,
			CONSTRAINT imhistory_config_pkey PRIMARY KEY (config_name)
		);			
		RETURN True;
	else
		RETURN False;
	end if;
END;
' LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION delete_config_tbl (integer) RETURNS boolean AS '
BEGIN
	if exists(select * from information_schema.tables where table_name = ''config'') then
		DROP TABLE config;
		RETURN True;
	else
		RETURN False;
	end if;
END;
' LANGUAGE 'plpgsql';