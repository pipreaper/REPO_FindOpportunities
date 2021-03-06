//+------------------------------------------------------------------+
//|                                                    IsSession.mqh |
//|                               Copyright 2015, Gruzdev Konstantin |
//|                            https://login.mql5.com/ru/users/Lizar |
//+------------------------------------------------------------------+
#property copyright     "Copyright 2015, Gruzdev Konstantin"
#property link          "https://login.mql5.com/ru/users/Lizar"
#property version       "1.00"
//---
#define   SECONDS_DAY   86400    // количество секунд в одном дне
//---
#include <Object.mqh>            // базовый класс для хранения элементов
//+------------------------------------------------------------------+
//| Class CIsSession.                                                |
//| Appointment: Класс идентификации торгового диапазона (сессии).   |
//+------------------------------------------------------------------+
class CIsSession : public CObject
  {
private:
   long              m_begin;          // начало торговой сессии (торгового диапазона) в секундах
   long              m_end;            // конец торговой сессии (торгового диапазона) в секундах
   long              m_current;        // текущее время торговой сессии в секундах
   MqlDateTime       m_scurrent;       // текущее время торговой сессии в виде структуры
   uchar             m_days_week;      // битовая маска, каждый бит соответствует дню недели (0 бит - воскресенье, ..., 6 бит - суббота).
                                       // Если значение бита равно 0, то торговля в соответствующий день запрещена.
                                       // Если значение бита равно 1, то торговля в соответствующий день разрешена.
   bool              m_is_session;     // признак нахождения в заданном торговом диапазоне (сессии):
                                       //    true  - находимся в торговом диапазоне;
                                       //    false - находимся вне торгового диапазона.
   bool              m_is_daily;       // признак ежедневной торговли; устанавливается, если дата
                                       // начала сессии и конца сессии равны 1970.01.01
   //    true  - ежедневные сессии;
   //    false - сессии внутри или вне диапазона дат.
   bool              m_type;           // тип торговой сессии:
                                       //    true  - дневная сессия или режим внутри диапазона дат, m_begin<m_end;
   //    false - ночная  сессия или режим вне диапазона дат, m_begin>m_end.
public:
   void              CIsSession(void);
   void              CIsSession(const datetime begin_session,
                                const datetime end_session,
                                const bool     permit_monday     = true,
                                const bool     permit_tuesday    = true,
                                const bool     permit_wednesday  = true,
                                const bool     permit_thursday   = true,
                                const bool     permit_friday     = true,
                                const bool     permit_saturday   = false,
                                const bool     permit_sunday     = false);
   void             ~CIsSession(void) {};
   //--- Методы инициализации:
   void              Init(const datetime begin_session,
                          const datetime end_session);
   void              Init(const int      index_day,
                          const bool     permit_trade);
   //--- Метод проверки нахождения в торговом диапазоне:
   bool              IsSession(void);
  };
//+------------------------------------------------------------------+
//| Конструктор класса.                                              |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CIsSession::CIsSession(void)
  {
   m_is_daily = true;                                                   // устанавливаем признак ежедневной сессии, true - ежедневная
   m_begin    = 0;                                                      // начало тоговой сессии (торгового диапазона) в секундах
   m_end      = SECONDS_DAY-1;                                          // конец тоговой сессии (торгового диапазона) в секундах
   m_type     = true;                                                   // тип торговой сессии
   m_days_week= B'11111111';                                            // битовая маска, торговля разрешена во все дни недели
  }
