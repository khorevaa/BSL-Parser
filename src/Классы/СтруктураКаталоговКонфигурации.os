///////////////////////////////////////////////////////////////////
//
// Класс-помощник, предоставляет информацию об иерархии каталогов
// выгрузки исходников 1с
//
// (с) BIA Technologies, LLC    
//
///////////////////////////////////////////////////////////////////

#Использовать fs

///////////////////////////////////////////////////////////////////

Перем КаталогИсходников;
Перем ФорматВыгрузки;
Перем СоздаватьКаталоги;
Перем РасширениеФайловОписания;
Перем РасширениеФайловМодулей;
Перем ЭтоФорматEDT;
Перем ИерархическийФормат;

///////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////
// Программный интерфейс
///////////////////////////////////////////////////////////////////

// Путь к корневому каталогу выгрузки
//
//  Возвращаемое значение:
//   Строка - Путь к корневому каталогу выгрузки
//
Функция КорневойКаталог() Экспорт
    
    Возврат КаталогИсходников;
    
КонецФункции

// Возвращает путь к каталогу файлов описания объекта
//
// Параметры:
//   ИмяОбъекта - Строка - Имя объекта
//   ВидОбъекта - Строка - Вид объекта метаданных, англ. в единственном числе
//
//  Возвращаемое значение:
//   Строка - Путь к каталогу
//
Функция КаталогФайловОбъекта(ИмяОбъекта, ВидОбъекта) Экспорт
	
	Если ТипыОбъектовКонфигурации.ЭтоТипКонфигурации(ВидОбъекта) Тогда
		
		Каталог = КаталогВидаОбъекта(ТипыОбъектовКонфигурации.ИмяТипаКонфигурации());
		
	ИначеЕсли ВидОбъекта = ТипыОбъектовКонфигурации.ИмяТипаПодсистемы() И СтрНайти(ИмяОбъекта, ".") Тогда
		
		Каталог = КаталогИсходников;
		Для Каждого Часть Из СтрРазделить(ИмяОбъекта, ".") Цикл
			
			Каталог = ОбъединитьПути(Каталог, ИмяКаталогВидаОбъекта(ВидОбъекта), Часть);
			
		КонецЦикла;
		
	Иначе
		
		Каталог = ОбъединитьПути(КаталогВидаОбъекта(ВидОбъекта), ИмяОбъекта);

	КонецЕсли;
	
    Если СоздаватьКаталоги Тогда
        
        СоздатьКаталог(Каталог);
        
    КонецЕсли;

    Возврат Каталог;
    
КонецФункции

// Возвращает путь к каталогу дополнительных файлов объекта (модули, справка и т.д.)
//
// Параметры:
//   ИмяОбъекта - Строка - Имя объекта
//   ВидОбъекта - Строка - Вид объекта метаданных, англ. в единственном числе
//
//  Возвращаемое значение:
//   Строка - Путь к каталогу
//
Функция КаталогДополнительныхФайловОбъекта(ИмяОбъекта, ВидОбъекта) Экспорт
		
	Если ЭтоФорматEDT Тогда
		
		Каталог = КаталогФайловОбъекта(ИмяОбъекта, ВидОбъекта);

	Иначе
		
		Каталог = ОбъединитьПути(КаталогФайловОбъекта(ИмяОбъекта, ВидОбъекта), "Ext");

	КонецЕсли;

    Если СоздаватьКаталоги Тогда
        
        СоздатьКаталог(Каталог);
        
    КонецЕсли;

    Возврат Каталог;
    
КонецФункции

// Возвращает путь к каталогу модулей объекта, на всякий случай
//
// Параметры:
//   ИмяОбъекта - Строка - Имя объекта
//   ВидОбъекта - Строка - Вид объекта метаданных, англ., в единственном числе
//
//  Возвращаемое значение:
//   Строка - Путь к каталогу
//
Функция КаталогМодулиОбъекта(ИмяОбъекта, ВидОбъекта) Экспорт
	
	Каталог = КаталогДополнительныхФайловОбъекта(ИмяОбъекта, ВидОбъекта);

    Возврат Каталог;
    
КонецФункции

// Возвращает путь к каталогу, в котором хранятся описания всех объектов одного вида
//
// Параметры:
//   ВидОбъекта - Строка - Вид объекта метаданных, англ., в единственном числе
//
//  Возвращаемое значение:
//   Строка - Путь к каталогу
//
Функция КаталогВидаОбъекта(ВидОбъекта) Экспорт
	
	Если ТипыОбъектовКонфигурации.ЭтоТипКонфигурации(ВидОбъекта) Тогда
		
		Если ЭтоФорматEDT Тогда

			Каталог = ОбъединитьПути(КаталогИсходников, ВидОбъекта);
			
		Иначе

			Каталог = КаталогИсходников;
			
		КонецЕсли;
		
	Иначе

		Каталог = ОбъединитьПути(КаталогИсходников, ИмяКаталогВидаОбъекта(ВидОбъекта));

	КонецЕсли;

    Если СоздаватьКаталоги Тогда
        
        СоздатьКаталог(Каталог);
        
    КонецЕсли;

    Возврат Каталог;
    
