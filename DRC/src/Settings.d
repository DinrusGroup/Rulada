/// Author: Aziz Köksal
/// License: GPL3
/// $(Maturity average)
module Settings;

import common;

/// Глобальные настройки приложения.
struct ГлобальныеНастройки
{
static:
  /// Путь к папке с данными.
  ткст папкаСДанными = "data/";
  /// Предопределенные идентификаторы версии.
  ткст[] идыВерсий;
  /// Путь к файлу языка.
  ткст файлЯзыка = "lang.d";
  /// Код языка загруженного каталога сообщений.
  ткст кодЯзыка = "ru";
  /// Таблица локализованных сообщений компилятора.
  ткст[] сообщения;
  /// Массив путей импорта для поиска модулей.
  ткст[] путиИмпорта;
  /// Массив путей к макросам Ддок.
  ткст[] путиКФайлуДдок;
  ткст файлКартыРЯР = "xml_map.d"; /// Файл карты РЯР.
  ткст файлКартыГЯР = "html_map.d"; /// Фацл карты ГЯР.
  ткст форматОшибкиЛексера = "{0}({1},{2})L: {3}"; /// Ошибка лексера.
  ткст форматОшибкиПарсера = "{0}({1},{2})P: {3}"; /// Ошибка парсера.
  ткст форматОшибкиСемантики = "{0}({1},{2})S: {3}"; /// Семантическая ошибка.
  бцел ширинаТаб = 4; /// Ширина табулятора символа.
}
