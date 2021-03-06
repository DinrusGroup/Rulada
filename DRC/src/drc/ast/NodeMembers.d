/// Author: Aziz Köksal
/// License: GPL3
/// $(Maturity very high)
module drc.ast.NodeMembers;

import drc.ast.NodesEnum;

private alias ВидУзла N;

сим[] генТаблицуЧленов()
{ //pragma(сооб, "генТаблицуЧленов()");
  сим[][][] t = [];
  // t.length = г_именаКлассов.length;
  // Setting the length doesn't work in CTFs. Этот is a workaround:
  // FIXME: remove this when dmd issue #2337 has been resolved.
  for (бцел i; i < г_именаКлассов.length; i++)
    t ~= [[]];
  assert(t.length == г_именаКлассов.length);

  t[N.СложнаяДекларация] = ["деклы[]"];
  t[N.ПустаяДекларация] = t[N.НелегальнаяДекларация] =
  t[N.ДекларацияМодуля] = t[N.ДекларацияИмпорта] = [];
  t[N.ДекларацияАлиаса] = t[N.ДекларацияТипдефа] = ["декл"];
  t[N.ДекларацияПеречня] = ["типОснова?", "члены[]"];
  t[N.ДекларацияЧленаПеречня] = ["тип?", "значение?"];
  t[N.ДекларацияКласса] = t[N.ДекларацияИнтерфейса] = ["основы[]", "деклы?"];
  t[N.ДекларацияСтруктуры] = t[N.ДекларацияСоюза] = ["деклы?"];
  t[N.ДекларацияКонструктора] = ["парамы", "телоФунк"];
  t[N.ДекларацияСтатическогоКонструктора] = t[N.ДекларацияДеструктора] =
  t[N.ДекларацияСтатическогоДеструктора] = t[N.ДекларацияИнварианта] =
  t[N.ДекларацияЮниттеста] = ["телоФунк"];
  t[N.ДекларацияФункции] = ["типВозврата?", "парамы", "телоФунк"];
  t[N.ДекларацияПеременных] = ["узелТипа?", "иниты[?]"];
  t[N.ДекларацияОтладки] = t[N.ДекларацияВерсии] = ["деклы?", "деклыИначе?"];
  t[N.ДекларацияСтатическогоЕсли] = ["условие", "деклыЕсли", "деклыИначе?"];
  t[N.ДекларацияСтатическогоПодтверди] = ["условие", "сообщение?"];
  t[N.ДекларацияШаблона] = ["шпарамы", "констрейнт?", "деклы"];
  t[N.ДекларацияНов] = t[N.ДекларацияУдали] = ["парамы", "телоФунк"];
  t[N.ДекларацияЗащиты] = t[N.ДекларацияКлассаХранения] =
  t[N.ДекларацияКомпоновки] = t[N.ДекларацияРазложи] = ["деклы"];
  t[N.ДекларацияПрагмы] = ["арги[]", "деклы"];
  t[N.ДекларацияСмеси] = ["выражШаблон?", "аргумент?"];
  // Выражения:
  t[N.НелегальноеВыражение] = t[N.ВыражениеИдентификатор] =
  t[N.ВыражениеСпецСема] = t[N.ВыражениеЭтот] =
  t[N.ВыражениеСупер] = t[N.ВыражениеНуль] =
  t[N.ВыражениеДоллар] = t[N.БулевоВыражение] =
  t[N.ЦелВыражение] = t[N.ВыражениеРеал] = t[N.ВыражениеКомплекс] =
  t[N.ВыражениеСим] = t[N.ВыражениеИницПроц] =
  t[N.ВыражениеЛокальногоРазмераАсм] = t[N.ВыражениеАсмРегистр] = [];
  // БинарныеВыражения:
  t[N.ВыражениеУсловия] = ["условие", "лв", "пв"];
  t[N.ВыражениеЗапятая] = t[N.ВыражениеИлиИли] = t[N.ВыражениеИИ] =
  t[N.ВыражениеИли] = t[N.ВыражениеИИли] = t[N.ВыражениеИ] =
  t[N.ВыражениеРавно] = t[N.ВыражениеРавенство] = t[N.ВыражениеОтнош] =
  t[N.ВыражениеВхо] = t[N.ВыражениеЛСдвиг] = t[N.ВыражениеПСдвиг] =
  t[N.ВыражениеБПСдвиг] = t[N.ВыражениеПлюс] = t[N.ВыражениеМинус] =
  t[N.ВыражениеСоедини] = t[N.ВыражениеУмножь] = t[N.ВыражениеДели] =
  t[N.ВыражениеМод] = t[N.ВыражениеПрисвой] = t[N.ВыражениеПрисвойЛСдвиг] =
  t[N.ВыражениеПрисвойПСдвиг] = t[N.ВыражениеПрисвойБПСдвиг] =
  t[N.ВыражениеПрисвойИли] = t[N.ВыражениеПрисвойИ] =
  t[N.ВыражениеПрисвойПлюс] = t[N.ВыражениеПрисвойМинус] =
  t[N.ВыражениеПрисвойДел] = t[N.ВыражениеПрисвойУмн] =
  t[N.ВыражениеПрисвойМод] = t[N.ВыражениеПрисвойИИли] =
  t[N.ВыражениеПрисвойСоед] = t[N.ВыражениеТочка] = ["лв", "пв"];
  // УнарныеВыражения:
  t[N.ВыражениеАдрес] = t[N.ВыражениеПреИнкр] = t[N.ВыражениеПреДекр] =
  t[N.ВыражениеПостИнкр] = t[N.ВыражениеПостДекр] = t[N.ВыражениеДереф] =
  t[N.ВыражениеЗнак] = t[N.ВыражениеНе] = t[N.ВыражениеКомп] =
  t[N.ВыражениеВызов] = t[N.ВыражениеУдали] = t[N.ВыражениеМасштабМодуля] =
  t[N.ВыражениеТипАсм] = t[N.ВыражениеСмещениеАсм] =
  t[N.ВыражениеСегАсм] = ["в"];
  t[N.ВыражениеКаст] = ["тип", "в"];
  t[N.ВыражениеИндекс] = ["в", "арги[]"];
  t[N.ВыражениеСрез] = ["в", "левый?", "правый?"];
  t[N.ВыражениеАсмПослеСкобки] = ["в", "e2"];
  t[N.ВыражениеНов] = ["новАрги[]", "тип", "кторАрги[]"];
  t[N.ВыражениеНовАнонКласс] = ["новАрги[]", "основы[]", "кторАрги[]", "деклы"];
  t[N.ВыражениеАсмСкобка] = ["в"];
  t[N.ВыражениеЭкземплярШаблона] = ["шарги?"];
  t[N.ВыражениеЛитералМассива] = ["значения[]"];
  t[N.ВыражениеЛитералАМассива] = ["ключи[]", "значения[]"];
  t[N.ВыражениеПодтверди] = ["выр", "сооб?"];
  t[N.ВыражениеСмесь] = t[N.ВыражениеИмпорта] = ["выр"];
  t[N.ВыражениеТипа] = t[N.ВыражениеИдТипаТочка] =
  t[N.ВыражениеИдТипа] = ["тип"];
  t[N.ВыражениеЯвляется] = ["тип", "типСпец?", "шпарамы?"];
  t[N.ВыражениеЛитералФункции] = ["типВозврата?", "парамы?", "телоФунк"];
  t[N.ВыражениеРодит] = ["следщ"];//paren
  t[N.ВыражениеТрактовки] = ["шарги"];//traits
  t[N.ВыражениеИницМассива] = ["ключи[?]", "значения[]"];
  t[N.ВыражениеИницСтрукуры] = ["значения[]"];
  t[N.ТекстовоеВыражение] = [],
  // Инструкции:
  t[N.НелегальнаяИнструкция] = t[N.ПустаяИнструкция] =
  t[N.ИнструкцияДалее] = t[N.ИнструкцияВсё] =//break
  t[N.ИнструкцияАсмРасклад] = t[N.ИнструкцияНелегальныйАсм] = [];
  t[N.СложнаяИнструкция] = ["инстрции[]"];
  t[N.ИнструкцияТелаФункции] = ["телоФунк?", "телоВхо?", "телоВых?"];
  t[N.ИнструкцияМасштаб] = t[N.ИнструкцияСМеткой] = ["s"];
  t[N.ИнструкцияВыражение] = ["в"];
  t[N.ИнструкцияДекларация] = ["декл"];
  t[N.ИнструкцияЕсли] = ["переменная?", "условие?", "телоЕсли", "телоИначе?"];
  t[N.ИнструкцияПока] = ["условие", "телоПока"];
  t[N.ИнструкцияДелайПока] = ["телоДелай", "условие"];
  t[N.ИнструкцияПри] = ["иниц?", "условие?", "инкремент?", "телоПри"];//for
  t[N.ИнструкцияСКаждым] = ["парамы", "агрегат", "телоПри"];
  t[N.ИнструкцияДиапазонСКаждым] = ["парамы", "нижний", "верхний", "телоПри"];
  t[N.ИнструкцияЩит] = ["условие", "телоЩит"];
  t[N.ИнструкцияРеле] = ["значения[]", "телоРеле"];
  t[N.ИнструкцияДефолт] = ["телоДефолта"];
  t[N.ИнструкцияИтог] = ["в?"];
  t[N.ИнструкцияПереход] = ["вырРеле?"];
  t[N.ИнструкцияДля] = ["в", "телоДля"];//with
  t[N.ИнструкцияСинхр] = ["в?", "телоСинхр"];//synchronized
  t[N.ИнструкцияПробуй] = ["телоПробуй", "телаЛови[]", "телоИтожь?"];//try
  t[N.ИнструкцияЛови] = ["парам?", "телоЛови"];//catch
  t[N.ИнструкцияИтожь] = ["телоИтожь"];//finally
  t[N.ИнструкцияСтражМасштаба] = ["телоМасштаба"];
  t[N.ИнструкцияБрось] = ["в"];
  t[N.ИнструкцияЛетучее] = ["телоЛетучего?"];//volatile
  t[N.ИнструкцияБлокАсм] = ["инструкции"];
  t[N.ИнструкцияАсм] = ["операнды[]"];
  t[N.ИнструкцияПрагма] = ["арги[]", "телоПрагмы"];
  t[N.ИнструкцияСмесь] = ["выражШаблон"];
  t[N.ИнструкцияСтатическоеЕсли] = ["условие", "телоЕсли", "телоИначе?"];
  t[N.ИнструкцияСтатическоеПодтверди] = ["условие", "сообщение?"];
  t[N.ИнструкцияОтладка] = t[N.ИнструкцияВерсия] = ["телоГлавного", "телоИначе?"];
  // УзлыТипов:
  t[N.НелегальныйТип] = t[N.ИнтегральныйТип] =
  t[N.ТипМасштабаМодуля] = t[N.ТипИдентификатор] = [];
  t[N.КвалифицированныйТип] = ["лв", "пв"];
  t[N.ТипТипа] = ["в"];
  t[N.ТипЭкземплярШаблона] = ["шарги?"];
  t[N.ТипМассив] = ["следщ", "ассоцТип?", "e1?", "e2?"];
  t[N.ТипФункция] = t[N.ТипДелегат] = ["типВозврата", "парамы"];
  t[N.ТипУказателяНаФункСи] = ["следщ", "парамы?"];
  t[N.ТипУказатель] = t[N.ТипКлассОснова] =
  t[N.ТипКонст] = t[N.ТипИнвариант] = ["следщ"];
  // Параметры:
  t[N.Параметр] = ["тип?", "дефЗначение?"];
  t[N.Параметры] = t[N.ПараметрыШаблона] =
  t[N.АргументыШаблона] = ["отпрыски[]"];
  t[N.ПараметрАлиасШаблона] = t[N.ПараметрТипаШаблона] =
  t[N.ПараметрЭтотШаблона] = ["типСпец?", "дефТип?"];
  t[N.ПараметрШаблонЗначения] = ["типЗначение", "спецЗначение?", "дефЗначение?"];
  t[N.ПараметрКортежШаблона] = [];

  сим[] код = "[";
  // Iterate over the elements in the таблица and create an массив.
  foreach (m; t)
  {
    if (!m.length) {
      код ~= "[],";
      continue; // No члены, добавь "[]," and continue.
    }
    код ~= '[';
    foreach (n; m)
      код ~= `"` ~ n ~ `",`;
    код[код.length-1] = ']'; // Overwrite last comma.
    код ~= ',';
  }
  код[код.length-1] = ']'; // Overwrite last comma.
  return код;
}

