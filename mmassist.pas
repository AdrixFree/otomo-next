///////////////////////////////////////////////////////////
//
//                          OTOMO
//               Radar + Assit for Interlude
//                by LanGhost (c) 2020-2021
//
///////////////////////////////////////////////////////////

unit MMAssist;

interface

uses
    Helpers, Classes, Packets;

const
    MYSTIC_ASSIST_SKILLS = 4;

type
    TAssistSpell = class
    private
        OID: cardinal;
        Skill: cardinal;
    public
        constructor Create(o: cardinal; s: cardinal);
        function GetOID(): cardinal;
        function GetSkill(): cardinal;
    end;

    TMysticAssist = class
    private
        IsAssistStatus: boolean;
        IsMoveToAss: boolean;
        AssistSpells: TList;
        PartyAssisters: TStringList;
        ArcaneChaos: boolean;
        PosDelta: integer;
        AssistSkills: array[1..MYSTIC_ASSIST_SKILLS] of integer;
    public
        procedure AddAssister(name: string);
        procedure SetAssistStatus(status: boolean);
        procedure SetArcaneChaos(status: boolean);
        procedure SetMoveToAssister(status: boolean);
        procedure ClearAssisters();
        function GetArcaneChaos(): boolean;
        function GetAssistStatus(): boolean;
        function GetMoveToAssister(): boolean;

        constructor Create();
        procedure AssistAttack();
        procedure AssistSpell();
        procedure AssistPacket(data: pointer; size: word);
        procedure MoveToAssister();
    end;

implementation

const
    ASSIST_SKILL_RETRIES = 30;

///////////////////////////////////////////////////////////
//
//                        PUBLIC VARS
//
///////////////////////////////////////////////////////////

procedure TMysticAssist.AddAssister(name: string);
begin
    PrintBotMsg('Add assister: ' + name);
    self.PartyAssisters.Add(name);
end;

procedure TMysticAssist.ClearAssisters();
begin
    PrintBotMsg('Clear assisters list');
    self.PartyAssisters.Clear();
end;

procedure TMysticAssist.SetMoveToAssister(status: boolean);
begin
    if (status <> self.IsMoveToAss)
    then begin
        if (status)
        then PrintBotMsg('Move to assister: ON')
        else PrintBotMsg('Move to assister: OFF');
    end;

    self.IsMoveToAss := status;
end;

function TMysticAssist.GetMoveToAssister(): boolean;
begin
    result := self.IsMoveToAss;
end;

procedure TMysticAssist.SetAssistStatus(status: boolean);
begin
    if (status <> self.IsAssistStatus)
    then begin
        if (status)
        then PrintBotMsg('Auto assist: ON')
        else PrintBotMsg('Auto assist: OFF');
    end;

    self.IsAssistStatus := status;
end;

procedure TMysticAssist.SetArcaneChaos(status: boolean);
begin
    if (status <> self.ArcaneChaos)
    then begin
        if (status)
        then PrintBotMsg('Arcane chaos: ON')
        else PrintBotMsg('Arcane chaos: OFF');
    end;

    self.ArcaneChaos := status;
end;

function TMysticAssist.GetArcaneChaos(): boolean;
begin
    result := self.ArcaneChaos;
end;

function TMysticAssist.GetAssistStatus(): boolean;
begin
    result := self.IsAssistStatus;
end;

///////////////////////////////////////////////////////////
//
//                    PUBLIC FUNCTIONS
//
///////////////////////////////////////////////////////////

constructor  TMysticAssist.Create();
begin
    inherited;

    self.PartyAssisters := TStringList.Create();
    self.AssistSpells := TList.Create();

    self.AssistSkills[1] := CANCEL_SKILL;
    self.AssistSkills[2] := AURA_SYMPHONY_SKILL;
    self.AssistSkills[3] := SPELL_FORCE_SKILL;
    self.AssistSkills[4] := ARCANE_CHAOS_SKILL;

    self.PosDelta := Random(10);
end;

procedure TMysticAssist.AssistPacket(data: pointer; size: word);
var
    packet: TNetworkPacket;
    oid, skill, i: cardinal;
    spell: TAssistSpell;
