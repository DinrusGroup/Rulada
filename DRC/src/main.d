/// Author: Aziz Köksal
/// License: GPL3
/// $(Maturity average)
module main;

import drc.parser.Parser;
import drc.lexer.Lexer,
       drc.lexer.Token;
import drc.ast.Declarations,
       drc.ast.Expressions,
       drc.ast.Node,
        drc.ast.Visitor;
import drc.semantic.Module,
       drc.semantic.Symbols,
       drc.semantic.Pass1,
       drc.semantic.Pass2,
       drc.semantic.Passes;
import drc.code.Interpreter;
import drc.translator.German;
import drc.Messages;
import drc.CompilerInfo;
import drc.Diagnostics;
import drc.SourceText;
import drc.Compilation;

import cmd.Compile;
import cmd.Highlight;
import cmd.Statistics;
import cmd.ImportGraph;
import cmd.DDoc;

import Settings;
import SettingsLoader;
import common;

import Integer = tango.text.convert.Integer;
import tango.stdc.stdio;
import tango.io.File;
import tango.text.Util;
import tango.time.StopWatch;
import tango.text.Ascii : icompare;

/// Функция входа в drc.
проц  main(сим[][] арги)
{
  auto диаг = new Диагностика();
  ЗагрузчикКонфиг(диаг).загрузи();
  if (диаг.естьИнфо_ли)
    return выведиОшибки(диаг);

  if (арги.length <= 1)
    return выведиСправку("глав");

  ткст команда = арги[1];
  switch (команда)
  {
  case "к", "компилируй", "c", "compile":
    if (арги.length < 3)
      return выведиСправку(команда);

    КомандаКомпилировать кмд;
    кмд.контекст = новКонтекстКомпиляции();
    кмд.диаг = диаг;

    foreach (арг; арги[2..$])
    {
      if (разборОтладкаИлиВерсия(арг, кмд.контекст))
      {}
      else if (ткстнач(арг, "-S"))
        кмд.контекст.путиИмпорта ~= арг[2..$];
      else if (арг == "-выпуск"||"-release")
        кмд.контекст.постройкаРелиз = да;
      else if (арг == "-тест"||"-unittest")
      {
      version(D2)
        кмд.контекст.добавьИдВерсии("unittest");
        кмд.контекст.постройкаТест = да;
      }
      else if (арг == "-о")
        кмд.контекст.приниматьДеприкированное = да;
      else if (арг == "-пс")
        кмд.вывестиДеревоСимволов_ли = да;
      else if (арг == "-пм")
        кмд.вывестиДеревоМодулей_ли = да;
      else
        кмд.путиКФайлам ~= арг;
    }
    кмд.пуск();
    диаг.естьИнфо_ли && выведиОшибки(диаг);
    break;
  case "ддок", "д", "ddoc", "d":
    if (арги.length < 4)
      return выведиСправку(команда);

    КомандаДДок кмд;
    кмд.путьКПапкеНазн = арги[2];
    кмд.макроПути = ГлобальныеНастройки.путиКФайлуДдок;
    кмд.контекст = новКонтекстКомпиляции();
    кмд.диаг = диаг;

    // Parse arguments.
    foreach (арг; арги[3..$])
    {
      if (разборОтладкаИлиВерсия(арг, кмд.контекст))
      {}
      else if (арг == "--ряр"||"--xml")
        кмд.писатьРЯР = да;
      else if (арг == "-и"||"-i")
        кмд.включатьНедокументированное = да;
      else if (арг == "-в"|| "-v")
        кмд.подробно = да;
      else if (арг.length > 3 && ткстнач(арг, "-м=")||ткстнач(арг, "-m="))
        кмд.ПутьТкстаМод = арг[3..$];
      else if (арг.length > 5 && icompare(арг[$-4..$], "ддок") == 0||icompare(арг[$-4..$], "ddoc") == 0)
        кмд.макроПути ~= арг;
      else
        кмд.путиКФайлам ~= арг;
    }
    кмд.пуск();
    диаг.естьИнфо_ли && выведиОшибки(диаг);
    break;
  case "псв", "подсвети":
    if (арги.length < 3)
      return выведиСправку(команда);

    КомандаВыделить кмд;
    кмд.диаг = диаг;

    foreach (арг; арги[2..$])
    {
      switch (арг)
      {
      case "--синтаксис":
        кмд.добавь(КомандаВыделить.Опция.Синтаксис); break;
      case "-ряр","-xml":
        кмд.добавь(КомандаВыделить.Опция.РЯР); break;
      case "-гяр","-html":
        кмд.добавь(КомандаВыделить.Опция.ГЯР); break;
      case "-строки":
        кмд.добавь(КомандаВыделить.Опция.ВыводСтрок); break;
      default:
        кмд.путьКФайлу = арг;
      }
    }
    кмд.пуск();
    диаг.естьИнфо_ли && выведиОшибки(диаг);
    break;
  case "графимпорта", "гимп":
    if (арги.length < 3)
      return выведиСправку(команда);

    ИКомандаГрафа кмд;
    кмд.контекст = новКонтекстКомпиляции();

    foreach (арг; арги[2..$])
    {
      if (разборОтладкаИлиВерсия(арг, кмд.контекст))
      {}
      else if (ткстнач(арг, "-S"))
        кмд.контекст.путиИмпорта ~= арг[2..$];
      else if(ткстнач(арг, "-х"))
        кмд.регвыры ~= арг[2..$];
      else if(ткстнач(арг, "-у"))
        кмд.уровни = Integer.toInt(арг[2..$]);
      else if(ткстнач(арг, "-си"))
        кмд.siStyle = арг[3..$];
      else if(ткстнач(арг, "-пи"))
        кмд.piStyle = арг[3..$];
      else
        switch (арг)
        {
        case "--дот", "--dot":
          кмд.добавь(ИКомандаГрафа.Опция.ВыводитьДот); break;
        case "--пути", "--paths":
          кмд.добавь(ИКомандаГрафа.Опция.ВывестиПути); break;
        case "--список", "--list":
          кмд.добавь(ИКомандаГрафа.Опция.ВывестиСписок); break;
        case "-и", "-i":
          кмд.добавь(ИКомандаГрафа.Опция.ВключатьНеопределённыеМодули); break;
        case "-псвкр", "-hle":
          кмд.добавь(ИКомандаГрафа.Опция.ВыделитьЦиклическиеКрая); break;
        case "-псввер":
          кмд.добавь(ИКомандаГрафа.Опция.ВыделитьЦиклическиеВершины); break;
        case "-гнп":
          кмд.добавь(ИКомандаГрафа.Опция.ГруппироватьПоИменамПакетов); break;
        case "--гпнп":
          кмд.добавь(ИКомандаГрафа.Опция.ГруппироватьПоПолномуИмениПакета); break;
        case "-м":
          кмд.добавь(ИКомандаГрафа.Опция.ПометитьЦиклическиеМодули); break;
        default:
          кмд.путьКФайлу = арг;
        }
    }
    кмд.пуск();
    break;
  case "стат", "статистика", "stats":
    if (арги.length < 3)
      return выведиСправку(команда);

    КомандаСтат кмд;
    foreach (арг; арги[2..$])
      if (арг == "--семтабл")
        кмд.выводитьТаблицуТокенов = да;
      else if (арг == "--адстабл")
        кмд.выводитьТаблицуУзлов = да;
      else
        кмд.путиКФайлам ~= арг;
    кмд.пуск();
    break;
  case "сем", "семанализ":
    if (арги.length < 3)
      return выведиСправку(команда);
    ИсходныйТекст исходныйТекст;
    сим[] путьКФайлу;
    сим[] разделитель;
    бул ignoreWSToks;
    бул printWS;

    foreach (арг; арги[2..$])
    {
      if (ткстнач(арг, "-к"))
        разделитель = арг[2..$];
      else if (арг == "-")
        исходныйТекст = new ИсходныйТекст("stdin", читайСтдвхо());
      else if (арг == "-и")
        ignoreWSToks = да;
      else if (арг == "-дс")
        printWS = да;
      else
        путьКФайлу = арг;
    }

    разделитель || (разделитель = "\n");
    if (!исходныйТекст)
      исходныйТекст = new ИсходныйТекст(путьКФайлу, да);

    диаг = new Диагностика();
    auto lx = new Лексер(исходныйТекст, диаг);
    lx.сканируйВсе();
    auto сема = lx.перваяСема();

    for (; сема.вид != TOK.КФ; сема = сема.следщ)
    {
      if (сема.вид == TOK.Новстр || ignoreWSToks && сема.пробел_ли)
        continue;
      if (printWS && сема.пп)
        выдай(сема.пробСимволы);
      выдай(сема.исхТекст)(разделитель);
    }

    диаг.естьИнфо_ли && выведиОшибки(диаг);
    break;
  case "пер", "переведи":
    if (арги.length < 3)
      return выведиСправку(команда);

    if (арги[2] != "Немецкий")
      return выдай.formatln("Ошибка: нераспознаный целевой язык перевода \"{}\"", арги[2]);

    диаг = new Диагностика();
    auto путьКФайлу = арги[3];
    auto мод = new Модуль(путьКФайлу, диаг);
    // Parse the file.
    мод.разбор();
    if (!мод.естьОшибки)
    { // Translate
      auto german = new НемецкийПереводчик(выдай, "  ");
      german.переведи(мод.корень);
    }
    выведиОшибки(диаг);
    break;
  case "профиль", "profile":
    if (арги.length < 3)
      break;
    сим[][] путиКФайлам;
    if (арги[2] == "дстресс"||"dstress")
    {
      auto текст = cast(сим[])(new File("dstress_files")).read();
      путиКФайлам = split(текст, "\0");
    }
    else
      путиКФайлам = арги[2..$];

    StopWatch swatch;
    swatch.start;

    foreach (путьКФайлу; путиКФайлам)
      (new Лексер(new ИсходныйТекст(путьКФайлу, да))).сканируйВсе();

    выдай.formatln("Сканирован за {:f10}с.", swatch.stop);
    break;
  case "с", "справка", "help", "/?":
    выведиСправку(арги.length >= 3 ? арги[2] : "");
    break;
  default:
    выведиСправку("глав");
  }
}