/// A таблица listing the subnodes of all classes inheriting из Узел.
static const сим[][][/+ВидУзла.max+1+/] г_таблицаЧленов = mixin(генТаблицуЧленов());

/// A helper function that parses the special тксты in г_таблицаЧленов.
///
/// Basic syntax:
/// $(PRE
/// Member := Array | Array2 | OptionalNode | Узел | Code
/// Array := Идентификатор "[]"
/// Array2 := Идентификатор "[?]"
/// OptionalNode := Идентификатор "?"
/// Узел := Идентификатор
/// Code := "%" AnyChar*
/// $(MODLINK2 drc.lexer.Identifier, Идентификатор)
/// )
/// Параметры:
///   члены = the член тксты в be parsed.
/// Возвращает:
///   an массив of tuples (Name, Тип) where Name is the exact имя of the член
///   and Тип may be one of these значения: "[]", "[?]", "?", "" or "%".
сим[][2][] разборЧленов(сим[][] члены)
{
  сим[][2][] результат;
  foreach (член; члены)
    if (член.length > 2 && член[$-2..$] == "[]")
      результат ~= [член[0..$-2], "[]"]; // Strip off trailing '[]'.
    else if (член.length > 3 && член[$-3..$] == "[?]")
      результат ~= [член[0..$-3], "[?]"]; // Strip off trailing '[?]'.
    else if (член[$-1] == '?')
      результат ~= [член[0..$-1], "?"]; // Strip off trailing '?'.
    else if (член[0] == '%')
      результат ~= [член[1..$], "%"]; // Strip off preceding '%'.
    else
      результат ~= [член, ""]; // Nothing в тктip off.
  return результат;
}
