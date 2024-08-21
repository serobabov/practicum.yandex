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
