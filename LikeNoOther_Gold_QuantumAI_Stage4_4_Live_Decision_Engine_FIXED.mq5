//+------------------------------------------------------------------+
//| LikeNoOther Gold Quantum AI - Stage 4.4 Live Decision Engine |
//| Pure Price Action Structure Mapper                               |
//| No trading. Institutional heat-map visualization framework.       |
//+------------------------------------------------------------------+
#property strict
#property version   "5.000"
#property description "Stage 4.3: Institutional Decision Card. Shows one institutional opportunity card and one clean opportunity zone. Visual only."

input string Inp01_General                 = "===== GENERAL =====";
input string InpTradeSymbol                = "";          // Empty = current chart symbol
input ENUM_TIMEFRAMES InpStructureTF       = PERIOD_M5;   // Recommended: M5 for Stage 1 testing
input int    InpLookbackBars               = 700;         // Bars to scan
input bool   InpRunOnNewBarOnly            = true;        // Faster visual/backtest
input bool   InpPrintDebug                 = true;

input string Inp02_PivotEngine             = "===== 1) PIVOT ENGINE / MAJOR SWINGS =====";
input int    InpPivotLeftBars              = 4;           // Stronger pivot = fewer fake SH/SL
input int    InpPivotRightBars             = 4;           // No-repaint confirmation bars
input bool   InpOnlyMajorSwings            = true;        // Hide weak/internal pivots
input double InpMinSwingDistancePips       = 35.0;        // Minimum distance between internal swings
input double InpExternalSwingDistancePips  = 90.0;        // External/Major swing threshold
input bool   InpKeepInternalSwingsInMemory = true;        // Keep internal structure even if labels are hidden
input int    InpMaxSwingsStored            = 160;

input string Inp03_BOS_CHOCH               = "===== 2/3) BOS & CHOCH ENGINE =====";
input bool   InpUseCloseBreak              = true;        // true = close break, false = wick break
input double InpBreakBufferPips            = 3.0;         // Extra confirmation buffer
input int    InpMinBarsBetweenEvents       = 3;           // Prevent event spam
input bool   InpBreakMajorOnly             = true;        // BOS/CHOCH only on major swings

input string Inp04_Intelligence            = "===== 4/5) BIAS / STRUCTURE INTELLIGENCE =====";
input bool   InpShowStructureID            = true;        // Show BOS # / CHOCH #
input bool   InpShowStrength               = true;        // Show strength 0-100
input int    InpStrongSwingStrength        = 78;          // Strong/Weak swing threshold
input int    InpInstitutionalStrength      = 88;          // Strong BOS/CHOCH threshold
input bool   InpShowCandidateSwings        = false;       // Stage 4: cleaner visualization        // Show unconfirmed latest candidate swing
input bool   InpShowInternalStructure      = false;        // Draw internal structure lightly
input bool   InpShowExternalStructure      = true;        // Draw external structure strongly
input bool   InpUseExternalForMainBias     = true;        // Market bias follows external CHOCH/BOS first

input string Inp05_Visual                  = "===== VISUAL / PROFESSIONAL UI 2.0 =====";
input bool   InpDrawOnChart                = true;
input bool   InpClearObjectsOnInit         = true;
input bool   InpShowSwingLabels            = false;       // Stage 4: hide raw swing labels by default for institutional chart
input bool   InpShowBOS_CHOCH              = true;
input bool   InpShowLastStatePanel         = true;
input bool   InpDrawBrokenLevelLines       = true;
input color  InpSwingHighColor             = clrSilver;
input color  InpSwingLowColor              = clrSilver;
input color  InpBOSColor                   = clrMediumSeaGreen;
input color  InpCHOCHColor                 = clrDarkOrange;
input color  InpPanelColor                 = clrWhite;
input color  InpPanelBgColor               = clrMidnightBlue;
input color  InpCandidateColor             = clrSilver;
input color  InpInternalColor              = clrMediumSeaGreen;    // Internal structure color
input color  InpExternalColor              = clrGold;              // External structure color
input bool   InpSmartLabelPlacement        = true;                 // Reduce label overlap
input int    InpBaseLabelFontSize          = 7;                    // Swing/BOS font size
input int    InpCHOCHFontSize              = 9;                    // Bigger CHOCH label
input bool   InpUI20CompactMode            = true;                 // UI 2.0: short labels instead of long text
input int    InpShowLastEvents             = 2;                    // Stage 4: major recent events only                    // Only draw last N BOS/CHOCH events
input int    InpShowLastSwings             = 6;                    // Stage 4: only if swing labels enabled                   // Only draw last N swing labels
input bool   InpShowEventStrengthOnly      = true;                 // Hide IDs on chart, keep strength
input bool   InpShowLegend                 = false;                // Right-side compact legend (OFF by default for clean chart)
input bool   InpShowBottomStatusBar        = true;                 // Bottom status strip
input bool   InpShowPremiumDiscountPreview = true;                 // Preview from last external range
input bool   InpShowPremiumDiscountZones   = true;                 // Draw premium/discount rectangles
input color  InpEquilibriumColor           = clrDeepSkyBlue;
input color  InpPremiumColor               = clrFireBrick;        // Border color only by default
input color  InpDiscountColor              = clrSeaGreen;         // Border color only by default
input color  InpPremiumDiscountColor       = clrSlateGray;
input bool   InpPDZoneFill                 = false;               // Stage 3.10: border-only PD zones to avoid covering candles
input int    InpPDZoneBorderWidth          = 1;
input int    InpPDZoneProjectionBars       = 10;                 // Stage 3.10: very short ICT dealing range projection
input bool   InpShowPDZoneLabels           = false;               // UI 2.0: colors/lines explain zones, not text
input bool   InpShowProPanel               = true;                 // Professional status panel
input int    InpPanelWidth                 = 455;
input int    InpPanelHeight                = 485;


input string Inp06_Liquidity              = "===== STAGE 2) LIQUIDITY ENGINE =====";
input bool   InpShowLiquidity             = true;        // Draw liquidity levels
input bool   InpDetectEqualHighLow        = true;        // EQH/EQL from confirmed swings
input bool   InpDetectSessionLiquidity    = true;        // Asia / Previous Day / Previous Week
input double InpEqualTolerancePips        = 12.0;        // Max distance to group equal highs/lows
input int    InpEqualLookbackSwings       = 36;          // Swings used for EQH/EQL detection
input int    InpMinEqualTouches           = 2;           // Minimum touches to qualify
input double InpSweepBufferPips           = 4.0;         // Wick beyond level to mark swept
input int    InpAsiaStartHour             = 0;           // Server time
input int    InpAsiaEndHour               = 7;           // Server time, exclusive
input int    InpLiquidityProjectionBars   = 70;          // Stage 4: shorter projection to reduce clutter         // Level projection to the right
input int    InpShowLastLiquidityZones    = 2;           // Stage 4: only top liquidity levels          // Max zones drawn
input color  InpBuyLiquidityColor         = clrLimeGreen;       // IBL/EBL buy-side liquidity
input color  InpSellLiquidityColor        = clrTomato;          // ISL/ESL sell-side liquidity
input color  InpAsiaLiquidityColor        = clrGold;            // Asia High/Low
input color  InpPDLiquidityColor          = clrDodgerBlue;      // Previous Day High/Low
input color  InpWeeklyLiquidityColor      = clrMediumPurple;    // Previous Week High/Low
input color  InpSweptLiquidityColor       = clrDimGray;         // Swept/old liquidity
input bool   InpShowLiquidityStrength     = true;
input bool   InpUseStrengthWords          = true;               // High / Medium / Weak instead of numbers
input bool   InpShowLiquidityLegend       = true;               // Show IBL/ISL/EBL/ESL legend in panel
input bool   InpUseCompactLiquidityLabels  = true;               // Chart labels: EBL-H / ISL-M / PDH-W
input bool   InpShowLiquidityConfidence     = true;               // Stage 3 panel confidence: HIGH/MEDIUM/LOW

input string Inp07_Institutional           = "===== STAGE 3) INSTITUTIONAL ENGINE =====";
input bool   InpShowInstitutionalZones     = true;        // Draw Order Blocks + FVG zones
input bool   InpDetectOrderBlocks          = true;        // Detect OB from BOS/CHOCH displacement
input bool   InpDetectFVG                  = true;        // Detect Fair Value Gaps / Imbalance
input int    InpOBLookbackCandles          = 12;          // Opposite candle search before BOS/CHOCH
input int    InpFVGScanBars                = 240;         // Bars used to scan FVG
input double InpMinFVGSizePips             = 8.0;         // Ignore tiny imbalances
input double InpMinOBSizePips              = 10.0;        // Ignore tiny order blocks
input int    InpInstitutionalProjectionBars= 120;         // Zone projection to the right
input int    InpShowLastOBZones            = 1;           // Stage 4: high-probability zones only           // Max OB zones drawn
input int    InpShowLastFVGZones           = 1;          // Stage 4: high-probability zones only          // Max FVG zones drawn
input color  InpBullOBColor                = clrSeaGreen;
input color  InpBearOBColor                = clrFireBrick;
input color  InpBullFVGColor               = clrMediumSeaGreen;
input color  InpBearFVGColor               = clrIndianRed;
input color  InpMitigatedZoneColor         = clrDimGray;
input bool   InpFillInstitutionalZones     = false;       // false = clean border zones
input bool   InpShowInstitutionalPanel     = true;        // Add OB/FVG summary to panel
input bool   InpUseOBFVGForConfidence      = true;        // Boost Stage 3 confidence using OB/FVG context
input int    InpZoneLifetimeBars           = 300;         // Delete/ignore old OB/FVG zones after this many bars
input double InpClusterTolerancePips        = 35.0;        // OB/FVG + Liquidity cluster tolerance
input bool   InpShowMitigatedInstitutionalZones = true;    // Show mitigated OB/FVG as gray historical zones
input bool   InpShowInstitutionalClusters   = true;        // Mark OB/FVG + liquidity clusters
input bool   InpUseSmartInstitutionalConfidence = true;     // Smart confidence from structure/liquidity/OB/FVG/cluster
input bool   InpShowInstitutionalBias       = true;        // Show STRONG BUY/BUY/NEUTRAL/SELL/STRONG SELL
input int    InpMitigatedKeepBars           = 20;          // Keep mitigated zones gray for N bars, then delete/hide
input bool   InpSuppressOverlappedZones      = true;        // Show strongest zone when OB/FVG overlap
input bool   InpDrawClusterAsOneBox          = true;        // Draw one institutional cluster box instead of clutter
input color  InpClusterColor                 = clrGoldenrod;
input bool   InpShowSessionLiquidityZones    = true;        // Asia/London/NY session context
input int    InpLondonStartHour              = 8;
input int    InpLondonEndHour                = 12;
input int    InpNYStartHour                  = 13;
input int    InpNYEndHour                    = 17;
input bool   InpShowLiquidityTimeline        = true;        // Last BOS/CHOCH/OB/FVG timeline in panel
input bool   InpShowZoneProbability          = true;        // Show zone probability % on chart
input int    InpMinDrawZoneProbability      = 80;          // Stage 4: stricter institutional probability filter          // Stage 3.7: do not draw OB/FVG/Cluster zones below this probability
input int    InpMinDrawLiquidityProbability = 86;          // Stage 4: draw only premium liquidity levels          // Stage 3.7: do not draw liquidity levels below this probability
input bool   InpShowZoneProbabilityOnNewLine= true;        // Stage 3.7: cleaner probability label
input bool   InpDrawICTPremiumDiscountFill  = true;       // Stage 3.10: border-only PD zones; no heavy background
input bool   InpDrawTrueSessionBoxes        = true;        // Stage 3.7: Asia/London/NY session boxes
input int    InpPDZoneAlpha                 = 1;          // Stage 3.10: almost invisible if fill is enabled
input int    InpSessionBoxAlpha              = 0;          // Stage 3.10: sessions are border-only
input int    InpClusterBoxAlpha              = 18;          // Stage 4: visible heat-map cluster, still candle-friendly          // Stage 3.7: visible but not blocking candles
input int    InpZoneBoxAlpha                 = 12;          // Stage 4: subtle standalone zone fill          // Stage 3.7: institutional zones transparency
input bool   InpHideZoneMembersInsideCluster = true;        // Stage 3.8: cluster replaces OB/FVG/liquidity clutter
input int    InpRendererMaxVisibleZones      = 1;           // Stage 4: one non-cluster institutional zone max           // Stage 3.10: fewer non-cluster zones
input int    InpRendererClusterProjectionBars= 26;          // Stage 4: compact heat zone projection          // Stage 3.10: compact cluster projection
input int    InpRendererZoneProjectionBars   = 14;          // Stage 4: compact zone projection          // Stage 3.10: compact zone projection
input int    InpRendererClusterMaxHeightPips= 32;          // Stage 4: precise institutional cluster height cap          // Stage 3.10: cap cluster height so it never covers half chart
input int    InpRendererDealingRangeMaxBars = 48;          // Stage 4: last dealing range only          // Stage 3.10: PD range may not cover more than this many bars
input bool   InpRendererHidePDWhenCluster    = false;        // Stage 3.10: do not draw PD fill over active cluster

string   g_symbol;
double   g_pip;
datetime g_lastBarTime=0;
string   g_prefix="LNO_QAI_V2_";

struct SwingPoint
{
   int      id;
   datetime time;
   double   price;
   int      shift;
   bool     isHigh;
   bool     broken;
   bool     major;     // internal quality threshold
   int      level;     // 2 external, 1 internal, 0 minor
   bool     confirmed;
   bool     strong;
   int      strength;
};

struct StructureEvent
{
   int      id;
   datetime time;
   double   price;
   int      shift;
   int      dir;       // 1 bull, -1 bear
   bool     isChoch;
   int      swingId;
   bool     major;
   int      level;     // 2 external, 1 internal
   int      strength;
};

SwingPoint     g_swings[];
StructureEvent g_events[];

enum ENUM_LNO_LIQ_TYPE
{
   LNO_LIQ_EQH=0,
   LNO_LIQ_EQL=1,
   LNO_LIQ_BSL=2,
   LNO_LIQ_SSL=3,
   LNO_LIQ_ASIA_H=4,
   LNO_LIQ_ASIA_L=5,
   LNO_LIQ_PDH=6,
   LNO_LIQ_PDL=7,
   LNO_LIQ_PWH=8,
   LNO_LIQ_PWL=9
};

struct LiquidityZone
{
   int      id;
   int      type;
   datetime time1;
   datetime time2;
   double   price;
   int      touches;
   bool     swept;
   datetime sweptTime;
   int      strength;
   bool     external;
};

LiquidityZone g_liquidity[];
int g_nextLiquidityId=1;
int g_activeBuyLiquidity=0;
int g_activeSellLiquidity=0;

enum ENUM_LNO_ZONE_TYPE
{
   LNO_ZONE_BULL_OB=0,
   LNO_ZONE_BEAR_OB=1,
   LNO_ZONE_BULL_FVG=2,
   LNO_ZONE_BEAR_FVG=3
};

struct InstitutionalZone
{
   int      id;
   int      type;
   datetime time1;
   datetime time2;
   double   top;
   double   bottom;
   int      strength;
   bool     mitigated;
   datetime mitigatedTime;
   bool     external;
   int      sourceEventId;
};

InstitutionalZone g_instZones[];
int g_nextInstZoneId=1;
int g_activeBullOB=0;
int g_activeBearOB=0;
int g_activeBullFVG=0;
int g_activeBearFVG=0;


int g_bias=0;              // 1 bullish, -1 bearish, 0 unknown/ranging
string g_lastEvent="NONE";
int g_lastBOSId=0;
int g_lastCHOCHId=0;
int g_nextSwingId=1;
int g_nextEventId=1;
int g_externalBias=0;
int g_internalBias=0;
int g_lastStrongHighId=0;
int g_lastStrongLowId=0;

// Stage 3.9 Unified Renderer state.
// Every module detects only; the renderer decides what is finally visible.
double g_renderClusterTops[];
double g_renderClusterBottoms[];
bool   g_renderClusterBulls[];
int    g_renderClusterCount=0;

//+------------------------------------------------------------------+
double PipSize()
{
   double point=SymbolInfoDouble(g_symbol,SYMBOL_POINT);
   int digits=(int)SymbolInfoInteger(g_symbol,SYMBOL_DIGITS);
   if(StringFind(g_symbol,"XAU")>=0 || StringFind(g_symbol,"GOLD")>=0) return 0.10;
   if(digits==3 || digits==5) return point*10.0;
   return point;
}

bool IsNewBar()
{
   datetime t=iTime(g_symbol,InpStructureTF,0);
   if(t!=g_lastBarTime)
   {
      g_lastBarTime=t;
      return true;
   }
   return false;
}

void DeleteObjects()
{
   int total=ObjectsTotal(0,0,-1);
   for(int i=total-1;i>=0;i--)
   {
      string name=ObjectName(0,i,0,-1);
      if(StringFind(name,g_prefix)==0) ObjectDelete(0,name);
   }
}

void DrawTextEx(string name, datetime t, double p, string txt, color clr, int anchor=ANCHOR_CENTER, int fontSize=8)
{
   if(!InpDrawOnChart) return;
   if(ObjectFind(0,name)>=0) ObjectDelete(0,name);
   ObjectCreate(0,name,OBJ_TEXT,0,t,p);
   ObjectSetString(0,name,OBJPROP_TEXT,txt);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontSize);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,anchor);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,30);
}

void DrawLineEx(string name, datetime t1, double p1, datetime t2, double p2, color clr, int style=STYLE_SOLID, int width=1)
{
   if(!InpDrawOnChart) return;
   if(ObjectFind(0,name)>=0) ObjectDelete(0,name);
   ObjectCreate(0,name,OBJ_TREND,0,t1,p1,t2,p2);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_STYLE,style);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,false);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,10);
}

color AlphaColor(color clr,int alpha)
{
   if(alpha<0) alpha=0;
   if(alpha>255) alpha=255;
   return (color)ColorToARGB(clr,(uchar)alpha);
}

void DrawRectEx(string name, datetime t1, double p1, datetime t2, double p2, color clr, bool back=true, bool fill=true, int width=1)
{
   if(!InpDrawOnChart) return;
   if(ObjectFind(0,name)>=0) ObjectDelete(0,name);
   ObjectCreate(0,name,OBJ_RECTANGLE,0,t1,p1,t2,p2);
   color useClr=clr;
   if(fill && back) useClr=AlphaColor(clr,InpZoneBoxAlpha);
   ObjectSetInteger(0,name,OBJPROP_COLOR,useClr);
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(0,name,OBJPROP_BACK,back);
   ObjectSetInteger(0,name,OBJPROP_FILL,fill);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,(back?0:15));
}

void DrawRectStyledEx(string name, datetime t1, double p1, datetime t2, double p2, color clr, int style=STYLE_SOLID, bool back=true, bool fill=true, int width=1)
{
   if(!InpDrawOnChart) return;
   if(ObjectFind(0,name)>=0) ObjectDelete(0,name);
   ObjectCreate(0,name,OBJ_RECTANGLE,0,t1,p1,t2,p2);
   color useClr=clr;
   if(fill && back) useClr=AlphaColor(clr,InpZoneBoxAlpha);
   ObjectSetInteger(0,name,OBJPROP_COLOR,useClr);
   ObjectSetInteger(0,name,OBJPROP_STYLE,style);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(0,name,OBJPROP_BACK,back);
   ObjectSetInteger(0,name,OBJPROP_FILL,fill);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,(back?1:16));
}


