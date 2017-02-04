/// Author: Aziz Köksal
/// License: GPL3
/// $(Maturity average)
module drc.semantic.Types;

import drc.semantic.Symbol,
       drc.semantic.TypesEnum;
import drc.lexer.Identifier;
import drc.CompilerInfo;

import common;

/// The base тип for all тип structures.
abstract class Тип/* : Символ*/
{
  Тип следщ;     /// The следщ тип in the тип structure.
  ТИП тид;       /// The ID of the тип.
  Символ символ; /// Не null if this тип has a символ.

  this(){}

  /// Constructs a Тип object.
  /// Параметры:
  ///   следщ = the тип's следщ тип.
  ///   тид = the тип's ID.
  this(Тип следщ, ТИП тид)
  {
//     this.сид = СИМ.Тип;

    this.следщ = следщ;
    this.тид = тид;
  }

  /// Returns да if this тип equals the другой one.
  бул opEquals(Тип другой)
  {
    // TODO:
    return нет;
  }

  /// Returns a pointer тип в this тип.
  УказательТип укНа()
  {
    return new УказательТип(this);
  }

  /// Returns a dynamic массив тип using this тип as its base.
  ДМассивТип массивИз()
  {
    return new ДМассивТип(this);
  }

  /// Returns an associative массив тип using this тип as its base.
  /// Параметры:
  ///   key = the key тип.
  АМассивТип массивИз(Тип key)
  {
    return new АМассивТип(this, key);
  }

  /// Returns the байт размер of this тип.
  final т_мера размера()
  {
    return МИТаблица.дайРазмер(this);
  }

  /// Size is not in МИТаблица. Find out via virtual method.
  т_мера sizeOf_()
  {
    return размера();
  }

  /// Returns да if this тип has a символ.
  бул естьСимвол_ли()
  {
    return символ !is null;
  }

  /// Returns the тип as a ткст.
  abstract сим[] вТкст();

  /// Returns да if this тип is a бул тип.
  бул бул_ли()
  {
    return тид == ТИП.Бул;
  }

  /// Returns да if this тип is a pointer тип.
  бул указатель_ли()
  {
    return тид == ТИП.Указатель;
  }

  /// Returns да if this тип is an integral число тип.
  бул интегральный_ли()
  {
    switch (тид)
    {
    case ТИП.Сим, ТИП.Шим, ТИП.Дим, ТИП.Бул, ТИП.Байт, ТИП.Ббайт,
         ТИП.Крат, ТИП.Бкрат, ТИП.Цел, ТИП.Бцел, ТИП.Дол, ТИП.Бдол,
         ТИП.Цент, ТИП.Бцент:
      return да;
    default:
      return нет;
    }
  }

  /// Returns да if this тип is a floating point число тип.
  бул плавающий_ли()
  {
    return реал_ли() || воображаемый_ли() || комплексный_ли();
  }

  /// Returns да if this тип is a реал число тип.
  бул реал_ли()
  {
    return тид == ТИП.Плав || тид == ТИП.Дво || тид == ТИП.Реал;
  }

  /// Returns да if this тип is an imaginary число тип.
  бул воображаемый_ли()
  {
    return тид == ТИП.Вплав || тид == ТИП.Вдво || тид == ТИП.Вреал;
  }

  /// Returns да if this тип is a complex число тип.
  бул комплексный_ли()
  {
    return тид == ТИП.Кплав || тид == ТИП.Кдво || тид == ТИП.Креал;
  }
}

/// All basic types. E.g.: цел, сим, реал etc.
class ТипБазовый : Тип
{
  this(ТИП typ)
  {
    super(null, typ);
  }

