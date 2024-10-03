/* Проект выполнен в интерактивном тренажёре на платформе Яндекс.Практикум и состоит из двух частей. 
В рамках проекта решено 20 задач по составлению SQL-запросов к базе данных StackOverflow за 2008 год с использованием PostgreSQL. */

/* ЧАСТЬ №1 */
/* 1) Найдите количество вопросов, которые набрали больше 300 очков или как минимум 100 раз были добавлены в «Закладки». */
SELECT COUNT(*) AS question_count
FROM stackoverflow.posts
WHERE post_type_id = 1  -- Пост типа вопрос
  AND (score > 300 OR favorites_count >= 100);

/* 2) Сколько в среднем в день задавали вопросов с 1 по 18 ноября 2008 включительно? Результат округлите до целого числа. */
SELECT ROUND(AVG(questions_per_day)) AS avg_questions_per_day
FROM (
    SELECT COUNT(*) AS questions_per_day
    FROM stackoverflow.posts
    WHERE post_type_id = 1  -- Пост типа вопрос
      AND DATE_TRUNC('day', creation_date) BETWEEN '2008-11-01' AND '2008-11-18'
    GROUP BY DATE_TRUNC('day', creation_date)
) AS daily_questions;

/* 3) Сколько пользователей получили значки сразу в день регистрации? Выведите количество уникальных пользователей. */
SELECT COUNT(DISTINCT u.id) AS unique_user_count
FROM stackoverflow.users u
JOIN stackoverflow.badges b ON u.id = b.user_id
WHERE DATE_TRUNC('day', u.creation_date) = DATE_TRUNC('day', b.creation_date);

/* 4) Сколько уникальных постов пользователя с именем Joel Coehoorn получили хотя бы один голос? */
SELECT COUNT(DISTINCT p.id) AS unique_posts_with_votes
FROM stackoverflow.users u
JOIN stackoverflow.posts p ON u.id = p.user_id
JOIN stackoverflow.votes v ON p.id = v.post_id
WHERE u.display_name = 'Joel Coehoorn';

/* 5) Выгрузите все поля таблицы `vote_types`. Добавьте к таблице поле `rank`, в которое войдут номера записей в обратном порядке. Таблица должна быть отсортирована по полю `id`. */
SELECT *,
       RANK() OVER (ORDER BY id DESC) AS rank
FROM stackoverflow.vote_types
ORDER BY id;

/* 6) Отберите 10 пользователей, которые поставили больше всего голосов типа `Close`. Отобразите таблицу из двух полей: идентификатором пользователя и количеством голосов. 
Отсортируйте данные сначала по убыванию количества голосов, потом по убыванию значения идентификатора пользователя. */
SELECT v.user_id, COUNT(v.id) AS vote_count
FROM stackoverflow.votes v
JOIN stackoverflow.vote_types vt ON v.vote_type_id = vt.id
JOIN stackoverflow.users u ON v.user_id = u.id
WHERE vt.name = 'Close'
GROUP BY v.user_id
ORDER BY vote_count DESC, v.user_id DESC
LIMIT 10;

/* 7) Отберите 10 пользователей по количеству значков, полученных в период с 15 ноября по 15 декабря 2008 года включительно.
Отобразите несколько полей:
- идентификатор пользователя;
- число значков;
- место в рейтинге — чем больше значков, тем выше рейтинг.
Пользователям, которые набрали одинаковое количество значков, присвойте одно и то же место в рейтинге.
Отсортируйте записи по количеству значков по убыванию, а затем по возрастанию значения идентификатора пользователя. */
SELECT b.user_id, 
       COUNT(b.id), 
       DENSE_RANK() OVER (ORDER BY COUNT(b.id) DESC) 
FROM stackoverflow.badges b 
WHERE CAST(creation_date AS date) BETWEEN '2008-11-15' AND '2008-12-15' 
GROUP BY b.user_id 
ORDER BY COUNT(b.id) DESC, b.user_id 
LIMIT 10;

/* 8) Сколько в среднем очков получает пост каждого пользователя?
Сформируйте таблицу из следующих полей:
- заголовок поста;
- идентификатор пользователя;
- число очков поста;
- среднее число очков пользователя за пост, округлённое до целого числа.
Не учитывайте посты без заголовка, а также те, что набрали ноль очков. */
SELECT p.title, 
       p.user_id, 
       p.score,
       ROUND(AVG(p.score) OVER (PARTITION BY p.user_id))
FROM stackoverflow.posts p
WHERE p.score <> 0 
  AND p.title IS NOT NULL;

/* 9) Отобразите заголовки постов, которые были написаны пользователями, получившими более 1000 значков. Посты без заголовков не должны попасть в список. */
SELECT p.title
FROM stackoverflow.posts p
WHERE p.user_id IN
  (SELECT user_id 
   FROM stackoverflow.badges 
   GROUP BY user_id 
   HAVING COUNT(id) > 1000)
