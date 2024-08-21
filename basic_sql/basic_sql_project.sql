/* Задача 1/23: Отобразите все записи из таблицы `company` по компаниям, которые закрылись. */
SELECT *
FROM company
WHERE status = 'closed';

/* Задача 2/23: Отобразите количество привлечённых средств для новостных компаний США. Используйте данные из таблицы `company`. Отсортируйте таблицу по убыванию значений в поле `funding_total`. */
SELECT funding_total
FROM company
WHERE category_code = 'news'
  AND country_code = 'USA'
ORDER BY funding_total DESC;

/* Задача 3/23 Найдите общую сумму сделок по покупке одних компаний другими в долларах. Отберите сделки, которые осуществлялись только за наличные с 2011 по 2013 год включительно. */
SELECT SUM(price_amount)
FROM acquisition
WHERE term_code = 'cash'
  AND acquired_at BETWEEN '2011-01-01' AND '2013-12-31';

/* Задача 4/23 Отобразите имя, фамилию и названия аккаунтов людей в поле `network_username`, у которых названия аккаунтов начинаются на `'Silver'`. */
SELECT first_name,
       last_name,
       network_username
FROM people
WHERE network_username LIKE 'Silver%';

/* Задача 5/23 Выведите на экран всю информацию о людях, у которых названия аккаунтов в поле `network_username` содержат подстроку `'money'`, а фамилия начинается на `'K'`. */
SELECT *
FROM people
WHERE network_username LIKE '%money%'
  AND last_name LIKE 'K%';

/* Задача 6/23 Для каждой страны отобразите общую сумму привлечённых инвестиций, которые получили компании, зарегистрированные в этой стране. Страну, в которой зарегистрирована компания, можно определить по коду страны. Отсортируйте данные по убыванию суммы. */
SELECT country_code,
       SUM(funding_total) AS total_funding
FROM company
GROUP BY country_code
ORDER BY total_funding DESC;

/* Задача 7/23 Составьте таблицу, в которую войдёт дата проведения раунда, а также минимальное и максимальное значения суммы инвестиций, привлечённых в эту дату. Оставьте в итоговой таблице только те записи, в которых минимальное значение суммы инвестиций не равно нулю и не равно максимальному значению. */
SELECT funded_at,
       MIN(raised_amount) AS min_raised_amount,
       MAX(raised_amount) AS max_raised_amount
FROM funding_round
GROUP BY funded_at
HAVING MIN(raised_amount) != 0
AND MIN(raised_amount) != MAX(raised_amount);

/* Задача 8/23
Создайте поле с категориями:
- Для фондов, которые инвестируют в 100 и более компаний, назначьте категорию `high_activity`.
- Для фондов, которые инвестируют в 20 и более компаний до 100, назначьте категорию `middle_activity`.
- Если количество инвестируемых компаний фонда не достигает 20, назначьте категорию `low_activity`.
Отобразите все поля таблицы `fund` и новое поле с категориями. */
SELECT *,
       CASE
           WHEN invested_companies >= 100 THEN 'high_activity'
           WHEN invested_companies >= 20 THEN 'middle_activity'
           ELSE 'low_activity'
       END AS activity_category
FROM fund;

/* Задача 9/23**
Для каждой из категорий, назначенных в предыдущем задании, посчитайте округлённое до ближайшего целого числа среднее количество инвестиционных раундов, в которых фонд принимал участие. Выведите на экран категории и среднее число инвестиционных раундов. Отсортируйте таблицу по возрастанию среднего. */
SELECT activity_category,
       ROUND(AVG(investment_rounds)) AS avg_investment_rounds
FROM
  (SELECT *,
          CASE
              WHEN invested_companies >= 100 THEN 'high_activity'
              WHEN invested_companies >= 20 THEN 'middle_activity'
              ELSE 'low_activity'
          END AS activity_category
   FROM fund) AS categorized_funds
