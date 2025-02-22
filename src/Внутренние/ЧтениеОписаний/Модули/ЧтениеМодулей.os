///////////////////////////////////////////////////////////////////////////////
//
// Методы разбора исходных модулей 1с
//
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// ПРОГРАММНЫЙ ИНТЕРФЕЙС
///////////////////////////////////////////////////////////////////////////////

// Выполняет чтение структуры модуля
//
// Параметры:
//   СодержимоеФайла - ТекстовыйДокумент - Код модуля
//   СтрокаМодуль - СтрокаТаблицыЗначений - Описание модуля
//
//  Возвращаемое значение:
//   Структура - Информация о структуре модуля
//		* Содержимое - Строка - Текст модуля
//		* БлокиМодуля - ТаблицаЗначений - Информация о ключевых блоках (областях, методах) модуля
//
Функция ПрочитатьМодуль(ПутьКФайлу, СтрокаМодуль) Экспорт

	СодержимоеФайла = Новый ТекстовыйДокумент;
	СодержимоеФайла.Прочитать(ПутьКФайлу, КодировкаТекста.UTF8NoBOM);	
	
	БлокиМодуля = Новый ТаблицаЗначений;
	БлокиМодуля.Колонки.Добавить("ТипБлока");	
	БлокиМодуля.Колонки.Добавить("НачальнаяСтрока");
	БлокиМодуля.Колонки.Добавить("КонечнаяСтрока");
	БлокиМодуля.Колонки.Добавить("Содержимое");
	БлокиМодуля.Колонки.Добавить("ОписаниеБлока");

	КоличествоСтрокМодуля = СодержимоеФайла.КоличествоСтрок();
	
	ТекущийБлок = Неопределено;
	ЭтоКонецБлока = Истина;

	НачальнаяСтрока = 1;
	КонечнаяСтрока = 1;

	Для НомерСтроки = 1 По КоличествоСтрокМодуля Цикл
		
		СтрокаМодуля = ВРег(СокрЛП(СодержимоеФайла.ПолучитьСтроку(НомерСтроки)));

		Если НЕ ЭтоКонецБлока Тогда 
			
			НовыйБлок = ТекущийБлок;
			Если НовыйБлок = ТипыБлоковМодуля.ОписаниеПеременной Тогда 
				
				УдалитьКомментарийИзСтроки(СтрокаМодуля);
				ЭтоКонецБлока = СтрНайти(СтрокаМодуля, ";") > 0;
				
			ИначеЕсли НовыйБлок = ТипыБлоковМодуля.ЗаголовокПроцедуры 
					ИЛИ НовыйБлок = ТипыБлоковМодуля.ЗаголовокФункции Тогда 
				
				УдалитьКомментарийИзСтроки(СтрокаМодуля);
				ПозицияСкобки = СтрНайти(СтрокаМодуля, ")") > 0;
				ЭтоКонецБлока = ПозицияСкобки > 0;
				
			Иначе 
				
				ЭтоКонецБлока = Истина;
				
			КонецЕсли;
			
		ИначеЕсли СтрНачинаетсяС(СтрокаМодуля, "#ОБЛАСТЬ")
				ИЛИ СтрНачинаетсяС(СтрокаМодуля, "// #ОБЛАСТЬ") Тогда
			
			НовыйБлок = ТипыБлоковМодуля.НачалоОбласти;
			ЭтоКонецБлока = Истина;

			Если СтрНачинаетсяС(СтрокаМодуля, "//") Тогда

				СтрокаМодуля = Сред(СтрокаМодуля, 4);

			КонецЕсли;

		ИначеЕсли СтрНачинаетсяС(СтрокаМодуля, "#КОНЕЦОБЛАСТИ")
				ИЛИ СтрНачинаетсяС(СтрокаМодуля, "// #КОНЕЦОБЛАСТИ") Тогда
			
			НовыйБлок = ТипыБлоковМодуля.КонецОбласти;
			ЭтоКонецБлока = Истина;
			
			Если СтрНачинаетсяС(СтрокаМодуля, "//") Тогда

				СтрокаМодуля = Сред(СтрокаМодуля, 4);

			КонецЕсли;
	
		ИначеЕсли СтрНачинаетсяС(СтрокаМодуля, "//") Тогда
			
			НовыйБлок = ТипыБлоковМодуля.Комментарий;
			ЭтоКонецБлока = Истина;
			
		ИначеЕсли СтрНачинаетсяС(СтрокаМодуля, "&") Тогда
			
			НовыйБлок = ТипыБлоковМодуля.ДирективаКомпиляции;
			ЭтоКонецБлока = Истина;
			
		ИначеЕсли СтрНачинаетсяС(СтрокаМодуля, "ПЕРЕМ") Тогда
			
			НовыйБлок = ТипыБлоковМодуля.ОписаниеПеременной;
			УдалитьКомментарийИзСтроки(СтрокаМодуля);
			ЭтоКонецБлока = СтрНайти(СтрокаМодуля, ";") > 0;
			
		ИначеЕсли СтрНачинаетсяС(СтрокаМодуля, "ПРОЦЕДУРА ") 
				ИЛИ СтрНачинаетсяС(СтрокаМодуля, "ФУНКЦИЯ ")
				ИЛИ СтрНачинаетсяС(СтрокаМодуля, "FUNCTION ") 
				ИЛИ СтрНачинаетсяС(СтрокаМодуля, "PROCEDURE ") Тогда
			
			НовыйБлок = ?(СтрНачинаетсяС(СтрокаМодуля, "ПРОЦЕДУРА") ИЛИ СтрНачинаетсяС(СтрокаМодуля, "PROCEDURE"), ТипыБлоковМодуля.ЗаголовокПроцедуры, ТипыБлоковМодуля.ЗаголовокФункции);
			
			УдалитьКомментарийИзСтроки(СтрокаМодуля);
			ПозицияСкобки = СтрНайти(СтрокаМодуля, ")");
			ЭтоКонецБлока = ПозицияСкобки > 0;			

		ИначеЕсли СтрНачинаетсяС(СтрокаМодуля, "КОНЕЦПРОЦЕДУРЫ") 
				ИЛИ СтрНачинаетсяС(СтрокаМодуля, "КОНЕЦФУНКЦИИ")
				ИЛИ СтрНачинаетсяС(СтрокаМодуля, "ENDFUNCTION")
				ИЛИ СтрНачинаетсяС(СтрокаМодуля, "ENDPROCEDURE") Тогда
			
			НовыйБлок = ?(СтрНачинаетсяС(СтрокаМодуля, "КОНЕЦПРОЦЕДУРЫ") ИЛИ СтрНачинаетсяС(СтрокаМодуля, "ENDPROCEDURE"), ТипыБлоковМодуля.ОкончаниеПроцедуры, ТипыБлоковМодуля.ОкончаниеФункции);
			ЭтоКонецБлока = Истина;
			УдалитьКомментарийИзСтроки(СтрокаМодуля);
			
		ИначеЕсли ПустаяСтрока(СтрокаМодуля) И ТекущийБлок <> ТипыБлоковМодуля.Операторы Тогда

			НовыйБлок = ТипыБлоковМодуля.ПустаяСтрока;
			ЭтоКонецБлока = Истина;

		Иначе
			
			НовыйБлок = ТипыБлоковМодуля.Операторы;
			ЭтоКонецБлока = Истина;
			
		КонецЕсли;
		
		Если НовыйБлок = ТекущийБлок Тогда
			
			КонечнаяСтрока = КонечнаяСтрока + 1;
			
		Иначе
			
			Если ЗначениеЗаполнено(ТекущийБлок) Тогда

				НоваяЗаписьОБлоке = БлокиМодуля.Добавить();
				НоваяЗаписьОБлоке.ТипБлока = ТекущийБлок;
				НоваяЗаписьОБлоке.НачальнаяСтрока = НачальнаяСтрока;
				НоваяЗаписьОБлоке.КонечнаяСтрока  = КонечнаяСтрока;
				НоваяЗаписьОБлоке.ОписаниеБлока = Новый Структура;

				УдалятьКомментарии = ТекущийБлок = ТипыБлоковМодуля.ЗаголовокПроцедуры ИЛИ ТекущийБлок = ТипыБлоковМодуля.ЗаголовокФункции;
				НоваяЗаписьОБлоке.Содержимое = ПолучитьСодержимоеБлока(СодержимоеФайла, НачальнаяСтрока, КонечнаяСтрока, УдалятьКомментарии);
				
			КонецЕсли;
			
			НачальнаяСтрока = НомерСтроки;
			КонечнаяСтрока  = НомерСтроки;
			ТекущийБлок = НовыйБлок;

		КонецЕсли;
		
		Если НомерСтроки = КоличествоСтрокМодуля Тогда

			НоваяЗаписьОБлоке = БлокиМодуля.Добавить();
			НоваяЗаписьОБлоке.ТипБлока = ТекущийБлок;
			НоваяЗаписьОБлоке.НачальнаяСтрока = НачальнаяСтрока;
			НоваяЗаписьОБлоке.КонечнаяСтрока  = КонечнаяСтрока;
			НоваяЗаписьОБлоке.ОписаниеБлока = Новый Структура;

			УдалятьКомментарии = ТекущийБлок = ТипыБлоковМодуля.ЗаголовокПроцедуры ИЛИ ТекущийБлок = ТипыБлоковМодуля.ЗаголовокФункции;
			НоваяЗаписьОБлоке.Содержимое = ПолучитьСодержимоеБлока(СодержимоеФайла, НачальнаяСтрока, КонечнаяСтрока, УдалятьКомментарии);

		КонецЕсли;

	КонецЦикла;

	СодержимоеМодуля = Новый Структура("Содержимое, БлокиМодуля", СодержимоеФайла.ПолучитьТекст(), БлокиМодуля);
	
	ДополнитьБлокиМодуля(БлокиМодуля, СодержимоеФайла, СтрокаМодуль);

	Возврат СодержимоеМодуля;