AND p.title IS NOT NULL;

/* 10) Напишите запрос, который выгрузит данные о пользователях из Канады (англ. Canada).
Разделите пользователей на три группы в зависимости от количества просмотров их профилей:
- пользователям с числом просмотров больше либо равным 350 присвойте группу `1`;
- пользователям с числом просмотров меньше 350, но больше либо равно 100 — группу `2`;
- пользователям с числом просмотров меньше 100 — группу `3`.
Отобразите в итоговой таблице идентификатор пользователя, количество просмотров профиля и группу. Пользователи с количеством просмотров меньше либо равным нулю не должны войти в итоговую таблицу. */
SELECT id, views,
CASE
    WHEN views < 100 THEN 3
    WHEN views < 350 THEN 2
    WHEN views >= 350 THEN 1
END
FROM stackoverflow.users
WHERE location LIKE '%Canada%' 
  AND views > 0;

/* 11) Дополните предыдущий запрос. Отобразите лидеров каждой группы — пользователей, которые набрали максимальное число просмотров в своей группе. 
Выведите поля с идентификатором пользователя, группой и количеством просмотров. Отсортируйте таблицу по убыванию просмотров, а затем по возрастанию значения идентификатора. */
ITH user_groups AS (
    SELECT id, views,
           CASE
               WHEN views < 100 THEN 3
               WHEN views < 350 THEN 2
               WHEN views >= 350 THEN 1
           END AS user_group
    FROM stackoverflow.users
    WHERE location LIKE '%Canada%' 
      AND views > 0
)
SELECT ug.id, 
       ug.user_group, 
       ug.views
FROM user_groups ug
JOIN (
    SELECT user_group, 
           MAX(views) AS max_views
    FROM user_groups
    GROUP BY user_group
) AS max_group_views
ON ug.user_group = max_group_views.user_group 
AND ug.views = max_group_views.max_views
ORDER BY ug.views DESC, ug.id ASC;

/* 12) Посчитайте ежедневный прирост новых пользователей в ноябре 2008 года. 
Сформируйте таблицу с полями:
- номер дня;
- число пользователей, зарегистрированных в этот день;
- сумму пользователей с накоплением. */
SELECT 
    EXTRACT(DAY FROM u.creation_date) AS day_number,
    COUNT(u.id) AS new_users,
    SUM(COUNT(u.id)) OVER (ORDER BY EXTRACT(DAY FROM u.creation_date)) AS cumulative_users
FROM stackoverflow.users u
WHERE EXTRACT(MONTH FROM u.creation_date) = 11
  AND EXTRACT(YEAR FROM u.creation_date) = 2008
GROUP BY EXTRACT(DAY FROM u.creation_date)
ORDER BY day_number;

/* 13) Для каждого пользователя, который написал хотя бы один пост, найдите интервал между регистрацией и временем создания первого поста.
Отобразите:
- идентификатор пользователя;
- разницу во времени между регистрацией и первым постом. */
WITH first_post AS (
    SELECT 
        p.user_id,
        p.creation_date AS post_creation_date,
        ROW_NUMBER() OVER (PARTITION BY p.user_id ORDER BY p.creation_date) AS rank
    FROM stackoverflow.posts p
)
SELECT 
    u.id AS user_id,
    (fp.post_creation_date - u.creation_date) AS time_difference
FROM stackoverflow.users u
JOIN first_post fp ON u.id = fp.user_id
WHERE fp.rank = 1;


/* ЧАСТЬ №2 */
/* 1) Выведите общую сумму просмотров у постов, опубликованных в каждый месяц 2008 года. Если данных за какой-либо месяц в базе нет, такой месяц можно пропустить. 
Результат отсортируйте по убыванию общего количества просмотров. */
SELECT CAST(DATE_TRUNC('month', creation_date) AS date) AS month, 
       SUM(views_count) AS sum
FROM stackoverflow.posts
WHERE creation_date::date BETWEEN '2008-01-01' AND '2008-12-31'
GROUP BY CAST(DATE_TRUNC('month', creation_date) AS date)
ORDER BY sum DESC;

/* 2) Выведите имена самых активных пользователей, которые в первый месяц после регистрации (включая день регистрации) дали больше 100 ответов. Вопросы, которые задавали пользователи, не учитывайте. 
Для каждого имени пользователя выведите количество уникальных значений `user_id`. Отсортируйте результат по полю с именами в лексикографическом порядке. */
SELECT display_name,
       COUNT(DISTINCT(user_id))
FROM stackoverflow.users AS u
JOIN stackoverflow.posts AS p ON u.id = p.user_id
JOIN stackoverflow.post_types AS t ON p.post_type_id = t.id
WHERE (DATE_TRUNC('day', p.creation_date) <= DATE_TRUNC('day', u.creation_date) + INTERVAL '1 month') 
  AND (p.post_type_id = 2)
GROUP BY display_name
HAVING COUNT(p.id) > 100;

