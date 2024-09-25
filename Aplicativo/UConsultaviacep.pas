unit UConsultaviacep;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.jpeg, Vcl.ExtCtrls,
  Vcl.StdCtrls, Data.DB, Vcl.Grids, Vcl.DBGrids, Vcl.DBCtrls, Vcl.Mask;

type
  TfrmConsultaCEP = class(TForm)
    Image1: TImage;
    lblcep: TLabel;
    Label2: TLabel;
    edtcep: TEdit;
    edtendereco: TEdit;
    btnconsultar: TButton;
    rbjson: TRadioButton;
    rbxml: TRadioButton;
    gbEnderecos: TGroupBox;
    DBGrid1: TDBGrid;
    dsEnderecos: TDataSource;
    btnLimparCampos: TButton;
    edtCidade: TEdit;
    edtEstado: TEdit;
    lblEstado: TLabel;
    lblCidade: TLabel;
    lblEndereco: TLabel;
    rgTipoPesquisa: TRadioGroup;
    Panel1: TPanel;
    DBNavigator1: TDBNavigator;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    DBEdit1: TDBEdit;
    Label3: TLabel;
    DBEdit2: TDBEdit;
    Label4: TLabel;
    DBEdit3: TDBEdit;
    Label5: TLabel;
    DBEdit4: TDBEdit;
    Label6: TLabel;
    DBEdit5: TDBEdit;
    Label7: TLabel;
    DBEdit6: TDBEdit;
    procedure btnconsultarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnLimparCamposClick(Sender: TObject);
    procedure HabilitaDesabilitaCampos(itemselecionado:Integer);
    procedure rgTipoPesquisaClick(Sender: TObject);
  private
    { Private declarations }
    function Validacampos(itemselecionado:Integer):Boolean;
  public
    { Public declarations }
  end;

var
  frmConsultaCEP: TfrmConsultaCEP;

implementation

{$R *.dfm}

uses Udados, System.StrUtils, System.JSON, Xml.XMLIntf;

procedure TfrmConsultaCEP.btnconsultarClick(Sender: TObject);
var
  Resposta: Integer;
begin

  if rgTipoPesquisa.ItemIndex = 0 then
  begin

    if not Validacampos(rgTipoPesquisa.ItemIndex) then
      Exit;

      try
        if dados.Consultaendereconabase(edtcep.Text, '', '', '') then
        begin
          Resposta := MessageBox(0, 'Deseja que seja mostrado o Endereço encontrado na base(Sim)?' + chr(13) +
                                    'Ou deseja que efetue uma nova consulta' +
                                    ' atualizando as informações do Endereço existente(Não)?', 'Confirmação', MB_YESNO + MB_ICONQUESTION);
          if Resposta = IDNO then
          begin

            try
              if dados.ConsultaporCEPEndereco(edtcep.Text, edtEstado.Text, edtCidade.Text, edtendereco.Text, ifthen(rbjson.Checked,'json','xml'), True) then
                ShowMessage('Registro atualizado com sucesso.');            
            except
              on E: Exception do
                ShowMessage('Ocorreu um erro: ' + e.Message);
            end;
            
          end;
          

        end
        else
        begin
          try
            if dados.ConsultaporCEPEndereco(edtcep.Text, edtEstado.Text, edtCidade.Text, edtendereco.Text, ifthen(rbjson.Checked,'json','xml'), False) then
              ShowMessage('Registro inserido com sucesso.')
            else
              ShowMessage('CEP não foi encontrado');
          except
            on E: Exception do
              ShowMessage('Ocorreu um erro: ' + e.Message);
          end;
        end;
      except
        on E: Exception do
          ShowMessage('Ocorreu um erro: ' + e.Message);
      end;

  end
  else
  begin
    if not Validacampos(rgTipoPesquisa.ItemIndex) then
      Exit;

      try
        if dados.Consultaendereconabase('', edtEstado.Text, edtCidade.Text, edtendereco.Text) then
        begin
          Resposta := MessageBox(0, 'Deseja que seja mostrado o Endereço encontrado na base(Sim)?' + chr(13) +
                                    'Ou deseja que efetue uma nova consulta' +
                                    ' atualizando as informações do Endereço existente(Não)?', 'Confirmação', MB_YESNO + MB_ICONQUESTION);
          if Resposta = IDNO then
          begin
            try
              dados.ConsultaporCEPEndereco(edtcep.Text, edtEstado.Text, edtCidade.Text, edtendereco.Text, ifthen(rbjson.Checked,'json','xml'), True);
              ShowMessage('Registro atualizado com sucesso.');
            except
              on E: Exception do
                ShowMessage('Ocorreu um erro: ' + e.Message);
            end;
          end;
        end
        else
        begin
          try
            if dados.ConsultaporCEPEndereco(edtcep.Text, edtEstado.Text, edtCidade.Text, edtendereco.Text, ifthen(rbjson.Checked,'json','xml'), False) then
              ShowMessage('Registro inserido com sucesso.')
            else
              ShowMessage('CEP não foi encontrado');
          except
            on E: Exception do
              ShowMessage('Ocorreu um erro: ' + e.Message);
          end;
        end;
      except
        on E: Exception do
          ShowMessage('Ocorreu um erro: ' + e.Message);
      end;

  end;