  сим[] вТкст()
  {
    return [
      ТИП.Сим : "сим"[], ТИП.Шим : "шим", ТИП.Дим : "дим",
      ТИП.Бул : "бул", ТИП.Байт : "байт", ТИП.Ббайт : "ббайт",
      ТИП.Крат : "крат", ТИП.Бкрат : "бкрат", ТИП.Цел : "цел",
      ТИП.Бцел : "бцел", ТИП.Дол : "дол", ТИП.Бдол : "бдол",
      ТИП.Цент : "цент", ТИП.Бцент : "бцент", ТИП.Плав : "плав",
      ТИП.Дво : "дво", ТИП.Реал : "реал", ТИП.Вплав : "вплав",
      ТИП.Вдво : "вдво", ТИП.Вреал : "вреал", ТИП.Кплав : "кплав",
      ТИП.Кдво : "кдво", ТИП.Креал : "креал"
    ][this.тид];
  }
}

/// Dynamic массив тип.
class ДМассивТип : Тип
{
  this(Тип следщ)
  {
    super(следщ, ТИП.ДМассив);
  }

  сим[] вТкст()
  {
    return следщ.вТкст() ~ "[]";
  }
}

/// Associative массив тип.
class АМассивТип : Тип
{
  Тип клТип;
  this(Тип следщ, Тип клТип)
  {
    super(следщ, ТИП.АМассив);
    this.клТип = клТип;
  }

  сим[] вТкст()
  {
    return следщ.вТкст() ~ "[" ~ клТип.вТкст() ~ "]";
  }
}

/// Статический массив тип.
class СМассивТип : Тип
{
  т_мера dimension;
  this(Тип следщ, т_мера dimension)
  {
    super(следщ, ТИП.СМассив);
    this.dimension = dimension;
  }

  сим[] вТкст()
  {
    return Формат("%s[%d]", следщ.вТкст(), dimension);
  }
}

/// Указатель тип.
class УказательТип : Тип
{
  this(Тип следщ)
  {
    super(следщ, ТИП.Указатель);
  }

  сим[] вТкст()
  {
    return следщ.вТкст() ~ "*";
  }
}

/// Ссылка тип.
class СсылкаТип : Тип
{
  this(Тип следщ)
  {
    super(следщ, ТИП.Ссылка);
  }

  сим[] вТкст()
  { // FIXME: this is probably wrong.
    return следщ.вТкст() ~ "&";
  }
}

/// Перечень тип.
class ПереченьТип : Тип
{
  this(Символ символ)
  {
    super(типОснова, ТИП.Перечень);
    this.символ = символ;
  }

  /// Setter for the base тип.
  проц  типОснова(Тип тип)
  {
    следщ = тип;
  }

  /// Getter for the base тип.
  Тип типОснова()
  {
    return следщ;
  }

  сим[] вТкст()
  {
    return символ.имя.ткт;
  }
}

/// Структура тип.
class СтруктураТип : Тип
{
  this(Символ символ)
  {
    super(null, ТИП.Структура);
    this.символ = символ;
  }

  сим[] вТкст()
  {
    return символ.имя.ткт;
  }
}

/// Класс тип.
class КлассТип : Тип
{
  this(Символ символ)
  {
    super(null, ТИП.Класс);
    this.символ = символ;
  }

  сим[] вТкст()
  {
    return символ.имя.ткт;
  }
}

/// Типдеф тип.
class ТипдефТип : Тип
{
  this(Тип следщ)
  {
    super(следщ, ТИП.Типдеф);
  }

  сим[] вТкст()
  { // TODO:
    return "типдеф";
  }
}

/// Функция тип.
class ФункцияТип : Тип
{
  this(Тип следщ)
  {
    super(следщ, ТИП.Функция);
  }

  сим[] вТкст()
  { // TODO:
    return "функция";
  }
}

/// Делегат тип.
class ДелегатТип : Тип
{
  this(Тип следщ)
  {
    super(следщ, ТИП.Делегат);
  }

  сим[] вТкст()
  { // TODO:
    return "делегат";
  }
}

/// Идентификатор тип.
class ИдентификаторТип : Тип
{
  Идентификатор* идент;
  this(Идентификатор* идент)
  {
    super(null, ТИП.Идентификатор);
  }

  сим[] вТкст()
  {
    return идент.ткт;
  }
}