//+------------------------------------------------------------------+
//| Параметрический конструктор класса.                              |
//| INPUT:  begin_session     - начало торговой сессии               |
//|         end_session       - конец торговой сессии                |
//|         permit_sunday     - разрешение торговать в воскресенье   |
//|         permit_monday     - разрешение торговать в понедельник   |
//|         permit_tuesday    - разрешение торговать во вторник      |
//|         permit_wednesday  - разрешение торговать в среду         |
//|         permit_thursday   - разрешение торговать в четверг       |
//|         permit_friday     - разрешение торговать в пятницу       |
//|         permit_saturday   - разрешение торговать в субботу       |
//| OUTPUT: no.                                                      |
//| REMARK: если значение параметра "permit..." равно true, то       |
//|         торговля в этот день разрешена, false - запрещена.       |
//+------------------------------------------------------------------+
void CIsSession::CIsSession(const datetime begin_session,
                            const datetime end_session,
                            const bool     permit_monday     = true,
                            const bool     permit_tuesday    = true,
                            const bool     permit_wednesday  = true,
                            const bool     permit_thursday   = true,
                            const bool     permit_friday     = true,
                            const bool     permit_saturday   = false,
                            const bool     permit_sunday     = false)
  {
   Init(begin_session,end_session);
   Init(0,permit_sunday);
   Init(1,permit_monday);
   Init(2,permit_tuesday);
   Init(3,permit_wednesday);
   Init(4,permit_thursday);
   Init(5,permit_friday);
   Init(6,permit_saturday);
  }
//+------------------------------------------------------------------+
//| Метод используется для инициализации фильтра торговой сессии.    |
//| INPUT:  begin_session - начало торговой сессии.                  |
//|         end_session   - конец торговой сессии.                   |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CIsSession::Init(const datetime begin_session,
                      const datetime end_session)
  {
   m_is_daily = (begin_session/SECONDS_DAY+end_session/SECONDS_DAY)==0; // устанавливаем/сбрасываем признак ежедневной сессии, true - ежедневная
   m_begin    = begin_session;                                          // начало тоговой сессии (торгового диапазона) в секундах
   m_end      = end_session;                                            // конец тоговой сессии (торгового диапазона) в секундах
   m_type     = m_begin<m_end;                                          // тип торговой сессии
  }
//+------------------------------------------------------------------+
//| Метод используется для разрешения/запрета торговать в заданный   |
//| день недели.                                                     |
//| INPUT:  index_day    - индекс дня недели                         |
//|                        (0 - воскресенье, ..., 6 - суббота)       |
//|         permit_trade - разрешение/запрет торговать в этот день   |
//| OUTPUT: no.                                                      |
//| REMARK: если значение параметра true, то торговля в этот день    |
//|         разрешена, false - запрещена.                            |
//+------------------------------------------------------------------+
void CIsSession::Init(const int  index_day,
                      const bool permit_trade)
  {
//--- инициализируем бит сооответствующего дня недели:
   m_days_week &=uchar(~(1<<index_day));                                // сбрасываем предыдущее значение
   m_days_week |=uchar(permit_trade<<index_day);                        // устанавливаем новое значение
  }
//+------------------------------------------------------------------+
//| Метод определяет, совпадает ли текущее время сервера с заданным  |
//| торговым диапазоном (сессией).                                   |
//| INPUT:  no.                                                      |
//| OUTPUT: true -  находимся в заданном торговом интервале.         |
//|         false - находимся вне заданного торгового интервала.     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CIsSession::IsSession(void)
  {
//--- получаем последнее известное время сервера:
   m_current=TimeCurrent(m_scurrent);
//--- проверяем разрешение на торговлю в текущий день недели:
   m_is_session=m_days_week&(1<<m_scurrent.day_of_week);
//---
   if(m_is_session)
     {
      //--- корректируем время, если ежедневные сессии:
      if(m_is_daily) m_current%=SECONDS_DAY;
      //--- устанавливаем/сбрасываем признак сессии:
      m_is_session=m_begin<=m_current;             // время должно быть больше начала сессии ...
      //--- корректируем m_is_session в зависимости от типа сессии:
      if(m_type) m_is_session &= m_current<=m_end;   // ... и меньше конца сессии
      else       m_is_session |= m_current<=m_end;   // ... или меньше конца сессии
     }
//--- результат:
   return m_is_session;
  }
//+------------------------------------------------------------------+
