{TriumVirat par cantador}

unit Unitanimation;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls, Math, Spin;

type
  TFTriumvirat = class(TForm)
    Timer1: TTimer;
    LBDelphiProg: TLabel;
    LBFoxi: TLabel;
    LBCirec: TLabel;
    edlargeur: TSpinEdit;
    edhauteur: TSpinEdit;
    Image1: TImage;
    PaintBox1: TPaintBox;
    Panel1: TPanel;
    Button1: TButton;
    Label1: TLabel;
    Edit1: TEdit;
    TrackBar1: TTrackBar;
    CheckBox1: TCheckBox;
    ImaFloc: TImage;
    Timer2: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
  end;

var
  FTriumvirat: TFTriumvirat;
  BmpImage1, BmpImage2, BmpImage3, BmpFond, BmpInvisible: TBitmap;
  W, H: integer;
  NewRect1, OldRect1, NewRect2, OldRect2, NewRect3, OldRect3: TRect;
  X1, Y1, X2, Y2, X3, Y3: integer;
  xx1, yy1, xx2, yy2, xx3, yy3, vx1, vy1, vx2, vy2, vx3, vy3: single;
  UnionR: Trect;

implementation

{$R *.DFM}

Const
  MaxFloc = 100;
  Vent: TPoint = (X: -4; Y: 10);
  ZoomRatio: Array[1..20] Of Byte =
  (2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 7, 8, 9, 10);

Type
  TFloc = Class
    FIma: TBitmap;
    Zoom: Integer;
    PosX: Single;
    PosY: Single;
    RIma: TRect;
    Constructor Create;
    Procedure MoveIt;
  End;

Var
  AFloc: Array[1..MaxFloc] Of TFloc;


