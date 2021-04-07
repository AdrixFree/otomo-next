
///////////////////////////////////////////////////////////
//
//                          OTOMO
//               Radar + Assit for Interlude
//                  by LanGhost (c) 2020
//
///////////////////////////////////////////////////////////

unit Back;

interface

uses
    Classes, Helpers, Players, Packets;

type
    TBacklight = class
    private
        IsShowAssist: boolean;
        Assisters: TList;
        procedure ShowTitle();
    public
        constructor Create();
        procedure SetShowAssist(isShow: boolean);
        procedure OnPacket(id: cardinal; data: pointer; size: word);
        procedure ShowTitlesThread();
    end;

var
    Backlight: TBacklight;

implementation

const
    MAX_ASSISTERS = 50;

///////////////////////////////////////////////////////////
//
//                        PUBLIC VARS
//
///////////////////////////////////////////////////////////

procedure TBacklight.SetShowAssist(isShow: boolean);
begin
    if (isShow <> self.IsShowAssist)
    then begin
        if (isShow)
        then PrintBotMsg('Show assisters: ON')
        else PrintBotMsg('Show assisters: OFF');
    end;

    self.IsShowAssist := isShow;
end;

///////////////////////////////////////////////////////////
//
//                      PUBLIC FUNCTIONS
//
///////////////////////////////////////////////////////////

constructor TBacklight.Create();
begin
    inherited;

    self.Assisters := TList.Create();

    SetShowAssist(true);
end;

procedure TBacklight.OnPacket(id: cardinal; data: pointer; size: word);
var
    player: TPlayer;
    i: integer;
    skill, oid: cardinal;
    found: boolean;
    packet: TNetworkPacket;
begin
    if (id = MAGIC_SKILL_USE_PACKET)
    then begin
        packet := TNetworkPacket.Create(data, size);

        oid := packet.ReadD();
        packet.ReadD();
        skill := packet.ReadD();

        // Find assisters
        if (skill = SURRENDER_WATER_SKILL)
        then begin
            found := false;
            for i := 0 to self.Assisters.Count - 1 do
            begin
                if (oid = Cardinal(self.Assisters[i]))
                then begin
                    found := true;
                    break;
                end;
            end;

            if (not found)
            then begin
                if (self.Assisters.Count > MAX_ASSISTERS)
                then self.Assisters.Delete(MAX_ASSISTERS);
                self.Assisters.Insert(0, Pointer(oid));
            end;
        end;

        // Anti fake assisters
        if (skill = LIGHT_VORTEX_SKILL)
            or (skill = ICE_VORTEX_SKILL)
        then begin
            for i := 0 to self.Assisters.Count - 1 do
            begin
                if (i > self.Assisters.Count - 1)
                then break;

                if (oid = Cardinal(self.Assisters[i]))
                then self.Assisters.Delete(i);
            end;
        end;

        packet.Free();
    end;
end;

procedure TBacklight.ShowTitlesThread();
begin
    while true do
    begin
        self.ShowTitle();
        delay(1000);
    end;
end;

///////////////////////////////////////////////////////////
//
//                      PRIVATE FUNCTIONS
//
///////////////////////////////////////////////////////////

procedure TBacklight.ShowTitle();
var
    i, j: integer;
    target: TL2Char;
    found: boolean;
begin
    for i := 0 to CharList.Count - 1 do
    begin
        target := CharList.Items(i);

        if (self.IsShowAssist)
        then begin
            for j := 0 to self.Assisters.Count - 1 do
            begin
                if (j > self.Assisters.Count - 1)
                then break;

                if (target.OID() = Cardinal(self.Assisters[j]))
                then begin
                    if (target.ClanID() = User.ClanID)
                    then self.Assisters.Delete(j)
                    else
                    begin
                        SendTitle(target.OID(), '>>> ASSISTER <<<');
                        delay(10);
                    end;
                    break;
                end;
            end;
        end;
    end;
end;

end.