КонецФункции

// Путь к файлу описания конфигурации
//
//  Возвращаемое значение:
//   Строка - Путь к файлу
//
Функция ИмяФайлаОписанияКонфигурации() Экспорт
	
	Возврат ИмяФайлаОписанияОбъекта(ТипыОбъектовКонфигурации.ИмяТипаКонфигурации(), ТипыОбъектовКонфигурации.ИмяТипаКонфигурации());
		
КонецФункции

// Путь к файлу описания объекта
//
// Параметры:
//   ИмяОбъекта - Строка - Имя объекта
//   ВидОбъекта - Строка - Вид объекта метаданных, англ., в единственном числе
//
//  Возвращаемое значение:
//   Строка - Путь к файлу
//
Функция ИмяФайлаОписанияОбъекта(ИмяОбъекта, ВидОбъекта) Экспорт
	
	Если ЭтоФорматEDT Тогда
		
		КаталогОписаний = КаталогФайловОбъекта(ИмяОбъекта, ВидОбъекта);
		
	ИначеЕсли ВидОбъекта = ТипыОбъектовКонфигурации.ИмяТипаПодсистемы() И СтрНайти(ИмяОбъекта, ".")	Тогда
		
		КаталогОписаний = КаталогФайловОбъекта(ИмяОбъекта, ВидОбъекта);

		Возврат КаталогОписаний + "." + РасширениеФайловОписания;

	Иначе
		
		КаталогОписаний = КаталогВидаОбъекта(ВидОбъекта);
		
	КонецЕсли;

    Возврат ОбъединитьПути(КаталогОписаний, СтрШаблон("%1.%2", ИмяОбъекта, РасширениеФайловОписания));

КонецФункции

// Путь к файлу модуля
//
// Параметры:
//   ИмяОбъекта - Строка - Имя объекта
//   ВидОбъекта - Строка - Вид объекта метаданных, англ., в единственном числе
//   ИмяМодуля - Строка - Имя модуля без расширения
//
//  Возвращаемое значение:
//   Строка - Путь к файлу
//
Функция ИмяФайлаМодуля(ИмяОбъекта, ВидОбъекта, ИмяМодуля = "Module") Экспорт
    
    Каталог = КаталогМодулиОбъекта(ИмяОбъекта, ВидОбъекта);
    
    Возврат ОбъединитьПути(Каталог, ИмяМодуля + ".bsl");

КонецФункции

// Возвращает путь до произвольного файла конфигурации
//
// Параметры:
//   ИмяФайла - Строка - Имя файла, путь к которому хотим получить
//
//  Возвращаемое значение:
//   Строка - Полный путь до файла конфигурации
//
Функция ИмяВложенногоФайла(ИмяФайла) Экспорт

	Возврат ОбъединитьПути(КорневойКаталог(), ИмяФайла);
	
КонецФункции

// возвращает признак, имеет ли выгрузка иерархический формат
//
//  Возвращаемое значение:
//   Булево - признак, имеет ли выгрузка иерархический формат
//
Функция ИерархическийФормат() Экспорт
	
	Возврат ИерархическийФормат;
	
КонецФункции

// Возвращает формат выгрузки
//	Возможные значения: EDT, Designer
//
//  Возвращаемое значение:
//   Строка - Формат выгрузки
//
Функция ФорматВыгрузки() Экспорт
	
	Возврат ФорматВыгрузки;

КонецФункции

// Выполняет поиск файлов описаний подсистем конфигурации
//
//  Возвращаемое значение:
//   Массив - Иерархическая коллекция, каждый элемент - структура, содержащая
//		* КаталогОписания - каталог доп. файлов описания
//		* ФайлОписания - Имя файла описания подсистемы
//		* Вложенные - Информация о вложенных подсистемах
//
Функция НайтиФайлыПодсистем() Экспорт
	
	Подсистемы = Новый Массив();

	НайтиПодсистемы(КорневойКаталог(), Подсистемы);
	
	Возврат Подсистемы;
	
КонецФункции

