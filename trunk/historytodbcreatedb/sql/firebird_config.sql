SET TERM !!! ;
EXECUTE BLOCK AS
BEGIN
if (not exists(select 1 from rdb$relations where rdb$relation_name = 'CONFIG')) then
execute statement 'CREATE TABLE config (config_name varchar(255) not null,config_value varchar(255) not null);';
END
!!!
SET TERM ; !!!