GROUP BY activity_category
ORDER BY avg_investment_rounds ASC;

/* Задача 10/23 Проанализируйте, в каких странах находятся фонды, которые чаще всего инвестируют в стартапы.
Для каждой страны посчитайте минимальное, максимальное и среднее число компаний, в которые инвестировали фонды этой страны, основанные с 2010 по 2012 год включительно. Исключите страны с фондами, у которых минимальное число компаний, получивших инвестиции, равно нулю.
Выгрузите десять самых активных стран-инвесторов: отсортируйте таблицу по среднему количеству компаний от большего к меньшему. Затем добавьте сортировку по коду страны в лексикографическом порядке. */
SELECT country_code,
       MIN(invested_companies) AS min_invested_companies,
       MAX(invested_companies) AS max_invested_companies,
       AVG(invested_companies) AS avg_invested_companies
FROM fund
WHERE founded_at BETWEEN '2010-01-01' AND '2012-12-31'
GROUP BY country_code
HAVING MIN(invested_companies) > 0
ORDER BY avg_invested_companies DESC,
         country_code ASC
LIMIT 10;

/* Задача 11/23 Отобразите имя и фамилию всех сотрудников стартапов. Добавьте поле с названием учебного заведения, которое окончил сотрудник, если эта информация известна. */
SELECT p.first_name,
       p.last_name,
       e.instituition
FROM people p
LEFT JOIN education e ON p.id = e.person_id;

/* Задача 12/23 Для каждой компании найдите количество учебных заведений, которые окончили её сотрудники. Выведите название компании и число уникальных названий учебных заведений. Составьте топ-5 компаний по количеству университетов. */
SELECT c.name AS company_name,
       COUNT(DISTINCT e.instituition) AS unique_institutions_count
FROM people p
JOIN education e ON p.id = e.person_id
JOIN company c ON p.company_id = c.id
GROUP BY c.name
ORDER BY unique_institutions_count DESC
LIMIT 5;

/* Задача 13/23 Составьте список с уникальными названиями закрытых компаний, для которых первый раунд финансирования оказался последним. */
SELECT DISTINCT c.name AS company_name
FROM company c
JOIN funding_round fr ON c.id = fr.company_id
WHERE c.status = 'closed'
  AND fr.is_first_round = 1
  AND fr.is_last_round = 1;

/* Задача 14/23 Составьте список уникальных номеров сотрудников, которые работают в компаниях, отобранных в предыдущем задании. */
SELECT DISTINCT p.id AS employee_id
FROM people p
JOIN company c ON p.company_id = c.id
WHERE c.id IN
    (SELECT DISTINCT c.id
     FROM company c
     JOIN funding_round fr ON c.id = fr.company_id
     WHERE c.status = 'closed'
       AND fr.is_first_round = 1
       AND fr.is_last_round = 1 );

/* Задача 15/23 Составьте таблицу, куда войдут уникальные пары с номерами сотрудников из предыдущей задачи и учебным заведением, которое окончил сотрудник. */
SELECT DISTINCT p.id AS employee_id,
                e.instituition AS education_institution
FROM people p
JOIN company c ON p.company_id = c.id
JOIN education e ON p.id = e.person_id
WHERE c.id IN
    (SELECT DISTINCT c.id
     FROM company c
     JOIN funding_round fr ON c.id = fr.company_id
     WHERE c.status = 'closed'
       AND fr.is_first_round = 1
       AND fr.is_last_round = 1 );

/* Задача 16/23 Посчитайте количество учебных заведений для каждого сотрудника из предыдущего задания. При подсчёте учитывайте, что некоторые сотрудники могли окончить одно и то же заведение дважды. */
SELECT p.id AS employee_id,
       COUNT(e.instituition) AS institutions_count
