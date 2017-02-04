/// Author: Aziz Köksal
/// License: GPL3
/// $(Maturity high)
module drc.ast.Declarations;

public import drc.ast.Declaration;
import drc.ast.Node,
       drc.ast.Expression,
       drc.ast.Types,
       drc.ast.Statements,
       drc.ast.Parameters,
       drc.ast.NodeCopier;
import drc.lexer.IdTable;
import drc.semantic.Symbols;
import drc.Enums;
import common;

class СложнаяДекларация : Декларация
{
  this()
  {
    естьТело = да;
    mixin(установить_вид);
  }

  проц  opCatAssign(Декларация d)
  {
    добавьОтпрыск(d);
  }

  проц  opCatAssign(СложнаяДекларация ds)
  {
    добавьОтпрыски(ds.отпрыски);
  }

  Декларация[] деклы()
  {
    return cast(Декларация[])this.отпрыски;
  }

  проц  деклы(Декларация[] деклы)
  {
    this.отпрыски = деклы;
  }

  mixin(методКопирования);
}

/// Единичная точка с запятой.
class ПустаяДекларация : Декларация
{
  this()
  {
    mixin(установить_вид);
  }
  mixin(методКопирования);
}

/// Нелегальным декларациям соответствуют все семы,
/// которые не начинают ДефиницияДекларации.
/// See_Also: drc.lexer.Token.семаНачалаДеклДеф_ли()
class НелегальнаяДекларация : Декларация
{
  this()
  {
    mixin(установить_вид);
  }
  mixin(методКопирования);
}

/// ПКИ = полностью "квалифицированное" имя
alias Идентификатор*[] ПКИМодуля; // Идентификатор(.Идентификатор)*

class ДекларацияМодуля : Декларация
{
  Идентификатор* имяМодуля;
  Идентификатор*[] пакеты;
  this(ПКИМодуля пкиМодуля)
  {
    mixin(установить_вид);
    assert(пкиМодуля.length != 0);
    this.имяМодуля = пкиМодуля[$-1];
    this.пакеты = пкиМодуля[0..$-1];
  }

  сим[] дайПКН()
  {
    auto имяп = дайИмяПакета('.');
    if (имяп.length)
      return имяп ~ "." ~ дайИмя();
    else
      return дайИмя();
  }

  сим[] дайИмя()
  {
    if (имяМодуля)
      return имяМодуля.ткт;
    return null;
  }

  сим[] дайИмяПакета(сим разделитель)
  {
    сим[] имяп;
    foreach (пкт; пакеты)
      if (пкт)
        имяп ~= пкт.ткт ~ разделитель;
    if (имяп.length)
      имяп = имяп[0..$-1]; // Удалить последний разделитель
    return имяп;
  }

  mixin(методКопирования);
}

class ДекларацияИмпорта : Декларация
{
  private alias Идентификатор*[] Иды;
  ПКИМодуля[] пкиМодулей;
  Иды алиасыМодуля;
  Иды связанныеИмена;
  Иды связанныеАлиасы;

  this(ПКИМодуля[] пкиМодулей, Иды алиасыМодуля, Иды связанныеИмена, Иды связанныеАлиасы, бул статический_ли)
  {
    mixin(установить_вид);
    this.пкиМодулей = пкиМодулей;
    this.алиасыМодуля = алиасыМодуля;
    this.связанныеИмена = связанныеИмена;
    this.связанныеАлиасы = связанныеАлиасы;
    if (статический_ли)
      this.кхр |= КлассХранения.Статический;
  }

  сим[][] дайПКНМодуля(сим разделитель)
  {
    сим[][] ПКИм_ч;
    foreach (пкиМодуля; пкиМодулей)
    {
      сим[] ПКИ;
      foreach (идент; пкиМодуля)
        if (идент)
          ПКИ ~= идент.ткт ~ разделитель;
      ПКИм_ч ~= ПКИ[0..$-1]; // Удалить последний разделитель
    }
    return ПКИм_ч;
  }

  mixin(методКопирования);
}