int LabelLane(int id, int maxLane=4)
{
   if(!InpSmartLabelPlacement) return 0;
   if(maxLane<1) maxLane=1;
   // Prime multiplier spreads nearby IDs across lanes better than id%lane.
   return ((id*7 + 3) % maxLane);
}

string ShortPowerTag(int strength)
{
   if(strength>=InpInstitutionalStrength) return "INST";
   if(strength>=75) return "STR";
   return "WK";
}


string BiasText(int bias)
{
   if(bias>0) return "BULLISH";
   if(bias<0) return "BEARISH";
   return "RANGING";
}

color BiasColor(int bias)
{
   if(bias>0) return clrLimeGreen;
   if(bias<0) return clrTomato;
   return clrSilver;
}

string BiasArrowText(int bias)
{
   if(bias>0) return "^ Bullish";
   if(bias<0) return "v Bearish";
   return "- Ranging";
}

string PhaseText()
{
   if(g_externalBias>0 && g_internalBias<0) return "Bull Pullback";
   if(g_externalBias<0 && g_internalBias>0) return "Bear Pullback";
   if(g_externalBias>0 && g_internalBias>0) return "Bull Expansion";
   if(g_externalBias<0 && g_internalBias<0) return "Bear Expansion";
   return "Waiting";
}

color PhaseColor(const string phase)
{
   if(phase=="Bull Expansion") return clrLimeGreen;
   if(phase=="Bull Pullback")  return clrDeepSkyBlue;
   if(phase=="Bear Expansion") return clrTomato;
   if(phase=="Bear Pullback")  return clrDarkOrange;
   return clrSilver;
}

int PercentOf(const int part,const int total)
{
   if(total<=0) return 0;
   return (int)MathRound(100.0*part/total);
}

int FindSwingById(int swingId)
{
   for(int i=0;i<ArraySize(g_swings);i++)
      if(g_swings[i].id==swingId) return i;
   return -1;
}

string CompactSwingLabel(const SwingPoint &sw)
{
   string s="";
   if(sw.level>=2) s+="EXT ";
   else if(sw.level==1) s+="INT ";
   else s+="MIN ";
   s += (sw.isHigh ? "SH" : "SL");
   if(sw.strong) s = "S-"+s; else s = "W-"+s;
   if(InpShowEventStrengthOnly || !InpShowStructureID)
      s += " "+IntegerToString(sw.strength);
   else
      s += " #"+IntegerToString(sw.id)+" "+IntegerToString(sw.strength);
   return s;
}

string CompactEventLabel(const StructureEvent &ev)
{
   string s=(ev.level>=2 ? "EXT " : "INT ");
   s += (ev.isChoch ? "CH" : "BOS");
   s += (ev.dir>0 ? "^" : "v");
   if(InpShowEventStrengthOnly || !InpShowStructureID)
      s += " "+IntegerToString(ev.strength);
   else
      s += " #"+IntegerToString(ev.id)+" "+IntegerToString(ev.strength);
   return s;
}


bool IsPivotHigh(int shift)
{
   double h=iHigh(g_symbol,InpStructureTF,shift);
   for(int i=1;i<=InpPivotLeftBars;i++)  if(iHigh(g_symbol,InpStructureTF,shift+i)>=h) return false;
   for(int j=1;j<=InpPivotRightBars;j++) if(iHigh(g_symbol,InpStructureTF,shift-j)>h)  return false;
   return true;
}

bool IsPivotLow(int shift)
{
   double l=iLow(g_symbol,InpStructureTF,shift);
   for(int i=1;i<=InpPivotLeftBars;i++)  if(iLow(g_symbol,InpStructureTF,shift+i)<=l) return false;
   for(int j=1;j<=InpPivotRightBars;j++) if(iLow(g_symbol,InpStructureTF,shift-j)<l)  return false;
   return true;
}


bool IsCandidateHigh(int shift)
{
   double h=iHigh(g_symbol,InpStructureTF,shift);
   for(int i=1;i<=InpPivotLeftBars;i++) if(iHigh(g_symbol,InpStructureTF,shift+i)>=h) return false;
   for(int j=1;j<shift;j++) if(iHigh(g_symbol,InpStructureTF,shift-j)>h) return false;
   return true;
}

bool IsCandidateLow(int shift)
{
   double l=iLow(g_symbol,InpStructureTF,shift);
   for(int i=1;i<=InpPivotLeftBars;i++) if(iLow(g_symbol,InpStructureTF,shift+i)<=l) return false;
   for(int j=1;j<shift;j++) if(iLow(g_symbol,InpStructureTF,shift-j)<l) return false;
   return true;
}

double AvgRangePips(int fromShift,int barsCount)
{
   double sum=0; int c=0; int bars=Bars(g_symbol,InpStructureTF);
   for(int i=fromShift;i<fromShift+barsCount && i<bars;i++)
   {
      sum+=(iHigh(g_symbol,InpStructureTF,i)-iLow(g_symbol,InpStructureTF,i))/g_pip;
      c++;
   }
   if(c<=0) return 1.0;
   return MathMax(1.0,sum/c);
}

int SwingStrength(double distPips, int pivotPower, bool major)
{
   // Wider dynamic range: weak internal swing can be 35-55, institutional external swing can be 88-100.
   int s=25;
   s += (int)MathMin(45.0, distPips/1.35);      // prominence is the main factor
   s += (int)MathMin(12.0, pivotPower*1.2);      // confirmation bars
   if(major) s+=14;
   if(distPips>=InpMinSwingDistancePips*3.0) s+=8;
   if(s>100) s=100;
   if(s<1) s=1;
   return s;
}

void PushSwing(datetime t,double price,int shift,bool isHigh,bool major,int level,int strength)
{
   int n=ArraySize(g_swings);
   ArrayResize(g_swings,n+1);
   g_swings[n].id=g_nextSwingId++;
   g_swings[n].time=t;
   g_swings[n].price=price;
   g_swings[n].shift=shift;
   g_swings[n].isHigh=isHigh;
   g_swings[n].broken=false;
   g_swings[n].major=major;
   g_swings[n].level=level;
   g_swings[n].confirmed=true;
   g_swings[n].strong=(strength>=InpStrongSwingStrength);
   g_swings[n].strength=strength;
   if(g_swings[n].strong && g_swings[n].isHigh) g_lastStrongHighId=g_swings[n].id;
   if(g_swings[n].strong && !g_swings[n].isHigh) g_lastStrongLowId=g_swings[n].id;

   if(ArraySize(g_swings)>InpMaxSwingsStored)
   {
      for(int i=1;i<ArraySize(g_swings);i++) g_swings[i-1]=g_swings[i];
      ArrayResize(g_swings,InpMaxSwingsStored);
   }
}

void DetectSwings()
{
   ArrayResize(g_swings,0);
   g_nextSwingId=1;
   g_lastStrongHighId=0;
   g_lastStrongLowId=0;

   int bars=Bars(g_symbol,InpStructureTF);
   int maxScan=MathMin(InpLookbackBars,bars-InpPivotRightBars-2);
   int end=InpPivotRightBars+1;

   // Temporary raw swings, still chronological old -> new
   SwingPoint raw[];
   int rid=1;
   for(int shift=maxScan; shift>=end; shift--)
   {
      bool ph=IsPivotHigh(shift);
      bool pl=IsPivotLow(shift);
      if(!ph && !pl) continue;

      if(ph)
      {
         int n=ArraySize(raw); ArrayResize(raw,n+1);
         raw[n].id=rid++; raw[n].time=iTime(g_symbol,InpStructureTF,shift); raw[n].price=iHigh(g_symbol,InpStructureTF,shift);
         raw[n].shift=shift; raw[n].isHigh=true; raw[n].broken=false; raw[n].major=false; raw[n].level=0; raw[n].confirmed=true; raw[n].strong=false; raw[n].strength=50;
      }
      if(pl)
      {
         int n=ArraySize(raw); ArrayResize(raw,n+1);
         raw[n].id=rid++; raw[n].time=iTime(g_symbol,InpStructureTF,shift); raw[n].price=iLow(g_symbol,InpStructureTF,shift);
         raw[n].shift=shift; raw[n].isHigh=false; raw[n].broken=false; raw[n].major=false; raw[n].level=0; raw[n].confirmed=true; raw[n].strong=false; raw[n].strength=50;
      }
   }

   // Real pivot engine: alternating swings only. If same type appears, keep the more extreme one.
   SwingPoint filtered[];
   for(int i=0;i<ArraySize(raw);i++)
   {
      int n=ArraySize(filtered);
      if(n==0)
      {
         ArrayResize(filtered,1); filtered[0]=raw[i];
         continue;
      }
      if(filtered[n-1].isHigh==raw[i].isHigh)
      {
         if(raw[i].isHigh && raw[i].price>filtered[n-1].price) filtered[n-1]=raw[i];
         if(!raw[i].isHigh && raw[i].price<filtered[n-1].price) filtered[n-1]=raw[i];
      }
      else
      {
         double dist=MathAbs(raw[i].price-filtered[n-1].price)/g_pip;
         if(InpOnlyMajorSwings && dist<InpMinSwingDistancePips)
         {
            // Too small. Ignore the new weak opposite pivot.
            continue;
         }
         ArrayResize(filtered,n+1); filtered[n]=raw[i];
      }
   }

   for(int k=0;k<ArraySize(filtered);k++)
   {
      double distPips=InpMinSwingDistancePips;
      if(k>0) distPips=MathAbs(filtered[k].price-filtered[k-1].price)/g_pip;
      bool internal=(distPips>=InpMinSwingDistancePips);
      bool external=(distPips>=InpExternalSwingDistancePips);
      int level=(external?2:(internal?1:0));
      bool major=(level>=1);
      int strength=SwingStrength(distPips,InpPivotLeftBars+InpPivotRightBars,external);
      // Stage 1.8 keeps useful internal levels in memory, but external levels are the main bias anchors.
      if(!InpOnlyMajorSwings || major || InpKeepInternalSwingsInMemory)
         PushSwing(filtered[k].time,filtered[k].price,filtered[k].shift,filtered[k].isHigh,major,level,strength);
   }
}

int FindBreakCandidate(bool breakHigh,int barShift,double close,double high,double low,double buffer)
{
   // Latest unbroken swing that is older than the break bar, only one candidate to avoid repeated BOS spam.
   for(int i=ArraySize(g_swings)-1;i>=0;i--)
   {
      if(g_swings[i].broken) continue;
      if(InpBreakMajorOnly && !g_swings[i].major) continue;
      if(g_swings[i].shift<=barShift) continue; // swing must be older than current bar
      if(breakHigh && g_swings[i].isHigh)
      {
         bool broke = InpUseCloseBreak ? (close > g_swings[i].price + buffer) : (high > g_swings[i].price + buffer);
         if(broke) return i;
      }
      if(!breakHigh && g_swings[i].isHigh==false)
      {
         bool broke = InpUseCloseBreak ? (close < g_swings[i].price - buffer) : (low < g_swings[i].price - buffer);
         if(broke) return i;
      }
   }
   return -1;
}

int EventStrength(int swingIndex,int barShift,int dir)
{
   double open=iOpen(g_symbol,InpStructureTF,barShift);
   double close=iClose(g_symbol,InpStructureTF,barShift);
   double high=iHigh(g_symbol,InpStructureTF,barShift);
   double low=iLow(g_symbol,InpStructureTF,barShift);
   double body=MathAbs(close-open)/g_pip;
   double range=(high-low)/g_pip;
   double avg=AvgRangePips(barShift+1,20);
   double over=0;
   if(dir>0) over=(close-g_swings[swingIndex].price)/g_pip;
   else      over=(g_swings[swingIndex].price-close)/g_pip;
   double closeLocation=0.5;
   if(range>0)
   {
      if(dir>0) closeLocation=(close-low)/(high-low);
      else      closeLocation=(high-close)/(high-low);
   }

   int s=22;
   s+=(int)MathMin(24.0, (body/MathMax(1.0,avg))*18.0);       // impulse body vs local average
   s+=(int)MathMin(18.0, (range/MathMax(1.0,avg))*10.0);      // expansion
   s+=(int)MathMin(20.0, MathMax(0.0,over)*3.0);              // clean close beyond level
   s+=(int)MathMin(14.0, g_swings[swingIndex].strength/7.0);  // quality of broken level
   s+=(int)MathMin(12.0, closeLocation*12.0);                 // close near extreme
   if(g_swings[swingIndex].strong) s+=8;
   if(g_swings[swingIndex].major) s+=6;
   if(s>100) s=100;
   if(s<1) s=1;
   return s;
}

void PushEvent(datetime t,double price,int shift,int dir,bool isChoch,int swingIndex,int strength)
{
   int n=ArraySize(g_events);
   ArrayResize(g_events,n+1);
   g_events[n].id=g_nextEventId++;
   g_events[n].time=t;
   g_events[n].price=price;
   g_events[n].shift=shift;
   g_events[n].dir=dir;
   g_events[n].isChoch=isChoch;
   g_events[n].swingId=g_swings[swingIndex].id;
   g_events[n].major=g_swings[swingIndex].major;
   g_events[n].level=g_swings[swingIndex].level;
   g_events[n].strength=strength;

   if(isChoch) g_lastCHOCHId=g_events[n].id;
   else        g_lastBOSId=g_events[n].id;

   string dirTxt=(dir>0?"BULL":"BEAR");
   g_lastEvent=(isChoch?"CHOCH ":"BOS ")+dirTxt+" #"+IntegerToString(g_events[n].id);
}


string LiquidityTypeText(int type)
{
   if(type==LNO_LIQ_EQH) return "EQH";
   if(type==LNO_LIQ_EQL) return "EQL";
   if(type==LNO_LIQ_BSL) return "BSL";
   if(type==LNO_LIQ_SSL) return "SSL";
   if(type==LNO_LIQ_ASIA_H) return "ASIA H";
   if(type==LNO_LIQ_ASIA_L) return "ASIA L";
   if(type==LNO_LIQ_PDH) return "PDH";
   if(type==LNO_LIQ_PDL) return "PDL";
   if(type==LNO_LIQ_PWH) return "PWH";
   if(type==LNO_LIQ_PWL) return "PWL";
   return "LIQ";
}

bool IsBuySideLiquidity(int type)
{
   return (type==LNO_LIQ_EQH || type==LNO_LIQ_BSL || type==LNO_LIQ_ASIA_H || type==LNO_LIQ_PDH || type==LNO_LIQ_PWH);
}

int LiquidityStrength(int type,int touches,bool external,bool swept)
{
   int s=35;
   if(type==LNO_LIQ_EQH || type==LNO_LIQ_EQL) s+=20;
   if(type==LNO_LIQ_ASIA_H || type==LNO_LIQ_ASIA_L) s+=14;
   if(type==LNO_LIQ_PDH || type==LNO_LIQ_PDL) s+=18;
   if(type==LNO_LIQ_PWH || type==LNO_LIQ_PWL) s+=24;
   s += (int)MathMin(24,(touches-1)*9);
   if(external) s+=12;
   if(swept) s-=28;
   if(s>100) s=100;
   if(s<1) s=1;
   return s;
}

string StrengthWord(int strength)
{
   if(strength>=80) return "High";
   if(strength>=55) return "Medium";
   return "Weak";
}

string StrengthInitial(int strength)
{
   if(strength>=80) return "H";
   if(strength>=55) return "M";
   return "W";
}

color StrengthColor(int strength)
{
   // Stage 2.4 strength color hierarchy:
   // High = bright green, Medium = gold, Weak = soft orange/red.
   if(strength>=80) return clrLime;
   if(strength>=55) return clrGold;
   return clrOrangeRed;
}

string LiquidityCode(const LiquidityZone &z)
{
   // IBL/ISL/EBL/ESL are used for structure liquidity.
   if(z.type==LNO_LIQ_EQH || z.type==LNO_LIQ_BSL) return (z.external ? "EBL" : "IBL"); // External/Internal Buy Liquidity
   if(z.type==LNO_LIQ_EQL || z.type==LNO_LIQ_SSL) return (z.external ? "ESL" : "ISL"); // External/Internal Sell Liquidity
   if(z.type==LNO_LIQ_ASIA_H) return "Asia H";
   if(z.type==LNO_LIQ_ASIA_L) return "Asia L";
   if(z.type==LNO_LIQ_PDH)    return "PDH";
   if(z.type==LNO_LIQ_PDL)    return "PDL";
   if(z.type==LNO_LIQ_PWH)    return "PWH";
   if(z.type==LNO_LIQ_PWL)    return "PWL";
   return "LIQ";
}

string LiquidityStrengthText(const LiquidityZone &z)
{
   if(!InpShowLiquidityStrength) return "";
   if(InpUseStrengthWords) return StrengthWord(z.strength);
   return IntegerToString(z.strength);
}

color LiquidityDisplayColor(const LiquidityZone &z)
{
   if(z.swept) return InpSweptLiquidityColor;

   // Stage 2.4: chart liquidity color follows strength for instant reading.
   // The label code still identifies the source/type: IBL, ISL, EBL, ESL, Asia H/L, PDH/PDL, PWH/PWL.
   return StrengthColor(z.strength);
}

int StrongestLiquidityIndex(bool buySide)
{
   int best=-1;
   for(int i=0;i<ArraySize(g_liquidity);i++)
   {
      if(g_liquidity[i].swept) continue;
      if(IsBuySideLiquidity(g_liquidity[i].type)!=buySide) continue;
      if(best<0 || g_liquidity[i].strength>g_liquidity[best].strength) best=i;
   }
   return best;
}

string StrongestLiquidityText(bool buySide)
{
   int best=StrongestLiquidityIndex(buySide);
   if(best<0) return "None";
   return LiquidityCode(g_liquidity[best])+" ("+StrengthWord(g_liquidity[best].strength)+")";
}

color StrongestLiquidityColor(bool buySide)
{
   int best=StrongestLiquidityIndex(buySide);
   if(best<0) return clrSilver;
   return StrengthColor(g_liquidity[best].strength);
}

int LastSweepIndex()
{
   int best=-1;
   for(int i=0;i<ArraySize(g_liquidity);i++)
   {
      if(!g_liquidity[i].swept) continue;
      if(best<0 || g_liquidity[i].sweptTime>g_liquidity[best].sweptTime) best=i;
   }
   return best;
}

int LastSweepBarsAgo()
{
   int idx=LastSweepIndex();
   if(idx<0 || g_liquidity[idx].sweptTime<=0) return -1;
   int shift=iBarShift(g_symbol,InpStructureTF,g_liquidity[idx].sweptTime,false);
   return shift;
}

string LastSweepText()
{
   int best=LastSweepIndex();
   if(best<0) return "None";
   int barsAgo=LastSweepBarsAgo();
   string ago=(barsAgo>=0 ? " | "+IntegerToString(barsAgo)+" bars ago" : "");
   return LiquidityCode(g_liquidity[best])+" ("+StrengthWord(g_liquidity[best].strength)+")"+ago;
}

color LastSweepColor()
{
   int best=LastSweepIndex();
   if(best<0) return clrSilver;
   return StrengthColor(g_liquidity[best].strength);
}

