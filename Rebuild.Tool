ORP.Compile Batch.Mod/s ~
# ------------ building the system ----------------
Batch.Run
|> ORP.Compile OXS.Mod/s OXB.Mod/s OXT.Mod/s ;
|> ORP.Compile OXX.Mod/s OXG.Mod/s OXP.Mod/s ;
|> ORP.Compile OXLinker.Mod/s ;
|> System.Free OXP OXG OXX OXT OXB OXS ;
|> Batch.Collect ;
||
Batch.Run
|> OXP.Compile Kernel.Mod/s FileDir.Mod/s Files.Mod/s Modules.Mod/s ;
|> OXLinker.Link Modules ;
|> Batch.Collect ;
|> OXP.Compile Input.Mod/s Display.Mod/s Viewers.Mod/s ;
|> OXP.Compile Fonts.Mod/s MIME.Mod/s Texts.Mod/s ;
|> OXP.Compile Oberon.Mod/s ;
|> OXP.Compile MenuViewers.Mod/s ;
|> OXP.Compile TextFrames.Mod/s ;
|> OXP.Compile System.Mod/s Stdio.Mod/s Batch.Mod/s Halt.Mod/s Fail.Mod/s;
|> OXP.Compile Edit.Mod/s Tools.Mod/s ;
|> Batch.Collect ;
|> OXP.Compile PCLink1.Mod/s Clipboard.Mod/s ;
|> OXP.Compile RS232.Mod/s SCC.Mod/s Net.Mod/s ;
|> OXP.Compile Graphics.Mod/s GraphicFrames.Mod/s ;
|> OXP.Compile GraphTool.Mod/s MacroTool.Mod/s Draw.Mod/s ;
|> OXP.Compile Curves.Mod/s Sierpinski.Mod/s ;
|> OXP.Compile Hilbert.Mod/s Stars.Mod/s ;
|> Batch.Collect ;
|> OXP.Compile Rectangles.Mod/s Checkers.Mod/s ;
|> OXP.Compile Math.Mod/s PIO.Mod/s Blink.Mod/s ;
|> Batch.Collect ;
|> OXP.Compile ORS.Mod/s ORB.Mod/s ;
|> OXP.Compile ORG.Mod/s ORP.Mod/s ;
|> Batch.Collect ;
||

|> ORP.Compile OXS.Mod/s OXB.Mod/s OXT.Mod/s ;
|> Batch.Collect ;
|> ORP.Compile OXX.Mod/s ;
|> Batch.Collect ;
|> ORP.Compile OXG.Mod/s ;
|> Batch.Collect ;
|> ORP.Compile OXP.Mod/s ;
|> Batch.Collect ;
|> ORP.Compile ORDis.Mod/s ; 
|> Batch.Collect ;
|> ORP.Compile OIDis.Mod/s ;
|> Batch.Collect ;
|> ORP.Compile OADis.Mod/s ;
|> Batch.Collect ;
|> ORP.Compile OaDis.Mod/s ;
|> Batch.Collect ;
|> ORP.Compile OvDis.Mod/s ;
|> Batch.Collect ;
|> ORP.Compile OXDis.Mod/s ;
|> Batch.Collect ;
|> ORP.Compile  OXTool.Mod/s ;
|> Batch.Collect ;
||
|> System.Free OXP OXG OXX OXT OXB OXS ;
|| 

 