КонецФункции

///////////////////////////////////////////////////////////////////////////////
// СЛУЖЕБНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ
///////////////////////////////////////////////////////////////////////////////

Процедура УдалитьКомментарийИзСтроки(СтрокаМодуля)

	ПозицияКомментария = СтрНайти(СтрокаМодуля, "//");
	Если ПозицияКомментария > 0 Тогда

		СтрокаМодуля = СокрП(Лев(СтрокаМодуля, ПозицияКомментария - 1));

	КонецЕсли;

КонецПроцедуры

Функция ПолучитьНазначениеБлока(Файл, Знач НачальнаяСтрока, Знач КонечнаяСтрока, ИмяБлока = "")

	Назначение = "";
	Если НачальнаяСтрока + 1 < КонечнаяСтрока Тогда

		СтрокаМодуляНач = СокрЛП(Файл.ПолучитьСтроку(НачальнаяСтрока));
		СтрокаМодуляКон = СокрЛП(Файл.ПолучитьСтроку(КонечнаяСтрока));
		Если СтрНачинаетсяС(СтрокаМодуляНач, "////") 
				И СтрНачинаетсяС(СтрокаМодуляКон, "////") Тогда // да, это описание

			Если Не ПустаяСтрока(ИмяБлока) Тогда

				СтрокаМодуля2 = СокрЛП(Файл.ПолучитьСтроку(НачальнаяСтрока + 1));
				Если СтрНачинаетсяС(СтрокаМодуля2, "// " + ИмяБлока) Тогда

					НачальнаяСтрока = НачальнаяСтрока + 1;

				Иначе

					// имени блока нет, пропускаем
					НачальнаяСтрока = КонечнаяСтрока;

				КонецЕсли;

			КонецЕсли;

			Для Ит = НачальнаяСтрока + 1 По КонечнаяСтрока - 1 Цикл
							
				СтрокаМодуля = СокрЛП(Сред(Файл.ПолучитьСтроку(Ит), 3));
				Назначение = Назначение + ?(ПустаяСтрока(Назначение), "", Символы.ПС) + СтрокаМодуля;

			КонецЦикла;

		КонецЕсли;

	КонецЕсли;

	Возврат Назначение;

