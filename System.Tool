System.Open ^  System.Recall  System.Watch  System.Collect
Edit.Open ^  Edit.Recall  
Edit.ChangeFont Oberon10i.Scn.Fnt
Edit.ChangeFont Oberon10b.Scn.Fnt
Edit.ChangeFont DVSans16.Scn.Fnt
Edit.ChangeFont Tahoma8.Scn.Fnt
Edit.ChangeFont unifont.Scn.Fnt

Edit.Open unicode2.txt

System.Directory ^
  *.Mod  *.Bak  *.Tool  *.Text  *.Scn.Fnt  *.smb  *.rsc

OXP.Compile @  OXP.Compile @/s  OXP.Compile name~
System.Free ~
System.Open Draw.Tool
System.CopyFiles ~
System.RenameFiles ~
System.DeleteFiles ~

System.ShowModules  System.ShowCommands ^ 

PCLink1.Run  Hilbert.Draw  Sierpinski.Draw  Blink.Run  Stars.Open

Tools.Inspect 0      OXP.Compile TextFrames.Mod ~
Tools.Sector 1
Tools.ShowFile 
Tools.Recall  Tools.Clear

System.Open Startup.Job
System.Open Build.Tool
System.Open Port.Tool
System.Open Debug.Tool
