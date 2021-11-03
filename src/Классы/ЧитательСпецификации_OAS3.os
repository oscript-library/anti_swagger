#Использовать logos
#Использовать json

Перем Лог Экспорт;

Перем Пути Экспорт;
Перем ПоддерживаемыеМетоды Экспорт;
Перем ВыходынеПараметры Экспорт;
Перем ВходныеПараметры Экспорт;
Перем ФайлСпецификации Экспорт;

Процедура ВыполнитьЧтениеСпецификации() Экспорт
	
	
	ЧтениеТекста = Новый ЧтениеТекста(ФайлСпецификации, "UTF-8");
	Данные = ЧтениеТекста.Прочитать();
	ЧтениеТекста.Закрыть();

	ПарсерJSON  = Новый ПарсерJSON();
	Прочитанное = ПарсерJSON.ПрочитатьJSON(Данные);

	Пути_Схемы = Прочитанное.Получить("paths");
	
	Если Пути_Схемы = Неопределено Тогда
		ТекстОшибки = СтрШаблон("Файл %1 не соответствует необходимой структуре OAS 3.0", ФайлСпецификации);
		Лог.Ошибка(ТекстОшибки);
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;

	Для каждого Эл Из Пути_Схемы Цикл
		
		СквознойИдентификатор = Строка(Новый УникальныйИдентификатор);
		
		НоваяСтрока = Пути.Добавить();
		НоваяСтрока.ИдентифкаторОтбора = СквознойИдентификатор;
		НоваяСтрока.Путь = Эл.Ключ;
		
		Путь_ИМЯ = СтрЗаменить(Эл.Ключ, "/", "_");
		Путь_ИМЯ = СтрЗаменить(Путь_ИМЯ, "{", "");
		Путь_ИМЯ = СтрЗаменить(Путь_ИМЯ, "}", "");

		НоваяСтрока.НаименованиеШаблона = Путь_ИМЯ;		
		
		РазобратьДополнительныеДанные(СквознойИдентификатор, Эл.Значение);		
		
	КонецЦикла;
	
	Пути.Сортировать("НаименованиеШаблона");

КонецПроцедуры

Процедура РазобратьДополнительныеДанные(СквознойИдентификатор, Данные)
	
	Если НЕ ТипЗнч(Данные) = Тип("Соответствие") Тогда 
		Возврат;
	КонецЕсли;
		
	Параметры_url = Данные.Получить("parameters");
	Параметры_get = Данные.Получить("get");
	Параметры_put = Данные.Получить("put");
	Параметры_post = Данные.Получить("post");
	Параметры_delete = Данные.Получить("delete");
	Параметры_patch = Данные.Получить("patch");
	Параметры_options = Данные.Получить("options");
	Параметры_trace = Данные.Получить("trace");
		
	РазобратьДанные_Параметры(СквознойИдентификатор, Параметры_url);
	
	РазобратьДанные_Методы(СквознойИдентификатор, Параметры_get, "get");
	РазобратьДанные_Методы(СквознойИдентификатор, Параметры_put, "put");
	РазобратьДанные_Методы(СквознойИдентификатор, Параметры_post, "post");
	РазобратьДанные_Методы(СквознойИдентификатор, Параметры_delete, "delete");
	РазобратьДанные_Методы(СквознойИдентификатор, Параметры_patch, "patch");
	РазобратьДанные_Методы(СквознойИдентификатор, Параметры_options, "options");
	РазобратьДанные_Методы(СквознойИдентификатор, Параметры_trace, "trace");	
	
	
КонецПроцедуры

Процедура РазобратьДанные_Параметры(СквознойИдентификатор, Данные)
	
	Если НЕ ТипЗнч(Данные) = Тип("Соответствие") 
		И НЕ ТипЗнч(Данные) = Тип("Массив") Тогда 
		Возврат;
	КонецЕсли;
	
	а=1;
	
	Если ТипЗнч(Данные) = Тип("Массив") Тогда 
		Для каждого Эл Из Данные Цикл
			РазобратьДанные_Параметры(СквознойИдентификатор, Эл);			       		
		КонецЦикла;
	КонецЕсли;
	
	Если ТипЗнч(Данные) = Тип("Соответствие") Тогда 
		
		ИмяПараметра = Данные.Получить("name");
		ПеремРасположение = Данные.Получить("in");
		ПеремОписание = Данные.Получить("description");
		
		НоваяСтрока = ВходныеПараметры.Добавить();
		НоваяСтрока.ИдентифкаторОтбора = СквознойИдентификатор;
		НоваяСтрока.Параметр = ИмяПараметра;
		НоваяСтрока.Описание = ПеремОписание;
		НоваяСтрока.ТипПараметра = ПеремРасположение;		
		
	КонецЕсли;
	
	
КонецПроцедуры

Процедура РазобратьДанные_Методы(СквознойИдентификатор, Данные, Метод)
	
	Если НЕ ТипЗнч(Данные) = Тип("Соответствие") 
		И НЕ ТипЗнч(Данные) = Тип("Массив") Тогда 
		Возврат;
	КонецЕсли;
	
	Если ТипЗнч(Данные) = Тип("Массив") Тогда 
		Для каждого Эл Из Данные Цикл
			РазобратьДанные_Методы(СквознойИдентификатор, Эл, Метод);			       		
		КонецЦикла;
	КонецЕсли;
	
	Если ТипЗнч(Данные) = Тип("Соответствие") Тогда 
		
		Параметры_query = Данные.Получить("parameters");
		Параметры_responces = Данные.Получить("responses");
		
		ИдентификаторМетода = Строка(Новый УникальныйИдентификатор);
		
		РазобратьДанные_Параметры(ИдентификаторМетода, Параметры_query); 
		РазобратьДанные_Ответы(ИдентификаторМетода, Параметры_responces);
		
		НоваяСтрока = ПоддерживаемыеМетоды.Добавить();
		НоваяСтрока.ИмяМетода = Метод;		
		НоваяСтрока.ИдентифкаторОтбора = СквознойИдентификатор;
		НоваяСтрока.Идентификатор = ИдентификаторМетода;
		
		НоваяСтрока.НаименованиеМетода = Данные.Получить("operationId");
		НоваяСтрока.СинонимМетода = Данные.Получить("summary");
		НоваяСтрока.КомментарийМетода = СтрЗаменить(Данные.Получить("description"), Символы.ПС, "");
				
	КонецЕсли;
	
	
КонецПроцедуры

Процедура РазобратьДанные_Ответы(СквознойИдентификатор, Данные)
	
	Если НЕ ТипЗнч(Данные) = Тип("Соответствие") 
		И НЕ ТипЗнч(Данные) = Тип("Массив") Тогда 
		Возврат;
	КонецЕсли;
	
	Если ТипЗнч(Данные) = Тип("Массив") Тогда 
		Для каждого Эл Из Данные Цикл
			РазобратьДанные_Ответы(СквознойИдентификатор, Эл);			       		
		КонецЦикла;
	КонецЕсли;
	
	Если ТипЗнч(Данные) = Тип("Соответствие") Тогда 
		
		Для Каждого Эл Из Данные Цикл
			НоваяСтрока = ВыходынеПараметры.Добавить();
			НоваяСтрока.КодВозврата = Эл.Ключ;
			НоваяСтрока.ИдентифкаторОтбора = СквознойИдентификатор;
		КонецЦикла;
		
	КонецЕсли;
		
КонецПроцедуры







