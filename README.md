# L4 балансировщик нагрузки на Nginx с тестированием
- Поднято три бэкенда с базой данных, [репозиторий бэкенда](https://github.com/SergTyapkin/DB-forums)
- Налажен сбор метрик с помощью Grafana+Prometeus
- Сконфигурирован L4 балансировщик нагрузки на Nginx
- Нагрузка осуществляется с помощью специальной программы `technopark-dbms-forum.exe` [её репозиторий](https://github.com/mailcourses/technopark-dbms-forum), а также [Apache Benchmark](https://httpd.apache.org/docs/current/programs/ab.html)

---
1. Даём нагрузку

![](даём%20нагрузку.png)
![](работает.png)


2. Даём больше нагрузки

![](даём%20больше%20нагрузки.png)


3. Отключаем один бэкенд

![](отрубили%201-ый%20бэк.png)
![](Виден%20момент%20перераспределения.png)


4. Подключаем бэкенд обратно
   
![](запускаем%20бэк%20обратно.png)
![](тестирование%20завершено%2C%20бэк%20включен.png)


### Итог: балансировщик работает

