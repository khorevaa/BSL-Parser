///////////////////////////////////////////////////////////////////////////////
//
// Модуль для чтения описаний метаданных 1с из XML выгрузки
//
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// ПРОГРАММНЫЙ ИНТЕРФЕЙС
///////////////////////////////////////////////////////////////////////////////

// Выполняет чтение описания объекта с учетом параметров
//
// Параметры:
//   ИмяФайла - Строка - Путь к файлу описания
//   ПараметрыЧтения - Структура - Описание трансформации данных описания в объект. См. ПараметрыСериализации.ПараметрыСериализации
//
//  Возвращаемое значение:
//   Структура - Данные описания
//
Функция ПрочитатьСвойстваИзФайла(ИмяФайла, ПараметрыЧтения) Экспорт

	ЧтениеXML = Новый ЧтениеXML;
	ЧтениеXML.ОткрытьФайл(ИмяФайла);
	
	СырыеДанные = ПрочитатьСвойстваXML(ЧтениеXML, ПараметрыЧтения);
	
	ЧтениеXML.Закрыть();
	
	СвойстваОписания = ОбработатьСырыеДанные(СырыеДанные, ПараметрыЧтения);
	
	Возврат СвойстваОписания;

КонецФункции

///////////////////////////////////////////////////////////////////////////////
// СЛУЖЕБНЫЙ ПРОГРАММНЫЙ ИНТЕРФЕЙС
///////////////////////////////////////////////////////////////////////////////

#Область МетодыЧтения

// Читает строку на разных языках
//
// Параметры:
//   ЧтениеXML - ЧтениеXML - Читатель данных
//
//  Возвращаемое значение:
//   Строка - Данные строки
//
Функция МногоязычнаяСтрока(Знач ЧтениеXML) Экспорт
	
	Язык = ЧтениеОписанийБазовый.ЗначениеВложенногоТэга(ЧтениеXML, "v8:lang");
	ЧтениеXML.Прочитать();
	Текст = ЧтениеОписанийБазовый.ЗначениеВложенногоТэга(ЧтениеXML, "v8:content");
	
	Если ЗначениеЗаполнено(Язык) и ЗначениеЗаполнено(Текст) Тогда
		МногоязычнаяСтрока = Новый Структура;
		МногоязычнаяСтрока.Вставить(Язык, Текст);

		Возврат МногоязычнаяСтрока;
	КонецЕсли;
	
	Возврат Текст;

КонецФункции

// Читает версию совместимости
//	Версия приводится к единному с EDT виду внутри инструмента
// Параметры:
//   ЧтениеXML - ЧтениеXML - Читатель данных
//
//  Возвращаемое значение:
//   Строка - Данные строки
//
Функция ВерсияСовместимости(Знач ЧтениеXML) Экспорт
		
	ЧтениеXML.Прочитать();
	
	Возврат ВерсияСовместимостиСтрокой(ЧтениеXML.Значение);
	
КонецФункции

// Удаляет лишние символы из строки версии
//	
// Параметры:
//   ЧтениеXML - ЧтениеXML - Читатель данных
//
//  Возвращаемое значение:
//   Строка - Данные строки, версия формата 8.3.10
//
Функция ВерсияСовместимостиСтрокой(Значение) 

	Версия = СтрРазделить(СтрЗаменить(Значение, "Version", ""), "_", Ложь);
	
	Возврат СтрШаблон("%1.%2.%3", Версия[0], Версия[1], Версия[2]);

	
КонецФункции

// Читает описание типа
//
// Параметры:
//   ЧтениеXML - ЧтениеXML - Читатель данных
//
//  Возвращаемое значение:
//   Строка - Значение типа
//
Функция ПолучитьТип(Знач ЧтениеXML) Экспорт
	
	Значение = ЧтениеОписанийБазовый.ЗначениеВложенногоТэга(ЧтениеXML, "v8:Type");

	Возврат ЧтениеОписанийБазовый.ПреобразоватьТип(Значение);

КонецФункции