/// Шаблон instantiation тип.
class ЭкземплШаблонаТип : Тип
{
  this()
  {
    super(null, ТИП.ШЭкземпляр);
  }

  сим[] вТкст()
  { // TODO:
    return "шабл!()";
  }
}

/// Шаблон tuple тип.
class КортежТип : Тип
{
  this(Тип следщ)
  {
    super(следщ, ТИП.Кортеж);
  }

  сим[] вТкст()
  { // TODO:
    return "кортеж";
  }
}

/// Constant тип. D2.0
class КонстантаТип : Тип
{
  this(Тип следщ)
  {
    super(следщ, ТИП.Конст);
  }

  сим[] вТкст()
  {
    return "конст(" ~ следщ.вТкст() ~ ")";
  }
}

/// Инвариант тип. D2.0
class ИнвариантТип : Тип
{
  this(Тип следщ)
  {
    super(следщ, ТИП.Конст);
  }

  сим[] вТкст()
  {
    return "инвариант(" ~ следщ.вТкст() ~ ")";
  }
}

/// Represents a значение related в a Тип.
union Значение
{
  ук  упроц;
  бул   бул_;
  дим  дим_;
  дол   дол_;
  бдол  бдол_;
  цел    цел_;
  бцел   бцел_;
  плав  плав_;
  дво дво_;
  реал   реал_;
  креал  креал_;
}

/// Информация related в a Тип.
struct МетаИнфоТип
{
  сим mangle; /// Mangle character of the тип.
  бкрат размер; /// Байт размер of the тип.
  Значение* дефолтИниц; /// Дефолт initialization значение.
}

/// Namespace for the meta инфо таблица.
struct МИТаблица
{
static:
  const бкрат РАЗМЕР_НЕ_ДОСТУПЕН = 0; /// Size not available.
  const Значение ЗНОЛЬ = {цел_:0}; /// Значение 0.
  const Значение ЗНУЛЬ = {упроц:null}; /// Значение null.
  const Значение V0xFF = {дим_:0xFF}; /// Значение 0xFF.
  const Значение V0xFFFF = {дим_:0xFFFF}; /// Значение 0xFFFF.
  const Значение ЗЛОЖЬ = {бул_:нет}; /// Значение нет.
  const Значение ЗНЕЧ = {плав_:плав.nan}; /// Значение NAN.
  const Значение ЗКНЕЧ = {креал_:креал.nan}; /// Значение complex NAN.
  private alias РАЗМЕР_НЕ_ДОСТУПЕН РНД;
  private alias РАЗМЕР_УК РА;
  /// The meta инфо таблица.
  private const МетаИнфоТип метаИнфоТаблица[] = [
    {'?', РНД}, // Ошибка

    {'a', 1, &V0xFF},   // Сим
    {'u', 2, &V0xFFFF},   // Шим
    {'w', 4, &V0xFFFF},   // Дим
    {'b', 1, &ЗЛОЖЬ},   // Бул
    {'g', 1, &ЗНОЛЬ},   // Байт
    {'h', 1, &ЗНОЛЬ},   // Ббайт
    {'s', 2, &ЗНОЛЬ},   // Крат
    {'t', 2, &ЗНОЛЬ},   // Бкрат
    {'i', 4, &ЗНОЛЬ},   // Цел
    {'k', 4, &ЗНОЛЬ},   // Бцел
    {'l', 8, &ЗНОЛЬ},   // Дол
    {'m', 8, &ЗНОЛЬ},   // Бдол
    {'?', 16, &ЗНОЛЬ},  // Цент
    {'?', 16, &ЗНОЛЬ},  // Бцент
    {'f', 4, &ЗНЕЧ},   // Плав
    {'d', 8, &ЗНЕЧ},   // Дво
    {'e', 12, &ЗНЕЧ},  // Реал
    {'o', 4, &ЗНЕЧ},   // Вплав
    {'p', 8, &ЗНЕЧ},   // Вдво
    {'j', 12, &ЗНЕЧ},  // Вреал
    {'q', 8, &ЗКНЕЧ},   // Кплав
    {'r', 16, &ЗКНЕЧ},  // Кдво
    {'c', 24, &ЗКНЕЧ},  // Креал
    {'v', 1},   // проц 

    {'n', РНД},  // Нет

    {'A', РА*2, &ЗНУЛЬ}, // Dynamic массив
    {'G', РА*2, &ЗНУЛЬ}, // Статический массив
    {'H', РА*2, &ЗНУЛЬ}, // Associative массив

    {'E', РНД}, // Перечень
    {'S', РНД}, // Структура
    {'C', РА, &ЗНУЛЬ},  // Класс
    {'T', РНД}, // Типдеф
    {'F', РА},  // Функция
    {'D', РА*2, &ЗНУЛЬ}, // Делегат
    {'P', РА, &ЗНУЛЬ},  // Указатель
    {'R', РА, &ЗНУЛЬ},  // Ссылка
    {'I', РНД}, // Идентификатор
    {'?', РНД}, // Шаблон instance
    {'B', РНД}, // Кортеж
    {'x', РНД}, // Конст, D2
    {'y', РНД}, // Инвариант, D2
  ];
  static assert(метаИнфоТаблица.length == ТИП.max+1);

