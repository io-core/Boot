# ------------ building the BASIC compiler ----------------
Batch.Run
|> OXP.Compile OXT.Mod/s OXS.Mod/s OXB.Mod/s ~
|> OXP.Compile OXX.Mod/s OXG.Mod/s OXP.Mod/s BXP.Mod/s ~
|> OXP.Compile OXLinker.Mod/s ~
|> System.Free BXP OXP OXG OXX OXT OXB OXS ~
||
Batch.Run
|> BXP.Compile Test.Bas/s ~
|| 

 
