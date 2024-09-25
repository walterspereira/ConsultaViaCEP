object dados: Tdados
  OldCreateOrder = False
  Height = 618
  Width = 653
  object FDConnection: TFDConnection
    Params.Strings = (
      
        'Database=C:\Users\CCC\Desktop\Walter\Softplan\Projeto\BD\consult' +
        'as.db'
      'DriverID=SQLite')
    Connected = True
    LoginPrompt = False
    Left = 200
    Top = 192
  end
  object FDQueryEnderecos: TFDQuery
    Connection = FDConnection
    SQL.Strings = (
      'select codigo,'
      '       cep,'
      '       logradouro,'
      '       complemento,'
      '       bairro,'
      '       localidade,'
      '       uf'
      'from Enderecos;')
    Left = 416
    Top = 200
    object FDQueryEnderecoscodigo: TFDAutoIncField
      FieldName = 'codigo'
      Origin = 'codigo'
      ProviderFlags = [pfInWhere, pfInKey]
      ReadOnly = True
    end
    object FDQueryEnderecoscep: TStringField
      FieldName = 'cep'
      Origin = 'cep'
      Size = 10
    end
    object FDQueryEnderecoslogradouro: TStringField
      FieldName = 'logradouro'
      Origin = 'logradouro'
      Size = 100
    end
    object FDQueryEnderecoscomplemento: TStringField
      FieldName = 'complemento'
      Origin = 'complemento'
      Size = 100
    end
    object FDQueryEnderecosbairro: TStringField
      FieldName = 'bairro'
      Origin = 'bairro'
      Size = 50
    end
    object FDQueryEnderecoslocalidade: TStringField
      FieldName = 'localidade'
      Origin = 'localidade'
      Size = 50
    end
    object FDQueryEnderecosuf: TStringField
      FieldName = 'uf'
      Origin = 'uf'
      Size = 2
    end
  end
  object RESTClient1: TRESTClient
    Accept = 'application/json, text/plain; q=0.9, text/html;q=0.8,'
    AcceptCharset = 'utf-8, *;q=0.8'
    BaseURL = 'http://viacep.com.br/ws/05858002/json/'
    Params = <>
    RaiseExceptionOn500 = False
    Left = 168
    Top = 416
  end
  object RESTRequest1: TRESTRequest
    Client = RESTClient1
    Params = <>
    Response = RESTResponse1
    Timeout = 90000
    SynchronizedEvents = False
    Left = 240
    Top = 416
  end
  object RESTResponse1: TRESTResponse
    ContentType = 'application/json'
    Left = 328
    Top = 416
  end
end
