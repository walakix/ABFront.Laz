unit umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Spin, Grids, ComCtrls,
  fphttpclient, fpjson, jsonparser;

type

  { TForm1 }

  TForm1 = class(TForm)
    btn_getall: TButton;
    btn_getlast: TButton;
    btn_getone: TButton;
    btn_deleteone: TButton;
    btn_deleteall: TButton;
    btn_writeone: TButton;
    btn_updateone: TButton;
    btn_Quit: TButton;
    e_comment: TEdit;
    fse_floatdata: TFloatSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    leAPIKey: TLabeledEdit;
    leLink: TLabeledEdit;
    Memo1: TMemo;
    se_id: TSpinEdit;
    sbInfo: TStatusBar;
    sgDatas: TStringGrid;
    se_intdata: TSpinEdit;
    se_booldata: TSpinEdit;
    procedure btn_deleteallClick(Sender: TObject);
    procedure btn_deleteoneClick(Sender: TObject);
    procedure btn_getallClick(Sender: TObject);
    procedure btn_getlastClick(Sender: TObject);
    procedure btn_getoneClick(Sender: TObject);
    procedure btn_QuitClick(Sender: TObject);
    procedure btn_writeoneClick(Sender: TObject);
    procedure sgDatasClick(Sender: TObject);
  private

  public
    procedure getRest(ALink:string);
    procedure getAll;
    procedure getLast;
    procedure deleteRest(ALink:string);
    procedure getOne;
    procedure deleteOne;
    procedure deleteAll;
    procedure writeRest(ACmd:string; ALink:string);
    procedure writeOne;
    procedure updateOne;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.btn_QuitClick(Sender: TObject);
begin
  Close;
end;

procedure TForm1.btn_writeoneClick(Sender: TObject);
begin
  writeOne;
end;

procedure TForm1.sgDatasClick(Sender: TObject);
begin
  se_id.Value:=StrToInt(sgDatas.Cells[0,sgDatas.Row]);
  se_intdata.Value:=StrToInt(sgDatas.Cells[1,sgDatas.Row]);
  fse_floatdata.Value:=StrToFloat(sgDatas.Cells[2,sgDatas.Row]);
  se_booldata.Value:=StrToInt(sgDatas.Cells[3,sgDatas.Row]);
  e_comment.Text:=sgDatas.Cells[5,sgDatas.Row];
end;

procedure TForm1.btn_getallClick(Sender: TObject);
begin
  getAll;
end;

procedure TForm1.btn_deleteoneClick(Sender: TObject);
begin
  deleteOne;
end;

procedure TForm1.btn_deleteallClick(Sender: TObject);
begin
  deleteAll;
end;

procedure TForm1.btn_getlastClick(Sender: TObject);
begin
  getLast;
end;

procedure TForm1.btn_getoneClick(Sender: TObject);
begin
  getOne;
end;

{ -------------------------------------------------------- }

procedure TForm1.getRest(ALink:string);
var
  Client: TFPHttpClient;
  Response: TStringStream;
  Res:string;
  URL:string;
  J: TJSONData;
  i:integer;
begin
  sbInfo.Panels.Items[0].Text:='';
  Client := TFPHttpClient.Create(nil);
  Client.AddHeader('User-Agent', 'Mozilla/5.0 (compatible; fpweb)');
  Client.AddHeader('Content-Type', 'application/json; charset=UTF-8');
  Client.AddHeader('Accept', 'application/json');
  Client.AllowRedirect := true;
  //Client.UserName := USER_STRING;
  //Client.Password := PASSW_STRING;
  //Client.RequestBody := TRawByteStringStream.Create(Params);
  Response := TStringStream.Create('');
  URL:=leLink.Text+ALink;
  try
    try
      //Client.Post(TheURL, Response);
      Res:=Client.Get(URL);
      //Writeln('Response Code: ' + IntToStr(Client.ResponseStatusCode)); // better be 200
      sbInfo.Panels.Items[0].Text:= IntToStr(Client.ResponseStatusCode);
      sbInfo.Panels.Items[1].Text:= Client.ResponseStatusText;
      Memo1.Lines.Add(Res);
      J := GetJSON(Res);
      //sgDatas.Clear;
      sgDatas.RowCount:=1;
      for i := 0 to J.Count - 1 do begin
        try
          //ListBox1.Items.Add( J.Items[c].FindPath('title').AsString );
          sgDatas.RowCount:=sgDatas.RowCount+1;
          sgDatas.Cells[0,i+1]:=J.Items[i].FindPath('id').AsString;
          sgDatas.Cells[1,i+1]:=J.Items[i].FindPath('intdata').AsString;
          sgDatas.Cells[2,i+1]:=J.Items[i].FindPath('floatdata').AsString;
          sgDatas.Cells[3,i+1]:=J.Items[i].FindPath('booldata').AsString;
          sgDatas.Cells[4,i+1]:=J.Items[i].FindPath('datedata').AsString;
          sgDatas.Cells[5,i+1]:=J.Items[i].FindPath('comment').AsString;
        finally
        end;
      end;

    except on E: Exception do begin
      //Writeln('Something bad happened: ' + E.Message);
      sbInfo.Panels.Items[0].Text:= IntToStr(Client.ResponseStatusCode);
      sbInfo.Panels.Items[1].Text:= Client.ResponseStatusText + ' - ' + E.Message;
      //sbInfo.Panels.Items[1].Text:=E.Message+' '+Client.ResponseStatusText;
      end;
    end;
  finally
    Client.RequestBody.Free;
    Client.Free;
    Response.Free;

  end;