class ДекларацияАлиаса : Декларация
{
  Декларация декл;
  this(Декларация декл)
  {
    mixin(установить_вид);
    добавьОтпрыск(декл);
    this.декл = декл;
  }
  mixin(методКопирования);
}

class ДекларацияТипдефа : Декларация
{
  Декларация декл;
  this(Декларация декл)
  {
    mixin(установить_вид);
    добавьОтпрыск(декл);
    this.декл = декл;
  }
  mixin(методКопирования);
}

class ДекларацияПеречня : Декларация
{
  Идентификатор* имя;
  УзелТипа типОснова;
  ДекларацияЧленаПеречня[] члены;
  this(Идентификатор* имя, УзелТипа типОснова, ДекларацияЧленаПеречня[] члены, бул естьТело)
  {
    super.естьТело = естьТело;
    mixin(установить_вид);
    добавьОпцОтпрыск(типОснова);
    добавьОпцОтпрыски(члены);

    this.имя = имя;
    this.типОснова = типОснова;
    this.члены = члены;
  }

  Перечень символ;

  mixin(методКопирования);
}

class ДекларацияЧленаПеречня : Декларация
{
  УзелТипа тип; // D 2.0
  Идентификатор* имя;
  Выражение значение;
  this(Идентификатор* имя, Выражение значение)
  {
    mixin(установить_вид);
    добавьОпцОтпрыск(значение);

    this.имя = имя;
    this.значение = значение;
  }

  // D 2.0
  this(УзелТипа тип, Идентификатор* имя, Выражение значение)
  {
    добавьОпцОтпрыск(тип);
    this.тип = тип;
    this(имя, значение);
  }

  ЧленПеречня символ;

  mixin(методКопирования);
}

class ДекларацияШаблона : Декларация
{
  Идентификатор* имя;
  ПараметрыШаблона шпарамы;
  Выражение констрейнт; // D 2.0
  СложнаяДекларация деклы;
  this(Идентификатор* имя, ПараметрыШаблона шпарамы, Выражение констрейнт, СложнаяДекларация деклы)
  {
    super.естьТело = да;
    mixin(установить_вид);
    добавьОтпрыск(шпарамы);
    добавьОпцОтпрыск(констрейнт);
    добавьОтпрыск(деклы);

    this.имя = имя;
    this.шпарамы = шпарамы;
    this.констрейнт = констрейнт;
    this.деклы = деклы;
  }

  Шаблон символ; /// Шаблонный символ для данной декларации.

  mixin(методКопирования);
}

// Примечание: шпарамы закомментированы, поскольку Парсер
//      оборачивает декларации шаблонными параметрами внутри ДекларацииШаблона.
//       

abstract class ДекларацияАгрегата : Декларация
{
  Идентификатор* имя;
//   ПараметрыШаблона шпарамы;
  СложнаяДекларация деклы;
  this(Идентификатор* имя, /+ПараметрыШаблона шпарамы, +/СложнаяДекларация деклы)
  {
    super.естьТело = деклы !is null;
    this.имя = имя;
//     this.шпарамы = шпарамы;
    this.деклы = деклы;
  }
}

class ДекларацияКласса : ДекларацияАгрегата
{
  ТипКлассОснова[] основы;
  this(Идентификатор* имя, /+ПараметрыШаблона шпарамы, +/ТипКлассОснова[] основы, СложнаяДекларация деклы)
  {
    super(имя, /+шпарамы, +/деклы);
    mixin(установить_вид);
//     добавьОтпрыск(шпарамы);
    добавьОпцОтпрыски(основы);
    добавьОпцОтпрыск(деклы);

    this.основы = основы;
  }

  Класс символ; /// Символ класса данной декларации.

  mixin(методКопирования);
}

class ДекларацияИнтерфейса : ДекларацияАгрегата
{
  ТипКлассОснова[] основы;
  this(Идентификатор* имя, /+ПараметрыШаблона шпарамы, +/ТипКлассОснова[] основы, СложнаяДекларация деклы)
  {
    super(имя, /+шпарамы, +/деклы);
    mixin(установить_вид);
//     добавьОтпрыск(шпарамы);
    добавьОпцОтпрыски(основы);
    добавьОпцОтпрыск(деклы);

    this.основы = основы;
  }

