/// Author: Aziz Köksal
/// License: GPL3
/// $(Maturity high)
module cmd.DDoc;

import cmd.DDocEmitter,
       cmd.DDocHTML,
       cmd.DDocXML,
       cmd.Highlight;
import drc.doc.Parser,
       drc.doc.Macro,
       drc.doc.Doc;
import drc.lexer.Token,
       drc.lexer.Funcs;
import drc.semantic.Module,
       drc.semantic.Pass1,
       drc.semantic.Symbol,
       drc.semantic.Symbols;
import drc.Compilation;
import drc.Diagnostics;
import drc.Converter;
import drc.SourceText;
import drc.Enums;
import drc.Time;
import common;

import tango.text.Ascii : toUpper;
import tango.io.File;
import tango.io.FilePath;

/// ddoc команда.
struct КомандаДДок
{
  ткст путьКПапкеНазн;  /// Папка назначения.
  ткст[] макроПути; /// Пути к файлам макросов.
  ткст[] путиКФайлам;  /// Пути к файлам модулей.
  ткст ПутьТкстаМод;  /// Записать в этот файл (если он указан) список модулей.
  ткст расшВыводимогоФайла;  /// Расширение выводимых файлов.
  бул включатьНедокументированное; /// Включать ли недокументированные символы.
  бул писатьРЯР; /// Писать ли РЯР вместо документов на ГЯР.
  бул подробно;  /// Многословность.

  КонтекстКомпиляции контекст; /// Переменные среды компиляции.
  Диагностика диаг;        /// Собрать сообщения об ошибках.
  ПодсветчикСем псвСем;   /// Для подсвечивания сем секций кода DDoc.

  /// Выполняет команду генерации документации.
  проц  пуск()
  {
    // Parse macro files and build macro таблица hierarchy.
    ТаблицаМакросов мтаблица;
    ПарсерМакросов мпарсер;
    foreach (макроПуть; макроПути)
    {
      auto макрос = мпарсер.разбор(загрузиФайлМакросов(макроПуть, диаг));
      мтаблица = new ТаблицаМакросов(мтаблица);
      мтаблица.вставь(макрос);
    }

    // При DDoc код резделы.
    псвСем = new ПодсветчикСем(диаг, писатьРЯР == нет);
    расшВыводимогоФайла = писатьРЯР ? ".xml" : ".html";

    ткст[][] modFQNs; // List of tuples (путьКФайлу, пкиМодуля).
    бул генерироватьТекстФайлыМодулей = ПутьТкстаМод !is null;

    // Process D files.
    foreach (путьКФайлу; путиКФайлам)
    {
      auto мод = new Модуль(путьКФайлу, диаг);

      // Only разбор if the file is not a "DDoc"-file.
      if (!ЭмиттерДДок.isDDocFile(мод))
      {
        мод.разбор();
        // No documentation for erroneous source files.
        if (мод.естьОшибки)
          continue;
        // Start semantic analysis.
        auto проходка1 = new СемантическаяПроходка1(мод, контекст);
        проходка1.пуск();

        if (генерироватьТекстФайлыМодулей)
          modFQNs ~= [путьКФайлу, мод.дайПКН()];
      }
      else // Normally done in мод.разбор().
        мод.установиПКН((new FilePath(путьКФайлу)).name());

      // Write the documentation file.
     пишиФайлДокументации(мод, мтаблица);
    }

    if (генерироватьТекстФайлыМодулей)
      пишиТекстФайлМодулей(modFQNs);
  }

  /// Записывает документацию к модулю на диск.
  /// Параметры:
  ///   мод = обрабатываемый модуль.
  ///   мтаблица = главная среда макросов.
  проц  пишиФайлДокументации(Модуль мод, ТаблицаМакросов мтаблица)
  {
    // Create an own macro environment for this module.
    мтаблица = new ТаблицаМакросов(мтаблица);
    // Define runtime макрос.
    auto modFQN = мод.дайПКН();
    мтаблица.вставь("DIL_MODPATH", мод.дайПутьПКН() ~ "." ~ мод.расширениеФайла());
    мтаблица.вставь("DIL_MODFQN", modFQN);
    мтаблица.вставь("DIL_DOCFILENAME", modFQN ~ расшВыводимогоФайла);
    мтаблица.вставь("TITLE", modFQN);
    auto ткстВрем = Время.вТкст();
    мтаблица.вставь("DATETIME", ткстВрем);
    мтаблица.вставь("YEAR", Время.год(ткстВрем));

    // Create the appropriate ЭмиттерДДок.
    ЭмиттерДДок эмиттерДДок;
    if (писатьРЯР)
      эмиттерДДок = new РЯРЭмиттерДДок(мод, мтаблица, включатьНедокументированное, псвСем);
    else
      эмиттерДДок = new ГЯРЭмиттерДДок(мод, мтаблица, включатьНедокументированное, псвСем);
    // Start the emitter.
    auto ddocText = эмиттерДДок.выдать();
    // Set the BODY macro в the текст produced by the emitter.
    мтаблица.вставь("BODY", ddocText);
    // Делай the macro expansion pass.
    auto текстФайла = РаскрывательМакросов.раскрой(мтаблица, "$(DDOC)",
                                         мод.путьКФайлу,
                                         подробно ? диаг : null);
    // debug текстФайла ~= "\n<pre>\n" ~ doc.текст ~ "\n</pre>";

    // Build destination file путь.
    auto путьНазнач = new FilePath(путьКПапкеНазн);
    путьНазнач.append(мод.дайПКН() ~ расшВыводимогоФайла);
    // Verbose output of activity.
    if (подробно) // TODO: create a setting for this format ткст in dilconf.d?
      выдай.formatln("ддок {} > {}", мод.путьКФайлу, путьНазнач);
    // Finally пиши the file out в the harddisk.
    scope file = new File(путьНазнач.вТкст());
    file.write(текстФайла);
  }

  /// Записываен на диск список обработанных модулей.
  /// Параметры:
  ///   списокМодулей = список модулей.
  проц   пишиТекстФайлМодулей(ткст[][] списокМодулей)
  {
    сим[] текст;
    foreach (мод; списокМодулей)
      текст ~= мод[0] ~ ", " ~ мод[1] ~ \n;
    scope file = new File(ПутьТкстаМод);
    file.write(текст);
  }

  /// Загружает файл макросов. Преобразует любую кодировку Unicode в UTF-8.
  /// Параметры:
  ///   путьКФайлу = путь к файлу макросов.
  ///   диаг  = для сообщений об ошибках.
  static ткст загрузиФайлМакросов(ткст путьКФайлу, Диагностика диаг)
  {
    auto ист = new ИсходныйТекст(путьКФайлу);
    ист.загрузи(диаг);
    auto текст = ист.данные[0..$-1]; // Exclude '\0'.
    return обеззаразьТекст(текст);
  }
}
