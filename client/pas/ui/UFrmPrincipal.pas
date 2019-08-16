unit UFrmPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    edtDocumentoCliente: TLabeledEdit;
    cmbTamanhoPizza: TComboBox;
    cmbSaborPizza: TComboBox;
    Button1: TButton;
    mmRetornoWebService: TMemo;
    edtEnderecoBackend: TLabeledEdit;
    edtPortaBackend: TLabeledEdit;
    btnConsultar: TButton;
    procedure Button1Click(Sender: TObject);
    procedure btnConsultarClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation

uses
  Rest.JSON, MVCFramework.RESTClient, UEfetuarPedidoDTOImpl, System.Rtti,
  UPizzaSaborEnum, UPizzaTamanhoEnum, System.JSON;

{$R *.dfm}

procedure TForm1.btnConsultarClick(Sender: TObject);
var
  oCliente: TRESTClient;
  oRetorno: TJSONValue;
  oResponse: IRESTResponse;
begin
  oCliente := TRESTClient.Create(edtEnderecoBackend.Text, string(edtPortaBackend.Text).ToInteger());
  oCliente.ReadTimeOut(60000);
  oResponse := oCliente.doGET('/buscarpedido', [edtDocumentoCliente.Text]);
  if oResponse.BodyAsString().ToLower().Contains('exception') then
  begin
    mmRetornoWebService.Text := oResponse.BodyAsString();
    Exit();
  end;
  oRetorno := TJSONObject.ParseJSONValue(oResponse.BodyAsString());
  mmRetornoWebService.Lines.Add(StringOfChar('-', 10));
  mmRetornoWebService.Lines.Add('Sabor=' + oRetorno.GetValue<string>('PizzaSabor'));
  mmRetornoWebService.Lines.Add('Tamanho=' + oRetorno.GetValue<string>('PizzaTamanho'));
  mmRetornoWebService.Lines.Add('Valor=' + oRetorno.GetValue<Double>('ValorTotalPedido').ToString());
  mmRetornoWebService.Lines.Add('Tempo Preparo=' + oRetorno.GetValue<Integer>('TempoPreparo').ToString());
  mmRetornoWebService.Lines.Add(StringOfChar('-', 10));
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  Clt: TRestClient;
  oEfetuarPedido: TEfetuarPedidoDTO;
begin
  Clt := MVCFramework.RESTClient.TRestClient.Create(edtEnderecoBackend.Text,
    StrToIntDef(edtPortaBackend.Text, 80), nil);
  try
    oEfetuarPedido := TEfetuarPedidoDTO.Create;
    try
      oEfetuarPedido.PizzaTamanho :=
        TRttiEnumerationType.GetValue<TPizzaTamanhoEnum>(cmbTamanhoPizza.Text);
      oEfetuarPedido.PizzaSabor :=
        TRttiEnumerationType.GetValue<TPizzaSaborEnum>(cmbSaborPizza.Text);
      oEfetuarPedido.DocumentoCliente := edtDocumentoCliente.Text;
      mmRetornoWebService.Text := Clt.doPOST('/efetuarPedido', [],
        TJson.ObjecttoJsonString(oEfetuarPedido)).BodyAsString;
    finally
      oEfetuarPedido.Free;
    end;
  finally
    Clt.Free;
  end;
end;

end.