begin
    packet := TNetworkPacket.Create(data, size);
    oid := packet.ReadD();
    packet.ReadD();
    skill := packet.ReadD();
    packet.Free();

    for i := 1 to ASSIST_SKILL_RETRIES do
    begin
        if (skill = self.AssistSkills[i])
        then begin
            spell := TAssistSpell.Create(oid, skill);
            self.AssistSpells.Add(Pointer(spell));
            exit;
        end;
    end;
end;

procedure TMysticAssist.AssistSpell();
var
    target: TL2Char;
    skill, chaos : TL2Skill;
    i, j, k: integer;
begin
    for i := 0 to self.PartyAssisters.Count - 1 do
    begin
        if (CharList.ByName(self.PartyAssisters[i], target))
        then begin
            if (not target.Dead) and (target.Target.Name <> target.Name)
            then begin
                for j := 0 to self.AssistSpells.Count - 1 do
                begin
                    if (j > self.AssistSpells.Count - 1)
                    then break;

                    if (target.OID = TAssistSpell(AssistSpells[j]).GetOID())
                    then begin
                        if (TAssistSpell(AssistSpells[j]).GetSkill() = CANCEL_SKILL)
                            or (TAssistSpell(AssistSpells[j]).GetSkill() = ARCANE_CHAOS_SKILL)
                        then begin
                            for k := 1 to ASSIST_SKILL_RETRIES do
                            begin
                                delay(100);
                                Engine.GetSkillList.ByID(CANCEL_SKILL, skill);

                                if (not UserValid())
                                then break;

                                if (ArcaneChaos)
                                then begin
                                    Engine.GetSkillList.ByID(ARCANE_CHAOS_SKILL, chaos);
                                    if (chaos.EndTime = 0)
                                    then Engine.DUseSkill(ARCANE_CHAOS_SKILL, false, false)
                                    else Engine.DUseSkill(CANCEL_SKILL, false, false);
                                end
                                else Engine.DUseSkill(CANCEL_SKILL, false, false);

                                if (skill.EndTime > 0) or (User.Dead)
                                then break;
                            end;
                        end else
                        begin
                            for k := 1 to ASSIST_SKILL_RETRIES do
                            begin
                                delay(100);

                                if (not UserValid())
                                then break;

                                Engine.GetSkillList.ByID(TAssistSpell(AssistSpells[j]).GetSkill(), skill);
                                Engine.DUseSkill(TAssistSpell(AssistSpells[j]).GetSkill(), false, false);

                                if (skill.EndTime > 0)
                                then break;
                            end;
                        end;
                    end;

                    TAssistSpell(self.AssistSpells[j]).Free();
                    self.AssistSpells.Delete(j);
                end;
                break;
            end;
        end;
    end;
end;

procedure TMysticAssist.AssistAttack();
var
    target: TL2Char;
    i: integer;
begin
    if (self.IsAssistStatus)
    then begin
        for i := 0 to self.PartyAssisters.Count - 1 do
        begin
            if (CharList.ByName(self.PartyAssisters[i], target))
            then begin
                if (not target.Dead()) and (target.Target.Name <> target.Name)
                then begin
                    if (not UserValid())
                    then break;

                    Engine.Assist(target.Name());
                    break;
                end;
            end;
        end;
    end;
end;

procedure TMysticAssist.MoveToAssister();
var
    i: integer;
    target: TL2Char;
begin
    for i := 0 to self.PartyAssisters.Count - 1 do
    begin
        if (CharList.ByName(self.PartyAssisters[i], target))
        then begin
            if (not target.Dead)
            then begin
                if (not UserValid())
                then break;

                Engine.DMoveTo(target.X - (5 + self.PosDelta), target.Y + (5 + self.PosDelta), target.Z);
                break;
            end;
        end;
    end;
end;

///////////////////////////////////////////////////////////
//
//                    PRIVATE FUNCTIONS
//
///////////////////////////////////////////////////////////

constructor TAssistSpell.Create(o: cardinal; s: cardinal);
begin
    inherited Create;

    OID := o;
    Skill := s;
end;

function TAssistSpell.GetOID(): cardinal;
begin
    result := OID;
end;

function TAssistSpell.GetSkill(): cardinal;
begin
    result := Skill;
end;

end.