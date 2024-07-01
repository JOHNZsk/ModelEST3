unit ProgDialog;

interface

uses Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Forms,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Vcl.NumberBox, CPortThread;

type
  TProgDlg = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Panel1: TPanel;
    FREDAdresa: TNumberBox;
    FREDBtn: TButton;
    Stav: TLabel;
    Panel2: TPanel;
    AddressReadBtn: TButton;
    Panel3: TPanel;
    AdresaKratka: TRadioButton;
    AdresaDlha: TRadioButton;
    AdresaHodnota: TNumberBox;
    AddressWriteBtn: TButton;
    Panel4: TPanel;
    RezimDirect: TRadioButton;
    RezimPOM: TRadioButton;
    Button3: TButton;
    Panel5: TPanel;
    CVHodnota: TNumberBox;
    Label1: TLabel;
    Label2: TLabel;
    Panel6: TPanel;
    Label3: TLabel;
    Label4: TLabel;
    POMAdresa: TNumberBox;
    CVAdresa: TNumberBox;
    Bit7: TCheckBox;
    Bit6: TCheckBox;
    Bit5: TCheckBox;
    Bit4: TCheckBox;
    Bit3: TCheckBox;
    Bit2: TCheckBox;
    Bit1: TCheckBox;
    Bit0: TCheckBox;
    Panel7: TPanel;
    CVReadBtn: TButton;
    CVWriteBtn: TButton;
    procedure FREDBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure CVReadBtnClick(Sender: TObject);
    procedure CVWriteBtnClick(Sender: TObject);
    procedure CVHodnotaChangeValue(Sender: TObject);
    procedure Bit0Click(Sender: TObject);
    procedure AdresaKratkaClick(Sender: TObject);
    procedure AdresaDlhaClick(Sender: TObject);
    procedure AddressReadBtnClick(Sender: TObject);
    procedure AddressWriteBtnClick(Sender: TObject);
  private
    { Private declarations }
    t_akt_dispatch: Boolean;
    t_akt_dispatch_adresa: Word;
    t_last_dispatch_adresa: Word;

    t_akt_prog: Boolean;
    t_akt_prog_read: Boolean;
    t_potlacit_bity: Boolean;

    t_akt_adr: Boolean;
    t_akt_adr_read: Boolean;
    t_akt_adr_cv: Word;
    t_akt_adr_cv_read: Boolean;
    t_akt_adr_cv17: Word;


  public
    { Public declarations }

    procedure SpracujSpravuBFB4(p_adresa: Word; p_stav: Boolean);
    procedure SpracujSpravuBAB4(p_slot: Byte);
    procedure SpracujSpravuEFB4(p_slot: Byte; p_odpoved: TCPortZpravaEFB4Odpoved);
    procedure SpracujSpravuE7Slot(p_slot: Byte; p_adresa: Word; p_stat: Byte; p_rychlost: Byte; p_dirf: Byte; p_trk: Byte; p_ss2: Byte; p_snd: Byte; p_id: Word);
    procedure SpracujSpravuE7Program(p_cmd: Byte; p_stat: Byte; p_pom_adresa: Word; p_trk: Byte; p_cv: Word; p_value: Byte);

  end;

var
  ProgDlg: TProgDlg;

implementation
  uses ComPort;

{$R *.dfm}
  
procedure TProgDlg.SpracujSpravuBFB4(p_adresa: Word; p_stav: Boolean);
begin
  if not p_stav then
  begin
    t_akt_dispatch_adresa:=0;
    t_akt_dispatch:=False;
    Enabled:=True;
    t_last_dispatch_adresa:=0;
    Stav.Caption:='CHYBA: Nejde zÌskaù voæn˝ slot';
    Stav.Refresh;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TProgDlg.SpracujSpravuBAB4(p_slot: Byte);