/// Reads the standard input and returns its contents.
сим[] читайСтдвхо()
{
  сим[] текст;
  while (1)
  {
    auto c = getc(stdin);
    if (c == EOF)
      break;
    текст ~= c;
  }
  return текст;
}

/// Доступные команды.
const ткст КОМАНДЫ =
"справка,с   (h, /?, help) \n"
"  компиляция,к     (c,compile)   \n"
"  ддок, д          (d, ddoc)     \n"
"  подсвет,псв       ()           \n"
"  графимпорта,ги   ()           \n"
"  статистика,стат  (stat)        \n"
"  семанализ,сем   (sem)         \n"
"  перевод, п       (t, translate)\n";

бул ткстнач(сим[] ткт, сим[] начало)
{
  if (ткт.length >= начало.length)
  {
    if (ткт[0 .. начало.length] == начало)
      return да;
  }
  return нет;
}

/// Creates the global compilation контекст.
КонтекстКомпиляции новКонтекстКомпиляции()
{
  auto кк = new КонтекстКомпиляции;
  кк.путиИмпорта = ГлобальныеНастройки.путиИмпорта;
  кк.добавьИдВерсии("дирк");
  кк.добавьИдВерсии("все");
version(D2)
  кк.добавьИдВерсии("D_Version2");
  foreach (идВерсии; ГлобальныеНастройки.идыВерсий)
    if (Лексер.действитНерезИдентификатор_ли(идВерсии))
      кк.добавьИдВерсии(идВерсии);
  return кк;
}