// Читает логическое значение
//
// Параметры:
//   Значение - Строка - Данные содержащие булево
//
//  Возвращаемое значение:
//   Булево - Значение
//
Функция ЗначениеБулево(Знач ЧтениеXML) Экспорт
	
	ЧтениеXML.Прочитать();
	Возврат ЧтениеXML.ИмеетЗначение И СтрСравнить(ЧтениеXML.Значение, "true") = 0;
	
КонецФункции

// Читает состав подсистемы
//
// Параметры:
//   ЧтениеXML - ЧтениеXML - Читатель данных
//
//  Возвращаемое значение:
//   Массив - Состав подсистемы
//
Функция СоставПодсистемы(Знач ЧтениеXML) Экспорт
	
	Значение = Новый Массив();
	
	Пока ЧтениеXML.Прочитать() И НЕ (ЧтениеXML.Имя = "Content" И ЧтениеXML.ТипУзла = ТипУзлаXML.КонецЭлемента)  Цикл
		
		Если ЧтениеXML.ИмеетЗначение Тогда
			
			Строка = ЧтениеXML.Значение;
			
			Позиция = СтрНайти(Строка, ".");

			Если Позиция > 0 Тогда
				
				Значение.Добавить(ТипыОбъектовКонфигурации.НормализоватьИмя(Лев(Строка, Позиция - 1)) + Сред(Строка, Позиция));

			Иначе
				
				Значение.Добавить(ЧтениеXML.Значение);
				
			КонецЕсли
			
		КонецЕсли;

	КонецЦикла;
	
	Возврат Значение;
	
КонецФункции

// Читает описание подчиненных элементов
//
// Параметры:
//   ЧтениеXML - ЧтениеXML - Читатель данных
//
//  Возвращаемое значение:
//   Массив - Описание подчиненных элементов
//
Функция Подчиненные(Знач ЧтениеXML) Экспорт
	
	Значение = Новый Массив();
	
	Пока ЧтениеXML.Прочитать() И НЕ (ЧтениеXML.Имя = "ChildObjects" И ЧтениеXML.ТипУзла = ТипУзлаXML.КонецЭлемента)  Цикл
		
		Если ЧтениеXML.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
			
			Тип = ЧтениеXML.ЛокальноеИмя;
			ЧтениеXML.Прочитать();
 			Имя = ЧтениеXML.Значение;
			Значение.Добавить(СтрШаблон("%1.%2", Тип, Имя));
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Значение;
	
КонецФункции

#КонецОбласти

///////////////////////////////////////////////////////////////////////////////
// СЛУЖЕБНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ
///////////////////////////////////////////////////////////////////////////////

Функция ОбработатьСырыеДанные(СырыеДанные, ПараметрыЧтения)
	
	ДанныеОбъекта = ЧтениеОписанийБазовый.ОбработатьСырыеДанные(СырыеДанные, ПараметрыЧтения);
		
	Если ПараметрыЧтения.ЕстьПодчиненные Тогда
		
		Подчиненные = СырыеДанные.Найти("ChildObjects", "Ключ");
		
		Если ЗначениеЗаполнено(Подчиненные) Тогда
			
			ДанныеОбъекта.Вставить("Подчиненные", Подчиненные.Значение);
			
		КонецЕсли;

	КонецЕсли;

	Возврат ДанныеОбъекта;
	
КонецФункции

Функция ПрочитатьСвойстваXML(ЧтениеXML, ПараметрыЧтения)

	Данные = Новый Структура();
	
	Пока ЧтениеXML.Прочитать() Цикл
		
		Если ЧтениеXML.ТипУзла = ТипУзлаXML.НачалоЭлемента И ЧтениеXML.Имя = "Properties" Тогда
			
			Данные = ЧтениеОписанийБазовый.ПрочитатьСвойстваXML(ЧтениеXML, ПараметрыЧтения, ЭтотОбъект);
			
		ИначеЕсли ЧтениеXML.ТипУзла = ТипУзлаXML.НачалоЭлемента И ЧтениеXML.Имя = "ChildObjects" Тогда
			
			ЗаписьЗначение = Данные.Добавить();
			ЗаписьЗначение.Ключ = "ChildObjects";
			ЗаписьЗначение.Значение = Подчиненные(ЧтениеXML);

		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Данные;

КонецФункции