  /// Returns the размер of a тип.
  т_мера дайРазмер(Тип тип)
  {
    auto размер = метаИнфоТаблица[тип.тид].размер;
    if (размер == РАЗМЕР_НЕ_ДОСТУПЕН)
      return тип.sizeOf_();
    return размер;
  }
}

/// Namespace for a установи of predefined types.
struct Типы
{
static:
  /// Predefined basic types.
  ТипБазовый Сим,   Шим,   Дим, Бул,
            Байт,   Ббайт,   Крат, Бкрат,
            Цел,    Бцел,    Дол,  Бдол,
            Цент,   Бцент,
            Плав,  Дво,  Реал,
            Вплав, Вдво, Вреал,
            Кплав, Кдво, Креал, Проц;

  ТипБазовый Т_мера; /// The размер тип.
  ТипБазовый Т_дельтаук; /// The pointer difference тип.
  УказательТип Проц_ук; /// The проц  pointer тип.
  ТипБазовый Ошибка; /// The ошибка тип.
  ТипБазовый Неопределённый; /// The undefined тип.
  ТипБазовый ПокаНеИзвестен; /// The символ is undefined but might be resolved.

  /// Allocates an instance of ТипБазовый and assigns it в имяТипа.
  template новТБ(сим[] имяТипа)
  {
    const новТБ = mixin(имяТипа~" = new ТипБазовый(ТИП."~имяТипа~")");
  }

  /// Initializes predefined types.
  static this()
  {
    новТБ!("Сим");
    новТБ!("Шим");
    новТБ!("Дим");
    новТБ!("Бул");
    новТБ!("Байт");
    новТБ!("Ббайт");
    новТБ!("Крат");
    новТБ!("Бкрат");
    новТБ!("Цел");
    новТБ!("Бцел");
    новТБ!("Дол");
    новТБ!("Бдол");
    новТБ!("Цент");
    новТБ!("Бцент");
    новТБ!("Плав");
    новТБ!("Дво");
    новТБ!("Реал");
    новТБ!("Вплав");
    новТБ!("Вдво");
    новТБ!("Вреал");
    новТБ!("Кплав");
    новТБ!("Кдво");
    новТБ!("Креал");
    новТБ!("Проц");
    version(X86_64)
    {
      Т_мера = Бдол;
      Т_дельтаук = Дол;
    }
    else
    {
      Т_мера = Бцел;
      Т_дельтаук = Цел;
    }
    Проц_ук = Проц.укНа;
    Ошибка = new ТипБазовый(ТИП.Ошибка);
    Неопределённый = new ТипБазовый(ТИП.Ошибка);
    ПокаНеИзвестен = new ТипБазовый(ТИП.Ошибка);
  }
}