program TriumVirat;

uses
  Forms,
  Unitanimation in 'Unitanimation.pas' {FTriumvirat};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFTriumvirat, FTriumvirat);
  Application.Run;
end.