КонецФункции

Функция ПолучитьПараметрыМетода(СтрокаПараметров)

	ПараметрыМетода = Новый ТаблицаЗначений;
	ПараметрыМетода.Колонки.Добавить("Имя");
	ПараметрыМетода.Колонки.Добавить("Знач");
	ПараметрыМетода.Колонки.Добавить("ЗначениеПоУмолчанию");
	ПараметрыМетода.Колонки.Добавить("ТипПараметра");
	ПараметрыМетода.Колонки.Добавить("ОписаниеПараметра");

	ДлинаСтроки = СтрДлина(СтрокаПараметров);

	Пока Истина Цикл

		Если ПустаяСтрока(СтрокаПараметров) Тогда

			Прервать;

		КонецЕсли;

		СтрокаПараметров = СокрЛП(СтрокаПараметров);
		ПараметрМетода = ПараметрыМетода.Добавить();
		ЗаполнитьЗначенияСвойств(ПараметрМетода, Новый Структура("ЗНАЧ, Имя, ЗначениеПоУмолчанию, ТипПараметра, ОписаниеПараметра", Ложь, "", Неопределено, "", ""));

		// отделим ЗНАЧ
		Если СтрНачинаетсяС(ВРег(СтрокаПараметров), "ЗНАЧ ") Тогда

			ПараметрМетода.ЗНАЧ = Истина;
			СтрокаПараметров = СокрЛП(Сред(СтрокаПараметров, 5)); 

		КонецЕсли;

		// отделим имя
		ПозицияРавно = СтрНайти(СтрокаПараметров, "=");
		ПозицияЗапятая = СтрНайти(СтрокаПараметров, ",");
		
		Если ПозицияЗапятая + ПозицияРавно = 0 Тогда
			
			//  вся строка параметр
			ПараметрМетода.Имя = СокрЛП(СтрокаПараметров);
			СтрокаПараметров = "";

		ИначеЕсли ПозицияРавно = 0 ИЛИ ПозицияРавно > ПозицияЗапятая И ПозицияЗапятая > 0 Тогда        
			
			// значения по умолчанию нет        
			ПараметрМетода.Имя = СокрЛП(Лев(СтрокаПараметров, ПозицияЗапятая - 1));
			СтрокаПараметров = СокрЛП(Сред(СтрокаПараметров, ПозицияЗапятая + 1));

		Иначе // есть значение по умолчанию
			
			ПараметрМетода.Имя = СокрЛП(Лев(СтрокаПараметров, ПозицияРавно - 1));
			СтрокаПараметров = СокрЛП(Сред(СтрокаПараметров, ПозицияРавно + 1));
			ПозицияЗапятая = СтрНайти(СтрокаПараметров, ",");
			Если ПозицияЗапятая = 0 Тогда 
				
				// до конца строки - это значение по умолчанию
				ПараметрМетода.ЗначениеПоУмолчанию = СтрокаПараметров;
				СтрокаПараметров = "";

			Иначе

				// надо отделить значение по умолчанию от следующего параметра
				// варианты значения - число, строка, булево, Неопределено  
				ПозицияКавычки = СтрНайти(СтрокаПараметров, """");
				Если ПозицияКавычки = 0 ИЛИ ПозицияКавычки > ПозицияЗапятая Тогда

					// текущее значение по умолчанию не строковое
					ПараметрМетода.ЗначениеПоУмолчанию = СокрЛП(Лев(СтрокаПараметров, ПозицияЗапятая - 1));
					СтрокаПараметров = СокрЛП(Сред(СтрокаПараметров, ПозицияЗапятая + 1));

				Иначе

					ЗначениеПараметра = "";
					КавычкаОткрыта = Истина;
					Пока Истина Цикл                    
			
						ПозицияКавычки = СтрНайти(СтрокаПараметров, """", , 2);
						КавычкаОткрыта = НЕ КавычкаОткрыта;
						ЗначениеПараметра = ЗначениеПараметра + Лев(СтрокаПараметров, ПозицияКавычки);     
						СтрокаПараметров = Сред(СтрокаПараметров, ПозицияКавычки + 1);

						Если ПустаяСтрока(СтрокаПараметров) Тогда

							Прервать;

						Иначе
		
							ПозицияЗапятая = СтрНайти(СтрокаПараметров, ",");
							ПозицияКавычки = СтрНайти(СтрокаПараметров, """", , 2);

							Если ПозицияКавычки = 0 ИЛИ ПозицияКавычки > ПозицияЗапятая ИЛИ НЕ КавычкаОткрыта Тогда

								
								ЗначениеПараметра = СокрЛП(ЗначениеПараметра + Лев(СтрокаПараметров, ПозицияЗапятая - 1));
								СтрокаПараметров = СокрЛП(Сред(СтрокаПараметров, ПозицияЗапятая + 1));
								Прервать;

							КонецЕсли;

						КонецЕсли;
						
					КонецЦикла; 
					
					ПараметрМетода.ЗначениеПоУмолчанию = ЗначениеПараметра;

				КонецЕсли;

			КонецЕсли;

		КонецЕсли;

	КонецЦикла;
	
	Возврат ПараметрыМетода;

КонецФункции

Процедура ДополнитьБлокиМодуля(БлокиМодуля, Файл, Модуль)

	ОписаниеМодуля = Новый Структура(
			"Глобальный, 	ЕстьНазначениеМодуля, 	Назначение,	Разделы",
			Ложь,			Ложь,					"",			Новый Массив);

	НазначениеМодуляПрошли = Ложь;
	РазделОткрыт = Ложь;
	ЛокальнаяОбластьОткрыта = Ложь;
	МетодОткрыт = Ложь;

	Области = Новый Массив;

	ТекущийРаздел = "";
	ПоследнийБлокКомментария = Неопределено;
	ПоследнийБлокМетода = Неопределено;

	БлокиДляУдаления = Новый Массив;

	Для Каждого Блок Из БлокиМодуля Цикл

		Блок.ОписаниеБлока.Вставить("ЭтоРаздел", Ложь);
		Блок.ОписаниеБлока.Вставить("ИмяРаздела", "");
		Блок.ОписаниеБлока.Вставить("ИмяОбласти", "");
		Блок.ОписаниеБлока.Вставить("НазначениеРаздела", "");
		Блок.ОписаниеБлока.Вставить("ИмяМетода", "");
		Блок.ОписаниеБлока.Вставить("ПараметрыМетода", Неопределено);
		Блок.ОписаниеБлока.Вставить("Назначение", "");
		Блок.ОписаниеБлока.Вставить("Экспортный", Ложь);
		Блок.ОписаниеБлока.Вставить("ТипВозвращаемогоЗначения", "");
		Блок.ОписаниеБлока.Вставить("ОписаниеВозвращаемогоЗначения", "");
		Блок.ОписаниеБлока.Вставить("Примеры", Новый Массив);		
		Блок.ОписаниеБлока.Вставить("Тело", "");

		Если МетодОткрыт Тогда

			БлокиДляУдаления.Добавить(Блок);

		КонецЕсли;

		Если Блок.ТипБлока = ТипыБлоковМодуля.ПустаяСтрока Тогда

			Продолжить;

		КонецЕсли;

		Если Блок.ТипБлока <> ТипыБлоковМодуля.Комментарий Тогда

			// если комментарий не первый, значит уже и нет смысла искать описания
			НазначениеМодуляПрошли = Истина;

		КонецЕсли;

		Если Блок.ТипБлока = ТипыБлоковМодуля.Комментарий Тогда

			Если НЕ НазначениеМодуляПрошли Тогда

				// первый комментарий считаем описанием модуля	
				НазначениеМодуляПрошли = Истина;
				Назначение = ПолучитьНазначениеБлока(Файл, Блок.НачальнаяСтрока, Блок.КонечнаяСтрока);

				Блок.ТипБлока = ТипыБлоковМодуля.Описание;
				ОписаниеМодуля.ЕстьНазначениеМодуля = НЕ ПустаяСтрока(Назначение);
				ОписаниеМодуля.Назначение = Назначение;

			Иначе
			
				ПоследнийБлокКомментария = Блок;

			КонецЕсли; 

		ИначеЕсли Блок.ТипБлока = ТипыБлоковМодуля.НачалоОбласти Тогда

			СтрокаМодуля = СокрЛП(Файл.ПолучитьСтроку(Блок.НачальнаяСтрока));
			ИмяОбласти = СокрЛП(Сред(СтрокаМодуля, СтрДлина("#Область") + 1));

			ЭтоРаздел = Ложь;
			Если Модуль.ТипМодуля = ТипыМодуля.ОбщийМодуль Тогда

				ЭтоРаздел = ТипыОбласти.РазделыОбщегоМодуля.Найти(ИмяОбласти) <> Неопределено;

			ИначеЕсли Модуль.ТипМодуля = ТипыМодуля.МодульМенеджера Тогда

				ЭтоРаздел = ТипыОбласти.РазделыМодуляМенеджера.Найти(ИмяОбласти) <> Неопределено;
			
			КонецЕсли;
				
			Если ЭтоРаздел И (РазделОткрыт ИЛИ ЛокальнаяОбластьОткрыта ИЛИ МетодОткрыт) Тогда

				// кривая структура модуля
				ЭтоРаздел = Ложь;
			
			КонецЕсли;

			ТекущаяОбласть = "";
			Если Области.Количество() Тогда

				ТекущаяОбласть = Области[Области.ВГраница()];

			КонецЕсли;

			Блок.ОписаниеБлока.Вставить("ЭтоРаздел", ЭтоРаздел);
			Блок.ОписаниеБлока.Вставить("ИмяРаздела", ТекущийРаздел);
			Блок.ОписаниеБлока.Вставить("ИмяОбласти", ТекущаяОбласть);
			Блок.ОписаниеБлока.Вставить("НазначениеРаздела", "");

			Если ЭтоРаздел Тогда

				РазделОткрыт = Истина;
				ТекущийРаздел = ИмяОбласти;

				ОписаниеМодуля.Разделы.Добавить(ТекущийРаздел);
			
				// заполним описание раздела
				Если ПоследнийБлокКомментария <> Неопределено Тогда

					Назначение = ПолучитьНазначениеБлока(Файл, ПоследнийБлокКомментария.НачальнаяСтрока, ПоследнийБлокКомментария.КонечнаяСтрока, ИмяОбласти);
					Блок.ОписаниеБлока.Вставить("НазначениеРаздела", Назначение);
					Если НЕ ПустаяСтрока(Назначение) Тогда
							
						ПоследнийБлокКомментария.ТипБлока = ТипыБлоковМодуля.Описание;

					КонецЕсли;							

					ПоследнийБлокКомментария = Неопределено;

				КонецЕсли;

			Иначе

				ЛокальнаяОбластьОткрыта = Истина;
				Области.Добавить(ИмяОбласти);				

			КонецЕсли;

		ИначеЕсли Блок.ТипБлока = ТипыБлоковМодуля.КонецОбласти Тогда

			ПоследнийБлокКомментария = Неопределено;

			Если ЛокальнаяОбластьОткрыта Тогда 

				Области.Удалить(Области.ВГраница());
				ЛокальнаяОбластьОткрыта = Области.Количество();

			ИначеЕсли РазделОткрыт Тогда

				РазделОткрыт = Ложь;
				ТекущийРаздел = "";

			Иначе

				// ошибка, пока не обрабатываю

			КонецЕсли;

		ИначеЕсли Блок.ТипБлока = ТипыБлоковМодуля.ЗаголовокПроцедуры
				ИЛИ Блок.ТипБлока = ТипыБлоковМодуля.ЗаголовокФункции Тогда
			
			Блок.ОписаниеБлока.Вставить("ИмяРаздела", ТекущийРаздел);
			Если Области.Количество() Тогда

				Блок.ОписаниеБлока.Вставить("ИмяОбласти", Области[Области.ВГраница()]);

			Иначе

				Блок.ОписаниеБлока.Вставить("ИмяОбласти", "");

			КонецЕсли;

			МетодОткрыт = Истина;
			ПоследнийБлокМетода = Блок;

			// получим имя метода
			Заголовок = СтрЗаменить(Блок.Содержимое, Символы.ПС, " ");
			Заголовок = СокрЛП(СтрЗаменить(Заголовок, Символы.Таб, " "));
			Если Блок.ТипБлока = ТипыБлоковМодуля.ЗаголовокПроцедуры Тогда

				Заголовок = СокрЛП(Сред(Заголовок, СтрДлина("Процедура") + 1))

			Иначе	
				
				Если СтрНачинаетсяС(Заголовок, "Функция") Тогда

					Заголовок = СокрЛП(Сред(Заголовок, СтрДлина("Функция") + 1))

				Иначе

					Заголовок = СокрЛП(Сред(Заголовок, СтрДлина("Function") + 1))

				КонецЕсли;
															 
			КонецЕсли;

			// получим параметры метода
			ПозицияСкобки = СтрНайти(Заголовок, "(");
			ИмяМетода = Лев(Заголовок, ПозицияСкобки - 1);
			СтрокаПараметров = СокрЛП(Сред(Заголовок, ПозицияСкобки + 1));
			ПозицияСкобки = СтрНайти(СтрокаПараметров, ")", НаправлениеПоиска.СКонца);
			СтрокаПараметров = СокрЛП(Лев(СтрокаПараметров, ПозицияСкобки - 1));
			Заголовок = СокрЛП(Сред(Заголовок, СтрНайти(Заголовок, ")", НаправлениеПоиска.СКонца) + 1));
			Блок.ОписаниеБлока.Вставить("ИмяМетода", ИмяМетода);
			Блок.ОписаниеБлока.Вставить("ПараметрыМетода", ПолучитьПараметрыМетода(СтрокаПараметров));
			Блок.ОписаниеБлока.Вставить("Назначение", "");
			Блок.ОписаниеБлока.Вставить("Экспортный", СтрЗаканчиваетсяНа(ВРег(Заголовок), "ЭКСПОРТ"));
			Блок.ОписаниеБлока.Вставить("ТипВозвращаемогоЗначения", "");
			Блок.ОписаниеБлока.Вставить("ОписаниеВозвращаемогоЗначения", "");
			Блок.ОписаниеБлока.Вставить("Примеры", Новый Массив);

			// получим описание метода
			Если ПоследнийБлокКомментария <> Неопределено Тогда

				СтрокаКомментария = Файл.ПолучитьСтроку(ПоследнийБлокКомментария.НачальнаяСтрока);
				СтрокаКомментария = СокрЛП(Сред(СтрокаКомментария, 3));
				Если СтрНайти(СтрокаКомментария, ИмяМетода) Тогда

					ПоследнийБлокКомментария.ТипБлока = ТипыБлоковМодуля.Описание;
					Назначение = "";
					НомерСтрокиПараметры = Неопределено;
					НомерСтрокиВозвращаемоеЗначение = Неопределено;
					НомерСтрокиПример = Неопределено;
					НомерСтроки = Неопределено;
					Для Ит = ПоследнийБлокКомментария.НачальнаяСтрока + 1 По ПоследнийБлокКомментария.КонечнаяСтрока Цикл

						СтрокаКомментария = Файл.ПолучитьСтроку(Ит);
						СтрокаКомментария = СокрЛП(Сред(СтрокаКомментария, 3));
						Если СтрНачинаетсяС(СтрокаКомментария, "Параметры:") Тогда

							НомерСтрокиПараметры = Ит;
							Прервать;

						ИначеЕсли СтрНачинаетсяС(СтрокаКомментария, "Возвращаемое значение:") Тогда

							НомерСтрокиВозвращаемоеЗначение = Ит;
							Прервать;

						ИначеЕсли СтрНачинаетсяС(СтрокаКомментария, "Примеры:") ИЛИ СтрНачинаетсяС(СтрокаКомментария, "Пример:") Тогда

							НомерСтрокиПример = Ит;
							Прервать;

						Иначе

							Назначение = Назначение + ?(ПустаяСтрока(Назначение), "", Символы.ПС) + СтрокаКомментария;

						КонецЕсли;

					КонецЦикла;

					Если НомерСтрокиПараметры <> Неопределено Тогда

						ИмяПараметра = Неопределено;
						ОписаниеПараметра = "";
						ТипПараметра = "";
						Дочитывание = Ложь;
						ПрошлаяСтрока = "";
						Для Ит = НомерСтрокиПараметры + 1 По ПоследнийБлокКомментария.КонечнаяСтрока Цикл

							СтрокаКомментария = Файл.ПолучитьСтроку(Ит);
							СтрокаКомментария = СокрЛП(Сред(СтрокаКомментария, 3));
							Если СтрНачинаетсяС(СтрокаКомментария, "Возвращаемое значение:") Тогда

								НомерСтрокиВозвращаемоеЗначение = Ит;
								Прервать;

							ИначеЕсли СтрНачинаетсяС(СтрокаКомментария, "Примеры:") ИЛИ СтрНачинаетсяС(СтрокаКомментария, "Пример:") Тогда

								НомерСтрокиПример = Ит;
								Прервать;

							Иначе
								
								Если Дочитывание Тогда
									СтрокаКомментария = ПрошлаяСтрока + СтрокаКомментария;
									ПрошлаяСтрока = "";
									Дочитывание = Ложь;
								КонецЕсли;

								// шаблон параметра 
								// 'Имя' - 'Тип' - 'Описание'
								// 'продолжение описания'
								СоставСтрокиКомментария = СтрРазделить(СтрокаКомментария, "-");
								Если СоставСтрокиКомментария.Количество() >= 3 Тогда 

									Если ИмяПараметра <> Неопределено Тогда

										СтрокаПараметраМетода = Блок.ОписаниеБлока.ПараметрыМетода.Найти(ИмяПараметра, "Имя");
										Если СтрокаПараметраМетода <> Неопределено Тогда

											СтрокаПараметраМетода.ТипПараметра = ТипПараметра;
											СтрокаПараметраМетода.ОписаниеПараметра = ОписаниеПараметра;
											
										КонецЕсли;

									КонецЕсли;

									// это описание параметра
									ИмяПараметра = СокрЛП(СоставСтрокиКомментария[0]);
									ТипПараметра = СокрЛП(СоставСтрокиКомментария[1]);

									ПозицияДефис = СтрНайти(СтрокаКомментария, "-");
									ПозицияДефис = СтрНайти(СтрокаКомментария, "-",, ПозицияДефис + 1);
									ОписаниеПараметра = СокрЛП(Сред(СтрокаКомментария, ПозицияДефис + 1));

								
								ИначеЕсли СоставСтрокиКомментария.Количество() = 2 и СтрЗаканчиваетсяНа(СокрЛП(СоставСтрокиКомментария[1]), ",") Тогда
									// шаблон параметра 
									// 'Имя' - 'Тип','Тип', 
									//			'Тип'  - 'Описание'
									// 'продолжение описания'
									ПрошлаяСтрока = СтрокаКомментария;
									Дочитывание = Истина;
									Продолжить;

								Иначе

									// продолжение описания параметра либо косячное описание
									ОписаниеПараметра = ОписаниеПараметра + ?(ПустаяСтрока(ОписаниеПараметра), "", Символы.ПС) + СтрокаКомментария; 

								КонецЕсли;

							КонецЕсли;

						КонецЦикла;

						Если ИмяПараметра <> Неопределено Тогда

							СтрокаПараметраМетода = Блок.ОписаниеБлока.ПараметрыМетода.Найти(ИмяПараметра, "Имя");
							Если СтрокаПараметраМетода <> Неопределено Тогда

								СтрокаПараметраМетода.ТипПараметра = ТипПараметра;
								СтрокаПараметраМетода.ОписаниеПараметра = ОписаниеПараметра;
											
							КонецЕсли;

						КонецЕсли;

					КонецЕсли;

					Если НомерСтрокиВозвращаемоеЗначение <> Неопределено Тогда

						ОписаниеПараметра = "";
						ТипПараметра = "";
						Для Ит = НомерСтрокиВозвращаемоеЗначение + 1 По ПоследнийБлокКомментария.КонечнаяСтрока Цикл

							СтрокаКомментария = Файл.ПолучитьСтроку(Ит);
							СтрокаКомментария = СокрЛП(Сред(СтрокаКомментария, 3));
						
							Если СтрНачинаетсяС(СтрокаКомментария, "Пример") Тогда

								НомерСтрокиПример = Ит;
								Прервать;

							Иначе
								
								// шаблон параметра 
								// 'Тип' - 'Описание'
								// 'продолжение описания'
								
								СоставСтрокиКомментария = СтрРазделить(СтрокаКомментария, "-");
								Если ТипПараметра = "" И СоставСтрокиКомментария.Количество() >= 2 Тогда 

									// это описание параметра
									ТипПараметра = СокрЛП(СоставСтрокиКомментария[0]);

									ПозицияДефис = СтрНайти(СтрокаКомментария, "-");
									ОписаниеПараметра = СокрЛП(Сред(СтрокаКомментария, ПозицияДефис + 1));

								Иначе

									// продолжение описания параметра либо косячное описание
									ОписаниеПараметра = ОписаниеПараметра + ?(ПустаяСтрока(ОписаниеПараметра), "", Символы.ПС) + СтрокаКомментария; 

								КонецЕсли;

							КонецЕсли;

						КонецЦикла;

						Если ТипПараметра <> "" Тогда

							Блок.ОписаниеБлока.Вставить("ТипВозвращаемогоЗначения", ТипПараметра);
							Блок.ОписаниеБлока.Вставить("ОписаниеВозвращаемогоЗначения", ОписаниеПараметра);						

						КонецЕсли;

					КонецЕсли;

					Если НомерСтрокиПример <> Неопределено Тогда

						Примеры = Новый Массив;
						СтрокаПример = "";
						Для Ит = НомерСтрокиПример + 1 По ПоследнийБлокКомментария.КонечнаяСтрока Цикл

							СтрокаКомментария = Файл.ПолучитьСтроку(Ит);
							СтрокаКомментария = СокрЛП(Сред(СтрокаКомментария, 3));
						
							Если СтрНачинаетсяС(СтрокаКомментария, "Пример") Тогда

								Примеры.Добавить(СтрокаПример);
								СтрокаПример = "";
								Продолжить;

							ИначеЕсли Не ПустаяСтрока(СтрокаКомментария) Тогда  
								
								СтрокаПример = СтрокаПример + ?(ПустаяСтрока(СтрокаПример), "", Символы.ПС)
									+ СтрокаКомментария; 

							КонецЕсли;

						КонецЦикла;

						Если СтрокаПример <> "" Тогда

							Примеры.Добавить(СтрокаПример);

						КонецЕсли;

						Если Примеры.Количество() Тогда
							
							Блок.ОписаниеБлока.Вставить("Примеры", Примеры);												

						КонецЕсли;

					КонецЕсли;

					Блок.ОписаниеБлока.Вставить("Назначение", Назначение);

				Иначе

					// кривое описание либо ХЗ что это				

				КонецЕсли;

				ПоследнийБлокКомментария = Неопределено;

			КонецЕсли;
			
		ИначеЕсли Блок.ТипБлока = ТипыБлоковМодуля.ОкончаниеПроцедуры
				ИЛИ Блок.ТипБлока = ТипыБлоковМодуля.ОкончаниеФункции Тогда

			МетодОткрыт = Ложь;
			ПоследнийБлокКомментария = Неопределено;

			ПоследнийБлокМетода.ОписаниеБлока.Тело = ПолучитьСодержимоеБлока(Файл, ПоследнийБлокМетода.КонечнаяСтрока + 1, Блок.НачальнаяСтрока - 1);
			ПоследнийБлокМетода = Неопределено;

		Иначе

			// забываем последний комментарий-блок
			ПоследнийБлокКомментария = Неопределено;
		
		КонецЕсли; 

	КонецЦикла;

	// // удалим служебные блоки
	// Для Каждого Блок Из БлокиДляУдаления Цикл

	// 	БлокиМодуля.Удалить(Блок);

	// КонецЦикла;

	КоличествоБлоков = БлокиМодуля.Количество() - 1; 
	Для Ит = 0 По КоличествоБлоков Цикл

		Блок = БлокиМодуля[КоличествоБлоков - Ит];
		Если Блок.ТипБлока = ТипыБлоковМодуля.ОкончаниеПроцедуры
				ИЛИ Блок.ТипБлока = ТипыБлоковМодуля.ОкончаниеФункции
				ИЛИ Блок.ТипБлока = ТипыБлоковМодуля.КонецОбласти
				ИЛИ Блок.ТипБлока = ТипыБлоковМодуля.Описание
				ИЛИ Блок.ТипБлока = ТипыБлоковМодуля.ПустаяСтрока Тогда

			БлокиМодуля.Удалить(Блок);
			
		КонецЕсли;

	КонецЦикла;
	
	Модуль.ОписаниеМодуля = ОписаниеМодуля;

КонецПроцедуры

Функция ПолучитьСодержимоеБлока(Текст, НачальнаяСтрока, КонечнаяСтрока, УдалятьКомментарии = Ложь)
	
	Строки = Новый Массив();

	Для Ит = НачальнаяСтрока По КонечнаяСтрока Цикл
		
		СтрокаМодуля = Текст.ПолучитьСтроку(Ит);
		
		Если УдалятьКомментарии Тогда
			
			УдалитьКомментарийИзСтроки(СтрокаМодуля);
			
		КонецЕсли;
		
		Строки.Добавить(СтрокаМодуля);

	КонецЦикла;
	
	Возврат СтрСоединить(Строки, Символы.ПС);

КонецФункции
