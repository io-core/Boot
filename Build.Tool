# ------------ building the system ----------------
Batch.Run
|> OXP.Compile OXS.Mod/s OXB.Mod/s OXT.Mod/s ;
|> OXP.Compile OXX.Mod/s OXG.Mod/s OXP.Mod/s ;
|> OXP.Compile OXLinker.Mod/s ;
|> System.Free OXP OXG OXX OXT OXB OXS ;
||
Batch.Run
|> OXP.Compile Kernel.Mod/s FileDir.Mod/s Files.Mod/s Modules.Mod/s ;
|> OXLinker.Link Modules ;
|> OXLinker.Load Modules.bin ;
|> Batch.Collect ;
|> OXP.Compile Nodes.Mod/s Input.Mod/s Display.Mod/s Viewers.Mod/s ;
|> OXP.Compile Fonts.Mod/s MIME.Mod/s Texts.Mod/s ArgParse.Mod ;
|> OXP.Compile Oberon.Mod/s ;
|> OXP.Compile MenuViewers.Mod/s ;
|> OXP.Compile TextFrames.Mod/s ;
|> OXP.Compile System.Mod/s Stdio.Mod/s Batch.Mod/s Halt.Mod/s Fail.Mod/s;
|> OXP.Compile Edit.Mod/s Tools.Mod/s Performance.Mod/s Fuzzing.Mod/s Test.Mod/s ;
|> Batch.Collect ;
|> OXP.Compile ConvertPCFFont.Mod/s FontSubsetBuilder.Mod/s ;
|> OXP.Compile GrowFont.Mod/s OptimizeFont.Mod/s ;
|> Batch.Collect ;
|> OXP.Compile PCLink1.Mod/s Clipboard.Mod/s ;
|> OXP.Compile RS232.Mod/s SCC.Mod/s Net.Mod/s ;
|> OXP.Compile Graphics.Mod/s GraphicFrames.Mod/s ;
|> OXP.Compile GraphTool.Mod/s MacroTool.Mod/s Draw.Mod/s ;
|> OXP.Compile Curves.Mod/s Sierpinski.Mod/s ;
|> OXP.Compile Hilbert.Mod/s Stars.Mod/s ;
|> OXP.Compile Rectangles.Mod/s Checkers.Mod/s ;
|> OXP.Compile Math.Mod/s PIO.Mod/s Blink.Mod/s ;
|> Batch.Collect ;
|> OXP.Compile OXS.Mod/s OXB.Mod/s OXT.Mod/s ;
|> OXP.Compile OXX.Mod/s OXG.Mod/s OXP.Mod/s ;
|> OXP.Compile ORDis.Mod/s OIDis.Mod/s OADis.Mod/s OaDis.Mod/s OvDis.Mod/s ;
|> OXP.Compile OXDis.Mod/s OXTool.Mod/s ;
||
|> System.Free OXP OXG OXX OXT OXB OXS ;
|| 

 