begin
  t_akt_dispatch_adresa:=0;
  t_akt_dispatch:=False;
  Enabled:=True;  
  t_last_dispatch_adresa:=0;
  Stav.Caption:='CHYBA: Nejde zadaù DISPATCH PUT';
  Stav.Refresh;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TProgDlg.SpracujSpravuEFB4(p_slot: Byte; p_odpoved: TCPortZpravaEFB4Odpoved);
begin
  if(p_slot=$7C) then
  begin
    case p_odpoved of
      EFB4_NOT_IMPLEMENTED:
      begin
        if t_akt_prog then
        begin
          t_akt_prog:=False;
          t_akt_prog_read:=False;
          Enabled:=True;
          Stav.Caption:='CHYBA: Nejde programovaù';
          Stav.Refresh;
        end
        else if t_akt_adr then
        begin
          t_akt_adr:=False;
          t_akt_adr_read:=False;
          Enabled:=True;
          Stav.Caption:='CHYBA: Nejde programovaù CV '+IntToStr(t_akt_adr_cv);
          Stav.Refresh;

          t_akt_adr_cv:=0;
          t_akt_adr_cv_read:=False;
          t_akt_adr_cv17:=0;
        end;
      end;
      EFB4_BUSY:
      begin
        if t_akt_prog then
        begin
          t_akt_prog:=False;
          t_akt_prog_read:=False;
          Enabled:=True;
          Stav.Caption:='CHYBA: ProgramovacÌ slot obsaden˝';
          Stav.Refresh;
        end
        else if t_akt_adr then
        begin
          t_akt_adr:=False;
          t_akt_adr_read:=False;
          Enabled:=True;
          Stav.Caption:='CHYBA: Slot pre CV '+IntToStr(t_akt_adr_cv)+' obsaden˝';
          Stav.Refresh;

          t_akt_adr_cv:=0;
          t_akt_adr_cv_read:=False;
          t_akt_adr_cv17:=0;
        end;
      end;
      EFB4_ACCEPTED:
      begin
        if t_akt_prog then
        begin
          Stav.Caption:='PrijatÈ, Ëak· sa na odpoveÔ';
          Stav.Refresh;
        end
        else if t_akt_adr then
        begin
          if t_akt_adr_cv_read then Stav.Caption:='NaËÌtanie CV '+IntToStr(t_akt_adr_cv)+' prijatÈ, Ëak· sa na odpoveÔ'
          else Stav.Caption:='Z·pis CV '+IntToStr(t_akt_adr_cv)+' prijat˝, Ëak· sa na odpoveÔ';
          Stav.Refresh;
        end;
      end;
      EFB4_ACCEPTED_NO_REPLY:
      begin
        if t_akt_prog then
        begin
          t_akt_prog:=False;
          Enabled:=True;          

          if not t_akt_prog_read then
          begin
            Stav.Caption:='PrijatÈ, nebude odpoveÔ';
            Stav.Refresh;
          end
          else
          begin
            t_akt_prog_read:=False;
            Stav.Caption:='CHYBA: Nejde vyËÌtaù hodnotu';
            Stav.Refresh;
          end;
        end
        else if t_akt_adr then
        begin
          if not t_akt_adr_cv_read then
          begin
            Stav.Caption:='CV '+IntToStr(t_akt_adr_cv)+' prijatÈ, nebude odpoveÔ';
            Stav.Refresh;
          end
          else
          begin
            t_akt_adr:=False;
            t_akt_adr_read:=False;
            Enabled:=True;
            Stav.Caption:='CHYBA: Nejde vyËÌtaù hodnotu CV '+IntToStr(t_akt_adr_cv);
            Stav.Refresh;

            t_akt_adr_cv:=0;
            t_akt_adr_cv_read:=False;
            t_akt_adr_cv17:=0;
          end;
        end;
      end
      else
      begin
        if t_akt_prog then
        begin
          t_akt_prog:=False;
          t_akt_prog_read:=False;
          Enabled:=True;          
          Stav.Caption:='CHYBA: Nezn·ma odpoveÔ na prog. povel';
          Stav.Refresh;
        end
        else if t_akt_adr then
        begin
          t_akt_adr:=False;
          t_akt_adr_read:=False;
          Enabled:=True;
          Stav.Caption:='CHYBA: Nezn·ma odpoveÔ na prog. povel CV'+IntToStr(t_akt_adr_cv);
          Stav.Refresh;

          t_akt_adr_cv:=0;
          t_akt_adr_cv_read:=False;
          t_akt_adr_cv17:=0;
        end;
      end;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TProgDlg.SpracujSpravuE7Slot(p_slot: Byte; p_adresa: Word; p_stat: Byte; p_rychlost: Byte; p_dirf: Byte; p_trk: Byte; p_ss2: Byte; p_snd: Byte; p_id: Word);
