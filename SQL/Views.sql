CREATE OR REPLACE VIEW allSales AS SELECT * FROM sales ORDER BY year, to_date(month, 'Month');

CREATE OR REPLACE VIEW allCurrMonthSales AS SELECT * FROM sales WHERE (year = date_part('year', CURRENT_DATE)) AND (to_date(month, 'Month') = to_date(to_char(current_date, 'MONTH'), 'Month')) ORDER BY year, month;

CREATE OR REPLACE VIEW allCurrYearSales AS SELECT * FROM sales WHERE year = date_part('year', CURRENT_DATE) ORDER BY year, month;