  alias drc.semantic.Symbols.Интерфейс Интерфейс;

  Интерфейс символ; /// Символ интерфейса данной декларации.

  mixin(методКопирования);
}

class ДекларацияСтруктуры : ДекларацияАгрегата
{
  бцел размерРаскладки;
  this(Идентификатор* имя, /+ПараметрыШаблона шпарамы, +/СложнаяДекларация деклы)
  {
    super(имя, /+шпарамы, +/деклы);
    mixin(установить_вид);
//     добавьОтпрыск(шпарамы);
    добавьОпцОтпрыск(деклы);
  }

  проц  установиРазмерРаскладки(бцел размерРаскладки)
  {
    this.размерРаскладки = размерРаскладки;
  }

  Структура символ; /// Символ структуры данной декларации.

  mixin(методКопирования);
}

class ДекларацияСоюза : ДекларацияАгрегата
{
  this(Идентификатор* имя, /+ПараметрыШаблона шпарамы, +/СложнаяДекларация деклы)
  {
    super(имя, /+шпарамы, +/деклы);
    mixin(установить_вид);
//     добавьОтпрыск(шпарамы);
    добавьОпцОтпрыск(деклы);
  }

  Союз символ; /// Символ союза данной декларации.

  mixin(методКопирования);
}

class ДекларацияКонструктора : Декларация
{
  Параметры парамы;
  ИнструкцияТелаФункции телоФунк;
  this(Параметры парамы, ИнструкцияТелаФункции телоФунк)
  {
    super.естьТело = да;
    mixin(установить_вид);
    добавьОтпрыск(парамы);
    добавьОтпрыск(телоФунк);

    this.парамы = парамы;
    this.телоФунк = телоФунк;
  }
  mixin(методКопирования);
}

class ДекларацияСтатическогоКонструктора : Декларация
{
  ИнструкцияТелаФункции телоФунк;
  this(ИнструкцияТелаФункции телоФунк)
  {
    super.естьТело = да;
    mixin(установить_вид);
    добавьОтпрыск(телоФунк);

    this.телоФунк = телоФунк;
  }
  mixin(методКопирования);
}

class ДекларацияДеструктора : Декларация
{
  ИнструкцияТелаФункции телоФунк;
  this(ИнструкцияТелаФункции телоФунк)
  {
    super.естьТело = да;
    mixin(установить_вид);
    добавьОтпрыск(телоФунк);

    this.телоФунк = телоФунк;
  }
  mixin(методКопирования);
}

class ДекларацияСтатическогоДеструктора : Декларация
{
  ИнструкцияТелаФункции телоФунк;
  this(ИнструкцияТелаФункции телоФунк)
  {
    super.естьТело = да;
    mixin(установить_вид);
    добавьОтпрыск(телоФунк);

    this.телоФунк = телоФунк;
  }
  mixin(методКопирования);
}

class ДекларацияФункции : Декларация
{
  УзелТипа типВозврата;
  Идентификатор* имя;
//   ПараметрыШаблона шпарамы;
  Параметры парамы;
  ИнструкцияТелаФункции телоФунк;
  ТипКомпоновки типКомпоновки;
  бул нельзяИнтерпретировать = нет;
  this(УзелТипа типВозврата, Идентификатор* имя,/+ ПараметрыШаблона шпарамы,+/
       Параметры парамы, ИнструкцияТелаФункции телоФунк)
  {
    super.естьТело = телоФунк.телоФунк !is null;
    mixin(установить_вид);
    добавьОпцОтпрыск(типВозврата);
//     добавьОтпрыск(шпарамы);
    добавьОтпрыск(парамы);
    добавьОтпрыск(телоФунк);

    this.типВозврата = типВозврата;
    this.имя = имя;
//     this.шпарамы = шпарамы;
    this.парамы = парамы;
    this.телоФунк = телоФунк;
  }

  проц  установиТипКомпоновки(ТипКомпоновки типКомпоновки)
  {
    this.типКомпоновки = типКомпоновки;
  }

