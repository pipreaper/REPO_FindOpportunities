// + ----------------------------------------------- ------------------- +
// | IsSession.mqh |
// | Copyright 2015, Gruzdev Konstantin |
// | https://login.mql5.com/en/users/Lizar |
// + ----------------------------------------------- ------------------- +
#property copyright "Copyright 2015, Gruzdev Konstantin"
#property link "https://login.mql5.com/en/users/Lizar"
#property version "1.00"
// ---
#define SECONDS_DAY 86400 // number of seconds in one day
// ---
#include <Object.mqh> // base class for storing elements
// + ----------------------------------------------- ------------------- +
// | Class CIsSession. |
// | Appointment: Class of identification of a trading range (session). |
// + ----------------------------------------------- ------------------- +
class CIsSession: public CObject
  {
private:
   long              m_begin; // start of a trading session (trading range) in seconds
   long              m_end; // end of the trading session (trading range) in seconds
   long              m_current; // current trading session time in seconds
   MqlDateTime       m_scurrent; // current time of the trading session as a structure
   uchar             m_days_week; // bitmask, each bit corresponds to the day of the week (0 bits - Sunday, ..., 6 bits - Saturday).
   // If the bit value is 0, then trading on the corresponding day is prohibited.
   // If the bit value is 1, then trading on the corresponding day is allowed.
   bool              m_is_session; // sign of being in a given trading range (session):
   // true - we are in a trading range;
   // false - we are out of the trading range.
   bool              m_is_daily; // sign of daily trading; set if date
   // the beginning of the session and the end of the session are 1970.01.01
   // true - daily sessions;
   // false - sessions inside or outside the date range.
   bool              m_type; // type of trading session:
   // true - daily session or mode within the date range, m_begin <m_end;
   // false - night session or mode outside the date range, m_begin> m_end.
public:
   void              CIsSession(void);
   void              CIsSession(const datetime begin_session,
                   const datetime end_session,
                   const bool permit_monday = true,
                   const bool permit_tuesday = true,
                   const bool permit_wednesday = true,
                   const bool permit_thursday = true,
                   const bool permit_friday = true,
                   const bool permit_saturday = false,
                   const bool permit_sunday = false);
   void             ~ CIsSession(void) {};
   // --- Initialization methods:
   void              Init(const datetime begin_session,
             const datetime end_session);
   void              Init(const int index_day,
             const bool permit_trade);
   // --- Method for checking the presence in the trading range:
   bool              IsSession(void);
  };
// + ----------------------------------------------- ------------------- +
// | Class constructor. |
// | INPUT: no. |
// | OUTPUT: no. |
// | REMARK: no. |
// + ----------------------------------------------- ------------------- +
void CIsSession :: CIsSession(void)
  {
   m_is_daily = true; // set the sign of the daily session, true - daily
   m_begin = 0; // start of a toggle session (trading range) in seconds
   m_end = SECONDS_DAY-1; // end of the toggle session (trading range) in seconds
   m_type = true; // type of a trading session
   m_days_week = B'11111111'; // bit mask, trading is allowed on all days of the week
  }
// + ----------------------------------- ------------------------------- +
// | Parametric constructor of the class. |
// | INPUT: begin_session - start of a trading session |
// | end_session - end of a trading session |
// | permit_sunday - permission to trade on Sunday |
// | permit_monday - permission to trade on Monday |
// | permit_tuesday - permission to trade on Tuesday |
// | permit_wednesday - permission to trade on Wednesday |
// | permit_thursday - permission to trade on Thursday |
// | permit_friday - permission to trade on Friday |
// | permit_saturday - permission to trade on Saturday |
// | OUTPUT: no. |
// | REMARK: if the value of the "permit ..." parameter is true, then |
// | trading on this day is allowed, false - is prohibited. |
// + ----------------------------------------------- ------------------- +
void CIsSession :: CIsSession(const datetime begin_session,
                              const datetime end_session,
                              const bool permit_monday = true,
                              const bool permit_tuesday = true,
                              const bool permit_wednesday = true,
                              const bool permit_thursday = true,
                              const bool permit_friday = true,
                              const bool permit_saturday = false,
                              const bool permit_sunday = false)
  {
   Init(begin_session, end_session);
   Init(0, permit_sunday);
   Init(1, permit_monday);
   Init(2, permit_tuesday);
   Init(3, permit_wednesday);
   Init(4, permit_thursday);
   Init(5, permit_friday);
   Init(6, permit_saturday);
  }
// + ---------------------------------------------- -------------------- +
// | The method is used to initialize the filter for a trading session. |
// | INPUT: begin_session - start of a trading session. |
// | end_session - end of the trading session. |
// | OUTPUT: no. |
// | REMARK: no. |
// + ----------------------------------------------- ------------------- +
void CIsSession :: Init(const datetime begin_session,
                        const datetime end_session)
  {
   m_is_daily = (begin_session / SECONDS_DAY + end_session / SECONDS_DAY) == 0; // set / reset the sign of the daily session, true - daily
   m_begin = begin_session; // start of the toggle session (trading range) in seconds
   m_end = end_session; // end of the trading session (trading range) in seconds
   m_type = m_begin <m_end; // type of trading session
  }
// + ----------------------------------------- ------------------------- +
// | The method is used to allow / prohibit trading in a given |
// | day of the week. |
// | INPUT: index_day - the index of the day of the week |
// | (0 - Sunday, ..., 6 - Saturday) |
// | permit_trade - permission / prohibition to trade on this day |
// | OUTPUT: no. |
// | REMARK: if the value of the parameter is true, then trade on this day |
// | allowed, false - not allowed. |
// + ----------------------------------------------- ------------------- +
void CIsSession::Init(const int  index_day,
                      const bool permit_trade)
  {
// --- initialize the bit of the corresponding day of the week:
   m_days_week &=uchar(~(1<<index_day));                                // reset the previous value
   m_days_week |=uchar(permit_trade<<index_day);                        // set a new value
  }

// + ----------------------------------------- ------------------------- +
// | The method determines whether the current server time matches the specified |
// | trading range (session). |
// | INPUT: no. |
// | OUTPUT: true - we are in the specified trading interval. |
// | false - we are out of the specified trading interval. |
// | REMARK: no. |
// + ----------------------------------------------- ------------------- +
bool CIsSession :: IsSession(void)
  {
// --- get the last known server time:
   m_current = TimeCurrent(m_scurrent);
// --- check the permission to trade on the current day of the week:
   m_is_session = m_days_week & (1 << m_scurrent.day_of_week);
// ---
   if(m_is_session)
     {
      // --- adjust the time if daily sessions:
      if(m_is_daily)
         m_current%=SECONDS_DAY;
      // --- set / reset the sign of the session:
      m_is_session = m_begin <= m_current; // time should be greater than the beginning of the session ...
      // --- adjust m_is_session depending on the type of session:
      if(m_type)
         m_is_session &= m_current<=m_end; // ... and less than the end of the session
      else
         m_is_session |= m_current<=m_end;  // ... or less than the end of the session
     }
// --- result:
   return m_is_session;
  }
// + ---------------------------------------------- -------------------- 
//+------------------------------------------------------------------+
