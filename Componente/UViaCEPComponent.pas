unit UViaCEPComponent;

interface

uses
  System.SysUtils, System.Classes, System.JSON, REST.Client, Data.Bind.Components, Data.Bind.ObjectScope, XMLDoc, XMLIntf;

type
  TFormat = (fmtJSON, fmtXML);

  TViaCEP = class(TComponent)
  private
    FCEP: string;
    FEstado: string;
    FCidade: string;
    FEndereco: string;
    FFormat: TFormat;
    FRESTClient: TRESTClient;
    FRESTRequest: TRESTRequest;
    FRESTResponse: TRESTResponse;
    FOnError: TNotifyEvent;
    function GetBaseURLByCEP: string;
    function GetBaseURLByEndereco: string;
    procedure SetCEP(const Value: string);
    procedure SetEstado(const Value: string);
    procedure SetCidade(const Value: string);
    procedure SetEndereco(const Value: string);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure BuscarPorCEP;
    procedure BuscarPorEndereco;
    function GetResultAsJSON: TJSONObject; // Para buscas por CEP, o ViaCEP retorna apenas um json e não um array
    function GetResultAsJSONarray: TJSONArray; // Para buscas por endereço, o ViaCEP pode retornar uma lista de resultados
    function GetResultAsXML: IXMLDocument;
  published
    property CEP: string read FCEP write SetCEP;

    property Estado: string read FEstado write SetEstado;
    property Cidade: string read FCidade write SetCidade;
    property Endereco: string read FEndereco write SetEndereco;

    property Format: TFormat read FFormat write FFormat;
    property OnError: TNotifyEvent read FOnError write FOnError;
  end;

procedure Register;

implementation

uses
  REST.Types;

procedure Register;
begin
  RegisterComponents('Softplan', [TViaCEP]);
end;

{ TViaCEP }

constructor TViaCEP.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRESTClient := TRESTClient.Create(nil);
  FRESTRequest := TRESTRequest.Create(nil);
  FRESTResponse := TRESTResponse.Create(nil);

  FRESTRequest.Client := FRESTClient;
  FRESTRequest.Response := FRESTResponse;

  FFormat := fmtJSON; // Formato padrão
end;

destructor TViaCEP.Destroy;
begin
  FRESTClient.Free;
  FRESTRequest.Free;
  FRESTResponse.Free;
  inherited Destroy;
end;

function TViaCEP.GetBaseURLByCEP: string;
begin
  case FFormat of
    fmtJSON: Result := 'https://viacep.com.br/ws/' + FCEP + '/json/';
    fmtXML: Result := 'https://viacep.com.br/ws/' + FCEP + '/xml/';
  end;
end;

function TViaCEP.GetBaseURLByEndereco: string;
begin
  if (FEstado = '') or (FCidade = '') or (FEndereco = '') then
    raise Exception.Create('Estado, Cidade e Endereço devem ser informados.');

  case FFormat of
    fmtJSON: Result := 'https://viacep.com.br/ws/' + FEstado + '/' + FCidade + '/' + FEndereco + '/json/';
    fmtXML: Result := 'https://viacep.com.br/ws/' + FEstado + '/' + FCidade + '/' + FEndereco + '/xml/';
  end;
end;

procedure TViaCEP.SetCEP(const Value: string);
begin
  FCEP := Value;
end;

procedure TViaCEP.SetCidade(const Value: string);
begin
    FCidade := Value;
end;

procedure TViaCEP.SetEndereco(const Value: string);
begin
  FEndereco := Value;
end;

procedure TViaCEP.SetEstado(const Value: string);
begin
  FEstado := Value;
end;

procedure TViaCEP.BuscarPorCEP;
begin
  if FCEP = '' then
    raise Exception.Create('O CEP não pode estar vazio.');

  try
    FRESTClient.BaseURL := GetBaseURLByCEP;
    FRESTRequest.Execute;
  except
    on E: Exception do
    begin
      if Assigned(FOnError) then
        FOnError(Self);
      raise;
    end;
  end;
end;

procedure TViaCEP.BuscarPorEndereco;
begin
  if (FEstado = '') or (FCidade = '') or (FEndereco = '') then
    raise Exception.Create('Estado, Cidade e Endereço devem ser informados.');

  try
    FRESTClient.BaseURL := GetBaseURLByEndereco;
    FRESTRequest.Execute;
  except
    on E: Exception do
    begin
      if Assigned(FOnError) then
        FOnError(Self);
      raise;
    end;
  end;
end;

function TViaCEP.GetResultAsJSON: TJSONObject;
begin
  if FFormat <> fmtJSON then
    raise Exception.Create('O formato da resposta não é JSON.');

  Result := TJSONObject.ParseJSONValue(FRESTResponse.Content) as TJSONObject;
end;

function TViaCEP.GetResultAsJSONarray: TJSONArray;
begin
  if FFormat <> fmtJSON then
    raise Exception.Create('O formato da resposta não é JSON.');

  // ViaCEP pode retornar um array de resultados para busca por endereço
  Result := TJSONObject.ParseJSONValue(FRESTResponse.Content) as TJSONArray;
end;

function TViaCEP.GetResultAsXML: IXMLDocument;
begin
  if FFormat <> fmtXML then
    raise Exception.Create('O formato da resposta não é XML.');

  Result := LoadXMLData(FRESTResponse.Content);
end;

end.