begin
  if p_adresa=t_akt_dispatch_adresa then
  begin
    if (not t_akt_dispatch) then
    begin
      t_akt_dispatch:=True;
      Enabled:=False;
      CPort.VydajPovelBA(p_slot,0);
      Stav.Caption:='DISPATCH PUT';
      Stav.Refresh;
    end
    else
    begin
      t_last_dispatch_adresa:=t_akt_dispatch_adresa;
      t_akt_dispatch_adresa:=0;
      t_akt_dispatch:=False;
      Enabled:=True;      
      Stav.Caption:='Dispatch OK - pripoj FREDa';
      Stav.Refresh;
    end;
  end
  else if p_adresa=t_last_dispatch_adresa then
  begin
    if(p_slot>0) then
    begin
      t_last_dispatch_adresa:=0;
      Enabled:=True;      
      Stav.Caption:='OK, pripravenÈ';
      Stav.Refresh;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TProgDlg.SpracujSpravuE7Program(p_cmd: Byte; p_stat: Byte; p_pom_adresa: Word; p_trk: Byte; p_cv: Word; p_value: Byte);
begin
  if t_akt_prog then
  begin
    if RezimDirect.Checked or (p_pom_adresa=0) or (p_pom_adresa=POMAdresa.ValueInt) then
    begin
      if(p_stat and $01)<>0 then
      begin
        Stav.Caption:='CHYBA: Bez odozvy, prog. koæaj pr·zdna?';
        Stav.Refresh;
      end
      else if(p_stat and $02)<>0 then
      begin
        Stav.Caption:='CHYBA: Bez odpovede od dekodÈra';
        Stav.Refresh;
      end
      else if(p_stat and $04)<>0 then
      begin
        Stav.Caption:='CHYBA: Nepodarilo sa overiù hodnotu';
        Stav.Refresh;
      end
      else if(p_stat and $08)<>0 then
      begin
        Stav.Caption:='CHYBA: ZruöenÈ uûÌvateæom';
        Stav.Refresh;
      end
      else if(t_akt_prog_read) and ((p_cv=0) or (p_cv=CVAdresa.ValueInt)) then
      begin
        CVHodnota.ValueInt:=p_value;

        Stav.Caption:='NaËÌtanÈ, pripravenÈ';
        Stav.Refresh;
      end
      else
      begin
        Stav.Caption:='OK, pripravenÈ';
        Stav.Refresh;
      end;

      t_akt_prog:=False;
      t_akt_prog_read:=False;
      Enabled:=True;
    end;
  end
  else if t_akt_adr then
  begin
    if RezimDirect.Checked or (p_pom_adresa=0) or (p_pom_adresa=POMAdresa.ValueInt) then
    begin
      if(p_stat and $01)<>0 then
      begin
        Stav.Caption:='CHYBA: Bez odozvy, prog. koæaj pr·zdna?';
        Stav.Refresh;

        t_akt_adr:=False;
        t_akt_adr_read:=False;
        t_akt_adr_cv:=0;
        t_akt_adr_cv_read:=False;
        t_akt_adr_cv17:=0;
        Enabled:=True;
      end
      else if(p_stat and $02)<>0 then
      begin
        Stav.Caption:='CHYBA: Bez odpovede od dekodÈra';
        Stav.Refresh;

        t_akt_adr:=False;
        t_akt_adr_read:=False;
        t_akt_adr_cv:=0;
        t_akt_adr_cv_read:=False;
        t_akt_adr_cv17:=0;
        Enabled:=True;
      end
      else if(p_stat and $04)<>0 then
      begin
        Stav.Caption:='CHYBA: Nepodarilo sa overiù hodnotu';
        Stav.Refresh;

        t_akt_adr:=False;
        t_akt_adr_read:=False;
        t_akt_adr_cv:=0;
        t_akt_adr_cv_read:=False;
        t_akt_adr_cv17:=0;
        Enabled:=True;
      end
      else if(p_stat and $08)<>0 then
      begin
        Stav.Caption:='CHYBA: ZruöenÈ uûÌvateæom';
        Stav.Refresh;

        t_akt_adr:=False;
        t_akt_adr_read:=False;
        t_akt_adr_cv:=0;
        t_akt_adr_cv_read:=False;
        t_akt_adr_cv17:=0;
        Enabled:=True;
      end
      else if(t_akt_adr_cv_read) and ((p_cv=0) or (p_cv=t_akt_adr_cv)) then
      begin
        if t_akt_adr_read then
        begin
          if t_akt_adr_cv=29 then
          begin
            if(p_value and $20)<>0 then
            begin
              AdresaDlha.Checked:=True;

              t_akt_adr_cv:=17;
              CPort.VydajPovelEDProgramTRK(t_akt_adr_cv_read,t_akt_adr_cv,0);
            end
            else
            begin
              AdresaKratka.Checked:=True;

              t_akt_adr_cv:=1;
              CPort.VydajPovelEDProgramTRK(t_akt_adr_cv_read,t_akt_adr_cv,0);
            end;
          end
          else if t_akt_adr_cv=1 then
          begin
            AdresaHodnota.ValueInt:=p_value;
            FREDAdresa.ValueInt:=AdresaHodnota.ValueInt;

            t_akt_adr:=False;
            t_akt_adr_read:=False;
            t_akt_adr_cv:=0;
            t_akt_adr_cv_read:=False;
            t_akt_adr_cv17:=0;
            Enabled:=True;
            ActiveControl:=AdresaHodnota;
          end
          else if t_akt_adr_cv=17 then
          begin
            t_akt_adr_cv17:=p_value;

            t_akt_adr_cv:=18;
            CPort.VydajPovelEDProgramTRK(t_akt_adr_cv_read,t_akt_adr_cv,0);
          end
          else if t_akt_adr_cv=18 then
          begin
            AdresaHodnota.ValueInt:=((t_akt_adr_cv17 and $3F) shl 8)+(p_value and $FF);
            FREDAdresa.ValueInt:=AdresaHodnota.ValueInt;

            t_akt_adr:=False;
            t_akt_adr_read:=False;
            t_akt_adr_cv:=0;
            t_akt_adr_cv_read:=False;
            t_akt_adr_cv17:=0;
            Enabled:=True;
            ActiveControl:=AdresaHodnota;
          end;
        end
        else
        begin
          if t_akt_adr_cv=29 then
          begin
            if AdresaDlha.Checked then
            begin
              if (p_value and $20)=0 then
              begin
                t_akt_adr_cv:=29;
                t_akt_adr_cv_read:=False;
                CPort.VydajPovelEDProgramTRK(t_akt_adr_cv_read,t_akt_adr_cv,p_value or $20)
              end
              else
              begin
                t_akt_adr_cv:=17;
                t_akt_adr_cv_read:=False;
                CPort.VydajPovelEDProgramTRK(t_akt_adr_cv_read,t_akt_adr_cv,((AdresaHodnota.ValueInt shr 8) or $C0) and $FF);
              end;
            end
            else
            begin
              if (p_value and $20)<>0 then
              begin
                t_akt_adr_cv:=29;
                t_akt_adr_cv_read:=False;
                CPort.VydajPovelEDProgramTRK(t_akt_adr_cv_read,t_akt_adr_cv,p_value and $EF);
              end
              else
              begin
                t_akt_adr_cv:=1;
                t_akt_adr_cv_read:=False;
                CPort.VydajPovelEDProgramTRK(t_akt_adr_cv_read,t_akt_adr_cv,AdresaHodnota.ValueInt and $FF);
              end;
            end;
          end;
        end;

        Stav.Caption:='NaËÌtanÈ, pripravenÈ';
        Stav.Refresh;
      end
      else
      begin
        if not t_akt_adr_read then
        begin
          if t_akt_adr_cv=29 then
          begin
            if AdresaDlha.Checked then
            begin
              t_akt_adr_cv:=17;
              t_akt_adr_cv_read:=False;
              CPort.VydajPovelEDProgramTRK(t_akt_adr_cv_read,t_akt_adr_cv,((AdresaHodnota.ValueInt shr 8) or $C0) and $FF);
            end
            else
            begin
              t_akt_adr_cv:=1;
              t_akt_adr_cv_read:=False;
              CPort.VydajPovelEDProgramTRK(t_akt_adr_cv_read,t_akt_adr_cv,AdresaHodnota.ValueInt and $FF);
            end;
          end
          else if t_akt_adr_cv=1 then
          begin
            FREDAdresa.ValueInt:=AdresaHodnota.ValueInt;
            t_akt_adr:=False;
            t_akt_adr_read:=False;
            t_akt_adr_cv:=0;
            t_akt_adr_cv_read:=False;
            t_akt_adr_cv17:=0;
            Enabled:=True;
            ActiveControl:=AdresaHodnota;
          end
          else if t_akt_adr_cv=17 then
          begin
            t_akt_adr_cv:=18;
            CPort.VydajPovelEDProgramTRK(t_akt_adr_cv_read,t_akt_adr_cv,AdresaHodnota.ValueInt and $FF);
          end
          else if t_akt_adr_cv=18 then
          begin
            FREDAdresa.ValueInt:=AdresaHodnota.ValueInt;
            t_akt_adr:=False;
            t_akt_adr_read:=False;
            t_akt_adr_cv:=0;
            t_akt_adr_cv_read:=False;
            t_akt_adr_cv17:=0;
            Enabled:=True;
            ActiveControl:=AdresaHodnota;
          end;
        end;


        Stav.Caption:='OK, pripravenÈ';
        Stav.Refresh;
      end;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TProgDlg.AddressReadBtnClick(Sender: TObject);
