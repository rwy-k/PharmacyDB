USE Pharmacy;
INSERT INTO recipes VALUES (9, 'Joe Lotrulio', 'JL', 'true', 'Azize Aslanbey', 72, 'osteoporos', 'Fastum', 1, 'external', '20.04.20','03.04.20');
CALL upd_orderbook();
SELECT * FROM recipes;
SELECT * FROM guideofpreparation;
SELECT * FROM ledger;
SELECT * FROM requestformedicine;
SELECT * FROM storagecomponent;
SELECT * FROM storagemedicine;
SELECT * FROM orderbook;
SELECT * FROM componentinmedicine;

DELETE FROM orderbook WHERE idOrder = 9;
DELETE FROM recipes WHERE idRecipe = 9;
DELETE FROM requestformedicine WHERE idRequest = 8;
CALL upd_orderbook();
CALL clean_up();
CALL check_storage();