FROM people p
JOIN company c ON p.company_id = c.id
JOIN education e ON p.id = e.person_id
WHERE c.id IN
    (SELECT DISTINCT c.id
     FROM company c
     JOIN funding_round fr ON c.id = fr.company_id
     WHERE c.status = 'closed'
       AND fr.is_first_round = 1
       AND fr.is_last_round = 1 )
GROUP BY p.id;

/* Задача 17/23 Дополните предыдущий запрос и выведите среднее число учебных заведений (всех, не только уникальных), которые окончили сотрудники разных компаний. Нужно вывести только одну запись, группировка здесь не понадобится. */
SELECT AVG(institutions_count) AS avg_institutions_per_employee
FROM
  (SELECT p.id AS employee_id,
          COUNT(e.instituition) AS institutions_count
   FROM people p
   JOIN company c ON p.company_id = c.id
   JOIN education e ON p.id = e.person_id
   WHERE c.id IN
       (SELECT DISTINCT c.id
        FROM company c
        JOIN funding_round fr ON c.id = fr.company_id
        WHERE c.status = 'closed'
          AND fr.is_first_round = 1
          AND fr.is_last_round = 1 )
   GROUP BY p.id) AS subquery;

/* Задача 18/23  Напишите похожий запрос: выведите среднее число учебных заведений (всех, не только уникальных), которые окончили сотрудники Socialnet. */
SELECT AVG(institutions_count) AS avg_institutions_per_employee
FROM
  (SELECT p.id AS employee_id,
          COUNT(e.instituition) AS institutions_count
   FROM people p
   JOIN company c ON p.company_id = c.id
   JOIN education e ON p.id = e.person_id
   WHERE c.name = 'Socialnet'
   GROUP BY p.id) AS subquery;

/* Задача 19/23 Составьте таблицу из полей:
- `name_of_fund` — название фонда;
- `name_of_company` — название компании;
- `amount` — сумма инвестиций, которую привлекла компания в раунде.
В таблицу войдут данные о компаниях, в истории которых было больше шести важных этапов, а раунды финансирования проходили с 2012 по 2013 год включительно. */
SELECT f.name AS name_of_fund,
       c.name AS name_of_company,
       fr.raised_amount AS amount
FROM investment i
JOIN company c ON i.company_id = c.id
JOIN fund f ON i.fund_id = f.id
JOIN funding_round fr ON i.funding_round_id = fr.id
WHERE c.milestones > 6
  AND fr.funded_at BETWEEN '2012-01-01' AND '2013-12-31';

/* Задача 20/23 Выгрузите таблицу, в которой будут такие поля:
- название компании-покупателя;
- сумма сделки;
- название компании, которую купили;
- сумма инвестиций, вложенных в купленную компанию;
- доля, которая отображает, во сколько раз сумма покупки превысила сумму вложенных в компанию инвестиций, округлённая до ближайшего целого числа.
Не учитывайте те сделки, в которых сумма покупки равна нулю. Если сумма инвестиций в компанию равна нулю, исключите такую компанию из таблицы.
Отсортируйте таблицу по сумме сделки от большей к меньшей, а затем по названию купленной компании в лексикографическом порядке. Ограничьте таблицу первыми десятью записями. */
SELECT acquiring_company.name AS acquiring_company_name,
       a.price_amount AS deal_amount,
       acquired_company.name AS acquired_company_name,
       acquired_company.funding_total AS total_investment,
       ROUND(a.price_amount / acquired_company.funding_total) AS investment_ratio
FROM acquisition a
JOIN company acquiring_company ON a.acquiring_company_id = acquiring_company.id
JOIN company acquired_company ON a.acquired_company_id = acquired_company.id
WHERE a.price_amount > 0
  AND acquired_company.funding_total > 0
ORDER BY a.price_amount DESC,
         acquired_company.name ASC
LIMIT 10;