int LiquidityConfidenceScore()
{
   int score=35;
   int active=g_activeBuyLiquidity+g_activeSellLiquidity;
   if(g_externalBias!=0 && g_externalBias==g_internalBias) score+=18;
   if(active>=8) score+=16; else if(active>=5) score+=10; else if(active>=3) score+=5;
   int nb=StrongestLiquidityIndex(true);
   int ns=StrongestLiquidityIndex(false);
   int mx=0;
   if(nb>=0) mx=MathMax(mx,g_liquidity[nb].strength);
   if(ns>=0) mx=MathMax(mx,g_liquidity[ns].strength);
   if(mx>=80) score+=18; else if(mx>=55) score+=10;
   int ls=LastSweepIndex();
   if(ls>=0)
   {
      int b=LastSweepBarsAgo();
      if(b>=0 && b<=12) score+=13; else score+=7;
   }
   if(score>100) score=100;
   if(score<1) score=1;
   return score;
}

string LiquidityConfidenceText()
{
   int s=LiquidityConfidenceScore();
   if(s>=80) return "HIGH";
   if(s>=55) return "MEDIUM";
   return "LOW";
}

color LiquidityConfidenceColor()
{
   int s=LiquidityConfidenceScore();
   if(s>=80) return clrLime;
   if(s>=55) return clrGold;
   return clrOrangeRed;
}


bool SameLiquidityExists(int type,double price,double tol)
{
   for(int i=0;i<ArraySize(g_liquidity);i++)
   {
      if(g_liquidity[i].type!=type) continue;
      if(MathAbs(g_liquidity[i].price-price)<=tol) return true;
   }
   return false;
}

void PushLiquidity(int type,datetime t1,datetime t2,double price,int touches,bool external)
{
   double tol=InpEqualTolerancePips*g_pip;
   if(SameLiquidityExists(type,price,tol*0.60)) return;
   int n=ArraySize(g_liquidity);
   ArrayResize(g_liquidity,n+1);
   g_liquidity[n].id=g_nextLiquidityId++;
   g_liquidity[n].type=type;
   g_liquidity[n].time1=t1;
   g_liquidity[n].time2=t2;
   g_liquidity[n].price=price;
   g_liquidity[n].touches=touches;
   g_liquidity[n].swept=false;
   g_liquidity[n].sweptTime=0;
   g_liquidity[n].external=external;
   g_liquidity[n].strength=LiquidityStrength(type,touches,external,false);
}

void MarkLiquiditySweeps()
{
   double buffer=InpSweepBufferPips*g_pip;
   int bars=Bars(g_symbol,InpStructureTF);
   for(int z=0; z<ArraySize(g_liquidity); z++)
   {
      int startShift=iBarShift(g_symbol,InpStructureTF,g_liquidity[z].time2,true);
      if(startShift<0) startShift=iBarShift(g_symbol,InpStructureTF,g_liquidity[z].time2,false);
      if(startShift<0) continue;
      bool buySide=IsBuySideLiquidity(g_liquidity[z].type);
      for(int sh=startShift-1; sh>=1 && sh<bars; sh--)
      {
         double h=iHigh(g_symbol,InpStructureTF,sh);
         double l=iLow(g_symbol,InpStructureTF,sh);
         if(buySide && h>g_liquidity[z].price+buffer)
         {
            g_liquidity[z].swept=true;
            g_liquidity[z].sweptTime=iTime(g_symbol,InpStructureTF,sh);
            break;
         }
         if(!buySide && l<g_liquidity[z].price-buffer)
         {
            g_liquidity[z].swept=true;
            g_liquidity[z].sweptTime=iTime(g_symbol,InpStructureTF,sh);
            break;
         }
      }
      g_liquidity[z].strength=LiquidityStrength(g_liquidity[z].type,g_liquidity[z].touches,g_liquidity[z].external,g_liquidity[z].swept);
   }
}

void DetectEqualHighLowLiquidity()
{
   if(!InpDetectEqualHighLow) return;
   double tol=InpEqualTolerancePips*g_pip;
   int n=ArraySize(g_swings);
   int first=0;
   if(InpEqualLookbackSwings>0 && n>InpEqualLookbackSwings) first=n-InpEqualLookbackSwings;

   for(int i=first;i<n;i++)
   {
      if(g_swings[i].level==0) continue;
      int touches=1;
      datetime t1=g_swings[i].time, t2=g_swings[i].time;
      double sum=g_swings[i].price;
      bool external=(g_swings[i].level>=2);
      for(int j=i+1;j<n;j++)
      {
         if(g_swings[j].level==0) continue;
         if(g_swings[j].isHigh!=g_swings[i].isHigh) continue;
         if(MathAbs(g_swings[j].price-g_swings[i].price)<=tol)
         {
            touches++;
            sum+=g_swings[j].price;
            if(g_swings[j].time<t1) t1=g_swings[j].time;
            if(g_swings[j].time>t2) t2=g_swings[j].time;
            if(g_swings[j].level>=2) external=true;
         }
      }
      if(touches>=InpMinEqualTouches)
      {
         double price=sum/touches;
         int typ=(g_swings[i].isHigh?LNO_LIQ_EQH:LNO_LIQ_EQL);
         PushLiquidity(typ,t1,t2,price,touches,external);
      }
   }
}

void DetectSessionLiquidity()
{
   if(!InpDetectSessionLiquidity) return;
   int bars=Bars(g_symbol,InpStructureTF);
   if(bars<50) return;
   datetime now=iTime(g_symbol,InpStructureTF,0);
   datetime d0=iTime(g_symbol,PERIOD_D1,0);
   datetime d1=iTime(g_symbol,PERIOD_D1,1);
   datetime w1=iTime(g_symbol,PERIOD_W1,1);

   // Previous day and week levels from higher timeframe data.
   double pdh=iHigh(g_symbol,PERIOD_D1,1), pdl=iLow(g_symbol,PERIOD_D1,1);
   if(pdh>0 && pdl>0 && d1>0)
   {
      PushLiquidity(LNO_LIQ_PDH,d1,d0,pdh,1,true);
      PushLiquidity(LNO_LIQ_PDL,d1,d0,pdl,1,true);
   }
   double pwh=iHigh(g_symbol,PERIOD_W1,1), pwl=iLow(g_symbol,PERIOD_W1,1);
   datetime w0=iTime(g_symbol,PERIOD_W1,0);
   if(pwh>0 && pwl>0 && w1>0)
   {
      PushLiquidity(LNO_LIQ_PWH,w1,w0,pwh,1,true);
      PushLiquidity(LNO_LIQ_PWL,w1,w0,pwl,1,true);
   }

   // Current-day Asia range from server time.
   if(d0<=0) return;
   double ah=-DBL_MAX, al=DBL_MAX;
   datetime at1=0, at2=0;
   for(int sh=1; sh<bars; sh++)
   {
      datetime bt=iTime(g_symbol,InpStructureTF,sh);
      if(bt<d0) break;
      MqlDateTime st; TimeToStruct(bt,st);
      if(st.hour>=InpAsiaStartHour && st.hour<InpAsiaEndHour)
      {
         double h=iHigh(g_symbol,InpStructureTF,sh), l=iLow(g_symbol,InpStructureTF,sh);
         if(h>ah) ah=h;
         if(l<al) al=l;
         if(at1==0 || bt<at1) at1=bt;
         if(at2==0 || bt>at2) at2=bt;
      }
   }
   if(at1>0 && ah>-DBL_MAX && al<DBL_MAX)
   {
      PushLiquidity(LNO_LIQ_ASIA_H,at1,at2,ah,1,false);
      PushLiquidity(LNO_LIQ_ASIA_L,at1,at2,al,1,false);
   }
}

void DetectLiquidity()
{
   ArrayResize(g_liquidity,0);
   g_nextLiquidityId=1;
   g_activeBuyLiquidity=0;
   g_activeSellLiquidity=0;
   DetectEqualHighLowLiquidity();
   DetectSessionLiquidity();
   MarkLiquiditySweeps();
   for(int i=0;i<ArraySize(g_liquidity);i++)
   {
      if(g_liquidity[i].swept) continue;
      if(IsBuySideLiquidity(g_liquidity[i].type)) g_activeBuyLiquidity++;
      else g_activeSellLiquidity++;
   }
}


bool IsBullishZoneType(const int type)
{
   return(type==LNO_ZONE_BULL_OB || type==LNO_ZONE_BULL_FVG);
}

string ZoneTypeText(const int type)
{
   if(type==LNO_ZONE_BULL_OB)  return "BULL OB";
   if(type==LNO_ZONE_BEAR_OB)  return "BEAR OB";
   if(type==LNO_ZONE_BULL_FVG) return "BULL FVG";
   if(type==LNO_ZONE_BEAR_FVG) return "BEAR FVG";
   return "ZONE";
}

string ZoneShortCode(const InstitutionalZone &z)
{
   string base="";
   if(z.type==LNO_ZONE_BULL_OB)  base="OB-B";
   if(z.type==LNO_ZONE_BEAR_OB)  base="OB-S";
   if(z.type==LNO_ZONE_BULL_FVG) base="FVG-B";
   if(z.type==LNO_ZONE_BEAR_FVG) base="FVG-S";
   return base+"-"+StrengthInitial(z.strength);
}

color ZoneColor(const InstitutionalZone &z)
{
   if(z.mitigated) return InpMitigatedZoneColor;
   if(z.type==LNO_ZONE_BULL_OB)  return InpBullOBColor;
   if(z.type==LNO_ZONE_BEAR_OB)  return InpBearOBColor;
   if(z.type==LNO_ZONE_BULL_FVG) return InpBullFVGColor;
   if(z.type==LNO_ZONE_BEAR_FVG) return InpBearFVGColor;
   return clrSilver;
}

int ZoneStrength(const int type,const double top,const double bottom,const bool external,const int sourceStrength)
{
   // Stage 3.1: OB/FVG ranking is no longer "all zones are equal".
   // It scores size, external/internal source, BOS/CHOCH source strength and zone type.
   double sizePips=MathAbs(top-bottom)/g_pip;
   bool isFVG=(type==LNO_ZONE_BULL_FVG || type==LNO_ZONE_BEAR_FVG);
   int s=38;

   // Real displacement/imbalance size matters, but avoid over-rewarding giant zones.
   if(isFVG)
      s+=(int)MathMin(30.0,sizePips*1.60);   // FVG strength = gap quality
   else
      s+=(int)MathMin(24.0,sizePips*1.15);   // OB strength = candle zone quality

   if(external) s+=14;                       // External zones matter more
   if(isFVG)   s+=6;                         // FVG/imbalance receives a small premium
   if(sourceStrength>0) s+=(int)MathMin(18.0,sourceStrength/7.0);

   if(s>100) s=100;
   if(s<1) s=1;
   return s;
}

int ZoneAgeBars(const InstitutionalZone &z)
{
   int sh=iBarShift(g_symbol,InpStructureTF,z.time2,false);
   if(sh<0) return 0;
   return sh;
}

int BarsSinceTime(const datetime t)
{
   if(t<=0) return -1;
   int sh=iBarShift(g_symbol,InpStructureTF,t,false);
   return sh;
}

bool IsMitigatedZoneExpired(const InstitutionalZone &z)
{
   if(!z.mitigated) return false;
   if(InpMitigatedKeepBars<=0) return true;
   int b=BarsSinceTime(z.mitigatedTime);
   if(b<0) return false;
   return (b>InpMitigatedKeepBars);
}

bool IsInstitutionalZoneExpired(const InstitutionalZone &z)
{
   if(IsMitigatedZoneExpired(z)) return true;
   if(InpZoneLifetimeBars<=0) return false;
   return (ZoneAgeBars(z)>InpZoneLifetimeBars);
}

int ZoneProbability(const InstitutionalZone &z)
{
   int p=35;
   p += (int)(z.strength*0.42);
   if(z.external) p+=8;
   int cl=ZoneLiquidityClusterScore(z);
   if(cl>=35) p+=16;
   else if(cl>=20) p+=10;
   else if(cl>0) p+=5;
   if(z.mitigated) p-=35;
   if(ZoneAgeBars(z)>InpZoneLifetimeBars/2 && InpZoneLifetimeBars>0) p-=7;
   if(p>97) p=97;        // keep 100 rare for full Stage 4 confluence
   if(p<5) p=5;
   return p;
}

int LiquidityProbability(const LiquidityZone &z)
{
   int p=25;
   p += (int)(z.strength*0.55);
   if(z.external) p += 10;
   if(z.touches>=3) p += 8;
   else if(z.touches>=2) p += 4;
   if(z.type==LNO_LIQ_ASIA_H || z.type==LNO_LIQ_ASIA_L) p += 8;
   if(z.type==LNO_LIQ_PDH || z.type==LNO_LIQ_PDL) p += 10;
   if(z.type==LNO_LIQ_PWH || z.type==LNO_LIQ_PWL) p += 12;
   if(z.swept) p -= 35;
   if(p>97) p=97;
   if(p<5) p=5;
   return p;
}

bool ZonesPriceOverlap(const double top1,const double bottom1,const double top2,const double bottom2)
{
   double top=MathMin(top1,top2);
   double bottom=MathMax(bottom1,bottom2);
   return (top>=bottom);
}

bool ZoneOverlapsDrawnCluster(const InstitutionalZone &z,const double &tops[],const double &bottoms[],const bool &bulls[],const int count)
{
   bool b=IsBullishZoneType(z.type);
   for(int i=0;i<count;i++)
   {
      if(bulls[i]!=b) continue;
      if(ZonesPriceOverlap(z.top,z.bottom,tops[i],bottoms[i])) return true;
   }
   return false;
}

bool ClusterAlreadyDrawn(const double top,const double bottom,const bool bull,const double &tops[],const double &bottoms[],const bool &bulls[],const int count)
{
   for(int i=0;i<count;i++)
   {
      if(bulls[i]!=bull) continue;
      if(ZonesPriceOverlap(top,bottom,tops[i],bottoms[i])) return true;
   }
   return false;
}

void RendererResetClusters()
{
   ArrayResize(g_renderClusterTops,0);
   ArrayResize(g_renderClusterBottoms,0);
   ArrayResize(g_renderClusterBulls,0);
   g_renderClusterCount=0;
}

void RendererPushCluster(const double top,const double bottom,const bool bull)
{
   int n=g_renderClusterCount;
   ArrayResize(g_renderClusterTops,n+1);
   ArrayResize(g_renderClusterBottoms,n+1);
   ArrayResize(g_renderClusterBulls,n+1);
   g_renderClusterTops[n]=top;
   g_renderClusterBottoms[n]=bottom;
   g_renderClusterBulls[n]=bull;
   g_renderClusterCount=n+1;
}

bool RendererPriceInsideCluster(const double price,const bool bull)
{
   for(int i=0;i<g_renderClusterCount;i++)
   {
      if(g_renderClusterBulls[i]!=bull) continue;
      if(price<=g_renderClusterTops[i] && price>=g_renderClusterBottoms[i]) return true;
   }
   return false;
}

bool RendererHasClusterForBull(const bool bull)
{
   for(int i=0;i<g_renderClusterCount;i++)
   {
      if(g_renderClusterBulls[i]==bull) return true;
   }
   return false;
}

int BuildClusterBoundsForZone(const int idx,double &clusterTop,double &clusterBottom)
{
   clusterTop=g_instZones[idx].top;
   clusterBottom=g_instZones[idx].bottom;
   bool bull=IsBullishZoneType(g_instZones[idx].type);
   int members=1;
   double tol=InpClusterTolerancePips*g_pip;

   for(int j=0;j<ArraySize(g_instZones);j++)
   {
      if(j==idx) continue;
      if(g_instZones[j].mitigated || IsInstitutionalZoneExpired(g_instZones[j])) continue;
      if(IsBullishZoneType(g_instZones[j].type)!=bull) continue;
      if(ZoneProbability(g_instZones[j])<InpMinDrawZoneProbability) continue;

      bool nearby=ZonesOverlap(g_instZones[idx],g_instZones[j]);
      if(!nearby)
      {
         double mid=ZoneMid(g_instZones[j]);
         nearby=PriceInsideZone(mid,g_instZones[idx],tol) || PriceInsideZone(ZoneMid(g_instZones[idx]),g_instZones[j],tol);
      }
      if(!nearby) continue;

      clusterTop=MathMax(clusterTop,g_instZones[j].top);
      clusterBottom=MathMin(clusterBottom,g_instZones[j].bottom);
      members++;
   }

   for(int k=0;k<ArraySize(g_liquidity);k++)
   {
      if(g_liquidity[k].swept) continue;
      if(IsBuySideLiquidity(g_liquidity[k].type)!=bull) continue;
      if(LiquidityProbability(g_liquidity[k])<InpMinDrawLiquidityProbability) continue;
      if(g_liquidity[k].price<=clusterTop+tol && g_liquidity[k].price>=clusterBottom-tol)
      {
         clusterTop=MathMax(clusterTop,g_liquidity[k].price+tol*0.15);
         clusterBottom=MathMin(clusterBottom,g_liquidity[k].price-tol*0.15);
         members++;
      }
   }

   return members;
}

int ClusterProbability(const int idx,const double top,const double bottom,const int members)
{
   int p=ZoneProbability(g_instZones[idx]);
   p += MathMin(18,(members-1)*6);
   p += MathMin(14,ZoneLiquidityClusterScore(g_instZones[idx])/2);
   if(g_instZones[idx].external) p+=5;
   if(p>98) p=98;
   if(p<5) p=5;
   return p;
}

void CapRendererClusterBounds(double &top,double &bottom)
{
   // Stage 3.10: keep a cluster as a precise institutional area, not a full-screen block.
   if(top<=bottom) return;
   double maxH=InpRendererClusterMaxHeightPips*g_pip;
   if(maxH<=0) return;
   double h=top-bottom;
   if(h<=maxH) return;
   double mid=(top+bottom)/2.0;
   top=mid+maxH/2.0;
   bottom=mid-maxH/2.0;
}

int ZoneLineStyle(const InstitutionalZone &z)
{
   if(z.mitigated) return STYLE_DOT;
   if(z.strength>=80) return STYLE_SOLID;
   if(z.strength>=55) return STYLE_DASH;
   return STYLE_DOT;
}

int ZoneLineWidth(const InstitutionalZone &z)
{
   if(z.mitigated) return 1;
   if(z.strength>=80) return 3;
   if(z.strength>=55) return 2;
   return 1;
}

bool ZonesOverlap(const InstitutionalZone &a,const InstitutionalZone &b)
{
   double top=MathMin(a.top,b.top);
   double bottom=MathMax(a.bottom,b.bottom);
   if(top<bottom) return false;
   double overlap=top-bottom;
   double amin=MathAbs(a.top-a.bottom);
   double bmin=MathAbs(b.top-b.bottom);
   double denom=MathMin(amin,bmin);
   if(denom<=0) return false;
   return (overlap/denom>=0.45);
}

bool HiddenByStrongerOverlappedZone(const int idx)
{
   if(!InpSuppressOverlappedZones) return false;
   if(idx<0 || idx>=ArraySize(g_instZones)) return false;
   if(g_instZones[idx].mitigated) return false;
   int myScore=ZoneProbability(g_instZones[idx]);
   bool myBull=IsBullishZoneType(g_instZones[idx].type);
   for(int j=0;j<ArraySize(g_instZones);j++)
   {
      if(j==idx) continue;
      if(g_instZones[j].mitigated || IsInstitutionalZoneExpired(g_instZones[j])) continue;
      if(IsBullishZoneType(g_instZones[j].type)!=myBull) continue;
      if(!ZonesOverlap(g_instZones[idx],g_instZones[j])) continue;
      int otherScore=ZoneProbability(g_instZones[j]);
      if(otherScore>myScore+6) return true;
      if(otherScore==myScore && g_instZones[j].id>g_instZones[idx].id) return true;
   }
   return false;
}