  бул вВидеШаблона_ли()
  { // E.g.: проц  func(T)(T t)
    //                  ^ парамы.начало.предшНепроб
    return парамы.начало.предшНепроб.вид == TOK.ПСкобка;
  }

  mixin(методКопирования);
}

/// ДекларацияПеременных := Тип? Идентификатор ("=" Init)? ("," Идентификатор ("=" Init)?)* ";"
class ДекларацияПеременных : Декларация
{
  УзелТипа узелТипа;
  Идентификатор*[] имена;
  Выражение[] иниты;
  this(УзелТипа узелТипа, Идентификатор*[] имена, Выражение[] иниты)
  {
    // Пустые массивы не допустимы. Оба массива должны быть одинакового размера.
    assert(имена.length != 0 && имена.length == иниты.length);
    // Если no тип (in case of ДекларацияАвто), first значение mustn't be null.
    assert(узелТипа ? 1 : иниты[0] !is null);
    mixin(установить_вид);
    добавьОпцОтпрыск(узелТипа);
    foreach(иниц; иниты)
      добавьОпцОтпрыск(иниц);

    this.узелТипа = узелТипа;
    this.имена = имена;
    this.иниты = иниты;
  }

  ТипКомпоновки типКомпоновки;

  проц  установиТипКомпоновки(ТипКомпоновки типКомпоновки)
  {
    this.типКомпоновки = типКомпоновки;
  }

  Переменная[] переменные;

  mixin(методКопирования);
}

class ДекларацияИнварианта : Декларация
{
  ИнструкцияТелаФункции телоФунк;
  this(ИнструкцияТелаФункции телоФунк)
  {
    super.естьТело = да;
    mixin(установить_вид);
    добавьОтпрыск(телоФунк);

    this.телоФунк = телоФунк;
  }
  mixin(методКопирования);
}

class ДекларацияЮниттеста : Декларация
{
  ИнструкцияТелаФункции телоФунк;
  this(ИнструкцияТелаФункции телоФунк)
  {
    super.естьТело = да;
    mixin(установить_вид);
    добавьОтпрыск(телоФунк);

    this.телоФунк = телоФунк;
  }
  mixin(методКопирования);
}

abstract class ДекларацияУсловнойКомпиляции : Декларация
{
  Сема* спец;
  Сема* услов;
  Декларация деклы, деклыИначе;

  this(Сема* спец, Сема* услов, Декларация деклы, Декларация деклыИначе)
  {
    super.естьТело = деклы !is null;
    добавьОпцОтпрыск(деклы);
    добавьОпцОтпрыск(деклыИначе);

    this.спец = спец;
    this.услов = услов;
    this.деклы = деклы;
    this.деклыИначе = деклыИначе;
  }

  бул определение_ли()
  {
    return деклы is null;
  }

  бул условие_ли()
  {
    return деклы !is null;
  }

  /// Ветвь, в которой компилируется.
  Декларация компилированныеДеклы;
}

class ДекларацияОтладки : ДекларацияУсловнойКомпиляции
{
  this(Сема* спец, Сема* услов, Декларация деклы, Декларация деклыИначе)
  {
    super(спец, услов, деклы, деклыИначе);
    mixin(установить_вид);
  }
  mixin(методКопирования);
}

class ДекларацияВерсии : ДекларацияУсловнойКомпиляции
{
  this(Сема* спец, Сема* услов, Декларация деклы, Декларация деклыИначе)
  {
    super(спец, услов, деклы, деклыИначе);
    mixin(установить_вид);
  }
  mixin(методКопирования);
}

class ДекларацияСтатическогоЕсли : Декларация
{
  Выражение условие;
  Декларация деклыЕсли, деклыИначе;
  this(Выражение условие, Декларация деклыЕсли, Декларация деклыИначе)
  {
    super.естьТело = да;
    mixin(установить_вид);
    добавьОтпрыск(условие);
    добавьОтпрыск(деклыЕсли);
    добавьОпцОтпрыск(деклыИначе);

    this.условие = условие;
    this.деклыЕсли = деклыЕсли;
    this.деклыИначе = деклыИначе;
  }
  mixin(методКопирования);
}