end;

procedure TfrmConsultaCEP.btnLimparCamposClick(Sender: TObject);
begin
  edtcep.Clear;
  edtEstado.Clear;
  edtCidade.Clear;
  edtendereco.Clear;
  rgTipoPesquisa.ItemIndex := 0;
  rbjson.Checked := True;
end;

procedure TfrmConsultaCEP.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  dados.FDQueryEnderecos.Close;
end;

procedure TfrmConsultaCEP.FormShow(Sender: TObject);
begin
  dados.FDQueryEnderecos.Open();
  HabilitaDesabilitaCampos(0);
end;

procedure TfrmConsultaCEP.HabilitaDesabilitaCampos(itemselecionado: Integer);
begin
  case itemselecionado of
    0:begin
      edtEstado.Enabled   := False;
      edtEstado.Clear;
      edtCidade.Enabled   := False;
      edtCidade.Clear;
      edtendereco.Enabled := False;
      edtendereco.Clear;
      edtcep.Enabled      := True;
      edtcep.SetFocus;
    end;
    1:begin
      edtEstado.Enabled   := True;
      edtCidade.Enabled   := True;
      edtendereco.Enabled := True;
      edtcep.Enabled      := False;
      edtcep.Clear;
      edtEstado.SetFocus;
    end;
  end;
end;

procedure TfrmConsultaCEP.rgTipoPesquisaClick(Sender: TObject);
begin
  HabilitaDesabilitaCampos(rgTipoPesquisa.ItemIndex);
end;

function TfrmConsultaCEP.Validacampos(itemselecionado:Integer): Boolean;
begin
  Result := True;


  case itemselecionado of
    0:begin
      if edtcep.Text = '' then
      begin
        ShowMessage('Campo: ' + lblcep.Caption + ' deve ser informado.');
        edtcep.SetFocus;
        Result := False;
      end;
    end;
    1:begin
      if edtEstado.Text = '' then
      begin
        ShowMessage('Campo: ' + lblEstado.Caption + ' deve ser informado.');
        edtEstado.SetFocus;
        Result := False;
      end
      else if (Length(edtEstado.Text) < 2) then
      begin
        ShowMessage('Campo: ' + lblEstado.Caption + ' foi informado incorretamente, tem menos que 2 caracteres.');
        edtEstado.SetFocus;
        Result := False;
      end
      else if edtCidade.Text = '' then
      begin
        ShowMessage('Campo: ' + lblCidade.Caption + ' deve ser informado.');
        edtCidade.SetFocus;
        Result := False;
      end
      else if(Length(edtCidade.Text) < 3) then
      begin
        ShowMessage('Campo: ' + lblCidade.Caption + ' foi informado incorretamente, tem menos que 3 caracteres.');
        edtCidade.SetFocus;
        Result := False;
      end
      else if edtendereco.Text = '' then
      begin
        ShowMessage('Campo: ' + lblEndereco.Caption + ' deve ser informado.');
        edtendereco.SetFocus;
        Result := False;
      end
      else if(Length(edtendereco.Text) < 3) then
      begin
        ShowMessage('Campo: ' + lblEndereco.Caption + ' foi informado incorretamente, tem menos que 3 caracteres.');
        edtendereco.SetFocus;
        Result := False;
      end;
      
    end;
  end;

end;

end.