double ZoneMid(const InstitutionalZone &z)
{
   return (z.top+z.bottom)/2.0;
}

bool PriceInsideZone(const double price,const InstitutionalZone &z,const double extra)
{
   return (price<=z.top+extra && price>=z.bottom-extra);
}

int ZoneLiquidityClusterScore(const InstitutionalZone &z)
{
   // Stage 3.1 Cluster Detection: OB/FVG + nearby liquidity = institutional cluster.
   double tol=InpClusterTolerancePips*g_pip;
   int score=0;
   for(int i=0;i<ArraySize(g_liquidity);i++)
   {
      if(g_liquidity[i].swept) continue;
      if(PriceInsideZone(g_liquidity[i].price,z,tol))
      {
         score += 10;
         if(g_liquidity[i].external) score += 6;
         if(g_liquidity[i].strength>=80) score += 8;
         else if(g_liquidity[i].strength>=55) score += 4;
      }
   }
   if(score>35) score=35;
   return score;
}

bool IsInstitutionalCluster(const InstitutionalZone &z)
{
   return (ZoneLiquidityClusterScore(z)>=14);
}

string ZoneStrengthWord(const InstitutionalZone &z)
{
   if(z.strength>=80) return "High";
   if(z.strength>=55) return "Medium";
   return "Weak";
}

color ZoneStrengthColor(const InstitutionalZone &z)
{
   if(z.mitigated || IsInstitutionalZoneExpired(z)) return InpMitigatedZoneColor;
   if(z.strength>=80) return clrLime;
   if(z.strength>=55) return clrGold;
   return clrDarkOrange;
}

bool SameInstitutionalZoneExists(const int type,const double top,const double bottom)
{
   double tol=3.0*g_pip;
   for(int i=0;i<ArraySize(g_instZones);i++)
   {
      if(g_instZones[i].type!=type) continue;
      if(MathAbs(g_instZones[i].top-top)<=tol && MathAbs(g_instZones[i].bottom-bottom)<=tol)
         return true;
   }
   return false;
}

void PushInstitutionalZone(const int type,const datetime t1,const datetime t2,const double top,const double bottom,const bool external,const int sourceEventId,const int sourceStrength)
{
   if(top<=0 || bottom<=0) return;
   double hi=MathMax(top,bottom);
   double lo=MathMin(top,bottom);
   if(MathAbs(hi-lo)<InpMinOBSizePips*g_pip && (type==LNO_ZONE_BULL_OB || type==LNO_ZONE_BEAR_OB)) return;
   if(MathAbs(hi-lo)<InpMinFVGSizePips*g_pip && (type==LNO_ZONE_BULL_FVG || type==LNO_ZONE_BEAR_FVG)) return;
   if(SameInstitutionalZoneExists(type,hi,lo)) return;

   int n=ArraySize(g_instZones);
   ArrayResize(g_instZones,n+1);
   g_instZones[n].id=g_nextInstZoneId++;
   g_instZones[n].type=type;
   g_instZones[n].time1=t1;
   g_instZones[n].time2=t2;
   g_instZones[n].top=hi;
   g_instZones[n].bottom=lo;
   g_instZones[n].strength=ZoneStrength(type,hi,lo,external,sourceStrength);
   g_instZones[n].mitigated=false;
   g_instZones[n].mitigatedTime=0;
   g_instZones[n].external=external;
   g_instZones[n].sourceEventId=sourceEventId;
}

void MarkInstitutionalMitigations()
{
   int n=ArraySize(g_instZones);
   int bars=Bars(g_symbol,InpStructureTF);
   for(int i=0;i<n;i++)
   {
      int startShift=iBarShift(g_symbol,InpStructureTF,g_instZones[i].time2,true);
      if(startShift<0) startShift=iBarShift(g_symbol,InpStructureTF,g_instZones[i].time1,false);
      if(startShift<0) continue;

      for(int sh=startShift-1; sh>=1 && sh<bars; sh--)
      {
         double h=iHigh(g_symbol,InpStructureTF,sh);
         double l=iLow(g_symbol,InpStructureTF,sh);
         bool touched=(h>=g_instZones[i].bottom && l<=g_instZones[i].top);
         if(touched)
         {
            g_instZones[i].mitigated=true;
            g_instZones[i].mitigatedTime=iTime(g_symbol,InpStructureTF,sh);
            break;
         }
      }
   }
}

void DetectOrderBlocks()
{
   if(!InpDetectOrderBlocks) return;
   int evn=ArraySize(g_events);
   int bars=Bars(g_symbol,InpStructureTF);
   for(int e=0;e<evn;e++)
   {
      int evShift=g_events[e].shift;
      if(evShift<1 || evShift>=bars-2) continue;
      bool bull=(g_events[e].dir>0);
      int found=-1;

      for(int sh=evShift+1; sh<=evShift+InpOBLookbackCandles && sh<bars-1; sh++)
      {
         double o=iOpen(g_symbol,InpStructureTF,sh);
         double c=iClose(g_symbol,InpStructureTF,sh);
         if(bull && c<o) { found=sh; break; }
         if(!bull && c>o) { found=sh; break; }
      }
      if(found<0) continue;

      double hi=iHigh(g_symbol,InpStructureTF,found);
      double lo=iLow(g_symbol,InpStructureTF,found);
      datetime t1=iTime(g_symbol,InpStructureTF,found);
      datetime t2=iTime(g_symbol,InpStructureTF,evShift);
      int type=(bull?LNO_ZONE_BULL_OB:LNO_ZONE_BEAR_OB);
      PushInstitutionalZone(type,t1,t2,hi,lo,(g_events[e].level>=2),g_events[e].id,g_events[e].strength);
   }
}

void DetectFVGZones()
{
   if(!InpDetectFVG) return;
   int bars=Bars(g_symbol,InpStructureTF);
   int maxScan=MathMin(InpFVGScanBars,bars-3);
   for(int sh=maxScan; sh>=1; sh--)
   {
      // Three-candle imbalance in series indexing:
      // old candle = sh+2, middle = sh+1, newer = sh.
      double oldHigh=iHigh(g_symbol,InpStructureTF,sh+2);
      double oldLow =iLow(g_symbol,InpStructureTF,sh+2);
      double newHigh=iHigh(g_symbol,InpStructureTF,sh);
      double newLow =iLow(g_symbol,InpStructureTF,sh);
      datetime t1=iTime(g_symbol,InpStructureTF,sh+2);
      datetime t2=iTime(g_symbol,InpStructureTF,sh);

      // Bullish FVG: newer low above older high.
      if(newLow>oldHigh && (newLow-oldHigh)>=InpMinFVGSizePips*g_pip)
      {
         bool ext=(MathAbs(newLow-oldHigh)/g_pip>=InpExternalSwingDistancePips/2.0);
         PushInstitutionalZone(LNO_ZONE_BULL_FVG,t1,t2,newLow,oldHigh,ext,0,0);
      }

      // Bearish FVG: newer high below older low.
      if(newHigh<oldLow && (oldLow-newHigh)>=InpMinFVGSizePips*g_pip)
      {
         bool ext=(MathAbs(oldLow-newHigh)/g_pip>=InpExternalSwingDistancePips/2.0);
         PushInstitutionalZone(LNO_ZONE_BEAR_FVG,t1,t2,oldLow,newHigh,ext,0,0);
      }
   }
}

void DetectInstitutionalZones()
{
   ArrayResize(g_instZones,0);
   g_nextInstZoneId=1;
   g_activeBullOB=0;
   g_activeBearOB=0;
   g_activeBullFVG=0;
   g_activeBearFVG=0;

   DetectOrderBlocks();
   DetectFVGZones();
   MarkInstitutionalMitigations();

   for(int i=0;i<ArraySize(g_instZones);i++)
   {
      // Stage 3.1: mitigated or expired zones become historical only and do not affect counts/confidence.
      if(g_instZones[i].mitigated) continue;
      if(IsInstitutionalZoneExpired(g_instZones[i])) continue;
      if(g_instZones[i].type==LNO_ZONE_BULL_OB)  g_activeBullOB++;
      if(g_instZones[i].type==LNO_ZONE_BEAR_OB)  g_activeBearOB++;
      if(g_instZones[i].type==LNO_ZONE_BULL_FVG) g_activeBullFVG++;
      if(g_instZones[i].type==LNO_ZONE_BEAR_FVG) g_activeBearFVG++;
   }
}

int StrongestInstitutionalIndex(const bool bullish)
{
   int best=-1, bestScore=-1;
   for(int i=0;i<ArraySize(g_instZones);i++)
   {
      if(g_instZones[i].mitigated) continue;
      if(IsInstitutionalZoneExpired(g_instZones[i])) continue;
      if(IsBullishZoneType(g_instZones[i].type)!=bullish) continue;
      int score=g_instZones[i].strength+(g_instZones[i].external?8:0)+ZoneLiquidityClusterScore(g_instZones[i]);
      if(score>bestScore)
      {
         bestScore=score;
         best=i;
      }
   }
   return best;
}

string StrongestInstitutionalText(const bool bullish)
{
   int idx=StrongestInstitutionalIndex(bullish);
   if(idx<0) return "None";
   return ZoneShortCode(g_instZones[idx]);
}

color StrongestInstitutionalColor(const bool bullish)
{
   int idx=StrongestInstitutionalIndex(bullish);
   if(idx<0) return clrSilver;
   return ZoneColor(g_instZones[idx]);
}

int ActiveInstitutionalTotal()
{
   return g_activeBullOB+g_activeBearOB+g_activeBullFVG+g_activeBearFVG;
}

int ActiveInstitutionalBull()
{
   return g_activeBullOB+g_activeBullFVG;
}

int ActiveInstitutionalBear()
{
   return g_activeBearOB+g_activeBearFVG;
}

int InstitutionalClusterCount(const bool bullish)
{
   int cnt=0;
   for(int i=0;i<ArraySize(g_instZones);i++)
   {
      if(g_instZones[i].mitigated) continue;
      if(IsInstitutionalZoneExpired(g_instZones[i])) continue;
      if(IsBullishZoneType(g_instZones[i].type)!=bullish) continue;
      if(IsInstitutionalCluster(g_instZones[i])) cnt++;
   }
   return cnt;
}

int StructureScore()
{
   int s=0;
   if(g_externalBias!=0) s+=18;
   if(g_internalBias!=0) s+=12;
   if(g_externalBias!=0 && g_externalBias==g_internalBias) s+=18;
   if(g_bias!=0) s+=12;
   return s;
}

int LiquidityScoreDirectional(const int dir)
{
   int s=0;
   int idx=StrongestLiquidityIndex(dir>0);
   if(idx>=0)
   {
      s+=12;
      if(g_liquidity[idx].strength>=80) s+=12;
      else if(g_liquidity[idx].strength>=55) s+=7;
      if(g_liquidity[idx].external) s+=6;
   }
   int ls=LastSweepIndex();
   if(ls>=0)
   {
      bool sweptBuy=IsBuySideLiquidity(g_liquidity[ls].type);
      // A sell-side sweep can support bullish reversal, buy-side sweep can support bearish reversal.
      if((dir>0 && !sweptBuy) || (dir<0 && sweptBuy)) s+=12;
      int b=LastSweepBarsAgo();
      if(b>=0 && b<=12) s+=6;
   }
   return s;
}

int InstitutionalScoreDirectional(const int dir)
{
   int s=0;
   int idx=StrongestInstitutionalIndex(dir>0);
   if(idx>=0)
   {
      s+=14;
      s+=(g_instZones[idx].strength>=80 ? 14 : (g_instZones[idx].strength>=55 ? 8 : 3));
      if(g_instZones[idx].external) s+=8;
      s+=ZoneLiquidityClusterScore(g_instZones[idx]);
   }
   int clusters=InstitutionalClusterCount(dir>0);
   if(clusters>0) s+=MathMin(18,clusters*8);
   return s;
}

int PremiumDiscountScoreDirectional(const int dir)
{
   // Stage 3.1: basic Premium/Discount score from last external range.
   int hi=-1, lo=-1;
   for(int i=ArraySize(g_swings)-1;i>=0;i--)
   {
      if(g_swings[i].level<2) continue;
      if(hi<0 && g_swings[i].isHigh) hi=i;
      if(lo<0 && !g_swings[i].isHigh) lo=i;
      if(hi>=0 && lo>=0) break;
   }
   if(hi<0 || lo<0) return 0;
   double high=MathMax(g_swings[hi].price,g_swings[lo].price);
   double low =MathMin(g_swings[hi].price,g_swings[lo].price);
   if(high<=low) return 0;
   double price=iClose(g_symbol,InpStructureTF,1);
   double eq=(high+low)/2.0;
   if(dir>0 && price<=eq) return 10;  // buy in discount
   if(dir<0 && price>=eq) return 10;  // sell in premium
   return 0;
}

int LegacyInstitutionalConfidenceBoost()
{
   int boost=0;
   int bullZones=g_activeBullOB+g_activeBullFVG;
   int bearZones=g_activeBearOB+g_activeBearFVG;
   if(g_bias>0 && bullZones>bearZones) boost+=8;
   if(g_bias<0 && bearZones>bullZones) boost+=8;

   int bi=StrongestInstitutionalIndex(g_bias>=0);
   if(bi>=0)
   {
      if(g_instZones[bi].strength>=78) boost+=7;
      if(g_instZones[bi].external) boost+=5;
      if(IsInstitutionalCluster(g_instZones[bi])) boost+=5;
   }
   if(boost>30) boost=30;
   return boost;
}

int SmartConfidenceScore()
{
   if(!InpUseSmartInstitutionalConfidence)
      return MathMin(94,LiquidityConfidenceScore()+LegacyInstitutionalConfidenceBoost());

   int bull=0, bear=0;

   // Weighted and stricter: 100 should be rare, not normal.
   bull += (g_externalBias>0?18:(g_externalBias<0?0:8));
   bear += (g_externalBias<0?18:(g_externalBias>0?0:8));
   bull += (g_internalBias>0?10:(g_internalBias<0?0:5));
   bear += (g_internalBias<0?10:(g_internalBias>0?0:5));

   bull += (int)MathMin(18.0, LiquidityScoreDirectional(1)*0.55);
   bear += (int)MathMin(18.0, LiquidityScoreDirectional(-1)*0.55);

   bull += (int)MathMin(24.0, InstitutionalScoreDirectional(1)*0.70);
   bear += (int)MathMin(24.0, InstitutionalScoreDirectional(-1)*0.70);

   bull += (int)MathMin(12.0, PremiumDiscountScoreDirectional(1)*0.65);
   bear += (int)MathMin(12.0, PremiumDiscountScoreDirectional(-1)*0.65);

   string ph=PhaseText();
   if(ph=="Bull Expansion") bull+=10;
   else if(ph=="Bull Pullback") bull+=7;
   if(ph=="Bear Expansion") bear+=10;
   else if(ph=="Bear Pullback") bear+=7;

   int ls=LastSweepIndex();
   if(ls>=0)
   {
      int b=LastSweepBarsAgo();
      if(b>=0 && b<=12)
      {
         if(IsBuySideLiquidity(g_liquidity[ls].type)) bear+=8;
         else bull+=8;
      }
      else if(b>=0 && b<=40)
      {
         if(IsBuySideLiquidity(g_liquidity[ls].type)) bear+=4;
         else bull+=4;
      }
   }

   int score=MathMax(bull,bear);

   // Exceptional requires clear institutional cluster and fresh sweep.
   bool exceptional=false;
   int zi=StrongestInstitutionalIndex(bull>=bear);
   if(zi>=0 && IsInstitutionalCluster(g_instZones[zi]) && ZoneProbability(g_instZones[zi])>=90)
   {
      int b=LastSweepBarsAgo();
      if(b>=0 && b<=15) exceptional=true;
   }

   if(!exceptional && score>94) score=94;
   if(exceptional && score>100) score=100;
   if(score<1) score=1;
   return score;
}

int InstitutionalBiasScore()
{
   int bull=LiquidityScoreDirectional(1)+InstitutionalScoreDirectional(1)+PremiumDiscountScoreDirectional(1);
   int bear=LiquidityScoreDirectional(-1)+InstitutionalScoreDirectional(-1)+PremiumDiscountScoreDirectional(-1);
   if(g_externalBias>0) bull+=18; else if(g_externalBias<0) bear+=18;
   if(g_internalBias>0) bull+=10; else if(g_internalBias<0) bear+=10;
   return bull-bear;
}

string InstitutionalBiasText()
{
   int s=InstitutionalBiasScore();
   if(s>=35) return "STRONG BUY";
   if(s>=12) return "BUY";
   if(s<=-35) return "STRONG SELL";
   if(s<=-12) return "SELL";
   return "NEUTRAL";
}

color InstitutionalBiasColor()
{
   int s=InstitutionalBiasScore();
   if(s>=35) return clrLime;
   if(s>=12) return clrMediumSeaGreen;
   if(s<=-35) return clrTomato;
   if(s<=-12) return clrOrangeRed;
   return clrGold;
}

int InstitutionalConfidenceBoost()
{
   if(!InpUseOBFVGForConfidence) return 0;
   if(!InpUseSmartInstitutionalConfidence) return LegacyInstitutionalConfidenceBoost();
   int score=SmartConfidenceScore();
   int base=LiquidityConfidenceScore();
   int boost=score-base;
   if(boost<0) boost=0;
   if(boost>30) boost=30;
   return boost;
}


int LastEventBarsAgo(const bool choch)
{
   int best=999999;
   for(int i=ArraySize(g_events)-1;i>=0;i--)
   {
      if(g_events[i].isChoch!=choch) continue;
      if(g_events[i].time<=0) continue;
      int b=BarsSinceTime(g_events[i].time);
      if(b>=0 && b<best) best=b;
   }
   return (best==999999?-1:best);
}

string LastEventTimelineText()
{
   int bos=LastEventBarsAgo(false);
   int ch=LastEventBarsAgo(true);
   string s="";
   s+="Last BOS: "+(bos>=0?IntegerToString(bos)+" bars":"None");
   s+="   Last CHOCH: "+(ch>=0?IntegerToString(ch)+" bars":"None");
   return s;
}

int LastZoneBarsAgo(const bool fvg)
{
   int best=999999;
   for(int i=ArraySize(g_instZones)-1;i>=0;i--)
   {
      bool isF=(g_instZones[i].type==LNO_ZONE_BULL_FVG || g_instZones[i].type==LNO_ZONE_BEAR_FVG);
      if(isF!=fvg) continue;
      if(IsInstitutionalZoneExpired(g_instZones[i])) continue;
      int b=BarsSinceTime(g_instZones[i].time2);
      if(b>=0 && b<best) best=b;
   }
   return (best==999999?-1:best);
}

string LastInstitutionalTimelineText()
{
   int ob=LastZoneBarsAgo(false);
   int fvg=LastZoneBarsAgo(true);
   string s="";
   s+="Last OB: "+(ob>=0?IntegerToString(ob)+" bars":"None");
   s+="   Last FVG: "+(fvg>=0?IntegerToString(fvg)+" bars":"None");
   return s;
}

