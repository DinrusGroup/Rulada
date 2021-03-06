/// Author: Aziz Köksal
/// License: GPL3
/// $(Maturity average)
module drc.Compilation;

import common;

/// Группа настроек, относящихся к процессу компиляции.
class КонтекстКомпиляции
{
  alias typeof(this) КК;
  КК родитель;
  ткст[] путиИмпорта;
  бцел уровеньОтладки;
  бцел уровеньВерсии;
  бул[ткст] отладИды;
  бул[ткст] версионИды;
  бул постройкаРелиз;
  бул постройкаТест;
  бул приниматьДеприкированное;
  бцел раскладкаСтруктуры = 4;

  this(КК родитель = null)
  {
    this.родитель = родитель;
    if (родитель)
    {
      this.путиИмпорта = родитель.путиИмпорта.dup;
      this.уровеньОтладки = родитель.уровеньОтладки;
      this.уровеньВерсии = родитель.уровеньВерсии;
      this.постройкаРелиз = родитель.постройкаРелиз;
      this.раскладкаСтруктуры = родитель.раскладкаСтруктуры;
    }
  }

  проц  добавьИдОтладки(ткст ид)
  {
    отладИды[ид] = да;
  }

  проц  добавьИдВерсии(ткст ид)
  {
    версионИды[ид] = да;
  }

  бул найдиИдОтладки(ткст ид)
  {
    auto pId = ид in отладИды;
    if (pId)
      return да;
    if (!корень_ли())
      return родитель.найдиИдОтладки(ид);
    return нет;
  }

  бул найдиИдВерсии(ткст ид)
  {
    auto pId = ид in версионИды;
    if (pId)
      return да;
    if (!корень_ли())
      return родитель.найдиИдВерсии(ид);
    return нет;
  }

  бул корень_ли()
  {
    return родитель is null;
  }
}