begin
  Enabled:=False;

  t_akt_adr:=True;
  t_akt_adr_read:=True;
  t_akt_adr_cv:=29;
  t_akt_adr_cv_read:=True;

  CPort.VydajPovelEDProgramTRK(t_akt_adr_cv_read,t_akt_adr_cv,0);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TProgDlg.AddressWriteBtnClick(Sender: TObject);
begin
  Enabled:=False;

  t_akt_adr:=True;
  t_akt_adr_read:=False;
  t_akt_adr_cv:=29;
  t_akt_adr_cv_read:=True;

  CPort.VydajPovelEDProgramTRK(t_akt_adr_cv_read,t_akt_adr_cv,0);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TProgDlg.AdresaDlhaClick(Sender: TObject);
begin
  AdresaHodnota.MaxValue:=$3FFF;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TProgDlg.AdresaKratkaClick(Sender: TObject);
begin
  AdresaHodnota.MaxValue:=255;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TProgDlg.Bit0Click(Sender: TObject);
begin
  if not t_potlacit_bity then
  begin
    if (Sender as TCheckBox).Checked then
    begin
      if Sender=Bit0 then CVHodnota.ValueInt:=CVHodnota.ValueInt or $01
      else if Sender=Bit1 then CVHodnota.ValueInt:=CVHodnota.ValueInt or $02
      else if Sender=Bit2 then CVHodnota.ValueInt:=CVHodnota.ValueInt or $04
      else if Sender=Bit3 then CVHodnota.ValueInt:=CVHodnota.ValueInt or $08
      else if Sender=Bit4 then CVHodnota.ValueInt:=CVHodnota.ValueInt or $10
      else if Sender=Bit5 then CVHodnota.ValueInt:=CVHodnota.ValueInt or $20
      else if Sender=Bit6 then CVHodnota.ValueInt:=CVHodnota.ValueInt or $40
      else if Sender=Bit7 then CVHodnota.ValueInt:=CVHodnota.ValueInt or $80
    end
    else
    begin
      if Sender=Bit0 then CVHodnota.ValueInt:=CVHodnota.ValueInt and $FE
      else if Sender=Bit1 then CVHodnota.ValueInt:=CVHodnota.ValueInt and $FD
      else if Sender=Bit2 then CVHodnota.ValueInt:=CVHodnota.ValueInt and $FB
      else if Sender=Bit3 then CVHodnota.ValueInt:=CVHodnota.ValueInt and $F7
      else if Sender=Bit4 then CVHodnota.ValueInt:=CVHodnota.ValueInt and $EF
      else if Sender=Bit5 then CVHodnota.ValueInt:=CVHodnota.ValueInt and $DF
      else if Sender=Bit6 then CVHodnota.ValueInt:=CVHodnota.ValueInt and $BF
      else if Sender=Bit7 then CVHodnota.ValueInt:=CVHodnota.ValueInt and $7F
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TProgDlg.Button3Click(Sender: TObject);
begin
  Close;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TProgDlg.CVHodnotaChangeValue(Sender: TObject);