string ConfidenceTierText(const int score)
{
   if(score>=95) return "EXCEPTIONAL";
   if(score>=85) return "VERY HIGH";
   if(score>=75) return "HIGH";
   if(score>=65) return "MEDIUM";
   return "LOW";
}

color ConfidenceTierColor(const int score)
{
   if(score>=95) return clrLime;
   if(score>=85) return clrMediumSeaGreen;
   if(score>=75) return clrGold;
   if(score>=65) return clrOrange;
   return clrTomato;
}

int InternalExternalScore(const int which)
{
   // which: 1 = external, 0 = internal
   int bias=(which==1?g_externalBias:g_internalBias);
   if(bias==0) return 50;
   int score=56;
   for(int i=ArraySize(g_events)-1;i>=0;i--)
   {
      if(which==1 && g_events[i].level<2) continue;
      if(which==0 && g_events[i].level!=1) continue;
      if(g_events[i].dir==bias) score += (g_events[i].isChoch?18:12);
      else score -= (g_events[i].isChoch?14:8);
      score += (int)MathMin(16.0,g_events[i].strength/8.0);
      break;
   }
   if(score>98) score=98;
   if(score<5) score=5;
   return score;
}

string InstitutionalBiasReason()
{
   int s=InstitutionalBiasScore();
   bool bull=(s>=0);
   int zi=StrongestInstitutionalIndex(bull);
   string z=(zi>=0?ZoneShortCode(g_instZones[zi]):"No zone");
   string reason="";
   if(MathAbs(s)>=35) reason=(bull?"Strong Buy":"Strong Sell");
   else if(MathAbs(s)>=12) reason=(bull?"Buy":"Sell");
   else reason="Neutral";
   reason += " (";
   if(bull)
   {
      reason += (g_externalBias>0?"External BOS":"Structure mixed");
      if(zi>=0) reason += " + "+z;
      if(zi>=0 && IsInstitutionalCluster(g_instZones[zi])) reason += " + Cluster";
      if(g_activeBuyLiquidity>g_activeSellLiquidity) reason += " + Buy Liq";
   }
   else
   {
      reason += (g_externalBias<0?"External BOS":"Structure mixed");
      if(zi>=0) reason += " + "+z;
      if(zi>=0 && IsInstitutionalCluster(g_instZones[zi])) reason += " + Cluster";
      if(g_activeSellLiquidity>g_activeBuyLiquidity) reason += " + Sell Liq";
   }
   reason += ")";
   return reason;
}

void DrawTransparentRectEx(string name, datetime t1, double p1, datetime t2, double p2, color clr, int alpha, int style=STYLE_SOLID, bool back=true, bool fill=true, int width=1, int zorder=0)
{
   if(!InpDrawOnChart) return;
   if(ObjectFind(0,name)>=0) ObjectDelete(0,name);
   ObjectCreate(0,name,OBJ_RECTANGLE,0,t1,p1,t2,p2);
   color useClr=(fill ? AlphaColor(clr,alpha) : clr);
   ObjectSetInteger(0,name,OBJPROP_COLOR,useClr);
   ObjectSetInteger(0,name,OBJPROP_STYLE,style);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(0,name,OBJPROP_BACK,back);
   ObjectSetInteger(0,name,OBJPROP_FILL,fill);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,zorder);
}

void DrawSingleSessionBox(const string key,const string label,const datetime t1,const datetime t2,const color clr)
{
   if(t2<=t1) return;
   double hi=-DBL_MAX, lo=DBL_MAX;
   int bars=Bars(g_symbol,InpStructureTF);
   for(int sh=0; sh<MathMin(bars,900); sh++)
   {
      datetime t=iTime(g_symbol,InpStructureTF,sh);
      if(t<t1) break;
      if(t>=t1 && t<t2)
      {
         hi=MathMax(hi,iHigh(g_symbol,InpStructureTF,sh));
         lo=MathMin(lo,iLow(g_symbol,InpStructureTF,sh));
      }
   }
   if(hi<=0 || lo<=0 || hi<=lo || hi== -DBL_MAX || lo==DBL_MAX) return;
   string nm=g_prefix+"SESSION_"+key;
   // Stage 3.7: real transparent session boxes. They stay in the background.
   // Stage 3.8 renderer: sessions are real boxes, but border-only to avoid hiding price.
   DrawTransparentRectEx(nm+"_BOX",t1,hi,t2,lo,clr,InpSessionBoxAlpha,STYLE_SOLID,true,false,1,0);
   DrawTextEx(nm+"_TXT",t1,hi,label,clr,ANCHOR_LEFT,InpBaseLabelFontSize);
}

void DrawSessionBoxes()
{
   if(!InpShowSessionLiquidityZones || !InpDrawOnChart || !InpDrawTrueSessionBoxes) return;
   datetime now=iTime(g_symbol,InpStructureTF,0);
   MqlDateTime dt; TimeToStruct(now,dt);
   dt.hour=0; dt.min=0; dt.sec=0;
   datetime dayStart=StructToTime(dt);

   // Draw today and previous day so visual test scrolling still shows complete sessions.
   for(int d=1; d>=0; d--)
   {
      datetime ds=dayStart-(datetime)(d*86400);
      datetime a1=ds+(datetime)(InpAsiaStartHour*3600);
      datetime a2=ds+(datetime)(InpAsiaEndHour*3600);
      datetime l1=ds+(datetime)(InpLondonStartHour*3600);
      datetime l2=ds+(datetime)(InpLondonEndHour*3600);
      datetime n1=ds+(datetime)(InpNYStartHour*3600);
      datetime n2=ds+(datetime)(InpNYEndHour*3600);

      DrawSingleSessionBox("ASIA_"+IntegerToString(d),"ASIA",a1,a2,clrSlateGray);
      DrawSingleSessionBox("LONDON_"+IntegerToString(d),"LONDON",l1,l2,clrDodgerBlue);
      DrawSingleSessionBox("NY_"+IntegerToString(d),"NY",n1,n2,clrMediumPurple);
   }
}


color Stage41HeatColor(const bool bull,const int probability)
{
   if(bull)
   {
      if(probability>=92) return clrLimeGreen;
      if(probability>=84) return clrSeaGreen;
      return clrDarkGreen;
   }
   if(probability>=92) return clrTomato;
   if(probability>=84) return clrFireBrick;
   return clrMaroon;
}

string Stage41ZoneClass(const int probability)
{
   if(probability>=92) return "EXCEPTIONAL";
   if(probability>=84) return "HIGH";
   if(probability>=75) return "MEDIUM";
   return "WEAK";
}

string Stage41ZoneKind(const InstitutionalZone &z)
{
   bool bull=IsBullishZoneType(z.type);
   bool fvg=(z.type==LNO_ZONE_BULL_FVG || z.type==LNO_ZONE_BEAR_FVG);
   if(fvg) return (bull?"BUY FVG":"SELL FVG");
   return (bull?"BUY OB":"SELL OB");
}

string Stage41ClusterLabel(const bool bull,const int probability,const int members)
{
   string side=(bull?"INSTITUTIONAL BUY":"INSTITUTIONAL SELL");
   return side+"\nCLUSTER\n"+IntegerToString(probability)+"%  "+Stage41ZoneClass(probability)+"\nOB + FVG + LIQ";
}

string InstitutionalPhaseText()
{
   int total=ActiveInstitutionalTotal();
   if(total<=0) return "No active zones";
   int clusters=InstitutionalClusterCount(true)+InstitutionalClusterCount(false);
   if(clusters>0) return "Cluster Map";
   if(g_activeBullFVG+g_activeBearFVG >= g_activeBullOB+g_activeBearOB)
      return "Imbalance Map";
   return "OB Map";
}

void DrawInstitutionalZones()
{
   if(!InpShowInstitutionalZones || !InpDrawOnChart) return;

   int sec=PeriodSeconds(InpStructureTF); if(sec<=0) sec=300;
   datetime now=iTime(g_symbol,InpStructureTF,0);
   datetime tEnd=now+(datetime)(InpRendererZoneProjectionBars*sec);

   int n=ArraySize(g_instZones);
   RendererResetClusters();

   // Stage 3.11 pass 1: draw only ONE best cluster per direction.
   // Cluster has absolute priority over OB/FVG/Liquidity members.
   bool clusterBullDrawn=false;
   bool clusterBearDrawn=false;
   if(InpShowInstitutionalClusters && InpDrawClusterAsOneBox)
   {
      for(int i=n-1;i>=0;i--)
      {
         if(IsInstitutionalZoneExpired(g_instZones[i])) continue;
         if(g_instZones[i].mitigated) continue;
         int prob=ZoneProbability(g_instZones[i]);
         if(prob<InpMinDrawZoneProbability) continue;
         if(!IsInstitutionalCluster(g_instZones[i])) continue;

         bool bull=IsBullishZoneType(g_instZones[i].type);
         if((bull && clusterBullDrawn) || (!bull && clusterBearDrawn)) continue;
         double ct, cb;
         int members=BuildClusterBoundsForZone(i,ct,cb);
         CapRendererClusterBounds(ct,cb);
         int cprob=ClusterProbability(i,ct,cb,members);
         if(members<2) continue;
         if(cprob<InpMinDrawZoneProbability) continue;
         if(ClusterAlreadyDrawn(ct,cb,bull,g_renderClusterTops,g_renderClusterBottoms,g_renderClusterBulls,g_renderClusterCount)) continue;

         RendererPushCluster(ct,cb,bull);

         string cnm=g_prefix+"TRUE_CLUSTER_"+IntegerToString(g_instZones[i].id);
         color cclr=Stage41HeatColor(bull,cprob);
         if(cprob>=94) cclr=InpClusterColor;

         datetime cStart=g_instZones[i].time1;
         for(int k=0;k<n;k++)
         {
            if(k==i) continue;
            if(IsInstitutionalZoneExpired(g_instZones[k]) || g_instZones[k].mitigated) continue;
            if(IsBullishZoneType(g_instZones[k].type)!=bull) continue;
            bool sameCluster=ZonesOverlap(g_instZones[i],g_instZones[k]);
            if(!sameCluster)
            {
               double tol=InpClusterTolerancePips*g_pip;
               sameCluster=PriceInsideZone(ZoneMid(g_instZones[k]),g_instZones[i],tol) ||
                           PriceInsideZone(ZoneMid(g_instZones[i]),g_instZones[k],tol);
            }
            if(sameCluster && g_instZones[k].time1<cStart)
               cStart=g_instZones[k].time1;
         }

         datetime clusterEnd=now+(datetime)(InpRendererClusterProjectionBars*sec);
         datetime minClusterStart=now-(datetime)(InpRendererClusterProjectionBars*sec);
         if(cStart<minClusterStart) cStart=minClusterStart;
         DrawTransparentRectEx(cnm+"_BOX",cStart,ct,clusterEnd,cb,cclr,InpClusterBoxAlpha,STYLE_SOLID,true,true,(cprob>=90?3:2),5);
         double mid=(ct+cb)/2.0;
         datetime labelTime=cStart+(clusterEnd-cStart)/2;
         string label=Stage41ClusterLabel(bull,cprob,members);
         DrawTextEx(cnm+"_TXT",labelTime,mid,label,clrWhite,ANCHOR_CENTER,InpBaseLabelFontSize+2);
         if(bull) clusterBullDrawn=true; else clusterBearDrawn=true;
      }
   }

   int drawnOB=0, drawnFVG=0, totalZonesDrawn=0;

   // Stage 3.8 pass 2: Zone Manager draws only high-probability non-cluster zones.
   for(int i=n-1;i>=0;i--)
   {
      if(IsInstitutionalZoneExpired(g_instZones[i])) continue;
      if(totalZonesDrawn>=InpRendererMaxVisibleZones) continue;
      if(g_instZones[i].mitigated && !InpShowMitigatedInstitutionalZones) continue;

      int prob=ZoneProbability(g_instZones[i]);
      if(prob<InpMinDrawZoneProbability) continue;
      if(HiddenByStrongerOverlappedZone(i)) continue;
      if(InpHideZoneMembersInsideCluster && ZoneOverlapsDrawnCluster(g_instZones[i],g_renderClusterTops,g_renderClusterBottoms,g_renderClusterBulls,g_renderClusterCount)) continue;

      bool bull=IsBullishZoneType(g_instZones[i].type);
      // Stage 3.11: if a cluster exists on this side, standalone members are hidden unless exceptional.
      if(RendererHasClusterForBull(bull) && prob<92) continue;
      bool isFVG=(g_instZones[i].type==LNO_ZONE_BULL_FVG || g_instZones[i].type==LNO_ZONE_BEAR_FVG);

      if(isFVG)
      {
         if(drawnFVG>=InpShowLastFVGZones) continue;
         drawnFVG++;
      }
      else
      {
         if(drawnOB>=InpShowLastOBZones) continue;
         drawnOB++;
      }

      color clr=ZoneColor(g_instZones[i]);
      datetime endZone=(g_instZones[i].mitigated && g_instZones[i].mitigatedTime>0 ? g_instZones[i].mitigatedTime : tEnd);
      string nm=g_prefix+"INST_"+IntegerToString(g_instZones[i].id);
      int width=ZoneLineWidth(g_instZones[i]);
      int style=ZoneLineStyle(g_instZones[i]);

      int alpha=InpZoneBoxAlpha;
      if(prob>=90) alpha=MathMin(90,InpZoneBoxAlpha+30);
      else if(prob<80) alpha=MathMax(18,InpZoneBoxAlpha-14);
      if(g_instZones[i].mitigated) { clr=InpMitigatedZoneColor; alpha=20; style=STYLE_DOT; width=1; }

      DrawTransparentRectEx(nm+"_R",g_instZones[i].time1,g_instZones[i].top,endZone,g_instZones[i].bottom,clr,alpha,style,true,InpFillInstitutionalZones,width,2);

      double mid=(g_instZones[i].top+g_instZones[i].bottom)/2.0;
      int anchor=(bull?ANCHOR_LOWER:ANCHOR_UPPER);
      string label=Stage41ZoneKind(g_instZones[i]);
      if(InpShowZoneProbability)
         label += "\n"+IntegerToString(prob)+"%  "+Stage41ZoneClass(prob);
      if(g_instZones[i].mitigated) label="MIT "+label;
      DrawTextEx(nm+"_T",endZone,mid,label,clr,anchor,InpBaseLabelFontSize);
      totalZonesDrawn++;
   }
}

void DrawLiquidity()
{
   if(!InpShowLiquidity || !InpDrawOnChart) return;
   int n=ArraySize(g_liquidity);
   int first=0;
   if(InpShowLastLiquidityZones>0 && n>InpShowLastLiquidityZones)
      first=n-InpShowLastLiquidityZones;

   int sec=PeriodSeconds(InpStructureTF); if(sec<=0) sec=300;
   datetime now=iTime(g_symbol,InpStructureTF,0);
   datetime tEnd=now+(datetime)(InpLiquidityProjectionBars*sec);

   int liqDrawn=0;
   for(int i=n-1;i>=first;i--)
   {
      if(liqDrawn>=4) break;
      int prob=LiquidityProbability(g_liquidity[i]);
      if(prob<InpMinDrawLiquidityProbability) continue;

      bool buySide=IsBuySideLiquidity(g_liquidity[i].type);
      if(InpHideZoneMembersInsideCluster && RendererPriceInsideCluster(g_liquidity[i].price,buySide)) continue;
      if(RendererHasClusterForBull(buySide) && prob<92) continue;
      color clr=LiquidityDisplayColor(g_liquidity[i]);
      int style=(g_liquidity[i].swept?STYLE_DOT:(g_liquidity[i].external?STYLE_SOLID:STYLE_DASH));
      int width=(prob>=85?2:1);
      string nm=g_prefix+"LIQ_"+IntegerToString(g_liquidity[i].id);
      datetime endLine=(g_liquidity[i].swept && g_liquidity[i].sweptTime>0 ? g_liquidity[i].sweptTime : tEnd);

      DrawLineEx(nm+"_L",g_liquidity[i].time1,g_liquidity[i].price,endLine,g_liquidity[i].price,clr,style,width);

      string label=LiquidityCode(g_liquidity[i]);
      if(InpUseCompactLiquidityLabels && InpShowLiquidityStrength)
         label += "-" + StrengthInitial(g_liquidity[i].strength);
      if(InpShowZoneProbability)
         label += "\n" + IntegerToString(prob)+"%";

      double yoff=(buySide?4*g_pip:-4*g_pip);
      int fnt=(g_liquidity[i].external ? InpBaseLabelFontSize+1 : InpBaseLabelFontSize);
      DrawTextEx(nm+"_T",endLine,g_liquidity[i].price+yoff,label,clr,(buySide?ANCHOR_LOWER:ANCHOR_UPPER),fnt);
      liqDrawn++;
   }
}

void DrawSwings()
{
   if(!InpShowSwingLabels) return;
   int n=ArraySize(g_swings);
   int first=0;
   if(InpUI20CompactMode && InpShowLastSwings>0 && n>InpShowLastSwings)
      first=n-InpShowLastSwings;

   for(int i=first;i<n;i++)
   {
      string tag;
      if(InpUI20CompactMode)
      {
         tag=CompactSwingLabel(g_swings[i]);
      }
      else
      {
         tag=g_swings[i].isHigh ? "SH" : "SL";
         if(g_swings[i].level>=2) tag="E-"+tag; else if(g_swings[i].level==1) tag="I-"+tag; else tag="m-"+tag;
         tag=(g_swings[i].strong?"S ":"W ")+tag;
         if(InpShowStructureID) tag+=" #"+IntegerToString(g_swings[i].id);
         if(InpShowStrength) tag+=" ("+IntegerToString(g_swings[i].strength)+")";
      }

      color clr=g_swings[i].isHigh ? InpSwingHighColor : InpSwingLowColor;
      if(g_swings[i].level>=2) clr=InpExternalColor;
      else if(g_swings[i].level==1) clr=InpInternalColor;
      if(g_swings[i].level>=2 && !InpShowExternalStructure) continue;
      if(g_swings[i].level==1 && !InpShowInternalStructure) continue;
      if(g_swings[i].level==0 && InpOnlyMajorSwings) continue;

      int lane=LabelLane(g_swings[i].id,6);
      double offset=(g_swings[i].isHigh ? (8+lane*4)*g_pip : -(8+lane*4)*g_pip);
      int anchor=(g_swings[i].isHigh ? ANCHOR_LOWER : ANCHOR_UPPER);
      int fnt=(g_swings[i].level>=2 ? InpBaseLabelFontSize+1 : InpBaseLabelFontSize);
      DrawTextEx(g_prefix+"SW_"+IntegerToString(g_swings[i].id),g_swings[i].time,g_swings[i].price+offset,tag,clr,anchor,fnt);
   }
}

