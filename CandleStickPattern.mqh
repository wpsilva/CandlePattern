enum TYPE_CANDLESTICK
  {
   CAND_NONE,
   CAND_MARIBOZU,
   CAND_MARIBOZU_LONG,
   CAND_DOJI,
   CAND_SPIN_TOP,
   CAND_HAMMER,
   CAND_INVERT_HAMMER,
   CAND_LONG,
   CAND_SHORT,
   CAND_STAR
  };
  
enum TYPE_TREND
  {
   UPPER,
   DOWN,
   LATERAL
  }; 
  
struct CANDLE_STRUCTURE
  {
   double            open,high,low,close;
   datetime          time;
   TYPE_TREND       trend;
   bool              bull;
   double            bodysize;
   TYPE_CANDLESTICK  type;
  };

bool RecognizeCandle(datetime time,int aver_period,CANDLE_STRUCTURE &res)
{
   MqlRates rt[];
//--- Get data of previous candlesticks
   if(CopyRates(_Symbol,_Period,time,aver_period+1,rt)<aver_period)
     {
      return(false);
     }
     
   res.open=rt[aver_period].open;
   res.high=rt[aver_period].high;
   res.low=rt[aver_period].low;
   res.close=rt[aver_period].close;
   res.time=rt[aver_period].time;
   
   double aver=0;
   for(int i=0;i<aver_period;i++)
   {
      aver+=rt[i].close;
   }
   aver=aver/aver_period;
   
   if(aver<res.close) res.trend=UPPER;
   if(aver>res.close) res.trend=DOWN;
   if(aver==res.close) res.trend=LATERAL;
   
   //--- Define of it bullish or bearish
   res.bull=res.open<res.close;
//--- Get the absolute value of the candlestick body size
   res.bodysize=MathAbs(res.open-res.close);
//--- Get the size of shadows
   double shade_low=res.close-res.low;
   double shade_high=res.high-res.open;
   if(res.bull)
     {
      shade_low=res.open-res.low;
      shade_high=res.high-res.close;
     }
   double HL=res.high-res.low;
//--- Calculate the average body size of previous candlesticks
   double sum=0;
   for(int i=1; i<=aver_period; i++)
      sum=sum+MathAbs(rt[i].open-rt[i].close);
   sum=sum/aver_period;
   
   //--- long 
   if(res.bodysize>sum*1.3) res.type=CAND_LONG;
   //--- short 
   if(res.bodysize<sum*0.5) res.type=CAND_SHORT;
   //--- doji
   if(res.bodysize<HL*0.03) res.type=CAND_DOJI;
   //--- maribozu
   if((shade_low<res.bodysize*0.01 || shade_high<res.bodysize*0.01) && res.bodysize>0)
     {
      if(res.type==CAND_LONG)
         res.type=CAND_MARIBOZU_LONG;
      else
         res.type=CAND_MARIBOZU;
     }
     
     //--- hammer
   if(shade_low>res.bodysize*2 && shade_high<res.bodysize*0.1) res.type=CAND_HAMMER;
   //--- invert hammer
   if(shade_low<res.bodysize*0.1 && shade_high>res.bodysize*2) res.type=CAND_INVERT_HAMMER;
   //--- spinning top
   if(res.type==CAND_SHORT && shade_low>res.bodysize && shade_high>res.bodysize) res.type=CAND_SPIN_TOP;
   
    ArrayFree(rt);
   
   return true;
}