begin
  t_potlacit_bity:=True;
  try
    if ((CVHodnota.ValueInt and $01)<>0) and (not Bit0.Checked) then Bit0.Checked:=True
    else if ((CVHodnota.ValueInt and $01)=0) and (Bit0.Checked) then Bit0.Checked:=False;

    if ((CVHodnota.ValueInt and $02)<>0) and (not Bit1.Checked) then Bit1.Checked:=True
    else if ((CVHodnota.ValueInt and $02)=0) and (Bit1.Checked) then Bit1.Checked:=False;

    if ((CVHodnota.ValueInt and $04)<>0) and (not Bit2.Checked) then Bit2.Checked:=True
    else if ((CVHodnota.ValueInt and $04)=0) and (Bit2.Checked) then Bit2.Checked:=False;

    if ((CVHodnota.ValueInt and $08)<>0) and (not Bit3.Checked) then Bit3.Checked:=True
    else if ((CVHodnota.ValueInt and $08)=0) and (Bit3.Checked) then Bit3.Checked:=False;

    if ((CVHodnota.ValueInt and $10)<>0) and (not Bit4.Checked) then Bit4.Checked:=True
    else if ((CVHodnota.ValueInt and $10)=0) and (Bit4.Checked) then Bit4.Checked:=False;

    if ((CVHodnota.ValueInt and $20)<>0) and (not Bit5.Checked) then Bit5.Checked:=True
    else if ((CVHodnota.ValueInt and $20)=0) and (Bit5.Checked) then Bit5.Checked:=False;

    if ((CVHodnota.ValueInt and $40)<>0) and (not Bit6.Checked) then Bit6.Checked:=True
    else if ((CVHodnota.ValueInt and $40)=0) and (Bit6.Checked) then Bit6.Checked:=False;

    if ((CVHodnota.ValueInt and $80)<>0) and (not Bit7.Checked) then Bit7.Checked:=True
    else if ((CVHodnota.ValueInt and $80)=0) and (Bit7.Checked) then Bit7.Checked:=False;


  finally
    t_potlacit_bity:=False;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

