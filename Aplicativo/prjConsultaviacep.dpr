program prjConsultaviacep;

uses
  Vcl.Forms,
  UConsultaviacep in 'UConsultaviacep.pas' {frmConsultaCEP},
  Udados in 'Udados.pas' {dados: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmConsultaCEP, frmConsultaCEP);
  Application.CreateForm(Tdados, dados);
  Application.Run;
end.
