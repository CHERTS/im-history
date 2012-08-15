SET TERM !!! ;
EXECUTE BLOCK AS
BEGIN
if (exists(select 1 from rdb$relations where rdb$relation_name = 'CONFIG')) then
execute statement 'DROP TABLE config;';
END
!!!
SET TERM ; !!!