const PROG_CMD_READ_DIR_DGX=%00100000;
const PROG_CMD_READ_POM_DGX=%00100100;

procedure TProgDlg.CVReadBtnClick(Sender: TObject);
begin
  if(RezimDirect.Checked)  then
  begin
    if(CVAdresa.ValueInt>0) and (CVAdresa.ValueInt<$7FF) then
    begin
      Enabled:=False;
    
      t_akt_prog:=True;
      t_akt_prog_read:=True;
      //CPort.VydajPovelEFProgram(PROG_CMD_READ_DIR,0,0,CVAdresa.ValueInt,0);
      CPort.VydajPovelEDProgramTRK(True,CVAdresa.ValueInt,0);
      Stav.Caption:='Povel pre naËÌtanie vydan˝';
      Stav.Refresh;
    end;
  end
  else if(RezimPOM.Checked) then
  begin
    if(POMAdresa.ValueInt>0) and (POMAdresa.ValueInt<10239) then
    begin
      if(CVAdresa.ValueInt>0) and (CVAdresa.ValueInt<$7FF) then
      begin
        Enabled:=False;
      
        t_akt_prog:=True;
        t_akt_prog_read:=True;
        //CPort.VydajPovelEFProgram(PROG_CMD_READ_POM,POMAdresa.ValueInt,0,CVAdresa.ValueInt,0);
        CPort.VydajPovelEDProgramPOM(True,POMAdresa.ValueInt,CVAdresa.ValueInt,0);
        Stav.Caption:='Povel pre naËÌtanie vydan˝';
        Stav.Refresh;
      end;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

