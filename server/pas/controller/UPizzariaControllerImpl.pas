unit UPizzariaControllerImpl;

interface

{$I dmvcframework.inc}

uses MVCFramework,
  MVCFramework.Logger,
  MVCFramework.Commons,
  Web.HTTPApp, UPizzaTamanhoEnum, UPizzaSaborEnum, UEfetuarPedidoDTOImpl;

type

  [MVCDoc('Pizzaria backend')]
  [MVCPath('/')]
  TPizzariaBackendController = class(TMVCController)
  public

    [MVCDoc('Criar novo pedido "201: Created"')]
    [MVCPath('/efetuarPedido')]
    [MVCHTTPMethod([httpPOST])]
    procedure efetuarPedido(const AContext: TWebContext);

    [MVCPath('/consultarpedido/($documento)')]
    [MVCHTTPMethod([httpPOST])]
    procedure consultarPedido(const AContext: TWebContext);

  end;

implementation

uses
  System.SysUtils,
  Rest.json,
  MVCFramework.SystemJSONUtils,
  UPedidoServiceIntf,
  UPedidoServiceImpl, UPedidoRetornoDTOImpl;

{ TApp1MainController }

procedure TPizzariaBackendController.consultarPedido(const AContext
  : TWebContext);
var
  oPedidoService: IPedidoService;
  oRetornoPedido: TPedidoRetornoDTO;
begin
  oPedidoService := TPedidoService.Create;
  if Context.Request.Params['documento'].IsEmpty then
    raise Exception.Create('Pedido inexistente');
  oRetornoPedido := oPedidoService.constultarPedido
    (Context.Request.Params['documento']);

end;

procedure TPizzariaBackendController.efetuarPedido(const AContext: TWebContext);
var
  oEfetuarPedidoDTO: TEfetuarPedidoDTO;
  oPedidoRetornoDTO: TPedidoRetornoDTO;
begin
  oEfetuarPedidoDTO := AContext.Request.BodyAs<TEfetuarPedidoDTO>;
  try
    with TPedidoService.Create do
      try
        oPedidoRetornoDTO := efetuarPedido(oEfetuarPedidoDTO.PizzaTamanho,
          oEfetuarPedidoDTO.PizzaSabor, oEfetuarPedidoDTO.DocumentoCliente);
        Render(TJson.ObjectToJsonString(oPedidoRetornoDTO));
      finally
        oPedidoRetornoDTO.Free
      end;
  finally
    oEfetuarPedidoDTO.Free;
  end;
  Log.Info('==>Executou o m�todo ', 'efetuarPedido');
end;

end.