void DrawCandidateSwings()
{
   if(!InpShowCandidateSwings || !InpDrawOnChart) return;
   int maxShift=MathMin(InpPivotRightBars, Bars(g_symbol,InpStructureTF)-InpPivotLeftBars-2);
   for(int shift=1; shift<=maxShift; shift++)
   {
      bool ch=IsCandidateHigh(shift);
      bool cl=IsCandidateLow(shift);
      if(!ch && !cl) continue;
      datetime t=iTime(g_symbol,InpStructureTF,shift);
      if(ch)
         DrawTextEx(g_prefix+"CAND_H_"+IntegerToString(shift),t,iHigh(g_symbol,InpStructureTF,shift)+6*g_pip,"C-H",InpCandidateColor,ANCHOR_LOWER,7);
      if(cl)
         DrawTextEx(g_prefix+"CAND_L_"+IntegerToString(shift),t,iLow(g_symbol,InpStructureTF,shift)-6*g_pip,"C-L",InpCandidateColor,ANCHOR_UPPER,7);
   }
}

void DetectStructureBreaks()
{
   ArrayResize(g_events,0);
   g_nextEventId=1;
   g_bias=0;
   g_externalBias=0;
   g_internalBias=0;
   g_lastEvent="NONE";
   g_lastBOSId=0;
   g_lastCHOCHId=0;

   double buffer=InpBreakBufferPips*g_pip;
   int bars=Bars(g_symbol,InpStructureTF);
   int maxScan=MathMin(InpLookbackBars,bars-2);
   int lastEventShift=999999;

   for(int shift=maxScan; shift>=1; shift--)
   {
      double close=iClose(g_symbol,InpStructureTF,shift);
      double high=iHigh(g_symbol,InpStructureTF,shift);
      double low=iLow(g_symbol,InpStructureTF,shift);
      datetime bt=iTime(g_symbol,InpStructureTF,shift);

      if(MathAbs(lastEventShift-shift)<InpMinBarsBetweenEvents) continue;

      int hi=FindBreakCandidate(true,shift,close,high,low,buffer);
      int lo=FindBreakCandidate(false,shift,close,high,low,buffer);

      int chosen=-1; int dir=0;
      if(hi>=0 && lo>=0)
      {
         // Rare outside candle: choose stronger break distance.
         double up=MathAbs(close-g_swings[hi].price);
         double dn=MathAbs(close-g_swings[lo].price);
         if(up>=dn) { chosen=hi; dir=1; } else { chosen=lo; dir=-1; }
      }
      else if(hi>=0) { chosen=hi; dir=1; }
      else if(lo>=0) { chosen=lo; dir=-1; }

      if(chosen<0) continue;

      int referenceBias=g_bias;
      if(InpUseExternalForMainBias && g_swings[chosen].level>=2) referenceBias=g_externalBias;
      else if(InpUseExternalForMainBias && g_swings[chosen].level==1 && g_externalBias!=0) referenceBias=g_internalBias;
      bool isChoch=(referenceBias!=0 && dir!=referenceBias);
      int strength=EventStrength(chosen,shift,dir);
      PushEvent(bt,g_swings[chosen].price,shift,dir,isChoch,chosen,strength);
      if(!InpUseExternalForMainBias) g_bias=dir;
      if(g_swings[chosen].level>=2) g_externalBias=dir;
      else if(g_swings[chosen].level==1) g_internalBias=dir;
      if(InpUseExternalForMainBias)
      {
         if(g_externalBias!=0) g_bias=g_externalBias;
         else if(g_internalBias!=0) g_bias=g_internalBias;
      }
      g_swings[chosen].broken=true;       // BOS/CHOCH once per level only
      lastEventShift=shift;

   }
}

void DrawEvents()
{
   // Quantum AI V2: raw BOS/CHOCH spam is suppressed. QV2DrawMajorStructureEvent() renders one major market shift.
   return;
   if(!InpShowBOS_CHOCH) return;
   int n=ArraySize(g_events);
   int first=0;
   if(InpUI20CompactMode && InpShowLastEvents>0 && n>InpShowLastEvents)
      first=n-InpShowLastEvents;

   for(int i=first;i<n;i++)
   {
      StructureEvent ev=g_events[i];
      int si=FindSwingById(ev.swingId);
      if(si<0) continue;

      color clr;
      if(ev.isChoch) clr=InpCHOCHColor;
      else           clr=(ev.dir>0 ? clrLimeGreen : clrTomato);

      int width=(ev.isChoch ? 2 : (ev.level>=2 ? 2 : 1));
      int fontSize=(ev.isChoch ? InpCHOCHFontSize : InpBaseLabelFontSize);
      string typ=(ev.isChoch ? "CHOCH" : "BOS");
      string label;

      if(InpUI20CompactMode)
      {
         label=CompactEventLabel(ev);
      }
      else
      {
         string dirTxt=(ev.dir>0?"BULL":"BEAR");
         string power=" "+ShortPowerTag(ev.strength);
         string scope=(ev.level>=2?" EXT":" INT");
         label=typ+" "+dirTxt+scope+power;
         if(InpShowStructureID) label+=" #"+IntegerToString(ev.id);
         if(InpShowStrength) label+=" ["+IntegerToString(ev.strength)+"]";
      }

      string nm=g_prefix+typ+"_"+IntegerToString(ev.id);
      int style=(ev.isChoch ? STYLE_DASH : (ev.level>=2 ? STYLE_SOLID : STYLE_DOT));
      if(InpDrawBrokenLevelLines)
         DrawLineEx(nm+"_L",g_swings[si].time,g_swings[si].price,ev.time,g_swings[si].price,clr,style,width);

      int lane=LabelLane(ev.id,7);
      double yoff=(ev.dir>0?(10+lane*4)*g_pip:-(10+lane*4)*g_pip);
      DrawTextEx(nm+"_T",ev.time,g_swings[si].price+yoff,label,clr,(ev.dir>0?ANCHOR_LOWER:ANCHOR_UPPER),fontSize);
   }
}

void DrawPremiumDiscountPreview()
{
   if(!InpShowPremiumDiscountPreview || !InpDrawOnChart) return;

   // Stage 4.1 ICT Dealing Range:
   // Use the latest confirmed external swing and the nearest previous opposite external swing.
   // This prevents old high/low pairs from covering half the chart.
   int latest=-1, opposite=-1;
   for(int i=ArraySize(g_swings)-1;i>=0;i--)
   {
      if(g_swings[i].level<2) continue;
      latest=i;
      break;
   }
   if(latest<0) return;
   for(int j=latest-1;j>=0;j--)
   {
      if(g_swings[j].level<2) continue;
      if(g_swings[j].isHigh!=g_swings[latest].isHigh)
      {
         opposite=j;
         break;
      }
   }
   if(opposite<0) return;

   double high=(g_swings[latest].isHigh?g_swings[latest].price:g_swings[opposite].price);
   double low =(!g_swings[latest].isHigh?g_swings[latest].price:g_swings[opposite].price);
   if(high<low) { double tmp=high; high=low; low=tmp; }
   if(high<=low) return;

   int sec=PeriodSeconds(InpStructureTF); if(sec<=0) sec=300;
   datetime now=iTime(g_symbol,InpStructureTF,0);
   datetime swingStart=(g_swings[latest].time>g_swings[opposite].time ? g_swings[opposite].time : g_swings[latest].time);
   datetime maxStart=now-(datetime)(MathMax(12,InpRendererDealingRangeMaxBars)*sec);
   datetime t1=(swingStart<maxStart ? maxStart : swingStart);
   datetime tEnd=now+(datetime)(MathMax(3,InpPDZoneProjectionBars/3)*sec);

   // If a strong cluster is already visible, keep PD as lines only to avoid visual collision.
   bool fillPD=(InpShowPremiumDiscountZones && InpPDZoneFill && InpDrawICTPremiumDiscountFill);
   if(InpRendererHidePDWhenCluster && g_renderClusterCount>0) fillPD=false;

   double range=high-low;
   double eq=(high+low)/2.0;
   double premLow=eq+range*0.02;
   double discHigh=eq-range*0.02;
   string base=g_prefix+"PD_";

   // V2: ICT dealing range heat bands, very light and limited to the latest confirmed swing range.
   // These are background guides only and never project across the whole chart.
   DrawTransparentRectEx(base+"PREMIUM_BAND",t1,high,tEnd,premLow,InpPremiumColor,10,STYLE_SOLID,true,true,1,-3);
   DrawTransparentRectEx(base+"DISCOUNT_BAND",t1,discHigh,tEnd,low,InpDiscountColor,10,STYLE_SOLID,true,true,1,-3);
   DrawLineEx(base+"HIGH",t1,high,tEnd,high,InpPremiumColor,STYLE_DOT,1);
   DrawLineEx(base+"LOW",t1,low,tEnd,low,InpDiscountColor,STYLE_DOT,1);
   DrawLineEx(base+"EQ",t1,eq,tEnd,eq,InpEquilibriumColor,STYLE_SOLID,2);
   if(InpShowPDZoneLabels)
   {
      DrawTextEx(base+"PREM_TX",tEnd,high,"Premium",InpPremiumColor,ANCHOR_RIGHT_UPPER,InpBaseLabelFontSize);
      DrawTextEx(base+"EQ_TX",tEnd,eq,"EQ",InpEquilibriumColor,ANCHOR_RIGHT,InpBaseLabelFontSize);
      DrawTextEx(base+"DISC_TX",tEnd,low,"Discount",InpDiscountColor,ANCHOR_RIGHT_LOWER,InpBaseLabelFontSize);
   }
}

void DrawInstitutionalRendererBackground()
{
   // Quantum AI V2: background is controlled only by DrawQuantumAIV2RenderingEngine().
   return;
}



//+------------------------------------------------------------------+
//| Quantum AI V2 Rendering Engine                                   |
//| Central story/event renderer: modules analyze; renderer draws.    |
//+------------------------------------------------------------------+
string QV2ScoreTier(const int score)
{
   if(score>=95) return "EXCEPTIONAL";
   if(score>=86) return "VERY HIGH";
   if(score>=76) return "HIGH";
   if(score>=66) return "MEDIUM";
   return "LOW";
}

color QV2EventColor(const int dir,const int score)
{
   if(dir>=0)
   {
      if(score>=90) return clrLimeGreen;
      if(score>=80) return clrSeaGreen;
      return clrDarkGreen;
   }
   if(score>=90) return clrTomato;
   if(score>=80) return clrFireBrick;
   return clrMaroon;
}

string QV2ZoneReason(const InstitutionalZone &z)
{
   string r="";
   bool bull=IsBullishZoneType(z.type);
   bool fvg=(z.type==LNO_ZONE_BULL_FVG || z.type==LNO_ZONE_BEAR_FVG);
   r += (bull ? "Buy" : "Sell");
   r += " ";
   r += (fvg ? "FVG" : "OB");
   if(z.external) r += " + External";
   if(IsInstitutionalCluster(z)) r += " + Cluster";
   return r;
}

int QV2BestZoneIndex(const int dir)
{
   int best=-1;
   int bestScore=-1;
   for(int i=0;i<ArraySize(g_instZones);i++)
   {
      if(g_instZones[i].mitigated) continue;
      if(IsInstitutionalZoneExpired(g_instZones[i])) continue;
      if(IsBullishZoneType(g_instZones[i].type)!=(dir>0)) continue;
      int p=ZoneProbability(g_instZones[i]);
      if(p<InpMinDrawZoneProbability) continue;
      int sc=p + (IsInstitutionalCluster(g_instZones[i])?12:0) + (g_instZones[i].external?6:0);
      if(sc>bestScore)
      {
         bestScore=sc;
         best=i;
      }
   }
   return best;
}

int QV2BestLiquidityIndex(const int dir)
{
   int best=-1;
   int bestScore=-1;
   bool buy=(dir>0);
   for(int i=0;i<ArraySize(g_liquidity);i++)
   {
      if(g_liquidity[i].swept) continue;
      if(IsBuySideLiquidity(g_liquidity[i].type)!=buy) continue;
      int p=LiquidityProbability(g_liquidity[i]);
      if(p<InpMinDrawLiquidityProbability) continue;
      int sc=p+(g_liquidity[i].external?8:0)+(g_liquidity[i].touches>=3?5:0);
      if(sc>bestScore)
      {
         bestScore=sc;
         best=i;
      }
   }
   return best;
}

int QV2LatestMajorEventIndex()
{
   for(int i=ArraySize(g_events)-1;i>=0;i--)
   {
      if(g_events[i].level>=2 || g_events[i].strength>=InpInstitutionalStrength)
         return i;
   }
   if(ArraySize(g_events)>0) return ArraySize(g_events)-1;
   return -1;
}

int QV2EventScore(const int dir,const int zi,const int li)
{
   int score=40;
   if(g_externalBias==dir) score+=14;
   if(g_internalBias==dir) score+=8;
   if(g_externalBias==dir && g_internalBias==dir) score+=8;
   if(zi>=0)
   {
      score += (int)(ZoneProbability(g_instZones[zi])*0.25);
      if(IsInstitutionalCluster(g_instZones[zi])) score+=12;
      if(g_instZones[zi].external) score+=6;
      if(g_instZones[zi].type==LNO_ZONE_BULL_FVG || g_instZones[zi].type==LNO_ZONE_BEAR_FVG) score+=4;
   }
   if(li>=0)
   {
      score += (int)(LiquidityProbability(g_liquidity[li])*0.12);
      if(g_liquidity[li].external) score+=4;
   }
   int ev=QV2LatestMajorEventIndex();
   if(ev>=0 && g_events[ev].dir==dir)
   {
      score+=8;
      if(g_events[ev].isChoch) score+=4;
      if(g_events[ev].strength>=85) score+=5;
   }
   if(score>98) score=98;
   if(score<5) score=5;
   return score;
}

void QV2DrawDealingRange()
{
   if(!InpShowPremiumDiscountPreview || !InpDrawOnChart) return;
   int latest=-1, opposite=-1;
   for(int i=ArraySize(g_swings)-1;i>=0;i--)
   {
      if(g_swings[i].level<2) continue;
      latest=i;
      break;
   }
   if(latest<0) return;
   for(int j=latest-1;j>=0;j--)
   {
      if(g_swings[j].level<2) continue;
      if(g_swings[j].isHigh!=g_swings[latest].isHigh)
      {
         opposite=j;
         break;
      }
   }
   if(opposite<0) return;
   double high=MathMax(g_swings[latest].price,g_swings[opposite].price);
   double low =MathMin(g_swings[latest].price,g_swings[opposite].price);
   if(high<=low) return;
   int sec=PeriodSeconds(InpStructureTF); if(sec<=0) sec=300;
   datetime now=iTime(g_symbol,InpStructureTF,0);
   datetime t1=(g_swings[latest].time>g_swings[opposite].time?g_swings[opposite].time:g_swings[latest].time);
   datetime minStart=now-(datetime)(MathMax(20,InpRendererDealingRangeMaxBars)*sec);
   if(t1<minStart) t1=minStart;
   datetime t2=now+(datetime)(18*sec);
   double range=high-low;
   double eq=(high+low)*0.5;
   double premiumLow=eq+range*0.03;
   double discountHigh=eq-range*0.03;
   string b=g_prefix+"QV2_DR_";
   DrawTransparentRectEx(b+"PREM",t1,high,t2,premiumLow,InpPremiumColor,5,STYLE_SOLID,true,true,1,-5);
   DrawTransparentRectEx(b+"DISC",t1,discountHigh,t2,low,InpDiscountColor,5,STYLE_SOLID,true,true,1,-5);
   DrawLineEx(b+"EQ",t1,eq,t2,eq,InpEquilibriumColor,STYLE_SOLID,1);
   DrawTextEx(b+"EQ_T",t2,eq,"EQ",InpEquilibriumColor,ANCHOR_RIGHT,InpBaseLabelFontSize);
}

void QV2DrawMajorLiquidity()
{
   if(!InpShowLiquidity || !InpDrawOnChart) return;
   int sec=PeriodSeconds(InpStructureTF); if(sec<=0) sec=300;
   datetime now=iTime(g_symbol,InpStructureTF,0);
   datetime t2=now+(datetime)(28*sec);
   for(int side=-1; side<=1; side+=2)
   {
      int idx=QV2BestLiquidityIndex(side);
      if(idx<0) continue;
      int p=LiquidityProbability(g_liquidity[idx]);
      color clr=(side>0?clrAqua:clrGold);
      string nm=g_prefix+"QV2_LIQ_"+IntegerToString(g_liquidity[idx].id);
      string label=(side>0?"BUY SIDE LIQ ":"SELL SIDE LIQ ")+IntegerToString(p)+"%";
      DrawLineEx(nm+"_L",g_liquidity[idx].time1,g_liquidity[idx].price,t2,g_liquidity[idx].price,clr,STYLE_DASH,2);
      DrawTextEx(nm+"_T",t2,g_liquidity[idx].price,label,clr,ANCHOR_RIGHT,InpBaseLabelFontSize+1);
   }
}

void QV2DrawMajorStructureEvent()
{
   if(!InpShowBOS_CHOCH || !InpDrawOnChart) return;
   int idx=QV2LatestMajorEventIndex();
   if(idx<0) return;
   int si=FindSwingById(g_events[idx].swingId);
   if(si<0) return;
   color clr=(g_events[idx].dir>0?clrLimeGreen:clrTomato);
   string nm=g_prefix+"QV2_MSS_"+IntegerToString(g_events[idx].id);
   string txt=(g_events[idx].isChoch?"MAJOR CHOCH ":"MAJOR BOS ");
   txt += (g_events[idx].dir>0?"BULL ":"BEAR ");
   txt += IntegerToString(g_events[idx].strength)+"%";
   DrawLineEx(nm+"_L",g_swings[si].time,g_swings[si].price,g_events[idx].time,g_swings[si].price,clr,STYLE_SOLID,2);
   DrawTextEx(nm+"_T",g_events[idx].time,g_swings[si].price+(g_events[idx].dir>0?10*g_pip:-10*g_pip),txt,clr,(g_events[idx].dir>0?ANCHOR_LOWER:ANCHOR_UPPER),InpBaseLabelFontSize+2);
}

void QV2BuildAndDrawInstitutionalEvent()
{
   if(!InpShowInstitutionalZones || !InpDrawOnChart) return;
   int dir=(g_bias!=0?g_bias:(g_externalBias!=0?g_externalBias:1));
   int zi=QV2BestZoneIndex(dir);
   int li=QV2BestLiquidityIndex(dir);
   if(zi<0 && li<0) return;
   int score=QV2EventScore(dir,zi,li);
   if(score<65) return;
   int sec=PeriodSeconds(InpStructureTF); if(sec<=0) sec=300;
   datetime now=iTime(g_symbol,InpStructureTF,0);
   datetime t1=now-(datetime)(18*sec);
   datetime t2=now+(datetime)(InpRendererClusterProjectionBars*sec);
   double top=0,bottom=0;
   string reasons="";
   if(zi>=0)
   {
      top=g_instZones[zi].top;
      bottom=g_instZones[zi].bottom;
      t1=g_instZones[zi].time1;
      if(t1<now-(datetime)(35*sec)) t1=now-(datetime)(35*sec);
      reasons=QV2ZoneReason(g_instZones[zi]);
      if(IsInstitutionalCluster(g_instZones[zi]))
      {
         double ct,cb; int members=BuildClusterBoundsForZone(zi,ct,cb);
         if(members>=2)
         {
            top=ct; bottom=cb; CapRendererClusterBounds(top,bottom);
            reasons="Sweep + BOS + OB/FVG Cluster";
         }
      }
   }
   else if(li>=0)
   {
      top=g_liquidity[li].price+InpClusterTolerancePips*g_pip*0.35;
      bottom=g_liquidity[li].price-InpClusterTolerancePips*g_pip*0.35;
      reasons=(dir>0?"Buy-side liquidity event":"Sell-side liquidity event");
   }
   if(top<=bottom) return;
   double maxH=InpRendererClusterMaxHeightPips*g_pip*1.4;
   if(top-bottom>maxH)
   {
      double mid=(top+bottom)*0.5;
      top=mid+maxH*0.5;
      bottom=mid-maxH*0.5;
   }
   color clr=QV2EventColor(dir,score);
   string nm=g_prefix+"QV2_EVENT_MAIN";
   int alpha=(score>=90?22:(score>=80?16:12));
   DrawTransparentRectEx(nm+"_BOX",t1,top,t2,bottom,clr,alpha,STYLE_SOLID,true,true,(score>=86?3:2),10);
   // inner heat strip
   double stripTop=(top+bottom)*0.5 + (top-bottom)*0.10;
   double stripBot=(top+bottom)*0.5 - (top-bottom)*0.10;
   DrawTransparentRectEx(nm+"_HEAT",t1,stripTop,t2,stripBot,clr,(int)MathMin(55,alpha+22),STYLE_SOLID,true,true,1,11);
   string side=(dir>0?"BUY EVENT":"SELL EVENT");
   string label=side+"  "+IntegerToString(score)+"%  "+QV2ScoreTier(score)+"\n"+reasons;
   DrawTextEx(nm+"_TXT",t1+(t2-t1)/2,(top+bottom)*0.5,label,clrWhite,ANCHOR_CENTER,InpBaseLabelFontSize+2);
}