// Выполняет поиск модулей объекта
//
// Параметры:
//   ИмяОбъекта - Строка - Имя объекта
//   ВидОбъекта - Строка - Вид объекта, например, Конфигурация, Document, Перечисления
//   МодулиПодчиненныхОбъектов - Булево - Признак, искать ли модули подчиненных объектов, таких как, формы и команды
//
//  Возвращаемое значение:
//   Массив - Коллекция имен файлов модулей
//
Функция НайтиМодулиОбъекта(ИмяОбъекта, ВидОбъекта, МодулиПодчиненныхОбъектов = Ложь) Экспорт
	
	Результат = Новый Массив();

	РасширениеФайлов = "." + РасширениеФайловМодулей;
	
	Если МодулиПодчиненныхОбъектов И НЕ ЭтоФорматEDT И НЕ ТипыОбъектовКонфигурации.ЭтоТипКонфигурации(ВидОбъекта) Тогда
		
		КаталогМодулей = КаталогФайловОбъекта(ИмяОбъекта, ВидОбъекта);
		
	Иначе
		
		КаталогМодулей = КаталогМодулиОбъекта(ИмяОбъекта, ВидОбъекта);
		
	КонецЕсли;
	
	Для Каждого Файл Из НайтиФайлы(КаталогМодулей, "*", МодулиПодчиненныхОбъектов) Цикл

		Если Файл.ЭтоКаталог() Тогда

			Продолжить;

		КонецЕсли;

		Если НЕ (Файл.Расширение = "" ИЛИ СтрСравнить(РасширениеФайлов, Файл.Расширение) = 0) Тогда

			Продолжить;

		КонецЕсли;
		
		Результат.Добавить(Файл.ПолноеИмя);

	КонецЦикла; 

	Возврат Результат;
	
КонецФункции

///////////////////////////////////////////////////////////////////
// Служебный функционал
///////////////////////////////////////////////////////////////////

Функция ИмяКаталогВидаОбъекта(ВидОбъекта)
	
	Возврат ТипыОбъектовКонфигурации.ОписаниеТипаПоИмени(ВидОбъекта).НаименованиеКоллекцииEng;

КонецФункции

Процедура НайтиПодсистемы(Знач КаталогПоиска, Подсистемы)

	КаталогПоиска = ОбъединитьПути(КаталогПоиска, "Subsystems");
	
	Если ЭтоФорматEDT Тогда
		
		Для Каждого Файл Из НайтиФайлы(КаталогПоиска, "*", Ложь) Цикл
			
			Если НЕ Файл.ЭтоКаталог() Тогда
				Продолжить;
			КонецЕсли;
			
			ИмяФайлаОписания = ОбъединитьПути(Файл.ПолноеИмя, СтрШаблон("%1.%2", Файл.Имя, РасширениеФайловОписания));
			
			Если НЕ (Новый Файл(ИмяФайлаОписания)).Существует() Тогда
				
				Продолжить;
				
			КонецЕсли;

			ОписаниеПодсистемы = Новый Структура("КаталогОписания, ФайлОписания, Вложенные", Файл.ПолноеИмя, ИмяФайлаОписания, Новый Массив);
			Подсистемы.Добавить(ОписаниеПодсистемы);

			НайтиПодсистемы(Файл.ПолноеИмя, ОписаниеПодсистемы.Вложенные);

		КонецЦикла;
		
	Иначе

		Для Каждого Файл Из НайтиФайлы(КаталогПоиска, "*.xml", Ложь) Цикл
					
			КаталогДополнительныхФайлов = ОбъединитьПути(Файл.Путь, Файл.ИмяБезРасширения);
			
			ОписаниеПодсистемы = Новый Структура("КаталогОписания, ФайлОписания, Вложенные", КаталогДополнительныхФайлов, Файл.ПолноеИмя, Новый Массив);
			
			Подсистемы.Добавить(ОписаниеПодсистемы);

			НайтиПодсистемы(КаталогДополнительныхФайлов, ОписаниеПодсистемы.Вложенные);

		КонецЦикла;
		
	КонецЕсли

КонецПроцедуры

Процедура ПриСозданииОбъекта(пКаталогИсходников, пФорматВыгрузки = "Авто", пСоздаватьКаталоги = Ложь)
    
    КаталогИсходников = пКаталогИсходников;
	ФорматВыгрузки = пФорматВыгрузки;
	СоздаватьКаталоги = пСоздаватьКаталоги = Истина;
	
	Если ПустаяСтрока(ФорматВыгрузки) ИЛИ СтрСравнить(ФорматВыгрузки, "Авто") = 0 Тогда
		
		Если ФС.ФайлСуществует(ОбъединитьПути(КаталогИсходников, ТипыОбъектовКонфигурации.ИмяТипаКонфигурации(), "Configuration.mdo")) Тогда
			
			ФорматВыгрузки = "EDT";
			
		Иначе
			
			ФорматВыгрузки = "Designer";
			
		КонецЕсли;

	КонецЕсли;
	
	// определим иерархию
	// схема определения проста, если есть каталог "Languages" то иерархия в формате 8.3.8
	КаталогЯзыки = КаталогВидаОбъекта("Language");
	ИерархическийФормат = ФС.Существует(КаталогЯзыки);

	ЭтоФорматEDT = ФорматВыгрузки = "EDT";

	Если ЭтоФорматEDT Тогда
		
		РасширениеФайловОписания = "mdo";
		
	Иначе
		
		РасширениеФайловОписания = "xml";
		
	КонецЕсли;

	РасширениеФайловМодулей = ?(ИерархическийФормат ИЛИ ЭтоФорматEDT, "bsl", "txt");

КонецПроцедуры