/* 3) Выведите количество постов за 2008 год по месяцам. Отберите посты от пользователей, которые зарегистрировались в сентябре 2008 года и сделали хотя бы один пост в декабре того же года. 
Отсортируйте таблицу по значению месяца по убыванию. */
WITH active_users AS (
    SELECT u.id
    FROM stackoverflow.users AS u
    JOIN stackoverflow.posts AS p ON u.id = p.user_id
    WHERE u.creation_date::date BETWEEN '2008-09-01' AND '2008-09-30'
      AND p.creation_date::date BETWEEN '2008-12-01' AND '2008-12-31'
    GROUP BY u.id
)
SELECT 
    CAST(DATE_TRUNC('month', p.creation_date) AS date) AS month, 
    COUNT(p.id) AS cnt
FROM stackoverflow.posts p
JOIN active_users au ON p.user_id = au.id
WHERE p.creation_date::date BETWEEN '2008-01-01' AND '2008-12-31'
GROUP BY CAST(DATE_TRUNC('month', p.creation_date) AS date)
ORDER BY month DESC;

/* 4) Используя данные о постах, выведите несколько полей:
- идентификатор пользователя, который написал пост;
- дата создания поста;
- количество просмотров у текущего поста;
- сумма просмотров постов автора с накоплением.
Данные в таблице должны быть отсортированы по возрастанию идентификаторов пользователей, а данные об одном и том же пользователе — по возрастанию даты создания поста. */
SELECT 
    p.user_id, 
    p.creation_date, 
    p.views_count, 
    SUM(p.views_count) OVER (PARTITION BY p.user_id ORDER BY p.creation_date) AS cumulative_views
FROM stackoverflow.posts p
ORDER BY p.user_id ASC, p.creation_date ASC;

/* 5) Сколько в среднем дней в период с 1 по 7 декабря 2008 года включительно пользователи взаимодействовали с платформой? 
Для каждого пользователя отберите дни, в которые он или она опубликовали хотя бы один пост. Нужно получить одно целое число — не забудьте округлить результат. */
WITH active_days AS (
    SELECT 
        p.user_id, 
        COUNT(DISTINCT DATE_TRUNC('day', p.creation_date)) AS active_days
    FROM stackoverflow.posts p
    WHERE p.creation_date::date BETWEEN '2008-12-01' AND '2008-12-07'
    GROUP BY p.user_id
)
SELECT ROUND(AVG(active_days)) AS avg_active_days
FROM active_days;

/* 6) На сколько процентов менялось количество постов ежемесячно с 1 сентября по 31 декабря 2008 года? 
Отобразите таблицу со следующими полями:
- Номер месяца.
- Количество постов за месяц.
- Процент, который показывает, насколько изменилось количество постов в текущем месяце по сравнению с предыдущим.
Если постов стало меньше, значение процента должно быть отрицательным, если больше — положительным. Округлите значение процента до двух знаков после запятой.
Напомним, что при делении одного целого числа на другое в PostgreSQL в результате получится целое число, округлённое до ближайшего целого вниз. 
Чтобы этого избежать, переведите делимое в тип `numeric`. */
WITH monthly_posts AS (
    SELECT 
        EXTRACT(MONTH FROM p.creation_date) AS month_number,
        COUNT(p.id) AS post_count
    FROM stackoverflow.posts p
    WHERE p.creation_date::date BETWEEN '2008-09-01' AND '2008-12-31'
    GROUP BY EXTRACT(MONTH FROM p.creation_date)
    ORDER BY month_number
)
SELECT 
    month_number,
    post_count,
    ROUND(
        (post_count::numeric - LAG(post_count::numeric) OVER (ORDER BY month_number)) 
        / LAG(post_count::numeric) OVER (ORDER BY month_number) * 100, 2
    ) AS percent_change
FROM monthly_posts;

/* 7) Найдите пользователя, который опубликовал больше всего постов за всё время с момента регистрации.
Выведите данные его активности за октябрь 2008 года в таком виде:
- номер недели;
- дата и время последнего поста, опубликованного на этой неделе. */
WITH most_active_user AS (
    -- Находим пользователя с наибольшим количеством постов
    SELECT p.user_id
    FROM stackoverflow.posts p
    GROUP BY p.user_id
    ORDER BY COUNT(p.id) DESC
    LIMIT 1
),
weekly_posts AS (
    -- Находим дату и время создания каждого поста этого пользователя и номер недели
    SELECT 
        p.user_id, 
        EXTRACT(WEEK FROM p.creation_date) AS week_number, 
        p.creation_date
    FROM stackoverflow.posts p
    JOIN most_active_user u ON p.user_id = u.user_id
    WHERE p.creation_date::date BETWEEN '2008-10-01' AND '2008-10-31'
)
SELECT 
    week_number,
    MAX(creation_date) AS last_post_time
FROM weekly_posts
GROUP BY week_number
ORDER BY week_number;
