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