//+------------------------------------------------------------------+
//| Stage 4.4 Live Decision Engine                             |
//| One story event replaces scattered indicator objects.             |
//+------------------------------------------------------------------+
string S42DirText(const int dir)
{
   return (dir>=0 ? "BUY" : "SELL");
}

color S42DirColor(const int dir,const int score)
{
   if(dir>=0)
   {
      if(score>=85) return clrLime;
      if(score>=75) return clrLimeGreen;
      return clrSeaGreen;
   }
   if(score>=85) return clrTomato;
   if(score>=75) return clrOrangeRed;
   return clrFireBrick;
}

string S42Grade(const int score)
{
   if(score>=92) return "A+";
   if(score>=84) return "A";
   if(score>=76) return "B+";
   if(score>=68) return "B";
   return "WAIT";
}

int S42PrimaryDirection()
{
   if(g_externalBias!=0 && g_externalBias==g_internalBias) return g_externalBias;
   if(g_externalBias!=0) return g_externalBias;
   if(g_bias!=0) return g_bias;
   return 1;
}

string S42PDLocation(const double price)
{
   int latest=-1, opposite=-1;
   for(int i=ArraySize(g_swings)-1;i>=0;i--)
   {
      if(g_swings[i].level<2) continue;
      latest=i; break;
   }
   if(latest<0) return "PD: unknown";
   for(int j=latest-1;j>=0;j--)
   {
      if(g_swings[j].level<2) continue;
      if(g_swings[j].isHigh!=g_swings[latest].isHigh) { opposite=j; break; }
   }
   if(opposite<0) return "PD: unknown";
   double hi=MathMax(g_swings[latest].price,g_swings[opposite].price);
   double lo=MathMin(g_swings[latest].price,g_swings[opposite].price);
   double eq=(hi+lo)*0.5;
   if(price>eq) return "PD: Premium";
   if(price<eq) return "PD: Discount";
   return "PD: Equilibrium";
}

int S42StoryScore(const int dir,const int zi,const int li,const int ev)
{
   int score=42;
   if(g_externalBias==dir) score+=12;
   if(g_internalBias==dir) score+=8;
   if(g_externalBias==dir && g_internalBias==dir) score+=8;
   if(zi>=0)
   {
      int zp=ZoneProbability(g_instZones[zi]);
      score+=(int)(zp*0.22);
      if(IsInstitutionalCluster(g_instZones[zi])) score+=10;
      if(g_instZones[zi].external) score+=5;
   }
   if(li>=0)
   {
      int lp=LiquidityProbability(g_liquidity[li]);
      score+=(int)(lp*0.10);
      if(g_liquidity[li].external) score+=4;
   }
   if(ev>=0)
   {
      if(g_events[ev].dir==dir) score+=10;
      if(g_events[ev].isChoch) score+=4;
      if(g_events[ev].strength>=InpInstitutionalStrength) score+=5;
   }
   if(score>96) score=96;
   if(score<5) score=5;
   return score;
}

string S42StoryReason(const int dir,const int zi,const int li,const int ev)
{
   string story="";
   if(li>=0)
      story += "Liquidity: "+(dir>0?"Sell-side raid":"Buy-side raid")+"  |  ";
   else
      story += "Liquidity: waiting  |  ";

   if(ev>=0)
   {
      story += (g_events[ev].isChoch?"MSS/CHOCH":"BOS");
      story += (g_events[ev].dir==dir?" aligned":" mixed");
      story += "  |  ";
   }
   else
   {
      story += "Structure: waiting  |  ";
   }

   if(zi>=0)
   {
      bool fvg=(g_instZones[zi].type==LNO_ZONE_BULL_FVG || g_instZones[zi].type==LNO_ZONE_BEAR_FVG);
      story += (IsInstitutionalCluster(g_instZones[zi])?"Cluster":"Zone");
      story += (fvg?" + FVG":" + OB");
   }
   else story += "Zone: waiting";

   return story;
}

void S42DrawDealingRangeLite()
{
   if(!InpShowPremiumDiscountPreview || !InpDrawOnChart) return;
   int latest=-1, opposite=-1;
   for(int i=ArraySize(g_swings)-1;i>=0;i--)
   {
      if(g_swings[i].level<2) continue;
      latest=i; break;
   }
   if(latest<0) return;
   for(int j=latest-1;j>=0;j--)
   {
      if(g_swings[j].level<2) continue;
      if(g_swings[j].isHigh!=g_swings[latest].isHigh) { opposite=j; break; }
   }
   if(opposite<0) return;

   double hi=MathMax(g_swings[latest].price,g_swings[opposite].price);
   double lo=MathMin(g_swings[latest].price,g_swings[opposite].price);
   if(hi<=lo) return;

   int sec=PeriodSeconds(InpStructureTF); if(sec<=0) sec=300;
   datetime now=iTime(g_symbol,InpStructureTF,0);
   datetime t1=(g_swings[latest].time>g_swings[opposite].time?g_swings[opposite].time:g_swings[latest].time);
   datetime minStart=now-(datetime)(MathMax(18,InpRendererDealingRangeMaxBars/2)*sec);
   if(t1<minStart) t1=minStart;
   datetime t2=now+(datetime)(10*sec);
   double eq=(hi+lo)*0.5;
   string b=g_prefix+"S42_DR_";
   DrawLineEx(b+"EQ",t1,eq,t2,eq,InpEquilibriumColor,STYLE_SOLID,1);
   DrawTextEx(b+"EQ_T",t2,eq,"EQ",InpEquilibriumColor,ANCHOR_RIGHT,InpBaseLabelFontSize);
   DrawLineEx(b+"HI",t1,hi,t2,hi,InpPremiumColor,STYLE_DOT,1);
   DrawLineEx(b+"LO",t1,lo,t2,lo,InpDiscountColor,STYLE_DOT,1);
}

void S42DrawInstitutionalStory()
{
   if(!InpDrawOnChart) return;
   int dir=S42PrimaryDirection();
   int zi=QV2BestZoneIndex(dir);
   int li=QV2BestLiquidityIndex(dir);
   int ev=QV2LatestMajorEventIndex();
   int score=S42StoryScore(dir,zi,li,ev);
   if(score<62 && zi<0 && li<0) return;

   int sec=PeriodSeconds(InpStructureTF); if(sec<=0) sec=300;
   datetime now=iTime(g_symbol,InpStructureTF,0);
   datetime t1=now-(datetime)(14*sec);
   datetime t2=now+(datetime)(22*sec);
   double top=0,bottom=0;

   if(zi>=0)
   {
      top=g_instZones[zi].top;
      bottom=g_instZones[zi].bottom;
      t1=g_instZones[zi].time1;
      if(t1<now-(datetime)(26*sec)) t1=now-(datetime)(26*sec);
      if(IsInstitutionalCluster(g_instZones[zi]))
      {
         double ct,cb; int members=BuildClusterBoundsForZone(zi,ct,cb);
         if(members>=2) { top=ct; bottom=cb; }
      }
   }
   else if(li>=0)
   {
      top=g_liquidity[li].price+InpClusterTolerancePips*g_pip*0.35;
      bottom=g_liquidity[li].price-InpClusterTolerancePips*g_pip*0.35;
   }
   else
   {
      double close=iClose(g_symbol,InpStructureTF,0);
      top=close+12*g_pip;
      bottom=close-12*g_pip;
   }

   if(top<bottom) { double tmp=top; top=bottom; bottom=tmp; }
   double maxH=InpRendererClusterMaxHeightPips*g_pip*1.05;
   if(top-bottom>maxH)
   {
      double mid=(top+bottom)*0.5;
      top=mid+maxH*0.5;
      bottom=mid-maxH*0.5;
   }

   color clr=S42DirColor(dir,score);
   string nm=g_prefix+"S42_STORY";
   int alpha=(score>=84?24:(score>=74?18:12));
   DrawTransparentRectEx(nm+"_BOX",t1,top,t2,bottom,clr,alpha,STYLE_SOLID,true,true,(score>=84?3:2),12);

   double mid=(top+bottom)*0.5;
   double stripTop=mid+(top-bottom)*0.13;
   double stripBot=mid-(top-bottom)*0.13;
   DrawTransparentRectEx(nm+"_HEAT",t1,stripTop,t2,stripBot,clr,(int)MathMin(62,alpha+28),STYLE_SOLID,true,true,1,13);

   string side=S42DirText(dir);
   string label="INSTITUTIONAL STORY\n"+side+"  "+IntegerToString(score)+"%  "+S42Grade(score)+"\n"+S42StoryReason(dir,zi,li,ev);
   if(zi>=0) label += "\n"+S42PDLocation(ZoneMid(g_instZones[zi]));
   DrawTextEx(nm+"_TXT",t1+(t2-t1)/2,mid,label,clrWhite,ANCHOR_CENTER,InpBaseLabelFontSize+2);

   // Draw a simple decision path from the latest major structure event into the story box.
   if(ev>=0)
   {
      DrawLineEx(nm+"_PATH",g_events[ev].time,g_events[ev].price,t1,mid,clr,STYLE_DASH,2);
   }
}

void S42DrawOneLiquidityTarget()
{
   if(!InpShowLiquidity || !InpDrawOnChart) return;
   int dir=S42PrimaryDirection();
   int idx=QV2BestLiquidityIndex(dir);
   if(idx<0) idx=QV2BestLiquidityIndex(-dir);
   if(idx<0) return;
   int sec=PeriodSeconds(InpStructureTF); if(sec<=0) sec=300;
   datetime now=iTime(g_symbol,InpStructureTF,0);
   datetime t2=now+(datetime)(18*sec);
   int prob=LiquidityProbability(g_liquidity[idx]);
   color clr=(IsBuySideLiquidity(g_liquidity[idx].type)?clrAqua:clrGold);
   string side=(IsBuySideLiquidity(g_liquidity[idx].type)?"BUY-SIDE LIQ ":"SELL-SIDE LIQ ");
   string nm=g_prefix+"S42_LIQ_TARGET";
   DrawLineEx(nm+"_L",g_liquidity[idx].time1,g_liquidity[idx].price,t2,g_liquidity[idx].price,clr,STYLE_DASH,2);
   DrawTextEx(nm+"_T",t2,g_liquidity[idx].price,side+IntegerToString(prob)+"%",clr,ANCHOR_RIGHT,InpBaseLabelFontSize+1);
}

void S42DrawMajorStructureOnly()
{
   if(!InpShowBOS_CHOCH || !InpDrawOnChart) return;
   int idx=QV2LatestMajorEventIndex();
   if(idx<0) return;
   int si=FindSwingById(g_events[idx].swingId);
   if(si<0) return;
   color clr=(g_events[idx].dir>0?clrDeepSkyBlue:clrOrangeRed);
   string nm=g_prefix+"S42_MAJOR_"+IntegerToString(g_events[idx].id);
   string txt=(g_events[idx].isChoch?"MSS / CHOCH ":"MAJOR BOS ")+(g_events[idx].dir>0?"BULL ":"BEAR ")+IntegerToString(g_events[idx].strength)+"%";
   DrawLineEx(nm+"_L",g_swings[si].time,g_swings[si].price,g_events[idx].time,g_swings[si].price,clr,STYLE_SOLID,2);
   DrawTextEx(nm+"_T",g_events[idx].time,g_swings[si].price+(g_events[idx].dir>0?8*g_pip:-8*g_pip),txt,clr,(g_events[idx].dir>0?ANCHOR_LOWER:ANCHOR_UPPER),InpBaseLabelFontSize+1);
}


//+------------------------------------------------------------------+
//| Stage 4.4 Live Decision Engine                            |
//| One decision card + one best opportunity zone.                    |
//+------------------------------------------------------------------+
string S43RankText(const int score)
{
   if(score>=92) return "EXCEPTIONAL";
   if(score>=84) return "HIGH QUALITY";
   if(score>=76) return "GOOD";
   if(score>=68) return "AVERAGE";
   return "WAIT";
}

color S43RankColor(const int score,const int dir)
{
   if(score>=92) return (dir>0 ? clrLime : clrTomato);
   if(score>=84) return (dir>0 ? clrLimeGreen : clrOrangeRed);
   if(score>=76) return clrGold;
   if(score>=68) return clrOrange;
   return clrSilver;
}

string S43WaitingText(const int score,const int zi)
{
   if(score<68) return "WAITING SETUP";
   if(zi>=0) return "WAITING PULLBACK";
   return "WAITING CONFIRMATION";
}

string S43LiveStatus(const int dir,const int zi,const int li,const int ev)
{
   double price=iClose(g_symbol,InpStructureTF,0);
   if(zi>=0)
   {
      double ztop=g_instZones[zi].top;
      double zbot=g_instZones[zi].bottom;
      if(ztop<zbot) { double tmp=ztop; ztop=zbot; zbot=tmp; }
      if(price<=ztop && price>=zbot) return "ENTER NOW";
      if(ev>=0) return "READY / WAIT PULLBACK";
      return "ZONE CONFIRMED";
   }
   if(ev>=0) return "SHIFT CONFIRMED";
   if(li>=0) return "LIQUIDITY TAKEN";
   return "WAITING LIQUIDITY";
}

color S43StatusColor(const string status,const color base)
{
   if(status=="ENTER NOW") return clrLime;
   if(status=="READY / WAIT PULLBACK") return clrGold;
   if(status=="SHIFT CONFIRMED") return clrDeepSkyBlue;
   if(status=="LIQUIDITY TAKEN") return clrAqua;
   if(status=="ZONE CONFIRMED") return base;
   return clrSilver;
}

string S43RRText(const int dir,const int zi)
{
   if(zi<0) return "RR  : waiting";
   double top=g_instZones[zi].top;
   double bot=g_instZones[zi].bottom;
   if(top<bot) { double tmp=top; top=bot; bot=tmp; }
   double entry=(top+bot)*0.5;
   double risk=MathAbs(top-bot)*0.55 + 5.0*g_pip;
   if(risk<=0.0) return "RR  : waiting";
   double bestReward=0.0;
   for(int i=ArraySize(g_liquidity)-1;i>=0;i--)
   {
      if(g_liquidity[i].swept) continue;
      double lp=g_liquidity[i].price;
      if(dir>0 && lp>entry) bestReward=MathMax(bestReward,lp-entry);
      if(dir<0 && lp<entry) bestReward=MathMax(bestReward,entry-lp);
   }
   if(bestReward<=0.0) bestReward=risk*3.0;
   double rr=bestReward/risk;
   if(rr>9.9) rr=9.9;
   return "RR  : 1 : "+DoubleToString(rr,1);
}

string S43TimelineText(const string status)
{
   if(status=="WAITING LIQUIDITY") return "Liquidity > Shift > Zone > Entry";
   if(status=="LIQUIDITY TAKEN") return "Liquidity ✓  > Shift > Zone > Entry";
   if(status=="SHIFT CONFIRMED") return "Liquidity ✓  > Shift ✓  > Zone > Entry";
   if(status=="ZONE CONFIRMED" || status=="READY / WAIT PULLBACK") return "Liquidity ✓  > Shift ✓  > Zone ✓  > Entry";
   if(status=="ENTER NOW") return "Liquidity ✓  > Shift ✓  > Zone ✓  > ENTRY NOW";
   return "Liquidity > Shift > Zone > Entry";
}

string S43Reason1(const int dir,const int ev)
{
   if(ev>=0 && g_events[ev].dir==dir)
      return (g_events[ev].isChoch ? "Major CHOCH / MSS" : "External BOS");
   return "Structure waiting";
}

string S43Reason2(const int zi)
{
   if(zi<0) return "Zone waiting";
   bool fvg=(g_instZones[zi].type==LNO_ZONE_BULL_FVG || g_instZones[zi].type==LNO_ZONE_BEAR_FVG);
   if(IsInstitutionalCluster(g_instZones[zi])) return "Institutional Cluster";
   return (fvg ? "Untapped FVG" : "Order Block");
}

string S43Reason3(const int dir,const int li)
{
   if(li<0) return "Liquidity waiting";
   return (dir>0 ? "Sell-side liquidity taken" : "Buy-side liquidity taken");
}

void S43SetCardLabel(const string key,const int row,const string txt,const color clr,const int font=8)
{
   string name=g_prefix+"S43_CARD_"+key;
   if(ObjectFind(0,name)<0)
   {
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_ZORDER,60+row);
   }
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,270);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,42+row*17);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,font);
   ObjectSetString(0,name,OBJPROP_TEXT,txt);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
}

