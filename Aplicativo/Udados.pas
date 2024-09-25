unit Udados;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, System.Variants, System.JSON,
  REST.Types, REST.Client, Data.Bind.Components, Data.Bind.ObjectScope;

type
  Tdados = class(TDataModule)
    FDConnection: TFDConnection;
    FDQueryEnderecos: TFDQuery;
    FDQueryEnderecoscodigo: TFDAutoIncField;
    FDQueryEnderecoscep: TStringField;
    FDQueryEnderecoslogradouro: TStringField;
    FDQueryEnderecoscomplemento: TStringField;
    FDQueryEnderecosbairro: TStringField;
    FDQueryEnderecoslocalidade: TStringField;
    FDQueryEnderecosuf: TStringField;
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
  private
    { Private declarations }
  public
    { Public declarations }
    function Consultaendereconabase(cep, estado, cidade, endereco:string):Boolean;
    procedure AdicionaRegistro(cep, logradouro, complemento, bairro, localidade, uf: string);
    procedure AtualizaRegistro(cep, logradouro, complemento, bairro, localidade, uf: string);
    procedure LerJSON(sArquivo:string; lista, update:Boolean);
    procedure LerXML(sArquivo:string; update:Boolean);
    function ConsultaporCEPEndereco(cep, estado, cidade, endereco, formato:string; update:Boolean):Boolean;
    function CEPNaoEncontrado(retorno:string):Boolean;
  end;

var
  dados: Tdados;

implementation



{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ Tdados }

uses
  XMLDOC, XMLIntf, UViaCEPComponent;

procedure Tdados.AdicionaRegistro(cep, logradouro, complemento, bairro,
  localidade, uf: string);
begin
  FDQueryEnderecos.Append;
  FDQueryEnderecoscep.Value         := cep;
  FDQueryEnderecoslogradouro.Value  := logradouro;
  FDQueryEnderecoscomplemento.Value := complemento;
  FDQueryEnderecosbairro.Value      := bairro;
  FDQueryEnderecoslocalidade.Value  := localidade;
  FDQueryEnderecosuf.Value          := uf;
  FDQueryEnderecos.Post;
end;

procedure Tdados.AtualizaRegistro(cep, logradouro, complemento, bairro,
  localidade, uf: string);
begin
  FDQueryEnderecos.Edit;
  FDQueryEnderecoscep.Value         := cep;
  FDQueryEnderecoslogradouro.Value  := logradouro;
  FDQueryEnderecoscomplemento.Value := complemento;
  FDQueryEnderecosbairro.Value      := bairro;
  FDQueryEnderecoslocalidade.Value  := localidade;
  FDQueryEnderecosuf.Value          := uf;
  FDQueryEnderecos.Post;
end;

function Tdados.CEPNaoEncontrado(retorno: string): Boolean;
begin
  Result := False;

  if Pos('erro', retorno) > 0 then
  begin
    Result := True;
  end
  else
  begin
    Result := False;
  end;

end;

function Tdados.Consultaendereconabase(cep, estado, cidade, endereco: string): Boolean;
var
  caracterespecial:string;
begin
 caracterespecial := '-';
 if cep <> '' then
 begin
  cep := Copy(cep,1,5) + caracterespecial + Copy(cep,6,3);
  Result := FDQueryEnderecos.Locate('cep', cep, []);
 end
 else if (cep = '') and ((estado <> '') and (cidade <> '') and (endereco <> '')) then
      begin
        Result := FDQueryEnderecos.Locate('uf;localidade;logradouro', VarArrayOf([estado,cidade,endereco]), []);
      end;
end;


function Tdados.ConsultaporCEPEndereco(cep, estado, cidade,
  endereco, formato: string; update:Boolean): Boolean;
var
  ViaCEP: TViaCEP;
  JSONObj: TJSONObject;
  JSONArr: TJSONArray;
  XMLDoc: IXMLDocument;
begin
  ViaCEP := TViaCEP.Create(Self);

  try
    if pos('json', formato) > 0 then
      ViaCEP.Format := fmtJSON
    else
      ViaCEP.Format := fmtXML;

    if (cep <> '') then
    begin
      ViaCEP.CEP := cep;  // CEP para consultar
      ViaCEP.BuscarPorCEP;



      if ViaCEP.Format = fmtJSON then
      begin
        JSONObj := ViaCEP.GetResultAsJSON;

        if CEPNaoEncontrado(JSONObj.ToString) then
        begin
          Result := False;
          Exit;
        end
        else
        begin
          dados.LerJSON(JSONObj.ToString, False, update);
          Result := True;
        end;

      end
      else if ViaCEP.Format = fmtXML then
      begin
        XMLDoc := ViaCEP.GetResultAsXML;

        if CEPNaoEncontrado(XMLDoc.XML.Text) then
        begin
          Result := False;
          Exit;
        end
        else
        begin
          dados.LerXML(XMLDoc.XML.Text, update);
          Result := True;
        end;

      end;


    end
    else
    begin
      ViaCEP.Estado := estado; // UF para consultar
      ViaCEP.Cidade := cidade; // CIDADE para consultar
      ViaCEP.Endereco := endereco; // Endereço para consultar
      ViaCEP.BuscarPorEndereco;

      if ViaCEP.Format = fmtJSON then
      begin
        JSONArr := ViaCEP.GetResultAsJSONarray;

        if CEPNaoEncontrado(JSONArr.ToString) then
        begin
          Result := False;
          Exit;
        end
        else
        begin
          dados.LerJSON(JSONArr.ToString, True, update);
          Result := True;
        end;
      end
      else if ViaCEP.Format = fmtXML then
      begin
        XMLDoc := ViaCEP.GetResultAsXML;

        if CEPNaoEncontrado(XMLDoc.XML.Text) then
        begin
          Result := False;
          Exit;
        end
        else
        begin
          dados.LerXML(XMLDoc.XML.Text, update);
          Result := True;
        end;
      end;

    end;

  finally
    ViaCEP.Free;
  end;

