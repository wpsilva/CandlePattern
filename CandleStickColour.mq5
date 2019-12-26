#include "CandlestickPattern.mqh"
#property indicator_chart_window

#property indicator_buffers 5
#property indicator_plots   1
//--- plot 1
#property indicator_label1  ""
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  Green,Blue,Magenta,DeepSkyBlue,Orange,LightSlateGray,Red,DarkViolet
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
//---- indicator buffers
double ExtOpen[];
double ExtHigh[];
double ExtLow[];
double ExtClose[];
double ExtColor[];
//--- indicator handles
//--- list global variable
string prefix="Candlestick Type ";
string name[]={"MARIBOZU","DOJI","SPINNING TOP","HAMMER","TURN HAMMER","LONG","SHORT"};
datetime CurTime=0;

input int   InpPeriodSMA   =17;         // Period of averaging
input bool  InpAlert       =true;       // Enable. signal
input int   InpCountBars   =1000;       // Amount of bars for calculation
input color InpColorBull   =DodgerBlue; // Color of bullish models
input color InpColorBear   =Tomato;     // Color of bearish models
input bool  InpCommentOn   =true;       // Enable comment
input int   InpTextFontSize=10;         // Font size

int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtOpen,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHigh,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLow,INDICATOR_DATA);
   SetIndexBuffer(3,ExtClose,INDICATOR_DATA);
   SetIndexBuffer(4,ExtColor,INDICATOR_CALCULATIONS);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- sets drawing line empty value--
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---
   for(int i=0;i<ArraySize(name);i++)
     {
      ObjectCreate(0,name[i],OBJ_LABEL,0,0,0);
      ObjectSetString(0,name[i],OBJPROP_FONT,"Tahoma");
      ObjectSetInteger(0,name[i],OBJPROP_FONTSIZE,8);
      ObjectSetInteger(0,name[i],OBJPROP_CORNER,2);
      ObjectSetInteger(0,name[i],OBJPROP_ANCHOR,ANCHOR_RIGHT_LOWER);
      ObjectSetInteger(0,name[i],OBJPROP_XDISTANCE,10);
      ObjectSetInteger(0,name[i],OBJPROP_YDISTANCE,i*15);
      ObjectSetInteger(0,name[i],OBJPROP_COLOR,PlotIndexGetInteger(0,PLOT_LINE_COLOR,i));
      ObjectSetString(0,name[i],OBJPROP_TEXT,name[i]);

     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(rates_total==prev_calculated)
     {
      return(rates_total);
     }
   ExtOpen[rates_total-1]=EMPTY_VALUE;
   ExtHigh[rates_total-1]=EMPTY_VALUE;
   ExtLow[rates_total-1]=EMPTY_VALUE;
   ExtClose[rates_total-1]=EMPTY_VALUE;
//--- delete object
   string objname,comment;
   for(int i=ObjectsTotal(0,0,-1)-1;i>=0;i--)
     {
      objname=ObjectName(0,i);
      if(StringFind(objname,prefix)==-1)
         continue;
      else
         ObjectDelete(0,objname);
     }
   int objcount=0;
//---
   int limit;
   if(prev_calculated==0)
      limit=20;
   else limit=prev_calculated-5;
//--- calculate candlestick
   for(int i=limit;i<rates_total-1;i++)
     {
      ExtOpen[i]=open[i];
      ExtHigh[i]=high[i];
      ExtLow[i]=low[i];
      ExtClose[i]=close[i];
      CANDLE_STRUCTURE cand;
      if(!RecognizeCandle(time[i],InpPeriodSMA,cand))
        {
         continue;
        }      
      //switch(cand.trend)
      //  {
      //   case  0:
      //     Alert("UPPER");
      //     break;
      //   case  1:
      //     Alert("DOWN");
      //     break;         
      //   case  2:
      //     Alert("LATERAL");
      //     break;
      //   default:
      //     break;
      //  }
      
      //switch(cand.type)
      //  {
      //   case CAND_MARIBOZU:
      //   case CAND_MARIBOZU_LONG:
      //      ExtColor[i]=0;
      //      break;
      //   case CAND_DOJI:
      //      ExtColor[i]=1;
      //      break;
      //   case CAND_SPIN_TOP:
      //      ExtColor[i]=2;
      //      break;
      //   case CAND_HAMMER:
      //      ExtColor[i]=3;
      //      break;
      //   case CAND_INVERT_HAMMER:
      //      ExtColor[i]=4;
      //      break;
      //   case CAND_LONG:
      //      ExtColor[i]=5;
      //      break;
      //   case CAND_SHORT:
      //      ExtColor[i]=6;
      //      break;
      //   case CAND_STAR:
      //      ExtColor[i]=7;
      //      break;
      //   default:
      //      ExtOpen[i]=EMPTY_VALUE;
      //      ExtHigh[i]=EMPTY_VALUE;
      //      ExtLow[i]=EMPTY_VALUE;
      //      ExtClose[i]=EMPTY_VALUE;
      //      break;
      //  }
        
      // Inverted Hammer the bull model 
      if(cand.trend==DOWN && // check the trend direction
         cand.type==CAND_INVERT_HAMMER) // check the "inverted hammer"
        {
         comment="Inverted hammer";
         DrawSignal(prefix+"Inverted Hammer the bull model"+string(objcount++),cand,InpColorBull,comment);
        }
      // Handing Man the bear model 
      if(cand.trend==UPPER && // check the trend direction
         cand.type==CAND_HAMMER) // check "hammer"
        {
         comment="Hanging Man";
         DrawSignal(prefix+"Hanging Man the bear model"+string(objcount++),cand,InpColorBear,comment);
        }
      // Hammer the bull model 
      if(cand.trend==DOWN && //check the trend direction
         cand.type==CAND_HAMMER) // check the hammer
        {
         comment="Hammer";
         DrawSignal(prefix+"Hammer the bull model"+string(objcount++),cand,InpColorBull,comment);
        }
        
      CANDLE_STRUCTURE cand2;
      cand2=cand;
      if(!RecognizeCandle(time[i-1],InpPeriodSMA,cand))
         continue;

      // Shooting Star the bear model 
      if(cand.trend==UPPER && cand2.trend==UPPER && //check the trend direction
         cand2.type==CAND_INVERT_HAMMER) // check the inverted hammer
        {
            comment="Shooting Star";
   
            if(cand.close<cand2.open && cand.close<cand2.close) // 2 candlestick detached from 1
              {
               DrawSignal(prefix+"Shooting Star the bear model"+string(objcount++),cand2,InpColorBear,comment);
              }
        }
        
      // Belt Hold the bull model 
      if(cand2.trend==DOWN && cand2.bull && !cand.bull &&// check the trend direction and direction of the candlestick
         cand2.type==CAND_MARIBOZU_LONG && // check the "long" marubozu
         cand.bodysize<cand2.bodysize && cand2.close<cand.close) // the body of the first candlestick is smaller than the body of the second one, close of the second one is below the close of the first
        {
            comment="Belt Hold";
         
            DrawSignal(prefix+"Belt Hold the bull model"+string(objcount++),cand,cand2,InpColorBull,comment);
        }
      // Belt Hold the bear model
      if(cand2.trend==UPPER && !cand2.bull && cand.bull && // check the trend direction and direction of the candlestick
         cand2.type==CAND_MARIBOZU_LONG && // check the "long" marubozu
         cand.bodysize<cand2.bodysize && cand2.close>cand.close) // the body of the first candlestick is smaller than the body of the second one, close of the second one is above the close of the first
        {
            comment="Belt Hold";
            DrawSignal(prefix+"Belt Hold the bear model"+string(objcount++),cand,cand2,InpColorBear,comment);
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }

void OnDeinit(const int reason)
  {
   for(int i=0;i<ArraySize(name);i++)
     {
      ObjectDelete(0,name[i]);
     }
//----
   string objname;
   for(int i=ObjectsTotal(0,0,-1)-1;i>=0;i--)
     {
      objname=ObjectName(0,i);

      if(StringFind(objname,prefix)==-1)
         continue;
      else
         ObjectDelete(0,objname);
     }
  }
//+------------------------------------------------------------------+

void DrawSignal(string objname,CANDLE_STRUCTURE &cand,color Col,string comment)
  {
   string objtext=objname+"text";
   if(ObjectFind(0,objtext)>=0) ObjectDelete(0,objtext);
   if(ObjectFind(0,objname)>=0) ObjectDelete(0,objname);

   if(InpAlert && cand.time>=CurTime)
     {
      Alert(Symbol()," ",PeriodToString(_Period)," ",comment);
     }
   if(Col==InpColorBull)
     {
      ObjectCreate(0,objname,OBJ_ARROW_BUY,0,cand.time,cand.low);
      ObjectSetInteger(0,objname,OBJPROP_ANCHOR,ANCHOR_TOP);
      if(InpCommentOn)
        {
         ObjectCreate(0,objtext,OBJ_TEXT,0,cand.time,cand.low);
         ObjectSetInteger(0,objtext,OBJPROP_ANCHOR,ANCHOR_LEFT);
         ObjectSetDouble(0,objtext,OBJPROP_ANGLE,-90);
        }
     }
   else
     {
      ObjectCreate(0,objname,OBJ_ARROW_SELL,0,cand.time,cand.high);
      ObjectSetInteger(0,objname,OBJPROP_ANCHOR,ANCHOR_BOTTOM);
      if(InpCommentOn)
        {
         ObjectCreate(0,objtext,OBJ_TEXT,0,cand.time,cand.high);
         ObjectSetInteger(0,objtext,OBJPROP_ANCHOR,ANCHOR_LEFT);
         ObjectSetDouble(0,objtext,OBJPROP_ANGLE,90);
        }
     }
   ObjectSetInteger(0,objname,OBJPROP_COLOR,Col);
   ObjectSetInteger(0,objname,OBJPROP_BACK,false);
   ObjectSetString(0,objname,OBJPROP_TEXT,comment);
   if(InpCommentOn)
     {
      ObjectSetInteger(0,objtext,OBJPROP_COLOR,Col);
      ObjectSetString(0,objtext,OBJPROP_FONT,"Tahoma");
      ObjectSetInteger(0,objtext,OBJPROP_FONTSIZE,InpTextFontSize);
      ObjectSetString(0,objtext,OBJPROP_TEXT,"    "+comment);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawSignal(string objname,CANDLE_STRUCTURE &cand1,CANDLE_STRUCTURE &cand2,color Col,string comment)
  {
   string objtext=objname+"text";
   double price_low=MathMin(cand1.low,cand2.low);
   double price_high=MathMax(cand1.high,cand2.high);

   if(ObjectFind(0,objtext)>=0) ObjectDelete(0,objtext);
   if(ObjectFind(0,objname)>=0) ObjectDelete(0,objname);
   if(InpAlert && cand2.time>=CurTime)
     {
      Alert(Symbol()," ",PeriodToString(_Period)," ",comment);
     }

   ObjectCreate(0,objname,OBJ_RECTANGLE,0,cand1.time,price_low,cand2.time,price_high);
   if(Col==InpColorBull)
     {
      if(InpCommentOn)
        {
         ObjectCreate(0,objtext,OBJ_TEXT,0,cand1.time,price_low);
         ObjectSetInteger(0,objtext,OBJPROP_ANCHOR,ANCHOR_LEFT);
         ObjectSetDouble(0,objtext,OBJPROP_ANGLE,-90);
        }
     }
   else
     {
      if(InpCommentOn)
        {
         ObjectCreate(0,objtext,OBJ_TEXT,0,cand1.time,price_high);
         ObjectSetInteger(0,objtext,OBJPROP_ANCHOR,ANCHOR_LEFT);
         ObjectSetDouble(0,objtext,OBJPROP_ANGLE,90);
        }
     }
   ObjectSetInteger(0,objname,OBJPROP_COLOR,Col);
   ObjectSetInteger(0,objname,OBJPROP_BACK,false);
   ObjectSetString(0,objname,OBJPROP_TEXT,comment);
   if(InpCommentOn)
     {
      ObjectSetInteger(0,objtext,OBJPROP_COLOR,Col);
      ObjectSetString(0,objtext,OBJPROP_FONT,"Tahoma");
      ObjectSetInteger(0,objtext,OBJPROP_FONTSIZE,InpTextFontSize);
      ObjectSetString(0,objtext,OBJPROP_TEXT,"    "+comment);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawSignal(string objname,CANDLE_STRUCTURE &cand1,CANDLE_STRUCTURE &cand2,CANDLE_STRUCTURE &cand3,color Col,string comment)
  {
   string objtext=objname+"text";
   double price_low=MathMin(cand1.low,MathMin(cand2.low,cand3.low));
   double price_high=MathMax(cand1.high,MathMax(cand2.high,cand3.high));

   if(ObjectFind(0,objtext)>=0) ObjectDelete(0,objtext);
   if(ObjectFind(0,objname)>=0) ObjectDelete(0,objname);
   if(InpAlert && cand3.time>=CurTime)
     {
      Alert(Symbol()," ",PeriodToString(_Period)," ",comment);
     }
   ObjectCreate(0,objname,OBJ_RECTANGLE,0,cand1.time,price_low,cand3.time,price_high);
   if(Col==InpColorBull)
     {
      if(InpCommentOn)
        {
         ObjectCreate(0,objtext,OBJ_TEXT,0,cand3.time,price_low);
         ObjectSetInteger(0,objtext,OBJPROP_ANCHOR,ANCHOR_LEFT);
         ObjectSetDouble(0,objtext,OBJPROP_ANGLE,-90);
        }
     }
   else
     {
      if(InpCommentOn)
        {
         ObjectCreate(0,objtext,OBJ_TEXT,0,cand3.time,price_high);
         ObjectSetInteger(0,objtext,OBJPROP_ANCHOR,ANCHOR_LEFT);
         ObjectSetDouble(0,objtext,OBJPROP_ANGLE,90);
        }
     }
   ObjectSetInteger(0,objname,OBJPROP_COLOR,Col);
   ObjectSetInteger(0,objname,OBJPROP_BACK,false);
   ObjectSetInteger(0,objname,OBJPROP_WIDTH,2);
   ObjectSetString(0,objname,OBJPROP_TEXT,comment);
   if(InpCommentOn)
     {
      ObjectSetInteger(0,objtext,OBJPROP_COLOR,Col);
      ObjectSetString(0,objtext,OBJPROP_FONT,"Tahoma");
      ObjectSetInteger(0,objtext,OBJPROP_FONTSIZE,InpTextFontSize);
      ObjectSetString(0,objtext,OBJPROP_TEXT,"    "+comment);
     }
  }
  
string PeriodToString(ENUM_TIMEFRAMES period)
  {
   switch(period)
     {
      case PERIOD_M1: return("M1");
      case PERIOD_M2: return("M2");
      case PERIOD_M3: return("M3");
      case PERIOD_M4: return("M4");
      case PERIOD_M5: return("M5");
      case PERIOD_M6: return("M6");
      case PERIOD_M10: return("M10");
      case PERIOD_M12: return("M12");
      case PERIOD_M15: return("M15");
      case PERIOD_M20: return("M20");
      case PERIOD_M30: return("M30");
      case PERIOD_H1: return("H1");
      case PERIOD_H2: return("H2");
      case PERIOD_H3: return("H3");
      case PERIOD_H4: return("H4");
      case PERIOD_H6: return("H6");
      case PERIOD_H8: return("H8");
      case PERIOD_H12: return("H12");
      case PERIOD_D1: return("D1");
      case PERIOD_W1: return("W1");
      case PERIOD_MN1: return("MN1");
     }
   return(NULL);
  };