class ДекларацияСтатическогоПодтверди : Декларация
{
  Выражение условие, сообщение;
  this(Выражение условие, Выражение сообщение)
  {
    super.естьТело = да;
    mixin(установить_вид);
    добавьОтпрыск(условие);
    добавьОпцОтпрыск(сообщение);

    this.условие = условие;
    this.сообщение = сообщение;
  }
  mixin(методКопирования);
}

class ДекларацияНов : Декларация
{
  Параметры парамы;
  ИнструкцияТелаФункции телоФунк;
  this(Параметры парамы, ИнструкцияТелаФункции телоФунк)
  {
    super.естьТело = да;
    mixin(установить_вид);
    добавьОтпрыск(парамы);
    добавьОтпрыск(телоФунк);

    this.парамы = парамы;
    this.телоФунк = телоФунк;
  }
  mixin(методКопирования);
}

class ДекларацияУдали : Декларация
{
  Параметры парамы;
  ИнструкцияТелаФункции телоФунк;
  this(Параметры парамы, ИнструкцияТелаФункции телоФунк)
  {
    super.естьТело = да;
    mixin(установить_вид);
    добавьОтпрыск(парамы);
    добавьОтпрыск(телоФунк);

    this.парамы = парамы;
    this.телоФунк = телоФунк;
  }
  mixin(методКопирования);
}

abstract class ДекларацияАтрибута : Декларация
{
  Декларация деклы;
  this(Декларация деклы)
  {
    super.естьТело = да;
    добавьОтпрыск(деклы);
    this.деклы = деклы;
  }
}

class ДекларацияЗащиты : ДекларацияАтрибута
{
  Защита защ;
  this(Защита защ, Декларация деклы)
  {
    super(деклы);
    mixin(установить_вид);
    this.защ = защ;
  }
  mixin(методКопирования);
}

class ДекларацияКлассаХранения : ДекларацияАтрибута
{
  КлассХранения классХранения;
  this(КлассХранения классХранения, Декларация декл)
  {
    super(декл);
    mixin(установить_вид);

    this.классХранения = классХранения;
  }
  mixin(методКопирования);
}

class ДекларацияКомпоновки : ДекларацияАтрибута
{
  ТипКомпоновки типКомпоновки;
  this(ТипКомпоновки типКомпоновки, Декларация деклы)
  {
    super(деклы);
    mixin(установить_вид);

    this.типКомпоновки = типКомпоновки;
  }
  mixin(методКопирования);
}

class ДекларацияРазложи : ДекларацияАтрибута
{
  цел размер;
  this(цел размер, Декларация деклы)
  {
    super(деклы);
    mixin(установить_вид);
    this.размер = размер;
  }
  mixin(методКопирования);
}

class ДекларацияПрагмы : ДекларацияАтрибута
{
  Идентификатор* идент;
  Выражение[] арги;
  this(Идентификатор* идент, Выражение[] арги, Декларация деклы)
  {
    добавьОпцОтпрыски(арги); // Добавить арги перед вызовом super().
    super(деклы);
    mixin(установить_вид);

    this.идент = идент;
    this.арги = арги;
  }
  mixin(методКопирования);
}

class ДекларацияСмеси : Декларация
{
  /// IdExpression := ВыражениеИдентификатор | ВыражениеЭкземплярШаблона
  /// MixinTemplate := IdExpression ("." IdExpression)*
  Выражение выражШаблон;
  Идентификатор* идентСмеси; /// Optional mixin identifier.
  Выражение аргумент; /// "mixin" "(" ВыражениеПрисвой ")"
  Декларация деклы; /// Инициализируется на семантической фазе.

  this(Выражение выражШаблон, Идентификатор* идентСмеси)
  {
    mixin(установить_вид);
    добавьОтпрыск(выражШаблон);

    this.выражШаблон = выражШаблон;
    this.идентСмеси = идентСмеси;
  }

  this(Выражение аргумент)
  {
    mixin(установить_вид);
    добавьОтпрыск(аргумент);

    this.аргумент = аргумент;
  }

  бул выражениеСмеси_ли()
  {
    return аргумент !is null;
  }

  mixin(методКопирования);
}