{----------------------------------------------------------------}
{ Création d'un flocon                                           }
{----------------------------------------------------------------}
Constructor TFloc.Create;
Begin
  Zoom := ZoomRatio[RandomRange(1, 20)];
  FIma := TBitmap.Create;
  FIma.Width := Round(FTriumvirat.ImaFloc.Width * (Zoom / 100));
  FIma.Height := Round(FTriumvirat.ImaFloc.Height * (Zoom / 100));
  FIma.PixelFormat := pf24bit;
  FIma.Transparent := True;
  FIma.Canvas.StretchDraw(FIma.Canvas.ClipRect, FTriumvirat.ImaFloc.Picture.Bitmap);
  PosY := RandomRange(0, FTriumvirat.ClientHeight);
  PosX := RandomRange(0, FTriumvirat.ClientWidth);
  RIma.Left := Round(PosX);
  RIma.Top := Round(PosY);
  RIma.Right := RIma.Left + FIma.Width;
  RIma.Bottom := RIma.Top + FIma.Height;
End;


{----------------------------------------------------------------}
{ Restaure, déplace et déssine un flocon                         }
{----------------------------------------------------------------}
Procedure TFloc.MoveIt;
Begin
  FTriumvirat.Canvas.CopyRect(RIma, FTriumvirat.ImaFloc.Picture.Bitmap.Canvas, RIma);
  PosX := PosX + ((Vent.X * RandomRange(3, 5 * Zoom)) / 30);
  PosY := PosY + ((Vent.Y * RandomRange(3, 5 * Zoom)) / 30);
  RIma.Left := Round(PosX);
  RIma.Top := Round(PosY);
  RIma.Right := RIma.Left + FIma.Width;
  RIma.Bottom := RIma.Top + FIma.Height;
  FTriumvirat.Canvas.StretchDraw(RIma, FIma);
  If (PosY > FTriumvirat.ClientHeight) And (Vent.Y > 0) Then
  Begin
    PosX := RandomRange(0, FTriumvirat.ClientWidth);
    PosY := -FIma.Height;
  End
  ELse
  If (PosY < FIma.Height) And (Vent.Y < 0) Then
  Begin
    PosX := RandomRange(0, FTriumvirat.ClientWidth);
    PosY := FTriumvirat.ClientHeight;
  End;
  If (PosX > FTriumvirat.ClientWidth) And (Vent.X > 0) Then
    PosX := -FIma.Width
  Else
  If (PosX < FIma.Width) And (Vent.X < 0) Then
    PosX :=  FTriumvirat.ClientWidth;
End;



procedure CleanPositionOf(var OldRect: TRect);
begin
{Effacement des anciennes positions}
  BmpInvisible.Canvas.CopyRect(OldRect, bmpFond.canvas, OldRect);
end;

procedure FusionPositionOf(var UnionR, OldRect, NewRect: TRect);
begin
{Union des positions anciennes et nouvelles}
  UnionRect(UnionR, OldRect, NewRect);
  FTriumVirat.PaintBox1.Canvas.CopyRect(UnionR, BmpInvisible.Canvas, UnionR);
  OldRect := NewRect;
end;

procedure NewPositionOf(var vx, vy, xx, yy: single; var x, y: integer; var RNew: TRect; Bmp: TBitmap);
begin
  { rebonds }
  if (x < 0) or (x > Bmpfond.width - W) then
    vx := -vx;
  if (y < 0) or (y > Bmpfond.height - H) then
    vy := -vy;
  xx := xx + vx;
  yy := yy + vy;
  x := trunc(xx);
  y := trunc(yy);
  RNew := bounds(x, y, W, H);
  BmpInvisible.Canvas.Draw(x, y, Bmp);
end;

procedure TFTriumvirat.FormCreate(Sender: TObject);
var
HH :HDC;
 largeur:integer;
 hauteur:integer;

 BMPLoaded : boolean;
 NewH, NewW, OldSBM : integer;
begin
  HH:=getdc(GetDesktopWindow);
  largeur:=GetDeviceCaps(HH,HORZRES);
  hauteur:=GetDeviceCaps(HH,VERTRES);
  edlargeur.value := largeur;
  edhauteur.Value := hauteur;
 
   { initialisation }
  BMPLoaded := false;

  BmpFond := TBitmap.Create;
  BmpFond.LoadFromFile('fond3.bmp');

  BMPLoaded := true;

   { si BMP est prét }
  if BMPLoaded then
  begin
 NewW:=Edlargeur.value  ;
 NewH:=Edhauteur.value ;
  end;

   { enfin on vas injecter BMP dans le bitmap de Image1 (autosize = true) }
        with image1.picture.bitmap do
        begin
          { on definit les nouvelles dimensions }
          width       := NewW;
          height      := NewH;
          { on travail en couleurs 24bpc }
          pixelformat := pf24bit;

          { on sauvegarde l'ancien mode de redimension du canvas }
          OldSBM := GetStretchBltMode(Canvas.Handle);

          { et on le definit en mode HALFTONE }
          SetStretchBltMode(Canvas.Handle, HALFTONE);

          { on dessine l'image }
          StretchBlt( Canvas.Handle, 0, 0, NewW, NewH,
                      BMPfond.Canvas.Handle, 0, 0, BMPfond.Width, BMPfond.Height,
                      SRCCOPY);

          { on restaure le mode de redimensionnement du canvas }
          SetStretchBltMode(Canvas.Handle, OldSBM);

          BMPfond.Assign(image1.picture.bitmap);

  image1.refresh;

  BmpInvisible := TBitmap.Create;
  BmpInvisible.Canvas.StretchDraw(BmpInvisible.Canvas.ClipRect,BmpFond);
  BmpImage1 := TBitmap.Create;
  BmpImage2 := TBitmap.Create;
  BmpImage3 := TBitmap.Create;

  BmpInvisible.Assign(Bmpfond);

  BmpImage1.LoadFromFile('foxirond.bmp');
  BmpImage2.LoadFromFile('delphiprogrond.bmp');
  BmpImage3.LoadFromFile('cirecrond.bmp');
  W := Bmpimage1.width;
  H := Bmpimage1.height;
  BmpImage1.Transparent := true;
  BmpImage1.TransParentColor := BmpImage1.canvas.pixels[1, 1];
  BmpImage2.Transparent := True;
  BmpImage2.TransParentColor := BmpImage2.canvas.pixels[1, 1];
  BmpImage3.Transparent := True;
  BmpImage3.TransParentColor := BmpImage3.canvas.pixels[1, 1];
  
  // initialisation
  xx1 := 1;
  yy1 := 1;
  x1 := trunc(xx1);
  y1 := trunc(yy1);
  vx1 := 1.5;
  vy1 := 0.5;
  NewRect1 := bounds(x1, y1, W, H);
  OldRect1 := NewRect1;

  xx2 := 200;
  yy2 := 200;
  x2 := trunc(xx2);
  y2 := trunc(yy2);
  vx2 := 1.5;
  vy2 := 0.5;
  NewRect2 := bounds(x2, y2, W, H);
  OldRect2 := NewRect2;

  xx3 := 80; yy3 := 80;
  x3 := trunc(xx3);
  y3 := trunc(yy3);
  vx3 := 1.5;
  vy3 := 0.5;
  NewRect3 := bounds(x3, y3, W, H);
  OldRect3 := NewRect3;

  LBDelphiProg.Hint := 'Ben celle-là vous me la copierez..';
  LBFoxi.Hint := 'Même à mon niveau, j''aurai jamais fais un truc pareil..';
  LBCirec.Hint := 'Dis-donc, faudrait p''tet mettre quelque chose dans le zip..';

end;
end;

procedure TFTriumvirat.FormDestroy(Sender: TObject);
begin
  BmpFond.free;
  BmpInvisible.free;
  BmpImage1.Free;
  BmpImage2.Free;
  BmpImage3.Free;
end;

procedure TFTriumvirat.FormPaint(Sender: TObject);
begin
  

  // PaintBox1.Canvas.Draw(0, 0, Bmpfond);
  BMPfond.Assign(image1.picture.bitmap);
  
  
end;

procedure TFTriumvirat.Button1Click(Sender: TObject);
begin
  close;
end;

procedure TFTriumvirat.Timer1Timer(Sender: TObject);
var
  n: integer;
begin
  for n := 1 to trackbar1.position do { boucle de répétition d'affichage }
  begin
    CleanPositionOf(OldRect1);
    CleanPositionOf(OldRect2);
    CleanPositionOf(OldRect3);

    NewPositionOf(vx1, vy1, xx1, yy1, x1, y1, NewRect1, BmpImage1);
    NewPositionOf(vx2, vy2, xx2, yy2, x2, y2, NewRect2, BmpImage2);
    NewPositionOf(vx3, vy3, xx3, yy3, x3, y3, NewRect3, BmpImage3);

    FusionPositionOf(UnionR, OldRect1, NewRect1);
    FusionPositionOf(UnionR, OldRect2, NewRect2);
    FusionPositionOf(UnionR, OldRect3, NewRect3);
  end;
end;

procedure TFTriumvirat.TrackBar1Change(Sender: TObject);
begin
  Edit1.text := inttostr(trackbar1.position);
end;

procedure TFTriumvirat.FormResize(Sender: TObject);
begin
  BmpFond.Width := image1.Width;
  BmpFond.Height := image1.Height;

end;

procedure TFTriumvirat.CheckBox1Click(Sender: TObject);
var
  Cpt: Tpoint;
begin
  //Timer1.Enabled := not (Timer1.Enabled);

  LBDelphiProg.Visible := not (Timer1.Enabled);
  LBFoxi.Visible := not (Timer1.Enabled);
  LBCirec.Visible := not (Timer1.Enabled);

  if not (Timer1.Enabled) then
  begin
    LBFoxi.Left := x1;
    LBFoxi.Top := y1 ;
    LBDelphiProg.Left := x2;
    LBDelphiProg.Top := y2;
    LBCirec.Left := x3;
    LBCirec.Top := y3;

    Application.HintPause := 10;
    Application.HintHidePause := 5000;

    randomize;

    case RandomRange(2, 5) of
      2:
        begin
          Cpt := Point(LBDelphiProg.Width div 2, LBDelphiProg.Height div 2);
          Cpt := LBDelphiProg.ClientToScreen(Cpt);
          SetCursorPos(Cpt.X, Cpt.Y);
        end;
      3:
        begin
          Cpt := Point(LBFoxi.Width div 2, LBFoxi.Height div 2);
          Cpt := LBFoxi.ClientToScreen(Cpt);
          SetCursorPos(Cpt.X, Cpt.Y);
        end;
      4:
        begin
          Cpt := Point(LBCirec.Width div 2, LBCirec.Height div 2);
          Cpt := LBCirec.ClientToScreen(Cpt);
          SetCursorPos(Cpt.X, Cpt.Y);
        end;
    end;
    sleep(1000);
    CheckBox1.SetFocus;
  end;
end;

procedure TFTriumvirat.FormActivate(Sender: TObject);
Var
  i, j: Integer;
  R, G, B: Byte;
Begin

  Randomize;
  { Création des flocons }
  For i := 1 To MaxFloc Do
    AFloc[i] := TFloc.Create;
  Application.ProcessMessages;

  
  { Sauvegarde de l'arrière-plan avant animation }
  ImaFloc.Picture.Bitmap.Width := Width;
  ImaFloc.Picture.Bitmap.Height := Height;
  ImaFloc.Picture.Bitmap.Canvas.CopyRect(ClientRect, Canvas, ClientRect);
  
  { Mise en route de l'animation }
  Timer1.Enabled := True ;
  Timer2.Enabled := True ;

end;

procedure TFTriumvirat.Timer2Timer(Sender: TObject);
Var
  i: Integer;
Begin
  { Mouvements des flocons }
  For i := 1 To MaxFloc Do AFloc[i].MoveIt;
  { Sortie du programme }
  If (GetActiveWindow <> Handle) Then Close;

end;

end.