/* Задача 21/23 Выгрузите таблицу, в которую войдут названия компаний из категории `social`, получившие финансирование с 2010 по 2013 год включительно. Проверьте, что сумма инвестиций не равна нулю. Выведите также номер месяца, в котором проходил раунд финансирования. */
SELECT c.name AS company_name,
       EXTRACT(MONTH
               FROM fr.funded_at) AS funding_month
FROM company c
JOIN funding_round fr ON c.id = fr.company_id
WHERE c.category_code = 'social'
  AND fr.funded_at BETWEEN '2010-01-01' AND '2013-12-31'
  AND fr.raised_amount <> 0;

/* Задача 22/23 Отберите данные по месяцам с 2010 по 2013 год, когда проходили инвестиционные раунды. Сгруппируйте данные по номеру месяца и получите таблицу, в которой будут поля:
- номер месяца, в котором проходили раунды;
- количество уникальных названий фондов из США, которые инвестировали в этом месяце;
- количество компаний, купленных за этот месяц;
- общая сумма сделок по покупкам в этом месяце. */
WITH InvestmentData AS
  (SELECT EXTRACT(MONTH
                  FROM fr.funded_at) AS MONTH,
          f.id AS fund_id
   FROM funding_round fr
   JOIN investment i ON fr.id = i.funding_round_id
   JOIN fund f ON i.fund_id = f.id
   WHERE fr.funded_at BETWEEN '2010-01-01' AND '2013-12-31'
     AND f.country_code = 'USA' ),
     UniqueFunds AS
  (SELECT MONTH,
          COUNT(DISTINCT fund_id) AS unique_us_funds
   FROM InvestmentData
   GROUP BY MONTH),
     AcquisitionData AS
  (SELECT EXTRACT(MONTH
                  FROM acquired_at) AS MONTH,
          COUNT(acquired_company_id) AS acquired_companies,
          SUM(price_amount) AS total_deal_amount
   FROM acquisition
   WHERE acquired_at BETWEEN '2010-01-01' AND '2013-12-31'
   GROUP BY MONTH)
SELECT uf.month,
       uf.unique_us_funds,
       COALESCE(ad.acquired_companies, 0) AS acquired_companies,
       COALESCE(ad.total_deal_amount, 0) AS total_deal_amount
FROM UniqueFunds uf
LEFT JOIN AcquisitionData ad ON uf.month = ad.month
ORDER BY uf.month;

/* Задача 23/23 Составьте сводную таблицу и выведите среднюю сумму инвестиций для стран, в которых есть стартапы, зарегистрированные в 2011, 2012 и 2013 годах. Данные за каждый год должны быть в отдельном поле. Отсортируйте таблицу по среднему значению инвестиций за 2011 год от большего к меньшему. */
WITH inv_2011 AS
  (SELECT co.country_code,
          AVG(co.funding_total)
   FROM company AS co
   WHERE EXTRACT(YEAR
                 FROM co.founded_at) = 2011
   GROUP BY co.country_code
   HAVING COUNT(co.id) > 0),
     inv_2012 AS
  (SELECT co.country_code,
          AVG(co.funding_total)
   FROM company AS co
   WHERE EXTRACT(YEAR
                 FROM co.founded_at) = 2012
   GROUP BY co.country_code
   HAVING COUNT(co.id) > 0),
     inv_2013 AS
  (SELECT co.country_code,
          AVG(co.funding_total)
   FROM company AS co
   WHERE EXTRACT(YEAR
                 FROM co.founded_at) = 2013
   GROUP BY co.country_code
   HAVING COUNT(co.id) > 0)
SELECT inv_2011.country_code,
       inv_2011.avg AS inv_2011,
       inv_2012.avg AS inv_2012,
       inv_2013.avg AS inv_2013
FROM inv_2011
INNER JOIN inv_2012 ON inv_2012.country_code = inv_2011.country_code
INNER JOIN inv_2013 ON inv_2013.country_code = inv_2011.country_code
ORDER BY inv_2011.avg DESC;