end;

procedure TForm1.getAll;
begin
  getRest('getall');
end;

procedure TForm1.getLast;
begin
  getRest('getlast');
end;

procedure TForm1.getOne;
begin
  getRest('getone/'+IntToStr(se_id.Value));
end;

procedure TForm1.deleteRest(ALink:string);
var
  Client: TFPHttpClient;
  Response: TStringStream;
  Res:string;
  URL:string;
  J: TJSONData;
  i:integer;
begin
  sbInfo.Panels.Items[0].Text:='';
  Client := TFPHttpClient.Create(nil);
  Client.AddHeader('User-Agent', 'Mozilla/5.0 (compatible; fpweb)');
  Client.AddHeader('Content-Type', 'application/json; charset=UTF-8');
  Client.AddHeader('Accept', 'application/json');
  Client.AllowRedirect := true;
  //Client.UserName := USER_STRING;
  //Client.Password := PASSW_STRING;
  //Client.RequestBody := TRawByteStringStream.Create(Params);
  Response := TStringStream.Create('');
  URL:=leLink.Text+ALink;
  try
    try
      //Client.Post(TheURL, Response);
//      Res:=Client.Get(URL);
      Res:=Client.Delete(URL);
      //Writeln('Response Code: ' + IntToStr(Client.ResponseStatusCode)); // better be 200
      sbInfo.Panels.Items[0].Text:= IntToStr(Client.ResponseStatusCode);
      sbInfo.Panels.Items[1].Text:= Client.ResponseStatusText;
      Memo1.Lines.Add(Res);
    except on E: Exception do begin
      //Writeln('Something bad happened: ' + E.Message);
      sbInfo.Panels.Items[0].Text:= IntToStr(Client.ResponseStatusCode);
      sbInfo.Panels.Items[1].Text:= Client.ResponseStatusText + ' - ' + E.Message;
      //sbInfo.Panels.Items[1].Text:=E.Message+' '+Client.ResponseStatusText;
      end;
    end;
  finally
    Client.RequestBody.Free;
    Client.Free;
    Response.Free;

  end;

end;

procedure TForm1.deleteOne;
begin
  deleteRest('deleteone/'+IntToStr(se_id.Value));
end;

procedure TForm1.deleteAll;
begin
  deleteRest('deleteall');
end;

procedure TForm1.writeRest(ACmd:string; ALink:string);
var
  Client: TFPHttpClient;
  Response: TStringStream;
  Res:string;
  URL:string;
  J: TJSONData;
  i:integer;
  Params:string;
begin
  sbInfo.Panels.Items[0].Text:='';
  Client := TFPHttpClient.Create(nil);
  Client.AddHeader('User-Agent', 'Mozilla/5.0 (compatible; fpweb)');
  Client.AddHeader('Content-Type', 'application/json; charset=UTF-8');
  Client.AddHeader('Accept', 'application/json');
  Client.AllowRedirect := true;
  //Client.UserName := USER_STRING;
  //Client.Password := PASSW_STRING;
  Params:='{"intdata":'+IntToStr(se_intdata.Value)+
          ', "floatdata":'+FloatToStr(fse_floatdata.Value)+
          ', "booldata":'+IntToStr(se_booldata.Value)+
          ', "comment":"'+e_comment.Text+'"}';
  Client.RequestBody := TRawByteStringStream.Create(Params);
  Response := TStringStream.Create('');
  URL:=leLink.Text+ALink;
  try
    try
      if (ACmd='POST') then Client.Post(URL, Response)
      else begin
        Res:=Client.Put(URL);
        Memo1.Lines.Add(Res);
      end;
      sbInfo.Panels.Items[0].Text:= IntToStr(Client.ResponseStatusCode);
      sbInfo.Panels.Items[1].Text:= Client.ResponseStatusText;
    except on E: Exception do begin
      //Writeln('Something bad happened: ' + E.Message);
      sbInfo.Panels.Items[0].Text:= IntToStr(Client.ResponseStatusCode);
      sbInfo.Panels.Items[1].Text:= Client.ResponseStatusText + ' - ' + E.Message;
      end;
    end;
  finally
    Client.RequestBody.Free;
    Client.Free;
    Response.Free;

  end;


end;


procedure TForm1.writeOne;
begin
  writeRest('POST', 'writeone');
end;

procedure TForm1.updateOne;
begin
  writeRest('PUT', 'updateone/'+IntToStr(se_id.Value));
end;



end.