const PROG_CMD_WRIT_DIR_DGX=%01100000;
const PROG_CMD_WRIT_POM_DGX=%01100100;

procedure TProgDlg.CVWriteBtnClick(Sender: TObject);
begin
  if(RezimDirect.Checked)  then
  begin
    if(CVAdresa.ValueInt>0) and (CVAdresa.ValueInt<$7FF) then
    begin
      if(CVHodnota.ValueInt>=0) and (CVHodnota.Value<=$FF) then
      begin
        Enabled:=False;

        t_akt_prog:=True;
        t_akt_prog_read:=False;
        //CPort.VydajPovelEFProgram(PROG_CMD_WRIT_DIR,0,0,CVAdresa.ValueInt,CVHodnota.ValueInt);
        CPort.VydajPovelEDProgramTRK(False,CVAdresa.ValueInt,CVHodnota.ValueInt);
        Stav.Caption:='Povel pre z·pis vydan˝';
        Stav.Refresh;
      end;
    end;
  end
  else if(RezimPOM.Checked) then
  begin
    if(POMAdresa.ValueInt>0) and (POMAdresa.ValueInt<10239) then
    begin
      if(CVAdresa.ValueInt>0) and (CVAdresa.ValueInt<$3FF) then
      begin
        if(CVHodnota.ValueInt>=0) and (CVHodnota.Value<=$FF) then
        begin
          Enabled:=False;

          t_akt_prog:=True;
          t_akt_prog_read:=False;
          //CPort.VydajPovelEFProgram(PROG_CMD_WRIT_POM,POMAdresa.ValueInt,0,CVAdresa.ValueInt,CVHodnota.ValueInt);
          CPort.VydajPovelEDProgramPOM(False,POMAdresa.ValueInt,CVAdresa.ValueInt,CVHodnota.ValueInt);
          Stav.Caption:='Povel pre z·pis vydan˝';
          Stav.Refresh;
        end;
      end;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TProgDlg.FormCreate(Sender: TObject);
begin
  t_akt_dispatch_adresa:=0;
  t_last_dispatch_adresa:=0;
  t_akt_dispatch:=False;

  t_akt_prog:=False;
  t_akt_prog_read:=False;

  t_potlacit_bity:=False;

  Stav.Caption:='PripravenÈ';
end;

////////////////////////////////////////////////////////////////////////////////

procedure TProgDlg.FREDBtnClick(Sender: TObject);
begin
  if(FREDAdresa.ValueInt>0) and (FREDAdresa.ValueInt<10239) then
  begin
    Enabled:=False;

    t_last_dispatch_adresa:=0;
    t_akt_dispatch_adresa:=FREDAdresa.ValueInt and $7FFF;
    CPort.VydajPovelBF(t_akt_dispatch_adresa);
    Stav.Caption:='Zadanie adresy';
    Stav.Refresh;
  end;
end;

end.