/// Parses a отладка or версия команда line option.
бул разборОтладкаИлиВерсия(ткст арг, КонтекстКомпиляции контекст)
{
  if (ткстнач(арг, "-отладка")||ткстнач(арг, "-debug"))
  {
    if (арг.length > 7)
    {
      auto знач = арг[7..$];
      if (цифра_ли(знач[0]))
        контекст.уровеньОтладки = Integer.toInt(знач);
      else if (Лексер.действитНерезИдентификатор_ли(знач))
        контекст.добавьИдОтладки(знач);
    }
    else
      контекст.уровеньОтладки = 1;
  }
  else if (арг.length > 9 && ткстнач(арг, "-версия=")||ткстнач(арг, "-version="))
  {
    auto знач = арг[9..$];
    if (цифра_ли(знач[0]))
      контекст.уровеньВерсии = Integer.toInt(знач);
    else if (Лексер.действитНерезИдентификатор_ли(знач))
      контекст.добавьИдВерсии(знач);
  }
  else
    return нет;
  return да;
}

/// Prints the ошибки collected in диаг.
проц  выведиОшибки(Диагностика диаг)
{
  foreach (инфо; диаг.инфо)
  {
    сим[] форматОшибки;
    if (инфо.classinfo is ОшибкаЛексера.classinfo)
      форматОшибки = ГлобальныеНастройки.форматОшибкиЛексера;
    else if (инфо.classinfo is ОшибкаПарсера.classinfo)
      форматОшибки = ГлобальныеНастройки.форматОшибкиПарсера;
    else if (инфо.classinfo is ОшибкаСемантики.classinfo)
      форматОшибки = ГлобальныеНастройки.форматОшибкиСемантики;
    else if (инфо.classinfo is Предупреждение.classinfo)
      форматОшибки = "{0}: Предупреждение: {3}";
    else if (инфо.classinfo is drc.Information.Ошибка.classinfo)
      форматОшибки = "Ошибка: {3}";
    else
      continue;
    auto ош = cast(Проблема)инфо;
    Stderr.formatln(форматОшибки, ош.путьКФайлу, ош.место, ош.столб, ош.дайСооб);
  }
}

