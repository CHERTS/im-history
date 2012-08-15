CREATE TABLE config (
   config_name varchar(255) NOT NULL,
   config_value varchar(255) NOT NULL,
   CONSTRAINT imhistory_config_pkey PRIMARY KEY (config_name)
);