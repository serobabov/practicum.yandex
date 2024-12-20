# Описание проекта
Анализ рынка заведений общественного питания в Москве. Основная задача исследования — предоставление детального анализа и визуализации данных, которые помогут инвесторам сделать обоснованный выбор при открытии нового заведения общественного питания в столице. Исследование охватывает несколько ключевых аспектов, включая категории заведений, их географическое распределение, среднюю стоимость услуг и количество посадочных мест.

### Описание данных:
- name — название заведения.
- address — адрес заведения.
- category — категория заведения (например, «кафе», «пиццерия», «кофейня» и т.д.).
- hours — информация о днях и часах работы.
- lat — широта географической точки.
- lng — долгота географической точки.
- rating — рейтинг заведения по оценкам пользователей (максимум — 5.0).
- price — ценовая категория заведения (например, «средние», «выше среднего»).
- avg_bill — строка с диапазоном средней стоимости заказа.
- middle_avg_bill — среднее значение среднего чека, извлеченное из avg_bill.
- middle_coffee_cup — средняя стоимость чашки капучино, извлеченная из avg_bill.
- chain — булевый флаг (0 — не сетевое заведение, 1 — сетевое заведение).
- district — административный район Москвы.
- seats — количество посадочных мест.

### Используемые инструменты
- `Python`
- `Pandas`
- `Matplotlib`
- `Seaborn`
- `Folium`

### Задача
Провести исследовательский анализ данных для выявления ключевых характеристик рынка общественного питания в Москве. Основное внимание уделяется распределению заведений по категориям, географическому положению, ценовым сегментам, а также количеству посадочных мест и режиму работы.

## Шаги исследования
- **Загрузка и предварительная обработка данных:** Данные загружены и предварительно обработаны. Было проведено исправление пропусков и аномалий, а также типизация данных.
- **Создание новых столбцов:** Были извлечены названия улиц из адресов, а также добавлены признаки круглосуточного режима работы (24/7) для анализа заведения по времени работы.
- **Анализ данных:**
  - Категории заведений: Анализ распределения заведений по категориям (например, кафе, рестораны).
  - Посадочные места: Исследование среднего количества посадочных мест в зависимости от категории заведения.
  - Стоимость услуг: Изучение средней стоимости чашки кофе и среднего чека в различных категориях заведений.
  - Географическое распределение: Анализ распределения заведений по районам Москвы.
**Визуализация результатов:** Построены графики и диаграммы, иллюстрирующие выявленные закономерности и распределения.

### Общие выводы:
В результате анализа был создан детализированный портрет рынка общественного питания Москвы. Были выявлены ключевые категории заведений, их распределение по районам города, а также особенности ценовой политики и численности посадочных мест. Эти результаты могут служить основой для дальнейшего принятия решений инвесторами в данной сфере.

---
[Проект в Colab](https://colab.research.google.com/drive/1JgqJnyC9vvWtwRYisd9hZU-DO_7ND-t_?usp=sharing)