end;

procedure Tdados.LerJSON(sArquivo: string; lista, update:Boolean);
var
  JSONStr: string;
  JSONObj: TJSONObject;
  JSONArray: TJSONArray;
  Cep, Logradouro, Complemento, Bairro, Localidade, UF: string;
  i: Integer;
begin
  // Defina o JSON em formato de string
  JSONStr := sArquivo;

  if not lista then
  begin
    // Parseia o JSON
    JSONObj := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(JSONStr), 0) as TJSONObject;

    try
      // Extrai os valores do JSON
      Cep := JSONObj.GetValue<string>('cep');
      Logradouro := JSONObj.GetValue<string>('logradouro');
      Complemento := JSONObj.GetValue<string>('complemento');
      Bairro := JSONObj.GetValue<string>('bairro');
      Localidade := JSONObj.GetValue<string>('localidade');
      UF := JSONObj.GetValue<string>('uf');

      case update of
        False: AdicionaRegistro(Cep, Logradouro, Complemento, Bairro, Localidade, UF);
        True:  AtualizaRegistro(Cep, Logradouro, Complemento, Bairro, Localidade, UF);
      end;
    finally
      // Libera o objeto JSON
      JSONObj.Free;
    end;
  end
  else
  begin
    // Parseia a string JSON
    JSONArray := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(JSONStr), 0) as TJSONArray;

    try
      // Itera sobre o array JSON
      for i := 0 to JSONArray.Count - 1 do
      begin
        JSONObj := JSONArray.Items[i] as TJSONObject;

        // Extrai os valores de cada objeto JSON
        Cep := JSONObj.GetValue<string>('cep');
        Logradouro := JSONObj.GetValue<string>('logradouro');
        Complemento := JSONObj.GetValue<string>('complemento');
        Bairro := JSONObj.GetValue<string>('bairro');
        Localidade := JSONObj.GetValue<string>('localidade');
        UF := JSONObj.GetValue<string>('uf');

        case update of
          False: AdicionaRegistro(Cep, Logradouro, Complemento, Bairro, Localidade, UF);
          True:  AtualizaRegistro(Cep, Logradouro, Complemento, Bairro, Localidade, UF);
        end;
      end;
    finally
      // Libera o array JSON
      JSONArray.Free;
    end;

  end;

end;

procedure Tdados.LerXML(sArquivo: string; update:Boolean);
var
  XMLDoc: IXMLDocument;
  RootNode, ChildNode, Enderecos, Endereco: IXMLNode;
  Cep, Logradouro, Complemento, Bairro, Localidade, UF: string;
  i, i2: Integer;
begin
  // Cria o documento XML e carrega a string XML
  XMLDoc := NewXMLDocument;
  XMLDoc.LoadFromXML(sArquivo);  // Carrega o conteúdo XML diretamente da string

  // Obtém o nó raiz <xmlcep>
  RootNode := XMLDoc.DocumentElement;

  if RootNode.ChildNodes.Count = 1 then
  begin
    Enderecos := RootNode.ChildNodes['enderecos'];
    for i := 0 to Enderecos.ChildNodes.Count - 1 do
    begin
      Endereco := Enderecos.ChildNodes[i];

      // Lê os valores dos elementos XML
      Cep         := Endereco.ChildNodes['cep'].Text;
      Logradouro  := Endereco.ChildNodes['logradouro'].Text;
      Complemento := Endereco.ChildNodes['complemento'].Text;
      Bairro      := Endereco.ChildNodes['bairro'].Text;
      Localidade  := Endereco.ChildNodes['localidade'].Text;
      UF          := Endereco.ChildNodes['uf'].Text;

      case update of
        False: AdicionaRegistro(Cep, Logradouro, Complemento, Bairro, Localidade, UF);
        True:  AtualizaRegistro(Cep, Logradouro, Complemento, Bairro, Localidade, UF);
      end;
    end;

  end
  else
  begin
    // Lê os valores dos elementos XML
    Cep := RootNode.ChildNodes['cep'].Text;
    Logradouro := RootNode.ChildNodes['logradouro'].Text;
    Complemento := RootNode.ChildNodes['complemento'].Text;
    Bairro := RootNode.ChildNodes['bairro'].Text;
    Localidade := RootNode.ChildNodes['localidade'].Text;
    UF := RootNode.ChildNodes['uf'].Text;

    case update of
      False: AdicionaRegistro(Cep, Logradouro, Complemento, Bairro, Localidade, UF);
      True:  AtualizaRegistro(Cep, Logradouro, Complemento, Bairro, Localidade, UF);
    end;
  end;

end;

end.