/// Prints the справка сообщение of a команда.
/// Если the команда wasn't found, the main справка сообщение is printed.
проц  выведиСправку(сим[] команда)
{
  сим[] сооб;
  switch (команда)
  {
  case "к", "компиляция", "c", "compile":
    сооб = `Компилировать исходники на Ди.
Использование:
  дирк компилируй файл.d [файл2.d, ...] [Опции]

  Эта команда только парсирует исходники и выполняет небольший семантический анализ.
  Ошибки выводятся на стандартный вывод для ошибок.

Опции:
  -депр             : принимать деприкированный код
  -отладка          : включать код отладки
  -отладка=уровень  : включать код отладка(у), где у <= уровень
  -отладка=идент    : включать код отладка(идент)
  -версия=уровень   : включать код версия(у), где у >= уровень
  -версия=идент     : включать код версия(идент)
  -Ипуть            : добавить 'путь' в список путей импорта
  -релиз       	: компилировать постройку-релиз
  -тест        		: компилировать постройку-тест
  -32               : произвести 32-битный код (дефолт)
  -64               : произвести 64-битный код
  -ofПРОГ           : вывести программу в ПРОГ

  -ps               : вывести древо символов модуля
  -pm               : вывести древо пакетов/модулей

Пример:
  дирк к ист/main.d -Иист/`;
    break;
  case "ддок", "д", "ddoc","d":
    сооб = `Генерировать документацию из комментариев DDoc в исходниках D.
Использование:
  дирк ддок Приёмник файл.d [файл2.d, ...] [Опции]

  Приёмник - это папка, в которую записываются файлы документации.
  Файлы с расширением .ddoc распознаются как файлы с определением макросов.

Опции:
  --ряр            : записать документы РЯР(XML), а не ГЯР(HTML)
  -и               : включить недокументированные символы
  -в               : многословный вывод
  -м=ПУТЬ          : записать список обработанных модулей в ПУТЬ(PATH)

Пример:
  дирк д doc/ ист/main.d ист/macros_drc.ddoc -и -м=doc/модули.txt`;
    break;
  case "псв", "подсвет":
//     сооб = ДайСооб(ИДС.HelpGenerate);
    сооб = `Подсветить исходный файл Ди с тегами РЯР или ГЯР.
Использование:
  дирк псв файл.d [Опции]

Опции:
  --синтаксис     : генерировать теги для синтактического дерева
  --ряр           : использовать формат РЯР(XML) (дефолт)
  --гяр           : использовать формат ГЯР(HTML)
  --строки        : выводить номера строк

Пример:
  дирк псв ист/main.d --гяр --синтаксис > main.html`;
    break;
  case "графимпорта", "ги":
//     сооб = ДайСооб(ИДС.HelpImportGraph);
    сооб = `Разобрать модуль и построить граф зависимостей, основанный на его импортах.
Использование:
  дирк гимп файл.d Формат [Опции]

  Папка файл.d негласно добавляется в список путей импорта.

Формат:
  --дот            : генерировать документ dot (дефолт)
  Опции, относящиеся к --дот:
  -гнп             : Группировать модули по названию пакета
  --гпнп           : Группировать модули по полному названию пакета
  -псвкр           : подсветить циклические края в графе
  -псввер          : подсветить модули в цикличиских связях
  -сиСТИЛЬ         : стиль края, используемый для статических импортов
  -пиСТИЛЬ         : стиль края, используемый для публичных импортов
  СТИЛЬ может быть: "dashed", "dotted", "solid", "invis" или "bold"

  --пути           : вывести пути к файлам модулей в графе

  --список         : вывести имена модулей в граф
  Опции, общие для --пути и --список:
  -уN              : вывести N уровней.
  -м               : использовать '*' для пометки модулей с циклическими взаимосвязями

Опции:
  -Ипуть           : добавить 'путь' в список путей импорта, по которым будут
                     искаться модули
  -хРЕГВЫР         : исключить модули, имена которых совпадают с регулярным выражением
                     РЕГВЫР
  -и               : включить нелоцируемые модули

Пример:
  дирк гимп ист/main.d --список
  дирк гимп ист/main.d | dot -Tpng > main.png`;
    break;
  case "сем", "семанализ":
    сооб = `Вывести семы исходного файла Ди.
Использование:
  дирк сем файл.d [Опции]

Опции:
  -               : читать текст со стандартного ввода.
  -рРАЗДЕЛИТЕЛЬ   : выводить РАЗДЕЛИТЕЛЬ вместо новой строки между семами.
  -и              : игнорировать пробельные символы (т.е. коментарии, шебанг и т.д.)
  -п             : выводить предшествующие пробельные символы.

Пример:
  echo "module foo; проц  func(){}" | дирк лекс -
  дирк лекс ист/main.d | grep ^[0-9]`;
    break;
  case "стат", "статистика":
    сооб = "Собрать статистику об исходных файлах Ди.
Использование:
  дирк стат файл.d [файл2.d, ...] [Опции]

Опции:
  --табток      : вывести число всех видов лексем в таблице.
  --табаст      : вывести число всех видов узлов в таблице.

Пример:
  дирк стат src/main.d src/drc/Unicode.d";
    break;
  case "п", "переведи":
    сооб = `Перевести исходник Ди  на другой язык.
Использование:
  дирк переведи Язык файл.d

  Поддерживаемые языки:
    *) Немецкий

Пример:
  дирк пер Немецкий src/main.d`;
    break;
  case "глав":
  default:
    auto COMPILED_WITH = __VENDOR__;
    auto COMPILED_VERSION = Формат("{}.{,:d3}", __VERSION__/1000, __VERSION__%1000);
    auto COMPILED_DATE = __TIMESTAMP__;
    сооб = ФорматируйСооб(ИДС.HelpMain, ВЕРСИЯ, КОМАНДЫ, COMPILED_WITH,
                    COMPILED_VERSION, COMPILED_DATE);
  }
  выдай(сооб).nl;
}