void S43DrawGauge(const int score,const color clr)
{
   string bg=g_prefix+"S43_GAUGE_BG";
   string fg=g_prefix+"S43_GAUGE_FG";
   if(ObjectFind(0,bg)<0)
   {
      ObjectCreate(0,bg,OBJ_RECTANGLE_LABEL,0,0,0);
      ObjectSetInteger(0,bg,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
      ObjectSetInteger(0,bg,OBJPROP_BGCOLOR,clrDimGray);
      ObjectSetInteger(0,bg,OBJPROP_COLOR,clrDimGray);
      ObjectSetInteger(0,bg,OBJPROP_BACK,false);
      ObjectSetInteger(0,bg,OBJPROP_ZORDER,58);
   }
   if(ObjectFind(0,fg)<0)
   {
      ObjectCreate(0,fg,OBJ_RECTANGLE_LABEL,0,0,0);
      ObjectSetInteger(0,fg,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
      ObjectSetInteger(0,fg,OBJPROP_BACK,false);
      ObjectSetInteger(0,fg,OBJPROP_ZORDER,59);
   }
   int fullW=210;
   int fillW=(int)MathMax(6,MathMin(fullW,(fullW*score)/100));
   ObjectSetInteger(0,bg,OBJPROP_XDISTANCE,270);
   ObjectSetInteger(0,bg,OBJPROP_YDISTANCE,134);
   ObjectSetInteger(0,bg,OBJPROP_XSIZE,fullW);
   ObjectSetInteger(0,bg,OBJPROP_YSIZE,8);
   ObjectSetInteger(0,fg,OBJPROP_XDISTANCE,270);
   ObjectSetInteger(0,fg,OBJPROP_YDISTANCE,134);
   ObjectSetInteger(0,fg,OBJPROP_XSIZE,fillW);
   ObjectSetInteger(0,fg,OBJPROP_YSIZE,8);
   ObjectSetInteger(0,fg,OBJPROP_BGCOLOR,clr);
   ObjectSetInteger(0,fg,OBJPROP_COLOR,clr);
}

void S43DrawDecisionCard()
{
   if(!InpDrawOnChart) return;
   int dir=S42PrimaryDirection();
   int zi=QV2BestZoneIndex(dir);
   int li=QV2BestLiquidityIndex(dir);
   int ev=QV2LatestMajorEventIndex();
   int score=S42StoryScore(dir,zi,li,ev);
   color clr=S43RankColor(score,dir);
   string side=(dir>0?"LONG":"SHORT");
   string bg=g_prefix+"S43_CARD_BG";
   if(ObjectFind(0,bg)<0)
   {
      ObjectCreate(0,bg,OBJ_RECTANGLE_LABEL,0,0,0);
      ObjectSetInteger(0,bg,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
      ObjectSetInteger(0,bg,OBJPROP_BGCOLOR,clrBlack);
      ObjectSetInteger(0,bg,OBJPROP_BORDER_TYPE,BORDER_FLAT);
      ObjectSetInteger(0,bg,OBJPROP_BACK,false);
      ObjectSetInteger(0,bg,OBJPROP_ZORDER,55);
   }
   ObjectSetInteger(0,bg,OBJPROP_XDISTANCE,280);
   ObjectSetInteger(0,bg,OBJPROP_YDISTANCE,28);
   ObjectSetInteger(0,bg,OBJPROP_XSIZE,250);
   ObjectSetInteger(0,bg,OBJPROP_YSIZE,285);
   ObjectSetInteger(0,bg,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,bg,OBJPROP_WIDTH,2);

   string liveStatus=S43LiveStatus(dir,zi,li,ev);
   color stClr=S43StatusColor(liveStatus,clr);
   S43SetCardLabel("HDR",0,"QUANTUM AI  |  LIVE DECISION",clrWhite,9);
   S43SetCardLabel("DIR",2,side,clr,14);
   S43SetCardLabel("QUALITY",3,S43RankText(score),clr,10);
   S43SetCardLabel("GRADE",4,"Grade "+S42Grade(score)+"   |   "+IntegerToString(score)+" / 100",clrWhite,9);
   S43DrawGauge(score,clr);
   S43SetCardLabel("STATE_HDR",6,"STATUS",clrDimGray,8);
   S43SetCardLabel("STATE",7,liveStatus,stClr,10);
   S43SetCardLabel("RR",8,S43RRText(dir,zi),clrGold,8);
   S43SetCardLabel("SEP",9,"------------------------------",clrDimGray,7);
   S43SetCardLabel("R1",10,"✓ "+S43Reason1(dir,ev),clrSilver,8);
   S43SetCardLabel("R2",11,"✓ "+S43Reason2(zi),clrSilver,8);
   S43SetCardLabel("R3",12,"✓ "+S43Reason3(dir,li),clrSilver,8);
   S43SetCardLabel("R4",13,"✓ "+S42PDLocation((zi>=0?ZoneMid(g_instZones[zi]):iClose(g_symbol,InpStructureTF,0))),clrSilver,8);
   S43SetCardLabel("TL",15,S43TimelineText(liveStatus),clrDeepSkyBlue,8);
}

void S43DrawBestOpportunityZone()
{
   if(!InpDrawOnChart) return;
   int dir=S42PrimaryDirection();
   int zi=QV2BestZoneIndex(dir);
   int li=QV2BestLiquidityIndex(dir);
   int ev=QV2LatestMajorEventIndex();
   int score=S42StoryScore(dir,zi,li,ev);
   if(score<66) return;

   int sec=PeriodSeconds(InpStructureTF); if(sec<=0) sec=300;
   datetime now=iTime(g_symbol,InpStructureTF,0);
   datetime t1=now-(datetime)(10*sec);
   datetime t2=now+(datetime)(18*sec);
   double top=0,bottom=0;
   if(zi>=0)
   {
      top=g_instZones[zi].top;
      bottom=g_instZones[zi].bottom;
      t1=g_instZones[zi].time1;
      if(t1<now-(datetime)(18*sec)) t1=now-(datetime)(18*sec);
      if(IsInstitutionalCluster(g_instZones[zi]))
      {
         double ct,cb; int members=BuildClusterBoundsForZone(zi,ct,cb);
         if(members>=2) { top=ct; bottom=cb; }
      }
   }
   else if(li>=0)
   {
      top=g_liquidity[li].price+InpClusterTolerancePips*g_pip*0.35;
      bottom=g_liquidity[li].price-InpClusterTolerancePips*g_pip*0.35;
   }
   else return;

   if(top<bottom) { double tmp=top; top=bottom; bottom=tmp; }
   double maxH=InpRendererClusterMaxHeightPips*g_pip*0.85;
   if(top-bottom>maxH)
   {
      double mid=(top+bottom)*0.5;
      top=mid+maxH*0.5;
      bottom=mid-maxH*0.5;
   }
   color clr=S43RankColor(score,dir);
   string nm=g_prefix+"S43_BEST_OPPORTUNITY";
   int alpha=(score>=92?30:(score>=84?24:(score>=76?18:12)));
   DrawTransparentRectEx(nm+"_BOX",t1,top,t2,bottom,clr,alpha,STYLE_SOLID,true,true,(score>=84?3:2),35);
   double mid=(top+bottom)*0.5;
   // Live decision zone: keep the chart clean. The card holds the details.
   string liveStatus=S43LiveStatus(dir,zi,li,ev);
   string label=(dir>0?"BUY ZONE":"SELL ZONE")+"\n"+S42Grade(score);
   DrawTextEx(nm+"_TXT",t1+(t2-t1)/2,mid,label,clrWhite,ANCHOR_CENTER,InpBaseLabelFontSize+2);
   // Soft gradient bands inside the opportunity zone.
   double h=(top-bottom);
   DrawTransparentRectEx(nm+"_G1",t1,top,t2,top-h*0.33,clr,(int)MathMin(70,alpha+18),STYLE_SOLID,true,true,1,36);
   DrawTransparentRectEx(nm+"_G2",t1,top-h*0.33,t2,top-h*0.66,clr,(int)MathMin(58,alpha+10),STYLE_SOLID,true,true,1,36);
   DrawTransparentRectEx(nm+"_G3",t1,top-h*0.66,t2,bottom,clr,alpha,STYLE_SOLID,true,true,1,36);
   // Shorter, cleaner path arrow from the shift area into the active decision zone.
   datetime a1=t1-(datetime)(4*sec);
   double ap=(dir>0 ? top+h*0.65 : bottom-h*0.65);
   if(ev>=0)
      DrawLineEx(nm+"_ARROW",a1,ap,t1,mid,clr,STYLE_DASH,2);
}

void S43DrawMinimalStructureShift()
{
   if(!InpShowBOS_CHOCH || !InpDrawOnChart) return;
   int idx=QV2LatestMajorEventIndex();
   if(idx<0) return;
   int si=FindSwingById(g_events[idx].swingId);
   if(si<0) return;
   color clr=(g_events[idx].dir>0?clrDeepSkyBlue:clrTomato);
   string nm=g_prefix+"S43_SHIFT_"+IntegerToString(g_events[idx].id);
   string txt=(g_events[idx].dir>0?"↑ Institutional Shift":"↓ Institutional Shift");
   DrawLineEx(nm+"_L",g_swings[si].time,g_swings[si].price,g_events[idx].time,g_swings[si].price,clr,STYLE_SOLID,2);
   DrawTextEx(nm+"_T",g_events[idx].time,g_swings[si].price+(g_events[idx].dir>0?8*g_pip:-8*g_pip),txt,clr,(g_events[idx].dir>0?ANCHOR_LOWER:ANCHOR_UPPER),InpBaseLabelFontSize+1);
}

void DrawQuantumAIStage43DecisionCard()
{
   if(!InpDrawOnChart) return;
   RendererResetClusters();
   DrawSessionBoxes();
   S42DrawDealingRangeLite();
   S43DrawBestOpportunityZone();
   S43DrawMinimalStructureShift();
   S43DrawDecisionCard();
}

void DrawQuantumAIV2RenderingEngine()
{
   DrawQuantumAIStage43DecisionCard();
}

void DrawUnifiedInstitutionalRenderer()
{
   DrawQuantumAIV2RenderingEngine();
}

void DrawLegend()
{
   if(!InpShowLegend || !InpDrawOnChart) return;
   string bg=g_prefix+"LEG_BG";
   string tx=g_prefix+"LEG_TXT";
   if(ObjectFind(0,bg)<0)
   {
      ObjectCreate(0,bg,OBJ_RECTANGLE_LABEL,0,0,0);
      ObjectSetInteger(0,bg,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
      ObjectSetInteger(0,bg,OBJPROP_XDISTANCE,8);
      ObjectSetInteger(0,bg,OBJPROP_YDISTANCE,178);
      ObjectSetInteger(0,bg,OBJPROP_XSIZE,245);
      ObjectSetInteger(0,bg,OBJPROP_YSIZE,118);
      ObjectSetInteger(0,bg,OBJPROP_BGCOLOR,clrBlack);
      ObjectSetInteger(0,bg,OBJPROP_BORDER_TYPE,BORDER_FLAT);
      ObjectSetInteger(0,bg,OBJPROP_COLOR,clrDimGray);
      ObjectSetInteger(0,bg,OBJPROP_BACK,false);
   }
   if(ObjectFind(0,tx)<0)
   {
      ObjectCreate(0,tx,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,tx,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
      ObjectSetInteger(0,tx,OBJPROP_XDISTANCE,235);
      ObjectSetInteger(0,tx,OBJPROP_YDISTANCE,186);
      ObjectSetInteger(0,tx,OBJPROP_FONTSIZE,8);
      ObjectSetInteger(0,tx,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
   }
   string txt="STRUCTURE LEGEND\n"
              "BOS^ / BOSv  = Break of Structure\n"
              "CH^ / CHv     = CHOCH\n"
              "EXT / INT     = External / Internal\n"
              "S-SH / W-SH   = Strong / Weak High\n"
              "S-SL / W-SL   = Strong / Weak Low\n"
              "Blue line     = EQ 50%";
   ObjectSetString(0,tx,OBJPROP_TEXT,txt);
   ObjectSetInteger(0,tx,OBJPROP_COLOR,clrSilver);
}

void DrawBottomStatusBar()
{
   if(!InpShowBottomStatusBar || !InpDrawOnChart) return;
   string name=g_prefix+"BOTTOM_BAR";
   if(ObjectFind(0,name)<0)
   {
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_LOWER);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,12);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,18);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,8);
      ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_LEFT_LOWER);
      ObjectSetInteger(0,name,OBJPROP_ZORDER,20);
   }

   string bias=BiasText(g_bias);
   string nextBuy=StrongestLiquidityText(true);
   string nextSell=StrongestLiquidityText(false);
   string lastSweep=LastSweepText();
   int active=g_activeBuyLiquidity+g_activeSellLiquidity;

   string txt="Quantum AI Stage 4.4 Live Decision Ready  |  Structure: "+bias+
              "  |  Liquidity: "+IntegerToString(active)+" Active"+
              "  |  Last Sweep: "+lastSweep+
              "  |  Next Buy: "+nextBuy+
              "  |  Next Sell: "+nextSell;

   ObjectSetString(0,name,OBJPROP_TEXT,txt);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrSilver);
}

void SetPanelLine(const string key,const int row,const string text,const color clr,const int fontSize=8)
{
   string name=g_prefix+"PANEL_"+key;
   if(ObjectFind(0,name)<0)
   {
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_ZORDER,20+row);
   }

   // Stage 2.4 panel polish: more width/height, better line spacing, no clipped legend lines.
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,24);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,38+row*17);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontSize);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
}


void DrawPanel()
{
   if(!InpShowLastStatePanel || !InpShowProPanel) return;

   string bg=g_prefix+"PANEL_BG";
   if(ObjectFind(0,bg)<0)
   {
      ObjectCreate(0,bg,OBJ_RECTANGLE_LABEL,0,0,0);
      ObjectSetInteger(0,bg,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,bg,OBJPROP_XDISTANCE,12);
      ObjectSetInteger(0,bg,OBJPROP_YDISTANCE,28);
      ObjectSetInteger(0,bg,OBJPROP_BGCOLOR,clrBlack);
      ObjectSetInteger(0,bg,OBJPROP_BORDER_TYPE,BORDER_FLAT);
      ObjectSetInteger(0,bg,OBJPROP_BACK,false);
      ObjectSetInteger(0,bg,OBJPROP_ZORDER,1);
   }
   ObjectSetInteger(0,bg,OBJPROP_XSIZE,InpPanelWidth);
   ObjectSetInteger(0,bg,OBJPROP_YSIZE,InpPanelHeight);
   ObjectSetInteger(0,bg,OBJPROP_BGCOLOR,clrBlack);
   ObjectSetInteger(0,bg,OBJPROP_COLOR,clrSilver);
   ObjectSetInteger(0,bg,OBJPROP_WIDTH,2);

   string bias=BiasText(g_bias);
   string ebias=BiasArrowText(g_externalBias);
   string ibias=BiasArrowText(g_internalBias);
   string phase=PhaseText();

   int active=g_activeBuyLiquidity+g_activeSellLiquidity;
   string nextBuy=StrongestLiquidityText(true);
   string nextSell=StrongestLiquidityText(false);
   string lastSweep=LastSweepText();
   int buyPct=PercentOf(g_activeBuyLiquidity,active);
   int sellPct=PercentOf(g_activeSellLiquidity,active);

   SetPanelLine("HDR",0,"QUANTUM AI | STAGE 4.4 LIVE DECISION",clrWhite,9);
   SetPanelLine("STR",1,"Market Structure : "+bias,BiasColor(g_bias),8);
   SetPanelLine("EXT",2,"External : "+ebias+" ("+IntegerToString(InternalExternalScore(1))+"%)",BiasColor(g_externalBias),8);
   SetPanelLine("INT",3,"Internal : "+ibias+" ("+IntegerToString(InternalExternalScore(0))+"%)",BiasColor(g_internalBias),8);
   SetPanelLine("PHS",4,"Market Phase : "+phase,PhaseColor(phase),8);

   SetPanelLine("TOT",5,"TOTAL Liquidity : "+IntegerToString(active),clrDeepSkyBlue,8);
   SetPanelLine("BUYCOUNT",6,"BUY  : "+IntegerToString(g_activeBuyLiquidity)+" ("+IntegerToString(buyPct)+"%)",InpBuyLiquidityColor,8);
   SetPanelLine("SELLCOUNT",7,"SELL : "+IntegerToString(g_activeSellLiquidity)+" ("+IntegerToString(sellPct)+"%)",InpSellLiquidityColor,8);

   SetPanelLine("BUY",8,"Next Buy  : "+nextBuy,StrongestLiquidityColor(true),8);
   SetPanelLine("SEL",9,"Next Sell : "+nextSell,StrongestLiquidityColor(false),8);
   SetPanelLine("SWP",10,"Last Sweep: "+lastSweep,LastSweepColor(),8);
   if(InpShowLiquidityTimeline)
   {
      SetPanelLine("TL1",11,LastEventTimelineText(),clrSilver,7);
      SetPanelLine("TL2",12,LastInstitutionalTimelineText(),clrSilver,7);
   }

   if(InpShowInstitutionalPanel)
   {
      SetPanelLine("INSTHDR",13,"Institutional Map : "+InstitutionalPhaseText(),clrDeepSkyBlue,8);
      SetPanelLine("OB1",14,"Bull OB/FVG : "+IntegerToString(g_activeBullOB)+" / "+IntegerToString(g_activeBullFVG),InpBullOBColor,8);
      SetPanelLine("OB2",15,"Bear OB/FVG : "+IntegerToString(g_activeBearOB)+" / "+IntegerToString(g_activeBearFVG),InpBearOBColor,8);
      SetPanelLine("NZ1",16,"Next Bull Zone : "+StrongestInstitutionalText(true),StrongestInstitutionalColor(true),8);
      SetPanelLine("NZ2",17,"Next Bear Zone : "+StrongestInstitutionalText(false),StrongestInstitutionalColor(false),8);
   }

   if(InpShowLiquidityLegend)
   {
      SetPanelLine("LG1",18,"IBL = Internal Buy     ISL = Internal Sell",clrSilver,7);
      SetPanelLine("LG2",19,"EBL = External Buy     ESL = External Sell",clrSilver,7);
      SetPanelLine("LGH",20,"High = Strong    Medium = Balanced    Weak = Low",clrSilver,7);
   }

   if(InpShowInstitutionalBias)
   {
      SetPanelLine("IBIAS",21,"Institution Bias : "+InstitutionalBiasText(),InstitutionalBiasColor(),9);
      SetPanelLine("IBIASR",22,InstitutionalBiasReason(),InstitutionalBiasColor(),7);
   }

   if(InpShowLiquidityConfidence)
   {
      int cscore=SmartConfidenceScore();
      string ctxt=ConfidenceTierText(cscore);
      color cclr=ConfidenceTierColor(cscore);
      SetPanelLine("CNF",23,"Quantum AI Confidence : "+ctxt,cclr,9);
      SetPanelLine("CNFS",24,"Confidence Score : "+IntegerToString(cscore)+" / 100",cclr,8);
   }
}

void Recalculate()
{
   if(InpDrawOnChart) DeleteObjects();
   DetectSwings();
   DetectStructureBreaks();
   DetectLiquidity();
   DetectInstitutionalZones();
   DrawInstitutionalRendererBackground();
   DrawUnifiedInstitutionalRenderer();
   DrawSwings();
   DrawCandidateSwings();
   // Stage 4.2: raw BOS/CHOCH labels are replaced by the Institutional Story event.
   // DrawEvents();
   DrawPanel();
   DrawLegend();
   DrawBottomStatusBar();
   ChartRedraw(0);
   if(InpPrintDebug)
      Print("LNO Quantum Stage 4.3: swings=",ArraySize(g_swings)," events=",ArraySize(g_events)," bias=",g_bias," last=",g_lastEvent);
}

int OnInit()
{
   g_symbol=(InpTradeSymbol==""?_Symbol:InpTradeSymbol);
   g_pip=PipSize();
   g_prefix="LNO_QAI_V2_"+g_symbol+"_"+IntegerToString((int)InpStructureTF)+"_";
   if(InpClearObjectsOnInit) DeleteObjects();
   Print("Initialized LikeNoOther Gold Quantum AI Stage 4.4 Live Decision Engine on ",g_symbol," TF=",EnumToString(InpStructureTF)," PipSize=",DoubleToString(g_pip,3));
   Recalculate();
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   // Keep drawings for review. Set InpClearObjectsOnInit=true and reload to clear old objects.
}

void OnTick()
{
   if(InpRunOnNewBarOnly)
   {
      if(!IsNewBar()) return;
   }
   Recalculate();
}
//+------------------------------------------------------------------+