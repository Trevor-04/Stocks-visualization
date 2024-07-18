USE stocks_database;

SELECT * FROM prices;

SELECT * FROM companies;

describe prices;

select date from prices;

SET sql_safe_updates = 0;

SELECT date FROM prices;

UPDATE prices
SET date = DATE_FORMAT(STR_TO_DATE(date, '%Y-%m-%d'), '%m/%d/%Y');

alter table prices
modify column date date;





