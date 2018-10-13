unit Av2CVCalcs;

//v5.15jK added some seat leak and shell pressure test calcs for Van dere End trip

// i'd like to expand these with other standards

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,
{$IFDEF ISORACLE}
     Av2DataModMain_ORA,oracle,oracledata,oraclewwdata,
{$ENDIF}
{$IFDEF ISKINTERBASE}
     Av2DataModMain_IBO,IBODataset, IB_Components, db,
{$ENDIF}
{$IFDEF ISPARADOX}
     Av2DataModMain,Wwquery,   DBTables, //v5.02K dbtables moved
{$ENDIF}
  ExtCtrls, Buttons, jpeg, RzLabel, Grids, RzGrids, RzLstBox, Mask, RzEdit,
  RzCmboBx, math;

type
  TfCVCalcs = class(TForm)
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    RzLabel1: TRzLabel;
    Label1: TLabel;
    rzcbRating: TRzComboBox;
    rzedVKRating: TRzEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    rzedVKBodyMat: TRzEdit;
    rzcbBodyMat: TRzComboBox;
    Label5: TLabel;
    Label6: TLabel;
    rzcbWHichShell: TRzComboBox;
    Label7: TLabel;
    RzComboBox4: TRzComboBox;
    lbShellTest: TLabel;
    rzShellTestP: TRzEdit;
    rzShellTime: TRzEdit;
    lbShellDur: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    rzcbSeatLeakClass: TRzComboBox;
    rzedVKSeatL: TRzEdit;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    rzedVKCv: TRzEdit;
    Label15: TLabel;
    Label16: TLabel;
    rzcbWhichSeat: TRzComboBox;
    Label17: TLabel;
    rzcbSeatLeakMedia: TRzComboBox;
    Label18: TLabel;
    rzedVKPressD: TRzEdit;
    Label19: TLabel;
    rzedVKSeatD: TRzEdit;
    lbSeatTest: TLabel;
    rzedLeakPress: TRzEdit;
    rzedLeak: TRzEdit;
    lbLeak: TLabel;
    Label22: TLabel;
    lbLeakUnit: TLabel;
    rzedCv: TRzEdit;
    rzedP: TRzEdit;
    rzedD: TRzEdit;
    Bevel1: TBevel;
    Label23: TLabel;
    rzedVKSize: TRzEdit;
    rzcbSize: TRzComboBox;
    memTestPress: TMemo;
    memHoldTime: TMemo;
    lbA: TListBox;
    SpeedButton1: TSpeedButton;
    cbPlaceShell: TCheckBox;
    cbShellResult: TComboBox;
    cbLeakResult: TComboBox;
    cbPlaceLeak: TCheckBox;
    lbTemp: TListBox;
    rzDiamMM: TRzEdit;
    Label8: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure OnChange_CalcSheCalcShell(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure recalc_Leak(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure rzcbSeatLeakClassCloseUp(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure rzDiamMMChange(Sender: TObject);
  private
    { Private declarations }
    lIgnoreOnChange: boolean;
{$IFDEF ISORACLE}
    aq: TOracleDataSet;                  // current query
{$ENDIF}
{$IFDEF ISKINTERBASE}
    aq: TIBOQuery;                  // current query
{$ENDIF}
    sFilenameS, sFilenameL: string;
  public
    { Public declarations }
  end;

var
  fCVCalcs: TfCVCalcs;

implementation

uses Av2Main, Av2EquipCommonRoutines, Av2CVDetails;


{$R *.DFM}

procedure TfCVCalcs.FormCreate(Sender: TObject);
begin
  // setup font too
  font := fMain.DefaultFont;
  font.size := 10;

  sFilenameS := fMain.sExtrasPath + 'ShellTestPlaceAt.av2';
  sFilenameL := fMain.sExtrasPath + 'LeakTestPlaceAt.av2';
end;

procedure TfCVCalcs.OnChange_CalcShell(Sender: TObject);
//CES-1001 Rev J Dec. 5, 2016
var
  i, j, iRating, iBodyMat, iSize: integer;
  s: string;
begin
  iRating := rzcbRating.itemindex;
  iBodyMat := rzcbBodyMat.itemindex;
  iSize := rzcbSize.ItemIndex;

  rzShellTestP.text := '';
  if (iRating>=0) and (iBodyMat>=0) then begin
    // loop through each line and find the material
    for i := 0 to memTestPress.Lines.Count-1 do begin
      s := memTestPress.Lines[i];
      // stupid bug in .CommaText
      s := stringReplace( s, ' ', '~', [rfReplaceall] );
      lbA.Items.Clear;
      lbA.Items.CommaText := s;
      for j := 0 to lbA.items.Count-1 do begin
        s := lbA.items[j];
        s := stringReplace( s, '~', ' ', [rfReplaceall] );
        lbA.Items[j] := s;
      end;
      // OK, we've got the list box with the columns

      //found material?
      if lbA.items[0] = rzcbBodyMat.text then begin
        rzShellTestP.text := lbA.items[1+iRating];
        break; // stop
      end;
    end;
  end;


  rzShellTime.text := '';
  if (iSize>=0) and (iRating>=0) then begin
    // loop through each line and find the size
    for i := 0 to memHoldTime.Lines.Count-1 do begin
      s := memHoldTime.Lines[i];
      // stupid bug in .CommaText
      s := stringReplace( s, ' ', '~', [rfReplaceall] );
      lbA.Items.Clear;
      lbA.Items.CommaText := s;
      for j := 0 to lbA.items.Count-1 do begin
        s := lbA.items[j];
        s := stringReplace( s, '~', ' ', [rfReplaceall] );
        lbA.Items[j] := s;
      end;
      // OK, we've got the list box with the columns

      //found material?
      if lbA.items[0] = rzcbSize.text then begin
        rzShellTime.text := lbA.items[1+iRating];
        break; // stop
      end;
    end;
  end;

end;

procedure TfCVCalcs.SpeedButton1Click(Sender: TObject);
begin
  lbA.visible := True;
  memHoldTime.Visible := true;
  memTestPress.Visible := True;
end;

procedure TfCVCalcs.rzcbSeatLeakClassCloseUp(Sender: TObject);
begin
  if rzcbSeatLeakClass.itemindex = 4 then
    //  for class V? switch to liquid
    rzcbSeatLeakMedia.itemindex := 1
  else
    // default to gas
    rzcbSeatLeakMedia.itemindex := 0;
end;

procedure TfCVCalcs.FormShow(Sender: TObject);
var
  i: integer;
  s, sCV, sSeatL: string;
begin
  try
    if (fEquip.qe.state in [dsEdit,dsInsert]) then
      aQ := fEquip.qe
    else
      aQ := fEquip.q;

    with aQ do begin
      // these most likely are where they are by defualt
      rzedVKRating.text := aQ.fieldByName( 'PressureClass' ).asstring;
      rzedVKBodyMat.text := aQ.fieldByName( 'BodyMat' ).asstring;
      rzedVKSize.text := aQ.fieldByName( 'ValveSize' ).asstring;

      //these are sometimes in other spots...find them based upon
      sCV := 'ValveCV';
      sSeatL := 'ConfigUniv';
      for i := 0 to fEquip.q.Fields.Count-1 do begin
        s := trim(uppercase( fequip.q.fields[i].DisplayName ));
        if s = 'CV' then
          sCV := fequip.q.fields[i].FieldName;
        if pos( 'CLASS', s ) <> 0 then
          if pos( 'LEAK', s) <> 0 then
            sSeatL := fequip.q.fields[i].FieldName;
      end;
      rzedVKSeatL.text := aQ.fieldByName( sSeatL ).asstring;
      rzedVKCv.text := aQ.fieldByName( sCV ).asstring;

      rzedVKPressD.text := aQ.fieldByName( 'ShutOffPDrop' ).asstring;
      rzedVKSeatD.text := aQ.fieldByName( 'SeatDiam' ).asstring;
    end;
  except
  end;

  // build the drop down FOR shell test "place results"
  cbShellResult.Items.Clear;
  cbShellResult.Items.add( fMain.avFields[283-1].UseName );
  cbShellResult.Items.add( fMain.avFields[288-1].UseName );
  cbShellResult.Items.add( fMain.avFields[293-1].UseName );
  cbShellResult.Items.add( fMain.avFields[298-1].UseName );
  cbShellResult.Items.add( fMain.avFields[1807-1].UseName );
  cbLeakResult.Items.clear;
  cbLeakResult.Items.AddStrings( cbShellResult.Items );

  if (fEquip.qe.state in [dsEdit,dsInsert]) then begin
    cbLeakResult.visible := True;
    cbShellResult.visible := True;
    cbPlaceLeak.visible := True;
    cbPlaceShell.visible := True;

    //lastly, put the drop down onto what they last chose
    try
      if FileExists( sFilenameS ) then begin
        lbTemp.Items.LoadFromFile( sFilenameS );
        try
        cbShellResult.ItemIndex := strtoint( lbTemp.Items[0] );
        except end;
      end;
      if FileExists( sFilenameL ) then begin
        lbTemp.Items.LoadFromFile( sFilenameL );
        try
        cbLeakResult.ItemIndex := strtoint( lbTemp.Items[0] );
        except end;
      end;
    except
    end;
  end;
end;

procedure TfCVCalcs.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  sF, sF1: string;
begin
  CanClose := True;
  //lastly, save the drop down onto what they last chose
  if cbplaceShell.checked or cbPlaceLeak.checked then try
    lbTemp.items.clear;
    lbTemp.items.add( inttostr( cbShellResult.ItemIndex ));
    if (cbShellResult.itemindex>=0) then
      lbTemp.Items.saveToFile( sFilenameS );

    lbTemp.items.clear;
    lbTemp.items.add( inttostr( cbLeakResult.ItemIndex ));
    if (cbLeakResult.itemindex>=0) then
      lbTemp.Items.saveToFile( sFilenameL );
  except
  end;

  // now place them
  if cbPlaceShell.checked and (cbShellResult.itemindex>=0) then begin
    if cbShellResult.itemindex = 0 then
      // 283, first one
      sF := 'Seat1';
    if cbShellResult.itemindex = 1 then
      // 288
      sF := 'Seat2';
    if cbShellResult.itemindex = 2 then
      // 293
      sF := 'BackSeat';
    if cbShellResult.itemindex = 3 then
      // 298
      sF := 'Hydro';
    if cbShellResult.itemindex = 4 then
      // 1807
      sF := 'Extra';

    fequip.qe.fieldByName( sf+'Test').asstring := rzShellTestP.text;
    fequip.qe.fieldByName( sf+'Proc').asstring := rzcbWhichShell.text;

    if cbShellResult.itemindex = 3 then
      // spelling error in table's fieldName for HydroHoldTm...it's: HyrdoHoldTm
      sF := 'Hyrdo';

    fequip.qe.fieldByName( sf+'HoldTm').asstring := rzShellTime.text;
  end;

  if cbPlaceLeak.checked and (cbLeakResult.itemindex>=0) then begin
    if cbLeakResult.itemindex = 0 then
      // 283, first one
      sF := 'Seat1';
    if cbLeakResult.itemindex = 1 then
      // 288
      sF := 'Seat2';
    if cbLeakResult.itemindex = 2 then
      // 293
      sF := 'BackSeat';
    if cbLeakResult.itemindex = 3 then
      // 298
      sF := 'Hydro';
    if cbLeakResult.itemindex = 4 then
      // 1807
      sF := 'Extra';

    fequip.qe.fieldByName( sF+'Test').asstring := rzedLeakPress.text;
    fequip.qe.fieldByName( sF+'AlwLeak').asstring := rzedLeak.text;
    fequip.qe.fieldByName( sf+'Proc').asstring := rzcbWhichSeat.text;

    if uppercase(lbLeakUnit.Caption) <> uppercase(trim(fequip.qe.fieldByName( 'E2').asstring)) then begin
      MessageDlg( 'Allowable Leak Rate UNIT of measure not same as here, it has been changed'+#13#10+
                  'from '+uppercase(trim(fequip.qe.fieldByName( 'E2').asstring))+'  TO  '+lbLeakUnit.Caption, mtinformation, [mbok], 0 );
      fequip.qe.fieldByName( 'E2').asstring :=  lbLeakUnit.Caption;
    end;
  end;
end;

procedure TfCVCalcs.recalc_Leak(Sender: TObject);
//CES 1002 Rev H... kelly chekced formulas Dec. 5, 2016 against Rev H...fine
var
  iLeakC, iD: integer;
  dCV, dSP, dSD, dPress, dLeak: double;
  Y1, Y2, Y3, X1, X2, X3: double;
  s: string;
begin
  rzedCv.enabled := True;
  rzedP.enabled := True;
  rzedD.enabled := True;

  rzedLeakPress.text := '';
  rzedLeak.text := '';
  lbLeakUnit.caption := '';
  dLeak := -10.0;

  iLeakC := rzcbSeatLeakClass.itemindex;

  lbLeakUnit.Caption := 'SCFH';
  if rzcbSeatLeakMedia.ItemIndex = 1 then
    lbLeakUnit.Caption := 'US G/MIN';

  if iLeakC <0 then
    exit;

  rzedLeakPress.text := '50';

  
  if iLeakC = 4 then begin
    // V
    rzedLeakPress.text := rzedP.text ;
  end;

  // the inputs are setup

  // try and do the calc
  if NOT TryStrToFloat( rzedP.text, dSP ) then
    dSP := -10.0;
  if NOT TryStrToFloat( rzedCV.text, dCV ) then
    dCV := -10.0;
  if NOT TryStrToFloat( rzedD.text, dSD ) then
    dSD := -10.0;

  if (iLeakC = 0) and (dCV>0.0) then begin
    // II
    if rzcbSeatLeakMedia.itemindex = 0 then begin
      // gas  SCFM * 60 = SCFH
      dLeak := 0.158 * dCV * 60.0;
      end
    else begin
      // liquid            GPM
      dLeak := 3.2*power(10,-2) * dCV;
    end;
  end;

  if (iLeakC = 1) and (dCV>0.0) then begin
    // III
    if rzcbSeatLeakMedia.itemindex = 0 then begin
      // gas
      dLeak := 3.15*power(10,-2) * dCV * 60.0;
      end
    else begin
      // liquid
      dLeak := 6.4*power(10,-3) * dCV;
    end;
  end;

  if (iLeakC = 2) and (dCV>0.0) then begin
    // IV
    if rzcbSeatLeakMedia.itemindex = 0 then begin
      // gas
      dLeak := 3.15*power(10,-3) * dCV * 60.0;
      end
    else begin
      // liquid
      dLeak := 6.4*power(10,-4) * dCV;
    end;
  end;

  if (iLeakC = 3) and (dCV>0.0) then begin
    // IV-S1
    if rzcbSeatLeakMedia.itemindex = 0 then begin
      // gas
      dLeak := 0.158*power(10,-3) * dCV * 60.0;
      end
    else begin
      // liquid
      dLeak := 3.2*power(10,-5) * dCV;
    end;
  end;

  if (iLeakC = 4) and (dSD>0.0) then begin
    // V// V
    if rzcbSeatLeakMedia.itemindex = 0 then begin
      // gas       does not need::    and (dSP>0.0)
      dLeak := 4.7*dSD; //ML/MIN air
      lbLeakUnit.Caption := 'ML/MIN, Air'+#13#10+' = '+formatfloat( '#.000000', 0.00211888*dLeak )+' FT^3/HR';
      end
    else begin
      // liquid
      if (dSP>0.0) then begin
        lbLeakUnit.Caption := 'ML/MIN, Water';
        dLeak := 5.0*power(10,-4)*dSD*dsP;
        end
      else begin
        // no cause this is an OnChange() fired method
        //messageDlg( 'missing "shut off prressure drop"', mtinformation, [mbok], 0 );
      end;
    end;
  end;

  if (iLeakC = 5) and (dSD>0.0)  then begin
    // VI
    lbLeakUnit.Caption := 'BPM';

    if dSD <= 1.080001 then begin
      dLeak := 1.0;
      end
    else if dSD <= 1.580001 then begin
      dLeak := 2.0;
      end
    else if dSD <= 2.080001 then begin
      dLeak := 3.0;
      end
    else if dSD <= 2.580001 then begin
      dLeak := 4.0;
      end
    else begin
      // ok, we need to handle otherwise
      dLeak := -11.0;
      if dSD > 16.08 then
        rzedLeak.text := 'Factory?';
      // hit all the "on" numbers +- 0.08 of an inch
      if (dSD >= (3.0-0.080001)) and (dSD <= (3.0+0.080001)) then
        dLeak := 6.0;
      if (dSD >= (4.0-0.080001)) and (dSD <= (4.0+0.080001)) then
        dLeak := 11.0;
      if (dSD >= (6.0-0.080001)) and (dSD <= (6.0+0.080001)) then
        dLeak := 27.0;
      if (dSD >= (8.0-0.080001)) and (dSD <= (8.0+0.080001)) then
        dLeak := 45.0;
      if (dSD >= (10.0-0.080001)) and (dSD <= (10.0+0.080001)) then
        dLeak := 74.0;
      if (dSD >= (12.0-0.080001)) and (dSD <= (12.0+0.080001)) then
        dLeak := 107.0;
      if (dSD >= (14.0-0.080001)) and (dSD <= (14.0+0.080001)) then
        dLeak := 144.0;
      if (dSD >= (16.0-0.080001)) and (dSD <= (16.0+0.080001)) then
        dLeak := 190.0;
    end;

    if (dLeak<-10.0) and (dLeak>-12.0) then begin

       x2 := dSD * dSD;
       if (x2>=4.0) and (x2<=6.25) then begin
         x1 := 4.0; x3 := 6.25; y1 := 3.0; y3 := 4.0;
       end;
       if (x2>6.25) and (x2<=9.0) then begin
         x1 := 6.25; x3 := 9.0; y1 := 4.0; y3 := 6.0;
       end;
       if (x2>9.0) and (x2<=16.0) then begin
         x1 := 9.0; x3 := 16.0; y1 := 6.0; y3 := 11.0;
       end;
       if (x2>16.0) and (x2<=36.0) then begin
         x1 := 16.0; x3 := 36.0; y1 := 11.0; y3 := 27.0;
       end;
       if (x2>36.0) and (x2<=64.0) then begin
         x1 := 36.0; x3 := 64.0; y1 := 27.0; y3 := 45.0;
       end;
       if (x2>64.0) and (x2<=100.0) then begin
         x1 := 64.0; x3 := 100.0; y1 := 45.0; y3 := 74.0;
       end;
       if (x2>100.0) and (x2<=144.0) then begin
         x1 := 100.0; x3 := 144.0; y1 := 74.0; y3 := 107.0;
       end;
       if (x2>144.0) and (x2<=196.0) then begin
         x1 := 144.0; x3 := 196.0; y1 := 107.0; y3 := 144.0;
       end;
       if (x2>196.0) and (x2<=256.0) then begin
         x1 := 196.0; x3 := 256.0; y1 := 144.0; y3 := 190.0;
       end;
       try
         // let's take the "int" as it's smaller than the value; ie. more conservative.
         y2 := int( y1 + ( (x2-x1) * (y3-y1) / (x3 - x1) ) );
         dLeak := y2;
       except
         MessageDlg( 'contact support '+exception(exceptobject).message, mtError, [mbOK], 0 );
         y2 := -1.0;
         rzedLeak.text := 'Factory?';
       end;
    end;

    
  end;

  if dLeak > 0 then begin
    rzedLeak.text := formatFloat( '#.00', dLeak );
  end;
end;

procedure TfCVCalcs.rzDiamMMChange(Sender: TObject);
var
  dDiamMM, dIN: double;
begin
  if rzcbSeatLeakClass.itemindex <> 5 then
    // ONLY for leakage class VI
    exit;

  // convert MM to IN and plug them in...
  if TryStrToFloat( rzDiamMM.text, dDiamMM ) then begin
    // it was a number...
    dIn := dDiamMM * 0.0393701;

 
    if round( dDiamMM ) = 25.0 then
      dIN := 1.0;
    if round( dDiamMM ) = 40.0 then
      dIN := 1.5;
    if round( dDiamMM ) = 50.0 then
      dIN := 2.0;
    if round( dDiamMM ) = 65.0 then
      dIN := 2.5;
    if round( dDiamMM ) = 80.0 then
      dIN := 3.0;
    if round( dDiamMM ) = 100.0 then
      dIN := 4.0;
    if round( dDiamMM ) = 150.0 then
      dIN := 6.0;
    if round( dDiamMM ) = 200.0 then
      dIN := 8.0;
    if round( dDiamMM ) = 250.0 then
      dIN := 10.0;
    if round( dDiamMM ) = 300.0 then
      dIN := 12.0;
    if round( dDiamMM ) = 350.0 then
      dIN := 14.0;
    if round( dDiamMM ) = 400.0 then
      dIN := 16.0;

    rzedD.Text := formatfloat( '0.00', dIN );
  end;
end;

end.

{
Orifice Diameter Allowable Leakage

9.6 Class VI

Class VI establishes the maximum permissible seat leakage generally associated with resilient
seating control valves.

If the valve orifice diameter differs by more than 2 mm (0.08 in) from the values listed, the
leakage rate may be obtained by interpolation, assuming that the leakage rate varies as the
square of the orifice diameter.

  x1, x2, x3             y1, y3...looking for BPM for given diam = y2

mm      inch    ml/min  Bubbles per min*
25	1	0.15	1
40	1.5	0.3	2
50	2	0.45	3
65	2.5	0.6	4
80	3	0.9	6
100	4	1.7	11
150	6	4	27
200	8	6.5	45
250	10	11	74
300	12	16	107
350	14	21	144
400	16	28	190


y2 = y1 + ( (x2-x1) (y3-y1) / (x3 - x1) )
}